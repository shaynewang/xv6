7550 // PC keyboard interface constants
7551 
7552 #define KBSTATP         0x64    // kbd controller status port(I)
7553 #define KBS_DIB         0x01    // kbd data in buffer
7554 #define KBDATAP         0x60    // kbd data port(I)
7555 
7556 #define NO              0
7557 
7558 #define SHIFT           (1<<0)
7559 #define CTL             (1<<1)
7560 #define ALT             (1<<2)
7561 
7562 #define CAPSLOCK        (1<<3)
7563 #define NUMLOCK         (1<<4)
7564 #define SCROLLLOCK      (1<<5)
7565 
7566 #define E0ESC           (1<<6)
7567 
7568 // Special keycodes
7569 #define KEY_HOME        0xE0
7570 #define KEY_END         0xE1
7571 #define KEY_UP          0xE2
7572 #define KEY_DN          0xE3
7573 #define KEY_LF          0xE4
7574 #define KEY_RT          0xE5
7575 #define KEY_PGUP        0xE6
7576 #define KEY_PGDN        0xE7
7577 #define KEY_INS         0xE8
7578 #define KEY_DEL         0xE9
7579 
7580 // C('A') == Control-A
7581 #define C(x) (x - '@')
7582 
7583 static uchar shiftcode[256] =
7584 {
7585   [0x1D] CTL,
7586   [0x2A] SHIFT,
7587   [0x36] SHIFT,
7588   [0x38] ALT,
7589   [0x9D] CTL,
7590   [0xB8] ALT
7591 };
7592 
7593 static uchar togglecode[256] =
7594 {
7595   [0x3A] CAPSLOCK,
7596   [0x45] NUMLOCK,
7597   [0x46] SCROLLLOCK
7598 };
7599 
7600 static uchar normalmap[256] =
7601 {
7602   NO,   0x1B, '1',  '2',  '3',  '4',  '5',  '6',  // 0x00
7603   '7',  '8',  '9',  '0',  '-',  '=',  '\b', '\t',
7604   'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',  // 0x10
7605   'o',  'p',  '[',  ']',  '\n', NO,   'a',  's',
7606   'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';',  // 0x20
7607   '\'', '`',  NO,   '\\', 'z',  'x',  'c',  'v',
7608   'b',  'n',  'm',  ',',  '.',  '/',  NO,   '*',  // 0x30
7609   NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
7610   NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',  // 0x40
7611   '8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
7612   '2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,   // 0x50
7613   [0x9C] '\n',      // KP_Enter
7614   [0xB5] '/',       // KP_Div
7615   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7616   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7617   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7618   [0x97] KEY_HOME,  [0xCF] KEY_END,
7619   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7620 };
7621 
7622 static uchar shiftmap[256] =
7623 {
7624   NO,   033,  '!',  '@',  '#',  '$',  '%',  '^',  // 0x00
7625   '&',  '*',  '(',  ')',  '_',  '+',  '\b', '\t',
7626   'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',  // 0x10
7627   'O',  'P',  '{',  '}',  '\n', NO,   'A',  'S',
7628   'D',  'F',  'G',  'H',  'J',  'K',  'L',  ':',  // 0x20
7629   '"',  '~',  NO,   '|',  'Z',  'X',  'C',  'V',
7630   'B',  'N',  'M',  '<',  '>',  '?',  NO,   '*',  // 0x30
7631   NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
7632   NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',  // 0x40
7633   '8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
7634   '2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,   // 0x50
7635   [0x9C] '\n',      // KP_Enter
7636   [0xB5] '/',       // KP_Div
7637   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7638   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7639   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7640   [0x97] KEY_HOME,  [0xCF] KEY_END,
7641   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7642 };
7643 
7644 
7645 
7646 
7647 
7648 
7649 
7650 static uchar ctlmap[256] =
7651 {
7652   NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO,
7653   NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO,
7654   C('Q'),  C('W'),  C('E'),  C('R'),  C('T'),  C('Y'),  C('U'),  C('I'),
7655   C('O'),  C('P'),  NO,      NO,      '\r',    NO,      C('A'),  C('S'),
7656   C('D'),  C('F'),  C('G'),  C('H'),  C('J'),  C('K'),  C('L'),  NO,
7657   NO,      NO,      NO,      C('\\'), C('Z'),  C('X'),  C('C'),  C('V'),
7658   C('B'),  C('N'),  C('M'),  NO,      NO,      C('/'),  NO,      NO,
7659   [0x9C] '\r',      // KP_Enter
7660   [0xB5] C('/'),    // KP_Div
7661   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7662   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7663   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7664   [0x97] KEY_HOME,  [0xCF] KEY_END,
7665   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7666 };
7667 
7668 
7669 
7670 
7671 
7672 
7673 
7674 
7675 
7676 
7677 
7678 
7679 
7680 
7681 
7682 
7683 
7684 
7685 
7686 
7687 
7688 
7689 
7690 
7691 
7692 
7693 
7694 
7695 
7696 
7697 
7698 
7699 
