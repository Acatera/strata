bits 64
default rel

%define CompareTokenWith(foo)

section .text
    global _start

_start:
.if_0:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .end_0
;then_0:
; 
.end_0:

.while_1:
    cmp rax, 0
    jne .end_1
;do_1:

.if_2:
    cmp rbx, 0
    je .end_2
;then_2:
; 
.end_2:

.if_3:
    cmp rbx, 0
    jge .end_3
;then_3:
; 
.end_3:

.if_4:
    cmp rbx, 0
    jg .end_4
;then_4:
; 
.end_4:

.if_5:
    cmp rbx, 0
    jle .end_5
;then_5:
; 
.end_5:

.if_6:
    cmp rbx, 0
    jg .end_6
;then_6:
; 
.end_6:

    jmp .while_1
    ; end while_1
.end_1:

.if_7:
    cmp rax, 0
    jne .end_7
;then_7:

.if_8:
    cmp rbx, 0
    je .end_8
;then_8:

.if_9:
    cmp rbx, 0
    jge .end_9
;then_9:

.if_10:
    cmp rbx, 0
    jg .end_10
;then_10:

.if_11:
    cmp rbx, 0
    jle .end_11
;then_11:

.if_12:
    cmp rbx, 0
    jg .end_12
;then_12:
mov rax, 1
.end_12:

.end_11:

.end_10:

.end_9:

.end_8:

.end_7:
; rax == 0
.if_13:
    cmp rax, 0
    jne .end_13
;then_13:

.end_13:
; rax ~= 0
.if_14:
    cmp rax, 0
    je .end_14
;then_14:

.end_14:
; rax < 0
.if_15:
    cmp rax, 0
    jge .end_15
;then_15:

.end_15:
; rax <= 0
.if_16:
    cmp rax, 0
    jg .end_16
;then_16:

.end_16:
; rax > 0
.if_17:
    cmp rax, 0
    jle .end_17
;then_17:

.end_17:
; rax >= 0
.if_18:
    cmp rax, 0
    jl .end_18
;then_18:

.end_18:

section .rodata
