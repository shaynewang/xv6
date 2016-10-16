9100 #include "types.h"
9101 #include "user.h"
9102 
9103 // Test GID and UID to be in the correct range
9104 #ifdef CS333_P2
9105 int
9106 testgiduid(void)
9107 {
9108 	uint uid, gid, ppid;
9109 
9110 	uid = getuid();
9111 	printf(2, "Current UID is : %d\n", uid);
9112 	printf(2, "Setting UID to 100\n");
9113 	setuid(100);
9114 	uid = getuid();
9115 	printf(2, "Current UID is : %d\n", uid);
9116 
9117 	gid = getgid();
9118 	printf(2, "Current GID is : %d\n", gid);
9119 	printf(2, "Setting GID to 100\n");
9120 	setgid(100);
9121 	gid = getgid();
9122 	printf(2, "Current UID is : %d\n", gid);
9123 
9124 	ppid = getppid();
9125 	printf(2, "My parent process is : %d\n", ppid);
9126 	printf(2, "Done!\n");
9127 
9128 	return 0;
9129 }
9130 
9131 int
9132 main(int argc, char *argv[])
9133 {
9134 	testgiduid();
9135 	exit();
9136 }
9137 #else
9138 int
9139 main(int argc, char *argv[])
9140 {
9141 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9142 	exit();
9143 }
9144 #endif
9145 
9146 
9147 
9148 
9149 
