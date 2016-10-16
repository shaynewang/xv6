2800 # Context switch
2801 #
2802 #   void swtch(struct context **old, struct context *new);
2803 #
2804 # Save current register context in old
2805 # and then load register context from new.
2806 
2807 .globl swtch
2808 swtch:
2809   movl 4(%esp), %eax
2810   movl 8(%esp), %edx
2811 
2812   # Save old callee-save registers
2813   pushl %ebp
2814   pushl %ebx
2815   pushl %esi
2816   pushl %edi
2817 
2818   # Switch stacks
2819   movl %esp, (%eax)
2820   movl %edx, %esp
2821 
2822   # Load new callee-save registers
2823   popl %edi
2824   popl %esi
2825   popl %ebx
2826   popl %ebp
2827   ret
2828 
2829 
2830 
2831 
2832 
2833 
2834 
2835 
2836 
2837 
2838 
2839 
2840 
2841 
2842 
2843 
2844 
2845 
2846 
2847 
2848 
2849 
