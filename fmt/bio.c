4300 // Buffer cache.
4301 //
4302 // The buffer cache is a linked list of buf structures holding
4303 // cached copies of disk block contents.  Caching disk blocks
4304 // in memory reduces the number of disk reads and also provides
4305 // a synchronization point for disk blocks used by multiple processes.
4306 //
4307 // Interface:
4308 // * To get a buffer for a particular disk block, call bread.
4309 // * After changing buffer data, call bwrite to write it to disk.
4310 // * When done with the buffer, call brelse.
4311 // * Do not use the buffer after calling brelse.
4312 // * Only one process at a time can use a buffer,
4313 //     so do not keep them longer than necessary.
4314 //
4315 // The implementation uses three state flags internally:
4316 // * B_BUSY: the block has been returned from bread
4317 //     and has not been passed back to brelse.
4318 // * B_VALID: the buffer data has been read from the disk.
4319 // * B_DIRTY: the buffer data has been modified
4320 //     and needs to be written to disk.
4321 
4322 #include "types.h"
4323 #include "defs.h"
4324 #include "param.h"
4325 #include "spinlock.h"
4326 #include "fs.h"
4327 #include "buf.h"
4328 
4329 struct {
4330   struct spinlock lock;
4331   struct buf buf[NBUF];
4332 
4333   // Linked list of all buffers, through prev/next.
4334   // head.next is most recently used.
4335   struct buf head;
4336 } bcache;
4337 
4338 void
4339 binit(void)
4340 {
4341   struct buf *b;
4342 
4343   initlock(&bcache.lock, "bcache");
4344 
4345   // Create linked list of buffers
4346   bcache.head.prev = &bcache.head;
4347   bcache.head.next = &bcache.head;
4348   for(b = bcache.buf; b < bcache.buf+NBUF; b++){
4349     b->next = bcache.head.next;
4350     b->prev = &bcache.head;
4351     b->dev = -1;
4352     bcache.head.next->prev = b;
4353     bcache.head.next = b;
4354   }
4355 }
4356 
4357 // Look through buffer cache for block on device dev.
4358 // If not found, allocate a buffer.
4359 // In either case, return B_BUSY buffer.
4360 static struct buf*
4361 bget(uint dev, uint blockno)
4362 {
4363   struct buf *b;
4364 
4365   acquire(&bcache.lock);
4366 
4367  loop:
4368   // Is the block already cached?
4369   for(b = bcache.head.next; b != &bcache.head; b = b->next){
4370     if(b->dev == dev && b->blockno == blockno){
4371       if(!(b->flags & B_BUSY)){
4372         b->flags |= B_BUSY;
4373         release(&bcache.lock);
4374         return b;
4375       }
4376       sleep(b, &bcache.lock);
4377       goto loop;
4378     }
4379   }
4380 
4381   // Not cached; recycle some non-busy and clean buffer.
4382   // "clean" because B_DIRTY and !B_BUSY means log.c
4383   // hasn't yet committed the changes to the buffer.
4384   for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
4385     if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
4386       b->dev = dev;
4387       b->blockno = blockno;
4388       b->flags = B_BUSY;
4389       release(&bcache.lock);
4390       return b;
4391     }
4392   }
4393   panic("bget: no buffers");
4394 }
4395 
4396 
4397 
4398 
4399 
4400 // Return a B_BUSY buf with the contents of the indicated block.
4401 struct buf*
4402 bread(uint dev, uint blockno)
4403 {
4404   struct buf *b;
4405 
4406   b = bget(dev, blockno);
4407   if(!(b->flags & B_VALID)) {
4408     iderw(b);
4409   }
4410   return b;
4411 }
4412 
4413 // Write b's contents to disk.  Must be B_BUSY.
4414 void
4415 bwrite(struct buf *b)
4416 {
4417   if((b->flags & B_BUSY) == 0)
4418     panic("bwrite");
4419   b->flags |= B_DIRTY;
4420   iderw(b);
4421 }
4422 
4423 // Release a B_BUSY buffer.
4424 // Move to the head of the MRU list.
4425 void
4426 brelse(struct buf *b)
4427 {
4428   if((b->flags & B_BUSY) == 0)
4429     panic("brelse");
4430 
4431   acquire(&bcache.lock);
4432 
4433   b->next->prev = b->prev;
4434   b->prev->next = b->next;
4435   b->next = bcache.head.next;
4436   b->prev = &bcache.head;
4437   bcache.head.next->prev = b;
4438   bcache.head.next = b;
4439 
4440   b->flags &= ~B_BUSY;
4441   wakeup(b);
4442 
4443   release(&bcache.lock);
4444 }
4445 // Blank page.
4446 
4447 
4448 
4449 
