section .data
    prompt db 'Enter n (5-200): ', 0
    prompt_len equ $ - prompt
    input_msg db 'Enter ', 0
    numbers_msg db ' numbers:', 10, 0
    orig_msg db 'Original array: ', 0
    rev_msg db 'Reversed array: ', 0
    pal_yes db 'PALINDROME: YES', 10, 0
    pal_no db 'PALINDROME: NO', 10, 0
    space db ' ', 0
    newline db 10, 0

    num_buffer times 12 db 0
    array times 200 dd 0
    rev_array times 200 dd 0

section .bss
    n resd 1

section .text
global _start

_start:
    ; Ввід n
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    call read_number
    mov [n], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, input_msg
    mov edx, 7
    int 0x80
    mov eax, [n]
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, numbers_msg
    mov edx, 10
    int 0x80

    xor ecx, ecx
    mov esi, array
read_loop:
    cmp ecx, [n]
    jge read_done
    call read_number
    mov [esi], eax
    add esi, 4
    inc ecx
    jmp read_loop
read_done:

    mov ecx, [n]
    mov esi, array
    mov edi, rev_array
    lea edi, [edi + ecx*4 - 4]
reverse_copy:
    mov eax, [esi]
    mov [edi], eax
    add esi, 4
    sub edi, 4
    loop reverse_copy

    mov eax, 4
    mov ebx, 1
    mov ecx, orig_msg
    mov edx, 16
    int 0x80
    call print_array

    mov eax, 4
    mov ebx, 1
    mov ecx, rev_msg
    mov edx, 16
    int 0x80
    call print_rev_array

    call check_palindrome
    cmp eax, 1
    je is_pal
    mov eax, 4
    mov ebx, 1
    mov ecx, pal_no
    mov edx, 15
    int 0x80
    jmp exit_prog
is_pal:
    mov eax, 4
    mov ebx, 1
    mov ecx, pal_yes
    mov edx, 16
    int 0x80

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80

read_number:
    push ebx
    push ecx
    push edx
    push esi
    mov eax, 3
    mov ebx, 0
    mov ecx, num_buffer
    mov edx, 12
    int 0x80

    mov esi, num_buffer
    xor eax, eax
parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, 0
    je parse_done
    cmp bl, '0'
    jb parse_next
    cmp bl, '9'
    ja parse_next
    sub bl, '0'
    imul eax, 10
    add eax, ebx
parse_next:
    inc esi
    jmp parse_loop
parse_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

print_number:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, num_buffer + 11
    mov byte [ecx], 0
    mov ebx, 10
print_loop:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz print_loop

    mov edx, num_buffer + 11
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_array:
    push ecx
    push esi
    xor ecx, ecx
    mov esi, array
print_arr_loop:
    cmp ecx, [n]
    jge print_arr_done
    mov eax, [esi]
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    add esi, 4
    inc ecx
    jmp print_arr_loop
print_arr_done:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop esi
    pop ecx
    ret

print_rev_array:
    push ecx
    push esi
    xor ecx, ecx
    mov esi, rev_array
print_rev_loop:
    cmp ecx, [n]
    jge print_rev_done
    mov eax, [esi]
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    add esi, 4
    inc ecx
    jmp print_rev_loop
print_rev_done:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop esi
    pop ecx
    ret

check_palindrome:
    push ecx
    push esi
    push edi
    mov ecx, [n]
    mov esi, array
    mov edi, rev_array
pal_loop:
    test ecx, ecx
    jle is_pal_true
    mov eax, [esi]
    cmp eax, [edi]
    jne is_pal_false
    add esi, 4
    add edi, 4
    dec ecx
    jmp pal_loop
is_pal_true:
    mov eax, 1
    jmp pal_done
is_pal_false:
    xor eax, eax
pal_done:
    pop edi
    pop esi
    pop ecx
    ret