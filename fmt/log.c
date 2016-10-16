4450 #include "types.h"
4451 #include "defs.h"
4452 #include "param.h"
4453 #include "spinlock.h"
4454 #include "fs.h"
4455 #include "buf.h"
4456 
4457 // Simple logging that allows concurrent FS system calls.
4458 //
4459 // A log transaction contains the updates of multiple FS system
4460 // calls. The logging system only commits when there are
4461 // no FS system calls active. Thus there is never
4462 // any reasoning required about whether a commit might
4463 // write an uncommitted system call's updates to disk.
4464 //
4465 // A system call should call begin_op()/end_op() to mark
4466 // its start and end. Usually begin_op() just increments
4467 // the count of in-progress FS system calls and returns.
4468 // But if it thinks the log is close to running out, it
4469 // sleeps until the last outstanding end_op() commits.
4470 //
4471 // The log is a physical re-do log containing disk blocks.
4472 // The on-disk log format:
4473 //   header block, containing block #s for block A, B, C, ...
4474 //   block A
4475 //   block B
4476 //   block C
4477 //   ...
4478 // Log appends are synchronous.
4479 
4480 // Contents of the header block, used for both the on-disk header block
4481 // and to keep track in memory of logged block# before commit.
4482 struct logheader {
4483   int n;
4484   int block[LOGSIZE];
4485 };
4486 
4487 struct log {
4488   struct spinlock lock;
4489   int start;
4490   int size;
4491   int outstanding; // how many FS sys calls are executing.
4492   int committing;  // in commit(), please wait.
4493   int dev;
4494   struct logheader lh;
4495 };
4496 
4497 
4498 
4499 
4500 struct log log;
4501 
4502 static void recover_from_log(void);
4503 static void commit();
4504 
4505 void
4506 initlog(int dev)
4507 {
4508   if (sizeof(struct logheader) >= BSIZE)
4509     panic("initlog: too big logheader");
4510 
4511   struct superblock sb;
4512   initlock(&log.lock, "log");
4513   readsb(dev, &sb);
4514   log.start = sb.logstart;
4515   log.size = sb.nlog;
4516   log.dev = dev;
4517   recover_from_log();
4518 }
4519 
4520 // Copy committed blocks from log to their home location
4521 static void
4522 install_trans(void)
4523 {
4524   int tail;
4525 
4526   for (tail = 0; tail < log.lh.n; tail++) {
4527     struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
4528     struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
4529     memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
4530     bwrite(dbuf);  // write dst to disk
4531     brelse(lbuf);
4532     brelse(dbuf);
4533   }
4534 }
4535 
4536 // Read the log header from disk into the in-memory log header
4537 static void
4538 read_head(void)
4539 {
4540   struct buf *buf = bread(log.dev, log.start);
4541   struct logheader *lh = (struct logheader *) (buf->data);
4542   int i;
4543   log.lh.n = lh->n;
4544   for (i = 0; i < log.lh.n; i++) {
4545     log.lh.block[i] = lh->block[i];
4546   }
4547   brelse(buf);
4548 }
4549 
4550 // Write in-memory log header to disk.
4551 // This is the true point at which the
4552 // current transaction commits.
4553 static void
4554 write_head(void)
4555 {
4556   struct buf *buf = bread(log.dev, log.start);
4557   struct logheader *hb = (struct logheader *) (buf->data);
4558   int i;
4559   hb->n = log.lh.n;
4560   for (i = 0; i < log.lh.n; i++) {
4561     hb->block[i] = log.lh.block[i];
4562   }
4563   bwrite(buf);
4564   brelse(buf);
4565 }
4566 
4567 static void
4568 recover_from_log(void)
4569 {
4570   read_head();
4571   install_trans(); // if committed, copy from log to disk
4572   log.lh.n = 0;
4573   write_head(); // clear the log
4574 }
4575 
4576 // called at the start of each FS system call.
4577 void
4578 begin_op(void)
4579 {
4580   acquire(&log.lock);
4581   while(1){
4582     if(log.committing){
4583       sleep(&log, &log.lock);
4584     } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
4585       // this op might exhaust log space; wait for commit.
4586       sleep(&log, &log.lock);
4587     } else {
4588       log.outstanding += 1;
4589       release(&log.lock);
4590       break;
4591     }
4592   }
4593 }
4594 
4595 
4596 
4597 
4598 
4599 
4600 // called at the end of each FS system call.
4601 // commits if this was the last outstanding operation.
4602 void
4603 end_op(void)
4604 {
4605   int do_commit = 0;
4606 
4607   acquire(&log.lock);
4608   log.outstanding -= 1;
4609   if(log.committing)
4610     panic("log.committing");
4611   if(log.outstanding == 0){
4612     do_commit = 1;
4613     log.committing = 1;
4614   } else {
4615     // begin_op() may be waiting for log space.
4616     wakeup(&log);
4617   }
4618   release(&log.lock);
4619 
4620   if(do_commit){
4621     // call commit w/o holding locks, since not allowed
4622     // to sleep with locks.
4623     commit();
4624     acquire(&log.lock);
4625     log.committing = 0;
4626     wakeup(&log);
4627     release(&log.lock);
4628   }
4629 }
4630 
4631 // Copy modified blocks from cache to log.
4632 static void
4633 write_log(void)
4634 {
4635   int tail;
4636 
4637   for (tail = 0; tail < log.lh.n; tail++) {
4638     struct buf *to = bread(log.dev, log.start+tail+1); // log block
4639     struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
4640     memmove(to->data, from->data, BSIZE);
4641     bwrite(to);  // write the log
4642     brelse(from);
4643     brelse(to);
4644   }
4645 }
4646 
4647 
4648 
4649 
4650 static void
4651 commit()
4652 {
4653   if (log.lh.n > 0) {
4654     write_log();     // Write modified blocks from cache to log
4655     write_head();    // Write header to disk -- the real commit
4656     install_trans(); // Now install writes to home locations
4657     log.lh.n = 0;
4658     write_head();    // Erase the transaction from the log
4659   }
4660 }
4661 
4662 // Caller has modified b->data and is done with the buffer.
4663 // Record the block number and pin in the cache with B_DIRTY.
4664 // commit()/write_log() will do the disk write.
4665 //
4666 // log_write() replaces bwrite(); a typical use is:
4667 //   bp = bread(...)
4668 //   modify bp->data[]
4669 //   log_write(bp)
4670 //   brelse(bp)
4671 void
4672 log_write(struct buf *b)
4673 {
4674   int i;
4675 
4676   if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
4677     panic("too big a transaction");
4678   if (log.outstanding < 1)
4679     panic("log_write outside of trans");
4680 
4681   acquire(&log.lock);
4682   for (i = 0; i < log.lh.n; i++) {
4683     if (log.lh.block[i] == b->blockno)   // log absorbtion
4684       break;
4685   }
4686   log.lh.block[i] = b->blockno;
4687   if (i == log.lh.n)
4688     log.lh.n++;
4689   b->flags |= B_DIRTY; // prevent eviction
4690   release(&log.lock);
4691 }
4692 
4693 
4694 
4695 
4696 
4697 
4698 
4699 
