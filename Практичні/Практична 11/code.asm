section .data
    prompt      db "Enter height h (5-25): ", 0
    prompt_len  equ $ - prompt
    newline     db 10, 0

section .bss
    input_buf   resb 16
    height      resd 1
    line_buf    resb 160

section .text
global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 15
    int 0x80

    call atoi
    mov [height], eax

    mov esi, 1                
draw_loop:
    cmp esi, [height]
    jg finish

    push esi

    ; Пробіли зліва = height - esi
    mov eax, [height]
    sub eax, esi
    call print_spaces

    ; Зірочки = 2*esi - 1
    pop esi
    push esi

    mov eax, esi
    shl eax, 1
    dec eax
    call print_stars

    call print_newline

    pop esi
    inc esi
    jmp draw_loop

finish:
    mov eax, 1
    mov ebx, 0
    int 0x80


print_spaces:
    push esi
    push ecx
    mov ecx, eax
    jecxz .end
    mov edi, line_buf
.sp:
    mov byte [edi], ' '
    inc edi
    loop .sp
    call print_line
.end:
    pop ecx
    pop esi
    ret


print_stars:
    push esi
    push ecx
    mov ecx, eax
    jecxz .end
    mov edi, line_buf
.st:
    mov byte [edi], '*'
    inc edi
    loop .st
    call print_line
.end:
    pop ecx
    pop esi
    ret


print_line:
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, edi
    sub edx, line_buf
    int 0x80
    ret


print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret


atoi:
    xor eax, eax
.loop:
    movzx ebx, byte [ecx]
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc ecx
    jmp .loop
.done:
    ret