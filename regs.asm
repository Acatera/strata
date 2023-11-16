bits 64
default rel

%include "inc/std.inc"

section .bss
    hStdOut resq 1

section .text
    global _start

%define x r10
%define y r11
%define t r12
%define n 1000000
%define set(var, value) mov var, value
%define add(var, value) add var, value
%define p(var) [var]

_start:
    InitStandardOutput()

    printf(roStr_0, n)

    ; generate fib sequence
    set(x, 0)
    set(y, 1)
.while_0:
    cmp y, n
    jge .end_0
;do_0:

        printf(roStr_1, x)
        ; set x = y, y = x + y
        set(t, x)
        set(x, y)
        add(y, t)
    jmp .while_0
    ; end while_0
.end_0:


    ExitProcess(0)
section .rodata
    roStr_1 db "%d\n", 0
    roStr_0 db "Fibonacci sequence up to %d:\n", 0
