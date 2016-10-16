6500 // See MultiProcessor Specification Version 1.[14]
6501 
6502 struct mp {             // floating pointer
6503   uchar signature[4];           // "_MP_"
6504   void *physaddr;               // phys addr of MP config table
6505   uchar length;                 // 1
6506   uchar specrev;                // [14]
6507   uchar checksum;               // all bytes must add up to 0
6508   uchar type;                   // MP system config type
6509   uchar imcrp;
6510   uchar reserved[3];
6511 };
6512 
6513 struct mpconf {         // configuration table header
6514   uchar signature[4];           // "PCMP"
6515   ushort length;                // total table length
6516   uchar version;                // [14]
6517   uchar checksum;               // all bytes must add up to 0
6518   uchar product[20];            // product id
6519   uint *oemtable;               // OEM table pointer
6520   ushort oemlength;             // OEM table length
6521   ushort entry;                 // entry count
6522   uint *lapicaddr;              // address of local APIC
6523   ushort xlength;               // extended table length
6524   uchar xchecksum;              // extended table checksum
6525   uchar reserved;
6526 };
6527 
6528 struct mpproc {         // processor table entry
6529   uchar type;                   // entry type (0)
6530   uchar apicid;                 // local APIC id
6531   uchar version;                // local APIC verison
6532   uchar flags;                  // CPU flags
6533     #define MPBOOT 0x02           // This proc is the bootstrap processor.
6534   uchar signature[4];           // CPU signature
6535   uint feature;                 // feature flags from CPUID instruction
6536   uchar reserved[8];
6537 };
6538 
6539 struct mpioapic {       // I/O APIC table entry
6540   uchar type;                   // entry type (2)
6541   uchar apicno;                 // I/O APIC id
6542   uchar version;                // I/O APIC version
6543   uchar flags;                  // I/O APIC flags
6544   uint *addr;                  // I/O APIC address
6545 };
6546 
6547 
6548 
6549 
6550 // Table entry types
6551 #define MPPROC    0x00  // One per processor
6552 #define MPBUS     0x01  // One per bus
6553 #define MPIOAPIC  0x02  // One per I/O APIC
6554 #define MPIOINTR  0x03  // One per bus interrupt source
6555 #define MPLINTR   0x04  // One per system interrupt source
6556 
6557 // Blank page.
6558 
6559 
6560 
6561 
6562 
6563 
6564 
6565 
6566 
6567 
6568 
6569 
6570 
6571 
6572 
6573 
6574 
6575 
6576 
6577 
6578 
6579 
6580 
6581 
6582 
6583 
6584 
6585 
6586 
6587 
6588 
6589 
6590 
6591 
6592 
6593 
6594 
6595 
6596 
6597 
6598 
6599 
