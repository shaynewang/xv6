9200 #include "types.h"
9201 #include "user.h"
9202 
9203 #ifdef CS333_P2
9204 int
9205 main(int argc, char *argv[])
9206 {
9207 	int elapsed_t = 0;
9208 	int pid;
9209 	int start_t = uptime();
9210 	int end_t = start_t;
9211 	if(argc > 1) {
9212 		pid = fork();
9213 		if(pid > 0) {
9214 			pid = wait();
9215 			end_t= uptime();
9216 			}
9217 		else if(pid == 0) {
9218 			//child process running
9219 			char **nargv = ++argv;
9220 			exec(argv[0], nargv);
9221 			exit();
9222 			}
9223 		else {
9224 			// error
9225 			exit();
9226 			}
9227 		}
9228 	elapsed_t = end_t - start_t;
9229 	char *proc_name = argv[1] ? argv[1] : "";
9230   printf(1,"%s ran in %d.%d seconds\n",proc_name, elapsed_t/100, elapsed_t%100);
9231 
9232   exit();
9233 }
9234 #else
9235 int
9236 main(int argc, char *argv[])
9237 {
9238 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9239 	exit();
9240 }
9241 #endif
9242 
9243 
9244 
9245 
9246 
9247 
9248 
9249 
