	; -*- mode: nasm;-*-

bits 16
org 0x7c00

	jmp main

%macro cls 0
	mov ah, 0x00
	mov al, 0x03
	int 0x10
%endmacro

%macro clear_key_buffer 0
	mov ax, [0x041a]
	mov [0x041c], ax
%endmacro

%macro read_character 0
	;; Read character
	mov ah, 0
	int 0x16
%endmacro

%macro print_character 1
	mov ax, %1
 	mov ah, 0x0e
 	int 0x10
%endmacro

%macro div3 3
	mov edx, 0        ; clear dividend
	mov eax, %2
	mov ecx, %3
	div ecx
	mov %1, ax
	add %1, 48
%endmacro

%macro print_int 1
	div3 ax, %1, 10000
	print_character ax
	div3 ax, %1, 1000
	print_character ax
	div3 ax, %1, 100
	print_character ax
	div3 ax, %1, 10
	print_character ax
	div3 ax, %1, 1
	print_character ax
%endmacro

%macro get_position 0
	mov ah, 0x03
	int 0x10
%endmacro

%macro set_position 0
	mov ah, 0x02
	int 0x10
%endmacro

goto_end_of_line:
;; Get current character
	mov ah, 0x08
	int 0x10

;; Iterate until the character is null
	cmp al, 0
	jz .done
	jnz .done 		; TODO: remove

	inc dl
	set_position
	jmp goto_end_of_line

.done:
	ret

%macro mov_read_ctrl_flag_into 1
	mov %1, [0x0417]
	and %1, 0x04 		; Grab 3rd bit: %1 & 0b0100
%endmacro

%macro mov_read_character_into 1
	mov ds, [0x041a]
	mov %1, [0x041e]
%endmacro

editor_action:
	read_character

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
 	cmp al, 0x08
 	jz .is_backspace

 	cmp al, 0x7F 		; For mac keyboards
 	jnz .done_backspace

.is_backspace:

 	get_position

;; Handle 0,0 coordinate (do nothing)
 	mov al, dh
 	add al, dl
 	jz .overwrite_character

 	cmp dl, 0
 	jz .backspace_at_start_of_line
 	dec dl 			; Decrement column
 	set_position
 	jmp .overwrite_character
.backspace_at_start_of_line:
 	dec dh 			; Decrement row
 	set_position

 	call goto_end_of_line

.overwrite_character:
 	; mov al, 0
 	; mov ah, 0x0a
 	; int 0x10

 	jmp .done

.done_backspace:

;; Handle enter
	mov_read_character_into ax
 	cmp al, 0x0d
 	jnz .done_enter

 	get_position
 	inc dh 			; Increment line
 	mov dl, 0 		; Reset column
 	set_position

 	jmp .done

.done_enter:

;; Handle ctrl- shortcuts

;; Check ctrl key
	mov_read_ctrl_flag_into ax
  	jz .ctrl_not_set

;; Handle ctrl-a shortcut
	mov_read_character_into ax
	cmp al, 97
	jnz .not_ctrl_a

;; Reset column
  	mov dl, 0
  	set_position

  	jmp .done

.not_ctrl_a:

;; Handle ctrl-e shortcut
	mov_read_character_into ax
	cmp al, 101
	jnz .not_ctrl_e

	call goto_end_of_line
	jmp .done

.not_ctrl_e:
 	jmp .done

.ctrl_not_set:

	mov_read_character_into ax
	print_character ax

.done:
	ret

main:
	cls

.loop:
	;call editor_action
	read_character
	mov ax, [0x0400]
	add ax, [0x041a]
	;print_character ax
	;mov ax, [0x041a]
	print_int 6234
	jmp .loop

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
