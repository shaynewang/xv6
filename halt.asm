
_halt:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
// halt the system.
#include "types.h"
#include "user.h"

int
main(void) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
  halt();
   6:	e8 0f 03 00 00       	call   31a <halt>
  return 0;
   b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10:	c9                   	leave  
  11:	c3                   	ret    

00000012 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  12:	55                   	push   %ebp
  13:	89 e5                	mov    %esp,%ebp
  15:	57                   	push   %edi
  16:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1a:	8b 55 10             	mov    0x10(%ebp),%edx
  1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  20:	89 cb                	mov    %ecx,%ebx
  22:	89 df                	mov    %ebx,%edi
  24:	89 d1                	mov    %edx,%ecx
  26:	fc                   	cld    
  27:	f3 aa                	rep stos %al,%es:(%edi)
  29:	89 ca                	mov    %ecx,%edx
  2b:	89 fb                	mov    %edi,%ebx
  2d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  30:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  33:	5b                   	pop    %ebx
  34:	5f                   	pop    %edi
  35:	5d                   	pop    %ebp
  36:	c3                   	ret    

00000037 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  37:	55                   	push   %ebp
  38:	89 e5                	mov    %esp,%ebp
  3a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  3d:	8b 45 08             	mov    0x8(%ebp),%eax
  40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  43:	90                   	nop
  44:	8b 45 08             	mov    0x8(%ebp),%eax
  47:	8d 50 01             	lea    0x1(%eax),%edx
  4a:	89 55 08             	mov    %edx,0x8(%ebp)
  4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  50:	8d 4a 01             	lea    0x1(%edx),%ecx
  53:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  56:	0f b6 12             	movzbl (%edx),%edx
  59:	88 10                	mov    %dl,(%eax)
  5b:	0f b6 00             	movzbl (%eax),%eax
  5e:	84 c0                	test   %al,%al
  60:	75 e2                	jne    44 <strcpy+0xd>
    ;
  return os;
  62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  65:	c9                   	leave  
  66:	c3                   	ret    

00000067 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  67:	55                   	push   %ebp
  68:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  6a:	eb 08                	jmp    74 <strcmp+0xd>
    p++, q++;
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  74:	8b 45 08             	mov    0x8(%ebp),%eax
  77:	0f b6 00             	movzbl (%eax),%eax
  7a:	84 c0                	test   %al,%al
  7c:	74 10                	je     8e <strcmp+0x27>
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	0f b6 10             	movzbl (%eax),%edx
  84:	8b 45 0c             	mov    0xc(%ebp),%eax
  87:	0f b6 00             	movzbl (%eax),%eax
  8a:	38 c2                	cmp    %al,%dl
  8c:	74 de                	je     6c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  8e:	8b 45 08             	mov    0x8(%ebp),%eax
  91:	0f b6 00             	movzbl (%eax),%eax
  94:	0f b6 d0             	movzbl %al,%edx
  97:	8b 45 0c             	mov    0xc(%ebp),%eax
  9a:	0f b6 00             	movzbl (%eax),%eax
  9d:	0f b6 c0             	movzbl %al,%eax
  a0:	29 c2                	sub    %eax,%edx
  a2:	89 d0                	mov    %edx,%eax
}
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    

000000a6 <strlen>:

