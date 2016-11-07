3550 #include "types.h"
3551 #include "defs.h"
3552 #include "param.h"
3553 #include "memlayout.h"
3554 #include "mmu.h"
3555 #include "proc.h"
3556 #include "x86.h"
3557 #include "syscall.h"
3558 
3559 // User code makes a system call with INT T_SYSCALL.
3560 // System call number in %eax.
3561 // Arguments on the stack, from the user call to the C
3562 // library system call function. The saved user %esp points
3563 // to a saved program counter, and then the first argument.
3564 
3565 // Fetch the int at addr from the current process.
3566 int
3567 fetchint(uint addr, int *ip)
3568 {
3569   if(addr >= proc->sz || addr+4 > proc->sz)
3570     return -1;
3571   *ip = *(int*)(addr);
3572   return 0;
3573 }
3574 
3575 // Fetch the nul-terminated string at addr from the current process.
3576 // Doesn't actually copy the string - just sets *pp to point at it.
3577 // Returns length of string, not including nul.
3578 int
3579 fetchstr(uint addr, char **pp)
3580 {
3581   char *s, *ep;
3582 
3583   if(addr >= proc->sz)
3584     return -1;
3585   *pp = (char*)addr;
3586   ep = (char*)proc->sz;
3587   for(s = *pp; s < ep; s++)
3588     if(*s == 0)
3589       return s - *pp;
3590   return -1;
3591 }
3592 
3593 // Fetch the nth 32-bit system call argument.
3594 int
3595 argint(int n, int *ip)
3596 {
3597   return fetchint(proc->tf->esp + 4 + 4*n, ip);
3598 }
3599 
3600 // Fetch the nth word-sized system call argument as a pointer
3601 // to a block of memory of size n bytes.  Check that the pointer
3602 // lies within the process address space.
3603 int
3604 argptr(int n, char **pp, int size)
3605 {
3606   int i;
3607 
3608   if(argint(n, &i) < 0)
3609     return -1;
3610   if((uint)i >= proc->sz || (uint)i+size > proc->sz)
3611     return -1;
3612   *pp = (char*)i;
3613   return 0;
3614 }
3615 
3616 // Fetch the nth word-sized system call argument as a string pointer.
3617 // Check that the pointer is valid and the string is nul-terminated.
3618 // (There is no shared writable memory, so the string can't change
3619 // between this check and being used by the kernel.)
3620 int
3621 argstr(int n, char **pp)
3622 {
3623   int addr;
3624   if(argint(n, &addr) < 0)
3625     return -1;
3626   return fetchstr(addr, pp);
3627 }
3628 
3629 extern int sys_chdir(void);
3630 extern int sys_close(void);
3631 extern int sys_dup(void);
3632 extern int sys_exec(void);
3633 extern int sys_exit(void);
3634 extern int sys_fork(void);
3635 extern int sys_fstat(void);
3636 extern int sys_getpid(void);
3637 extern int sys_kill(void);
3638 extern int sys_link(void);
3639 extern int sys_mkdir(void);
3640 extern int sys_mknod(void);
3641 extern int sys_open(void);
3642 extern int sys_pipe(void);
3643 extern int sys_read(void);
3644 extern int sys_sbrk(void);
3645 extern int sys_sleep(void);
3646 extern int sys_unlink(void);
3647 extern int sys_wait(void);
3648 extern int sys_write(void);
3649 extern int sys_uptime(void);
3650 extern int sys_halt(void);
3651 extern int sys_date(void);
3652 #ifdef CS333_P2
3653 extern int sys_getuid(void);
3654 extern int sys_getgid(void);
3655 extern int sys_getppid(void);
3656 extern int sys_setuid(void);
3657 extern int sys_setgid(void);
3658 extern int sys_getprocs(void);
3659 #endif
3660 #ifdef CS333_P3
3661 extern int sys_setpriority(void);
3662 #endif
3663 
3664 static int (*syscalls[])(void) = {
3665 [SYS_fork]    sys_fork,
3666 [SYS_exit]    sys_exit,
3667 [SYS_wait]    sys_wait,
3668 [SYS_pipe]    sys_pipe,
3669 [SYS_read]    sys_read,
3670 [SYS_kill]    sys_kill,
3671 [SYS_exec]    sys_exec,
3672 [SYS_fstat]   sys_fstat,
3673 [SYS_chdir]   sys_chdir,
3674 [SYS_dup]     sys_dup,
3675 [SYS_getpid]  sys_getpid,
3676 [SYS_sbrk]    sys_sbrk,
3677 [SYS_sleep]   sys_sleep,
3678 [SYS_uptime]  sys_uptime,
3679 [SYS_open]    sys_open,
3680 [SYS_write]   sys_write,
3681 [SYS_mknod]   sys_mknod,
3682 [SYS_unlink]  sys_unlink,
3683 [SYS_link]    sys_link,
3684 [SYS_mkdir]   sys_mkdir,
3685 [SYS_close]   sys_close,
3686 [SYS_halt]    sys_halt,
3687 [SYS_date]    sys_date,
3688 #ifdef CS333_P2
3689 [SYS_getuid]  sys_getuid,
3690 [SYS_getgid]  sys_getgid,
3691 [SYS_getppid] sys_getppid,
3692 [SYS_setuid]  sys_setuid,
3693 [SYS_setgid]  sys_setgid,
3694 [SYS_getprocs]  sys_getprocs,
3695 #endif
3696 #ifdef CS333_P3
3697 [SYS_setpriority]  sys_setpriority,
3698 #endif
3699 };
3700 // put data structure for printing out system call invocation information here
3701 #ifdef PRINT_SYSCALLS
3702 static const char * (print_syscalls[]) = {
3703 [SYS_fork] = "fork",
3704 [SYS_exit]   = "exit",
3705 [SYS_wait]     = "wait",
3706 [SYS_pipe]     = "pipe",
3707 [SYS_read]     = "read",
3708 [SYS_kill]     = "kill",
3709 [SYS_exec]     = "exec",
3710 [SYS_fstat]    = "fstat",
3711 [SYS_chdir]    = "chdir",
3712 [SYS_dup]      = "dup",
3713 [SYS_getpid]   = "getpid",
3714 [SYS_sbrk]     = "sbrk",
3715 [SYS_sleep]    = "sleep",
3716 [SYS_uptime]   = "uptime",
3717 [SYS_open]     = "open",
3718 [SYS_write]    = "write",
3719 [SYS_mknod]    = "mknod",
3720 [SYS_unlink]   = "unlink",
3721 [SYS_link]     = "link",
3722 [SYS_mkdir]    = "mkdir",
3723 [SYS_close]    = "close",
3724 [SYS_halt]     = "halt",
3725 [SYS_date]     = "date",
3726 #ifdef CS333_P2
3727 [SYS_getgid]   = "getuid",
3728 [SYS_getuid]   = "getgid",
3729 [SYS_getppid]  = "getppid",
3730 [SYS_setgid]   = "setuid",
3731 [SYS_setuid]   = "setgid",
3732 [SYS_getprocs]   = "getprocs",
3733 #endif
3734 #ifdef CS333_P3
3735 [SYS_setpriority]  = "setpriority",
3736 #endif
3737 };
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
3750 #endif
3751 
3752 void
3753 syscall(void)
3754 {
3755   int num;
3756 
3757   num = proc->tf->eax;
3758   if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
3759     proc->tf->eax = syscalls[num]();
3760 // some code goes here
3761 #ifdef PRINT_SYSCALLS
3762 	cprintf("%s -> %d\n", print_syscalls[num], proc->tf->eax);
3763 #endif
3764   } else {
3765     cprintf("%d %s: unknown sys call %d\n",
3766             proc->pid, proc->name, num);
3767     proc->tf->eax = -1;
3768   }
3769 }
3770 
3771 
3772 
3773 
3774 
3775 
3776 
3777 
3778 
3779 
3780 
3781 
3782 
3783 
3784 
3785 
3786 
3787 
3788 
3789 
3790 
3791 
3792 
3793 
3794 
3795 
3796 
3797 
3798 
3799 
