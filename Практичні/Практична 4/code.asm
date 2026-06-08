section .data
    buffer      times 32 db 0     
    newline     db 10, 0          
    minus_sign  db '-', 0       

section .text
    global _start

_start:
==
    mov eax, 3                  
    mov ebx, 0                  
    mov ecx, buffer
    mov edx, 31                   
    int 0x80

    mov byte [buffer + eax], 0    

    call string_to_int

    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1                
    xor ebx, ebx
    int 0x80


string_to_int:
    push ebx
    push ecx
    push edx

    xor eax, eax                 
    xor ebx, ebx                 
    mov ecx, buffer

    cmp byte [ecx], '-'
    jne .parse_loop
    mov ebx, 1                   
    inc ecx                       

.parse_loop:
    movzx edx, byte [ecx]        
    cmp edx, 10                  
    je .finish
    cmp edx, 0                   
    je .finish
    cmp edx, '0'
    jl .finish
    cmp edx, '9'
    jg .finish

    imul eax, eax, 10
    sub edx, '0'
    add eax, edx

    inc ecx
    jmp .parse_loop

.finish:
    test ebx, ebx
    jz .done
    neg eax

.done:
    pop edx
    pop ecx
    pop ebx
    ret


print_int:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, buffer + 31          
    mov byte [ecx], 0            
    mov ebx, 10

    test eax, eax
    jns .convert_loop
    neg eax                      
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_sign
    mov edx, 1
    int 0x80                      
    pop eax

.convert_loop:
    xor edx, edx
    div ebx                     
    add dl, '0'                   
    dec ecx
    mov [ecx], dl

    test eax, eax
    jnz .convert_loop

    mov eax, 4
    mov ebx, 1
    mov edx, buffer + 32
    sub edx, ecx                 
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret