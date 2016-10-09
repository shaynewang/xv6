
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "uproc.h"
#include "user.h"

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
	display_size = 16;
   c:	c7 44 24 54 10 00 00 	movl   $0x10,0x54(%esp)
  13:	00 
	struct uproc* ps;
	ps = malloc(sizeof(struct uproc) * display_size);
  14:	8b 44 24 54          	mov    0x54(%esp),%eax
  18:	6b c0 5c             	imul   $0x5c,%eax,%eax
  1b:	89 04 24             	mov    %eax,(%esp)
  1e:	e8 7e 08 00 00       	call   8a1 <malloc>
  23:	89 44 24 5c          	mov    %eax,0x5c(%esp)
	ptable_size = getprocs(display_size, ps);
  27:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  2f:	8b 44 24 54          	mov    0x54(%esp),%eax
  33:	89 04 24             	mov    %eax,(%esp)
  36:	e8 92 04 00 00       	call   4cd <getprocs>
  3b:	89 44 24 50          	mov    %eax,0x50(%esp)
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
  3f:	8b 44 24 50          	mov    0x50(%esp),%eax
  43:	89 44 24 08          	mov    %eax,0x8(%esp)
  47:	c7 44 24 04 84 09 00 	movl   $0x984,0x4(%esp)
  4e:	00 
  4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  56:	e8 5a 05 00 00       	call   5b5 <printf>
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
  5b:	c7 44 24 04 a4 09 00 	movl   $0x9a4,0x4(%esp)
  62:	00 
  63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6a:	e8 46 05 00 00       	call   5b5 <printf>
	int i;
	for(i=0; i < ptable_size; ++i){
  6f:	c7 44 24 58 00 00 00 	movl   $0x0,0x58(%esp)
  76:	00 
  77:	e9 fe 00 00 00       	jmp    17a <main+0x17a>
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  7c:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  80:	8b 78 38             	mov    0x38(%eax),%edi
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  83:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  87:	8b 48 14             	mov    0x14(%eax),%ecx
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  8a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  8f:	89 c8                	mov    %ecx,%eax
  91:	f7 e2                	mul    %edx
  93:	89 d3                	mov    %edx,%ebx
  95:	c1 eb 05             	shr    $0x5,%ebx
  98:	6b c3 64             	imul   $0x64,%ebx,%eax
  9b:	89 cb                	mov    %ecx,%ebx
  9d:	29 c3                	sub    %eax,%ebx
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  9f:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  a3:	8b 40 14             	mov    0x14(%eax),%eax
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  a6:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  ab:	f7 e2                	mul    %edx
  ad:	c1 ea 05             	shr    $0x5,%edx
  b0:	89 54 24 4c          	mov    %edx,0x4c(%esp)
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  b4:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  b8:	8b 48 10             	mov    0x10(%eax),%ecx
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  bb:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  c0:	89 c8                	mov    %ecx,%eax
  c2:	f7 e2                	mul    %edx
  c4:	89 d6                	mov    %edx,%esi
  c6:	c1 ee 05             	shr    $0x5,%esi
  c9:	6b c6 64             	imul   $0x64,%esi,%eax
  cc:	89 ce                	mov    %ecx,%esi
  ce:	29 c6                	sub    %eax,%esi
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
  d0:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  d4:	8b 40 10             	mov    0x10(%eax),%eax
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
  d7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  dc:	f7 e2                	mul    %edx
  de:	89 d0                	mov    %edx,%eax
  e0:	c1 e8 05             	shr    $0x5,%eax
  e3:	89 44 24 48          	mov    %eax,0x48(%esp)
  e7:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  eb:	8b 48 0c             	mov    0xc(%eax),%ecx
  ee:	89 4c 24 44          	mov    %ecx,0x44(%esp)
  f2:	8b 44 24 5c          	mov    0x5c(%esp),%eax
  f6:	8b 40 08             	mov    0x8(%eax),%eax
  f9:	89 44 24 40          	mov    %eax,0x40(%esp)
  fd:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 101:	8b 48 04             	mov    0x4(%eax),%ecx
 104:	89 4c 24 3c          	mov    %ecx,0x3c(%esp)
		ps->state,\
		ps->name,\
 108:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 10c:	8d 48 3c             	lea    0x3c(%eax),%ecx
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
		ps->state,\
 10f:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 113:	8d 50 18             	lea    0x18(%eax),%edx
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
    printf(1,"\n%d         %s    %s    %d    %d    %d    %d.%d    %d.%d    %d\n", ps->pid,\
 116:	8b 44 24 5c          	mov    0x5c(%esp),%eax
 11a:	8b 00                	mov    (%eax),%eax
 11c:	89 7c 24 30          	mov    %edi,0x30(%esp)
 120:	89 5c 24 2c          	mov    %ebx,0x2c(%esp)
 124:	8b 7c 24 4c          	mov    0x4c(%esp),%edi
 128:	89 7c 24 28          	mov    %edi,0x28(%esp)
 12c:	89 74 24 24          	mov    %esi,0x24(%esp)
 130:	8b 7c 24 48          	mov    0x48(%esp),%edi
 134:	89 7c 24 20          	mov    %edi,0x20(%esp)
 138:	8b 7c 24 44          	mov    0x44(%esp),%edi
 13c:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
 140:	8b 7c 24 40          	mov    0x40(%esp),%edi
 144:	89 7c 24 18          	mov    %edi,0x18(%esp)
 148:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
 14c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 150:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 154:	89 54 24 0c          	mov    %edx,0xc(%esp)
 158:	89 44 24 08          	mov    %eax,0x8(%esp)
 15c:	c7 44 24 04 fc 09 00 	movl   $0x9fc,0x4(%esp)
 163:	00 
 164:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16b:	e8 45 04 00 00       	call   5b5 <printf>
		ps->state,\
		ps->name,\
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
 170:	83 44 24 5c 5c       	addl   $0x5c,0x5c(%esp)
	ps = malloc(sizeof(struct uproc) * display_size);
	ptable_size = getprocs(display_size, ps);
	printf(1,"\nNumber of processes is :%d\n",ptable_size);
	printf(1,"\nPID       State     Name      UID       GID       PPID       Elapsed   CPU       Size\n");
	int i;
	for(i=0; i < ptable_size; ++i){
 175:	83 44 24 58 01       	addl   $0x1,0x58(%esp)
 17a:	8b 44 24 58          	mov    0x58(%esp),%eax
 17e:	3b 44 24 50          	cmp    0x50(%esp),%eax
 182:	0f 8c f4 fe ff ff    	jl     7c <main+0x7c>
		ps->uid,\
		ps->gid,\
		ps->ppid, ps->elapsed_ticks/100, ps->elapsed_ticks%100, ps->CPU_total_ticks/100, ps->CPU_total_ticks%100, ps->size);
		++ps;
	}
  exit();
 188:	e8 68 02 00 00       	call   3f5 <exit>

0000018d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 18d:	55                   	push   %ebp
 18e:	89 e5                	mov    %esp,%ebp
 190:	57                   	push   %edi
 191:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 192:	8b 4d 08             	mov    0x8(%ebp),%ecx
 195:	8b 55 10             	mov    0x10(%ebp),%edx
 198:	8b 45 0c             	mov    0xc(%ebp),%eax
 19b:	89 cb                	mov    %ecx,%ebx
 19d:	89 df                	mov    %ebx,%edi
 19f:	89 d1                	mov    %edx,%ecx
 1a1:	fc                   	cld    
 1a2:	f3 aa                	rep stos %al,%es:(%edi)
 1a4:	89 ca                	mov    %ecx,%edx
 1a6:	89 fb                	mov    %edi,%ebx
 1a8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1ab:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1ae:	5b                   	pop    %ebx
 1af:	5f                   	pop    %edi
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1be:	90                   	nop
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	8d 50 01             	lea    0x1(%eax),%edx
 1c5:	89 55 08             	mov    %edx,0x8(%ebp)
 1c8:	8b 55 0c             	mov    0xc(%ebp),%edx
 1cb:	8d 4a 01             	lea    0x1(%edx),%ecx
 1ce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1d1:	0f b6 12             	movzbl (%edx),%edx
 1d4:	88 10                	mov    %dl,(%eax)
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 e2                	jne    1bf <strcpy+0xd>
    ;
  return os;
 1dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e0:	c9                   	leave  
 1e1:	c3                   	ret    

000001e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1e5:	eb 08                	jmp    1ef <strcmp+0xd>
    p++, q++;
 1e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1eb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 00             	movzbl (%eax),%eax
 1f5:	84 c0                	test   %al,%al
 1f7:	74 10                	je     209 <strcmp+0x27>
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 10             	movzbl (%eax),%edx
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	38 c2                	cmp    %al,%dl
 207:	74 de                	je     1e7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	0f b6 00             	movzbl (%eax),%eax
 20f:	0f b6 d0             	movzbl %al,%edx
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	0f b6 00             	movzbl (%eax),%eax
 218:	0f b6 c0             	movzbl %al,%eax
 21b:	29 c2                	sub    %eax,%edx
 21d:	89 d0                	mov    %edx,%eax
}
 21f:	5d                   	pop    %ebp
 220:	c3                   	ret    

