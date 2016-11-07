7700 #include "types.h"
7701 #include "x86.h"
7702 #include "defs.h"
7703 #include "kbd.h"
7704 
7705 int
7706 kbdgetc(void)
7707 {
7708   static uint shift;
7709   static uchar *charcode[4] = {
7710     normalmap, shiftmap, ctlmap, ctlmap
7711   };
7712   uint st, data, c;
7713 
7714   st = inb(KBSTATP);
7715   if((st & KBS_DIB) == 0)
7716     return -1;
7717   data = inb(KBDATAP);
7718 
7719   if(data == 0xE0){
7720     shift |= E0ESC;
7721     return 0;
7722   } else if(data & 0x80){
7723     // Key released
7724     data = (shift & E0ESC ? data : data & 0x7F);
7725     shift &= ~(shiftcode[data] | E0ESC);
7726     return 0;
7727   } else if(shift & E0ESC){
7728     // Last character was an E0 escape; or with 0x80
7729     data |= 0x80;
7730     shift &= ~E0ESC;
7731   }
7732 
7733   shift |= shiftcode[data];
7734   shift ^= togglecode[data];
7735   c = charcode[shift & (CTL | SHIFT)][data];
7736   if(shift & CAPSLOCK){
7737     if('a' <= c && c <= 'z')
7738       c += 'A' - 'a';
7739     else if('A' <= c && c <= 'Z')
7740       c += 'a' - 'A';
7741   }
7742   return c;
7743 }
7744 
7745 void
7746 kbdintr(void)
7747 {
7748   consoleintr(kbdgetc);
7749 }
