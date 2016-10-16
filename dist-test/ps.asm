
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
  1e:	e8 9e 08 00 00       	call   8c1 <malloc>
  23:	89 44 24 5c          	mov    %eax,0x5c(%esp)
	ptable_size = getprocs(display_size, ps);
  27:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  2f:	8b 44 24 54          	mov    0x54(%esp),%eax
  33:	89 04 24             	mov    %eax,(%esp)
  36:	e8 b2 04 00 00       	call   4ed <getprocs>
  3b:	89 44 24 50          	mov    %eax,0x50(%esp)
	if(ptable_size <= 0) {
  3f:	83 7c 24 50 00       	cmpl   $0x0,0x50(%esp)
  44:	7f 19                	jg     5f <main+0x5f>
		printf(1,"\nGetting processes information failed\n");
  46:	c7 44 24 04 a4 09 00 	movl   $0x9a4,0x4(%esp)
  4d:	00 
  4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  55:	e8 7b 05 00 00       	call   5d5 <printf>
		exit();
  5a:	e8 b6 03 00 00       	call   415 <exit>
	}
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
  5f:	8b 44 24 50          	mov    0x50(%esp),%eax
  63:	89 44 24 08          	mov    %eax,0x8(%esp)
  67:	c7 44 24 04 cb 09 00 	movl   $0x9cb,0x4(%esp)
  6e:	00 
  6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  76:	e8 5a 05 00 00       	call   5d5 <printf>
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
  7b:	c7 44 24 04 e8 09 00 	movl   $0x9e8,0x4(%esp)
  82:	00 
  83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8a:	e8 46 05 00 00       	call   5d5 <printf>
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
 17c:	c7 44 24 04 40 0a 00 	movl   $0xa40,0x4(%esp)
 183:	00 
 184:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18b:	e8 45 04 00 00       	call   5d5 <printf>
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
  exit();
 1a8:	e8 68 02 00 00       	call   415 <exit>

000001ad <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1ad:	55                   	push   %ebp
 1ae:	89 e5                	mov    %esp,%ebp
 1b0:	57                   	push   %edi
 1b1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1b5:	8b 55 10             	mov    0x10(%ebp),%edx
 1b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bb:	89 cb                	mov    %ecx,%ebx
 1bd:	89 df                	mov    %ebx,%edi
 1bf:	89 d1                	mov    %edx,%ecx
 1c1:	fc                   	cld    
 1c2:	f3 aa                	rep stos %al,%es:(%edi)
 1c4:	89 ca                	mov    %ecx,%edx
 1c6:	89 fb                	mov    %edi,%ebx
 1c8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1cb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1ce:	5b                   	pop    %ebx
 1cf:	5f                   	pop    %edi
 1d0:	5d                   	pop    %ebp
 1d1:	c3                   	ret    

000001d2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
 1db:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1de:	90                   	nop
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	8d 50 01             	lea    0x1(%eax),%edx
 1e5:	89 55 08             	mov    %edx,0x8(%ebp)
 1e8:	8b 55 0c             	mov    0xc(%ebp),%edx
 1eb:	8d 4a 01             	lea    0x1(%edx),%ecx
 1ee:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1f1:	0f b6 12             	movzbl (%edx),%edx
 1f4:	88 10                	mov    %dl,(%eax)
 1f6:	0f b6 00             	movzbl (%eax),%eax
 1f9:	84 c0                	test   %al,%al
 1fb:	75 e2                	jne    1df <strcpy+0xd>
    ;
  return os;
 1fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 200:	c9                   	leave  
 201:	c3                   	ret    

