section .data
    prompt      db "Введіть число x: ", 0
    prompt_len  equ $ - prompt

    newline     db 0x0A, 0

section .bss
    buffer      resb 32     
    number      resd 1      
    sum_digits  resd 1      
    digit_count resd 1     

section .text
global _start

_start:

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Прочитати число як рядок
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

    call atoi
    mov [number], eax

    mov eax, [number]
    xor ebx, ebx           
    xor ecx, ecx           

calculate_loop:
    cmp eax, 0
    je calculation_done

    xor edx, edx       
    mov edi, 10
    div edi                 

    add ebx, edx          
    inc ecx               

    jmp calculate_loop

calculation_done:
    mov [sum_digits], ebx
    mov [digit_count], ecx

    mov eax, [sum_digits]
    call print_number
    call print_newline

    mov eax, [digit_count]
    call print_number
    call print_newline

    mov eax, [sum_digits]
    add eax, 0             
    call print_number
    call print_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
    mov esi, buffer

atoi_loop:
    movzx edx, byte [esi]
    cmp dl, 0x0A           
    je atoi_done
    cmp dl, 0
    je atoi_done
    cmp dl, '0'
    jb atoi_done
    cmp dl, '9'
    ja atoi_done

    imul eax, eax, 10
    sub dl, '0'
    add eax, edx

    inc esi
    jmp atoi_loop

atoi_done:
    ret


print_number:
    push eax
    mov edi, buffer + 30
    mov byte [edi], 0
    mov ecx, 10

print_loop:
    xor edx, edx
    div ecx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz print_loop

    mov eax, 4
    mov ebx, 1
    lea ecx, [edi]
    mov edx, buffer + 30
    sub edx, edi
    inc edx
    int 0x80

    pop eax
    ret

print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret