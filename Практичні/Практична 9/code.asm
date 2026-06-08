section .data
    msg_n       db "Введіть n (100-1000):
    newline     db 10, 0
    colon       db ": ", 0
    lbracket    db " (", 0
    rbracket    db ")", 0
    hash        db "#", 0

section .bss
    n           resd 1
    x           resd 1         
    freq        resd 10      
    buffer      resb 20

section .text
global _start

_start:
    call init_freq

    mov edx, msg_n
    call print_str
    call read_int
    mov [n], eax

    mov dword [x], 12345

    mov ecx, [n]
generate:
    call lcg_next      
    call inc_frequency
    loop generate

    call print_histogram

    mov eax, 1
    xor ebx, ebx
    int 0x80

lcg_next:
    mov eax, [x]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7FFFFFFF     
    mov [x], eax

    mov ebx, 10
    xor edx, edx
    div ebx
    mov eax, edx           
    ret

init_freq:
    mov ecx, 10
    mov edi, freq
    xor eax, eax
clear:
    mov [edi], eax
    add edi, 4
    loop clear
    ret

inc_frequency:
    mov ebx, eax
    shl ebx, 2            
    add ebx, freq
    inc dword [ebx]
    ret

print_histogram:
    mov esi, 0           
loop_digit:
    cmp esi, 10
    jge done_histogram

    mov eax, esi
    call print_int

    mov edx, colon
    call print_str

    mov ecx, [freq + esi*4]
print_hashes:
    test ecx, ecx
    jz print_count
    mov edx, hash
    call print_str
    dec ecx
    jmp print_hashes

print_count:
    mov edx, lbracket
    call print_str

    mov eax, [freq + esi*4]
    call print_int

    mov edx, rbracket
    call print_str

    call print_newline

    inc esi
    jmp loop_digit

done_histogram:
    ret

read_int:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    mov esi, buffer
    xor eax, eax
parse:
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, 32
    je parse_done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp parse
parse_done:
    ret

print_str:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, edx
    xor edx, edx
strlen:
    cmp byte [ecx+edx], 0
    je write
    inc edx
    jmp strlen
write:
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

    mov ecx, buffer + 15
    mov byte [ecx], 0
    mov ebx, 10
conv:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz conv

    mov edx, ecx
    call print_str

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret