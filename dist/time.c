#include "types.h"
#include "user.h"

#ifdef CS333_P2
int
main(int argc, char *argv[])
{
	int elapsed_t = 0;
	int pid;
	int start_t = 0;
	int end_t = start_t;
	if(argc > 1) {
		start_t = uptime();
		pid = fork();
		if(pid > 0) {
			pid = wait();
			end_t= uptime();
			}
		else if(pid == 0) {
			//child process running
			if(exec(argv[1], argv+1) < 0)
				printf(2,"%s failed to execute.", argv[1]);
			exit();
			}
		else {
			// error: fork failed
			printf(2,"Error: Fork failed");
			exit();
			}
		}
	elapsed_t = end_t - start_t;
	char *proc_name = argv[1] ? argv[1] : "";
  printf(1,"%s ran in %d.%d seconds\n",proc_name, elapsed_t/100, elapsed_t%100);

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
