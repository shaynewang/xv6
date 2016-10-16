1150 #include "asm.h"
1151 #include "memlayout.h"
1152 #include "mmu.h"
1153 
1154 # Each non-boot CPU ("AP") is started up in response to a STARTUP
1155 # IPI from the boot CPU.  Section B.4.2 of the Multi-Processor
1156 # Specification says that the AP will start in real mode with CS:IP
1157 # set to XY00:0000, where XY is an 8-bit value sent with the
1158 # STARTUP. Thus this code must start at a 4096-byte boundary.
1159 #
1160 # Because this code sets DS to zero, it must sit
1161 # at an address in the low 2^16 bytes.
1162 #
1163 # Startothers (in main.c) sends the STARTUPs one at a time.
1164 # It copies this code (start) at 0x7000.  It puts the address of
1165 # a newly allocated per-core stack in start-4,the address of the
1166 # place to jump to (mpenter) in start-8, and the physical address
1167 # of entrypgdir in start-12.
1168 #
1169 # This code is identical to bootasm.S except:
1170 #   - it does not need to enable A20
1171 #   - it uses the address at start-4, start-8, and start-12
1172 
1173 .code16
1174 .globl start
1175 start:
1176   cli
1177 
1178   xorw    %ax,%ax
1179   movw    %ax,%ds
1180   movw    %ax,%es
1181   movw    %ax,%ss
1182 
1183   lgdt    gdtdesc
1184   movl    %cr0, %eax
1185   orl     $CR0_PE, %eax
1186   movl    %eax, %cr0
1187 
1188   ljmpl    $(SEG_KCODE<<3), $(start32)
1189 
1190 .code32
1191 start32:
1192   movw    $(SEG_KDATA<<3), %ax
1193   movw    %ax, %ds
1194   movw    %ax, %es
1195   movw    %ax, %ss
1196   movw    $0, %ax
1197   movw    %ax, %fs
1198   movw    %ax, %gs
1199 
1200   # Turn on page size extension for 4Mbyte pages
1201   movl    %cr4, %eax
1202   orl     $(CR4_PSE), %eax
1203   movl    %eax, %cr4
1204   # Use enterpgdir as our initial page table
1205   movl    (start-12), %eax
1206   movl    %eax, %cr3
1207   # Turn on paging.
1208   movl    %cr0, %eax
1209   orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
1210   movl    %eax, %cr0
1211 
1212   # Switch to the stack allocated by startothers()
1213   movl    (start-4), %esp
1214   # Call mpenter()
1215   call	 *(start-8)
1216 
1217   movw    $0x8a00, %ax
1218   movw    %ax, %dx
1219   outw    %ax, %dx
1220   movw    $0x8ae0, %ax
1221   outw    %ax, %dx
1222 spin:
1223   jmp     spin
1224 
1225 .p2align 2
1226 gdt:
1227   SEG_NULLASM
1228   SEG_ASM(STA_X|STA_R, 0, 0xffffffff)
1229   SEG_ASM(STA_W, 0, 0xffffffff)
1230 
1231 
1232 gdtdesc:
1233   .word   (gdtdesc - gdt - 1)
1234   .long   gdt
1235 
1236 
1237 
1238 
1239 
1240 
1241 
1242 
1243 
1244 
1245 
1246 
1247 
1248 
1249 
