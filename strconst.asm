bits 64
default rel

%include "inc/std.inc"

section .bss
    hStdOut resq 1

section .data
    message db "Hello, World!", 10, 0

section .text
    global _start

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    printf([hStdOut], roStr_0)
    printf([hStdOut], roStr_1)
    printf([hStdOut], roStr_2)
    printf([hStdOut], roStr_3)
    printf([hStdOut], roStr_4)
    printf([hStdOut], roStr_5)
    printf([hStdOut], roStr_6)
    printf([hStdOut], roStr_7)
    printf([hStdOut], roStr_8)
    printf([hStdOut], roStr_9)

    ExitProcess(0)
section .rdata
    roStr_9 db "    ExitProcess(0)\r\n", 0
    roStr_8 db "\r\n", 0
    roStr_7 db "    printf([hStdOut], roStr_1)\r\n", 0
    roStr_6 db "    printf([hStdOut], roStr_0)\r\n", 0
    roStr_5 db "\r\n", 0
    roStr_4 db "    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])\r\n", 0
    roStr_3 db "_start:\r\n", 0
    roStr_2 db "\r\n", 0
    roStr_1 db "    global _start\r\n", 0
    roStr_0 db "section .text\r\n", 0
