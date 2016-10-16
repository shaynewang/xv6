9000 #include "types.h"
9001 #include "user.h"
9002 #include "date.h"
9003 
9004 
9005 int
9006 main(int argc, char *argv[])
9007 {
9008   struct rtcdate r;
9009   if(date(&r)) {
9010     printf(2,"date failed\n");
9011     exit();
9012   }
9013   printf(1, "Current UTC time is: %d/%d/%d - %d:%d:%d\n",r.year, r.month, r.day, r.hour, r.minute, r.second);
9014 
9015   exit();
9016 }
9017 
9018 
9019 
9020 
9021 
9022 
9023 
9024 
9025 
9026 
9027 
9028 
9029 
9030 
9031 
9032 
9033 
9034 
9035 
9036 
9037 
9038 
9039 
9040 
9041 
9042 
9043 
9044 
9045 
9046 
9047 
9048 
9049 