00000221 <strlen>:

uint
strlen(char *s)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 227:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 22e:	eb 04                	jmp    234 <strlen+0x13>
 230:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 234:	8b 55 fc             	mov    -0x4(%ebp),%edx
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	01 d0                	add    %edx,%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	84 c0                	test   %al,%al
 241:	75 ed                	jne    230 <strlen+0xf>
    ;
  return n;
 243:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 246:	c9                   	leave  
 247:	c3                   	ret    

00000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	55                   	push   %ebp
 249:	89 e5                	mov    %esp,%ebp
 24b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 24e:	8b 45 10             	mov    0x10(%ebp),%eax
 251:	89 44 24 08          	mov    %eax,0x8(%esp)
 255:	8b 45 0c             	mov    0xc(%ebp),%eax
 258:	89 44 24 04          	mov    %eax,0x4(%esp)
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	89 04 24             	mov    %eax,(%esp)
 262:	e8 26 ff ff ff       	call   18d <stosb>
  return dst;
 267:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26a:	c9                   	leave  
 26b:	c3                   	ret    

0000026c <strchr>:

char*
strchr(const char *s, char c)
{
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	83 ec 04             	sub    $0x4,%esp
 272:	8b 45 0c             	mov    0xc(%ebp),%eax
 275:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 278:	eb 14                	jmp    28e <strchr+0x22>
    if(*s == c)
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	0f b6 00             	movzbl (%eax),%eax
 280:	3a 45 fc             	cmp    -0x4(%ebp),%al
 283:	75 05                	jne    28a <strchr+0x1e>
      return (char*)s;
 285:	8b 45 08             	mov    0x8(%ebp),%eax
 288:	eb 13                	jmp    29d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 28a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	0f b6 00             	movzbl (%eax),%eax
 294:	84 c0                	test   %al,%al
 296:	75 e2                	jne    27a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 298:	b8 00 00 00 00       	mov    $0x0,%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <gets>:

char*
gets(char *buf, int max)
{
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ac:	eb 4c                	jmp    2fa <gets+0x5b>
    cc = read(0, &c, 1);
 2ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2b5:	00 
 2b6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2c4:	e8 44 01 00 00       	call   40d <read>
 2c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2d0:	7f 02                	jg     2d4 <gets+0x35>
      break;
 2d2:	eb 31                	jmp    305 <gets+0x66>
    buf[i++] = c;
 2d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d7:	8d 50 01             	lea    0x1(%eax),%edx
 2da:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2dd:	89 c2                	mov    %eax,%edx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	01 c2                	add    %eax,%edx
 2e4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ee:	3c 0a                	cmp    $0xa,%al
 2f0:	74 13                	je     305 <gets+0x66>
 2f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2f6:	3c 0d                	cmp    $0xd,%al
 2f8:	74 0b                	je     305 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fd:	83 c0 01             	add    $0x1,%eax
 300:	3b 45 0c             	cmp    0xc(%ebp),%eax
 303:	7c a9                	jl     2ae <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 305:	8b 55 f4             	mov    -0xc(%ebp),%edx
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	01 d0                	add    %edx,%eax
 30d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 310:	8b 45 08             	mov    0x8(%ebp),%eax
}
 313:	c9                   	leave  
 314:	c3                   	ret    

00000315 <stat>:

int
stat(char *n, struct stat *st)
{
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
 318:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 322:	00 
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	89 04 24             	mov    %eax,(%esp)
 329:	e8 07 01 00 00       	call   435 <open>
 32e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 331:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 335:	79 07                	jns    33e <stat+0x29>
    return -1;
 337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 33c:	eb 23                	jmp    361 <stat+0x4c>
  r = fstat(fd, st);
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 44 24 04          	mov    %eax,0x4(%esp)
 345:	8b 45 f4             	mov    -0xc(%ebp),%eax
 348:	89 04 24             	mov    %eax,(%esp)
 34b:	e8 fd 00 00 00       	call   44d <fstat>
 350:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 353:	8b 45 f4             	mov    -0xc(%ebp),%eax
 356:	89 04 24             	mov    %eax,(%esp)
 359:	e8 bf 00 00 00       	call   41d <close>
  return r;
 35e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 361:	c9                   	leave  
 362:	c3                   	ret    

00000363 <atoi>:

int
atoi(const char *s)
{
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp
 366:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 369:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 370:	eb 25                	jmp    397 <atoi+0x34>
    n = n*10 + *s++ - '0';
 372:	8b 55 fc             	mov    -0x4(%ebp),%edx
 375:	89 d0                	mov    %edx,%eax
 377:	c1 e0 02             	shl    $0x2,%eax
 37a:	01 d0                	add    %edx,%eax
 37c:	01 c0                	add    %eax,%eax
 37e:	89 c1                	mov    %eax,%ecx
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	8d 50 01             	lea    0x1(%eax),%edx
 386:	89 55 08             	mov    %edx,0x8(%ebp)
 389:	0f b6 00             	movzbl (%eax),%eax
 38c:	0f be c0             	movsbl %al,%eax
 38f:	01 c8                	add    %ecx,%eax
 391:	83 e8 30             	sub    $0x30,%eax
 394:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	0f b6 00             	movzbl (%eax),%eax
 39d:	3c 2f                	cmp    $0x2f,%al
 39f:	7e 0a                	jle    3ab <atoi+0x48>
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	3c 39                	cmp    $0x39,%al
 3a9:	7e c7                	jle    372 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ae:	c9                   	leave  
 3af:	c3                   	ret    

000003b0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3c2:	eb 17                	jmp    3db <memmove+0x2b>
    *dst++ = *src++;
 3c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3c7:	8d 50 01             	lea    0x1(%eax),%edx
 3ca:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3cd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3d0:	8d 4a 01             	lea    0x1(%edx),%ecx
 3d3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3d6:	0f b6 12             	movzbl (%edx),%edx
 3d9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3db:	8b 45 10             	mov    0x10(%ebp),%eax
 3de:	8d 50 ff             	lea    -0x1(%eax),%edx
 3e1:	89 55 10             	mov    %edx,0x10(%ebp)
 3e4:	85 c0                	test   %eax,%eax
 3e6:	7f dc                	jg     3c4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3eb:	c9                   	leave  
 3ec:	c3                   	ret    

000003ed <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3ed:	b8 01 00 00 00       	mov    $0x1,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <exit>:
SYSCALL(exit)
 3f5:	b8 02 00 00 00       	mov    $0x2,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <wait>:
SYSCALL(wait)
 3fd:	b8 03 00 00 00       	mov    $0x3,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <pipe>:
SYSCALL(pipe)
 405:	b8 04 00 00 00       	mov    $0x4,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <read>:
SYSCALL(read)
 40d:	b8 05 00 00 00       	mov    $0x5,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <write>:
SYSCALL(write)
 415:	b8 10 00 00 00       	mov    $0x10,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <close>:
SYSCALL(close)
 41d:	b8 15 00 00 00       	mov    $0x15,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <kill>:
SYSCALL(kill)
 425:	b8 06 00 00 00       	mov    $0x6,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <exec>:
SYSCALL(exec)
 42d:	b8 07 00 00 00       	mov    $0x7,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <open>:
SYSCALL(open)
 435:	b8 0f 00 00 00       	mov    $0xf,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <mknod>:
SYSCALL(mknod)
 43d:	b8 11 00 00 00       	mov    $0x11,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <unlink>:
SYSCALL(unlink)
 445:	b8 12 00 00 00       	mov    $0x12,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <fstat>:
SYSCALL(fstat)
 44d:	b8 08 00 00 00       	mov    $0x8,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <link>:
SYSCALL(link)
 455:	b8 13 00 00 00       	mov    $0x13,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <mkdir>:
SYSCALL(mkdir)
 45d:	b8 14 00 00 00       	mov    $0x14,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <chdir>:
SYSCALL(chdir)
 465:	b8 09 00 00 00       	mov    $0x9,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <dup>:
SYSCALL(dup)
 46d:	b8 0a 00 00 00       	mov    $0xa,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <getpid>:
SYSCALL(getpid)
 475:	b8 0b 00 00 00       	mov    $0xb,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <sbrk>:
SYSCALL(sbrk)
 47d:	b8 0c 00 00 00       	mov    $0xc,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <sleep>:
SYSCALL(sleep)
 485:	b8 0d 00 00 00       	mov    $0xd,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <uptime>:
SYSCALL(uptime)
 48d:	b8 0e 00 00 00       	mov    $0xe,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <halt>:
SYSCALL(halt)
 495:	b8 16 00 00 00       	mov    $0x16,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <date>:
SYSCALL(date)
 49d:	b8 17 00 00 00       	mov    $0x17,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <getuid>:
SYSCALL(getuid)
 4a5:	b8 18 00 00 00       	mov    $0x18,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <getgid>:
SYSCALL(getgid)
 4ad:	b8 19 00 00 00       	mov    $0x19,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <getppid>:
SYSCALL(getppid)
 4b5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <setuid>:
SYSCALL(setuid)
 4bd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <setgid>:
SYSCALL(setgid)
 4c5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <getprocs>:
SYSCALL(getprocs)
 4cd:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 18             	sub    $0x18,%esp
 4db:	8b 45 0c             	mov    0xc(%ebp),%eax
 4de:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e8:	00 
 4e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	89 04 24             	mov    %eax,(%esp)
 4f6:	e8 1a ff ff ff       	call   415 <write>
}
 4fb:	c9                   	leave  
 4fc:	c3                   	ret    

000004fd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4fd:	55                   	push   %ebp
 4fe:	89 e5                	mov    %esp,%ebp
 500:	56                   	push   %esi
 501:	53                   	push   %ebx
 502:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 505:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 50c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 510:	74 17                	je     529 <printint+0x2c>
 512:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 516:	79 11                	jns    529 <printint+0x2c>
    neg = 1;
 518:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 51f:	8b 45 0c             	mov    0xc(%ebp),%eax
 522:	f7 d8                	neg    %eax
 524:	89 45 ec             	mov    %eax,-0x14(%ebp)
 527:	eb 06                	jmp    52f <printint+0x32>
  } else {
    x = xx;
 529:	8b 45 0c             	mov    0xc(%ebp),%eax
 52c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 52f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 536:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 539:	8d 41 01             	lea    0x1(%ecx),%eax
 53c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 53f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 542:	8b 45 ec             	mov    -0x14(%ebp),%eax
 545:	ba 00 00 00 00       	mov    $0x0,%edx
 54a:	f7 f3                	div    %ebx
 54c:	89 d0                	mov    %edx,%eax
 54e:	0f b6 80 8c 0c 00 00 	movzbl 0xc8c(%eax),%eax
 555:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 559:	8b 75 10             	mov    0x10(%ebp),%esi
 55c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55f:	ba 00 00 00 00       	mov    $0x0,%edx
 564:	f7 f6                	div    %esi
 566:	89 45 ec             	mov    %eax,-0x14(%ebp)
 569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56d:	75 c7                	jne    536 <printint+0x39>
  if(neg)
 56f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 573:	74 10                	je     585 <printint+0x88>
    buf[i++] = '-';
 575:	8b 45 f4             	mov    -0xc(%ebp),%eax
 578:	8d 50 01             	lea    0x1(%eax),%edx
 57b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 57e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 583:	eb 1f                	jmp    5a4 <printint+0xa7>
 585:	eb 1d                	jmp    5a4 <printint+0xa7>
    putc(fd, buf[i]);
 587:	8d 55 dc             	lea    -0x24(%ebp),%edx
 58a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58d:	01 d0                	add    %edx,%eax
 58f:	0f b6 00             	movzbl (%eax),%eax
 592:	0f be c0             	movsbl %al,%eax
 595:	89 44 24 04          	mov    %eax,0x4(%esp)
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	89 04 24             	mov    %eax,(%esp)
 59f:	e8 31 ff ff ff       	call   4d5 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5a4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ac:	79 d9                	jns    587 <printint+0x8a>
    putc(fd, buf[i]);
}
 5ae:	83 c4 30             	add    $0x30,%esp
 5b1:	5b                   	pop    %ebx
 5b2:	5e                   	pop    %esi
 5b3:	5d                   	pop    %ebp
 5b4:	c3                   	ret    

000005b5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5b5:	55                   	push   %ebp
 5b6:	89 e5                	mov    %esp,%ebp
 5b8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5c2:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c5:	83 c0 04             	add    $0x4,%eax
 5c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5d2:	e9 7c 01 00 00       	jmp    753 <printf+0x19e>
    c = fmt[i] & 0xff;
 5d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 5da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	25 ff 00 00 00       	and    $0xff,%eax
 5ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f1:	75 2c                	jne    61f <printf+0x6a>
      if(c == '%'){
 5f3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f7:	75 0c                	jne    605 <printf+0x50>
        state = '%';
 5f9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 600:	e9 4a 01 00 00       	jmp    74f <printf+0x19a>
      } else {
        putc(fd, c);
 605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 608:	0f be c0             	movsbl %al,%eax
 60b:	89 44 24 04          	mov    %eax,0x4(%esp)
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	89 04 24             	mov    %eax,(%esp)
 615:	e8 bb fe ff ff       	call   4d5 <putc>
 61a:	e9 30 01 00 00       	jmp    74f <printf+0x19a>
      }
    } else if(state == '%'){
 61f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 623:	0f 85 26 01 00 00    	jne    74f <printf+0x19a>
      if(c == 'd'){
 629:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 62d:	75 2d                	jne    65c <printf+0xa7>
        printint(fd, *ap, 10, 1);
 62f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 632:	8b 00                	mov    (%eax),%eax
 634:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 63b:	00 
 63c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 643:	00 
 644:	89 44 24 04          	mov    %eax,0x4(%esp)
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	89 04 24             	mov    %eax,(%esp)
 64e:	e8 aa fe ff ff       	call   4fd <printint>
        ap++;
 653:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 657:	e9 ec 00 00 00       	jmp    748 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 65c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 660:	74 06                	je     668 <printf+0xb3>
 662:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 666:	75 2d                	jne    695 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 668:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66b:	8b 00                	mov    (%eax),%eax
 66d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 674:	00 
 675:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 67c:	00 
 67d:	89 44 24 04          	mov    %eax,0x4(%esp)
 681:	8b 45 08             	mov    0x8(%ebp),%eax
 684:	89 04 24             	mov    %eax,(%esp)
 687:	e8 71 fe ff ff       	call   4fd <printint>
        ap++;
 68c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 690:	e9 b3 00 00 00       	jmp    748 <printf+0x193>
      } else if(c == 's'){
 695:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 699:	75 45                	jne    6e0 <printf+0x12b>
        s = (char*)*ap;
 69b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69e:	8b 00                	mov    (%eax),%eax
 6a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ab:	75 09                	jne    6b6 <printf+0x101>
          s = "(null)";
 6ad:	c7 45 f4 3c 0a 00 00 	movl   $0xa3c,-0xc(%ebp)
        while(*s != 0){
 6b4:	eb 1e                	jmp    6d4 <printf+0x11f>
 6b6:	eb 1c                	jmp    6d4 <printf+0x11f>
          putc(fd, *s);
 6b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bb:	0f b6 00             	movzbl (%eax),%eax
 6be:	0f be c0             	movsbl %al,%eax
 6c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c5:	8b 45 08             	mov    0x8(%ebp),%eax
 6c8:	89 04 24             	mov    %eax,(%esp)
 6cb:	e8 05 fe ff ff       	call   4d5 <putc>
          s++;
 6d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d7:	0f b6 00             	movzbl (%eax),%eax
 6da:	84 c0                	test   %al,%al
 6dc:	75 da                	jne    6b8 <printf+0x103>
 6de:	eb 68                	jmp    748 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6e0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e4:	75 1d                	jne    703 <printf+0x14e>
        putc(fd, *ap);
 6e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e9:	8b 00                	mov    (%eax),%eax
 6eb:	0f be c0             	movsbl %al,%eax
 6ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f2:	8b 45 08             	mov    0x8(%ebp),%eax
 6f5:	89 04 24             	mov    %eax,(%esp)
 6f8:	e8 d8 fd ff ff       	call   4d5 <putc>
        ap++;
 6fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 701:	eb 45                	jmp    748 <printf+0x193>
      } else if(c == '%'){
 703:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 707:	75 17                	jne    720 <printf+0x16b>
        putc(fd, c);
 709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70c:	0f be c0             	movsbl %al,%eax
 70f:	89 44 24 04          	mov    %eax,0x4(%esp)
 713:	8b 45 08             	mov    0x8(%ebp),%eax
 716:	89 04 24             	mov    %eax,(%esp)
 719:	e8 b7 fd ff ff       	call   4d5 <putc>
 71e:	eb 28                	jmp    748 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 720:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 727:	00 
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 a2 fd ff ff       	call   4d5 <putc>
        putc(fd, c);
 733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 736:	0f be c0             	movsbl %al,%eax
 739:	89 44 24 04          	mov    %eax,0x4(%esp)
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	89 04 24             	mov    %eax,(%esp)
 743:	e8 8d fd ff ff       	call   4d5 <putc>
      }
      state = 0;
 748:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 74f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 753:	8b 55 0c             	mov    0xc(%ebp),%edx
 756:	8b 45 f0             	mov    -0x10(%ebp),%eax
 759:	01 d0                	add    %edx,%eax
 75b:	0f b6 00             	movzbl (%eax),%eax
 75e:	84 c0                	test   %al,%al
 760:	0f 85 71 fe ff ff    	jne    5d7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 766:	c9                   	leave  
 767:	c3                   	ret    

00000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	55                   	push   %ebp
 769:	89 e5                	mov    %esp,%ebp
 76b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	8b 45 08             	mov    0x8(%ebp),%eax
 771:	83 e8 08             	sub    $0x8,%eax
 774:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 777:	a1 a8 0c 00 00       	mov    0xca8,%eax
 77c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 77f:	eb 24                	jmp    7a5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 789:	77 12                	ja     79d <free+0x35>
 78b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 791:	77 24                	ja     7b7 <free+0x4f>
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 00                	mov    (%eax),%eax
 798:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 79b:	77 1a                	ja     7b7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ab:	76 d4                	jbe    781 <free+0x19>
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b5:	76 ca                	jbe    781 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	8b 40 04             	mov    0x4(%eax),%eax
 7bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c7:	01 c2                	add    %eax,%edx
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	39 c2                	cmp    %eax,%edx
 7d0:	75 24                	jne    7f6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	8b 50 04             	mov    0x4(%eax),%edx
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	8b 40 04             	mov    0x4(%eax),%eax
 7e0:	01 c2                	add    %eax,%edx
 7e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7eb:	8b 00                	mov    (%eax),%eax
 7ed:	8b 10                	mov    (%eax),%edx
 7ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f2:	89 10                	mov    %edx,(%eax)
 7f4:	eb 0a                	jmp    800 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f9:	8b 10                	mov    (%eax),%edx
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 40 04             	mov    0x4(%eax),%eax
 806:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	01 d0                	add    %edx,%eax
 812:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 815:	75 20                	jne    837 <free+0xcf>
    p->s.size += bp->s.size;
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	8b 50 04             	mov    0x4(%eax),%edx
 81d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 820:	8b 40 04             	mov    0x4(%eax),%eax
 823:	01 c2                	add    %eax,%edx
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	8b 10                	mov    (%eax),%edx
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	89 10                	mov    %edx,(%eax)
 835:	eb 08                	jmp    83f <free+0xd7>
  } else
    p->s.ptr = bp;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83d:	89 10                	mov    %edx,(%eax)
  freep = p;
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	a3 a8 0c 00 00       	mov    %eax,0xca8
}
 847:	c9                   	leave  
 848:	c3                   	ret    

