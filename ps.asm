
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"

#ifdef CS333_P2
int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 60             	sub    $0x60,%esp
	int ptable_size;
	uint display_size;
	display_size = 64;
   c:	c7 44 24 54 40 00 00 	movl   $0x40,0x54(%esp)
  13:	00 
	struct uproc* ps;
	ps = malloc(sizeof(struct uproc) * display_size);
  14:	8b 44 24 54          	mov    0x54(%esp),%eax
  18:	6b c0 5c             	imul   $0x5c,%eax,%eax
  1b:	89 04 24             	mov    %eax,(%esp)
  1e:	e8 aa 08 00 00       	call   8cd <malloc>
  23:	89 44 24 5c          	mov    %eax,0x5c(%esp)
	ptable_size = getprocs(display_size, ps);
  27:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  2f:	8b 44 24 54          	mov    0x54(%esp),%eax
  33:	89 04 24             	mov    %eax,(%esp)
  36:	e8 be 04 00 00       	call   4f9 <getprocs>
  3b:	89 44 24 50          	mov    %eax,0x50(%esp)
	if(ptable_size <= 0) {
  3f:	83 7c 24 50 00       	cmpl   $0x0,0x50(%esp)
  44:	7f 19                	jg     5f <main+0x5f>
		printf(1,"\nGetting processes information failed\n");
  46:	c7 44 24 04 b0 09 00 	movl   $0x9b0,0x4(%esp)
  4d:	00 
  4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  55:	e8 87 05 00 00       	call   5e1 <printf>
		exit();
  5a:	e8 c2 03 00 00       	call   421 <exit>
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
  5f:	8b 44 24 50          	mov    0x50(%esp),%eax
  63:	89 44 24 08          	mov    %eax,0x8(%esp)
  67:	c7 44 24 04 d7 09 00 	movl   $0x9d7,0x4(%esp)
  6e:	00 
  6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  76:	e8 66 05 00 00       	call   5e1 <printf>
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
  7b:	c7 44 24 04 f4 09 00 	movl   $0x9f4,0x4(%esp)
  82:	00 
  83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8a:	e8 52 05 00 00       	call   5e1 <printf>
	int i;
	for(i=0; i < ptable_size; ++i){
  8f:	c7 44 24 58 00 00 00 	movl   $0x0,0x58(%esp)
  96:	00 
  97:	e9 fe 00 00 00       	jmp    19a <main+0x19a>
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  9c:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  a0:	8b 78 38             	mov    0x38(%eax),%edi
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  a3:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  a7:	8b 48 14             	mov    0x14(%eax),%ecx
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  aa:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  af:	89 c8                	mov    %ecx,%eax
  b1:	f7 e2                	mul    %edx
  b3:	89 d3                	mov    %edx,%ebx
  b5:	c1 eb 05             	shr    $0x5,%ebx
  b8:	6b c3 64             	imul   $0x64,%ebx,%eax
  bb:	89 cb                	mov    %ecx,%ebx
  bd:	29 c3                	sub    %eax,%ebx
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  bf:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  c3:	8b 40 14             	mov    0x14(%eax),%eax
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  c6:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  cb:	f7 e2                	mul    %edx
  cd:	c1 ea 05             	shr    $0x5,%edx
  d0:	89 54 24 4c          	mov    %edx,0x4c(%esp)
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  d4:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  d8:	8b 48 10             	mov    0x10(%eax),%ecx
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  db:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  e0:	89 c8                	mov    %ecx,%eax
  e2:	f7 e2                	mul    %edx
  e4:	89 d6                	mov    %edx,%esi
  e6:	c1 ee 05             	shr    $0x5,%esi
  e9:	6b c6 64             	imul   $0x64,%esi,%eax
  ec:	89 ce                	mov    %ecx,%esi
  ee:	29 c6                	sub    %eax,%esi
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  f0:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  f4:	8b 40 10             	mov    0x10(%eax),%eax
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  f7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  fc:	f7 e2                	mul    %edx
  fe:	89 d0                	mov    %edx,%eax
 100:	c1 e8 05             	shr    $0x5,%eax
 103:	89 44 24 48          	mov    %eax,0x48(%esp)
 107:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 10b:	8b 48 0c             	mov    0xc(%eax),%ecx
 10e:	89 4c 24 44          	mov    %ecx,0x44(%esp)
 112:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 116:	8b 40 08             	mov    0x8(%eax),%eax
 119:	89 44 24 40          	mov    %eax,0x40(%esp)
 11d:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 121:	8b 48 04             	mov    0x4(%eax),%ecx
 124:	89 4c 24 3c          	mov    %ecx,0x3c(%esp)
		ps->state,\
		ps->name,\
 128:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 12c:	8d 48 3c             	lea    0x3c(%eax),%ecx
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
		ps->state,\
 12f:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 133:	8d 50 18             	lea    0x18(%eax),%edx
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
 136:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 13a:	8b 00                	mov    (%eax),%eax
 13c:	89 7c 24 30          	mov    %edi,0x30(%esp)
 140:	89 5c 24 2c          	mov    %ebx,0x2c(%esp)
 144:	8b 7c 24 4c          	mov    0x4c(%esp),%edi
 148:	89 7c 24 28          	mov    %edi,0x28(%esp)
 14c:	89 74 24 24          	mov    %esi,0x24(%esp)
 150:	8b 7c 24 48          	mov    0x48(%esp),%edi
 154:	89 7c 24 20          	mov    %edi,0x20(%esp)
 158:	8b 7c 24 44          	mov    0x44(%esp),%edi
 15c:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
 160:	8b 7c 24 40          	mov    0x40(%esp),%edi
 164:	89 7c 24 18          	mov    %edi,0x18(%esp)
 168:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
 16c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 170:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 174:	89 54 24 0c          	mov    %edx,0xc(%esp)
 178:	89 44 24 08          	mov    %eax,0x8(%esp)
 17c:	c7 44 24 04 4c 0a 00 	movl   $0xa4c,0x4(%esp)
 183:	00 
 184:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18b:	e8 51 04 00 00       	call   5e1 <printf>
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
 190:	83 44 24 5c 5c       	addl   $0x5c,0x5c(%esp)
		exit();
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
 195:	83 44 24 58 01       	addl   $0x1,0x58(%esp)
 19a:	8b 44 24 58          	mov    0x58(%esp),%eax
 19e:	3b 44 24 50          	cmp    0x50(%esp),%eax
 1a2:	0f 8c f4 fe ff ff    	jl     9c <main+0x9c>
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
	}
	free(ps);
 1a8:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 1ac:	89 04 24             	mov    %eax,(%esp)
 1af:	e8 e0 05 00 00       	call   794 <free>
  exit();
 1b4:	e8 68 02 00 00       	call   421 <exit>

000001b9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	57                   	push   %edi
 1bd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1be:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c1:	8b 55 10             	mov    0x10(%ebp),%edx
 1c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c7:	89 cb                	mov    %ecx,%ebx
 1c9:	89 df                	mov    %ebx,%edi
 1cb:	89 d1                	mov    %edx,%ecx
 1cd:	fc                   	cld    
 1ce:	f3 aa                	rep stos %al,%es:(%edi)
 1d0:	89 ca                	mov    %ecx,%edx
 1d2:	89 fb                	mov    %edi,%ebx
 1d4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1da:	5b                   	pop    %ebx
 1db:	5f                   	pop    %edi
 1dc:	5d                   	pop    %ebp
 1dd:	c3                   	ret    

000001de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1de:	55                   	push   %ebp
 1df:	89 e5                	mov    %esp,%ebp
 1e1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1ea:	90                   	nop
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	8d 50 01             	lea    0x1(%eax),%edx
 1f1:	89 55 08             	mov    %edx,0x8(%ebp)
 1f4:	8b 55 0c             	mov    0xc(%ebp),%edx
 1f7:	8d 4a 01             	lea    0x1(%edx),%ecx
 1fa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1fd:	0f b6 12             	movzbl (%edx),%edx
 200:	88 10                	mov    %dl,(%eax)
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	84 c0                	test   %al,%al
 207:	75 e2                	jne    1eb <strcpy+0xd>
    ;
  return os;
 209:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 211:	eb 08                	jmp    21b <strcmp+0xd>
    p++, q++;
 213:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 217:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	74 10                	je     235 <strcmp+0x27>
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	0f b6 10             	movzbl (%eax),%edx
 22b:	8b 45 0c             	mov    0xc(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	38 c2                	cmp    %al,%dl
 233:	74 de                	je     213 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	0f b6 00             	movzbl (%eax),%eax
 23b:	0f b6 d0             	movzbl %al,%edx
 23e:	8b 45 0c             	mov    0xc(%ebp),%eax
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	0f b6 c0             	movzbl %al,%eax
 247:	29 c2                	sub    %eax,%edx
 249:	89 d0                	mov    %edx,%eax
}
 24b:	5d                   	pop    %ebp
 24c:	c3                   	ret    

0000024d <strlen>:

uint
strlen(char *s)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
 250:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 253:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25a:	eb 04                	jmp    260 <strlen+0x13>
 25c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 260:	8b 55 fc             	mov    -0x4(%ebp),%edx
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	01 d0                	add    %edx,%eax
 268:	0f b6 00             	movzbl (%eax),%eax
 26b:	84 c0                	test   %al,%al
 26d:	75 ed                	jne    25c <strlen+0xf>
    ;
  return n;
 26f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 272:	c9                   	leave  
 273:	c3                   	ret    

00000274 <memset>:

void*
memset(void *dst, int c, uint n)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 27a:	8b 45 10             	mov    0x10(%ebp),%eax
 27d:	89 44 24 08          	mov    %eax,0x8(%esp)
 281:	8b 45 0c             	mov    0xc(%ebp),%eax
 284:	89 44 24 04          	mov    %eax,0x4(%esp)
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	89 04 24             	mov    %eax,(%esp)
 28e:	e8 26 ff ff ff       	call   1b9 <stosb>
  return dst;
 293:	8b 45 08             	mov    0x8(%ebp),%eax
}
 296:	c9                   	leave  
 297:	c3                   	ret    

