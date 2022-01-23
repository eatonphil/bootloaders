bits 16
org 0x7c00

	jmp main

%macro print_character 1
        mov ax, %1
        mov ah, 0x0e
        int 0x10
%endmacro

%macro div3 3
        mov eax, %2
        mov ecx, %3
        mov edx, 0
        div ecx
        add eax, 48             ; Convert to ascii number
%endmacro

%macro print_uint8 1
        mov eax, %1
        and eax, 0xFF           ; Truncate to 1 byte
        div3 ax, eax, 100
        print_character ax
        div3 ax, edx, 10
        print_character ax
        add dx, 48              ; Convert remainder to ascii number
        print_character dx
%endmacro

main:
        ;; Clear screen
        mov ah, 0x00
        mov al, 0x03
        int 0x10

	print_uint8 345

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
