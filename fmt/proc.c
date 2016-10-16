2150 #include "types.h"
2151 #include "defs.h"
2152 #include "param.h"
2153 #include "memlayout.h"
2154 #include "mmu.h"
2155 #include "x86.h"
2156 #include "proc.h"
2157 #include "spinlock.h"
2158 #include "uproc.h"
2159 
2160 struct {
2161   struct spinlock lock;
2162   struct proc proc[NPROC];
2163 } ptable;
2164 
2165 static struct proc *initproc;
2166 
2167 int nextpid = 1;
2168 extern void forkret(void);
2169 extern void trapret(void);
2170 
2171 static void wakeup1(void *chan);
2172 
2173 void
2174 pinit(void)
2175 {
2176   initlock(&ptable.lock, "ptable");
2177 }
2178 
2179 // Look in the process table for an UNUSED proc.
2180 // If found, change state to EMBRYO and initialize
2181 // state required to run in the kernel.
2182 // Otherwise return 0.
2183 static struct proc*
2184 allocproc(void)
2185 {
2186   struct proc *p;
2187   char *sp;
2188 
2189   acquire(&ptable.lock);
2190   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2191     if(p->state == UNUSED)
2192       goto found;
2193   release(&ptable.lock);
2194   return 0;
2195 
2196 found:
2197   p->state = EMBRYO;
2198   p->pid = nextpid++;
2199   release(&ptable.lock);
2200   // Allocate kernel stack.
2201   if((p->kstack = kalloc()) == 0){
2202     p->state = UNUSED;
2203     return 0;
2204   }
2205   sp = p->kstack + KSTACKSIZE;
2206 
2207   // Leave room for trap frame.
2208   sp -= sizeof *p->tf;
2209   p->tf = (struct trapframe*)sp;
2210 
2211   // Set up new context to start executing at forkret,
2212   // which returns to trapret.
2213   sp -= 4;
2214   *(uint*)sp = (uint)trapret;
2215 
2216   sp -= sizeof *p->context;
2217   p->context = (struct context*)sp;
2218   memset(p->context, 0, sizeof *p->context);
2219   p->context->eip = (uint)forkret;
2220 
2221   acquire(&tickslock);
2222   p->start_ticks = ticks;
2223   release(&tickslock);
2224 	p->cpu_ticks_in = 0;
2225 	p->cpu_ticks_in = 0;
2226 
2227   return p;
2228 }
2229 
2230 // Set up first user process.
2231 void
2232 userinit(void)
2233 {
2234   struct proc *p;
2235   extern char _binary_initcode_start[], _binary_initcode_size[];
2236 
2237   p = allocproc();
2238   initproc = p;
2239   if((p->pgdir = setupkvm()) == 0)
2240     panic("userinit: out of memory?");
2241   inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
2242   p->sz = PGSIZE;
2243   memset(p->tf, 0, sizeof(*p->tf));
2244   p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
2245   p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
2246   p->tf->es = p->tf->ds;
2247   p->tf->ss = p->tf->ds;
2248   p->tf->eflags = FL_IF;
2249   p->tf->esp = PGSIZE;
2250   p->tf->eip = 0;  // beginning of initcode.S
2251 
2252   safestrcpy(p->name, "initcode", sizeof(p->name));
2253   p->cwd = namei("/");
2254 
2255   p->state = RUNNABLE;
2256 
2257 #ifdef CS333_P2
2258 	p->uid = INITUID;
2259 	p->gid = INITGID;
2260 #endif
2261 }
2262 
2263 // Grow current process's memory by n bytes.
2264 // Return 0 on success, -1 on failure.
2265 int
2266 growproc(int n)
2267 {
2268   uint sz;
2269 
2270   sz = proc->sz;
2271   if(n > 0){
2272     if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
2273       return -1;
2274   } else if(n < 0){
2275     if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
2276       return -1;
2277   }
2278   proc->sz = sz;
2279   switchuvm(proc);
2280   return 0;
2281 }
2282 
2283 // Create a new process copying p as the parent.
2284 // Sets up stack to return as if from system call.
2285 // Caller must set state of returned proc to RUNNABLE.
2286 int
2287 fork(void)
2288 {
2289   int i, pid;
2290   struct proc *np;
2291 
2292   // Allocate process.
2293   if((np = allocproc()) == 0)
2294     return -1;
2295 
2296 
2297 
2298 
2299 
2300   // Copy process state from p.
2301   if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
2302     kfree(np->kstack);
2303     np->kstack = 0;
2304     np->state = UNUSED;
2305     return -1;
2306   }
2307   np->sz = proc->sz;
2308   np->parent = proc;
2309   *np->tf = *proc->tf;
2310 
2311 #ifdef CS333_P2
2312 	// Copy process UID, GID
2313 	np->uid = proc->uid;
2314 	np->gid = proc->gid;
2315 #endif
2316 
2317   // Clear %eax so that fork returns 0 in the child.
2318   np->tf->eax = 0;
2319 
2320   for(i = 0; i < NOFILE; i++)
2321     if(proc->ofile[i])
2322       np->ofile[i] = filedup(proc->ofile[i]);
2323   np->cwd = idup(proc->cwd);
2324 
2325   safestrcpy(np->name, proc->name, sizeof(proc->name));
2326 
2327   pid = np->pid;
2328 
2329   // lock to force the compiler to emit the np->state write last.
2330   acquire(&ptable.lock);
2331   np->state = RUNNABLE;
2332   release(&ptable.lock);
2333 
2334   return pid;
2335 }
2336 
2337 
2338 
2339 
2340 
2341 
2342 
2343 
2344 
2345 
2346 
2347 
2348 
2349 
2350 // Exit the current process.  Does not return.
2351 // An exited process remains in the zombie state
2352 // until its parent calls wait() to find out it exited.
2353 void
2354 exit(void)
2355 {
2356   struct proc *p;
2357   int fd;
2358 
2359   if(proc == initproc)
2360     panic("init exiting");
2361 
2362   // Close all open files.
2363   for(fd = 0; fd < NOFILE; fd++){
2364     if(proc->ofile[fd]){
2365       fileclose(proc->ofile[fd]);
2366       proc->ofile[fd] = 0;
2367     }
2368   }
2369 
2370   begin_op();
2371   iput(proc->cwd);
2372   end_op();
2373   proc->cwd = 0;
2374 
2375   acquire(&ptable.lock);
2376 
2377   // Parent might be sleeping in wait().
2378   wakeup1(proc->parent);
2379 
2380   // Pass abandoned children to init.
2381   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2382     if(p->parent == proc){
2383       p->parent = initproc;
2384       if(p->state == ZOMBIE)
2385         wakeup1(initproc);
2386     }
2387   }
2388 
2389   // Jump into the scheduler, never to return.
2390   proc->state = ZOMBIE;
2391   sched();
2392   panic("zombie exit");
2393 }
2394 
2395 
2396 
2397 
2398 
2399 
2400 // Wait for a child process to exit and return its pid.
2401 // Return -1 if this process has no children.
2402 int
2403 wait(void)
2404 {
2405   struct proc *p;
2406   int havekids, pid;
2407 
2408   acquire(&ptable.lock);
2409   for(;;){
2410     // Scan through table looking for zombie children.
2411     havekids = 0;
2412     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2413       if(p->parent != proc)
2414         continue;
2415       havekids = 1;
2416       if(p->state == ZOMBIE){
2417         // Found one.
2418         pid = p->pid;
2419         kfree(p->kstack);
2420         p->kstack = 0;
2421         freevm(p->pgdir);
2422         p->state = UNUSED;
2423         p->pid = 0;
2424         p->parent = 0;
2425         p->name[0] = 0;
2426         p->killed = 0;
2427         release(&ptable.lock);
2428         return pid;
2429       }
2430     }
2431 
2432     // No point waiting if we don't have any children.
2433     if(!havekids || proc->killed){
2434       release(&ptable.lock);
2435       return -1;
2436     }
2437 
2438     // Wait for children to exit.  (See wakeup1 call in proc_exit.)
2439     sleep(proc, &ptable.lock);  //DOC: wait-sleep
2440   }
2441 }
2442 
2443 
2444 
2445 
2446 
2447 
2448 
2449 
2450 // Per-CPU process scheduler.
2451 // Each CPU calls scheduler() after setting itself up.
2452 // Scheduler never returns.  It loops, doing:
2453 //  - choose a process to run
2454 //  - swtch to start running that process
2455 //  - eventually that process transfers control
2456 //      via swtch back to the scheduler.
2457 #ifndef CS333_P3
2458 // original xv6 scheduler. Use if CS333_P3 NOT defined.
2459 void
2460 scheduler(void)
2461 {
2462   struct proc *p;
2463 
2464   for(;;){
2465     // Enable interrupts on this processor.
2466     sti();
2467 
2468     // Loop over process table looking for process to run.
2469     acquire(&ptable.lock);
2470     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2471       if(p->state != RUNNABLE)
2472         continue;
2473 
2474       // Switch to chosen process.  It is the process's job
2475       // to release ptable.lock and then reacquire it
2476       // before jumping back to us.
2477       proc = p;
2478       switchuvm(p);
2479       p->state = RUNNING;
2480 #ifdef CS333_P2
2481 	    acquire(&tickslock);
2482 			p->cpu_ticks_in = ticks;
2483 			release(&tickslock);
2484 #endif
2485       swtch(&cpu->scheduler, proc->context);
2486       switchkvm();
2487 
2488       // Process is done running for now.
2489       // It should have changed its p->state before coming back.
2490       proc = 0;
2491     }
2492     release(&ptable.lock);
2493 
2494   }
2495 }
2496 
2497 
2498 
2499 
2500 #else
2501 // CS333_P3 MLFQ scheduler implementation goes here
2502 void
2503 scheduler(void)
2504 {
2505 
2506 }
2507 #endif
2508 
2509 // Enter scheduler.  Must hold only ptable.lock
2510 // and have changed proc->state.
2511 void
2512 sched(void)
2513 {
2514   int intena;
2515 
2516   if(!holding(&ptable.lock))
2517     panic("sched ptable.lock");
2518   if(cpu->ncli != 1)
2519     panic("sched locks");
2520   if(proc->state == RUNNING)
2521     panic("sched running");
2522   if(readeflags()&FL_IF)
2523     panic("sched interrible");
2524 #ifdef CS333_P2
2525 	acquire(&tickslock);
2526 	proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
2527 	release(&tickslock);
2528 #endif
2529   intena = cpu->intena;
2530   swtch(&proc->context, cpu->scheduler);
2531   cpu->intena = intena;
2532 }
2533 
2534 // Give up the CPU for one scheduling round.
2535 void
2536 yield(void)
2537 {
2538   acquire(&ptable.lock);  //DOC: yieldlock
2539   proc->state = RUNNABLE;
2540   sched();
2541   release(&ptable.lock);
2542 }
2543 
2544 
2545 
2546 
2547 
2548 
2549 
2550 // A fork child's very first scheduling by scheduler()
2551 // will swtch here.  "Return" to user space.
2552 void
2553 forkret(void)
2554 {
2555   static int first = 1;
2556   // Still holding ptable.lock from scheduler.
2557   release(&ptable.lock);
2558 
2559   if (first) {
2560     // Some initialization functions must be run in the context
2561     // of a regular process (e.g., they call sleep), and thus cannot
2562     // be run from main().
2563     first = 0;
2564     iinit(ROOTDEV);
2565     initlog(ROOTDEV);
2566   }
2567 
2568   // Return to "caller", actually trapret (see allocproc).
2569 }
2570 
2571 // Atomically release lock and sleep on chan.
2572 // Reacquires lock when awakened.
2573 void
2574 sleep(void *chan, struct spinlock *lk)
2575 {
2576   if(proc == 0)
2577     panic("sleep");
2578 
2579   if(lk == 0)
2580     panic("sleep without lk");
2581 
2582   // Must acquire ptable.lock in order to
2583   // change p->state and then call sched.
2584   // Once we hold ptable.lock, we can be
2585   // guaranteed that we won't miss any wakeup
2586   // (wakeup runs with ptable.lock locked),
2587   // so it's okay to release lk.
2588   if(lk != &ptable.lock){  //DOC: sleeplock0
2589     acquire(&ptable.lock);  //DOC: sleeplock1
2590     release(lk);
2591   }
2592 
2593   // Go to sleep.
2594   proc->chan = chan;
2595   proc->state = SLEEPING;
2596   sched();
2597 
2598   // Tidy up.
2599   proc->chan = 0;
2600   // Reacquire original lock.
2601   if(lk != &ptable.lock){  //DOC: sleeplock2
2602     release(&ptable.lock);
2603     acquire(lk);
2604   }
2605 }
2606 
2607 // Wake up all processes sleeping on chan.
2608 // The ptable lock must be held.
2609 static void
2610 wakeup1(void *chan)
2611 {
2612   struct proc *p;
2613 
2614   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2615     if(p->state == SLEEPING && p->chan == chan)
2616       p->state = RUNNABLE;
2617 }
2618 
2619 // Wake up all processes sleeping on chan.
2620 void
2621 wakeup(void *chan)
2622 {
2623   acquire(&ptable.lock);
2624   wakeup1(chan);
2625   release(&ptable.lock);
2626 }
2627 
2628 // Kill the process with the given pid.
2629 // Process won't exit until it returns
2630 // to user space (see trap in trap.c).
2631 int
2632 kill(int pid)
2633 {
2634   struct proc *p;
2635 
2636   acquire(&ptable.lock);
2637   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2638     if(p->pid == pid){
2639       p->killed = 1;
2640       // Wake process from sleep if necessary.
2641       if(p->state == SLEEPING)
2642         p->state = RUNNABLE;
2643       release(&ptable.lock);
2644       return 0;
2645     }
2646   }
2647   release(&ptable.lock);
2648   return -1;
2649 }
2650 // Print a process listing to console.  For debugging.
2651 // Runs when user types ^P on console.
2652 // No lock to avoid wedging a stuck machine further.
2653 static void
2654 print_elapsed(struct proc *p)
2655 {
2656   uint temp = p->start_ticks;
2657   temp = ticks - temp;
2658   cprintf("%d.%d",temp/100, temp%100);
2659 #ifdef CS333_P2
2660   cprintf("  %d.%d",p->cpu_ticks_total/100, p->cpu_ticks_total%100);
2661   cprintf("    %d  ", p->uid);
2662   cprintf("  %d  ", p->gid);
2663   if(p->parent && p->pid != 1)
2664 		cprintf("  %d  ", p->parent->pid);
2665 	else
2666 		cprintf("  %d  ", p->pid);
2667 #endif
2668 }
2669 
2670 void
2671 procdump(void)
2672 {
2673   static char *states[] = {
2674   [UNUSED]    "unused",
2675   [EMBRYO]    "embryo",
2676   [SLEEPING]  "sleep ",
2677   [RUNNABLE]  "runble",
2678   [RUNNING]   "run   ",
2679   [ZOMBIE]    "zombie"
2680   };
2681   int i;
2682   struct proc *p;
2683   char *state;
2684   uint pc[10];
2685 
2686 #ifdef CS333_P2
2687   cprintf("\nPID  State  Name  Elapsed    TotalCpuTime    UID    GID    PPID     PCs\n");
2688 #else
2689 	cprintf("\nPID  State  Name  Elapsed    PCs\n");
2690 #endif
2691 
2692   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2693     if(p->state == UNUSED)
2694       continue;
2695     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
2696       state = states[p->state];
2697     else
2698       state = "???";
2699     cprintf("%d    %s %s   ", p->pid, state, p->name);
2700     print_elapsed(p);
2701     if(p->state == SLEEPING){
2702       getcallerpcs((uint*)p->context->ebp+2, pc);
2703       for(i=0; i<10 && pc[i] != 0; i++)
2704         cprintf(" %p", pc[i]);
2705     }
2706     cprintf("\n");
2707   }
2708 }
2709 
2710 #ifdef CS333_P2
2711 // Get process information
2712 int
2713 getprocs(uint max, struct uproc* table)
2714 {
2715 	if(!table || max == 0) return -1;
2716   static char *states[] = {
2717   [UNUSED]    "unused",
2718   [EMBRYO]    "embryo",
2719   [SLEEPING]  "sleep ",
2720   [RUNNABLE]  "runble",
2721   [RUNNING]   "run   ",
2722   [ZOMBIE]    "zombie"
2723   };
2724 
2725 	int procscount = 0;
2726   struct proc *p;
2727 	if(max > NPROC)
2728 		max = NPROC;
2729 	acquire(&ptable.lock);
2730 	for(p = ptable.proc; p < &ptable.proc[max]; p++){
2731 		if(p->state == UNUSED || p->state == EMBRYO || p->state == ZOMBIE)
2732 			continue;
2733 		table->pid = p->pid;
2734 		table->uid = p->uid;
2735 		table->gid = p->gid;
2736 		if(!p->parent || p->pid ==1)
2737 			table->ppid = p->pid;
2738 		else
2739 			table->ppid = p->parent->pid;
2740 		acquire(&tickslock);
2741 		table->elapsed_ticks = ticks - p->start_ticks;
2742 		table->CPU_total_ticks = p->cpu_ticks_total;
2743 		release(&tickslock);
2744 		safestrcpy(table->state, states[p->state], sizeof(table->state));
2745 		table->size = p->sz;
2746 		safestrcpy(table->name, p->name, sizeof(table->name));
2747 		++procscount;
2748 		++table;
2749 	}
2750 	release(&ptable.lock);
2751 
2752   return procscount;
2753 }
2754 #endif
2755 
2756 
2757 
2758 
2759 
2760 
2761 
2762 
2763 
2764 
2765 
2766 
2767 
2768 
2769 
2770 
2771 
2772 
2773 
2774 
2775 
2776 
2777 
2778 
2779 
2780 
2781 
2782 
2783 
2784 
2785 
2786 
2787 
2788 
2789 
2790 
2791 
2792 
2793 
2794 
2795 
2796 
2797 
2798 
2799 
