	; -*- mode: nasm;-*-

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
;; Get current character
	xor bx, bx
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
	mov ah, 0
	int 0x16

;; Store ctrl-set flag is 1 from top of stack
  	mov bx, [0x0417]
  	and bx, 0x04 		; Grab 3rd bit: & 0b0100
 	push bx

;; Check pressed key directly
  	;mov ax, [0x041e] ; Read character is top of stack
	push ax

;; Ignore arrow keys
	cmp ah, 0x4b 		; Left
	jz .done
	cmp ah, 0x50 		; Down
	jz .done
	cmp ah, 0x4d 		; Right
	jz .done
	cmp ah, 0x48 		; Up
	jz .done

;; Handle backspace
	mov ax, [esp]
 	cmp al, 0x08
 	jz .is_backspace

 	cmp al, 0x7F 		; For mac keyboards
 	jnz .done_backspace

.is_backspace:

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

 	jmp .done

.done_backspace:

;; Handle enter
	mov ax, [esp]
 	cmp al, 0x0d
 	jnz .done_enter

 	call get_position
 	inc dh 			; Increment line
 	mov dl, 0 		; Reset column
 	call set_position

 	jmp .done

.done_enter:

;; Handle ctrl- shortcuts

;; Check ctrl key
	mov ax, [esp+1]
  	jz .ctrl_not_set

;; Handle ctrl-a shortcut
	mov ax, [esp]
	cmp al, 97
	jnz .not_ctrl_a

;; Reset column
  	mov dl, 0
  	call set_position

  	jmp .done

.not_ctrl_a:

;; Handle ctrl-e shortcut
	mov ax, [esp]
	mov ah, 0x0e
	int 0x10
	mov ax, [esp]
	cmp al, 101
	jnz .not_ctrl_e

	call goto_end_of_line
	jmp .done

.not_ctrl_e:
 	jmp .done

.ctrl_not_set:

;; Print input
	mov ax, [esp]
 	mov ah, 0x0e
 	int 0x10

.done:
	pop ax
	pop ax
 	ret

main:
	call cls

.loop:
	call editor_action
	jmp .loop

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