00000298 <strchr>:

char*
strchr(const char *s, char c)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	83 ec 04             	sub    $0x4,%esp
 29e:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2a4:	eb 14                	jmp    2ba <strchr+0x22>
    if(*s == c)
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2af:	75 05                	jne    2b6 <strchr+0x1e>
      return (char*)s;
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	eb 13                	jmp    2c9 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	0f b6 00             	movzbl (%eax),%eax
 2c0:	84 c0                	test   %al,%al
 2c2:	75 e2                	jne    2a6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c9:	c9                   	leave  
 2ca:	c3                   	ret    

000002cb <gets>:

char*
gets(char *buf, int max)
{
 2cb:	55                   	push   %ebp
 2cc:	89 e5                	mov    %esp,%ebp
 2ce:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d8:	eb 4c                	jmp    326 <gets+0x5b>
    cc = read(0, &c, 1);
 2da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e1:	00 
 2e2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2f0:	e8 44 01 00 00       	call   439 <read>
 2f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2fc:	7f 02                	jg     300 <gets+0x35>
      break;
 2fe:	eb 31                	jmp    331 <gets+0x66>
    buf[i++] = c;
 300:	8b 45 f4             	mov    -0xc(%ebp),%eax
 303:	8d 50 01             	lea    0x1(%eax),%edx
 306:	89 55 f4             	mov    %edx,-0xc(%ebp)
 309:	89 c2                	mov    %eax,%edx
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	01 c2                	add    %eax,%edx
 310:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 314:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 316:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 31a:	3c 0a                	cmp    $0xa,%al
 31c:	74 13                	je     331 <gets+0x66>
 31e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 322:	3c 0d                	cmp    $0xd,%al
 324:	74 0b                	je     331 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 326:	8b 45 f4             	mov    -0xc(%ebp),%eax
 329:	83 c0 01             	add    $0x1,%eax
 32c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 32f:	7c a9                	jl     2da <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 331:	8b 55 f4             	mov    -0xc(%ebp),%edx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	01 d0                	add    %edx,%eax
 339:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <stat>:

int
stat(char *n, struct stat *st)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 347:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 34e:	00 
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	89 04 24             	mov    %eax,(%esp)
 355:	e8 07 01 00 00       	call   461 <open>
 35a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 35d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 361:	79 07                	jns    36a <stat+0x29>
    return -1;
 363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 368:	eb 23                	jmp    38d <stat+0x4c>
  r = fstat(fd, st);
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	89 44 24 04          	mov    %eax,0x4(%esp)
 371:	8b 45 f4             	mov    -0xc(%ebp),%eax
 374:	89 04 24             	mov    %eax,(%esp)
 377:	e8 fd 00 00 00       	call   479 <fstat>
 37c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 37f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 382:	89 04 24             	mov    %eax,(%esp)
 385:	e8 bf 00 00 00       	call   449 <close>
  return r;
 38a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 38d:	c9                   	leave  
 38e:	c3                   	ret    

0000038f <atoi>:

int
atoi(const char *s)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 395:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 39c:	eb 25                	jmp    3c3 <atoi+0x34>
    n = n*10 + *s++ - '0';
 39e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a1:	89 d0                	mov    %edx,%eax
 3a3:	c1 e0 02             	shl    $0x2,%eax
 3a6:	01 d0                	add    %edx,%eax
 3a8:	01 c0                	add    %eax,%eax
 3aa:	89 c1                	mov    %eax,%ecx
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	8d 50 01             	lea    0x1(%eax),%edx
 3b2:	89 55 08             	mov    %edx,0x8(%ebp)
 3b5:	0f b6 00             	movzbl (%eax),%eax
 3b8:	0f be c0             	movsbl %al,%eax
 3bb:	01 c8                	add    %ecx,%eax
 3bd:	83 e8 30             	sub    $0x30,%eax
 3c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	0f b6 00             	movzbl (%eax),%eax
 3c9:	3c 2f                	cmp    $0x2f,%al
 3cb:	7e 0a                	jle    3d7 <atoi+0x48>
 3cd:	8b 45 08             	mov    0x8(%ebp),%eax
 3d0:	0f b6 00             	movzbl (%eax),%eax
 3d3:	3c 39                	cmp    $0x39,%al
 3d5:	7e c7                	jle    39e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3da:	c9                   	leave  
 3db:	c3                   	ret    

000003dc <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3dc:	55                   	push   %ebp
 3dd:	89 e5                	mov    %esp,%ebp
 3df:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3ee:	eb 17                	jmp    407 <memmove+0x2b>
    *dst++ = *src++;
 3f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3f3:	8d 50 01             	lea    0x1(%eax),%edx
 3f6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3f9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3fc:	8d 4a 01             	lea    0x1(%edx),%ecx
 3ff:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 402:	0f b6 12             	movzbl (%edx),%edx
 405:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 407:	8b 45 10             	mov    0x10(%ebp),%eax
 40a:	8d 50 ff             	lea    -0x1(%eax),%edx
 40d:	89 55 10             	mov    %edx,0x10(%ebp)
 410:	85 c0                	test   %eax,%eax
 412:	7f dc                	jg     3f0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 414:	8b 45 08             	mov    0x8(%ebp),%eax
}
 417:	c9                   	leave  
 418:	c3                   	ret    

