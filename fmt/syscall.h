3250 // System call numbers
3251 #define SYS_fork			1
3252 #define SYS_exit    	SYS_fork+1
3253 #define SYS_wait    	SYS_exit+1
3254 #define SYS_pipe    	SYS_wait+1
3255 #define SYS_read    	SYS_pipe+1
3256 #define SYS_kill    	SYS_read+1
3257 #define SYS_exec    	SYS_kill+1
3258 #define SYS_fstat   	SYS_exec+1
3259 #define SYS_chdir   	SYS_fstat+1
3260 #define SYS_dup     	SYS_chdir+1
3261 #define SYS_getpid  	SYS_dup+1
3262 #define SYS_sbrk    	SYS_getpid+1
3263 #define SYS_sleep   	SYS_sbrk+1
3264 #define SYS_uptime  	SYS_sleep+1
3265 #define SYS_open    	SYS_uptime+1
3266 #define SYS_write   	SYS_open+1
3267 #define SYS_mknod   	SYS_write+1
3268 #define SYS_unlink  	SYS_mknod+1
3269 #define SYS_link    	SYS_unlink+1
3270 #define SYS_mkdir   	SYS_link+1
3271 #define SYS_close   	SYS_mkdir+1
3272 #define SYS_halt    	SYS_close+1
3273 // student system calls begin here. Follow the existing pattern.
3274 #define SYS_date			SYS_halt+1
3275 #define SYS_getuid		SYS_date+1
3276 #define SYS_getgid		SYS_getuid+1
3277 #define SYS_getppid		SYS_getgid+1
3278 #define SYS_setuid		SYS_getppid+1
3279 #define SYS_setgid		SYS_setuid+1
3280 #define SYS_getprocs  SYS_setgid+1
3281 
3282 
3283 
3284 
3285 
3286 
3287 
3288 
3289 
3290 
3291 
3292 
3293 
3294 
3295 
3296 
3297 
3298 
3299 
