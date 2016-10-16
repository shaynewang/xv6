3300 #include "types.h"
3301 #include "defs.h"
3302 #include "param.h"
3303 #include "memlayout.h"
3304 #include "mmu.h"
3305 #include "proc.h"
3306 #include "x86.h"
3307 #include "syscall.h"
3308 
3309 // User code makes a system call with INT T_SYSCALL.
3310 // System call number in %eax.
3311 // Arguments on the stack, from the user call to the C
3312 // library system call function. The saved user %esp points
3313 // to a saved program counter, and then the first argument.
3314 
3315 // Fetch the int at addr from the current process.
3316 int
3317 fetchint(uint addr, int *ip)
3318 {
3319   if(addr >= proc->sz || addr+4 > proc->sz)
3320     return -1;
3321   *ip = *(int*)(addr);
3322   return 0;
3323 }
3324 
3325 // Fetch the nul-terminated string at addr from the current process.
3326 // Doesn't actually copy the string - just sets *pp to point at it.
3327 // Returns length of string, not including nul.
3328 int
3329 fetchstr(uint addr, char **pp)
3330 {
3331   char *s, *ep;
3332 
3333   if(addr >= proc->sz)
3334     return -1;
3335   *pp = (char*)addr;
3336   ep = (char*)proc->sz;
3337   for(s = *pp; s < ep; s++)
3338     if(*s == 0)
3339       return s - *pp;
3340   return -1;
3341 }
3342 
3343 // Fetch the nth 32-bit system call argument.
3344 int
3345 argint(int n, int *ip)
3346 {
3347   return fetchint(proc->tf->esp + 4 + 4*n, ip);
3348 }
3349 
3350 // Fetch the nth word-sized system call argument as a pointer
3351 // to a block of memory of size n bytes.  Check that the pointer
3352 // lies within the process address space.
3353 int
3354 argptr(int n, char **pp, int size)
3355 {
3356   int i;
3357 
3358   if(argint(n, &i) < 0)
3359     return -1;
3360   if((uint)i >= proc->sz || (uint)i+size > proc->sz)
3361     return -1;
3362   *pp = (char*)i;
3363   return 0;
3364 }
3365 
3366 // Fetch the nth word-sized system call argument as a string pointer.
3367 // Check that the pointer is valid and the string is nul-terminated.
3368 // (There is no shared writable memory, so the string can't change
3369 // between this check and being used by the kernel.)
3370 int
3371 argstr(int n, char **pp)
3372 {
3373   int addr;
3374   if(argint(n, &addr) < 0)
3375     return -1;
3376   return fetchstr(addr, pp);
3377 }
3378 
3379 extern int sys_chdir(void);
3380 extern int sys_close(void);
3381 extern int sys_dup(void);
3382 extern int sys_exec(void);
3383 extern int sys_exit(void);
3384 extern int sys_fork(void);
3385 extern int sys_fstat(void);
3386 extern int sys_getpid(void);
3387 extern int sys_kill(void);
3388 extern int sys_link(void);
3389 extern int sys_mkdir(void);
3390 extern int sys_mknod(void);
3391 extern int sys_open(void);
3392 extern int sys_pipe(void);
3393 extern int sys_read(void);
3394 extern int sys_sbrk(void);
3395 extern int sys_sleep(void);
3396 extern int sys_unlink(void);
3397 extern int sys_wait(void);
3398 extern int sys_write(void);
3399 extern int sys_uptime(void);
3400 extern int sys_halt(void);
3401 extern int sys_date(void);
3402 #ifdef CS333_P2
3403 extern int sys_getuid(void);
3404 extern int sys_getgid(void);
3405 extern int sys_getppid(void);
3406 extern int sys_setuid(void);
3407 extern int sys_setgid(void);
3408 extern int sys_getprocs(void);
3409 #endif
3410 
3411 static int (*syscalls[])(void) = {
3412 [SYS_fork]    sys_fork,
3413 [SYS_exit]    sys_exit,
3414 [SYS_wait]    sys_wait,
3415 [SYS_pipe]    sys_pipe,
3416 [SYS_read]    sys_read,
3417 [SYS_kill]    sys_kill,
3418 [SYS_exec]    sys_exec,
3419 [SYS_fstat]   sys_fstat,
3420 [SYS_chdir]   sys_chdir,
3421 [SYS_dup]     sys_dup,
3422 [SYS_getpid]  sys_getpid,
3423 [SYS_sbrk]    sys_sbrk,
3424 [SYS_sleep]   sys_sleep,
3425 [SYS_uptime]  sys_uptime,
3426 [SYS_open]    sys_open,
3427 [SYS_write]   sys_write,
3428 [SYS_mknod]   sys_mknod,
3429 [SYS_unlink]  sys_unlink,
3430 [SYS_link]    sys_link,
3431 [SYS_mkdir]   sys_mkdir,
3432 [SYS_close]   sys_close,
3433 [SYS_halt]    sys_halt,
3434 [SYS_date]    sys_date,
3435 #ifdef CS333_P2
3436 [SYS_getuid]  sys_getuid,
3437 [SYS_getgid]  sys_getgid,
3438 [SYS_getppid] sys_getppid,
3439 [SYS_setuid]  sys_setuid,
3440 [SYS_setgid]  sys_setgid,
3441 [SYS_getprocs]  sys_getprocs,
3442 #endif
3443 };
3444 
3445 
3446 
3447 
3448 
3449 
3450 // put data structure for printing out system call invocation information here
3451 #ifdef PRINT_SYSCALLS
3452 static const char * (print_syscalls[]) = {
3453 [SYS_fork] = "fork",
3454 [SYS_exit]   = "exit",
3455 [SYS_wait]     = "wait",
3456 [SYS_pipe]     = "pipe",
3457 [SYS_read]     = "read",
3458 [SYS_kill]     = "kill",
3459 [SYS_exec]     = "exec",
3460 [SYS_fstat]    = "fstat",
3461 [SYS_chdir]    = "chdir",
3462 [SYS_dup]      = "dup",
3463 [SYS_getpid]   = "getpid",
3464 [SYS_sbrk]     = "sbrk",
3465 [SYS_sleep]    = "sleep",
3466 [SYS_uptime]   = "uptime",
3467 [SYS_open]     = "open",
3468 [SYS_write]    = "write",
3469 [SYS_mknod]    = "mknod",
3470 [SYS_unlink]   = "unlink",
3471 [SYS_link]     = "link",
3472 [SYS_mkdir]    = "mkdir",
3473 [SYS_close]    = "close",
3474 [SYS_halt]     = "halt",
3475 [SYS_date]     = "date",
3476 #ifdef CS333_P2
3477 [SYS_getgid]   = "getuid",
3478 [SYS_getuid]   = "getgid",
3479 [SYS_getppid]  = "getppid",
3480 [SYS_setgid]   = "setuid",
3481 [SYS_setuid]   = "setgid",
3482 [SYS_getprocs]   = "getprocs",
3483 #endif
3484 };
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
3500 #endif
3501 
3502 void
3503 syscall(void)
3504 {
3505   int num;
3506 
3507   num = proc->tf->eax;
3508   if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
3509     proc->tf->eax = syscalls[num]();
3510 // some code goes here
3511 #ifdef PRINT_SYSCALLS
3512 	cprintf("%s -> %d\n", print_syscalls[num], proc->tf->eax);
3513 #endif
3514   } else {
3515     cprintf("%d %s: unknown sys call %d\n",
3516             proc->pid, proc->name, num);
3517     proc->tf->eax = -1;
3518   }
3519 }
3520 
3521 
3522 
3523 
3524 
3525 
3526 
3527 
3528 
3529 
3530 
3531 
3532 
3533 
3534 
3535 
3536 
3537 
3538 
3539 
3540 
3541 
3542 
3543 
3544 
3545 
3546 
3547 
3548 
3549 