00000202 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 202:	55                   	push   %ebp
 203:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 205:	eb 08                	jmp    20f <strcmp+0xd>
    p++, q++;
 207:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	84 c0                	test   %al,%al
 217:	74 10                	je     229 <strcmp+0x27>
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	0f b6 10             	movzbl (%eax),%edx
 21f:	8b 45 0c             	mov    0xc(%ebp),%eax
 222:	0f b6 00             	movzbl (%eax),%eax
 225:	38 c2                	cmp    %al,%dl
 227:	74 de                	je     207 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	0f b6 d0             	movzbl %al,%edx
 232:	8b 45 0c             	mov    0xc(%ebp),%eax
 235:	0f b6 00             	movzbl (%eax),%eax
 238:	0f b6 c0             	movzbl %al,%eax
 23b:	29 c2                	sub    %eax,%edx
 23d:	89 d0                	mov    %edx,%eax
}
 23f:	5d                   	pop    %ebp
 240:	c3                   	ret    

00000241 <strlen>:

uint
strlen(char *s)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 247:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 24e:	eb 04                	jmp    254 <strlen+0x13>
 250:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 254:	8b 55 fc             	mov    -0x4(%ebp),%edx
 257:	8b 45 08             	mov    0x8(%ebp),%eax
 25a:	01 d0                	add    %edx,%eax
 25c:	0f b6 00             	movzbl (%eax),%eax
 25f:	84 c0                	test   %al,%al
 261:	75 ed                	jne    250 <strlen+0xf>
    ;
  return n;
 263:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 266:	c9                   	leave  
 267:	c3                   	ret    

00000268 <memset>:

void*
memset(void *dst, int c, uint n)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 26e:	8b 45 10             	mov    0x10(%ebp),%eax
 271:	89 44 24 08          	mov    %eax,0x8(%esp)
 275:	8b 45 0c             	mov    0xc(%ebp),%eax
 278:	89 44 24 04          	mov    %eax,0x4(%esp)
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	89 04 24             	mov    %eax,(%esp)
 282:	e8 26 ff ff ff       	call   1ad <stosb>
  return dst;
 287:	8b 45 08             	mov    0x8(%ebp),%eax
}
 28a:	c9                   	leave  
 28b:	c3                   	ret    

0000028c <strchr>:

char*
strchr(const char *s, char c)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	83 ec 04             	sub    $0x4,%esp
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 298:	eb 14                	jmp    2ae <strchr+0x22>
    if(*s == c)
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	0f b6 00             	movzbl (%eax),%eax
 2a0:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2a3:	75 05                	jne    2aa <strchr+0x1e>
      return (char*)s;
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	eb 13                	jmp    2bd <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	0f b6 00             	movzbl (%eax),%eax
 2b4:	84 c0                	test   %al,%al
 2b6:	75 e2                	jne    29a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2bd:	c9                   	leave  
 2be:	c3                   	ret    

000002bf <gets>:

