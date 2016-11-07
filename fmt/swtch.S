3050 # Context switch
3051 #
3052 #   void swtch(struct context **old, struct context *new);
3053 #
3054 # Save current register context in old
3055 # and then load register context from new.
3056 
3057 .globl swtch
3058 swtch:
3059   movl 4(%esp), %eax
3060   movl 8(%esp), %edx
3061 
3062   # Save old callee-save registers
3063   pushl %ebp
3064   pushl %ebx
3065   pushl %esi
3066   pushl %edi
3067 
3068   # Switch stacks
3069   movl %esp, (%eax)
3070   movl %edx, %esp
3071 
3072   # Load new callee-save registers
3073   popl %edi
3074   popl %esi
3075   popl %ebx
3076   popl %ebp
3077   ret
3078 
3079 
3080 
3081 
3082 
3083 
3084 
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
