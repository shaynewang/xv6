
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c3 37 10 80       	mov    $0x801037c3,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 94 88 10 	movl   $0x80108894,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 90 50 00 00       	call   801050de <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 05 11 80 84 	movl   $0x80110584,0x80110590
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 05 11 80 84 	movl   $0x80110584,0x80110594
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 05 11 80       	mov    0x80110594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 05 11 80       	mov    %eax,0x80110594
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 3d 50 00 00       	call   801050ff <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 05 11 80       	mov    0x80110594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 58 50 00 00       	call   80105161 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 32 4b 00 00       	call   80104c56 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 05 11 80       	mov    0x80110590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 e0 4f 00 00       	call   80105161 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 9b 88 10 80 	movl   $0x8010889b,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 7f 26 00 00       	call   80102857 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 ac 88 10 80 	movl   $0x801088ac,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 42 26 00 00       	call   80102857 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 b3 88 10 80 	movl   $0x801088b3,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 be 4e 00 00       	call   801050ff <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 05 11 80       	mov    0x80110594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 05 11 80       	mov    %eax,0x80110594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 90 4a 00 00       	call   80104d32 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 b3 4e 00 00       	call   80105161 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bb:	e8 3f 4d 00 00       	call   801050ff <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 ba 88 10 80 	movl   $0x801088ba,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec c3 88 10 80 	movl   $0x801088c3,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100533:	e8 29 4c 00 00       	call   80105161 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 ca 88 10 80 	movl   $0x801088ca,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 d9 88 10 80 	movl   $0x801088d9,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 1c 4c 00 00       	call   801051b0 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 db 88 10 80 	movl   $0x801088db,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 90 10 80       	mov    0x80109000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 50 4d 00 00       	call   80105422 <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 52 4c 00 00       	call   80105353 <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 3f 67 00 00       	call   80106ed5 <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 33 67 00 00       	call   80106ed5 <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 27 67 00 00       	call   80106ed5 <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 1a 67 00 00       	call   80106ed5 <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801007dc:	e8 1e 49 00 00       	call   801050ff <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 28 08 11 80       	mov    0x80110828,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 28 08 11 80    	mov    0x80110828,%edx
8010083a:	a1 24 08 11 80       	mov    0x80110824,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 28 08 11 80       	mov    0x80110828,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 28 08 11 80    	mov    0x80110828,%edx
80100864:	a1 24 08 11 80       	mov    0x80110824,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 28 08 11 80       	mov    0x80110828,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 28 08 11 80    	mov    0x80110828,%edx
801008a0:	a1 20 08 11 80       	mov    0x80110820,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 28 08 11 80       	mov    0x80110828,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 28 08 11 80    	mov    %edx,0x80110828
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 a0 07 11 80    	mov    %al,-0x7feef860(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 28 08 11 80       	mov    0x80110828,%eax
801008f9:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 28 08 11 80       	mov    0x80110828,%eax
8010090b:	a3 24 08 11 80       	mov    %eax,0x80110824
          wakeup(&input.r);
80100910:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100917:	e8 16 44 00 00       	call   80104d32 <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100938:	e8 24 48 00 00       	call   80105161 <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 f5 44 00 00       	call   80104e3d <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 cd 10 00 00       	call   80101a28 <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100968:	e8 92 47 00 00       	call   801050ff <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 24             	mov    0x24(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100988:	e8 d4 47 00 00       	call   80105161 <release>
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 3c 0f 00 00       	call   801018d4 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
801009b1:	e8 a0 42 00 00       	call   80104c56 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801009bc:	a1 24 08 11 80       	mov    0x80110824,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 20 08 11 80       	mov    0x80110820,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 20 08 11 80    	mov    %edx,0x80110820
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 20 08 11 80       	mov    0x80110820,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 20 08 11 80       	mov    %eax,0x80110820
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a2d:	e8 2f 47 00 00       	call   80105161 <release>
  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 97 0e 00 00       	call   801018d4 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 ce 0f 00 00       	call   80101a28 <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a61:	e8 99 46 00 00       	call   801050ff <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a9b:	e8 c1 46 00 00       	call   80105161 <release>
  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 29 0e 00 00       	call   801018d4 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 f2 88 10 	movl   $0x801088f2,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100ac5:	e8 14 46 00 00       	call   801050de <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 ec 11 11 80 49 	movl   $0x80100a49,0x801111ec
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 e8 11 11 80 4a 	movl   $0x8010094a,0x801111e8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 67 33 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 0b 1f 00 00       	call   80102a13 <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    

80100b0a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b0a:	55                   	push   %ebp
80100b0b:	89 e5                	mov    %esp,%ebp
80100b0d:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b13:	e8 a4 29 00 00       	call   801034bc <begin_op>
  if((ip = namei(path)) == 0){
80100b18:	8b 45 08             	mov    0x8(%ebp),%eax
80100b1b:	89 04 24             	mov    %eax,(%esp)
80100b1e:	e8 62 19 00 00       	call   80102485 <namei>
80100b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b26:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b2a:	75 0f                	jne    80100b3b <exec+0x31>
    end_op();
80100b2c:	e8 0f 2a 00 00       	call   80103540 <end_op>
    return -1;
80100b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b36:	e9 e8 03 00 00       	jmp    80100f23 <exec+0x419>
  }
  ilock(ip);
80100b3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b3e:	89 04 24             	mov    %eax,(%esp)
80100b41:	e8 8e 0d 00 00       	call   801018d4 <ilock>
  pgdir = 0;
80100b46:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b4d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b54:	00 
80100b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5c:	00 
80100b5d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b67:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b6a:	89 04 24             	mov    %eax,(%esp)
80100b6d:	e8 75 12 00 00       	call   80101de7 <readi>
80100b72:	83 f8 33             	cmp    $0x33,%eax
80100b75:	77 05                	ja     80100b7c <exec+0x72>
    goto bad;
80100b77:	e9 7b 03 00 00       	jmp    80100ef7 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b7c:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b82:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b87:	74 05                	je     80100b8e <exec+0x84>
    goto bad;
80100b89:	e9 69 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b8e:	e8 93 74 00 00       	call   80108026 <setupkvm>
80100b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b96:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9a:	75 05                	jne    80100ba1 <exec+0x97>
    goto bad;
80100b9c:	e9 56 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100ba1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100baf:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bb8:	e9 cb 00 00 00       	jmp    80100c88 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc0:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc7:	00 
80100bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bcc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd9:	89 04 24             	mov    %eax,(%esp)
80100bdc:	e8 06 12 00 00       	call   80101de7 <readi>
80100be1:	83 f8 20             	cmp    $0x20,%eax
80100be4:	74 05                	je     80100beb <exec+0xe1>
      goto bad;
80100be6:	e9 0c 03 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100beb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf1:	83 f8 01             	cmp    $0x1,%eax
80100bf4:	74 05                	je     80100bfb <exec+0xf1>
      continue;
80100bf6:	e9 80 00 00 00       	jmp    80100c7b <exec+0x171>
    if(ph.memsz < ph.filesz)
80100bfb:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c01:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c07:	39 c2                	cmp    %eax,%edx
80100c09:	73 05                	jae    80100c10 <exec+0x106>
      goto bad;
80100c0b:	e9 e7 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c10:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c16:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c1c:	01 d0                	add    %edx,%eax
80100c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c25:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c2c:	89 04 24             	mov    %eax,(%esp)
80100c2f:	e8 c0 77 00 00       	call   801083f4 <allocuvm>
80100c34:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c3b:	75 05                	jne    80100c42 <exec+0x138>
      goto bad;
80100c3d:	e9 b5 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c42:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c48:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c4e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c54:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c58:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c6a:	89 04 24             	mov    %eax,(%esp)
80100c6d:	e8 97 76 00 00       	call   80108309 <loaduvm>
80100c72:	85 c0                	test   %eax,%eax
80100c74:	79 05                	jns    80100c7b <exec+0x171>
      goto bad;
80100c76:	e9 7c 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c82:	83 c0 20             	add    $0x20,%eax
80100c85:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c88:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8f:	0f b7 c0             	movzwl %ax,%eax
80100c92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c95:	0f 8f 22 ff ff ff    	jg     80100bbd <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9e:	89 04 24             	mov    %eax,(%esp)
80100ca1:	e8 b8 0e 00 00       	call   80101b5e <iunlockput>
  end_op();
80100ca6:	e8 95 28 00 00       	call   80103540 <end_op>
  ip = 0;
80100cab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc5:	05 00 20 00 00       	add    $0x2000,%eax
80100cca:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 14 77 00 00       	call   801083f4 <allocuvm>
80100ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce7:	75 05                	jne    80100cee <exec+0x1e4>
    goto bad;
80100ce9:	e9 09 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 1f 79 00 00       	call   80108624 <clearpteu>
  sp = sz;
80100d05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d08:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d12:	e9 9a 00 00 00       	jmp    80100db1 <exec+0x2a7>
    if(argc >= MAXARG)
80100d17:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1b:	76 05                	jbe    80100d22 <exec+0x218>
      goto bad;
80100d1d:	e9 d5 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2f:	01 d0                	add    %edx,%eax
80100d31:	8b 00                	mov    (%eax),%eax
80100d33:	89 04 24             	mov    %eax,(%esp)
80100d36:	e8 82 48 00 00       	call   801055bd <strlen>
80100d3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d3e:	29 c2                	sub    %eax,%edx
80100d40:	89 d0                	mov    %edx,%eax
80100d42:	83 e8 01             	sub    $0x1,%eax
80100d45:	83 e0 fc             	and    $0xfffffffc,%eax
80100d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	8b 00                	mov    (%eax),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 59 48 00 00       	call   801055bd <strlen>
80100d64:	83 c0 01             	add    $0x1,%eax
80100d67:	89 c2                	mov    %eax,%edx
80100d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d76:	01 c8                	add    %ecx,%eax
80100d78:	8b 00                	mov    (%eax),%eax
80100d7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d8c:	89 04 24             	mov    %eax,(%esp)
80100d8f:	e8 55 7a 00 00       	call   801087e9 <copyout>
80100d94:	85 c0                	test   %eax,%eax
80100d96:	79 05                	jns    80100d9d <exec+0x293>
      goto bad;
80100d98:	e9 5a 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    ustack[3+argc] = sp;
80100d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da0:	8d 50 03             	lea    0x3(%eax),%edx
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dad:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbe:	01 d0                	add    %edx,%eax
80100dc0:	8b 00                	mov    (%eax),%eax
80100dc2:	85 c0                	test   %eax,%eax
80100dc4:	0f 85 4d ff ff ff    	jne    80100d17 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	83 c0 03             	add    $0x3,%eax
80100dd0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dd7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100de2:	ff ff ff 
  ustack[1] = argc;
80100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de8:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dfe:	29 d0                	sub    %edx,%eax
80100e00:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	83 c0 04             	add    $0x4,%eax
80100e0c:	c1 e0 02             	shl    $0x2,%eax
80100e0f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e15:	83 c0 04             	add    $0x4,%eax
80100e18:	c1 e0 02             	shl    $0x2,%eax
80100e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e1f:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e25:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e33:	89 04 24             	mov    %eax,(%esp)
80100e36:	e8 ae 79 00 00       	call   801087e9 <copyout>
80100e3b:	85 c0                	test   %eax,%eax
80100e3d:	79 05                	jns    80100e44 <exec+0x33a>
    goto bad;
80100e3f:	e9 b3 00 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x35f>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x35b>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e7c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e83:	00 
80100e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8b:	89 14 24             	mov    %edx,(%esp)
80100e8e:	e8 e0 46 00 00       	call   80105573 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 04             	mov    0x4(%eax),%eax
80100e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebc:	8b 40 18             	mov    0x18(%eax),%eax
80100ebf:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ece:	8b 40 18             	mov    0x18(%eax),%eax
80100ed1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 32 72 00 00       	call   80108117 <switchuvm>
  freevm(oldpgdir);
80100ee5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee8:	89 04 24             	mov    %eax,(%esp)
80100eeb:	e8 9a 76 00 00       	call   8010858a <freevm>
  return 0;
80100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef5:	eb 2c                	jmp    80100f23 <exec+0x419>

 bad:
  if(pgdir)
80100ef7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efb:	74 0b                	je     80100f08 <exec+0x3fe>
    freevm(pgdir);
80100efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f00:	89 04 24             	mov    %eax,(%esp)
80100f03:	e8 82 76 00 00       	call   8010858a <freevm>
  if(ip){
80100f08:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0c:	74 10                	je     80100f1e <exec+0x414>
    iunlockput(ip);
80100f0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f11:	89 04 24             	mov    %eax,(%esp)
80100f14:	e8 45 0c 00 00       	call   80101b5e <iunlockput>
    end_op();
80100f19:	e8 22 26 00 00       	call   80103540 <end_op>
  }
  return -1;
80100f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f23:	c9                   	leave  
80100f24:	c3                   	ret    

80100f25 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f25:	55                   	push   %ebp
80100f26:	89 e5                	mov    %esp,%ebp
80100f28:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2b:	c7 44 24 04 fa 88 10 	movl   $0x801088fa,0x4(%esp)
80100f32:	80 
80100f33:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f3a:	e8 9f 41 00 00       	call   801050de <initlock>
}
80100f3f:	c9                   	leave  
80100f40:	c3                   	ret    

80100f41 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f41:	55                   	push   %ebp
80100f42:	89 e5                	mov    %esp,%ebp
80100f44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f47:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f4e:	e8 ac 41 00 00       	call   801050ff <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f53:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f5a:	eb 29                	jmp    80100f85 <filealloc+0x44>
    if(f->ref == 0){
80100f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5f:	8b 40 04             	mov    0x4(%eax),%eax
80100f62:	85 c0                	test   %eax,%eax
80100f64:	75 1b                	jne    80100f81 <filealloc+0x40>
      f->ref = 1;
80100f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f69:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f70:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f77:	e8 e5 41 00 00       	call   80105161 <release>
      return f;
80100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7f:	eb 1e                	jmp    80100f9f <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f81:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f85:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f8c:	72 ce                	jb     80100f5c <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f8e:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f95:	e8 c7 41 00 00       	call   80105161 <release>
  return 0;
80100f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9f:	c9                   	leave  
80100fa0:	c3                   	ret    

80100fa1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa1:	55                   	push   %ebp
80100fa2:	89 e5                	mov    %esp,%ebp
80100fa4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa7:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fae:	e8 4c 41 00 00       	call   801050ff <acquire>
  if(f->ref < 1)
80100fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb6:	8b 40 04             	mov    0x4(%eax),%eax
80100fb9:	85 c0                	test   %eax,%eax
80100fbb:	7f 0c                	jg     80100fc9 <filedup+0x28>
    panic("filedup");
80100fbd:	c7 04 24 01 89 10 80 	movl   $0x80108901,(%esp)
80100fc4:	e8 71 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	8b 40 04             	mov    0x4(%eax),%eax
80100fcf:	8d 50 01             	lea    0x1(%eax),%edx
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd8:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdf:	e8 7d 41 00 00       	call   80105161 <release>
  return f;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fef:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100ff6:	e8 04 41 00 00       	call   801050ff <acquire>
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0c                	jg     80101011 <fileclose+0x28>
    panic("fileclose");
80101005:	c7 04 24 09 89 10 80 	movl   $0x80108909,(%esp)
8010100c:	e8 29 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101011:	8b 45 08             	mov    0x8(%ebp),%eax
80101014:	8b 40 04             	mov    0x4(%eax),%eax
80101017:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	89 50 04             	mov    %edx,0x4(%eax)
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 40 04             	mov    0x4(%eax),%eax
80101026:	85 c0                	test   %eax,%eax
80101028:	7e 11                	jle    8010103b <fileclose+0x52>
    release(&ftable.lock);
8010102a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101031:	e8 2b 41 00 00       	call   80105161 <release>
80101036:	e9 82 00 00 00       	jmp    801010bd <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103b:	8b 45 08             	mov    0x8(%ebp),%eax
8010103e:	8b 10                	mov    (%eax),%edx
80101040:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101043:	8b 50 04             	mov    0x4(%eax),%edx
80101046:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101049:	8b 50 08             	mov    0x8(%eax),%edx
8010104c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104f:	8b 50 0c             	mov    0xc(%eax),%edx
80101052:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101055:	8b 50 10             	mov    0x10(%eax),%edx
80101058:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105b:	8b 40 14             	mov    0x14(%eax),%eax
8010105e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101074:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010107b:	e8 e1 40 00 00       	call   80105161 <release>
  
  if(ff.type == FD_PIPE)
80101080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101083:	83 f8 01             	cmp    $0x1,%eax
80101086:	75 18                	jne    801010a0 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101088:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108c:	0f be d0             	movsbl %al,%edx
8010108f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101092:	89 54 24 04          	mov    %edx,0x4(%esp)
80101096:	89 04 24             	mov    %eax,(%esp)
80101099:	e8 6d 30 00 00       	call   8010410b <pipeclose>
8010109e:	eb 1d                	jmp    801010bd <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a3:	83 f8 02             	cmp    $0x2,%eax
801010a6:	75 15                	jne    801010bd <fileclose+0xd4>
    begin_op();
801010a8:	e8 0f 24 00 00       	call   801034bc <begin_op>
    iput(ff.ip);
801010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 d5 09 00 00       	call   80101a8d <iput>
    end_op();
801010b8:	e8 83 24 00 00       	call   80103540 <end_op>
  }
}
801010bd:	c9                   	leave  
801010be:	c3                   	ret    

801010bf <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010bf:	55                   	push   %ebp
801010c0:	89 e5                	mov    %esp,%ebp
801010c2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 00                	mov    (%eax),%eax
801010ca:	83 f8 02             	cmp    $0x2,%eax
801010cd:	75 38                	jne    80101107 <filestat+0x48>
    ilock(f->ip);
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 10             	mov    0x10(%eax),%eax
801010d5:	89 04 24             	mov    %eax,(%esp)
801010d8:	e8 f7 07 00 00       	call   801018d4 <ilock>
    stati(f->ip, st);
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 40 10             	mov    0x10(%eax),%eax
801010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ea:	89 04 24             	mov    %eax,(%esp)
801010ed:	e8 b0 0c 00 00       	call   80101da2 <stati>
    iunlock(f->ip);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 10             	mov    0x10(%eax),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 28 09 00 00       	call   80101a28 <iunlock>
    return 0;
80101100:	b8 00 00 00 00       	mov    $0x0,%eax
80101105:	eb 05                	jmp    8010110c <filestat+0x4d>
  }
  return -1;
80101107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110c:	c9                   	leave  
8010110d:	c3                   	ret    

8010110e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010110e:	55                   	push   %ebp
8010110f:	89 e5                	mov    %esp,%ebp
80101111:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111b:	84 c0                	test   %al,%al
8010111d:	75 0a                	jne    80101129 <fileread+0x1b>
    return -1;
8010111f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101124:	e9 9f 00 00 00       	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 00                	mov    (%eax),%eax
8010112e:	83 f8 01             	cmp    $0x1,%eax
80101131:	75 1e                	jne    80101151 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 0c             	mov    0xc(%eax),%eax
80101139:	8b 55 10             	mov    0x10(%ebp),%edx
8010113c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101140:	8b 55 0c             	mov    0xc(%ebp),%edx
80101143:	89 54 24 04          	mov    %edx,0x4(%esp)
80101147:	89 04 24             	mov    %eax,(%esp)
8010114a:	e8 3d 31 00 00       	call   8010428c <piperead>
8010114f:	eb 77                	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_INODE){
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 00                	mov    (%eax),%eax
80101156:	83 f8 02             	cmp    $0x2,%eax
80101159:	75 61                	jne    801011bc <fileread+0xae>
    ilock(f->ip);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	89 04 24             	mov    %eax,(%esp)
80101164:	e8 6b 07 00 00       	call   801018d4 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101169:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 50 14             	mov    0x14(%eax),%edx
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 10             	mov    0x10(%eax),%eax
80101178:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 58 0c 00 00       	call   80101de7 <readi>
8010118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101192:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101196:	7e 11                	jle    801011a9 <fileread+0x9b>
      f->off += r;
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 50 14             	mov    0x14(%eax),%edx
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	01 c2                	add    %eax,%edx
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
801011a6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	8b 40 10             	mov    0x10(%eax),%eax
801011af:	89 04 24             	mov    %eax,(%esp)
801011b2:	e8 71 08 00 00       	call   80101a28 <iunlock>
    return r;
801011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ba:	eb 0c                	jmp    801011c8 <fileread+0xba>
  }
  panic("fileread");
801011bc:	c7 04 24 13 89 10 80 	movl   $0x80108913,(%esp)
801011c3:	e8 72 f3 ff ff       	call   8010053a <panic>
}
801011c8:	c9                   	leave  
801011c9:	c3                   	ret    

801011ca <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ca:	55                   	push   %ebp
801011cb:	89 e5                	mov    %esp,%ebp
801011cd:	53                   	push   %ebx
801011ce:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d8:	84 c0                	test   %al,%al
801011da:	75 0a                	jne    801011e6 <filewrite+0x1c>
    return -1;
801011dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e1:	e9 20 01 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 00                	mov    (%eax),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 21                	jne    80101211 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0c             	mov    0xc(%eax),%eax
801011f6:	8b 55 10             	mov    0x10(%ebp),%edx
801011f9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101200:	89 54 24 04          	mov    %edx,0x4(%esp)
80101204:	89 04 24             	mov    %eax,(%esp)
80101207:	e8 91 2f 00 00       	call   8010419d <pipewrite>
8010120c:	e9 f5 00 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 00                	mov    (%eax),%eax
80101216:	83 f8 02             	cmp    $0x2,%eax
80101219:	0f 85 db 00 00 00    	jne    801012fa <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121f:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010122d:	e9 a8 00 00 00       	jmp    801012da <filewrite+0x110>
      int n1 = n - i;
80101232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101235:	8b 55 10             	mov    0x10(%ebp),%edx
80101238:	29 c2                	sub    %eax,%edx
8010123a:	89 d0                	mov    %edx,%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101242:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101245:	7e 06                	jle    8010124d <filewrite+0x83>
        n1 = max;
80101247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010124d:	e8 6a 22 00 00       	call   801034bc <begin_op>
      ilock(f->ip);
80101252:	8b 45 08             	mov    0x8(%ebp),%eax
80101255:	8b 40 10             	mov    0x10(%eax),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 74 06 00 00       	call   801018d4 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101260:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 50 14             	mov    0x14(%eax),%edx
80101269:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010126c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010126f:	01 c3                	add    %eax,%ebx
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 40 10             	mov    0x10(%eax),%eax
80101277:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010127f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101283:	89 04 24             	mov    %eax,(%esp)
80101286:	e8 c0 0c 00 00       	call   80101f4b <writei>
8010128b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101292:	7e 11                	jle    801012a5 <filewrite+0xdb>
        f->off += r;
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 50 14             	mov    0x14(%eax),%edx
8010129a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129d:	01 c2                	add    %eax,%edx
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	89 04 24             	mov    %eax,(%esp)
801012ae:	e8 75 07 00 00       	call   80101a28 <iunlock>
      end_op();
801012b3:	e8 88 22 00 00       	call   80103540 <end_op>

      if(r < 0)
801012b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bc:	79 02                	jns    801012c0 <filewrite+0xf6>
        break;
801012be:	eb 26                	jmp    801012e6 <filewrite+0x11c>
      if(r != n1)
801012c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c6:	74 0c                	je     801012d4 <filewrite+0x10a>
        panic("short filewrite");
801012c8:	c7 04 24 1c 89 10 80 	movl   $0x8010891c,(%esp)
801012cf:	e8 66 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d7:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dd:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e0:	0f 8c 4c ff ff ff    	jl     80101232 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ec:	75 05                	jne    801012f3 <filewrite+0x129>
801012ee:	8b 45 10             	mov    0x10(%ebp),%eax
801012f1:	eb 05                	jmp    801012f8 <filewrite+0x12e>
801012f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f8:	eb 0c                	jmp    80101306 <filewrite+0x13c>
  }
  panic("filewrite");
801012fa:	c7 04 24 2c 89 10 80 	movl   $0x8010892c,(%esp)
80101301:	e8 34 f2 ff ff       	call   8010053a <panic>
}
80101306:	83 c4 24             	add    $0x24,%esp
80101309:	5b                   	pop    %ebx
8010130a:	5d                   	pop    %ebp
8010130b:	c3                   	ret    

8010130c <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010131c:	00 
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 81 ee ff ff       	call   801001a6 <bread>
80101325:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132b:	83 c0 18             	add    $0x18,%eax
8010132e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101335:	00 
80101336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 dd 40 00 00       	call   80105422 <memmove>
  brelse(bp);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 c7 ee ff ff       	call   80100217 <brelse>
}
80101350:	c9                   	leave  
80101351:	c3                   	ret    

80101352 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101352:	55                   	push   %ebp
80101353:	89 e5                	mov    %esp,%ebp
80101355:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101358:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101362:	89 04 24             	mov    %eax,(%esp)
80101365:	e8 3c ee ff ff       	call   801001a6 <bread>
8010136a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010136d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101370:	83 c0 18             	add    $0x18,%eax
80101373:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137a:	00 
8010137b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101382:	00 
80101383:	89 04 24             	mov    %eax,(%esp)
80101386:	e8 c8 3f 00 00       	call   80105353 <memset>
  log_write(bp);
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	89 04 24             	mov    %eax,(%esp)
80101391:	e8 31 23 00 00       	call   801036c7 <log_write>
  brelse(bp);
80101396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101399:	89 04 24             	mov    %eax,(%esp)
8010139c:	e8 76 ee ff ff       	call   80100217 <brelse>
}
801013a1:	c9                   	leave  
801013a2:	c3                   	ret    

801013a3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a3:	55                   	push   %ebp
801013a4:	89 e5                	mov    %esp,%ebp
801013a6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013a9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013b7:	e9 07 01 00 00       	jmp    801014c3 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013bf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c5:	85 c0                	test   %eax,%eax
801013c7:	0f 48 c2             	cmovs  %edx,%eax
801013ca:	c1 f8 0c             	sar    $0xc,%eax
801013cd:	89 c2                	mov    %eax,%edx
801013cf:	a1 58 12 11 80       	mov    0x80111258,%eax
801013d4:	01 d0                	add    %edx,%eax
801013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013da:	8b 45 08             	mov    0x8(%ebp),%eax
801013dd:	89 04 24             	mov    %eax,(%esp)
801013e0:	e8 c1 ed ff ff       	call   801001a6 <bread>
801013e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013ef:	e9 9d 00 00 00       	jmp    80101491 <balloc+0xee>
      m = 1 << (bi % 8);
801013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f7:	99                   	cltd   
801013f8:	c1 ea 1d             	shr    $0x1d,%edx
801013fb:	01 d0                	add    %edx,%eax
801013fd:	83 e0 07             	and    $0x7,%eax
80101400:	29 d0                	sub    %edx,%eax
80101402:	ba 01 00 00 00       	mov    $0x1,%edx
80101407:	89 c1                	mov    %eax,%ecx
80101409:	d3 e2                	shl    %cl,%edx
8010140b:	89 d0                	mov    %edx,%eax
8010140d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101413:	8d 50 07             	lea    0x7(%eax),%edx
80101416:	85 c0                	test   %eax,%eax
80101418:	0f 48 c2             	cmovs  %edx,%eax
8010141b:	c1 f8 03             	sar    $0x3,%eax
8010141e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101421:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101426:	0f b6 c0             	movzbl %al,%eax
80101429:	23 45 e8             	and    -0x18(%ebp),%eax
8010142c:	85 c0                	test   %eax,%eax
8010142e:	75 5d                	jne    8010148d <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101433:	8d 50 07             	lea    0x7(%eax),%edx
80101436:	85 c0                	test   %eax,%eax
80101438:	0f 48 c2             	cmovs  %edx,%eax
8010143b:	c1 f8 03             	sar    $0x3,%eax
8010143e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101441:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010144b:	09 ca                	or     %ecx,%edx
8010144d:	89 d1                	mov    %edx,%ecx
8010144f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101452:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101456:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101459:	89 04 24             	mov    %eax,(%esp)
8010145c:	e8 66 22 00 00       	call   801036c7 <log_write>
        brelse(bp);
80101461:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101464:	89 04 24             	mov    %eax,(%esp)
80101467:	e8 ab ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101472:	01 c2                	add    %eax,%edx
80101474:	8b 45 08             	mov    0x8(%ebp),%eax
80101477:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147b:	89 04 24             	mov    %eax,(%esp)
8010147e:	e8 cf fe ff ff       	call   80101352 <bzero>
        return b + bi;
80101483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101489:	01 d0                	add    %edx,%eax
8010148b:	eb 52                	jmp    801014df <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101491:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101498:	7f 17                	jg     801014b1 <balloc+0x10e>
8010149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a0:	01 d0                	add    %edx,%eax
801014a2:	89 c2                	mov    %eax,%edx
801014a4:	a1 40 12 11 80       	mov    0x80111240,%eax
801014a9:	39 c2                	cmp    %eax,%edx
801014ab:	0f 82 43 ff ff ff    	jb     801013f4 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b4:	89 04 24             	mov    %eax,(%esp)
801014b7:	e8 5b ed ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c6:	a1 40 12 11 80       	mov    0x80111240,%eax
801014cb:	39 c2                	cmp    %eax,%edx
801014cd:	0f 82 e9 fe ff ff    	jb     801013bc <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d3:	c7 04 24 38 89 10 80 	movl   $0x80108938,(%esp)
801014da:	e8 5b f0 ff ff       	call   8010053a <panic>
}
801014df:	c9                   	leave  
801014e0:	c3                   	ret    

801014e1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e1:	55                   	push   %ebp
801014e2:	89 e5                	mov    %esp,%ebp
801014e4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014e7:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801014ee:	80 
801014ef:	8b 45 08             	mov    0x8(%ebp),%eax
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 12 fe ff ff       	call   8010130c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801014fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801014fd:	c1 e8 0c             	shr    $0xc,%eax
80101500:	89 c2                	mov    %eax,%edx
80101502:	a1 58 12 11 80       	mov    0x80111258,%eax
80101507:	01 c2                	add    %eax,%edx
80101509:	8b 45 08             	mov    0x8(%ebp),%eax
8010150c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101510:	89 04 24             	mov    %eax,(%esp)
80101513:	e8 8e ec ff ff       	call   801001a6 <bread>
80101518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010151b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	99                   	cltd   
8010152a:	c1 ea 1d             	shr    $0x1d,%edx
8010152d:	01 d0                	add    %edx,%eax
8010152f:	83 e0 07             	and    $0x7,%eax
80101532:	29 d0                	sub    %edx,%eax
80101534:	ba 01 00 00 00       	mov    $0x1,%edx
80101539:	89 c1                	mov    %eax,%ecx
8010153b:	d3 e2                	shl    %cl,%edx
8010153d:	89 d0                	mov    %edx,%eax
8010153f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101545:	8d 50 07             	lea    0x7(%eax),%edx
80101548:	85 c0                	test   %eax,%eax
8010154a:	0f 48 c2             	cmovs  %edx,%eax
8010154d:	c1 f8 03             	sar    $0x3,%eax
80101550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101553:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101558:	0f b6 c0             	movzbl %al,%eax
8010155b:	23 45 ec             	and    -0x14(%ebp),%eax
8010155e:	85 c0                	test   %eax,%eax
80101560:	75 0c                	jne    8010156e <bfree+0x8d>
    panic("freeing free block");
80101562:	c7 04 24 4e 89 10 80 	movl   $0x8010894e,(%esp)
80101569:	e8 cc ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
8010156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101571:	8d 50 07             	lea    0x7(%eax),%edx
80101574:	85 c0                	test   %eax,%eax
80101576:	0f 48 c2             	cmovs  %edx,%eax
80101579:	c1 f8 03             	sar    $0x3,%eax
8010157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101584:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101587:	f7 d1                	not    %ecx
80101589:	21 ca                	and    %ecx,%edx
8010158b:	89 d1                	mov    %edx,%ecx
8010158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101590:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101597:	89 04 24             	mov    %eax,(%esp)
8010159a:	e8 28 21 00 00       	call   801036c7 <log_write>
  brelse(bp);
8010159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a2:	89 04 24             	mov    %eax,(%esp)
801015a5:	e8 6d ec ff ff       	call   80100217 <brelse>
}
801015aa:	c9                   	leave  
801015ab:	c3                   	ret    

801015ac <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015ac:	55                   	push   %ebp
801015ad:	89 e5                	mov    %esp,%ebp
801015af:	57                   	push   %edi
801015b0:	56                   	push   %esi
801015b1:	53                   	push   %ebx
801015b2:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
801015b5:	c7 44 24 04 61 89 10 	movl   $0x80108961,0x4(%esp)
801015bc:	80 
801015bd:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801015c4:	e8 15 3b 00 00       	call   801050de <initlock>
  readsb(dev, &sb);
801015c9:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801015d0:	80 
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	89 04 24             	mov    %eax,(%esp)
801015d7:	e8 30 fd ff ff       	call   8010130c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801015dc:	a1 58 12 11 80       	mov    0x80111258,%eax
801015e1:	8b 3d 54 12 11 80    	mov    0x80111254,%edi
801015e7:	8b 35 50 12 11 80    	mov    0x80111250,%esi
801015ed:	8b 1d 4c 12 11 80    	mov    0x8011124c,%ebx
801015f3:	8b 0d 48 12 11 80    	mov    0x80111248,%ecx
801015f9:	8b 15 44 12 11 80    	mov    0x80111244,%edx
801015ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101602:	8b 15 40 12 11 80    	mov    0x80111240,%edx
80101608:	89 44 24 1c          	mov    %eax,0x1c(%esp)
8010160c:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101610:	89 74 24 14          	mov    %esi,0x14(%esp)
80101614:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101618:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010161c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010161f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101623:	89 d0                	mov    %edx,%eax
80101625:	89 44 24 04          	mov    %eax,0x4(%esp)
80101629:	c7 04 24 68 89 10 80 	movl   $0x80108968,(%esp)
80101630:	e8 6b ed ff ff       	call   801003a0 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101635:	83 c4 3c             	add    $0x3c,%esp
80101638:	5b                   	pop    %ebx
80101639:	5e                   	pop    %esi
8010163a:	5f                   	pop    %edi
8010163b:	5d                   	pop    %ebp
8010163c:	c3                   	ret    

8010163d <ialloc>:

// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010163d:	55                   	push   %ebp
8010163e:	89 e5                	mov    %esp,%ebp
80101640:	83 ec 28             	sub    $0x28,%esp
80101643:	8b 45 0c             	mov    0xc(%ebp),%eax
80101646:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010164a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101651:	e9 9e 00 00 00       	jmp    801016f4 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101659:	c1 e8 03             	shr    $0x3,%eax
8010165c:	89 c2                	mov    %eax,%edx
8010165e:	a1 54 12 11 80       	mov    0x80111254,%eax
80101663:	01 d0                	add    %edx,%eax
80101665:	89 44 24 04          	mov    %eax,0x4(%esp)
80101669:	8b 45 08             	mov    0x8(%ebp),%eax
8010166c:	89 04 24             	mov    %eax,(%esp)
8010166f:	e8 32 eb ff ff       	call   801001a6 <bread>
80101674:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167a:	8d 50 18             	lea    0x18(%eax),%edx
8010167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101680:	83 e0 07             	and    $0x7,%eax
80101683:	c1 e0 06             	shl    $0x6,%eax
80101686:	01 d0                	add    %edx,%eax
80101688:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010168b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010168e:	0f b7 00             	movzwl (%eax),%eax
80101691:	66 85 c0             	test   %ax,%ax
80101694:	75 4f                	jne    801016e5 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101696:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010169d:	00 
8010169e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016a5:	00 
801016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a9:	89 04 24             	mov    %eax,(%esp)
801016ac:	e8 a2 3c 00 00       	call   80105353 <memset>
      dip->type = type;
801016b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016b4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801016b8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016be:	89 04 24             	mov    %eax,(%esp)
801016c1:	e8 01 20 00 00       	call   801036c7 <log_write>
      brelse(bp);
801016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c9:	89 04 24             	mov    %eax,(%esp)
801016cc:	e8 46 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	89 04 24             	mov    %eax,(%esp)
801016de:	e8 ed 00 00 00       	call   801017d0 <iget>
801016e3:	eb 2b                	jmp    80101710 <ialloc+0xd3>
    }
    brelse(bp);
801016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e8:	89 04 24             	mov    %eax,(%esp)
801016eb:	e8 27 eb ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f7:	a1 48 12 11 80       	mov    0x80111248,%eax
801016fc:	39 c2                	cmp    %eax,%edx
801016fe:	0f 82 52 ff ff ff    	jb     80101656 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101704:	c7 04 24 bb 89 10 80 	movl   $0x801089bb,(%esp)
8010170b:	e8 2a ee ff ff       	call   8010053a <panic>
}
80101710:	c9                   	leave  
80101711:	c3                   	ret    

80101712 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101712:	55                   	push   %ebp
80101713:	89 e5                	mov    %esp,%ebp
80101715:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101718:	8b 45 08             	mov    0x8(%ebp),%eax
8010171b:	8b 40 04             	mov    0x4(%eax),%eax
8010171e:	c1 e8 03             	shr    $0x3,%eax
80101721:	89 c2                	mov    %eax,%edx
80101723:	a1 54 12 11 80       	mov    0x80111254,%eax
80101728:	01 c2                	add    %eax,%edx
8010172a:	8b 45 08             	mov    0x8(%ebp),%eax
8010172d:	8b 00                	mov    (%eax),%eax
8010172f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101733:	89 04 24             	mov    %eax,(%esp)
80101736:	e8 6b ea ff ff       	call   801001a6 <bread>
8010173b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101741:	8d 50 18             	lea    0x18(%eax),%edx
80101744:	8b 45 08             	mov    0x8(%ebp),%eax
80101747:	8b 40 04             	mov    0x4(%eax),%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	c1 e0 06             	shl    $0x6,%eax
80101750:	01 d0                	add    %edx,%eax
80101752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101755:	8b 45 08             	mov    0x8(%ebp),%eax
80101758:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175f:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101762:	8b 45 08             	mov    0x8(%ebp),%eax
80101765:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101770:	8b 45 08             	mov    0x8(%ebp),%eax
80101773:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010177e:	8b 45 08             	mov    0x8(%ebp),%eax
80101781:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101788:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010178c:	8b 45 08             	mov    0x8(%ebp),%eax
8010178f:	8b 50 18             	mov    0x18(%eax),%edx
80101792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101795:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a1:	83 c0 0c             	add    $0xc,%eax
801017a4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017ab:	00 
801017ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b0:	89 04 24             	mov    %eax,(%esp)
801017b3:	e8 6a 3c 00 00       	call   80105422 <memmove>
  log_write(bp);
801017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bb:	89 04 24             	mov    %eax,(%esp)
801017be:	e8 04 1f 00 00       	call   801036c7 <log_write>
  brelse(bp);
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	89 04 24             	mov    %eax,(%esp)
801017c9:	e8 49 ea ff ff       	call   80100217 <brelse>
}
801017ce:	c9                   	leave  
801017cf:	c3                   	ret    

801017d0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017d0:	55                   	push   %ebp
801017d1:	89 e5                	mov    %esp,%ebp
801017d3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017d6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801017dd:	e8 1d 39 00 00       	call   801050ff <acquire>

  // Is the inode already cached?
  empty = 0;
801017e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e9:	c7 45 f4 94 12 11 80 	movl   $0x80111294,-0xc(%ebp)
801017f0:	eb 59                	jmp    8010184b <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f5:	8b 40 08             	mov    0x8(%eax),%eax
801017f8:	85 c0                	test   %eax,%eax
801017fa:	7e 35                	jle    80101831 <iget+0x61>
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	8b 00                	mov    (%eax),%eax
80101801:	3b 45 08             	cmp    0x8(%ebp),%eax
80101804:	75 2b                	jne    80101831 <iget+0x61>
80101806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101809:	8b 40 04             	mov    0x4(%eax),%eax
8010180c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010180f:	75 20                	jne    80101831 <iget+0x61>
      ip->ref++;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	8b 40 08             	mov    0x8(%eax),%eax
80101817:	8d 50 01             	lea    0x1(%eax),%edx
8010181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101820:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101827:	e8 35 39 00 00       	call   80105161 <release>
      return ip;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	eb 6f                	jmp    801018a0 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101831:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101835:	75 10                	jne    80101847 <iget+0x77>
80101837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183a:	8b 40 08             	mov    0x8(%eax),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	75 06                	jne    80101847 <iget+0x77>
      empty = ip;
80101841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101844:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101847:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010184b:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
80101852:	72 9e                	jb     801017f2 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101854:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101858:	75 0c                	jne    80101866 <iget+0x96>
    panic("iget: no inodes");
8010185a:	c7 04 24 cd 89 10 80 	movl   $0x801089cd,(%esp)
80101861:	e8 d4 ec ff ff       	call   8010053a <panic>

  ip = empty;
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186f:	8b 55 08             	mov    0x8(%ebp),%edx
80101872:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101877:	8b 55 0c             	mov    0xc(%ebp),%edx
8010187a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101880:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101891:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101898:	e8 c4 38 00 00       	call   80105161 <release>

  return ip;
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a0:	c9                   	leave  
801018a1:	c3                   	ret    

801018a2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a2:	55                   	push   %ebp
801018a3:	89 e5                	mov    %esp,%ebp
801018a5:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018a8:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018af:	e8 4b 38 00 00       	call   801050ff <acquire>
  ip->ref++;
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	8b 40 08             	mov    0x8(%eax),%eax
801018ba:	8d 50 01             	lea    0x1(%eax),%edx
801018bd:	8b 45 08             	mov    0x8(%ebp),%eax
801018c0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c3:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018ca:	e8 92 38 00 00       	call   80105161 <release>
  return ip;
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018d2:	c9                   	leave  
801018d3:	c3                   	ret    

801018d4 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018d4:	55                   	push   %ebp
801018d5:	89 e5                	mov    %esp,%ebp
801018d7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018de:	74 0a                	je     801018ea <ilock+0x16>
801018e0:	8b 45 08             	mov    0x8(%ebp),%eax
801018e3:	8b 40 08             	mov    0x8(%eax),%eax
801018e6:	85 c0                	test   %eax,%eax
801018e8:	7f 0c                	jg     801018f6 <ilock+0x22>
    panic("ilock");
801018ea:	c7 04 24 dd 89 10 80 	movl   $0x801089dd,(%esp)
801018f1:	e8 44 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801018f6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018fd:	e8 fd 37 00 00       	call   801050ff <acquire>
  while(ip->flags & I_BUSY)
80101902:	eb 13                	jmp    80101917 <ilock+0x43>
    sleep(ip, &icache.lock);
80101904:	c7 44 24 04 60 12 11 	movl   $0x80111260,0x4(%esp)
8010190b:	80 
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	89 04 24             	mov    %eax,(%esp)
80101912:	e8 3f 33 00 00       	call   80104c56 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 40 0c             	mov    0xc(%eax),%eax
8010191d:	83 e0 01             	and    $0x1,%eax
80101920:	85 c0                	test   %eax,%eax
80101922:	75 e0                	jne    80101904 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 40 0c             	mov    0xc(%eax),%eax
8010192a:	83 c8 01             	or     $0x1,%eax
8010192d:	89 c2                	mov    %eax,%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101935:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
8010193c:	e8 20 38 00 00       	call   80105161 <release>

  if(!(ip->flags & I_VALID)){
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 40 0c             	mov    0xc(%eax),%eax
80101947:	83 e0 02             	and    $0x2,%eax
8010194a:	85 c0                	test   %eax,%eax
8010194c:	0f 85 d4 00 00 00    	jne    80101a26 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	8b 40 04             	mov    0x4(%eax),%eax
80101958:	c1 e8 03             	shr    $0x3,%eax
8010195b:	89 c2                	mov    %eax,%edx
8010195d:	a1 54 12 11 80       	mov    0x80111254,%eax
80101962:	01 c2                	add    %eax,%edx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	8b 00                	mov    (%eax),%eax
80101969:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196d:	89 04 24             	mov    %eax,(%esp)
80101970:	e8 31 e8 ff ff       	call   801001a6 <bread>
80101975:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	8d 50 18             	lea    0x18(%eax),%edx
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	83 e0 07             	and    $0x7,%eax
80101987:	c1 e0 06             	shl    $0x6,%eax
8010198a:	01 d0                	add    %edx,%eax
8010198c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101992:	0f b7 10             	movzwl (%eax),%edx
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019a3:	8b 45 08             	mov    0x8(%ebp),%eax
801019a6:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ad:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019b1:	8b 45 08             	mov    0x8(%ebp),%eax
801019b4:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c9:	8b 50 08             	mov    0x8(%eax),%edx
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	8d 50 0c             	lea    0xc(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	83 c0 1c             	add    $0x1c,%eax
801019de:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019e5:	00 
801019e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801019ea:	89 04 24             	mov    %eax,(%esp)
801019ed:	e8 30 3a 00 00       	call   80105422 <memmove>
    brelse(bp);
801019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f5:	89 04 24             	mov    %eax,(%esp)
801019f8:	e8 1a e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	83 c8 02             	or     $0x2,%eax
80101a06:	89 c2                	mov    %eax,%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a15:	66 85 c0             	test   %ax,%ax
80101a18:	75 0c                	jne    80101a26 <ilock+0x152>
      panic("ilock: no type");
80101a1a:	c7 04 24 e3 89 10 80 	movl   $0x801089e3,(%esp)
80101a21:	e8 14 eb ff ff       	call   8010053a <panic>
  }
}
80101a26:	c9                   	leave  
80101a27:	c3                   	ret    

80101a28 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a28:	55                   	push   %ebp
80101a29:	89 e5                	mov    %esp,%ebp
80101a2b:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a32:	74 17                	je     80101a4b <iunlock+0x23>
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3a:	83 e0 01             	and    $0x1,%eax
80101a3d:	85 c0                	test   %eax,%eax
80101a3f:	74 0a                	je     80101a4b <iunlock+0x23>
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	85 c0                	test   %eax,%eax
80101a49:	7f 0c                	jg     80101a57 <iunlock+0x2f>
    panic("iunlock");
80101a4b:	c7 04 24 f2 89 10 80 	movl   $0x801089f2,(%esp)
80101a52:	e8 e3 ea ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101a57:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a5e:	e8 9c 36 00 00       	call   801050ff <acquire>
  ip->flags &= ~I_BUSY;
80101a63:	8b 45 08             	mov    0x8(%ebp),%eax
80101a66:	8b 40 0c             	mov    0xc(%eax),%eax
80101a69:	83 e0 fe             	and    $0xfffffffe,%eax
80101a6c:	89 c2                	mov    %eax,%edx
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	89 04 24             	mov    %eax,(%esp)
80101a7a:	e8 b3 32 00 00       	call   80104d32 <wakeup>
  release(&icache.lock);
80101a7f:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a86:	e8 d6 36 00 00       	call   80105161 <release>
}
80101a8b:	c9                   	leave  
80101a8c:	c3                   	ret    

80101a8d <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a8d:	55                   	push   %ebp
80101a8e:	89 e5                	mov    %esp,%ebp
80101a90:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a93:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a9a:	e8 60 36 00 00       	call   801050ff <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa2:	8b 40 08             	mov    0x8(%eax),%eax
80101aa5:	83 f8 01             	cmp    $0x1,%eax
80101aa8:	0f 85 93 00 00 00    	jne    80101b41 <iput+0xb4>
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab4:	83 e0 02             	and    $0x2,%eax
80101ab7:	85 c0                	test   %eax,%eax
80101ab9:	0f 84 82 00 00 00    	je     80101b41 <iput+0xb4>
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ac6:	66 85 c0             	test   %ax,%ax
80101ac9:	75 76                	jne    80101b41 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad1:	83 e0 01             	and    $0x1,%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	74 0c                	je     80101ae4 <iput+0x57>
      panic("iput busy");
80101ad8:	c7 04 24 fa 89 10 80 	movl   $0x801089fa,(%esp)
80101adf:	e8 56 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 0c             	mov    0xc(%eax),%eax
80101aea:	83 c8 01             	or     $0x1,%eax
80101aed:	89 c2                	mov    %eax,%edx
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101af5:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101afc:	e8 60 36 00 00       	call   80105161 <release>
    itrunc(ip);
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	89 04 24             	mov    %eax,(%esp)
80101b07:	e8 7d 01 00 00       	call   80101c89 <itrunc>
    ip->type = 0;
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	89 04 24             	mov    %eax,(%esp)
80101b1b:	e8 f2 fb ff ff       	call   80101712 <iupdate>
    acquire(&icache.lock);
80101b20:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b27:	e8 d3 35 00 00       	call   801050ff <acquire>
    ip->flags = 0;
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	89 04 24             	mov    %eax,(%esp)
80101b3c:	e8 f1 31 00 00       	call   80104d32 <wakeup>
  }
  ip->ref--;
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	8b 40 08             	mov    0x8(%eax),%eax
80101b47:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b50:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b57:	e8 05 36 00 00       	call   80105161 <release>
}
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	89 04 24             	mov    %eax,(%esp)
80101b6a:	e8 b9 fe ff ff       	call   80101a28 <iunlock>
  iput(ip);
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	89 04 24             	mov    %eax,(%esp)
80101b75:	e8 13 ff ff ff       	call   80101a8d <iput>
}
80101b7a:	c9                   	leave  
80101b7b:	c3                   	ret    

80101b7c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b7c:	55                   	push   %ebp
80101b7d:	89 e5                	mov    %esp,%ebp
80101b7f:	53                   	push   %ebx
80101b80:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b83:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b87:	77 3e                	ja     80101bc7 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b8f:	83 c2 04             	add    $0x4,%edx
80101b92:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b9d:	75 20                	jne    80101bbf <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 00                	mov    (%eax),%eax
80101ba4:	89 04 24             	mov    %eax,(%esp)
80101ba7:	e8 f7 f7 ff ff       	call   801013a3 <balloc>
80101bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb5:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bbb:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc2:	e9 bc 00 00 00       	jmp    80101c83 <bmap+0x107>
  }
  bn -= NDIRECT;
80101bc7:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bcb:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bcf:	0f 87 a2 00 00 00    	ja     80101c77 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be2:	75 19                	jne    80101bfd <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 00                	mov    (%eax),%eax
80101be9:	89 04 24             	mov    %eax,(%esp)
80101bec:	e8 b2 f7 ff ff       	call   801013a3 <balloc>
80101bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfa:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	8b 00                	mov    (%eax),%eax
80101c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c05:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c09:	89 04 24             	mov    %eax,(%esp)
80101c0c:	e8 95 e5 ff ff       	call   801001a6 <bread>
80101c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c17:	83 c0 18             	add    $0x18,%eax
80101c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c2a:	01 d0                	add    %edx,%eax
80101c2c:	8b 00                	mov    (%eax),%eax
80101c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c35:	75 30                	jne    80101c67 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101c37:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c44:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 00                	mov    (%eax),%eax
80101c4c:	89 04 24             	mov    %eax,(%esp)
80101c4f:	e8 4f f7 ff ff       	call   801013a3 <balloc>
80101c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 60 1a 00 00       	call   801036c7 <log_write>
    }
    brelse(bp);
80101c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6a:	89 04 24             	mov    %eax,(%esp)
80101c6d:	e8 a5 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c75:	eb 0c                	jmp    80101c83 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c77:	c7 04 24 04 8a 10 80 	movl   $0x80108a04,(%esp)
80101c7e:	e8 b7 e8 ff ff       	call   8010053a <panic>
}
80101c83:	83 c4 24             	add    $0x24,%esp
80101c86:	5b                   	pop    %ebx
80101c87:	5d                   	pop    %ebp
80101c88:	c3                   	ret    

80101c89 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c89:	55                   	push   %ebp
80101c8a:	89 e5                	mov    %esp,%ebp
80101c8c:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c96:	eb 44                	jmp    80101cdc <itrunc+0x53>
    if(ip->addrs[i]){
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9e:	83 c2 04             	add    $0x4,%edx
80101ca1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ca5:	85 c0                	test   %eax,%eax
80101ca7:	74 2f                	je     80101cd8 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101caf:	83 c2 04             	add    $0x4,%edx
80101cb2:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cbf:	89 04 24             	mov    %eax,(%esp)
80101cc2:	e8 1a f8 ff ff       	call   801014e1 <bfree>
      ip->addrs[i] = 0;
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ccd:	83 c2 04             	add    $0x4,%edx
80101cd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cd7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101cdc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ce0:	7e b6                	jle    80101c98 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ce8:	85 c0                	test   %eax,%eax
80101cea:	0f 84 9b 00 00 00    	je     80101d8b <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cff:	89 04 24             	mov    %eax,(%esp)
80101d02:	e8 9f e4 ff ff       	call   801001a6 <bread>
80101d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d0d:	83 c0 18             	add    $0x18,%eax
80101d10:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d1a:	eb 3b                	jmp    80101d57 <itrunc+0xce>
      if(a[j])
80101d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d29:	01 d0                	add    %edx,%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	85 c0                	test   %eax,%eax
80101d2f:	74 22                	je     80101d53 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d3e:	01 d0                	add    %edx,%eax
80101d40:	8b 10                	mov    (%eax),%edx
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4b:	89 04 24             	mov    %eax,(%esp)
80101d4e:	e8 8e f7 ff ff       	call   801014e1 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d53:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5a:	83 f8 7f             	cmp    $0x7f,%eax
80101d5d:	76 bd                	jbe    80101d1c <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d62:	89 04 24             	mov    %eax,(%esp)
80101d65:	e8 ad e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 00                	mov    (%eax),%eax
80101d75:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d79:	89 04 24             	mov    %eax,(%esp)
80101d7c:	e8 60 f7 ff ff       	call   801014e1 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	89 04 24             	mov    %eax,(%esp)
80101d9b:	e8 72 f9 ff ff       	call   80101712 <iupdate>
}
80101da0:	c9                   	leave  
80101da1:	c3                   	ret    

80101da2 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 00                	mov    (%eax),%eax
80101daa:	89 c2                	mov    %eax,%edx
80101dac:	8b 45 0c             	mov    0xc(%ebp),%eax
80101daf:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 50 04             	mov    0x4(%eax),%edx
80101db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbb:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	8b 50 18             	mov    0x18(%eax),%edx
80101ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101de5:	5d                   	pop    %ebp
80101de6:	c3                   	ret    

80101de7 <readi>:

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101de7:	55                   	push   %ebp
80101de8:	89 e5                	mov    %esp,%ebp
80101dea:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101df4:	66 83 f8 03          	cmp    $0x3,%ax
80101df8:	75 60                	jne    80101e5a <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e01:	66 85 c0             	test   %ax,%ax
80101e04:	78 20                	js     80101e26 <readi+0x3f>
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e0d:	66 83 f8 09          	cmp    $0x9,%ax
80101e11:	7f 13                	jg     80101e26 <readi+0x3f>
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e1a:	98                   	cwtl   
80101e1b:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e22:	85 c0                	test   %eax,%eax
80101e24:	75 0a                	jne    80101e30 <readi+0x49>
      return -1;
80101e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2b:	e9 19 01 00 00       	jmp    80101f49 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e37:	98                   	cwtl   
80101e38:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e3f:	8b 55 14             	mov    0x14(%ebp),%edx
80101e42:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e46:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e49:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e50:	89 14 24             	mov    %edx,(%esp)
80101e53:	ff d0                	call   *%eax
80101e55:	e9 ef 00 00 00       	jmp    80101f49 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	8b 40 18             	mov    0x18(%eax),%eax
80101e60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e63:	72 0d                	jb     80101e72 <readi+0x8b>
80101e65:	8b 45 14             	mov    0x14(%ebp),%eax
80101e68:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6b:	01 d0                	add    %edx,%eax
80101e6d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e70:	73 0a                	jae    80101e7c <readi+0x95>
    return -1;
80101e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e77:	e9 cd 00 00 00       	jmp    80101f49 <readi+0x162>
  if(off + n > ip->size)
80101e7c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e7f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e82:	01 c2                	add    %eax,%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 40 18             	mov    0x18(%eax),%eax
80101e8a:	39 c2                	cmp    %eax,%edx
80101e8c:	76 0c                	jbe    80101e9a <readi+0xb3>
    n = ip->size - off;
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 40 18             	mov    0x18(%eax),%eax
80101e94:	2b 45 10             	sub    0x10(%ebp),%eax
80101e97:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea1:	e9 94 00 00 00       	jmp    80101f3a <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80101ea9:	c1 e8 09             	shr    $0x9,%eax
80101eac:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	89 04 24             	mov    %eax,(%esp)
80101eb6:	e8 c1 fc ff ff       	call   80101b7c <bmap>
80101ebb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebe:	8b 12                	mov    (%edx),%edx
80101ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec4:	89 14 24             	mov    %edx,(%esp)
80101ec7:	e8 da e2 ff ff       	call   801001a6 <bread>
80101ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80101ed2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ed7:	89 c2                	mov    %eax,%edx
80101ed9:	b8 00 02 00 00       	mov    $0x200,%eax
80101ede:	29 d0                	sub    %edx,%eax
80101ee0:	89 c2                	mov    %eax,%edx
80101ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ee8:	29 c1                	sub    %eax,%ecx
80101eea:	89 c8                	mov    %ecx,%eax
80101eec:	39 c2                	cmp    %eax,%edx
80101eee:	0f 46 c2             	cmovbe %edx,%eax
80101ef1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ef4:	8b 45 10             	mov    0x10(%ebp),%eax
80101ef7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101efc:	8d 50 10             	lea    0x10(%eax),%edx
80101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f02:	01 d0                	add    %edx,%eax
80101f04:	8d 50 08             	lea    0x8(%eax),%edx
80101f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f15:	89 04 24             	mov    %eax,(%esp)
80101f18:	e8 05 35 00 00       	call   80105422 <memmove>
    brelse(bp);
80101f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f20:	89 04 24             	mov    %eax,(%esp)
80101f23:	e8 ef e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2b:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f31:	01 45 10             	add    %eax,0x10(%ebp)
80101f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f37:	01 45 0c             	add    %eax,0xc(%ebp)
80101f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f3d:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f40:	0f 82 60 ff ff ff    	jb     80101ea6 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f49:	c9                   	leave  
80101f4a:	c3                   	ret    

80101f4b <writei>:

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f4b:	55                   	push   %ebp
80101f4c:	89 e5                	mov    %esp,%ebp
80101f4e:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f58:	66 83 f8 03          	cmp    $0x3,%ax
80101f5c:	75 60                	jne    80101fbe <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f65:	66 85 c0             	test   %ax,%ax
80101f68:	78 20                	js     80101f8a <writei+0x3f>
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f71:	66 83 f8 09          	cmp    $0x9,%ax
80101f75:	7f 13                	jg     80101f8a <writei+0x3f>
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f7e:	98                   	cwtl   
80101f7f:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f86:	85 c0                	test   %eax,%eax
80101f88:	75 0a                	jne    80101f94 <writei+0x49>
      return -1;
80101f8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f8f:	e9 44 01 00 00       	jmp    801020d8 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f94:	8b 45 08             	mov    0x8(%ebp),%eax
80101f97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9b:	98                   	cwtl   
80101f9c:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101fa3:	8b 55 14             	mov    0x14(%ebp),%edx
80101fa6:	89 54 24 08          	mov    %edx,0x8(%esp)
80101faa:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fad:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb4:	89 14 24             	mov    %edx,(%esp)
80101fb7:	ff d0                	call   *%eax
80101fb9:	e9 1a 01 00 00       	jmp    801020d8 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	8b 40 18             	mov    0x18(%eax),%eax
80101fc4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc7:	72 0d                	jb     80101fd6 <writei+0x8b>
80101fc9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcf:	01 d0                	add    %edx,%eax
80101fd1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd4:	73 0a                	jae    80101fe0 <writei+0x95>
    return -1;
80101fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdb:	e9 f8 00 00 00       	jmp    801020d8 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fe0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe3:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fed:	76 0a                	jbe    80101ff9 <writei+0xae>
    return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 df 00 00 00       	jmp    801020d8 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ff9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102000:	e9 9f 00 00 00       	jmp    801020a4 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102005:	8b 45 10             	mov    0x10(%ebp),%eax
80102008:	c1 e8 09             	shr    $0x9,%eax
8010200b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	89 04 24             	mov    %eax,(%esp)
80102015:	e8 62 fb ff ff       	call   80101b7c <bmap>
8010201a:	8b 55 08             	mov    0x8(%ebp),%edx
8010201d:	8b 12                	mov    (%edx),%edx
8010201f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102023:	89 14 24             	mov    %edx,(%esp)
80102026:	e8 7b e1 ff ff       	call   801001a6 <bread>
8010202b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202e:	8b 45 10             	mov    0x10(%ebp),%eax
80102031:	25 ff 01 00 00       	and    $0x1ff,%eax
80102036:	89 c2                	mov    %eax,%edx
80102038:	b8 00 02 00 00       	mov    $0x200,%eax
8010203d:	29 d0                	sub    %edx,%eax
8010203f:	89 c2                	mov    %eax,%edx
80102041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102044:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102047:	29 c1                	sub    %eax,%ecx
80102049:	89 c8                	mov    %ecx,%eax
8010204b:	39 c2                	cmp    %eax,%edx
8010204d:	0f 46 c2             	cmovbe %edx,%eax
80102050:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102053:	8b 45 10             	mov    0x10(%ebp),%eax
80102056:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205b:	8d 50 10             	lea    0x10(%eax),%edx
8010205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102061:	01 d0                	add    %edx,%eax
80102063:	8d 50 08             	lea    0x8(%eax),%edx
80102066:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102069:	89 44 24 08          	mov    %eax,0x8(%esp)
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 44 24 04          	mov    %eax,0x4(%esp)
80102074:	89 14 24             	mov    %edx,(%esp)
80102077:	e8 a6 33 00 00       	call   80105422 <memmove>
    log_write(bp);
8010207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207f:	89 04 24             	mov    %eax,(%esp)
80102082:	e8 40 16 00 00       	call   801036c7 <log_write>
    brelse(bp);
80102087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208a:	89 04 24             	mov    %eax,(%esp)
8010208d:	e8 85 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102095:	01 45 f4             	add    %eax,-0xc(%ebp)
80102098:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209b:	01 45 10             	add    %eax,0x10(%ebp)
8010209e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a1:	01 45 0c             	add    %eax,0xc(%ebp)
801020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a7:	3b 45 14             	cmp    0x14(%ebp),%eax
801020aa:	0f 82 55 ff ff ff    	jb     80102005 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020b0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020b4:	74 1f                	je     801020d5 <writei+0x18a>
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	73 14                	jae    801020d5 <writei+0x18a>
    ip->size = off;
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	89 04 24             	mov    %eax,(%esp)
801020d0:	e8 3d f6 ff ff       	call   80101712 <iupdate>
  }
  return n;
801020d5:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020d8:	c9                   	leave  
801020d9:	c3                   	ret    

801020da <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
801020da:	55                   	push   %ebp
801020db:	89 e5                	mov    %esp,%ebp
801020dd:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020e7:	00 
801020e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 cb 33 00 00       	call   801054c5 <strncmp>
}
801020fa:	c9                   	leave  
801020fb:	c3                   	ret    

801020fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020fc:	55                   	push   %ebp
801020fd:	89 e5                	mov    %esp,%ebp
801020ff:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102109:	66 83 f8 01          	cmp    $0x1,%ax
8010210d:	74 0c                	je     8010211b <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010210f:	c7 04 24 17 8a 10 80 	movl   $0x80108a17,(%esp)
80102116:	e8 1f e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010211b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102122:	e9 88 00 00 00       	jmp    801021af <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102127:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010212e:	00 
8010212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102132:	89 44 24 08          	mov    %eax,0x8(%esp)
80102136:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102139:	89 44 24 04          	mov    %eax,0x4(%esp)
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	89 04 24             	mov    %eax,(%esp)
80102143:	e8 9f fc ff ff       	call   80101de7 <readi>
80102148:	83 f8 10             	cmp    $0x10,%eax
8010214b:	74 0c                	je     80102159 <dirlookup+0x5d>
      panic("dirlink read");
8010214d:	c7 04 24 29 8a 10 80 	movl   $0x80108a29,(%esp)
80102154:	e8 e1 e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102159:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010215d:	66 85 c0             	test   %ax,%ax
80102160:	75 02                	jne    80102164 <dirlookup+0x68>
      continue;
80102162:	eb 47                	jmp    801021ab <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102164:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102167:	83 c0 02             	add    $0x2,%eax
8010216a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102171:	89 04 24             	mov    %eax,(%esp)
80102174:	e8 61 ff ff ff       	call   801020da <namecmp>
80102179:	85 c0                	test   %eax,%eax
8010217b:	75 2e                	jne    801021ab <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010217d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102181:	74 08                	je     8010218b <dirlookup+0x8f>
        *poff = off;
80102183:	8b 45 10             	mov    0x10(%ebp),%eax
80102186:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102189:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010218b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010218f:	0f b7 c0             	movzwl %ax,%eax
80102192:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 00                	mov    (%eax),%eax
8010219a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010219d:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a1:	89 04 24             	mov    %eax,(%esp)
801021a4:	e8 27 f6 ff ff       	call   801017d0 <iget>
801021a9:	eb 18                	jmp    801021c3 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ab:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	8b 40 18             	mov    0x18(%eax),%eax
801021b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021b8:	0f 87 69 ff ff ff    	ja     80102127 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021c3:	c9                   	leave  
801021c4:	c3                   	ret    

801021c5 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021c5:	55                   	push   %ebp
801021c6:	89 e5                	mov    %esp,%ebp
801021c8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021d2:	00 
801021d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 17 ff ff ff       	call   801020fc <dirlookup>
801021e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021ec:	74 15                	je     80102203 <dirlink+0x3e>
    iput(ip);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 94 f8 ff ff       	call   80101a8d <iput>
    return -1;
801021f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021fe:	e9 b7 00 00 00       	jmp    801022ba <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102203:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220a:	eb 46                	jmp    80102252 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102216:	00 
80102217:	89 44 24 08          	mov    %eax,0x8(%esp)
8010221b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102222:	8b 45 08             	mov    0x8(%ebp),%eax
80102225:	89 04 24             	mov    %eax,(%esp)
80102228:	e8 ba fb ff ff       	call   80101de7 <readi>
8010222d:	83 f8 10             	cmp    $0x10,%eax
80102230:	74 0c                	je     8010223e <dirlink+0x79>
      panic("dirlink read");
80102232:	c7 04 24 29 8a 10 80 	movl   $0x80108a29,(%esp)
80102239:	e8 fc e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010223e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102242:	66 85 c0             	test   %ax,%ax
80102245:	75 02                	jne    80102249 <dirlink+0x84>
      break;
80102247:	eb 16                	jmp    8010225f <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010224c:	83 c0 10             	add    $0x10,%eax
8010224f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102252:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 40 18             	mov    0x18(%eax),%eax
8010225b:	39 c2                	cmp    %eax,%edx
8010225d:	72 ad                	jb     8010220c <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010225f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102266:	00 
80102267:	8b 45 0c             	mov    0xc(%ebp),%eax
8010226a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102271:	83 c0 02             	add    $0x2,%eax
80102274:	89 04 24             	mov    %eax,(%esp)
80102277:	e8 9f 32 00 00       	call   8010551b <strncpy>
  de.inum = inum;
8010227c:	8b 45 10             	mov    0x10(%ebp),%eax
8010227f:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102286:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010228d:	00 
8010228e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102292:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102295:	89 44 24 04          	mov    %eax,0x4(%esp)
80102299:	8b 45 08             	mov    0x8(%ebp),%eax
8010229c:	89 04 24             	mov    %eax,(%esp)
8010229f:	e8 a7 fc ff ff       	call   80101f4b <writei>
801022a4:	83 f8 10             	cmp    $0x10,%eax
801022a7:	74 0c                	je     801022b5 <dirlink+0xf0>
    panic("dirlink");
801022a9:	c7 04 24 36 8a 10 80 	movl   $0x80108a36,(%esp)
801022b0:	e8 85 e2 ff ff       	call   8010053a <panic>
  
  return 0;
801022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ba:	c9                   	leave  
801022bb:	c3                   	ret    

801022bc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022bc:	55                   	push   %ebp
801022bd:	89 e5                	mov    %esp,%ebp
801022bf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022c2:	eb 04                	jmp    801022c8 <skipelem+0xc>
    path++;
801022c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022c8:	8b 45 08             	mov    0x8(%ebp),%eax
801022cb:	0f b6 00             	movzbl (%eax),%eax
801022ce:	3c 2f                	cmp    $0x2f,%al
801022d0:	74 f2                	je     801022c4 <skipelem+0x8>
    path++;
  if(*path == 0)
801022d2:	8b 45 08             	mov    0x8(%ebp),%eax
801022d5:	0f b6 00             	movzbl (%eax),%eax
801022d8:	84 c0                	test   %al,%al
801022da:	75 0a                	jne    801022e6 <skipelem+0x2a>
    return 0;
801022dc:	b8 00 00 00 00       	mov    $0x0,%eax
801022e1:	e9 86 00 00 00       	jmp    8010236c <skipelem+0xb0>
  s = path;
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022ec:	eb 04                	jmp    801022f2 <skipelem+0x36>
    path++;
801022ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	0f b6 00             	movzbl (%eax),%eax
801022f8:	3c 2f                	cmp    $0x2f,%al
801022fa:	74 0a                	je     80102306 <skipelem+0x4a>
801022fc:	8b 45 08             	mov    0x8(%ebp),%eax
801022ff:	0f b6 00             	movzbl (%eax),%eax
80102302:	84 c0                	test   %al,%al
80102304:	75 e8                	jne    801022ee <skipelem+0x32>
    path++;
  len = path - s;
80102306:	8b 55 08             	mov    0x8(%ebp),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	29 c2                	sub    %eax,%edx
8010230e:	89 d0                	mov    %edx,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102313:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102317:	7e 1c                	jle    80102335 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102319:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102320:	00 
80102321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102324:	89 44 24 04          	mov    %eax,0x4(%esp)
80102328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232b:	89 04 24             	mov    %eax,(%esp)
8010232e:	e8 ef 30 00 00       	call   80105422 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102333:	eb 2a                	jmp    8010235f <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102338:	89 44 24 08          	mov    %eax,0x8(%esp)
8010233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102343:	8b 45 0c             	mov    0xc(%ebp),%eax
80102346:	89 04 24             	mov    %eax,(%esp)
80102349:	e8 d4 30 00 00       	call   80105422 <memmove>
    name[len] = 0;
8010234e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102351:	8b 45 0c             	mov    0xc(%ebp),%eax
80102354:	01 d0                	add    %edx,%eax
80102356:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102359:	eb 04                	jmp    8010235f <skipelem+0xa3>
    path++;
8010235b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b6 00             	movzbl (%eax),%eax
80102365:	3c 2f                	cmp    $0x2f,%al
80102367:	74 f2                	je     8010235b <skipelem+0x9f>
    path++;
  return path;
80102369:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010236c:	c9                   	leave  
8010236d:	c3                   	ret    

8010236e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010236e:	55                   	push   %ebp
8010236f:	89 e5                	mov    %esp,%ebp
80102371:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	3c 2f                	cmp    $0x2f,%al
8010237c:	75 1c                	jne    8010239a <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010237e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102385:	00 
80102386:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010238d:	e8 3e f4 ff ff       	call   801017d0 <iget>
80102392:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102395:	e9 af 00 00 00       	jmp    80102449 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010239a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023a0:	8b 40 68             	mov    0x68(%eax),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 f7 f4 ff ff       	call   801018a2 <idup>
801023ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ae:	e9 96 00 00 00       	jmp    80102449 <namex+0xdb>
    ilock(ip);
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	89 04 24             	mov    %eax,(%esp)
801023b9:	e8 16 f5 ff ff       	call   801018d4 <ilock>
    if(ip->type != T_DIR){
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023c5:	66 83 f8 01          	cmp    $0x1,%ax
801023c9:	74 15                	je     801023e0 <namex+0x72>
      iunlockput(ip);
801023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ce:	89 04 24             	mov    %eax,(%esp)
801023d1:	e8 88 f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
801023d6:	b8 00 00 00 00       	mov    $0x0,%eax
801023db:	e9 a3 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e4:	74 1d                	je     80102403 <namex+0x95>
801023e6:	8b 45 08             	mov    0x8(%ebp),%eax
801023e9:	0f b6 00             	movzbl (%eax),%eax
801023ec:	84 c0                	test   %al,%al
801023ee:	75 13                	jne    80102403 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f3:	89 04 24             	mov    %eax,(%esp)
801023f6:	e8 2d f6 ff ff       	call   80101a28 <iunlock>
      return ip;
801023fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fe:	e9 80 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010240a:	00 
8010240b:	8b 45 10             	mov    0x10(%ebp),%eax
8010240e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102415:	89 04 24             	mov    %eax,(%esp)
80102418:	e8 df fc ff ff       	call   801020fc <dirlookup>
8010241d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102424:	75 12                	jne    80102438 <namex+0xca>
      iunlockput(ip);
80102426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102429:	89 04 24             	mov    %eax,(%esp)
8010242c:	e8 2d f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
80102431:	b8 00 00 00 00       	mov    $0x0,%eax
80102436:	eb 4b                	jmp    80102483 <namex+0x115>
    }
    iunlockput(ip);
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	89 04 24             	mov    %eax,(%esp)
8010243e:	e8 1b f7 ff ff       	call   80101b5e <iunlockput>
    ip = next;
80102443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102449:	8b 45 10             	mov    0x10(%ebp),%eax
8010244c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	89 04 24             	mov    %eax,(%esp)
80102456:	e8 61 fe ff ff       	call   801022bc <skipelem>
8010245b:	89 45 08             	mov    %eax,0x8(%ebp)
8010245e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102462:	0f 85 4b ff ff ff    	jne    801023b3 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102468:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246c:	74 12                	je     80102480 <namex+0x112>
    iput(ip);
8010246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102471:	89 04 24             	mov    %eax,(%esp)
80102474:	e8 14 f6 ff ff       	call   80101a8d <iput>
    return 0;
80102479:	b8 00 00 00 00       	mov    $0x0,%eax
8010247e:	eb 03                	jmp    80102483 <namex+0x115>
  }
  return ip;
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102483:	c9                   	leave  
80102484:	c3                   	ret    

80102485 <namei>:

struct inode*
namei(char *path)
{
80102485:	55                   	push   %ebp
80102486:	89 e5                	mov    %esp,%ebp
80102488:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010248b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010248e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102499:	00 
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	89 04 24             	mov    %eax,(%esp)
801024a0:	e8 c9 fe ff ff       	call   8010236e <namex>
}
801024a5:	c9                   	leave  
801024a6:	c3                   	ret    

801024a7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024a7:	55                   	push   %ebp
801024a8:	89 e5                	mov    %esp,%ebp
801024aa:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024bb:	00 
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	89 04 24             	mov    %eax,(%esp)
801024c2:	e8 a7 fe ff ff       	call   8010236e <namex>
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	83 ec 14             	sub    $0x14,%esp
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024da:	89 c2                	mov    %eax,%edx
801024dc:	ec                   	in     (%dx),%al
801024dd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024e0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024e4:	c9                   	leave  
801024e5:	c3                   	ret    

801024e6 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e6:	55                   	push   %ebp
801024e7:	89 e5                	mov    %esp,%ebp
801024e9:	57                   	push   %edi
801024ea:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024eb:	8b 55 08             	mov    0x8(%ebp),%edx
801024ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024f1:	8b 45 10             	mov    0x10(%ebp),%eax
801024f4:	89 cb                	mov    %ecx,%ebx
801024f6:	89 df                	mov    %ebx,%edi
801024f8:	89 c1                	mov    %eax,%ecx
801024fa:	fc                   	cld    
801024fb:	f3 6d                	rep insl (%dx),%es:(%edi)
801024fd:	89 c8                	mov    %ecx,%eax
801024ff:	89 fb                	mov    %edi,%ebx
80102501:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102504:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102507:	5b                   	pop    %ebx
80102508:	5f                   	pop    %edi
80102509:	5d                   	pop    %ebp
8010250a:	c3                   	ret    

8010250b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010250b:	55                   	push   %ebp
8010250c:	89 e5                	mov    %esp,%ebp
8010250e:	83 ec 08             	sub    $0x8,%esp
80102511:	8b 55 08             	mov    0x8(%ebp),%edx
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010251b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102522:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102526:	ee                   	out    %al,(%dx)
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	56                   	push   %esi
8010252d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252e:	8b 55 08             	mov    0x8(%ebp),%edx
80102531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102534:	8b 45 10             	mov    0x10(%ebp),%eax
80102537:	89 cb                	mov    %ecx,%ebx
80102539:	89 de                	mov    %ebx,%esi
8010253b:	89 c1                	mov    %eax,%ecx
8010253d:	fc                   	cld    
8010253e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102540:	89 c8                	mov    %ecx,%eax
80102542:	89 f3                	mov    %esi,%ebx
80102544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102547:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010254a:	5b                   	pop    %ebx
8010254b:	5e                   	pop    %esi
8010254c:	5d                   	pop    %ebp
8010254d:	c3                   	ret    

8010254e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254e:	55                   	push   %ebp
8010254f:	89 e5                	mov    %esp,%ebp
80102551:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102554:	90                   	nop
80102555:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010255c:	e8 68 ff ff ff       	call   801024c9 <inb>
80102561:	0f b6 c0             	movzbl %al,%eax
80102564:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010256a:	25 c0 00 00 00       	and    $0xc0,%eax
8010256f:	83 f8 40             	cmp    $0x40,%eax
80102572:	75 e1                	jne    80102555 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102578:	74 11                	je     8010258b <idewait+0x3d>
8010257a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257d:	83 e0 21             	and    $0x21,%eax
80102580:	85 c0                	test   %eax,%eax
80102582:	74 07                	je     8010258b <idewait+0x3d>
    return -1;
80102584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102589:	eb 05                	jmp    80102590 <idewait+0x42>
  return 0;
8010258b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102590:	c9                   	leave  
80102591:	c3                   	ret    

80102592 <ideinit>:

void
ideinit(void)
{
80102592:	55                   	push   %ebp
80102593:	89 e5                	mov    %esp,%ebp
80102595:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102598:	c7 44 24 04 3e 8a 10 	movl   $0x80108a3e,0x4(%esp)
8010259f:	80 
801025a0:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801025a7:	e8 32 2b 00 00       	call   801050de <initlock>
  picenable(IRQ_IDE);
801025ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025b3:	e8 a3 18 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025b8:	a1 60 29 11 80       	mov    0x80112960,%eax
801025bd:	83 e8 01             	sub    $0x1,%eax
801025c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801025c4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025cb:	e8 43 04 00 00       	call   80102a13 <ioapicenable>
  idewait(0);
801025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d7:	e8 72 ff ff ff       	call   8010254e <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025dc:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025e3:	00 
801025e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025eb:	e8 1b ff ff ff       	call   8010250b <outb>
  for(i=0; i<1000; i++){
801025f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f7:	eb 20                	jmp    80102619 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025f9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102600:	e8 c4 fe ff ff       	call   801024c9 <inb>
80102605:	84 c0                	test   %al,%al
80102607:	74 0c                	je     80102615 <ideinit+0x83>
      havedisk1 = 1;
80102609:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102610:	00 00 00 
      break;
80102613:	eb 0d                	jmp    80102622 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102619:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102620:	7e d7                	jle    801025f9 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102622:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102629:	00 
8010262a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102631:	e8 d5 fe ff ff       	call   8010250b <outb>
}
80102636:	c9                   	leave  
80102637:	c3                   	ret    

80102638 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010263e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102642:	75 0c                	jne    80102650 <idestart+0x18>
    panic("idestart");
80102644:	c7 04 24 42 8a 10 80 	movl   $0x80108a42,(%esp)
8010264b:	e8 ea de ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE)
80102650:	8b 45 08             	mov    0x8(%ebp),%eax
80102653:	8b 40 08             	mov    0x8(%eax),%eax
80102656:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010265b:	76 0c                	jbe    80102669 <idestart+0x31>
    panic("incorrect blockno");
8010265d:	c7 04 24 4b 8a 10 80 	movl   $0x80108a4b,(%esp)
80102664:	e8 d1 de ff ff       	call   8010053a <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102669:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102670:	8b 45 08             	mov    0x8(%ebp),%eax
80102673:	8b 50 08             	mov    0x8(%eax),%edx
80102676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102679:	0f af c2             	imul   %edx,%eax
8010267c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010267f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102683:	7e 0c                	jle    80102691 <idestart+0x59>
80102685:	c7 04 24 42 8a 10 80 	movl   $0x80108a42,(%esp)
8010268c:	e8 a9 de ff ff       	call   8010053a <panic>
  
  idewait(0);
80102691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102698:	e8 b1 fe ff ff       	call   8010254e <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010269d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026a4:	00 
801026a5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026ac:	e8 5a fe ff ff       	call   8010250b <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b4:	0f b6 c0             	movzbl %al,%eax
801026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bb:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026c2:	e8 44 fe ff ff       	call   8010250b <outb>
  outb(0x1f3, sector & 0xff);
801026c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026ca:	0f b6 c0             	movzbl %al,%eax
801026cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d1:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026d8:	e8 2e fe ff ff       	call   8010250b <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e0:	c1 f8 08             	sar    $0x8,%eax
801026e3:	0f b6 c0             	movzbl %al,%eax
801026e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ea:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026f1:	e8 15 fe ff ff       	call   8010250b <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f9:	c1 f8 10             	sar    $0x10,%eax
801026fc:	0f b6 c0             	movzbl %al,%eax
801026ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102703:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010270a:	e8 fc fd ff ff       	call   8010250b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010270f:	8b 45 08             	mov    0x8(%ebp),%eax
80102712:	8b 40 04             	mov    0x4(%eax),%eax
80102715:	83 e0 01             	and    $0x1,%eax
80102718:	c1 e0 04             	shl    $0x4,%eax
8010271b:	89 c2                	mov    %eax,%edx
8010271d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102720:	c1 f8 18             	sar    $0x18,%eax
80102723:	83 e0 0f             	and    $0xf,%eax
80102726:	09 d0                	or     %edx,%eax
80102728:	83 c8 e0             	or     $0xffffffe0,%eax
8010272b:	0f b6 c0             	movzbl %al,%eax
8010272e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102732:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102739:	e8 cd fd ff ff       	call   8010250b <outb>
  if(b->flags & B_DIRTY){
8010273e:	8b 45 08             	mov    0x8(%ebp),%eax
80102741:	8b 00                	mov    (%eax),%eax
80102743:	83 e0 04             	and    $0x4,%eax
80102746:	85 c0                	test   %eax,%eax
80102748:	74 34                	je     8010277e <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
8010274a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102751:	00 
80102752:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102759:	e8 ad fd ff ff       	call   8010250b <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010275e:	8b 45 08             	mov    0x8(%ebp),%eax
80102761:	83 c0 18             	add    $0x18,%eax
80102764:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010276b:	00 
8010276c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102770:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102777:	e8 ad fd ff ff       	call   80102529 <outsl>
8010277c:	eb 14                	jmp    80102792 <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010277e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102785:	00 
80102786:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010278d:	e8 79 fd ff ff       	call   8010250b <outb>
  }
}
80102792:	c9                   	leave  
80102793:	c3                   	ret    

80102794 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010279a:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027a1:	e8 59 29 00 00       	call   801050ff <acquire>
  if((b = idequeue) == 0){
801027a6:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801027ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b2:	75 11                	jne    801027c5 <ideintr+0x31>
    release(&idelock);
801027b4:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027bb:	e8 a1 29 00 00       	call   80105161 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801027c0:	e9 90 00 00 00       	jmp    80102855 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c8:	8b 40 14             	mov    0x14(%eax),%eax
801027cb:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	8b 00                	mov    (%eax),%eax
801027d5:	83 e0 04             	and    $0x4,%eax
801027d8:	85 c0                	test   %eax,%eax
801027da:	75 2e                	jne    8010280a <ideintr+0x76>
801027dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027e3:	e8 66 fd ff ff       	call   8010254e <idewait>
801027e8:	85 c0                	test   %eax,%eax
801027ea:	78 1e                	js     8010280a <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ef:	83 c0 18             	add    $0x18,%eax
801027f2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027f9:	00 
801027fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801027fe:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102805:	e8 dc fc ff ff       	call   801024e6 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	8b 00                	mov    (%eax),%eax
8010280f:	83 c8 02             	or     $0x2,%eax
80102812:	89 c2                	mov    %eax,%edx
80102814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102817:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	8b 00                	mov    (%eax),%eax
8010281e:	83 e0 fb             	and    $0xfffffffb,%eax
80102821:	89 c2                	mov    %eax,%edx
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	89 04 24             	mov    %eax,(%esp)
8010282e:	e8 ff 24 00 00       	call   80104d32 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102833:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102838:	85 c0                	test   %eax,%eax
8010283a:	74 0d                	je     80102849 <ideintr+0xb5>
    idestart(idequeue);
8010283c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102841:	89 04 24             	mov    %eax,(%esp)
80102844:	e8 ef fd ff ff       	call   80102638 <idestart>

  release(&idelock);
80102849:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102850:	e8 0c 29 00 00       	call   80105161 <release>
}
80102855:	c9                   	leave  
80102856:	c3                   	ret    

80102857 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	8b 00                	mov    (%eax),%eax
80102862:	83 e0 01             	and    $0x1,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	75 0c                	jne    80102875 <iderw+0x1e>
    panic("iderw: buf not busy");
80102869:	c7 04 24 5d 8a 10 80 	movl   $0x80108a5d,(%esp)
80102870:	e8 c5 dc ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102875:	8b 45 08             	mov    0x8(%ebp),%eax
80102878:	8b 00                	mov    (%eax),%eax
8010287a:	83 e0 06             	and    $0x6,%eax
8010287d:	83 f8 02             	cmp    $0x2,%eax
80102880:	75 0c                	jne    8010288e <iderw+0x37>
    panic("iderw: nothing to do");
80102882:	c7 04 24 71 8a 10 80 	movl   $0x80108a71,(%esp)
80102889:	e8 ac dc ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
8010288e:	8b 45 08             	mov    0x8(%ebp),%eax
80102891:	8b 40 04             	mov    0x4(%eax),%eax
80102894:	85 c0                	test   %eax,%eax
80102896:	74 15                	je     801028ad <iderw+0x56>
80102898:	a1 58 b6 10 80       	mov    0x8010b658,%eax
8010289d:	85 c0                	test   %eax,%eax
8010289f:	75 0c                	jne    801028ad <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801028a1:	c7 04 24 86 8a 10 80 	movl   $0x80108a86,(%esp)
801028a8:	e8 8d dc ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028ad:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801028b4:	e8 46 28 00 00       	call   801050ff <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028c3:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028ca:	eb 0b                	jmp    801028d7 <iderw+0x80>
801028cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cf:	8b 00                	mov    (%eax),%eax
801028d1:	83 c0 14             	add    $0x14,%eax
801028d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028da:	8b 00                	mov    (%eax),%eax
801028dc:	85 c0                	test   %eax,%eax
801028de:	75 ec                	jne    801028cc <iderw+0x75>
    ;
  *pp = b;
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	8b 55 08             	mov    0x8(%ebp),%edx
801028e6:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028e8:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028ed:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f0:	75 0d                	jne    801028ff <iderw+0xa8>
    idestart(b);
801028f2:	8b 45 08             	mov    0x8(%ebp),%eax
801028f5:	89 04 24             	mov    %eax,(%esp)
801028f8:	e8 3b fd ff ff       	call   80102638 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028fd:	eb 15                	jmp    80102914 <iderw+0xbd>
801028ff:	eb 13                	jmp    80102914 <iderw+0xbd>
    sleep(b, &idelock);
80102901:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
80102908:	80 
80102909:	8b 45 08             	mov    0x8(%ebp),%eax
8010290c:	89 04 24             	mov    %eax,(%esp)
8010290f:	e8 42 23 00 00       	call   80104c56 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	8b 00                	mov    (%eax),%eax
80102919:	83 e0 06             	and    $0x6,%eax
8010291c:	83 f8 02             	cmp    $0x2,%eax
8010291f:	75 e0                	jne    80102901 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102921:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102928:	e8 34 28 00 00       	call   80105161 <release>
}
8010292d:	c9                   	leave  
8010292e:	c3                   	ret    

8010292f <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010292f:	55                   	push   %ebp
80102930:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102932:	a1 34 22 11 80       	mov    0x80112234,%eax
80102937:	8b 55 08             	mov    0x8(%ebp),%edx
8010293a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010293c:	a1 34 22 11 80       	mov    0x80112234,%eax
80102941:	8b 40 10             	mov    0x10(%eax),%eax
}
80102944:	5d                   	pop    %ebp
80102945:	c3                   	ret    

80102946 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102946:	55                   	push   %ebp
80102947:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102949:	a1 34 22 11 80       	mov    0x80112234,%eax
8010294e:	8b 55 08             	mov    0x8(%ebp),%edx
80102951:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102953:	a1 34 22 11 80       	mov    0x80112234,%eax
80102958:	8b 55 0c             	mov    0xc(%ebp),%edx
8010295b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010295e:	5d                   	pop    %ebp
8010295f:	c3                   	ret    

80102960 <ioapicinit>:

void
ioapicinit(void)
{
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102966:	a1 64 23 11 80       	mov    0x80112364,%eax
8010296b:	85 c0                	test   %eax,%eax
8010296d:	75 05                	jne    80102974 <ioapicinit+0x14>
    return;
8010296f:	e9 9d 00 00 00       	jmp    80102a11 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102974:	c7 05 34 22 11 80 00 	movl   $0xfec00000,0x80112234
8010297b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010297e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102985:	e8 a5 ff ff ff       	call   8010292f <ioapicread>
8010298a:	c1 e8 10             	shr    $0x10,%eax
8010298d:	25 ff 00 00 00       	and    $0xff,%eax
80102992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102995:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010299c:	e8 8e ff ff ff       	call   8010292f <ioapicread>
801029a1:	c1 e8 18             	shr    $0x18,%eax
801029a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029a7:	0f b6 05 60 23 11 80 	movzbl 0x80112360,%eax
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029b4:	74 0c                	je     801029c2 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029b6:	c7 04 24 a4 8a 10 80 	movl   $0x80108aa4,(%esp)
801029bd:	e8 de d9 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029c9:	eb 3e                	jmp    80102a09 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ce:	83 c0 20             	add    $0x20,%eax
801029d1:	0d 00 00 01 00       	or     $0x10000,%eax
801029d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029d9:	83 c2 08             	add    $0x8,%edx
801029dc:	01 d2                	add    %edx,%edx
801029de:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e2:	89 14 24             	mov    %edx,(%esp)
801029e5:	e8 5c ff ff ff       	call   80102946 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ed:	83 c0 08             	add    $0x8,%eax
801029f0:	01 c0                	add    %eax,%eax
801029f2:	83 c0 01             	add    $0x1,%eax
801029f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029fc:	00 
801029fd:	89 04 24             	mov    %eax,(%esp)
80102a00:	e8 41 ff ff ff       	call   80102946 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a0f:	7e ba                	jle    801029cb <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a11:	c9                   	leave  
80102a12:	c3                   	ret    

80102a13 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a13:	55                   	push   %ebp
80102a14:	89 e5                	mov    %esp,%ebp
80102a16:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102a19:	a1 64 23 11 80       	mov    0x80112364,%eax
80102a1e:	85 c0                	test   %eax,%eax
80102a20:	75 02                	jne    80102a24 <ioapicenable+0x11>
    return;
80102a22:	eb 37                	jmp    80102a5b <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a24:	8b 45 08             	mov    0x8(%ebp),%eax
80102a27:	83 c0 20             	add    $0x20,%eax
80102a2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a2d:	83 c2 08             	add    $0x8,%edx
80102a30:	01 d2                	add    %edx,%edx
80102a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a36:	89 14 24             	mov    %edx,(%esp)
80102a39:	e8 08 ff ff ff       	call   80102946 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a41:	c1 e0 18             	shl    $0x18,%eax
80102a44:	8b 55 08             	mov    0x8(%ebp),%edx
80102a47:	83 c2 08             	add    $0x8,%edx
80102a4a:	01 d2                	add    %edx,%edx
80102a4c:	83 c2 01             	add    $0x1,%edx
80102a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a53:	89 14 24             	mov    %edx,(%esp)
80102a56:	e8 eb fe ff ff       	call   80102946 <ioapicwrite>
}
80102a5b:	c9                   	leave  
80102a5c:	c3                   	ret    

80102a5d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a5d:	55                   	push   %ebp
80102a5e:	89 e5                	mov    %esp,%ebp
80102a60:	8b 45 08             	mov    0x8(%ebp),%eax
80102a63:	05 00 00 00 80       	add    $0x80000000,%eax
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a70:	c7 44 24 04 d6 8a 10 	movl   $0x80108ad6,0x4(%esp)
80102a77:	80 
80102a78:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102a7f:	e8 5a 26 00 00       	call   801050de <initlock>
  kmem.use_lock = 0;
80102a84:	c7 05 74 22 11 80 00 	movl   $0x0,0x80112274
80102a8b:	00 00 00 
  freerange(vstart, vend);
80102a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a95:	8b 45 08             	mov    0x8(%ebp),%eax
80102a98:	89 04 24             	mov    %eax,(%esp)
80102a9b:	e8 26 00 00 00       	call   80102ac6 <freerange>
}
80102aa0:	c9                   	leave  
80102aa1:	c3                   	ret    

80102aa2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102aa2:	55                   	push   %ebp
80102aa3:	89 e5                	mov    %esp,%ebp
80102aa5:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab2:	89 04 24             	mov    %eax,(%esp)
80102ab5:	e8 0c 00 00 00       	call   80102ac6 <freerange>
  kmem.use_lock = 1;
80102aba:	c7 05 74 22 11 80 01 	movl   $0x1,0x80112274
80102ac1:	00 00 00 
}
80102ac4:	c9                   	leave  
80102ac5:	c3                   	ret    

80102ac6 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102acc:	8b 45 08             	mov    0x8(%ebp),%eax
80102acf:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102adc:	eb 12                	jmp    80102af0 <freerange+0x2a>
    kfree(p);
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 16 00 00 00       	call   80102aff <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	05 00 10 00 00       	add    $0x1000,%eax
80102af8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102afb:	76 e1                	jbe    80102ade <freerange+0x18>
    kfree(p);
}
80102afd:	c9                   	leave  
80102afe:	c3                   	ret    

80102aff <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aff:	55                   	push   %ebp
80102b00:	89 e5                	mov    %esp,%ebp
80102b02:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b05:	8b 45 08             	mov    0x8(%ebp),%eax
80102b08:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b0d:	85 c0                	test   %eax,%eax
80102b0f:	75 1b                	jne    80102b2c <kfree+0x2d>
80102b11:	81 7d 08 5c 54 11 80 	cmpl   $0x8011545c,0x8(%ebp)
80102b18:	72 12                	jb     80102b2c <kfree+0x2d>
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	89 04 24             	mov    %eax,(%esp)
80102b20:	e8 38 ff ff ff       	call   80102a5d <v2p>
80102b25:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b2a:	76 0c                	jbe    80102b38 <kfree+0x39>
    panic("kfree");
80102b2c:	c7 04 24 db 8a 10 80 	movl   $0x80108adb,(%esp)
80102b33:	e8 02 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b3f:	00 
80102b40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b47:	00 
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	89 04 24             	mov    %eax,(%esp)
80102b4e:	e8 00 28 00 00       	call   80105353 <memset>

  if(kmem.use_lock)
80102b53:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b58:	85 c0                	test   %eax,%eax
80102b5a:	74 0c                	je     80102b68 <kfree+0x69>
    acquire(&kmem.lock);
80102b5c:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b63:	e8 97 25 00 00       	call   801050ff <acquire>
  r = (struct run*)v;
80102b68:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b6e:	8b 15 78 22 11 80    	mov    0x80112278,%edx
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7c:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102b81:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	74 0c                	je     80102b96 <kfree+0x97>
    release(&kmem.lock);
80102b8a:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b91:	e8 cb 25 00 00       	call   80105161 <release>
}
80102b96:	c9                   	leave  
80102b97:	c3                   	ret    

80102b98 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b98:	55                   	push   %ebp
80102b99:	89 e5                	mov    %esp,%ebp
80102b9b:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b9e:	a1 74 22 11 80       	mov    0x80112274,%eax
80102ba3:	85 c0                	test   %eax,%eax
80102ba5:	74 0c                	je     80102bb3 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ba7:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bae:	e8 4c 25 00 00       	call   801050ff <acquire>
  r = kmem.freelist;
80102bb3:	a1 78 22 11 80       	mov    0x80112278,%eax
80102bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bbf:	74 0a                	je     80102bcb <kalloc+0x33>
    kmem.freelist = r->next;
80102bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc4:	8b 00                	mov    (%eax),%eax
80102bc6:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102bcb:	a1 74 22 11 80       	mov    0x80112274,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	74 0c                	je     80102be0 <kalloc+0x48>
    release(&kmem.lock);
80102bd4:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bdb:	e8 81 25 00 00       	call   80105161 <release>
  return (char*)r;
80102be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102be3:	c9                   	leave  
80102be4:	c3                   	ret    

80102be5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102be5:	55                   	push   %ebp
80102be6:	89 e5                	mov    %esp,%ebp
80102be8:	83 ec 14             	sub    $0x14,%esp
80102beb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bee:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bf6:	89 c2                	mov    %eax,%edx
80102bf8:	ec                   	in     (%dx),%al
80102bf9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bfc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c00:	c9                   	leave  
80102c01:	c3                   	ret    

80102c02 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c02:	55                   	push   %ebp
80102c03:	89 e5                	mov    %esp,%ebp
80102c05:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c08:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c0f:	e8 d1 ff ff ff       	call   80102be5 <inb>
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1d:	83 e0 01             	and    $0x1,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	75 0a                	jne    80102c2e <kbdgetc+0x2c>
    return -1;
80102c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c29:	e9 25 01 00 00       	jmp    80102d53 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c2e:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c35:	e8 ab ff ff ff       	call   80102be5 <inb>
80102c3a:	0f b6 c0             	movzbl %al,%eax
80102c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c40:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c47:	75 17                	jne    80102c60 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c49:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c4e:	83 c8 40             	or     $0x40,%eax
80102c51:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c56:	b8 00 00 00 00       	mov    $0x0,%eax
80102c5b:	e9 f3 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c63:	25 80 00 00 00       	and    $0x80,%eax
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	74 45                	je     80102cb1 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c6c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c71:	83 e0 40             	and    $0x40,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	75 08                	jne    80102c80 <kbdgetc+0x7e>
80102c78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7b:	83 e0 7f             	and    $0x7f,%eax
80102c7e:	eb 03                	jmp    80102c83 <kbdgetc+0x81>
80102c80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c83:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c86:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c89:	05 20 90 10 80       	add    $0x80109020,%eax
80102c8e:	0f b6 00             	movzbl (%eax),%eax
80102c91:	83 c8 40             	or     $0x40,%eax
80102c94:	0f b6 c0             	movzbl %al,%eax
80102c97:	f7 d0                	not    %eax
80102c99:	89 c2                	mov    %eax,%edx
80102c9b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ca0:	21 d0                	and    %edx,%eax
80102ca2:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80102cac:	e9 a2 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cb1:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cb6:	83 e0 40             	and    $0x40,%eax
80102cb9:	85 c0                	test   %eax,%eax
80102cbb:	74 14                	je     80102cd1 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cbd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cc4:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cc9:	83 e0 bf             	and    $0xffffffbf,%eax
80102ccc:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd4:	05 20 90 10 80       	add    $0x80109020,%eax
80102cd9:	0f b6 00             	movzbl (%eax),%eax
80102cdc:	0f b6 d0             	movzbl %al,%edx
80102cdf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ce4:	09 d0                	or     %edx,%eax
80102ce6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cee:	05 20 91 10 80       	add    $0x80109120,%eax
80102cf3:	0f b6 00             	movzbl (%eax),%eax
80102cf6:	0f b6 d0             	movzbl %al,%edx
80102cf9:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cfe:	31 d0                	xor    %edx,%eax
80102d00:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d05:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d0a:	83 e0 03             	and    $0x3,%eax
80102d0d:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d17:	01 d0                	add    %edx,%eax
80102d19:	0f b6 00             	movzbl (%eax),%eax
80102d1c:	0f b6 c0             	movzbl %al,%eax
80102d1f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d22:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d27:	83 e0 08             	and    $0x8,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	74 22                	je     80102d50 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d2e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d32:	76 0c                	jbe    80102d40 <kbdgetc+0x13e>
80102d34:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d38:	77 06                	ja     80102d40 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d3a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d3e:	eb 10                	jmp    80102d50 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d40:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d44:	76 0a                	jbe    80102d50 <kbdgetc+0x14e>
80102d46:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d4a:	77 04                	ja     80102d50 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d4c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d50:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <kbdintr>:

void
kbdintr(void)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d5b:	c7 04 24 02 2c 10 80 	movl   $0x80102c02,(%esp)
80102d62:	e8 61 da ff ff       	call   801007c8 <consoleintr>
}
80102d67:	c9                   	leave  
80102d68:	c3                   	ret    

80102d69 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d69:	55                   	push   %ebp
80102d6a:	89 e5                	mov    %esp,%ebp
80102d6c:	83 ec 14             	sub    $0x14,%esp
80102d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d72:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d76:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d7a:	89 c2                	mov    %eax,%edx
80102d7c:	ec                   	in     (%dx),%al
80102d7d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d80:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d84:	c9                   	leave  
80102d85:	c3                   	ret    

80102d86 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 08             	sub    $0x8,%esp
80102d8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d92:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d96:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d99:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d9d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da1:	ee                   	out    %al,(%dx)
}
80102da2:	c9                   	leave  
80102da3:	c3                   	ret    

80102da4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102da4:	55                   	push   %ebp
80102da5:	89 e5                	mov    %esp,%ebp
80102da7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102daa:	9c                   	pushf  
80102dab:	58                   	pop    %eax
80102dac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102db2:	c9                   	leave  
80102db3:	c3                   	ret    

80102db4 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102db4:	55                   	push   %ebp
80102db5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102db7:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dbc:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbf:	c1 e2 02             	shl    $0x2,%edx
80102dc2:	01 c2                	add    %eax,%edx
80102dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc7:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dc9:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dce:	83 c0 20             	add    $0x20,%eax
80102dd1:	8b 00                	mov    (%eax),%eax
}
80102dd3:	5d                   	pop    %ebp
80102dd4:	c3                   	ret    

80102dd5 <lapicinit>:

void
lapicinit(void)
{
80102dd5:	55                   	push   %ebp
80102dd6:	89 e5                	mov    %esp,%ebp
80102dd8:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102ddb:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102de0:	85 c0                	test   %eax,%eax
80102de2:	75 05                	jne    80102de9 <lapicinit+0x14>
    return;
80102de4:	e9 43 01 00 00       	jmp    80102f2c <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102de9:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102df0:	00 
80102df1:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102df8:	e8 b7 ff ff ff       	call   80102db4 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfd:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e04:	00 
80102e05:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e0c:	e8 a3 ff ff ff       	call   80102db4 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e11:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e18:	00 
80102e19:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e20:	e8 8f ff ff ff       	call   80102db4 <lapicw>
  lapicw(TICR, 10000000); 
80102e25:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e2c:	00 
80102e2d:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e34:	e8 7b ff ff ff       	call   80102db4 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e48:	e8 67 ff ff ff       	call   80102db4 <lapicw>
  lapicw(LINT1, MASKED);
80102e4d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e54:	00 
80102e55:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e5c:	e8 53 ff ff ff       	call   80102db4 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e61:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e66:	83 c0 30             	add    $0x30,%eax
80102e69:	8b 00                	mov    (%eax),%eax
80102e6b:	c1 e8 10             	shr    $0x10,%eax
80102e6e:	0f b6 c0             	movzbl %al,%eax
80102e71:	83 f8 03             	cmp    $0x3,%eax
80102e74:	76 14                	jbe    80102e8a <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e76:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e7d:	00 
80102e7e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e85:	e8 2a ff ff ff       	call   80102db4 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e8a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e91:	00 
80102e92:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e99:	e8 16 ff ff ff       	call   80102db4 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea5:	00 
80102ea6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ead:	e8 02 ff ff ff       	call   80102db4 <lapicw>
  lapicw(ESR, 0);
80102eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb9:	00 
80102eba:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ec1:	e8 ee fe ff ff       	call   80102db4 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ec6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ecd:	00 
80102ece:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ed5:	e8 da fe ff ff       	call   80102db4 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee1:	00 
80102ee2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ee9:	e8 c6 fe ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eee:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ef5:	00 
80102ef6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102efd:	e8 b2 fe ff ff       	call   80102db4 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f02:	90                   	nop
80102f03:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f08:	05 00 03 00 00       	add    $0x300,%eax
80102f0d:	8b 00                	mov    (%eax),%eax
80102f0f:	25 00 10 00 00       	and    $0x1000,%eax
80102f14:	85 c0                	test   %eax,%eax
80102f16:	75 eb                	jne    80102f03 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f1f:	00 
80102f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f27:	e8 88 fe ff ff       	call   80102db4 <lapicw>
}
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <cpunum>:

int
cpunum(void)
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
80102f31:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f34:	e8 6b fe ff ff       	call   80102da4 <readeflags>
80102f39:	25 00 02 00 00       	and    $0x200,%eax
80102f3e:	85 c0                	test   %eax,%eax
80102f40:	74 25                	je     80102f67 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f42:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102f47:	8d 50 01             	lea    0x1(%eax),%edx
80102f4a:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f50:	85 c0                	test   %eax,%eax
80102f52:	75 13                	jne    80102f67 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f54:	8b 45 04             	mov    0x4(%ebp),%eax
80102f57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f5b:	c7 04 24 e4 8a 10 80 	movl   $0x80108ae4,(%esp)
80102f62:	e8 39 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f67:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f6c:	85 c0                	test   %eax,%eax
80102f6e:	74 0f                	je     80102f7f <cpunum+0x51>
    return lapic[ID]>>24;
80102f70:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f75:	83 c0 20             	add    $0x20,%eax
80102f78:	8b 00                	mov    (%eax),%eax
80102f7a:	c1 e8 18             	shr    $0x18,%eax
80102f7d:	eb 05                	jmp    80102f84 <cpunum+0x56>
  return 0;
80102f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    

80102f86 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f86:	55                   	push   %ebp
80102f87:	89 e5                	mov    %esp,%ebp
80102f89:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f8c:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f91:	85 c0                	test   %eax,%eax
80102f93:	74 14                	je     80102fa9 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f9c:	00 
80102f9d:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fa4:	e8 0b fe ff ff       	call   80102db4 <lapicw>
}
80102fa9:	c9                   	leave  
80102faa:	c3                   	ret    

80102fab <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fab:	55                   	push   %ebp
80102fac:	89 e5                	mov    %esp,%ebp
}
80102fae:	5d                   	pop    %ebp
80102faf:	c3                   	ret    

80102fb0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fb0:	55                   	push   %ebp
80102fb1:	89 e5                	mov    %esp,%ebp
80102fb3:	83 ec 1c             	sub    $0x1c,%esp
80102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fbc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fc3:	00 
80102fc4:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fcb:	e8 b6 fd ff ff       	call   80102d86 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fd0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fd7:	00 
80102fd8:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fdf:	e8 a2 fd ff ff       	call   80102d86 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fe4:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102feb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fee:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ff3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff6:	8d 50 02             	lea    0x2(%eax),%edx
80102ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ffc:	c1 e8 04             	shr    $0x4,%eax
80102fff:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103002:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103006:	c1 e0 18             	shl    $0x18,%eax
80103009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010300d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103014:	e8 9b fd ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103019:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103020:	00 
80103021:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103028:	e8 87 fd ff ff       	call   80102db4 <lapicw>
  microdelay(200);
8010302d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103034:	e8 72 ff ff ff       	call   80102fab <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103039:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103040:	00 
80103041:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103048:	e8 67 fd ff ff       	call   80102db4 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010304d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103054:	e8 52 ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103059:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103060:	eb 40                	jmp    801030a2 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103062:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103066:	c1 e0 18             	shl    $0x18,%eax
80103069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010306d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103074:	e8 3b fd ff ff       	call   80102db4 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010307c:	c1 e8 0c             	shr    $0xc,%eax
8010307f:	80 cc 06             	or     $0x6,%ah
80103082:	89 44 24 04          	mov    %eax,0x4(%esp)
80103086:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010308d:	e8 22 fd ff ff       	call   80102db4 <lapicw>
    microdelay(200);
80103092:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103099:	e8 0d ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010309e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030a2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030a6:	7e ba                	jle    80103062 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030b0:	8b 45 08             	mov    0x8(%ebp),%eax
801030b3:	0f b6 c0             	movzbl %al,%eax
801030b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030ba:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030c1:	e8 c0 fc ff ff       	call   80102d86 <outb>
  microdelay(200);
801030c6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030cd:	e8 d9 fe ff ff       	call   80102fab <microdelay>

  return inb(CMOS_RETURN);
801030d2:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030d9:	e8 8b fc ff ff       	call   80102d69 <inb>
801030de:	0f b6 c0             	movzbl %al,%eax
}
801030e1:	c9                   	leave  
801030e2:	c3                   	ret    

801030e3 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030e3:	55                   	push   %ebp
801030e4:	89 e5                	mov    %esp,%ebp
801030e6:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030f0:	e8 b5 ff ff ff       	call   801030aa <cmos_read>
801030f5:	8b 55 08             	mov    0x8(%ebp),%edx
801030f8:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103101:	e8 a4 ff ff ff       	call   801030aa <cmos_read>
80103106:	8b 55 08             	mov    0x8(%ebp),%edx
80103109:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010310c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103113:	e8 92 ff ff ff       	call   801030aa <cmos_read>
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010311e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103125:	e8 80 ff ff ff       	call   801030aa <cmos_read>
8010312a:	8b 55 08             	mov    0x8(%ebp),%edx
8010312d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103130:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103137:	e8 6e ff ff ff       	call   801030aa <cmos_read>
8010313c:	8b 55 08             	mov    0x8(%ebp),%edx
8010313f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103142:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103149:	e8 5c ff ff ff       	call   801030aa <cmos_read>
8010314e:	8b 55 08             	mov    0x8(%ebp),%edx
80103151:	89 42 14             	mov    %eax,0x14(%edx)
}
80103154:	c9                   	leave  
80103155:	c3                   	ret    

80103156 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103156:	55                   	push   %ebp
80103157:	89 e5                	mov    %esp,%ebp
80103159:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010315c:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103163:	e8 42 ff ff ff       	call   801030aa <cmos_read>
80103168:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010316b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316e:	83 e0 04             	and    $0x4,%eax
80103171:	85 c0                	test   %eax,%eax
80103173:	0f 94 c0             	sete   %al
80103176:	0f b6 c0             	movzbl %al,%eax
80103179:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010317c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010317f:	89 04 24             	mov    %eax,(%esp)
80103182:	e8 5c ff ff ff       	call   801030e3 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103187:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010318e:	e8 17 ff ff ff       	call   801030aa <cmos_read>
80103193:	25 80 00 00 00       	and    $0x80,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	74 02                	je     8010319e <cmostime+0x48>
        continue;
8010319c:	eb 36                	jmp    801031d4 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010319e:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031a1:	89 04 24             	mov    %eax,(%esp)
801031a4:	e8 3a ff ff ff       	call   801030e3 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031a9:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031b0:	00 
801031b1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801031b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031bb:	89 04 24             	mov    %eax,(%esp)
801031be:	e8 07 22 00 00       	call   801053ca <memcmp>
801031c3:	85 c0                	test   %eax,%eax
801031c5:	75 0d                	jne    801031d4 <cmostime+0x7e>
      break;
801031c7:	90                   	nop
  }

  // convert
  if (bcd) {
801031c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031cc:	0f 84 ac 00 00 00    	je     8010327e <cmostime+0x128>
801031d2:	eb 02                	jmp    801031d6 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031d4:	eb a6                	jmp    8010317c <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031d9:	c1 e8 04             	shr    $0x4,%eax
801031dc:	89 c2                	mov    %eax,%edx
801031de:	89 d0                	mov    %edx,%eax
801031e0:	c1 e0 02             	shl    $0x2,%eax
801031e3:	01 d0                	add    %edx,%eax
801031e5:	01 c0                	add    %eax,%eax
801031e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ea:	83 e2 0f             	and    $0xf,%edx
801031ed:	01 d0                	add    %edx,%eax
801031ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031f5:	c1 e8 04             	shr    $0x4,%eax
801031f8:	89 c2                	mov    %eax,%edx
801031fa:	89 d0                	mov    %edx,%eax
801031fc:	c1 e0 02             	shl    $0x2,%eax
801031ff:	01 d0                	add    %edx,%eax
80103201:	01 c0                	add    %eax,%eax
80103203:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103206:	83 e2 0f             	and    $0xf,%edx
80103209:	01 d0                	add    %edx,%eax
8010320b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010320e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103211:	c1 e8 04             	shr    $0x4,%eax
80103214:	89 c2                	mov    %eax,%edx
80103216:	89 d0                	mov    %edx,%eax
80103218:	c1 e0 02             	shl    $0x2,%eax
8010321b:	01 d0                	add    %edx,%eax
8010321d:	01 c0                	add    %eax,%eax
8010321f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103222:	83 e2 0f             	and    $0xf,%edx
80103225:	01 d0                	add    %edx,%eax
80103227:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010322a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010322d:	c1 e8 04             	shr    $0x4,%eax
80103230:	89 c2                	mov    %eax,%edx
80103232:	89 d0                	mov    %edx,%eax
80103234:	c1 e0 02             	shl    $0x2,%eax
80103237:	01 d0                	add    %edx,%eax
80103239:	01 c0                	add    %eax,%eax
8010323b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010323e:	83 e2 0f             	and    $0xf,%edx
80103241:	01 d0                	add    %edx,%eax
80103243:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103246:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103249:	c1 e8 04             	shr    $0x4,%eax
8010324c:	89 c2                	mov    %eax,%edx
8010324e:	89 d0                	mov    %edx,%eax
80103250:	c1 e0 02             	shl    $0x2,%eax
80103253:	01 d0                	add    %edx,%eax
80103255:	01 c0                	add    %eax,%eax
80103257:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010325a:	83 e2 0f             	and    $0xf,%edx
8010325d:	01 d0                	add    %edx,%eax
8010325f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103262:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103276:	83 e2 0f             	and    $0xf,%edx
80103279:	01 d0                	add    %edx,%eax
8010327b:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010327e:	8b 45 08             	mov    0x8(%ebp),%eax
80103281:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103284:	89 10                	mov    %edx,(%eax)
80103286:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103289:	89 50 04             	mov    %edx,0x4(%eax)
8010328c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010328f:	89 50 08             	mov    %edx,0x8(%eax)
80103292:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103295:	89 50 0c             	mov    %edx,0xc(%eax)
80103298:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010329b:	89 50 10             	mov    %edx,0x10(%eax)
8010329e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032a1:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	8b 40 14             	mov    0x14(%eax),%eax
801032aa:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032b0:	8b 45 08             	mov    0x8(%ebp),%eax
801032b3:	89 50 14             	mov    %edx,0x14(%eax)
}
801032b6:	c9                   	leave  
801032b7:	c3                   	ret    

801032b8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032b8:	55                   	push   %ebp
801032b9:	89 e5                	mov    %esp,%ebp
801032bb:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032be:	c7 44 24 04 10 8b 10 	movl   $0x80108b10,0x4(%esp)
801032c5:	80 
801032c6:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801032cd:	e8 0c 1e 00 00       	call   801050de <initlock>
  readsb(dev, &sb);
801032d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 28 e0 ff ff       	call   8010130c <readsb>
  log.start = sb.logstart;
801032e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e7:	a3 b4 22 11 80       	mov    %eax,0x801122b4
  log.size = sb.nlog;
801032ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ef:	a3 b8 22 11 80       	mov    %eax,0x801122b8
  log.dev = dev;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	a3 c4 22 11 80       	mov    %eax,0x801122c4
  recover_from_log();
801032fc:	e8 9a 01 00 00       	call   8010349b <recover_from_log>
}
80103301:	c9                   	leave  
80103302:	c3                   	ret    

80103303 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
80103306:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103310:	e9 8c 00 00 00       	jmp    801033a1 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103315:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
8010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331e:	01 d0                	add    %edx,%eax
80103320:	83 c0 01             	add    $0x1,%eax
80103323:	89 c2                	mov    %eax,%edx
80103325:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010332a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332e:	89 04 24             	mov    %eax,(%esp)
80103331:	e8 70 ce ff ff       	call   801001a6 <bread>
80103336:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333c:	83 c0 10             	add    $0x10,%eax
8010333f:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
80103346:	89 c2                	mov    %eax,%edx
80103348:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010334d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103351:	89 04 24             	mov    %eax,(%esp)
80103354:	e8 4d ce ff ff       	call   801001a6 <bread>
80103359:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335f:	8d 50 18             	lea    0x18(%eax),%edx
80103362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103365:	83 c0 18             	add    $0x18,%eax
80103368:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010336f:	00 
80103370:	89 54 24 04          	mov    %edx,0x4(%esp)
80103374:	89 04 24             	mov    %eax,(%esp)
80103377:	e8 a6 20 00 00       	call   80105422 <memmove>
    bwrite(dbuf);  // write dst to disk
8010337c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337f:	89 04 24             	mov    %eax,(%esp)
80103382:	e8 56 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 85 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103395:	89 04 24             	mov    %eax,(%esp)
80103398:	e8 7a ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033a1:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801033a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a9:	0f 8f 66 ff ff ff    	jg     80103315 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033af:	c9                   	leave  
801033b0:	c3                   	ret    

801033b1 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033b1:	55                   	push   %ebp
801033b2:	89 e5                	mov    %esp,%ebp
801033b4:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033b7:	a1 b4 22 11 80       	mov    0x801122b4,%eax
801033bc:	89 c2                	mov    %eax,%edx
801033be:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801033c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c7:	89 04 24             	mov    %eax,(%esp)
801033ca:	e8 d7 cd ff ff       	call   801001a6 <bread>
801033cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d5:	83 c0 18             	add    $0x18,%eax
801033d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033de:	8b 00                	mov    (%eax),%eax
801033e0:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  for (i = 0; i < log.lh.n; i++) {
801033e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ec:	eb 1b                	jmp    80103409 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fb:	83 c2 10             	add    $0x10,%edx
801033fe:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103405:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103409:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010340e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103411:	7f db                	jg     801033ee <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103416:	89 04 24             	mov    %eax,(%esp)
80103419:	e8 f9 cd ff ff       	call   80100217 <brelse>
}
8010341e:	c9                   	leave  
8010341f:	c3                   	ret    

80103420 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103420:	55                   	push   %ebp
80103421:	89 e5                	mov    %esp,%ebp
80103423:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103426:	a1 b4 22 11 80       	mov    0x801122b4,%eax
8010342b:	89 c2                	mov    %eax,%edx
8010342d:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103432:	89 54 24 04          	mov    %edx,0x4(%esp)
80103436:	89 04 24             	mov    %eax,(%esp)
80103439:	e8 68 cd ff ff       	call   801001a6 <bread>
8010343e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103444:	83 c0 18             	add    $0x18,%eax
80103447:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010344a:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
80103450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103453:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345c:	eb 1b                	jmp    80103479 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
8010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103461:	83 c0 10             	add    $0x10,%eax
80103464:	8b 0c 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%ecx
8010346b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103471:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103475:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103479:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010347e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103481:	7f db                	jg     8010345e <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103486:	89 04 24             	mov    %eax,(%esp)
80103489:	e8 4f cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010348e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103491:	89 04 24             	mov    %eax,(%esp)
80103494:	e8 7e cd ff ff       	call   80100217 <brelse>
}
80103499:	c9                   	leave  
8010349a:	c3                   	ret    

8010349b <recover_from_log>:

static void
recover_from_log(void)
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a1:	e8 0b ff ff ff       	call   801033b1 <read_head>
  install_trans(); // if committed, copy from log to disk
801034a6:	e8 58 fe ff ff       	call   80103303 <install_trans>
  log.lh.n = 0;
801034ab:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801034b2:	00 00 00 
  write_head(); // clear the log
801034b5:	e8 66 ff ff ff       	call   80103420 <write_head>
}
801034ba:	c9                   	leave  
801034bb:	c3                   	ret    

801034bc <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c2:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034c9:	e8 31 1c 00 00       	call   801050ff <acquire>
  while(1){
    if(log.committing){
801034ce:	a1 c0 22 11 80       	mov    0x801122c0,%eax
801034d3:	85 c0                	test   %eax,%eax
801034d5:	74 16                	je     801034ed <begin_op+0x31>
      sleep(&log, &log.lock);
801034d7:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
801034de:	80 
801034df:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034e6:	e8 6b 17 00 00       	call   80104c56 <sleep>
801034eb:	eb 4f                	jmp    8010353c <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ed:	8b 0d c8 22 11 80    	mov    0x801122c8,%ecx
801034f3:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801034f8:	8d 50 01             	lea    0x1(%eax),%edx
801034fb:	89 d0                	mov    %edx,%eax
801034fd:	c1 e0 02             	shl    $0x2,%eax
80103500:	01 d0                	add    %edx,%eax
80103502:	01 c0                	add    %eax,%eax
80103504:	01 c8                	add    %ecx,%eax
80103506:	83 f8 1e             	cmp    $0x1e,%eax
80103509:	7e 16                	jle    80103521 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010350b:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
80103512:	80 
80103513:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010351a:	e8 37 17 00 00       	call   80104c56 <sleep>
8010351f:	eb 1b                	jmp    8010353c <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103521:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103526:	83 c0 01             	add    $0x1,%eax
80103529:	a3 bc 22 11 80       	mov    %eax,0x801122bc
      release(&log.lock);
8010352e:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103535:	e8 27 1c 00 00       	call   80105161 <release>
      break;
8010353a:	eb 02                	jmp    8010353e <begin_op+0x82>
    }
  }
8010353c:	eb 90                	jmp    801034ce <begin_op+0x12>
}
8010353e:	c9                   	leave  
8010353f:	c3                   	ret    

80103540 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010354d:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103554:	e8 a6 1b 00 00       	call   801050ff <acquire>
  log.outstanding -= 1;
80103559:	a1 bc 22 11 80       	mov    0x801122bc,%eax
8010355e:	83 e8 01             	sub    $0x1,%eax
80103561:	a3 bc 22 11 80       	mov    %eax,0x801122bc
  if(log.committing)
80103566:	a1 c0 22 11 80       	mov    0x801122c0,%eax
8010356b:	85 c0                	test   %eax,%eax
8010356d:	74 0c                	je     8010357b <end_op+0x3b>
    panic("log.committing");
8010356f:	c7 04 24 14 8b 10 80 	movl   $0x80108b14,(%esp)
80103576:	e8 bf cf ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
8010357b:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103580:	85 c0                	test   %eax,%eax
80103582:	75 13                	jne    80103597 <end_op+0x57>
    do_commit = 1;
80103584:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010358b:	c7 05 c0 22 11 80 01 	movl   $0x1,0x801122c0
80103592:	00 00 00 
80103595:	eb 0c                	jmp    801035a3 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103597:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010359e:	e8 8f 17 00 00       	call   80104d32 <wakeup>
  }
  release(&log.lock);
801035a3:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035aa:	e8 b2 1b 00 00       	call   80105161 <release>

  if(do_commit){
801035af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b3:	74 33                	je     801035e8 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b5:	e8 de 00 00 00       	call   80103698 <commit>
    acquire(&log.lock);
801035ba:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035c1:	e8 39 1b 00 00       	call   801050ff <acquire>
    log.committing = 0;
801035c6:	c7 05 c0 22 11 80 00 	movl   $0x0,0x801122c0
801035cd:	00 00 00 
    wakeup(&log);
801035d0:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035d7:	e8 56 17 00 00       	call   80104d32 <wakeup>
    release(&log.lock);
801035dc:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035e3:	e8 79 1b 00 00       	call   80105161 <release>
  }
}
801035e8:	c9                   	leave  
801035e9:	c3                   	ret    

801035ea <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035ea:	55                   	push   %ebp
801035eb:	89 e5                	mov    %esp,%ebp
801035ed:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f7:	e9 8c 00 00 00       	jmp    80103688 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035fc:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	01 d0                	add    %edx,%eax
80103607:	83 c0 01             	add    $0x1,%eax
8010360a:	89 c2                	mov    %eax,%edx
8010360c:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103611:	89 54 24 04          	mov    %edx,0x4(%esp)
80103615:	89 04 24             	mov    %eax,(%esp)
80103618:	e8 89 cb ff ff       	call   801001a6 <bread>
8010361d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103623:	83 c0 10             	add    $0x10,%eax
80103626:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010362d:	89 c2                	mov    %eax,%edx
8010362f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103634:	89 54 24 04          	mov    %edx,0x4(%esp)
80103638:	89 04 24             	mov    %eax,(%esp)
8010363b:	e8 66 cb ff ff       	call   801001a6 <bread>
80103640:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103643:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103646:	8d 50 18             	lea    0x18(%eax),%edx
80103649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364c:	83 c0 18             	add    $0x18,%eax
8010364f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103656:	00 
80103657:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365b:	89 04 24             	mov    %eax,(%esp)
8010365e:	e8 bf 1d 00 00       	call   80105422 <memmove>
    bwrite(to);  // write the log
80103663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103666:	89 04 24             	mov    %eax,(%esp)
80103669:	e8 6f cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010366e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103671:	89 04 24             	mov    %eax,(%esp)
80103674:	e8 9e cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367c:	89 04 24             	mov    %eax,(%esp)
8010367f:	e8 93 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103688:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010368d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103690:	0f 8f 66 ff ff ff    	jg     801035fc <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <commit>:

static void
commit()
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010369e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	7e 1e                	jle    801036c5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a7:	e8 3e ff ff ff       	call   801035ea <write_log>
    write_head();    // Write header to disk -- the real commit
801036ac:	e8 6f fd ff ff       	call   80103420 <write_head>
    install_trans(); // Now install writes to home locations
801036b1:	e8 4d fc ff ff       	call   80103303 <install_trans>
    log.lh.n = 0; 
801036b6:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801036bd:	00 00 00 
    write_head();    // Erase the transaction from the log
801036c0:	e8 5b fd ff ff       	call   80103420 <write_head>
  }
}
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036cd:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036d2:	83 f8 1d             	cmp    $0x1d,%eax
801036d5:	7f 12                	jg     801036e9 <log_write+0x22>
801036d7:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036dc:	8b 15 b8 22 11 80    	mov    0x801122b8,%edx
801036e2:	83 ea 01             	sub    $0x1,%edx
801036e5:	39 d0                	cmp    %edx,%eax
801036e7:	7c 0c                	jl     801036f5 <log_write+0x2e>
    panic("too big a transaction");
801036e9:	c7 04 24 23 8b 10 80 	movl   $0x80108b23,(%esp)
801036f0:	e8 45 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
801036f5:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801036fa:	85 c0                	test   %eax,%eax
801036fc:	7f 0c                	jg     8010370a <log_write+0x43>
    panic("log_write outside of trans");
801036fe:	c7 04 24 39 8b 10 80 	movl   $0x80108b39,(%esp)
80103705:	e8 30 ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010370a:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103711:	e8 e9 19 00 00       	call   801050ff <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371d:	eb 1f                	jmp    8010373e <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103722:	83 c0 10             	add    $0x10,%eax
80103725:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010372c:	89 c2                	mov    %eax,%edx
8010372e:	8b 45 08             	mov    0x8(%ebp),%eax
80103731:	8b 40 08             	mov    0x8(%eax),%eax
80103734:	39 c2                	cmp    %eax,%edx
80103736:	75 02                	jne    8010373a <log_write+0x73>
      break;
80103738:	eb 0e                	jmp    80103748 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010373a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010373e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103743:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103746:	7f d7                	jg     8010371f <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103748:	8b 45 08             	mov    0x8(%ebp),%eax
8010374b:	8b 40 08             	mov    0x8(%eax),%eax
8010374e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103751:	83 c2 10             	add    $0x10,%edx
80103754:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
  if (i == log.lh.n)
8010375b:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103760:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103763:	75 0d                	jne    80103772 <log_write+0xab>
    log.lh.n++;
80103765:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010376a:	83 c0 01             	add    $0x1,%eax
8010376d:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  b->flags |= B_DIRTY; // prevent eviction
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	8b 00                	mov    (%eax),%eax
80103777:	83 c8 04             	or     $0x4,%eax
8010377a:	89 c2                	mov    %eax,%edx
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103781:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103788:	e8 d4 19 00 00       	call   80105161 <release>
}
8010378d:	c9                   	leave  
8010378e:	c3                   	ret    

8010378f <v2p>:
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	8b 45 08             	mov    0x8(%ebp),%eax
80103795:	05 00 00 00 80       	add    $0x80000000,%eax
8010379a:	5d                   	pop    %ebp
8010379b:	c3                   	ret    

8010379c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010379c:	55                   	push   %ebp
8010379d:	89 e5                	mov    %esp,%ebp
8010379f:	8b 45 08             	mov    0x8(%ebp),%eax
801037a2:	05 00 00 00 80       	add    $0x80000000,%eax
801037a7:	5d                   	pop    %ebp
801037a8:	c3                   	ret    

801037a9 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037af:	8b 55 08             	mov    0x8(%ebp),%edx
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037b8:	f0 87 02             	lock xchg %eax,(%edx)
801037bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037c1:	c9                   	leave  
801037c2:	c3                   	ret    

801037c3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037c3:	55                   	push   %ebp
801037c4:	89 e5                	mov    %esp,%ebp
801037c6:	83 e4 f0             	and    $0xfffffff0,%esp
801037c9:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037cc:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037d3:	80 
801037d4:	c7 04 24 5c 54 11 80 	movl   $0x8011545c,(%esp)
801037db:	e8 8a f2 ff ff       	call   80102a6a <kinit1>
  kvmalloc();      // kernel page table
801037e0:	e8 fe 48 00 00       	call   801080e3 <kvmalloc>
  mpinit();        // collect info about this machine
801037e5:	e8 41 04 00 00       	call   80103c2b <mpinit>
  lapicinit();
801037ea:	e8 e6 f5 ff ff       	call   80102dd5 <lapicinit>
  seginit();       // set up segments
801037ef:	e8 82 42 00 00       	call   80107a76 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fa:	0f b6 00             	movzbl (%eax),%eax
801037fd:	0f b6 c0             	movzbl %al,%eax
80103800:	89 44 24 04          	mov    %eax,0x4(%esp)
80103804:	c7 04 24 54 8b 10 80 	movl   $0x80108b54,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103810:	e8 74 06 00 00       	call   80103e89 <picinit>
  ioapicinit();    // another interrupt controller
80103815:	e8 46 f1 ff ff       	call   80102960 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010381a:	e8 91 d2 ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
8010381f:	e8 a1 35 00 00       	call   80106dc5 <uartinit>
  pinit();         // process table
80103824:	e8 6a 0b 00 00       	call   80104393 <pinit>
  tvinit();        // trap vectors
80103829:	e8 49 31 00 00       	call   80106977 <tvinit>
  binit();         // buffer cache
8010382e:	e8 01 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103833:	e8 ed d6 ff ff       	call   80100f25 <fileinit>
  ideinit();       // disk
80103838:	e8 55 ed ff ff       	call   80102592 <ideinit>
  if(!ismp)
8010383d:	a1 64 23 11 80       	mov    0x80112364,%eax
80103842:	85 c0                	test   %eax,%eax
80103844:	75 05                	jne    8010384b <main+0x88>
    timerinit();   // uniprocessor timer
80103846:	e8 77 30 00 00       	call   801068c2 <timerinit>
  startothers();   // start other processors
8010384b:	e8 7f 00 00 00       	call   801038cf <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103850:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103857:	8e 
80103858:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010385f:	e8 3e f2 ff ff       	call   80102aa2 <kinit2>
  userinit();      // first user process
80103864:	e8 74 0c 00 00       	call   801044dd <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103869:	e8 1a 00 00 00       	call   80103888 <mpmain>

8010386e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010386e:	55                   	push   %ebp
8010386f:	89 e5                	mov    %esp,%ebp
80103871:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103874:	e8 81 48 00 00       	call   801080fa <switchkvm>
  seginit();
80103879:	e8 f8 41 00 00       	call   80107a76 <seginit>
  lapicinit();
8010387e:	e8 52 f5 ff ff       	call   80102dd5 <lapicinit>
  mpmain();
80103883:	e8 00 00 00 00       	call   80103888 <mpmain>

80103888 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103888:	55                   	push   %ebp
80103889:	89 e5                	mov    %esp,%ebp
8010388b:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010388e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103894:	0f b6 00             	movzbl (%eax),%eax
80103897:	0f b6 c0             	movzbl %al,%eax
8010389a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010389e:	c7 04 24 6b 8b 10 80 	movl   $0x80108b6b,(%esp)
801038a5:	e8 f6 ca ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801038aa:	e8 3c 32 00 00       	call   80106aeb <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038b5:	05 a8 00 00 00       	add    $0xa8,%eax
801038ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038c1:	00 
801038c2:	89 04 24             	mov    %eax,(%esp)
801038c5:	e8 df fe ff ff       	call   801037a9 <xchg>
  scheduler();     // start running processes
801038ca:	e8 c9 11 00 00       	call   80104a98 <scheduler>

801038cf <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038cf:	55                   	push   %ebp
801038d0:	89 e5                	mov    %esp,%ebp
801038d2:	53                   	push   %ebx
801038d3:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038d6:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038dd:	e8 ba fe ff ff       	call   8010379c <p2v>
801038e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038e5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801038ee:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801038f5:	80 
801038f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f9:	89 04 24             	mov    %eax,(%esp)
801038fc:	e8 21 1b 00 00       	call   80105422 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103901:	c7 45 f4 80 23 11 80 	movl   $0x80112380,-0xc(%ebp)
80103908:	e9 85 00 00 00       	jmp    80103992 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
8010390d:	e8 1c f6 ff ff       	call   80102f2e <cpunum>
80103912:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103918:	05 80 23 11 80       	add    $0x80112380,%eax
8010391d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103920:	75 02                	jne    80103924 <startothers+0x55>
      continue;
80103922:	eb 67                	jmp    8010398b <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103924:	e8 6f f2 ff ff       	call   80102b98 <kalloc>
80103929:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010392c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392f:	83 e8 04             	sub    $0x4,%eax
80103932:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103935:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010393b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010393d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103940:	83 e8 08             	sub    $0x8,%eax
80103943:	c7 00 6e 38 10 80    	movl   $0x8010386e,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394c:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010394f:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103956:	e8 34 fe ff ff       	call   8010378f <v2p>
8010395b:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103960:	89 04 24             	mov    %eax,(%esp)
80103963:	e8 27 fe ff ff       	call   8010378f <v2p>
80103968:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010396b:	0f b6 12             	movzbl (%edx),%edx
8010396e:	0f b6 d2             	movzbl %dl,%edx
80103971:	89 44 24 04          	mov    %eax,0x4(%esp)
80103975:	89 14 24             	mov    %edx,(%esp)
80103978:	e8 33 f6 ff ff       	call   80102fb0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010397d:	90                   	nop
8010397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103981:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103987:	85 c0                	test   %eax,%eax
80103989:	74 f3                	je     8010397e <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010398b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103992:	a1 60 29 11 80       	mov    0x80112960,%eax
80103997:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010399d:	05 80 23 11 80       	add    $0x80112380,%eax
801039a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039a5:	0f 87 62 ff ff ff    	ja     8010390d <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039ab:	83 c4 24             	add    $0x24,%esp
801039ae:	5b                   	pop    %ebx
801039af:	5d                   	pop    %ebp
801039b0:	c3                   	ret    

801039b1 <p2v>:
801039b1:	55                   	push   %ebp
801039b2:	89 e5                	mov    %esp,%ebp
801039b4:	8b 45 08             	mov    0x8(%ebp),%eax
801039b7:	05 00 00 00 80       	add    $0x80000000,%eax
801039bc:	5d                   	pop    %ebp
801039bd:	c3                   	ret    

801039be <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	83 ec 14             	sub    $0x14,%esp
801039c4:	8b 45 08             	mov    0x8(%ebp),%eax
801039c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801039cf:	89 c2                	mov    %eax,%edx
801039d1:	ec                   	in     (%dx),%al
801039d2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039d5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801039d9:	c9                   	leave  
801039da:	c3                   	ret    

801039db <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039db:	55                   	push   %ebp
801039dc:	89 e5                	mov    %esp,%ebp
801039de:	83 ec 08             	sub    $0x8,%esp
801039e1:	8b 55 08             	mov    0x8(%ebp),%edx
801039e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039eb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ee:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039f2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039f6:	ee                   	out    %al,(%dx)
}
801039f7:	c9                   	leave  
801039f8:	c3                   	ret    

801039f9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039fc:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103a01:	89 c2                	mov    %eax,%edx
80103a03:	b8 80 23 11 80       	mov    $0x80112380,%eax
80103a08:	29 c2                	sub    %eax,%edx
80103a0a:	89 d0                	mov    %edx,%eax
80103a0c:	c1 f8 02             	sar    $0x2,%eax
80103a0f:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a15:	5d                   	pop    %ebp
80103a16:	c3                   	ret    

80103a17 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a17:	55                   	push   %ebp
80103a18:	89 e5                	mov    %esp,%ebp
80103a1a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a1d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a2b:	eb 15                	jmp    80103a42 <sum+0x2b>
    sum += addr[i];
80103a2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a30:	8b 45 08             	mov    0x8(%ebp),%eax
80103a33:	01 d0                	add    %edx,%eax
80103a35:	0f b6 00             	movzbl (%eax),%eax
80103a38:	0f b6 c0             	movzbl %al,%eax
80103a3b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a45:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a48:	7c e3                	jl     80103a2d <sum+0x16>
    sum += addr[i];
  return sum;
80103a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a4d:	c9                   	leave  
80103a4e:	c3                   	ret    

80103a4f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a55:	8b 45 08             	mov    0x8(%ebp),%eax
80103a58:	89 04 24             	mov    %eax,(%esp)
80103a5b:	e8 51 ff ff ff       	call   801039b1 <p2v>
80103a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a63:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a69:	01 d0                	add    %edx,%eax
80103a6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a74:	eb 3f                	jmp    80103ab5 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a76:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a7d:	00 
80103a7e:	c7 44 24 04 7c 8b 10 	movl   $0x80108b7c,0x4(%esp)
80103a85:	80 
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	89 04 24             	mov    %eax,(%esp)
80103a8c:	e8 39 19 00 00       	call   801053ca <memcmp>
80103a91:	85 c0                	test   %eax,%eax
80103a93:	75 1c                	jne    80103ab1 <mpsearch1+0x62>
80103a95:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a9c:	00 
80103a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa0:	89 04 24             	mov    %eax,(%esp)
80103aa3:	e8 6f ff ff ff       	call   80103a17 <sum>
80103aa8:	84 c0                	test   %al,%al
80103aaa:	75 05                	jne    80103ab1 <mpsearch1+0x62>
      return (struct mp*)p;
80103aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaf:	eb 11                	jmp    80103ac2 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ab1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103abb:	72 b9                	jb     80103a76 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ac2:	c9                   	leave  
80103ac3:	c3                   	ret    

80103ac4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ac4:	55                   	push   %ebp
80103ac5:	89 e5                	mov    %esp,%ebp
80103ac7:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aca:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad4:	83 c0 0f             	add    $0xf,%eax
80103ad7:	0f b6 00             	movzbl (%eax),%eax
80103ada:	0f b6 c0             	movzbl %al,%eax
80103add:	c1 e0 08             	shl    $0x8,%eax
80103ae0:	89 c2                	mov    %eax,%edx
80103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae5:	83 c0 0e             	add    $0xe,%eax
80103ae8:	0f b6 00             	movzbl (%eax),%eax
80103aeb:	0f b6 c0             	movzbl %al,%eax
80103aee:	09 d0                	or     %edx,%eax
80103af0:	c1 e0 04             	shl    $0x4,%eax
80103af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103afa:	74 21                	je     80103b1d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103afc:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b03:	00 
80103b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b07:	89 04 24             	mov    %eax,(%esp)
80103b0a:	e8 40 ff ff ff       	call   80103a4f <mpsearch1>
80103b0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b16:	74 50                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b1b:	eb 5f                	jmp    80103b7c <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b20:	83 c0 14             	add    $0x14,%eax
80103b23:	0f b6 00             	movzbl (%eax),%eax
80103b26:	0f b6 c0             	movzbl %al,%eax
80103b29:	c1 e0 08             	shl    $0x8,%eax
80103b2c:	89 c2                	mov    %eax,%edx
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	83 c0 13             	add    $0x13,%eax
80103b34:	0f b6 00             	movzbl (%eax),%eax
80103b37:	0f b6 c0             	movzbl %al,%eax
80103b3a:	09 d0                	or     %edx,%eax
80103b3c:	c1 e0 0a             	shl    $0xa,%eax
80103b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b45:	2d 00 04 00 00       	sub    $0x400,%eax
80103b4a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b51:	00 
80103b52:	89 04 24             	mov    %eax,(%esp)
80103b55:	e8 f5 fe ff ff       	call   80103a4f <mpsearch1>
80103b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b61:	74 05                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b66:	eb 14                	jmp    80103b7c <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b68:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b6f:	00 
80103b70:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b77:	e8 d3 fe ff ff       	call   80103a4f <mpsearch1>
}
80103b7c:	c9                   	leave  
80103b7d:	c3                   	ret    

80103b7e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b7e:	55                   	push   %ebp
80103b7f:	89 e5                	mov    %esp,%ebp
80103b81:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b84:	e8 3b ff ff ff       	call   80103ac4 <mpsearch>
80103b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b90:	74 0a                	je     80103b9c <mpconfig+0x1e>
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	8b 40 04             	mov    0x4(%eax),%eax
80103b98:	85 c0                	test   %eax,%eax
80103b9a:	75 0a                	jne    80103ba6 <mpconfig+0x28>
    return 0;
80103b9c:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba1:	e9 83 00 00 00       	jmp    80103c29 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	8b 40 04             	mov    0x4(%eax),%eax
80103bac:	89 04 24             	mov    %eax,(%esp)
80103baf:	e8 fd fd ff ff       	call   801039b1 <p2v>
80103bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bb7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bbe:	00 
80103bbf:	c7 44 24 04 81 8b 10 	movl   $0x80108b81,0x4(%esp)
80103bc6:	80 
80103bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bca:	89 04 24             	mov    %eax,(%esp)
80103bcd:	e8 f8 17 00 00       	call   801053ca <memcmp>
80103bd2:	85 c0                	test   %eax,%eax
80103bd4:	74 07                	je     80103bdd <mpconfig+0x5f>
    return 0;
80103bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bdb:	eb 4c                	jmp    80103c29 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103be4:	3c 01                	cmp    $0x1,%al
80103be6:	74 12                	je     80103bfa <mpconfig+0x7c>
80103be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103beb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bef:	3c 04                	cmp    $0x4,%al
80103bf1:	74 07                	je     80103bfa <mpconfig+0x7c>
    return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 2f                	jmp    80103c29 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c01:	0f b7 c0             	movzwl %ax,%eax
80103c04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0b:	89 04 24             	mov    %eax,(%esp)
80103c0e:	e8 04 fe ff ff       	call   80103a17 <sum>
80103c13:	84 c0                	test   %al,%al
80103c15:	74 07                	je     80103c1e <mpconfig+0xa0>
    return 0;
80103c17:	b8 00 00 00 00       	mov    $0x0,%eax
80103c1c:	eb 0b                	jmp    80103c29 <mpconfig+0xab>
  *pmp = mp;
80103c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c24:	89 10                	mov    %edx,(%eax)
  return conf;
80103c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c29:	c9                   	leave  
80103c2a:	c3                   	ret    

80103c2b <mpinit>:

void
mpinit(void)
{
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c31:	c7 05 64 b6 10 80 80 	movl   $0x80112380,0x8010b664
80103c38:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c3b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c3e:	89 04 24             	mov    %eax,(%esp)
80103c41:	e8 38 ff ff ff       	call   80103b7e <mpconfig>
80103c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c4d:	75 05                	jne    80103c54 <mpinit+0x29>
    return;
80103c4f:	e9 9c 01 00 00       	jmp    80103df0 <mpinit+0x1c5>
  ismp = 1;
80103c54:	c7 05 64 23 11 80 01 	movl   $0x1,0x80112364
80103c5b:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c61:	8b 40 24             	mov    0x24(%eax),%eax
80103c64:	a3 7c 22 11 80       	mov    %eax,0x8011227c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6c:	83 c0 2c             	add    $0x2c,%eax
80103c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c75:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c79:	0f b7 d0             	movzwl %ax,%edx
80103c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7f:	01 d0                	add    %edx,%eax
80103c81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c84:	e9 f4 00 00 00       	jmp    80103d7d <mpinit+0x152>
    switch(*p){
80103c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8c:	0f b6 00             	movzbl (%eax),%eax
80103c8f:	0f b6 c0             	movzbl %al,%eax
80103c92:	83 f8 04             	cmp    $0x4,%eax
80103c95:	0f 87 bf 00 00 00    	ja     80103d5a <mpinit+0x12f>
80103c9b:	8b 04 85 c4 8b 10 80 	mov    -0x7fef743c(,%eax,4),%eax
80103ca2:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103caa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cb1:	0f b6 d0             	movzbl %al,%edx
80103cb4:	a1 60 29 11 80       	mov    0x80112960,%eax
80103cb9:	39 c2                	cmp    %eax,%edx
80103cbb:	74 2d                	je     80103cea <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc4:	0f b6 d0             	movzbl %al,%edx
80103cc7:	a1 60 29 11 80       	mov    0x80112960,%eax
80103ccc:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cd4:	c7 04 24 86 8b 10 80 	movl   $0x80108b86,(%esp)
80103cdb:	e8 c0 c6 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103ce0:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103ce7:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ced:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cf1:	0f b6 c0             	movzbl %al,%eax
80103cf4:	83 e0 02             	and    $0x2,%eax
80103cf7:	85 c0                	test   %eax,%eax
80103cf9:	74 15                	je     80103d10 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103cfb:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d00:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d06:	05 80 23 11 80       	add    $0x80112380,%eax
80103d0b:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103d10:	8b 15 60 29 11 80    	mov    0x80112960,%edx
80103d16:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d1b:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d21:	81 c2 80 23 11 80    	add    $0x80112380,%edx
80103d27:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d29:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d2e:	83 c0 01             	add    $0x1,%eax
80103d31:	a3 60 29 11 80       	mov    %eax,0x80112960
      p += sizeof(struct mpproc);
80103d36:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d3a:	eb 41                	jmp    80103d7d <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d45:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d49:	a2 60 23 11 80       	mov    %al,0x80112360
      p += sizeof(struct mpioapic);
80103d4e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d52:	eb 29                	jmp    80103d7d <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d54:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d58:	eb 23                	jmp    80103d7d <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5d:	0f b6 00             	movzbl (%eax),%eax
80103d60:	0f b6 c0             	movzbl %al,%eax
80103d63:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d67:	c7 04 24 a4 8b 10 80 	movl   $0x80108ba4,(%esp)
80103d6e:	e8 2d c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103d73:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103d7a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d80:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d83:	0f 82 00 ff ff ff    	jb     80103c89 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d89:	a1 64 23 11 80       	mov    0x80112364,%eax
80103d8e:	85 c0                	test   %eax,%eax
80103d90:	75 1d                	jne    80103daf <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d92:	c7 05 60 29 11 80 01 	movl   $0x1,0x80112960
80103d99:	00 00 00 
    lapic = 0;
80103d9c:	c7 05 7c 22 11 80 00 	movl   $0x0,0x8011227c
80103da3:	00 00 00 
    ioapicid = 0;
80103da6:	c6 05 60 23 11 80 00 	movb   $0x0,0x80112360
    return;
80103dad:	eb 41                	jmp    80103df0 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103db6:	84 c0                	test   %al,%al
80103db8:	74 36                	je     80103df0 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dba:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103dc1:	00 
80103dc2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103dc9:	e8 0d fc ff ff       	call   801039db <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dce:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dd5:	e8 e4 fb ff ff       	call   801039be <inb>
80103dda:	83 c8 01             	or     $0x1,%eax
80103ddd:	0f b6 c0             	movzbl %al,%eax
80103de0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103de4:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103deb:	e8 eb fb ff ff       	call   801039db <outb>
  }
}
80103df0:	c9                   	leave  
80103df1:	c3                   	ret    

80103df2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103df2:	55                   	push   %ebp
80103df3:	89 e5                	mov    %esp,%ebp
80103df5:	83 ec 08             	sub    $0x8,%esp
80103df8:	8b 55 08             	mov    0x8(%ebp),%edx
80103dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dfe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e02:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e05:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e09:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e0d:	ee                   	out    %al,(%dx)
}
80103e0e:	c9                   	leave  
80103e0f:	c3                   	ret    

80103e10 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	83 ec 0c             	sub    $0xc,%esp
80103e16:	8b 45 08             	mov    0x8(%ebp),%eax
80103e19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e1d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e21:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103e27:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e2b:	0f b6 c0             	movzbl %al,%eax
80103e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e32:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e39:	e8 b4 ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e42:	66 c1 e8 08          	shr    $0x8,%ax
80103e46:	0f b6 c0             	movzbl %al,%eax
80103e49:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e4d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e54:	e8 99 ff ff ff       	call   80103df2 <outb>
}
80103e59:	c9                   	leave  
80103e5a:	c3                   	ret    

80103e5b <picenable>:

void
picenable(int irq)
{
80103e5b:	55                   	push   %ebp
80103e5c:	89 e5                	mov    %esp,%ebp
80103e5e:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e61:	8b 45 08             	mov    0x8(%ebp),%eax
80103e64:	ba 01 00 00 00       	mov    $0x1,%edx
80103e69:	89 c1                	mov    %eax,%ecx
80103e6b:	d3 e2                	shl    %cl,%edx
80103e6d:	89 d0                	mov    %edx,%eax
80103e6f:	f7 d0                	not    %eax
80103e71:	89 c2                	mov    %eax,%edx
80103e73:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e7a:	21 d0                	and    %edx,%eax
80103e7c:	0f b7 c0             	movzwl %ax,%eax
80103e7f:	89 04 24             	mov    %eax,(%esp)
80103e82:	e8 89 ff ff ff       	call   80103e10 <picsetmask>
}
80103e87:	c9                   	leave  
80103e88:	c3                   	ret    

80103e89 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e89:	55                   	push   %ebp
80103e8a:	89 e5                	mov    %esp,%ebp
80103e8c:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e8f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e96:	00 
80103e97:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9e:	e8 4f ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ea3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eaa:	00 
80103eab:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb2:	e8 3b ff ff ff       	call   80103df2 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103eb7:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ebe:	00 
80103ebf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec6:	e8 27 ff ff ff       	call   80103df2 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ecb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ed2:	00 
80103ed3:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eda:	e8 13 ff ff ff       	call   80103df2 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103edf:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ee6:	00 
80103ee7:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eee:	e8 ff fe ff ff       	call   80103df2 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ef3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103efa:	00 
80103efb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f02:	e8 eb fe ff ff       	call   80103df2 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f07:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f0e:	00 
80103f0f:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f16:	e8 d7 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f1b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f22:	00 
80103f23:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2a:	e8 c3 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f2f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f36:	00 
80103f37:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f3e:	e8 af fe ff ff       	call   80103df2 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f43:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f4a:	00 
80103f4b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f52:	e8 9b fe ff ff       	call   80103df2 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f57:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5e:	00 
80103f5f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f66:	e8 87 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f6b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f72:	00 
80103f73:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f7a:	e8 73 fe ff ff       	call   80103df2 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f7f:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f86:	00 
80103f87:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f8e:	e8 5f fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f93:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f9a:	00 
80103f9b:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fa2:	e8 4b fe ff ff       	call   80103df2 <outb>

  if(irqmask != 0xFFFF)
80103fa7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fae:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fb2:	74 12                	je     80103fc6 <picinit+0x13d>
    picsetmask(irqmask);
80103fb4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fbb:	0f b7 c0             	movzwl %ax,%eax
80103fbe:	89 04 24             	mov    %eax,(%esp)
80103fc1:	e8 4a fe ff ff       	call   80103e10 <picsetmask>
}
80103fc6:	c9                   	leave  
80103fc7:	c3                   	ret    

80103fc8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe1:	8b 10                	mov    (%eax),%edx
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe8:	e8 54 cf ff ff       	call   80100f41 <filealloc>
80103fed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff0:	89 02                	mov    %eax,(%edx)
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	85 c0                	test   %eax,%eax
80103ff9:	0f 84 c8 00 00 00    	je     801040c7 <pipealloc+0xff>
80103fff:	e8 3d cf ff ff       	call   80100f41 <filealloc>
80104004:	8b 55 0c             	mov    0xc(%ebp),%edx
80104007:	89 02                	mov    %eax,(%edx)
80104009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	0f 84 b1 00 00 00    	je     801040c7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104016:	e8 7d eb ff ff       	call   80102b98 <kalloc>
8010401b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104022:	75 05                	jne    80104029 <pipealloc+0x61>
    goto bad;
80104024:	e9 9e 00 00 00       	jmp    801040c7 <pipealloc+0xff>
  p->readopen = 1;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104033:	00 00 00 
  p->writeopen = 1;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104040:	00 00 00 
  p->nwrite = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010404d:	00 00 00 
  p->nread = 0;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010405a:	00 00 00 
  initlock(&p->lock, "pipe");
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 44 24 04 d8 8b 10 	movl   $0x80108bd8,0x4(%esp)
80104067:	80 
80104068:	89 04 24             	mov    %eax,(%esp)
8010406b:	e8 6e 10 00 00       	call   801050de <initlock>
  (*f0)->type = FD_PIPE;
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8b 00                	mov    (%eax),%eax
80104080:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104095:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a6:	8b 00                	mov    (%eax),%eax
801040a8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040bd:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c0:	b8 00 00 00 00       	mov    $0x0,%eax
801040c5:	eb 42                	jmp    80104109 <pipealloc+0x141>

 bad:
  if(p)
801040c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cb:	74 0b                	je     801040d8 <pipealloc+0x110>
    kfree((char*)p);
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	89 04 24             	mov    %eax,(%esp)
801040d3:	e8 27 ea ff ff       	call   80102aff <kfree>
  if(*f0)
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 0d                	je     801040ee <pipealloc+0x126>
    fileclose(*f0);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 fb ce ff ff       	call   80100fe9 <fileclose>
  if(*f1)
801040ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	85 c0                	test   %eax,%eax
801040f5:	74 0d                	je     80104104 <pipealloc+0x13c>
    fileclose(*f1);
801040f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fa:	8b 00                	mov    (%eax),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 e5 ce ff ff       	call   80100fe9 <fileclose>
  return -1;
80104104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104109:	c9                   	leave  
8010410a:	c3                   	ret    

8010410b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	89 04 24             	mov    %eax,(%esp)
80104117:	e8 e3 0f 00 00       	call   801050ff <acquire>
  if(writable){
8010411c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104120:	74 1f                	je     80104141 <pipeclose+0x36>
    p->writeopen = 0;
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010412c:	00 00 00 
    wakeup(&p->nread);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	05 34 02 00 00       	add    $0x234,%eax
80104137:	89 04 24             	mov    %eax,(%esp)
8010413a:	e8 f3 0b 00 00       	call   80104d32 <wakeup>
8010413f:	eb 1d                	jmp    8010415e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414b:	00 00 00 
    wakeup(&p->nwrite);
8010414e:	8b 45 08             	mov    0x8(%ebp),%eax
80104151:	05 38 02 00 00       	add    $0x238,%eax
80104156:	89 04 24             	mov    %eax,(%esp)
80104159:	e8 d4 0b 00 00       	call   80104d32 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010415e:	8b 45 08             	mov    0x8(%ebp),%eax
80104161:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104167:	85 c0                	test   %eax,%eax
80104169:	75 25                	jne    80104190 <pipeclose+0x85>
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	75 18                	jne    80104190 <pipeclose+0x85>
    release(&p->lock);
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 de 0f 00 00       	call   80105161 <release>
    kfree((char*)p);
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	89 04 24             	mov    %eax,(%esp)
80104189:	e8 71 e9 ff ff       	call   80102aff <kfree>
8010418e:	eb 0b                	jmp    8010419b <pipeclose+0x90>
  } else
    release(&p->lock);
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	89 04 24             	mov    %eax,(%esp)
80104196:	e8 c6 0f 00 00       	call   80105161 <release>
}
8010419b:	c9                   	leave  
8010419c:	c3                   	ret    

8010419d <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
8010419d:	55                   	push   %ebp
8010419e:	89 e5                	mov    %esp,%ebp
801041a0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 51 0f 00 00       	call   801050ff <acquire>
  for(i = 0; i < n; i++){
801041ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041b5:	e9 a6 00 00 00       	jmp    80104260 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ba:	eb 57                	jmp    80104213 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 0d                	je     801041d6 <pipewrite+0x39>
801041c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041cf:	8b 40 24             	mov    0x24(%eax),%eax
801041d2:	85 c0                	test   %eax,%eax
801041d4:	74 15                	je     801041eb <pipewrite+0x4e>
        release(&p->lock);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	89 04 24             	mov    %eax,(%esp)
801041dc:	e8 80 0f 00 00       	call   80105161 <release>
        return -1;
801041e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e6:	e9 9f 00 00 00       	jmp    8010428a <pipewrite+0xed>
      }
      wakeup(&p->nread);
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	05 34 02 00 00       	add    $0x234,%eax
801041f3:	89 04 24             	mov    %eax,(%esp)
801041f6:	e8 37 0b 00 00       	call   80104d32 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104201:	81 c2 38 02 00 00    	add    $0x238,%edx
80104207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010420b:	89 14 24             	mov    %edx,(%esp)
8010420e:	e8 43 0a 00 00       	call   80104c56 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104225:	05 00 02 00 00       	add    $0x200,%eax
8010422a:	39 c2                	cmp    %eax,%edx
8010422c:	74 8e                	je     801041bc <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104237:	8d 48 01             	lea    0x1(%eax),%ecx
8010423a:	8b 55 08             	mov    0x8(%ebp),%edx
8010423d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104243:	25 ff 01 00 00       	and    $0x1ff,%eax
80104248:	89 c1                	mov    %eax,%ecx
8010424a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104250:	01 d0                	add    %edx,%eax
80104252:	0f b6 10             	movzbl (%eax),%edx
80104255:	8b 45 08             	mov    0x8(%ebp),%eax
80104258:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010425c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	3b 45 10             	cmp    0x10(%ebp),%eax
80104266:	0f 8c 4e ff ff ff    	jl     801041ba <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	05 34 02 00 00       	add    $0x234,%eax
80104274:	89 04 24             	mov    %eax,(%esp)
80104277:	e8 b6 0a 00 00       	call   80104d32 <wakeup>
  release(&p->lock);
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	89 04 24             	mov    %eax,(%esp)
80104282:	e8 da 0e 00 00       	call   80105161 <release>
  return n;
80104287:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010428a:	c9                   	leave  
8010428b:	c3                   	ret    

8010428c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
8010428f:	53                   	push   %ebx
80104290:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	89 04 24             	mov    %eax,(%esp)
80104299:	e8 61 0e 00 00       	call   801050ff <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429e:	eb 3a                	jmp    801042da <piperead+0x4e>
    if(proc->killed){
801042a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042a6:	8b 40 24             	mov    0x24(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 15                	je     801042c2 <piperead+0x36>
      release(&p->lock);
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	89 04 24             	mov    %eax,(%esp)
801042b3:	e8 a9 0e 00 00       	call   80105161 <release>
      return -1;
801042b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042bd:	e9 b5 00 00 00       	jmp    80104377 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	8b 55 08             	mov    0x8(%ebp),%edx
801042c8:	81 c2 34 02 00 00    	add    $0x234,%edx
801042ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801042d2:	89 14 24             	mov    %edx,(%esp)
801042d5:	e8 7c 09 00 00       	call   80104c56 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e3:	8b 45 08             	mov    0x8(%ebp),%eax
801042e6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042ec:	39 c2                	cmp    %eax,%edx
801042ee:	75 0d                	jne    801042fd <piperead+0x71>
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042f9:	85 c0                	test   %eax,%eax
801042fb:	75 a3                	jne    801042a0 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104304:	eb 4b                	jmp    80104351 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010430f:	8b 45 08             	mov    0x8(%ebp),%eax
80104312:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104318:	39 c2                	cmp    %eax,%edx
8010431a:	75 02                	jne    8010431e <piperead+0x92>
      break;
8010431c:	eb 3b                	jmp    80104359 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010431e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104321:	8b 45 0c             	mov    0xc(%ebp),%eax
80104324:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104327:	8b 45 08             	mov    0x8(%ebp),%eax
8010432a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104330:	8d 48 01             	lea    0x1(%eax),%ecx
80104333:	8b 55 08             	mov    0x8(%ebp),%edx
80104336:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010433c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104341:	89 c2                	mov    %eax,%edx
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010434b:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010434d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104354:	3b 45 10             	cmp    0x10(%ebp),%eax
80104357:	7c ad                	jl     80104306 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104359:	8b 45 08             	mov    0x8(%ebp),%eax
8010435c:	05 38 02 00 00       	add    $0x238,%eax
80104361:	89 04 24             	mov    %eax,(%esp)
80104364:	e8 c9 09 00 00       	call   80104d32 <wakeup>
  release(&p->lock);
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 ed 0d 00 00       	call   80105161 <release>
  return i;
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104377:	83 c4 24             	add    $0x24,%esp
8010437a:	5b                   	pop    %ebx
8010437b:	5d                   	pop    %ebp
8010437c:	c3                   	ret    

8010437d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010437d:	55                   	push   %ebp
8010437e:	89 e5                	mov    %esp,%ebp
80104380:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104383:	9c                   	pushf  
80104384:	58                   	pop    %eax
80104385:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104388:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010438b:	c9                   	leave  
8010438c:	c3                   	ret    

8010438d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010438d:	55                   	push   %ebp
8010438e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104390:	fb                   	sti    
}
80104391:	5d                   	pop    %ebp
80104392:	c3                   	ret    

80104393 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104393:	55                   	push   %ebp
80104394:	89 e5                	mov    %esp,%ebp
80104396:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104399:	c7 44 24 04 e0 8b 10 	movl   $0x80108be0,0x4(%esp)
801043a0:	80 
801043a1:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043a8:	e8 31 0d 00 00       	call   801050de <initlock>
}
801043ad:	c9                   	leave  
801043ae:	c3                   	ret    

801043af <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043af:	55                   	push   %ebp
801043b0:	89 e5                	mov    %esp,%ebp
801043b2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043b5:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043bc:	e8 3e 0d 00 00       	call   801050ff <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c1:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801043c8:	eb 55                	jmp    8010441f <allocproc+0x70>
    if(p->state == UNUSED)
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	8b 40 0c             	mov    0xc(%eax),%eax
801043d0:	85 c0                	test   %eax,%eax
801043d2:	75 44                	jne    80104418 <allocproc+0x69>
      goto found;
801043d4:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043df:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043e4:	8d 50 01             	lea    0x1(%eax),%edx
801043e7:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801043ed:	89 c2                	mov    %eax,%edx
801043ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f2:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
801043f5:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043fc:	e8 60 0d 00 00       	call   80105161 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104401:	e8 92 e7 ff ff       	call   80102b98 <kalloc>
80104406:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104409:	89 42 08             	mov    %eax,0x8(%edx)
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	8b 40 08             	mov    0x8(%eax),%eax
80104412:	85 c0                	test   %eax,%eax
80104414:	75 3c                	jne    80104452 <allocproc+0xa3>
80104416:	eb 26                	jmp    8010443e <allocproc+0x8f>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104418:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010441f:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104426:	72 a2                	jb     801043ca <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104428:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010442f:	e8 2d 0d 00 00       	call   80105161 <release>
  return 0;
80104434:	b8 00 00 00 00       	mov    $0x0,%eax
80104439:	e9 9d 00 00 00       	jmp    801044db <allocproc+0x12c>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010443e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104441:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104448:	b8 00 00 00 00       	mov    $0x0,%eax
8010444d:	e9 89 00 00 00       	jmp    801044db <allocproc+0x12c>
  }
  sp = p->kstack + KSTACKSIZE;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 40 08             	mov    0x8(%eax),%eax
80104458:	05 00 10 00 00       	add    $0x1000,%eax
8010445d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104460:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104467:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010446a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010446d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104471:	ba 32 69 10 80       	mov    $0x80106932,%edx
80104476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104479:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010447b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010447f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104482:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104485:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010448e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104495:	00 
80104496:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010449d:	00 
8010449e:	89 04 24             	mov    %eax,(%esp)
801044a1:	e8 ad 0e 00 00       	call   80105353 <memset>
  p->context->eip = (uint)forkret;
801044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a9:	8b 40 1c             	mov    0x1c(%eax),%eax
801044ac:	ba 17 4c 10 80       	mov    $0x80104c17,%edx
801044b1:	89 50 10             	mov    %edx,0x10(%eax)

  acquire(&tickslock);
801044b4:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801044bb:	e8 3f 0c 00 00       	call   801050ff <acquire>
  p->start_ticks = ticks;
801044c0:	8b 15 00 54 11 80    	mov    0x80115400,%edx
801044c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c9:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801044cc:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801044d3:	e8 89 0c 00 00       	call   80105161 <release>

  return p;
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044db:	c9                   	leave  
801044dc:	c3                   	ret    

801044dd <userinit>:

// Set up first user process.
void
userinit(void)
{
801044dd:	55                   	push   %ebp
801044de:	89 e5                	mov    %esp,%ebp
801044e0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044e3:	e8 c7 fe ff ff       	call   801043af <allocproc>
801044e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ee:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801044f3:	e8 2e 3b 00 00       	call   80108026 <setupkvm>
801044f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044fb:	89 42 04             	mov    %eax,0x4(%edx)
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 04             	mov    0x4(%eax),%eax
80104504:	85 c0                	test   %eax,%eax
80104506:	75 0c                	jne    80104514 <userinit+0x37>
    panic("userinit: out of memory?");
80104508:	c7 04 24 e7 8b 10 80 	movl   $0x80108be7,(%esp)
8010450f:	e8 26 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104514:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 40 04             	mov    0x4(%eax),%eax
8010451f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104523:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
8010452a:	80 
8010452b:	89 04 24             	mov    %eax,(%esp)
8010452e:	e8 4b 3d 00 00       	call   8010827e <inituvm>
  p->sz = PGSIZE;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453f:	8b 40 18             	mov    0x18(%eax),%eax
80104542:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104549:	00 
8010454a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104551:	00 
80104552:	89 04 24             	mov    %eax,(%esp)
80104555:	e8 f9 0d 00 00       	call   80105353 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	8b 40 18             	mov    0x18(%eax),%eax
80104560:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 18             	mov    0x18(%eax),%eax
8010456c:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	8b 40 18             	mov    0x18(%eax),%eax
80104578:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457b:	8b 52 18             	mov    0x18(%edx),%edx
8010457e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104582:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104589:	8b 40 18             	mov    0x18(%eax),%eax
8010458c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458f:	8b 52 18             	mov    0x18(%edx),%edx
80104592:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104596:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459d:	8b 40 18             	mov    0x18(%eax),%eax
801045a0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045aa:	8b 40 18             	mov    0x18(%eax),%eax
801045ad:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8b 40 18             	mov    0x18(%eax),%eax
801045ba:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c4:	83 c0 6c             	add    $0x6c,%eax
801045c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045ce:	00 
801045cf:	c7 44 24 04 00 8c 10 	movl   $0x80108c00,0x4(%esp)
801045d6:	80 
801045d7:	89 04 24             	mov    %eax,(%esp)
801045da:	e8 94 0f 00 00       	call   80105573 <safestrcpy>
  p->cwd = namei("/");
801045df:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
801045e6:	e8 9a de ff ff       	call   80102485 <namei>
801045eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ee:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

#ifdef CS333_P2
	p->uid = INITUID;
801045fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fe:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104605:	00 00 00 
	p->gid = INITGID;
80104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460b:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104612:	00 00 00 
#endif
}
80104615:	c9                   	leave  
80104616:	c3                   	ret    

80104617 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104617:	55                   	push   %ebp
80104618:	89 e5                	mov    %esp,%ebp
8010461a:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010461d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104623:	8b 00                	mov    (%eax),%eax
80104625:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104628:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010462c:	7e 34                	jle    80104662 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010462e:	8b 55 08             	mov    0x8(%ebp),%edx
80104631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104634:	01 c2                	add    %eax,%edx
80104636:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463c:	8b 40 04             	mov    0x4(%eax),%eax
8010463f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104643:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104646:	89 54 24 04          	mov    %edx,0x4(%esp)
8010464a:	89 04 24             	mov    %eax,(%esp)
8010464d:	e8 a2 3d 00 00       	call   801083f4 <allocuvm>
80104652:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104659:	75 41                	jne    8010469c <growproc+0x85>
      return -1;
8010465b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104660:	eb 58                	jmp    801046ba <growproc+0xa3>
  } else if(n < 0){
80104662:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104666:	79 34                	jns    8010469c <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104668:	8b 55 08             	mov    0x8(%ebp),%edx
8010466b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466e:	01 c2                	add    %eax,%edx
80104670:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104676:	8b 40 04             	mov    0x4(%eax),%eax
80104679:	89 54 24 08          	mov    %edx,0x8(%esp)
8010467d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104680:	89 54 24 04          	mov    %edx,0x4(%esp)
80104684:	89 04 24             	mov    %eax,(%esp)
80104687:	e8 42 3e 00 00       	call   801084ce <deallocuvm>
8010468c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010468f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104693:	75 07                	jne    8010469c <growproc+0x85>
      return -1;
80104695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469a:	eb 1e                	jmp    801046ba <growproc+0xa3>
  }
  proc->sz = sz;
8010469c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046a5:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801046a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ad:	89 04 24             	mov    %eax,(%esp)
801046b0:	e8 62 3a 00 00       	call   80108117 <switchuvm>
  return 0;
801046b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046ba:	c9                   	leave  
801046bb:	c3                   	ret    

801046bc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	57                   	push   %edi
801046c0:	56                   	push   %esi
801046c1:	53                   	push   %ebx
801046c2:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801046c5:	e8 e5 fc ff ff       	call   801043af <allocproc>
801046ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
801046cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801046d1:	75 0a                	jne    801046dd <fork+0x21>
    return -1;
801046d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d8:	e9 7c 01 00 00       	jmp    80104859 <fork+0x19d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801046dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e3:	8b 10                	mov    (%eax),%edx
801046e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046eb:	8b 40 04             	mov    0x4(%eax),%eax
801046ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801046f2:	89 04 24             	mov    %eax,(%esp)
801046f5:	e8 70 3f 00 00       	call   8010866a <copyuvm>
801046fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046fd:	89 42 04             	mov    %eax,0x4(%edx)
80104700:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104703:	8b 40 04             	mov    0x4(%eax),%eax
80104706:	85 c0                	test   %eax,%eax
80104708:	75 2c                	jne    80104736 <fork+0x7a>
    kfree(np->kstack);
8010470a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470d:	8b 40 08             	mov    0x8(%eax),%eax
80104710:	89 04 24             	mov    %eax,(%esp)
80104713:	e8 e7 e3 ff ff       	call   80102aff <kfree>
    np->kstack = 0;
80104718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104722:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104725:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010472c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104731:	e9 23 01 00 00       	jmp    80104859 <fork+0x19d>
  }
  np->sz = proc->sz;
80104736:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473c:	8b 10                	mov    (%eax),%edx
8010473e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104741:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104743:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010474a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104750:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104753:	8b 50 18             	mov    0x18(%eax),%edx
80104756:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475c:	8b 40 18             	mov    0x18(%eax),%eax
8010475f:	89 c3                	mov    %eax,%ebx
80104761:	b8 13 00 00 00       	mov    $0x13,%eax
80104766:	89 d7                	mov    %edx,%edi
80104768:	89 de                	mov    %ebx,%esi
8010476a:	89 c1                	mov    %eax,%ecx
8010476c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

#ifdef CS333_P2
	// Copy process UID, GID
	np->uid = proc->uid;
8010476e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104774:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010477a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477d:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	np->gid = proc->gid;
80104783:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104789:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010478f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104792:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
#endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104798:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479b:	8b 40 18             	mov    0x18(%eax),%eax
8010479e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801047a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801047ac:	eb 3d                	jmp    801047eb <fork+0x12f>
    if(proc->ofile[i])
801047ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047b7:	83 c2 08             	add    $0x8,%edx
801047ba:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047be:	85 c0                	test   %eax,%eax
801047c0:	74 25                	je     801047e7 <fork+0x12b>
      np->ofile[i] = filedup(proc->ofile[i]);
801047c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047cb:	83 c2 08             	add    $0x8,%edx
801047ce:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047d2:	89 04 24             	mov    %eax,(%esp)
801047d5:	e8 c7 c7 ff ff       	call   80100fa1 <filedup>
801047da:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047dd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801047e0:	83 c1 08             	add    $0x8,%ecx
801047e3:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
#endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801047e7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801047eb:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047ef:	7e bd                	jle    801047ae <fork+0xf2>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801047f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f7:	8b 40 68             	mov    0x68(%eax),%eax
801047fa:	89 04 24             	mov    %eax,(%esp)
801047fd:	e8 a0 d0 ff ff       	call   801018a2 <idup>
80104802:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104805:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104808:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104811:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104814:	83 c0 6c             	add    $0x6c,%eax
80104817:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010481e:	00 
8010481f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104823:	89 04 24             	mov    %eax,(%esp)
80104826:	e8 48 0d 00 00       	call   80105573 <safestrcpy>
 
  pid = np->pid;
8010482b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482e:	8b 40 10             	mov    0x10(%eax),%eax
80104831:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104834:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010483b:	e8 bf 08 00 00       	call   801050ff <acquire>
  np->state = RUNNABLE;
80104840:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104843:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010484a:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104851:	e8 0b 09 00 00       	call   80105161 <release>
  
  return pid;
80104856:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104859:	83 c4 2c             	add    $0x2c,%esp
8010485c:	5b                   	pop    %ebx
8010485d:	5e                   	pop    %esi
8010485e:	5f                   	pop    %edi
8010485f:	5d                   	pop    %ebp
80104860:	c3                   	ret    

80104861 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104861:	55                   	push   %ebp
80104862:	89 e5                	mov    %esp,%ebp
80104864:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104867:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010486e:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104873:	39 c2                	cmp    %eax,%edx
80104875:	75 0c                	jne    80104883 <exit+0x22>
    panic("init exiting");
80104877:	c7 04 24 0b 8c 10 80 	movl   $0x80108c0b,(%esp)
8010487e:	e8 b7 bc ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104883:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010488a:	eb 44                	jmp    801048d0 <exit+0x6f>
    if(proc->ofile[fd]){
8010488c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104892:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104895:	83 c2 08             	add    $0x8,%edx
80104898:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010489c:	85 c0                	test   %eax,%eax
8010489e:	74 2c                	je     801048cc <exit+0x6b>
      fileclose(proc->ofile[fd]);
801048a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048a9:	83 c2 08             	add    $0x8,%edx
801048ac:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048b0:	89 04 24             	mov    %eax,(%esp)
801048b3:	e8 31 c7 ff ff       	call   80100fe9 <fileclose>
      proc->ofile[fd] = 0;
801048b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048c1:	83 c2 08             	add    $0x8,%edx
801048c4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801048cb:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048cc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801048d0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801048d4:	7e b6                	jle    8010488c <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801048d6:	e8 e1 eb ff ff       	call   801034bc <begin_op>
  iput(proc->cwd);
801048db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e1:	8b 40 68             	mov    0x68(%eax),%eax
801048e4:	89 04 24             	mov    %eax,(%esp)
801048e7:	e8 a1 d1 ff ff       	call   80101a8d <iput>
  end_op();
801048ec:	e8 4f ec ff ff       	call   80103540 <end_op>
  proc->cwd = 0;
801048f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048fe:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104905:	e8 f5 07 00 00       	call   801050ff <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010490a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104910:	8b 40 14             	mov    0x14(%eax),%eax
80104913:	89 04 24             	mov    %eax,(%esp)
80104916:	e8 d6 03 00 00       	call   80104cf1 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010491b:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104922:	eb 3b                	jmp    8010495f <exit+0xfe>
    if(p->parent == proc){
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	8b 50 14             	mov    0x14(%eax),%edx
8010492a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104930:	39 c2                	cmp    %eax,%edx
80104932:	75 24                	jne    80104958 <exit+0xf7>
      p->parent = initproc;
80104934:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
8010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 40 0c             	mov    0xc(%eax),%eax
80104946:	83 f8 05             	cmp    $0x5,%eax
80104949:	75 0d                	jne    80104958 <exit+0xf7>
        wakeup1(initproc);
8010494b:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104950:	89 04 24             	mov    %eax,(%esp)
80104953:	e8 99 03 00 00       	call   80104cf1 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104958:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010495f:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104966:	72 bc                	jb     80104924 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104968:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104975:	e8 b9 01 00 00       	call   80104b33 <sched>
  panic("zombie exit");
8010497a:	c7 04 24 18 8c 10 80 	movl   $0x80108c18,(%esp)
80104981:	e8 b4 bb ff ff       	call   8010053a <panic>

80104986 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104986:	55                   	push   %ebp
80104987:	89 e5                	mov    %esp,%ebp
80104989:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010498c:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104993:	e8 67 07 00 00       	call   801050ff <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104998:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010499f:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801049a6:	e9 9d 00 00 00       	jmp    80104a48 <wait+0xc2>
      if(p->parent != proc)
801049ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ae:	8b 50 14             	mov    0x14(%eax),%edx
801049b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b7:	39 c2                	cmp    %eax,%edx
801049b9:	74 05                	je     801049c0 <wait+0x3a>
        continue;
801049bb:	e9 81 00 00 00       	jmp    80104a41 <wait+0xbb>
      havekids = 1;
801049c0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	8b 40 0c             	mov    0xc(%eax),%eax
801049cd:	83 f8 05             	cmp    $0x5,%eax
801049d0:	75 6f                	jne    80104a41 <wait+0xbb>
        // Found one.
        pid = p->pid;
801049d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d5:	8b 40 10             	mov    0x10(%eax),%eax
801049d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801049db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049de:	8b 40 08             	mov    0x8(%eax),%eax
801049e1:	89 04 24             	mov    %eax,(%esp)
801049e4:	e8 16 e1 ff ff       	call   80102aff <kfree>
        p->kstack = 0;
801049e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f6:	8b 40 04             	mov    0x4(%eax),%eax
801049f9:	89 04 24             	mov    %eax,(%esp)
801049fc:	e8 89 3b 00 00       	call   8010858a <freevm>
        p->state = UNUSED;
80104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a04:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a18:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a22:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104a30:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104a37:	e8 25 07 00 00       	call   80105161 <release>
        return pid;
80104a3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a3f:	eb 55                	jmp    80104a96 <wait+0x110>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a41:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104a48:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104a4f:	0f 82 56 ff ff ff    	jb     801049ab <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a55:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a59:	74 0d                	je     80104a68 <wait+0xe2>
80104a5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a61:	8b 40 24             	mov    0x24(%eax),%eax
80104a64:	85 c0                	test   %eax,%eax
80104a66:	74 13                	je     80104a7b <wait+0xf5>
      release(&ptable.lock);
80104a68:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104a6f:	e8 ed 06 00 00       	call   80105161 <release>
      return -1;
80104a74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a79:	eb 1b                	jmp    80104a96 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a81:	c7 44 24 04 80 29 11 	movl   $0x80112980,0x4(%esp)
80104a88:	80 
80104a89:	89 04 24             	mov    %eax,(%esp)
80104a8c:	e8 c5 01 00 00       	call   80104c56 <sleep>
  }
80104a91:	e9 02 ff ff ff       	jmp    80104998 <wait+0x12>
}
80104a96:	c9                   	leave  
80104a97:	c3                   	ret    

80104a98 <scheduler>:
//      via swtch back to the scheduler.
#ifndef CS333_P3
// original xv6 scheduler. Use if CS333_P3 NOT defined.
void
scheduler(void)
{
80104a98:	55                   	push   %ebp
80104a99:	89 e5                	mov    %esp,%ebp
80104a9b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a9e:	e8 ea f8 ff ff       	call   8010438d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104aa3:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104aaa:	e8 50 06 00 00       	call   801050ff <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aaf:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104ab6:	eb 61                	jmp    80104b19 <scheduler+0x81>
      if(p->state != RUNNABLE)
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	8b 40 0c             	mov    0xc(%eax),%eax
80104abe:	83 f8 03             	cmp    $0x3,%eax
80104ac1:	74 02                	je     80104ac5 <scheduler+0x2d>
        continue;
80104ac3:	eb 4d                	jmp    80104b12 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac8:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	89 04 24             	mov    %eax,(%esp)
80104ad4:	e8 3e 36 00 00       	call   80108117 <switchuvm>
      p->state = RUNNING;
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ae3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104aec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104af3:	83 c2 04             	add    $0x4,%edx
80104af6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104afa:	89 14 24             	mov    %edx,(%esp)
80104afd:	e8 e2 0a 00 00       	call   801055e4 <swtch>
      switchkvm();
80104b02:	e8 f3 35 00 00       	call   801080fa <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104b07:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b0e:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b12:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b19:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104b20:	72 96                	jb     80104ab8 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104b22:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104b29:	e8 33 06 00 00       	call   80105161 <release>

  }
80104b2e:	e9 6b ff ff ff       	jmp    80104a9e <scheduler+0x6>

80104b33 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104b33:	55                   	push   %ebp
80104b34:	89 e5                	mov    %esp,%ebp
80104b36:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104b39:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104b40:	e8 e4 06 00 00       	call   80105229 <holding>
80104b45:	85 c0                	test   %eax,%eax
80104b47:	75 0c                	jne    80104b55 <sched+0x22>
    panic("sched ptable.lock");
80104b49:	c7 04 24 24 8c 10 80 	movl   $0x80108c24,(%esp)
80104b50:	e8 e5 b9 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b55:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b5b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b61:	83 f8 01             	cmp    $0x1,%eax
80104b64:	74 0c                	je     80104b72 <sched+0x3f>
    panic("sched locks");
80104b66:	c7 04 24 36 8c 10 80 	movl   $0x80108c36,(%esp)
80104b6d:	e8 c8 b9 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b78:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7b:	83 f8 04             	cmp    $0x4,%eax
80104b7e:	75 0c                	jne    80104b8c <sched+0x59>
    panic("sched running");
80104b80:	c7 04 24 42 8c 10 80 	movl   $0x80108c42,(%esp)
80104b87:	e8 ae b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b8c:	e8 ec f7 ff ff       	call   8010437d <readeflags>
80104b91:	25 00 02 00 00       	and    $0x200,%eax
80104b96:	85 c0                	test   %eax,%eax
80104b98:	74 0c                	je     80104ba6 <sched+0x73>
    panic("sched interruptible");
80104b9a:	c7 04 24 50 8c 10 80 	movl   $0x80108c50,(%esp)
80104ba1:	e8 94 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104ba6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bac:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104bb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bbb:	8b 40 04             	mov    0x4(%eax),%eax
80104bbe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bc5:	83 c2 1c             	add    $0x1c,%edx
80104bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bcc:	89 14 24             	mov    %edx,(%esp)
80104bcf:	e8 10 0a 00 00       	call   801055e4 <swtch>
  cpu->intena = intena;
80104bd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bdd:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104be3:	c9                   	leave  
80104be4:	c3                   	ret    

80104be5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
80104be8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104beb:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104bf2:	e8 08 05 00 00       	call   801050ff <acquire>
  proc->state = RUNNABLE;
80104bf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bfd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c04:	e8 2a ff ff ff       	call   80104b33 <sched>
  release(&ptable.lock);
80104c09:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c10:	e8 4c 05 00 00       	call   80105161 <release>
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c1d:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c24:	e8 38 05 00 00       	call   80105161 <release>

  if (first) {
80104c29:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104c2e:	85 c0                	test   %eax,%eax
80104c30:	74 22                	je     80104c54 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104c32:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104c39:	00 00 00 
    iinit(ROOTDEV);
80104c3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c43:	e8 64 c9 ff ff       	call   801015ac <iinit>
    initlog(ROOTDEV);
80104c48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c4f:	e8 64 e6 ff ff       	call   801032b8 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104c54:	c9                   	leave  
80104c55:	c3                   	ret    

80104c56 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c56:	55                   	push   %ebp
80104c57:	89 e5                	mov    %esp,%ebp
80104c59:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104c5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c62:	85 c0                	test   %eax,%eax
80104c64:	75 0c                	jne    80104c72 <sleep+0x1c>
    panic("sleep");
80104c66:	c7 04 24 64 8c 10 80 	movl   $0x80108c64,(%esp)
80104c6d:	e8 c8 b8 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c76:	75 0c                	jne    80104c84 <sleep+0x2e>
    panic("sleep without lk");
80104c78:	c7 04 24 6a 8c 10 80 	movl   $0x80108c6a,(%esp)
80104c7f:	e8 b6 b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c84:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104c8b:	74 17                	je     80104ca4 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c8d:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c94:	e8 66 04 00 00       	call   801050ff <acquire>
    release(lk);
80104c99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9c:	89 04 24             	mov    %eax,(%esp)
80104c9f:	e8 bd 04 00 00       	call   80105161 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ca4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caa:	8b 55 08             	mov    0x8(%ebp),%edx
80104cad:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104cbd:	e8 71 fe ff ff       	call   80104b33 <sched>

  // Tidy up.
  proc->chan = 0;
80104cc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ccf:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104cd6:	74 17                	je     80104cef <sleep+0x99>
    release(&ptable.lock);
80104cd8:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104cdf:	e8 7d 04 00 00       	call   80105161 <release>
    acquire(lk);
80104ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce7:	89 04 24             	mov    %eax,(%esp)
80104cea:	e8 10 04 00 00       	call   801050ff <acquire>
  }
}
80104cef:	c9                   	leave  
80104cf0:	c3                   	ret    

80104cf1 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cf1:	55                   	push   %ebp
80104cf2:	89 e5                	mov    %esp,%ebp
80104cf4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf7:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104cfe:	eb 27                	jmp    80104d27 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d03:	8b 40 0c             	mov    0xc(%eax),%eax
80104d06:	83 f8 02             	cmp    $0x2,%eax
80104d09:	75 15                	jne    80104d20 <wakeup1+0x2f>
80104d0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d0e:	8b 40 20             	mov    0x20(%eax),%eax
80104d11:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d14:	75 0a                	jne    80104d20 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104d16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d19:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d20:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104d27:	81 7d fc b4 4b 11 80 	cmpl   $0x80114bb4,-0x4(%ebp)
80104d2e:	72 d0                	jb     80104d00 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104d30:	c9                   	leave  
80104d31:	c3                   	ret    

80104d32 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d32:	55                   	push   %ebp
80104d33:	89 e5                	mov    %esp,%ebp
80104d35:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104d38:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d3f:	e8 bb 03 00 00       	call   801050ff <acquire>
  wakeup1(chan);
80104d44:	8b 45 08             	mov    0x8(%ebp),%eax
80104d47:	89 04 24             	mov    %eax,(%esp)
80104d4a:	e8 a2 ff ff ff       	call   80104cf1 <wakeup1>
  release(&ptable.lock);
80104d4f:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d56:	e8 06 04 00 00       	call   80105161 <release>
}
80104d5b:	c9                   	leave  
80104d5c:	c3                   	ret    

80104d5d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d5d:	55                   	push   %ebp
80104d5e:	89 e5                	mov    %esp,%ebp
80104d60:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d63:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d6a:	e8 90 03 00 00       	call   801050ff <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d6f:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104d76:	eb 46                	jmp    80104dbe <kill+0x61>
    if(p->pid == pid){
80104d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7b:	8b 50 10             	mov    0x10(%eax),%edx
80104d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d81:	39 c2                	cmp    %eax,%edx
80104d83:	75 32                	jne    80104db7 <kill+0x5a>
      p->killed = 1;
80104d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d88:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d92:	8b 40 0c             	mov    0xc(%eax),%eax
80104d95:	83 f8 02             	cmp    $0x2,%eax
80104d98:	75 0a                	jne    80104da4 <kill+0x47>
        p->state = RUNNABLE;
80104d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104da4:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104dab:	e8 b1 03 00 00       	call   80105161 <release>
      return 0;
80104db0:	b8 00 00 00 00       	mov    $0x0,%eax
80104db5:	eb 21                	jmp    80104dd8 <kill+0x7b>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db7:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104dbe:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104dc5:	72 b1                	jb     80104d78 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104dc7:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104dce:	e8 8e 03 00 00       	call   80105161 <release>
  return -1;
80104dd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dd8:	c9                   	leave  
80104dd9:	c3                   	ret    

80104dda <print_elapsed>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
static void
print_elapsed(struct proc *p)
{
80104dda:	55                   	push   %ebp
80104ddb:	89 e5                	mov    %esp,%ebp
80104ddd:	83 ec 28             	sub    $0x28,%esp
  uint temp = p->start_ticks;
80104de0:	8b 45 08             	mov    0x8(%ebp),%eax
80104de3:	8b 40 7c             	mov    0x7c(%eax),%eax
80104de6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  temp = ticks - temp;
80104de9:	a1 00 54 11 80       	mov    0x80115400,%eax
80104dee:	2b 45 f4             	sub    -0xc(%ebp),%eax
80104df1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  cprintf("%d.",temp/100);
80104df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104dfc:	f7 e2                	mul    %edx
80104dfe:	89 d0                	mov    %edx,%eax
80104e00:	c1 e8 05             	shr    $0x5,%eax
80104e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e07:	c7 04 24 7b 8c 10 80 	movl   $0x80108c7b,(%esp)
80104e0e:	e8 8d b5 ff ff       	call   801003a0 <cprintf>
  cprintf("%d",temp%100);
80104e13:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104e16:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104e1b:	89 c8                	mov    %ecx,%eax
80104e1d:	f7 e2                	mul    %edx
80104e1f:	89 d0                	mov    %edx,%eax
80104e21:	c1 e8 05             	shr    $0x5,%eax
80104e24:	6b c0 64             	imul   $0x64,%eax,%eax
80104e27:	29 c1                	sub    %eax,%ecx
80104e29:	89 c8                	mov    %ecx,%eax
80104e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e2f:	c7 04 24 7f 8c 10 80 	movl   $0x80108c7f,(%esp)
80104e36:	e8 65 b5 ff ff       	call   801003a0 <cprintf>
}
80104e3b:	c9                   	leave  
80104e3c:	c3                   	ret    

80104e3d <procdump>:

void
procdump(void)
{
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  cprintf("\nPID  State  Name  Elapsed  PCs\n");
80104e43:	c7 04 24 84 8c 10 80 	movl   $0x80108c84,(%esp)
80104e4a:	e8 51 b5 ff ff       	call   801003a0 <cprintf>
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4f:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
80104e56:	e9 e4 00 00 00       	jmp    80104f3f <procdump+0x102>
    if(p->state == UNUSED)
80104e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e5e:	8b 40 0c             	mov    0xc(%eax),%eax
80104e61:	85 c0                	test   %eax,%eax
80104e63:	75 05                	jne    80104e6a <procdump+0x2d>
      continue;
80104e65:	e9 ce 00 00 00       	jmp    80104f38 <procdump+0xfb>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e70:	83 f8 05             	cmp    $0x5,%eax
80104e73:	77 23                	ja     80104e98 <procdump+0x5b>
80104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e78:	8b 40 0c             	mov    0xc(%eax),%eax
80104e7b:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e82:	85 c0                	test   %eax,%eax
80104e84:	74 12                	je     80104e98 <procdump+0x5b>
      state = states[p->state];
80104e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e89:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8c:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e93:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e96:	eb 07                	jmp    80104e9f <procdump+0x62>
    else
      state = "???";
80104e98:	c7 45 ec a5 8c 10 80 	movl   $0x80108ca5,-0x14(%ebp)
    cprintf("%d    %s %s   ", p->pid, state, p->name);
80104e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea2:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea8:	8b 40 10             	mov    0x10(%eax),%eax
80104eab:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104eaf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104eb2:	89 54 24 08          	mov    %edx,0x8(%esp)
80104eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104eba:	c7 04 24 a9 8c 10 80 	movl   $0x80108ca9,(%esp)
80104ec1:	e8 da b4 ff ff       	call   801003a0 <cprintf>
    print_elapsed(p);
80104ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec9:	89 04 24             	mov    %eax,(%esp)
80104ecc:	e8 09 ff ff ff       	call   80104dda <print_elapsed>
    if(p->state == SLEEPING){
80104ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed7:	83 f8 02             	cmp    $0x2,%eax
80104eda:	75 50                	jne    80104f2c <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ee2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee5:	83 c0 08             	add    $0x8,%eax
80104ee8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104eeb:	89 54 24 04          	mov    %edx,0x4(%esp)
80104eef:	89 04 24             	mov    %eax,(%esp)
80104ef2:	e8 b9 02 00 00       	call   801051b0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ef7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104efe:	eb 1b                	jmp    80104f1b <procdump+0xde>
        cprintf(" %p", pc[i]);
80104f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f03:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f0b:	c7 04 24 b8 8c 10 80 	movl   $0x80108cb8,(%esp)
80104f12:	e8 89 b4 ff ff       	call   801003a0 <cprintf>
      state = "???";
    cprintf("%d    %s %s   ", p->pid, state, p->name);
    print_elapsed(p);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f1b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f1f:	7f 0b                	jg     80104f2c <procdump+0xef>
80104f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f24:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f28:	85 c0                	test   %eax,%eax
80104f2a:	75 d4                	jne    80104f00 <procdump+0xc3>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f2c:	c7 04 24 bc 8c 10 80 	movl   $0x80108cbc,(%esp)
80104f33:	e8 68 b4 ff ff       	call   801003a0 <cprintf>
  char *state;
  uint pc[10];

  cprintf("\nPID  State  Name  Elapsed  PCs\n");
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f38:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104f3f:	81 7d f0 b4 4b 11 80 	cmpl   $0x80114bb4,-0x10(%ebp)
80104f46:	0f 82 0f ff ff ff    	jb     80104e5b <procdump+0x1e>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f4c:	c9                   	leave  
80104f4d:	c3                   	ret    

80104f4e <getprocs>:

#ifdef CS333_P2
// Get process information
int
getprocs(uint max, struct uproc* table)
{
80104f4e:	55                   	push   %ebp
80104f4f:	89 e5                	mov    %esp,%ebp
80104f51:	83 ec 28             	sub    $0x28,%esp
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };

	int procscount = 0;
80104f54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc *p;
	if(max > NPROC)
80104f5b:	83 7d 08 40          	cmpl   $0x40,0x8(%ebp)
80104f5f:	76 07                	jbe    80104f68 <getprocs+0x1a>
		max = NPROC;
80104f61:	c7 45 08 40 00 00 00 	movl   $0x40,0x8(%ebp)
	acquire(&ptable.lock);
80104f68:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104f6f:	e8 8b 01 00 00       	call   801050ff <acquire>
	for(p = ptable.proc; p < &ptable.proc[max]; p++){
80104f74:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
80104f7b:	e9 f6 00 00 00       	jmp    80105076 <getprocs+0x128>
		if(p->state == UNUSED || p->state == EMBRYO || p->state == ZOMBIE)
80104f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f83:	8b 40 0c             	mov    0xc(%eax),%eax
80104f86:	85 c0                	test   %eax,%eax
80104f88:	74 16                	je     80104fa0 <getprocs+0x52>
80104f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f90:	83 f8 01             	cmp    $0x1,%eax
80104f93:	74 0b                	je     80104fa0 <getprocs+0x52>
80104f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f98:	8b 40 0c             	mov    0xc(%eax),%eax
80104f9b:	83 f8 05             	cmp    $0x5,%eax
80104f9e:	75 05                	jne    80104fa5 <getprocs+0x57>
			continue;
80104fa0:	e9 ca 00 00 00       	jmp    8010506f <getprocs+0x121>
		table->pid = p->pid;
80104fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa8:	8b 50 10             	mov    0x10(%eax),%edx
80104fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fae:	89 10                	mov    %edx,(%eax)
		table->uid = p->uid;
80104fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb3:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fbc:	89 50 04             	mov    %edx,0x4(%eax)
		table->gid = p->gid;
80104fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc2:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fcb:	89 50 08             	mov    %edx,0x8(%eax)
		table->ppid = p->parent->pid;
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	8b 40 14             	mov    0x14(%eax),%eax
80104fd4:	8b 50 10             	mov    0x10(%eax),%edx
80104fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fda:	89 50 0c             	mov    %edx,0xc(%eax)
		acquire(&tickslock);
80104fdd:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80104fe4:	e8 16 01 00 00       	call   801050ff <acquire>
		table->elapsed_ticks = ticks - p->start_ticks;
80104fe9:	8b 15 00 54 11 80    	mov    0x80115400,%edx
80104fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff2:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ff5:	29 c2                	sub    %eax,%edx
80104ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffa:	89 50 10             	mov    %edx,0x10(%eax)
		table->CPU_total_ticks = ticks;
80104ffd:	8b 15 00 54 11 80    	mov    0x80115400,%edx
80105003:	8b 45 0c             	mov    0xc(%ebp),%eax
80105006:	89 50 14             	mov    %edx,0x14(%eax)
		release(&tickslock);
80105009:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80105010:	e8 4c 01 00 00       	call   80105161 <release>
		safestrcpy(table->state, states[p->state], sizeof(table->state));
80105015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105018:	8b 40 0c             	mov    0xc(%eax),%eax
8010501b:	8b 04 85 24 b0 10 80 	mov    -0x7fef4fdc(,%eax,4),%eax
80105022:	8b 55 0c             	mov    0xc(%ebp),%edx
80105025:	83 c2 18             	add    $0x18,%edx
80105028:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
8010502f:	00 
80105030:	89 44 24 04          	mov    %eax,0x4(%esp)
80105034:	89 14 24             	mov    %edx,(%esp)
80105037:	e8 37 05 00 00       	call   80105573 <safestrcpy>
		table->size = p->sz;
8010503c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503f:	8b 10                	mov    (%eax),%edx
80105041:	8b 45 0c             	mov    0xc(%ebp),%eax
80105044:	89 50 38             	mov    %edx,0x38(%eax)
		safestrcpy(table->name, p->name, sizeof(table->name));
80105047:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010504d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105050:	83 c0 3c             	add    $0x3c,%eax
80105053:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
8010505a:	00 
8010505b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010505f:	89 04 24             	mov    %eax,(%esp)
80105062:	e8 0c 05 00 00       	call   80105573 <safestrcpy>
		++procscount;
80105067:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		++table;
8010506b:	83 45 0c 5c          	addl   $0x5c,0xc(%ebp)
	int procscount = 0;
  struct proc *p;
	if(max > NPROC)
		max = NPROC;
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[max]; p++){
8010506f:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80105076:	8b 45 08             	mov    0x8(%ebp),%eax
80105079:	c1 e0 03             	shl    $0x3,%eax
8010507c:	89 c2                	mov    %eax,%edx
8010507e:	c1 e2 04             	shl    $0x4,%edx
80105081:	01 d0                	add    %edx,%eax
80105083:	83 c0 30             	add    $0x30,%eax
80105086:	05 80 29 11 80       	add    $0x80112980,%eax
8010508b:	83 c0 04             	add    $0x4,%eax
8010508e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80105091:	0f 87 e9 fe ff ff    	ja     80104f80 <getprocs+0x32>
		table->size = p->sz;
		safestrcpy(table->name, p->name, sizeof(table->name));
		++procscount;
		++table;
	}
	release(&ptable.lock);
80105097:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010509e:	e8 be 00 00 00       	call   80105161 <release>

  return procscount;
801050a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050a6:	c9                   	leave  
801050a7:	c3                   	ret    

801050a8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801050a8:	55                   	push   %ebp
801050a9:	89 e5                	mov    %esp,%ebp
801050ab:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801050ae:	9c                   	pushf  
801050af:	58                   	pop    %eax
801050b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801050b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050b6:	c9                   	leave  
801050b7:	c3                   	ret    

801050b8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801050b8:	55                   	push   %ebp
801050b9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801050bb:	fa                   	cli    
}
801050bc:	5d                   	pop    %ebp
801050bd:	c3                   	ret    

801050be <sti>:

static inline void
sti(void)
{
801050be:	55                   	push   %ebp
801050bf:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801050c1:	fb                   	sti    
}
801050c2:	5d                   	pop    %ebp
801050c3:	c3                   	ret    

801050c4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801050c4:	55                   	push   %ebp
801050c5:	89 e5                	mov    %esp,%ebp
801050c7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801050ca:	8b 55 08             	mov    0x8(%ebp),%edx
801050cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050d3:	f0 87 02             	lock xchg %eax,(%edx)
801050d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801050d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050dc:	c9                   	leave  
801050dd:	c3                   	ret    

801050de <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050de:	55                   	push   %ebp
801050df:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050e1:	8b 45 08             	mov    0x8(%ebp),%eax
801050e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801050e7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050ea:	8b 45 08             	mov    0x8(%ebp),%eax
801050ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050f3:	8b 45 08             	mov    0x8(%ebp),%eax
801050f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050fd:	5d                   	pop    %ebp
801050fe:	c3                   	ret    

801050ff <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050ff:	55                   	push   %ebp
80105100:	89 e5                	mov    %esp,%ebp
80105102:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105105:	e8 49 01 00 00       	call   80105253 <pushcli>
  if(holding(lk))
8010510a:	8b 45 08             	mov    0x8(%ebp),%eax
8010510d:	89 04 24             	mov    %eax,(%esp)
80105110:	e8 14 01 00 00       	call   80105229 <holding>
80105115:	85 c0                	test   %eax,%eax
80105117:	74 0c                	je     80105125 <acquire+0x26>
    panic("acquire");
80105119:	c7 04 24 e8 8c 10 80 	movl   $0x80108ce8,(%esp)
80105120:	e8 15 b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105125:	90                   	nop
80105126:	8b 45 08             	mov    0x8(%ebp),%eax
80105129:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105130:	00 
80105131:	89 04 24             	mov    %eax,(%esp)
80105134:	e8 8b ff ff ff       	call   801050c4 <xchg>
80105139:	85 c0                	test   %eax,%eax
8010513b:	75 e9                	jne    80105126 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010513d:	8b 45 08             	mov    0x8(%ebp),%eax
80105140:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105147:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	83 c0 0c             	add    $0xc,%eax
80105150:	89 44 24 04          	mov    %eax,0x4(%esp)
80105154:	8d 45 08             	lea    0x8(%ebp),%eax
80105157:	89 04 24             	mov    %eax,(%esp)
8010515a:	e8 51 00 00 00       	call   801051b0 <getcallerpcs>
}
8010515f:	c9                   	leave  
80105160:	c3                   	ret    

80105161 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105161:	55                   	push   %ebp
80105162:	89 e5                	mov    %esp,%ebp
80105164:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105167:	8b 45 08             	mov    0x8(%ebp),%eax
8010516a:	89 04 24             	mov    %eax,(%esp)
8010516d:	e8 b7 00 00 00       	call   80105229 <holding>
80105172:	85 c0                	test   %eax,%eax
80105174:	75 0c                	jne    80105182 <release+0x21>
    panic("release");
80105176:	c7 04 24 f0 8c 10 80 	movl   $0x80108cf0,(%esp)
8010517d:	e8 b8 b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105182:	8b 45 08             	mov    0x8(%ebp),%eax
80105185:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010518c:	8b 45 08             	mov    0x8(%ebp),%eax
8010518f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105196:	8b 45 08             	mov    0x8(%ebp),%eax
80105199:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801051a0:	00 
801051a1:	89 04 24             	mov    %eax,(%esp)
801051a4:	e8 1b ff ff ff       	call   801050c4 <xchg>

  popcli();
801051a9:	e8 e9 00 00 00       	call   80105297 <popcli>
}
801051ae:	c9                   	leave  
801051af:	c3                   	ret    

801051b0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801051b6:	8b 45 08             	mov    0x8(%ebp),%eax
801051b9:	83 e8 08             	sub    $0x8,%eax
801051bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051bf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051c6:	eb 38                	jmp    80105200 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051c8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051cc:	74 38                	je     80105206 <getcallerpcs+0x56>
801051ce:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051d5:	76 2f                	jbe    80105206 <getcallerpcs+0x56>
801051d7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051db:	74 29                	je     80105206 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ea:	01 c2                	add    %eax,%edx
801051ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ef:	8b 40 04             	mov    0x4(%eax),%eax
801051f2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f7:	8b 00                	mov    (%eax),%eax
801051f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051fc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105200:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105204:	7e c2                	jle    801051c8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105206:	eb 19                	jmp    80105221 <getcallerpcs+0x71>
    pcs[i] = 0;
80105208:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010520b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105212:	8b 45 0c             	mov    0xc(%ebp),%eax
80105215:	01 d0                	add    %edx,%eax
80105217:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010521d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105221:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105225:	7e e1                	jle    80105208 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105227:	c9                   	leave  
80105228:	c3                   	ret    

80105229 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105229:	55                   	push   %ebp
8010522a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010522c:	8b 45 08             	mov    0x8(%ebp),%eax
8010522f:	8b 00                	mov    (%eax),%eax
80105231:	85 c0                	test   %eax,%eax
80105233:	74 17                	je     8010524c <holding+0x23>
80105235:	8b 45 08             	mov    0x8(%ebp),%eax
80105238:	8b 50 08             	mov    0x8(%eax),%edx
8010523b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105241:	39 c2                	cmp    %eax,%edx
80105243:	75 07                	jne    8010524c <holding+0x23>
80105245:	b8 01 00 00 00       	mov    $0x1,%eax
8010524a:	eb 05                	jmp    80105251 <holding+0x28>
8010524c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105251:	5d                   	pop    %ebp
80105252:	c3                   	ret    

80105253 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105253:	55                   	push   %ebp
80105254:	89 e5                	mov    %esp,%ebp
80105256:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105259:	e8 4a fe ff ff       	call   801050a8 <readeflags>
8010525e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105261:	e8 52 fe ff ff       	call   801050b8 <cli>
  if(cpu->ncli++ == 0)
80105266:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010526d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105273:	8d 48 01             	lea    0x1(%eax),%ecx
80105276:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010527c:	85 c0                	test   %eax,%eax
8010527e:	75 15                	jne    80105295 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105280:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105286:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105289:	81 e2 00 02 00 00    	and    $0x200,%edx
8010528f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105295:	c9                   	leave  
80105296:	c3                   	ret    

80105297 <popcli>:

void
popcli(void)
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010529d:	e8 06 fe ff ff       	call   801050a8 <readeflags>
801052a2:	25 00 02 00 00       	and    $0x200,%eax
801052a7:	85 c0                	test   %eax,%eax
801052a9:	74 0c                	je     801052b7 <popcli+0x20>
    panic("popcli - interruptible");
801052ab:	c7 04 24 f8 8c 10 80 	movl   $0x80108cf8,(%esp)
801052b2:	e8 83 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801052b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052bd:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801052c3:	83 ea 01             	sub    $0x1,%edx
801052c6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801052cc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052d2:	85 c0                	test   %eax,%eax
801052d4:	79 0c                	jns    801052e2 <popcli+0x4b>
    panic("popcli");
801052d6:	c7 04 24 0f 8d 10 80 	movl   $0x80108d0f,(%esp)
801052dd:	e8 58 b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801052e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052e8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052ee:	85 c0                	test   %eax,%eax
801052f0:	75 15                	jne    80105307 <popcli+0x70>
801052f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052fe:	85 c0                	test   %eax,%eax
80105300:	74 05                	je     80105307 <popcli+0x70>
    sti();
80105302:	e8 b7 fd ff ff       	call   801050be <sti>
}
80105307:	c9                   	leave  
80105308:	c3                   	ret    

80105309 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105309:	55                   	push   %ebp
8010530a:	89 e5                	mov    %esp,%ebp
8010530c:	57                   	push   %edi
8010530d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010530e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105311:	8b 55 10             	mov    0x10(%ebp),%edx
80105314:	8b 45 0c             	mov    0xc(%ebp),%eax
80105317:	89 cb                	mov    %ecx,%ebx
80105319:	89 df                	mov    %ebx,%edi
8010531b:	89 d1                	mov    %edx,%ecx
8010531d:	fc                   	cld    
8010531e:	f3 aa                	rep stos %al,%es:(%edi)
80105320:	89 ca                	mov    %ecx,%edx
80105322:	89 fb                	mov    %edi,%ebx
80105324:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105327:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010532a:	5b                   	pop    %ebx
8010532b:	5f                   	pop    %edi
8010532c:	5d                   	pop    %ebp
8010532d:	c3                   	ret    

8010532e <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010532e:	55                   	push   %ebp
8010532f:	89 e5                	mov    %esp,%ebp
80105331:	57                   	push   %edi
80105332:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105333:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105336:	8b 55 10             	mov    0x10(%ebp),%edx
80105339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533c:	89 cb                	mov    %ecx,%ebx
8010533e:	89 df                	mov    %ebx,%edi
80105340:	89 d1                	mov    %edx,%ecx
80105342:	fc                   	cld    
80105343:	f3 ab                	rep stos %eax,%es:(%edi)
80105345:	89 ca                	mov    %ecx,%edx
80105347:	89 fb                	mov    %edi,%ebx
80105349:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010534c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010534f:	5b                   	pop    %ebx
80105350:	5f                   	pop    %edi
80105351:	5d                   	pop    %ebp
80105352:	c3                   	ret    

80105353 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105353:	55                   	push   %ebp
80105354:	89 e5                	mov    %esp,%ebp
80105356:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105359:	8b 45 08             	mov    0x8(%ebp),%eax
8010535c:	83 e0 03             	and    $0x3,%eax
8010535f:	85 c0                	test   %eax,%eax
80105361:	75 49                	jne    801053ac <memset+0x59>
80105363:	8b 45 10             	mov    0x10(%ebp),%eax
80105366:	83 e0 03             	and    $0x3,%eax
80105369:	85 c0                	test   %eax,%eax
8010536b:	75 3f                	jne    801053ac <memset+0x59>
    c &= 0xFF;
8010536d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105374:	8b 45 10             	mov    0x10(%ebp),%eax
80105377:	c1 e8 02             	shr    $0x2,%eax
8010537a:	89 c2                	mov    %eax,%edx
8010537c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010537f:	c1 e0 18             	shl    $0x18,%eax
80105382:	89 c1                	mov    %eax,%ecx
80105384:	8b 45 0c             	mov    0xc(%ebp),%eax
80105387:	c1 e0 10             	shl    $0x10,%eax
8010538a:	09 c1                	or     %eax,%ecx
8010538c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538f:	c1 e0 08             	shl    $0x8,%eax
80105392:	09 c8                	or     %ecx,%eax
80105394:	0b 45 0c             	or     0xc(%ebp),%eax
80105397:	89 54 24 08          	mov    %edx,0x8(%esp)
8010539b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539f:	8b 45 08             	mov    0x8(%ebp),%eax
801053a2:	89 04 24             	mov    %eax,(%esp)
801053a5:	e8 84 ff ff ff       	call   8010532e <stosl>
801053aa:	eb 19                	jmp    801053c5 <memset+0x72>
  } else
    stosb(dst, c, n);
801053ac:	8b 45 10             	mov    0x10(%ebp),%eax
801053af:	89 44 24 08          	mov    %eax,0x8(%esp)
801053b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ba:	8b 45 08             	mov    0x8(%ebp),%eax
801053bd:	89 04 24             	mov    %eax,(%esp)
801053c0:	e8 44 ff ff ff       	call   80105309 <stosb>
  return dst;
801053c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053c8:	c9                   	leave  
801053c9:	c3                   	ret    

801053ca <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053ca:	55                   	push   %ebp
801053cb:	89 e5                	mov    %esp,%ebp
801053cd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801053d0:	8b 45 08             	mov    0x8(%ebp),%eax
801053d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053dc:	eb 30                	jmp    8010540e <memcmp+0x44>
    if(*s1 != *s2)
801053de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e1:	0f b6 10             	movzbl (%eax),%edx
801053e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e7:	0f b6 00             	movzbl (%eax),%eax
801053ea:	38 c2                	cmp    %al,%dl
801053ec:	74 18                	je     80105406 <memcmp+0x3c>
      return *s1 - *s2;
801053ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f1:	0f b6 00             	movzbl (%eax),%eax
801053f4:	0f b6 d0             	movzbl %al,%edx
801053f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fa:	0f b6 00             	movzbl (%eax),%eax
801053fd:	0f b6 c0             	movzbl %al,%eax
80105400:	29 c2                	sub    %eax,%edx
80105402:	89 d0                	mov    %edx,%eax
80105404:	eb 1a                	jmp    80105420 <memcmp+0x56>
    s1++, s2++;
80105406:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010540a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010540e:	8b 45 10             	mov    0x10(%ebp),%eax
80105411:	8d 50 ff             	lea    -0x1(%eax),%edx
80105414:	89 55 10             	mov    %edx,0x10(%ebp)
80105417:	85 c0                	test   %eax,%eax
80105419:	75 c3                	jne    801053de <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010541b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105420:	c9                   	leave  
80105421:	c3                   	ret    

80105422 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
80105425:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105428:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010542e:	8b 45 08             	mov    0x8(%ebp),%eax
80105431:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105434:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105437:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010543a:	73 3d                	jae    80105479 <memmove+0x57>
8010543c:	8b 45 10             	mov    0x10(%ebp),%eax
8010543f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105442:	01 d0                	add    %edx,%eax
80105444:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105447:	76 30                	jbe    80105479 <memmove+0x57>
    s += n;
80105449:	8b 45 10             	mov    0x10(%ebp),%eax
8010544c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010544f:	8b 45 10             	mov    0x10(%ebp),%eax
80105452:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105455:	eb 13                	jmp    8010546a <memmove+0x48>
      *--d = *--s;
80105457:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010545b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010545f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105462:	0f b6 10             	movzbl (%eax),%edx
80105465:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105468:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010546a:	8b 45 10             	mov    0x10(%ebp),%eax
8010546d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105470:	89 55 10             	mov    %edx,0x10(%ebp)
80105473:	85 c0                	test   %eax,%eax
80105475:	75 e0                	jne    80105457 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105477:	eb 26                	jmp    8010549f <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105479:	eb 17                	jmp    80105492 <memmove+0x70>
      *d++ = *s++;
8010547b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010547e:	8d 50 01             	lea    0x1(%eax),%edx
80105481:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105484:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105487:	8d 4a 01             	lea    0x1(%edx),%ecx
8010548a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010548d:	0f b6 12             	movzbl (%edx),%edx
80105490:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105492:	8b 45 10             	mov    0x10(%ebp),%eax
80105495:	8d 50 ff             	lea    -0x1(%eax),%edx
80105498:	89 55 10             	mov    %edx,0x10(%ebp)
8010549b:	85 c0                	test   %eax,%eax
8010549d:	75 dc                	jne    8010547b <memmove+0x59>
      *d++ = *s++;

  return dst;
8010549f:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054a2:	c9                   	leave  
801054a3:	c3                   	ret    

801054a4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
801054a7:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801054aa:	8b 45 10             	mov    0x10(%ebp),%eax
801054ad:	89 44 24 08          	mov    %eax,0x8(%esp)
801054b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b8:	8b 45 08             	mov    0x8(%ebp),%eax
801054bb:	89 04 24             	mov    %eax,(%esp)
801054be:	e8 5f ff ff ff       	call   80105422 <memmove>
}
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    

801054c5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801054c5:	55                   	push   %ebp
801054c6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801054c8:	eb 0c                	jmp    801054d6 <strncmp+0x11>
    n--, p++, q++;
801054ca:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801054d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054da:	74 1a                	je     801054f6 <strncmp+0x31>
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	0f b6 00             	movzbl (%eax),%eax
801054e2:	84 c0                	test   %al,%al
801054e4:	74 10                	je     801054f6 <strncmp+0x31>
801054e6:	8b 45 08             	mov    0x8(%ebp),%eax
801054e9:	0f b6 10             	movzbl (%eax),%edx
801054ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ef:	0f b6 00             	movzbl (%eax),%eax
801054f2:	38 c2                	cmp    %al,%dl
801054f4:	74 d4                	je     801054ca <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054fa:	75 07                	jne    80105503 <strncmp+0x3e>
    return 0;
801054fc:	b8 00 00 00 00       	mov    $0x0,%eax
80105501:	eb 16                	jmp    80105519 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105503:	8b 45 08             	mov    0x8(%ebp),%eax
80105506:	0f b6 00             	movzbl (%eax),%eax
80105509:	0f b6 d0             	movzbl %al,%edx
8010550c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010550f:	0f b6 00             	movzbl (%eax),%eax
80105512:	0f b6 c0             	movzbl %al,%eax
80105515:	29 c2                	sub    %eax,%edx
80105517:	89 d0                	mov    %edx,%eax
}
80105519:	5d                   	pop    %ebp
8010551a:	c3                   	ret    

8010551b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010551b:	55                   	push   %ebp
8010551c:	89 e5                	mov    %esp,%ebp
8010551e:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105521:	8b 45 08             	mov    0x8(%ebp),%eax
80105524:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105527:	90                   	nop
80105528:	8b 45 10             	mov    0x10(%ebp),%eax
8010552b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010552e:	89 55 10             	mov    %edx,0x10(%ebp)
80105531:	85 c0                	test   %eax,%eax
80105533:	7e 1e                	jle    80105553 <strncpy+0x38>
80105535:	8b 45 08             	mov    0x8(%ebp),%eax
80105538:	8d 50 01             	lea    0x1(%eax),%edx
8010553b:	89 55 08             	mov    %edx,0x8(%ebp)
8010553e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105541:	8d 4a 01             	lea    0x1(%edx),%ecx
80105544:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105547:	0f b6 12             	movzbl (%edx),%edx
8010554a:	88 10                	mov    %dl,(%eax)
8010554c:	0f b6 00             	movzbl (%eax),%eax
8010554f:	84 c0                	test   %al,%al
80105551:	75 d5                	jne    80105528 <strncpy+0xd>
    ;
  while(n-- > 0)
80105553:	eb 0c                	jmp    80105561 <strncpy+0x46>
    *s++ = 0;
80105555:	8b 45 08             	mov    0x8(%ebp),%eax
80105558:	8d 50 01             	lea    0x1(%eax),%edx
8010555b:	89 55 08             	mov    %edx,0x8(%ebp)
8010555e:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105561:	8b 45 10             	mov    0x10(%ebp),%eax
80105564:	8d 50 ff             	lea    -0x1(%eax),%edx
80105567:	89 55 10             	mov    %edx,0x10(%ebp)
8010556a:	85 c0                	test   %eax,%eax
8010556c:	7f e7                	jg     80105555 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010556e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105571:	c9                   	leave  
80105572:	c3                   	ret    

80105573 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105573:	55                   	push   %ebp
80105574:	89 e5                	mov    %esp,%ebp
80105576:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010557f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105583:	7f 05                	jg     8010558a <safestrcpy+0x17>
    return os;
80105585:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105588:	eb 31                	jmp    801055bb <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010558a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010558e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105592:	7e 1e                	jle    801055b2 <safestrcpy+0x3f>
80105594:	8b 45 08             	mov    0x8(%ebp),%eax
80105597:	8d 50 01             	lea    0x1(%eax),%edx
8010559a:	89 55 08             	mov    %edx,0x8(%ebp)
8010559d:	8b 55 0c             	mov    0xc(%ebp),%edx
801055a0:	8d 4a 01             	lea    0x1(%edx),%ecx
801055a3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055a6:	0f b6 12             	movzbl (%edx),%edx
801055a9:	88 10                	mov    %dl,(%eax)
801055ab:	0f b6 00             	movzbl (%eax),%eax
801055ae:	84 c0                	test   %al,%al
801055b0:	75 d8                	jne    8010558a <safestrcpy+0x17>
    ;
  *s = 0;
801055b2:	8b 45 08             	mov    0x8(%ebp),%eax
801055b5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801055b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055bb:	c9                   	leave  
801055bc:	c3                   	ret    

801055bd <strlen>:

int
strlen(const char *s)
{
801055bd:	55                   	push   %ebp
801055be:	89 e5                	mov    %esp,%ebp
801055c0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055ca:	eb 04                	jmp    801055d0 <strlen+0x13>
801055cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055d3:	8b 45 08             	mov    0x8(%ebp),%eax
801055d6:	01 d0                	add    %edx,%eax
801055d8:	0f b6 00             	movzbl (%eax),%eax
801055db:	84 c0                	test   %al,%al
801055dd:	75 ed                	jne    801055cc <strlen+0xf>
    ;
  return n;
801055df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055e2:	c9                   	leave  
801055e3:	c3                   	ret    

801055e4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055e4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055e8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055ec:	55                   	push   %ebp
  pushl %ebx
801055ed:	53                   	push   %ebx
  pushl %esi
801055ee:	56                   	push   %esi
  pushl %edi
801055ef:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055f0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055f2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055f4:	5f                   	pop    %edi
  popl %esi
801055f5:	5e                   	pop    %esi
  popl %ebx
801055f6:	5b                   	pop    %ebx
  popl %ebp
801055f7:	5d                   	pop    %ebp
  ret
801055f8:	c3                   	ret    

801055f9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055f9:	55                   	push   %ebp
801055fa:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105602:	8b 00                	mov    (%eax),%eax
80105604:	3b 45 08             	cmp    0x8(%ebp),%eax
80105607:	76 12                	jbe    8010561b <fetchint+0x22>
80105609:	8b 45 08             	mov    0x8(%ebp),%eax
8010560c:	8d 50 04             	lea    0x4(%eax),%edx
8010560f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105615:	8b 00                	mov    (%eax),%eax
80105617:	39 c2                	cmp    %eax,%edx
80105619:	76 07                	jbe    80105622 <fetchint+0x29>
    return -1;
8010561b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105620:	eb 0f                	jmp    80105631 <fetchint+0x38>
  *ip = *(int*)(addr);
80105622:	8b 45 08             	mov    0x8(%ebp),%eax
80105625:	8b 10                	mov    (%eax),%edx
80105627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562a:	89 10                	mov    %edx,(%eax)
  return 0;
8010562c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105631:	5d                   	pop    %ebp
80105632:	c3                   	ret    

80105633 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105633:	55                   	push   %ebp
80105634:	89 e5                	mov    %esp,%ebp
80105636:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105639:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563f:	8b 00                	mov    (%eax),%eax
80105641:	3b 45 08             	cmp    0x8(%ebp),%eax
80105644:	77 07                	ja     8010564d <fetchstr+0x1a>
    return -1;
80105646:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564b:	eb 46                	jmp    80105693 <fetchstr+0x60>
  *pp = (char*)addr;
8010564d:	8b 55 08             	mov    0x8(%ebp),%edx
80105650:	8b 45 0c             	mov    0xc(%ebp),%eax
80105653:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565b:	8b 00                	mov    (%eax),%eax
8010565d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105660:	8b 45 0c             	mov    0xc(%ebp),%eax
80105663:	8b 00                	mov    (%eax),%eax
80105665:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105668:	eb 1c                	jmp    80105686 <fetchstr+0x53>
    if(*s == 0)
8010566a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566d:	0f b6 00             	movzbl (%eax),%eax
80105670:	84 c0                	test   %al,%al
80105672:	75 0e                	jne    80105682 <fetchstr+0x4f>
      return s - *pp;
80105674:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105677:	8b 45 0c             	mov    0xc(%ebp),%eax
8010567a:	8b 00                	mov    (%eax),%eax
8010567c:	29 c2                	sub    %eax,%edx
8010567e:	89 d0                	mov    %edx,%eax
80105680:	eb 11                	jmp    80105693 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105682:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105686:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105689:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010568c:	72 dc                	jb     8010566a <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010568e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105693:	c9                   	leave  
80105694:	c3                   	ret    

80105695 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105695:	55                   	push   %ebp
80105696:	89 e5                	mov    %esp,%ebp
80105698:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010569b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056a1:	8b 40 18             	mov    0x18(%eax),%eax
801056a4:	8b 50 44             	mov    0x44(%eax),%edx
801056a7:	8b 45 08             	mov    0x8(%ebp),%eax
801056aa:	c1 e0 02             	shl    $0x2,%eax
801056ad:	01 d0                	add    %edx,%eax
801056af:	8d 50 04             	lea    0x4(%eax),%edx
801056b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801056b9:	89 14 24             	mov    %edx,(%esp)
801056bc:	e8 38 ff ff ff       	call   801055f9 <fetchint>
}
801056c1:	c9                   	leave  
801056c2:	c3                   	ret    

801056c3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056c3:	55                   	push   %ebp
801056c4:	89 e5                	mov    %esp,%ebp
801056c6:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801056c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	89 04 24             	mov    %eax,(%esp)
801056d6:	e8 ba ff ff ff       	call   80105695 <argint>
801056db:	85 c0                	test   %eax,%eax
801056dd:	79 07                	jns    801056e6 <argptr+0x23>
    return -1;
801056df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e4:	eb 3d                	jmp    80105723 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e9:	89 c2                	mov    %eax,%edx
801056eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f1:	8b 00                	mov    (%eax),%eax
801056f3:	39 c2                	cmp    %eax,%edx
801056f5:	73 16                	jae    8010570d <argptr+0x4a>
801056f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056fa:	89 c2                	mov    %eax,%edx
801056fc:	8b 45 10             	mov    0x10(%ebp),%eax
801056ff:	01 c2                	add    %eax,%edx
80105701:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105707:	8b 00                	mov    (%eax),%eax
80105709:	39 c2                	cmp    %eax,%edx
8010570b:	76 07                	jbe    80105714 <argptr+0x51>
    return -1;
8010570d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105712:	eb 0f                	jmp    80105723 <argptr+0x60>
  *pp = (char*)i;
80105714:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105717:	89 c2                	mov    %eax,%edx
80105719:	8b 45 0c             	mov    0xc(%ebp),%eax
8010571c:	89 10                	mov    %edx,(%eax)
  return 0;
8010571e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105723:	c9                   	leave  
80105724:	c3                   	ret    

80105725 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105725:	55                   	push   %ebp
80105726:	89 e5                	mov    %esp,%ebp
80105728:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010572b:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010572e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105732:	8b 45 08             	mov    0x8(%ebp),%eax
80105735:	89 04 24             	mov    %eax,(%esp)
80105738:	e8 58 ff ff ff       	call   80105695 <argint>
8010573d:	85 c0                	test   %eax,%eax
8010573f:	79 07                	jns    80105748 <argstr+0x23>
    return -1;
80105741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105746:	eb 12                	jmp    8010575a <argstr+0x35>
  return fetchstr(addr, pp);
80105748:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010574b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010574e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105752:	89 04 24             	mov    %eax,(%esp)
80105755:	e8 d9 fe ff ff       	call   80105633 <fetchstr>
}
8010575a:	c9                   	leave  
8010575b:	c3                   	ret    

8010575c <syscall>:
};
#endif

void
syscall(void)
{
8010575c:	55                   	push   %ebp
8010575d:	89 e5                	mov    %esp,%ebp
8010575f:	53                   	push   %ebx
80105760:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105769:	8b 40 18             	mov    0x18(%eax),%eax
8010576c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010576f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105772:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105776:	7e 30                	jle    801057a8 <syscall+0x4c>
80105778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577b:	83 f8 1d             	cmp    $0x1d,%eax
8010577e:	77 28                	ja     801057a8 <syscall+0x4c>
80105780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105783:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010578a:	85 c0                	test   %eax,%eax
8010578c:	74 1a                	je     801057a8 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010578e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105794:	8b 58 18             	mov    0x18(%eax),%ebx
80105797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579a:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057a1:	ff d0                	call   *%eax
801057a3:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057a6:	eb 3d                	jmp    801057e5 <syscall+0x89>
#ifdef PRINT_SYSCALLS
	cprintf("%s -> %d\n", print_syscalls[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801057a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ae:	8d 48 6c             	lea    0x6c(%eax),%ecx
801057b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
	cprintf("%s -> %d\n", print_syscalls[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801057b7:	8b 40 10             	mov    0x10(%eax),%eax
801057ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
801057c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c9:	c7 04 24 16 8d 10 80 	movl   $0x80108d16,(%esp)
801057d0:	e8 cb ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801057d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057db:	8b 40 18             	mov    0x18(%eax),%eax
801057de:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057e5:	83 c4 24             	add    $0x24,%esp
801057e8:	5b                   	pop    %ebx
801057e9:	5d                   	pop    %ebp
801057ea:	c3                   	ret    

801057eb <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057eb:	55                   	push   %ebp
801057ec:	89 e5                	mov    %esp,%ebp
801057ee:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801057f8:	8b 45 08             	mov    0x8(%ebp),%eax
801057fb:	89 04 24             	mov    %eax,(%esp)
801057fe:	e8 92 fe ff ff       	call   80105695 <argint>
80105803:	85 c0                	test   %eax,%eax
80105805:	79 07                	jns    8010580e <argfd+0x23>
    return -1;
80105807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580c:	eb 50                	jmp    8010585e <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010580e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105811:	85 c0                	test   %eax,%eax
80105813:	78 21                	js     80105836 <argfd+0x4b>
80105815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105818:	83 f8 0f             	cmp    $0xf,%eax
8010581b:	7f 19                	jg     80105836 <argfd+0x4b>
8010581d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105826:	83 c2 08             	add    $0x8,%edx
80105829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010582d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105830:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105834:	75 07                	jne    8010583d <argfd+0x52>
    return -1;
80105836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583b:	eb 21                	jmp    8010585e <argfd+0x73>
  if(pfd)
8010583d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105841:	74 08                	je     8010584b <argfd+0x60>
    *pfd = fd;
80105843:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105846:	8b 45 0c             	mov    0xc(%ebp),%eax
80105849:	89 10                	mov    %edx,(%eax)
  if(pf)
8010584b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010584f:	74 08                	je     80105859 <argfd+0x6e>
    *pf = f;
80105851:	8b 45 10             	mov    0x10(%ebp),%eax
80105854:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105857:	89 10                	mov    %edx,(%eax)
  return 0;
80105859:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010585e:	c9                   	leave  
8010585f:	c3                   	ret    

80105860 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105866:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010586d:	eb 30                	jmp    8010589f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010586f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105875:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105878:	83 c2 08             	add    $0x8,%edx
8010587b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010587f:	85 c0                	test   %eax,%eax
80105881:	75 18                	jne    8010589b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105883:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105889:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010588c:	8d 4a 08             	lea    0x8(%edx),%ecx
8010588f:	8b 55 08             	mov    0x8(%ebp),%edx
80105892:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105896:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105899:	eb 0f                	jmp    801058aa <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010589b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010589f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801058a3:	7e ca                	jle    8010586f <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801058a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058aa:	c9                   	leave  
801058ab:	c3                   	ret    

801058ac <sys_dup>:

int
sys_dup(void)
{
801058ac:	55                   	push   %ebp
801058ad:	89 e5                	mov    %esp,%ebp
801058af:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801058b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058b5:	89 44 24 08          	mov    %eax,0x8(%esp)
801058b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058c0:	00 
801058c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058c8:	e8 1e ff ff ff       	call   801057eb <argfd>
801058cd:	85 c0                	test   %eax,%eax
801058cf:	79 07                	jns    801058d8 <sys_dup+0x2c>
    return -1;
801058d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d6:	eb 29                	jmp    80105901 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058db:	89 04 24             	mov    %eax,(%esp)
801058de:	e8 7d ff ff ff       	call   80105860 <fdalloc>
801058e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ea:	79 07                	jns    801058f3 <sys_dup+0x47>
    return -1;
801058ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f1:	eb 0e                	jmp    80105901 <sys_dup+0x55>
  filedup(f);
801058f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f6:	89 04 24             	mov    %eax,(%esp)
801058f9:	e8 a3 b6 ff ff       	call   80100fa1 <filedup>
  return fd;
801058fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105901:	c9                   	leave  
80105902:	c3                   	ret    

80105903 <sys_read>:

int
sys_read(void)
{
80105903:	55                   	push   %ebp
80105904:	89 e5                	mov    %esp,%ebp
80105906:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105909:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010590c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105910:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105917:	00 
80105918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010591f:	e8 c7 fe ff ff       	call   801057eb <argfd>
80105924:	85 c0                	test   %eax,%eax
80105926:	78 35                	js     8010595d <sys_read+0x5a>
80105928:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010592f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105936:	e8 5a fd ff ff       	call   80105695 <argint>
8010593b:	85 c0                	test   %eax,%eax
8010593d:	78 1e                	js     8010595d <sys_read+0x5a>
8010593f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105942:	89 44 24 08          	mov    %eax,0x8(%esp)
80105946:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105949:	89 44 24 04          	mov    %eax,0x4(%esp)
8010594d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105954:	e8 6a fd ff ff       	call   801056c3 <argptr>
80105959:	85 c0                	test   %eax,%eax
8010595b:	79 07                	jns    80105964 <sys_read+0x61>
    return -1;
8010595d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105962:	eb 19                	jmp    8010597d <sys_read+0x7a>
  return fileread(f, p, n);
80105964:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105967:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010596a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105971:	89 54 24 04          	mov    %edx,0x4(%esp)
80105975:	89 04 24             	mov    %eax,(%esp)
80105978:	e8 91 b7 ff ff       	call   8010110e <fileread>
}
8010597d:	c9                   	leave  
8010597e:	c3                   	ret    

8010597f <sys_write>:

int
sys_write(void)
{
8010597f:	55                   	push   %ebp
80105980:	89 e5                	mov    %esp,%ebp
80105982:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105985:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105988:	89 44 24 08          	mov    %eax,0x8(%esp)
8010598c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105993:	00 
80105994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010599b:	e8 4b fe ff ff       	call   801057eb <argfd>
801059a0:	85 c0                	test   %eax,%eax
801059a2:	78 35                	js     801059d9 <sys_write+0x5a>
801059a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059b2:	e8 de fc ff ff       	call   80105695 <argint>
801059b7:	85 c0                	test   %eax,%eax
801059b9:	78 1e                	js     801059d9 <sys_write+0x5a>
801059bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059be:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059d0:	e8 ee fc ff ff       	call   801056c3 <argptr>
801059d5:	85 c0                	test   %eax,%eax
801059d7:	79 07                	jns    801059e0 <sys_write+0x61>
    return -1;
801059d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059de:	eb 19                	jmp    801059f9 <sys_write+0x7a>
  return filewrite(f, p, n);
801059e0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801059f1:	89 04 24             	mov    %eax,(%esp)
801059f4:	e8 d1 b7 ff ff       	call   801011ca <filewrite>
}
801059f9:	c9                   	leave  
801059fa:	c3                   	ret    

801059fb <sys_close>:

int
sys_close(void)
{
801059fb:	55                   	push   %ebp
801059fc:	89 e5                	mov    %esp,%ebp
801059fe:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a01:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a04:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a08:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a16:	e8 d0 fd ff ff       	call   801057eb <argfd>
80105a1b:	85 c0                	test   %eax,%eax
80105a1d:	79 07                	jns    80105a26 <sys_close+0x2b>
    return -1;
80105a1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a24:	eb 24                	jmp    80105a4a <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a2f:	83 c2 08             	add    $0x8,%edx
80105a32:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a39:	00 
  fileclose(f);
80105a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3d:	89 04 24             	mov    %eax,(%esp)
80105a40:	e8 a4 b5 ff ff       	call   80100fe9 <fileclose>
  return 0;
80105a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a4a:	c9                   	leave  
80105a4b:	c3                   	ret    

80105a4c <sys_fstat>:

int
sys_fstat(void)
{
80105a4c:	55                   	push   %ebp
80105a4d:	89 e5                	mov    %esp,%ebp
80105a4f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a55:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a60:	00 
80105a61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a68:	e8 7e fd ff ff       	call   801057eb <argfd>
80105a6d:	85 c0                	test   %eax,%eax
80105a6f:	78 1f                	js     80105a90 <sys_fstat+0x44>
80105a71:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a78:	00 
80105a79:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a87:	e8 37 fc ff ff       	call   801056c3 <argptr>
80105a8c:	85 c0                	test   %eax,%eax
80105a8e:	79 07                	jns    80105a97 <sys_fstat+0x4b>
    return -1;
80105a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a95:	eb 12                	jmp    80105aa9 <sys_fstat+0x5d>
  return filestat(f, st);
80105a97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aa1:	89 04 24             	mov    %eax,(%esp)
80105aa4:	e8 16 b6 ff ff       	call   801010bf <filestat>
}
80105aa9:	c9                   	leave  
80105aaa:	c3                   	ret    

80105aab <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105aab:	55                   	push   %ebp
80105aac:	89 e5                	mov    %esp,%ebp
80105aae:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ab1:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105abf:	e8 61 fc ff ff       	call   80105725 <argstr>
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	78 17                	js     80105adf <sys_link+0x34>
80105ac8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105acb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ad6:	e8 4a fc ff ff       	call   80105725 <argstr>
80105adb:	85 c0                	test   %eax,%eax
80105add:	79 0a                	jns    80105ae9 <sys_link+0x3e>
    return -1;
80105adf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae4:	e9 42 01 00 00       	jmp    80105c2b <sys_link+0x180>

  begin_op();
80105ae9:	e8 ce d9 ff ff       	call   801034bc <begin_op>
  if((ip = namei(old)) == 0){
80105aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105af1:	89 04 24             	mov    %eax,(%esp)
80105af4:	e8 8c c9 ff ff       	call   80102485 <namei>
80105af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b00:	75 0f                	jne    80105b11 <sys_link+0x66>
    end_op();
80105b02:	e8 39 da ff ff       	call   80103540 <end_op>
    return -1;
80105b07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0c:	e9 1a 01 00 00       	jmp    80105c2b <sys_link+0x180>
  }

  ilock(ip);
80105b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b14:	89 04 24             	mov    %eax,(%esp)
80105b17:	e8 b8 bd ff ff       	call   801018d4 <ilock>
  if(ip->type == T_DIR){
80105b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b23:	66 83 f8 01          	cmp    $0x1,%ax
80105b27:	75 1a                	jne    80105b43 <sys_link+0x98>
    iunlockput(ip);
80105b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2c:	89 04 24             	mov    %eax,(%esp)
80105b2f:	e8 2a c0 ff ff       	call   80101b5e <iunlockput>
    end_op();
80105b34:	e8 07 da ff ff       	call   80103540 <end_op>
    return -1;
80105b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3e:	e9 e8 00 00 00       	jmp    80105c2b <sys_link+0x180>
  }

  ip->nlink++;
80105b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b46:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b4a:	8d 50 01             	lea    0x1(%eax),%edx
80105b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b50:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	89 04 24             	mov    %eax,(%esp)
80105b5a:	e8 b3 bb ff ff       	call   80101712 <iupdate>
  iunlock(ip);
80105b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b62:	89 04 24             	mov    %eax,(%esp)
80105b65:	e8 be be ff ff       	call   80101a28 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b6d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b70:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b74:	89 04 24             	mov    %eax,(%esp)
80105b77:	e8 2b c9 ff ff       	call   801024a7 <nameiparent>
80105b7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b83:	75 02                	jne    80105b87 <sys_link+0xdc>
    goto bad;
80105b85:	eb 68                	jmp    80105bef <sys_link+0x144>
  ilock(dp);
80105b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8a:	89 04 24             	mov    %eax,(%esp)
80105b8d:	e8 42 bd ff ff       	call   801018d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b95:	8b 10                	mov    (%eax),%edx
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	8b 00                	mov    (%eax),%eax
80105b9c:	39 c2                	cmp    %eax,%edx
80105b9e:	75 20                	jne    80105bc0 <sys_link+0x115>
80105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba3:	8b 40 04             	mov    0x4(%eax),%eax
80105ba6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105baa:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105bad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb4:	89 04 24             	mov    %eax,(%esp)
80105bb7:	e8 09 c6 ff ff       	call   801021c5 <dirlink>
80105bbc:	85 c0                	test   %eax,%eax
80105bbe:	79 0d                	jns    80105bcd <sys_link+0x122>
    iunlockput(dp);
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	89 04 24             	mov    %eax,(%esp)
80105bc6:	e8 93 bf ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105bcb:	eb 22                	jmp    80105bef <sys_link+0x144>
  }
  iunlockput(dp);
80105bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd0:	89 04 24             	mov    %eax,(%esp)
80105bd3:	e8 86 bf ff ff       	call   80101b5e <iunlockput>
  iput(ip);
80105bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdb:	89 04 24             	mov    %eax,(%esp)
80105bde:	e8 aa be ff ff       	call   80101a8d <iput>

  end_op();
80105be3:	e8 58 d9 ff ff       	call   80103540 <end_op>

  return 0;
80105be8:	b8 00 00 00 00       	mov    $0x0,%eax
80105bed:	eb 3c                	jmp    80105c2b <sys_link+0x180>

bad:
  ilock(ip);
80105bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf2:	89 04 24             	mov    %eax,(%esp)
80105bf5:	e8 da bc ff ff       	call   801018d4 <ilock>
  ip->nlink--;
80105bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c01:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c07:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0e:	89 04 24             	mov    %eax,(%esp)
80105c11:	e8 fc ba ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c19:	89 04 24             	mov    %eax,(%esp)
80105c1c:	e8 3d bf ff ff       	call   80101b5e <iunlockput>
  end_op();
80105c21:	e8 1a d9 ff ff       	call   80103540 <end_op>
  return -1;
80105c26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c2b:	c9                   	leave  
80105c2c:	c3                   	ret    

80105c2d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c2d:	55                   	push   %ebp
80105c2e:	89 e5                	mov    %esp,%ebp
80105c30:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c33:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c3a:	eb 4b                	jmp    80105c87 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c46:	00 
80105c47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c52:	8b 45 08             	mov    0x8(%ebp),%eax
80105c55:	89 04 24             	mov    %eax,(%esp)
80105c58:	e8 8a c1 ff ff       	call   80101de7 <readi>
80105c5d:	83 f8 10             	cmp    $0x10,%eax
80105c60:	74 0c                	je     80105c6e <isdirempty+0x41>
      panic("isdirempty: readi");
80105c62:	c7 04 24 32 8d 10 80 	movl   $0x80108d32,(%esp)
80105c69:	e8 cc a8 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105c6e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c72:	66 85 c0             	test   %ax,%ax
80105c75:	74 07                	je     80105c7e <isdirempty+0x51>
      return 0;
80105c77:	b8 00 00 00 00       	mov    $0x0,%eax
80105c7c:	eb 1b                	jmp    80105c99 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c81:	83 c0 10             	add    $0x10,%eax
80105c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c8d:	8b 40 18             	mov    0x18(%eax),%eax
80105c90:	39 c2                	cmp    %eax,%edx
80105c92:	72 a8                	jb     80105c3c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c94:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c99:	c9                   	leave  
80105c9a:	c3                   	ret    

80105c9b <sys_unlink>:

int
sys_unlink(void)
{
80105c9b:	55                   	push   %ebp
80105c9c:	89 e5                	mov    %esp,%ebp
80105c9e:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ca1:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105caf:	e8 71 fa ff ff       	call   80105725 <argstr>
80105cb4:	85 c0                	test   %eax,%eax
80105cb6:	79 0a                	jns    80105cc2 <sys_unlink+0x27>
    return -1;
80105cb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbd:	e9 af 01 00 00       	jmp    80105e71 <sys_unlink+0x1d6>

  begin_op();
80105cc2:	e8 f5 d7 ff ff       	call   801034bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105cc7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105cca:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ccd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cd1:	89 04 24             	mov    %eax,(%esp)
80105cd4:	e8 ce c7 ff ff       	call   801024a7 <nameiparent>
80105cd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ce0:	75 0f                	jne    80105cf1 <sys_unlink+0x56>
    end_op();
80105ce2:	e8 59 d8 ff ff       	call   80103540 <end_op>
    return -1;
80105ce7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cec:	e9 80 01 00 00       	jmp    80105e71 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf4:	89 04 24             	mov    %eax,(%esp)
80105cf7:	e8 d8 bb ff ff       	call   801018d4 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cfc:	c7 44 24 04 44 8d 10 	movl   $0x80108d44,0x4(%esp)
80105d03:	80 
80105d04:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d07:	89 04 24             	mov    %eax,(%esp)
80105d0a:	e8 cb c3 ff ff       	call   801020da <namecmp>
80105d0f:	85 c0                	test   %eax,%eax
80105d11:	0f 84 45 01 00 00    	je     80105e5c <sys_unlink+0x1c1>
80105d17:	c7 44 24 04 46 8d 10 	movl   $0x80108d46,0x4(%esp)
80105d1e:	80 
80105d1f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d22:	89 04 24             	mov    %eax,(%esp)
80105d25:	e8 b0 c3 ff ff       	call   801020da <namecmp>
80105d2a:	85 c0                	test   %eax,%eax
80105d2c:	0f 84 2a 01 00 00    	je     80105e5c <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d32:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d35:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d39:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d43:	89 04 24             	mov    %eax,(%esp)
80105d46:	e8 b1 c3 ff ff       	call   801020fc <dirlookup>
80105d4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d52:	75 05                	jne    80105d59 <sys_unlink+0xbe>
    goto bad;
80105d54:	e9 03 01 00 00       	jmp    80105e5c <sys_unlink+0x1c1>
  ilock(ip);
80105d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5c:	89 04 24             	mov    %eax,(%esp)
80105d5f:	e8 70 bb ff ff       	call   801018d4 <ilock>

  if(ip->nlink < 1)
80105d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d67:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d6b:	66 85 c0             	test   %ax,%ax
80105d6e:	7f 0c                	jg     80105d7c <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d70:	c7 04 24 49 8d 10 80 	movl   $0x80108d49,(%esp)
80105d77:	e8 be a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d83:	66 83 f8 01          	cmp    $0x1,%ax
80105d87:	75 1f                	jne    80105da8 <sys_unlink+0x10d>
80105d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8c:	89 04 24             	mov    %eax,(%esp)
80105d8f:	e8 99 fe ff ff       	call   80105c2d <isdirempty>
80105d94:	85 c0                	test   %eax,%eax
80105d96:	75 10                	jne    80105da8 <sys_unlink+0x10d>
    iunlockput(ip);
80105d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9b:	89 04 24             	mov    %eax,(%esp)
80105d9e:	e8 bb bd ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105da3:	e9 b4 00 00 00       	jmp    80105e5c <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105da8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105daf:	00 
80105db0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105db7:	00 
80105db8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dbb:	89 04 24             	mov    %eax,(%esp)
80105dbe:	e8 90 f5 ff ff       	call   80105353 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dc3:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dc6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105dcd:	00 
80105dce:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd2:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	89 04 24             	mov    %eax,(%esp)
80105ddf:	e8 67 c1 ff ff       	call   80101f4b <writei>
80105de4:	83 f8 10             	cmp    $0x10,%eax
80105de7:	74 0c                	je     80105df5 <sys_unlink+0x15a>
    panic("unlink: writei");
80105de9:	c7 04 24 5b 8d 10 80 	movl   $0x80108d5b,(%esp)
80105df0:	e8 45 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dfc:	66 83 f8 01          	cmp    $0x1,%ax
80105e00:	75 1c                	jne    80105e1e <sys_unlink+0x183>
    dp->nlink--;
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e09:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e16:	89 04 24             	mov    %eax,(%esp)
80105e19:	e8 f4 b8 ff ff       	call   80101712 <iupdate>
  }
  iunlockput(dp);
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	89 04 24             	mov    %eax,(%esp)
80105e24:	e8 35 bd ff ff       	call   80101b5e <iunlockput>

  ip->nlink--;
80105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e30:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e36:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3d:	89 04 24             	mov    %eax,(%esp)
80105e40:	e8 cd b8 ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e48:	89 04 24             	mov    %eax,(%esp)
80105e4b:	e8 0e bd ff ff       	call   80101b5e <iunlockput>

  end_op();
80105e50:	e8 eb d6 ff ff       	call   80103540 <end_op>

  return 0;
80105e55:	b8 00 00 00 00       	mov    $0x0,%eax
80105e5a:	eb 15                	jmp    80105e71 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5f:	89 04 24             	mov    %eax,(%esp)
80105e62:	e8 f7 bc ff ff       	call   80101b5e <iunlockput>
  end_op();
80105e67:	e8 d4 d6 ff ff       	call   80103540 <end_op>
  return -1;
80105e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e71:	c9                   	leave  
80105e72:	c3                   	ret    

80105e73 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e73:	55                   	push   %ebp
80105e74:	89 e5                	mov    %esp,%ebp
80105e76:	83 ec 48             	sub    $0x48,%esp
80105e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e7c:	8b 55 10             	mov    0x10(%ebp),%edx
80105e7f:	8b 45 14             	mov    0x14(%ebp),%eax
80105e82:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e86:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e8a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e8e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e95:	8b 45 08             	mov    0x8(%ebp),%eax
80105e98:	89 04 24             	mov    %eax,(%esp)
80105e9b:	e8 07 c6 ff ff       	call   801024a7 <nameiparent>
80105ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ea3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea7:	75 0a                	jne    80105eb3 <create+0x40>
    return 0;
80105ea9:	b8 00 00 00 00       	mov    $0x0,%eax
80105eae:	e9 7e 01 00 00       	jmp    80106031 <create+0x1be>
  ilock(dp);
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 16 ba ff ff       	call   801018d4 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ebe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ec5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecf:	89 04 24             	mov    %eax,(%esp)
80105ed2:	e8 25 c2 ff ff       	call   801020fc <dirlookup>
80105ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ede:	74 47                	je     80105f27 <create+0xb4>
    iunlockput(dp);
80105ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee3:	89 04 24             	mov    %eax,(%esp)
80105ee6:	e8 73 bc ff ff       	call   80101b5e <iunlockput>
    ilock(ip);
80105eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eee:	89 04 24             	mov    %eax,(%esp)
80105ef1:	e8 de b9 ff ff       	call   801018d4 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ef6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105efb:	75 15                	jne    80105f12 <create+0x9f>
80105efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f00:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f04:	66 83 f8 02          	cmp    $0x2,%ax
80105f08:	75 08                	jne    80105f12 <create+0x9f>
      return ip;
80105f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0d:	e9 1f 01 00 00       	jmp    80106031 <create+0x1be>
    iunlockput(ip);
80105f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f15:	89 04 24             	mov    %eax,(%esp)
80105f18:	e8 41 bc ff ff       	call   80101b5e <iunlockput>
    return 0;
80105f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80105f22:	e9 0a 01 00 00       	jmp    80106031 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f27:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2e:	8b 00                	mov    (%eax),%eax
80105f30:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f34:	89 04 24             	mov    %eax,(%esp)
80105f37:	e8 01 b7 ff ff       	call   8010163d <ialloc>
80105f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f43:	75 0c                	jne    80105f51 <create+0xde>
    panic("create: ialloc");
80105f45:	c7 04 24 6a 8d 10 80 	movl   $0x80108d6a,(%esp)
80105f4c:	e8 e9 a5 ff ff       	call   8010053a <panic>

  ilock(ip);
80105f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f54:	89 04 24             	mov    %eax,(%esp)
80105f57:	e8 78 b9 ff ff       	call   801018d4 <ilock>
  ip->major = major;
80105f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f63:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f6e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f75:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7e:	89 04 24             	mov    %eax,(%esp)
80105f81:	e8 8c b7 ff ff       	call   80101712 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f86:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f8b:	75 6a                	jne    80105ff7 <create+0x184>
    dp->nlink++;  // for ".."
80105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f90:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f94:	8d 50 01             	lea    0x1(%eax),%edx
80105f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa1:	89 04 24             	mov    %eax,(%esp)
80105fa4:	e8 69 b7 ff ff       	call   80101712 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fac:	8b 40 04             	mov    0x4(%eax),%eax
80105faf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fb3:	c7 44 24 04 44 8d 10 	movl   $0x80108d44,0x4(%esp)
80105fba:	80 
80105fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbe:	89 04 24             	mov    %eax,(%esp)
80105fc1:	e8 ff c1 ff ff       	call   801021c5 <dirlink>
80105fc6:	85 c0                	test   %eax,%eax
80105fc8:	78 21                	js     80105feb <create+0x178>
80105fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcd:	8b 40 04             	mov    0x4(%eax),%eax
80105fd0:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fd4:	c7 44 24 04 46 8d 10 	movl   $0x80108d46,0x4(%esp)
80105fdb:	80 
80105fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdf:	89 04 24             	mov    %eax,(%esp)
80105fe2:	e8 de c1 ff ff       	call   801021c5 <dirlink>
80105fe7:	85 c0                	test   %eax,%eax
80105fe9:	79 0c                	jns    80105ff7 <create+0x184>
      panic("create dots");
80105feb:	c7 04 24 79 8d 10 80 	movl   $0x80108d79,(%esp)
80105ff2:	e8 43 a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffa:	8b 40 04             	mov    0x4(%eax),%eax
80105ffd:	89 44 24 08          	mov    %eax,0x8(%esp)
80106001:	8d 45 de             	lea    -0x22(%ebp),%eax
80106004:	89 44 24 04          	mov    %eax,0x4(%esp)
80106008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600b:	89 04 24             	mov    %eax,(%esp)
8010600e:	e8 b2 c1 ff ff       	call   801021c5 <dirlink>
80106013:	85 c0                	test   %eax,%eax
80106015:	79 0c                	jns    80106023 <create+0x1b0>
    panic("create: dirlink");
80106017:	c7 04 24 85 8d 10 80 	movl   $0x80108d85,(%esp)
8010601e:	e8 17 a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106026:	89 04 24             	mov    %eax,(%esp)
80106029:	e8 30 bb ff ff       	call   80101b5e <iunlockput>

  return ip;
8010602e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106031:	c9                   	leave  
80106032:	c3                   	ret    

80106033 <sys_open>:

int
sys_open(void)
{
80106033:	55                   	push   %ebp
80106034:	89 e5                	mov    %esp,%ebp
80106036:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106039:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010603c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106047:	e8 d9 f6 ff ff       	call   80105725 <argstr>
8010604c:	85 c0                	test   %eax,%eax
8010604e:	78 17                	js     80106067 <sys_open+0x34>
80106050:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106053:	89 44 24 04          	mov    %eax,0x4(%esp)
80106057:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010605e:	e8 32 f6 ff ff       	call   80105695 <argint>
80106063:	85 c0                	test   %eax,%eax
80106065:	79 0a                	jns    80106071 <sys_open+0x3e>
    return -1;
80106067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606c:	e9 5c 01 00 00       	jmp    801061cd <sys_open+0x19a>

  begin_op();
80106071:	e8 46 d4 ff ff       	call   801034bc <begin_op>

  if(omode & O_CREATE){
80106076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106079:	25 00 02 00 00       	and    $0x200,%eax
8010607e:	85 c0                	test   %eax,%eax
80106080:	74 3b                	je     801060bd <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106082:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106085:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010608c:	00 
8010608d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106094:	00 
80106095:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010609c:	00 
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 ce fd ff ff       	call   80105e73 <create>
801060a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801060a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ac:	75 6b                	jne    80106119 <sys_open+0xe6>
      end_op();
801060ae:	e8 8d d4 ff ff       	call   80103540 <end_op>
      return -1;
801060b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b8:	e9 10 01 00 00       	jmp    801061cd <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
801060bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060c0:	89 04 24             	mov    %eax,(%esp)
801060c3:	e8 bd c3 ff ff       	call   80102485 <namei>
801060c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060cf:	75 0f                	jne    801060e0 <sys_open+0xad>
      end_op();
801060d1:	e8 6a d4 ff ff       	call   80103540 <end_op>
      return -1;
801060d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060db:	e9 ed 00 00 00       	jmp    801061cd <sys_open+0x19a>
    }
    ilock(ip);
801060e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e3:	89 04 24             	mov    %eax,(%esp)
801060e6:	e8 e9 b7 ff ff       	call   801018d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ee:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060f2:	66 83 f8 01          	cmp    $0x1,%ax
801060f6:	75 21                	jne    80106119 <sys_open+0xe6>
801060f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060fb:	85 c0                	test   %eax,%eax
801060fd:	74 1a                	je     80106119 <sys_open+0xe6>
      iunlockput(ip);
801060ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106102:	89 04 24             	mov    %eax,(%esp)
80106105:	e8 54 ba ff ff       	call   80101b5e <iunlockput>
      end_op();
8010610a:	e8 31 d4 ff ff       	call   80103540 <end_op>
      return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	e9 b4 00 00 00       	jmp    801061cd <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106119:	e8 23 ae ff ff       	call   80100f41 <filealloc>
8010611e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106121:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106125:	74 14                	je     8010613b <sys_open+0x108>
80106127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612a:	89 04 24             	mov    %eax,(%esp)
8010612d:	e8 2e f7 ff ff       	call   80105860 <fdalloc>
80106132:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106135:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106139:	79 28                	jns    80106163 <sys_open+0x130>
    if(f)
8010613b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010613f:	74 0b                	je     8010614c <sys_open+0x119>
      fileclose(f);
80106141:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106144:	89 04 24             	mov    %eax,(%esp)
80106147:	e8 9d ae ff ff       	call   80100fe9 <fileclose>
    iunlockput(ip);
8010614c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614f:	89 04 24             	mov    %eax,(%esp)
80106152:	e8 07 ba ff ff       	call   80101b5e <iunlockput>
    end_op();
80106157:	e8 e4 d3 ff ff       	call   80103540 <end_op>
    return -1;
8010615c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106161:	eb 6a                	jmp    801061cd <sys_open+0x19a>
  }
  iunlock(ip);
80106163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 ba b8 ff ff       	call   80101a28 <iunlock>
  end_op();
8010616e:	e8 cd d3 ff ff       	call   80103540 <end_op>

  f->type = FD_INODE;
80106173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106176:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010617c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106182:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106188:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010618f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106192:	83 e0 01             	and    $0x1,%eax
80106195:	85 c0                	test   %eax,%eax
80106197:	0f 94 c0             	sete   %al
8010619a:	89 c2                	mov    %eax,%edx
8010619c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a5:	83 e0 01             	and    $0x1,%eax
801061a8:	85 c0                	test   %eax,%eax
801061aa:	75 0a                	jne    801061b6 <sys_open+0x183>
801061ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061af:	83 e0 02             	and    $0x2,%eax
801061b2:	85 c0                	test   %eax,%eax
801061b4:	74 07                	je     801061bd <sys_open+0x18a>
801061b6:	b8 01 00 00 00       	mov    $0x1,%eax
801061bb:	eb 05                	jmp    801061c2 <sys_open+0x18f>
801061bd:	b8 00 00 00 00       	mov    $0x0,%eax
801061c2:	89 c2                	mov    %eax,%edx
801061c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c7:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061cd:	c9                   	leave  
801061ce:	c3                   	ret    

801061cf <sys_mkdir>:

int
sys_mkdir(void)
{
801061cf:	55                   	push   %ebp
801061d0:	89 e5                	mov    %esp,%ebp
801061d2:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061d5:	e8 e2 d2 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801061e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061e8:	e8 38 f5 ff ff       	call   80105725 <argstr>
801061ed:	85 c0                	test   %eax,%eax
801061ef:	78 2c                	js     8010621d <sys_mkdir+0x4e>
801061f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061fb:	00 
801061fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106203:	00 
80106204:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010620b:	00 
8010620c:	89 04 24             	mov    %eax,(%esp)
8010620f:	e8 5f fc ff ff       	call   80105e73 <create>
80106214:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106217:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010621b:	75 0c                	jne    80106229 <sys_mkdir+0x5a>
    end_op();
8010621d:	e8 1e d3 ff ff       	call   80103540 <end_op>
    return -1;
80106222:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106227:	eb 15                	jmp    8010623e <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622c:	89 04 24             	mov    %eax,(%esp)
8010622f:	e8 2a b9 ff ff       	call   80101b5e <iunlockput>
  end_op();
80106234:	e8 07 d3 ff ff       	call   80103540 <end_op>
  return 0;
80106239:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623e:	c9                   	leave  
8010623f:	c3                   	ret    

80106240 <sys_mknod>:

int
sys_mknod(void)
{
80106240:	55                   	push   %ebp
80106241:	89 e5                	mov    %esp,%ebp
80106243:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106246:	e8 71 d2 ff ff       	call   801034bc <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010624b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010624e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106252:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106259:	e8 c7 f4 ff ff       	call   80105725 <argstr>
8010625e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106261:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106265:	78 5e                	js     801062c5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106267:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010626a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010626e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106275:	e8 1b f4 ff ff       	call   80105695 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010627a:	85 c0                	test   %eax,%eax
8010627c:	78 47                	js     801062c5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010627e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106281:	89 44 24 04          	mov    %eax,0x4(%esp)
80106285:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010628c:	e8 04 f4 ff ff       	call   80105695 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106291:	85 c0                	test   %eax,%eax
80106293:	78 30                	js     801062c5 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106298:	0f bf c8             	movswl %ax,%ecx
8010629b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010629e:	0f bf d0             	movswl %ax,%edx
801062a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801062a8:	89 54 24 08          	mov    %edx,0x8(%esp)
801062ac:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801062b3:	00 
801062b4:	89 04 24             	mov    %eax,(%esp)
801062b7:	e8 b7 fb ff ff       	call   80105e73 <create>
801062bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062c3:	75 0c                	jne    801062d1 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801062c5:	e8 76 d2 ff ff       	call   80103540 <end_op>
    return -1;
801062ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062cf:	eb 15                	jmp    801062e6 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801062d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d4:	89 04 24             	mov    %eax,(%esp)
801062d7:	e8 82 b8 ff ff       	call   80101b5e <iunlockput>
  end_op();
801062dc:	e8 5f d2 ff ff       	call   80103540 <end_op>
  return 0;
801062e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e6:	c9                   	leave  
801062e7:	c3                   	ret    

801062e8 <sys_chdir>:

int
sys_chdir(void)
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062ee:	e8 c9 d1 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106301:	e8 1f f4 ff ff       	call   80105725 <argstr>
80106306:	85 c0                	test   %eax,%eax
80106308:	78 14                	js     8010631e <sys_chdir+0x36>
8010630a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630d:	89 04 24             	mov    %eax,(%esp)
80106310:	e8 70 c1 ff ff       	call   80102485 <namei>
80106315:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106318:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631c:	75 0c                	jne    8010632a <sys_chdir+0x42>
    end_op();
8010631e:	e8 1d d2 ff ff       	call   80103540 <end_op>
    return -1;
80106323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106328:	eb 61                	jmp    8010638b <sys_chdir+0xa3>
  }
  ilock(ip);
8010632a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632d:	89 04 24             	mov    %eax,(%esp)
80106330:	e8 9f b5 ff ff       	call   801018d4 <ilock>
  if(ip->type != T_DIR){
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010633c:	66 83 f8 01          	cmp    $0x1,%ax
80106340:	74 17                	je     80106359 <sys_chdir+0x71>
    iunlockput(ip);
80106342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106345:	89 04 24             	mov    %eax,(%esp)
80106348:	e8 11 b8 ff ff       	call   80101b5e <iunlockput>
    end_op();
8010634d:	e8 ee d1 ff ff       	call   80103540 <end_op>
    return -1;
80106352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106357:	eb 32                	jmp    8010638b <sys_chdir+0xa3>
  }
  iunlock(ip);
80106359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635c:	89 04 24             	mov    %eax,(%esp)
8010635f:	e8 c4 b6 ff ff       	call   80101a28 <iunlock>
  iput(proc->cwd);
80106364:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636a:	8b 40 68             	mov    0x68(%eax),%eax
8010636d:	89 04 24             	mov    %eax,(%esp)
80106370:	e8 18 b7 ff ff       	call   80101a8d <iput>
  end_op();
80106375:	e8 c6 d1 ff ff       	call   80103540 <end_op>
  proc->cwd = ip;
8010637a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106380:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106383:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106386:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638b:	c9                   	leave  
8010638c:	c3                   	ret    

8010638d <sys_exec>:

int
sys_exec(void)
{
8010638d:	55                   	push   %ebp
8010638e:	89 e5                	mov    %esp,%ebp
80106390:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106396:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106399:	89 44 24 04          	mov    %eax,0x4(%esp)
8010639d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063a4:	e8 7c f3 ff ff       	call   80105725 <argstr>
801063a9:	85 c0                	test   %eax,%eax
801063ab:	78 1a                	js     801063c7 <sys_exec+0x3a>
801063ad:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801063b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801063b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063be:	e8 d2 f2 ff ff       	call   80105695 <argint>
801063c3:	85 c0                	test   %eax,%eax
801063c5:	79 0a                	jns    801063d1 <sys_exec+0x44>
    return -1;
801063c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cc:	e9 c8 00 00 00       	jmp    80106499 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801063d1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801063d8:	00 
801063d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063e0:	00 
801063e1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063e7:	89 04 24             	mov    %eax,(%esp)
801063ea:	e8 64 ef ff ff       	call   80105353 <memset>
  for(i=0;; i++){
801063ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f9:	83 f8 1f             	cmp    $0x1f,%eax
801063fc:	76 0a                	jbe    80106408 <sys_exec+0x7b>
      return -1;
801063fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106403:	e9 91 00 00 00       	jmp    80106499 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640b:	c1 e0 02             	shl    $0x2,%eax
8010640e:	89 c2                	mov    %eax,%edx
80106410:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106416:	01 c2                	add    %eax,%edx
80106418:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010641e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106422:	89 14 24             	mov    %edx,(%esp)
80106425:	e8 cf f1 ff ff       	call   801055f9 <fetchint>
8010642a:	85 c0                	test   %eax,%eax
8010642c:	79 07                	jns    80106435 <sys_exec+0xa8>
      return -1;
8010642e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106433:	eb 64                	jmp    80106499 <sys_exec+0x10c>
    if(uarg == 0){
80106435:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010643b:	85 c0                	test   %eax,%eax
8010643d:	75 26                	jne    80106465 <sys_exec+0xd8>
      argv[i] = 0;
8010643f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106442:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106449:	00 00 00 00 
      break;
8010644d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010644e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106451:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106457:	89 54 24 04          	mov    %edx,0x4(%esp)
8010645b:	89 04 24             	mov    %eax,(%esp)
8010645e:	e8 a7 a6 ff ff       	call   80100b0a <exec>
80106463:	eb 34                	jmp    80106499 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106465:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010646b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010646e:	c1 e2 02             	shl    $0x2,%edx
80106471:	01 c2                	add    %eax,%edx
80106473:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106479:	89 54 24 04          	mov    %edx,0x4(%esp)
8010647d:	89 04 24             	mov    %eax,(%esp)
80106480:	e8 ae f1 ff ff       	call   80105633 <fetchstr>
80106485:	85 c0                	test   %eax,%eax
80106487:	79 07                	jns    80106490 <sys_exec+0x103>
      return -1;
80106489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648e:	eb 09                	jmp    80106499 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106490:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106494:	e9 5d ff ff ff       	jmp    801063f6 <sys_exec+0x69>
  return exec(path, argv);
}
80106499:	c9                   	leave  
8010649a:	c3                   	ret    

8010649b <sys_pipe>:

int
sys_pipe(void)
{
8010649b:	55                   	push   %ebp
8010649c:	89 e5                	mov    %esp,%ebp
8010649e:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064a1:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064a8:	00 
801064a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b7:	e8 07 f2 ff ff       	call   801056c3 <argptr>
801064bc:	85 c0                	test   %eax,%eax
801064be:	79 0a                	jns    801064ca <sys_pipe+0x2f>
    return -1;
801064c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c5:	e9 9b 00 00 00       	jmp    80106565 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801064ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801064d1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064d4:	89 04 24             	mov    %eax,(%esp)
801064d7:	e8 ec da ff ff       	call   80103fc8 <pipealloc>
801064dc:	85 c0                	test   %eax,%eax
801064de:	79 07                	jns    801064e7 <sys_pipe+0x4c>
    return -1;
801064e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e5:	eb 7e                	jmp    80106565 <sys_pipe+0xca>
  fd0 = -1;
801064e7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f1:	89 04 24             	mov    %eax,(%esp)
801064f4:	e8 67 f3 ff ff       	call   80105860 <fdalloc>
801064f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106500:	78 14                	js     80106516 <sys_pipe+0x7b>
80106502:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106505:	89 04 24             	mov    %eax,(%esp)
80106508:	e8 53 f3 ff ff       	call   80105860 <fdalloc>
8010650d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106510:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106514:	79 37                	jns    8010654d <sys_pipe+0xb2>
    if(fd0 >= 0)
80106516:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651a:	78 14                	js     80106530 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010651c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106522:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106525:	83 c2 08             	add    $0x8,%edx
80106528:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010652f:	00 
    fileclose(rf);
80106530:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106533:	89 04 24             	mov    %eax,(%esp)
80106536:	e8 ae aa ff ff       	call   80100fe9 <fileclose>
    fileclose(wf);
8010653b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010653e:	89 04 24             	mov    %eax,(%esp)
80106541:	e8 a3 aa ff ff       	call   80100fe9 <fileclose>
    return -1;
80106546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654b:	eb 18                	jmp    80106565 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010654d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106553:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106558:	8d 50 04             	lea    0x4(%eax),%edx
8010655b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010655e:	89 02                	mov    %eax,(%edx)
  return 0;
80106560:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106565:	c9                   	leave  
80106566:	c3                   	ret    

80106567 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80106567:	55                   	push   %ebp
80106568:	89 e5                	mov    %esp,%ebp
8010656a:	83 ec 08             	sub    $0x8,%esp
8010656d:	8b 55 08             	mov    0x8(%ebp),%edx
80106570:	8b 45 0c             	mov    0xc(%ebp),%eax
80106573:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106577:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010657b:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
8010657f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106583:	66 ef                	out    %ax,(%dx)
}
80106585:	c9                   	leave  
80106586:	c3                   	ret    

80106587 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80106587:	55                   	push   %ebp
80106588:	89 e5                	mov    %esp,%ebp
8010658a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010658d:	e8 2a e1 ff ff       	call   801046bc <fork>
}
80106592:	c9                   	leave  
80106593:	c3                   	ret    

80106594 <sys_exit>:

int
sys_exit(void)
{
80106594:	55                   	push   %ebp
80106595:	89 e5                	mov    %esp,%ebp
80106597:	83 ec 08             	sub    $0x8,%esp
  exit();
8010659a:	e8 c2 e2 ff ff       	call   80104861 <exit>
  return 0;  // not reached
8010659f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065a4:	c9                   	leave  
801065a5:	c3                   	ret    

801065a6 <sys_wait>:

int
sys_wait(void)
{
801065a6:	55                   	push   %ebp
801065a7:	89 e5                	mov    %esp,%ebp
801065a9:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065ac:	e8 d5 e3 ff ff       	call   80104986 <wait>
}
801065b1:	c9                   	leave  
801065b2:	c3                   	ret    

801065b3 <sys_kill>:

int
sys_kill(void)
{
801065b3:	55                   	push   %ebp
801065b4:	89 e5                	mov    %esp,%ebp
801065b6:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801065c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065c7:	e8 c9 f0 ff ff       	call   80105695 <argint>
801065cc:	85 c0                	test   %eax,%eax
801065ce:	79 07                	jns    801065d7 <sys_kill+0x24>
    return -1;
801065d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d5:	eb 0b                	jmp    801065e2 <sys_kill+0x2f>
  return kill(pid);
801065d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065da:	89 04 24             	mov    %eax,(%esp)
801065dd:	e8 7b e7 ff ff       	call   80104d5d <kill>
}
801065e2:	c9                   	leave  
801065e3:	c3                   	ret    

801065e4 <sys_getpid>:

int
sys_getpid(void)
{
801065e4:	55                   	push   %ebp
801065e5:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801065e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ed:	8b 40 10             	mov    0x10(%eax),%eax
}
801065f0:	5d                   	pop    %ebp
801065f1:	c3                   	ret    

801065f2 <sys_sbrk>:

int
sys_sbrk(void)
{
801065f2:	55                   	push   %ebp
801065f3:	89 e5                	mov    %esp,%ebp
801065f5:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106606:	e8 8a f0 ff ff       	call   80105695 <argint>
8010660b:	85 c0                	test   %eax,%eax
8010660d:	79 07                	jns    80106616 <sys_sbrk+0x24>
    return -1;
8010660f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106614:	eb 24                	jmp    8010663a <sys_sbrk+0x48>
  addr = proc->sz;
80106616:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010661c:	8b 00                	mov    (%eax),%eax
8010661e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106624:	89 04 24             	mov    %eax,(%esp)
80106627:	e8 eb df ff ff       	call   80104617 <growproc>
8010662c:	85 c0                	test   %eax,%eax
8010662e:	79 07                	jns    80106637 <sys_sbrk+0x45>
    return -1;
80106630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106635:	eb 03                	jmp    8010663a <sys_sbrk+0x48>
  return addr;
80106637:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010663a:	c9                   	leave  
8010663b:	c3                   	ret    

8010663c <sys_sleep>:

int
sys_sleep(void)
{
8010663c:	55                   	push   %ebp
8010663d:	89 e5                	mov    %esp,%ebp
8010663f:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106642:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106645:	89 44 24 04          	mov    %eax,0x4(%esp)
80106649:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106650:	e8 40 f0 ff ff       	call   80105695 <argint>
80106655:	85 c0                	test   %eax,%eax
80106657:	79 07                	jns    80106660 <sys_sleep+0x24>
    return -1;
80106659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665e:	eb 6c                	jmp    801066cc <sys_sleep+0x90>
  acquire(&tickslock);
80106660:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106667:	e8 93 ea ff ff       	call   801050ff <acquire>
  ticks0 = ticks;
8010666c:	a1 00 54 11 80       	mov    0x80115400,%eax
80106671:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106674:	eb 34                	jmp    801066aa <sys_sleep+0x6e>
    if(proc->killed){
80106676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667c:	8b 40 24             	mov    0x24(%eax),%eax
8010667f:	85 c0                	test   %eax,%eax
80106681:	74 13                	je     80106696 <sys_sleep+0x5a>
      release(&tickslock);
80106683:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
8010668a:	e8 d2 ea ff ff       	call   80105161 <release>
      return -1;
8010668f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106694:	eb 36                	jmp    801066cc <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106696:	c7 44 24 04 c0 4b 11 	movl   $0x80114bc0,0x4(%esp)
8010669d:	80 
8010669e:	c7 04 24 00 54 11 80 	movl   $0x80115400,(%esp)
801066a5:	e8 ac e5 ff ff       	call   80104c56 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801066aa:	a1 00 54 11 80       	mov    0x80115400,%eax
801066af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801066b2:	89 c2                	mov    %eax,%edx
801066b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b7:	39 c2                	cmp    %eax,%edx
801066b9:	72 bb                	jb     80106676 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066bb:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801066c2:	e8 9a ea ff ff       	call   80105161 <release>
  return 0;
801066c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066cc:	c9                   	leave  
801066cd:	c3                   	ret    

801066ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066ce:	55                   	push   %ebp
801066cf:	89 e5                	mov    %esp,%ebp
801066d1:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801066d4:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801066db:	e8 1f ea ff ff       	call   801050ff <acquire>
  xticks = ticks;
801066e0:	a1 00 54 11 80       	mov    0x80115400,%eax
801066e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066e8:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801066ef:	e8 6d ea ff ff       	call   80105161 <release>
  return xticks;
801066f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066f7:	c9                   	leave  
801066f8:	c3                   	ret    

801066f9 <sys_halt>:

//Turn of the computer
int sys_halt(void){
801066f9:	55                   	push   %ebp
801066fa:	89 e5                	mov    %esp,%ebp
801066fc:	83 ec 18             	sub    $0x18,%esp
  cprintf("Shutting down ...\n");
801066ff:	c7 04 24 95 8d 10 80 	movl   $0x80108d95,(%esp)
80106706:	e8 95 9c ff ff       	call   801003a0 <cprintf>
  outw (0xB004, 0x0 | 0x2000);
8010670b:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
80106712:	00 
80106713:	c7 04 24 04 b0 00 00 	movl   $0xb004,(%esp)
8010671a:	e8 48 fe ff ff       	call   80106567 <outw>
  return 0;
8010671f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106724:	c9                   	leave  
80106725:	c3                   	ret    

80106726 <sys_date>:

//Get current UTC date of the system
int
sys_date(void)
{
80106726:	55                   	push   %ebp
80106727:	89 e5                	mov    %esp,%ebp
80106729:	83 ec 28             	sub    $0x28,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(*d)) < 0)
8010672c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80106733:	00 
80106734:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106737:	89 44 24 04          	mov    %eax,0x4(%esp)
8010673b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106742:	e8 7c ef ff ff       	call   801056c3 <argptr>
80106747:	85 c0                	test   %eax,%eax
80106749:	79 07                	jns    80106752 <sys_date+0x2c>
    return -1;
8010674b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106750:	eb 10                	jmp    80106762 <sys_date+0x3c>
  cmostime(d);
80106752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106755:	89 04 24             	mov    %eax,(%esp)
80106758:	e8 f9 c9 ff ff       	call   80103156 <cmostime>
  return 0;
8010675d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106762:	c9                   	leave  
80106763:	c3                   	ret    

80106764 <sys_setuid>:

#ifdef CS333_P2
// Set UID
int
sys_setuid(void)
{
80106764:	55                   	push   %ebp
80106765:	89 e5                	mov    %esp,%ebp
80106767:	83 ec 28             	sub    $0x28,%esp
	uint new_uid;
  if(argint(0,(int*) &new_uid) < 0)
8010676a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010676d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106778:	e8 18 ef ff ff       	call   80105695 <argint>
8010677d:	85 c0                	test   %eax,%eax
8010677f:	79 07                	jns    80106788 <sys_setuid+0x24>
		return -1;
80106781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106786:	eb 25                	jmp    801067ad <sys_setuid+0x49>
	if(new_uid < 0 || new_uid > 32767)
80106788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678b:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80106790:	76 07                	jbe    80106799 <sys_setuid+0x35>
		return -1;
80106792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106797:	eb 14                	jmp    801067ad <sys_setuid+0x49>
	proc->uid = new_uid;
80106799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010679f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067a2:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	return 0;
801067a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067ad:	c9                   	leave  
801067ae:	c3                   	ret    

801067af <sys_setgid>:

// Set UID
int
sys_setgid(void)
{
801067af:	55                   	push   %ebp
801067b0:	89 e5                	mov    %esp,%ebp
801067b2:	83 ec 28             	sub    $0x28,%esp
	uint new_gid;
  if(argint(0,(int*) &new_gid) < 0)
801067b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801067bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c3:	e8 cd ee ff ff       	call   80105695 <argint>
801067c8:	85 c0                	test   %eax,%eax
801067ca:	79 07                	jns    801067d3 <sys_setgid+0x24>
		return -1;
801067cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d1:	eb 25                	jmp    801067f8 <sys_setgid+0x49>
	if(new_gid < 0 || new_gid > 32767)
801067d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d6:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801067db:	76 07                	jbe    801067e4 <sys_setgid+0x35>
		return -1;
801067dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e2:	eb 14                	jmp    801067f8 <sys_setgid+0x49>
	proc->gid = new_gid;
801067e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ed:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	return 0;
801067f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067f8:	c9                   	leave  
801067f9:	c3                   	ret    

801067fa <sys_getuid>:

// Get UID of current process
uint
sys_getuid(void)
{
801067fa:	55                   	push   %ebp
801067fb:	89 e5                	mov    %esp,%ebp
	return proc->uid;
801067fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106803:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80106809:	5d                   	pop    %ebp
8010680a:	c3                   	ret    

8010680b <sys_getgid>:

// Get GID of current process
uint
sys_getgid(void)
{
8010680b:	55                   	push   %ebp
8010680c:	89 e5                	mov    %esp,%ebp
	return proc->gid;
8010680e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106814:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
8010681a:	5d                   	pop    %ebp
8010681b:	c3                   	ret    

8010681c <sys_getppid>:

// Get PPID of current process
uint
sys_getppid(void)
{
8010681c:	55                   	push   %ebp
8010681d:	89 e5                	mov    %esp,%ebp
	if(proc->pid == 1)
8010681f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106825:	8b 40 10             	mov    0x10(%eax),%eax
80106828:	83 f8 01             	cmp    $0x1,%eax
8010682b:	75 0b                	jne    80106838 <sys_getppid+0x1c>
		return proc->pid;
8010682d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106833:	8b 40 10             	mov    0x10(%eax),%eax
80106836:	eb 0c                	jmp    80106844 <sys_getppid+0x28>
	return proc->parent->pid;
80106838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010683e:	8b 40 14             	mov    0x14(%eax),%eax
80106841:	8b 40 10             	mov    0x10(%eax),%eax
}
80106844:	5d                   	pop    %ebp
80106845:	c3                   	ret    

80106846 <sys_getprocs>:

// Get process info
int
sys_getprocs(void)
{
80106846:	55                   	push   %ebp
80106847:	89 e5                	mov    %esp,%ebp
80106849:	83 ec 28             	sub    $0x28,%esp
	uint arg1;
	struct uproc* table;
	if(argint(0,(int*) &arg1) < 0)
8010684c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010684f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010685a:	e8 36 ee ff ff       	call   80105695 <argint>
8010685f:	85 c0                	test   %eax,%eax
80106861:	79 07                	jns    8010686a <sys_getprocs+0x24>
		return -1;
80106863:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106868:	eb 38                	jmp    801068a2 <sys_getprocs+0x5c>
	if(argptr(1,(void*)&table, sizeof(*table)) < 0)
8010686a:	c7 44 24 08 5c 00 00 	movl   $0x5c,0x8(%esp)
80106871:	00 
80106872:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106875:	89 44 24 04          	mov    %eax,0x4(%esp)
80106879:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106880:	e8 3e ee ff ff       	call   801056c3 <argptr>
80106885:	85 c0                	test   %eax,%eax
80106887:	79 07                	jns    80106890 <sys_getprocs+0x4a>
		return -1;;
80106889:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010688e:	eb 12                	jmp    801068a2 <sys_getprocs+0x5c>
	return getprocs(arg1, table);
80106890:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106896:	89 54 24 04          	mov    %edx,0x4(%esp)
8010689a:	89 04 24             	mov    %eax,(%esp)
8010689d:	e8 ac e6 ff ff       	call   80104f4e <getprocs>
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
801068a7:	83 ec 08             	sub    $0x8,%esp
801068aa:	8b 55 08             	mov    0x8(%ebp),%edx
801068ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801068b0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068b4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068b7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068bb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068bf:	ee                   	out    %al,(%dx)
}
801068c0:	c9                   	leave  
801068c1:	c3                   	ret    

801068c2 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801068c2:	55                   	push   %ebp
801068c3:	89 e5                	mov    %esp,%ebp
801068c5:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801068c8:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801068cf:	00 
801068d0:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801068d7:	e8 c8 ff ff ff       	call   801068a4 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068dc:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801068e3:	00 
801068e4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068eb:	e8 b4 ff ff ff       	call   801068a4 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068f0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801068f7:	00 
801068f8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068ff:	e8 a0 ff ff ff       	call   801068a4 <outb>
  picenable(IRQ_TIMER);
80106904:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010690b:	e8 4b d5 ff ff       	call   80103e5b <picenable>
}
80106910:	c9                   	leave  
80106911:	c3                   	ret    

80106912 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106912:	1e                   	push   %ds
  pushl %es
80106913:	06                   	push   %es
  pushl %fs
80106914:	0f a0                	push   %fs
  pushl %gs
80106916:	0f a8                	push   %gs
  pushal
80106918:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106919:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010691d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010691f:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106921:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106925:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106927:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106929:	54                   	push   %esp
  call trap
8010692a:	e8 d8 01 00 00       	call   80106b07 <trap>
  addl $4, %esp
8010692f:	83 c4 04             	add    $0x4,%esp

80106932 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106932:	61                   	popa   
  popl %gs
80106933:	0f a9                	pop    %gs
  popl %fs
80106935:	0f a1                	pop    %fs
  popl %es
80106937:	07                   	pop    %es
  popl %ds
80106938:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106939:	83 c4 08             	add    $0x8,%esp
  iret
8010693c:	cf                   	iret   

8010693d <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010693d:	55                   	push   %ebp
8010693e:	89 e5                	mov    %esp,%ebp
80106940:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106943:	8b 45 0c             	mov    0xc(%ebp),%eax
80106946:	83 e8 01             	sub    $0x1,%eax
80106949:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010694d:	8b 45 08             	mov    0x8(%ebp),%eax
80106950:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106954:	8b 45 08             	mov    0x8(%ebp),%eax
80106957:	c1 e8 10             	shr    $0x10,%eax
8010695a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010695e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106961:	0f 01 18             	lidtl  (%eax)
}
80106964:	c9                   	leave  
80106965:	c3                   	ret    

80106966 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106966:	55                   	push   %ebp
80106967:	89 e5                	mov    %esp,%ebp
80106969:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010696c:	0f 20 d0             	mov    %cr2,%eax
8010696f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106972:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106975:	c9                   	leave  
80106976:	c3                   	ret    

80106977 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106977:	55                   	push   %ebp
80106978:	89 e5                	mov    %esp,%ebp
8010697a:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010697d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106984:	e9 c3 00 00 00       	jmp    80106a4c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698c:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
80106993:	89 c2                	mov    %eax,%edx
80106995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106998:	66 89 14 c5 00 4c 11 	mov    %dx,-0x7feeb400(,%eax,8)
8010699f:	80 
801069a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a3:	66 c7 04 c5 02 4c 11 	movw   $0x8,-0x7feeb3fe(,%eax,8)
801069aa:	80 08 00 
801069ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b0:	0f b6 14 c5 04 4c 11 	movzbl -0x7feeb3fc(,%eax,8),%edx
801069b7:	80 
801069b8:	83 e2 e0             	and    $0xffffffe0,%edx
801069bb:	88 14 c5 04 4c 11 80 	mov    %dl,-0x7feeb3fc(,%eax,8)
801069c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c5:	0f b6 14 c5 04 4c 11 	movzbl -0x7feeb3fc(,%eax,8),%edx
801069cc:	80 
801069cd:	83 e2 1f             	and    $0x1f,%edx
801069d0:	88 14 c5 04 4c 11 80 	mov    %dl,-0x7feeb3fc(,%eax,8)
801069d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069da:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
801069e1:	80 
801069e2:	83 e2 f0             	and    $0xfffffff0,%edx
801069e5:	83 ca 0e             	or     $0xe,%edx
801069e8:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
801069ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f2:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
801069f9:	80 
801069fa:	83 e2 ef             	and    $0xffffffef,%edx
801069fd:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a07:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
80106a0e:	80 
80106a0f:	83 e2 9f             	and    $0xffffff9f,%edx
80106a12:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a1c:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
80106a23:	80 
80106a24:	83 ca 80             	or     $0xffffff80,%edx
80106a27:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a31:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
80106a38:	c1 e8 10             	shr    $0x10,%eax
80106a3b:	89 c2                	mov    %eax,%edx
80106a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a40:	66 89 14 c5 06 4c 11 	mov    %dx,-0x7feeb3fa(,%eax,8)
80106a47:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a4c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a53:	0f 8e 30 ff ff ff    	jle    80106989 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a59:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106a5e:	66 a3 00 4e 11 80    	mov    %ax,0x80114e00
80106a64:	66 c7 05 02 4e 11 80 	movw   $0x8,0x80114e02
80106a6b:	08 00 
80106a6d:	0f b6 05 04 4e 11 80 	movzbl 0x80114e04,%eax
80106a74:	83 e0 e0             	and    $0xffffffe0,%eax
80106a77:	a2 04 4e 11 80       	mov    %al,0x80114e04
80106a7c:	0f b6 05 04 4e 11 80 	movzbl 0x80114e04,%eax
80106a83:	83 e0 1f             	and    $0x1f,%eax
80106a86:	a2 04 4e 11 80       	mov    %al,0x80114e04
80106a8b:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106a92:	83 c8 0f             	or     $0xf,%eax
80106a95:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106a9a:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106aa1:	83 e0 ef             	and    $0xffffffef,%eax
80106aa4:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106aa9:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106ab0:	83 c8 60             	or     $0x60,%eax
80106ab3:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106ab8:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106abf:	83 c8 80             	or     $0xffffff80,%eax
80106ac2:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106ac7:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106acc:	c1 e8 10             	shr    $0x10,%eax
80106acf:	66 a3 06 4e 11 80    	mov    %ax,0x80114e06
  
  initlock(&tickslock, "time");
80106ad5:	c7 44 24 04 a8 8d 10 	movl   $0x80108da8,0x4(%esp)
80106adc:	80 
80106add:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106ae4:	e8 f5 e5 ff ff       	call   801050de <initlock>
}
80106ae9:	c9                   	leave  
80106aea:	c3                   	ret    

80106aeb <idtinit>:

void
idtinit(void)
{
80106aeb:	55                   	push   %ebp
80106aec:	89 e5                	mov    %esp,%ebp
80106aee:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106af1:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106af8:	00 
80106af9:	c7 04 24 00 4c 11 80 	movl   $0x80114c00,(%esp)
80106b00:	e8 38 fe ff ff       	call   8010693d <lidt>
}
80106b05:	c9                   	leave  
80106b06:	c3                   	ret    

80106b07 <trap>:

void
trap(struct trapframe *tf)
{
80106b07:	55                   	push   %ebp
80106b08:	89 e5                	mov    %esp,%ebp
80106b0a:	57                   	push   %edi
80106b0b:	56                   	push   %esi
80106b0c:	53                   	push   %ebx
80106b0d:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106b10:	8b 45 08             	mov    0x8(%ebp),%eax
80106b13:	8b 40 30             	mov    0x30(%eax),%eax
80106b16:	83 f8 40             	cmp    $0x40,%eax
80106b19:	75 3f                	jne    80106b5a <trap+0x53>
    if(proc->killed)
80106b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b21:	8b 40 24             	mov    0x24(%eax),%eax
80106b24:	85 c0                	test   %eax,%eax
80106b26:	74 05                	je     80106b2d <trap+0x26>
      exit();
80106b28:	e8 34 dd ff ff       	call   80104861 <exit>
    proc->tf = tf;
80106b2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b33:	8b 55 08             	mov    0x8(%ebp),%edx
80106b36:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b39:	e8 1e ec ff ff       	call   8010575c <syscall>
    if(proc->killed)
80106b3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b44:	8b 40 24             	mov    0x24(%eax),%eax
80106b47:	85 c0                	test   %eax,%eax
80106b49:	74 0a                	je     80106b55 <trap+0x4e>
      exit();
80106b4b:	e8 11 dd ff ff       	call   80104861 <exit>
    return;
80106b50:	e9 2d 02 00 00       	jmp    80106d82 <trap+0x27b>
80106b55:	e9 28 02 00 00       	jmp    80106d82 <trap+0x27b>
  }

  switch(tf->trapno){
80106b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b5d:	8b 40 30             	mov    0x30(%eax),%eax
80106b60:	83 e8 20             	sub    $0x20,%eax
80106b63:	83 f8 1f             	cmp    $0x1f,%eax
80106b66:	0f 87 bc 00 00 00    	ja     80106c28 <trap+0x121>
80106b6c:	8b 04 85 50 8e 10 80 	mov    -0x7fef71b0(,%eax,4),%eax
80106b73:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b75:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b7b:	0f b6 00             	movzbl (%eax),%eax
80106b7e:	84 c0                	test   %al,%al
80106b80:	75 31                	jne    80106bb3 <trap+0xac>
      acquire(&tickslock);
80106b82:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106b89:	e8 71 e5 ff ff       	call   801050ff <acquire>
      ticks++;
80106b8e:	a1 00 54 11 80       	mov    0x80115400,%eax
80106b93:	83 c0 01             	add    $0x1,%eax
80106b96:	a3 00 54 11 80       	mov    %eax,0x80115400
      release(&tickslock);    // NOTE: MarkM has reversed these two lines.
80106b9b:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106ba2:	e8 ba e5 ff ff       	call   80105161 <release>
      wakeup(&ticks);         // wakeup() should not require the tickslock to be held
80106ba7:	c7 04 24 00 54 11 80 	movl   $0x80115400,(%esp)
80106bae:	e8 7f e1 ff ff       	call   80104d32 <wakeup>
    }
    lapiceoi();
80106bb3:	e8 ce c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bb8:	e9 41 01 00 00       	jmp    80106cfe <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bbd:	e8 d2 bb ff ff       	call   80102794 <ideintr>
    lapiceoi();
80106bc2:	e8 bf c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bc7:	e9 32 01 00 00       	jmp    80106cfe <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bcc:	e8 84 c1 ff ff       	call   80102d55 <kbdintr>
    lapiceoi();
80106bd1:	e8 b0 c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bd6:	e9 23 01 00 00       	jmp    80106cfe <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bdb:	e8 97 03 00 00       	call   80106f77 <uartintr>
    lapiceoi();
80106be0:	e8 a1 c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106be5:	e9 14 01 00 00       	jmp    80106cfe <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bea:	8b 45 08             	mov    0x8(%ebp),%eax
80106bed:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bf7:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bfa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c00:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c03:	0f b6 c0             	movzbl %al,%eax
80106c06:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c0a:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c12:	c7 04 24 b0 8d 10 80 	movl   $0x80108db0,(%esp)
80106c19:	e8 82 97 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c1e:	e8 63 c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106c23:	e9 d6 00 00 00       	jmp    80106cfe <trap+0x1f7>
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c2e:	85 c0                	test   %eax,%eax
80106c30:	74 11                	je     80106c43 <trap+0x13c>
80106c32:	8b 45 08             	mov    0x8(%ebp),%eax
80106c35:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c39:	0f b7 c0             	movzwl %ax,%eax
80106c3c:	83 e0 03             	and    $0x3,%eax
80106c3f:	85 c0                	test   %eax,%eax
80106c41:	75 46                	jne    80106c89 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c43:	e8 1e fd ff ff       	call   80106966 <rcr2>
80106c48:	8b 55 08             	mov    0x8(%ebp),%edx
80106c4b:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c4e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c55:	0f b6 12             	movzbl (%edx),%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c58:	0f b6 ca             	movzbl %dl,%ecx
80106c5b:	8b 55 08             	mov    0x8(%ebp),%edx
80106c5e:	8b 52 30             	mov    0x30(%edx),%edx
80106c61:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c65:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c71:	c7 04 24 d4 8d 10 80 	movl   $0x80108dd4,(%esp)
80106c78:	e8 23 97 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c7d:	c7 04 24 06 8e 10 80 	movl   $0x80108e06,(%esp)
80106c84:	e8 b1 98 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c89:	e8 d8 fc ff ff       	call   80106966 <rcr2>
80106c8e:	89 c2                	mov    %eax,%edx
80106c90:	8b 45 08             	mov    0x8(%ebp),%eax
80106c93:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c96:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c9c:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9f:	0f b6 f0             	movzbl %al,%esi
80106ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca5:	8b 58 34             	mov    0x34(%eax),%ebx
80106ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cab:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cb4:	83 c0 6c             	add    $0x6c,%eax
80106cb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106cba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cc0:	8b 40 10             	mov    0x10(%eax),%eax
80106cc3:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106cc7:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106ccb:	89 74 24 14          	mov    %esi,0x14(%esp)
80106ccf:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106cd3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106cd7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106cda:	89 74 24 08          	mov    %esi,0x8(%esp)
80106cde:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ce2:	c7 04 24 0c 8e 10 80 	movl   $0x80108e0c,(%esp)
80106ce9:	e8 b2 96 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cfb:	eb 01                	jmp    80106cfe <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cfd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d04:	85 c0                	test   %eax,%eax
80106d06:	74 24                	je     80106d2c <trap+0x225>
80106d08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0e:	8b 40 24             	mov    0x24(%eax),%eax
80106d11:	85 c0                	test   %eax,%eax
80106d13:	74 17                	je     80106d2c <trap+0x225>
80106d15:	8b 45 08             	mov    0x8(%ebp),%eax
80106d18:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d1c:	0f b7 c0             	movzwl %ax,%eax
80106d1f:	83 e0 03             	and    $0x3,%eax
80106d22:	83 f8 03             	cmp    $0x3,%eax
80106d25:	75 05                	jne    80106d2c <trap+0x225>
    exit();
80106d27:	e8 35 db ff ff       	call   80104861 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d32:	85 c0                	test   %eax,%eax
80106d34:	74 1e                	je     80106d54 <trap+0x24d>
80106d36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d3c:	8b 40 0c             	mov    0xc(%eax),%eax
80106d3f:	83 f8 04             	cmp    $0x4,%eax
80106d42:	75 10                	jne    80106d54 <trap+0x24d>
80106d44:	8b 45 08             	mov    0x8(%ebp),%eax
80106d47:	8b 40 30             	mov    0x30(%eax),%eax
80106d4a:	83 f8 20             	cmp    $0x20,%eax
80106d4d:	75 05                	jne    80106d54 <trap+0x24d>
    yield();
80106d4f:	e8 91 de ff ff       	call   80104be5 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d5a:	85 c0                	test   %eax,%eax
80106d5c:	74 24                	je     80106d82 <trap+0x27b>
80106d5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d64:	8b 40 24             	mov    0x24(%eax),%eax
80106d67:	85 c0                	test   %eax,%eax
80106d69:	74 17                	je     80106d82 <trap+0x27b>
80106d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d6e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d72:	0f b7 c0             	movzwl %ax,%eax
80106d75:	83 e0 03             	and    $0x3,%eax
80106d78:	83 f8 03             	cmp    $0x3,%eax
80106d7b:	75 05                	jne    80106d82 <trap+0x27b>
    exit();
80106d7d:	e8 df da ff ff       	call   80104861 <exit>
}
80106d82:	83 c4 3c             	add    $0x3c,%esp
80106d85:	5b                   	pop    %ebx
80106d86:	5e                   	pop    %esi
80106d87:	5f                   	pop    %edi
80106d88:	5d                   	pop    %ebp
80106d89:	c3                   	ret    

80106d8a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d8a:	55                   	push   %ebp
80106d8b:	89 e5                	mov    %esp,%ebp
80106d8d:	83 ec 14             	sub    $0x14,%esp
80106d90:	8b 45 08             	mov    0x8(%ebp),%eax
80106d93:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d97:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d9b:	89 c2                	mov    %eax,%edx
80106d9d:	ec                   	in     (%dx),%al
80106d9e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106da1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106da5:	c9                   	leave  
80106da6:	c3                   	ret    

80106da7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106da7:	55                   	push   %ebp
80106da8:	89 e5                	mov    %esp,%ebp
80106daa:	83 ec 08             	sub    $0x8,%esp
80106dad:	8b 55 08             	mov    0x8(%ebp),%edx
80106db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106db3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106db7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106dba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106dbe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106dc2:	ee                   	out    %al,(%dx)
}
80106dc3:	c9                   	leave  
80106dc4:	c3                   	ret    

80106dc5 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106dc5:	55                   	push   %ebp
80106dc6:	89 e5                	mov    %esp,%ebp
80106dc8:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106dcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dd2:	00 
80106dd3:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106dda:	e8 c8 ff ff ff       	call   80106da7 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ddf:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106de6:	00 
80106de7:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106dee:	e8 b4 ff ff ff       	call   80106da7 <outb>
  outb(COM1+0, 115200/9600);
80106df3:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106dfa:	00 
80106dfb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e02:	e8 a0 ff ff ff       	call   80106da7 <outb>
  outb(COM1+1, 0);
80106e07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e0e:	00 
80106e0f:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e16:	e8 8c ff ff ff       	call   80106da7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e1b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e22:	00 
80106e23:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e2a:	e8 78 ff ff ff       	call   80106da7 <outb>
  outb(COM1+4, 0);
80106e2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e36:	00 
80106e37:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e3e:	e8 64 ff ff ff       	call   80106da7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e43:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e4a:	00 
80106e4b:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e52:	e8 50 ff ff ff       	call   80106da7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e57:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e5e:	e8 27 ff ff ff       	call   80106d8a <inb>
80106e63:	3c ff                	cmp    $0xff,%al
80106e65:	75 02                	jne    80106e69 <uartinit+0xa4>
    return;
80106e67:	eb 6a                	jmp    80106ed3 <uartinit+0x10e>
  uart = 1;
80106e69:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106e70:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e73:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e7a:	e8 0b ff ff ff       	call   80106d8a <inb>
  inb(COM1+0);
80106e7f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e86:	e8 ff fe ff ff       	call   80106d8a <inb>
  picenable(IRQ_COM1);
80106e8b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e92:	e8 c4 cf ff ff       	call   80103e5b <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e9e:	00 
80106e9f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ea6:	e8 68 bb ff ff       	call   80102a13 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106eab:	c7 45 f4 d0 8e 10 80 	movl   $0x80108ed0,-0xc(%ebp)
80106eb2:	eb 15                	jmp    80106ec9 <uartinit+0x104>
    uartputc(*p);
80106eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb7:	0f b6 00             	movzbl (%eax),%eax
80106eba:	0f be c0             	movsbl %al,%eax
80106ebd:	89 04 24             	mov    %eax,(%esp)
80106ec0:	e8 10 00 00 00       	call   80106ed5 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ec5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ecc:	0f b6 00             	movzbl (%eax),%eax
80106ecf:	84 c0                	test   %al,%al
80106ed1:	75 e1                	jne    80106eb4 <uartinit+0xef>
    uartputc(*p);
}
80106ed3:	c9                   	leave  
80106ed4:	c3                   	ret    

80106ed5 <uartputc>:

void
uartputc(int c)
{
80106ed5:	55                   	push   %ebp
80106ed6:	89 e5                	mov    %esp,%ebp
80106ed8:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106edb:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106ee0:	85 c0                	test   %eax,%eax
80106ee2:	75 02                	jne    80106ee6 <uartputc+0x11>
    return;
80106ee4:	eb 4b                	jmp    80106f31 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ee6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eed:	eb 10                	jmp    80106eff <uartputc+0x2a>
    microdelay(10);
80106eef:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ef6:	e8 b0 c0 ff ff       	call   80102fab <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106efb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eff:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f03:	7f 16                	jg     80106f1b <uartputc+0x46>
80106f05:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f0c:	e8 79 fe ff ff       	call   80106d8a <inb>
80106f11:	0f b6 c0             	movzbl %al,%eax
80106f14:	83 e0 20             	and    $0x20,%eax
80106f17:	85 c0                	test   %eax,%eax
80106f19:	74 d4                	je     80106eef <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1e:	0f b6 c0             	movzbl %al,%eax
80106f21:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f25:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f2c:	e8 76 fe ff ff       	call   80106da7 <outb>
}
80106f31:	c9                   	leave  
80106f32:	c3                   	ret    

80106f33 <uartgetc>:

static int
uartgetc(void)
{
80106f33:	55                   	push   %ebp
80106f34:	89 e5                	mov    %esp,%ebp
80106f36:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f39:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106f3e:	85 c0                	test   %eax,%eax
80106f40:	75 07                	jne    80106f49 <uartgetc+0x16>
    return -1;
80106f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f47:	eb 2c                	jmp    80106f75 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f49:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f50:	e8 35 fe ff ff       	call   80106d8a <inb>
80106f55:	0f b6 c0             	movzbl %al,%eax
80106f58:	83 e0 01             	and    $0x1,%eax
80106f5b:	85 c0                	test   %eax,%eax
80106f5d:	75 07                	jne    80106f66 <uartgetc+0x33>
    return -1;
80106f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f64:	eb 0f                	jmp    80106f75 <uartgetc+0x42>
  return inb(COM1+0);
80106f66:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f6d:	e8 18 fe ff ff       	call   80106d8a <inb>
80106f72:	0f b6 c0             	movzbl %al,%eax
}
80106f75:	c9                   	leave  
80106f76:	c3                   	ret    

80106f77 <uartintr>:

void
uartintr(void)
{
80106f77:	55                   	push   %ebp
80106f78:	89 e5                	mov    %esp,%ebp
80106f7a:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f7d:	c7 04 24 33 6f 10 80 	movl   $0x80106f33,(%esp)
80106f84:	e8 3f 98 ff ff       	call   801007c8 <consoleintr>
}
80106f89:	c9                   	leave  
80106f8a:	c3                   	ret    

80106f8b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $0
80106f8d:	6a 00                	push   $0x0
  jmp alltraps
80106f8f:	e9 7e f9 ff ff       	jmp    80106912 <alltraps>

80106f94 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $1
80106f96:	6a 01                	push   $0x1
  jmp alltraps
80106f98:	e9 75 f9 ff ff       	jmp    80106912 <alltraps>

80106f9d <vector2>:
.globl vector2
vector2:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $2
80106f9f:	6a 02                	push   $0x2
  jmp alltraps
80106fa1:	e9 6c f9 ff ff       	jmp    80106912 <alltraps>

80106fa6 <vector3>:
.globl vector3
vector3:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $3
80106fa8:	6a 03                	push   $0x3
  jmp alltraps
80106faa:	e9 63 f9 ff ff       	jmp    80106912 <alltraps>

80106faf <vector4>:
.globl vector4
vector4:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $4
80106fb1:	6a 04                	push   $0x4
  jmp alltraps
80106fb3:	e9 5a f9 ff ff       	jmp    80106912 <alltraps>

80106fb8 <vector5>:
.globl vector5
vector5:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $5
80106fba:	6a 05                	push   $0x5
  jmp alltraps
80106fbc:	e9 51 f9 ff ff       	jmp    80106912 <alltraps>

80106fc1 <vector6>:
.globl vector6
vector6:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $6
80106fc3:	6a 06                	push   $0x6
  jmp alltraps
80106fc5:	e9 48 f9 ff ff       	jmp    80106912 <alltraps>

80106fca <vector7>:
.globl vector7
vector7:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $7
80106fcc:	6a 07                	push   $0x7
  jmp alltraps
80106fce:	e9 3f f9 ff ff       	jmp    80106912 <alltraps>

80106fd3 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fd3:	6a 08                	push   $0x8
  jmp alltraps
80106fd5:	e9 38 f9 ff ff       	jmp    80106912 <alltraps>

80106fda <vector9>:
.globl vector9
vector9:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $9
80106fdc:	6a 09                	push   $0x9
  jmp alltraps
80106fde:	e9 2f f9 ff ff       	jmp    80106912 <alltraps>

80106fe3 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fe3:	6a 0a                	push   $0xa
  jmp alltraps
80106fe5:	e9 28 f9 ff ff       	jmp    80106912 <alltraps>

80106fea <vector11>:
.globl vector11
vector11:
  pushl $11
80106fea:	6a 0b                	push   $0xb
  jmp alltraps
80106fec:	e9 21 f9 ff ff       	jmp    80106912 <alltraps>

80106ff1 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ff1:	6a 0c                	push   $0xc
  jmp alltraps
80106ff3:	e9 1a f9 ff ff       	jmp    80106912 <alltraps>

80106ff8 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ff8:	6a 0d                	push   $0xd
  jmp alltraps
80106ffa:	e9 13 f9 ff ff       	jmp    80106912 <alltraps>

80106fff <vector14>:
.globl vector14
vector14:
  pushl $14
80106fff:	6a 0e                	push   $0xe
  jmp alltraps
80107001:	e9 0c f9 ff ff       	jmp    80106912 <alltraps>

80107006 <vector15>:
.globl vector15
vector15:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $15
80107008:	6a 0f                	push   $0xf
  jmp alltraps
8010700a:	e9 03 f9 ff ff       	jmp    80106912 <alltraps>

8010700f <vector16>:
.globl vector16
vector16:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $16
80107011:	6a 10                	push   $0x10
  jmp alltraps
80107013:	e9 fa f8 ff ff       	jmp    80106912 <alltraps>

80107018 <vector17>:
.globl vector17
vector17:
  pushl $17
80107018:	6a 11                	push   $0x11
  jmp alltraps
8010701a:	e9 f3 f8 ff ff       	jmp    80106912 <alltraps>

8010701f <vector18>:
.globl vector18
vector18:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $18
80107021:	6a 12                	push   $0x12
  jmp alltraps
80107023:	e9 ea f8 ff ff       	jmp    80106912 <alltraps>

80107028 <vector19>:
.globl vector19
vector19:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $19
8010702a:	6a 13                	push   $0x13
  jmp alltraps
8010702c:	e9 e1 f8 ff ff       	jmp    80106912 <alltraps>

80107031 <vector20>:
.globl vector20
vector20:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $20
80107033:	6a 14                	push   $0x14
  jmp alltraps
80107035:	e9 d8 f8 ff ff       	jmp    80106912 <alltraps>

8010703a <vector21>:
.globl vector21
vector21:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $21
8010703c:	6a 15                	push   $0x15
  jmp alltraps
8010703e:	e9 cf f8 ff ff       	jmp    80106912 <alltraps>

80107043 <vector22>:
.globl vector22
vector22:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $22
80107045:	6a 16                	push   $0x16
  jmp alltraps
80107047:	e9 c6 f8 ff ff       	jmp    80106912 <alltraps>

8010704c <vector23>:
.globl vector23
vector23:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $23
8010704e:	6a 17                	push   $0x17
  jmp alltraps
80107050:	e9 bd f8 ff ff       	jmp    80106912 <alltraps>

80107055 <vector24>:
.globl vector24
vector24:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $24
80107057:	6a 18                	push   $0x18
  jmp alltraps
80107059:	e9 b4 f8 ff ff       	jmp    80106912 <alltraps>

8010705e <vector25>:
.globl vector25
vector25:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $25
80107060:	6a 19                	push   $0x19
  jmp alltraps
80107062:	e9 ab f8 ff ff       	jmp    80106912 <alltraps>

80107067 <vector26>:
.globl vector26
vector26:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $26
80107069:	6a 1a                	push   $0x1a
  jmp alltraps
8010706b:	e9 a2 f8 ff ff       	jmp    80106912 <alltraps>

80107070 <vector27>:
.globl vector27
vector27:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $27
80107072:	6a 1b                	push   $0x1b
  jmp alltraps
80107074:	e9 99 f8 ff ff       	jmp    80106912 <alltraps>

80107079 <vector28>:
.globl vector28
vector28:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $28
8010707b:	6a 1c                	push   $0x1c
  jmp alltraps
8010707d:	e9 90 f8 ff ff       	jmp    80106912 <alltraps>

80107082 <vector29>:
.globl vector29
vector29:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $29
80107084:	6a 1d                	push   $0x1d
  jmp alltraps
80107086:	e9 87 f8 ff ff       	jmp    80106912 <alltraps>

8010708b <vector30>:
.globl vector30
vector30:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $30
8010708d:	6a 1e                	push   $0x1e
  jmp alltraps
8010708f:	e9 7e f8 ff ff       	jmp    80106912 <alltraps>

80107094 <vector31>:
.globl vector31
vector31:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $31
80107096:	6a 1f                	push   $0x1f
  jmp alltraps
80107098:	e9 75 f8 ff ff       	jmp    80106912 <alltraps>

8010709d <vector32>:
.globl vector32
vector32:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $32
8010709f:	6a 20                	push   $0x20
  jmp alltraps
801070a1:	e9 6c f8 ff ff       	jmp    80106912 <alltraps>

801070a6 <vector33>:
.globl vector33
vector33:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $33
801070a8:	6a 21                	push   $0x21
  jmp alltraps
801070aa:	e9 63 f8 ff ff       	jmp    80106912 <alltraps>

801070af <vector34>:
.globl vector34
vector34:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $34
801070b1:	6a 22                	push   $0x22
  jmp alltraps
801070b3:	e9 5a f8 ff ff       	jmp    80106912 <alltraps>

801070b8 <vector35>:
.globl vector35
vector35:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $35
801070ba:	6a 23                	push   $0x23
  jmp alltraps
801070bc:	e9 51 f8 ff ff       	jmp    80106912 <alltraps>

801070c1 <vector36>:
.globl vector36
vector36:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $36
801070c3:	6a 24                	push   $0x24
  jmp alltraps
801070c5:	e9 48 f8 ff ff       	jmp    80106912 <alltraps>

801070ca <vector37>:
.globl vector37
vector37:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $37
801070cc:	6a 25                	push   $0x25
  jmp alltraps
801070ce:	e9 3f f8 ff ff       	jmp    80106912 <alltraps>

801070d3 <vector38>:
.globl vector38
vector38:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $38
801070d5:	6a 26                	push   $0x26
  jmp alltraps
801070d7:	e9 36 f8 ff ff       	jmp    80106912 <alltraps>

801070dc <vector39>:
.globl vector39
vector39:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $39
801070de:	6a 27                	push   $0x27
  jmp alltraps
801070e0:	e9 2d f8 ff ff       	jmp    80106912 <alltraps>

801070e5 <vector40>:
.globl vector40
vector40:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $40
801070e7:	6a 28                	push   $0x28
  jmp alltraps
801070e9:	e9 24 f8 ff ff       	jmp    80106912 <alltraps>

801070ee <vector41>:
.globl vector41
vector41:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $41
801070f0:	6a 29                	push   $0x29
  jmp alltraps
801070f2:	e9 1b f8 ff ff       	jmp    80106912 <alltraps>

801070f7 <vector42>:
.globl vector42
vector42:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $42
801070f9:	6a 2a                	push   $0x2a
  jmp alltraps
801070fb:	e9 12 f8 ff ff       	jmp    80106912 <alltraps>

80107100 <vector43>:
.globl vector43
vector43:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $43
80107102:	6a 2b                	push   $0x2b
  jmp alltraps
80107104:	e9 09 f8 ff ff       	jmp    80106912 <alltraps>

80107109 <vector44>:
.globl vector44
vector44:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $44
8010710b:	6a 2c                	push   $0x2c
  jmp alltraps
8010710d:	e9 00 f8 ff ff       	jmp    80106912 <alltraps>

80107112 <vector45>:
.globl vector45
vector45:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $45
80107114:	6a 2d                	push   $0x2d
  jmp alltraps
80107116:	e9 f7 f7 ff ff       	jmp    80106912 <alltraps>

8010711b <vector46>:
.globl vector46
vector46:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $46
8010711d:	6a 2e                	push   $0x2e
  jmp alltraps
8010711f:	e9 ee f7 ff ff       	jmp    80106912 <alltraps>

80107124 <vector47>:
.globl vector47
vector47:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $47
80107126:	6a 2f                	push   $0x2f
  jmp alltraps
80107128:	e9 e5 f7 ff ff       	jmp    80106912 <alltraps>

8010712d <vector48>:
.globl vector48
vector48:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $48
8010712f:	6a 30                	push   $0x30
  jmp alltraps
80107131:	e9 dc f7 ff ff       	jmp    80106912 <alltraps>

80107136 <vector49>:
.globl vector49
vector49:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $49
80107138:	6a 31                	push   $0x31
  jmp alltraps
8010713a:	e9 d3 f7 ff ff       	jmp    80106912 <alltraps>

8010713f <vector50>:
.globl vector50
vector50:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $50
80107141:	6a 32                	push   $0x32
  jmp alltraps
80107143:	e9 ca f7 ff ff       	jmp    80106912 <alltraps>

80107148 <vector51>:
.globl vector51
vector51:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $51
8010714a:	6a 33                	push   $0x33
  jmp alltraps
8010714c:	e9 c1 f7 ff ff       	jmp    80106912 <alltraps>

80107151 <vector52>:
.globl vector52
vector52:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $52
80107153:	6a 34                	push   $0x34
  jmp alltraps
80107155:	e9 b8 f7 ff ff       	jmp    80106912 <alltraps>

8010715a <vector53>:
.globl vector53
vector53:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $53
8010715c:	6a 35                	push   $0x35
  jmp alltraps
8010715e:	e9 af f7 ff ff       	jmp    80106912 <alltraps>

80107163 <vector54>:
.globl vector54
vector54:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $54
80107165:	6a 36                	push   $0x36
  jmp alltraps
80107167:	e9 a6 f7 ff ff       	jmp    80106912 <alltraps>

8010716c <vector55>:
.globl vector55
vector55:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $55
8010716e:	6a 37                	push   $0x37
  jmp alltraps
80107170:	e9 9d f7 ff ff       	jmp    80106912 <alltraps>

80107175 <vector56>:
.globl vector56
vector56:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $56
80107177:	6a 38                	push   $0x38
  jmp alltraps
80107179:	e9 94 f7 ff ff       	jmp    80106912 <alltraps>

8010717e <vector57>:
.globl vector57
vector57:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $57
80107180:	6a 39                	push   $0x39
  jmp alltraps
80107182:	e9 8b f7 ff ff       	jmp    80106912 <alltraps>

80107187 <vector58>:
.globl vector58
vector58:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $58
80107189:	6a 3a                	push   $0x3a
  jmp alltraps
8010718b:	e9 82 f7 ff ff       	jmp    80106912 <alltraps>

80107190 <vector59>:
.globl vector59
vector59:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $59
80107192:	6a 3b                	push   $0x3b
  jmp alltraps
80107194:	e9 79 f7 ff ff       	jmp    80106912 <alltraps>

80107199 <vector60>:
.globl vector60
vector60:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $60
8010719b:	6a 3c                	push   $0x3c
  jmp alltraps
8010719d:	e9 70 f7 ff ff       	jmp    80106912 <alltraps>

801071a2 <vector61>:
.globl vector61
vector61:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $61
801071a4:	6a 3d                	push   $0x3d
  jmp alltraps
801071a6:	e9 67 f7 ff ff       	jmp    80106912 <alltraps>

801071ab <vector62>:
.globl vector62
vector62:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $62
801071ad:	6a 3e                	push   $0x3e
  jmp alltraps
801071af:	e9 5e f7 ff ff       	jmp    80106912 <alltraps>

801071b4 <vector63>:
.globl vector63
vector63:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $63
801071b6:	6a 3f                	push   $0x3f
  jmp alltraps
801071b8:	e9 55 f7 ff ff       	jmp    80106912 <alltraps>

801071bd <vector64>:
.globl vector64
vector64:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $64
801071bf:	6a 40                	push   $0x40
  jmp alltraps
801071c1:	e9 4c f7 ff ff       	jmp    80106912 <alltraps>

801071c6 <vector65>:
.globl vector65
vector65:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $65
801071c8:	6a 41                	push   $0x41
  jmp alltraps
801071ca:	e9 43 f7 ff ff       	jmp    80106912 <alltraps>

801071cf <vector66>:
.globl vector66
vector66:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $66
801071d1:	6a 42                	push   $0x42
  jmp alltraps
801071d3:	e9 3a f7 ff ff       	jmp    80106912 <alltraps>

801071d8 <vector67>:
.globl vector67
vector67:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $67
801071da:	6a 43                	push   $0x43
  jmp alltraps
801071dc:	e9 31 f7 ff ff       	jmp    80106912 <alltraps>

801071e1 <vector68>:
.globl vector68
vector68:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $68
801071e3:	6a 44                	push   $0x44
  jmp alltraps
801071e5:	e9 28 f7 ff ff       	jmp    80106912 <alltraps>

801071ea <vector69>:
.globl vector69
vector69:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $69
801071ec:	6a 45                	push   $0x45
  jmp alltraps
801071ee:	e9 1f f7 ff ff       	jmp    80106912 <alltraps>

801071f3 <vector70>:
.globl vector70
vector70:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $70
801071f5:	6a 46                	push   $0x46
  jmp alltraps
801071f7:	e9 16 f7 ff ff       	jmp    80106912 <alltraps>

801071fc <vector71>:
.globl vector71
vector71:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $71
801071fe:	6a 47                	push   $0x47
  jmp alltraps
80107200:	e9 0d f7 ff ff       	jmp    80106912 <alltraps>

80107205 <vector72>:
.globl vector72
vector72:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $72
80107207:	6a 48                	push   $0x48
  jmp alltraps
80107209:	e9 04 f7 ff ff       	jmp    80106912 <alltraps>

8010720e <vector73>:
.globl vector73
vector73:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $73
80107210:	6a 49                	push   $0x49
  jmp alltraps
80107212:	e9 fb f6 ff ff       	jmp    80106912 <alltraps>

80107217 <vector74>:
.globl vector74
vector74:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $74
80107219:	6a 4a                	push   $0x4a
  jmp alltraps
8010721b:	e9 f2 f6 ff ff       	jmp    80106912 <alltraps>

80107220 <vector75>:
.globl vector75
vector75:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $75
80107222:	6a 4b                	push   $0x4b
  jmp alltraps
80107224:	e9 e9 f6 ff ff       	jmp    80106912 <alltraps>

80107229 <vector76>:
.globl vector76
vector76:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $76
8010722b:	6a 4c                	push   $0x4c
  jmp alltraps
8010722d:	e9 e0 f6 ff ff       	jmp    80106912 <alltraps>

80107232 <vector77>:
.globl vector77
vector77:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $77
80107234:	6a 4d                	push   $0x4d
  jmp alltraps
80107236:	e9 d7 f6 ff ff       	jmp    80106912 <alltraps>

8010723b <vector78>:
.globl vector78
vector78:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $78
8010723d:	6a 4e                	push   $0x4e
  jmp alltraps
8010723f:	e9 ce f6 ff ff       	jmp    80106912 <alltraps>

80107244 <vector79>:
.globl vector79
vector79:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $79
80107246:	6a 4f                	push   $0x4f
  jmp alltraps
80107248:	e9 c5 f6 ff ff       	jmp    80106912 <alltraps>

8010724d <vector80>:
.globl vector80
vector80:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $80
8010724f:	6a 50                	push   $0x50
  jmp alltraps
80107251:	e9 bc f6 ff ff       	jmp    80106912 <alltraps>

80107256 <vector81>:
.globl vector81
vector81:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $81
80107258:	6a 51                	push   $0x51
  jmp alltraps
8010725a:	e9 b3 f6 ff ff       	jmp    80106912 <alltraps>

8010725f <vector82>:
.globl vector82
vector82:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $82
80107261:	6a 52                	push   $0x52
  jmp alltraps
80107263:	e9 aa f6 ff ff       	jmp    80106912 <alltraps>

80107268 <vector83>:
.globl vector83
vector83:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $83
8010726a:	6a 53                	push   $0x53
  jmp alltraps
8010726c:	e9 a1 f6 ff ff       	jmp    80106912 <alltraps>

80107271 <vector84>:
.globl vector84
vector84:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $84
80107273:	6a 54                	push   $0x54
  jmp alltraps
80107275:	e9 98 f6 ff ff       	jmp    80106912 <alltraps>

8010727a <vector85>:
.globl vector85
vector85:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $85
8010727c:	6a 55                	push   $0x55
  jmp alltraps
8010727e:	e9 8f f6 ff ff       	jmp    80106912 <alltraps>

80107283 <vector86>:
.globl vector86
vector86:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $86
80107285:	6a 56                	push   $0x56
  jmp alltraps
80107287:	e9 86 f6 ff ff       	jmp    80106912 <alltraps>

8010728c <vector87>:
.globl vector87
vector87:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $87
8010728e:	6a 57                	push   $0x57
  jmp alltraps
80107290:	e9 7d f6 ff ff       	jmp    80106912 <alltraps>

80107295 <vector88>:
.globl vector88
vector88:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $88
80107297:	6a 58                	push   $0x58
  jmp alltraps
80107299:	e9 74 f6 ff ff       	jmp    80106912 <alltraps>

8010729e <vector89>:
.globl vector89
vector89:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $89
801072a0:	6a 59                	push   $0x59
  jmp alltraps
801072a2:	e9 6b f6 ff ff       	jmp    80106912 <alltraps>

801072a7 <vector90>:
.globl vector90
vector90:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $90
801072a9:	6a 5a                	push   $0x5a
  jmp alltraps
801072ab:	e9 62 f6 ff ff       	jmp    80106912 <alltraps>

801072b0 <vector91>:
.globl vector91
vector91:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $91
801072b2:	6a 5b                	push   $0x5b
  jmp alltraps
801072b4:	e9 59 f6 ff ff       	jmp    80106912 <alltraps>

801072b9 <vector92>:
.globl vector92
vector92:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $92
801072bb:	6a 5c                	push   $0x5c
  jmp alltraps
801072bd:	e9 50 f6 ff ff       	jmp    80106912 <alltraps>

801072c2 <vector93>:
.globl vector93
vector93:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $93
801072c4:	6a 5d                	push   $0x5d
  jmp alltraps
801072c6:	e9 47 f6 ff ff       	jmp    80106912 <alltraps>

801072cb <vector94>:
.globl vector94
vector94:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $94
801072cd:	6a 5e                	push   $0x5e
  jmp alltraps
801072cf:	e9 3e f6 ff ff       	jmp    80106912 <alltraps>

801072d4 <vector95>:
.globl vector95
vector95:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $95
801072d6:	6a 5f                	push   $0x5f
  jmp alltraps
801072d8:	e9 35 f6 ff ff       	jmp    80106912 <alltraps>

801072dd <vector96>:
.globl vector96
vector96:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $96
801072df:	6a 60                	push   $0x60
  jmp alltraps
801072e1:	e9 2c f6 ff ff       	jmp    80106912 <alltraps>

801072e6 <vector97>:
.globl vector97
vector97:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $97
801072e8:	6a 61                	push   $0x61
  jmp alltraps
801072ea:	e9 23 f6 ff ff       	jmp    80106912 <alltraps>

801072ef <vector98>:
.globl vector98
vector98:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $98
801072f1:	6a 62                	push   $0x62
  jmp alltraps
801072f3:	e9 1a f6 ff ff       	jmp    80106912 <alltraps>

801072f8 <vector99>:
.globl vector99
vector99:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $99
801072fa:	6a 63                	push   $0x63
  jmp alltraps
801072fc:	e9 11 f6 ff ff       	jmp    80106912 <alltraps>

80107301 <vector100>:
.globl vector100
vector100:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $100
80107303:	6a 64                	push   $0x64
  jmp alltraps
80107305:	e9 08 f6 ff ff       	jmp    80106912 <alltraps>

8010730a <vector101>:
.globl vector101
vector101:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $101
8010730c:	6a 65                	push   $0x65
  jmp alltraps
8010730e:	e9 ff f5 ff ff       	jmp    80106912 <alltraps>

80107313 <vector102>:
.globl vector102
vector102:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $102
80107315:	6a 66                	push   $0x66
  jmp alltraps
80107317:	e9 f6 f5 ff ff       	jmp    80106912 <alltraps>

8010731c <vector103>:
.globl vector103
vector103:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $103
8010731e:	6a 67                	push   $0x67
  jmp alltraps
80107320:	e9 ed f5 ff ff       	jmp    80106912 <alltraps>

80107325 <vector104>:
.globl vector104
vector104:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $104
80107327:	6a 68                	push   $0x68
  jmp alltraps
80107329:	e9 e4 f5 ff ff       	jmp    80106912 <alltraps>

8010732e <vector105>:
.globl vector105
vector105:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $105
80107330:	6a 69                	push   $0x69
  jmp alltraps
80107332:	e9 db f5 ff ff       	jmp    80106912 <alltraps>

80107337 <vector106>:
.globl vector106
vector106:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $106
80107339:	6a 6a                	push   $0x6a
  jmp alltraps
8010733b:	e9 d2 f5 ff ff       	jmp    80106912 <alltraps>

80107340 <vector107>:
.globl vector107
vector107:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $107
80107342:	6a 6b                	push   $0x6b
  jmp alltraps
80107344:	e9 c9 f5 ff ff       	jmp    80106912 <alltraps>

80107349 <vector108>:
.globl vector108
vector108:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $108
8010734b:	6a 6c                	push   $0x6c
  jmp alltraps
8010734d:	e9 c0 f5 ff ff       	jmp    80106912 <alltraps>

80107352 <vector109>:
.globl vector109
vector109:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $109
80107354:	6a 6d                	push   $0x6d
  jmp alltraps
80107356:	e9 b7 f5 ff ff       	jmp    80106912 <alltraps>

8010735b <vector110>:
.globl vector110
vector110:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $110
8010735d:	6a 6e                	push   $0x6e
  jmp alltraps
8010735f:	e9 ae f5 ff ff       	jmp    80106912 <alltraps>

80107364 <vector111>:
.globl vector111
vector111:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $111
80107366:	6a 6f                	push   $0x6f
  jmp alltraps
80107368:	e9 a5 f5 ff ff       	jmp    80106912 <alltraps>

8010736d <vector112>:
.globl vector112
vector112:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $112
8010736f:	6a 70                	push   $0x70
  jmp alltraps
80107371:	e9 9c f5 ff ff       	jmp    80106912 <alltraps>

80107376 <vector113>:
.globl vector113
vector113:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $113
80107378:	6a 71                	push   $0x71
  jmp alltraps
8010737a:	e9 93 f5 ff ff       	jmp    80106912 <alltraps>

8010737f <vector114>:
.globl vector114
vector114:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $114
80107381:	6a 72                	push   $0x72
  jmp alltraps
80107383:	e9 8a f5 ff ff       	jmp    80106912 <alltraps>

80107388 <vector115>:
.globl vector115
vector115:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $115
8010738a:	6a 73                	push   $0x73
  jmp alltraps
8010738c:	e9 81 f5 ff ff       	jmp    80106912 <alltraps>

80107391 <vector116>:
.globl vector116
vector116:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $116
80107393:	6a 74                	push   $0x74
  jmp alltraps
80107395:	e9 78 f5 ff ff       	jmp    80106912 <alltraps>

8010739a <vector117>:
.globl vector117
vector117:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $117
8010739c:	6a 75                	push   $0x75
  jmp alltraps
8010739e:	e9 6f f5 ff ff       	jmp    80106912 <alltraps>

801073a3 <vector118>:
.globl vector118
vector118:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $118
801073a5:	6a 76                	push   $0x76
  jmp alltraps
801073a7:	e9 66 f5 ff ff       	jmp    80106912 <alltraps>

801073ac <vector119>:
.globl vector119
vector119:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $119
801073ae:	6a 77                	push   $0x77
  jmp alltraps
801073b0:	e9 5d f5 ff ff       	jmp    80106912 <alltraps>

801073b5 <vector120>:
.globl vector120
vector120:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $120
801073b7:	6a 78                	push   $0x78
  jmp alltraps
801073b9:	e9 54 f5 ff ff       	jmp    80106912 <alltraps>

801073be <vector121>:
.globl vector121
vector121:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $121
801073c0:	6a 79                	push   $0x79
  jmp alltraps
801073c2:	e9 4b f5 ff ff       	jmp    80106912 <alltraps>

801073c7 <vector122>:
.globl vector122
vector122:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $122
801073c9:	6a 7a                	push   $0x7a
  jmp alltraps
801073cb:	e9 42 f5 ff ff       	jmp    80106912 <alltraps>

801073d0 <vector123>:
.globl vector123
vector123:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $123
801073d2:	6a 7b                	push   $0x7b
  jmp alltraps
801073d4:	e9 39 f5 ff ff       	jmp    80106912 <alltraps>

801073d9 <vector124>:
.globl vector124
vector124:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $124
801073db:	6a 7c                	push   $0x7c
  jmp alltraps
801073dd:	e9 30 f5 ff ff       	jmp    80106912 <alltraps>

801073e2 <vector125>:
.globl vector125
vector125:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $125
801073e4:	6a 7d                	push   $0x7d
  jmp alltraps
801073e6:	e9 27 f5 ff ff       	jmp    80106912 <alltraps>

801073eb <vector126>:
.globl vector126
vector126:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $126
801073ed:	6a 7e                	push   $0x7e
  jmp alltraps
801073ef:	e9 1e f5 ff ff       	jmp    80106912 <alltraps>

801073f4 <vector127>:
.globl vector127
vector127:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $127
801073f6:	6a 7f                	push   $0x7f
  jmp alltraps
801073f8:	e9 15 f5 ff ff       	jmp    80106912 <alltraps>

801073fd <vector128>:
.globl vector128
vector128:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $128
801073ff:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107404:	e9 09 f5 ff ff       	jmp    80106912 <alltraps>

80107409 <vector129>:
.globl vector129
vector129:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $129
8010740b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107410:	e9 fd f4 ff ff       	jmp    80106912 <alltraps>

80107415 <vector130>:
.globl vector130
vector130:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $130
80107417:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010741c:	e9 f1 f4 ff ff       	jmp    80106912 <alltraps>

80107421 <vector131>:
.globl vector131
vector131:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $131
80107423:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107428:	e9 e5 f4 ff ff       	jmp    80106912 <alltraps>

8010742d <vector132>:
.globl vector132
vector132:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $132
8010742f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107434:	e9 d9 f4 ff ff       	jmp    80106912 <alltraps>

80107439 <vector133>:
.globl vector133
vector133:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $133
8010743b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107440:	e9 cd f4 ff ff       	jmp    80106912 <alltraps>

80107445 <vector134>:
.globl vector134
vector134:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $134
80107447:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010744c:	e9 c1 f4 ff ff       	jmp    80106912 <alltraps>

80107451 <vector135>:
.globl vector135
vector135:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $135
80107453:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107458:	e9 b5 f4 ff ff       	jmp    80106912 <alltraps>

8010745d <vector136>:
.globl vector136
vector136:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $136
8010745f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107464:	e9 a9 f4 ff ff       	jmp    80106912 <alltraps>

80107469 <vector137>:
.globl vector137
vector137:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $137
8010746b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107470:	e9 9d f4 ff ff       	jmp    80106912 <alltraps>

80107475 <vector138>:
.globl vector138
vector138:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $138
80107477:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010747c:	e9 91 f4 ff ff       	jmp    80106912 <alltraps>

80107481 <vector139>:
.globl vector139
vector139:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $139
80107483:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107488:	e9 85 f4 ff ff       	jmp    80106912 <alltraps>

8010748d <vector140>:
.globl vector140
vector140:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $140
8010748f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107494:	e9 79 f4 ff ff       	jmp    80106912 <alltraps>

80107499 <vector141>:
.globl vector141
vector141:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $141
8010749b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801074a0:	e9 6d f4 ff ff       	jmp    80106912 <alltraps>

801074a5 <vector142>:
.globl vector142
vector142:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $142
801074a7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074ac:	e9 61 f4 ff ff       	jmp    80106912 <alltraps>

801074b1 <vector143>:
.globl vector143
vector143:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $143
801074b3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074b8:	e9 55 f4 ff ff       	jmp    80106912 <alltraps>

801074bd <vector144>:
.globl vector144
vector144:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $144
801074bf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074c4:	e9 49 f4 ff ff       	jmp    80106912 <alltraps>

801074c9 <vector145>:
.globl vector145
vector145:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $145
801074cb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074d0:	e9 3d f4 ff ff       	jmp    80106912 <alltraps>

801074d5 <vector146>:
.globl vector146
vector146:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $146
801074d7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074dc:	e9 31 f4 ff ff       	jmp    80106912 <alltraps>

801074e1 <vector147>:
.globl vector147
vector147:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $147
801074e3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074e8:	e9 25 f4 ff ff       	jmp    80106912 <alltraps>

801074ed <vector148>:
.globl vector148
vector148:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $148
801074ef:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074f4:	e9 19 f4 ff ff       	jmp    80106912 <alltraps>

801074f9 <vector149>:
.globl vector149
vector149:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $149
801074fb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107500:	e9 0d f4 ff ff       	jmp    80106912 <alltraps>

80107505 <vector150>:
.globl vector150
vector150:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $150
80107507:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010750c:	e9 01 f4 ff ff       	jmp    80106912 <alltraps>

80107511 <vector151>:
.globl vector151
vector151:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $151
80107513:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107518:	e9 f5 f3 ff ff       	jmp    80106912 <alltraps>

8010751d <vector152>:
.globl vector152
vector152:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $152
8010751f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107524:	e9 e9 f3 ff ff       	jmp    80106912 <alltraps>

80107529 <vector153>:
.globl vector153
vector153:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $153
8010752b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107530:	e9 dd f3 ff ff       	jmp    80106912 <alltraps>

80107535 <vector154>:
.globl vector154
vector154:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $154
80107537:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010753c:	e9 d1 f3 ff ff       	jmp    80106912 <alltraps>

80107541 <vector155>:
.globl vector155
vector155:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $155
80107543:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107548:	e9 c5 f3 ff ff       	jmp    80106912 <alltraps>

8010754d <vector156>:
.globl vector156
vector156:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $156
8010754f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107554:	e9 b9 f3 ff ff       	jmp    80106912 <alltraps>

80107559 <vector157>:
.globl vector157
vector157:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $157
8010755b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107560:	e9 ad f3 ff ff       	jmp    80106912 <alltraps>

80107565 <vector158>:
.globl vector158
vector158:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $158
80107567:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010756c:	e9 a1 f3 ff ff       	jmp    80106912 <alltraps>

80107571 <vector159>:
.globl vector159
vector159:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $159
80107573:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107578:	e9 95 f3 ff ff       	jmp    80106912 <alltraps>

8010757d <vector160>:
.globl vector160
vector160:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $160
8010757f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107584:	e9 89 f3 ff ff       	jmp    80106912 <alltraps>

80107589 <vector161>:
.globl vector161
vector161:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $161
8010758b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107590:	e9 7d f3 ff ff       	jmp    80106912 <alltraps>

80107595 <vector162>:
.globl vector162
vector162:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $162
80107597:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010759c:	e9 71 f3 ff ff       	jmp    80106912 <alltraps>

801075a1 <vector163>:
.globl vector163
vector163:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $163
801075a3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075a8:	e9 65 f3 ff ff       	jmp    80106912 <alltraps>

801075ad <vector164>:
.globl vector164
vector164:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $164
801075af:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075b4:	e9 59 f3 ff ff       	jmp    80106912 <alltraps>

801075b9 <vector165>:
.globl vector165
vector165:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $165
801075bb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075c0:	e9 4d f3 ff ff       	jmp    80106912 <alltraps>

801075c5 <vector166>:
.globl vector166
vector166:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $166
801075c7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075cc:	e9 41 f3 ff ff       	jmp    80106912 <alltraps>

801075d1 <vector167>:
.globl vector167
vector167:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $167
801075d3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075d8:	e9 35 f3 ff ff       	jmp    80106912 <alltraps>

801075dd <vector168>:
.globl vector168
vector168:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $168
801075df:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075e4:	e9 29 f3 ff ff       	jmp    80106912 <alltraps>

801075e9 <vector169>:
.globl vector169
vector169:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $169
801075eb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075f0:	e9 1d f3 ff ff       	jmp    80106912 <alltraps>

801075f5 <vector170>:
.globl vector170
vector170:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $170
801075f7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075fc:	e9 11 f3 ff ff       	jmp    80106912 <alltraps>

80107601 <vector171>:
.globl vector171
vector171:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $171
80107603:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107608:	e9 05 f3 ff ff       	jmp    80106912 <alltraps>

8010760d <vector172>:
.globl vector172
vector172:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $172
8010760f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107614:	e9 f9 f2 ff ff       	jmp    80106912 <alltraps>

80107619 <vector173>:
.globl vector173
vector173:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $173
8010761b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107620:	e9 ed f2 ff ff       	jmp    80106912 <alltraps>

80107625 <vector174>:
.globl vector174
vector174:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $174
80107627:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010762c:	e9 e1 f2 ff ff       	jmp    80106912 <alltraps>

80107631 <vector175>:
.globl vector175
vector175:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $175
80107633:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107638:	e9 d5 f2 ff ff       	jmp    80106912 <alltraps>

8010763d <vector176>:
.globl vector176
vector176:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $176
8010763f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107644:	e9 c9 f2 ff ff       	jmp    80106912 <alltraps>

80107649 <vector177>:
.globl vector177
vector177:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $177
8010764b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107650:	e9 bd f2 ff ff       	jmp    80106912 <alltraps>

80107655 <vector178>:
.globl vector178
vector178:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $178
80107657:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010765c:	e9 b1 f2 ff ff       	jmp    80106912 <alltraps>

80107661 <vector179>:
.globl vector179
vector179:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $179
80107663:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107668:	e9 a5 f2 ff ff       	jmp    80106912 <alltraps>

8010766d <vector180>:
.globl vector180
vector180:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $180
8010766f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107674:	e9 99 f2 ff ff       	jmp    80106912 <alltraps>

80107679 <vector181>:
.globl vector181
vector181:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $181
8010767b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107680:	e9 8d f2 ff ff       	jmp    80106912 <alltraps>

80107685 <vector182>:
.globl vector182
vector182:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $182
80107687:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010768c:	e9 81 f2 ff ff       	jmp    80106912 <alltraps>

80107691 <vector183>:
.globl vector183
vector183:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $183
80107693:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107698:	e9 75 f2 ff ff       	jmp    80106912 <alltraps>

8010769d <vector184>:
.globl vector184
vector184:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $184
8010769f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076a4:	e9 69 f2 ff ff       	jmp    80106912 <alltraps>

801076a9 <vector185>:
.globl vector185
vector185:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $185
801076ab:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076b0:	e9 5d f2 ff ff       	jmp    80106912 <alltraps>

801076b5 <vector186>:
.globl vector186
vector186:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $186
801076b7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076bc:	e9 51 f2 ff ff       	jmp    80106912 <alltraps>

801076c1 <vector187>:
.globl vector187
vector187:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $187
801076c3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076c8:	e9 45 f2 ff ff       	jmp    80106912 <alltraps>

801076cd <vector188>:
.globl vector188
vector188:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $188
801076cf:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076d4:	e9 39 f2 ff ff       	jmp    80106912 <alltraps>

801076d9 <vector189>:
.globl vector189
vector189:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $189
801076db:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076e0:	e9 2d f2 ff ff       	jmp    80106912 <alltraps>

801076e5 <vector190>:
.globl vector190
vector190:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $190
801076e7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076ec:	e9 21 f2 ff ff       	jmp    80106912 <alltraps>

801076f1 <vector191>:
.globl vector191
vector191:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $191
801076f3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076f8:	e9 15 f2 ff ff       	jmp    80106912 <alltraps>

801076fd <vector192>:
.globl vector192
vector192:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $192
801076ff:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107704:	e9 09 f2 ff ff       	jmp    80106912 <alltraps>

80107709 <vector193>:
.globl vector193
vector193:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $193
8010770b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107710:	e9 fd f1 ff ff       	jmp    80106912 <alltraps>

80107715 <vector194>:
.globl vector194
vector194:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $194
80107717:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010771c:	e9 f1 f1 ff ff       	jmp    80106912 <alltraps>

80107721 <vector195>:
.globl vector195
vector195:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $195
80107723:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107728:	e9 e5 f1 ff ff       	jmp    80106912 <alltraps>

8010772d <vector196>:
.globl vector196
vector196:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $196
8010772f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107734:	e9 d9 f1 ff ff       	jmp    80106912 <alltraps>

80107739 <vector197>:
.globl vector197
vector197:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $197
8010773b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107740:	e9 cd f1 ff ff       	jmp    80106912 <alltraps>

80107745 <vector198>:
.globl vector198
vector198:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $198
80107747:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010774c:	e9 c1 f1 ff ff       	jmp    80106912 <alltraps>

80107751 <vector199>:
.globl vector199
vector199:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $199
80107753:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107758:	e9 b5 f1 ff ff       	jmp    80106912 <alltraps>

8010775d <vector200>:
.globl vector200
vector200:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $200
8010775f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107764:	e9 a9 f1 ff ff       	jmp    80106912 <alltraps>

80107769 <vector201>:
.globl vector201
vector201:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $201
8010776b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107770:	e9 9d f1 ff ff       	jmp    80106912 <alltraps>

80107775 <vector202>:
.globl vector202
vector202:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $202
80107777:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010777c:	e9 91 f1 ff ff       	jmp    80106912 <alltraps>

80107781 <vector203>:
.globl vector203
vector203:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $203
80107783:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107788:	e9 85 f1 ff ff       	jmp    80106912 <alltraps>

8010778d <vector204>:
.globl vector204
vector204:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $204
8010778f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107794:	e9 79 f1 ff ff       	jmp    80106912 <alltraps>

80107799 <vector205>:
.globl vector205
vector205:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $205
8010779b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801077a0:	e9 6d f1 ff ff       	jmp    80106912 <alltraps>

801077a5 <vector206>:
.globl vector206
vector206:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $206
801077a7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077ac:	e9 61 f1 ff ff       	jmp    80106912 <alltraps>

801077b1 <vector207>:
.globl vector207
vector207:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $207
801077b3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077b8:	e9 55 f1 ff ff       	jmp    80106912 <alltraps>

801077bd <vector208>:
.globl vector208
vector208:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $208
801077bf:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077c4:	e9 49 f1 ff ff       	jmp    80106912 <alltraps>

801077c9 <vector209>:
.globl vector209
vector209:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $209
801077cb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077d0:	e9 3d f1 ff ff       	jmp    80106912 <alltraps>

801077d5 <vector210>:
.globl vector210
vector210:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $210
801077d7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077dc:	e9 31 f1 ff ff       	jmp    80106912 <alltraps>

801077e1 <vector211>:
.globl vector211
vector211:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $211
801077e3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077e8:	e9 25 f1 ff ff       	jmp    80106912 <alltraps>

801077ed <vector212>:
.globl vector212
vector212:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $212
801077ef:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077f4:	e9 19 f1 ff ff       	jmp    80106912 <alltraps>

801077f9 <vector213>:
.globl vector213
vector213:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $213
801077fb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107800:	e9 0d f1 ff ff       	jmp    80106912 <alltraps>

80107805 <vector214>:
.globl vector214
vector214:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $214
80107807:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010780c:	e9 01 f1 ff ff       	jmp    80106912 <alltraps>

80107811 <vector215>:
.globl vector215
vector215:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $215
80107813:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107818:	e9 f5 f0 ff ff       	jmp    80106912 <alltraps>

8010781d <vector216>:
.globl vector216
vector216:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $216
8010781f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107824:	e9 e9 f0 ff ff       	jmp    80106912 <alltraps>

80107829 <vector217>:
.globl vector217
vector217:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $217
8010782b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107830:	e9 dd f0 ff ff       	jmp    80106912 <alltraps>

80107835 <vector218>:
.globl vector218
vector218:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $218
80107837:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010783c:	e9 d1 f0 ff ff       	jmp    80106912 <alltraps>

80107841 <vector219>:
.globl vector219
vector219:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $219
80107843:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107848:	e9 c5 f0 ff ff       	jmp    80106912 <alltraps>

8010784d <vector220>:
.globl vector220
vector220:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $220
8010784f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107854:	e9 b9 f0 ff ff       	jmp    80106912 <alltraps>

80107859 <vector221>:
.globl vector221
vector221:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $221
8010785b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107860:	e9 ad f0 ff ff       	jmp    80106912 <alltraps>

80107865 <vector222>:
.globl vector222
vector222:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $222
80107867:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010786c:	e9 a1 f0 ff ff       	jmp    80106912 <alltraps>

80107871 <vector223>:
.globl vector223
vector223:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $223
80107873:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107878:	e9 95 f0 ff ff       	jmp    80106912 <alltraps>

8010787d <vector224>:
.globl vector224
vector224:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $224
8010787f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107884:	e9 89 f0 ff ff       	jmp    80106912 <alltraps>

80107889 <vector225>:
.globl vector225
vector225:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $225
8010788b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107890:	e9 7d f0 ff ff       	jmp    80106912 <alltraps>

80107895 <vector226>:
.globl vector226
vector226:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $226
80107897:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010789c:	e9 71 f0 ff ff       	jmp    80106912 <alltraps>

801078a1 <vector227>:
.globl vector227
vector227:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $227
801078a3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078a8:	e9 65 f0 ff ff       	jmp    80106912 <alltraps>

801078ad <vector228>:
.globl vector228
vector228:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $228
801078af:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078b4:	e9 59 f0 ff ff       	jmp    80106912 <alltraps>

801078b9 <vector229>:
.globl vector229
vector229:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $229
801078bb:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078c0:	e9 4d f0 ff ff       	jmp    80106912 <alltraps>

801078c5 <vector230>:
.globl vector230
vector230:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $230
801078c7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078cc:	e9 41 f0 ff ff       	jmp    80106912 <alltraps>

801078d1 <vector231>:
.globl vector231
vector231:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $231
801078d3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078d8:	e9 35 f0 ff ff       	jmp    80106912 <alltraps>

801078dd <vector232>:
.globl vector232
vector232:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $232
801078df:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078e4:	e9 29 f0 ff ff       	jmp    80106912 <alltraps>

801078e9 <vector233>:
.globl vector233
vector233:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $233
801078eb:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078f0:	e9 1d f0 ff ff       	jmp    80106912 <alltraps>

801078f5 <vector234>:
.globl vector234
vector234:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $234
801078f7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078fc:	e9 11 f0 ff ff       	jmp    80106912 <alltraps>

80107901 <vector235>:
.globl vector235
vector235:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $235
80107903:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107908:	e9 05 f0 ff ff       	jmp    80106912 <alltraps>

8010790d <vector236>:
.globl vector236
vector236:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $236
8010790f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107914:	e9 f9 ef ff ff       	jmp    80106912 <alltraps>

80107919 <vector237>:
.globl vector237
vector237:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $237
8010791b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107920:	e9 ed ef ff ff       	jmp    80106912 <alltraps>

80107925 <vector238>:
.globl vector238
vector238:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $238
80107927:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010792c:	e9 e1 ef ff ff       	jmp    80106912 <alltraps>

80107931 <vector239>:
.globl vector239
vector239:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $239
80107933:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107938:	e9 d5 ef ff ff       	jmp    80106912 <alltraps>

8010793d <vector240>:
.globl vector240
vector240:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $240
8010793f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107944:	e9 c9 ef ff ff       	jmp    80106912 <alltraps>

80107949 <vector241>:
.globl vector241
vector241:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $241
8010794b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107950:	e9 bd ef ff ff       	jmp    80106912 <alltraps>

80107955 <vector242>:
.globl vector242
vector242:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $242
80107957:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010795c:	e9 b1 ef ff ff       	jmp    80106912 <alltraps>

80107961 <vector243>:
.globl vector243
vector243:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $243
80107963:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107968:	e9 a5 ef ff ff       	jmp    80106912 <alltraps>

8010796d <vector244>:
.globl vector244
vector244:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $244
8010796f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107974:	e9 99 ef ff ff       	jmp    80106912 <alltraps>

80107979 <vector245>:
.globl vector245
vector245:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $245
8010797b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107980:	e9 8d ef ff ff       	jmp    80106912 <alltraps>

80107985 <vector246>:
.globl vector246
vector246:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $246
80107987:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010798c:	e9 81 ef ff ff       	jmp    80106912 <alltraps>

80107991 <vector247>:
.globl vector247
vector247:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $247
80107993:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107998:	e9 75 ef ff ff       	jmp    80106912 <alltraps>

8010799d <vector248>:
.globl vector248
vector248:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $248
8010799f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079a4:	e9 69 ef ff ff       	jmp    80106912 <alltraps>

801079a9 <vector249>:
.globl vector249
vector249:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $249
801079ab:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079b0:	e9 5d ef ff ff       	jmp    80106912 <alltraps>

801079b5 <vector250>:
.globl vector250
vector250:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $250
801079b7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079bc:	e9 51 ef ff ff       	jmp    80106912 <alltraps>

801079c1 <vector251>:
.globl vector251
vector251:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $251
801079c3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079c8:	e9 45 ef ff ff       	jmp    80106912 <alltraps>

801079cd <vector252>:
.globl vector252
vector252:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $252
801079cf:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079d4:	e9 39 ef ff ff       	jmp    80106912 <alltraps>

801079d9 <vector253>:
.globl vector253
vector253:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $253
801079db:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079e0:	e9 2d ef ff ff       	jmp    80106912 <alltraps>

801079e5 <vector254>:
.globl vector254
vector254:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $254
801079e7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079ec:	e9 21 ef ff ff       	jmp    80106912 <alltraps>

801079f1 <vector255>:
.globl vector255
vector255:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $255
801079f3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079f8:	e9 15 ef ff ff       	jmp    80106912 <alltraps>

801079fd <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079fd:	55                   	push   %ebp
801079fe:	89 e5                	mov    %esp,%ebp
80107a00:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a03:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a06:	83 e8 01             	sub    $0x1,%eax
80107a09:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a10:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a14:	8b 45 08             	mov    0x8(%ebp),%eax
80107a17:	c1 e8 10             	shr    $0x10,%eax
80107a1a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a1e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a21:	0f 01 10             	lgdtl  (%eax)
}
80107a24:	c9                   	leave  
80107a25:	c3                   	ret    

80107a26 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a26:	55                   	push   %ebp
80107a27:	89 e5                	mov    %esp,%ebp
80107a29:	83 ec 04             	sub    $0x4,%esp
80107a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a37:	0f 00 d8             	ltr    %ax
}
80107a3a:	c9                   	leave  
80107a3b:	c3                   	ret    

80107a3c <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a3c:	55                   	push   %ebp
80107a3d:	89 e5                	mov    %esp,%ebp
80107a3f:	83 ec 04             	sub    $0x4,%esp
80107a42:	8b 45 08             	mov    0x8(%ebp),%eax
80107a45:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a49:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a4d:	8e e8                	mov    %eax,%gs
}
80107a4f:	c9                   	leave  
80107a50:	c3                   	ret    

80107a51 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a51:	55                   	push   %ebp
80107a52:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a54:	8b 45 08             	mov    0x8(%ebp),%eax
80107a57:	0f 22 d8             	mov    %eax,%cr3
}
80107a5a:	5d                   	pop    %ebp
80107a5b:	c3                   	ret    

80107a5c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a5c:	55                   	push   %ebp
80107a5d:	89 e5                	mov    %esp,%ebp
80107a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a62:	05 00 00 00 80       	add    $0x80000000,%eax
80107a67:	5d                   	pop    %ebp
80107a68:	c3                   	ret    

80107a69 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a69:	55                   	push   %ebp
80107a6a:	89 e5                	mov    %esp,%ebp
80107a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a6f:	05 00 00 00 80       	add    $0x80000000,%eax
80107a74:	5d                   	pop    %ebp
80107a75:	c3                   	ret    

80107a76 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a76:	55                   	push   %ebp
80107a77:	89 e5                	mov    %esp,%ebp
80107a79:	53                   	push   %ebx
80107a7a:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a7d:	e8 ac b4 ff ff       	call   80102f2e <cpunum>
80107a82:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a88:	05 80 23 11 80       	add    $0x80112380,%eax
80107a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ab0:	83 e2 f0             	and    $0xfffffff0,%edx
80107ab3:	83 ca 0a             	or     $0xa,%edx
80107ab6:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ac0:	83 ca 10             	or     $0x10,%edx
80107ac3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107acd:	83 e2 9f             	and    $0xffffff9f,%edx
80107ad0:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ada:	83 ca 80             	or     $0xffffff80,%edx
80107add:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae7:	83 ca 0f             	or     $0xf,%edx
80107aea:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af4:	83 e2 ef             	and    $0xffffffef,%edx
80107af7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b01:	83 e2 df             	and    $0xffffffdf,%edx
80107b04:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b0e:	83 ca 40             	or     $0x40,%edx
80107b11:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b17:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b1b:	83 ca 80             	or     $0xffffff80,%edx
80107b1e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b24:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b32:	ff ff 
80107b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b37:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b3e:	00 00 
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b54:	83 e2 f0             	and    $0xfffffff0,%edx
80107b57:	83 ca 02             	or     $0x2,%edx
80107b5a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b63:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b6a:	83 ca 10             	or     $0x10,%edx
80107b6d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b76:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b7d:	83 e2 9f             	and    $0xffffff9f,%edx
80107b80:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b89:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b90:	83 ca 80             	or     $0xffffff80,%edx
80107b93:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba3:	83 ca 0f             	or     $0xf,%edx
80107ba6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb6:	83 e2 ef             	and    $0xffffffef,%edx
80107bb9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc9:	83 e2 df             	and    $0xffffffdf,%edx
80107bcc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bdc:	83 ca 40             	or     $0x40,%edx
80107bdf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bef:	83 ca 80             	or     $0xffffff80,%edx
80107bf2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfb:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c05:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c0c:	ff ff 
80107c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c11:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c18:	00 00 
80107c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c27:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c2e:	83 e2 f0             	and    $0xfffffff0,%edx
80107c31:	83 ca 0a             	or     $0xa,%edx
80107c34:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c44:	83 ca 10             	or     $0x10,%edx
80107c47:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c50:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c57:	83 ca 60             	or     $0x60,%edx
80107c5a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c63:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c6a:	83 ca 80             	or     $0xffffff80,%edx
80107c6d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c76:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c7d:	83 ca 0f             	or     $0xf,%edx
80107c80:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c90:	83 e2 ef             	and    $0xffffffef,%edx
80107c93:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ca3:	83 e2 df             	and    $0xffffffdf,%edx
80107ca6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cb6:	83 ca 40             	or     $0x40,%edx
80107cb9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cc9:	83 ca 80             	or     $0xffffff80,%edx
80107ccc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdf:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ce6:	ff ff 
80107ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ceb:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cf2:	00 00 
80107cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf7:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d01:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d08:	83 e2 f0             	and    $0xfffffff0,%edx
80107d0b:	83 ca 02             	or     $0x2,%edx
80107d0e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d1e:	83 ca 10             	or     $0x10,%edx
80107d21:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d31:	83 ca 60             	or     $0x60,%edx
80107d34:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d44:	83 ca 80             	or     $0xffffff80,%edx
80107d47:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d50:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d57:	83 ca 0f             	or     $0xf,%edx
80107d5a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d63:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d6a:	83 e2 ef             	and    $0xffffffef,%edx
80107d6d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d7d:	83 e2 df             	and    $0xffffffdf,%edx
80107d80:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d89:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d90:	83 ca 40             	or     $0x40,%edx
80107d93:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107da3:	83 ca 80             	or     $0xffffff80,%edx
80107da6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	05 b4 00 00 00       	add    $0xb4,%eax
80107dbe:	89 c3                	mov    %eax,%ebx
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	05 b4 00 00 00       	add    $0xb4,%eax
80107dc8:	c1 e8 10             	shr    $0x10,%eax
80107dcb:	89 c1                	mov    %eax,%ecx
80107dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd0:	05 b4 00 00 00       	add    $0xb4,%eax
80107dd5:	c1 e8 18             	shr    $0x18,%eax
80107dd8:	89 c2                	mov    %eax,%edx
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107de4:	00 00 
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df3:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfc:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e03:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e06:	83 c9 02             	or     $0x2,%ecx
80107e09:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e19:	83 c9 10             	or     $0x10,%ecx
80107e1c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e2c:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e2f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e3f:	83 c9 80             	or     $0xffffff80,%ecx
80107e42:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e52:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e55:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e65:	83 e1 ef             	and    $0xffffffef,%ecx
80107e68:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e78:	83 e1 df             	and    $0xffffffdf,%ecx
80107e7b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e8b:	83 c9 40             	or     $0x40,%ecx
80107e8e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e9e:	83 c9 80             	or     $0xffffff80,%ecx
80107ea1:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaa:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	83 c0 70             	add    $0x70,%eax
80107eb6:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ebd:	00 
80107ebe:	89 04 24             	mov    %eax,(%esp)
80107ec1:	e8 37 fb ff ff       	call   801079fd <lgdt>
  loadgs(SEG_KCPU << 3);
80107ec6:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107ecd:	e8 6a fb ff ff       	call   80107a3c <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107edb:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ee2:	00 00 00 00 
}
80107ee6:	83 c4 24             	add    $0x24,%esp
80107ee9:	5b                   	pop    %ebx
80107eea:	5d                   	pop    %ebp
80107eeb:	c3                   	ret    

80107eec <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eec:	55                   	push   %ebp
80107eed:	89 e5                	mov    %esp,%ebp
80107eef:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ef5:	c1 e8 16             	shr    $0x16,%eax
80107ef8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eff:	8b 45 08             	mov    0x8(%ebp),%eax
80107f02:	01 d0                	add    %edx,%eax
80107f04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0a:	8b 00                	mov    (%eax),%eax
80107f0c:	83 e0 01             	and    $0x1,%eax
80107f0f:	85 c0                	test   %eax,%eax
80107f11:	74 17                	je     80107f2a <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f16:	8b 00                	mov    (%eax),%eax
80107f18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f1d:	89 04 24             	mov    %eax,(%esp)
80107f20:	e8 44 fb ff ff       	call   80107a69 <p2v>
80107f25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f28:	eb 4b                	jmp    80107f75 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f2e:	74 0e                	je     80107f3e <walkpgdir+0x52>
80107f30:	e8 63 ac ff ff       	call   80102b98 <kalloc>
80107f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f3c:	75 07                	jne    80107f45 <walkpgdir+0x59>
      return 0;
80107f3e:	b8 00 00 00 00       	mov    $0x0,%eax
80107f43:	eb 47                	jmp    80107f8c <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f4c:	00 
80107f4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f54:	00 
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	89 04 24             	mov    %eax,(%esp)
80107f5b:	e8 f3 d3 ff ff       	call   80105353 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f63:	89 04 24             	mov    %eax,(%esp)
80107f66:	e8 f1 fa ff ff       	call   80107a5c <v2p>
80107f6b:	83 c8 07             	or     $0x7,%eax
80107f6e:	89 c2                	mov    %eax,%edx
80107f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f73:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f78:	c1 e8 0c             	shr    $0xc,%eax
80107f7b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8a:	01 d0                	add    %edx,%eax
}
80107f8c:	c9                   	leave  
80107f8d:	c3                   	ret    

80107f8e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f8e:	55                   	push   %ebp
80107f8f:	89 e5                	mov    %esp,%ebp
80107f91:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fa2:	8b 45 10             	mov    0x10(%ebp),%eax
80107fa5:	01 d0                	add    %edx,%eax
80107fa7:	83 e8 01             	sub    $0x1,%eax
80107faa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107faf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fb2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107fb9:	00 
80107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc4:	89 04 24             	mov    %eax,(%esp)
80107fc7:	e8 20 ff ff ff       	call   80107eec <walkpgdir>
80107fcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fcf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fd3:	75 07                	jne    80107fdc <mappages+0x4e>
      return -1;
80107fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fda:	eb 48                	jmp    80108024 <mappages+0x96>
    if(*pte & PTE_P)
80107fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fdf:	8b 00                	mov    (%eax),%eax
80107fe1:	83 e0 01             	and    $0x1,%eax
80107fe4:	85 c0                	test   %eax,%eax
80107fe6:	74 0c                	je     80107ff4 <mappages+0x66>
      panic("remap");
80107fe8:	c7 04 24 d8 8e 10 80 	movl   $0x80108ed8,(%esp)
80107fef:	e8 46 85 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107ff4:	8b 45 18             	mov    0x18(%ebp),%eax
80107ff7:	0b 45 14             	or     0x14(%ebp),%eax
80107ffa:	83 c8 01             	or     $0x1,%eax
80107ffd:	89 c2                	mov    %eax,%edx
80107fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108002:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108007:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010800a:	75 08                	jne    80108014 <mappages+0x86>
      break;
8010800c:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010800d:	b8 00 00 00 00       	mov    $0x0,%eax
80108012:	eb 10                	jmp    80108024 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108014:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010801b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108022:	eb 8e                	jmp    80107fb2 <mappages+0x24>
  return 0;
}
80108024:	c9                   	leave  
80108025:	c3                   	ret    

80108026 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108026:	55                   	push   %ebp
80108027:	89 e5                	mov    %esp,%ebp
80108029:	53                   	push   %ebx
8010802a:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010802d:	e8 66 ab ff ff       	call   80102b98 <kalloc>
80108032:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108035:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108039:	75 0a                	jne    80108045 <setupkvm+0x1f>
    return 0;
8010803b:	b8 00 00 00 00       	mov    $0x0,%eax
80108040:	e9 98 00 00 00       	jmp    801080dd <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108045:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010804c:	00 
8010804d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108054:	00 
80108055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108058:	89 04 24             	mov    %eax,(%esp)
8010805b:	e8 f3 d2 ff ff       	call   80105353 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108060:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108067:	e8 fd f9 ff ff       	call   80107a69 <p2v>
8010806c:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108071:	76 0c                	jbe    8010807f <setupkvm+0x59>
    panic("PHYSTOP too high");
80108073:	c7 04 24 de 8e 10 80 	movl   $0x80108ede,(%esp)
8010807a:	e8 bb 84 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010807f:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80108086:	eb 49                	jmp    801080d1 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808b:	8b 48 0c             	mov    0xc(%eax),%ecx
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	8b 50 04             	mov    0x4(%eax),%edx
80108094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108097:	8b 58 08             	mov    0x8(%eax),%ebx
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	8b 40 04             	mov    0x4(%eax),%eax
801080a0:	29 c3                	sub    %eax,%ebx
801080a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a5:	8b 00                	mov    (%eax),%eax
801080a7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801080b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ba:	89 04 24             	mov    %eax,(%esp)
801080bd:	e8 cc fe ff ff       	call   80107f8e <mappages>
801080c2:	85 c0                	test   %eax,%eax
801080c4:	79 07                	jns    801080cd <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801080c6:	b8 00 00 00 00       	mov    $0x0,%eax
801080cb:	eb 10                	jmp    801080dd <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080cd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080d1:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
801080d8:	72 ae                	jb     80108088 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080dd:	83 c4 34             	add    $0x34,%esp
801080e0:	5b                   	pop    %ebx
801080e1:	5d                   	pop    %ebp
801080e2:	c3                   	ret    

801080e3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080e3:	55                   	push   %ebp
801080e4:	89 e5                	mov    %esp,%ebp
801080e6:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080e9:	e8 38 ff ff ff       	call   80108026 <setupkvm>
801080ee:	a3 58 54 11 80       	mov    %eax,0x80115458
  switchkvm();
801080f3:	e8 02 00 00 00       	call   801080fa <switchkvm>
}
801080f8:	c9                   	leave  
801080f9:	c3                   	ret    

801080fa <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080fa:	55                   	push   %ebp
801080fb:	89 e5                	mov    %esp,%ebp
801080fd:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108100:	a1 58 54 11 80       	mov    0x80115458,%eax
80108105:	89 04 24             	mov    %eax,(%esp)
80108108:	e8 4f f9 ff ff       	call   80107a5c <v2p>
8010810d:	89 04 24             	mov    %eax,(%esp)
80108110:	e8 3c f9 ff ff       	call   80107a51 <lcr3>
}
80108115:	c9                   	leave  
80108116:	c3                   	ret    

80108117 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108117:	55                   	push   %ebp
80108118:	89 e5                	mov    %esp,%ebp
8010811a:	53                   	push   %ebx
8010811b:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010811e:	e8 30 d1 ff ff       	call   80105253 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108123:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108129:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108130:	83 c2 08             	add    $0x8,%edx
80108133:	89 d3                	mov    %edx,%ebx
80108135:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010813c:	83 c2 08             	add    $0x8,%edx
8010813f:	c1 ea 10             	shr    $0x10,%edx
80108142:	89 d1                	mov    %edx,%ecx
80108144:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010814b:	83 c2 08             	add    $0x8,%edx
8010814e:	c1 ea 18             	shr    $0x18,%edx
80108151:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108158:	67 00 
8010815a:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108161:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108167:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010816e:	83 e1 f0             	and    $0xfffffff0,%ecx
80108171:	83 c9 09             	or     $0x9,%ecx
80108174:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010817a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108181:	83 c9 10             	or     $0x10,%ecx
80108184:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010818a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108191:	83 e1 9f             	and    $0xffffff9f,%ecx
80108194:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010819a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081a1:	83 c9 80             	or     $0xffffff80,%ecx
801081a4:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081aa:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081b1:	83 e1 f0             	and    $0xfffffff0,%ecx
801081b4:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081ba:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081c1:	83 e1 ef             	and    $0xffffffef,%ecx
801081c4:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081ca:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081d1:	83 e1 df             	and    $0xffffffdf,%ecx
801081d4:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081da:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081e1:	83 c9 40             	or     $0x40,%ecx
801081e4:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081ea:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081f1:	83 e1 7f             	and    $0x7f,%ecx
801081f4:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081fa:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108200:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108206:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010820d:	83 e2 ef             	and    $0xffffffef,%edx
80108210:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108216:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010821c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108222:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108228:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010822f:	8b 52 08             	mov    0x8(%edx),%edx
80108232:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108238:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010823b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108242:	e8 df f7 ff ff       	call   80107a26 <ltr>
  if(p->pgdir == 0)
80108247:	8b 45 08             	mov    0x8(%ebp),%eax
8010824a:	8b 40 04             	mov    0x4(%eax),%eax
8010824d:	85 c0                	test   %eax,%eax
8010824f:	75 0c                	jne    8010825d <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108251:	c7 04 24 ef 8e 10 80 	movl   $0x80108eef,(%esp)
80108258:	e8 dd 82 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010825d:	8b 45 08             	mov    0x8(%ebp),%eax
80108260:	8b 40 04             	mov    0x4(%eax),%eax
80108263:	89 04 24             	mov    %eax,(%esp)
80108266:	e8 f1 f7 ff ff       	call   80107a5c <v2p>
8010826b:	89 04 24             	mov    %eax,(%esp)
8010826e:	e8 de f7 ff ff       	call   80107a51 <lcr3>
  popcli();
80108273:	e8 1f d0 ff ff       	call   80105297 <popcli>
}
80108278:	83 c4 14             	add    $0x14,%esp
8010827b:	5b                   	pop    %ebx
8010827c:	5d                   	pop    %ebp
8010827d:	c3                   	ret    

8010827e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010827e:	55                   	push   %ebp
8010827f:	89 e5                	mov    %esp,%ebp
80108281:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108284:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010828b:	76 0c                	jbe    80108299 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010828d:	c7 04 24 03 8f 10 80 	movl   $0x80108f03,(%esp)
80108294:	e8 a1 82 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108299:	e8 fa a8 ff ff       	call   80102b98 <kalloc>
8010829e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082a8:	00 
801082a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082b0:	00 
801082b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b4:	89 04 24             	mov    %eax,(%esp)
801082b7:	e8 97 d0 ff ff       	call   80105353 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bf:	89 04 24             	mov    %eax,(%esp)
801082c2:	e8 95 f7 ff ff       	call   80107a5c <v2p>
801082c7:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082ce:	00 
801082cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082da:	00 
801082db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082e2:	00 
801082e3:	8b 45 08             	mov    0x8(%ebp),%eax
801082e6:	89 04 24             	mov    %eax,(%esp)
801082e9:	e8 a0 fc ff ff       	call   80107f8e <mappages>
  memmove(mem, init, sz);
801082ee:	8b 45 10             	mov    0x10(%ebp),%eax
801082f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801082f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801082fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ff:	89 04 24             	mov    %eax,(%esp)
80108302:	e8 1b d1 ff ff       	call   80105422 <memmove>
}
80108307:	c9                   	leave  
80108308:	c3                   	ret    

80108309 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108309:	55                   	push   %ebp
8010830a:	89 e5                	mov    %esp,%ebp
8010830c:	53                   	push   %ebx
8010830d:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108310:	8b 45 0c             	mov    0xc(%ebp),%eax
80108313:	25 ff 0f 00 00       	and    $0xfff,%eax
80108318:	85 c0                	test   %eax,%eax
8010831a:	74 0c                	je     80108328 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010831c:	c7 04 24 20 8f 10 80 	movl   $0x80108f20,(%esp)
80108323:	e8 12 82 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010832f:	e9 a9 00 00 00       	jmp    801083dd <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108337:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833a:	01 d0                	add    %edx,%eax
8010833c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108343:	00 
80108344:	89 44 24 04          	mov    %eax,0x4(%esp)
80108348:	8b 45 08             	mov    0x8(%ebp),%eax
8010834b:	89 04 24             	mov    %eax,(%esp)
8010834e:	e8 99 fb ff ff       	call   80107eec <walkpgdir>
80108353:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108356:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010835a:	75 0c                	jne    80108368 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010835c:	c7 04 24 43 8f 10 80 	movl   $0x80108f43,(%esp)
80108363:	e8 d2 81 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108368:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010836b:	8b 00                	mov    (%eax),%eax
8010836d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108372:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108378:	8b 55 18             	mov    0x18(%ebp),%edx
8010837b:	29 c2                	sub    %eax,%edx
8010837d:	89 d0                	mov    %edx,%eax
8010837f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108384:	77 0f                	ja     80108395 <loaduvm+0x8c>
      n = sz - i;
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	8b 55 18             	mov    0x18(%ebp),%edx
8010838c:	29 c2                	sub    %eax,%edx
8010838e:	89 d0                	mov    %edx,%eax
80108390:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108393:	eb 07                	jmp    8010839c <loaduvm+0x93>
    else
      n = PGSIZE;
80108395:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010839c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839f:	8b 55 14             	mov    0x14(%ebp),%edx
801083a2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801083a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083a8:	89 04 24             	mov    %eax,(%esp)
801083ab:	e8 b9 f6 ff ff       	call   80107a69 <p2v>
801083b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801083bf:	8b 45 10             	mov    0x10(%ebp),%eax
801083c2:	89 04 24             	mov    %eax,(%esp)
801083c5:	e8 1d 9a ff ff       	call   80101de7 <readi>
801083ca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083cd:	74 07                	je     801083d6 <loaduvm+0xcd>
      return -1;
801083cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083d4:	eb 18                	jmp    801083ee <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e0:	3b 45 18             	cmp    0x18(%ebp),%eax
801083e3:	0f 82 4b ff ff ff    	jb     80108334 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083ee:	83 c4 24             	add    $0x24,%esp
801083f1:	5b                   	pop    %ebx
801083f2:	5d                   	pop    %ebp
801083f3:	c3                   	ret    

801083f4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083f4:	55                   	push   %ebp
801083f5:	89 e5                	mov    %esp,%ebp
801083f7:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083fa:	8b 45 10             	mov    0x10(%ebp),%eax
801083fd:	85 c0                	test   %eax,%eax
801083ff:	79 0a                	jns    8010840b <allocuvm+0x17>
    return 0;
80108401:	b8 00 00 00 00       	mov    $0x0,%eax
80108406:	e9 c1 00 00 00       	jmp    801084cc <allocuvm+0xd8>
  if(newsz < oldsz)
8010840b:	8b 45 10             	mov    0x10(%ebp),%eax
8010840e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108411:	73 08                	jae    8010841b <allocuvm+0x27>
    return oldsz;
80108413:	8b 45 0c             	mov    0xc(%ebp),%eax
80108416:	e9 b1 00 00 00       	jmp    801084cc <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010841b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010841e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108423:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108428:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010842b:	e9 8d 00 00 00       	jmp    801084bd <allocuvm+0xc9>
    mem = kalloc();
80108430:	e8 63 a7 ff ff       	call   80102b98 <kalloc>
80108435:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108438:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010843c:	75 2c                	jne    8010846a <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
8010843e:	c7 04 24 61 8f 10 80 	movl   $0x80108f61,(%esp)
80108445:	e8 56 7f ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010844a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844d:	89 44 24 08          	mov    %eax,0x8(%esp)
80108451:	8b 45 10             	mov    0x10(%ebp),%eax
80108454:	89 44 24 04          	mov    %eax,0x4(%esp)
80108458:	8b 45 08             	mov    0x8(%ebp),%eax
8010845b:	89 04 24             	mov    %eax,(%esp)
8010845e:	e8 6b 00 00 00       	call   801084ce <deallocuvm>
      return 0;
80108463:	b8 00 00 00 00       	mov    $0x0,%eax
80108468:	eb 62                	jmp    801084cc <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010846a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108471:	00 
80108472:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108479:	00 
8010847a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010847d:	89 04 24             	mov    %eax,(%esp)
80108480:	e8 ce ce ff ff       	call   80105353 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108488:	89 04 24             	mov    %eax,(%esp)
8010848b:	e8 cc f5 ff ff       	call   80107a5c <v2p>
80108490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108493:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010849a:	00 
8010849b:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010849f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084a6:	00 
801084a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801084ab:	8b 45 08             	mov    0x8(%ebp),%eax
801084ae:	89 04 24             	mov    %eax,(%esp)
801084b1:	e8 d8 fa ff ff       	call   80107f8e <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084b6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801084c3:	0f 82 67 ff ff ff    	jb     80108430 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084c9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084cc:	c9                   	leave  
801084cd:	c3                   	ret    

801084ce <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084ce:	55                   	push   %ebp
801084cf:	89 e5                	mov    %esp,%ebp
801084d1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084d4:	8b 45 10             	mov    0x10(%ebp),%eax
801084d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084da:	72 08                	jb     801084e4 <deallocuvm+0x16>
    return oldsz;
801084dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801084df:	e9 a4 00 00 00       	jmp    80108588 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084e4:	8b 45 10             	mov    0x10(%ebp),%eax
801084e7:	05 ff 0f 00 00       	add    $0xfff,%eax
801084ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084f4:	e9 80 00 00 00       	jmp    80108579 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108503:	00 
80108504:	89 44 24 04          	mov    %eax,0x4(%esp)
80108508:	8b 45 08             	mov    0x8(%ebp),%eax
8010850b:	89 04 24             	mov    %eax,(%esp)
8010850e:	e8 d9 f9 ff ff       	call   80107eec <walkpgdir>
80108513:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108516:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010851a:	75 09                	jne    80108525 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010851c:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108523:	eb 4d                	jmp    80108572 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108528:	8b 00                	mov    (%eax),%eax
8010852a:	83 e0 01             	and    $0x1,%eax
8010852d:	85 c0                	test   %eax,%eax
8010852f:	74 41                	je     80108572 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108534:	8b 00                	mov    (%eax),%eax
80108536:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010853b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010853e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108542:	75 0c                	jne    80108550 <deallocuvm+0x82>
        panic("kfree");
80108544:	c7 04 24 79 8f 10 80 	movl   $0x80108f79,(%esp)
8010854b:	e8 ea 7f ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108550:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108553:	89 04 24             	mov    %eax,(%esp)
80108556:	e8 0e f5 ff ff       	call   80107a69 <p2v>
8010855b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010855e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108561:	89 04 24             	mov    %eax,(%esp)
80108564:	e8 96 a5 ff ff       	call   80102aff <kfree>
      *pte = 0;
80108569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010856c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108572:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010857f:	0f 82 74 ff ff ff    	jb     801084f9 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108585:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108588:	c9                   	leave  
80108589:	c3                   	ret    

8010858a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010858a:	55                   	push   %ebp
8010858b:	89 e5                	mov    %esp,%ebp
8010858d:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108590:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108594:	75 0c                	jne    801085a2 <freevm+0x18>
    panic("freevm: no pgdir");
80108596:	c7 04 24 7f 8f 10 80 	movl   $0x80108f7f,(%esp)
8010859d:	e8 98 7f ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085a9:	00 
801085aa:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085b1:	80 
801085b2:	8b 45 08             	mov    0x8(%ebp),%eax
801085b5:	89 04 24             	mov    %eax,(%esp)
801085b8:	e8 11 ff ff ff       	call   801084ce <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085c4:	eb 48                	jmp    8010860e <freevm+0x84>
    if(pgdir[i] & PTE_P){
801085c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085d0:	8b 45 08             	mov    0x8(%ebp),%eax
801085d3:	01 d0                	add    %edx,%eax
801085d5:	8b 00                	mov    (%eax),%eax
801085d7:	83 e0 01             	and    $0x1,%eax
801085da:	85 c0                	test   %eax,%eax
801085dc:	74 2c                	je     8010860a <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085e8:	8b 45 08             	mov    0x8(%ebp),%eax
801085eb:	01 d0                	add    %edx,%eax
801085ed:	8b 00                	mov    (%eax),%eax
801085ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085f4:	89 04 24             	mov    %eax,(%esp)
801085f7:	e8 6d f4 ff ff       	call   80107a69 <p2v>
801085fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108602:	89 04 24             	mov    %eax,(%esp)
80108605:	e8 f5 a4 ff ff       	call   80102aff <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010860a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010860e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108615:	76 af                	jbe    801085c6 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108617:	8b 45 08             	mov    0x8(%ebp),%eax
8010861a:	89 04 24             	mov    %eax,(%esp)
8010861d:	e8 dd a4 ff ff       	call   80102aff <kfree>
}
80108622:	c9                   	leave  
80108623:	c3                   	ret    

80108624 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108624:	55                   	push   %ebp
80108625:	89 e5                	mov    %esp,%ebp
80108627:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010862a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108631:	00 
80108632:	8b 45 0c             	mov    0xc(%ebp),%eax
80108635:	89 44 24 04          	mov    %eax,0x4(%esp)
80108639:	8b 45 08             	mov    0x8(%ebp),%eax
8010863c:	89 04 24             	mov    %eax,(%esp)
8010863f:	e8 a8 f8 ff ff       	call   80107eec <walkpgdir>
80108644:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108647:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010864b:	75 0c                	jne    80108659 <clearpteu+0x35>
    panic("clearpteu");
8010864d:	c7 04 24 90 8f 10 80 	movl   $0x80108f90,(%esp)
80108654:	e8 e1 7e ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865c:	8b 00                	mov    (%eax),%eax
8010865e:	83 e0 fb             	and    $0xfffffffb,%eax
80108661:	89 c2                	mov    %eax,%edx
80108663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108666:	89 10                	mov    %edx,(%eax)
}
80108668:	c9                   	leave  
80108669:	c3                   	ret    

8010866a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010866a:	55                   	push   %ebp
8010866b:	89 e5                	mov    %esp,%ebp
8010866d:	53                   	push   %ebx
8010866e:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108671:	e8 b0 f9 ff ff       	call   80108026 <setupkvm>
80108676:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108679:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010867d:	75 0a                	jne    80108689 <copyuvm+0x1f>
    return 0;
8010867f:	b8 00 00 00 00       	mov    $0x0,%eax
80108684:	e9 fd 00 00 00       	jmp    80108786 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108690:	e9 d0 00 00 00       	jmp    80108765 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108698:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010869f:	00 
801086a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a4:	8b 45 08             	mov    0x8(%ebp),%eax
801086a7:	89 04 24             	mov    %eax,(%esp)
801086aa:	e8 3d f8 ff ff       	call   80107eec <walkpgdir>
801086af:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086b6:	75 0c                	jne    801086c4 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801086b8:	c7 04 24 9a 8f 10 80 	movl   $0x80108f9a,(%esp)
801086bf:	e8 76 7e ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
801086c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c7:	8b 00                	mov    (%eax),%eax
801086c9:	83 e0 01             	and    $0x1,%eax
801086cc:	85 c0                	test   %eax,%eax
801086ce:	75 0c                	jne    801086dc <copyuvm+0x72>
      panic("copyuvm: page not present");
801086d0:	c7 04 24 b4 8f 10 80 	movl   $0x80108fb4,(%esp)
801086d7:	e8 5e 7e ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801086dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086df:	8b 00                	mov    (%eax),%eax
801086e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ec:	8b 00                	mov    (%eax),%eax
801086ee:	25 ff 0f 00 00       	and    $0xfff,%eax
801086f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801086f6:	e8 9d a4 ff ff       	call   80102b98 <kalloc>
801086fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801086fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108702:	75 02                	jne    80108706 <copyuvm+0x9c>
      goto bad;
80108704:	eb 70                	jmp    80108776 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108706:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108709:	89 04 24             	mov    %eax,(%esp)
8010870c:	e8 58 f3 ff ff       	call   80107a69 <p2v>
80108711:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108718:	00 
80108719:	89 44 24 04          	mov    %eax,0x4(%esp)
8010871d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108720:	89 04 24             	mov    %eax,(%esp)
80108723:	e8 fa cc ff ff       	call   80105422 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108728:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010872b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010872e:	89 04 24             	mov    %eax,(%esp)
80108731:	e8 26 f3 ff ff       	call   80107a5c <v2p>
80108736:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108739:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010873d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108741:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108748:	00 
80108749:	89 54 24 04          	mov    %edx,0x4(%esp)
8010874d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108750:	89 04 24             	mov    %eax,(%esp)
80108753:	e8 36 f8 ff ff       	call   80107f8e <mappages>
80108758:	85 c0                	test   %eax,%eax
8010875a:	79 02                	jns    8010875e <copyuvm+0xf4>
      goto bad;
8010875c:	eb 18                	jmp    80108776 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010875e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010876b:	0f 82 24 ff ff ff    	jb     80108695 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108774:	eb 10                	jmp    80108786 <copyuvm+0x11c>

bad:
  freevm(d);
80108776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108779:	89 04 24             	mov    %eax,(%esp)
8010877c:	e8 09 fe ff ff       	call   8010858a <freevm>
  return 0;
80108781:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108786:	83 c4 44             	add    $0x44,%esp
80108789:	5b                   	pop    %ebx
8010878a:	5d                   	pop    %ebp
8010878b:	c3                   	ret    

8010878c <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010878c:	55                   	push   %ebp
8010878d:	89 e5                	mov    %esp,%ebp
8010878f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108792:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108799:	00 
8010879a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010879d:	89 44 24 04          	mov    %eax,0x4(%esp)
801087a1:	8b 45 08             	mov    0x8(%ebp),%eax
801087a4:	89 04 24             	mov    %eax,(%esp)
801087a7:	e8 40 f7 ff ff       	call   80107eec <walkpgdir>
801087ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801087af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b2:	8b 00                	mov    (%eax),%eax
801087b4:	83 e0 01             	and    $0x1,%eax
801087b7:	85 c0                	test   %eax,%eax
801087b9:	75 07                	jne    801087c2 <uva2ka+0x36>
    return 0;
801087bb:	b8 00 00 00 00       	mov    $0x0,%eax
801087c0:	eb 25                	jmp    801087e7 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801087c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c5:	8b 00                	mov    (%eax),%eax
801087c7:	83 e0 04             	and    $0x4,%eax
801087ca:	85 c0                	test   %eax,%eax
801087cc:	75 07                	jne    801087d5 <uva2ka+0x49>
    return 0;
801087ce:	b8 00 00 00 00       	mov    $0x0,%eax
801087d3:	eb 12                	jmp    801087e7 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d8:	8b 00                	mov    (%eax),%eax
801087da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087df:	89 04 24             	mov    %eax,(%esp)
801087e2:	e8 82 f2 ff ff       	call   80107a69 <p2v>
}
801087e7:	c9                   	leave  
801087e8:	c3                   	ret    

801087e9 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087e9:	55                   	push   %ebp
801087ea:	89 e5                	mov    %esp,%ebp
801087ec:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087ef:	8b 45 10             	mov    0x10(%ebp),%eax
801087f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087f5:	e9 87 00 00 00       	jmp    80108881 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801087fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801087fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108802:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108805:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010880c:	8b 45 08             	mov    0x8(%ebp),%eax
8010880f:	89 04 24             	mov    %eax,(%esp)
80108812:	e8 75 ff ff ff       	call   8010878c <uva2ka>
80108817:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010881a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010881e:	75 07                	jne    80108827 <copyout+0x3e>
      return -1;
80108820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108825:	eb 69                	jmp    80108890 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010882a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010882d:	29 c2                	sub    %eax,%edx
8010882f:	89 d0                	mov    %edx,%eax
80108831:	05 00 10 00 00       	add    $0x1000,%eax
80108836:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108839:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010883f:	76 06                	jbe    80108847 <copyout+0x5e>
      n = len;
80108841:	8b 45 14             	mov    0x14(%ebp),%eax
80108844:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108847:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010884a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010884d:	29 c2                	sub    %eax,%edx
8010884f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108852:	01 c2                	add    %eax,%edx
80108854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108857:	89 44 24 08          	mov    %eax,0x8(%esp)
8010885b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108862:	89 14 24             	mov    %edx,(%esp)
80108865:	e8 b8 cb ff ff       	call   80105422 <memmove>
    len -= n;
8010886a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108873:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108876:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108879:	05 00 10 00 00       	add    $0x1000,%eax
8010887e:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108881:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108885:	0f 85 6f ff ff ff    	jne    801087fa <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010888b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108890:	c9                   	leave  
80108891:	c3                   	ret    
