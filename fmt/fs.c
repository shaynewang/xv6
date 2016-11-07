5000 // File system implementation.  Five layers:
5001 //   + Blocks: allocator for raw disk blocks.
5002 //   + Log: crash recovery for multi-step updates.
5003 //   + Files: inode allocator, reading, writing, metadata.
5004 //   + Directories: inode with special contents (list of other inodes!)
5005 //   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
5006 //
5007 // This file contains the low-level file system manipulation
5008 // routines.  The (higher-level) system call implementations
5009 // are in sysfile.c.
5010 
5011 #include "types.h"
5012 #include "defs.h"
5013 #include "param.h"
5014 #include "stat.h"
5015 #include "mmu.h"
5016 #include "proc.h"
5017 #include "spinlock.h"
5018 #include "fs.h"
5019 #include "buf.h"
5020 #include "file.h"
5021 
5022 #define min(a, b) ((a) < (b) ? (a) : (b))
5023 static void itrunc(struct inode*);
5024 struct superblock sb;   // there should be one per dev, but we run with one dev
5025 
5026 // Read the super block.
5027 void
5028 readsb(int dev, struct superblock *sb)
5029 {
5030   struct buf *bp;
5031 
5032   bp = bread(dev, 1);
5033   memmove(sb, bp->data, sizeof(*sb));
5034   brelse(bp);
5035 }
5036 
5037 // Zero a block.
5038 static void
5039 bzero(int dev, int bno)
5040 {
5041   struct buf *bp;
5042 
5043   bp = bread(dev, bno);
5044   memset(bp->data, 0, BSIZE);
5045   log_write(bp);
5046   brelse(bp);
5047 }
5048 
5049 
5050 // Blocks.
5051 
5052 // Allocate a zeroed disk block.
5053 static uint
5054 balloc(uint dev)
5055 {
5056   int b, bi, m;
5057   struct buf *bp;
5058 
5059   bp = 0;
5060   for(b = 0; b < sb.size; b += BPB){
5061     bp = bread(dev, BBLOCK(b, sb));
5062     for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
5063       m = 1 << (bi % 8);
5064       if((bp->data[bi/8] & m) == 0){  // Is block free?
5065         bp->data[bi/8] |= m;  // Mark block in use.
5066         log_write(bp);
5067         brelse(bp);
5068         bzero(dev, b + bi);
5069         return b + bi;
5070       }
5071     }
5072     brelse(bp);
5073   }
5074   panic("balloc: out of blocks");
5075 }
5076 
5077 // Free a disk block.
5078 static void
5079 bfree(int dev, uint b)
5080 {
5081   struct buf *bp;
5082   int bi, m;
5083 
5084   readsb(dev, &sb);
5085   bp = bread(dev, BBLOCK(b, sb));
5086   bi = b % BPB;
5087   m = 1 << (bi % 8);
5088   if((bp->data[bi/8] & m) == 0)
5089     panic("freeing free block");
5090   bp->data[bi/8] &= ~m;
5091   log_write(bp);
5092   brelse(bp);
5093 }
5094 
5095 
5096 
5097 
5098 
5099 
5100 // Inodes.
5101 //
5102 // An inode describes a single unnamed file.
5103 // The inode disk structure holds metadata: the file's type,
5104 // its size, the number of links referring to it, and the
5105 // list of blocks holding the file's content.
5106 //
5107 // The inodes are laid out sequentially on disk at
5108 // sb.startinode. Each inode has a number, indicating its
5109 // position on the disk.
5110 //
5111 // The kernel keeps a cache of in-use inodes in memory
5112 // to provide a place for synchronizing access
5113 // to inodes used by multiple processes. The cached
5114 // inodes include book-keeping information that is
5115 // not stored on disk: ip->ref and ip->flags.
5116 //
5117 // An inode and its in-memory represtative go through a
5118 // sequence of states before they can be used by the
5119 // rest of the file system code.
5120 //
5121 // * Allocation: an inode is allocated if its type (on disk)
5122 //   is non-zero. ialloc() allocates, iput() frees if
5123 //   the link count has fallen to zero.
5124 //
5125 // * Referencing in cache: an entry in the inode cache
5126 //   is free if ip->ref is zero. Otherwise ip->ref tracks
5127 //   the number of in-memory pointers to the entry (open
5128 //   files and current directories). iget() to find or
5129 //   create a cache entry and increment its ref, iput()
5130 //   to decrement ref.
5131 //
5132 // * Valid: the information (type, size, &c) in an inode
5133 //   cache entry is only correct when the I_VALID bit
5134 //   is set in ip->flags. ilock() reads the inode from
5135 //   the disk and sets I_VALID, while iput() clears
5136 //   I_VALID if ip->ref has fallen to zero.
5137 //
5138 // * Locked: file system code may only examine and modify
5139 //   the information in an inode and its content if it
5140 //   has first locked the inode. The I_BUSY flag indicates
5141 //   that the inode is locked. ilock() sets I_BUSY,
5142 //   while iunlock clears it.
5143 //
5144 // Thus a typical sequence is:
5145 //   ip = iget(dev, inum)
5146 //   ilock(ip)
5147 //   ... examine and modify ip->xxx ...
5148 //   iunlock(ip)
5149 //   iput(ip)
5150 //
5151 // ilock() is separate from iget() so that system calls can
5152 // get a long-term reference to an inode (as for an open file)
5153 // and only lock it for short periods (e.g., in read()).
5154 // The separation also helps avoid deadlock and races during
5155 // pathname lookup. iget() increments ip->ref so that the inode
5156 // stays cached and pointers to it remain valid.
5157 //
5158 // Many internal file system functions expect the caller to
5159 // have locked the inodes involved; this lets callers create
5160 // multi-step atomic operations.
5161 
5162 struct {
5163   struct spinlock lock;
5164   struct inode inode[NINODE];
5165 } icache;
5166 
5167 void
5168 iinit(int dev)
5169 {
5170   initlock(&icache.lock, "icache");
5171   readsb(dev, &sb);
5172   cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
5173           sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
5174 }
5175 
5176 static struct inode* iget(uint dev, uint inum);
5177 
5178 // Allocate a new inode with the given type on device dev.
5179 // A free inode has a type of zero.
5180 struct inode*
5181 ialloc(uint dev, short type)
5182 {
5183   int inum;
5184   struct buf *bp;
5185   struct dinode *dip;
5186 
5187   for(inum = 1; inum < sb.ninodes; inum++){
5188     bp = bread(dev, IBLOCK(inum, sb));
5189     dip = (struct dinode*)bp->data + inum%IPB;
5190     if(dip->type == 0){  // a free inode
5191       memset(dip, 0, sizeof(*dip));
5192       dip->type = type;
5193       log_write(bp);   // mark it allocated on the disk
5194       brelse(bp);
5195       return iget(dev, inum);
5196     }
5197     brelse(bp);
5198   }
5199   panic("ialloc: no inodes");
5200 }
5201 
5202 // Copy a modified in-memory inode to disk.
5203 void
5204 iupdate(struct inode *ip)
5205 {
5206   struct buf *bp;
5207   struct dinode *dip;
5208 
5209   bp = bread(ip->dev, IBLOCK(ip->inum, sb));
5210   dip = (struct dinode*)bp->data + ip->inum%IPB;
5211   dip->type = ip->type;
5212   dip->major = ip->major;
5213   dip->minor = ip->minor;
5214   dip->nlink = ip->nlink;
5215   dip->size = ip->size;
5216   memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
5217   log_write(bp);
5218   brelse(bp);
5219 }
5220 
5221 // Find the inode with number inum on device dev
5222 // and return the in-memory copy. Does not lock
5223 // the inode and does not read it from disk.
5224 static struct inode*
5225 iget(uint dev, uint inum)
5226 {
5227   struct inode *ip, *empty;
5228 
5229   acquire(&icache.lock);
5230 
5231   // Is the inode already cached?
5232   empty = 0;
5233   for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
5234     if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
5235       ip->ref++;
5236       release(&icache.lock);
5237       return ip;
5238     }
5239     if(empty == 0 && ip->ref == 0)    // Remember empty slot.
5240       empty = ip;
5241   }
5242 
5243   // Recycle an inode cache entry.
5244   if(empty == 0)
5245     panic("iget: no inodes");
5246 
5247 
5248 
5249 
5250   ip = empty;
5251   ip->dev = dev;
5252   ip->inum = inum;
5253   ip->ref = 1;
5254   ip->flags = 0;
5255   release(&icache.lock);
5256 
5257   return ip;
5258 }
5259 
5260 // Increment reference count for ip.
5261 // Returns ip to enable ip = idup(ip1) idiom.
5262 struct inode*
5263 idup(struct inode *ip)
5264 {
5265   acquire(&icache.lock);
5266   ip->ref++;
5267   release(&icache.lock);
5268   return ip;
5269 }
5270 
5271 // Lock the given inode.
5272 // Reads the inode from disk if necessary.
5273 void
5274 ilock(struct inode *ip)
5275 {
5276   struct buf *bp;
5277   struct dinode *dip;
5278 
5279   if(ip == 0 || ip->ref < 1)
5280     panic("ilock");
5281 
5282   acquire(&icache.lock);
5283   while(ip->flags & I_BUSY)
5284     sleep(ip, &icache.lock);
5285   ip->flags |= I_BUSY;
5286   release(&icache.lock);
5287 
5288   if(!(ip->flags & I_VALID)){
5289     bp = bread(ip->dev, IBLOCK(ip->inum, sb));
5290     dip = (struct dinode*)bp->data + ip->inum%IPB;
5291     ip->type = dip->type;
5292     ip->major = dip->major;
5293     ip->minor = dip->minor;
5294     ip->nlink = dip->nlink;
5295     ip->size = dip->size;
5296     memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
5297     brelse(bp);
5298     ip->flags |= I_VALID;
5299     if(ip->type == 0)
5300       panic("ilock: no type");
5301   }
5302 }
5303 
5304 // Unlock the given inode.
5305 void
5306 iunlock(struct inode *ip)
5307 {
5308   if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
5309     panic("iunlock");
5310 
5311   acquire(&icache.lock);
5312   ip->flags &= ~I_BUSY;
5313   wakeup(ip);
5314   release(&icache.lock);
5315 }
5316 
5317 // Drop a reference to an in-memory inode.
5318 // If that was the last reference, the inode cache entry can
5319 // be recycled.
5320 // If that was the last reference and the inode has no links
5321 // to it, free the inode (and its content) on disk.
5322 // All calls to iput() must be inside a transaction in
5323 // case it has to free the inode.
5324 void
5325 iput(struct inode *ip)
5326 {
5327   acquire(&icache.lock);
5328   if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
5329     // inode has no links and no other references: truncate and free.
5330     if(ip->flags & I_BUSY)
5331       panic("iput busy");
5332     ip->flags |= I_BUSY;
5333     release(&icache.lock);
5334     itrunc(ip);
5335     ip->type = 0;
5336     iupdate(ip);
5337     acquire(&icache.lock);
5338     ip->flags = 0;
5339     wakeup(ip);
5340   }
5341   ip->ref--;
5342   release(&icache.lock);
5343 }
5344 
5345 
5346 
5347 
5348 
5349 
5350 // Common idiom: unlock, then put.
5351 void
5352 iunlockput(struct inode *ip)
5353 {
5354   iunlock(ip);
5355   iput(ip);
5356 }
5357 
5358 // Inode content
5359 //
5360 // The content (data) associated with each inode is stored
5361 // in blocks on the disk. The first NDIRECT block numbers
5362 // are listed in ip->addrs[].  The next NINDIRECT blocks are
5363 // listed in block ip->addrs[NDIRECT].
5364 
5365 // Return the disk block address of the nth block in inode ip.
5366 // If there is no such block, bmap allocates one.
5367 static uint
5368 bmap(struct inode *ip, uint bn)
5369 {
5370   uint addr, *a;
5371   struct buf *bp;
5372 
5373   if(bn < NDIRECT){
5374     if((addr = ip->addrs[bn]) == 0)
5375       ip->addrs[bn] = addr = balloc(ip->dev);
5376     return addr;
5377   }
5378   bn -= NDIRECT;
5379 
5380   if(bn < NINDIRECT){
5381     // Load indirect block, allocating if necessary.
5382     if((addr = ip->addrs[NDIRECT]) == 0)
5383       ip->addrs[NDIRECT] = addr = balloc(ip->dev);
5384     bp = bread(ip->dev, addr);
5385     a = (uint*)bp->data;
5386     if((addr = a[bn]) == 0){
5387       a[bn] = addr = balloc(ip->dev);
5388       log_write(bp);
5389     }
5390     brelse(bp);
5391     return addr;
5392   }
5393 
5394   panic("bmap: out of range");
5395 }
5396 
5397 
5398 
5399 
5400 // Truncate inode (discard contents).
5401 // Only called when the inode has no links
5402 // to it (no directory entries referring to it)
5403 // and has no in-memory reference to it (is
5404 // not an open file or current directory).
5405 static void
5406 itrunc(struct inode *ip)
5407 {
5408   int i, j;
5409   struct buf *bp;
5410   uint *a;
5411 
5412   for(i = 0; i < NDIRECT; i++){
5413     if(ip->addrs[i]){
5414       bfree(ip->dev, ip->addrs[i]);
5415       ip->addrs[i] = 0;
5416     }
5417   }
5418 
5419   if(ip->addrs[NDIRECT]){
5420     bp = bread(ip->dev, ip->addrs[NDIRECT]);
5421     a = (uint*)bp->data;
5422     for(j = 0; j < NINDIRECT; j++){
5423       if(a[j])
5424         bfree(ip->dev, a[j]);
5425     }
5426     brelse(bp);
5427     bfree(ip->dev, ip->addrs[NDIRECT]);
5428     ip->addrs[NDIRECT] = 0;
5429   }
5430 
5431   ip->size = 0;
5432   iupdate(ip);
5433 }
5434 
5435 // Copy stat information from inode.
5436 void
5437 stati(struct inode *ip, struct stat *st)
5438 {
5439   st->dev = ip->dev;
5440   st->ino = ip->inum;
5441   st->type = ip->type;
5442   st->nlink = ip->nlink;
5443   st->size = ip->size;
5444 }
5445 
5446 
5447 
5448 
5449 
5450 // Read data from inode.
5451 int
5452 readi(struct inode *ip, char *dst, uint off, uint n)
5453 {
5454   uint tot, m;
5455   struct buf *bp;
5456 
5457   if(ip->type == T_DEV){
5458     if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
5459       return -1;
5460     return devsw[ip->major].read(ip, dst, n);
5461   }
5462 
5463   if(off > ip->size || off + n < off)
5464     return -1;
5465   if(off + n > ip->size)
5466     n = ip->size - off;
5467 
5468   for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
5469     bp = bread(ip->dev, bmap(ip, off/BSIZE));
5470     m = min(n - tot, BSIZE - off%BSIZE);
5471     memmove(dst, bp->data + off%BSIZE, m);
5472     brelse(bp);
5473   }
5474   return n;
5475 }
5476 
5477 // Write data to inode.
5478 int
5479 writei(struct inode *ip, char *src, uint off, uint n)
5480 {
5481   uint tot, m;
5482   struct buf *bp;
5483 
5484   if(ip->type == T_DEV){
5485     if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
5486       return -1;
5487     return devsw[ip->major].write(ip, src, n);
5488   }
5489 
5490   if(off > ip->size || off + n < off)
5491     return -1;
5492   if(off + n > MAXFILE*BSIZE)
5493     return -1;
5494 
5495   for(tot=0; tot<n; tot+=m, off+=m, src+=m){
5496     bp = bread(ip->dev, bmap(ip, off/BSIZE));
5497     m = min(n - tot, BSIZE - off%BSIZE);
5498     memmove(bp->data + off%BSIZE, src, m);
5499     log_write(bp);
5500     brelse(bp);
5501   }
5502 
5503   if(n > 0 && off > ip->size){
5504     ip->size = off;
5505     iupdate(ip);
5506   }
5507   return n;
5508 }
5509 
5510 // Directories
5511 
5512 int
5513 namecmp(const char *s, const char *t)
5514 {
5515   return strncmp(s, t, DIRSIZ);
5516 }
5517 
5518 // Look for a directory entry in a directory.
5519 // If found, set *poff to byte offset of entry.
5520 struct inode*
5521 dirlookup(struct inode *dp, char *name, uint *poff)
5522 {
5523   uint off, inum;
5524   struct dirent de;
5525 
5526   if(dp->type != T_DIR)
5527     panic("dirlookup not DIR");
5528 
5529   for(off = 0; off < dp->size; off += sizeof(de)){
5530     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5531       panic("dirlink read");
5532     if(de.inum == 0)
5533       continue;
5534     if(namecmp(name, de.name) == 0){
5535       // entry matches path element
5536       if(poff)
5537         *poff = off;
5538       inum = de.inum;
5539       return iget(dp->dev, inum);
5540     }
5541   }
5542 
5543   return 0;
5544 }
5545 
5546 
5547 
5548 
5549 
5550 // Write a new directory entry (name, inum) into the directory dp.
5551 int
5552 dirlink(struct inode *dp, char *name, uint inum)
5553 {
5554   int off;
5555   struct dirent de;
5556   struct inode *ip;
5557 
5558   // Check that name is not present.
5559   if((ip = dirlookup(dp, name, 0)) != 0){
5560     iput(ip);
5561     return -1;
5562   }
5563 
5564   // Look for an empty dirent.
5565   for(off = 0; off < dp->size; off += sizeof(de)){
5566     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5567       panic("dirlink read");
5568     if(de.inum == 0)
5569       break;
5570   }
5571 
5572   strncpy(de.name, name, DIRSIZ);
5573   de.inum = inum;
5574   if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5575     panic("dirlink");
5576 
5577   return 0;
5578 }
5579 
5580 // Paths
5581 
5582 // Copy the next path element from path into name.
5583 // Return a pointer to the element following the copied one.
5584 // The returned path has no leading slashes,
5585 // so the caller can check *path=='\0' to see if the name is the last one.
5586 // If no name to remove, return 0.
5587 //
5588 // Examples:
5589 //   skipelem("a/bb/c", name) = "bb/c", setting name = "a"
5590 //   skipelem("///a//bb", name) = "bb", setting name = "a"
5591 //   skipelem("a", name) = "", setting name = "a"
5592 //   skipelem("", name) = skipelem("////", name) = 0
5593 //
5594 static char*
5595 skipelem(char *path, char *name)
5596 {
5597   char *s;
5598   int len;
5599 
5600   while(*path == '/')
5601     path++;
5602   if(*path == 0)
5603     return 0;
5604   s = path;
5605   while(*path != '/' && *path != 0)
5606     path++;
5607   len = path - s;
5608   if(len >= DIRSIZ)
5609     memmove(name, s, DIRSIZ);
5610   else {
5611     memmove(name, s, len);
5612     name[len] = 0;
5613   }
5614   while(*path == '/')
5615     path++;
5616   return path;
5617 }
5618 
5619 // Look up and return the inode for a path name.
5620 // If parent != 0, return the inode for the parent and copy the final
5621 // path element into name, which must have room for DIRSIZ bytes.
5622 // Must be called inside a transaction since it calls iput().
5623 static struct inode*
5624 namex(char *path, int nameiparent, char *name)
5625 {
5626   struct inode *ip, *next;
5627 
5628   if(*path == '/')
5629     ip = iget(ROOTDEV, ROOTINO);
5630   else
5631     ip = idup(proc->cwd);
5632 
5633   while((path = skipelem(path, name)) != 0){
5634     ilock(ip);
5635     if(ip->type != T_DIR){
5636       iunlockput(ip);
5637       return 0;
5638     }
5639     if(nameiparent && *path == '\0'){
5640       // Stop one level early.
5641       iunlock(ip);
5642       return ip;
5643     }
5644     if((next = dirlookup(ip, name, 0)) == 0){
5645       iunlockput(ip);
5646       return 0;
5647     }
5648     iunlockput(ip);
5649     ip = next;
5650   }
5651   if(nameiparent){
5652     iput(ip);
5653     return 0;
5654   }
5655   return ip;
5656 }
5657 
5658 struct inode*
5659 namei(char *path)
5660 {
5661   char name[DIRSIZ];
5662   return namex(path, 0, name);
5663 }
5664 
5665 struct inode*
5666 nameiparent(char *path, char *name)
5667 {
5668   return namex(path, 1, name);
5669 }
5670 
5671 
5672 
5673 
5674 
5675 
5676 
5677 
5678 
5679 
5680 
5681 
5682 
5683 
5684 
5685 
5686 
5687 
5688 
5689 
5690 
5691 
5692 
5693 
5694 
5695 
5696 
5697 
5698 
5699 
