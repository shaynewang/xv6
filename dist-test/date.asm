
_date:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "date.h"


int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 40             	sub    $0x40,%esp
  struct rtcdate r;
  if(date(&r)) {
   c:	8d 44 24 28          	lea    0x28(%esp),%eax
  10:	89 04 24             	mov    %eax,(%esp)
  13:	e8 76 03 00 00       	call   38e <date>
  18:	85 c0                	test   %eax,%eax
  1a:	74 19                	je     35 <main+0x35>
    printf(2,"date failed\n");
  1c:	c7 44 24 04 74 08 00 	movl   $0x874,0x4(%esp)
  23:	00 
  24:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  2b:	e8 76 04 00 00       	call   4a6 <printf>
    exit();
  30:	e8 b1 02 00 00       	call   2e6 <exit>
  }
  printf(1, "Current UTC time is: %d/%d/%d - %d:%d:%d\n",r.year, r.month, r.day, r.hour, r.minute, r.second);
  35:	8b 7c 24 28          	mov    0x28(%esp),%edi
  39:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  3d:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  41:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  45:	8b 54 24 38          	mov    0x38(%esp),%edx
  49:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  4d:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
  51:	89 74 24 18          	mov    %esi,0x18(%esp)
  55:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  59:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  61:	89 44 24 08          	mov    %eax,0x8(%esp)
  65:	c7 44 24 04 84 08 00 	movl   $0x884,0x4(%esp)
  6c:	00 
  6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  74:	e8 2d 04 00 00       	call   4a6 <printf>

  exit();
  79:	e8 68 02 00 00       	call   2e6 <exit>

0000007e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7e:	55                   	push   %ebp
  7f:	89 e5                	mov    %esp,%ebp
  81:	57                   	push   %edi
  82:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  86:	8b 55 10             	mov    0x10(%ebp),%edx
  89:	8b 45 0c             	mov    0xc(%ebp),%eax
  8c:	89 cb                	mov    %ecx,%ebx
  8e:	89 df                	mov    %ebx,%edi
  90:	89 d1                	mov    %edx,%ecx
  92:	fc                   	cld    
  93:	f3 aa                	rep stos %al,%es:(%edi)
  95:	89 ca                	mov    %ecx,%edx
  97:	89 fb                	mov    %edi,%ebx
  99:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9f:	5b                   	pop    %ebx
  a0:	5f                   	pop    %edi
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    

000000a3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a3:	55                   	push   %ebp
  a4:	89 e5                	mov    %esp,%ebp
  a6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  af:	90                   	nop
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	8d 50 01             	lea    0x1(%eax),%edx
  b6:	89 55 08             	mov    %edx,0x8(%ebp)
  b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  bf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  c2:	0f b6 12             	movzbl (%edx),%edx
  c5:	88 10                	mov    %dl,(%eax)
  c7:	0f b6 00             	movzbl (%eax),%eax
  ca:	84 c0                	test   %al,%al
  cc:	75 e2                	jne    b0 <strcpy+0xd>
    ;
  return os;
  ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d1:	c9                   	leave  
  d2:	c3                   	ret    

000000d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d3:	55                   	push   %ebp
  d4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d6:	eb 08                	jmp    e0 <strcmp+0xd>
    p++, q++;
  d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  e0:	8b 45 08             	mov    0x8(%ebp),%eax
  e3:	0f b6 00             	movzbl (%eax),%eax
  e6:	84 c0                	test   %al,%al
  e8:	74 10                	je     fa <strcmp+0x27>
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
  ed:	0f b6 10             	movzbl (%eax),%edx
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	0f b6 00             	movzbl (%eax),%eax
  f6:	38 c2                	cmp    %al,%dl
  f8:	74 de                	je     d8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  fa:	8b 45 08             	mov    0x8(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	0f b6 d0             	movzbl %al,%edx
 103:	8b 45 0c             	mov    0xc(%ebp),%eax
 106:	0f b6 00             	movzbl (%eax),%eax
 109:	0f b6 c0             	movzbl %al,%eax
 10c:	29 c2                	sub    %eax,%edx
 10e:	89 d0                	mov    %edx,%eax
}
 110:	5d                   	pop    %ebp
 111:	c3                   	ret    

