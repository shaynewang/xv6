7100 // The local APIC manages internal (non-I/O) interrupts.
7101 // See Chapter 8 & Appendix C of Intel processor manual volume 3.
7102 // As of 7/26/2016, Intel processor manual Chapter 10 of Volume 3
7103 
7104 #include "types.h"
7105 #include "defs.h"
7106 #include "date.h"
7107 #include "memlayout.h"
7108 #include "traps.h"
7109 #include "mmu.h"
7110 #include "x86.h"
7111 
7112 // Local APIC registers, divided by 4 for use as uint[] indices.
7113 #define ID      (0x0020/4)   // ID
7114 #define VER     (0x0030/4)   // Version
7115 #define TPR     (0x0080/4)   // Task Priority
7116 #define EOI     (0x00B0/4)   // EOI
7117 #define SVR     (0x00F0/4)   // Spurious Interrupt Vector
7118   #define ENABLE     0x00000100   // Unit Enable
7119 #define ESR     (0x0280/4)   // Error Status
7120 #define ICRLO   (0x0300/4)   // Interrupt Command
7121   #define INIT       0x00000500   // INIT/RESET
7122   #define STARTUP    0x00000600   // Startup IPI
7123   #define DELIVS     0x00001000   // Delivery status
7124   #define ASSERT     0x00004000   // Assert interrupt (vs deassert)
7125   #define DEASSERT   0x00000000
7126   #define LEVEL      0x00008000   // Level triggered
7127   #define BCAST      0x00080000   // Send to all APICs, including self.
7128   #define BUSY       0x00001000
7129   #define FIXED      0x00000000
7130 #define ICRHI   (0x0310/4)   // Interrupt Command [63:32]
7131 #define TIMER   (0x0320/4)   // Local Vector Table 0 (TIMER)
7132   #define X1         0x0000000B   // divide counts by 1
7133   #define PERIODIC   0x00020000   // Periodic
7134 #define PCINT   (0x0340/4)   // Performance Counter LVT
7135 #define LINT0   (0x0350/4)   // Local Vector Table 1 (LINT0)
7136 #define LINT1   (0x0360/4)   // Local Vector Table 2 (LINT1)
7137 #define ERROR   (0x0370/4)   // Local Vector Table 3 (ERROR)
7138   #define MASKED     0x00010000   // Interrupt masked
7139 #define TICR    (0x0380/4)   // Timer Initial Count
7140 #define TCCR    (0x0390/4)   // Timer Current Count
7141 #define TDCR    (0x03E0/4)   // Timer Divide Configuration
7142 
7143 volatile uint *lapic;  // Initialized in mp.c
7144 
7145 static void
7146 lapicw(int index, int value)
7147 {
7148   lapic[index] = value;
7149   lapic[ID];  // wait for write to finish, by reading
7150 }
7151 
7152 void
7153 lapicinit(void)
7154 {
7155   if(!lapic)
7156     return;
7157 
7158   // Enable local APIC; set spurious interrupt vector.
7159   lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
7160 
7161   // The timer repeatedly counts down at bus frequency
7162   // from lapic[TICR] and then issues an interrupt.
7163   // If xv6 cared more about precise timekeeping,
7164   // TICR would be calibrated using an external time source.
7165   lapicw(TDCR, X1);
7166   lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
7167   lapicw(TICR, 10000000);
7168 
7169   // Disable logical interrupt lines.
7170   lapicw(LINT0, MASKED);
7171   lapicw(LINT1, MASKED);
7172 
7173   // Disable performance counter overflow interrupts
7174   // on machines that provide that interrupt entry.
7175   if(((lapic[VER]>>16) & 0xFF) >= 4)
7176     lapicw(PCINT, MASKED);
7177 
7178   // Map error interrupt to IRQ_ERROR.
7179   lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
7180 
7181   // Clear error status register (requires back-to-back writes).
7182   lapicw(ESR, 0);
7183   lapicw(ESR, 0);
7184 
7185   // Ack any outstanding interrupts.
7186   lapicw(EOI, 0);
7187 
7188   // Send an Init Level De-Assert to synchronise arbitration ID's.
7189   lapicw(ICRHI, 0);
7190   lapicw(ICRLO, BCAST | INIT | LEVEL);
7191   while(lapic[ICRLO] & DELIVS)
7192     ;
7193 
7194   // Enable interrupts on the APIC (but not on the processor).
7195   lapicw(TPR, 0);
7196 }
7197 
7198 
7199 
7200 int
7201 cpunum(void)
7202 {
7203   // Cannot call cpu when interrupts are enabled:
7204   // result not guaranteed to last long enough to be used!
7205   // Would prefer to panic but even printing is chancy here:
7206   // almost everything, including cprintf and panic, calls cpu,
7207   // often indirectly through acquire and release.
7208   if(readeflags()&FL_IF){
7209     static int n;
7210     if(n++ == 0)
7211       cprintf("cpu called from %x with interrupts enabled\n",
7212         __builtin_return_address(0));
7213   }
7214 
7215   if(lapic)
7216     return lapic[ID]>>24;
7217   return 0;
7218 }
7219 
7220 // Acknowledge interrupt.
7221 void
7222 lapiceoi(void)
7223 {
7224   if(lapic)
7225     lapicw(EOI, 0);
7226 }
7227 
7228 // Spin for a given number of microseconds.
7229 // On real hardware would want to tune this dynamically.
7230 void
7231 microdelay(int us)
7232 {
7233 }
7234 
7235 #define CMOS_PORT    0x70
7236 #define CMOS_RETURN  0x71
7237 
7238 // Start additional processor running entry code at addr.
7239 // See Appendix B of MultiProcessor Specification.
7240 void
7241 lapicstartap(uchar apicid, uint addr)
7242 {
7243   int i;
7244   ushort *wrv;
7245 
7246   // "The BSP must initialize CMOS shutdown code to 0AH
7247   // and the warm reset vector (DWORD based at 40:67) to point at
7248   // the AP startup code prior to the [universal startup algorithm]."
7249   outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
7250   outb(CMOS_PORT+1, 0x0A);
7251   wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
7252   wrv[0] = 0;
7253   wrv[1] = addr >> 4;
7254 
7255   // "Universal startup algorithm."
7256   // Send INIT (level-triggered) interrupt to reset other CPU.
7257   lapicw(ICRHI, apicid<<24);
7258   lapicw(ICRLO, INIT | LEVEL | ASSERT);
7259   microdelay(200);
7260   lapicw(ICRLO, INIT | LEVEL);
7261   microdelay(100);    // should be 10ms, but too slow in Bochs!
7262 
7263   // Send startup IPI (twice!) to enter code.
7264   // Regular hardware is supposed to only accept a STARTUP
7265   // when it is in the halted state due to an INIT.  So the second
7266   // should be ignored, but it is part of the official Intel algorithm.
7267   // Bochs complains about the second one.  Too bad for Bochs.
7268   for(i = 0; i < 2; i++){
7269     lapicw(ICRHI, apicid<<24);
7270     lapicw(ICRLO, STARTUP | (addr>>12));
7271     microdelay(200);
7272   }
7273 }
7274 
7275 #define CMOS_STATA   0x0a
7276 #define CMOS_STATB   0x0b
7277 #define CMOS_UIP    (1 << 7)        // RTC update in progress
7278 
7279 #define SECS    0x00
7280 #define MINS    0x02
7281 #define HOURS   0x04
7282 #define DAY     0x07
7283 #define MONTH   0x08
7284 #define YEAR    0x09
7285 
7286 static uint cmos_read(uint reg)
7287 {
7288   outb(CMOS_PORT,  reg);
7289   microdelay(200);
7290 
7291   return inb(CMOS_RETURN);
7292 }
7293 
7294 
7295 
7296 
7297 
7298 
7299 
7300 static void fill_rtcdate(struct rtcdate *r)
7301 {
7302   r->second = cmos_read(SECS);
7303   r->minute = cmos_read(MINS);
7304   r->hour   = cmos_read(HOURS);
7305   r->day    = cmos_read(DAY);
7306   r->month  = cmos_read(MONTH);
7307   r->year   = cmos_read(YEAR);
7308 }
7309 
7310 // qemu seems to use 24-hour GWT and the values are BCD encoded
7311 void cmostime(struct rtcdate *r)
7312 {
7313   struct rtcdate t1, t2;
7314   int sb, bcd;
7315 
7316   sb = cmos_read(CMOS_STATB);
7317 
7318   bcd = (sb & (1 << 2)) == 0;
7319 
7320   // make sure CMOS doesn't modify time while we read it
7321   for (;;) {
7322     fill_rtcdate(&t1);
7323     if (cmos_read(CMOS_STATA) & CMOS_UIP)
7324         continue;
7325     fill_rtcdate(&t2);
7326     if (memcmp(&t1, &t2, sizeof(t1)) == 0)
7327       break;
7328   }
7329 
7330   // convert
7331   if (bcd) {
7332 #define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
7333     CONV(second);
7334     CONV(minute);
7335     CONV(hour  );
7336     CONV(day   );
7337     CONV(month );
7338     CONV(year  );
7339 #undef     CONV
7340   }
7341 
7342   *r = t1;
7343   r->year += 2000;
7344 }
7345 
7346 
7347 
7348 
7349 
