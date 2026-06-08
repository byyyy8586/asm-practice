section .data
    prompt_text     db "Enter text: ", 0
    prompt_text_len equ $ - prompt_text

    prompt_pat      db "Enter pattern: ", 0
    prompt_pat_len  equ $ - prompt_pat

    msg_pos         db 10, "First position: ", 0
    msg_pos_len     equ $ - msg_pos

    msg_count       db 10, "Count: ", 0
    msg_count_len   equ $ - msg_count

    newline         db 10, 0
    minus_one       db "-1", 0
    minus_one_len   equ $ - minus_one

section .bss
    text_buf        resb 201
    pat_buf         resb 51
    text_len        resd 1
    pat_len         resd 1
    pos             resd 1
    count           resd 1

section .text
global _start

_start:
    ; Ввід text
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_text
    mov edx, prompt_text_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 200
    int 0x80
    call remove_newline
    mov [text_len], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_pat
    mov edx, prompt_pat_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pat_buf
    mov edx, 50
    int 0x80
    call remove_newline
    mov [pat_len], eax

    cmp dword [pat_len], 0
    je empty_pattern

    call find_substring
    jmp print_results

empty_pattern:
    mov dword [pos], -1
    mov dword [count], 0

print_results:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pos
    mov edx, msg_pos_len
    int 0x80
    mov eax, [pos]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, msg_count_len
    int 0x80
    mov eax, [count]
    call print_number

    call print_newline

    mov eax, 1
    mov ebx, 0
    int 0x80


remove_newline:
    xor eax, eax
.loop:
    cmp byte [ecx + eax], 10
    je .remove
    cmp byte [ecx + eax], 0
    je .done
    inc eax
    jmp .loop
.remove:
    mov byte [ecx + eax], 0
.done:
    ret


find_substring:
    mov dword [pos], -1
    mov dword [count], 0

    mov esi, 0
    mov ebx, [text_len]
    mov edx, [pat_len]

.search:
    cmp esi, ebx
    jge .end

    mov eax, esi
    add eax, edx
    cmp eax, ebx
    jg .end

    push esi
    mov edi, 0

.compare:
    cmp edi, edx
    jge .match

    mov al, [text_buf + esi]
    mov ah, [pat_buf + edi]
    cmp al, ah
    jne .no_match

    inc esi
    inc edi
    jmp .compare

.match:
    pop esi
    cmp dword [pos], -1
    jne .count_it
    mov [pos], esi
.count_it:
    inc dword [count]
    add esi, edx
    jmp .search

.no_match:
    pop esi
    inc esi
    jmp .search

.end:
    ret


print_number:
    cmp eax, -1
    je .minus

    push eax
    push ebx
    push ecx
    push edx

    mov ebx, 10
    mov ecx, text_buf + 50
    mov byte [ecx], 10
    dec ecx

.conv:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    test eax, eax
    jnz .conv

    inc ecx

    mov edx, text_buf + 51
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

.minus:
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_one
    mov edx, minus_one_len
    int 0x80
    ret


print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret