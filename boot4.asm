bits 16
org 0x7c00
jmp main

cls:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret

get_position:
	mov ah, 0x03
	int 0x10
	ret

set_position:
	mov ah, 0x02
	int 0x10
	ret

editor_action:
	;; Read character
	mov ah, 0x00
	int 0x16

	;; Handle backspace
	cmp al, 0x08
	jnz .done_backspace

	call get_position

	cmp dl, 0
	jz .start_of_line
	dec dl 			; Decrement column
	call set_position
	jmp .overwrite_character
.start_of_line:
	dec dh 			; Decrement row
	call set_position

.overwrite_character:
	mov al, 0
	mov ah, 0x0a
	int 0x10

	ret

.done_backspace:

	;; Handle enter
	cmp al,0x0d
	jnz .done_enter

	call get_position
	inc dh 			; Increment line
	mov dl, 0 		; Reset column
	call set_position

	ret

.done_enter:

	;; Print input
	mov ah, 0x0e
	int 0x10

	ret

main:
	call cls

.loop:
	call editor_action
	jmp .loop

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
