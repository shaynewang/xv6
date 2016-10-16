7900 # Initial process execs /init.
7901 
7902 #include "syscall.h"
7903 #include "traps.h"
7904 
7905 
7906 # exec(init, argv)
7907 .globl start
7908 start:
7909   pushl $argv
7910   pushl $init
7911   pushl $0  // where caller pc would be
7912   movl $SYS_exec, %eax
7913   int $T_SYSCALL
7914 
7915 # for(;;) exit();
7916 exit:
7917   movl $SYS_exit, %eax
7918   int $T_SYSCALL
7919   jmp exit
7920 
7921 # char init[] = "/init\0";
7922 init:
7923   .string "/init\0"
7924 
7925 # char *argv[] = { init, 0 };
7926 .p2align 2
7927 argv:
7928   .long init
7929   .long 0
7930 
7931 
7932 
7933 
7934 
7935 
7936 
7937 
7938 
7939 
7940 
7941 
7942 
7943 
7944 
7945 
7946 
7947 
7948 
7949 
