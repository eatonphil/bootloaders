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

goto_end_of_line:
	;; Get current position
	mov ah, 0x08
	int 0x10

	;; Iterate until the character is null
	cmp al, 0
	jz .done

	inc dl
	call set_position
	jmp goto_end_of_line

.done:

	ret

editor_action:
	;; Read character
	mov ah, 0x00
	int 0x16

	;; Handle backspace
	cmp al, 0x08
	jnz .done_backspace

	call get_position

	;; Handle 0,0 coordinate (do nothing)
	mov al, dh
	add al, dl
	jz .overwrite_character

	cmp dl, 0
	jz .backspace_at_start_of_line
	dec dl 			; Decrement column
	call set_position
	jmp .overwrite_character
.backspace_at_start_of_line:
	dec dh 			; Decrement row
	call set_position

	call goto_end_of_line

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

	mov cl, al 		; So we can restore

	;; Handle ctrl-a

	;; Check ctrl key
	;; mov ah, 0x02
	;; int 0x16

	mov al, [0x0417]
	and al, 0x04
	jz .done_ctrl_a

	mov ax, [0x41a]
	cmp ah, 97
	jnz .done_ctrl_a

	mov dl, 0
	call set_position

	ret

.done_ctrl_a:
	mov al, cl 		; Restore al

	;; Handle ctrl-e
	cmp al, 0x12
	jnz .done_ctrl_e

	call goto_end_of_line

	ret

.done_ctrl_e:

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
