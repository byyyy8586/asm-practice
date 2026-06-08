section .data
    prompt     db 'Enter n (0-12): ', 0
    prompt_len equ $ - prompt
    fact_msg   db 'fact(n) = ', 0
    calls_msg  db 'calls = ', 0
    newline    db 10, 0

    num_buffer times 12 db 0

section .bss
    n      resd 1
    calls  resd 1

section .text
global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    call read_number
    mov [n], eax

    mov dword [calls], 0

    push dword [n]
    call factorial
    add esp, 4

    push eax                

    mov eax, 4
    mov ebx, 1
    mov ecx, fact_msg
    mov edx, 10
    int 0x80

    pop eax
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, calls_msg
    mov edx, 8
    int 0x80

    mov eax, [calls]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

factorial:
    inc dword [calls]

    push ebp
    mov ebp, esp

    mov ecx, [ebp + 8]    

    cmp ecx, 1
    jle base_case

    dec ecx
    push ecx
    call factorial
    add esp, 4

    mov ecx, [ebp + 8]   
    imul eax, ecx

    jmp end_fact

base_case:
    mov eax, 1

end_fact:
    pop ebp
    ret

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