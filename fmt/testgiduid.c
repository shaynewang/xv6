9400 #include "types.h"
9401 #include "user.h"
9402 
9403 // Test GID and UID to be in the correct range
9404 #ifdef CS333_P2
9405 int
9406 testgiduid(void)
9407 {
9408 	uint uid, gid, ppid;
9409 
9410 	uid = getuid();
9411 	printf(2, "Current UID is : %d\n", uid);
9412 	printf(2, "Setting UID to 100\n");
9413 	setuid(100);
9414 	uid = getuid();
9415 	printf(2, "Current UID is : %d\n", uid);
9416 
9417 	gid = getgid();
9418 	printf(2, "Current GID is : %d\n", gid);
9419 	printf(2, "Setting GID to 100\n");
9420 	setgid(100);
9421 	gid = getgid();
9422 	printf(2, "Current UID is : %d\n", gid);
9423 
9424 	ppid = getppid();
9425 	printf(2, "My parent process is : %d\n", ppid);
9426 	printf(2, "Done!\n");
9427 
9428 	return 0;
9429 }
9430 
9431 int
9432 main(int argc, char *argv[])
9433 {
9434 	testgiduid();
9435 	exit();
9436 }
9437 #else
9438 int
9439 main(int argc, char *argv[])
9440 {
9441 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9442 	exit();
9443 }
9444 #endif
9445 
9446 
9447 
9448 
9449 
