#include "types.h"
#include "user.h"

// Test GID and UID to be in the correct range
#ifdef CS333_P2
int
testgiduid(void)
{
	uint uid, gid, ppid;

	uid = getuid();
	printf(2, "Current UID is : %d\n", uid);
	printf(2, "Setting UID to 100\n");
	setuid(100);
	uid = getuid();
	printf(2, "Current UID is : %d\n", uid);

	gid = getgid();
	printf(2, "Current GID is : %d\n", gid);
	printf(2, "Setting GID to 100\n");
	setgid(100);
	gid = getgid();
	printf(2, "Current UID is : %d\n", gid);

	ppid = getppid();
	printf(2, "My parent process is : %d\n", ppid);
	printf(2, "Done!\n");

	return 0;
}

int
main(int argc, char *argv[])
{
	testgiduid();
	exit();
}
#else
int
main(int argc, char *argv[])
{
	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
	exit();
}
#endif
