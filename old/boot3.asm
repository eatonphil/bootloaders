bits 16
org 0x7c00
jmp main

cls:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret

print:
	mov si,ax
	mov ah,0x0e

	.loop:
	lodsb
	or al,al
	jz .done
	int 0x10
	jmp .loop

	.done:
	ret

drawpixel:
	mov ax,0x13
	int 0x10

	mov edi,0x0a00
	mov al,0x0F      ; the color of the pixel
	mov [edi],al
	ret

main:
	call cls

	call drawpixel

	mov ax,hello
	call print

	call exit

exit:
    cli
    hlt

hello: db "Hello world!",0

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