00000849 <morecore>:

static Header*
morecore(uint nu)
{
 849:	55                   	push   %ebp
 84a:	89 e5                	mov    %esp,%ebp
 84c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 84f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 856:	77 07                	ja     85f <morecore+0x16>
    nu = 4096;
 858:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	c1 e0 03             	shl    $0x3,%eax
 865:	89 04 24             	mov    %eax,(%esp)
 868:	e8 10 fc ff ff       	call   47d <sbrk>
 86d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 870:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 874:	75 07                	jne    87d <morecore+0x34>
    return 0;
 876:	b8 00 00 00 00       	mov    $0x0,%eax
 87b:	eb 22                	jmp    89f <morecore+0x56>
  hp = (Header*)p;
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 883:	8b 45 f0             	mov    -0x10(%ebp),%eax
 886:	8b 55 08             	mov    0x8(%ebp),%edx
 889:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88f:	83 c0 08             	add    $0x8,%eax
 892:	89 04 24             	mov    %eax,(%esp)
 895:	e8 ce fe ff ff       	call   768 <free>
  return freep;
 89a:	a1 a8 0c 00 00       	mov    0xca8,%eax
}
 89f:	c9                   	leave  
 8a0:	c3                   	ret    

000008a1 <malloc>:

void*
malloc(uint nbytes)
{
 8a1:	55                   	push   %ebp
 8a2:	89 e5                	mov    %esp,%ebp
 8a4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a7:	8b 45 08             	mov    0x8(%ebp),%eax
 8aa:	83 c0 07             	add    $0x7,%eax
 8ad:	c1 e8 03             	shr    $0x3,%eax
 8b0:	83 c0 01             	add    $0x1,%eax
 8b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8b6:	a1 a8 0c 00 00       	mov    0xca8,%eax
 8bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8c2:	75 23                	jne    8e7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8c4:	c7 45 f0 a0 0c 00 00 	movl   $0xca0,-0x10(%ebp)
 8cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ce:	a3 a8 0c 00 00       	mov    %eax,0xca8
 8d3:	a1 a8 0c 00 00       	mov    0xca8,%eax
 8d8:	a3 a0 0c 00 00       	mov    %eax,0xca0
    base.s.size = 0;
 8dd:	c7 05 a4 0c 00 00 00 	movl   $0x0,0xca4
 8e4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ea:	8b 00                	mov    (%eax),%eax
 8ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	8b 40 04             	mov    0x4(%eax),%eax
 8f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f8:	72 4d                	jb     947 <malloc+0xa6>
      if(p->s.size == nunits)
 8fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fd:	8b 40 04             	mov    0x4(%eax),%eax
 900:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 903:	75 0c                	jne    911 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	8b 10                	mov    (%eax),%edx
 90a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90d:	89 10                	mov    %edx,(%eax)
 90f:	eb 26                	jmp    937 <malloc+0x96>
      else {
        p->s.size -= nunits;
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	2b 45 ec             	sub    -0x14(%ebp),%eax
 91a:	89 c2                	mov    %eax,%edx
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 922:	8b 45 f4             	mov    -0xc(%ebp),%eax
 925:	8b 40 04             	mov    0x4(%eax),%eax
 928:	c1 e0 03             	shl    $0x3,%eax
 92b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	8b 55 ec             	mov    -0x14(%ebp),%edx
 934:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 937:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93a:	a3 a8 0c 00 00       	mov    %eax,0xca8
      return (void*)(p + 1);
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	83 c0 08             	add    $0x8,%eax
 945:	eb 38                	jmp    97f <malloc+0xde>
    }
    if(p == freep)
 947:	a1 a8 0c 00 00       	mov    0xca8,%eax
 94c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 94f:	75 1b                	jne    96c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 951:	8b 45 ec             	mov    -0x14(%ebp),%eax
 954:	89 04 24             	mov    %eax,(%esp)
 957:	e8 ed fe ff ff       	call   849 <morecore>
 95c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 95f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 963:	75 07                	jne    96c <malloc+0xcb>
        return 0;
 965:	b8 00 00 00 00       	mov    $0x0,%eax
 96a:	eb 13                	jmp    97f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	8b 00                	mov    (%eax),%eax
 977:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 97a:	e9 70 ff ff ff       	jmp    8ef <malloc+0x4e>
}
 97f:	c9                   	leave  
 980:	c3                   	ret    
