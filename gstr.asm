; Compare rax with 0
.if_0:

.then_0:

.endif_0:
; Compare rax with 0
.if_1:
    cmp rax, 0
    jne .endif_1
.then_1:

.endif_1:
; Compare rax with 0
.if_2:
    cmp rax, 0
    je .endif_2
.then_2:

.endif_2:
; Compare rax with 0
.if_3:
    cmp rax, 0
    jge .endif_3
.then_3:

.endif_3:
; Compare rax with 0
.if_4:
    cmp rax, 0
    jg .endif_4
.then_4:

.endif_4:
; Compare rax with 0
.if_5:
    cmp rax, 0
    jle .endif_5
.then_5:

.endif_5:
; Compare rax with 0
.if_6:
    cmp rax, 0
    jl .endif_6
.then_6:

.endif_6:

section .data
    string db "Hello World!"
    string.length equ $ - string
    string db "Hello World!"
    string.length equ $ - string
    string db "Hello World!"
    string.length equ $ - string
    string db "Hello World!"
    string.length equ $ - string
