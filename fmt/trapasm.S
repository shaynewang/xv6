3050 #include "mmu.h"
3051 
3052   # vectors.S sends all traps here.
3053 .globl alltraps
3054 alltraps:
3055   # Build trap frame.
3056   pushl %ds
3057   pushl %es
3058   pushl %fs
3059   pushl %gs
3060   pushal
3061 
3062   # Set up data and per-cpu segments.
3063   movw $(SEG_KDATA<<3), %ax
3064   movw %ax, %ds
3065   movw %ax, %es
3066   movw $(SEG_KCPU<<3), %ax
3067   movw %ax, %fs
3068   movw %ax, %gs
3069 
3070   # Call trap(tf), where tf=%esp
3071   pushl %esp
3072   call trap
3073   addl $4, %esp
3074 
3075   # Return falls through to trapret...
3076 .globl trapret
3077 trapret:
3078   popal
3079   popl %gs
3080   popl %fs
3081   popl %es
3082   popl %ds
3083   addl $0x8, %esp  # trapno and errcode
3084   iret
3085 
3086 
3087 
3088 
3089 
3090 
3091 
3092 
3093 
3094 
3095 
3096 
3097 
3098 
3099 
