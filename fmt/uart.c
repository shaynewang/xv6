8100 // Intel 8250 serial port (UART).
8101 
8102 #include "types.h"
8103 #include "defs.h"
8104 #include "param.h"
8105 #include "traps.h"
8106 #include "spinlock.h"
8107 #include "fs.h"
8108 #include "file.h"
8109 #include "mmu.h"
8110 #include "proc.h"
8111 #include "x86.h"
8112 
8113 #define COM1    0x3f8
8114 
8115 static int uart;    // is there a uart?
8116 
8117 void
8118 uartinit(void)
8119 {
8120   char *p;
8121 
8122   // Turn off the FIFO
8123   outb(COM1+2, 0);
8124 
8125   // 9600 baud, 8 data bits, 1 stop bit, parity off.
8126   outb(COM1+3, 0x80);    // Unlock divisor
8127   outb(COM1+0, 115200/9600);
8128   outb(COM1+1, 0);
8129   outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8130   outb(COM1+4, 0);
8131   outb(COM1+1, 0x01);    // Enable receive interrupts.
8132 
8133   // If status is 0xFF, no serial port.
8134   if(inb(COM1+5) == 0xFF)
8135     return;
8136   uart = 1;
8137 
8138   // Acknowledge pre-existing interrupt conditions;
8139   // enable interrupts.
8140   inb(COM1+2);
8141   inb(COM1+0);
8142   picenable(IRQ_COM1);
8143   ioapicenable(IRQ_COM1, 0);
8144 
8145   // Announce that we're here.
8146   for(p="xv6...\n"; *p; p++)
8147     uartputc(*p);
8148 }
8149 
8150 void
8151 uartputc(int c)
8152 {
8153   int i;
8154 
8155   if(!uart)
8156     return;
8157   for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8158     microdelay(10);
8159   outb(COM1+0, c);
8160 }
8161 
8162 static int
8163 uartgetc(void)
8164 {
8165   if(!uart)
8166     return -1;
8167   if(!(inb(COM1+5) & 0x01))
8168     return -1;
8169   return inb(COM1+0);
8170 }
8171 
8172 void
8173 uartintr(void)
8174 {
8175   consoleintr(uartgetc);
8176 }
8177 
8178 
8179 
8180 
8181 
8182 
8183 
8184 
8185 
8186 
8187 
8188 
8189 
8190 
8191 
8192 
8193 
8194 
8195 
8196 
8197 
8198 
8199 
