; Stage2 real-mode chain loader (MBR + GPT + VBR)
; nasm -f bin -o stage2.bin stage2.asm

[BITS 16]
[CPU 386]

%include "../include/stage2_layout.inc"

BOOT_DL         equ 0x0500

[ORG 0]

STAGE2_SEG      equ 0x1000
SECT_BUF        equ 0x8000
GPT_BUF         equ 0x9000
ENT_BUF         equ 0x9800
MAX_SHOWN       equ 16
TIMEOUT_TICKS   equ 180

start:
	cli
	mov	ax, STAGE2_SEG
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0xE000
	sti

	xor	ax, ax
	mov	fs, ax
	mov	al, [fs:BOOT_DL]
	mov	[boot_drive], al

	mov	si, title_msg
	call	puts

	xor	eax, eax
	xor	ax, ax
	mov	es, ax
	mov	bx, SECT_BUF
	call	read_lba_esbx_es
	jc	.err_read

	call	verify_mbr_sig
	jne	.err_mbr

	call	is_gpt_disk
	cmp	ax, 1
	je	.do_gpt
	call	mbr_fill_list
	jmp	.after_list

.do_gpt:
	call	gpt_fill_list

.after_list:
	mov	si, key_msg
	call	puts
	call	await_choice
	jmp	$

.err_read:
	mov	si, err_read
	call	puts
	jmp	$
.err_mbr:
	mov	si, err_mbr
	call	puts
	jmp	$

verify_mbr_sig:
	mov	bx, SECT_BUF
	mov	ax, [fs:bx+0x1FE]
	cmp	ax, 0xAA55
	ret

is_gpt_disk:
	push	si
	push	cx
	mov	si, 0x1BE + SECT_BUF
	mov	cx, 4
.lp:
	mov	al, [fs:si+4]
	cmp	al, 0xEE
	je	.yes
	add	si, 16
	loop	.lp
	xor	ax, ax
	pop	cx
	pop	si
	ret
.yes:
	mov	ax, 1
	pop	cx
	pop	si
	ret


mbr_fill_list:
	mov	dword [entry_count], 0
	mov	cx, 4
	mov	si, 0x1BE + SECT_BUF
.lp:
	mov	al, [fs:si+4]
	test	al, al
	jz	.sk
	mov	eax, [fs:si+8]
	test	eax, eax
	jz	.sk
	mov	edi, [entry_count]
	cmp	edi, MAX_SHOWN
	jae	.done
	mov	[entry_lba + edi*4], eax
	inc	dword [entry_count]
.sk:
	add	si, 16
	loop	.lp
.done:
	jmp	print_list

gpt_fill_list:
	mov	eax, 1
	xor	ax, ax
	mov	es, ax
	mov	bx, GPT_BUF
	call	read_lba_esbx_es
	jc	.gerr

	mov	bx, GPT_BUF
	mov	eax, [fs:bx]
	mov	ecx, [fs:bx+4]
	cmp	eax, 0x20494645
	jne	.gerr
	cmp	ecx, 0x54524150
	jne	.gerr

	mov	eax, [fs:bx+0x48]
	mov	[gpt_entry_lba], eax
	mov	eax, [fs:bx+0x50]
	mov	[gpt_num_ent], eax
	mov	eax, [fs:bx+0x54]
	mov	[gpt_ent_size], eax

	mov	dword [entry_count], 0
	mov	esi, 0
.gloop:
	mov	eax, [gpt_num_ent]
	cmp	esi, eax
	jge	print_list
	cmp	dword [entry_count], MAX_SHOWN
	jge	print_list

	mov	eax, [gpt_ent_size]
	cmp	eax, 0
	je	.gerr
	imul	eax, esi
	mov	ebx, eax
	shr	ebx, 9
	mov	ecx, eax
	and	ecx, 511

	mov	eax, [gpt_entry_lba]
	add	eax, ebx
	push	ecx
	xor	ax, ax
	mov	es, ax
	mov	bx, ENT_BUF
	call	read_lba_esbx_es
	pop	ecx
	jc	.gerr

	mov	eax, [gpt_ent_size]
	imul	eax, esi
	and	eax, 511
	mov	edi, eax
	mov	bx, ENT_BUF
	add	bx, di

	mov	eax, [fs:bx]
	or	eax, [fs:bx+4]
	or	eax, [fs:bx+8]
	or	eax, [fs:bx+12]
	jz	.gskip

	mov	eax, [fs:bx+32]
	mov	edi, [entry_count]
	mov	[entry_lba + edi*4], eax
	inc	dword [entry_count]

.gskip:
	inc	esi
	jmp	.gloop