00000112 <strlen>:

uint
strlen(char *s)
{
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 118:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11f:	eb 04                	jmp    125 <strlen+0x13>
 121:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 125:	8b 55 fc             	mov    -0x4(%ebp),%edx
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	01 d0                	add    %edx,%eax
 12d:	0f b6 00             	movzbl (%eax),%eax
 130:	84 c0                	test   %al,%al
 132:	75 ed                	jne    121 <strlen+0xf>
    ;
  return n;
 134:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 137:	c9                   	leave  
 138:	c3                   	ret    

00000139 <memset>:

void*
memset(void *dst, int c, uint n)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 13f:	8b 45 10             	mov    0x10(%ebp),%eax
 142:	89 44 24 08          	mov    %eax,0x8(%esp)
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	89 44 24 04          	mov    %eax,0x4(%esp)
 14d:	8b 45 08             	mov    0x8(%ebp),%eax
 150:	89 04 24             	mov    %eax,(%esp)
 153:	e8 26 ff ff ff       	call   7e <stosb>
  return dst;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <strchr>:

char*
strchr(const char *s, char c)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	83 ec 04             	sub    $0x4,%esp
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 169:	eb 14                	jmp    17f <strchr+0x22>
    if(*s == c)
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	0f b6 00             	movzbl (%eax),%eax
 171:	3a 45 fc             	cmp    -0x4(%ebp),%al
 174:	75 05                	jne    17b <strchr+0x1e>
      return (char*)s;
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	eb 13                	jmp    18e <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 17b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	75 e2                	jne    16b <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 189:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 196:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19d:	eb 4c                	jmp    1eb <gets+0x5b>
    cc = read(0, &c, 1);
 19f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a6:	00 
 1a7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b5:	e8 44 01 00 00       	call   2fe <read>
 1ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c1:	7f 02                	jg     1c5 <gets+0x35>
      break;
 1c3:	eb 31                	jmp    1f6 <gets+0x66>
    buf[i++] = c;
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	8d 50 01             	lea    0x1(%eax),%edx
 1cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ce:	89 c2                	mov    %eax,%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 c2                	add    %eax,%edx
 1d5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1df:	3c 0a                	cmp    $0xa,%al
 1e1:	74 13                	je     1f6 <gets+0x66>
 1e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e7:	3c 0d                	cmp    $0xd,%al
 1e9:	74 0b                	je     1f6 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ee:	83 c0 01             	add    $0x1,%eax
 1f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f4:	7c a9                	jl     19f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	01 d0                	add    %edx,%eax
 1fe:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
}
 204:	c9                   	leave  
 205:	c3                   	ret    

00000206 <stat>:

int
stat(char *n, struct stat *st)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 213:	00 
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	89 04 24             	mov    %eax,(%esp)
 21a:	e8 07 01 00 00       	call   326 <open>
 21f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 222:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 226:	79 07                	jns    22f <stat+0x29>
    return -1;
 228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22d:	eb 23                	jmp    252 <stat+0x4c>
  r = fstat(fd, st);
 22f:	8b 45 0c             	mov    0xc(%ebp),%eax
 232:	89 44 24 04          	mov    %eax,0x4(%esp)
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	89 04 24             	mov    %eax,(%esp)
 23c:	e8 fd 00 00 00       	call   33e <fstat>
 241:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 244:	8b 45 f4             	mov    -0xc(%ebp),%eax
 247:	89 04 24             	mov    %eax,(%esp)
 24a:	e8 bf 00 00 00       	call   30e <close>
  return r;
 24f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 252:	c9                   	leave  
 253:	c3                   	ret    

00000254 <atoi>:

