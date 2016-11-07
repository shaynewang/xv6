3500 // System call numbers
3501 #define SYS_fork			1
3502 #define SYS_exit    	SYS_fork+1
3503 #define SYS_wait    	SYS_exit+1
3504 #define SYS_pipe    	SYS_wait+1
3505 #define SYS_read    	SYS_pipe+1
3506 #define SYS_kill    	SYS_read+1
3507 #define SYS_exec    	SYS_kill+1
3508 #define SYS_fstat   	SYS_exec+1
3509 #define SYS_chdir   	SYS_fstat+1
3510 #define SYS_dup     	SYS_chdir+1
3511 #define SYS_getpid  	SYS_dup+1
3512 #define SYS_sbrk    	SYS_getpid+1
3513 #define SYS_sleep   	SYS_sbrk+1
3514 #define SYS_uptime  	SYS_sleep+1
3515 #define SYS_open    	SYS_uptime+1
3516 #define SYS_write   	SYS_open+1
3517 #define SYS_mknod   	SYS_write+1
3518 #define SYS_unlink  	SYS_mknod+1
3519 #define SYS_link    	SYS_unlink+1
3520 #define SYS_mkdir   	SYS_link+1
3521 #define SYS_close   	SYS_mkdir+1
3522 #define SYS_halt    	SYS_close+1
3523 // student system calls begin here. Follow the existing pattern.
3524 #define SYS_date			SYS_halt+1
3525 #define SYS_getuid		SYS_date+1
3526 #define SYS_getgid		SYS_getuid+1
3527 #define SYS_getppid		SYS_getgid+1
3528 #define SYS_setuid		SYS_getppid+1
3529 #define SYS_setgid		SYS_setuid+1
3530 #define SYS_getprocs  SYS_setgid+1
3531 #define SYS_setpriority  SYS_getprocs+1
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
