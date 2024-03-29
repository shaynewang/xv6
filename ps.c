#include "types.h"
#include "uproc.h"
#include "user.h"

#ifdef CS333_P2
int
main(int argc, char *argv[])
{
	int ptable_size;
	uint display_size;
	display_size = 64;
	struct uproc* ps;
	ps = malloc(sizeof(struct uproc) * display_size);
	ptable_size = getprocs(display_size, ps);
	if(ptable_size <= 0) {
		printf(1,"\nGetting processes information failed\n");
		exit();
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
#ifdef CS333_P3
	printf(1,"\nPID       State     Name      UID       GID       PPID    Priority    Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid,\
		ps->priority,\
		ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
	}
#else
	printf(1,"\nPID       State     Name      UID       GID       PPID      Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid,\
		ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
	}
#endif
	free(ps);
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
