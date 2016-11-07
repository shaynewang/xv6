9550 #include "types.h"
9551 #include "user.h"
9552 
9553 #ifdef CS333_P2
9554 int
9555 main(int argc, char *argv[])
9556 {
9557 	int elapsed_t = 0;
9558 	int pid;
9559 	int start_t = 0;
9560 	int end_t = start_t;
9561 	if(argc > 1) {
9562 		start_t = uptime();
9563 		pid = fork();
9564 		if(pid > 0) {
9565 			pid = wait();
9566 			end_t= uptime();
9567 			}
9568 		else if(pid == 0) {
9569 			//child process running
9570 			if(exec(argv[1], argv+1) < 0)
9571 				printf(2,"%s failed to execute.", argv[1]);
9572 			exit();
9573 			}
9574 		else {
9575 			// error: fork failed
9576 			printf(2,"Error: Fork failed");
9577 			exit();
9578 			}
9579 		}
9580 	elapsed_t = end_t - start_t;
9581 	char *proc_name = argv[1] ? argv[1] : "";
9582   printf(1,"%s ran in %d.%d seconds\n",proc_name, elapsed_t/100, elapsed_t%100);
9583 
9584   exit();
9585 }
9586 #else
9587 int
9588 main(int argc, char *argv[])
9589 {
9590 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9591 	exit();
9592 }
9593 #endif
9594 
9595 
9596 
9597 
9598 
9599 
