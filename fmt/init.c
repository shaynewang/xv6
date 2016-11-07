8300 // init: The initial user-level program
8301 
8302 #include "types.h"
8303 #include "stat.h"
8304 #include "user.h"
8305 #include "fcntl.h"
8306 
8307 char *argv[] = { "sh", 0 };
8308 
8309 int
8310 main(void)
8311 {
8312   int pid, wpid;
8313 
8314   if(open("console", O_RDWR) < 0){
8315     mknod("console", 1, 1);
8316     open("console", O_RDWR);
8317   }
8318   dup(0);  // stdout
8319   dup(0);  // stderr
8320 
8321   for(;;){
8322     printf(1, "init: starting sh\n");
8323     pid = fork();
8324     if(pid < 0){
8325       printf(1, "init: fork failed\n");
8326       exit();
8327     }
8328     if(pid == 0){
8329       exec("sh", argv);
8330       printf(1, "init: exec sh failed\n");
8331       exit();
8332     }
8333     while((wpid=wait()) >= 0 && wpid != pid)
8334       printf(1, "zombie!\n");
8335   }
8336 }
8337 
8338 
8339 
8340 
8341 
8342 
8343 
8344 
8345 
8346 
8347 
8348 
8349 
