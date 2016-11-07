3800 #include "types.h"
3801 #include "x86.h"
3802 #include "defs.h"
3803 #include "date.h"
3804 #include "param.h"
3805 #include "memlayout.h"
3806 #include "mmu.h"
3807 #include "proc.h"
3808 #include "uproc.h"
3809 
3810 int
3811 sys_fork(void)
3812 {
3813   return fork();
3814 }
3815 
3816 int
3817 sys_exit(void)
3818 {
3819   exit();
3820   return 0;  // not reached
3821 }
3822 
3823 int
3824 sys_wait(void)
3825 {
3826   return wait();
3827 }
3828 
3829 int
3830 sys_kill(void)
3831 {
3832   int pid;
3833 
3834   if(argint(0, &pid) < 0)
3835     return -1;
3836   return kill(pid);
3837 }
3838 
3839 int
3840 sys_getpid(void)
3841 {
3842   return proc->pid;
3843 }
3844 
3845 
3846 
3847 
3848 
3849 
3850 int
3851 sys_sbrk(void)
3852 {
3853   int addr;
3854   int n;
3855 
3856   if(argint(0, &n) < 0)
3857     return -1;
3858   addr = proc->sz;
3859   if(growproc(n) < 0)
3860     return -1;
3861   return addr;
3862 }
3863 
3864 int
3865 sys_sleep(void)
3866 {
3867   int n;
3868   uint ticks0;
3869 
3870   if(argint(0, &n) < 0)
3871     return -1;
3872   acquire(&tickslock);
3873   ticks0 = ticks;
3874   while(ticks - ticks0 < n){
3875     if(proc->killed){
3876       release(&tickslock);
3877       return -1;
3878     }
3879     sleep(&ticks, &tickslock);
3880   }
3881   release(&tickslock);
3882   return 0;
3883 }
3884 
3885 // return how many clock tick interrupts have occurred
3886 // since start.
3887 int
3888 sys_uptime(void)
3889 {
3890   uint xticks;
3891 
3892   acquire(&tickslock);
3893   xticks = ticks;
3894   release(&tickslock);
3895   return xticks;
3896 }
3897 
3898 
3899 
3900 //Turn of the computer
3901 int sys_halt(void){
3902   cprintf("Shutting down ...\n");
3903   //outw (0xB004, 0x0 | 0x2000);
3904 	outw( 0x604, 0x0 | 0x2000 );
3905 	return 0;
3906 
3907 }
3908 
3909 //Get current UTC date of the system
3910 int
3911 sys_date(void)
3912 {
3913   struct rtcdate *d;
3914   if(argptr(0, (void*)&d, sizeof(*d)) < 0)
3915     return -1;
3916   cmostime(d);
3917   return 0;
3918 }
3919 
3920 #ifdef CS333_P2
3921 // Set UID
3922 int
3923 sys_setuid(void)
3924 {
3925 	uint new_uid;
3926   if(argint(0,(int*) &new_uid) < 0)
3927 		return -1;
3928 	if(new_uid < 0 || new_uid > 32767)
3929 		return -1;
3930 	proc->uid = new_uid;
3931 	return 0;
3932 }
3933 
3934 // Set GID
3935 int
3936 sys_setgid(void)
3937 {
3938 	uint new_gid;
3939   if(argint(0,(int*) &new_gid) < 0)
3940 		return -1;
3941 	if(new_gid < 0 || new_gid > 32767)
3942 		return -1;
3943 	proc->gid = new_gid;
3944 	return 0;
3945 }
3946 
3947 
3948 
3949 
3950 // Get UID of current process
3951 int
3952 sys_getuid(void)
3953 {
3954 	return proc->uid;
3955 }
3956 
3957 // Get GID of current process
3958 int
3959 sys_getgid(void)
3960 {
3961 	return proc->gid;
3962 }
3963 
3964 // Get PPID of current process
3965 int
3966 sys_getppid(void)
3967 {
3968 	if(proc->pid == 1)
3969 		return proc->pid;
3970 	if(!proc->parent)
3971 		return proc->pid;
3972 	return proc->parent->pid;
3973 }
3974 
3975 // Get process info
3976 int
3977 sys_getprocs(void)
3978 {
3979 	uint arg1;
3980 	struct uproc* table;
3981 	if(argint(0,(int*) &arg1) < 0)
3982 		return -1;
3983 	if(argptr(1,(void*)&table, sizeof(*table)) < 0)
3984 		return -1;;
3985 	return getprocs(arg1, table);
3986 }
3987 
3988 
3989 
3990 
3991 
3992 
3993 
3994 
3995 
3996 
3997 
3998 
3999 
4000 #endif
4001 
4002 #ifdef CS333_P3
4003 int
4004 sys_setpriority(void)
4005 {
4006 	int value;
4007 	int pid;
4008 	if(argint(0,(int*) &pid) < 0)
4009 		return -1;
4010 	if(argint(1,(int*) &value) < 0)
4011 		return -1;
4012   return setpriority(pid, value);
4013 }
4014 #endif
4015 
4016 
4017 
4018 
4019 
4020 
4021 
4022 
4023 
4024 
4025 
4026 
4027 
4028 
4029 
4030 
4031 
4032 
4033 
4034 
4035 
4036 
4037 
4038 
4039 
4040 
4041 
4042 
4043 
4044 
4045 
4046 
4047 
4048 
4049 
