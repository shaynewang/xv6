7450 // Console input and output.
7451 // Input is from the keyboard or serial port.
7452 // Output is written to the screen and serial port.
7453 
7454 #include "types.h"
7455 #include "defs.h"
7456 #include "param.h"
7457 #include "traps.h"
7458 #include "spinlock.h"
7459 #include "fs.h"
7460 #include "file.h"
7461 #include "memlayout.h"
7462 #include "mmu.h"
7463 #include "proc.h"
7464 #include "x86.h"
7465 
7466 static void consputc(int);
7467 
7468 static int panicked = 0;
7469 
7470 static struct {
7471   struct spinlock lock;
7472   int locking;
7473 } cons;
7474 
7475 static void
7476 printint(int xx, int base, int sign)
7477 {
7478   static char digits[] = "0123456789abcdef";
7479   char buf[16];
7480   int i;
7481   uint x;
7482 
7483   if(sign && (sign = xx < 0))
7484     x = -xx;
7485   else
7486     x = xx;
7487 
7488   i = 0;
7489   do{
7490     buf[i++] = digits[x % base];
7491   }while((x /= base) != 0);
7492 
7493   if(sign)
7494     buf[i++] = '-';
7495 
7496   while(--i >= 0)
7497     consputc(buf[i]);
7498 }
7499 
7500 // Print to the console. only understands %d, %x, %p, %s.
7501 void
7502 cprintf(char *fmt, ...)
7503 {
7504   int i, c, locking;
7505   uint *argp;
7506   char *s;
7507 
7508   locking = cons.locking;
7509   if(locking)
7510     acquire(&cons.lock);
7511 
7512   if (fmt == 0)
7513     panic("null fmt");
7514 
7515   argp = (uint*)(void*)(&fmt + 1);
7516   for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
7517     if(c != '%'){
7518       consputc(c);
7519       continue;
7520     }
7521     c = fmt[++i] & 0xff;
7522     if(c == 0)
7523       break;
7524     switch(c){
7525     case 'd':
7526       printint(*argp++, 10, 1);
7527       break;
7528     case 'x':
7529     case 'p':
7530       printint(*argp++, 16, 0);
7531       break;
7532     case 's':
7533       if((s = (char*)*argp++) == 0)
7534         s = "(null)";
7535       for(; *s; s++)
7536         consputc(*s);
7537       break;
7538     case '%':
7539       consputc('%');
7540       break;
7541     default:
7542       // Print unknown % sequence to draw attention.
7543       consputc('%');
7544       consputc(c);
7545       break;
7546     }
7547   }
7548 
7549 
7550   if(locking)
7551     release(&cons.lock);
7552 }
7553 
7554 void
7555 panic(char *s)
7556 {
7557   int i;
7558   uint pcs[10];
7559 
7560   cli();
7561   cons.locking = 0;
7562   cprintf("cpu%d: panic: ", cpu->id);
7563   cprintf(s);
7564   cprintf("\n");
7565   getcallerpcs(&s, pcs);
7566   for(i=0; i<10; i++)
7567     cprintf(" %p", pcs[i]);
7568   panicked = 1; // freeze other CPU
7569   for(;;)
7570     ;
7571 }
7572 
7573 #define BACKSPACE 0x100
7574 #define CRTPORT 0x3d4
7575 static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
7576 
7577 static void
7578 cgaputc(int c)
7579 {
7580   int pos;
7581 
7582   // Cursor position: col + 80*row.
7583   outb(CRTPORT, 14);
7584   pos = inb(CRTPORT+1) << 8;
7585   outb(CRTPORT, 15);
7586   pos |= inb(CRTPORT+1);
7587 
7588   if(c == '\n')
7589     pos += 80 - pos%80;
7590   else if(c == BACKSPACE){
7591     if(pos > 0) --pos;
7592   } else
7593     crt[pos++] = (c&0xff) | 0x0700;  // black on white
7594 
7595   if(pos < 0 || pos > 25*80)
7596     panic("pos under/overflow");
7597 
7598 
7599 
7600   if((pos/80) >= 24){  // Scroll up.
7601     memmove(crt, crt+80, sizeof(crt[0])*23*80);
7602     pos -= 80;
7603     memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
7604   }
7605 
7606   outb(CRTPORT, 14);
7607   outb(CRTPORT+1, pos>>8);
7608   outb(CRTPORT, 15);
7609   outb(CRTPORT+1, pos);
7610   crt[pos] = ' ' | 0x0700;
7611 }
7612 
7613 void
7614 consputc(int c)
7615 {
7616   if(panicked){
7617     cli();
7618     for(;;)
7619       ;
7620   }
7621 
7622   if(c == BACKSPACE){
7623     uartputc('\b'); uartputc(' '); uartputc('\b');
7624   } else
7625     uartputc(c);
7626   cgaputc(c);
7627 }
7628 
7629 #define INPUT_BUF 128
7630 struct {
7631   char buf[INPUT_BUF];
7632   uint r;  // Read index
7633   uint w;  // Write index
7634   uint e;  // Edit index
7635 } input;
7636 
7637 #define C(x)  ((x)-'@')  // Control-x
7638 
7639 void
7640 consoleintr(int (*getc)(void))
7641 {
7642   int c, doprocdump = 0;
7643 
7644   acquire(&cons.lock);
7645   while((c = getc()) >= 0){
7646     switch(c){
7647     case C('P'):  // Process listing.
7648       doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
7649       break;
7650     case C('U'):  // Kill line.
7651       while(input.e != input.w &&
7652             input.buf[(input.e-1) % INPUT_BUF] != '\n'){
7653         input.e--;
7654         consputc(BACKSPACE);
7655       }
7656       break;
7657     case C('H'): case '\x7f':  // Backspace
7658       if(input.e != input.w){
7659         input.e--;
7660         consputc(BACKSPACE);
7661       }
7662       break;
7663     default:
7664       if(c != 0 && input.e-input.r < INPUT_BUF){
7665         c = (c == '\r') ? '\n' : c;
7666         input.buf[input.e++ % INPUT_BUF] = c;
7667         consputc(c);
7668         if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
7669           input.w = input.e;
7670           wakeup(&input.r);
7671         }
7672       }
7673       break;
7674     }
7675   }
7676   release(&cons.lock);
7677   if(doprocdump) {
7678     procdump();  // now call procdump() wo. cons.lock held
7679   }
7680 }
7681 
7682 int
7683 consoleread(struct inode *ip, char *dst, int n)
7684 {
7685   uint target;
7686   int c;
7687 
7688   iunlock(ip);
7689   target = n;
7690   acquire(&cons.lock);
7691   while(n > 0){
7692     while(input.r == input.w){
7693       if(proc->killed){
7694         release(&cons.lock);
7695         ilock(ip);
7696         return -1;
7697       }
7698       sleep(&input.r, &cons.lock);
7699     }
7700     c = input.buf[input.r++ % INPUT_BUF];
7701     if(c == C('D')){  // EOF
7702       if(n < target){
7703         // Save ^D for next time, to make sure
7704         // caller gets a 0-byte result.
7705         input.r--;
7706       }
7707       break;
7708     }
7709     *dst++ = c;
7710     --n;
7711     if(c == '\n')
7712       break;
7713   }
7714   release(&cons.lock);
7715   ilock(ip);
7716 
7717   return target - n;
7718 }
7719 
7720 int
7721 consolewrite(struct inode *ip, char *buf, int n)
7722 {
7723   int i;
7724 
7725   iunlock(ip);
7726   acquire(&cons.lock);
7727   for(i = 0; i < n; i++)
7728     consputc(buf[i] & 0xff);
7729   release(&cons.lock);
7730   ilock(ip);
7731 
7732   return n;
7733 }
7734 
7735 void
7736 consoleinit(void)
7737 {
7738   initlock(&cons.lock, "console");
7739 
7740   devsw[CONSOLE].write = consolewrite;
7741   devsw[CONSOLE].read = consoleread;
7742   cons.locking = 1;
7743 
7744   picenable(IRQ_KBD);
7745   ioapicenable(IRQ_KBD, 0);
7746 }
7747 
7748 
7749 