int
atoi(const char *s)
{
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 261:	eb 25                	jmp    288 <atoi+0x34>
    n = n*10 + *s++ - '0';
 263:	8b 55 fc             	mov    -0x4(%ebp),%edx
 266:	89 d0                	mov    %edx,%eax
 268:	c1 e0 02             	shl    $0x2,%eax
 26b:	01 d0                	add    %edx,%eax
 26d:	01 c0                	add    %eax,%eax
 26f:	89 c1                	mov    %eax,%ecx
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	8d 50 01             	lea    0x1(%eax),%edx
 277:	89 55 08             	mov    %edx,0x8(%ebp)
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	0f be c0             	movsbl %al,%eax
 280:	01 c8                	add    %ecx,%eax
 282:	83 e8 30             	sub    $0x30,%eax
 285:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	0f b6 00             	movzbl (%eax),%eax
 28e:	3c 2f                	cmp    $0x2f,%al
 290:	7e 0a                	jle    29c <atoi+0x48>
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	0f b6 00             	movzbl (%eax),%eax
 298:	3c 39                	cmp    $0x39,%al
 29a:	7e c7                	jle    263 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 29c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29f:	c9                   	leave  
 2a0:	c3                   	ret    

000002a1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a1:	55                   	push   %ebp
 2a2:	89 e5                	mov    %esp,%ebp
 2a4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b3:	eb 17                	jmp    2cc <memmove+0x2b>
    *dst++ = *src++;
 2b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b8:	8d 50 01             	lea    0x1(%eax),%edx
 2bb:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2be:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c1:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c7:	0f b6 12             	movzbl (%edx),%edx
 2ca:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2cc:	8b 45 10             	mov    0x10(%ebp),%eax
 2cf:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d2:	89 55 10             	mov    %edx,0x10(%ebp)
 2d5:	85 c0                	test   %eax,%eax
 2d7:	7f dc                	jg     2b5 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2dc:	c9                   	leave  
 2dd:	c3                   	ret    

000002de <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2de:	b8 01 00 00 00       	mov    $0x1,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <exit>:
SYSCALL(exit)
 2e6:	b8 02 00 00 00       	mov    $0x2,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <wait>:
SYSCALL(wait)
 2ee:	b8 03 00 00 00       	mov    $0x3,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <pipe>:
SYSCALL(pipe)
 2f6:	b8 04 00 00 00       	mov    $0x4,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <read>:
SYSCALL(read)
 2fe:	b8 05 00 00 00       	mov    $0x5,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <write>:
SYSCALL(write)
 306:	b8 10 00 00 00       	mov    $0x10,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <close>:
SYSCALL(close)
 30e:	b8 15 00 00 00       	mov    $0x15,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <kill>:
SYSCALL(kill)
 316:	b8 06 00 00 00       	mov    $0x6,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <exec>:
SYSCALL(exec)
 31e:	b8 07 00 00 00       	mov    $0x7,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <open>:
SYSCALL(open)
 326:	b8 0f 00 00 00       	mov    $0xf,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <mknod>:
SYSCALL(mknod)
 32e:	b8 11 00 00 00       	mov    $0x11,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <unlink>:
SYSCALL(unlink)
 336:	b8 12 00 00 00       	mov    $0x12,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <fstat>:
SYSCALL(fstat)
 33e:	b8 08 00 00 00       	mov    $0x8,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <link>:
SYSCALL(link)
 346:	b8 13 00 00 00       	mov    $0x13,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <mkdir>:
SYSCALL(mkdir)
 34e:	b8 14 00 00 00       	mov    $0x14,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <chdir>:
SYSCALL(chdir)
 356:	b8 09 00 00 00       	mov    $0x9,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <dup>:
SYSCALL(dup)
 35e:	b8 0a 00 00 00       	mov    $0xa,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <getpid>:
SYSCALL(getpid)
 366:	b8 0b 00 00 00       	mov    $0xb,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <sbrk>:
SYSCALL(sbrk)
 36e:	b8 0c 00 00 00       	mov    $0xc,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <sleep>:
SYSCALL(sleep)
 376:	b8 0d 00 00 00       	mov    $0xd,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <uptime>:
SYSCALL(uptime)
 37e:	b8 0e 00 00 00       	mov    $0xe,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <halt>:
SYSCALL(halt)
 386:	b8 16 00 00 00       	mov    $0x16,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <date>:
SYSCALL(date)
 38e:	b8 17 00 00 00       	mov    $0x17,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <getuid>:
SYSCALL(getuid)
 396:	b8 18 00 00 00       	mov    $0x18,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <getgid>:
SYSCALL(getgid)
 39e:	b8 19 00 00 00       	mov    $0x19,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <getppid>:
SYSCALL(getppid)
 3a6:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <setuid>:
SYSCALL(setuid)
 3ae:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <setgid>:
SYSCALL(setgid)
 3b6:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <getprocs>:
SYSCALL(getprocs)
 3be:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3c6:	55                   	push   %ebp
 3c7:	89 e5                	mov    %esp,%ebp
 3c9:	83 ec 18             	sub    $0x18,%esp
 3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cf:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3d2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3d9:	00 
 3da:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	89 04 24             	mov    %eax,(%esp)
 3e7:	e8 1a ff ff ff       	call   306 <write>
}
 3ec:	c9                   	leave  
 3ed:	c3                   	ret    

