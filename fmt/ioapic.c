7050 // The I/O APIC manages hardware interrupts for an SMP system.
7051 // http://www.intel.com/design/chipsets/datashts/29056601.pdf
7052 // See also picirq.c.
7053 
7054 #include "types.h"
7055 #include "defs.h"
7056 #include "traps.h"
7057 
7058 #define IOAPIC  0xFEC00000   // Default physical address of IO APIC
7059 
7060 #define REG_ID     0x00  // Register index: ID
7061 #define REG_VER    0x01  // Register index: version
7062 #define REG_TABLE  0x10  // Redirection table base
7063 
7064 // The redirection table starts at REG_TABLE and uses
7065 // two registers to configure each interrupt.
7066 // The first (low) register in a pair contains configuration bits.
7067 // The second (high) register contains a bitmask telling which
7068 // CPUs can serve that interrupt.
7069 #define INT_DISABLED   0x00010000  // Interrupt disabled
7070 #define INT_LEVEL      0x00008000  // Level-triggered (vs edge-)
7071 #define INT_ACTIVELOW  0x00002000  // Active low (vs high)
7072 #define INT_LOGICAL    0x00000800  // Destination is CPU id (vs APIC ID)
7073 
7074 volatile struct ioapic *ioapic;
7075 
7076 // IO APIC MMIO structure: write reg, then read or write data.
7077 struct ioapic {
7078   uint reg;
7079   uint pad[3];
7080   uint data;
7081 };
7082 
7083 static uint
7084 ioapicread(int reg)
7085 {
7086   ioapic->reg = reg;
7087   return ioapic->data;
7088 }
7089 
7090 static void
7091 ioapicwrite(int reg, uint data)
7092 {
7093   ioapic->reg = reg;
7094   ioapic->data = data;
7095 }
7096 
7097 
7098 
7099 
7100 void
7101 ioapicinit(void)
7102 {
7103   int i, id, maxintr;
7104 
7105   if(!ismp)
7106     return;
7107 
7108   ioapic = (volatile struct ioapic*)IOAPIC;
7109   maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
7110   id = ioapicread(REG_ID) >> 24;
7111   if(id != ioapicid)
7112     cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
7113 
7114   // Mark all interrupts edge-triggered, active high, disabled,
7115   // and not routed to any CPUs.
7116   for(i = 0; i <= maxintr; i++){
7117     ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
7118     ioapicwrite(REG_TABLE+2*i+1, 0);
7119   }
7120 }
7121 
7122 void
7123 ioapicenable(int irq, int cpunum)
7124 {
7125   if(!ismp)
7126     return;
7127 
7128   // Mark interrupt edge-triggered, active high,
7129   // enabled, and routed to the given cpunum,
7130   // which happens to be that cpu's APIC ID.
7131   ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
7132   ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
7133 }
7134 
7135 
7136 
7137 
7138 
7139 
7140 
7141 
7142 
7143 
7144 
7145 
7146 
7147 
7148 
7149 
