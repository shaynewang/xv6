5900 //
5901 // File-system system calls.
5902 // Mostly argument checking, since we don't trust
5903 // user code, and calls into file.c and fs.c.
5904 //
5905 
5906 #include "types.h"
5907 #include "defs.h"
5908 #include "param.h"
5909 #include "stat.h"
5910 #include "mmu.h"
5911 #include "proc.h"
5912 #include "fs.h"
5913 #include "file.h"
5914 #include "fcntl.h"
5915 
5916 // Fetch the nth word-sized system call argument as a file descriptor
5917 // and return both the descriptor and the corresponding struct file.
5918 static int
5919 argfd(int n, int *pfd, struct file **pf)
5920 {
5921   int fd;
5922   struct file *f;
5923 
5924   if(argint(n, &fd) < 0)
5925     return -1;
5926   if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
5927     return -1;
5928   if(pfd)
5929     *pfd = fd;
5930   if(pf)
5931     *pf = f;
5932   return 0;
5933 }
5934 
5935 // Allocate a file descriptor for the given file.
5936 // Takes over file reference from caller on success.
5937 static int
5938 fdalloc(struct file *f)
5939 {
5940   int fd;
5941 
5942   for(fd = 0; fd < NOFILE; fd++){
5943     if(proc->ofile[fd] == 0){
5944       proc->ofile[fd] = f;
5945       return fd;
5946     }
5947   }
5948   return -1;
5949 }
5950 int
5951 sys_dup(void)
5952 {
5953   struct file *f;
5954   int fd;
5955 
5956   if(argfd(0, 0, &f) < 0)
5957     return -1;
5958   if((fd=fdalloc(f)) < 0)
5959     return -1;
5960   filedup(f);
5961   return fd;
5962 }
5963 
5964 int
5965 sys_read(void)
5966 {
5967   struct file *f;
5968   int n;
5969   char *p;
5970 
5971   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5972     return -1;
5973   return fileread(f, p, n);
5974 }
5975 
5976 int
5977 sys_write(void)
5978 {
5979   struct file *f;
5980   int n;
5981   char *p;
5982 
5983   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5984     return -1;
5985   return filewrite(f, p, n);
5986 }
5987 
5988 int
5989 sys_close(void)
5990 {
5991   int fd;
5992   struct file *f;
5993 
5994   if(argfd(0, &fd, &f) < 0)
5995     return -1;
5996   proc->ofile[fd] = 0;
5997   fileclose(f);
5998   return 0;
5999 }
6000 int
6001 sys_fstat(void)
6002 {
6003   struct file *f;
6004   struct stat *st;
6005 
6006   if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
6007     return -1;
6008   return filestat(f, st);
6009 }
6010 
6011 // Create the path new as a link to the same inode as old.
6012 int
6013 sys_link(void)
6014 {
6015   char name[DIRSIZ], *new, *old;
6016   struct inode *dp, *ip;
6017 
6018   if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
6019     return -1;
6020 
6021   begin_op();
6022   if((ip = namei(old)) == 0){
6023     end_op();
6024     return -1;
6025   }
6026 
6027   ilock(ip);
6028   if(ip->type == T_DIR){
6029     iunlockput(ip);
6030     end_op();
6031     return -1;
6032   }
6033 
6034   ip->nlink++;
6035   iupdate(ip);
6036   iunlock(ip);
6037 
6038   if((dp = nameiparent(new, name)) == 0)
6039     goto bad;
6040   ilock(dp);
6041   if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
6042     iunlockput(dp);
6043     goto bad;
6044   }
6045   iunlockput(dp);
6046   iput(ip);
6047 
6048   end_op();
6049 
6050   return 0;
6051 
6052 bad:
6053   ilock(ip);
6054   ip->nlink--;
6055   iupdate(ip);
6056   iunlockput(ip);
6057   end_op();
6058   return -1;
6059 }
6060 
6061 // Is the directory dp empty except for "." and ".." ?
6062 static int
6063 isdirempty(struct inode *dp)
6064 {
6065   int off;
6066   struct dirent de;
6067 
6068   for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
6069     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
6070       panic("isdirempty: readi");
6071     if(de.inum != 0)
6072       return 0;
6073   }
6074   return 1;
6075 }
6076 
6077 int
6078 sys_unlink(void)
6079 {
6080   struct inode *ip, *dp;
6081   struct dirent de;
6082   char name[DIRSIZ], *path;
6083   uint off;
6084 
6085   if(argstr(0, &path) < 0)
6086     return -1;
6087 
6088   begin_op();
6089   if((dp = nameiparent(path, name)) == 0){
6090     end_op();
6091     return -1;
6092   }
6093 
6094   ilock(dp);
6095 
6096   // Cannot unlink "." or "..".
6097   if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
6098     goto bad;
6099 
6100   if((ip = dirlookup(dp, name, &off)) == 0)
6101     goto bad;
6102   ilock(ip);
6103 
6104   if(ip->nlink < 1)
6105     panic("unlink: nlink < 1");
6106   if(ip->type == T_DIR && !isdirempty(ip)){
6107     iunlockput(ip);
6108     goto bad;
6109   }
6110 
6111   memset(&de, 0, sizeof(de));
6112   if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
6113     panic("unlink: writei");
6114   if(ip->type == T_DIR){
6115     dp->nlink--;
6116     iupdate(dp);
6117   }
6118   iunlockput(dp);
6119 
6120   ip->nlink--;
6121   iupdate(ip);
6122   iunlockput(ip);
6123 
6124   end_op();
6125 
6126   return 0;
6127 
6128 bad:
6129   iunlockput(dp);
6130   end_op();
6131   return -1;
6132 }
6133 
6134 static struct inode*
6135 create(char *path, short type, short major, short minor)
6136 {
6137   uint off;
6138   struct inode *ip, *dp;
6139   char name[DIRSIZ];
6140 
6141   if((dp = nameiparent(path, name)) == 0)
6142     return 0;
6143   ilock(dp);
6144 
6145   if((ip = dirlookup(dp, name, &off)) != 0){
6146     iunlockput(dp);
6147     ilock(ip);
6148     if(type == T_FILE && ip->type == T_FILE)
6149       return ip;
6150     iunlockput(ip);
6151     return 0;
6152   }
6153 
6154   if((ip = ialloc(dp->dev, type)) == 0)
6155     panic("create: ialloc");
6156 
6157   ilock(ip);
6158   ip->major = major;
6159   ip->minor = minor;
6160   ip->nlink = 1;
6161   iupdate(ip);
6162 
6163   if(type == T_DIR){  // Create . and .. entries.
6164     dp->nlink++;  // for ".."
6165     iupdate(dp);
6166     // No ip->nlink++ for ".": avoid cyclic ref count.
6167     if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
6168       panic("create dots");
6169   }
6170 
6171   if(dirlink(dp, name, ip->inum) < 0)
6172     panic("create: dirlink");
6173 
6174   iunlockput(dp);
6175 
6176   return ip;
6177 }
6178 
6179 int
6180 sys_open(void)
6181 {
6182   char *path;
6183   int fd, omode;
6184   struct file *f;
6185   struct inode *ip;
6186 
6187   if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
6188     return -1;
6189 
6190   begin_op();
6191 
6192   if(omode & O_CREATE){
6193     ip = create(path, T_FILE, 0, 0);
6194     if(ip == 0){
6195       end_op();
6196       return -1;
6197     }
6198   } else {
6199     if((ip = namei(path)) == 0){
6200       end_op();
6201       return -1;
6202     }
6203     ilock(ip);
6204     if(ip->type == T_DIR && omode != O_RDONLY){
6205       iunlockput(ip);
6206       end_op();
6207       return -1;
6208     }
6209   }
6210 
6211   if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
6212     if(f)
6213       fileclose(f);
6214     iunlockput(ip);
6215     end_op();
6216     return -1;
6217   }
6218   iunlock(ip);
6219   end_op();
6220 
6221   f->type = FD_INODE;
6222   f->ip = ip;
6223   f->off = 0;
6224   f->readable = !(omode & O_WRONLY);
6225   f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
6226   return fd;
6227 }
6228 
6229 int
6230 sys_mkdir(void)
6231 {
6232   char *path;
6233   struct inode *ip;
6234 
6235   begin_op();
6236   if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
6237     end_op();
6238     return -1;
6239   }
6240   iunlockput(ip);
6241   end_op();
6242   return 0;
6243 }
6244 
6245 
6246 
6247 
6248 
6249 
6250 int
6251 sys_mknod(void)
6252 {
6253   struct inode *ip;
6254   char *path;
6255   int len;
6256   int major, minor;
6257 
6258   begin_op();
6259   if((len=argstr(0, &path)) < 0 ||
6260      argint(1, &major) < 0 ||
6261      argint(2, &minor) < 0 ||
6262      (ip = create(path, T_DEV, major, minor)) == 0){
6263     end_op();
6264     return -1;
6265   }
6266   iunlockput(ip);
6267   end_op();
6268   return 0;
6269 }
6270 
6271 int
6272 sys_chdir(void)
6273 {
6274   char *path;
6275   struct inode *ip;
6276 
6277   begin_op();
6278   if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
6279     end_op();
6280     return -1;
6281   }
6282   ilock(ip);
6283   if(ip->type != T_DIR){
6284     iunlockput(ip);
6285     end_op();
6286     return -1;
6287   }
6288   iunlock(ip);
6289   iput(proc->cwd);
6290   end_op();
6291   proc->cwd = ip;
6292   return 0;
6293 }
6294 
6295 
6296 
6297 
6298 
6299 
6300 int
6301 sys_exec(void)
6302 {
6303   char *path, *argv[MAXARG];
6304   int i;
6305   uint uargv, uarg;
6306 
6307   if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
6308     return -1;
6309   }
6310   memset(argv, 0, sizeof(argv));
6311   for(i=0;; i++){
6312     if(i >= NELEM(argv))
6313       return -1;
6314     if(fetchint(uargv+4*i, (int*)&uarg) < 0)
6315       return -1;
6316     if(uarg == 0){
6317       argv[i] = 0;
6318       break;
6319     }
6320     if(fetchstr(uarg, &argv[i]) < 0)
6321       return -1;
6322   }
6323   return exec(path, argv);
6324 }
6325 
6326 int
6327 sys_pipe(void)
6328 {
6329   int *fd;
6330   struct file *rf, *wf;
6331   int fd0, fd1;
6332 
6333   if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
6334     return -1;
6335   if(pipealloc(&rf, &wf) < 0)
6336     return -1;
6337   fd0 = -1;
6338   if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
6339     if(fd0 >= 0)
6340       proc->ofile[fd0] = 0;
6341     fileclose(rf);
6342     fileclose(wf);
6343     return -1;
6344   }
6345   fd[0] = fd0;
6346   fd[1] = fd1;
6347   return 0;
6348 }
6349 
