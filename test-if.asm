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

.if_1:
    cmp rbx, 0
    jge .endif_1
.then_1:
    mov rbx, 0
.endif_1:

section .data