00000419 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 419:	b8 01 00 00 00       	mov    $0x1,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <exit>:
SYSCALL(exit)
 421:	b8 02 00 00 00       	mov    $0x2,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <wait>:
SYSCALL(wait)
 429:	b8 03 00 00 00       	mov    $0x3,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <pipe>:
SYSCALL(pipe)
 431:	b8 04 00 00 00       	mov    $0x4,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <read>:
SYSCALL(read)
 439:	b8 05 00 00 00       	mov    $0x5,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <write>:
SYSCALL(write)
 441:	b8 10 00 00 00       	mov    $0x10,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <close>:
SYSCALL(close)
 449:	b8 15 00 00 00       	mov    $0x15,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <kill>:
SYSCALL(kill)
 451:	b8 06 00 00 00       	mov    $0x6,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <exec>:
SYSCALL(exec)
 459:	b8 07 00 00 00       	mov    $0x7,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <open>:
SYSCALL(open)
 461:	b8 0f 00 00 00       	mov    $0xf,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <mknod>:
SYSCALL(mknod)
 469:	b8 11 00 00 00       	mov    $0x11,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <unlink>:
SYSCALL(unlink)
 471:	b8 12 00 00 00       	mov    $0x12,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <fstat>:
SYSCALL(fstat)
 479:	b8 08 00 00 00       	mov    $0x8,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret    

