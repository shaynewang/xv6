2200 #include "types.h"
2201 #include "defs.h"
2202 #include "param.h"
2203 #include "memlayout.h"
2204 #include "mmu.h"
2205 #include "x86.h"
2206 #include "proc.h"
2207 #include "spinlock.h"
2208 #include "uproc.h"
2209 
2210 struct {
2211   struct spinlock lock;
2212   struct proc proc[NPROC];
2213 #ifdef CS333_P3
2214 	struct proc *pReadyList[NUM_READY_LISTS];
2215 	struct proc *pFreeList;
2216 	uint PromoteAtTime;
2217 #endif
2218 } ptable;
2219 
2220 static struct proc *initproc;
2221 
2222 int nextpid = 1;
2223 extern void forkret(void);
2224 extern void trapret(void);
2225 
2226 static void wakeup1(void *chan);
2227 
2228 void
2229 pinit(void)
2230 {
2231   initlock(&ptable.lock, "ptable");
2232 }
2233 
2234 #ifdef CS333_P3
2235 // Pops a process off a process queue
2236 // Return -1 if no process in the queue
2237 static struct proc*
2238 popq(struct proc **proclist)
2239 {
2240   if(!holding(&ptable.lock))
2241     panic("popq ptable.lock\n");
2242 	if(proclist <= 0 || *proclist <= 0) return 0;
2243 	struct proc *ret;
2244 	ret = *proclist;
2245 	*proclist = (*proclist)->next;
2246 	ret->next = 0;
2247 	return ret;
2248 }
2249 
2250 // Pushs a process to the pFreeList
2251 static void
2252 pushfreeq(struct proc* input, struct proc **freelist)
2253 {
2254   if(!holding(&ptable.lock))
2255     panic("pushfreeq ptable.lock\n");
2256 	else {
2257 		input->next = *freelist;
2258 		*freelist = input;
2259 	}
2260 }
2261 
2262 // Pushs a process to the pReadyList
2263 static void
2264 pushreadyq(struct proc* input, struct proc **readylist)
2265 {
2266   if(!holding(&ptable.lock))
2267     panic("pushreadyq ptable.lock\n");
2268 	if(!input)
2269 		return;
2270 	if(!*readylist) {
2271 		input->next = 0;
2272 		*readylist = input;
2273 	}
2274 	else {
2275 		struct proc* temp = *readylist;
2276 		while(temp->next)
2277 			temp = temp->next;
2278 		temp->next = input;
2279 		input->next = 0;
2280 	}
2281 }
2282 
2283 // Set process's priority to specified value
2284 // Return 0 if success
2285 // Assumes holding ptable lock
2286 int
2287 setpriority(int pid, int priority)
2288 {
2289 	if(pid < 0)
2290     panic("pid out of bound\n");
2291 	if(priority < PRIORITY_HIGH || priority > PRIORITY_LOW) {
2292 		cprintf("Invalid priority value: %d, need an int between %d and %d\n",priority,PRIORITY_HIGH,PRIORITY_LOW);
2293 		return -1;
2294 	}
2295 
2296 	acquire(&ptable.lock);
2297   struct proc *p;
2298 	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2299 		if(p->pid == pid) {
2300 			p->priority = priority;
2301 			p->budget = BUDGET;
2302 			release(&ptable.lock);
2303 			return 0;
2304 	}
2305 	cprintf("Invalid pid: %d\n",pid);
2306 	release(&ptable.lock);
2307 	return -1;
2308 }
2309 #endif
2310 
2311 
2312 // Look in the process table for an UNUSED proc.
2313 // If found, change state to EMBRYO and initialize
2314 // state required to run in the kernel.
2315 // Otherwise return 0.
2316 static struct proc*
2317 allocproc(void)
2318 {
2319   struct proc *p;
2320   char *sp;
2321 
2322 #ifndef CS333_P3
2323   acquire(&ptable.lock);
2324   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2325     if(p->state == UNUSED)
2326       goto found;
2327   release(&ptable.lock);
2328 #else
2329 
2330   acquire(&ptable.lock);
2331 	p = popq(&ptable.pFreeList);
2332 	if(p && p->state == UNUSED)
2333 		goto found;
2334   release(&ptable.lock);
2335 #endif
2336   return 0;
2337 
2338 found:
2339   p->state = EMBRYO;
2340   p->pid = nextpid++;
2341   release(&ptable.lock);
2342 
2343   // Allocate kernel stack.
2344   if((p->kstack = kalloc()) == 0){
2345     p->state = UNUSED;
2346 		acquire(&ptable.lock);
2347 		pushfreeq(p, &ptable.pFreeList);
2348 		release(&ptable.lock);
2349     return 0;
2350   }
2351   sp = p->kstack + KSTACKSIZE;
2352 
2353   // Leave room for trap frame.
2354   sp -= sizeof *p->tf;
2355   p->tf = (struct trapframe*)sp;
2356 
2357   // Set up new context to start executing at forkret,
2358   // which returns to trapret.
2359   sp -= 4;
2360   *(uint*)sp = (uint)trapret;
2361 
2362   sp -= sizeof *p->context;
2363   p->context = (struct context*)sp;
2364   memset(p->context, 0, sizeof *p->context);
2365   p->context->eip = (uint)forkret;
2366 
2367   acquire(&tickslock);
2368   p->start_ticks = ticks;
2369   release(&tickslock);
2370 	p->cpu_ticks_in = 0;
2371 
2372   return p;
2373 }
2374 
2375 // Check if it's time to promote
2376 // Assume alway hold the lock
2377 // return 1 if it's time to promote
2378 #ifdef CS333_P3
2379 static int
2380 timetopromote(void)
2381 {
2382   if(!holding(&ptable.lock))
2383     panic("timetopromote ptable.lock");
2384 	acquire(&tickslock);
2385 	if(ticks < ptable.PromoteAtTime) {
2386 	  release(&tickslock);
2387 		return 0; // Not time to promote
2388 	}
2389 	ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
2390 	release(&tickslock);
2391   return 1;
2392 }
2393 
2394 
2395 
2396 
2397 
2398 
2399 
2400 #endif
2401 
2402 // Set up first user process.
2403 void
2404 userinit(void)
2405 {
2406   struct proc *p;
2407   extern char _binary_initcode_start[], _binary_initcode_size[];
2408 
2409 #ifdef CS333_P3
2410 	acquire(&ptable.lock);
2411 	ptable.pFreeList = 0;
2412 	// Initialize freelist by putting UNUSED processes to the list
2413   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2414     if(p->state == UNUSED)
2415 			pushfreeq(p, &ptable.pFreeList);
2416 	// Initialize readylist to empty
2417 	int i;
2418 	for(i = PRIORITY_HIGH; i < NUM_READY_LISTS; ++i) {
2419 		ptable.pReadyList[i] = 0;
2420 	}
2421 	release(&ptable.lock);
2422 #endif
2423 
2424   p = allocproc();
2425   initproc = p;
2426   if((p->pgdir = setupkvm()) == 0)
2427     panic("userinit: out of memory?");
2428   inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
2429   p->sz = PGSIZE;
2430   memset(p->tf, 0, sizeof(*p->tf));
2431   p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
2432   p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
2433   p->tf->es = p->tf->ds;
2434   p->tf->ss = p->tf->ds;
2435   p->tf->eflags = FL_IF;
2436   p->tf->esp = PGSIZE;
2437   p->tf->eip = 0;  // beginning of initcode.S
2438 
2439   safestrcpy(p->name, "initcode", sizeof(p->name));
2440   p->cwd = namei("/");
2441 
2442   p->state = RUNNABLE;
2443 #ifdef CS333_P3
2444 	acquire(&ptable.lock);
2445 	ptable.pReadyList[PRIORITY_HIGH] = p;
2446 	p->next = 0;
2447 	release(&ptable.lock);
2448 #endif
2449 
2450 #ifdef CS333_P2
2451 	p->uid = INITUID;
2452 	p->gid = INITGID;
2453 #endif
2454 }
2455 
2456 // Grow current process's memory by n bytes.
2457 // Return 0 on success, -1 on failure.
2458 int
2459 growproc(int n)
2460 {
2461   uint sz;
2462 
2463   sz = proc->sz;
2464   if(n > 0){
2465     if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
2466       return -1;
2467   } else if(n < 0){
2468     if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
2469       return -1;
2470   }
2471   proc->sz = sz;
2472   switchuvm(proc);
2473   return 0;
2474 }
2475 
2476 // Create a new process copying p as the parent.
2477 // Sets up stack to return as if from system call.
2478 // Caller must set state of returned proc to RUNNABLE.
2479 int
2480 fork(void)
2481 {
2482   int i, pid;
2483   struct proc *np;
2484 
2485   // Allocate process.
2486   if((np = allocproc()) == 0)
2487     return -1;
2488 
2489   // Copy process state from p.
2490   if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
2491     kfree(np->kstack);
2492     np->kstack = 0;
2493     np->state = UNUSED;
2494 #ifdef CS333_P3
2495 		pushfreeq(np, &ptable.pFreeList);
2496 #endif
2497     return -1;
2498   }
2499   np->sz = proc->sz;
2500   np->parent = proc;
2501   *np->tf = *proc->tf;
2502 
2503 #ifdef CS333_P2
2504 	// Copy process UID, GID
2505 	np->uid = proc->uid;
2506 	np->gid = proc->gid;
2507 #endif
2508 
2509   // Clear %eax so that fork returns 0 in the child.
2510   np->tf->eax = 0;
2511 
2512   for(i = 0; i < NOFILE; i++)
2513     if(proc->ofile[i])
2514       np->ofile[i] = filedup(proc->ofile[i]);
2515   np->cwd = idup(proc->cwd);
2516 
2517   safestrcpy(np->name, proc->name, sizeof(proc->name));
2518 
2519   pid = np->pid;
2520 
2521   // lock to force the compiler to emit the np->state write last.
2522   acquire(&ptable.lock);
2523   np->state = RUNNABLE;
2524 #ifdef CS333_P3
2525 	np->priority = PRIORITY_HIGH;
2526 	np->budget = BUDGET;
2527   pushreadyq(np, &ptable.pReadyList[PRIORITY_HIGH]);
2528 #endif
2529   release(&ptable.lock);
2530 
2531   return pid;
2532 }
2533 
2534 // Exit the current process.  Does not return.
2535 // An exited process remains in the zombie state
2536 // until its parent calls wait() to find out it exited.
2537 void
2538 exit(void)
2539 {
2540   struct proc *p;
2541   int fd;
2542 
2543   if(proc == initproc)
2544     panic("init exiting");
2545 
2546 
2547 
2548 
2549 
2550   // Close all open files.
2551   for(fd = 0; fd < NOFILE; fd++){
2552     if(proc->ofile[fd]){
2553       fileclose(proc->ofile[fd]);
2554       proc->ofile[fd] = 0;
2555     }
2556   }
2557 
2558   begin_op();
2559   iput(proc->cwd);
2560   end_op();
2561   proc->cwd = 0;
2562 
2563   acquire(&ptable.lock);
2564 
2565   // Parent might be sleeping in wait().
2566   wakeup1(proc->parent);
2567 
2568   // Pass abandoned children to init.
2569   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2570     if(p->parent == proc){
2571       p->parent = initproc;
2572       if(p->state == ZOMBIE)
2573         wakeup1(initproc);
2574     }
2575   }
2576 
2577   // Jump into the scheduler, never to return.
2578   proc->state = ZOMBIE;
2579   sched();
2580   panic("zombie exit");
2581 }
2582 
2583 // Wait for a child process to exit and return its pid.
2584 // Return -1 if this process has no children.
2585 int
2586 wait(void)
2587 {
2588   struct proc *p;
2589   int havekids, pid;
2590 
2591   acquire(&ptable.lock);
2592   for(;;){
2593     // Scan through table looking for zombie children.
2594     havekids = 0;
2595     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2596       if(p->parent != proc)
2597         continue;
2598       havekids = 1;
2599       if(p->state == ZOMBIE){
2600         // Found one.
2601         pid = p->pid;
2602         kfree(p->kstack);
2603         p->kstack = 0;
2604         freevm(p->pgdir);
2605         p->state = UNUSED;
2606 #ifdef CS333_P3
2607 				pushfreeq(p, &ptable.pFreeList);
2608 #endif
2609         p->pid = 0;
2610         p->parent = 0;
2611         p->name[0] = 0;
2612         p->killed = 0;
2613         release(&ptable.lock);
2614         return pid;
2615       }
2616     }
2617 
2618     // No point waiting if we don't have any children.
2619     if(!havekids || proc->killed){
2620       release(&ptable.lock);
2621       return -1;
2622     }
2623 
2624     // Wait for children to exit.  (See wakeup1 call in proc_exit.)
2625     sleep(proc, &ptable.lock);  //DOC: wait-sleep
2626   }
2627 }
2628 
2629 // Per-CPU process scheduler.
2630 // Each CPU calls scheduler() after setting itself up.
2631 // Scheduler never returns.  It loops, doing:
2632 //  - choose a process to run
2633 //  - swtch to start running that process
2634 //  - eventually that process transfers control
2635 //      via swtch back to the scheduler.
2636 #ifndef CS333_P3
2637 // original xv6 scheduler. Use if CS333_P3 NOT defined.
2638 void
2639 scheduler(void)
2640 {
2641   struct proc *p;
2642 
2643   for(;;){
2644     // Enable interrupts on this processor.
2645     sti();
2646 
2647 
2648 
2649 
2650     // Loop over process table looking for process to run.
2651     acquire(&ptable.lock);
2652     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2653       if(p->state != RUNNABLE)
2654         continue;
2655 
2656       // Switch to chosen process.  It is the process's job
2657       // to release ptable.lock and then reacquire it
2658       // before jumping back to us.
2659       proc = p;
2660       switchuvm(p);
2661       p->state = RUNNING;
2662 #ifdef CS333_P2
2663 	    acquire(&tickslock);
2664 			p->cpu_ticks_in = ticks;
2665 			release(&tickslock);
2666 #endif
2667       swtch(&cpu->scheduler, proc->context);
2668       switchkvm();
2669 
2670       // Process is done running for now.
2671       // It should have changed its p->state before coming back.
2672       proc = 0;
2673     }
2674     release(&ptable.lock);
2675 
2676   }
2677 }
2678 
2679 #else
2680 // CS333_P3 MLFQ scheduler implementation goes here
2681 void
2682 scheduler(void)
2683 {
2684   struct proc *p;
2685 
2686   for(;;){
2687 		// Enable interrupts on this processor.
2688 		sti();
2689 
2690 		// If promotion timer expires promote all processes one
2691 		// level up
2692 		acquire(&ptable.lock);
2693 		if(timetopromote()) {
2694 			// Increase priority for Running, sleeping processes
2695 			for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2696 				if(p->priority <= PRIORITY_HIGH)
2697 					continue;
2698 				if(p->state == RUNNING || p->state == SLEEPING){
2699 					p->budget = BUDGET;
2700 					p->priority -= 1;
2701 				}
2702 			}
2703 			// Priority queue shift up
2704 			int priority;
2705 			for(priority = PRIORITY_HIGH; priority < PRIORITY_LOW; ++priority) {
2706 				cprintf("time to promote\n");
2707 				do {
2708 					p = popq(&ptable.pReadyList[priority+1]);
2709 					if(p) {
2710 						p->priority -= 1;
2711 						p->budget = BUDGET;
2712 						pushreadyq(p, &ptable.pReadyList[p->priority]);
2713 					}
2714 				}while(p);
2715 			}
2716 		}
2717 
2718 		// Find the next runnable process and pop it from the ready
2719 		// list
2720 		int i;
2721 		for(i = PRIORITY_HIGH; i < PRIORITY_LOW+1;) {
2722 			if(!ptable.pReadyList[i]){
2723 				++i;
2724 				continue;
2725 			}
2726 			p = popq(&ptable.pReadyList[i]);
2727 
2728 			if(!p) {
2729 				panic("poping an empty readylist");
2730 			}
2731 
2732 			// Switch to chosen process.  It is the process's job
2733 			// to release ptable.lock and then reacquire it
2734 			// before jumping back to us.
2735 			proc = p;
2736 			switchuvm(p);
2737 			p->state = RUNNING;
2738 #ifdef CS333_P2
2739 			acquire(&tickslock);
2740 			p->cpu_ticks_in = ticks;
2741 			release(&tickslock);
2742 #endif
2743 			swtch(&cpu->scheduler, proc->context);
2744 			switchkvm();
2745 
2746 
2747 
2748 
2749 
2750 			// Process is done running for now.
2751 			// It should have changed its p->state before coming back.
2752 			proc = 0;
2753 		}
2754 		release(&ptable.lock);
2755   }
2756 }
2757 #endif
2758 
2759 // Enter scheduler.  Must hold only ptable.lock
2760 // and have changed proc->state.
2761 void
2762 sched(void)
2763 {
2764   int intena;
2765 
2766   if(!holding(&ptable.lock))
2767     panic("sched ptable.lock");
2768   if(cpu->ncli != 1)
2769     panic("sched locks");
2770   if(proc->state == RUNNING)
2771     panic("sched running");
2772   if(readeflags()&FL_IF)
2773     panic("sched interrible");
2774   intena = cpu->intena;
2775 #ifdef CS333_P2
2776 	acquire(&tickslock);
2777 	proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
2778 #ifdef CS333_P3
2779 	proc->budget -= ticks - proc->cpu_ticks_in;
2780 #endif
2781 	release(&tickslock);
2782 #endif
2783 
2784 #ifdef CS333_P3
2785 	// Check process's budget if its <= 0
2786 	// demote to the next lower priority queue
2787 	// else add it to the back of current queue.
2788 	if(proc->budget <= 0 && proc->priority < PRIORITY_LOW){
2789 			proc->priority += 1;
2790 			proc->budget = BUDGET;
2791 	}
2792 	if(proc->state == RUNNABLE)
2793 			pushreadyq(proc, &ptable.pReadyList[proc->priority]);
2794 #endif
2795   swtch(&proc->context, cpu->scheduler);
2796   cpu->intena = intena;
2797 }
2798 
2799 
2800 // Give up the CPU for one scheduling round.
2801 void
2802 yield(void)
2803 {
2804   acquire(&ptable.lock);  //DOC: yieldlock
2805   proc->state = RUNNABLE;
2806   sched();
2807   release(&ptable.lock);
2808 }
2809 
2810 // A fork child's very first scheduling by scheduler()
2811 // will swtch here.  "Return" to user space.
2812 void
2813 forkret(void)
2814 {
2815   static int first = 1;
2816   // Still holding ptable.lock from scheduler.
2817   release(&ptable.lock);
2818 
2819   if (first) {
2820     // Some initialization functions must be run in the context
2821     // of a regular process (e.g., they call sleep), and thus cannot
2822     // be run from main().
2823     first = 0;
2824     iinit(ROOTDEV);
2825     initlog(ROOTDEV);
2826   }
2827 
2828   // Return to "caller", actually trapret (see allocproc).
2829 }
2830 
2831 // Atomically release lock and sleep on chan.
2832 // Reacquires lock when awakened.
2833 void
2834 sleep(void *chan, struct spinlock *lk)
2835 {
2836   if(proc == 0)
2837     panic("sleep");
2838 
2839   if(lk == 0)
2840     panic("sleep without lk");
2841 
2842   // Must acquire ptable.lock in order to
2843   // change p->state and then call sched.
2844   // Once we hold ptable.lock, we can be
2845   // guaranteed that we won't miss any wakeup
2846   // (wakeup runs with ptable.lock locked),
2847   // so it's okay to release lk.
2848   if(lk != &ptable.lock){  //DOC: sleeplock0
2849     acquire(&ptable.lock);  //DOC: sleeplock1
2850     release(lk);
2851   }
2852 
2853   // Go to sleep.
2854   proc->chan = chan;
2855   proc->state = SLEEPING;
2856   sched();
2857 
2858   // Tidy up.
2859   proc->chan = 0;
2860 
2861   // Reacquire original lock.
2862   if(lk != &ptable.lock){  //DOC: sleeplock2
2863     release(&ptable.lock);
2864     acquire(lk);
2865   }
2866 }
2867 
2868 // Wake up all processes sleeping on chan.
2869 // The ptable lock must be held.
2870 static void
2871 wakeup1(void *chan)
2872 {
2873   struct proc *p;
2874 
2875   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2876 #ifndef CS333_P3
2877     if(p->state == SLEEPING && p->chan == chan)
2878       p->state = RUNNABLE;
2879 #else
2880     if(p->state == SLEEPING && p->chan == chan) {
2881       p->state = RUNNABLE;
2882 			pushreadyq(p, &ptable.pReadyList[p->priority]);
2883 		}
2884 #endif
2885 }
2886 
2887 // Wake up all processes sleeping on chan.
2888 void
2889 wakeup(void *chan)
2890 {
2891   acquire(&ptable.lock);
2892   wakeup1(chan);
2893   release(&ptable.lock);
2894 }
2895 
2896 
2897 
2898 
2899 
2900 // Kill the process with the given pid.
2901 // Process won't exit until it returns
2902 // to user space (see trap in trap.c).
2903 int
2904 kill(int pid)
2905 {
2906   struct proc *p;
2907 
2908   acquire(&ptable.lock);
2909   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2910     if(p->pid == pid){
2911       p->killed = 1;
2912       // Wake process from sleep if necessary.
2913 #ifndef CS333_P3
2914       if(p->state == SLEEPING)
2915         p->state = RUNNABLE;
2916 #else
2917       if(p->state == SLEEPING) {
2918         p->state = RUNNABLE;
2919 				pushreadyq(p, &ptable.pReadyList[p->priority]);
2920 			}
2921 #endif
2922 
2923       release(&ptable.lock);
2924       return 0;
2925     }
2926   }
2927   release(&ptable.lock);
2928   return -1;
2929 }
2930 
2931 // Print a process listing to console.  For debugging.
2932 // Runs when user types ^P on console.
2933 // No lock to avoid wedging a stuck machine further.
2934 static void
2935 print_elapsed(struct proc *p)
2936 {
2937   uint temp = p->start_ticks;
2938   temp = ticks - temp;
2939   cprintf("%d.%d",temp/100, temp%100);
2940 #ifdef CS333_P2
2941   cprintf("  %d.%d",p->cpu_ticks_total/100, p->cpu_ticks_total%100);
2942   cprintf("    %d  ", p->uid);
2943   cprintf("  %d  ", p->gid);
2944   if(p->parent && p->pid != 1)
2945 		cprintf("  %d  ", p->parent->pid);
2946 	else
2947 		cprintf("  %d  ", p->pid);
2948 #ifdef CS333_P3
2949 	cprintf("  %d  ", p->priority);
2950 #endif
2951 #endif
2952 }
2953 
2954 void
2955 procdump(void)
2956 {
2957   static char *states[] = {
2958   [UNUSED]    "unused",
2959   [EMBRYO]    "embryo",
2960   [SLEEPING]  "sleep ",
2961   [RUNNABLE]  "runble",
2962   [RUNNING]   "run   ",
2963   [ZOMBIE]    "zombie"
2964   };
2965   int i;
2966   struct proc *p;
2967   char *state;
2968   uint pc[10];
2969 
2970 #ifdef CS333_P3
2971   cprintf("\nPID  State  Name  Elapsed    TotalCpuTime    UID    GID    PPID   Priority   PCs\n");
2972 #else
2973 #ifdef CS333_P2
2974   cprintf("\nPID  State  Name  Elapsed    TotalCpuTime    UID    GID    PPID     PCs\n");
2975 #else
2976 	cprintf("\nPID  State  Name  Elapsed    PCs\n");
2977 #endif
2978 #endif
2979 
2980   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2981     if(p->state == UNUSED)
2982       continue;
2983     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
2984       state = states[p->state];
2985     else
2986       state = "???";
2987     cprintf("%d    %s %s   ", p->pid, state, p->name);
2988     print_elapsed(p);
2989     if(p->state == SLEEPING){
2990       getcallerpcs((uint*)p->context->ebp+2, pc);
2991       for(i=0; i<10 && pc[i] != 0; i++)
2992         cprintf(" %p", pc[i]);
2993     }
2994     cprintf("\n");
2995   }
2996 }
2997 
2998 
2999 
3000 #ifdef CS333_P2
3001 // Get process information
3002 int
3003 getprocs(uint max, struct uproc* table)
3004 {
3005 	if(!table || max == 0) return -1;
3006   static char *states[] = {
3007   [UNUSED]    "unused",
3008   [EMBRYO]    "embryo",
3009   [SLEEPING]  "sleep ",
3010   [RUNNABLE]  "runble",
3011   [RUNNING]   "run   ",
3012   [ZOMBIE]    "zombie"
3013   };
3014 
3015 	int procscount = 0;
3016   struct proc *p;
3017 	if(max > NPROC)
3018 		max = NPROC;
3019 	acquire(&ptable.lock);
3020 	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
3021 		if(max <= 0) break; // break out of the loop if the max number of processes to be displayed has reached
3022 		if(p->state == UNUSED || p->state == EMBRYO || p->state == ZOMBIE)
3023 			continue;
3024 		table->pid = p->pid;
3025 		table->uid = p->uid;
3026 		table->gid = p->gid;
3027 		if(!p->parent || p->pid ==1)
3028 			table->ppid = p->pid;
3029 		else
3030 			table->ppid = p->parent->pid;
3031 #ifdef CS333_P3
3032 		table->priority = p->priority;
3033 #endif
3034 		acquire(&tickslock);
3035 		table->elapsed_ticks = ticks - p->start_ticks;
3036 		table->CPU_total_ticks = p->cpu_ticks_total;
3037 		release(&tickslock);
3038 		safestrcpy(table->state, states[p->state], sizeof(table->state));
3039 		table->size = p->sz;
3040 		safestrcpy(table->name, p->name, sizeof(table->name));
3041 		++procscount;
3042 		++table;
3043 		--max;
3044 	}
3045 	release(&ptable.lock);
3046 
3047   return procscount;
3048 }
3049 #endif
