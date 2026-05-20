; -*- tab-width: 8 -*-
; MBR Stage1: load Stage2 flat binary starting at STAGE2_LBA into STAGE2_LOAD_SEG:0
; Assemble: nasm -f bin -o mbr.bin mbr.asm

%include "../../bios/include/stage2_layout.inc"

[BITS 16]
[ORG 0x7C00]

BOOT_DRIVE_SAVE equ 0x0500
DAP_BASE        equ 0x0600

start:
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0x7C00
	sti
	mov	[BOOT_DRIVE_SAVE], dl

	mov	si, msg_load
	call	puts_real

	mov	bx, 0x55AA
	mov	ah, 0x41
	int	0x13
	jc	.noext
	cmp	bx, 0xAA55
	jne	.noext
	test	cx, 1
	jz	.noext
	jmp	.load

.noext:
	mov	si, msg_noext
	call	puts_real
	jmp	$

.load:
	; Disk Address Packet at 0000:0600
	mov	byte [DAP_BASE], 16
	mov	byte [DAP_BASE+1], 0
	mov	word [DAP_BASE+2], STAGE2_SECTOR_COUNT
	mov	word [DAP_BASE+4], STAGE2_LOAD_OFF
	mov	word [DAP_BASE+6], STAGE2_LOAD_SEG
	mov	dword [DAP_BASE+8], STAGE2_LBA
	mov	dword [DAP_BASE+12], 0

	mov	si, DAP_BASE
	mov	ah, 0x42
	mov	dl, [BOOT_DRIVE_SAVE]
	int	0x13
	jc	.readfail

	mov	dl, [BOOT_DRIVE_SAVE]
	push	word STAGE2_LOAD_SEG
	push	word STAGE2_LOAD_OFF
	retf

.readfail:
	mov	si, msg_read
	call	puts_real
	jmp	$

puts_real:
	pusha
	mov	ah, 0x0E
	mov	bh, 0
	mov	bl, 7
.loop:
	lodsb
	test	al, al
	jz	.done
	int	0x10
	jmp	.loop
.done:
	popa
	ret

msg_load:
	db "Chain ", 0
msg_noext:
	db "No LBA BIOS", 0
msg_read:
	db "Stage2 read err", 0

times 0x1BE - ($ - $$) db 0

partitions:
	times 64 db 0

dw 0xAA55
