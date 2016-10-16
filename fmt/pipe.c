6200 #include "types.h"
6201 #include "defs.h"
6202 #include "param.h"
6203 #include "mmu.h"
6204 #include "proc.h"
6205 #include "fs.h"
6206 #include "file.h"
6207 #include "spinlock.h"
6208 
6209 #define PIPESIZE 512
6210 
6211 struct pipe {
6212   struct spinlock lock;
6213   char data[PIPESIZE];
6214   uint nread;     // number of bytes read
6215   uint nwrite;    // number of bytes written
6216   int readopen;   // read fd is still open
6217   int writeopen;  // write fd is still open
6218 };
6219 
6220 int
6221 pipealloc(struct file **f0, struct file **f1)
6222 {
6223   struct pipe *p;
6224 
6225   p = 0;
6226   *f0 = *f1 = 0;
6227   if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
6228     goto bad;
6229   if((p = (struct pipe*)kalloc()) == 0)
6230     goto bad;
6231   p->readopen = 1;
6232   p->writeopen = 1;
6233   p->nwrite = 0;
6234   p->nread = 0;
6235   initlock(&p->lock, "pipe");
6236   (*f0)->type = FD_PIPE;
6237   (*f0)->readable = 1;
6238   (*f0)->writable = 0;
6239   (*f0)->pipe = p;
6240   (*f1)->type = FD_PIPE;
6241   (*f1)->readable = 0;
6242   (*f1)->writable = 1;
6243   (*f1)->pipe = p;
6244   return 0;
6245 
6246 
6247 
6248 
6249 
6250  bad:
6251   if(p)
6252     kfree((char*)p);
6253   if(*f0)
6254     fileclose(*f0);
6255   if(*f1)
6256     fileclose(*f1);
6257   return -1;
6258 }
6259 
6260 void
6261 pipeclose(struct pipe *p, int writable)
6262 {
6263   acquire(&p->lock);
6264   if(writable){
6265     p->writeopen = 0;
6266     wakeup(&p->nread);
6267   } else {
6268     p->readopen = 0;
6269     wakeup(&p->nwrite);
6270   }
6271   if(p->readopen == 0 && p->writeopen == 0){
6272     release(&p->lock);
6273     kfree((char*)p);
6274   } else
6275     release(&p->lock);
6276 }
6277 
6278 int
6279 pipewrite(struct pipe *p, char *addr, int n)
6280 {
6281   int i;
6282 
6283   acquire(&p->lock);
6284   for(i = 0; i < n; i++){
6285     while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
6286       if(p->readopen == 0 || proc->killed){
6287         release(&p->lock);
6288         return -1;
6289       }
6290       wakeup(&p->nread);
6291       sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
6292     }
6293     p->data[p->nwrite++ % PIPESIZE] = addr[i];
6294   }
6295   wakeup(&p->nread);  //DOC: pipewrite-wakeup1
6296   release(&p->lock);
6297   return n;
6298 }
6299 
6300 int
6301 piperead(struct pipe *p, char *addr, int n)
6302 {
6303   int i;
6304 
6305   acquire(&p->lock);
6306   while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
6307     if(proc->killed){
6308       release(&p->lock);
6309       return -1;
6310     }
6311     sleep(&p->nread, &p->lock); //DOC: piperead-sleep
6312   }
6313   for(i = 0; i < n; i++){  //DOC: piperead-copy
6314     if(p->nread == p->nwrite)
6315       break;
6316     addr[i] = p->data[p->nread++ % PIPESIZE];
6317   }
6318   wakeup(&p->nwrite);  //DOC: piperead-wakeup
6319   release(&p->lock);
6320   return i;
6321 }
6322 
6323 
6324 
6325 
6326 
6327 
6328 
6329 
6330 
6331 
6332 
6333 
6334 
6335 
6336 
6337 
6338 
6339 
6340 
6341 
6342 
6343 
6344 
6345 
6346 
6347 
6348 
6349 
