8700 #include "asm.h"
8701 #include "memlayout.h"
8702 #include "mmu.h"
8703 
8704 # Start the first CPU: switch to 32-bit protected mode, jump into C.
8705 # The BIOS loads this code from the first sector of the hard disk into
8706 # memory at physical address 0x7c00 and starts executing in real mode
8707 # with %cs=0 %ip=7c00.
8708 
8709 .code16                       # Assemble for 16-bit mode
8710 .globl start
8711 start:
8712   cli                         # BIOS enabled interrupts; disable
8713 
8714   # Zero data segment registers DS, ES, and SS.
8715   xorw    %ax,%ax             # Set %ax to zero
8716   movw    %ax,%ds             # -> Data Segment
8717   movw    %ax,%es             # -> Extra Segment
8718   movw    %ax,%ss             # -> Stack Segment
8719 
8720   # Physical address line A20 is tied to zero so that the first PCs
8721   # with 2 MB would run software that assumed 1 MB.  Undo that.
8722 seta20.1:
8723   inb     $0x64,%al               # Wait for not busy
8724   testb   $0x2,%al
8725   jnz     seta20.1
8726 
8727   movb    $0xd1,%al               # 0xd1 -> port 0x64
8728   outb    %al,$0x64
8729 
8730 seta20.2:
8731   inb     $0x64,%al               # Wait for not busy
8732   testb   $0x2,%al
8733   jnz     seta20.2
8734 
8735   movb    $0xdf,%al               # 0xdf -> port 0x60
8736   outb    %al,$0x60
8737 
8738   # Switch from real to protected mode.  Use a bootstrap GDT that makes
8739   # virtual addresses map directly to physical addresses so that the
8740   # effective memory map doesn't change during the transition.
8741   lgdt    gdtdesc
8742   movl    %cr0, %eax
8743   orl     $CR0_PE, %eax
8744   movl    %eax, %cr0
8745 
8746   # Complete transition to 32-bit protected mode by using long jmp
8747   # to reload %cs and %eip.  The segment descriptors are set up with no
8748   # translation, so that the mapping is still the identity mapping.
8749   ljmp    $(SEG_KCODE<<3), $start32
8750 .code32  # Tell assembler to generate 32-bit code now.
8751 start32:
8752   # Set up the protected-mode data segment registers
8753   movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
8754   movw    %ax, %ds                # -> DS: Data Segment
8755   movw    %ax, %es                # -> ES: Extra Segment
8756   movw    %ax, %ss                # -> SS: Stack Segment
8757   movw    $0, %ax                 # Zero segments not ready for use
8758   movw    %ax, %fs                # -> FS
8759   movw    %ax, %gs                # -> GS
8760 
8761   # Set up the stack pointer and call into C.
8762   movl    $start, %esp
8763   call    bootmain
8764 
8765   # If bootmain returns (it shouldn't), trigger a Bochs
8766   # breakpoint if running under Bochs, then loop.
8767   movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
8768   movw    %ax, %dx
8769   outw    %ax, %dx
8770   movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
8771   outw    %ax, %dx
8772 spin:
8773   jmp     spin
8774 
8775 # Bootstrap GDT
8776 .p2align 2                                # force 4 byte alignment
8777 gdt:
8778   SEG_NULLASM                             # null seg
8779   SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
8780   SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg
8781 
8782 gdtdesc:
8783   .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
8784   .long   gdt                             # address gdt
8785 
8786 
8787 
8788 
8789 
8790 
8791 
8792 
8793 
8794 
8795 
8796 
8797 
8798 
8799 
