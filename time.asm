
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"

#ifdef CS333_P2
int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 40             	sub    $0x40,%esp
	int start_t = uptime();
   a:	e8 01 04 00 00       	call   410 <uptime>
   f:	89 44 24 38          	mov    %eax,0x38(%esp)
	int end_t = start_t;
  13:	8b 44 24 38          	mov    0x38(%esp),%eax
  17:	89 44 24 3c          	mov    %eax,0x3c(%esp)
	int elapsed_t = 0;
  1b:	c7 44 24 34 00 00 00 	movl   $0x0,0x34(%esp)
  22:	00 
	int pid;
	if(argc > 1) {
  23:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  27:	7e 58                	jle    81 <main+0x81>
		pid = fork();
  29:	e8 42 03 00 00       	call   370 <fork>
  2e:	89 44 24 30          	mov    %eax,0x30(%esp)
		if(pid > 0) {
  32:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  37:	7e 14                	jle    4d <main+0x4d>
			pid = wait();
  39:	e8 42 03 00 00       	call   380 <wait>
  3e:	89 44 24 30          	mov    %eax,0x30(%esp)
			end_t= uptime();
  42:	e8 c9 03 00 00       	call   410 <uptime>
  47:	89 44 24 3c          	mov    %eax,0x3c(%esp)
  4b:	eb 34                	jmp    81 <main+0x81>
			}
		else if(pid == 0) {
  4d:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  52:	75 28                	jne    7c <main+0x7c>
			//child process running
			char **nargv = ++argv;
  54:	83 45 0c 04          	addl   $0x4,0xc(%ebp)
  58:	8b 45 0c             	mov    0xc(%ebp),%eax
  5b:	89 44 24 2c          	mov    %eax,0x2c(%esp)
			exec(argv[1], nargv);
  5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  62:	83 c0 04             	add    $0x4,%eax
  65:	8b 00                	mov    (%eax),%eax
  67:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  6b:	89 54 24 04          	mov    %edx,0x4(%esp)
  6f:	89 04 24             	mov    %eax,(%esp)
  72:	e8 39 03 00 00       	call   3b0 <exec>
			exit();
  77:	e8 fc 02 00 00       	call   378 <exit>
			}
		else {
			// error
			exit();
  7c:	e8 f7 02 00 00       	call   378 <exit>
			}
		}
	elapsed_t = end_t - start_t;
  81:	8b 44 24 38          	mov    0x38(%esp),%eax
  85:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  89:	29 c2                	sub    %eax,%edx
  8b:	89 d0                	mov    %edx,%eax
  8d:	89 44 24 34          	mov    %eax,0x34(%esp)
	char *proc_name = argv[1] ? argv[1] : "";
  91:	8b 45 0c             	mov    0xc(%ebp),%eax
  94:	83 c0 04             	add    $0x4,%eax
  97:	8b 00                	mov    (%eax),%eax
  99:	85 c0                	test   %eax,%eax
  9b:	74 08                	je     a5 <main+0xa5>
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	8b 40 04             	mov    0x4(%eax),%eax
  a3:	eb 05                	jmp    aa <main+0xaa>
  a5:	b8 04 09 00 00       	mov    $0x904,%eax
  aa:	89 44 24 28          	mov    %eax,0x28(%esp)
  printf(1,"%s ran in %d.%d seconds\n",proc_name, elapsed_t/100, elapsed_t%100);
  ae:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  b2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  b7:	89 d8                	mov    %ebx,%eax
  b9:	f7 ea                	imul   %edx
  bb:	c1 fa 05             	sar    $0x5,%edx
  be:	89 d8                	mov    %ebx,%eax
  c0:	c1 f8 1f             	sar    $0x1f,%eax
  c3:	89 d1                	mov    %edx,%ecx
  c5:	29 c1                	sub    %eax,%ecx
  c7:	6b c1 64             	imul   $0x64,%ecx,%eax
  ca:	89 d9                	mov    %ebx,%ecx
  cc:	29 c1                	sub    %eax,%ecx
  ce:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  d2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  d7:	89 d8                	mov    %ebx,%eax
  d9:	f7 ea                	imul   %edx
  db:	c1 fa 05             	sar    $0x5,%edx
  de:	89 d8                	mov    %ebx,%eax
  e0:	c1 f8 1f             	sar    $0x1f,%eax
  e3:	29 c2                	sub    %eax,%edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  ef:	8b 44 24 28          	mov    0x28(%esp),%eax
  f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  f7:	c7 44 24 04 05 09 00 	movl   $0x905,0x4(%esp)
  fe:	00 
  ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 106:	e8 2d 04 00 00       	call   538 <printf>

  exit();
 10b:	e8 68 02 00 00       	call   378 <exit>

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	8d 50 01             	lea    0x1(%eax),%edx
 148:	89 55 08             	mov    %edx,0x8(%ebp)
 14b:	8b 55 0c             	mov    0xc(%ebp),%edx
 14e:	8d 4a 01             	lea    0x1(%edx),%ecx
 151:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 154:	0f b6 12             	movzbl (%edx),%edx
 157:	88 10                	mov    %dl,(%eax)
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	84 c0                	test   %al,%al
 15e:	75 e2                	jne    142 <strcpy+0xd>
    ;
  return os;
 160:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 163:	c9                   	leave  
 164:	c3                   	ret    

