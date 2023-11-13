bits 64
default rel

%include "inc/std.inc"

section .bss
    hStdOut resq 1
    ptrBuffer64 resb 64

section .data
    message db "Hello,\r\nMy name is 'John'. Here are some details:\r\n\tage: 38\r\n\tdob: undisclosed\\undefined\r\n\0"

section .text
    global _start

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    memset(ptrBuffer64, 32, 64)

    escape(ptrBuffer64, message)

    printf([hStdOut], ptrBuffer64)

    ExitProcess(0)
section .rdata
