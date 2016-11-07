4600 // Buffer cache.
4601 //
4602 // The buffer cache is a linked list of buf structures holding
4603 // cached copies of disk block contents.  Caching disk blocks
4604 // in memory reduces the number of disk reads and also provides
4605 // a synchronization point for disk blocks used by multiple processes.
4606 //
4607 // Interface:
4608 // * To get a buffer for a particular disk block, call bread.
4609 // * After changing buffer data, call bwrite to write it to disk.
4610 // * When done with the buffer, call brelse.
4611 // * Do not use the buffer after calling brelse.
4612 // * Only one process at a time can use a buffer,
4613 //     so do not keep them longer than necessary.
4614 //
4615 // The implementation uses three state flags internally:
4616 // * B_BUSY: the block has been returned from bread
4617 //     and has not been passed back to brelse.
4618 // * B_VALID: the buffer data has been read from the disk.
4619 // * B_DIRTY: the buffer data has been modified
4620 //     and needs to be written to disk.
4621 
4622 #include "types.h"
4623 #include "defs.h"
4624 #include "param.h"
4625 #include "spinlock.h"
4626 #include "fs.h"
4627 #include "buf.h"
4628 
4629 struct {
4630   struct spinlock lock;
4631   struct buf buf[NBUF];
4632 
4633   // Linked list of all buffers, through prev/next.
4634   // head.next is most recently used.
4635   struct buf head;
4636 } bcache;
4637 
4638 void
4639 binit(void)
4640 {
4641   struct buf *b;
4642 
4643   initlock(&bcache.lock, "bcache");
4644 
4645   // Create linked list of buffers
4646   bcache.head.prev = &bcache.head;
4647   bcache.head.next = &bcache.head;
4648   for(b = bcache.buf; b < bcache.buf+NBUF; b++){
4649     b->next = bcache.head.next;
4650     b->prev = &bcache.head;
4651     b->dev = -1;
4652     bcache.head.next->prev = b;
4653     bcache.head.next = b;
4654   }
4655 }
4656 
4657 // Look through buffer cache for block on device dev.
4658 // If not found, allocate a buffer.
4659 // In either case, return B_BUSY buffer.
4660 static struct buf*
4661 bget(uint dev, uint blockno)
4662 {
4663   struct buf *b;
4664 
4665   acquire(&bcache.lock);
4666 
4667  loop:
4668   // Is the block already cached?
4669   for(b = bcache.head.next; b != &bcache.head; b = b->next){
4670     if(b->dev == dev && b->blockno == blockno){
4671       if(!(b->flags & B_BUSY)){
4672         b->flags |= B_BUSY;
4673         release(&bcache.lock);
4674         return b;
4675       }
4676       sleep(b, &bcache.lock);
4677       goto loop;
4678     }
4679   }
4680 
4681   // Not cached; recycle some non-busy and clean buffer.
4682   // "clean" because B_DIRTY and !B_BUSY means log.c
4683   // hasn't yet committed the changes to the buffer.
4684   for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
4685     if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
4686       b->dev = dev;
4687       b->blockno = blockno;
4688       b->flags = B_BUSY;
4689       release(&bcache.lock);
4690       return b;
4691     }
4692   }
4693   panic("bget: no buffers");
4694 }
4695 
4696 
4697 
4698 
4699 
4700 // Return a B_BUSY buf with the contents of the indicated block.
4701 struct buf*
4702 bread(uint dev, uint blockno)
4703 {
4704   struct buf *b;
4705 
4706   b = bget(dev, blockno);
4707   if(!(b->flags & B_VALID)) {
4708     iderw(b);
4709   }
4710   return b;
4711 }
4712 
4713 // Write b's contents to disk.  Must be B_BUSY.
4714 void
4715 bwrite(struct buf *b)
4716 {
4717   if((b->flags & B_BUSY) == 0)
4718     panic("bwrite");
4719   b->flags |= B_DIRTY;
4720   iderw(b);
4721 }
4722 
4723 // Release a B_BUSY buffer.
4724 // Move to the head of the MRU list.
4725 void
4726 brelse(struct buf *b)
4727 {
4728   if((b->flags & B_BUSY) == 0)
4729     panic("brelse");
4730 
4731   acquire(&bcache.lock);
4732 
4733   b->next->prev = b->prev;
4734   b->prev->next = b->next;
4735   b->next = bcache.head.next;
4736   b->prev = &bcache.head;
4737   bcache.head.next->prev = b;
4738   bcache.head.next = b;
4739 
4740   b->flags &= ~B_BUSY;
4741   wakeup(b);
4742 
4743   release(&bcache.lock);
4744 }
4745 // Blank page.
4746 
4747 
4748 
4749 
