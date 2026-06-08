section .data
    prompt_n     db 'Enter n (10-100): ', 0
    prompt_n_len equ $ - prompt_n
    prompt_nums  db 'Enter ', 0
    prompt_nums2 db ' numbers:', 10, 0
    orig_msg     db 'Original array: ', 0
    sorted_msg   db 'Sorted array: ', 0
    median_msg   db 'Median: ', 0
    space        db ' ', 0
    newline      db 10, 0

    num_buffer times 12 db 0
    array      times 100 dd 0

section .bss
    n resd 1

section .text
global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_n
    mov edx, prompt_n_len
    int 0x80

    call read_number
    mov [n], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_nums
    mov edx, 7
    int 0x80
    mov eax, [n]
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_nums2
    mov edx, 10
    int 0x80

    ; Читання масиву
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

    mov eax, 4
    mov ebx, 1
    mov ecx, orig_msg
    mov edx, 16
    int 0x80
    call print_array

    call selection_sort

    mov eax, 4
    mov ebx, 1
    mov ecx, sorted_msg
    mov edx, 14
    int 0x80
    call print_array

    call calculate_median

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

    push ecx
    push esi
    mov eax, [esi]
    call print_number
    pop esi
    pop ecx

    push ecx
    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop esi
    pop ecx

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

selection_sort:
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0
outer_loop:
    cmp ecx, [n]
    jge sort_done
    mov ebx, ecx
    mov esi, ecx
    inc esi
inner_loop:
    cmp esi, [n]
    jge inner_done
    mov eax, [array + ebx*4]
    cmp eax, [array + esi*4]
    jle no_swap
    mov ebx, esi
no_swap:
    inc esi
    jmp inner_loop
inner_done:
    mov eax, [array + ecx*4]
    mov edx, [array + ebx*4]
    mov [array + ecx*4], edx
    mov [array + ebx*4], eax
    inc ecx
    jmp outer_loop
sort_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

calculate_median:
    push eax
    push ebx

    mov eax, 4
    mov ebx, 1
    mov ecx, median_msg
    mov edx, 8
    int 0x80

    mov eax, [n]
    shr eax, 1
    test dword [n], 1
    jnz odd_case
    dec eax
odd_case:
    mov ebx, [array + eax*4]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop ebx
    pop eax
    ret