00000481 <link>:
SYSCALL(link)
 481:	b8 13 00 00 00       	mov    $0x13,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret    

00000489 <mkdir>:
SYSCALL(mkdir)
 489:	b8 14 00 00 00       	mov    $0x14,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret    

00000491 <chdir>:
SYSCALL(chdir)
 491:	b8 09 00 00 00       	mov    $0x9,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	ret    

00000499 <dup>:
SYSCALL(dup)
 499:	b8 0a 00 00 00       	mov    $0xa,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	ret    

000004a1 <getpid>:
SYSCALL(getpid)
 4a1:	b8 0b 00 00 00       	mov    $0xb,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	ret    

000004a9 <sbrk>:
SYSCALL(sbrk)
 4a9:	b8 0c 00 00 00       	mov    $0xc,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	ret    

000004b1 <sleep>:
SYSCALL(sleep)
 4b1:	b8 0d 00 00 00       	mov    $0xd,%eax
 4b6:	cd 40                	int    $0x40
 4b8:	c3                   	ret    

000004b9 <uptime>:
SYSCALL(uptime)
 4b9:	b8 0e 00 00 00       	mov    $0xe,%eax
 4be:	cd 40                	int    $0x40
 4c0:	c3                   	ret    

000004c1 <halt>:
SYSCALL(halt)
 4c1:	b8 16 00 00 00       	mov    $0x16,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	ret    

