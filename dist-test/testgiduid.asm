
_testgiduid:     file format elf32-i386


Disassembly of section .text:

00000000 <testgiduid>:

// Test GID and UID to be in the correct range
#ifdef CS333_P2
int
testgiduid(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
	uint uid, gid, ppid;

	uid = getuid();
   6:	e8 2d 04 00 00       	call   438 <getuid>
   b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	printf(2, "Current UID is : %d\n", uid);
   e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	c7 44 24 04 14 09 00 	movl   $0x914,0x4(%esp)
  1c:	00 
  1d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  24:	e8 1f 05 00 00       	call   548 <printf>
	printf(2, "Setting UID to 100\n");
  29:	c7 44 24 04 29 09 00 	movl   $0x929,0x4(%esp)
  30:	00 
  31:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  38:	e8 0b 05 00 00       	call   548 <printf>
	setuid(100);
  3d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  44:	e8 07 04 00 00       	call   450 <setuid>
	uid = getuid();
  49:	e8 ea 03 00 00       	call   438 <getuid>
  4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	printf(2, "Current UID is : %d\n", uid);
  51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	c7 44 24 04 14 09 00 	movl   $0x914,0x4(%esp)
  5f:	00 
  60:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  67:	e8 dc 04 00 00       	call   548 <printf>

	gid = getgid();
  6c:	e8 cf 03 00 00       	call   440 <getgid>
  71:	89 45 f0             	mov    %eax,-0x10(%ebp)
	printf(2, "Current GID is : %d\n", gid);
  74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  77:	89 44 24 08          	mov    %eax,0x8(%esp)
  7b:	c7 44 24 04 3d 09 00 	movl   $0x93d,0x4(%esp)
  82:	00 
  83:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8a:	e8 b9 04 00 00       	call   548 <printf>
	printf(2, "Setting GID to 100\n");
  8f:	c7 44 24 04 52 09 00 	movl   $0x952,0x4(%esp)
  96:	00 
  97:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  9e:	e8 a5 04 00 00       	call   548 <printf>
	setgid(100);
  a3:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  aa:	e8 a9 03 00 00       	call   458 <setgid>
	gid = getgid();
  af:	e8 8c 03 00 00       	call   440 <getgid>
  b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	printf(2, "Current UID is : %d\n", gid);
  b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  be:	c7 44 24 04 14 09 00 	movl   $0x914,0x4(%esp)
  c5:	00 
  c6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  cd:	e8 76 04 00 00       	call   548 <printf>

	ppid = getppid();
  d2:	e8 71 03 00 00       	call   448 <getppid>
  d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	printf(2, "My parent process is : %d\n", ppid);
  da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  e1:	c7 44 24 04 66 09 00 	movl   $0x966,0x4(%esp)
  e8:	00 
  e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  f0:	e8 53 04 00 00       	call   548 <printf>
	printf(2, "Done!\n");
  f5:	c7 44 24 04 81 09 00 	movl   $0x981,0x4(%esp)
  fc:	00 
  fd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 104:	e8 3f 04 00 00       	call   548 <printf>

	return 0;
 109:	b8 00 00 00 00       	mov    $0x0,%eax
}
 10e:	c9                   	leave  
 10f:	c3                   	ret    

00000110 <main>:

int
main(int argc, char *argv[])
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	83 e4 f0             	and    $0xfffffff0,%esp
	testgiduid();
 116:	e8 e5 fe ff ff       	call   0 <testgiduid>
	exit();
 11b:	e8 68 02 00 00       	call   388 <exit>

00000120 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	57                   	push   %edi
 124:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
 128:	8b 55 10             	mov    0x10(%ebp),%edx
 12b:	8b 45 0c             	mov    0xc(%ebp),%eax
 12e:	89 cb                	mov    %ecx,%ebx
 130:	89 df                	mov    %ebx,%edi
 132:	89 d1                	mov    %edx,%ecx
 134:	fc                   	cld    
 135:	f3 aa                	rep stos %al,%es:(%edi)
 137:	89 ca                	mov    %ecx,%edx
 139:	89 fb                	mov    %edi,%ebx
 13b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 141:	5b                   	pop    %ebx
 142:	5f                   	pop    %edi
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    

