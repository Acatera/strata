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
.if_0:
    cmp rax, 0
    jne .endif_0
.then_0:
    ExitProcess(1)
.endif_0:

    WriteConsoleA([hStdOut], myName, myName.length, 0)

    ExitProcess(0)

section .data
    message db "Hello, "
    message.length equ $ - message
    message1 db "Hello, "
    message1.length equ $ - message1
    message2 db "Hello, "
    message2.length equ $ - message2
    message3 db "Hello, "
    message3.length equ $ - message3
    message4= db "Hello, "
    message4=.length equ $ - message4=
    message5= db "Hello, "
    message5=.length equ $ - message5=
    message6 db "Hello, "
    message6.length equ $ - message6
    myName db "Alex"
    myName.length equ $ - myName
