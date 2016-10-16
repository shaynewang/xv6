6800 // The local APIC manages internal (non-I/O) interrupts.
6801 // See Chapter 8 & Appendix C of Intel processor manual volume 3.
6802 // As of 7/26/2016, Intel processor manual Chapter 10 of Volume 3
6803 
6804 #include "types.h"
6805 #include "defs.h"
6806 #include "date.h"
6807 #include "memlayout.h"
6808 #include "traps.h"
6809 #include "mmu.h"
6810 #include "x86.h"
6811 
6812 // Local APIC registers, divided by 4 for use as uint[] indices.
6813 #define ID      (0x0020/4)   // ID
6814 #define VER     (0x0030/4)   // Version
6815 #define TPR     (0x0080/4)   // Task Priority
6816 #define EOI     (0x00B0/4)   // EOI
6817 #define SVR     (0x00F0/4)   // Spurious Interrupt Vector
6818   #define ENABLE     0x00000100   // Unit Enable
6819 #define ESR     (0x0280/4)   // Error Status
6820 #define ICRLO   (0x0300/4)   // Interrupt Command
6821   #define INIT       0x00000500   // INIT/RESET
6822   #define STARTUP    0x00000600   // Startup IPI
6823   #define DELIVS     0x00001000   // Delivery status
6824   #define ASSERT     0x00004000   // Assert interrupt (vs deassert)
6825   #define DEASSERT   0x00000000
6826   #define LEVEL      0x00008000   // Level triggered
6827   #define BCAST      0x00080000   // Send to all APICs, including self.
6828   #define BUSY       0x00001000
6829   #define FIXED      0x00000000
6830 #define ICRHI   (0x0310/4)   // Interrupt Command [63:32]
6831 #define TIMER   (0x0320/4)   // Local Vector Table 0 (TIMER)
6832   #define X1         0x0000000B   // divide counts by 1
6833   #define PERIODIC   0x00020000   // Periodic
6834 #define PCINT   (0x0340/4)   // Performance Counter LVT
6835 #define LINT0   (0x0350/4)   // Local Vector Table 1 (LINT0)
6836 #define LINT1   (0x0360/4)   // Local Vector Table 2 (LINT1)
6837 #define ERROR   (0x0370/4)   // Local Vector Table 3 (ERROR)
6838   #define MASKED     0x00010000   // Interrupt masked
6839 #define TICR    (0x0380/4)   // Timer Initial Count
6840 #define TCCR    (0x0390/4)   // Timer Current Count
6841 #define TDCR    (0x03E0/4)   // Timer Divide Configuration
6842 
6843 volatile uint *lapic;  // Initialized in mp.c
6844 
6845 static void
6846 lapicw(int index, int value)
6847 {
6848   lapic[index] = value;
6849   lapic[ID];  // wait for write to finish, by reading
6850 }
6851 
6852 void
6853 lapicinit(void)
6854 {
6855   if(!lapic)
6856     return;
6857 
6858   // Enable local APIC; set spurious interrupt vector.
6859   lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
6860 
6861   // The timer repeatedly counts down at bus frequency
6862   // from lapic[TICR] and then issues an interrupt.
6863   // If xv6 cared more about precise timekeeping,
6864   // TICR would be calibrated using an external time source.
6865   lapicw(TDCR, X1);
6866   lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
6867   lapicw(TICR, 10000000);
6868 
6869   // Disable logical interrupt lines.
6870   lapicw(LINT0, MASKED);
6871   lapicw(LINT1, MASKED);
6872 
6873   // Disable performance counter overflow interrupts
6874   // on machines that provide that interrupt entry.
6875   if(((lapic[VER]>>16) & 0xFF) >= 4)
6876     lapicw(PCINT, MASKED);
6877 
6878   // Map error interrupt to IRQ_ERROR.
6879   lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
6880 
6881   // Clear error status register (requires back-to-back writes).
6882   lapicw(ESR, 0);
6883   lapicw(ESR, 0);
6884 
6885   // Ack any outstanding interrupts.
6886   lapicw(EOI, 0);
6887 
6888   // Send an Init Level De-Assert to synchronise arbitration ID's.
6889   lapicw(ICRHI, 0);
6890   lapicw(ICRLO, BCAST | INIT | LEVEL);
6891   while(lapic[ICRLO] & DELIVS)
6892     ;
6893 
6894   // Enable interrupts on the APIC (but not on the processor).
6895   lapicw(TPR, 0);
6896 }
6897 
6898 
6899 
6900 int
6901 cpunum(void)
6902 {
6903   // Cannot call cpu when interrupts are enabled:
6904   // result not guaranteed to last long enough to be used!
6905   // Would prefer to panic but even printing is chancy here:
6906   // almost everything, including cprintf and panic, calls cpu,
6907   // often indirectly through acquire and release.
6908   if(readeflags()&FL_IF){
6909     static int n;
6910     if(n++ == 0)
6911       cprintf("cpu called from %x with interrupts enabled\n",
6912         __builtin_return_address(0));
6913   }
6914 
6915   if(lapic)
6916     return lapic[ID]>>24;
6917   return 0;
6918 }
6919 
6920 // Acknowledge interrupt.
6921 void
6922 lapiceoi(void)
6923 {
6924   if(lapic)
6925     lapicw(EOI, 0);
6926 }
6927 
6928 // Spin for a given number of microseconds.
6929 // On real hardware would want to tune this dynamically.
6930 void
6931 microdelay(int us)
6932 {
6933 }
6934 
6935 #define CMOS_PORT    0x70
6936 #define CMOS_RETURN  0x71
6937 
6938 // Start additional processor running entry code at addr.
6939 // See Appendix B of MultiProcessor Specification.
6940 void
6941 lapicstartap(uchar apicid, uint addr)
6942 {
6943   int i;
6944   ushort *wrv;
6945 
6946   // "The BSP must initialize CMOS shutdown code to 0AH
6947   // and the warm reset vector (DWORD based at 40:67) to point at
6948   // the AP startup code prior to the [universal startup algorithm]."
6949   outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
6950   outb(CMOS_PORT+1, 0x0A);
6951   wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
6952   wrv[0] = 0;
6953   wrv[1] = addr >> 4;
6954 
6955   // "Universal startup algorithm."
6956   // Send INIT (level-triggered) interrupt to reset other CPU.
6957   lapicw(ICRHI, apicid<<24);
6958   lapicw(ICRLO, INIT | LEVEL | ASSERT);
6959   microdelay(200);
6960   lapicw(ICRLO, INIT | LEVEL);
6961   microdelay(100);    // should be 10ms, but too slow in Bochs!
6962 
6963   // Send startup IPI (twice!) to enter code.
6964   // Regular hardware is supposed to only accept a STARTUP
6965   // when it is in the halted state due to an INIT.  So the second
6966   // should be ignored, but it is part of the official Intel algorithm.
6967   // Bochs complains about the second one.  Too bad for Bochs.
6968   for(i = 0; i < 2; i++){
6969     lapicw(ICRHI, apicid<<24);
6970     lapicw(ICRLO, STARTUP | (addr>>12));
6971     microdelay(200);
6972   }
6973 }
6974 
6975 #define CMOS_STATA   0x0a
6976 #define CMOS_STATB   0x0b
6977 #define CMOS_UIP    (1 << 7)        // RTC update in progress
6978 
6979 #define SECS    0x00
6980 #define MINS    0x02
6981 #define HOURS   0x04
6982 #define DAY     0x07
6983 #define MONTH   0x08
6984 #define YEAR    0x09
6985 
6986 static uint cmos_read(uint reg)
6987 {
6988   outb(CMOS_PORT,  reg);
6989   microdelay(200);
6990 
6991   return inb(CMOS_RETURN);
6992 }
6993 
6994 
6995 
6996 
6997 
6998 
6999 
7000 static void fill_rtcdate(struct rtcdate *r)
7001 {
7002   r->second = cmos_read(SECS);
7003   r->minute = cmos_read(MINS);
7004   r->hour   = cmos_read(HOURS);
7005   r->day    = cmos_read(DAY);
7006   r->month  = cmos_read(MONTH);
7007   r->year   = cmos_read(YEAR);
7008 }
7009 
7010 // qemu seems to use 24-hour GWT and the values are BCD encoded
7011 void cmostime(struct rtcdate *r)
7012 {
7013   struct rtcdate t1, t2;
7014   int sb, bcd;
7015 
7016   sb = cmos_read(CMOS_STATB);
7017 
7018   bcd = (sb & (1 << 2)) == 0;
7019 
7020   // make sure CMOS doesn't modify time while we read it
7021   for (;;) {
7022     fill_rtcdate(&t1);
7023     if (cmos_read(CMOS_STATA) & CMOS_UIP)
7024         continue;
7025     fill_rtcdate(&t2);
7026     if (memcmp(&t1, &t2, sizeof(t1)) == 0)
7027       break;
7028   }
7029 
7030   // convert
7031   if (bcd) {
7032 #define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
7033     CONV(second);
7034     CONV(minute);
7035     CONV(hour  );
7036     CONV(day   );
7037     CONV(month );
7038     CONV(year  );
7039 #undef     CONV
7040   }
7041 
7042   *r = t1;
7043   r->year += 2000;
7044 }
7045 
7046 
7047 
7048 
7049 
