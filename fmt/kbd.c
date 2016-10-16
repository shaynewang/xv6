7400 #include "types.h"
7401 #include "x86.h"
7402 #include "defs.h"
7403 #include "kbd.h"
7404 
7405 int
7406 kbdgetc(void)
7407 {
7408   static uint shift;
7409   static uchar *charcode[4] = {
7410     normalmap, shiftmap, ctlmap, ctlmap
7411   };
7412   uint st, data, c;
7413 
7414   st = inb(KBSTATP);
7415   if((st & KBS_DIB) == 0)
7416     return -1;
7417   data = inb(KBDATAP);
7418 
7419   if(data == 0xE0){
7420     shift |= E0ESC;
7421     return 0;
7422   } else if(data & 0x80){
7423     // Key released
7424     data = (shift & E0ESC ? data : data & 0x7F);
7425     shift &= ~(shiftcode[data] | E0ESC);
7426     return 0;
7427   } else if(shift & E0ESC){
7428     // Last character was an E0 escape; or with 0x80
7429     data |= 0x80;
7430     shift &= ~E0ESC;
7431   }
7432 
7433   shift |= shiftcode[data];
7434   shift ^= togglecode[data];
7435   c = charcode[shift & (CTL | SHIFT)][data];
7436   if(shift & CAPSLOCK){
7437     if('a' <= c && c <= 'z')
7438       c += 'A' - 'a';
7439     else if('A' <= c && c <= 'Z')
7440       c += 'a' - 'A';
7441   }
7442   return c;
7443 }
7444 
7445 void
7446 kbdintr(void)
7447 {
7448   consoleintr(kbdgetc);
7449 }
