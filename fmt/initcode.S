8200 # Initial process execs /init.
8201 
8202 #include "syscall.h"
8203 #include "traps.h"
8204 
8205 
8206 # exec(init, argv)
8207 .globl start
8208 start:
8209   pushl $argv
8210   pushl $init
8211   pushl $0  // where caller pc would be
8212   movl $SYS_exec, %eax
8213   int $T_SYSCALL
8214 
8215 # for(;;) exit();
8216 exit:
8217   movl $SYS_exit, %eax
8218   int $T_SYSCALL
8219   jmp exit
8220 
8221 # char init[] = "/init\0";
8222 init:
8223   .string "/init\0"
8224 
8225 # char *argv[] = { init, 0 };
8226 .p2align 2
8227 argv:
8228   .long init
8229   .long 0
8230 
8231 
8232 
8233 
8234 
8235 
8236 
8237 
8238 
8239 
8240 
8241 
8242 
8243 
8244 
8245 
8246 
8247 
8248 
8249 
