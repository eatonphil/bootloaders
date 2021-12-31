bits 16
org 0x7c00

main:
	;; Clear screen
	mov ah, 0x00
	mov al, 0x03
	int 0x10

.loop:
	;; Read character
	mov ah, 0x00
	int 0x16

	;; Print character
	mov ah, 0x0e
	int 0x10

	jmp .loop

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
