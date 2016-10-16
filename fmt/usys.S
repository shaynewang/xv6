7950 #include "syscall.h"
7951 #include "traps.h"
7952 
7953 #define SYSCALL(name) \
7954   .globl name; \
7955   name: \
7956     movl $SYS_ ## name, %eax; \
7957     int $T_SYSCALL; \
7958     ret
7959 
7960 SYSCALL(fork)
7961 SYSCALL(exit)
7962 SYSCALL(wait)
7963 SYSCALL(pipe)
7964 SYSCALL(read)
7965 SYSCALL(write)
7966 SYSCALL(close)
7967 SYSCALL(kill)
7968 SYSCALL(exec)
7969 SYSCALL(open)
7970 SYSCALL(mknod)
7971 SYSCALL(unlink)
7972 SYSCALL(fstat)
7973 SYSCALL(link)
7974 SYSCALL(mkdir)
7975 SYSCALL(chdir)
7976 SYSCALL(dup)
7977 SYSCALL(getpid)
7978 SYSCALL(sbrk)
7979 SYSCALL(sleep)
7980 SYSCALL(uptime)
7981 SYSCALL(halt)
7982 SYSCALL(date)
7983 SYSCALL(getuid)
7984 SYSCALL(getgid)
7985 SYSCALL(getppid)
7986 SYSCALL(setuid)
7987 SYSCALL(setgid)
7988 SYSCALL(getprocs)
7989 
7990 
7991 
7992 
7993 
7994 
7995 
7996 
7997 
7998 
7999 
