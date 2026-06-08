section .data
    prompt_n     db  "Enter n (5-50): ", 0
    len_n        equ $ - prompt_n

    msg_min      db  "Min = ", 0
    len_min      equ $ - msg_min

    msg_max      db  "Max = ", 0
    len_max      equ $ - msg_max

    msg_idx      db  ", index = ", 0
    len_idx      equ $ - msg_idx

    newline      db  10

section .bss
    n            resd 1
    array        resd 50
    min_val      resd 1
    min_idx      resd 1
    max_val      resd 1
    max_idx      resd 1
    buffer       resb 16

section .text
    global _start

_start:
    ; Ввід n
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_n
    mov edx, len_n
    int 0x80

    call read_number
    mov [n], eax

    mov ecx, 0
fill:
    cmp ecx, [n]
    jge fill_end

    mov eax, ecx
    shl eax, 1          ; eax = i * 2
    add eax, 5          ; array[i] = i*2 + 5

    mov [array + ecx*4], eax

    inc ecx
    jmp fill
fill_end:

    mov eax, [array]
    mov [min_val], eax
    mov [max_val], eax
    mov dword [min_idx], 0
    mov dword [max_idx], 0

    mov ecx, 1
find_loop:
    cmp ecx, [n]
    jge find_done

    mov eax, [array + ecx*4]

    cmp eax, [min_val]
    jge no_new_min
    mov [min_val], eax
    mov [min_idx], ecx
no_new_min:

    cmp eax, [max_val]
    jle no_new_max
    mov [max_val], eax
    mov [max_idx], ecx
no_new_max:

    inc ecx
    jmp find_loop
find_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, len_min
    int 0x80
    mov eax, [min_val]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_idx
    int 0x80
    mov eax, [min_idx]
    call print_number
    call print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, len_max
    int 0x80
    mov eax, [max_val]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_idx
    int 0x80
    mov eax, [max_idx]
    call print_number
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80


read_number:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 15
    int 0x80

    mov esi, buffer
    xor eax, eax
    mov ebx, 10
conv:
    movzx edx, byte [esi]
    cmp edx, 10
    je .done
    sub edx, '0'
    imul eax, ebx
    add eax, edx
    inc esi
    jmp conv
.done:
    ret


print_number:
    push ebx
    mov ebx, 10
    mov ecx, buffer + 15
    mov byte [ecx], 0
    dec ecx

    test eax, eax
    jnz .loop
    mov byte [ecx], '0'
    dec ecx
    jmp .print

.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    test eax, eax
    jnz .loop

.print:
    inc ecx
    mov edx, buffer + 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    ret


print_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret