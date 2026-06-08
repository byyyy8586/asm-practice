section .data
    prompt_a     db  "Enter a: ", 0
    prompt_b     db  "Enter b: ", 0
    newline      db  10, 0

    signed_title db  "SIGNED:", 10, 0
    unsign_title db  "UNSIGNED:", 10, 0
    maxs_title   db  "max_signed = ", 0
    maxu_title   db  "max_unsigned = ", 0

    str_lt       db  "a < b", 10, 0
    str_eq       db  "a = b", 10, 0
    str_gt       db  "a > b", 10, 0

section .bss
    a            resq 1
    b            resq 1
    buf          resb 40

section .text
    global _start

_start:
    mov rdi, prompt_a
    call print
    call read_int
    mov [a], rax

    mov rdi, prompt_b
    call print
    call read_int
    mov [b], rax

    ; SIGNED
    mov rdi, signed_title
    call print
    mov rax, [a]
    mov rbx, [b]
    call print_signed

    ; UNSIGNED
    mov rdi, unsign_title
    call print
    mov rax, [a]
    mov rbx, [b]
    call print_unsigned

    ; max_signed
    mov rdi, maxs_title
    call print
    mov rax, [a]
    mov rbx, [b]
    call max_signed
    call print_int
    call print_nl

    ; max_unsigned
    mov rdi, maxu_title
    call print
    mov rax, [a]
    mov rbx, [b]
    call max_unsigned
    call print_int
    call print_nl

    mov rax, 60
    xor rdi, rdi
    syscall


print_signed:
    cmp rax, rbx
    jl .lt
    je .eq
    jmp .gt
.lt:
    mov rdi, str_lt
    call print
    jmp .check_eq
.eq:
    mov rdi, str_eq
    call print
    jmp .check_gt
.gt:
    mov rdi, str_gt
    call print
    ret

.check_eq:
    cmp rax, rbx
    je .eq2
    jmp .check_gt
.eq2:
    mov rdi, str_eq
    call print

.check_gt:
    cmp rax, rbx
    jg .gt2
    ret
.gt2:
    mov rdi, str_gt
    call print
    ret


print_unsigned:
    cmp rax, rbx
    jb .lt
    je .eq
    jmp .gt
.lt:
    mov rdi, str_lt
    call print
    jmp .check_eq_u
.eq:
    mov rdi, str_eq
    call print
    jmp .check_gt_u
.gt:
    mov rdi, str_gt
    call print
    ret

.check_eq_u:
    cmp rax, rbx
    je .eq2_u
    jmp .check_gt_u
.eq2_u:
    mov rdi, str_eq
    call print

.check_gt_u:
    cmp rax, rbx
    ja .gt2_u
    ret
.gt2_u:
    mov rdi, str_gt
    call print
    ret


max_signed:
    cmp rax, rbx
    jg .done
    mov rax, rbx
.done:
    ret

max_unsigned:
    cmp rax, rbx
    ja .done
    mov rax, rbx
.done:
    ret


print:
    push rdi
    mov rsi, rdi
    call strlen
    mov rdx, rax
    pop rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret

strlen:
    xor rax, rax
.loop:
    cmp byte [rdi+rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

print_nl:
    mov rdi, newline
    call print
    ret

read_int:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 39
    syscall
    mov rsi, buf
    xor rax, rax
    mov r10, 10
.loop:
    movzx rbx, byte [rsi]
    cmp rbx, 10
    je .done
    cmp rbx, 0
    je .done
    sub rbx, '0'
    imul rax, r10
    add rax, rbx
    inc rsi
    jmp .loop
.done:
    ret

print_int:
    test rax, rax
    jz .zero
    mov r10, 10
    mov rsi, buf + 39
    mov byte [rsi], 0
    dec rsi
.conv:
    xor rdx, rdx
    div r10
    add dl, '0'
    mov [rsi], dl
    dec rsi
    test rax, rax
    jnz .conv
    inc rsi
    mov rdi, rsi
    call print
    ret
.zero:
    mov rdi, buf
    mov byte [rdi], '0'
    mov byte [rdi+1], 0
    call print
    ret