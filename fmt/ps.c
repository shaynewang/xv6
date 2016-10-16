9150 #include "types.h"
9151 #include "uproc.h"
9152 #include "user.h"
9153 
9154 #ifdef CS333_P2
9155 int
9156 main(int argc, char *argv[])
9157 {
9158 	int ptable_size;
9159 	uint display_size;
9160 	display_size = 64;
9161 	struct uproc* ps;
9162 	ps = malloc(sizeof(struct uproc) * display_size);
9163 	ptable_size = getprocs(display_size, ps);
9164 	if(ptable_size <= 0) {
9165 		printf(1,"\nGetting processes information failed\n");
9166 		exit();
9167 	}
9168 	printf(1,"\nNumber of processes is :%d\n",ptable_size);
9169 	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
9170 	int i;
9171 	for(i=0; i < ptable_size; ++i){
9172     printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
9173 		ps->state,\
9174 		ps->name,\
9175 		ps->uid,\
9176 		ps->gid,\
9177 		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
9178 		++ps;
9179 	}
9180   exit();
9181 }
9182 #else
9183 int
9184 main(int argc, char *argv[])
9185 {
9186 	printf(2, "Please compile with CS333_P2 on to enable this feature.\n");
9187 	exit();
9188 }
9189 #endif
9190 
9191 
9192 
9193 
9194 
9195 
9196 
9197 
9198 
9199 
