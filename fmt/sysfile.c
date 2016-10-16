5600 //
5601 // File-system system calls.
5602 // Mostly argument checking, since we don't trust
5603 // user code, and calls into file.c and fs.c.
5604 //
5605 
5606 #include "types.h"
5607 #include "defs.h"
5608 #include "param.h"
5609 #include "stat.h"
5610 #include "mmu.h"
5611 #include "proc.h"
5612 #include "fs.h"
5613 #include "file.h"
5614 #include "fcntl.h"
5615 
5616 // Fetch the nth word-sized system call argument as a file descriptor
5617 // and return both the descriptor and the corresponding struct file.
5618 static int
5619 argfd(int n, int *pfd, struct file **pf)
5620 {
5621   int fd;
5622   struct file *f;
5623 
5624   if(argint(n, &fd) < 0)
5625     return -1;
5626   if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
5627     return -1;
5628   if(pfd)
5629     *pfd = fd;
5630   if(pf)
5631     *pf = f;
5632   return 0;
5633 }
5634 
5635 // Allocate a file descriptor for the given file.
5636 // Takes over file reference from caller on success.
5637 static int
5638 fdalloc(struct file *f)
5639 {
5640   int fd;
5641 
5642   for(fd = 0; fd < NOFILE; fd++){
5643     if(proc->ofile[fd] == 0){
5644       proc->ofile[fd] = f;
5645       return fd;
5646     }
5647   }
5648   return -1;
5649 }
5650 int
5651 sys_dup(void)
5652 {
5653   struct file *f;
5654   int fd;
5655 
5656   if(argfd(0, 0, &f) < 0)
5657     return -1;
5658   if((fd=fdalloc(f)) < 0)
5659     return -1;
5660   filedup(f);
5661   return fd;
5662 }
5663 
5664 int
5665 sys_read(void)
5666 {
5667   struct file *f;
5668   int n;
5669   char *p;
5670 
5671   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5672     return -1;
5673   return fileread(f, p, n);
5674 }
5675 
5676 int
5677 sys_write(void)
5678 {
5679   struct file *f;
5680   int n;
5681   char *p;
5682 
5683   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5684     return -1;
5685   return filewrite(f, p, n);
5686 }
5687 
5688 int
5689 sys_close(void)
5690 {
5691   int fd;
5692   struct file *f;
5693 
5694   if(argfd(0, &fd, &f) < 0)
5695     return -1;
5696   proc->ofile[fd] = 0;
5697   fileclose(f);
5698   return 0;
5699 }
5700 int
5701 sys_fstat(void)
5702 {
5703   struct file *f;
5704   struct stat *st;
5705 
5706   if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
5707     return -1;
5708   return filestat(f, st);
5709 }
5710 
5711 // Create the path new as a link to the same inode as old.
5712 int
5713 sys_link(void)
5714 {
5715   char name[DIRSIZ], *new, *old;
5716   struct inode *dp, *ip;
5717 
5718   if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
5719     return -1;
5720 
5721   begin_op();
5722   if((ip = namei(old)) == 0){
5723     end_op();
5724     return -1;
5725   }
5726 
5727   ilock(ip);
5728   if(ip->type == T_DIR){
5729     iunlockput(ip);
5730     end_op();
5731     return -1;
5732   }
5733 
5734   ip->nlink++;
5735   iupdate(ip);
5736   iunlock(ip);
5737 
5738   if((dp = nameiparent(new, name)) == 0)
5739     goto bad;
5740   ilock(dp);
5741   if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
5742     iunlockput(dp);
5743     goto bad;
5744   }
5745   iunlockput(dp);
5746   iput(ip);
5747 
5748   end_op();
5749 
5750   return 0;
5751 
5752 bad:
5753   ilock(ip);
5754   ip->nlink--;
5755   iupdate(ip);
5756   iunlockput(ip);
5757   end_op();
5758   return -1;
5759 }
5760 
5761 // Is the directory dp empty except for "." and ".." ?
5762 static int
5763 isdirempty(struct inode *dp)
5764 {
5765   int off;
5766   struct dirent de;
5767 
5768   for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
5769     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5770       panic("isdirempty: readi");
5771     if(de.inum != 0)
5772       return 0;
5773   }
5774   return 1;
5775 }
5776 
5777 int
5778 sys_unlink(void)
5779 {
5780   struct inode *ip, *dp;
5781   struct dirent de;
5782   char name[DIRSIZ], *path;
5783   uint off;
5784 
5785   if(argstr(0, &path) < 0)
5786     return -1;
5787 
5788   begin_op();
5789   if((dp = nameiparent(path, name)) == 0){
5790     end_op();
5791     return -1;
5792   }
5793 
5794   ilock(dp);
5795 
5796   // Cannot unlink "." or "..".
5797   if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
5798     goto bad;
5799 
5800   if((ip = dirlookup(dp, name, &off)) == 0)
5801     goto bad;
5802   ilock(ip);
5803 
5804   if(ip->nlink < 1)
5805     panic("unlink: nlink < 1");
5806   if(ip->type == T_DIR && !isdirempty(ip)){
5807     iunlockput(ip);
5808     goto bad;
5809   }
5810 
5811   memset(&de, 0, sizeof(de));
5812   if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
5813     panic("unlink: writei");
5814   if(ip->type == T_DIR){
5815     dp->nlink--;
5816     iupdate(dp);
5817   }
5818   iunlockput(dp);
5819 
5820   ip->nlink--;
5821   iupdate(ip);
5822   iunlockput(ip);
5823 
5824   end_op();
5825 
5826   return 0;
5827 
5828 bad:
5829   iunlockput(dp);
5830   end_op();
5831   return -1;
5832 }
5833 
5834 static struct inode*
5835 create(char *path, short type, short major, short minor)
5836 {
5837   uint off;
5838   struct inode *ip, *dp;
5839   char name[DIRSIZ];
5840 
5841   if((dp = nameiparent(path, name)) == 0)
5842     return 0;
5843   ilock(dp);
5844 
5845   if((ip = dirlookup(dp, name, &off)) != 0){
5846     iunlockput(dp);
5847     ilock(ip);
5848     if(type == T_FILE && ip->type == T_FILE)
5849       return ip;
5850     iunlockput(ip);
5851     return 0;
5852   }
5853 
5854   if((ip = ialloc(dp->dev, type)) == 0)
5855     panic("create: ialloc");
5856 
5857   ilock(ip);
5858   ip->major = major;
5859   ip->minor = minor;
5860   ip->nlink = 1;
5861   iupdate(ip);
5862 
5863   if(type == T_DIR){  // Create . and .. entries.
5864     dp->nlink++;  // for ".."
5865     iupdate(dp);
5866     // No ip->nlink++ for ".": avoid cyclic ref count.
5867     if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
5868       panic("create dots");
5869   }
5870 
5871   if(dirlink(dp, name, ip->inum) < 0)
5872     panic("create: dirlink");
5873 
5874   iunlockput(dp);
5875 
5876   return ip;
5877 }
5878 
5879 int
5880 sys_open(void)
5881 {
5882   char *path;
5883   int fd, omode;
5884   struct file *f;
5885   struct inode *ip;
5886 
5887   if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
5888     return -1;
5889 
5890   begin_op();
5891 
5892   if(omode & O_CREATE){
5893     ip = create(path, T_FILE, 0, 0);
5894     if(ip == 0){
5895       end_op();
5896       return -1;
5897     }
5898   } else {
5899     if((ip = namei(path)) == 0){
5900       end_op();
5901       return -1;
5902     }
5903     ilock(ip);
5904     if(ip->type == T_DIR && omode != O_RDONLY){
5905       iunlockput(ip);
5906       end_op();
5907       return -1;
5908     }
5909   }
5910 
5911   if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
5912     if(f)
5913       fileclose(f);
5914     iunlockput(ip);
5915     end_op();
5916     return -1;
5917   }
5918   iunlock(ip);
5919   end_op();
5920 
5921   f->type = FD_INODE;
5922   f->ip = ip;
5923   f->off = 0;
5924   f->readable = !(omode & O_WRONLY);
5925   f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
5926   return fd;
5927 }
5928 
5929 int
5930 sys_mkdir(void)
5931 {
5932   char *path;
5933   struct inode *ip;
5934 
5935   begin_op();
5936   if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
5937     end_op();
5938     return -1;
5939   }
5940   iunlockput(ip);
5941   end_op();
5942   return 0;
5943 }
5944 
5945 
5946 
5947 
5948 
5949 
5950 int
5951 sys_mknod(void)
5952 {
5953   struct inode *ip;
5954   char *path;
5955   int len;
5956   int major, minor;
5957 
5958   begin_op();
5959   if((len=argstr(0, &path)) < 0 ||
5960      argint(1, &major) < 0 ||
5961      argint(2, &minor) < 0 ||
5962      (ip = create(path, T_DEV, major, minor)) == 0){
5963     end_op();
5964     return -1;
5965   }
5966   iunlockput(ip);
5967   end_op();
5968   return 0;
5969 }
5970 
5971 int
5972 sys_chdir(void)
5973 {
5974   char *path;
5975   struct inode *ip;
5976 
5977   begin_op();
5978   if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
5979     end_op();
5980     return -1;
5981   }
5982   ilock(ip);
5983   if(ip->type != T_DIR){
5984     iunlockput(ip);
5985     end_op();
5986     return -1;
5987   }
5988   iunlock(ip);
5989   iput(proc->cwd);
5990   end_op();
5991   proc->cwd = ip;
5992   return 0;
5993 }
5994 
5995 
5996 
5997 
5998 
5999 
6000 int
6001 sys_exec(void)
6002 {
6003   char *path, *argv[MAXARG];
6004   int i;
6005   uint uargv, uarg;
6006 
6007   if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
6008     return -1;
6009   }
6010   memset(argv, 0, sizeof(argv));
6011   for(i=0;; i++){
6012     if(i >= NELEM(argv))
6013       return -1;
6014     if(fetchint(uargv+4*i, (int*)&uarg) < 0)
6015       return -1;
6016     if(uarg == 0){
6017       argv[i] = 0;
6018       break;
6019     }
6020     if(fetchstr(uarg, &argv[i]) < 0)
6021       return -1;
6022   }
6023   return exec(path, argv);
6024 }
6025 
6026 int
6027 sys_pipe(void)
6028 {
6029   int *fd;
6030   struct file *rf, *wf;
6031   int fd0, fd1;
6032 
6033   if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
6034     return -1;
6035   if(pipealloc(&rf, &wf) < 0)
6036     return -1;
6037   fd0 = -1;
6038   if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
6039     if(fd0 >= 0)
6040       proc->ofile[fd0] = 0;
6041     fileclose(rf);
6042     fileclose(wf);
6043     return -1;
6044   }
6045   fd[0] = fd0;
6046   fd[1] = fd1;
6047   return 0;
6048 }
6049 