00000165 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 165:	55                   	push   %ebp
 166:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 168:	eb 08                	jmp    172 <strcmp+0xd>
    p++, q++;
 16a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	84 c0                	test   %al,%al
 17a:	74 10                	je     18c <strcmp+0x27>
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	0f b6 10             	movzbl (%eax),%edx
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	0f b6 00             	movzbl (%eax),%eax
 188:	38 c2                	cmp    %al,%dl
 18a:	74 de                	je     16a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	0f b6 00             	movzbl (%eax),%eax
 192:	0f b6 d0             	movzbl %al,%edx
 195:	8b 45 0c             	mov    0xc(%ebp),%eax
 198:	0f b6 00             	movzbl (%eax),%eax
 19b:	0f b6 c0             	movzbl %al,%eax
 19e:	29 c2                	sub    %eax,%edx
 1a0:	89 d0                	mov    %edx,%eax
}
 1a2:	5d                   	pop    %ebp
 1a3:	c3                   	ret    

000001a4 <strlen>:

uint
strlen(char *s)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b1:	eb 04                	jmp    1b7 <strlen+0x13>
 1b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 d0                	add    %edx,%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	84 c0                	test   %al,%al
 1c4:	75 ed                	jne    1b3 <strlen+0xf>
    ;
  return n;
 1c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c9:	c9                   	leave  
 1ca:	c3                   	ret    

000001cb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cb:	55                   	push   %ebp
 1cc:	89 e5                	mov    %esp,%ebp
 1ce:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d1:	8b 45 10             	mov    0x10(%ebp),%eax
 1d4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1db:	89 44 24 04          	mov    %eax,0x4(%esp)
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 26 ff ff ff       	call   110 <stosb>
  return dst;
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ed:	c9                   	leave  
 1ee:	c3                   	ret    

000001ef <strchr>:

