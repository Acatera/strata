section .text
global _start

%include "inc/std.inc"

_start:
.if_0:
    cmp rax, 69
    je .endif_0
.then_0:
    mov rbx, 35
    mov rcx, 34
    add rbx, rcx
    mov rax, rbx
.endif_0:
