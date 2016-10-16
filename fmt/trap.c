3100 #include "types.h"
3101 #include "defs.h"
3102 #include "param.h"
3103 #include "memlayout.h"
3104 #include "mmu.h"
3105 #include "proc.h"
3106 #include "x86.h"
3107 #include "traps.h"
3108 #include "spinlock.h"
3109 
3110 // Interrupt descriptor table (shared by all CPUs).
3111 struct gatedesc idt[256];
3112 extern uint vectors[];  // in vectors.S: array of 256 entry pointers
3113 struct spinlock tickslock;
3114 uint ticks;
3115 
3116 void
3117 tvinit(void)
3118 {
3119   int i;
3120 
3121   for(i = 0; i < 256; i++)
3122     SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
3123   SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
3124 
3125   initlock(&tickslock, "time");
3126 }
3127 
3128 void
3129 idtinit(void)
3130 {
3131   lidt(idt, sizeof(idt));
3132 }
3133 
3134 void
3135 trap(struct trapframe *tf)
3136 {
3137   if(tf->trapno == T_SYSCALL){
3138     if(proc->killed)
3139       exit();
3140     proc->tf = tf;
3141     syscall();
3142     if(proc->killed)
3143       exit();
3144     return;
3145   }
3146 
3147   switch(tf->trapno){
3148   case T_IRQ0 + IRQ_TIMER:
3149     if(cpu->id == 0){
3150       acquire(&tickslock);
3151       ticks++;
3152       release(&tickslock);    // NOTE: MarkM has reversed these two lines.
3153       wakeup(&ticks);         // wakeup() should not require the tickslock to be held
3154     }
3155     lapiceoi();
3156     break;
3157   case T_IRQ0 + IRQ_IDE:
3158     ideintr();
3159     lapiceoi();
3160     break;
3161   case T_IRQ0 + IRQ_IDE+1:
3162     // Bochs generates spurious IDE1 interrupts.
3163     break;
3164   case T_IRQ0 + IRQ_KBD:
3165     kbdintr();
3166     lapiceoi();
3167     break;
3168   case T_IRQ0 + IRQ_COM1:
3169     uartintr();
3170     lapiceoi();
3171     break;
3172   case T_IRQ0 + 7:
3173   case T_IRQ0 + IRQ_SPURIOUS:
3174     cprintf("cpu%d: spurious interrupt at %x:%x\n",
3175             cpu->id, tf->cs, tf->eip);
3176     lapiceoi();
3177     break;
3178 
3179   default:
3180     if(proc == 0 || (tf->cs&3) == 0){
3181       // In kernel, it must be our mistake.
3182       cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
3183               tf->trapno, cpu->id, tf->eip, rcr2());
3184       panic("trap");
3185     }
3186     // In user space, assume process misbehaved.
3187     cprintf("pid %d %s: trap %d err %d on cpu %d "
3188             "eip 0x%x addr 0x%x--kill proc\n",
3189             proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
3190             rcr2());
3191     proc->killed = 1;
3192   }
3193 
3194   // Force process exit if it has been killed and is in user space.
3195   // (If it is still executing in the kernel, let it keep running
3196   // until it gets to the regular system call return.)
3197   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3198     exit();
3199 
3200   // Force process to give up CPU on clock tick.
3201   // If interrupts were on while locks held, would need to check nlock.
3202   if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
3203     yield();
3204 
3205   // Check if the process has been killed since we yielded
3206   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3207     exit();
3208 }
3209 
3210 
3211 
3212 
3213 
3214 
3215 
3216 
3217 
3218 
3219 
3220 
3221 
3222 
3223 
3224 
3225 
3226 
3227 
3228 
3229 
3230 
3231 
3232 
3233 
3234 
3235 
3236 
3237 
3238 
3239 
3240 
3241 
3242 
3243 
3244 
3245 
3246 
3247 
3248 
3249 
