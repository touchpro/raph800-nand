@
@ Tinboot_mod
@ Very simple bootloader for HTC Raph800 modified from Vogue
@ LuYU426.
@ Original author : Martin Johnson - M.J.Johnson@massey.ac.nz
@

.equ	LOAD_START, 	0x10000000
.equ	RAM_START, 	0x10000000
.equ	RAM_SIZE, 	0x10000000
.equ	INITRD_START, 	RAM_START+0x00800000

.equ	KERNEL_OFFSET,  0x8000
.equ	XIP_END,	0x600000

		.org 0
		b boot

		.org 0x40
		.word 0x43454345
		.word romhdr+0x80000000				@ location of wince romhdr 
		.word romhdr
.org 0x100
tags:		.word 5,0x54410001,1,0x1000,0 			@ ATAG_CORE, pagesize=4K
		.word 4,0x54410002,RAM_SIZE,RAM_START		@ ATAG_MEM
		.word 4,0x54420005,INITRD_START,fin-initrd	@ ATAG_INITRD2
cmdline_start:	.word (cmdline_end-cmdline_start)/4,0x54410009	@ ATAG_CMDLINE


@.ifdef rhod
@.asciz "gsensor_axis=2,1,3 msmvkeyb_toggle=off htc_hw.force_cdma=1 panic=0 pm.sleep_mode=1 mtdparts=msm_nand:0x20000000@0x0(nand),0x800000@0x8000000(recovery),0x0A000000@0x8800000(system),0xB800000@0x12800000(userdata),0x2000000@0x1E000000(cache)"
@.endif

.ifdef raph800
.asciz "msmvkeyb_toggle=off board-htcraphael-navi.wake=0 pmem.extra=1 gsensor_axis=-2,1,-3 pm.sleep_mode=1  mtdparts=msm_nand:0x20000000@0x0(nand),0x2000000@0x6000000(root),0x800000@0x8000000(recovery),0x0A000000@0x8800000(system),0xB800000@0x12800000(userdata),0x2000000@0x1E000000(cache)"
.endif
@ mtdparts=msm_nand:0x20000000@0x0(nand),0x800000@0x8000000(recovery),0x0A000000@0x8800000(system),0xB800000@0x12800000(userdata),0x2000000@0x1E000000(cache) 
@ root_partition=/dev/block/mmcblk1p2  pm.sleep_mode=1
		.align
cmdline_end:	.word 0,0					@ ATAG_END

		.org 0x00001000

boot:		ldr r0,loadstart_ptr
		ldr r1,ramstart_ptr
		ldr r3,fin_ptr

copycode:	ldr r2,[r0],#4
		str r2,[r1],#4
		cmp r1,r3
		blo copycode
@		ldr pc,start_ptr

start:		ldr r0,initrd_ptr
		ldr r3,fin_ptr
		ldr r1,ird_start_ptr

copyinitrd:	ldr r2,[r0],#4
		str r2,[r1],#4
		cmp r0,r3
		blo copyinitrd

		mov r0,#0
		ldr r1,mtype
		ldr r2,tags_addr
		ldr pc,kernel_start

mtype:		.word MTYPE
start_ptr:	.word start+RAM_START
loadstart_ptr:	.word LOAD_START
ramstart_ptr:	.word RAM_START
initrd_ptr:	.word initrd+RAM_START
fin_ptr:	.word fin+RAM_START
ird_start_ptr:	.word INITRD_START
kernel_start:	.word RAM_START+0x8000
tags_addr:	.word RAM_START+0x100

romhdr:
		.word 0x0		@ dllfirst
		.word 0x0		@ dlllast
		.word 0x80000000	@ physfirst
		.word 0x80000000+fin	@ physlast
		.word 0			@ num mods
		.word 0x80000000+fin	@ ramstart
		.word 0x80000000	@ ramfree
		.word 0x83000000	@ ramend
		.word 0			@ copyentries
		.word 0x80000000	@ copyoffset
		.word 0			@ profilelen
		.word 0			@ profileoffset
		.word 0			@ numfileshy
		.word 0			@ flags
		.word 0x20		@ fsrampercent
		.word 0			@ drvglobstart
		.word 0			@ drvgloblen
		.word 0x201c2		@ cputype/flags
		.word 0x80000000	@ pextensions
		.word 0			@ trackingstart
		.word 0			@ trackinglen

		.org KERNEL_OFFSET
kernel:
		.incbin "kernel/zImage"
initrd:
		.incbin	"kernel/initrd.gz"
		.align
fin:
