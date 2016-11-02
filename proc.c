#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "uproc.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
#ifdef CS333_P3
	struct proc *pReadyList[NUM_READY_LISTS];
	struct proc *pFreeList;
	uint PromoteAtTime;
#endif
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

#ifdef CS333_P3
// Pops a process off a process queue
static struct proc*
popq(struct proc **proclist)
{
	if(!proclist) return 0;
	struct proc *ret;
	ret = *proclist;
	ret->next = 0;
	*proclist = (*proclist)->next;
	return ret;
}


// Pushs a process to the pFreeList
static int
pushfreeq(struct proc* input, struct proc **freelist)
{
  if(!holding(&ptable.lock))
    panic("pushfreeq ptable.lock\n");
	if(!input || input->state != UNUSED)
		panic("error push to freelist\n");
	else {
		input->next = *freelist;
		*freelist = input;
	}
	return 0;
}

// Pushs a process to the pReadyList
static int
pushreadyq(struct proc* input, struct proc **readylist)
{
	if(!input) return -1;
	input->state = RUNNABLE;
	if(!*readylist) {
		input->next = 0;
		*readylist = input;
	}
	else {
		struct proc* temp = *readylist;
		while(temp->next)
			temp = temp->next;
		temp->next = input;
		input->next = 0;
	}
	return 0;
}

// Pops unused process off the free list
static struct proc*
popfree(struct proc **freelist)
{
	if(!*freelist) return 0;
	struct proc *ret;
	ret = popq(freelist);
	if(ret->state == UNUSED)
		return ret;
	pushfreeq(ret, freelist);
	panic("NON-UNUSED process in freelist");
}

// Pops runnable process off the ready list
static struct proc*
popready(struct proc **readylist)
{
	if(!*readylist) return 0;
	struct proc *ret;
	ret = popq(readylist);
	if(ret->state == RUNNABLE)
		return ret;
	pushreadyq(ret, readylist);
	panic("NON-RUNNABLE process in readylist");
}
#endif


// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

#ifndef CS333_P3
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
#else
	p = 0;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
			pushfreeq(p, &ptable.pFreeList);
	p = popfree(&ptable.pFreeList);
	if(p && p->state == UNUSED)
		goto found;
  release(&ptable.lock);
#endif
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  acquire(&tickslock);
  p->start_ticks = ticks;
  release(&tickslock);
	p->cpu_ticks_in = 0;

  return p;
}

// Check if it's time to promote
// Assume alway hold the lock
// return 1 if it's time to promote
#ifdef CS333_P3
static int
timetopromote(void)
{
  if(!holding(&ptable.lock))
    panic("timetopromote ptable.lock");
	acquire(&tickslock);
	if(ticks < ptable.PromoteAtTime) {
	  release(&tickslock);
		return 0; // Not time to promote
	}
	ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
	release(&tickslock);
  return 1;	
}

//TODO: Set a process's priority to value
int
setpriority(int pid, int priority)
{
	return 0;
}
#endif

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3
	acquire(&ptable.lock);
	timetopromote(); // Initialize promote timer
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
			pushfreeq(p, &ptable.pFreeList);
	release(&ptable.lock);
#endif
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
#ifdef CS333_P3
	if(p->state == RUNNABLE) {
		p->next = 0;
		acquire(&ptable.lock);
		pushreadyq(p, &ptable.pReadyList[0]);
		release(&ptable.lock);
	}
	else
		panic("userinit: not RUNNABLE process cannot be ran.");
#endif

#ifdef CS333_P2
	p->uid = INITUID;
	p->gid = INITGID;
#endif
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

#ifdef CS333_P2
	// Copy process UID, GID
	np->uid = proc->uid;
	np->gid = proc->gid;
#endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
#ifdef CS333_P3
  pushreadyq(np, &ptable.pReadyList[0]);
#endif
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3
// original xv6 scheduler. Use if CS333_P3 NOT defined.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
#ifdef CS333_P2
	    acquire(&tickslock);
			p->cpu_ticks_in = ticks;
			release(&tickslock);
#endif
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);

  }
}

#else
// CS333_P3 MLFQ scheduler implementation goes here
void
scheduler(void)
{
  struct proc *p;

  for(;;){
		// Enable interrupts on this processor.
		sti();

		// Loop over process table looking for process to run.
		p = 0;
		acquire(&ptable.lock);
		p = popready(&ptable.pReadyList[0]);
		if(!p) {
				release(&ptable.lock);
				continue;
		}
		if(p && p->state != RUNNABLE)
				panic("Non-runnable process in readytable");

		// Switch to chosen process.  It is the process's job
		// to release ptable.lock and then reacquire it
		// before jumping back to us.
		proc = p;
		switchuvm(p);
		p->state = RUNNING;
#ifdef CS333_P2
		acquire(&tickslock);
		p->cpu_ticks_in = ticks;
		release(&tickslock);
#endif
		swtch(&cpu->scheduler, proc->context);
		switchkvm();

		// Process is done running for now.
		// It should have changed its p->state before coming back.
		proc = 0;
    release(&ptable.lock);
  }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interrible");
#ifdef CS333_P2
	acquire(&tickslock);
	proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
	release(&tickslock);
#endif
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
#ifdef CS333_P3
	pushreadyq(proc, &ptable.pReadyList[0]);
#endif
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
#ifndef CS333_P3
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
#else
    if(p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;
			pushreadyq(p, &ptable.pReadyList[0]);
		}
#endif
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
#ifndef CS333_P3
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
#else
      if(p->state == SLEEPING) {
        p->state = RUNNABLE;
				pushreadyq(p, &ptable.pReadyList[0]);
			}
#endif

      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
static void
print_elapsed(struct proc *p)
{
  uint temp = p->start_ticks;
  temp = ticks - temp;
  cprintf("%d.%d",temp/100, temp%100);
#ifdef CS333_P2
  cprintf("  %d.%d",p->cpu_ticks_total/100, p->cpu_ticks_total%100);
  cprintf("    %d  ", p->uid);
  cprintf("  %d  ", p->gid);
  if(p->parent && p->pid != 1)
		cprintf("  %d  ", p->parent->pid);
	else
		cprintf("  %d  ", p->pid);
#endif
}

void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

#ifdef CS333_P2
  cprintf("\nPID  State  Name  Elapsed    TotalCpuTime    UID    GID    PPID     PCs\n");
#else
	cprintf("\nPID  State  Name  Elapsed    PCs\n");
#endif
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d    %s %s   ", p->pid, state, p->name);
    print_elapsed(p);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

#ifdef CS333_P2
// Get process information
int
getprocs(uint max, struct uproc* table)
{
	if(!table || max == 0) return -1;
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };

	int procscount = 0;
  struct proc *p;
	if(max > NPROC)
		max = NPROC;
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
		if(max <= 0) break; // break out of the loop if the max number of processes to be displayed has reached
		if(p->state == UNUSED || p->state == EMBRYO || p->state == ZOMBIE)
			continue;
		table->pid = p->pid;
		table->uid = p->uid;
		table->gid = p->gid;
		if(!p->parent || p->pid ==1)
			table->ppid = p->pid;
		else
			table->ppid = p->parent->pid;
		acquire(&tickslock);
		table->elapsed_ticks = ticks - p->start_ticks;
		table->CPU_total_ticks = p->cpu_ticks_total;
		release(&tickslock);
		safestrcpy(table->state, states[p->state], sizeof(table->state));
		table->size = p->sz;
		safestrcpy(table->name, p->name, sizeof(table->name));
		++procscount;
		++table;
		--max;
	}
	release(&ptable.lock);

  return procscount;
}
#endif
