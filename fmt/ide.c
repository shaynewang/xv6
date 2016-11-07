4400 // Simple PIO-based (non-DMA) IDE driver code.
4401 
4402 #include "types.h"
4403 #include "defs.h"
4404 #include "param.h"
4405 #include "memlayout.h"
4406 #include "mmu.h"
4407 #include "proc.h"
4408 #include "x86.h"
4409 #include "traps.h"
4410 #include "spinlock.h"
4411 #include "fs.h"
4412 #include "buf.h"
4413 
4414 #define SECTOR_SIZE   512
4415 #define IDE_BSY       0x80
4416 #define IDE_DRDY      0x40
4417 #define IDE_DF        0x20
4418 #define IDE_ERR       0x01
4419 
4420 #define IDE_CMD_READ  0x20
4421 #define IDE_CMD_WRITE 0x30
4422 
4423 // idequeue points to the buf now being read/written to the disk.
4424 // idequeue->qnext points to the next buf to be processed.
4425 // You must hold idelock while manipulating queue.
4426 
4427 static struct spinlock idelock;
4428 static struct buf *idequeue;
4429 
4430 static int havedisk1;
4431 static void idestart(struct buf*);
4432 
4433 // Wait for IDE disk to become ready.
4434 static int
4435 idewait(int checkerr)
4436 {
4437   int r;
4438 
4439   while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
4440     ;
4441   if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
4442     return -1;
4443   return 0;
4444 }
4445 
4446 
4447 
4448 
4449 
4450 void
4451 ideinit(void)
4452 {
4453   int i;
4454 
4455   initlock(&idelock, "ide");
4456   picenable(IRQ_IDE);
4457   ioapicenable(IRQ_IDE, ncpu - 1);
4458   idewait(0);
4459 
4460   // Check if disk 1 is present
4461   outb(0x1f6, 0xe0 | (1<<4));
4462   for(i=0; i<1000; i++){
4463     if(inb(0x1f7) != 0){
4464       havedisk1 = 1;
4465       break;
4466     }
4467   }
4468 
4469   // Switch back to disk 0.
4470   outb(0x1f6, 0xe0 | (0<<4));
4471 }
4472 
4473 // Start the request for b.  Caller must hold idelock.
4474 static void
4475 idestart(struct buf *b)
4476 {
4477   if(b == 0)
4478     panic("idestart");
4479   if(b->blockno >= FSSIZE)
4480     panic("incorrect blockno");
4481   int sector_per_block =  BSIZE/SECTOR_SIZE;
4482   int sector = b->blockno * sector_per_block;
4483 
4484   if (sector_per_block > 7) panic("idestart");
4485 
4486   idewait(0);
4487   outb(0x3f6, 0);  // generate interrupt
4488   outb(0x1f2, sector_per_block);  // number of sectors
4489   outb(0x1f3, sector & 0xff);
4490   outb(0x1f4, (sector >> 8) & 0xff);
4491   outb(0x1f5, (sector >> 16) & 0xff);
4492   outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
4493   if(b->flags & B_DIRTY){
4494     outb(0x1f7, IDE_CMD_WRITE);
4495     outsl(0x1f0, b->data, BSIZE/4);
4496   } else {
4497     outb(0x1f7, IDE_CMD_READ);
4498   }
4499 }
4500 // Interrupt handler.
4501 void
4502 ideintr(void)
4503 {
4504   struct buf *b;
4505 
4506   // First queued buffer is the active request.
4507   acquire(&idelock);
4508   if((b = idequeue) == 0){
4509     release(&idelock);
4510     // cprintf("spurious IDE interrupt\n");
4511     return;
4512   }
4513   idequeue = b->qnext;
4514 
4515   // Read data if needed.
4516   if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
4517     insl(0x1f0, b->data, BSIZE/4);
4518 
4519   // Wake process waiting for this buf.
4520   b->flags |= B_VALID;
4521   b->flags &= ~B_DIRTY;
4522   wakeup(b);
4523 
4524   // Start disk on next buf in queue.
4525   if(idequeue != 0)
4526     idestart(idequeue);
4527 
4528   release(&idelock);
4529 }
4530 
4531 // Sync buf with disk.
4532 // If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
4533 // Else if B_VALID is not set, read buf from disk, set B_VALID.
4534 void
4535 iderw(struct buf *b)
4536 {
4537   struct buf **pp;
4538 
4539   if(!(b->flags & B_BUSY))
4540     panic("iderw: buf not busy");
4541   if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
4542     panic("iderw: nothing to do");
4543   if(b->dev != 0 && !havedisk1)
4544     panic("iderw: ide disk 1 not present");
4545 
4546   acquire(&idelock);  //DOC:acquire-lock
4547 
4548 
4549 
4550   // Append b to idequeue.
4551   b->qnext = 0;
4552   for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
4553     ;
4554   *pp = b;
4555 
4556   // Start disk if necessary.
4557   if(idequeue == b)
4558     idestart(b);
4559 
4560   // Wait for request to finish.
4561   while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
4562     sleep(b, &idelock);
4563   }
4564 
4565   release(&idelock);
4566 }
4567 
4568 
4569 
4570 
4571 
4572 
4573 
4574 
4575 
4576 
4577 
4578 
4579 
4580 
4581 
4582 
4583 
4584 
4585 
4586 
4587 
4588 
4589 
4590 
4591 
4592 
4593 
4594 
4595 
4596 
4597 
4598 
4599 
