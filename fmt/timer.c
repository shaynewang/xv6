8050 // Intel 8253/8254/82C54 Programmable Interval Timer (PIT).
8051 // Only used on uniprocessors;
8052 // SMP machines use the local APIC timer.
8053 
8054 #include "types.h"
8055 #include "defs.h"
8056 #include "traps.h"
8057 #include "x86.h"
8058 
8059 #define IO_TIMER1       0x040           // 8253 Timer #1
8060 
8061 // Frequency of all three count-down timers;
8062 // (TIMER_FREQ/freq) is the appropriate count
8063 // to generate a frequency of freq Hz.
8064 
8065 #define TIMER_FREQ      1193182
8066 #define TIMER_DIV(x)    ((TIMER_FREQ+(x)/2)/(x))
8067 
8068 #define TIMER_MODE      (IO_TIMER1 + 3) // timer mode port
8069 #define TIMER_SEL0      0x00    // select counter 0
8070 #define TIMER_RATEGEN   0x04    // mode 2, rate generator
8071 #define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first
8072 
8073 void
8074 timerinit(void)
8075 {
8076   // Interrupt 100 times/sec.
8077   outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8078   outb(IO_TIMER1, TIMER_DIV(100) % 256);
8079   outb(IO_TIMER1, TIMER_DIV(100) / 256);
8080   picenable(IRQ_TIMER);
8081 }
8082 
8083 
8084 
8085 
8086 
8087 
8088 
8089 
8090 
8091 
8092 
8093 
8094 
8095 
8096 
8097 
8098 
8099 