char*
gets(char *buf, int max)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2cc:	eb 4c                	jmp    31a <gets+0x5b>
    cc = read(0, &c, 1);
 2ce:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2d5:	00 
 2d6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2e4:	e8 44 01 00 00       	call   42d <read>
 2e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2f0:	7f 02                	jg     2f4 <gets+0x35>
      break;
 2f2:	eb 31                	jmp    325 <gets+0x66>
    buf[i++] = c;
 2f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f7:	8d 50 01             	lea    0x1(%eax),%edx
 2fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2fd:	89 c2                	mov    %eax,%edx
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	01 c2                	add    %eax,%edx
 304:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 308:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 30a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30e:	3c 0a                	cmp    $0xa,%al
 310:	74 13                	je     325 <gets+0x66>
 312:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 316:	3c 0d                	cmp    $0xd,%al
 318:	74 0b                	je     325 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31d:	83 c0 01             	add    $0x1,%eax
 320:	3b 45 0c             	cmp    0xc(%ebp),%eax
 323:	7c a9                	jl     2ce <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 325:	8b 55 f4             	mov    -0xc(%ebp),%edx
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	01 d0                	add    %edx,%eax
 32d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 330:	8b 45 08             	mov    0x8(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <stat>:

int
stat(char *n, struct stat *st)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 342:	00 
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	89 04 24             	mov    %eax,(%esp)
 349:	e8 07 01 00 00       	call   455 <open>
 34e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 351:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 355:	79 07                	jns    35e <stat+0x29>
    return -1;
 357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 35c:	eb 23                	jmp    381 <stat+0x4c>
  r = fstat(fd, st);
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	89 44 24 04          	mov    %eax,0x4(%esp)
 365:	8b 45 f4             	mov    -0xc(%ebp),%eax
 368:	89 04 24             	mov    %eax,(%esp)
 36b:	e8 fd 00 00 00       	call   46d <fstat>
 370:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 373:	8b 45 f4             	mov    -0xc(%ebp),%eax
 376:	89 04 24             	mov    %eax,(%esp)
 379:	e8 bf 00 00 00       	call   43d <close>
  return r;
 37e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <atoi>:

int
atoi(const char *s)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 389:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 390:	eb 25                	jmp    3b7 <atoi+0x34>
    n = n*10 + *s++ - '0';
 392:	8b 55 fc             	mov    -0x4(%ebp),%edx
 395:	89 d0                	mov    %edx,%eax
 397:	c1 e0 02             	shl    $0x2,%eax
 39a:	01 d0                	add    %edx,%eax
 39c:	01 c0                	add    %eax,%eax
 39e:	89 c1                	mov    %eax,%ecx
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	8d 50 01             	lea    0x1(%eax),%edx
 3a6:	89 55 08             	mov    %edx,0x8(%ebp)
 3a9:	0f b6 00             	movzbl (%eax),%eax
 3ac:	0f be c0             	movsbl %al,%eax
 3af:	01 c8                	add    %ecx,%eax
 3b1:	83 e8 30             	sub    $0x30,%eax
 3b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	3c 2f                	cmp    $0x2f,%al
 3bf:	7e 0a                	jle    3cb <atoi+0x48>
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 00             	movzbl (%eax),%eax
 3c7:	3c 39                	cmp    $0x39,%al
 3c9:	7e c7                	jle    392 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
 3d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e2:	eb 17                	jmp    3fb <memmove+0x2b>
    *dst++ = *src++;
 3e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3e7:	8d 50 01             	lea    0x1(%eax),%edx
 3ea:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3f0:	8d 4a 01             	lea    0x1(%edx),%ecx
 3f3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3f6:	0f b6 12             	movzbl (%edx),%edx
 3f9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3fb:	8b 45 10             	mov    0x10(%ebp),%eax
 3fe:	8d 50 ff             	lea    -0x1(%eax),%edx
 401:	89 55 10             	mov    %edx,0x10(%ebp)
 404:	85 c0                	test   %eax,%eax
 406:	7f dc                	jg     3e4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 40d:	b8 01 00 00 00       	mov    $0x1,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <exit>:
SYSCALL(exit)
 415:	b8 02 00 00 00       	mov    $0x2,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <wait>:
SYSCALL(wait)
 41d:	b8 03 00 00 00       	mov    $0x3,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <pipe>:
SYSCALL(pipe)
 425:	b8 04 00 00 00       	mov    $0x4,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <read>:
SYSCALL(read)
 42d:	b8 05 00 00 00       	mov    $0x5,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <write>:
SYSCALL(write)
 435:	b8 10 00 00 00       	mov    $0x10,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <close>:
SYSCALL(close)
 43d:	b8 15 00 00 00       	mov    $0x15,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <kill>:
SYSCALL(kill)
 445:	b8 06 00 00 00       	mov    $0x6,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <exec>:
SYSCALL(exec)
 44d:	b8 07 00 00 00       	mov    $0x7,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <open>:
SYSCALL(open)
 455:	b8 0f 00 00 00       	mov    $0xf,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <mknod>:
SYSCALL(mknod)
 45d:	b8 11 00 00 00       	mov    $0x11,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <unlink>:
SYSCALL(unlink)
 465:	b8 12 00 00 00       	mov    $0x12,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <fstat>:
SYSCALL(fstat)
 46d:	b8 08 00 00 00       	mov    $0x8,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <link>:
SYSCALL(link)
 475:	b8 13 00 00 00       	mov    $0x13,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <mkdir>:
SYSCALL(mkdir)
 47d:	b8 14 00 00 00       	mov    $0x14,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <chdir>:
SYSCALL(chdir)
 485:	b8 09 00 00 00       	mov    $0x9,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <dup>:
SYSCALL(dup)
 48d:	b8 0a 00 00 00       	mov    $0xa,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <getpid>:
SYSCALL(getpid)
 495:	b8 0b 00 00 00       	mov    $0xb,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <sbrk>:
SYSCALL(sbrk)
 49d:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <sleep>:
SYSCALL(sleep)
 4a5:	b8 0d 00 00 00       	mov    $0xd,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <uptime>:
SYSCALL(uptime)
 4ad:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <halt>:
SYSCALL(halt)
 4b5:	b8 16 00 00 00       	mov    $0x16,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <date>:
SYSCALL(date)
 4bd:	b8 17 00 00 00       	mov    $0x17,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <getuid>:
SYSCALL(getuid)
 4c5:	b8 18 00 00 00       	mov    $0x18,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <getgid>:
SYSCALL(getgid)
 4cd:	b8 19 00 00 00       	mov    $0x19,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <getppid>:
SYSCALL(getppid)
 4d5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <setuid>:
SYSCALL(setuid)
 4dd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <setgid>:
SYSCALL(setgid)
 4e5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <getprocs>:
SYSCALL(getprocs)
 4ed:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f5:	55                   	push   %ebp
 4f6:	89 e5                	mov    %esp,%ebp
 4f8:	83 ec 18             	sub    $0x18,%esp
 4fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fe:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 501:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 508:	00 
 509:	8d 45 f4             	lea    -0xc(%ebp),%eax
 50c:	89 44 24 04          	mov    %eax,0x4(%esp)
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	89 04 24             	mov    %eax,(%esp)
 516:	e8 1a ff ff ff       	call   435 <write>
}
 51b:	c9                   	leave  
 51c:	c3                   	ret    