000003ee <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ee:	55                   	push   %ebp
 3ef:	89 e5                	mov    %esp,%ebp
 3f1:	56                   	push   %esi
 3f2:	53                   	push   %ebx
 3f3:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3fd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 401:	74 17                	je     41a <printint+0x2c>
 403:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 407:	79 11                	jns    41a <printint+0x2c>
    neg = 1;
 409:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 410:	8b 45 0c             	mov    0xc(%ebp),%eax
 413:	f7 d8                	neg    %eax
 415:	89 45 ec             	mov    %eax,-0x14(%ebp)
 418:	eb 06                	jmp    420 <printint+0x32>
  } else {
    x = xx;
 41a:	8b 45 0c             	mov    0xc(%ebp),%eax
 41d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 427:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 42a:	8d 41 01             	lea    0x1(%ecx),%eax
 42d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 430:	8b 5d 10             	mov    0x10(%ebp),%ebx
 433:	8b 45 ec             	mov    -0x14(%ebp),%eax
 436:	ba 00 00 00 00       	mov    $0x0,%edx
 43b:	f7 f3                	div    %ebx
 43d:	89 d0                	mov    %edx,%eax
 43f:	0f b6 80 00 0b 00 00 	movzbl 0xb00(%eax),%eax
 446:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 44a:	8b 75 10             	mov    0x10(%ebp),%esi
 44d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 450:	ba 00 00 00 00       	mov    $0x0,%edx
 455:	f7 f6                	div    %esi
 457:	89 45 ec             	mov    %eax,-0x14(%ebp)
 45a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 45e:	75 c7                	jne    427 <printint+0x39>
  if(neg)
 460:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 464:	74 10                	je     476 <printint+0x88>
    buf[i++] = '-';
 466:	8b 45 f4             	mov    -0xc(%ebp),%eax
 469:	8d 50 01             	lea    0x1(%eax),%edx
 46c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 474:	eb 1f                	jmp    495 <printint+0xa7>
 476:	eb 1d                	jmp    495 <printint+0xa7>
    putc(fd, buf[i]);
 478:	8d 55 dc             	lea    -0x24(%ebp),%edx
 47b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47e:	01 d0                	add    %edx,%eax
 480:	0f b6 00             	movzbl (%eax),%eax
 483:	0f be c0             	movsbl %al,%eax
 486:	89 44 24 04          	mov    %eax,0x4(%esp)
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	89 04 24             	mov    %eax,(%esp)
 490:	e8 31 ff ff ff       	call   3c6 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 495:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 499:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 49d:	79 d9                	jns    478 <printint+0x8a>
    putc(fd, buf[i]);
}
 49f:	83 c4 30             	add    $0x30,%esp
 4a2:	5b                   	pop    %ebx
 4a3:	5e                   	pop    %esi
 4a4:	5d                   	pop    %ebp
 4a5:	c3                   	ret    