000004c9 <date>:
SYSCALL(date)
 4c9:	b8 17 00 00 00       	mov    $0x17,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <getuid>:
SYSCALL(getuid)
 4d1:	b8 18 00 00 00       	mov    $0x18,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <getgid>:
SYSCALL(getgid)
 4d9:	b8 19 00 00 00       	mov    $0x19,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <getppid>:
SYSCALL(getppid)
 4e1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <setuid>:
SYSCALL(setuid)
 4e9:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <setgid>:
SYSCALL(setgid)
 4f1:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <getprocs>:
SYSCALL(getprocs)
 4f9:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 501:	55                   	push   %ebp
 502:	89 e5                	mov    %esp,%ebp
 504:	83 ec 18             	sub    $0x18,%esp
 507:	8b 45 0c             	mov    0xc(%ebp),%eax
 50a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 50d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 514:	00 
 515:	8d 45 f4             	lea    -0xc(%ebp),%eax
 518:	89 44 24 04          	mov    %eax,0x4(%esp)
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	89 04 24             	mov    %eax,(%esp)
 522:	e8 1a ff ff ff       	call   441 <write>
}
 527:	c9                   	leave  
 528:	c3                   	ret    

00000529 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	56                   	push   %esi
 52d:	53                   	push   %ebx
 52e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 531:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 538:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 53c:	74 17                	je     555 <printint+0x2c>
 53e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 542:	79 11                	jns    555 <printint+0x2c>
    neg = 1;
 544:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	f7 d8                	neg    %eax
 550:	89 45 ec             	mov    %eax,-0x14(%ebp)
 553:	eb 06                	jmp    55b <printint+0x32>
  } else {
    x = xx;
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 55b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 562:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 565:	8d 41 01             	lea    0x1(%ecx),%eax
 568:	89 45 f4             	mov    %eax,-0xc(%ebp)
 56b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 56e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 571:	ba 00 00 00 00       	mov    $0x0,%edx
 576:	f7 f3                	div    %ebx
 578:	89 d0                	mov    %edx,%eax
 57a:	0f b6 80 dc 0c 00 00 	movzbl 0xcdc(%eax),%eax
 581:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 585:	8b 75 10             	mov    0x10(%ebp),%esi
 588:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58b:	ba 00 00 00 00       	mov    $0x0,%edx
 590:	f7 f6                	div    %esi
 592:	89 45 ec             	mov    %eax,-0x14(%ebp)
 595:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 599:	75 c7                	jne    562 <printint+0x39>
  if(neg)
 59b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 59f:	74 10                	je     5b1 <printint+0x88>
    buf[i++] = '-';
 5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a4:	8d 50 01             	lea    0x1(%eax),%edx
 5a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5aa:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5af:	eb 1f                	jmp    5d0 <printint+0xa7>
 5b1:	eb 1d                	jmp    5d0 <printint+0xa7>
    putc(fd, buf[i]);
 5b3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b9:	01 d0                	add    %edx,%eax
 5bb:	0f b6 00             	movzbl (%eax),%eax
 5be:	0f be c0             	movsbl %al,%eax
 5c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c5:	8b 45 08             	mov    0x8(%ebp),%eax
 5c8:	89 04 24             	mov    %eax,(%esp)
 5cb:	e8 31 ff ff ff       	call   501 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d8:	79 d9                	jns    5b3 <printint+0x8a>
    putc(fd, buf[i]);
}
 5da:	83 c4 30             	add    $0x30,%esp
 5dd:	5b                   	pop    %ebx
 5de:	5e                   	pop    %esi
 5df:	5d                   	pop    %ebp
 5e0:	c3                   	ret    

