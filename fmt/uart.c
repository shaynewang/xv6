7800 // Intel 8250 serial port (UART).
7801 
7802 #include "types.h"
7803 #include "defs.h"
7804 #include "param.h"
7805 #include "traps.h"
7806 #include "spinlock.h"
7807 #include "fs.h"
7808 #include "file.h"
7809 #include "mmu.h"
7810 #include "proc.h"
7811 #include "x86.h"
7812 
7813 #define COM1    0x3f8
7814 
7815 static int uart;    // is there a uart?
7816 
7817 void
7818 uartinit(void)
7819 {
7820   char *p;
7821 
7822   // Turn off the FIFO
7823   outb(COM1+2, 0);
7824 
7825   // 9600 baud, 8 data bits, 1 stop bit, parity off.
7826   outb(COM1+3, 0x80);    // Unlock divisor
7827   outb(COM1+0, 115200/9600);
7828   outb(COM1+1, 0);
7829   outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
7830   outb(COM1+4, 0);
7831   outb(COM1+1, 0x01);    // Enable receive interrupts.
7832 
7833   // If status is 0xFF, no serial port.
7834   if(inb(COM1+5) == 0xFF)
7835     return;
7836   uart = 1;
7837 
7838   // Acknowledge pre-existing interrupt conditions;
7839   // enable interrupts.
7840   inb(COM1+2);
7841   inb(COM1+0);
7842   picenable(IRQ_COM1);
7843   ioapicenable(IRQ_COM1, 0);
7844 
7845   // Announce that we're here.
7846   for(p="xv6...\n"; *p; p++)
7847     uartputc(*p);
7848 }
7849 
7850 void
7851 uartputc(int c)
7852 {
7853   int i;
7854 
7855   if(!uart)
7856     return;
7857   for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
7858     microdelay(10);
7859   outb(COM1+0, c);
7860 }
7861 
7862 static int
7863 uartgetc(void)
7864 {
7865   if(!uart)
7866     return -1;
7867   if(!(inb(COM1+5) & 0x01))
7868     return -1;
7869   return inb(COM1+0);
7870 }
7871 
7872 void
7873 uartintr(void)
7874 {
7875   consoleintr(uartgetc);
7876 }
7877 
7878 
7879 
7880 
7881 
7882 
7883 
7884 
7885 
7886 
7887 
7888 
7889 
7890 
7891 
7892 
7893 
7894 
7895 
7896 
7897 
7898 
7899 
