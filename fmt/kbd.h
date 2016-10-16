7250 // PC keyboard interface constants
7251 
7252 #define KBSTATP         0x64    // kbd controller status port(I)
7253 #define KBS_DIB         0x01    // kbd data in buffer
7254 #define KBDATAP         0x60    // kbd data port(I)
7255 
7256 #define NO              0
7257 
7258 #define SHIFT           (1<<0)
7259 #define CTL             (1<<1)
7260 #define ALT             (1<<2)
7261 
7262 #define CAPSLOCK        (1<<3)
7263 #define NUMLOCK         (1<<4)
7264 #define SCROLLLOCK      (1<<5)
7265 
7266 #define E0ESC           (1<<6)
7267 
7268 // Special keycodes
7269 #define KEY_HOME        0xE0
7270 #define KEY_END         0xE1
7271 #define KEY_UP          0xE2
7272 #define KEY_DN          0xE3
7273 #define KEY_LF          0xE4
7274 #define KEY_RT          0xE5
7275 #define KEY_PGUP        0xE6
7276 #define KEY_PGDN        0xE7
7277 #define KEY_INS         0xE8
7278 #define KEY_DEL         0xE9
7279 
7280 // C('A') == Control-A
7281 #define C(x) (x - '@')
7282 
7283 static uchar shiftcode[256] =
7284 {
7285   [0x1D] CTL,
7286   [0x2A] SHIFT,
7287   [0x36] SHIFT,
7288   [0x38] ALT,
7289   [0x9D] CTL,
7290   [0xB8] ALT
7291 };
7292 
7293 static uchar togglecode[256] =
7294 {
7295   [0x3A] CAPSLOCK,
7296   [0x45] NUMLOCK,
7297   [0x46] SCROLLLOCK
7298 };
7299 
7300 static uchar normalmap[256] =
7301 {
7302   NO,   0x1B, '1',  '2',  '3',  '4',  '5',  '6',  // 0x00
7303   '7',  '8',  '9',  '0',  '-',  '=',  '\b', '\t',
7304   'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',  // 0x10
7305   'o',  'p',  '[',  ']',  '\n', NO,   'a',  's',
7306   'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';',  // 0x20
7307   '\'', '`',  NO,   '\\', 'z',  'x',  'c',  'v',
7308   'b',  'n',  'm',  ',',  '.',  '/',  NO,   '*',  // 0x30
7309   NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
7310   NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',  // 0x40
7311   '8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
7312   '2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,   // 0x50
7313   [0x9C] '\n',      // KP_Enter
7314   [0xB5] '/',       // KP_Div
7315   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7316   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7317   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7318   [0x97] KEY_HOME,  [0xCF] KEY_END,
7319   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7320 };
7321 
7322 static uchar shiftmap[256] =
7323 {
7324   NO,   033,  '!',  '@',  '#',  '$',  '%',  '^',  // 0x00
7325   '&',  '*',  '(',  ')',  '_',  '+',  '\b', '\t',
7326   'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',  // 0x10
7327   'O',  'P',  '{',  '}',  '\n', NO,   'A',  'S',
7328   'D',  'F',  'G',  'H',  'J',  'K',  'L',  ':',  // 0x20
7329   '"',  '~',  NO,   '|',  'Z',  'X',  'C',  'V',
7330   'B',  'N',  'M',  '<',  '>',  '?',  NO,   '*',  // 0x30
7331   NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
7332   NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',  // 0x40
7333   '8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
7334   '2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,   // 0x50
7335   [0x9C] '\n',      // KP_Enter
7336   [0xB5] '/',       // KP_Div
7337   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7338   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7339   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7340   [0x97] KEY_HOME,  [0xCF] KEY_END,
7341   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7342 };
7343 
7344 
7345 
7346 
7347 
7348 
7349 
7350 static uchar ctlmap[256] =
7351 {
7352   NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO,
7353   NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO,
7354   C('Q'),  C('W'),  C('E'),  C('R'),  C('T'),  C('Y'),  C('U'),  C('I'),
7355   C('O'),  C('P'),  NO,      NO,      '\r',    NO,      C('A'),  C('S'),
7356   C('D'),  C('F'),  C('G'),  C('H'),  C('J'),  C('K'),  C('L'),  NO,
7357   NO,      NO,      NO,      C('\\'), C('Z'),  C('X'),  C('C'),  C('V'),
7358   C('B'),  C('N'),  C('M'),  NO,      NO,      C('/'),  NO,      NO,
7359   [0x9C] '\r',      // KP_Enter
7360   [0xB5] C('/'),    // KP_Div
7361   [0xC8] KEY_UP,    [0xD0] KEY_DN,
7362   [0xC9] KEY_PGUP,  [0xD1] KEY_PGDN,
7363   [0xCB] KEY_LF,    [0xCD] KEY_RT,
7364   [0x97] KEY_HOME,  [0xCF] KEY_END,
7365   [0xD2] KEY_INS,   [0xD3] KEY_DEL
7366 };
7367 
7368 
7369 
7370 
7371 
7372 
7373 
7374 
7375 
7376 
7377 
7378 
7379 
7380 
7381 
7382 
7383 
7384 
7385 
7386 
7387 
7388 
7389 
7390 
7391 
7392 
7393 
7394 
7395 
7396 
7397 
7398 
7399 
