4350 struct file {
4351   enum { FD_NONE, FD_PIPE, FD_INODE } type;
4352   int ref; // reference count
4353   char readable;
4354   char writable;
4355   struct pipe *pipe;
4356   struct inode *ip;
4357   uint off;
4358 };
4359 
4360 
4361 // in-memory copy of an inode
4362 struct inode {
4363   uint dev;           // Device number
4364   uint inum;          // Inode number
4365   int ref;            // Reference count
4366   int flags;          // I_BUSY, I_VALID
4367 
4368   short type;         // copy of disk inode
4369   short major;
4370   short minor;
4371   short nlink;
4372   uint size;
4373   uint addrs[NDIRECT+1];
4374 };
4375 #define I_BUSY 0x1
4376 #define I_VALID 0x2
4377 
4378 // table mapping major device number to
4379 // device functions
4380 struct devsw {
4381   int (*read)(struct inode*, char*, int);
4382   int (*write)(struct inode*, char*, int);
4383 };
4384 
4385 extern struct devsw devsw[];
4386 
4387 #define CONSOLE 1
4388 
4389 // Blank page.
4390 
4391 
4392 
4393 
4394 
4395 
4396 
4397 
4398 
4399 
