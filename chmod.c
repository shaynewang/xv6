#ifdef CS333_P4
#include "types.h"
#include "user.h"
#include "fs.h"
int
main(int argc, char *argv[])
{
	if(chmod(argv[1], argv[2]) < 0)
		printf(1,"\n chmod failed\n");
	exit();
}
#endif
