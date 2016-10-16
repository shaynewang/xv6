7150 // Intel 8259A programmable interrupt controllers.
7151 
7152 #include "types.h"
7153 #include "x86.h"
7154 #include "traps.h"
7155 
7156 // I/O Addresses of the two programmable interrupt controllers
7157 #define IO_PIC1         0x20    // Master (IRQs 0-7)
7158 #define IO_PIC2         0xA0    // Slave (IRQs 8-15)
7159 
7160 #define IRQ_SLAVE       2       // IRQ at which slave connects to master
7161 
7162 // Current IRQ mask.
7163 // Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
7164 static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);
7165 
7166 static void
7167 picsetmask(ushort mask)
7168 {
7169   irqmask = mask;
7170   outb(IO_PIC1+1, mask);
7171   outb(IO_PIC2+1, mask >> 8);
7172 }
7173 
7174 void
7175 picenable(int irq)
7176 {
7177   picsetmask(irqmask & ~(1<<irq));
7178 }
7179 
7180 // Initialize the 8259A interrupt controllers.
7181 void
7182 picinit(void)
7183 {
7184   // mask all interrupts
7185   outb(IO_PIC1+1, 0xFF);
7186   outb(IO_PIC2+1, 0xFF);
7187 
7188   // Set up master (8259A-1)
7189 
7190   // ICW1:  0001g0hi
7191   //    g:  0 = edge triggering, 1 = level triggering
7192   //    h:  0 = cascaded PICs, 1 = master only
7193   //    i:  0 = no ICW4, 1 = ICW4 required
7194   outb(IO_PIC1, 0x11);
7195 
7196   // ICW2:  Vector offset
7197   outb(IO_PIC1+1, T_IRQ0);
7198 
7199 
7200   // ICW3:  (master PIC) bit mask of IR lines connected to slaves
7201   //        (slave PIC) 3-bit # of slave's connection to master
7202   outb(IO_PIC1+1, 1<<IRQ_SLAVE);
7203 
7204   // ICW4:  000nbmap
7205   //    n:  1 = special fully nested mode
7206   //    b:  1 = buffered mode
7207   //    m:  0 = slave PIC, 1 = master PIC
7208   //      (ignored when b is 0, as the master/slave role
7209   //      can be hardwired).
7210   //    a:  1 = Automatic EOI mode
7211   //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
7212   outb(IO_PIC1+1, 0x3);
7213 
7214   // Set up slave (8259A-2)
7215   outb(IO_PIC2, 0x11);                  // ICW1
7216   outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
7217   outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
7218   // NB Automatic EOI mode doesn't tend to work on the slave.
7219   // Linux source code says it's "to be investigated".
7220   outb(IO_PIC2+1, 0x3);                 // ICW4
7221 
7222   // OCW3:  0ef01prs
7223   //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
7224   //    p:  0 = no polling, 1 = polling mode
7225   //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
7226   outb(IO_PIC1, 0x68);             // clear specific mask
7227   outb(IO_PIC1, 0x0a);             // read IRR by default
7228 
7229   outb(IO_PIC2, 0x68);             // OCW3
7230   outb(IO_PIC2, 0x0a);             // OCW3
7231 
7232   if(irqmask != 0xFFFF)
7233     picsetmask(irqmask);
7234 }
7235 
7236 
7237 
7238 
7239 
7240 
7241 
7242 
7243 
7244 
7245 
7246 
7247 
7248 
7249 
