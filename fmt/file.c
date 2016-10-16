5400 //
5401 // File descriptors
5402 //
5403 
5404 #include "types.h"
5405 #include "defs.h"
5406 #include "param.h"
5407 #include "fs.h"
5408 #include "file.h"
5409 #include "spinlock.h"
5410 
5411 struct devsw devsw[NDEV];
5412 struct {
5413   struct spinlock lock;
5414   struct file file[NFILE];
5415 } ftable;
5416 
5417 void
5418 fileinit(void)
5419 {
5420   initlock(&ftable.lock, "ftable");
5421 }
5422 
5423 // Allocate a file structure.
5424 struct file*
5425 filealloc(void)
5426 {
5427   struct file *f;
5428 
5429   acquire(&ftable.lock);
5430   for(f = ftable.file; f < ftable.file + NFILE; f++){
5431     if(f->ref == 0){
5432       f->ref = 1;
5433       release(&ftable.lock);
5434       return f;
5435     }
5436   }
5437   release(&ftable.lock);
5438   return 0;
5439 }
5440 
5441 
5442 
5443 
5444 
5445 
5446 
5447 
5448 
5449 
5450 // Increment ref count for file f.
5451 struct file*
5452 filedup(struct file *f)
5453 {
5454   acquire(&ftable.lock);
5455   if(f->ref < 1)
5456     panic("filedup");
5457   f->ref++;
5458   release(&ftable.lock);
5459   return f;
5460 }
5461 
5462 // Close file f.  (Decrement ref count, close when reaches 0.)
5463 void
5464 fileclose(struct file *f)
5465 {
5466   struct file ff;
5467 
5468   acquire(&ftable.lock);
5469   if(f->ref < 1)
5470     panic("fileclose");
5471   if(--f->ref > 0){
5472     release(&ftable.lock);
5473     return;
5474   }
5475   ff = *f;
5476   f->ref = 0;
5477   f->type = FD_NONE;
5478   release(&ftable.lock);
5479 
5480   if(ff.type == FD_PIPE)
5481     pipeclose(ff.pipe, ff.writable);
5482   else if(ff.type == FD_INODE){
5483     begin_op();
5484     iput(ff.ip);
5485     end_op();
5486   }
5487 }
5488 
5489 
5490 
5491 
5492 
5493 
5494 
5495 
5496 
5497 
5498 
5499 
5500 // Get metadata about file f.
5501 int
5502 filestat(struct file *f, struct stat *st)
5503 {
5504   if(f->type == FD_INODE){
5505     ilock(f->ip);
5506     stati(f->ip, st);
5507     iunlock(f->ip);
5508     return 0;
5509   }
5510   return -1;
5511 }
5512 
5513 // Read from file f.
5514 int
5515 fileread(struct file *f, char *addr, int n)
5516 {
5517   int r;
5518 
5519   if(f->readable == 0)
5520     return -1;
5521   if(f->type == FD_PIPE)
5522     return piperead(f->pipe, addr, n);
5523   if(f->type == FD_INODE){
5524     ilock(f->ip);
5525     if((r = readi(f->ip, addr, f->off, n)) > 0)
5526       f->off += r;
5527     iunlock(f->ip);
5528     return r;
5529   }
5530   panic("fileread");
5531 }
5532 
5533 // Write to file f.
5534 int
5535 filewrite(struct file *f, char *addr, int n)
5536 {
5537   int r;
5538 
5539   if(f->writable == 0)
5540     return -1;
5541   if(f->type == FD_PIPE)
5542     return pipewrite(f->pipe, addr, n);
5543   if(f->type == FD_INODE){
5544     // write a few blocks at a time to avoid exceeding
5545     // the maximum log transaction size, including
5546     // i-node, indirect block, allocation blocks,
5547     // and 2 blocks of slop for non-aligned writes.
5548     // this really belongs lower down, since writei()
5549     // might be writing a device like the console.
5550     int max = ((LOGSIZE-1-1-2) / 2) * 512;
5551     int i = 0;
5552     while(i < n){
5553       int n1 = n - i;
5554       if(n1 > max)
5555         n1 = max;
5556 
5557       begin_op();
5558       ilock(f->ip);
5559       if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
5560         f->off += r;
5561       iunlock(f->ip);
5562       end_op();
5563 
5564       if(r < 0)
5565         break;
5566       if(r != n1)
5567         panic("short filewrite");
5568       i += r;
5569     }
5570     return i == n ? n : -1;
5571   }
5572   panic("filewrite");
5573 }
5574 
5575 
5576 
5577 
5578 
5579 
5580 
5581 
5582 
5583 
5584 
5585 
5586 
5587 
5588 
5589 
5590 
5591 
5592 
5593 
5594 
5595 
5596 
5597 
5598 
5599 
