2850 // Physical memory allocator, intended to allocate
2851 // memory for user processes, kernel stacks, page table pages,
2852 // and pipe buffers. Allocates 4096-byte pages.
2853 
2854 #include "types.h"
2855 #include "defs.h"
2856 #include "param.h"
2857 #include "memlayout.h"
2858 #include "mmu.h"
2859 #include "spinlock.h"
2860 
2861 void freerange(void *vstart, void *vend);
2862 extern char end[]; // first address after kernel loaded from ELF file
2863 
2864 struct run {
2865   struct run *next;
2866 };
2867 
2868 struct {
2869   struct spinlock lock;
2870   int use_lock;
2871   struct run *freelist;
2872 } kmem;
2873 
2874 // Initialization happens in two phases.
2875 // 1. main() calls kinit1() while still using entrypgdir to place just
2876 // the pages mapped by entrypgdir on free list.
2877 // 2. main() calls kinit2() with the rest of the physical pages
2878 // after installing a full page table that maps them on all cores.
2879 void
2880 kinit1(void *vstart, void *vend)
2881 {
2882   initlock(&kmem.lock, "kmem");
2883   kmem.use_lock = 0;
2884   freerange(vstart, vend);
2885 }
2886 
2887 void
2888 kinit2(void *vstart, void *vend)
2889 {
2890   freerange(vstart, vend);
2891   kmem.use_lock = 1;
2892 }
2893 
2894 
2895 
2896 
2897 
2898 
2899 
2900 void
2901 freerange(void *vstart, void *vend)
2902 {
2903   char *p;
2904   p = (char*)PGROUNDUP((uint)vstart);
2905   for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
2906     kfree(p);
2907 }
2908 
2909 // Free the page of physical memory pointed at by v,
2910 // which normally should have been returned by a
2911 // call to kalloc().  (The exception is when
2912 // initializing the allocator; see kinit above.)
2913 void
2914 kfree(char *v)
2915 {
2916   struct run *r;
2917 
2918   if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
2919     panic("kfree");
2920 
2921   // Fill with junk to catch dangling refs.
2922   memset(v, 1, PGSIZE);
2923 
2924   if(kmem.use_lock)
2925     acquire(&kmem.lock);
2926   r = (struct run*)v;
2927   r->next = kmem.freelist;
2928   kmem.freelist = r;
2929   if(kmem.use_lock)
2930     release(&kmem.lock);
2931 }
2932 
2933 // Allocate one 4096-byte page of physical memory.
2934 // Returns a pointer that the kernel can use.
2935 // Returns 0 if the memory cannot be allocated.
2936 char*
2937 kalloc(void)
2938 {
2939   struct run *r;
2940 
2941   if(kmem.use_lock)
2942     acquire(&kmem.lock);
2943   r = kmem.freelist;
2944   if(r)
2945     kmem.freelist = r->next;
2946   if(kmem.use_lock)
2947     release(&kmem.lock);
2948   return (char*)r;
2949 }
