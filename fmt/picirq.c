7450 // Intel 8259A programmable interrupt controllers.
7451 
7452 #include "types.h"
7453 #include "x86.h"
7454 #include "traps.h"
7455 
7456 // I/O Addresses of the two programmable interrupt controllers
7457 #define IO_PIC1         0x20    // Master (IRQs 0-7)
7458 #define IO_PIC2         0xA0    // Slave (IRQs 8-15)
7459 
7460 #define IRQ_SLAVE       2       // IRQ at which slave connects to master
7461 
7462 // Current IRQ mask.
7463 // Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
7464 static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);
7465 
7466 static void
7467 picsetmask(ushort mask)
7468 {
7469   irqmask = mask;
7470   outb(IO_PIC1+1, mask);
7471   outb(IO_PIC2+1, mask >> 8);
7472 }
7473 
7474 void
7475 picenable(int irq)
7476 {
7477   picsetmask(irqmask & ~(1<<irq));
7478 }
7479 
7480 // Initialize the 8259A interrupt controllers.
7481 void
7482 picinit(void)
7483 {
7484   // mask all interrupts
7485   outb(IO_PIC1+1, 0xFF);
7486   outb(IO_PIC2+1, 0xFF);
7487 
7488   // Set up master (8259A-1)
7489 
7490   // ICW1:  0001g0hi
7491   //    g:  0 = edge triggering, 1 = level triggering
7492   //    h:  0 = cascaded PICs, 1 = master only
7493   //    i:  0 = no ICW4, 1 = ICW4 required
7494   outb(IO_PIC1, 0x11);
7495 
7496   // ICW2:  Vector offset
7497   outb(IO_PIC1+1, T_IRQ0);
7498 
7499 
7500   // ICW3:  (master PIC) bit mask of IR lines connected to slaves
7501   //        (slave PIC) 3-bit # of slave's connection to master
7502   outb(IO_PIC1+1, 1<<IRQ_SLAVE);
7503 
7504   // ICW4:  000nbmap
7505   //    n:  1 = special fully nested mode
7506   //    b:  1 = buffered mode
7507   //    m:  0 = slave PIC, 1 = master PIC
7508   //      (ignored when b is 0, as the master/slave role
7509   //      can be hardwired).
7510   //    a:  1 = Automatic EOI mode
7511   //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
7512   outb(IO_PIC1+1, 0x3);
7513 
7514   // Set up slave (8259A-2)
7515   outb(IO_PIC2, 0x11);                  // ICW1
7516   outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
7517   outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
7518   // NB Automatic EOI mode doesn't tend to work on the slave.
7519   // Linux source code says it's "to be investigated".
7520   outb(IO_PIC2+1, 0x3);                 // ICW4
7521 
7522   // OCW3:  0ef01prs
7523   //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
7524   //    p:  0 = no polling, 1 = polling mode
7525   //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
7526   outb(IO_PIC1, 0x68);             // clear specific mask
7527   outb(IO_PIC1, 0x0a);             // read IRR by default
7528 
7529   outb(IO_PIC2, 0x68);             // OCW3
7530   outb(IO_PIC2, 0x0a);             // OCW3
7531 
7532   if(irqmask != 0xFFFF)
7533     picsetmask(irqmask);
7534 }
7535 
7536 
7537 
7538 
7539 
7540 
7541 
7542 
7543 
7544 
7545 
7546 
7547 
7548 
7549 