uint
strlen(char *s)
{
  a6:	55                   	push   %ebp
  a7:	89 e5                	mov    %esp,%ebp
  a9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  b3:	eb 04                	jmp    b9 <strlen+0x13>
  b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  b9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  bc:	8b 45 08             	mov    0x8(%ebp),%eax
  bf:	01 d0                	add    %edx,%eax
  c1:	0f b6 00             	movzbl (%eax),%eax
  c4:	84 c0                	test   %al,%al
  c6:	75 ed                	jne    b5 <strlen+0xf>
    ;
  return n;
  c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cb:	c9                   	leave  
  cc:	c3                   	ret    

000000cd <memset>:

void*
memset(void *dst, int c, uint n)
{
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  d3:	8b 45 10             	mov    0x10(%ebp),%eax
  d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	89 04 24             	mov    %eax,(%esp)
  e7:	e8 26 ff ff ff       	call   12 <stosb>
  return dst;
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
  ef:	c9                   	leave  
  f0:	c3                   	ret    

000000f1 <strchr>:

char*
strchr(const char *s, char c)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  f4:	83 ec 04             	sub    $0x4,%esp
  f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  fa:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  fd:	eb 14                	jmp    113 <strchr+0x22>
    if(*s == c)
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	0f b6 00             	movzbl (%eax),%eax
 105:	3a 45 fc             	cmp    -0x4(%ebp),%al
 108:	75 05                	jne    10f <strchr+0x1e>
      return (char*)s;
 10a:	8b 45 08             	mov    0x8(%ebp),%eax
 10d:	eb 13                	jmp    122 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 10f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	0f b6 00             	movzbl (%eax),%eax
 119:	84 c0                	test   %al,%al
 11b:	75 e2                	jne    ff <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 11d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 122:	c9                   	leave  
 123:	c3                   	ret    

00000124 <gets>:

char*
gets(char *buf, int max)
{
 124:	55                   	push   %ebp
 125:	89 e5                	mov    %esp,%ebp
 127:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 131:	eb 4c                	jmp    17f <gets+0x5b>
    cc = read(0, &c, 1);
 133:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 13a:	00 
 13b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 13e:	89 44 24 04          	mov    %eax,0x4(%esp)
 142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 149:	e8 44 01 00 00       	call   292 <read>
 14e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 151:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 155:	7f 02                	jg     159 <gets+0x35>
      break;
 157:	eb 31                	jmp    18a <gets+0x66>
    buf[i++] = c;
 159:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15c:	8d 50 01             	lea    0x1(%eax),%edx
 15f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 162:	89 c2                	mov    %eax,%edx
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	01 c2                	add    %eax,%edx
 169:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 16d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 16f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 173:	3c 0a                	cmp    $0xa,%al
 175:	74 13                	je     18a <gets+0x66>
 177:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17b:	3c 0d                	cmp    $0xd,%al
 17d:	74 0b                	je     18a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 182:	83 c0 01             	add    $0x1,%eax
 185:	3b 45 0c             	cmp    0xc(%ebp),%eax
 188:	7c a9                	jl     133 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 18a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	01 d0                	add    %edx,%eax
 192:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 195:	8b 45 08             	mov    0x8(%ebp),%eax
}
 198:	c9                   	leave  
 199:	c3                   	ret    

0000019a <stat>:

int
stat(char *n, struct stat *st)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a7:	00 
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	89 04 24             	mov    %eax,(%esp)
 1ae:	e8 07 01 00 00       	call   2ba <open>
 1b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1ba:	79 07                	jns    1c3 <stat+0x29>
    return -1;
 1bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c1:	eb 23                	jmp    1e6 <stat+0x4c>
  r = fstat(fd, st);
 1c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cd:	89 04 24             	mov    %eax,(%esp)
 1d0:	e8 fd 00 00 00       	call   2d2 <fstat>
 1d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 bf 00 00 00       	call   2a2 <close>
  return r;
 1e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e6:	c9                   	leave  
 1e7:	c3                   	ret    

000001e8 <atoi>:

int
atoi(const char *s)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f5:	eb 25                	jmp    21c <atoi+0x34>
    n = n*10 + *s++ - '0';
 1f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1fa:	89 d0                	mov    %edx,%eax
 1fc:	c1 e0 02             	shl    $0x2,%eax
 1ff:	01 d0                	add    %edx,%eax
 201:	01 c0                	add    %eax,%eax
 203:	89 c1                	mov    %eax,%ecx
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	8d 50 01             	lea    0x1(%eax),%edx
 20b:	89 55 08             	mov    %edx,0x8(%ebp)
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	0f be c0             	movsbl %al,%eax
 214:	01 c8                	add    %ecx,%eax
 216:	83 e8 30             	sub    $0x30,%eax
 219:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	0f b6 00             	movzbl (%eax),%eax
 222:	3c 2f                	cmp    $0x2f,%al
 224:	7e 0a                	jle    230 <atoi+0x48>
 226:	8b 45 08             	mov    0x8(%ebp),%eax
 229:	0f b6 00             	movzbl (%eax),%eax
 22c:	3c 39                	cmp    $0x39,%al
 22e:	7e c7                	jle    1f7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 230:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 233:	c9                   	leave  
 234:	c3                   	ret    

00000235 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 235:	55                   	push   %ebp
 236:	89 e5                	mov    %esp,%ebp
 238:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 241:	8b 45 0c             	mov    0xc(%ebp),%eax
 244:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 247:	eb 17                	jmp    260 <memmove+0x2b>
    *dst++ = *src++;
 249:	8b 45 fc             	mov    -0x4(%ebp),%eax
 24c:	8d 50 01             	lea    0x1(%eax),%edx
 24f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 252:	8b 55 f8             	mov    -0x8(%ebp),%edx
 255:	8d 4a 01             	lea    0x1(%edx),%ecx
 258:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 25b:	0f b6 12             	movzbl (%edx),%edx
 25e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 260:	8b 45 10             	mov    0x10(%ebp),%eax
 263:	8d 50 ff             	lea    -0x1(%eax),%edx
 266:	89 55 10             	mov    %edx,0x10(%ebp)
 269:	85 c0                	test   %eax,%eax
 26b:	7f dc                	jg     249 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 270:	c9                   	leave  
 271:	c3                   	ret    

00000272 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 272:	b8 01 00 00 00       	mov    $0x1,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <exit>:
SYSCALL(exit)
 27a:	b8 02 00 00 00       	mov    $0x2,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <wait>:
SYSCALL(wait)
 282:	b8 03 00 00 00       	mov    $0x3,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <pipe>:
SYSCALL(pipe)
 28a:	b8 04 00 00 00       	mov    $0x4,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <read>:
SYSCALL(read)
 292:	b8 05 00 00 00       	mov    $0x5,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <write>:
SYSCALL(write)
 29a:	b8 10 00 00 00       	mov    $0x10,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <close>:
SYSCALL(close)
 2a2:	b8 15 00 00 00       	mov    $0x15,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <kill>:
SYSCALL(kill)
 2aa:	b8 06 00 00 00       	mov    $0x6,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <exec>:
SYSCALL(exec)
 2b2:	b8 07 00 00 00       	mov    $0x7,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <open>:
SYSCALL(open)
 2ba:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <mknod>:
SYSCALL(mknod)
 2c2:	b8 11 00 00 00       	mov    $0x11,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <unlink>:
SYSCALL(unlink)
 2ca:	b8 12 00 00 00       	mov    $0x12,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <fstat>:
SYSCALL(fstat)
 2d2:	b8 08 00 00 00       	mov    $0x8,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <link>:
SYSCALL(link)
 2da:	b8 13 00 00 00       	mov    $0x13,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <mkdir>:
SYSCALL(mkdir)
 2e2:	b8 14 00 00 00       	mov    $0x14,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <chdir>:
SYSCALL(chdir)
 2ea:	b8 09 00 00 00       	mov    $0x9,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <dup>:
SYSCALL(dup)
 2f2:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <getpid>:
SYSCALL(getpid)
 2fa:	b8 0b 00 00 00       	mov    $0xb,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <sbrk>:
SYSCALL(sbrk)
 302:	b8 0c 00 00 00       	mov    $0xc,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <sleep>:
SYSCALL(sleep)
 30a:	b8 0d 00 00 00       	mov    $0xd,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <uptime>:
SYSCALL(uptime)
 312:	b8 0e 00 00 00       	mov    $0xe,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <halt>:
SYSCALL(halt)
 31a:	b8 16 00 00 00       	mov    $0x16,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <date>:
SYSCALL(date)
 322:	b8 17 00 00 00       	mov    $0x17,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <getuid>:
SYSCALL(getuid)
 32a:	b8 18 00 00 00       	mov    $0x18,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <getgid>:
SYSCALL(getgid)
 332:	b8 19 00 00 00       	mov    $0x19,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <getppid>:
SYSCALL(getppid)
 33a:	b8 1a 00 00 00       	mov    $0x1a,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <setuid>:
SYSCALL(setuid)
 342:	b8 1b 00 00 00       	mov    $0x1b,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <setgid>:
SYSCALL(setgid)
 34a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <getprocs>:
SYSCALL(getprocs)
 352:	b8 1d 00 00 00       	mov    $0x1d,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 18             	sub    $0x18,%esp
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 366:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 36d:	00 
 36e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 371:	89 44 24 04          	mov    %eax,0x4(%esp)
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	89 04 24             	mov    %eax,(%esp)
 37b:	e8 1a ff ff ff       	call   29a <write>
}
 380:	c9                   	leave  
 381:	c3                   	ret    

00000382 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	56                   	push   %esi
 386:	53                   	push   %ebx
 387:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 38a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 391:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 395:	74 17                	je     3ae <printint+0x2c>
 397:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 39b:	79 11                	jns    3ae <printint+0x2c>
    neg = 1;
 39d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a7:	f7 d8                	neg    %eax
 3a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ac:	eb 06                	jmp    3b4 <printint+0x32>
  } else {
    x = xx;
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3be:	8d 41 01             	lea    0x1(%ecx),%eax
 3c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ca:	ba 00 00 00 00       	mov    $0x0,%edx
 3cf:	f7 f3                	div    %ebx
 3d1:	89 d0                	mov    %edx,%eax
 3d3:	0f b6 80 58 0a 00 00 	movzbl 0xa58(%eax),%eax
 3da:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3de:	8b 75 10             	mov    0x10(%ebp),%esi
 3e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e4:	ba 00 00 00 00       	mov    $0x0,%edx
 3e9:	f7 f6                	div    %esi
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f2:	75 c7                	jne    3bb <printint+0x39>
  if(neg)
 3f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f8:	74 10                	je     40a <printint+0x88>
    buf[i++] = '-';
 3fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fd:	8d 50 01             	lea    0x1(%eax),%edx
 400:	89 55 f4             	mov    %edx,-0xc(%ebp)
 403:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 408:	eb 1f                	jmp    429 <printint+0xa7>
 40a:	eb 1d                	jmp    429 <printint+0xa7>
    putc(fd, buf[i]);
 40c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 40f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 412:	01 d0                	add    %edx,%eax
 414:	0f b6 00             	movzbl (%eax),%eax
 417:	0f be c0             	movsbl %al,%eax
 41a:	89 44 24 04          	mov    %eax,0x4(%esp)
 41e:	8b 45 08             	mov    0x8(%ebp),%eax
 421:	89 04 24             	mov    %eax,(%esp)
 424:	e8 31 ff ff ff       	call   35a <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 429:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 42d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 431:	79 d9                	jns    40c <printint+0x8a>
    putc(fd, buf[i]);
}
 433:	83 c4 30             	add    $0x30,%esp
 436:	5b                   	pop    %ebx
 437:	5e                   	pop    %esi
 438:	5d                   	pop    %ebp
 439:	c3                   	ret    

