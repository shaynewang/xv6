#define T_DIR  1   // Directory
#define T_FILE 2   // File
#define T_DEV  3   // Device

#ifdef CS333_P4
// Stat mode union has to match the mode_t union in fs.h
union stat_mode_t {
	struct {
		uint o_x	:	1;	
		uint o_w	:	1;	
		uint o_r	:	1;	// other
		uint g_x	:	1;	
		uint g_w	:	1;	
		uint g_r	:	1;	// group
		uint u_x	:	1;	
		uint u_w	:	1;	
		uint u_r	:	1;	// user
		uint setuid	:	1;
		uint	:	22;	// pad
	}	flags;
	uint asInt;
};
#endif

struct stat {
  short type;  // Type of file
  int dev;     // File system's disk device
  uint ino;    // Inode number
  short nlink; // Number of links to file
#ifdef CS333_P4
	short uid;						// owner id
	short gid;						// group id
	union stat_mode_t mode;    // protection/mode bits
#endif
  uint size;   // Size of file in bytes
};
