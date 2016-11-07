9450 #include "types.h"
9451 #include "uproc.h"
9452 #include "user.h"
9453 
9454 #ifdef CS333_P2
9455 int
9456 main(int argc, char *argv[])
9457 {
9458 	int ptable_size;
9459 	uint display_size;
9460 	display_size = 64;
9461 	struct uproc* ps;
9462 	ps = malloc(sizeof(struct uproc) * display_size);
9463 	ptable_size = getprocs(display_size, ps);
9464 	if(ptable_size <= 0) {
9465 		printf(1,"\nGetting processes information failed\n");
9466 		exit();
9467 	}
9468 	printf(1,"\nNumber of processes is :%d\n",ptable_size);
9469 #ifdef CS333_P3
9470 	printf(1,"\nPID       State     Name      UID       GID       PPID    Priority    Elapsed   CPU       Size\n");
9471 	int i;
9472 	for(i=0; i < ptable_size; ++i){
9473     printf(1,"\n%d         %s    %s    %d    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
9474 		ps->state,\
9475 		ps->name,\
9476 		ps->uid,\
9477 		ps->gid,\
9478 		ps->ppid,\
9479 		ps->priority,\
9480 		ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
9481 		++ps;
9482 	}
9483 #else
9484 	printf(1,"\nPID       State     Name      UID       GID       PPID      Elapsed   CPU       Size\n");
9485 	int i;
9486 	for(i=0; i < ptable_size; ++i){
9487     printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
9488 		ps->state,\
9489 		ps->name,\
9490 		ps->uid,\
9491 		ps->gid,\
9492 		ps->ppid,\
9493 		ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
9494 		++ps;
9495 	}
9496 #endif
9497 	free(ps);
9498   exit();
9499 }
9500 #else
9501 int
9502 main(int argc, char *argv[])
9503 {
9504 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9505 	exit();
9506 }
9507 #endif
9508 
9509 
9510 
9511 
9512 
9513 
9514 
9515 
9516 
9517 
9518 
9519 
9520 
9521 
9522 
9523 
9524 
9525 
9526 
9527 
9528 
9529 
9530 
9531 
9532 
9533 
9534 
9535 
9536 
9537 
9538 
9539 
9540 
9541 
9542 
9543 
9544 
9545 
9546 
9547 
9548 
9549 
