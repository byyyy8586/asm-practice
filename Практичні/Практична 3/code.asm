section .data
    prompt db 'Enter number (0-99999): ', 0
    prompt_len equ $ - prompt

section .bss
    input resb 10     

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
    mov ecx, input
    mov edx, 10
    int 0x80

    mov esi, input
    xor eax, eax
parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, 0
    je parse_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp parse_loop
parse_done:

    mov edi, input + 9
    mov byte [edi], 10
    dec edi
    mov ecx, 0

convert_loop:
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test eax, eax
    jnz convert_loop

    lea ecx, [edi+1]
    mov edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80