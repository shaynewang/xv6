8800 // Boot loader.
8801 //
8802 // Part of the boot block, along with bootasm.S, which calls bootmain().
8803 // bootasm.S has put the processor into protected 32-bit mode.
8804 // bootmain() loads an ELF kernel image from the disk starting at
8805 // sector 1 and then jumps to the kernel entry routine.
8806 
8807 #include "types.h"
8808 #include "elf.h"
8809 #include "x86.h"
8810 #include "memlayout.h"
8811 
8812 #define SECTSIZE  512
8813 
8814 void readseg(uchar*, uint, uint);
8815 
8816 void
8817 bootmain(void)
8818 {
8819   struct elfhdr *elf;
8820   struct proghdr *ph, *eph;
8821   void (*entry)(void);
8822   uchar* pa;
8823 
8824   elf = (struct elfhdr*)0x10000;  // scratch space
8825 
8826   // Read 1st page off disk
8827   readseg((uchar*)elf, 4096, 0);
8828 
8829   // Is this an ELF executable?
8830   if(elf->magic != ELF_MAGIC)
8831     return;  // let bootasm.S handle error
8832 
8833   // Load each program segment (ignores ph flags).
8834   ph = (struct proghdr*)((uchar*)elf + elf->phoff);
8835   eph = ph + elf->phnum;
8836   for(; ph < eph; ph++){
8837     pa = (uchar*)ph->paddr;
8838     readseg(pa, ph->filesz, ph->off);
8839     if(ph->memsz > ph->filesz)
8840       stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
8841   }
8842 
8843   // Call the entry point from the ELF header.
8844   // Does not return!
8845   entry = (void(*)(void))(elf->entry);
8846   entry();
8847 }
8848 
8849 
8850 void
8851 waitdisk(void)
8852 {
8853   // Wait for disk ready.
8854   while((inb(0x1F7) & 0xC0) != 0x40)
8855     ;
8856 }
8857 
8858 // Read a single sector at offset into dst.
8859 void
8860 readsect(void *dst, uint offset)
8861 {
8862   // Issue command.
8863   waitdisk();
8864   outb(0x1F2, 1);   // count = 1
8865   outb(0x1F3, offset);
8866   outb(0x1F4, offset >> 8);
8867   outb(0x1F5, offset >> 16);
8868   outb(0x1F6, (offset >> 24) | 0xE0);
8869   outb(0x1F7, 0x20);  // cmd 0x20 - read sectors
8870 
8871   // Read data.
8872   waitdisk();
8873   insl(0x1F0, dst, SECTSIZE/4);
8874 }
8875 
8876 // Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
8877 // Might copy more than asked.
8878 void
8879 readseg(uchar* pa, uint count, uint offset)
8880 {
8881   uchar* epa;
8882 
8883   epa = pa + count;
8884 
8885   // Round down to sector boundary.
8886   pa -= offset % SECTSIZE;
8887 
8888   // Translate from bytes to sectors; kernel starts at sector 1.
8889   offset = (offset / SECTSIZE) + 1;
8890 
8891   // If this is too slow, we could read lots of sectors at a time.
8892   // We'd write more to memory than asked, but it doesn't matter --
8893   // we load in increasing order.
8894   for(; pa < epa; pa += SECTSIZE, offset++)
8895     readsect(pa, offset);
8896 }
8897 
8898 
8899 
