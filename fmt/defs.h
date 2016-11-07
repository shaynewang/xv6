0300 struct buf;
0301 struct context;
0302 struct file;
0303 struct inode;
0304 struct pipe;
0305 struct proc;
0306 struct rtcdate;
0307 struct spinlock;
0308 struct stat;
0309 struct superblock;
0310 #ifdef CS333_P2
0311 struct uproc;
0312 #endif
0313 
0314 
0315 // bio.c
0316 void            binit(void);
0317 struct buf*     bread(uint, uint);
0318 void            brelse(struct buf*);
0319 void            bwrite(struct buf*);
0320 // console.c
0321 void            consoleinit(void);
0322 void            cprintf(char*, ...);
0323 void            consoleintr(int(*)(void));
0324 void            panic(char*) __attribute__((noreturn));
0325 
0326 // exec.c
0327 int             exec(char*, char**);
0328 
0329 // file.c
0330 struct file*    filealloc(void);
0331 void            fileclose(struct file*);
0332 struct file*    filedup(struct file*);
0333 void            fileinit(void);
0334 int             fileread(struct file*, char*, int n);
0335 int             filestat(struct file*, struct stat*);
0336 int             filewrite(struct file*, char*, int n);
0337 
0338 // fs.c
0339 void            readsb(int dev, struct superblock *sb);
0340 int             dirlink(struct inode*, char*, uint);
0341 struct inode*   dirlookup(struct inode*, char*, uint*);
0342 struct inode*   ialloc(uint, short);
0343 struct inode*   idup(struct inode*);
0344 void            iinit(int dev);
0345 void            ilock(struct inode*);
0346 void            iput(struct inode*);
0347 void            iunlock(struct inode*);
0348 void            iunlockput(struct inode*);
0349 void            iupdate(struct inode*);
0350 int             namecmp(const char*, const char*);
0351 struct inode*   namei(char*);
0352 struct inode*   nameiparent(char*, char*);
0353 int             readi(struct inode*, char*, uint, uint);
0354 void            stati(struct inode*, struct stat*);
0355 int             writei(struct inode*, char*, uint, uint);
0356 
0357 // ide.c
0358 void            ideinit(void);
0359 void            ideintr(void);
0360 void            iderw(struct buf*);
0361 
0362 // ioapic.c
0363 void            ioapicenable(int irq, int cpu);
0364 extern uchar    ioapicid;
0365 void            ioapicinit(void);
0366 
0367 // kalloc.c
0368 char*           kalloc(void);
0369 void            kfree(char*);
0370 void            kinit1(void*, void*);
0371 void            kinit2(void*, void*);
0372 
0373 // kbd.c
0374 void            kbdintr(void);
0375 
0376 // lapic.c
0377 void            cmostime(struct rtcdate *r);
0378 int             cpunum(void);
0379 extern volatile uint*    lapic;
0380 void            lapiceoi(void);
0381 void            lapicinit(void);
0382 void            lapicstartap(uchar, uint);
0383 void            microdelay(int);
0384 
0385 // log.c
0386 void            initlog(int dev);
0387 void            log_write(struct buf*);
0388 void            begin_op();
0389 void            end_op();
0390 
0391 // mp.c
0392 extern int      ismp;
0393 int             mpbcpu(void);
0394 void            mpinit(void);
0395 void            mpstartthem(void);
0396 
0397 // picirq.c
0398 void            picenable(int);
0399 void            picinit(void);
0400 // pipe.c
0401 int             pipealloc(struct file**, struct file**);
0402 void            pipeclose(struct pipe*, int);
0403 int             piperead(struct pipe*, char*, int);
0404 int             pipewrite(struct pipe*, char*, int);
0405 
0406 // proc.c
0407 struct proc*    copyproc(struct proc*);
0408 void            exit(void);
0409 int             fork(void);
0410 int             growproc(int);
0411 int             kill(int);
0412 void            pinit(void);
0413 void            procdump(void);
0414 void            scheduler(void) __attribute__((noreturn));
0415 void            sched(void);
0416 void            sleep(void*, struct spinlock*);
0417 void            userinit(void);
0418 int             wait(void);
0419 void            wakeup(void*);
0420 void            yield(void);
0421 #ifdef CS333_P2
0422 int							getprocs(uint max, struct uproc*);
0423 #endif
0424 #ifdef CS333_P3
0425 int							setpriority(int pid, int priority);
0426 #endif
0427 
0428 // swtch.S
0429 void            swtch(struct context**, struct context*);
0430 
0431 // spinlock.c
0432 void            acquire(struct spinlock*);
0433 void            getcallerpcs(void*, uint*);
0434 int             holding(struct spinlock*);
0435 void            initlock(struct spinlock*, char*);
0436 void            release(struct spinlock*);
0437 void            pushcli(void);
0438 void            popcli(void);
0439 
0440 // string.c
0441 int             memcmp(const void*, const void*, uint);
0442 void*           memmove(void*, const void*, uint);
0443 void*           memset(void*, int, uint);
0444 char*           safestrcpy(char*, const char*, int);
0445 int             strlen(const char*);
0446 int             strncmp(const char*, const char*, uint);
0447 char*           strncpy(char*, const char*, int);
0448 
0449 
0450 // syscall.c
0451 int             argint(int, int*);
0452 int             argptr(int, char**, int);
0453 int             argstr(int, char**);
0454 int             fetchint(uint, int*);
0455 int             fetchstr(uint, char**);
0456 void            syscall(void);
0457 
0458 // timer.c
0459 void            timerinit(void);
0460 
0461 // trap.c
0462 void            idtinit(void);
0463 extern uint     ticks;
0464 void            tvinit(void);
0465 extern struct spinlock tickslock;
0466 
0467 // uart.c
0468 void            uartinit(void);
0469 void            uartintr(void);
0470 void            uartputc(int);
0471 
0472 // vm.c
0473 void            seginit(void);
0474 void            kvmalloc(void);
0475 void            vmenable(void);
0476 pde_t*          setupkvm(void);
0477 char*           uva2ka(pde_t*, char*);
0478 int             allocuvm(pde_t*, uint, uint);
0479 int             deallocuvm(pde_t*, uint, uint);
0480 void            freevm(pde_t*);
0481 void            inituvm(pde_t*, char*, uint);
0482 int             loaduvm(pde_t*, char*, struct inode*, uint, uint);
0483 pde_t*          copyuvm(pde_t*, uint);
0484 void            switchuvm(struct proc*);
0485 void            switchkvm(void);
0486 int             copyout(pde_t*, uint, void*, uint);
0487 void            clearpteu(pde_t *pgdir, char *uva);
0488 
0489 // number of elements in fixed-size array
0490 #define NELEM(x) (sizeof(x)/sizeof((x)[0]))
0491 
0492 
0493 
0494 
0495 
0496 
0497 
0498 
0499 
