7750 // Console input and output.
7751 // Input is from the keyboard or serial port.
7752 // Output is written to the screen and serial port.
7753 
7754 #include "types.h"
7755 #include "defs.h"
7756 #include "param.h"
7757 #include "traps.h"
7758 #include "spinlock.h"
7759 #include "fs.h"
7760 #include "file.h"
7761 #include "memlayout.h"
7762 #include "mmu.h"
7763 #include "proc.h"
7764 #include "x86.h"
7765 
7766 static void consputc(int);
7767 
7768 static int panicked = 0;
7769 
7770 static struct {
7771   struct spinlock lock;
7772   int locking;
7773 } cons;
7774 
7775 static void
7776 printint(int xx, int base, int sign)
7777 {
7778   static char digits[] = "0123456789abcdef";
7779   char buf[16];
7780   int i;
7781   uint x;
7782 
7783   if(sign && (sign = xx < 0))
7784     x = -xx;
7785   else
7786     x = xx;
7787 
7788   i = 0;
7789   do{
7790     buf[i++] = digits[x % base];
7791   }while((x /= base) != 0);
7792 
7793   if(sign)
7794     buf[i++] = '-';
7795 
7796   while(--i >= 0)
7797     consputc(buf[i]);
7798 }
7799 
7800 // Print to the console. only understands %d, %x, %p, %s.
7801 void
7802 cprintf(char *fmt, ...)
7803 {
7804   int i, c, locking;
7805   uint *argp;
7806   char *s;
7807 
7808   locking = cons.locking;
7809   if(locking)
7810     acquire(&cons.lock);
7811 
7812   if (fmt == 0)
7813     panic("null fmt");
7814 
7815   argp = (uint*)(void*)(&fmt + 1);
7816   for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
7817     if(c != '%'){
7818       consputc(c);
7819       continue;
7820     }
7821     c = fmt[++i] & 0xff;
7822     if(c == 0)
7823       break;
7824     switch(c){
7825     case 'd':
7826       printint(*argp++, 10, 1);
7827       break;
7828     case 'x':
7829     case 'p':
7830       printint(*argp++, 16, 0);
7831       break;
7832     case 's':
7833       if((s = (char*)*argp++) == 0)
7834         s = "(null)";
7835       for(; *s; s++)
7836         consputc(*s);
7837       break;
7838     case '%':
7839       consputc('%');
7840       break;
7841     default:
7842       // Print unknown % sequence to draw attention.
7843       consputc('%');
7844       consputc(c);
7845       break;
7846     }
7847   }
7848 
7849 
7850   if(locking)
7851     release(&cons.lock);
7852 }
7853 
7854 void
7855 panic(char *s)
7856 {
7857   int i;
7858   uint pcs[10];
7859 
7860   cli();
7861   cons.locking = 0;
7862   cprintf("cpu%d: panic: ", cpu->id);
7863   cprintf(s);
7864   cprintf("\n");
7865   getcallerpcs(&s, pcs);
7866   for(i=0; i<10; i++)
7867     cprintf(" %p", pcs[i]);
7868   panicked = 1; // freeze other CPU
7869   for(;;)
7870     ;
7871 }
7872 
7873 #define BACKSPACE 0x100
7874 #define CRTPORT 0x3d4
7875 static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
7876 
7877 static void
7878 cgaputc(int c)
7879 {
7880   int pos;
7881 
7882   // Cursor position: col + 80*row.
7883   outb(CRTPORT, 14);
7884   pos = inb(CRTPORT+1) << 8;
7885   outb(CRTPORT, 15);
7886   pos |= inb(CRTPORT+1);
7887 
7888   if(c == '\n')
7889     pos += 80 - pos%80;
7890   else if(c == BACKSPACE){
7891     if(pos > 0) --pos;
7892   } else
7893     crt[pos++] = (c&0xff) | 0x0700;  // black on white
7894 
7895   if(pos < 0 || pos > 25*80)
7896     panic("pos under/overflow");
7897 
7898 
7899 
7900   if((pos/80) >= 24){  // Scroll up.
7901     memmove(crt, crt+80, sizeof(crt[0])*23*80);
7902     pos -= 80;
7903     memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
7904   }
7905 
7906   outb(CRTPORT, 14);
7907   outb(CRTPORT+1, pos>>8);
7908   outb(CRTPORT, 15);
7909   outb(CRTPORT+1, pos);
7910   crt[pos] = ' ' | 0x0700;
7911 }
7912 
7913 void
7914 consputc(int c)
7915 {
7916   if(panicked){
7917     cli();
7918     for(;;)
7919       ;
7920   }
7921 
7922   if(c == BACKSPACE){
7923     uartputc('\b'); uartputc(' '); uartputc('\b');
7924   } else
7925     uartputc(c);
7926   cgaputc(c);
7927 }
7928 
7929 #define INPUT_BUF 128
7930 struct {
7931   char buf[INPUT_BUF];
7932   uint r;  // Read index
7933   uint w;  // Write index
7934   uint e;  // Edit index
7935 } input;
7936 
7937 #define C(x)  ((x)-'@')  // Control-x
7938 
7939 void
7940 consoleintr(int (*getc)(void))
7941 {
7942   int c, doprocdump = 0;
7943 
7944   acquire(&cons.lock);
7945   while((c = getc()) >= 0){
7946     switch(c){
7947     case C('P'):  // Process listing.
7948       doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
7949       break;
7950     case C('U'):  // Kill line.
7951       while(input.e != input.w &&
7952             input.buf[(input.e-1) % INPUT_BUF] != '\n'){
7953         input.e--;
7954         consputc(BACKSPACE);
7955       }
7956       break;
7957     case C('H'): case '\x7f':  // Backspace
7958       if(input.e != input.w){
7959         input.e--;
7960         consputc(BACKSPACE);
7961       }
7962       break;
7963     default:
7964       if(c != 0 && input.e-input.r < INPUT_BUF){
7965         c = (c == '\r') ? '\n' : c;
7966         input.buf[input.e++ % INPUT_BUF] = c;
7967         consputc(c);
7968         if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
7969           input.w = input.e;
7970           wakeup(&input.r);
7971         }
7972       }
7973       break;
7974     }
7975   }
7976   release(&cons.lock);
7977   if(doprocdump) {
7978     procdump();  // now call procdump() wo. cons.lock held
7979   }
7980 }
7981 
7982 int
7983 consoleread(struct inode *ip, char *dst, int n)
7984 {
7985   uint target;
7986   int c;
7987 
7988   iunlock(ip);
7989   target = n;
7990   acquire(&cons.lock);
7991   while(n > 0){
7992     while(input.r == input.w){
7993       if(proc->killed){
7994         release(&cons.lock);
7995         ilock(ip);
7996         return -1;
7997       }
7998       sleep(&input.r, &cons.lock);
7999     }
8000     c = input.buf[input.r++ % INPUT_BUF];
8001     if(c == C('D')){  // EOF
8002       if(n < target){
8003         // Save ^D for next time, to make sure
8004         // caller gets a 0-byte result.
8005         input.r--;
8006       }
8007       break;
8008     }
8009     *dst++ = c;
8010     --n;
8011     if(c == '\n')
8012       break;
8013   }
8014   release(&cons.lock);
8015   ilock(ip);
8016 
8017   return target - n;
8018 }
8019 
8020 int
8021 consolewrite(struct inode *ip, char *buf, int n)
8022 {
8023   int i;
8024 
8025   iunlock(ip);
8026   acquire(&cons.lock);
8027   for(i = 0; i < n; i++)
8028     consputc(buf[i] & 0xff);
8029   release(&cons.lock);
8030   ilock(ip);
8031 
8032   return n;
8033 }
8034 
8035 void
8036 consoleinit(void)
8037 {
8038   initlock(&cons.lock, "console");
8039 
8040   devsw[CONSOLE].write = consolewrite;
8041   devsw[CONSOLE].read = consoleread;
8042   cons.locking = 1;
8043 
8044   picenable(IRQ_KBD);
8045   ioapicenable(IRQ_KBD, 0);
8046 }
8047 
8048 
8049 
