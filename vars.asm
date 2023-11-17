bits 64
default rel

%include "inc/std.inc"

section .text
    global _start
    
_start:
    InitStandardOutput()
    
    printf(roStr_0)
section .data
	l1 dq 34
section .text

section .data
	l2 dq 35
section .text
	mov r14, [l1]
	mov r15, 1
	add r14, r15
	mov [l2], r14
	mov r14, 252345
	mov r15, [l2]
	add r14, r15
	mov [l2], r14
	mov r14, 9223372036854775806
	mov r15, 1
	add r14, r15
	mov [l1], r14

    printf(roStr_1, [l1])
   

    ExitProcess(0)

section .rodata
    roStr_1 db "l1 = %d\n", 0
    roStr_0 db "Hello, World!\n", 0
