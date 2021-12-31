bits 16
org 0x7c00

main:
	;; Clear screen
	mov ah, 0x00
	mov al, 0x03
	int 0x10

.loop:
	;; Read character
.wait_for_input:
	mov ah, 0x01
	int 0x16
	jz .wait_for_input

	;; Print character
	mov ah, 0x0e
	int 0x10

	;; Clear key buffer
	mov ax, [0x041a]
	mov [0x041c], ax

	jmp .loop

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
