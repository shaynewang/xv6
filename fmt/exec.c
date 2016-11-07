6350 #include "types.h"
6351 #include "param.h"
6352 #include "memlayout.h"
6353 #include "mmu.h"
6354 #include "proc.h"
6355 #include "defs.h"
6356 #include "x86.h"
6357 #include "elf.h"
6358 
6359 int
6360 exec(char *path, char **argv)
6361 {
6362   char *s, *last;
6363   int i, off;
6364   uint argc, sz, sp, ustack[3+MAXARG+1];
6365   struct elfhdr elf;
6366   struct inode *ip;
6367   struct proghdr ph;
6368   pde_t *pgdir, *oldpgdir;
6369 
6370   begin_op();
6371   if((ip = namei(path)) == 0){
6372     end_op();
6373     return -1;
6374   }
6375   ilock(ip);
6376   pgdir = 0;
6377 
6378   // Check ELF header
6379   if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
6380     goto bad;
6381   if(elf.magic != ELF_MAGIC)
6382     goto bad;
6383 
6384   if((pgdir = setupkvm()) == 0)
6385     goto bad;
6386 
6387   // Load program into memory.
6388   sz = 0;
6389   for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
6390     if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
6391       goto bad;
6392     if(ph.type != ELF_PROG_LOAD)
6393       continue;
6394     if(ph.memsz < ph.filesz)
6395       goto bad;
6396     if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
6397       goto bad;
6398     if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
6399       goto bad;
6400   }
6401   iunlockput(ip);
6402   end_op();
6403   ip = 0;
6404 
6405   // Allocate two pages at the next page boundary.
6406   // Make the first inaccessible.  Use the second as the user stack.
6407   sz = PGROUNDUP(sz);
6408   if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
6409     goto bad;
6410   clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
6411   sp = sz;
6412 
6413   // Push argument strings, prepare rest of stack in ustack.
6414   for(argc = 0; argv[argc]; argc++) {
6415     if(argc >= MAXARG)
6416       goto bad;
6417     sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
6418     if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
6419       goto bad;
6420     ustack[3+argc] = sp;
6421   }
6422   ustack[3+argc] = 0;
6423 
6424   ustack[0] = 0xffffffff;  // fake return PC
6425   ustack[1] = argc;
6426   ustack[2] = sp - (argc+1)*4;  // argv pointer
6427 
6428   sp -= (3+argc+1) * 4;
6429   if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
6430     goto bad;
6431 
6432   // Save program name for debugging.
6433   for(last=s=path; *s; s++)
6434     if(*s == '/')
6435       last = s+1;
6436   safestrcpy(proc->name, last, sizeof(proc->name));
6437 
6438   // Commit to the user image.
6439   oldpgdir = proc->pgdir;
6440   proc->pgdir = pgdir;
6441   proc->sz = sz;
6442   proc->tf->eip = elf.entry;  // main
6443   proc->tf->esp = sp;
6444   switchuvm(proc);
6445   freevm(oldpgdir);
6446   return 0;
6447 
6448 
6449 
6450  bad:
6451   if(pgdir)
6452     freevm(pgdir);
6453   if(ip){
6454     iunlockput(ip);
6455     end_op();
6456   }
6457   return -1;
6458 }
6459 
6460 
6461 
6462 
6463 
6464 
6465 
6466 
6467 
6468 
6469 
6470 
6471 
6472 
6473 
6474 
6475 
6476 
6477 
6478 
6479 
6480 
6481 
6482 
6483 
6484 
6485 
6486 
6487 
6488 
6489 
6490 
6491 
6492 
6493 
6494 
6495 
6496 
6497 
6498 
6499 
