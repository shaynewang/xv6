#ifdef CS333_P4
#include "types.h"
#include "user.h"
#include "fs.h"
int
main(int argc, char *argv[])
{
	if(argv[1][0] == '-'){ // negative input
		printf(1,"\n chown failed\n");
		exit();
	}
	int gid = atoi(argv[1]);
	if(gid < 0 || gid > 32767){
		printf(1,"\n chgrp failed\n");
		exit();
	}
	if(chgrp(atoi(argv[1]), argv[2]) < 0)
		printf(1,"\n chgrp failed\n");
	exit();
}
#endif
