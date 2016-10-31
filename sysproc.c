#include "types.h"
#include "x86.h"
#include "defs.h" 
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

//Turn of the computer
int sys_halt(void){
  cprintf("Shutting down ...\n");
  //outw (0xB004, 0x0 | 0x2000);
	outw( 0x604, 0x0 | 0x2000 );
	return 0;

}

//Get current UTC date of the system
int
sys_date(void)
{
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(*d)) < 0)
    return -1;
  cmostime(d);
  return 0;
}

#ifdef CS333_P2
// Set UID
int
sys_setuid(void)
{
	uint new_uid;
  if(argint(0,(int*) &new_uid) < 0)
		return -1;
	if(new_uid < 0 || new_uid > 32767)
		return -1;
	proc->uid = new_uid;
	return 0;
}

// Set GID
int
sys_setgid(void)
{
	uint new_gid;
  if(argint(0,(int*) &new_gid) < 0)
		return -1;
	if(new_gid < 0 || new_gid > 32767)
		return -1;
	proc->gid = new_gid;
	return 0;
}

// Get UID of current process
uint
sys_getuid(void)
{
	return proc->uid;
}

// Get GID of current process
uint
sys_getgid(void)
{
	return proc->gid;
}

// Get PPID of current process
uint
sys_getppid(void)
{
	if(proc->pid == 1)
		return proc->pid;
	if(!proc->parent)
		return proc->pid;
	return proc->parent->pid;
}

// Get process info
int
sys_getprocs(void)
{
	uint arg1;
	struct uproc* table;
	if(argint(0,(int*) &arg1) < 0)
		return -1;
	if(argptr(1,(void*)&table, sizeof(*table)) < 0)
		return -1;;
	return getprocs(arg1, table);
}
#endif

#ifdef CS333_P3
int
sys_setpriority(void)
{
	int value;
	if(argint(1,(int*) &value) < 0)
		return -1;
  return setpriority(getpid(), value);
}
#endif
