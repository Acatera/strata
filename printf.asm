bits 64
default rel

%include "inc/std.inc"

section .bss
    padding resq 1
    hStdOut resq 1
    buffer64 resb 64
    sprintfBuffer resb 32

section .data
    name db "John", 0
    format db "Hello %x %d %d %d %d %d %s %p %% <- this is a percent! %u", 0xd, 0xa, 0

section .text
global _start

_start:
    ; align stack to 16 bytes
    and rsp, 0xfffffffffffffff0

    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])
    
    push -3
    mov rax, name
    push rax
    push rax
    push 6
    push 5
    push 4
    push -3
    sub rsp, 0x20
    mov r9, 2
    mov r8, 16
    mov rdx, format
    mov rcx, buffer64
    call mysprintf
    
    WriteConsoleA([hStdOut], buffer64, rax, 0)

    ExitProcess(0)

mysprintf:
    ; set up stack frame
    push rbp
    mov rbp, rsp

    ; according to windows x64 calling convention
    ; rbx, rbp, rsi, rdi, r12, r13, r14, r15 are callee-saved
    ; rcx, rdx, r8, r9, r10, r11 are volatile  
    multipush rbx, rsi, rdi, r12, r13, r14, r15

    ; save params on the stack, to ease the use of printf
    mov [rbp + 0x28], r9
    mov [rbp + 0x20], r8
    mov [rbp + 0x18], rdx
    mov [rbp + 0x10], rcx

    xor rax, rax    ; rax = return value
    xor r14, r14    ; r14 = param counter

    ; todo - strata-fy this
.if_buffer_is_null:
    cmp rcx, 0
    jne .endif_buffer_is_null
.then_buffer_is_null:
    mov rax, 0
    jmp .done 
.endif_buffer_is_null:

    mov rsi, rdx     ; rsi = format string, null terminated
    mov rdi, rcx     ; rdi = buffer

.while_format_not_null:
    cmp byte [rsi], 0
    je .end_format_not_null
    ; todo - should check for buffer overflow
    ; no idea how to do that yet
.do_format_not_null:
.if_char_is_not_percent:
    cmp byte [rsi], '%'
    je .endif_char_is_not_percent
.then_char_is_not_percent:
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rsi
    inc rdi
    inc rax
    ; continue
    jmp .while_format_not_null
.endif_char_is_not_percent:

    ; char is percent
    inc rsi
.if_percent_specifier:    
    cmp byte [rsi], '%'
    jne .endif_percent_specifier
.then_percent_specifier:
    mov byte [rdi], '%'
    inc rdi
    inc rsi          ; next char after '%%'
    inc rax
.endif_percent_specifier:

.if_decimal_specifier:    
    cmp byte [rsi], 'd'
    jne .endif_decimal_specifier
.then_decimal_specifier:
    multipush rsi, rax
    ; convert number to string
    itoa([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_decimal_specifier:

.if_unsigned_specifier:    
    cmp byte [rsi], 'u'
    jne .endif_unsigned_specifier
.then_unsigned_specifier:
    multipush rsi, rax
    ; convert number to string
    itoad([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_unsigned_specifier:

.if_hexadecimal_specifier:    
    cmp byte [rsi], 'x'
    jne .endif_hexadecimal_specifier
.then_hexadecimal_specifier:
    multipush rsi, rax

    ; convert number to string
    itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_hexadecimal_specifier:

.if_pointer_specifier:    
    cmp byte [rsi], 'p'
    jne .endif_pointer_specifier
.then_pointer_specifier:
    multipush rsi, rax

    ; add '0x' to output
    mov byte [rdi], '0'
    mov byte [rdi + 1], 'x'
    add rdi, 2
    add rax, 2

    ; convert number to string
    itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_pointer_specifier:

.if_string_specifier:
    cmp byte [rsi], 's'
    jne .endif_string_specifier
.then_string_specifier:
    push rsi

    ; get string pointer from stack
    mov rsi, [rbp + 0x20 + r14 * 8]

.while_string_not_null:
    cmp byte [rsi], 0
    je .end_string_not_null
.do_string_not_null:
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rsi
    inc rdi
    inc rax
    jmp .while_string_not_null
.end_string_not_null:    

    pop rsi
    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
.endif_string_specifier:
    jmp .while_format_not_null
.end_format_not_null:

    ; add null terminator
    mov byte [rdi], 0

.done:
    multipop rbx, rsi, rdi, r12, r13, r14, r15

    ; tear down stack frame
    pop rbp
    ret
