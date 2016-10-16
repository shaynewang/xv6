6050 #include "types.h"
6051 #include "param.h"
6052 #include "memlayout.h"
6053 #include "mmu.h"
6054 #include "proc.h"
6055 #include "defs.h"
6056 #include "x86.h"
6057 #include "elf.h"
6058 
6059 int
6060 exec(char *path, char **argv)
6061 {
6062   char *s, *last;
6063   int i, off;
6064   uint argc, sz, sp, ustack[3+MAXARG+1];
6065   struct elfhdr elf;
6066   struct inode *ip;
6067   struct proghdr ph;
6068   pde_t *pgdir, *oldpgdir;
6069 
6070   begin_op();
6071   if((ip = namei(path)) == 0){
6072     end_op();
6073     return -1;
6074   }
6075   ilock(ip);
6076   pgdir = 0;
6077 
6078   // Check ELF header
6079   if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
6080     goto bad;
6081   if(elf.magic != ELF_MAGIC)
6082     goto bad;
6083 
6084   if((pgdir = setupkvm()) == 0)
6085     goto bad;
6086 
6087   // Load program into memory.
6088   sz = 0;
6089   for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
6090     if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
6091       goto bad;
6092     if(ph.type != ELF_PROG_LOAD)
6093       continue;
6094     if(ph.memsz < ph.filesz)
6095       goto bad;
6096     if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
6097       goto bad;
6098     if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
6099       goto bad;
6100   }
6101   iunlockput(ip);
6102   end_op();
6103   ip = 0;
6104 
6105   // Allocate two pages at the next page boundary.
6106   // Make the first inaccessible.  Use the second as the user stack.
6107   sz = PGROUNDUP(sz);
6108   if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
6109     goto bad;
6110   clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
6111   sp = sz;
6112 
6113   // Push argument strings, prepare rest of stack in ustack.
6114   for(argc = 0; argv[argc]; argc++) {
6115     if(argc >= MAXARG)
6116       goto bad;
6117     sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
6118     if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
6119       goto bad;
6120     ustack[3+argc] = sp;
6121   }
6122   ustack[3+argc] = 0;
6123 
6124   ustack[0] = 0xffffffff;  // fake return PC
6125   ustack[1] = argc;
6126   ustack[2] = sp - (argc+1)*4;  // argv pointer
6127 
6128   sp -= (3+argc+1) * 4;
6129   if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
6130     goto bad;
6131 
6132   // Save program name for debugging.
6133   for(last=s=path; *s; s++)
6134     if(*s == '/')
6135       last = s+1;
6136   safestrcpy(proc->name, last, sizeof(proc->name));
6137 
6138   // Commit to the user image.
6139   oldpgdir = proc->pgdir;
6140   proc->pgdir = pgdir;
6141   proc->sz = sz;
6142   proc->tf->eip = elf.entry;  // main
6143   proc->tf->esp = sp;
6144   switchuvm(proc);
6145   freevm(oldpgdir);
6146   return 0;
6147 
6148 
6149 
6150  bad:
6151   if(pgdir)
6152     freevm(pgdir);
6153   if(ip){
6154     iunlockput(ip);
6155     end_op();
6156   }
6157   return -1;
6158 }
6159 
6160 
6161 
6162 
6163 
6164 
6165 
6166 
6167 
6168 
6169 
6170 
6171 
6172 
6173 
6174 
6175 
6176 
6177 
6178 
6179 
6180 
6181 
6182 
6183 
6184 
6185 
6186 
6187 
6188 
6189 
6190 
6191 
6192 
6193 
6194 
6195 
6196 
6197 
6198 
6199 