0000051d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	56                   	push   %esi
 521:	53                   	push   %ebx
 522:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 525:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 52c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 530:	74 17                	je     549 <printint+0x2c>
 532:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 536:	79 11                	jns    549 <printint+0x2c>
    neg = 1;
 538:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 53f:	8b 45 0c             	mov    0xc(%ebp),%eax
 542:	f7 d8                	neg    %eax
 544:	89 45 ec             	mov    %eax,-0x14(%ebp)
 547:	eb 06                	jmp    54f <printint+0x32>
  } else {
    x = xx;
 549:	8b 45 0c             	mov    0xc(%ebp),%eax
 54c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 54f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 556:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 559:	8d 41 01             	lea    0x1(%ecx),%eax
 55c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 55f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 562:	8b 45 ec             	mov    -0x14(%ebp),%eax
 565:	ba 00 00 00 00       	mov    $0x0,%edx
 56a:	f7 f3                	div    %ebx
 56c:	89 d0                	mov    %edx,%eax
 56e:	0f b6 80 d0 0c 00 00 	movzbl 0xcd0(%eax),%eax
 575:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 579:	8b 75 10             	mov    0x10(%ebp),%esi
 57c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 57f:	ba 00 00 00 00       	mov    $0x0,%edx
 584:	f7 f6                	div    %esi
 586:	89 45 ec             	mov    %eax,-0x14(%ebp)
 589:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 58d:	75 c7                	jne    556 <printint+0x39>
  if(neg)
 58f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 593:	74 10                	je     5a5 <printint+0x88>
    buf[i++] = '-';
 595:	8b 45 f4             	mov    -0xc(%ebp),%eax
 598:	8d 50 01             	lea    0x1(%eax),%edx
 59b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 59e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5a3:	eb 1f                	jmp    5c4 <printint+0xa7>
 5a5:	eb 1d                	jmp    5c4 <printint+0xa7>
    putc(fd, buf[i]);
 5a7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ad:	01 d0                	add    %edx,%eax
 5af:	0f b6 00             	movzbl (%eax),%eax
 5b2:	0f be c0             	movsbl %al,%eax
 5b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b9:	8b 45 08             	mov    0x8(%ebp),%eax
 5bc:	89 04 24             	mov    %eax,(%esp)
 5bf:	e8 31 ff ff ff       	call   4f5 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cc:	79 d9                	jns    5a7 <printint+0x8a>
    putc(fd, buf[i]);
}
 5ce:	83 c4 30             	add    $0x30,%esp
 5d1:	5b                   	pop    %ebx
 5d2:	5e                   	pop    %esi
 5d3:	5d                   	pop    %ebp
 5d4:	c3                   	ret    

