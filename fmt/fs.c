4700 // File system implementation.  Five layers:
4701 //   + Blocks: allocator for raw disk blocks.
4702 //   + Log: crash recovery for multi-step updates.
4703 //   + Files: inode allocator, reading, writing, metadata.
4704 //   + Directories: inode with special contents (list of other inodes!)
4705 //   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
4706 //
4707 // This file contains the low-level file system manipulation
4708 // routines.  The (higher-level) system call implementations
4709 // are in sysfile.c.
4710 
4711 #include "types.h"
4712 #include "defs.h"
4713 #include "param.h"
4714 #include "stat.h"
4715 #include "mmu.h"
4716 #include "proc.h"
4717 #include "spinlock.h"
4718 #include "fs.h"
4719 #include "buf.h"
4720 #include "file.h"
4721 
4722 #define min(a, b) ((a) < (b) ? (a) : (b))
4723 static void itrunc(struct inode*);
4724 struct superblock sb;   // there should be one per dev, but we run with one dev
4725 
4726 // Read the super block.
4727 void
4728 readsb(int dev, struct superblock *sb)
4729 {
4730   struct buf *bp;
4731 
4732   bp = bread(dev, 1);
4733   memmove(sb, bp->data, sizeof(*sb));
4734   brelse(bp);
4735 }
4736 
4737 // Zero a block.
4738 static void
4739 bzero(int dev, int bno)
4740 {
4741   struct buf *bp;
4742 
4743   bp = bread(dev, bno);
4744   memset(bp->data, 0, BSIZE);
4745   log_write(bp);
4746   brelse(bp);
4747 }
4748 
4749 
4750 // Blocks.
4751 
4752 // Allocate a zeroed disk block.
4753 static uint
4754 balloc(uint dev)
4755 {
4756   int b, bi, m;
4757   struct buf *bp;
4758 
4759   bp = 0;
4760   for(b = 0; b < sb.size; b += BPB){
4761     bp = bread(dev, BBLOCK(b, sb));
4762     for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
4763       m = 1 << (bi % 8);
4764       if((bp->data[bi/8] & m) == 0){  // Is block free?
4765         bp->data[bi/8] |= m;  // Mark block in use.
4766         log_write(bp);
4767         brelse(bp);
4768         bzero(dev, b + bi);
4769         return b + bi;
4770       }
4771     }
4772     brelse(bp);
4773   }
4774   panic("balloc: out of blocks");
4775 }
4776 
4777 // Free a disk block.
4778 static void
4779 bfree(int dev, uint b)
4780 {
4781   struct buf *bp;
4782   int bi, m;
4783 
4784   readsb(dev, &sb);
4785   bp = bread(dev, BBLOCK(b, sb));
4786   bi = b % BPB;
4787   m = 1 << (bi % 8);
4788   if((bp->data[bi/8] & m) == 0)
4789     panic("freeing free block");
4790   bp->data[bi/8] &= ~m;
4791   log_write(bp);
4792   brelse(bp);
4793 }
4794 
4795 
4796 
4797 
4798 
4799 
4800 // Inodes.
4801 //
4802 // An inode describes a single unnamed file.
4803 // The inode disk structure holds metadata: the file's type,
4804 // its size, the number of links referring to it, and the
4805 // list of blocks holding the file's content.
4806 //
4807 // The inodes are laid out sequentially on disk at
4808 // sb.startinode. Each inode has a number, indicating its
4809 // position on the disk.
4810 //
4811 // The kernel keeps a cache of in-use inodes in memory
4812 // to provide a place for synchronizing access
4813 // to inodes used by multiple processes. The cached
4814 // inodes include book-keeping information that is
4815 // not stored on disk: ip->ref and ip->flags.
4816 //
4817 // An inode and its in-memory represtative go through a
4818 // sequence of states before they can be used by the
4819 // rest of the file system code.
4820 //
4821 // * Allocation: an inode is allocated if its type (on disk)
4822 //   is non-zero. ialloc() allocates, iput() frees if
4823 //   the link count has fallen to zero.
4824 //
4825 // * Referencing in cache: an entry in the inode cache
4826 //   is free if ip->ref is zero. Otherwise ip->ref tracks
4827 //   the number of in-memory pointers to the entry (open
4828 //   files and current directories). iget() to find or
4829 //   create a cache entry and increment its ref, iput()
4830 //   to decrement ref.
4831 //
4832 // * Valid: the information (type, size, &c) in an inode
4833 //   cache entry is only correct when the I_VALID bit
4834 //   is set in ip->flags. ilock() reads the inode from
4835 //   the disk and sets I_VALID, while iput() clears
4836 //   I_VALID if ip->ref has fallen to zero.
4837 //
4838 // * Locked: file system code may only examine and modify
4839 //   the information in an inode and its content if it
4840 //   has first locked the inode. The I_BUSY flag indicates
4841 //   that the inode is locked. ilock() sets I_BUSY,
4842 //   while iunlock clears it.
4843 //
4844 // Thus a typical sequence is:
4845 //   ip = iget(dev, inum)
4846 //   ilock(ip)
4847 //   ... examine and modify ip->xxx ...
4848 //   iunlock(ip)
4849 //   iput(ip)
4850 //
4851 // ilock() is separate from iget() so that system calls can
4852 // get a long-term reference to an inode (as for an open file)
4853 // and only lock it for short periods (e.g., in read()).
4854 // The separation also helps avoid deadlock and races during
4855 // pathname lookup. iget() increments ip->ref so that the inode
4856 // stays cached and pointers to it remain valid.
4857 //
4858 // Many internal file system functions expect the caller to
4859 // have locked the inodes involved; this lets callers create
4860 // multi-step atomic operations.
4861 
4862 struct {
4863   struct spinlock lock;
4864   struct inode inode[NINODE];
4865 } icache;
4866 
4867 void
4868 iinit(int dev)
4869 {
4870   initlock(&icache.lock, "icache");
4871   readsb(dev, &sb);
4872   cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
4873           sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
4874 }
4875 
4876 static struct inode* iget(uint dev, uint inum);
4877 
4878 // Allocate a new inode with the given type on device dev.
4879 // A free inode has a type of zero.
4880 struct inode*
4881 ialloc(uint dev, short type)
4882 {
4883   int inum;
4884   struct buf *bp;
4885   struct dinode *dip;
4886 
4887   for(inum = 1; inum < sb.ninodes; inum++){
4888     bp = bread(dev, IBLOCK(inum, sb));
4889     dip = (struct dinode*)bp->data + inum%IPB;
4890     if(dip->type == 0){  // a free inode
4891       memset(dip, 0, sizeof(*dip));
4892       dip->type = type;
4893       log_write(bp);   // mark it allocated on the disk
4894       brelse(bp);
4895       return iget(dev, inum);
4896     }
4897     brelse(bp);
4898   }
4899   panic("ialloc: no inodes");
4900 }
4901 
4902 // Copy a modified in-memory inode to disk.
4903 void
4904 iupdate(struct inode *ip)
4905 {
4906   struct buf *bp;
4907   struct dinode *dip;
4908 
4909   bp = bread(ip->dev, IBLOCK(ip->inum, sb));
4910   dip = (struct dinode*)bp->data + ip->inum%IPB;
4911   dip->type = ip->type;
4912   dip->major = ip->major;
4913   dip->minor = ip->minor;
4914   dip->nlink = ip->nlink;
4915   dip->size = ip->size;
4916   memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
4917   log_write(bp);
4918   brelse(bp);
4919 }
4920 
4921 // Find the inode with number inum on device dev
4922 // and return the in-memory copy. Does not lock
4923 // the inode and does not read it from disk.
4924 static struct inode*
4925 iget(uint dev, uint inum)
4926 {
4927   struct inode *ip, *empty;
4928 
4929   acquire(&icache.lock);
4930 
4931   // Is the inode already cached?
4932   empty = 0;
4933   for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
4934     if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
4935       ip->ref++;
4936       release(&icache.lock);
4937       return ip;
4938     }
4939     if(empty == 0 && ip->ref == 0)    // Remember empty slot.
4940       empty = ip;
4941   }
4942 
4943   // Recycle an inode cache entry.
4944   if(empty == 0)
4945     panic("iget: no inodes");
4946 
4947 
4948 
4949 
4950   ip = empty;
4951   ip->dev = dev;
4952   ip->inum = inum;
4953   ip->ref = 1;
4954   ip->flags = 0;
4955   release(&icache.lock);
4956 
4957   return ip;
4958 }
4959 
4960 // Increment reference count for ip.
4961 // Returns ip to enable ip = idup(ip1) idiom.
4962 struct inode*
4963 idup(struct inode *ip)
4964 {
4965   acquire(&icache.lock);
4966   ip->ref++;
4967   release(&icache.lock);
4968   return ip;
4969 }
4970 
4971 // Lock the given inode.
4972 // Reads the inode from disk if necessary.
4973 void
4974 ilock(struct inode *ip)
4975 {
4976   struct buf *bp;
4977   struct dinode *dip;
4978 
4979   if(ip == 0 || ip->ref < 1)
4980     panic("ilock");
4981 
4982   acquire(&icache.lock);
4983   while(ip->flags & I_BUSY)
4984     sleep(ip, &icache.lock);
4985   ip->flags |= I_BUSY;
4986   release(&icache.lock);
4987 
4988   if(!(ip->flags & I_VALID)){
4989     bp = bread(ip->dev, IBLOCK(ip->inum, sb));
4990     dip = (struct dinode*)bp->data + ip->inum%IPB;
4991     ip->type = dip->type;
4992     ip->major = dip->major;
4993     ip->minor = dip->minor;
4994     ip->nlink = dip->nlink;
4995     ip->size = dip->size;
4996     memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
4997     brelse(bp);
4998     ip->flags |= I_VALID;
4999     if(ip->type == 0)
5000       panic("ilock: no type");
5001   }
5002 }
5003 
5004 // Unlock the given inode.
5005 void
5006 iunlock(struct inode *ip)
5007 {
5008   if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
5009     panic("iunlock");
5010 
5011   acquire(&icache.lock);
5012   ip->flags &= ~I_BUSY;
5013   wakeup(ip);
5014   release(&icache.lock);
5015 }
5016 
5017 // Drop a reference to an in-memory inode.
5018 // If that was the last reference, the inode cache entry can
5019 // be recycled.
5020 // If that was the last reference and the inode has no links
5021 // to it, free the inode (and its content) on disk.
5022 // All calls to iput() must be inside a transaction in
5023 // case it has to free the inode.
5024 void
5025 iput(struct inode *ip)
5026 {
5027   acquire(&icache.lock);
5028   if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
5029     // inode has no links and no other references: truncate and free.
5030     if(ip->flags & I_BUSY)
5031       panic("iput busy");
5032     ip->flags |= I_BUSY;
5033     release(&icache.lock);
5034     itrunc(ip);
5035     ip->type = 0;
5036     iupdate(ip);
5037     acquire(&icache.lock);
5038     ip->flags = 0;
5039     wakeup(ip);
5040   }
5041   ip->ref--;
5042   release(&icache.lock);
5043 }
5044 
5045 
5046 
5047 
5048 
5049 
5050 // Common idiom: unlock, then put.
5051 void
5052 iunlockput(struct inode *ip)
5053 {
5054   iunlock(ip);
5055   iput(ip);
5056 }
5057 
5058 // Inode content
5059 //
5060 // The content (data) associated with each inode is stored
5061 // in blocks on the disk. The first NDIRECT block numbers
5062 // are listed in ip->addrs[].  The next NINDIRECT blocks are
5063 // listed in block ip->addrs[NDIRECT].
5064 
5065 // Return the disk block address of the nth block in inode ip.
5066 // If there is no such block, bmap allocates one.
5067 static uint
5068 bmap(struct inode *ip, uint bn)
5069 {
5070   uint addr, *a;
5071   struct buf *bp;
5072 
5073   if(bn < NDIRECT){
5074     if((addr = ip->addrs[bn]) == 0)
5075       ip->addrs[bn] = addr = balloc(ip->dev);
5076     return addr;
5077   }
5078   bn -= NDIRECT;
5079 
5080   if(bn < NINDIRECT){
5081     // Load indirect block, allocating if necessary.
5082     if((addr = ip->addrs[NDIRECT]) == 0)
5083       ip->addrs[NDIRECT] = addr = balloc(ip->dev);
5084     bp = bread(ip->dev, addr);
5085     a = (uint*)bp->data;
5086     if((addr = a[bn]) == 0){
5087       a[bn] = addr = balloc(ip->dev);
5088       log_write(bp);
5089     }
5090     brelse(bp);
5091     return addr;
5092   }
5093 
5094   panic("bmap: out of range");
5095 }
5096 
5097 
5098 
5099 
5100 // Truncate inode (discard contents).
5101 // Only called when the inode has no links
5102 // to it (no directory entries referring to it)
5103 // and has no in-memory reference to it (is
5104 // not an open file or current directory).
5105 static void
5106 itrunc(struct inode *ip)
5107 {
5108   int i, j;
5109   struct buf *bp;
5110   uint *a;
5111 
5112   for(i = 0; i < NDIRECT; i++){
5113     if(ip->addrs[i]){
5114       bfree(ip->dev, ip->addrs[i]);
5115       ip->addrs[i] = 0;
5116     }
5117   }
5118 
5119   if(ip->addrs[NDIRECT]){
5120     bp = bread(ip->dev, ip->addrs[NDIRECT]);
5121     a = (uint*)bp->data;
5122     for(j = 0; j < NINDIRECT; j++){
5123       if(a[j])
5124         bfree(ip->dev, a[j]);
5125     }
5126     brelse(bp);
5127     bfree(ip->dev, ip->addrs[NDIRECT]);
5128     ip->addrs[NDIRECT] = 0;
5129   }
5130 
5131   ip->size = 0;
5132   iupdate(ip);
5133 }
5134 
5135 // Copy stat information from inode.
5136 void
5137 stati(struct inode *ip, struct stat *st)
5138 {
5139   st->dev = ip->dev;
5140   st->ino = ip->inum;
5141   st->type = ip->type;
5142   st->nlink = ip->nlink;
5143   st->size = ip->size;
5144 }
5145 
5146 
5147 
5148 
5149 
5150 // Read data from inode.
5151 int
5152 readi(struct inode *ip, char *dst, uint off, uint n)
5153 {
5154   uint tot, m;
5155   struct buf *bp;
5156 
5157   if(ip->type == T_DEV){
5158     if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
5159       return -1;
5160     return devsw[ip->major].read(ip, dst, n);
5161   }
5162 
5163   if(off > ip->size || off + n < off)
5164     return -1;
5165   if(off + n > ip->size)
5166     n = ip->size - off;
5167 
5168   for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
5169     bp = bread(ip->dev, bmap(ip, off/BSIZE));
5170     m = min(n - tot, BSIZE - off%BSIZE);
5171     memmove(dst, bp->data + off%BSIZE, m);
5172     brelse(bp);
5173   }
5174   return n;
5175 }
5176 
5177 // Write data to inode.
5178 int
5179 writei(struct inode *ip, char *src, uint off, uint n)
5180 {
5181   uint tot, m;
5182   struct buf *bp;
5183 
5184   if(ip->type == T_DEV){
5185     if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
5186       return -1;
5187     return devsw[ip->major].write(ip, src, n);
5188   }
5189 
5190   if(off > ip->size || off + n < off)
5191     return -1;
5192   if(off + n > MAXFILE*BSIZE)
5193     return -1;
5194 
5195   for(tot=0; tot<n; tot+=m, off+=m, src+=m){
5196     bp = bread(ip->dev, bmap(ip, off/BSIZE));
5197     m = min(n - tot, BSIZE - off%BSIZE);
5198     memmove(bp->data + off%BSIZE, src, m);
5199     log_write(bp);
5200     brelse(bp);
5201   }
5202 
5203   if(n > 0 && off > ip->size){
5204     ip->size = off;
5205     iupdate(ip);
5206   }
5207   return n;
5208 }
5209 
5210 // Directories
5211 
5212 int
5213 namecmp(const char *s, const char *t)
5214 {
5215   return strncmp(s, t, DIRSIZ);
5216 }
5217 
5218 // Look for a directory entry in a directory.
5219 // If found, set *poff to byte offset of entry.
5220 struct inode*
5221 dirlookup(struct inode *dp, char *name, uint *poff)
5222 {
5223   uint off, inum;
5224   struct dirent de;
5225 
5226   if(dp->type != T_DIR)
5227     panic("dirlookup not DIR");
5228 
5229   for(off = 0; off < dp->size; off += sizeof(de)){
5230     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5231       panic("dirlink read");
5232     if(de.inum == 0)
5233       continue;
5234     if(namecmp(name, de.name) == 0){
5235       // entry matches path element
5236       if(poff)
5237         *poff = off;
5238       inum = de.inum;
5239       return iget(dp->dev, inum);
5240     }
5241   }
5242 
5243   return 0;
5244 }
5245 
5246 
5247 
5248 
5249 
5250 // Write a new directory entry (name, inum) into the directory dp.
5251 int
5252 dirlink(struct inode *dp, char *name, uint inum)
5253 {
5254   int off;
5255   struct dirent de;
5256   struct inode *ip;
5257 
5258   // Check that name is not present.
5259   if((ip = dirlookup(dp, name, 0)) != 0){
5260     iput(ip);
5261     return -1;
5262   }
5263 
5264   // Look for an empty dirent.
5265   for(off = 0; off < dp->size; off += sizeof(de)){
5266     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5267       panic("dirlink read");
5268     if(de.inum == 0)
5269       break;
5270   }
5271 
5272   strncpy(de.name, name, DIRSIZ);
5273   de.inum = inum;
5274   if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5275     panic("dirlink");
5276 
5277   return 0;
5278 }
5279 
5280 // Paths
5281 
5282 // Copy the next path element from path into name.
5283 // Return a pointer to the element following the copied one.
5284 // The returned path has no leading slashes,
5285 // so the caller can check *path=='\0' to see if the name is the last one.
5286 // If no name to remove, return 0.
5287 //
5288 // Examples:
5289 //   skipelem("a/bb/c", name) = "bb/c", setting name = "a"
5290 //   skipelem("///a//bb", name) = "bb", setting name = "a"
5291 //   skipelem("a", name) = "", setting name = "a"
5292 //   skipelem("", name) = skipelem("////", name) = 0
5293 //
5294 static char*
5295 skipelem(char *path, char *name)
5296 {
5297   char *s;
5298   int len;
5299 
5300   while(*path == '/')
5301     path++;
5302   if(*path == 0)
5303     return 0;
5304   s = path;
5305   while(*path != '/' && *path != 0)
5306     path++;
5307   len = path - s;
5308   if(len >= DIRSIZ)
5309     memmove(name, s, DIRSIZ);
5310   else {
5311     memmove(name, s, len);
5312     name[len] = 0;
5313   }
5314   while(*path == '/')
5315     path++;
5316   return path;
5317 }
5318 
5319 // Look up and return the inode for a path name.
5320 // If parent != 0, return the inode for the parent and copy the final
5321 // path element into name, which must have room for DIRSIZ bytes.
5322 // Must be called inside a transaction since it calls iput().
5323 static struct inode*
5324 namex(char *path, int nameiparent, char *name)
5325 {
5326   struct inode *ip, *next;
5327 
5328   if(*path == '/')
5329     ip = iget(ROOTDEV, ROOTINO);
5330   else
5331     ip = idup(proc->cwd);
5332 
5333   while((path = skipelem(path, name)) != 0){
5334     ilock(ip);
5335     if(ip->type != T_DIR){
5336       iunlockput(ip);
5337       return 0;
5338     }
5339     if(nameiparent && *path == '\0'){
5340       // Stop one level early.
5341       iunlock(ip);
5342       return ip;
5343     }
5344     if((next = dirlookup(ip, name, 0)) == 0){
5345       iunlockput(ip);
5346       return 0;
5347     }
5348     iunlockput(ip);
5349     ip = next;
5350   }
5351   if(nameiparent){
5352     iput(ip);
5353     return 0;
5354   }
5355   return ip;
5356 }
5357 
5358 struct inode*
5359 namei(char *path)
5360 {
5361   char name[DIRSIZ];
5362   return namex(path, 0, name);
5363 }
5364 
5365 struct inode*
5366 nameiparent(char *path, char *name)
5367 {
5368   return namex(path, 1, name);
5369 }
5370 
5371 
5372 
5373 
5374 
5375 
5376 
5377 
5378 
5379 
5380 
5381 
5382 
5383 
5384 
5385 
5386 
5387 
5388 
5389 
5390 
5391 
5392 
5393 
5394 
5395 
5396 
5397 
5398 
5399 
