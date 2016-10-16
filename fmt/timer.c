7750 // Intel 8253/8254/82C54 Programmable Interval Timer (PIT).
7751 // Only used on uniprocessors;
7752 // SMP machines use the local APIC timer.
7753 
7754 #include "types.h"
7755 #include "defs.h"
7756 #include "traps.h"
7757 #include "x86.h"
7758 
7759 #define IO_TIMER1       0x040           // 8253 Timer #1
7760 
7761 // Frequency of all three count-down timers;
7762 // (TIMER_FREQ/freq) is the appropriate count
7763 // to generate a frequency of freq Hz.
7764 
7765 #define TIMER_FREQ      1193182
7766 #define TIMER_DIV(x)    ((TIMER_FREQ+(x)/2)/(x))
7767 
7768 #define TIMER_MODE      (IO_TIMER1 + 3) // timer mode port
7769 #define TIMER_SEL0      0x00    // select counter 0
7770 #define TIMER_RATEGEN   0x04    // mode 2, rate generator
7771 #define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first
7772 
7773 void
7774 timerinit(void)
7775 {
7776   // Interrupt 100 times/sec.
7777   outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
7778   outb(IO_TIMER1, TIMER_DIV(100) % 256);
7779   outb(IO_TIMER1, TIMER_DIV(100) / 256);
7780   picenable(IRQ_TIMER);
7781 }
7782 
7783 
7784 
7785 
7786 
7787 
7788 
7789 
7790 
7791 
7792 
7793 
7794 
7795 
7796 
7797 
7798 
7799 
