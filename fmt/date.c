9300 #include "types.h"
9301 #include "user.h"
9302 #include "date.h"
9303 
9304 
9305 int
9306 main(int argc, char *argv[])
9307 {
9308   struct rtcdate r;
9309   if(date(&r)) {
9310     printf(2,"date failed\n");
9311     exit();
9312   }
9313   printf(1, "Current UTC time is: %d/%d/%d - %d:%d:%d\n",r.year, r.month, r.day, r.hour, r.minute, r.second);
9314 
9315   exit();
9316 }
9317 
9318 
9319 
9320 
9321 
9322 
9323 
9324 
9325 
9326 
9327 
9328 
9329 
9330 
9331 
9332 
9333 
9334 
9335 
9336 
9337 
9338 
9339 
9340 
9341 
9342 
9343 
9344 
9345 
9346 
9347 
9348 
9349 
