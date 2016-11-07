7350 // The I/O APIC manages hardware interrupts for an SMP system.
7351 // http://www.intel.com/design/chipsets/datashts/29056601.pdf
7352 // See also picirq.c.
7353 
7354 #include "types.h"
7355 #include "defs.h"
7356 #include "traps.h"
7357 
7358 #define IOAPIC  0xFEC00000   // Default physical address of IO APIC
7359 
7360 #define REG_ID     0x00  // Register index: ID
7361 #define REG_VER    0x01  // Register index: version
7362 #define REG_TABLE  0x10  // Redirection table base
7363 
7364 // The redirection table starts at REG_TABLE and uses
7365 // two registers to configure each interrupt.
7366 // The first (low) register in a pair contains configuration bits.
7367 // The second (high) register contains a bitmask telling which
7368 // CPUs can serve that interrupt.
7369 #define INT_DISABLED   0x00010000  // Interrupt disabled
7370 #define INT_LEVEL      0x00008000  // Level-triggered (vs edge-)
7371 #define INT_ACTIVELOW  0x00002000  // Active low (vs high)
7372 #define INT_LOGICAL    0x00000800  // Destination is CPU id (vs APIC ID)
7373 
7374 volatile struct ioapic *ioapic;
7375 
7376 // IO APIC MMIO structure: write reg, then read or write data.
7377 struct ioapic {
7378   uint reg;
7379   uint pad[3];
7380   uint data;
7381 };
7382 
7383 static uint
7384 ioapicread(int reg)
7385 {
7386   ioapic->reg = reg;
7387   return ioapic->data;
7388 }
7389 
7390 static void
7391 ioapicwrite(int reg, uint data)
7392 {
7393   ioapic->reg = reg;
7394   ioapic->data = data;
7395 }
7396 
7397 
7398 
7399 
7400 void
7401 ioapicinit(void)
7402 {
7403   int i, id, maxintr;
7404 
7405   if(!ismp)
7406     return;
7407 
7408   ioapic = (volatile struct ioapic*)IOAPIC;
7409   maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
7410   id = ioapicread(REG_ID) >> 24;
7411   if(id != ioapicid)
7412     cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
7413 
7414   // Mark all interrupts edge-triggered, active high, disabled,
7415   // and not routed to any CPUs.
7416   for(i = 0; i <= maxintr; i++){
7417     ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
7418     ioapicwrite(REG_TABLE+2*i+1, 0);
7419   }
7420 }
7421 
7422 void
7423 ioapicenable(int irq, int cpunum)
7424 {
7425   if(!ismp)
7426     return;
7427 
7428   // Mark interrupt edge-triggered, active high,
7429   // enabled, and routed to the given cpunum,
7430   // which happens to be that cpu's APIC ID.
7431   ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
7432   ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
7433 }
7434 
7435 
7436 
7437 
7438 
7439 
7440 
7441 
7442 
7443 
7444 
7445 
7446 
7447 
7448 
7449 
