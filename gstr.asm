bits 64
default rel

%define CompareTokenWith(foo)

section .text
    global _start

_start:
.if_0:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .endif_0
.then_0:
; 
.endif_0:

.if_1:
    cmp rbx, 0
    je .endif_1
.then_1:
; 
.endif_1:

.if_2:
    cmp rbx, 0
    jge .endif_2
.then_2:
; 
.endif_2:

.if_3:
    cmp rbx, 0
    jg .endif_3
.then_3:
; 
.endif_3:

.if_4:
    cmp rbx, 0
    jle .endif_4
.then_4:
; 
.endif_4:

.if_5:
    cmp rbx, 0
    jg .endif_5
.then_5:
; 
.endif_5:

.if_6:
    cmp rax, 0
    jne .endif_6
.then_6:

.if_7:
    cmp rbx, 0
    je .endif_7
.then_7:

.if_8:
    cmp rbx, 0
    jge .endif_8
.then_8:

.if_9:
    cmp rbx, 0
    jg .endif_9
.then_9:

.if_10:
    cmp rbx, 0
    jle .endif_10
.then_10:

.if_11:
    cmp rbx, 0
    jg .endif_11
.then_11:
mov rax, 1
.endif_11:

.endif_10:

.endif_9:

.endif_8:

.endif_7:

.endif_6:
; rax == 0
.if_12:
    cmp rax, 0
    jne .endif_12
.then_12:

.endif_12:
; rax ~= 0
.if_13:
    cmp rax, 0
    je .endif_13
.then_13:

.endif_13:
; rax < 0
.if_14:
    cmp rax, 0
    jge .endif_14
.then_14:

.endif_14:
; rax <= 0
.if_15:
    cmp rax, 0
    jg .endif_15
.then_15:

.endif_15:
; rax > 0
.if_16:
    cmp rax, 0
    jle .endif_16
.then_16:

.endif_16:
; rax >= 0
.if_17:
    cmp rax, 0
    jl .endif_17
.then_17:

.endif_17:
section .rodata
