3350 #include "types.h"
3351 #include "defs.h"
3352 #include "param.h"
3353 #include "memlayout.h"
3354 #include "mmu.h"
3355 #include "proc.h"
3356 #include "x86.h"
3357 #include "traps.h"
3358 #include "spinlock.h"
3359 
3360 // Interrupt descriptor table (shared by all CPUs).
3361 struct gatedesc idt[256];
3362 extern uint vectors[];  // in vectors.S: array of 256 entry pointers
3363 struct spinlock tickslock;
3364 uint ticks;
3365 
3366 void
3367 tvinit(void)
3368 {
3369   int i;
3370 
3371   for(i = 0; i < 256; i++)
3372     SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
3373   SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
3374 
3375   initlock(&tickslock, "time");
3376 }
3377 
3378 void
3379 idtinit(void)
3380 {
3381   lidt(idt, sizeof(idt));
3382 }
3383 
3384 void
3385 trap(struct trapframe *tf)
3386 {
3387   if(tf->trapno == T_SYSCALL){
3388     if(proc->killed)
3389       exit();
3390     proc->tf = tf;
3391     syscall();
3392     if(proc->killed)
3393       exit();
3394     return;
3395   }
3396 
3397   switch(tf->trapno){
3398   case T_IRQ0 + IRQ_TIMER:
3399     if(cpu->id == 0){
3400       acquire(&tickslock);
3401       ticks++;
3402       release(&tickslock);    // NOTE: MarkM has reversed these two lines.
3403       wakeup(&ticks);         // wakeup() should not require the tickslock to be held
3404     }
3405     lapiceoi();
3406     break;
3407   case T_IRQ0 + IRQ_IDE:
3408     ideintr();
3409     lapiceoi();
3410     break;
3411   case T_IRQ0 + IRQ_IDE+1:
3412     // Bochs generates spurious IDE1 interrupts.
3413     break;
3414   case T_IRQ0 + IRQ_KBD:
3415     kbdintr();
3416     lapiceoi();
3417     break;
3418   case T_IRQ0 + IRQ_COM1:
3419     uartintr();
3420     lapiceoi();
3421     break;
3422   case T_IRQ0 + 7:
3423   case T_IRQ0 + IRQ_SPURIOUS:
3424     cprintf("cpu%d: spurious interrupt at %x:%x\n",
3425             cpu->id, tf->cs, tf->eip);
3426     lapiceoi();
3427     break;
3428 
3429   default:
3430     if(proc == 0 || (tf->cs&3) == 0){
3431       // In kernel, it must be our mistake.
3432       cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
3433               tf->trapno, cpu->id, tf->eip, rcr2());
3434       panic("trap");
3435     }
3436     // In user space, assume process misbehaved.
3437     cprintf("pid %d %s: trap %d err %d on cpu %d "
3438             "eip 0x%x addr 0x%x--kill proc\n",
3439             proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
3440             rcr2());
3441     proc->killed = 1;
3442   }
3443 
3444   // Force process exit if it has been killed and is in user space.
3445   // (If it is still executing in the kernel, let it keep running
3446   // until it gets to the regular system call return.)
3447   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3448     exit();
3449 
3450   // Force process to give up CPU on clock tick.
3451   // If interrupts were on while locks held, would need to check nlock.
3452   if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
3453     yield();
3454 
3455   // Check if the process has been killed since we yielded
3456   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3457     exit();
3458 }
3459 
3460 
3461 
3462 
3463 
3464 
3465 
3466 
3467 
3468 
3469 
3470 
3471 
3472 
3473 
3474 
3475 
3476 
3477 
3478 
3479 
3480 
3481 
3482 
3483 
3484 
3485 
3486 
3487 
3488 
3489 
3490 
3491 
3492 
3493 
3494 
3495 
3496 
3497 
3498 
3499 