000005d5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d5:	55                   	push   %ebp
 5d6:	89 e5                	mov    %esp,%ebp
 5d8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e2:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e5:	83 c0 04             	add    $0x4,%eax
 5e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f2:	e9 7c 01 00 00       	jmp    773 <printf+0x19e>
    c = fmt[i] & 0xff;
 5f7:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5fd:	01 d0                	add    %edx,%eax
 5ff:	0f b6 00             	movzbl (%eax),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	25 ff 00 00 00       	and    $0xff,%eax
 60a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 60d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 611:	75 2c                	jne    63f <printf+0x6a>
      if(c == '%'){
 613:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 617:	75 0c                	jne    625 <printf+0x50>
        state = '%';
 619:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 620:	e9 4a 01 00 00       	jmp    76f <printf+0x19a>
      } else {
        putc(fd, c);
 625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 628:	0f be c0             	movsbl %al,%eax
 62b:	89 44 24 04          	mov    %eax,0x4(%esp)
 62f:	8b 45 08             	mov    0x8(%ebp),%eax
 632:	89 04 24             	mov    %eax,(%esp)
 635:	e8 bb fe ff ff       	call   4f5 <putc>
 63a:	e9 30 01 00 00       	jmp    76f <printf+0x19a>
      }
    } else if(state == '%'){
 63f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 643:	0f 85 26 01 00 00    	jne    76f <printf+0x19a>
      if(c == 'd'){
 649:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 64d:	75 2d                	jne    67c <printf+0xa7>
        printint(fd, *ap, 10, 1);
 64f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 65b:	00 
 65c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 663:	00 
 664:	89 44 24 04          	mov    %eax,0x4(%esp)
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	89 04 24             	mov    %eax,(%esp)
 66e:	e8 aa fe ff ff       	call   51d <printint>
        ap++;
 673:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 677:	e9 ec 00 00 00       	jmp    768 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 67c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 680:	74 06                	je     688 <printf+0xb3>
 682:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 686:	75 2d                	jne    6b5 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 688:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68b:	8b 00                	mov    (%eax),%eax
 68d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 694:	00 
 695:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 69c:	00 
 69d:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a1:	8b 45 08             	mov    0x8(%ebp),%eax
 6a4:	89 04 24             	mov    %eax,(%esp)
 6a7:	e8 71 fe ff ff       	call   51d <printint>
        ap++;
 6ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b0:	e9 b3 00 00 00       	jmp    768 <printf+0x193>
      } else if(c == 's'){
 6b5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b9:	75 45                	jne    700 <printf+0x12b>
        s = (char*)*ap;
 6bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6cb:	75 09                	jne    6d6 <printf+0x101>
          s = "(null)";
 6cd:	c7 45 f4 80 0a 00 00 	movl   $0xa80,-0xc(%ebp)
        while(*s != 0){
 6d4:	eb 1e                	jmp    6f4 <printf+0x11f>
 6d6:	eb 1c                	jmp    6f4 <printf+0x11f>
          putc(fd, *s);
 6d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6db:	0f b6 00             	movzbl (%eax),%eax
 6de:	0f be c0             	movsbl %al,%eax
 6e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	89 04 24             	mov    %eax,(%esp)
 6eb:	e8 05 fe ff ff       	call   4f5 <putc>
          s++;
 6f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f7:	0f b6 00             	movzbl (%eax),%eax
 6fa:	84 c0                	test   %al,%al
 6fc:	75 da                	jne    6d8 <printf+0x103>
 6fe:	eb 68                	jmp    768 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 700:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 704:	75 1d                	jne    723 <printf+0x14e>
        putc(fd, *ap);
 706:	8b 45 e8             	mov    -0x18(%ebp),%eax
 709:	8b 00                	mov    (%eax),%eax
 70b:	0f be c0             	movsbl %al,%eax
 70e:	89 44 24 04          	mov    %eax,0x4(%esp)
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	89 04 24             	mov    %eax,(%esp)
 718:	e8 d8 fd ff ff       	call   4f5 <putc>
        ap++;
 71d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 721:	eb 45                	jmp    768 <printf+0x193>
      } else if(c == '%'){
 723:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 727:	75 17                	jne    740 <printf+0x16b>
        putc(fd, c);
 729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72c:	0f be c0             	movsbl %al,%eax
 72f:	89 44 24 04          	mov    %eax,0x4(%esp)
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 b7 fd ff ff       	call   4f5 <putc>
 73e:	eb 28                	jmp    768 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 740:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 747:	00 
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 a2 fd ff ff       	call   4f5 <putc>
        putc(fd, c);
 753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 756:	0f be c0             	movsbl %al,%eax
 759:	89 44 24 04          	mov    %eax,0x4(%esp)
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 8d fd ff ff       	call   4f5 <putc>
      }
      state = 0;
 768:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 76f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 773:	8b 55 0c             	mov    0xc(%ebp),%edx
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	01 d0                	add    %edx,%eax
 77b:	0f b6 00             	movzbl (%eax),%eax
 77e:	84 c0                	test   %al,%al
 780:	0f 85 71 fe ff ff    	jne    5f7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 786:	c9                   	leave  
 787:	c3                   	ret    

00000788 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	83 e8 08             	sub    $0x8,%eax
 794:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 797:	a1 ec 0c 00 00       	mov    0xcec,%eax
 79c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79f:	eb 24                	jmp    7c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a9:	77 12                	ja     7bd <free+0x35>
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b1:	77 24                	ja     7d7 <free+0x4f>
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	8b 00                	mov    (%eax),%eax
 7b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bb:	77 1a                	ja     7d7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cb:	76 d4                	jbe    7a1 <free+0x19>
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d5:	76 ca                	jbe    7a1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	8b 40 04             	mov    0x4(%eax),%eax
 7dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e7:	01 c2                	add    %eax,%edx
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	39 c2                	cmp    %eax,%edx
 7f0:	75 24                	jne    816 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	8b 50 04             	mov    0x4(%eax),%edx
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 00                	mov    (%eax),%eax
 7fd:	8b 40 04             	mov    0x4(%eax),%eax
 800:	01 c2                	add    %eax,%edx
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	8b 10                	mov    (%eax),%edx
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	89 10                	mov    %edx,(%eax)
 814:	eb 0a                	jmp    820 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 10                	mov    (%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 40 04             	mov    0x4(%eax),%eax
 826:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	01 d0                	add    %edx,%eax
 832:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 835:	75 20                	jne    857 <free+0xcf>
    p->s.size += bp->s.size;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 50 04             	mov    0x4(%eax),%edx
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	01 c2                	add    %eax,%edx
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	8b 10                	mov    (%eax),%edx
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	89 10                	mov    %edx,(%eax)
 855:	eb 08                	jmp    85f <free+0xd7>
  } else
    p->s.ptr = bp;
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85d:	89 10                	mov    %edx,(%eax)
  freep = p;
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	a3 ec 0c 00 00       	mov    %eax,0xcec
}
 867:	c9                   	leave  
 868:	c3                   	ret    

00000869 <morecore>:

static Header*
morecore(uint nu)
{
 869:	55                   	push   %ebp
 86a:	89 e5                	mov    %esp,%ebp
 86c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 86f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 876:	77 07                	ja     87f <morecore+0x16>
    nu = 4096;
 878:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 87f:	8b 45 08             	mov    0x8(%ebp),%eax
 882:	c1 e0 03             	shl    $0x3,%eax
 885:	89 04 24             	mov    %eax,(%esp)
 888:	e8 10 fc ff ff       	call   49d <sbrk>
 88d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 890:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 894:	75 07                	jne    89d <morecore+0x34>
    return 0;
 896:	b8 00 00 00 00       	mov    $0x0,%eax
 89b:	eb 22                	jmp    8bf <morecore+0x56>
  hp = (Header*)p;
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a6:	8b 55 08             	mov    0x8(%ebp),%edx
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	83 c0 08             	add    $0x8,%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 ce fe ff ff       	call   788 <free>
  return freep;
 8ba:	a1 ec 0c 00 00       	mov    0xcec,%eax
}
 8bf:	c9                   	leave  
 8c0:	c3                   	ret    

000008c1 <malloc>:

void*
malloc(uint nbytes)
{
 8c1:	55                   	push   %ebp
 8c2:	89 e5                	mov    %esp,%ebp
 8c4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ca:	83 c0 07             	add    $0x7,%eax
 8cd:	c1 e8 03             	shr    $0x3,%eax
 8d0:	83 c0 01             	add    $0x1,%eax
 8d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d6:	a1 ec 0c 00 00       	mov    0xcec,%eax
 8db:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e2:	75 23                	jne    907 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e4:	c7 45 f0 e4 0c 00 00 	movl   $0xce4,-0x10(%ebp)
 8eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ee:	a3 ec 0c 00 00       	mov    %eax,0xcec
 8f3:	a1 ec 0c 00 00       	mov    0xcec,%eax
 8f8:	a3 e4 0c 00 00       	mov    %eax,0xce4
    base.s.size = 0;
 8fd:	c7 05 e8 0c 00 00 00 	movl   $0x0,0xce8
 904:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 907:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90a:	8b 00                	mov    (%eax),%eax
 90c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 918:	72 4d                	jb     967 <malloc+0xa6>
      if(p->s.size == nunits)
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 923:	75 0c                	jne    931 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 925:	8b 45 f4             	mov    -0xc(%ebp),%eax
 928:	8b 10                	mov    (%eax),%edx
 92a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92d:	89 10                	mov    %edx,(%eax)
 92f:	eb 26                	jmp    957 <malloc+0x96>
      else {
        p->s.size -= nunits;
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	2b 45 ec             	sub    -0x14(%ebp),%eax
 93a:	89 c2                	mov    %eax,%edx
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 942:	8b 45 f4             	mov    -0xc(%ebp),%eax
 945:	8b 40 04             	mov    0x4(%eax),%eax
 948:	c1 e0 03             	shl    $0x3,%eax
 94b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	8b 55 ec             	mov    -0x14(%ebp),%edx
 954:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 957:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95a:	a3 ec 0c 00 00       	mov    %eax,0xcec
      return (void*)(p + 1);
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	83 c0 08             	add    $0x8,%eax
 965:	eb 38                	jmp    99f <malloc+0xde>
    }
    if(p == freep)
 967:	a1 ec 0c 00 00       	mov    0xcec,%eax
 96c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 96f:	75 1b                	jne    98c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 971:	8b 45 ec             	mov    -0x14(%ebp),%eax
 974:	89 04 24             	mov    %eax,(%esp)
 977:	e8 ed fe ff ff       	call   869 <morecore>
 97c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 97f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 983:	75 07                	jne    98c <malloc+0xcb>
        return 0;
 985:	b8 00 00 00 00       	mov    $0x0,%eax
 98a:	eb 13                	jmp    99f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 992:	8b 45 f4             	mov    -0xc(%ebp),%eax
 995:	8b 00                	mov    (%eax),%eax
 997:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99a:	e9 70 ff ff ff       	jmp    90f <malloc+0x4e>
}
 99f:	c9                   	leave  
 9a0:	c3                   	ret    
