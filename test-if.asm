section .text
global _start

%include "inc/std.inc"

_start:
.if_0:
    cmp rax, 69
    je .endif_0
section .data
