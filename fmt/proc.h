2050 // Segments in proc->gdt.
2051 #define NSEGS     7
2052 
2053 // Default UID and GID for init
2054 #define INITUID     0
2055 #define INITGID     0
2056 
2057 // Default number of ready processes list
2058 #define NUM_READY_LISTS	7
2059 // Default starting priority number
2060 #define PRIORITY_HIGH	0
2061 // Default lowest priority number
2062 #define PRIORITY_LOW	PRIORITY_HIGH+NUM_READY_LISTS-1
2063 // Default promotion interval
2064 #define TICKS_TO_PROMOTE 200
2065 // Default process budget
2066 #define BUDGET 400
2067 
2068 // Per-CPU state
2069 struct cpu {
2070   uchar id;                    // Local APIC ID; index into cpus[] below
2071   struct context *scheduler;   // swtch() here to enter scheduler
2072   struct taskstate ts;         // Used by x86 to find stack for interrupt
2073   struct segdesc gdt[NSEGS];   // x86 global descriptor table
2074   volatile uint started;       // Has the CPU started?
2075   int ncli;                    // Depth of pushcli nesting.
2076   int intena;                  // Were interrupts enabled before pushcli?
2077 
2078   // Cpu-local storage variables; see below
2079   struct cpu *cpu;
2080   struct proc *proc;           // The currently-running process.
2081 };
2082 
2083 extern struct cpu cpus[NCPU];
2084 extern int ncpu;
2085 
2086 // Per-CPU variables, holding pointers to the
2087 // current cpu and to the current process.
2088 // The asm suffix tells gcc to use "%gs:0" to refer to cpu
2089 // and "%gs:4" to refer to proc.  seginit sets up the
2090 // %gs segment register so that %gs refers to the memory
2091 // holding those two variables in the local cpu's struct cpu.
2092 // This is similar to how thread-local variables are implemented
2093 // in thread libraries such as Linux pthreads.
2094 extern struct cpu *cpu asm("%gs:0");       // &cpus[cpunum()]
2095 extern struct proc *proc asm("%gs:4");     // cpus[cpunum()].proc
2096 
2097 
2098 
2099 
2100 // Saved registers for kernel context switches.
2101 // Don't need to save all the segment registers (%cs, etc),
2102 // because they are constant across kernel contexts.
2103 // Don't need to save %eax, %ecx, %edx, because the
2104 // x86 convention is that the caller has saved them.
2105 // Contexts are stored at the bottom of the stack they
2106 // describe; the stack pointer is the address of the context.
2107 // The layout of the context matches the layout of the stack in swtch.S
2108 // at the "Switch stacks" comment. Switch doesn't save eip explicitly,
2109 // but it is on the stack and allocproc() manipulates it.
2110 struct context {
2111   uint edi;
2112   uint esi;
2113   uint ebx;
2114   uint ebp;
2115   uint eip;
2116 };
2117 
2118 enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
2119 
2120 // Per-process state
2121 struct proc {
2122   uint sz;                     // Size of process memory (bytes)
2123   pde_t* pgdir;                // Page table
2124   char *kstack;                // Bottom of kernel stack for this process
2125   enum procstate state;        // Process state
2126   uint pid;                    // Process ID
2127   struct proc *parent;         // Parent process
2128   struct trapframe *tf;        // Trap frame for current syscall
2129   struct context *context;     // swtch() here to run process
2130   void *chan;                  // If non-zero, sleeping on chan
2131   int killed;                  // If non-zero, have been killed
2132   struct file *ofile[NOFILE];  // Open files
2133   struct inode *cwd;           // Current directory
2134   char name[16];               // Process name (debugging)
2135   uint start_ticks;	           // Start ticks (debugging)
2136 #ifdef CS333_P2
2137 	uint cpu_ticks_total;				 // Total elapsed ticks in CPU
2138 	uint cpu_ticks_in;			  	 // Ticks when scheduled
2139   uint uid;                    // Process owner's user id
2140   uint gid;                    // Process owner's group id
2141 #endif
2142 
2143 #ifdef CS333_P3
2144 	int priority;						 // Process priority 0 being the highest
2145 	int budget;							 // A process's budget time
2146 	struct proc *next;			 // Next process in the process list
2147 #endif
2148 };
2149 
2150 // Process memory is laid out contiguously, low addresses first:
2151 //   text
2152 //   original data and bss
2153 //   fixed-size stack
2154 //   expandable heap
2155 
2156 
2157 
2158 
2159 
2160 
2161 
2162 
2163 
2164 
2165 
2166 
2167 
2168 
2169 
2170 
2171 
2172 
2173 
2174 
2175 
2176 
2177 
2178 
2179 
2180 
2181 
2182 
2183 
2184 
2185 
2186 
2187 
2188 
2189 
2190 
2191 
2192 
2193 
2194 
2195 
2196 
2197 
2198 
2199 