0000043a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 440:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 447:	8d 45 0c             	lea    0xc(%ebp),%eax
 44a:	83 c0 04             	add    $0x4,%eax
 44d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 450:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 457:	e9 7c 01 00 00       	jmp    5d8 <printf+0x19e>
    c = fmt[i] & 0xff;
 45c:	8b 55 0c             	mov    0xc(%ebp),%edx
 45f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 462:	01 d0                	add    %edx,%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	0f be c0             	movsbl %al,%eax
 46a:	25 ff 00 00 00       	and    $0xff,%eax
 46f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 472:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 476:	75 2c                	jne    4a4 <printf+0x6a>
      if(c == '%'){
 478:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 47c:	75 0c                	jne    48a <printf+0x50>
        state = '%';
 47e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 485:	e9 4a 01 00 00       	jmp    5d4 <printf+0x19a>
      } else {
        putc(fd, c);
 48a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 48d:	0f be c0             	movsbl %al,%eax
 490:	89 44 24 04          	mov    %eax,0x4(%esp)
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	89 04 24             	mov    %eax,(%esp)
 49a:	e8 bb fe ff ff       	call   35a <putc>
 49f:	e9 30 01 00 00       	jmp    5d4 <printf+0x19a>
      }
    } else if(state == '%'){
 4a4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4a8:	0f 85 26 01 00 00    	jne    5d4 <printf+0x19a>
      if(c == 'd'){
 4ae:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b2:	75 2d                	jne    4e1 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b7:	8b 00                	mov    (%eax),%eax
 4b9:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4c0:	00 
 4c1:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4c8:	00 
 4c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	89 04 24             	mov    %eax,(%esp)
 4d3:	e8 aa fe ff ff       	call   382 <printint>
        ap++;
 4d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4dc:	e9 ec 00 00 00       	jmp    5cd <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4e1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4e5:	74 06                	je     4ed <printf+0xb3>
 4e7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4eb:	75 2d                	jne    51a <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f0:	8b 00                	mov    (%eax),%eax
 4f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4f9:	00 
 4fa:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 501:	00 
 502:	89 44 24 04          	mov    %eax,0x4(%esp)
 506:	8b 45 08             	mov    0x8(%ebp),%eax
 509:	89 04 24             	mov    %eax,(%esp)
 50c:	e8 71 fe ff ff       	call   382 <printint>
        ap++;
 511:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 515:	e9 b3 00 00 00       	jmp    5cd <printf+0x193>
      } else if(c == 's'){
 51a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 51e:	75 45                	jne    565 <printf+0x12b>
        s = (char*)*ap;
 520:	8b 45 e8             	mov    -0x18(%ebp),%eax
 523:	8b 00                	mov    (%eax),%eax
 525:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 528:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 52c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 530:	75 09                	jne    53b <printf+0x101>
          s = "(null)";
 532:	c7 45 f4 06 08 00 00 	movl   $0x806,-0xc(%ebp)
        while(*s != 0){
 539:	eb 1e                	jmp    559 <printf+0x11f>
 53b:	eb 1c                	jmp    559 <printf+0x11f>
          putc(fd, *s);
 53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 540:	0f b6 00             	movzbl (%eax),%eax
 543:	0f be c0             	movsbl %al,%eax
 546:	89 44 24 04          	mov    %eax,0x4(%esp)
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
 54d:	89 04 24             	mov    %eax,(%esp)
 550:	e8 05 fe ff ff       	call   35a <putc>
          s++;
 555:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 559:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	84 c0                	test   %al,%al
 561:	75 da                	jne    53d <printf+0x103>
 563:	eb 68                	jmp    5cd <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 565:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 569:	75 1d                	jne    588 <printf+0x14e>
        putc(fd, *ap);
 56b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56e:	8b 00                	mov    (%eax),%eax
 570:	0f be c0             	movsbl %al,%eax
 573:	89 44 24 04          	mov    %eax,0x4(%esp)
 577:	8b 45 08             	mov    0x8(%ebp),%eax
 57a:	89 04 24             	mov    %eax,(%esp)
 57d:	e8 d8 fd ff ff       	call   35a <putc>
        ap++;
 582:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 586:	eb 45                	jmp    5cd <printf+0x193>
      } else if(c == '%'){
 588:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58c:	75 17                	jne    5a5 <printf+0x16b>
        putc(fd, c);
 58e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 591:	0f be c0             	movsbl %al,%eax
 594:	89 44 24 04          	mov    %eax,0x4(%esp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 04 24             	mov    %eax,(%esp)
 59e:	e8 b7 fd ff ff       	call   35a <putc>
 5a3:	eb 28                	jmp    5cd <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a5:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5ac:	00 
 5ad:	8b 45 08             	mov    0x8(%ebp),%eax
 5b0:	89 04 24             	mov    %eax,(%esp)
 5b3:	e8 a2 fd ff ff       	call   35a <putc>
        putc(fd, c);
 5b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5bb:	0f be c0             	movsbl %al,%eax
 5be:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	89 04 24             	mov    %eax,(%esp)
 5c8:	e8 8d fd ff ff       	call   35a <putc>
      }
      state = 0;
 5cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5d8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5de:	01 d0                	add    %edx,%eax
 5e0:	0f b6 00             	movzbl (%eax),%eax
 5e3:	84 c0                	test   %al,%al
 5e5:	0f 85 71 fe ff ff    	jne    45c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5eb:	c9                   	leave  
 5ec:	c3                   	ret    

000005ed <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5ed:	55                   	push   %ebp
 5ee:	89 e5                	mov    %esp,%ebp
 5f0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	83 e8 08             	sub    $0x8,%eax
 5f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5fc:	a1 74 0a 00 00       	mov    0xa74,%eax
 601:	89 45 fc             	mov    %eax,-0x4(%ebp)
 604:	eb 24                	jmp    62a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 606:	8b 45 fc             	mov    -0x4(%ebp),%eax
 609:	8b 00                	mov    (%eax),%eax
 60b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60e:	77 12                	ja     622 <free+0x35>
 610:	8b 45 f8             	mov    -0x8(%ebp),%eax
 613:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 616:	77 24                	ja     63c <free+0x4f>
 618:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61b:	8b 00                	mov    (%eax),%eax
 61d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 620:	77 1a                	ja     63c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 630:	76 d4                	jbe    606 <free+0x19>
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 63a:	76 ca                	jbe    606 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 63c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63f:	8b 40 04             	mov    0x4(%eax),%eax
 642:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	01 c2                	add    %eax,%edx
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	39 c2                	cmp    %eax,%edx
 655:	75 24                	jne    67b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	8b 50 04             	mov    0x4(%eax),%edx
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8b 00                	mov    (%eax),%eax
 662:	8b 40 04             	mov    0x4(%eax),%eax
 665:	01 c2                	add    %eax,%edx
 667:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	8b 00                	mov    (%eax),%eax
 672:	8b 10                	mov    (%eax),%edx
 674:	8b 45 f8             	mov    -0x8(%ebp),%eax
 677:	89 10                	mov    %edx,(%eax)
 679:	eb 0a                	jmp    685 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67e:	8b 10                	mov    (%eax),%edx
 680:	8b 45 f8             	mov    -0x8(%ebp),%eax
 683:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 40 04             	mov    0x4(%eax),%eax
 68b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	01 d0                	add    %edx,%eax
 697:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 69a:	75 20                	jne    6bc <free+0xcf>
    p->s.size += bp->s.size;
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	8b 50 04             	mov    0x4(%eax),%edx
 6a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a5:	8b 40 04             	mov    0x4(%eax),%eax
 6a8:	01 c2                	add    %eax,%edx
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b3:	8b 10                	mov    (%eax),%edx
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	89 10                	mov    %edx,(%eax)
 6ba:	eb 08                	jmp    6c4 <free+0xd7>
  } else
    p->s.ptr = bp;
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c2:	89 10                	mov    %edx,(%eax)
  freep = p;
 6c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c7:	a3 74 0a 00 00       	mov    %eax,0xa74
}
 6cc:	c9                   	leave  
 6cd:	c3                   	ret    

000006ce <morecore>:

static Header*
morecore(uint nu)
{
 6ce:	55                   	push   %ebp
 6cf:	89 e5                	mov    %esp,%ebp
 6d1:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6d4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6db:	77 07                	ja     6e4 <morecore+0x16>
    nu = 4096;
 6dd:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	c1 e0 03             	shl    $0x3,%eax
 6ea:	89 04 24             	mov    %eax,(%esp)
 6ed:	e8 10 fc ff ff       	call   302 <sbrk>
 6f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6f5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6f9:	75 07                	jne    702 <morecore+0x34>
    return 0;
 6fb:	b8 00 00 00 00       	mov    $0x0,%eax
 700:	eb 22                	jmp    724 <morecore+0x56>
  hp = (Header*)p;
 702:	8b 45 f4             	mov    -0xc(%ebp),%eax
 705:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 708:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70b:	8b 55 08             	mov    0x8(%ebp),%edx
 70e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 711:	8b 45 f0             	mov    -0x10(%ebp),%eax
 714:	83 c0 08             	add    $0x8,%eax
 717:	89 04 24             	mov    %eax,(%esp)
 71a:	e8 ce fe ff ff       	call   5ed <free>
  return freep;
 71f:	a1 74 0a 00 00       	mov    0xa74,%eax
}
 724:	c9                   	leave  
 725:	c3                   	ret    

00000726 <malloc>:

void*
malloc(uint nbytes)
{
 726:	55                   	push   %ebp
 727:	89 e5                	mov    %esp,%ebp
 729:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72c:	8b 45 08             	mov    0x8(%ebp),%eax
 72f:	83 c0 07             	add    $0x7,%eax
 732:	c1 e8 03             	shr    $0x3,%eax
 735:	83 c0 01             	add    $0x1,%eax
 738:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 73b:	a1 74 0a 00 00       	mov    0xa74,%eax
 740:	89 45 f0             	mov    %eax,-0x10(%ebp)
 743:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 747:	75 23                	jne    76c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 749:	c7 45 f0 6c 0a 00 00 	movl   $0xa6c,-0x10(%ebp)
 750:	8b 45 f0             	mov    -0x10(%ebp),%eax
 753:	a3 74 0a 00 00       	mov    %eax,0xa74
 758:	a1 74 0a 00 00       	mov    0xa74,%eax
 75d:	a3 6c 0a 00 00       	mov    %eax,0xa6c
    base.s.size = 0;
 762:	c7 05 70 0a 00 00 00 	movl   $0x0,0xa70
 769:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76f:	8b 00                	mov    (%eax),%eax
 771:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 77d:	72 4d                	jb     7cc <malloc+0xa6>
      if(p->s.size == nunits)
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	8b 40 04             	mov    0x4(%eax),%eax
 785:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 788:	75 0c                	jne    796 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 78a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78d:	8b 10                	mov    (%eax),%edx
 78f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 792:	89 10                	mov    %edx,(%eax)
 794:	eb 26                	jmp    7bc <malloc+0x96>
      else {
        p->s.size -= nunits;
 796:	8b 45 f4             	mov    -0xc(%ebp),%eax
 799:	8b 40 04             	mov    0x4(%eax),%eax
 79c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 79f:	89 c2                	mov    %eax,%edx
 7a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	8b 40 04             	mov    0x4(%eax),%eax
 7ad:	c1 e0 03             	shl    $0x3,%eax
 7b0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bf:	a3 74 0a 00 00       	mov    %eax,0xa74
      return (void*)(p + 1);
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	83 c0 08             	add    $0x8,%eax
 7ca:	eb 38                	jmp    804 <malloc+0xde>
    }
    if(p == freep)
 7cc:	a1 74 0a 00 00       	mov    0xa74,%eax
 7d1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7d4:	75 1b                	jne    7f1 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7d9:	89 04 24             	mov    %eax,(%esp)
 7dc:	e8 ed fe ff ff       	call   6ce <morecore>
 7e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e8:	75 07                	jne    7f1 <malloc+0xcb>
        return 0;
 7ea:	b8 00 00 00 00       	mov    $0x0,%eax
 7ef:	eb 13                	jmp    804 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7ff:	e9 70 ff ff ff       	jmp    774 <malloc+0x4e>
}
 804:	c9                   	leave  
 805:	c3                   	ret    