000005e1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e1:	55                   	push   %ebp
 5e2:	89 e5                	mov    %esp,%ebp
 5e4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ee:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f1:	83 c0 04             	add    $0x4,%eax
 5f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5fe:	e9 7c 01 00 00       	jmp    77f <printf+0x19e>
    c = fmt[i] & 0xff;
 603:	8b 55 0c             	mov    0xc(%ebp),%edx
 606:	8b 45 f0             	mov    -0x10(%ebp),%eax
 609:	01 d0                	add    %edx,%eax
 60b:	0f b6 00             	movzbl (%eax),%eax
 60e:	0f be c0             	movsbl %al,%eax
 611:	25 ff 00 00 00       	and    $0xff,%eax
 616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 619:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61d:	75 2c                	jne    64b <printf+0x6a>
      if(c == '%'){
 61f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 623:	75 0c                	jne    631 <printf+0x50>
        state = '%';
 625:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62c:	e9 4a 01 00 00       	jmp    77b <printf+0x19a>
      } else {
        putc(fd, c);
 631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	89 44 24 04          	mov    %eax,0x4(%esp)
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	89 04 24             	mov    %eax,(%esp)
 641:	e8 bb fe ff ff       	call   501 <putc>
 646:	e9 30 01 00 00       	jmp    77b <printf+0x19a>
      }
    } else if(state == '%'){
 64b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 64f:	0f 85 26 01 00 00    	jne    77b <printf+0x19a>
      if(c == 'd'){
 655:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 659:	75 2d                	jne    688 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 65b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 667:	00 
 668:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 66f:	00 
 670:	89 44 24 04          	mov    %eax,0x4(%esp)
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 aa fe ff ff       	call   529 <printint>
        ap++;
 67f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 683:	e9 ec 00 00 00       	jmp    774 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 688:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 68c:	74 06                	je     694 <printf+0xb3>
 68e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 692:	75 2d                	jne    6c1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 694:	8b 45 e8             	mov    -0x18(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6a0:	00 
 6a1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6a8:	00 
 6a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ad:	8b 45 08             	mov    0x8(%ebp),%eax
 6b0:	89 04 24             	mov    %eax,(%esp)
 6b3:	e8 71 fe ff ff       	call   529 <printint>
        ap++;
 6b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6bc:	e9 b3 00 00 00       	jmp    774 <printf+0x193>
      } else if(c == 's'){
 6c1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6c5:	75 45                	jne    70c <printf+0x12b>
        s = (char*)*ap;
 6c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ca:	8b 00                	mov    (%eax),%eax
 6cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6cf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d7:	75 09                	jne    6e2 <printf+0x101>
          s = "(null)";
 6d9:	c7 45 f4 8c 0a 00 00 	movl   $0xa8c,-0xc(%ebp)
        while(*s != 0){
 6e0:	eb 1e                	jmp    700 <printf+0x11f>
 6e2:	eb 1c                	jmp    700 <printf+0x11f>
          putc(fd, *s);
 6e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e7:	0f b6 00             	movzbl (%eax),%eax
 6ea:	0f be c0             	movsbl %al,%eax
 6ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	89 04 24             	mov    %eax,(%esp)
 6f7:	e8 05 fe ff ff       	call   501 <putc>
          s++;
 6fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 700:	8b 45 f4             	mov    -0xc(%ebp),%eax
 703:	0f b6 00             	movzbl (%eax),%eax
 706:	84 c0                	test   %al,%al
 708:	75 da                	jne    6e4 <printf+0x103>
 70a:	eb 68                	jmp    774 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 70c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 710:	75 1d                	jne    72f <printf+0x14e>
        putc(fd, *ap);
 712:	8b 45 e8             	mov    -0x18(%ebp),%eax
 715:	8b 00                	mov    (%eax),%eax
 717:	0f be c0             	movsbl %al,%eax
 71a:	89 44 24 04          	mov    %eax,0x4(%esp)
 71e:	8b 45 08             	mov    0x8(%ebp),%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 d8 fd ff ff       	call   501 <putc>
        ap++;
 729:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72d:	eb 45                	jmp    774 <printf+0x193>
      } else if(c == '%'){
 72f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 733:	75 17                	jne    74c <printf+0x16b>
        putc(fd, c);
 735:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 738:	0f be c0             	movsbl %al,%eax
 73b:	89 44 24 04          	mov    %eax,0x4(%esp)
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	89 04 24             	mov    %eax,(%esp)
 745:	e8 b7 fd ff ff       	call   501 <putc>
 74a:	eb 28                	jmp    774 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 74c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 753:	00 
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	89 04 24             	mov    %eax,(%esp)
 75a:	e8 a2 fd ff ff       	call   501 <putc>
        putc(fd, c);
 75f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 762:	0f be c0             	movsbl %al,%eax
 765:	89 44 24 04          	mov    %eax,0x4(%esp)
 769:	8b 45 08             	mov    0x8(%ebp),%eax
 76c:	89 04 24             	mov    %eax,(%esp)
 76f:	e8 8d fd ff ff       	call   501 <putc>
      }
      state = 0;
 774:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 77b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 77f:	8b 55 0c             	mov    0xc(%ebp),%edx
 782:	8b 45 f0             	mov    -0x10(%ebp),%eax
 785:	01 d0                	add    %edx,%eax
 787:	0f b6 00             	movzbl (%eax),%eax
 78a:	84 c0                	test   %al,%al
 78c:	0f 85 71 fe ff ff    	jne    603 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 792:	c9                   	leave  
 793:	c3                   	ret    

00000794 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	83 e8 08             	sub    $0x8,%eax
 7a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a3:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 7a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ab:	eb 24                	jmp    7d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b5:	77 12                	ja     7c9 <free+0x35>
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 24                	ja     7e3 <free+0x4f>
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c7:	77 1a                	ja     7e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d7:	76 d4                	jbe    7ad <free+0x19>
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e1:	76 ca                	jbe    7ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	8b 40 04             	mov    0x4(%eax),%eax
 7e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	01 c2                	add    %eax,%edx
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	39 c2                	cmp    %eax,%edx
 7fc:	75 24                	jne    822 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 801:	8b 50 04             	mov    0x4(%eax),%edx
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	8b 40 04             	mov    0x4(%eax),%eax
 80c:	01 c2                	add    %eax,%edx
 80e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 811:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	8b 00                	mov    (%eax),%eax
 819:	8b 10                	mov    (%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 10                	mov    %edx,(%eax)
 820:	eb 0a                	jmp    82c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 822:	8b 45 fc             	mov    -0x4(%ebp),%eax
 825:	8b 10                	mov    (%eax),%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 40 04             	mov    0x4(%eax),%eax
 832:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	01 d0                	add    %edx,%eax
 83e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 841:	75 20                	jne    863 <free+0xcf>
    p->s.size += bp->s.size;
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 50 04             	mov    0x4(%eax),%edx
 849:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84c:	8b 40 04             	mov    0x4(%eax),%eax
 84f:	01 c2                	add    %eax,%edx
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	8b 10                	mov    (%eax),%edx
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	89 10                	mov    %edx,(%eax)
 861:	eb 08                	jmp    86b <free+0xd7>
  } else
    p->s.ptr = bp;
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 55 f8             	mov    -0x8(%ebp),%edx
 869:	89 10                	mov    %edx,(%eax)
  freep = p;
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	a3 f8 0c 00 00       	mov    %eax,0xcf8
}
 873:	c9                   	leave  
 874:	c3                   	ret    

00000875 <morecore>:

static Header*
morecore(uint nu)
{
 875:	55                   	push   %ebp
 876:	89 e5                	mov    %esp,%ebp
 878:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 87b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 882:	77 07                	ja     88b <morecore+0x16>
    nu = 4096;
 884:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 88b:	8b 45 08             	mov    0x8(%ebp),%eax
 88e:	c1 e0 03             	shl    $0x3,%eax
 891:	89 04 24             	mov    %eax,(%esp)
 894:	e8 10 fc ff ff       	call   4a9 <sbrk>
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 89c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a0:	75 07                	jne    8a9 <morecore+0x34>
    return 0;
 8a2:	b8 00 00 00 00       	mov    $0x0,%eax
 8a7:	eb 22                	jmp    8cb <morecore+0x56>
  hp = (Header*)p;
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b2:	8b 55 08             	mov    0x8(%ebp),%edx
 8b5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bb:	83 c0 08             	add    $0x8,%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 ce fe ff ff       	call   794 <free>
  return freep;
 8c6:	a1 f8 0c 00 00       	mov    0xcf8,%eax
}
 8cb:	c9                   	leave  
 8cc:	c3                   	ret    

000008cd <malloc>:

void*
malloc(uint nbytes)
{
 8cd:	55                   	push   %ebp
 8ce:	89 e5                	mov    %esp,%ebp
 8d0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	83 c0 07             	add    $0x7,%eax
 8d9:	c1 e8 03             	shr    $0x3,%eax
 8dc:	83 c0 01             	add    $0x1,%eax
 8df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e2:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 8e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ee:	75 23                	jne    913 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8f0:	c7 45 f0 f0 0c 00 00 	movl   $0xcf0,-0x10(%ebp)
 8f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fa:	a3 f8 0c 00 00       	mov    %eax,0xcf8
 8ff:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 904:	a3 f0 0c 00 00       	mov    %eax,0xcf0
    base.s.size = 0;
 909:	c7 05 f4 0c 00 00 00 	movl   $0x0,0xcf4
 910:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 913:	8b 45 f0             	mov    -0x10(%ebp),%eax
 916:	8b 00                	mov    (%eax),%eax
 918:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	8b 40 04             	mov    0x4(%eax),%eax
 921:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 924:	72 4d                	jb     973 <malloc+0xa6>
      if(p->s.size == nunits)
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	8b 40 04             	mov    0x4(%eax),%eax
 92c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92f:	75 0c                	jne    93d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 10                	mov    (%eax),%edx
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	89 10                	mov    %edx,(%eax)
 93b:	eb 26                	jmp    963 <malloc+0x96>
      else {
        p->s.size -= nunits;
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	2b 45 ec             	sub    -0x14(%ebp),%eax
 946:	89 c2                	mov    %eax,%edx
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	8b 40 04             	mov    0x4(%eax),%eax
 954:	c1 e0 03             	shl    $0x3,%eax
 957:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 960:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 963:	8b 45 f0             	mov    -0x10(%ebp),%eax
 966:	a3 f8 0c 00 00       	mov    %eax,0xcf8
      return (void*)(p + 1);
 96b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96e:	83 c0 08             	add    $0x8,%eax
 971:	eb 38                	jmp    9ab <malloc+0xde>
    }
    if(p == freep)
 973:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 97b:	75 1b                	jne    998 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 97d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 980:	89 04 24             	mov    %eax,(%esp)
 983:	e8 ed fe ff ff       	call   875 <morecore>
 988:	89 45 f4             	mov    %eax,-0xc(%ebp)
 98b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 98f:	75 07                	jne    998 <malloc+0xcb>
        return 0;
 991:	b8 00 00 00 00       	mov    $0x0,%eax
 996:	eb 13                	jmp    9ab <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 998:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 99e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a1:	8b 00                	mov    (%eax),%eax
 9a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9a6:	e9 70 ff ff ff       	jmp    91b <malloc+0x4e>
}
 9ab:	c9                   	leave  
 9ac:	c3                   	ret    
