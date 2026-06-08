section .data
    prompt      db "Enter 32-bit number x: ", 0
    prompt_len  equ $ - prompt

    bin_msg     db 10, "Binary:  ", 0
    bin_len     equ $ - bin_msg

    pop_msg     db 10, "Popcount: ", 0
    pop_len     equ $ - pop_msg

    res_msg     db 10, "Result after set p,q and clear r: ", 0
    res_len     equ $ - res_msg

    newline     db 10, 0

section .bss
    input_buf   resb 16      ; буфер для вводу
    bin_buf     resb 50      ; буфер для двійкового виведення
    number      resd 1       ; збережене число x
    temp        resd 1       ; тимчасовий результат

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
    mov [number], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, bin_msg
    mov edx, bin_len
    int 0x80

    mov eax, [number]
    call print_binary_32

    mov eax, 4
    mov ebx, 1
    mov ecx, pop_msg
    mov edx, pop_len
    int 0x80

    mov eax, [number]
    call popcount
    call print_decimal

    mov eax, [number]
    
    bts eax, 3        
    bts eax, 7          
    btr eax, 15         

    mov [temp], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, res_msg
    mov edx, res_len
    int 0x80

    mov eax, [temp]
    call print_decimal

    ; Завершення
    mov eax, 1
    mov ebx, 0
    int 0x80


atoi:
    xor eax, eax
.loop:
    movzx ebx, byte [ecx]
    cmp bl, 10         
    je .done
    cmp bl, 0
    je .done
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done

    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx
    inc ecx
    jmp .loop
.done:
    ret


print_binary_32:
    mov ecx, 32
    lea edx, [bin_buf]
.loop:
    shl eax, 1
    setc bl
    add bl, '0'
    mov [edx], bl
    inc edx

    dec ecx
    jz .finish

    test ecx, 3
    jnz .loop

    mov byte [edx], ' '
    inc edx
    jmp .loop

.finish:
    mov byte [edx], 10
    inc edx

    mov eax, 4
    mov ebx, 1
    mov ecx, bin_buf
    sub edx, ecx
    int 0x80
    ret


popcount:
    xor ecx, ecx
.loop:
    test eax, 1
    jz .skip
    inc ecx
.skip:
    shr eax, 1
    jnz .loop
    mov eax, ecx
    ret


print_decimal:
    push eax
    mov ecx, bin_buf + 40
    mov byte [ecx], 10
    dec ecx
    mov ebx, 10

    pop eax
    test eax, eax
    jnz .loop
    mov byte [ecx], '0'
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
    mov edx, bin_buf + 41
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    int 0x80
    ret