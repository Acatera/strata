section .text
global _start
_start:
	mov rdi, 69  ;exit code
	mov rax, 60 ; syscall number
	syscall
