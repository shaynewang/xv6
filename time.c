#include "types.h"
#include "user.h"

#ifdef CS333_P2
int
main(int argc, char *argv[])
{
	int start_t = uptime();
	int end_t = start_t;
	int elapsed_t = 0;
	int pid;
	if(argc > 1) {
		pid = fork();
		if(pid > 0) {
			pid = wait();
			end_t= uptime();
			}
		else if(pid == 0) {
			//child process running
			char **nargv = ++argv;
			exec(argv[1], nargv);
			exit();
			}
		else {
			// error
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
