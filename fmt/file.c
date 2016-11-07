5700 //
5701 // File descriptors
5702 //
5703 
5704 #include "types.h"
5705 #include "defs.h"
5706 #include "param.h"
5707 #include "fs.h"
5708 #include "file.h"
5709 #include "spinlock.h"
5710 
5711 struct devsw devsw[NDEV];
5712 struct {
5713   struct spinlock lock;
5714   struct file file[NFILE];
5715 } ftable;
5716 
5717 void
5718 fileinit(void)
5719 {
5720   initlock(&ftable.lock, "ftable");
5721 }
5722 
5723 // Allocate a file structure.
5724 struct file*
5725 filealloc(void)
5726 {
5727   struct file *f;
5728 
5729   acquire(&ftable.lock);
5730   for(f = ftable.file; f < ftable.file + NFILE; f++){
5731     if(f->ref == 0){
5732       f->ref = 1;
5733       release(&ftable.lock);
5734       return f;
5735     }
5736   }
5737   release(&ftable.lock);
5738   return 0;
5739 }
5740 
5741 
5742 
5743 
5744 
5745 
5746 
5747 
5748 
5749 
5750 // Increment ref count for file f.
5751 struct file*
5752 filedup(struct file *f)
5753 {
5754   acquire(&ftable.lock);
5755   if(f->ref < 1)
5756     panic("filedup");
5757   f->ref++;
5758   release(&ftable.lock);
5759   return f;
5760 }
5761 
5762 // Close file f.  (Decrement ref count, close when reaches 0.)
5763 void
5764 fileclose(struct file *f)
5765 {
5766   struct file ff;
5767 
5768   acquire(&ftable.lock);
5769   if(f->ref < 1)
5770     panic("fileclose");
5771   if(--f->ref > 0){
5772     release(&ftable.lock);
5773     return;
5774   }
5775   ff = *f;
5776   f->ref = 0;
5777   f->type = FD_NONE;
5778   release(&ftable.lock);
5779 
5780   if(ff.type == FD_PIPE)
5781     pipeclose(ff.pipe, ff.writable);
5782   else if(ff.type == FD_INODE){
5783     begin_op();
5784     iput(ff.ip);
5785     end_op();
5786   }
5787 }
5788 
5789 
5790 
5791 
5792 
5793 
5794 
5795 
5796 
5797 
5798 
5799 
5800 // Get metadata about file f.
5801 int
5802 filestat(struct file *f, struct stat *st)
5803 {
5804   if(f->type == FD_INODE){
5805     ilock(f->ip);
5806     stati(f->ip, st);
5807     iunlock(f->ip);
5808     return 0;
5809   }
5810   return -1;
5811 }
5812 
5813 // Read from file f.
5814 int
5815 fileread(struct file *f, char *addr, int n)
5816 {
5817   int r;
5818 
5819   if(f->readable == 0)
5820     return -1;
5821   if(f->type == FD_PIPE)
5822     return piperead(f->pipe, addr, n);
5823   if(f->type == FD_INODE){
5824     ilock(f->ip);
5825     if((r = readi(f->ip, addr, f->off, n)) > 0)
5826       f->off += r;
5827     iunlock(f->ip);
5828     return r;
5829   }
5830   panic("fileread");
5831 }
5832 
5833 // Write to file f.
5834 int
5835 filewrite(struct file *f, char *addr, int n)
5836 {
5837   int r;
5838 
5839   if(f->writable == 0)
5840     return -1;
5841   if(f->type == FD_PIPE)
5842     return pipewrite(f->pipe, addr, n);
5843   if(f->type == FD_INODE){
5844     // write a few blocks at a time to avoid exceeding
5845     // the maximum log transaction size, including
5846     // i-node, indirect block, allocation blocks,
5847     // and 2 blocks of slop for non-aligned writes.
5848     // this really belongs lower down, since writei()
5849     // might be writing a device like the console.
5850     int max = ((LOGSIZE-1-1-2) / 2) * 512;
5851     int i = 0;
5852     while(i < n){
5853       int n1 = n - i;
5854       if(n1 > max)
5855         n1 = max;
5856 
5857       begin_op();
5858       ilock(f->ip);
5859       if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
5860         f->off += r;
5861       iunlock(f->ip);
5862       end_op();
5863 
5864       if(r < 0)
5865         break;
5866       if(r != n1)
5867         panic("short filewrite");
5868       i += r;
5869     }
5870     return i == n ? n : -1;
5871   }
5872   panic("filewrite");
5873 }
5874 
5875 
5876 
5877 
5878 
5879 
5880 
5881 
5882 
5883 
5884 
5885 
5886 
5887 
5888 
5889 
5890 
5891 
5892 
5893 
5894 
5895 
5896 
5897 
5898 
5899 
