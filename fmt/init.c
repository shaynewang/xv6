8000 // init: The initial user-level program
8001 
8002 #include "types.h"
8003 #include "stat.h"
8004 #include "user.h"
8005 #include "fcntl.h"
8006 
8007 char *argv[] = { "sh", 0 };
8008 
8009 int
8010 main(void)
8011 {
8012   int pid, wpid;
8013 
8014   if(open("console", O_RDWR) < 0){
8015     mknod("console", 1, 1);
8016     open("console", O_RDWR);
8017   }
8018   dup(0);  // stdout
8019   dup(0);  // stderr
8020 
8021   for(;;){
8022     printf(1, "init: starting sh\n");
8023     pid = fork();
8024     if(pid < 0){
8025       printf(1, "init: fork failed\n");
8026       exit();
8027     }
8028     if(pid == 0){
8029       exec("sh", argv);
8030       printf(1, "init: exec sh failed\n");
8031       exit();
8032     }
8033     while((wpid=wait()) >= 0 && wpid != pid)
8034       printf(1, "zombie!\n");
8035   }
8036 }
8037 
8038 
8039 
8040 
8041 
8042 
8043 
8044 
8045 
8046 
8047 
8048 
8049 
