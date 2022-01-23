; -*- mode: nasm;-*-
; -*- mode: nasm;-*-
	
bits 16
org 0x7c00

	jmp main

%macro cls 0
	mov ah, 0x00
	mov al, 0x03
	int 0x10
%endmacro

main:
	cls

	mov ah, 0   ;Set display mode
	mov al, 13h ;13h = 320x200, 256 colors
	int  0x10


times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