000004a6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4a6:	55                   	push   %ebp
 4a7:	89 e5                	mov    %esp,%ebp
 4a9:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4b3:	8d 45 0c             	lea    0xc(%ebp),%eax
 4b6:	83 c0 04             	add    $0x4,%eax
 4b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4c3:	e9 7c 01 00 00       	jmp    644 <printf+0x19e>
    c = fmt[i] & 0xff;
 4c8:	8b 55 0c             	mov    0xc(%ebp),%edx
 4cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ce:	01 d0                	add    %edx,%eax
 4d0:	0f b6 00             	movzbl (%eax),%eax
 4d3:	0f be c0             	movsbl %al,%eax
 4d6:	25 ff 00 00 00       	and    $0xff,%eax
 4db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e2:	75 2c                	jne    510 <printf+0x6a>
      if(c == '%'){
 4e4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4e8:	75 0c                	jne    4f6 <printf+0x50>
        state = '%';
 4ea:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4f1:	e9 4a 01 00 00       	jmp    640 <printf+0x19a>
      } else {
        putc(fd, c);
 4f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	89 04 24             	mov    %eax,(%esp)
 506:	e8 bb fe ff ff       	call   3c6 <putc>
 50b:	e9 30 01 00 00       	jmp    640 <printf+0x19a>
      }
    } else if(state == '%'){
 510:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 514:	0f 85 26 01 00 00    	jne    640 <printf+0x19a>
      if(c == 'd'){
 51a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 51e:	75 2d                	jne    54d <printf+0xa7>
        printint(fd, *ap, 10, 1);
 520:	8b 45 e8             	mov    -0x18(%ebp),%eax
 523:	8b 00                	mov    (%eax),%eax
 525:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 52c:	00 
 52d:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 534:	00 
 535:	89 44 24 04          	mov    %eax,0x4(%esp)
 539:	8b 45 08             	mov    0x8(%ebp),%eax
 53c:	89 04 24             	mov    %eax,(%esp)
 53f:	e8 aa fe ff ff       	call   3ee <printint>
        ap++;
 544:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 548:	e9 ec 00 00 00       	jmp    639 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 54d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 551:	74 06                	je     559 <printf+0xb3>
 553:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 557:	75 2d                	jne    586 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 559:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55c:	8b 00                	mov    (%eax),%eax
 55e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 565:	00 
 566:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 56d:	00 
 56e:	89 44 24 04          	mov    %eax,0x4(%esp)
 572:	8b 45 08             	mov    0x8(%ebp),%eax
 575:	89 04 24             	mov    %eax,(%esp)
 578:	e8 71 fe ff ff       	call   3ee <printint>
        ap++;
 57d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 581:	e9 b3 00 00 00       	jmp    639 <printf+0x193>
      } else if(c == 's'){
 586:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 58a:	75 45                	jne    5d1 <printf+0x12b>
        s = (char*)*ap;
 58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58f:	8b 00                	mov    (%eax),%eax
 591:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 594:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 598:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59c:	75 09                	jne    5a7 <printf+0x101>
          s = "(null)";
 59e:	c7 45 f4 ae 08 00 00 	movl   $0x8ae,-0xc(%ebp)
        while(*s != 0){
 5a5:	eb 1e                	jmp    5c5 <printf+0x11f>
 5a7:	eb 1c                	jmp    5c5 <printf+0x11f>
          putc(fd, *s);
 5a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ac:	0f b6 00             	movzbl (%eax),%eax
 5af:	0f be c0             	movsbl %al,%eax
 5b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b6:	8b 45 08             	mov    0x8(%ebp),%eax
 5b9:	89 04 24             	mov    %eax,(%esp)
 5bc:	e8 05 fe ff ff       	call   3c6 <putc>
          s++;
 5c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c8:	0f b6 00             	movzbl (%eax),%eax
 5cb:	84 c0                	test   %al,%al
 5cd:	75 da                	jne    5a9 <printf+0x103>
 5cf:	eb 68                	jmp    639 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5d1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d5:	75 1d                	jne    5f4 <printf+0x14e>
        putc(fd, *ap);
 5d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5da:	8b 00                	mov    (%eax),%eax
 5dc:	0f be c0             	movsbl %al,%eax
 5df:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e3:	8b 45 08             	mov    0x8(%ebp),%eax
 5e6:	89 04 24             	mov    %eax,(%esp)
 5e9:	e8 d8 fd ff ff       	call   3c6 <putc>
        ap++;
 5ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f2:	eb 45                	jmp    639 <printf+0x193>
      } else if(c == '%'){
 5f4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f8:	75 17                	jne    611 <printf+0x16b>
        putc(fd, c);
 5fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fd:	0f be c0             	movsbl %al,%eax
 600:	89 44 24 04          	mov    %eax,0x4(%esp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 b7 fd ff ff       	call   3c6 <putc>
 60f:	eb 28                	jmp    639 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 611:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 618:	00 
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 a2 fd ff ff       	call   3c6 <putc>
        putc(fd, c);
 624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 627:	0f be c0             	movsbl %al,%eax
 62a:	89 44 24 04          	mov    %eax,0x4(%esp)
 62e:	8b 45 08             	mov    0x8(%ebp),%eax
 631:	89 04 24             	mov    %eax,(%esp)
 634:	e8 8d fd ff ff       	call   3c6 <putc>
      }
      state = 0;
 639:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 640:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 644:	8b 55 0c             	mov    0xc(%ebp),%edx
 647:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64a:	01 d0                	add    %edx,%eax
 64c:	0f b6 00             	movzbl (%eax),%eax
 64f:	84 c0                	test   %al,%al
 651:	0f 85 71 fe ff ff    	jne    4c8 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 657:	c9                   	leave  
 658:	c3                   	ret    

00000659 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 659:	55                   	push   %ebp
 65a:	89 e5                	mov    %esp,%ebp
 65c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65f:	8b 45 08             	mov    0x8(%ebp),%eax
 662:	83 e8 08             	sub    $0x8,%eax
 665:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 668:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 66d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 670:	eb 24                	jmp    696 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67a:	77 12                	ja     68e <free+0x35>
 67c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 682:	77 24                	ja     6a8 <free+0x4f>
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68c:	77 1a                	ja     6a8 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 691:	8b 00                	mov    (%eax),%eax
 693:	89 45 fc             	mov    %eax,-0x4(%ebp)
 696:	8b 45 f8             	mov    -0x8(%ebp),%eax
 699:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69c:	76 d4                	jbe    672 <free+0x19>
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	8b 00                	mov    (%eax),%eax
 6a3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a6:	76 ca                	jbe    672 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ab:	8b 40 04             	mov    0x4(%eax),%eax
 6ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	01 c2                	add    %eax,%edx
 6ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	39 c2                	cmp    %eax,%edx
 6c1:	75 24                	jne    6e7 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	8b 50 04             	mov    0x4(%eax),%edx
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	8b 40 04             	mov    0x4(%eax),%eax
 6d1:	01 c2                	add    %eax,%edx
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	8b 10                	mov    (%eax),%edx
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	89 10                	mov    %edx,(%eax)
 6e5:	eb 0a                	jmp    6f1 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ea:	8b 10                	mov    (%eax),%edx
 6ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ef:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 40 04             	mov    0x4(%eax),%eax
 6f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	01 d0                	add    %edx,%eax
 703:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 706:	75 20                	jne    728 <free+0xcf>
    p->s.size += bp->s.size;
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 50 04             	mov    0x4(%eax),%edx
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 40 04             	mov    0x4(%eax),%eax
 714:	01 c2                	add    %eax,%edx
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 71c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71f:	8b 10                	mov    (%eax),%edx
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	89 10                	mov    %edx,(%eax)
 726:	eb 08                	jmp    730 <free+0xd7>
  } else
    p->s.ptr = bp;
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 72e:	89 10                	mov    %edx,(%eax)
  freep = p;
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	a3 1c 0b 00 00       	mov    %eax,0xb1c
}
 738:	c9                   	leave  
 739:	c3                   	ret    

0000073a <morecore>:

static Header*
morecore(uint nu)
{
 73a:	55                   	push   %ebp
 73b:	89 e5                	mov    %esp,%ebp
 73d:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 740:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 747:	77 07                	ja     750 <morecore+0x16>
    nu = 4096;
 749:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 750:	8b 45 08             	mov    0x8(%ebp),%eax
 753:	c1 e0 03             	shl    $0x3,%eax
 756:	89 04 24             	mov    %eax,(%esp)
 759:	e8 10 fc ff ff       	call   36e <sbrk>
 75e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 761:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 765:	75 07                	jne    76e <morecore+0x34>
    return 0;
 767:	b8 00 00 00 00       	mov    $0x0,%eax
 76c:	eb 22                	jmp    790 <morecore+0x56>
  hp = (Header*)p;
 76e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 771:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 774:	8b 45 f0             	mov    -0x10(%ebp),%eax
 777:	8b 55 08             	mov    0x8(%ebp),%edx
 77a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 77d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 780:	83 c0 08             	add    $0x8,%eax
 783:	89 04 24             	mov    %eax,(%esp)
 786:	e8 ce fe ff ff       	call   659 <free>
  return freep;
 78b:	a1 1c 0b 00 00       	mov    0xb1c,%eax
}
 790:	c9                   	leave  
 791:	c3                   	ret    

00000792 <malloc>:

void*
malloc(uint nbytes)
{
 792:	55                   	push   %ebp
 793:	89 e5                	mov    %esp,%ebp
 795:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 798:	8b 45 08             	mov    0x8(%ebp),%eax
 79b:	83 c0 07             	add    $0x7,%eax
 79e:	c1 e8 03             	shr    $0x3,%eax
 7a1:	83 c0 01             	add    $0x1,%eax
 7a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a7:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 7ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b3:	75 23                	jne    7d8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7b5:	c7 45 f0 14 0b 00 00 	movl   $0xb14,-0x10(%ebp)
 7bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bf:	a3 1c 0b 00 00       	mov    %eax,0xb1c
 7c4:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 7c9:	a3 14 0b 00 00       	mov    %eax,0xb14
    base.s.size = 0;
 7ce:	c7 05 18 0b 00 00 00 	movl   $0x0,0xb18
 7d5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	8b 40 04             	mov    0x4(%eax),%eax
 7e6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e9:	72 4d                	jb     838 <malloc+0xa6>
      if(p->s.size == nunits)
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	8b 40 04             	mov    0x4(%eax),%eax
 7f1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f4:	75 0c                	jne    802 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f9:	8b 10                	mov    (%eax),%edx
 7fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fe:	89 10                	mov    %edx,(%eax)
 800:	eb 26                	jmp    828 <malloc+0x96>
      else {
        p->s.size -= nunits;
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	2b 45 ec             	sub    -0x14(%ebp),%eax
 80b:	89 c2                	mov    %eax,%edx
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	8b 40 04             	mov    0x4(%eax),%eax
 819:	c1 e0 03             	shl    $0x3,%eax
 81c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 55 ec             	mov    -0x14(%ebp),%edx
 825:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 828:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82b:	a3 1c 0b 00 00       	mov    %eax,0xb1c
      return (void*)(p + 1);
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	83 c0 08             	add    $0x8,%eax
 836:	eb 38                	jmp    870 <malloc+0xde>
    }
    if(p == freep)
 838:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 83d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 840:	75 1b                	jne    85d <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 842:	8b 45 ec             	mov    -0x14(%ebp),%eax
 845:	89 04 24             	mov    %eax,(%esp)
 848:	e8 ed fe ff ff       	call   73a <morecore>
 84d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 854:	75 07                	jne    85d <malloc+0xcb>
        return 0;
 856:	b8 00 00 00 00       	mov    $0x0,%eax
 85b:	eb 13                	jmp    870 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	89 45 f0             	mov    %eax,-0x10(%ebp)
 863:	8b 45 f4             	mov    -0xc(%ebp),%eax
 866:	8b 00                	mov    (%eax),%eax
 868:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 86b:	e9 70 ff ff ff       	jmp    7e0 <malloc+0x4e>
}
 870:	c9                   	leave  
 871:	c3                   	ret    
