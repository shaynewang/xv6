8250 #include "syscall.h"
8251 #include "traps.h"
8252 
8253 #define SYSCALL(name) \
8254   .globl name; \
8255   name: \
8256     movl $SYS_ ## name, %eax; \
8257     int $T_SYSCALL; \
8258     ret
8259 
8260 SYSCALL(fork)
8261 SYSCALL(exit)
8262 SYSCALL(wait)
8263 SYSCALL(pipe)
8264 SYSCALL(read)
8265 SYSCALL(write)
8266 SYSCALL(close)
8267 SYSCALL(kill)
8268 SYSCALL(exec)
8269 SYSCALL(open)
8270 SYSCALL(mknod)
8271 SYSCALL(unlink)
8272 SYSCALL(fstat)
8273 SYSCALL(link)
8274 SYSCALL(mkdir)
8275 SYSCALL(chdir)
8276 SYSCALL(dup)
8277 SYSCALL(getpid)
8278 SYSCALL(sbrk)
8279 SYSCALL(sleep)
8280 SYSCALL(uptime)
8281 SYSCALL(halt)
8282 SYSCALL(date)
8283 SYSCALL(getuid)
8284 SYSCALL(getgid)
8285 SYSCALL(getppid)
8286 SYSCALL(setuid)
8287 SYSCALL(setgid)
8288 SYSCALL(getprocs)
8289 SYSCALL(setpriority)
8290 
8291 
8292 
8293 
8294 
8295 
8296 
8297 
8298 
8299 