00000145 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 151:	90                   	nop
 152:	8b 45 08             	mov    0x8(%ebp),%eax
 155:	8d 50 01             	lea    0x1(%eax),%edx
 158:	89 55 08             	mov    %edx,0x8(%ebp)
 15b:	8b 55 0c             	mov    0xc(%ebp),%edx
 15e:	8d 4a 01             	lea    0x1(%edx),%ecx
 161:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 164:	0f b6 12             	movzbl (%edx),%edx
 167:	88 10                	mov    %dl,(%eax)
 169:	0f b6 00             	movzbl (%eax),%eax
 16c:	84 c0                	test   %al,%al
 16e:	75 e2                	jne    152 <strcpy+0xd>
    ;
  return os;
 170:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 173:	c9                   	leave  
 174:	c3                   	ret    

00000175 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 178:	eb 08                	jmp    182 <strcmp+0xd>
    p++, q++;
 17a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 182:	8b 45 08             	mov    0x8(%ebp),%eax
 185:	0f b6 00             	movzbl (%eax),%eax
 188:	84 c0                	test   %al,%al
 18a:	74 10                	je     19c <strcmp+0x27>
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	0f b6 10             	movzbl (%eax),%edx
 192:	8b 45 0c             	mov    0xc(%ebp),%eax
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	38 c2                	cmp    %al,%dl
 19a:	74 de                	je     17a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	0f b6 d0             	movzbl %al,%edx
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	0f b6 00             	movzbl (%eax),%eax
 1ab:	0f b6 c0             	movzbl %al,%eax
 1ae:	29 c2                	sub    %eax,%edx
 1b0:	89 d0                	mov    %edx,%eax
}
 1b2:	5d                   	pop    %ebp
 1b3:	c3                   	ret    

000001b4 <strlen>:

uint
strlen(char *s)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c1:	eb 04                	jmp    1c7 <strlen+0x13>
 1c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	01 d0                	add    %edx,%eax
 1cf:	0f b6 00             	movzbl (%eax),%eax
 1d2:	84 c0                	test   %al,%al
 1d4:	75 ed                	jne    1c3 <strlen+0xf>
    ;
  return n;
 1d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d9:	c9                   	leave  
 1da:	c3                   	ret    

000001db <memset>:

