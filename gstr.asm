
.if_0:
    cmp rax, 0
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

.endif_11:

.endif_11:

.endif_11:

.endif_11:

.endif_11:
;-----------------------------  refactored output -------------------------------
.if_0:
    cmp rax, 0
    jne .endif_0:
.then_0:
; 
.endif_0:

.if_1:
    cmp rbx, 0
    je .endif_1:
.then_1:
; 
.endif_1:

.if_2:
    cmp rbx, 0
    jge .endif_2:
.then_281474976710658:
; 
.endif_2:

.if_3:
    cmp rbx, 0
    jg .endif_3:
.then_562949953421315:
; 
.endif_3:

.if_4:
    cmp rbx, 0
    jle .endif_4:
.then_844424930131972:
; 
.endif_4:

.if_5:
    cmp rbx, 0
    jg .endif_5:
.then_1125899906842629:
; 
.endif_5:

.if_6:
    cmp rax, 0
    jne .endif_6:
.then_1407374883553286:

.if_7:
    cmp rbx, 0
    je .endif_7:
.then_7:

.if_8:
    cmp rbx, 0
    jge .endif_8:
.then_8:

.if_9:
    cmp rbx, 0
    jg .endif_9:
.then_9:

.if_10:
    cmp rbx, 0
    jle .endif_10:
.then_10:

.if_11:
    cmp rbx, 0
    jg .endif_11:
.then_11:
mov rax, 1
.endif_11:

.endif_10:

.endif_9:

.endif_8:

.endif_7:

.endif_6:
