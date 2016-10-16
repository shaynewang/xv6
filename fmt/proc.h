2050 // Segments in proc->gdt.
2051 #define NSEGS     7
2052 
2053 // Default UID and GID for init
2054 #define INITUID     0
2055 #define INITGID     0
2056 
2057 // Per-CPU state
2058 struct cpu {
2059   uchar id;                    // Local APIC ID; index into cpus[] below
2060   struct context *scheduler;   // swtch() here to enter scheduler
2061   struct taskstate ts;         // Used by x86 to find stack for interrupt
2062   struct segdesc gdt[NSEGS];   // x86 global descriptor table
2063   volatile uint started;       // Has the CPU started?
2064   int ncli;                    // Depth of pushcli nesting.
2065   int intena;                  // Were interrupts enabled before pushcli?
2066 
2067   // Cpu-local storage variables; see below
2068   struct cpu *cpu;
2069   struct proc *proc;           // The currently-running process.
2070 };
2071 
2072 extern struct cpu cpus[NCPU];
2073 extern int ncpu;
2074 
2075 // Per-CPU variables, holding pointers to the
2076 // current cpu and to the current process.
2077 // The asm suffix tells gcc to use "%gs:0" to refer to cpu
2078 // and "%gs:4" to refer to proc.  seginit sets up the
2079 // %gs segment register so that %gs refers to the memory
2080 // holding those two variables in the local cpu's struct cpu.
2081 // This is similar to how thread-local variables are implemented
2082 // in thread libraries such as Linux pthreads.
2083 extern struct cpu *cpu asm("%gs:0");       // &cpus[cpunum()]
2084 extern struct proc *proc asm("%gs:4");     // cpus[cpunum()].proc
2085 
2086 // Saved registers for kernel context switches.
2087 // Don't need to save all the segment registers (%cs, etc),
2088 // because they are constant across kernel contexts.
2089 // Don't need to save %eax, %ecx, %edx, because the
2090 // x86 convention is that the caller has saved them.
2091 // Contexts are stored at the bottom of the stack they
2092 // describe; the stack pointer is the address of the context.
2093 // The layout of the context matches the layout of the stack in swtch.S
2094 // at the "Switch stacks" comment. Switch doesn't save eip explicitly,
2095 // but it is on the stack and allocproc() manipulates it.
2096 struct context {
2097   uint edi;
2098   uint esi;
2099   uint ebx;
2100   uint ebp;
2101   uint eip;
2102 };
2103 
2104 enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
2105 
2106 // Per-process state
2107 struct proc {
2108   uint sz;                     // Size of process memory (bytes)
2109   pde_t* pgdir;                // Page table
2110   char *kstack;                // Bottom of kernel stack for this process
2111   enum procstate state;        // Process state
2112   uint pid;                    // Process ID
2113   struct proc *parent;         // Parent process
2114   struct trapframe *tf;        // Trap frame for current syscall
2115   struct context *context;     // swtch() here to run process
2116   void *chan;                  // If non-zero, sleeping on chan
2117   int killed;                  // If non-zero, have been killed
2118   struct file *ofile[NOFILE];  // Open files
2119   struct inode *cwd;           // Current directory
2120   char name[16];               // Process name (debugging)
2121   uint start_ticks;	           // Start ticks (debugging)
2122 #ifdef CS333_P2
2123 	uint cpu_ticks_total;				 // Total elapsed ticks in CPU
2124 	uint cpu_ticks_in;			  	 // Ticks when scheduled
2125   uint uid;                    // Process owner's user id
2126   uint gid;                    // Process owner's group id
2127 #endif
2128 };
2129 
2130 // Process memory is laid out contiguously, low addresses first:
2131 //   text
2132 //   original data and bss
2133 //   fixed-size stack
2134 //   expandable heap
2135 
2136 
2137 
2138 
2139 
2140 
2141 
2142 
2143 
2144 
2145 
2146 
2147 
2148 
2149 
