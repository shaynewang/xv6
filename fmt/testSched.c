9600 // This program can be freely used to test your scheduler. It is
9601 // by no means a complete test.
9602 
9603 #include "types.h"
9604 #include "user.h"
9605 
9606 // PrioCount should be set to the nummber of priority levels
9607 #define PrioCount 3
9608 #define numChildren 10
9609 
9610 void
9611 countForever(int p)
9612 {
9613   int j;
9614   unsigned long count = 0;
9615 
9616   j = getpid();
9617   p = p%PrioCount;
9618   setpriority(j, p);
9619   printf(1, "%d: start prio %d\n", j, p);
9620 
9621   while (1) {
9622     count++;
9623     if ((count & 0xFFFFFFF) == 0) {
9624       p = (p+1) % PrioCount;
9625       setpriority(j, p);
9626       printf(1, "%d: new prio %d\n", j, p);
9627     }
9628   }
9629 }
9630 
9631 int
9632 main(void)
9633 {
9634   int i, rc;
9635 
9636   for (i=0; i<numChildren; i++) {
9637     rc = fork();
9638     if (!rc) { // child
9639       countForever(i);
9640     }
9641   }
9642   // what the heck, let's have the parent waste time as well!
9643   countForever(1);
9644   exit();
9645 }
9646 
9647 
9648 
9649 
