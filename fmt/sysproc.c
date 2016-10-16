3550 #include "types.h"
3551 #include "x86.h"
3552 #include "defs.h"
3553 #include "date.h"
3554 #include "param.h"
3555 #include "memlayout.h"
3556 #include "mmu.h"
3557 #include "proc.h"
3558 #include "uproc.h"
3559 
3560 int
3561 sys_fork(void)
3562 {
3563   return fork();
3564 }
3565 
3566 int
3567 sys_exit(void)
3568 {
3569   exit();
3570   return 0;  // not reached
3571 }
3572 
3573 int
3574 sys_wait(void)
3575 {
3576   return wait();
3577 }
3578 
3579 int
3580 sys_kill(void)
3581 {
3582   int pid;
3583 
3584   if(argint(0, &pid) < 0)
3585     return -1;
3586   return kill(pid);
3587 }
3588 
3589 int
3590 sys_getpid(void)
3591 {
3592   return proc->pid;
3593 }
3594 
3595 
3596 
3597 
3598 
3599 
3600 int
3601 sys_sbrk(void)
3602 {
3603   int addr;
3604   int n;
3605 
3606   if(argint(0, &n) < 0)
3607     return -1;
3608   addr = proc->sz;
3609   if(growproc(n) < 0)
3610     return -1;
3611   return addr;
3612 }
3613 
3614 int
3615 sys_sleep(void)
3616 {
3617   int n;
3618   uint ticks0;
3619 
3620   if(argint(0, &n) < 0)
3621     return -1;
3622   acquire(&tickslock);
3623   ticks0 = ticks;
3624   while(ticks - ticks0 < n){
3625     if(proc->killed){
3626       release(&tickslock);
3627       return -1;
3628     }
3629     sleep(&ticks, &tickslock);
3630   }
3631   release(&tickslock);
3632   return 0;
3633 }
3634 
3635 // return how many clock tick interrupts have occurred
3636 // since start.
3637 int
3638 sys_uptime(void)
3639 {
3640   uint xticks;
3641 
3642   acquire(&tickslock);
3643   xticks = ticks;
3644   release(&tickslock);
3645   return xticks;
3646 }
3647 
3648 
3649 
3650 //Turn of the computer
3651 int sys_halt(void){
3652   cprintf("Shutting down ...\n");
3653   //outw (0xB004, 0x0 | 0x2000);
3654 	outw( 0x604, 0x0 | 0x2000 );
3655 	return 0;
3656 
3657 }
3658 
3659 //Get current UTC date of the system
3660 int
3661 sys_date(void)
3662 {
3663   struct rtcdate *d;
3664   if(argptr(0, (void*)&d, sizeof(*d)) < 0)
3665     return -1;
3666   cmostime(d);
3667   return 0;
3668 }
3669 
3670 #ifdef CS333_P2
3671 // Set UID
3672 int
3673 sys_setuid(void)
3674 {
3675 	uint new_uid;
3676   if(argint(0,(int*) &new_uid) < 0)
3677 		return -1;
3678 	if(new_uid < 0 || new_uid > 32767)
3679 		return -1;
3680 	proc->uid = new_uid;
3681 	return 0;
3682 }
3683 
3684 // Set GID
3685 int
3686 sys_setgid(void)
3687 {
3688 	uint new_gid;
3689   if(argint(0,(int*) &new_gid) < 0)
3690 		return -1;
3691 	if(new_gid < 0 || new_gid > 32767)
3692 		return -1;
3693 	proc->gid = new_gid;
3694 	return 0;
3695 }
3696 
3697 
3698 
3699 
3700 // Get UID of current process
3701 uint
3702 sys_getuid(void)
3703 {
3704 	return proc->uid;
3705 }
3706 
3707 // Get GID of current process
3708 uint
3709 sys_getgid(void)
3710 {
3711 	return proc->gid;
3712 }
3713 
3714 // Get PPID of current process
3715 uint
3716 sys_getppid(void)
3717 {
3718 	if(proc->pid == 1)
3719 		return proc->pid;
3720 	if(!proc->parent)
3721 		return proc->pid;
3722 	return proc->parent->pid;
3723 }
3724 
3725 // Get process info
3726 int
3727 sys_getprocs(void)
3728 {
3729 	uint arg1;
3730 	struct uproc* table;
3731 	if(argint(0,(int*) &arg1) < 0)
3732 		return -1;
3733 	if(argptr(1,(void*)&table, sizeof(*table)) < 0)
3734 		return -1;;
3735 	return getprocs(arg1, table);
3736 }
3737 #endif
3738 
3739 
3740 
3741 
3742 
3743 
3744 
3745 
3746 
3747 
3748 
3749 