.gerr:
	mov	si, err_gpt
	call	puts
	ret

print_list:
	xor	ebx, ebx
.pl:
	cmp	ebx, [entry_count]
	jge	.pd
	mov	si, spc
	call	puts
	mov	eax, ebx
	add	al, '1'
	mov	[onechar], al
	mov	si, onechar
	call	puts
	mov	si, colon_lba
	call	puts
	mov	eax, [entry_lba + ebx*4]
	call	put_hex32
	mov	si, nl
	call	puts
	inc	ebx
	jmp	.pl
.pd:
	ret

await_choice:
	mov	cx, TIMEOUT_TICKS
.wait:
	mov	ah, 1
	int	0x16
	jnz	.got
	dec	cx
	jz	.pick_def
	test	cx, cx
	jnz	.wait
.pick_def:
	movzx	eax, byte [default_idx]
	jmp	do_chain_index

.got:
	xor	ah, ah
	int	0x16
	cmp	al, '1'
	jb	.await_retry
	cmp	al, '9'
	jbe	.idx_digit
	cmp	al, 'a'
	jb	.await_retry
	cmp	al, 'f'
	jbe	.idx_hex
.await_retry:
	jmp	await_choice

.idx_digit:
	sub	al, '1'
	movzx	eax, al
	jmp	do_chain_index

.idx_hex:
	sub	al, 'a'
	add	al, 9
	movzx	eax, al

do_chain_index:
	cmp	eax, [entry_count]
	jae	await_choice
	mov	eax, [entry_lba + eax*4]
	test	eax, eax
	jz	await_choice
	jmp	chain_partition

chain_partition:
	xor	ax, ax
	mov	es, ax
	mov	bx, 0x7C00
	call	read_lba_esbx_es
	jc	.badchain
	mov	bx, 0x7C00
	mov	ax, [fs:bx+0x1FE]
	cmp	ax, 0xAA55
	jne	.badchain
	mov	dl, [boot_drive]
	push	word 0
	push	word 0x7C00
	retf
.badchain:
	mov	si, err_chain
	call	puts
	jmp	$

; IN: EAX=LBA, ES:BX = destination
read_lba_esbx_es:
	mov	[saved_eax], eax
	mov	word [saved_es], es
	mov	word [saved_bx], bx
	mov	[dap_pkt+0], byte 16
	mov	[dap_pkt+1], byte 0
	mov	[dap_pkt+2], word 1
	mov	ax, [saved_bx]
	mov	[dap_pkt+4], ax
	mov	ax, [saved_es]
	mov	[dap_pkt+6], ax
	mov	eax, [saved_eax]
	mov	[dap_pkt+8], eax
	mov	[dap_pkt+12], dword 0

	push	ds
	mov	ax, STAGE2_SEG
	mov	ds, ax
	mov	si, dap_pkt
	mov	ah, 0x42
	mov	dl, [boot_drive]
	int	0x13
	pop	ds
	jc	.read_fail
	clc
	ret
.read_fail:
	stc
	ret

saved_eax	dd 0
saved_es	dw 0
saved_bx	dw 0

dap_pkt	times 16 db 0

puts:
	pusha
	mov	ah, 0x0E
	mov	bh, 0
	mov	bl, 7
.pl:
	lodsb
	test	al, al
	jz	.pd
	int	0x10
	jmp	.pl
.pd:
	popa
	ret

put_hex32:
	push eax
	push ebx
	push ecx
	mov	ebx, eax
	mov	cx, 8
.ph:
	rol	ebx, 4
	mov	al, bl
	and	al, 0x0F
	cmp	al, 10
	jl	.dig
	add	al, 'a'-10
	jmp	.pr
.dig:
	add	al, '0'
.pr:
	mov	ah, 0x0E
	mov	bh, 0
	int	0x10
	loop	.ph
	pop	ecx
	pop	ebx
	pop	eax
	ret

title_msg   db "MOS Stage2", 13, 10, 0
key_msg     db "Key 1-f / wait", 13, 10, 0
spc         db " ", 0
colon_lba   db " LBA ", 0
nl          db 13, 10, 0
err_read    db "read err", 13, 10, 0
err_mbr     db "bad MBR", 13, 10, 0
err_gpt     db "GPT err", 13, 10, 0
err_chain   db "chain err", 13, 10, 0

boot_drive    db 0
default_idx   db 0
entry_count   dd 0
gpt_entry_lba dd 0
gpt_num_ent   dd 0
gpt_ent_size  dd 0
onechar       db "?", 0, 0

entry_lba times MAX_SHOWN dd 0

times (($$ + 512 - 1) / 512) * 512 - ($ - $$) db 0