char*
strchr(const char *s, char c)
{
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
 1f2:	83 ec 04             	sub    $0x4,%esp
 1f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fb:	eb 14                	jmp    211 <strchr+0x22>
    if(*s == c)
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	0f b6 00             	movzbl (%eax),%eax
 203:	3a 45 fc             	cmp    -0x4(%ebp),%al
 206:	75 05                	jne    20d <strchr+0x1e>
      return (char*)s;
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	eb 13                	jmp    220 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 211:	8b 45 08             	mov    0x8(%ebp),%eax
 214:	0f b6 00             	movzbl (%eax),%eax
 217:	84 c0                	test   %al,%al
 219:	75 e2                	jne    1fd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 220:	c9                   	leave  
 221:	c3                   	ret    

00000222 <gets>:

char*
gets(char *buf, int max)
{
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
 225:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 228:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22f:	eb 4c                	jmp    27d <gets+0x5b>
    cc = read(0, &c, 1);
 231:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 238:	00 
 239:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23c:	89 44 24 04          	mov    %eax,0x4(%esp)
 240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 247:	e8 44 01 00 00       	call   390 <read>
 24c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 253:	7f 02                	jg     257 <gets+0x35>
      break;
 255:	eb 31                	jmp    288 <gets+0x66>
    buf[i++] = c;
 257:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25a:	8d 50 01             	lea    0x1(%eax),%edx
 25d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 260:	89 c2                	mov    %eax,%edx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	01 c2                	add    %eax,%edx
 267:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0a                	cmp    $0xa,%al
 273:	74 13                	je     288 <gets+0x66>
 275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 279:	3c 0d                	cmp    $0xd,%al
 27b:	74 0b                	je     288 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	83 c0 01             	add    $0x1,%eax
 283:	3b 45 0c             	cmp    0xc(%ebp),%eax
 286:	7c a9                	jl     231 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 288:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	01 d0                	add    %edx,%eax
 290:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 293:	8b 45 08             	mov    0x8(%ebp),%eax
}
 296:	c9                   	leave  
 297:	c3                   	ret    

00000298 <stat>:

int
stat(char *n, struct stat *st)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a5:	00 
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 04 24             	mov    %eax,(%esp)
 2ac:	e8 07 01 00 00       	call   3b8 <open>
 2b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b8:	79 07                	jns    2c1 <stat+0x29>
    return -1;
 2ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bf:	eb 23                	jmp    2e4 <stat+0x4c>
  r = fstat(fd, st);
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cb:	89 04 24             	mov    %eax,(%esp)
 2ce:	e8 fd 00 00 00       	call   3d0 <fstat>
 2d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d9:	89 04 24             	mov    %eax,(%esp)
 2dc:	e8 bf 00 00 00       	call   3a0 <close>
  return r;
 2e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e4:	c9                   	leave  
 2e5:	c3                   	ret    

000002e6 <atoi>:

int
atoi(const char *s)
{
 2e6:	55                   	push   %ebp
 2e7:	89 e5                	mov    %esp,%ebp
 2e9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f3:	eb 25                	jmp    31a <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f8:	89 d0                	mov    %edx,%eax
 2fa:	c1 e0 02             	shl    $0x2,%eax
 2fd:	01 d0                	add    %edx,%eax
 2ff:	01 c0                	add    %eax,%eax
 301:	89 c1                	mov    %eax,%ecx
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	8d 50 01             	lea    0x1(%eax),%edx
 309:	89 55 08             	mov    %edx,0x8(%ebp)
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	0f be c0             	movsbl %al,%eax
 312:	01 c8                	add    %ecx,%eax
 314:	83 e8 30             	sub    $0x30,%eax
 317:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	0f b6 00             	movzbl (%eax),%eax
 320:	3c 2f                	cmp    $0x2f,%al
 322:	7e 0a                	jle    32e <atoi+0x48>
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	0f b6 00             	movzbl (%eax),%eax
 32a:	3c 39                	cmp    $0x39,%al
 32c:	7e c7                	jle    2f5 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 331:	c9                   	leave  
 332:	c3                   	ret    

00000333 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 333:	55                   	push   %ebp
 334:	89 e5                	mov    %esp,%ebp
 336:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33f:	8b 45 0c             	mov    0xc(%ebp),%eax
 342:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 345:	eb 17                	jmp    35e <memmove+0x2b>
    *dst++ = *src++;
 347:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34a:	8d 50 01             	lea    0x1(%eax),%edx
 34d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 350:	8b 55 f8             	mov    -0x8(%ebp),%edx
 353:	8d 4a 01             	lea    0x1(%edx),%ecx
 356:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 359:	0f b6 12             	movzbl (%edx),%edx
 35c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35e:	8b 45 10             	mov    0x10(%ebp),%eax
 361:	8d 50 ff             	lea    -0x1(%eax),%edx
 364:	89 55 10             	mov    %edx,0x10(%ebp)
 367:	85 c0                	test   %eax,%eax
 369:	7f dc                	jg     347 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36e:	c9                   	leave  
 36f:	c3                   	ret    

00000370 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 370:	b8 01 00 00 00       	mov    $0x1,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <exit>:
SYSCALL(exit)
 378:	b8 02 00 00 00       	mov    $0x2,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <wait>:
SYSCALL(wait)
 380:	b8 03 00 00 00       	mov    $0x3,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <pipe>:
SYSCALL(pipe)
 388:	b8 04 00 00 00       	mov    $0x4,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <read>:
SYSCALL(read)
 390:	b8 05 00 00 00       	mov    $0x5,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <write>:
SYSCALL(write)
 398:	b8 10 00 00 00       	mov    $0x10,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <close>:
SYSCALL(close)
 3a0:	b8 15 00 00 00       	mov    $0x15,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <kill>:
SYSCALL(kill)
 3a8:	b8 06 00 00 00       	mov    $0x6,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <exec>:
SYSCALL(exec)
 3b0:	b8 07 00 00 00       	mov    $0x7,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <open>:
SYSCALL(open)
 3b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <mknod>:
SYSCALL(mknod)
 3c0:	b8 11 00 00 00       	mov    $0x11,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <unlink>:
SYSCALL(unlink)
 3c8:	b8 12 00 00 00       	mov    $0x12,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <fstat>:
SYSCALL(fstat)
 3d0:	b8 08 00 00 00       	mov    $0x8,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <link>:
SYSCALL(link)
 3d8:	b8 13 00 00 00       	mov    $0x13,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <mkdir>:
SYSCALL(mkdir)
 3e0:	b8 14 00 00 00       	mov    $0x14,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <chdir>:
SYSCALL(chdir)
 3e8:	b8 09 00 00 00       	mov    $0x9,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <dup>:
SYSCALL(dup)
 3f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <getpid>:
SYSCALL(getpid)
 3f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <sbrk>:
SYSCALL(sbrk)
 400:	b8 0c 00 00 00       	mov    $0xc,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <sleep>:
SYSCALL(sleep)
 408:	b8 0d 00 00 00       	mov    $0xd,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <uptime>:
SYSCALL(uptime)
 410:	b8 0e 00 00 00       	mov    $0xe,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <halt>:
SYSCALL(halt)
 418:	b8 16 00 00 00       	mov    $0x16,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <date>:
SYSCALL(date)
 420:	b8 17 00 00 00       	mov    $0x17,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <getuid>:
SYSCALL(getuid)
 428:	b8 18 00 00 00       	mov    $0x18,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <getgid>:
SYSCALL(getgid)
 430:	b8 19 00 00 00       	mov    $0x19,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <getppid>:
SYSCALL(getppid)
 438:	b8 1a 00 00 00       	mov    $0x1a,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <setuid>:
SYSCALL(setuid)
 440:	b8 1b 00 00 00       	mov    $0x1b,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <setgid>:
SYSCALL(setgid)
 448:	b8 1c 00 00 00       	mov    $0x1c,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <getprocs>:
SYSCALL(getprocs)
 450:	b8 1d 00 00 00       	mov    $0x1d,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 18             	sub    $0x18,%esp
 45e:	8b 45 0c             	mov    0xc(%ebp),%eax
 461:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 464:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 46b:	00 
 46c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46f:	89 44 24 04          	mov    %eax,0x4(%esp)
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	89 04 24             	mov    %eax,(%esp)
 479:	e8 1a ff ff ff       	call   398 <write>
}
 47e:	c9                   	leave  
 47f:	c3                   	ret    

00000480 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	56                   	push   %esi
 484:	53                   	push   %ebx
 485:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 488:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 493:	74 17                	je     4ac <printint+0x2c>
 495:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 499:	79 11                	jns    4ac <printint+0x2c>
    neg = 1;
 49b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	f7 d8                	neg    %eax
 4a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4aa:	eb 06                	jmp    4b2 <printint+0x32>
  } else {
    x = xx;
 4ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 4af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4bc:	8d 41 01             	lea    0x1(%ecx),%eax
 4bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c8:	ba 00 00 00 00       	mov    $0x0,%edx
 4cd:	f7 f3                	div    %ebx
 4cf:	89 d0                	mov    %edx,%eax
 4d1:	0f b6 80 6c 0b 00 00 	movzbl 0xb6c(%eax),%eax
 4d8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4dc:	8b 75 10             	mov    0x10(%ebp),%esi
 4df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e2:	ba 00 00 00 00       	mov    $0x0,%edx
 4e7:	f7 f6                	div    %esi
 4e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f0:	75 c7                	jne    4b9 <printint+0x39>
  if(neg)
 4f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f6:	74 10                	je     508 <printint+0x88>
    buf[i++] = '-';
 4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fb:	8d 50 01             	lea    0x1(%eax),%edx
 4fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 501:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 506:	eb 1f                	jmp    527 <printint+0xa7>
 508:	eb 1d                	jmp    527 <printint+0xa7>
    putc(fd, buf[i]);
 50a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 510:	01 d0                	add    %edx,%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	0f be c0             	movsbl %al,%eax
 518:	89 44 24 04          	mov    %eax,0x4(%esp)
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	89 04 24             	mov    %eax,(%esp)
 522:	e8 31 ff ff ff       	call   458 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 527:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 52b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52f:	79 d9                	jns    50a <printint+0x8a>
    putc(fd, buf[i]);
}
 531:	83 c4 30             	add    $0x30,%esp
 534:	5b                   	pop    %ebx
 535:	5e                   	pop    %esi
 536:	5d                   	pop    %ebp
 537:	c3                   	ret    

