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
	int uid = atoi(argv[1]);
	if(uid < 0 || uid > 32767){
		printf(1,"\n chown failed\n");
		exit();
	}
	if(chown(atoi(argv[1]), argv[2]) < 0)
		printf(1,"\n chown failed\n");
	exit();
}
#endif