void*
memset(void *dst, int c, uint n)
{
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
 1de:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e1:	8b 45 10             	mov    0x10(%ebp),%eax
 1e4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 04 24             	mov    %eax,(%esp)
 1f5:	e8 26 ff ff ff       	call   120 <stosb>
  return dst;
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fd:	c9                   	leave  
 1fe:	c3                   	ret    

000001ff <strchr>:

char*
strchr(const char *s, char c)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 04             	sub    $0x4,%esp
 205:	8b 45 0c             	mov    0xc(%ebp),%eax
 208:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 20b:	eb 14                	jmp    221 <strchr+0x22>
    if(*s == c)
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	0f b6 00             	movzbl (%eax),%eax
 213:	3a 45 fc             	cmp    -0x4(%ebp),%al
 216:	75 05                	jne    21d <strchr+0x1e>
      return (char*)s;
 218:	8b 45 08             	mov    0x8(%ebp),%eax
 21b:	eb 13                	jmp    230 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 21d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	0f b6 00             	movzbl (%eax),%eax
 227:	84 c0                	test   %al,%al
 229:	75 e2                	jne    20d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 22b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 230:	c9                   	leave  
 231:	c3                   	ret    

00000232 <gets>:

char*
gets(char *buf, int max)
{
 232:	55                   	push   %ebp
 233:	89 e5                	mov    %esp,%ebp
 235:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23f:	eb 4c                	jmp    28d <gets+0x5b>
    cc = read(0, &c, 1);
 241:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 248:	00 
 249:	8d 45 ef             	lea    -0x11(%ebp),%eax
 24c:	89 44 24 04          	mov    %eax,0x4(%esp)
 250:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 257:	e8 44 01 00 00       	call   3a0 <read>
 25c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 263:	7f 02                	jg     267 <gets+0x35>
      break;
 265:	eb 31                	jmp    298 <gets+0x66>
    buf[i++] = c;
 267:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26a:	8d 50 01             	lea    0x1(%eax),%edx
 26d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 270:	89 c2                	mov    %eax,%edx
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	01 c2                	add    %eax,%edx
 277:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	3c 0a                	cmp    $0xa,%al
 283:	74 13                	je     298 <gets+0x66>
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0d                	cmp    $0xd,%al
 28b:	74 0b                	je     298 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 290:	83 c0 01             	add    $0x1,%eax
 293:	3b 45 0c             	cmp    0xc(%ebp),%eax
 296:	7c a9                	jl     241 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 298:	8b 55 f4             	mov    -0xc(%ebp),%edx
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	01 d0                	add    %edx,%eax
 2a0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <stat>:

int
stat(char *n, struct stat *st)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b5:	00 
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	89 04 24             	mov    %eax,(%esp)
 2bc:	e8 07 01 00 00       	call   3c8 <open>
 2c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c8:	79 07                	jns    2d1 <stat+0x29>
    return -1;
 2ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cf:	eb 23                	jmp    2f4 <stat+0x4c>
  r = fstat(fd, st);
 2d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 fd 00 00 00       	call   3e0 <fstat>
 2e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e9:	89 04 24             	mov    %eax,(%esp)
 2ec:	e8 bf 00 00 00       	call   3b0 <close>
  return r;
 2f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f4:	c9                   	leave  
 2f5:	c3                   	ret    

000002f6 <atoi>:

int
atoi(const char *s)
{
 2f6:	55                   	push   %ebp
 2f7:	89 e5                	mov    %esp,%ebp
 2f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 303:	eb 25                	jmp    32a <atoi+0x34>
    n = n*10 + *s++ - '0';
 305:	8b 55 fc             	mov    -0x4(%ebp),%edx
 308:	89 d0                	mov    %edx,%eax
 30a:	c1 e0 02             	shl    $0x2,%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	01 c0                	add    %eax,%eax
 311:	89 c1                	mov    %eax,%ecx
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	8d 50 01             	lea    0x1(%eax),%edx
 319:	89 55 08             	mov    %edx,0x8(%ebp)
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	0f be c0             	movsbl %al,%eax
 322:	01 c8                	add    %ecx,%eax
 324:	83 e8 30             	sub    $0x30,%eax
 327:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	3c 2f                	cmp    $0x2f,%al
 332:	7e 0a                	jle    33e <atoi+0x48>
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	0f b6 00             	movzbl (%eax),%eax
 33a:	3c 39                	cmp    $0x39,%al
 33c:	7e c7                	jle    305 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 341:	c9                   	leave  
 342:	c3                   	ret    

00000343 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 343:	55                   	push   %ebp
 344:	89 e5                	mov    %esp,%ebp
 346:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34f:	8b 45 0c             	mov    0xc(%ebp),%eax
 352:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 355:	eb 17                	jmp    36e <memmove+0x2b>
    *dst++ = *src++;
 357:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35a:	8d 50 01             	lea    0x1(%eax),%edx
 35d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 360:	8b 55 f8             	mov    -0x8(%ebp),%edx
 363:	8d 4a 01             	lea    0x1(%edx),%ecx
 366:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 369:	0f b6 12             	movzbl (%edx),%edx
 36c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36e:	8b 45 10             	mov    0x10(%ebp),%eax
 371:	8d 50 ff             	lea    -0x1(%eax),%edx
 374:	89 55 10             	mov    %edx,0x10(%ebp)
 377:	85 c0                	test   %eax,%eax
 379:	7f dc                	jg     357 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37e:	c9                   	leave  
 37f:	c3                   	ret    

00000380 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 380:	b8 01 00 00 00       	mov    $0x1,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <exit>:
SYSCALL(exit)
 388:	b8 02 00 00 00       	mov    $0x2,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <wait>:
SYSCALL(wait)
 390:	b8 03 00 00 00       	mov    $0x3,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <pipe>:
SYSCALL(pipe)
 398:	b8 04 00 00 00       	mov    $0x4,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <read>:
SYSCALL(read)
 3a0:	b8 05 00 00 00       	mov    $0x5,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <write>:
SYSCALL(write)
 3a8:	b8 10 00 00 00       	mov    $0x10,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <close>:
SYSCALL(close)
 3b0:	b8 15 00 00 00       	mov    $0x15,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <kill>:
SYSCALL(kill)
 3b8:	b8 06 00 00 00       	mov    $0x6,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <exec>:
SYSCALL(exec)
 3c0:	b8 07 00 00 00       	mov    $0x7,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <open>:
SYSCALL(open)
 3c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <mknod>:
SYSCALL(mknod)
 3d0:	b8 11 00 00 00       	mov    $0x11,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <unlink>:
SYSCALL(unlink)
 3d8:	b8 12 00 00 00       	mov    $0x12,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <fstat>:
SYSCALL(fstat)
 3e0:	b8 08 00 00 00       	mov    $0x8,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <link>:
SYSCALL(link)
 3e8:	b8 13 00 00 00       	mov    $0x13,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <mkdir>:
SYSCALL(mkdir)
 3f0:	b8 14 00 00 00       	mov    $0x14,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <chdir>:
SYSCALL(chdir)
 3f8:	b8 09 00 00 00       	mov    $0x9,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <dup>:
SYSCALL(dup)
 400:	b8 0a 00 00 00       	mov    $0xa,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <getpid>:
SYSCALL(getpid)
 408:	b8 0b 00 00 00       	mov    $0xb,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <sbrk>:
SYSCALL(sbrk)
 410:	b8 0c 00 00 00       	mov    $0xc,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <sleep>:
SYSCALL(sleep)
 418:	b8 0d 00 00 00       	mov    $0xd,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <uptime>:
SYSCALL(uptime)
 420:	b8 0e 00 00 00       	mov    $0xe,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <halt>:
SYSCALL(halt)
 428:	b8 16 00 00 00       	mov    $0x16,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <date>:
SYSCALL(date)
 430:	b8 17 00 00 00       	mov    $0x17,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <getuid>:
SYSCALL(getuid)
 438:	b8 18 00 00 00       	mov    $0x18,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <getgid>:
SYSCALL(getgid)
 440:	b8 19 00 00 00       	mov    $0x19,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <getppid>:
SYSCALL(getppid)
 448:	b8 1a 00 00 00       	mov    $0x1a,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <setuid>:
SYSCALL(setuid)
 450:	b8 1b 00 00 00       	mov    $0x1b,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <setgid>:
SYSCALL(setgid)
 458:	b8 1c 00 00 00       	mov    $0x1c,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <getprocs>:
SYSCALL(getprocs)
 460:	b8 1d 00 00 00       	mov    $0x1d,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	83 ec 18             	sub    $0x18,%esp
 46e:	8b 45 0c             	mov    0xc(%ebp),%eax
 471:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 474:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47b:	00 
 47c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 47f:	89 44 24 04          	mov    %eax,0x4(%esp)
 483:	8b 45 08             	mov    0x8(%ebp),%eax
 486:	89 04 24             	mov    %eax,(%esp)
 489:	e8 1a ff ff ff       	call   3a8 <write>
}
 48e:	c9                   	leave  
 48f:	c3                   	ret    

00000490 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	56                   	push   %esi
 494:	53                   	push   %ebx
 495:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 498:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 49f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4a3:	74 17                	je     4bc <printint+0x2c>
 4a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4a9:	79 11                	jns    4bc <printint+0x2c>
    neg = 1;
 4ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b5:	f7 d8                	neg    %eax
 4b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ba:	eb 06                	jmp    4c2 <printint+0x32>
  } else {
    x = xx;
 4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4c9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4cc:	8d 41 01             	lea    0x1(%ecx),%eax
 4cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d8:	ba 00 00 00 00       	mov    $0x0,%edx
 4dd:	f7 f3                	div    %ebx
 4df:	89 d0                	mov    %edx,%eax
 4e1:	0f b6 80 f4 0b 00 00 	movzbl 0xbf4(%eax),%eax
 4e8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ec:	8b 75 10             	mov    0x10(%ebp),%esi
 4ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f2:	ba 00 00 00 00       	mov    $0x0,%edx
 4f7:	f7 f6                	div    %esi
 4f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 500:	75 c7                	jne    4c9 <printint+0x39>
  if(neg)
 502:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 506:	74 10                	je     518 <printint+0x88>
    buf[i++] = '-';
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	8d 50 01             	lea    0x1(%eax),%edx
 50e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 511:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 516:	eb 1f                	jmp    537 <printint+0xa7>
 518:	eb 1d                	jmp    537 <printint+0xa7>
    putc(fd, buf[i]);
 51a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 51d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 520:	01 d0                	add    %edx,%eax
 522:	0f b6 00             	movzbl (%eax),%eax
 525:	0f be c0             	movsbl %al,%eax
 528:	89 44 24 04          	mov    %eax,0x4(%esp)
 52c:	8b 45 08             	mov    0x8(%ebp),%eax
 52f:	89 04 24             	mov    %eax,(%esp)
 532:	e8 31 ff ff ff       	call   468 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 537:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 53b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53f:	79 d9                	jns    51a <printint+0x8a>
    putc(fd, buf[i]);
}
 541:	83 c4 30             	add    $0x30,%esp
 544:	5b                   	pop    %ebx
 545:	5e                   	pop    %esi
 546:	5d                   	pop    %ebp
 547:	c3                   	ret    

00000548 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
 54b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 54e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 555:	8d 45 0c             	lea    0xc(%ebp),%eax
 558:	83 c0 04             	add    $0x4,%eax
 55b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 55e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 565:	e9 7c 01 00 00       	jmp    6e6 <printf+0x19e>
    c = fmt[i] & 0xff;
 56a:	8b 55 0c             	mov    0xc(%ebp),%edx
 56d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 570:	01 d0                	add    %edx,%eax
 572:	0f b6 00             	movzbl (%eax),%eax
 575:	0f be c0             	movsbl %al,%eax
 578:	25 ff 00 00 00       	and    $0xff,%eax
 57d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 580:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 584:	75 2c                	jne    5b2 <printf+0x6a>
      if(c == '%'){
 586:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58a:	75 0c                	jne    598 <printf+0x50>
        state = '%';
 58c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 593:	e9 4a 01 00 00       	jmp    6e2 <printf+0x19a>
      } else {
        putc(fd, c);
 598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59b:	0f be c0             	movsbl %al,%eax
 59e:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	89 04 24             	mov    %eax,(%esp)
 5a8:	e8 bb fe ff ff       	call   468 <putc>
 5ad:	e9 30 01 00 00       	jmp    6e2 <printf+0x19a>
      }
    } else if(state == '%'){
 5b2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5b6:	0f 85 26 01 00 00    	jne    6e2 <printf+0x19a>
      if(c == 'd'){
 5bc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5c0:	75 2d                	jne    5ef <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ce:	00 
 5cf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5d6:	00 
 5d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	89 04 24             	mov    %eax,(%esp)
 5e1:	e8 aa fe ff ff       	call   490 <printint>
        ap++;
 5e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ea:	e9 ec 00 00 00       	jmp    6db <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5ef:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5f3:	74 06                	je     5fb <printf+0xb3>
 5f5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5f9:	75 2d                	jne    628 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fe:	8b 00                	mov    (%eax),%eax
 600:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 607:	00 
 608:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 60f:	00 
 610:	89 44 24 04          	mov    %eax,0x4(%esp)
 614:	8b 45 08             	mov    0x8(%ebp),%eax
 617:	89 04 24             	mov    %eax,(%esp)
 61a:	e8 71 fe ff ff       	call   490 <printint>
        ap++;
 61f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 623:	e9 b3 00 00 00       	jmp    6db <printf+0x193>
      } else if(c == 's'){
 628:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 62c:	75 45                	jne    673 <printf+0x12b>
        s = (char*)*ap;
 62e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 631:	8b 00                	mov    (%eax),%eax
 633:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 636:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 63a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63e:	75 09                	jne    649 <printf+0x101>
          s = "(null)";
 640:	c7 45 f4 88 09 00 00 	movl   $0x988,-0xc(%ebp)
        while(*s != 0){
 647:	eb 1e                	jmp    667 <printf+0x11f>
 649:	eb 1c                	jmp    667 <printf+0x11f>
          putc(fd, *s);
 64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	0f be c0             	movsbl %al,%eax
 654:	89 44 24 04          	mov    %eax,0x4(%esp)
 658:	8b 45 08             	mov    0x8(%ebp),%eax
 65b:	89 04 24             	mov    %eax,(%esp)
 65e:	e8 05 fe ff ff       	call   468 <putc>
          s++;
 663:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 667:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	84 c0                	test   %al,%al
 66f:	75 da                	jne    64b <printf+0x103>
 671:	eb 68                	jmp    6db <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 673:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 677:	75 1d                	jne    696 <printf+0x14e>
        putc(fd, *ap);
 679:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	0f be c0             	movsbl %al,%eax
 681:	89 44 24 04          	mov    %eax,0x4(%esp)
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	89 04 24             	mov    %eax,(%esp)
 68b:	e8 d8 fd ff ff       	call   468 <putc>
        ap++;
 690:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 694:	eb 45                	jmp    6db <printf+0x193>
      } else if(c == '%'){
 696:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 69a:	75 17                	jne    6b3 <printf+0x16b>
        putc(fd, c);
 69c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69f:	0f be c0             	movsbl %al,%eax
 6a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a6:	8b 45 08             	mov    0x8(%ebp),%eax
 6a9:	89 04 24             	mov    %eax,(%esp)
 6ac:	e8 b7 fd ff ff       	call   468 <putc>
 6b1:	eb 28                	jmp    6db <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6ba:	00 
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	89 04 24             	mov    %eax,(%esp)
 6c1:	e8 a2 fd ff ff       	call   468 <putc>
        putc(fd, c);
 6c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c9:	0f be c0             	movsbl %al,%eax
 6cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d0:	8b 45 08             	mov    0x8(%ebp),%eax
 6d3:	89 04 24             	mov    %eax,(%esp)
 6d6:	e8 8d fd ff ff       	call   468 <putc>
      }
      state = 0;
 6db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ec:	01 d0                	add    %edx,%eax
 6ee:	0f b6 00             	movzbl (%eax),%eax
 6f1:	84 c0                	test   %al,%al
 6f3:	0f 85 71 fe ff ff    	jne    56a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6f9:	c9                   	leave  
 6fa:	c3                   	ret    

000006fb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	83 e8 08             	sub    $0x8,%eax
 707:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70a:	a1 10 0c 00 00       	mov    0xc10,%eax
 70f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 712:	eb 24                	jmp    738 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71c:	77 12                	ja     730 <free+0x35>
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 724:	77 24                	ja     74a <free+0x4f>
 726:	8b 45 fc             	mov    -0x4(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72e:	77 1a                	ja     74a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	8b 00                	mov    (%eax),%eax
 735:	89 45 fc             	mov    %eax,-0x4(%ebp)
 738:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73e:	76 d4                	jbe    714 <free+0x19>
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 748:	76 ca                	jbe    714 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 757:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75a:	01 c2                	add    %eax,%edx
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	39 c2                	cmp    %eax,%edx
 763:	75 24                	jne    789 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	8b 50 04             	mov    0x4(%eax),%edx
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	01 c2                	add    %eax,%edx
 775:	8b 45 f8             	mov    -0x8(%ebp),%eax
 778:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 00                	mov    (%eax),%eax
 780:	8b 10                	mov    (%eax),%edx
 782:	8b 45 f8             	mov    -0x8(%ebp),%eax
 785:	89 10                	mov    %edx,(%eax)
 787:	eb 0a                	jmp    793 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 10                	mov    (%eax),%edx
 78e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 791:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	01 d0                	add    %edx,%eax
 7a5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a8:	75 20                	jne    7ca <free+0xcf>
    p->s.size += bp->s.size;
 7aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ad:	8b 50 04             	mov    0x4(%eax),%edx
 7b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b3:	8b 40 04             	mov    0x4(%eax),%eax
 7b6:	01 c2                	add    %eax,%edx
 7b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c1:	8b 10                	mov    (%eax),%edx
 7c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c6:	89 10                	mov    %edx,(%eax)
 7c8:	eb 08                	jmp    7d2 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d0:	89 10                	mov    %edx,(%eax)
  freep = p;
 7d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d5:	a3 10 0c 00 00       	mov    %eax,0xc10
}
 7da:	c9                   	leave  
 7db:	c3                   	ret    

000007dc <morecore>:

static Header*
morecore(uint nu)
{
 7dc:	55                   	push   %ebp
 7dd:	89 e5                	mov    %esp,%ebp
 7df:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7e2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7e9:	77 07                	ja     7f2 <morecore+0x16>
    nu = 4096;
 7eb:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	c1 e0 03             	shl    $0x3,%eax
 7f8:	89 04 24             	mov    %eax,(%esp)
 7fb:	e8 10 fc ff ff       	call   410 <sbrk>
 800:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 803:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 807:	75 07                	jne    810 <morecore+0x34>
    return 0;
 809:	b8 00 00 00 00       	mov    $0x0,%eax
 80e:	eb 22                	jmp    832 <morecore+0x56>
  hp = (Header*)p;
 810:	8b 45 f4             	mov    -0xc(%ebp),%eax
 813:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 816:	8b 45 f0             	mov    -0x10(%ebp),%eax
 819:	8b 55 08             	mov    0x8(%ebp),%edx
 81c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 81f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 822:	83 c0 08             	add    $0x8,%eax
 825:	89 04 24             	mov    %eax,(%esp)
 828:	e8 ce fe ff ff       	call   6fb <free>
  return freep;
 82d:	a1 10 0c 00 00       	mov    0xc10,%eax
}
 832:	c9                   	leave  
 833:	c3                   	ret    

00000834 <malloc>:

void*
malloc(uint nbytes)
{
 834:	55                   	push   %ebp
 835:	89 e5                	mov    %esp,%ebp
 837:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	83 c0 07             	add    $0x7,%eax
 840:	c1 e8 03             	shr    $0x3,%eax
 843:	83 c0 01             	add    $0x1,%eax
 846:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 849:	a1 10 0c 00 00       	mov    0xc10,%eax
 84e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 851:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 855:	75 23                	jne    87a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 857:	c7 45 f0 08 0c 00 00 	movl   $0xc08,-0x10(%ebp)
 85e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 861:	a3 10 0c 00 00       	mov    %eax,0xc10
 866:	a1 10 0c 00 00       	mov    0xc10,%eax
 86b:	a3 08 0c 00 00       	mov    %eax,0xc08
    base.s.size = 0;
 870:	c7 05 0c 0c 00 00 00 	movl   $0x0,0xc0c
 877:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87d:	8b 00                	mov    (%eax),%eax
 87f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	8b 40 04             	mov    0x4(%eax),%eax
 888:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 88b:	72 4d                	jb     8da <malloc+0xa6>
      if(p->s.size == nunits)
 88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 890:	8b 40 04             	mov    0x4(%eax),%eax
 893:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 896:	75 0c                	jne    8a4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	8b 10                	mov    (%eax),%edx
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	89 10                	mov    %edx,(%eax)
 8a2:	eb 26                	jmp    8ca <malloc+0x96>
      else {
        p->s.size -= nunits;
 8a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a7:	8b 40 04             	mov    0x4(%eax),%eax
 8aa:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8ad:	89 c2                	mov    %eax,%edx
 8af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b8:	8b 40 04             	mov    0x4(%eax),%eax
 8bb:	c1 e0 03             	shl    $0x3,%eax
 8be:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8c7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cd:	a3 10 0c 00 00       	mov    %eax,0xc10
      return (void*)(p + 1);
 8d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d5:	83 c0 08             	add    $0x8,%eax
 8d8:	eb 38                	jmp    912 <malloc+0xde>
    }
    if(p == freep)
 8da:	a1 10 0c 00 00       	mov    0xc10,%eax
 8df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8e2:	75 1b                	jne    8ff <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8e7:	89 04 24             	mov    %eax,(%esp)
 8ea:	e8 ed fe ff ff       	call   7dc <morecore>
 8ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8f6:	75 07                	jne    8ff <malloc+0xcb>
        return 0;
 8f8:	b8 00 00 00 00       	mov    $0x0,%eax
 8fd:	eb 13                	jmp    912 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 902:	89 45 f0             	mov    %eax,-0x10(%ebp)
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 90d:	e9 70 ff ff ff       	jmp    882 <malloc+0x4e>
}
 912:	c9                   	leave  
 913:	c3                   	ret    
