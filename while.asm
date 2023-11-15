bits 64
default rel

%include "inc/std.inc"

%define COUNT 100

section .data
    hStdOut dq 0

section .text
    global _start

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    printf([hStdOut], roStr_0)
    
    xor r15, r15
.while_0:
    cmp r15, COUNT
    jge .end_0
.do_0:

        printf([hStdOut], roStr_1, r15)
        inc r15
    jmp .while_0

.end_0:


    ExitProcess(0)
section .rodata
    roStr_1 db "Register r15 = %d\n", 0
    roStr_0 db "Hello, World!\n", 0
