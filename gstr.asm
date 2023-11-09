bits 64
default rel

%include "inc/std.inc"

section .bss
    hStdOut resd 1

section .text
    global _start

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    WriteConsoleA([hStdOut], message, message.length, 0)
    WriteConsoleA([hStdOut], myName, myName.length, 0)

    ExitProcess(0)

section .data
    message db "Hello, "
    message.length equ $ - message
    myName db "Alex"
    myName.length equ $ - myName