00000538 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 545:	8d 45 0c             	lea    0xc(%ebp),%eax
 548:	83 c0 04             	add    $0x4,%eax
 54b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 555:	e9 7c 01 00 00       	jmp    6d6 <printf+0x19e>
    c = fmt[i] & 0xff;
 55a:	8b 55 0c             	mov    0xc(%ebp),%edx
 55d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 560:	01 d0                	add    %edx,%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	25 ff 00 00 00       	and    $0xff,%eax
 56d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 570:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 574:	75 2c                	jne    5a2 <printf+0x6a>
      if(c == '%'){
 576:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57a:	75 0c                	jne    588 <printf+0x50>
        state = '%';
 57c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 583:	e9 4a 01 00 00       	jmp    6d2 <printf+0x19a>
      } else {
        putc(fd, c);
 588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58b:	0f be c0             	movsbl %al,%eax
 58e:	89 44 24 04          	mov    %eax,0x4(%esp)
 592:	8b 45 08             	mov    0x8(%ebp),%eax
 595:	89 04 24             	mov    %eax,(%esp)
 598:	e8 bb fe ff ff       	call   458 <putc>
 59d:	e9 30 01 00 00       	jmp    6d2 <printf+0x19a>
      }
    } else if(state == '%'){
 5a2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a6:	0f 85 26 01 00 00    	jne    6d2 <printf+0x19a>
      if(c == 'd'){
 5ac:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5b0:	75 2d                	jne    5df <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5be:	00 
 5bf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c6:	00 
 5c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ce:	89 04 24             	mov    %eax,(%esp)
 5d1:	e8 aa fe ff ff       	call   480 <printint>
        ap++;
 5d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5da:	e9 ec 00 00 00       	jmp    6cb <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e3:	74 06                	je     5eb <printf+0xb3>
 5e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e9:	75 2d                	jne    618 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ee:	8b 00                	mov    (%eax),%eax
 5f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f7:	00 
 5f8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ff:	00 
 600:	89 44 24 04          	mov    %eax,0x4(%esp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 71 fe ff ff       	call   480 <printint>
        ap++;
 60f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 613:	e9 b3 00 00 00       	jmp    6cb <printf+0x193>
      } else if(c == 's'){
 618:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 61c:	75 45                	jne    663 <printf+0x12b>
        s = (char*)*ap;
 61e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 621:	8b 00                	mov    (%eax),%eax
 623:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 626:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 62a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62e:	75 09                	jne    639 <printf+0x101>
          s = "(null)";
 630:	c7 45 f4 1e 09 00 00 	movl   $0x91e,-0xc(%ebp)
        while(*s != 0){
 637:	eb 1e                	jmp    657 <printf+0x11f>
 639:	eb 1c                	jmp    657 <printf+0x11f>
          putc(fd, *s);
 63b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63e:	0f b6 00             	movzbl (%eax),%eax
 641:	0f be c0             	movsbl %al,%eax
 644:	89 44 24 04          	mov    %eax,0x4(%esp)
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	89 04 24             	mov    %eax,(%esp)
 64e:	e8 05 fe ff ff       	call   458 <putc>
          s++;
 653:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 657:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65a:	0f b6 00             	movzbl (%eax),%eax
 65d:	84 c0                	test   %al,%al
 65f:	75 da                	jne    63b <printf+0x103>
 661:	eb 68                	jmp    6cb <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 663:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 667:	75 1d                	jne    686 <printf+0x14e>
        putc(fd, *ap);
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	89 44 24 04          	mov    %eax,0x4(%esp)
 675:	8b 45 08             	mov    0x8(%ebp),%eax
 678:	89 04 24             	mov    %eax,(%esp)
 67b:	e8 d8 fd ff ff       	call   458 <putc>
        ap++;
 680:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 684:	eb 45                	jmp    6cb <printf+0x193>
      } else if(c == '%'){
 686:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 68a:	75 17                	jne    6a3 <printf+0x16b>
        putc(fd, c);
 68c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	89 44 24 04          	mov    %eax,0x4(%esp)
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	89 04 24             	mov    %eax,(%esp)
 69c:	e8 b7 fd ff ff       	call   458 <putc>
 6a1:	eb 28                	jmp    6cb <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6aa:	00 
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 a2 fd ff ff       	call   458 <putc>
        putc(fd, c);
 6b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b9:	0f be c0             	movsbl %al,%eax
 6bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	89 04 24             	mov    %eax,(%esp)
 6c6:	e8 8d fd ff ff       	call   458 <putc>
      }
      state = 0;
 6cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6dc:	01 d0                	add    %edx,%eax
 6de:	0f b6 00             	movzbl (%eax),%eax
 6e1:	84 c0                	test   %al,%al
 6e3:	0f 85 71 fe ff ff    	jne    55a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	83 e8 08             	sub    $0x8,%eax
 6f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fa:	a1 88 0b 00 00       	mov    0xb88,%eax
 6ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
 702:	eb 24                	jmp    728 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70c:	77 12                	ja     720 <free+0x35>
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 714:	77 24                	ja     73a <free+0x4f>
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	8b 00                	mov    (%eax),%eax
 71b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71e:	77 1a                	ja     73a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	89 45 fc             	mov    %eax,-0x4(%ebp)
 728:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72e:	76 d4                	jbe    704 <free+0x19>
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	8b 00                	mov    (%eax),%eax
 735:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 738:	76 ca                	jbe    704 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 73a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73d:	8b 40 04             	mov    0x4(%eax),%eax
 740:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	01 c2                	add    %eax,%edx
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	39 c2                	cmp    %eax,%edx
 753:	75 24                	jne    779 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 755:	8b 45 f8             	mov    -0x8(%ebp),%eax
 758:	8b 50 04             	mov    0x4(%eax),%edx
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 00                	mov    (%eax),%eax
 760:	8b 40 04             	mov    0x4(%eax),%eax
 763:	01 c2                	add    %eax,%edx
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	8b 10                	mov    (%eax),%edx
 772:	8b 45 f8             	mov    -0x8(%ebp),%eax
 775:	89 10                	mov    %edx,(%eax)
 777:	eb 0a                	jmp    783 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 10                	mov    (%eax),%edx
 77e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 781:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	8b 40 04             	mov    0x4(%eax),%eax
 789:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 790:	8b 45 fc             	mov    -0x4(%ebp),%eax
 793:	01 d0                	add    %edx,%eax
 795:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 798:	75 20                	jne    7ba <free+0xcf>
    p->s.size += bp->s.size;
 79a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79d:	8b 50 04             	mov    0x4(%eax),%edx
 7a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a3:	8b 40 04             	mov    0x4(%eax),%eax
 7a6:	01 c2                	add    %eax,%edx
 7a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ab:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b1:	8b 10                	mov    (%eax),%edx
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	89 10                	mov    %edx,(%eax)
 7b8:	eb 08                	jmp    7c2 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7c0:	89 10                	mov    %edx,(%eax)
  freep = p;
 7c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c5:	a3 88 0b 00 00       	mov    %eax,0xb88
}
 7ca:	c9                   	leave  
 7cb:	c3                   	ret    

000007cc <morecore>:

static Header*
morecore(uint nu)
{
 7cc:	55                   	push   %ebp
 7cd:	89 e5                	mov    %esp,%ebp
 7cf:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7d2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7d9:	77 07                	ja     7e2 <morecore+0x16>
    nu = 4096;
 7db:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7e2:	8b 45 08             	mov    0x8(%ebp),%eax
 7e5:	c1 e0 03             	shl    $0x3,%eax
 7e8:	89 04 24             	mov    %eax,(%esp)
 7eb:	e8 10 fc ff ff       	call   400 <sbrk>
 7f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f7:	75 07                	jne    800 <morecore+0x34>
    return 0;
 7f9:	b8 00 00 00 00       	mov    $0x0,%eax
 7fe:	eb 22                	jmp    822 <morecore+0x56>
  hp = (Header*)p;
 800:	8b 45 f4             	mov    -0xc(%ebp),%eax
 803:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 806:	8b 45 f0             	mov    -0x10(%ebp),%eax
 809:	8b 55 08             	mov    0x8(%ebp),%edx
 80c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 80f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 812:	83 c0 08             	add    $0x8,%eax
 815:	89 04 24             	mov    %eax,(%esp)
 818:	e8 ce fe ff ff       	call   6eb <free>
  return freep;
 81d:	a1 88 0b 00 00       	mov    0xb88,%eax
}
 822:	c9                   	leave  
 823:	c3                   	ret    

00000824 <malloc>:

void*
malloc(uint nbytes)
{
 824:	55                   	push   %ebp
 825:	89 e5                	mov    %esp,%ebp
 827:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82a:	8b 45 08             	mov    0x8(%ebp),%eax
 82d:	83 c0 07             	add    $0x7,%eax
 830:	c1 e8 03             	shr    $0x3,%eax
 833:	83 c0 01             	add    $0x1,%eax
 836:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 839:	a1 88 0b 00 00       	mov    0xb88,%eax
 83e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 841:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 845:	75 23                	jne    86a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 847:	c7 45 f0 80 0b 00 00 	movl   $0xb80,-0x10(%ebp)
 84e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 851:	a3 88 0b 00 00       	mov    %eax,0xb88
 856:	a1 88 0b 00 00       	mov    0xb88,%eax
 85b:	a3 80 0b 00 00       	mov    %eax,0xb80
    base.s.size = 0;
 860:	c7 05 84 0b 00 00 00 	movl   $0x0,0xb84
 867:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86d:	8b 00                	mov    (%eax),%eax
 86f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	8b 40 04             	mov    0x4(%eax),%eax
 878:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 87b:	72 4d                	jb     8ca <malloc+0xa6>
      if(p->s.size == nunits)
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	8b 40 04             	mov    0x4(%eax),%eax
 883:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 886:	75 0c                	jne    894 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	8b 10                	mov    (%eax),%edx
 88d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 890:	89 10                	mov    %edx,(%eax)
 892:	eb 26                	jmp    8ba <malloc+0x96>
      else {
        p->s.size -= nunits;
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 40 04             	mov    0x4(%eax),%eax
 89a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89d:	89 c2                	mov    %eax,%edx
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	c1 e0 03             	shl    $0x3,%eax
 8ae:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bd:	a3 88 0b 00 00       	mov    %eax,0xb88
      return (void*)(p + 1);
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	83 c0 08             	add    $0x8,%eax
 8c8:	eb 38                	jmp    902 <malloc+0xde>
    }
    if(p == freep)
 8ca:	a1 88 0b 00 00       	mov    0xb88,%eax
 8cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8d2:	75 1b                	jne    8ef <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d7:	89 04 24             	mov    %eax,(%esp)
 8da:	e8 ed fe ff ff       	call   7cc <morecore>
 8df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e6:	75 07                	jne    8ef <malloc+0xcb>
        return 0;
 8e8:	b8 00 00 00 00       	mov    $0x0,%eax
 8ed:	eb 13                	jmp    902 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	8b 00                	mov    (%eax),%eax
 8fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8fd:	e9 70 ff ff ff       	jmp    872 <malloc+0x4e>
}
 902:	c9                   	leave  
 903:	c3                   	ret    
