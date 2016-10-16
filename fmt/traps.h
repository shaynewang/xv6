2950 // x86 trap and interrupt constants.
2951 
2952 // Processor-defined:
2953 #define T_DIVIDE         0      // divide error
2954 #define T_DEBUG          1      // debug exception
2955 #define T_NMI            2      // non-maskable interrupt
2956 #define T_BRKPT          3      // breakpoint
2957 #define T_OFLOW          4      // overflow
2958 #define T_BOUND          5      // bounds check
2959 #define T_ILLOP          6      // illegal opcode
2960 #define T_DEVICE         7      // device not available
2961 #define T_DBLFLT         8      // double fault
2962 // #define T_COPROC      9      // reserved (not used since 486)
2963 #define T_TSS           10      // invalid task switch segment
2964 #define T_SEGNP         11      // segment not present
2965 #define T_STACK         12      // stack exception
2966 #define T_GPFLT         13      // general protection fault
2967 #define T_PGFLT         14      // page fault
2968 // #define T_RES        15      // reserved
2969 #define T_FPERR         16      // floating point error
2970 #define T_ALIGN         17      // aligment check
2971 #define T_MCHK          18      // machine check
2972 #define T_SIMDERR       19      // SIMD floating point error
2973 
2974 // These are arbitrarily chosen, but with care not to overlap
2975 // processor defined exceptions or interrupt vectors.
2976 #define T_SYSCALL       64      // system call
2977 #define T_DEFAULT      500      // catchall
2978 
2979 #define T_IRQ0          32      // IRQ 0 corresponds to int T_IRQ
2980 
2981 #define IRQ_TIMER        0
2982 #define IRQ_KBD          1
2983 #define IRQ_COM1         4
2984 #define IRQ_IDE         14
2985 #define IRQ_ERROR       19
2986 #define IRQ_SPURIOUS    31
2987 
2988 
2989 
2990 
2991 
2992 
2993 
2994 
2995 
2996 
2997 
2998 
2999 
