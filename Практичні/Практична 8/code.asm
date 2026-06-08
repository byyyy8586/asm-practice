section .data
    msg_n       db "Введіть n (10-100): ", 0
    msg_array   db "Введіть елементи масиву: ", 0
    msg_target  db "Введіть target: ", 0
    msg_first   db 10, "Перший індекс: ", 0
    msg_count   db 10, "Кількість входжень: ", 0
    msg_indices db 10, "Індекси: ", 0
    msg_not     db 10, "Не знайдено", 10, 0
    space       db " ", 0
    newline     db 10, 0

section .bss
    n           resd 1
    target      resd 1
    array       resd 100
    indices     resd 100
    count       resd 1
    first_index resd 1
    buffer      resb 32

section .text
global _start

_start:
    ; Ввід n
    mov edx, msg_n
    call print_str
    call read_int
    mov [n], eax

    mov edx, msg_array
    call print_str
    call print_newline

    mov ecx, [n]
    mov edi, array
read_array:
    push ecx
    push edi
    call read_int
    pop edi
    pop ecx
    mov [edi], eax
    add edi, 4
    loop read_array

    mov edx, msg_target
    call print_str
    call read_int
    mov [target], eax

    mov dword [count], 0
    mov dword [first_index], -1
    mov esi, 0
    mov edi, array
    mov ecx, [n]

search:
    cmp esi, ecx
    jge search_end

    mov eax, [edi]
    cmp eax, [target]
    jne next_elem

    mov ebx, [count]
    mov [indices + ebx*4], esi
    inc dword [count]

    cmp dword [first_index], -1
    jne next_elem
    mov [first_index], esi

next_elem:
    add edi, 4
    inc esi
    jmp search

search_end:

    mov edx, msg_first
    call print_str

    cmp dword [count], 0
    je not_found_case

    mov eax, [first_index]
    call print_int
    jmp print_count_part

not_found_case:
    mov edx, msg_not
    call print_str
    jmp finish

print_count_part:
    mov edx, msg_count
    call print_str
    mov eax, [count]
    call print_int

    mov edx, msg_indices
    call print_str

    mov ecx, [count]
    mov esi, 0
print_idx:
    cmp esi, ecx
    jge finish

    mov eax, [indices + esi*4]
    call print_int
    mov edx, space
    call print_str

    inc esi
    jmp print_idx

finish:
    call print_newline

    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80


read_int:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

    mov esi, buffer
    xor eax, eax
    xor ebx, ebx
parse:
    mov bl, [esi]
    cmp bl, 10
    je done_read
    cmp bl, 32
    je done_read
    cmp bl, 0
    je done_read

    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp parse
done_read:
    ret

print_str:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, edx
    xor edx, edx
len_loop:
    cmp byte [ecx + edx], 0
    je write_str
    inc edx
    jmp len_loop
write_str:
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_newline:
    mov edx, newline
    call print_str
    ret

print_int:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, buffer + 31
    mov byte [ecx], 0
    mov ebx, 10

conv_loop:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz conv_loop

    mov edx, ecx
    call print_str

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret