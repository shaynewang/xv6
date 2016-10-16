6600 // Multiprocessor support
6601 // Search memory for MP description structures.
6602 // http://developer.intel.com/design/pentium/datashts/24201606.pdf
6603 
6604 #include "types.h"
6605 #include "defs.h"
6606 #include "param.h"
6607 #include "memlayout.h"
6608 #include "mp.h"
6609 #include "x86.h"
6610 #include "mmu.h"
6611 #include "proc.h"
6612 
6613 struct cpu cpus[NCPU];
6614 static struct cpu *bcpu;
6615 int ismp;
6616 int ncpu;
6617 uchar ioapicid;
6618 
6619 int
6620 mpbcpu(void)
6621 {
6622   return bcpu-cpus;
6623 }
6624 
6625 static uchar
6626 sum(uchar *addr, int len)
6627 {
6628   int i, sum;
6629 
6630   sum = 0;
6631   for(i=0; i<len; i++)
6632     sum += addr[i];
6633   return sum;
6634 }
6635 
6636 // Look for an MP structure in the len bytes at addr.
6637 static struct mp*
6638 mpsearch1(uint a, int len)
6639 {
6640   uchar *e, *p, *addr;
6641 
6642   addr = p2v(a);
6643   e = addr+len;
6644   for(p = addr; p < e; p += sizeof(struct mp))
6645     if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
6646       return (struct mp*)p;
6647   return 0;
6648 }
6649 
6650 // Search for the MP Floating Pointer Structure, which according to the
6651 // spec is in one of the following three locations:
6652 // 1) in the first KB of the EBDA;
6653 // 2) in the last KB of system base memory;
6654 // 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
6655 static struct mp*
6656 mpsearch(void)
6657 {
6658   uchar *bda;
6659   uint p;
6660   struct mp *mp;
6661 
6662   bda = (uchar *) P2V(0x400);
6663   if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
6664     if((mp = mpsearch1(p, 1024)))
6665       return mp;
6666   } else {
6667     p = ((bda[0x14]<<8)|bda[0x13])*1024;
6668     if((mp = mpsearch1(p-1024, 1024)))
6669       return mp;
6670   }
6671   return mpsearch1(0xF0000, 0x10000);
6672 }
6673 
6674 // Search for an MP configuration table.  For now,
6675 // don't accept the default configurations (physaddr == 0).
6676 // Check for correct signature, calculate the checksum and,
6677 // if correct, check the version.
6678 // To do: check extended table checksum.
6679 static struct mpconf*
6680 mpconfig(struct mp **pmp)
6681 {
6682   struct mpconf *conf;
6683   struct mp *mp;
6684 
6685   if((mp = mpsearch()) == 0 || mp->physaddr == 0)
6686     return 0;
6687   conf = (struct mpconf*) p2v((uint) mp->physaddr);
6688   if(memcmp(conf, "PCMP", 4) != 0)
6689     return 0;
6690   if(conf->version != 1 && conf->version != 4)
6691     return 0;
6692   if(sum((uchar*)conf, conf->length) != 0)
6693     return 0;
6694   *pmp = mp;
6695   return conf;
6696 }
6697 
6698 
6699 
6700 void
6701 mpinit(void)
6702 {
6703   uchar *p, *e;
6704   struct mp *mp;
6705   struct mpconf *conf;
6706   struct mpproc *proc;
6707   struct mpioapic *ioapic;
6708 
6709   bcpu = &cpus[0];
6710   if((conf = mpconfig(&mp)) == 0)
6711     return;
6712   ismp = 1;
6713   lapic = (uint*)conf->lapicaddr;
6714   for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
6715     switch(*p){
6716     case MPPROC:
6717       proc = (struct mpproc*)p;
6718       if(ncpu != proc->apicid){
6719         cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
6720         ismp = 0;
6721       }
6722       if(proc->flags & MPBOOT)
6723         bcpu = &cpus[ncpu];
6724       cpus[ncpu].id = ncpu;
6725       ncpu++;
6726       p += sizeof(struct mpproc);
6727       continue;
6728     case MPIOAPIC:
6729       ioapic = (struct mpioapic*)p;
6730       ioapicid = ioapic->apicno;
6731       p += sizeof(struct mpioapic);
6732       continue;
6733     case MPBUS:
6734     case MPIOINTR:
6735     case MPLINTR:
6736       p += 8;
6737       continue;
6738     default:
6739       cprintf("mpinit: unknown config type %x\n", *p);
6740       ismp = 0;
6741     }
6742   }
6743   if(!ismp){
6744     // Didn't like what we found; fall back to no MP.
6745     ncpu = 1;
6746     lapic = 0;
6747     ioapicid = 0;
6748     return;
6749   }
6750   if(mp->imcrp){
6751     // Bochs doesn't support IMCR, so this doesn't run on Bochs.
6752     // But it would on real hardware.
6753     outb(0x22, 0x70);   // Select IMCR
6754     outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
6755   }
6756 }
6757 
6758 
6759 
6760 
6761 
6762 
6763 
6764 
6765 
6766 
6767 
6768 
6769 
6770 
6771 
6772 
6773 
6774 
6775 
6776 
6777 
6778 
6779 
6780 
6781 
6782 
6783 
6784 
6785 
6786 
6787 
6788 
6789 
6790 
6791 
6792 
6793 
6794 
6795 
6796 
6797 
6798 
6799 
