bits 64
default rel


%include 'inc/std.inc'

%define SOURCE_CODE_SIZE 1048576
section .bss
    inFileHandle resq 1
    outFileHandle resq 1
    buffer1 resb 256
    buffer2 resb 256
    buffer3 resb 256

section .data
    cStrSourceFile db "v2.strata", 0
    cStrOutputFile db "v2.asm", 0
    cStrObjectFile db "v2.o", 0
    cStrLinkerFile db "v2.exe", 0

section .text
    global _start
    extern CreateFileA
    extern ReadFile
    extern CloseHandle
    extern GetLastError

_start:
    InitStandardOutput()
    section .bss
	sourceCode resb 1048576
section .text

section .data
	bytesRead dq 0
section .text

	jmp OpenSourceFile_end
OpenSourceFile:
	push rbp
	mov rbp, rsp

    ; print input and output file names
    printf(roStr_0, cStrSourceFile)

    ; Preparing the parameters for CreateFileA to open a file for reading
    mov rcx, cStrSourceFile                       ; First parameter: Pointer to the filename (LPCSTR)
    mov rdx, GENERIC_READ                       ; Second parameter: Access to the file (DWORD), for reading use GENERIC_READ
    mov r8, 1                                   ; Third parameter: File sharing mode (DWORD)
    mov r9, 0                                   ; Fourth parameter: Pointer to security attributes (LPSECURITY_ATTRIBUTES)
    sub rsp, 4*8 + 3*8                          ; Shadow space for 4 register parameters + 3 additional stack parameters
    mov [rsp+4*8], dword 3                      ; Fifth parameter: Action to take on files that exist or do not exist (DWORD)
    mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; Sixth parameter: File attributes and flags (DWORD)
    mov [rsp+6*8], dword 0                      ; Seventh parameter: Handle to a template file (HANDLE)
    call CreateFileA
    add rsp, 4*8 + 3*8 
    mov [inFileHandle], rax
    
    mov rcx, [inFileHandle]      ; Handle to the file (HANDLE)
    mov rdx, sourceCode        ; Pointer to the buffer that receives the data read from the file (LPVOID)
    mov r8, dword SOURCE_CODE_SIZE   ; Number of bytes to be read from the file (DWORD)
    mov r9, bytesRead         ; Pointer to the variable that receives the number of bytes read (LPDWORD)
    sub rsp, 32
    push 0
    call ReadFile
    add rsp, 40
	mov rsp, rbp
	pop rbp
	ret
OpenSourceFile_end:

	jmp CloseSourceFile_end
CloseSourceFile:
	push rbp
	mov rbp, rsp

    mov rcx, [inFileHandle]
    sub rsp, 32
    push 0
    call CloseHandle
    add rsp, 40
	mov rsp, rbp
	pop rbp
	ret
CloseSourceFile_end:

	jmp CreateOutputFile_end
CreateOutputFile:
	push rbp
	mov rbp, rsp

    ; print input and output file names
    printf(roStr_1, cStrOutputFile)

    ; Preparing the parameters for CreateFileA to open a file for reading
    mov rcx, cStrOutputFile                       ; First parameter: Pointer to the filename (LPCSTR)
    mov rdx, GENERIC_WRITE                       ; Second parameter: Access to the file (DWORD), for reading use GENERIC_READ
    mov r8, 2                                   ; Third parameter: File sharing mode (DWORD)
    mov r9, 0                                   ; Fourth parameter: Pointer to security attributes (LPSECURITY_ATTRIBUTES)
    sub rsp, 4*8 + 3*8                          ; Shadow space for 4 register parameters + 3 additional stack parameters
    mov [rsp+4*8], dword 2                      ; Fifth parameter: Action to take on files that exist or do not exist (DWORD)
    mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; Sixth parameter: File attributes and flags (DWORD)
    mov [rsp+6*8], dword 0                      ; Seventh parameter: Handle to a template file (HANDLE)
    call CreateFileA
    add rsp, 4*8 + 3*8 
    mov [outFileHandle], rax
    SetOutputFile(outFileHandle)
	mov rsp, rbp
	pop rbp
	ret
CreateOutputFile_end:

	jmp CloseOutputFile_end
CloseOutputFile:
	push rbp
	mov rbp, rsp

    mov rcx, [outFileHandle]
    sub rsp, 32
    push 0
    call CloseHandle
    add rsp, 40
	mov rsp, rbp
	pop rbp
	ret
CloseOutputFile_end:

	jmp WriteFileHeader_end
WriteFileHeader:
	push rbp
	mov rbp, rsp

    WriteToFile(roStr_2)
    WriteToFile(roStr_3)
    WriteToFile(roStr_4)
    WriteToFile(roStr_5)
    WriteToFile(roStr_6)
    WriteToFile(roStr_7)
    WriteToFile(roStr_8)
    WriteToFile(roStr_9)
    WriteToFile(roStr_10)
	mov rsp, rbp
	pop rbp
	ret
WriteFileHeader_end:

section .data
	handle dq 0
section .text

	call OpenSourceFile
	mov [handle], rax
	add rsp, 0

;.if_0:
	mov r15, [handle]
	cmp r15, 0
	jge .else_0
;then_0:

    printf(roStr_11, cStrSourceFile)
    ExitProcess(1) 
	jmp .end_0
.else_0:

    printf(roStr_12, cStrSourceFile) 
    printf(roStr_13, [bytesRead])
.end_0:

	call CloseSourceFile

	call CreateOutputFile

	call WriteFileHeader

section .data
	_ dq 0
section .text

section .data
	true dq 1
section .text

section .data
	c db 0
section .text

section .data
	scIndex dq 0
section .text
section .bss
	token resb 512
section .text

section .data
	tokenIndex dq 0
section .text

section .data
	isSep dq 0
section .text

section .data
	line dq 1
section .text

section .data
	line_start dq 1
section .text

section .data
	col dq 1
section .text
section .bss
	tokens resq 10000
section .text

section .data
	tokenCount dq 0
section .text

section .data
	tokenSize dq 4
section .text

section .data
	pt_ dq 0
section .text

	jmp push_token_end
push_token:
	push rbp
	mov rbp, rsp
	push qword [rbp + 16]
	pop rax
	mov qword [pt_], rax
	mov rax, [tokenCount]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [pt_]
	mov [rdx], rax
	push qword [tokenCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 24]
	pop rax
	mov qword [pt_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [pt_]
	mov [rdx], rax
	push qword [tokenCount]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 32]
	pop rax
	mov qword [pt_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [pt_]
	mov [rdx], rax
	push qword [tokenCount]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 40]
	pop rax
	mov qword [pt_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [pt_]
	mov [rdx], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenCount], rax

    ;printf(roStr_14, [rbp+16], [rbp+24])
    ;printf(roStr_15, [rbp+32], [rbp+40])
	mov rsp, rbp
	pop rbp
	ret
push_token_end:
section .bss
	stringBuffer resb 100000
section .text

section .data
	sbIndex dq 0
section .text

section .data
	stringBufferTop dq 0
section .text
section .bss
	stringPointers resq 5000
section .text

section .data
	stringPointersTop dq 0
section .text
section .bss
	stringToPush resb 256
section .text

section .data
	freeStringIndex dq 0
section .text

section .data
	freeChar db 0
section .text

	jmp push_identifier_end
push_identifier:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, token
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al
	mov rax, [stringPointersTop]
	mov rdx, 8
	mul rdx
	mov rdx, stringPointers
	add rdx, rax
	mov rax, [stringBufferTop]
	mov [rdx], rax

.while_1:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_1
;do_1:
	mov rdx, stringBuffer
	add rdx, [stringBufferTop]
	movzx rax, byte [freeChar]
	mov byte [rdx], al
	push qword [stringBufferTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringBufferTop], rax
	push qword [freeStringIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, token
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

    jmp .while_1
    ; end while_1
.end_1:
	mov rdx, stringBuffer
	add rdx, [stringBufferTop]
	mov byte [rdx], 0
	push qword [stringBufferTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringBufferTop], rax

    ;printf(roStr_16, [stringPointersTop], [freeStringIndex])
    	push qword [stringPointersTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringPointersTop], rax

	mov rsp, rbp
	pop rbp
	ret
push_identifier_end:

section .data
	TOKEN_UINT8 dq 1
section .text

section .data
	TOKEN_UINT64 dq 2
section .text

section .data
	TOKEN_POINTER dq 3
section .text

section .data
	TOKEN_IDENTIFIER dq 4
section .text

section .data
	TOKEN_ASSIGNMENT dq 5
section .text

section .data
	TOKEN_CONSTANT_INTEGER dq 6
section .text

section .data
	TOKEN_CONSTANT_STRING dq 7
section .text

section .data
	TOKEN_SEMICOLON dq 8
section .text

section .data
	TOKEN_COMMA dq 9
section .text

section .data
	TOKEN_LEFT_PARENTHESIS dq 10
section .text

section .data
	TOKEN_RIGHT_PARENTHESIS dq 11
section .text

section .data
	TOKEN_LEFT_BRACKET dq 12
section .text

section .data
	TOKEN_RIGHT_BRACKET dq 13
section .text

section .data
	TOKEN_PLUS dq 14
section .text

section .data
	TOKEN_MINUS dq 15
section .text

section .data
	TOKEN_MULTIPLY dq 16
section .text

section .data
	TOKEN_DIVIDE dq 17
section .text

section .data
	TOKEN_MODULO dq 18
section .text

section .data
	TOKEN_LESS_THAN dq 19
section .text

section .data
	TOKEN_LESS_THAN_OR_EQUAL_TO dq 20
section .text

section .data
	TOKEN_GREATER_THAN dq 21
section .text

section .data
	TOKEN_GREATER_THAN_OR_EQUAL_TO dq 22
section .text

section .data
	TOKEN_EQUALS dq 23
section .text

section .data
	TOKEN_NOT_EQUALS dq 24
section .text

section .data
	TOKEN_LOGICAL_AND dq 25
section .text

section .data
	TOKEN_LOGICAL_OR dq 26
section .text

section .data
	TOKEN_IF dq 27
section .text

section .data
	TOKEN_THEN dq 28
section .text

section .data
	TOKEN_ELSE dq 29
section .text

section .data
	TOKEN_END dq 30
section .text

section .data
	TOKEN_WHILE dq 31
section .text

section .data
	TOKEN_DO dq 32
section .text

section .data
	TOKEN_BREAK dq 33
section .text

section .data
	TOKEN_CONTINUE dq 34
section .text

section .data
	TOKEN_EXTERN dq 35
section .text

section .data
	TOKEN_PROC dq 36
section .text

section .data
	TOKEN_ARROW_RIGHT dq 37
section .text

section .data
	TOKEN_VARS dq 38
section .text

section .data
	TOKEN_CODE dq 39
section .text

section .data
	TOKEN_RETURN dq 40
section .text

section .data
	TOKEN_STRUCT dq 41
section .text

section .data
	TOKEN_DOT dq 42
section .text

section .data
	TOKEN_AT_SIGN dq 43
section .text

section .data
	TOKEN_DEFINE dq 44
section .text

section .data
	TOKEN_AMPERSAND dq 45
section .text

section .data
	TOKEN_EXIT dq 46
section .text

section .data
	TOKEN_SIZEOF dq 47
section .text

section .data
	TYPE_UINT8 dq 1
section .text

section .data
	TYPE_UINT64 dq 2
section .text

section .data
	TYPE_POINTER dq 3
section .text

section .data
	TYPE_ARRAY dq 4
section .text

section .data
	TYPE_STRING dq 5
section .text

section .data
	TYPE_PROCEDURE dq 6
section .text

section .data
	TYPE_EXTERNAL_PROCEDURE dq 7
section .text

section .data
	TYPE_USER_DEFINED dq 8
section .text

section .data
	TYPE_DEFINE dq 9
section .text

section .data
	TYPE_STRUCT_POINTER dq 10
section .text

section .data
	VARIABLE_SCOPE_GLOBAL dq 0
section .text

section .data
	VARTYPE_PARAMETER dq 1
section .text

section .data
	VARTYPE_LOCAL dq 2
section .text

section .data
	VAR_KIND_PRIMITIVE dq 1
section .text

section .data
	VAR_KIND_USER_DEFINED dq 2
section .text

section .data
	i dq 0
section .text
section .bss
	token_dictionary resb 5000
section .text

section .data
	token_dictionary_top dq 0
section .text
section .bss
	token_dictionary_pointers resq 500
section .text

section .data
	token_dictionary_pointers_top dq 0
section .text

	jmp register_token_type_end
register_token_type:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, stringToPush
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al
	mov rax, [token_dictionary_pointers_top]
	mov rdx, 8
	mul rdx
	mov rdx, token_dictionary_pointers
	add rdx, rax
	mov rax, [token_dictionary_top]
	mov [rdx], rax

.while_2:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_2
;do_2:
	mov rdx, token_dictionary
	add rdx, [token_dictionary_top]
	movzx rax, byte [freeChar]
	mov byte [rdx], al
	push qword [token_dictionary_top]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [token_dictionary_top], rax
	push qword [freeStringIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, stringToPush
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

    jmp .while_2
    ; end while_2
.end_2:
	mov rdx, token_dictionary
	add rdx, [token_dictionary_top]
	mov byte [rdx], 0
	push qword [token_dictionary_top]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [token_dictionary_top], rax

    ;printf(roStr_17, [token_dictionary_pointers_top], [freeStringIndex])
    	push qword [token_dictionary_pointers_top]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [token_dictionary_pointers_top], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_], rax
	mov rax, [token_dictionary_pointers_top]
	mov rdx, 8
	mul rdx
	mov rdx, token_dictionary_pointers
	add rdx, rax
	mov rax, [_]
	mov [rdx], rax
	push qword [token_dictionary_pointers_top]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [token_dictionary_pointers_top], rax

	mov rsp, rbp
	pop rbp
	ret
register_token_type_end:
section .bss
	token_at_pointer resb 256
section .text

	jmp read_token_end
read_token:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [freeStringIndex], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, token_dictionary_pointers
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [sbIndex], rax
	push qword [sbIndex]
	pop rax
	mov qword [_], rax
	mov rdx, token_dictionary
	add rdx, [sbIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

.while_3:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_3
;do_3:
	mov rdx, token_at_pointer
	add rdx, [freeStringIndex]
	movzx rax, byte [freeChar]
	mov byte [rdx], al
	push qword [freeStringIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [freeStringIndex], rax
	push qword [sbIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [sbIndex], rax
	mov rdx, token_dictionary
	add rdx, [sbIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

    jmp .while_3
    ; end while_3
.end_3:
	mov rdx, token_at_pointer
	add rdx, [freeStringIndex]
	mov byte [rdx], 0

    ;printf(roStr_18, [rbp + 16], [freeStringIndex])
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
read_token_end:

	jmp token_equals_end
token_equals:
	push rbp
	mov rbp, rsp

    mov rsi, token
    	push qword [rbp + 16]

	call read_token
	mov [_], rax
	add rsp, 8

    mov rdi, token_at_pointer

    ;printf(roStr_19, rsi, rdi)
.loop:
    mov al, byte [rdi]
    mov bl, byte [rsi]
    cmp al, bl
    jne .str_neq
    cmp al, 0
    je .str1_null
    cmp bl, 0
    je .str2_null
    inc rdi
    inc rsi
    jmp .loop

.str1_null:
    cmp bl, 0
    je .str_eq
    jmp .str_neq

.str2_null:
    cmp al, 0
    je .str_eq
    jmp .str_neq    

.str_neq:
    xor rax, rax
    jmp .end

.str_eq:
    mov rax, 1
.end: 
	mov rsp, rbp
	pop rbp
	ret
token_equals_end:

section .data
	gttCount dq 0
section .text

section .data
	gttIndex dq 0
section .text

section .data
	gttEqual dq 0
section .text

	jmp get_token_type_end
get_token_type:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [gttCount], rax
	push 0
	pop rax
	mov qword [gttIndex], rax
	push 0
	pop rax
	mov qword [gttEqual], rax

.while_4:
	mov r15, [gttCount]
	cmp r15, [token_dictionary_pointers_top]
	jge .end_4
;do_4:
	push qword [gttIndex]

	call token_equals
	mov [gttEqual], rax
	add rsp, 8

;.if_5:
	mov r15, [gttEqual]
	cmp r15, 0
	je .end_5
;then_5:

    jmp .end_4

.end_5:
	push qword [gttCount]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [gttCount], rax
	push qword [gttIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [gttIndex], rax

    jmp .while_4
    ; end while_4
.end_4:

;.if_6:
	mov r15, [gttEqual]
	cmp r15, [true]
	jne .else_6
;then_6:
	push 1
	push qword [gttCount]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, token_dictionary_pointers
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

        mov rax, [_]
	jmp .end_6
.else_6:

        mov rax, 0
.end_6:

	mov rsp, rbp
	pop rbp
	ret
get_token_type_end:

section .data
	tnNumber dq 0
section .text

section .data
	tnDigit dq 0
section .text

section .data
	tnChar db 0
section .text

section .data
	tnIndex dq 0
section .text

section .data
	tnSuccess dq 0
section .text

section .data
	tnIsHex dq 0
section .text

section .data
	tnBase dq 10
section .text

	jmp to_number_end
to_number:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [tnNumber], rax
	push 0
	pop rax
	mov qword [tnIsHex], rax
	push 0
	pop rax
	mov qword [tnIndex], rax
	push 10
	pop rax
	mov qword [tnBase], rax
	push 1
	pop rax
	mov qword [tnSuccess], rax
	mov rdx, token
	add rdx, [tnIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [tnChar], al

;.if_7:
	movzx r15, byte [tnChar]
	cmp r15, 0
	je .end_7
;then_7:
	push qword [tnIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rdx, token
	add rdx, [_]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov qword [_], rax

;.if_8:
	mov r15, [_]
	cmp r15, 88
	jne .end_8
;then_8:
	push 1
	pop rax
	mov qword [tnIsHex], rax

.end_8:

;.if_9:
	mov r15, [_]
	cmp r15, 120
	jne .end_9
;then_9:
	push 1
	pop rax
	mov qword [tnIsHex], rax

.end_9:

.end_7:

;.if_10:
	mov r15, [tnIsHex]
	cmp r15, 1
	jne .end_10
;then_10:
	push 16
	pop rax
	mov qword [tnBase], rax
	push 2
	pop rax
	mov qword [tnIndex], rax
	mov rdx, token
	add rdx, [tnIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [tnChar], al

.end_10:

.while_11:
	movzx r15, byte [tnChar]
	cmp r15, 0
	je .end_11
;do_11:
	push qword [tnNumber]
	push qword [tnBase]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [tnNumber], rax
	mov rdx, token
	add rdx, [tnIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov qword [tnDigit], rax

;.if_12:
	mov r15, [tnDigit]
	cmp r15, 96
	jle .else_12
;then_12:

;.if_13:
	mov r15, [tnDigit]
	cmp r15, 103
	jge .else_13
;then_13:
	push qword [tnDigit]
	push 87
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_13
.else_13:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_11

.end_13:

	jmp .end_12
.else_12:

;.if_14:
	mov r15, [tnDigit]
	cmp r15, 64
	jle .else_14
;then_14:

;.if_15:
	mov r15, [tnDigit]
	cmp r15, 71
	jge .else_15
;then_15:
	push qword [tnDigit]
	push 55
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_15
.else_15:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_11

.end_15:

	jmp .end_14
.else_14:

;.if_16:
	mov r15, [tnDigit]
	cmp r15, 47
	jle .end_16
;then_16:

;.if_17:
	mov r15, [tnDigit]
	cmp r15, 58
	jge .else_17
;then_17:
	push qword [tnDigit]
	push 48
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_17
.else_17:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_11

.end_17:

.end_16:

.end_14:

.end_12:
	push qword [tnNumber]
	push qword [tnDigit]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tnNumber], rax
	push qword [tnIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tnIndex], rax
	mov rdx, token
	add rdx, [tnIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [tnChar], al

    jmp .while_11
    ; end while_11
.end_11:

    mov rax, [tnSuccess]
	mov rsp, rbp
	pop rbp
	ret
to_number_end:

	jmp isSpace_end
isSpace:
	push rbp
	mov rbp, rsp

;.if_18:
	movzx r15, byte [c]
	cmp r15, 32
	jne .else_18
;then_18:

        mov rax, 1
	jmp .end_18
.else_18:

;.if_19:
	movzx r15, byte [c]
	cmp r15, 10
	jne .else_19
;then_19:

        mov rax, 1
	jmp .end_19
.else_19:

;.if_20:
	movzx r15, byte [c]
	cmp r15, 13
	jne .else_20
;then_20:

        mov rax, 1
	jmp .end_20
.else_20:

;.if_21:
	movzx r15, byte [c]
	cmp r15, 9
	jne .else_21
;then_21:

        mov rax, 1
	jmp .end_21
.else_21:

        mov rax, 0
.end_21:

.end_20:

.end_19:

.end_18:

	mov rsp, rbp
	pop rbp
	ret
isSpace_end:

	jmp isSeparator_end
isSeparator:
	push rbp
	mov rbp, rsp

;.if_22:
	movzx r15, byte [c]
	cmp r15, 59
	jne .else_22
;then_22:

        mov rax, 1
	jmp .end_22
.else_22:

;.if_23:
	movzx r15, byte [c]
	cmp r15, 44
	jne .else_23
;then_23:

        mov rax, 1
	jmp .end_23
.else_23:

;.if_24:
	movzx r15, byte [c]
	cmp r15, 40
	jne .else_24
;then_24:

        mov rax, 1
	jmp .end_24
.else_24:

;.if_25:
	movzx r15, byte [c]
	cmp r15, 41
	jne .else_25
;then_25:

        mov rax, 1
	jmp .end_25
.else_25:

;.if_26:
	movzx r15, byte [c]
	cmp r15, 91
	jne .else_26
;then_26:

        mov rax, 1
	jmp .end_26
.else_26:

;.if_27:
	movzx r15, byte [c]
	cmp r15, 93
	jne .else_27
;then_27:

        mov rax, 1
	jmp .end_27
.else_27:

;.if_28:
	movzx r15, byte [c]
	cmp r15, 46
	jne .else_28
;then_28:

        mov rax, 1
	jmp .end_28
.else_28:

;.if_29:
	movzx r15, byte [c]
	cmp r15, 64
	jne .else_29
;then_29:

        mov rax, 1
	jmp .end_29
.else_29:

;.if_30:
	movzx r15, byte [c]
	cmp r15, 38
	jne .else_30
;then_30:

        mov rax, 1
	jmp .end_30
.else_30:

        mov rax, 0
.end_30:

.end_29:

.end_28:

.end_27:

.end_26:

.end_25:

.end_24:

.end_23:

.end_22:

	mov rsp, rbp
	pop rbp
	ret
isSeparator_end:
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 56
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 0
	push qword [TOKEN_UINT8]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 54
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 52
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_UINT64]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 112
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 7
	mov byte [rdx], 0
	push qword [TOKEN_POINTER]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 97
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 100
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 0
	push qword [TOKEN_LOGICAL_AND]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 0
	push qword [TOKEN_LOGICAL_OR]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 102
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 0
	push qword [TOKEN_IF]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 104
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_THEN]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 108
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 115
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_ELSE]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 100
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 0
	push qword [TOKEN_END]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 119
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 104
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 108
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 0
	push qword [TOKEN_WHILE]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 100
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 0
	push qword [TOKEN_DO]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 98
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 97
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 107
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 0
	push qword [TOKEN_BREAK]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 99
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 7
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 8
	mov byte [rdx], 0
	push qword [TOKEN_CONTINUE]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 120
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_EXTERN]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 112
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 99
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_PROC]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 118
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 97
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 115
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_VARS]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 99
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 100
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_CODE]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_RETURN]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 115
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 114
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 99
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_STRUCT]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 120
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 116
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_EXIT]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 100
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 102
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_DEFINE]

	call register_token_type
	mov [_], rax
	add rsp, 8
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 115
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 105
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 122
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 111
	mov rdx, stringToPush
	add rdx, 5
	mov byte [rdx], 102
	mov rdx, stringToPush
	add rdx, 6
	mov byte [rdx], 0
	push qword [TOKEN_SIZEOF]

	call register_token_type
	mov [_], rax
	add rsp, 8

;printf(roStr_20, [token_dictionary_pointers_top])

section .data
	token_type dq 0
section .text

	jmp push_and_print_token_end
push_and_print_token:
	push rbp
	mov rbp, rsp

    ;printf(roStr_21, token)
    
	call to_number
	mov [_], rax
	add rsp, 0

;.if_31:
	mov r15, [_]
	cmp r15, 1
	jne .else_31
;then_31:
	push qword [col]
	push qword [line]
	push qword [tnNumber]
	push qword [TOKEN_CONSTANT_INTEGER]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_31
.else_31:

	call get_token_type
	mov [token_type], rax
	add rsp, 0

;.if_32:
	mov r15, [token_type]
	cmp r15, 0
	jne .else_32
;then_32:
	push qword [col]
	push qword [line]
	push qword [stringPointersTop]
	push qword [TOKEN_IDENTIFIER]

	call push_token
	mov [_], rax
	add rsp, 32

	call push_identifier

	jmp .end_32
.else_32:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [token_type]

	call push_token
	mov [_], rax
	add rsp, 32

.end_32:

.end_31:

	mov rsp, rbp
	pop rbp
	ret
push_and_print_token_end:

.while_33:
	mov r15, [scIndex]
	cmp r15, [bytesRead]
	jge .end_33
;do_33:
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	call isSpace
	mov [_], rax
	add rsp, 0

	call isSeparator
	mov [isSep], rax
	add rsp, 0

;.if_34:
	mov r15, [_]
	cmp r15, 1
	jne .else_34
;then_34:

;.if_35:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_35
;then_35:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_35:

;.if_36:
	movzx r15, byte [c]
	cmp r15, 10
	jne .end_36
;then_36:
	push qword [line]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line_start], rax

.end_36:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

.while_37:
	mov r15, [true]
	cmp r15, 1
	jne .end_37
;do_37:
	push qword [c]

	call isSpace
	mov [_], rax
	add rsp, 8

;.if_38:
	mov r15, [_]
	cmp r15, 1
	jne .else_38
;then_38:

;.if_39:
	movzx r15, byte [c]
	cmp r15, 10
	jne .end_39
;then_39:
	push qword [line]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line_start], rax

.end_39:
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_38
.else_38:
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

    jmp .end_37

    jmp .end_33

.end_38:

    jmp .while_37
    ; end while_37
.end_37:
	push 1
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [col], rax

        ;printf(roStr_22, [scIndex], [col])
        
	jmp .end_34
.else_34:

;.if_40:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_40
;then_40:

;.if_41:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_41
;then_41:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_41:
	push 0
	pop rax
	mov qword [tokenIndex], rax

        ;token [ tokenIndex ] = c ;
        ;tokenIndex = tokenIndex + 1 ;
        	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

.while_42:
	mov r15, [scIndex]
	cmp r15, [bytesRead]
	jge .end_42
;do_42:

;.if_43:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_43
;then_43:
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_44:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_44
;then_44:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_44
.else_44:

;.if_45:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_45
;then_45:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_45
.else_45:

;.if_46:
	movzx r15, byte [c]
	cmp r15, 110
	jne .else_46
;then_46:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 10
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_46
.else_46:

;.if_47:
	movzx r15, byte [c]
	cmp r15, 114
	jne .else_47
;then_47:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 13
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_47
.else_47:

;.if_48:
	movzx r15, byte [c]
	cmp r15, 116
	jne .else_48
;then_48:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 9
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_48
.else_48:

;.if_49:
	movzx r15, byte [c]
	cmp r15, 48
	jne .else_49
;then_49:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_49
.else_49:

;.if_50:
	movzx r15, byte [c]
	cmp r15, 39
	jne .else_50
;then_50:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 39
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_50
.else_50:

;.if_51:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_51
;then_51:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 92
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

	jmp .end_51
.else_51:

                    printf(roStr_23)
                    ExitProcess(1)
.end_51:

.end_50:

.end_49:

.end_48:

.end_47:

.end_46:

.end_45:

.end_44:

	jmp .end_43
.else_43:

;.if_52:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_52
;then_52:

    jmp .end_42

    jmp .end_33

	jmp .end_52
.else_52:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

.end_52:

.end_43:

    jmp .while_42
    ; end while_42
.end_42:

        ;token [ tokenIndex ] = c ; 
        ;tokenIndex = tokenIndex + 1 ;
        	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

        ;printf(roStr_24, token)
        	push qword [col]
	push qword [line]
	push qword [stringPointersTop]
	push qword [TOKEN_CONSTANT_STRING]

	call push_token
	mov [_], rax
	add rsp, 32

	call push_identifier
	push 2
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [col], rax
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_40
.else_40:

;.if_53:
	mov r15, [isSep]
	cmp r15, 1
	jne .else_53
;then_53:

;.if_54:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_54
;then_54:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_54:
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [col], rax
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

        ;printf(roStr_25, token)
        
;.if_55:
	movzx r15, byte [c]
	cmp r15, 59
	jne .else_55
;then_55:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_SEMICOLON]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_55
.else_55:

;.if_56:
	movzx r15, byte [c]
	cmp r15, 44
	jne .else_56
;then_56:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_COMMA]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_56
.else_56:

;.if_57:
	movzx r15, byte [c]
	cmp r15, 40
	jne .else_57
;then_57:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LEFT_PARENTHESIS]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_57
.else_57:

;.if_58:
	movzx r15, byte [c]
	cmp r15, 41
	jne .else_58
;then_58:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_RIGHT_PARENTHESIS]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_58
.else_58:

;.if_59:
	movzx r15, byte [c]
	cmp r15, 91
	jne .else_59
;then_59:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LEFT_BRACKET]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_59
.else_59:

;.if_60:
	movzx r15, byte [c]
	cmp r15, 93
	jne .else_60
;then_60:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_RIGHT_BRACKET]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_60
.else_60:

;.if_61:
	movzx r15, byte [c]
	cmp r15, 46
	jne .else_61
;then_61:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_DOT]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_61
.else_61:

;.if_62:
	movzx r15, byte [c]
	cmp r15, 64
	jne .else_62
;then_62:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_AT_SIGN]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_62
.else_62:

;.if_63:
	movzx r15, byte [c]
	cmp r15, 38
	jne .end_63
;then_63:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_AMPERSAND]

	call push_token
	mov [_], rax
	add rsp, 32

.end_63:

.end_62:

.end_61:

.end_60:

.end_59:

.end_58:

.end_57:

.end_56:

.end_55:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push 1
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [col], rax

	jmp .end_53
.else_53:

;.if_64:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_64
;then_64:

;.if_65:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_65
;then_65:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [col], rax

.end_65:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_66:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_66
;then_66:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_26, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_EQUALS]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_66
.else_66:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_27, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_ASSIGNMENT]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_66:

	jmp .end_64
.else_64:

;.if_67:
	movzx r15, byte [c]
	cmp r15, 33
	jne .else_67
;then_67:

;.if_68:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_68
;then_68:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_68:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_69:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_69
;then_69:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_28, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_NOT_EQUALS]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_69
.else_69:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_29, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_69:

	jmp .end_67
.else_67:

;.if_70:
	movzx r15, byte [c]
	cmp r15, 60
	jne .else_70
;then_70:

;.if_71:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_71
;then_71:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_71:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_72:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_72
;then_72:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_30, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LESS_THAN_OR_EQUAL_TO]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_72
.else_72:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_31, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LESS_THAN]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_72:

	jmp .end_70
.else_70:

;.if_73:
	movzx r15, byte [c]
	cmp r15, 62
	jne .else_73
;then_73:

;.if_74:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_74
;then_74:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_74:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_75:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_75
;then_75:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_32, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_GREATER_THAN_OR_EQUAL_TO]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_75
.else_75:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_33, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_GREATER_THAN]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_75:

	jmp .end_73
.else_73:

;.if_76:
	movzx r15, byte [c]
	cmp r15, 43
	jne .else_76
;then_76:

;.if_77:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_77
;then_77:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_77:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_78:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_78
;then_78:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_34, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_78
.else_78:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_35, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_PLUS]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_78:

	jmp .end_76
.else_76:

;.if_79:
	movzx r15, byte [c]
	cmp r15, 42
	jne .else_79
;then_79:

;.if_80:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_80
;then_80:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_80:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_81:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_81
;then_81:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_36, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_81
.else_81:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_37, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_MULTIPLY]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_81:

	jmp .end_79
.else_79:

;.if_82:
	movzx r15, byte [c]
	cmp r15, 45
	jne .else_82
;then_82:

;.if_83:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_83
;then_83:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_83:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_84:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_84
;then_84:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_38, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_84
.else_84:

;.if_85:
	movzx r15, byte [c]
	cmp r15, 62
	jne .else_85
;then_85:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_39, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_ARROW_RIGHT]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_85
.else_85:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_40, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_MINUS]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_85:

.end_84:

	jmp .end_82
.else_82:

;.if_86:
	movzx r15, byte [c]
	cmp r15, 47
	jne .else_86
;then_86:

;.if_87:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_87
;then_87:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_87:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_88:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_88
;then_88:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_41, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_88
.else_88:

;.if_89:
	movzx r15, byte [c]
	cmp r15, 47
	jne .else_89
;then_89:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.while_90:
	movzx r15, byte [c]
	cmp r15, 10
	je .end_90
;do_90:
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

    jmp .while_90
    ; end while_90
.end_90:
	push qword [line]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [line_start], rax
	push 1
	push qword [scIndex]
	push qword [line_start]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [col], rax

	jmp .end_89
.else_89:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_42, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_DIVIDE]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_89:

.end_88:

	jmp .end_86
.else_86:

;.if_91:
	movzx r15, byte [c]
	cmp r15, 37
	jne .else_91
;then_91:

;.if_92:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_92
;then_92:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_92:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

;.if_93:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_93
;then_93:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_43, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_93
.else_93:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_44, token)
            	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_MODULO]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax
	push qword [scIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

.end_93:

	jmp .end_91
.else_91:
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [c]
	mov byte [rdx], al
	push qword [tokenIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenIndex], rax

.end_91:

.end_86:

.end_82:

.end_79:

.end_76:

.end_73:

.end_70:

.end_67:

.end_64:

.end_53:

.end_40:

.end_34:
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

    jmp .while_33
    ; end while_33
.end_33:

printf(roStr_45, [tokenCount])

section .data
	globalBlockId dq 0
section .text

section .data
	globalProcedureId dq 1
section .text

section .data
	globalUserTypeId dq 1
section .text

section .data
	globalBoolParsingProcedure dq 0
section .text

section .data
	globalAllowVariableDeclaration dq 1
section .text

section .data
	ppdLocalVariableCount dq 0
section .text

section .data
	ppdRbpOffset dq 0
section .text
section .bss
	globalVariables resq 10000
section .text

section .data
	globalVariableCount dq 0
section .text

section .data
	globalVariableSize dq 6
section .text

section .data
	gvTypeOffset dq 0
section .text

section .data
	gvSubTypeOffset dq 1
section .text

section .data
	gvKindOffset dq 2
section .text

section .data
	gvNameOffset dq 3
section .text

section .data
	gvValueOffset dq 4
section .text

section .data
	gvScopeOffset dq 5
section .text

section .data
	gvType dq 0
section .text

section .data
	gvSubType dq 0
section .text

section .data
	gvKind dq 0
section .text

section .data
	gvNamePointer dq 0
section .text

section .data
	gvValue dq 0
section .text

section .data
	gvScope dq 0
section .text

section .data
	_av dq 0
section .text

	jmp addVariable_end
addVariable:
	push rbp
	mov rbp, rsp
	push qword [gvTypeOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [gvSubTypeOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 24]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [gvKindOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 32]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [gvNameOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 40]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [gvValueOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 48]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [gvScopeOffset]
	push qword [globalVariableCount]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 56]
	pop rax
	mov qword [_av], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	mov rax, [_av]
	mov [rdx], rax
	push qword [globalVariableCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalVariableCount], rax

	mov rsp, rbp
	pop rbp
	ret
addVariable_end:
section .bss
	globalSymbolTable resq 10000
section .text

section .data
	globalSymbolsCount dq 0
section .text

section .data
	globalSymbolSize dq 6
section .text

section .data
	gsType dq 0
section .text

section .data
	gsSubType dq 0
section .text

section .data
	gsKind dq 0
section .text

section .data
	gsNamePointer dq 0
section .text

section .data
	gsValue dq 0
section .text

section .data
	gsScope dq 0
section .text

section .data
	gsTypeOffset dq 0
section .text

section .data
	gsSubTypeOffset dq 1
section .text

section .data
	gsKindOffset dq 2
section .text

section .data
	gsNameOffset dq 3
section .text

section .data
	gsValueOffset dq 4
section .text

section .data
	gsScopeOffset dq 5
section .text

section .data
	_as dq 0
section .text

	jmp addSymbol_end
addSymbol:
	push rbp
	mov rbp, rsp
	push qword [gvTypeOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [gvSubTypeOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 24]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [gvKindOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 32]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [gvNameOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 40]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [gvValueOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 48]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [gvScopeOffset]
	push qword [globalSymbolsCount]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 56]
	pop rax
	mov qword [_as], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	mov rax, [_as]
	mov [rdx], rax
	push qword [globalSymbolsCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalSymbolsCount], rax

	mov rsp, rbp
	pop rbp
	ret
addSymbol_end:

	jmp stringsEqual_end
stringsEqual:
	push rbp
	mov rbp, rsp
	push qword [rbp + 16]

	call readString
	mov [_], rax
	add rsp, 8

    mov rsi, rax
    mov rax, stringBuffer
    add rsi, rax
    	push qword [rbp + 24]

	call readString
	mov [_], rax
	add rsp, 8

    mov rdi, rax
    mov rax, stringBuffer
    add rdi, rax
.t:
    ;printf(roStr_46, rsi, rdi)
.loop:
    mov al, byte [rdi]
    mov bl, byte [rsi]
    cmp al, bl
    jne .str_neq
    cmp al, 0
    je .str1_null
    cmp bl, 0
    je .str2_null
    inc rdi
    inc rsi
    jmp .loop

.str1_null:
    cmp bl, 0
    je .str_eq
    jmp .str_neq

.str2_null:
    cmp al, 0
    je .str_eq
    jmp .str_neq    

.str_neq:
    xor rax, rax
    jmp .end

.str_eq:
    mov rax, 1
.end: 
	mov rsp, rbp
	pop rbp
	ret
stringsEqual_end:

section .data
	fgsIndex dq 0
section .text

section .data
	fgsNamePointer dq 0
section .text

section .data
	fgsScope dq 0
section .text

section .data
	fgsEqual dq 0
section .text

	jmp findSymbol_end
findSymbol:
	push rbp
	mov rbp, rsp
	push qword [globalSymbolsCount]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

.while_94:
	mov r15, [fgsIndex]
	cmp r15, 0
	jl .end_94
;do_94:
	push qword [gvNameOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [fgsNamePointer], rax
	push qword [gvScopeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [fgsScope], rax

;.if_95:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 1
	jne .else_95
;then_95:

;.if_96:
	mov r15, [fgsScope]
	cmp r15, [globalProcedureId]
	je .end_96
;then_96:

;.if_97:
	mov r15, [fgsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_97
;then_97:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_94

.end_97:

.end_96:

	jmp .end_95
.else_95:

;.if_98:
	mov r15, [fgsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_98
;then_98:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_94

.end_98:

.end_95:
	push qword [fgsNamePointer]
	push qword [rbp + 16]

	call stringsEqual
	mov [fgsEqual], rax
	add rsp, 16

;.if_99:
	mov r15, [fgsEqual]
	cmp r15, 0
	je .end_99
;then_99:

    jmp .end_94

.end_99:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_94
    ; end while_94
.end_94:

;.if_100:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_100
;then_100:
	push qword [gsTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsType], rax
	push qword [gsSubTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsSubType], rax
	push qword [gsKindOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsKind], rax
	push qword [gsNameOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsNamePointer], rax
	push qword [gsValueOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsValue], rax
	push qword [gsScopeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsScope], rax
	push qword [gvValueOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax

        ;printf(roStr_47, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_100
.else_100:
	push 0
	pop rax
	mov qword [gsType], rax
	push 0
	pop rax
	mov qword [gsSubType], rax
	push 0
	pop rax
	mov qword [gsNamePointer], rax
	push 0
	pop rax
	mov qword [gsValue], rax
	push 0
	pop rax
	mov qword [gsScope], rax

        ;printf(roStr_48)
        mov rax, -1 
.end_100:

	mov rsp, rbp
	pop rbp
	ret
findSymbol_end:

section .data
	futUserType dq 0
section .text

	jmp findUserType_end
findUserType:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [fgsIndex], rax
	push 0
	pop rax
	mov qword [fgsEqual], rax

.while_101:
	mov r15, [fgsIndex]
	cmp r15, [globalSymbolsCount]
	jge .end_101
;do_101:
	push qword [gsTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

;.if_102:
	mov r15, [_]
	cmp r15, [TYPE_USER_DEFINED]
	je .end_102
;then_102:
	push qword [fgsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_101

.end_102:
	push qword [gsSubTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax
	push qword [rbp + 16]
	pop rax
	mov qword [futUserType], rax

;.if_103:
	mov r15, [_]
	cmp r15, [futUserType]
	jne .end_103
;then_103:
	push 1
	pop rax
	mov qword [fgsEqual], rax

    jmp .end_101

.end_103:
	push qword [fgsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_101
    ; end while_101
.end_101:

;.if_104:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_104
;then_104:
	push qword [gsTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsType], rax
	push qword [gsSubTypeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsSubType], rax
	push qword [gsKindOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsKind], rax
	push qword [gsNameOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsNamePointer], rax
	push qword [gsValueOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsValue], rax
	push qword [gsScopeOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gsScope], rax
	push qword [gvValueOffset]
	push qword [fgsIndex]
	push qword [globalSymbolSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalSymbolTable
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

        ;printf(roStr_49, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_104
.else_104:
	push 0
	pop rax
	mov qword [gsType], rax
	push 0
	pop rax
	mov qword [gsSubType], rax
	push 0
	pop rax
	mov qword [gsNamePointer], rax
	push 0
	pop rax
	mov qword [gsValue], rax
	push 0
	pop rax
	mov qword [gsScope], rax

        ;printf(roStr_50)
        mov rax, -1 
.end_104:

	mov rsp, rbp
	pop rbp
	ret
findUserType_end:

section .data
	currentToken dq 0
section .text

section .data
	expectedToken dq 0
section .text

section .data
	nextToken dq 0
section .text
section .bss
	userTypes resq 10000
section .text

section .data
	userTypeCount dq 0
section .text

section .data
	userTypeSize dq 4
section .text

section .data
	utParentOffset dq 0
section .text

section .data
	utTypeOffset dq 1
section .text

section .data
	utNameOffset dq 2
section .text

section .data
	utOffsetOffset dq 3
section .text

section .data
	utParent dq 0
section .text

section .data
	utType dq 0
section .text

section .data
	utNamePointer dq 0
section .text

section .data
	utOffset dq 0
section .text

	jmp addUserTypeField_end
addUserTypeField:
	push rbp
	mov rbp, rsp
	push qword [utParentOffset]
	push qword [userTypeCount]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 16]
	pop rax
	mov qword [utParent], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	mov rax, [utParent]
	mov [rdx], rax
	push qword [utTypeOffset]
	push qword [userTypeCount]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 24]
	pop rax
	mov qword [utType], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	mov rax, [utType]
	mov [rdx], rax
	push qword [utNameOffset]
	push qword [userTypeCount]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 32]
	pop rax
	mov qword [utNamePointer], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	mov rax, [utNamePointer]
	mov [rdx], rax
	push qword [utOffsetOffset]
	push qword [userTypeCount]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [rbp + 40]
	pop rax
	mov qword [utOffset], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	mov rax, [utOffset]
	mov [rdx], rax
	push qword [userTypeCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [userTypeCount], rax

	mov rsp, rbp
	pop rbp
	ret
addUserTypeField_end:

	jmp findUserTypeField_end
findUserTypeField:
	push rbp
	mov rbp, rsp
	push qword [globalSymbolsCount]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

.while_105:
	mov r15, [userTypeCount]
	cmp r15, 0
	jl .end_105
;do_105:
	push qword [utParentOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utParent], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_], rax

;.if_106:
	mov r15, [utParent]
	cmp r15, [_]
	je .end_106
;then_106:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_105

.end_106:
	push qword [utNameOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utNamePointer], rax
	push qword [utNamePointer]
	push qword [rbp + 24]

	call stringsEqual
	mov [fgsEqual], rax
	add rsp, 16

;.if_107:
	mov r15, [fgsEqual]
	cmp r15, 0
	je .end_107
;then_107:

    jmp .end_105

.end_107:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_105
    ; end while_105
.end_105:

;.if_108:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_108
;then_108:
	push qword [utParentOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utParent], rax
	push qword [utTypeOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utType], rax
	push qword [utNameOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utNamePointer], rax
	push qword [utOffsetOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [utOffset], rax
	push qword [utOffsetOffset]
	push qword [fgsIndex]
	push qword [userTypeSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, userTypes
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

        ;printf(roStr_51, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_108
.else_108:
	push 0
	pop rax
	mov qword [utParent], rax
	push 0
	pop rax
	mov qword [utType], rax
	push 0
	pop rax
	mov qword [utNamePointer], rax
	push 0
	pop rax
	mov qword [utOffset], rax

        ;printf(roStr_52)
        mov rax, -1 
.end_108:

	mov rsp, rbp
	pop rbp
	ret
findUserTypeField_end:

	jmp pushString_end
pushString:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, stringToPush
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al
	mov rax, [stringPointersTop]
	mov rdx, 8
	mul rdx
	mov rdx, stringPointers
	add rdx, rax
	mov rax, [stringBufferTop]
	mov [rdx], rax

.while_109:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_109
;do_109:
	mov rdx, stringBuffer
	add rdx, [stringBufferTop]
	movzx rax, byte [freeChar]
	mov byte [rdx], al
	push qword [stringBufferTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringBufferTop], rax
	push qword [freeStringIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [freeStringIndex], rax
	mov rdx, stringToPush
	add rdx, [freeStringIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

    jmp .while_109
    ; end while_109
.end_109:
	mov rdx, stringBuffer
	add rdx, [stringBufferTop]
	mov byte [rdx], 0
	push qword [stringBufferTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringBufferTop], rax

    ;printf(roStr_53, [stringPointersTop], [freeStringIndex])
    	push qword [stringPointersTop]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [stringPointersTop], rax

	mov rsp, rbp
	pop rbp
	ret
pushString_end:
section .bss
	stringAtPointer resb 256
section .text

	jmp readString_end
readString:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [freeStringIndex], rax
	push qword [rbp + 16]
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, stringPointers
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [sbIndex], rax
	push qword [sbIndex]
	pop rax
	mov qword [_], rax
	mov rdx, stringBuffer
	add rdx, [sbIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

.while_110:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_110
;do_110:
	mov rdx, stringAtPointer
	add rdx, [freeStringIndex]
	movzx rax, byte [freeChar]
	mov byte [rdx], al
	push qword [freeStringIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [freeStringIndex], rax
	push qword [sbIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [sbIndex], rax
	mov rdx, stringBuffer
	add rdx, [sbIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [freeChar], al

    jmp .while_110
    ; end while_110
.end_110:
	mov rdx, stringAtPointer
	add rdx, [freeStringIndex]
	mov byte [rdx], 0

    ;printf(roStr_54, [rbp + 16], [freeStringIndex])
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
readString_end:

section .data
	errorAtLine dq 0
section .text

section .data
	errorAtColumn dq 0
section .text

	jmp consumeToken_end
consumeToken:
	push rbp
	mov rbp, rsp

;.if_111:
	mov r15, [currentToken]
	cmp r15, [expectedToken]
	jne .else_111
;then_111:
	push qword [i]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax
	push qword [i]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [nextToken], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [i], rax

	jmp .end_111
.else_111:
	push qword [i]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax

        printf(roStr_55, [errorAtLine], [errorAtColumn])
        printf(roStr_56, [expectedToken], [currentToken])
        ExitProcess(1) 
.end_111:

	mov rsp, rbp
	pop rbp
	ret
consumeToken_end:

	jmp indentifierRedeclared_end
indentifierRedeclared:
	push rbp
	mov rbp, rsp
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
	push qword [rbp + 16]

	call readString
	mov [_], rax
	add rsp, 8
 
    printf(roStr_57, [errorAtLine], [errorAtColumn])
    printf(roStr_58, stringAtPointer) ;
    ExitProcess(1)
	mov rsp, rbp
	pop rbp
	ret
indentifierRedeclared_end:

	jmp identifierUnknown_end
identifierUnknown:
	push rbp
	mov rbp, rsp
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
	push qword [rbp + 16]

	call readString
	mov [_], rax
	add rsp, 8
 
    printf(roStr_59, [errorAtLine], [errorAtColumn])
    printf(roStr_60, stringAtPointer) ;
    ExitProcess(1)
	mov rsp, rbp
	pop rbp
	ret
identifierUnknown_end:

	jmp unexpectedToken_end
unexpectedToken:
	push rbp
	mov rbp, rsp
	push qword [i]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax

    printf(roStr_61, [errorAtLine], [errorAtColumn])
    printf(roStr_62, [currentToken])
    ExitProcess(1)
	mov rsp, rbp
	pop rbp
	ret
unexpectedToken_end:

	jmp parseNumber_end
parseNumber:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_CONSTANT_INTEGER]
	pop rax
	mov qword [expectedToken], rax
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

	call consumeToken

    ;printf(roStr_63, [_])
    ; set result
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
parseNumber_end:

	jmp parseIdentifier_end
parseIdentifier:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_IDENTIFIER]
	pop rax
	mov qword [expectedToken], rax
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

	call consumeToken

    ;printf(roStr_64, [_])
    ; set result
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
parseIdentifier_end:

	jmp parseType_end
parseType:
	push rbp
	mov rbp, rsp

;.if_112:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_112
;then_112:
	push qword [TYPE_UINT8]
	pop rax
	mov qword [_], rax
	push qword [i]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax

	jmp .end_112
.else_112:

;.if_113:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_113
;then_113:
	push qword [TYPE_UINT64]
	pop rax
	mov qword [_], rax
	push qword [i]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax

	jmp .end_113
.else_113:

;.if_114:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_114
;then_114:
	push qword [TYPE_POINTER]
	pop rax
	mov qword [_], rax
	push qword [i]
	push qword [tokenSize]
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax

	jmp .end_114
.else_114:

	call unexpectedToken

.end_114:

.end_113:

.end_112:

    ; set result
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
parseType_end:

	jmp parseString_end
parseString:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_CONSTANT_STRING]
	pop rax
	mov qword [expectedToken], rax
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

	call consumeToken

    ;printf(roStr_65, [_])
    ; set result
    mov rax, [_]
	mov rsp, rbp
	pop rbp
	ret
parseString_end:

section .data
	padIdentifier dq 0
section .text

	jmp parseArrayDeclaration_end
parseArrayDeclaration:
	push rbp
	mov rbp, rsp

;.if_115:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	je .end_115
;then_115:
	push qword [i]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax

        printf(roStr_66, [errorAtLine], [errorAtColumn])
        printf(roStr_67)
.end_115:
	push qword [TOKEN_LEFT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_116:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_116
;then_116:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

        ;printf(roStr_68, [gvValue])
        	push qword [TOKEN_RIGHT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [gvType]
	pop rax
	mov qword [gvSubType], rax
	push qword [TYPE_ARRAY]
	pop rax
	mov qword [gvType], rax

        ;printf(roStr_69, [gvType], [gvSubType])
        	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48

        ;printf(roStr_70, [gvType], [gvValue])
	jmp .end_116
.else_116:

;.if_117:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_117
;then_117:

	call parseIdentifier
	mov [padIdentifier], rax
	add rsp, 0
	push qword [padIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_118:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_118
;then_118:
	push qword [padIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_118:

;.if_119:
	mov r15, [gsType]
	cmp r15, [TYPE_DEFINE]
	je .end_119
;then_119:
	push qword [i]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax

            printf(roStr_71, [errorAtLine], [errorAtColumn])
            printf(roStr_72)
            ExitProcess(1)
.end_119:
	push qword [gsValue]
	pop rax
	mov qword [gvValue], rax
	push qword [TOKEN_RIGHT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [gvType]
	pop rax
	mov qword [gvSubType], rax
	push qword [TYPE_ARRAY]
	pop rax
	mov qword [gvType], rax

        ;printf(roStr_73, [gvType], [gvSubType])
        	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48

        ;printf(roStr_74, [gvType], [gvValue])
	jmp .end_117
.else_117:
	push qword [TOKEN_RIGHT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [TYPE_STRING]
	pop rax
	mov qword [gvSubType], rax
	push qword [TYPE_ARRAY]
	pop rax
	mov qword [gvType], rax
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseString
	mov [gvValue], rax
	add rsp, 0

        ;printf(roStr_75, [gvType], [gvSubType])
        	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvSubType]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48

        ;printf(roStr_76, [gvType], [gvValue])
.end_117:

.end_116:

	mov rsp, rbp
	pop rbp
	ret
parseArrayDeclaration_end:

section .data
	pidIndentifier dq 0
section .text

	jmp parseIntegerDeclaration_end
parseIntegerDeclaration:
	push rbp
	mov rbp, rsp

	call parseIdentifier
	mov [pidIndentifier], rax
	add rsp, 0
	push qword [pidIndentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_120:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_120
;then_120:
	push qword [pidIndentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_120:
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_121:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_121
;then_121:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

	jmp .end_121
.else_121:
	push 0
	pop rax
	mov qword [gvValue], rax

	call parseLogicalOrExpression

.end_121:

;.if_122:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	jne .else_122
;then_122:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [pidIndentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword 0
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [pidIndentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword 0
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [pidIndentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_77, stringAtPointer)
	jmp .end_122
.else_122:
	push qword [globalProcedureId]
	push qword [gvValue]
	push qword [pidIndentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_LOCAL]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [globalProcedureId]
	push qword [ppdRbpOffset]
	push qword [pidIndentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_LOCAL]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [ppdRbpOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax

.end_122:

	mov rsp, rbp
	pop rbp
	ret
parseIntegerDeclaration_end:

	jmp parsePointerDeclaration_end
parsePointerDeclaration:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [gvNamePointer]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_123:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_123
;then_123:
	push qword [gvNamePointer]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_123:
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

;.if_124:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	jne .else_124
;then_124:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvType]
	push qword [TYPE_POINTER]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvType]
	push qword [TYPE_POINTER]

	call addSymbol
	mov [_], rax
	add rsp, 48

	jmp .end_124
.else_124:

        printf(roStr_78)
        ExitProcess(1)
.end_124:

    ;printf(roStr_79, [gvType], [gvValue])
	mov rsp, rbp
	pop rbp
	ret
parsePointerDeclaration_end:

	jmp parseVariableDeclaration_end
parseVariableDeclaration:
	push rbp
	mov rbp, rsp

;.if_125:
	mov r15, [globalAllowVariableDeclaration]
	cmp r15, 0
	jne .end_125
;then_125:
	push qword [i]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax

        printf(roStr_80, [errorAtLine], [errorAtColumn])
        printf(roStr_81)
.end_125:
	push qword [ppdLocalVariableCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdLocalVariableCount], rax

	call parseType
	mov [gvType], rax
	add rsp, 0

;.if_126:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_126
;then_126:

	call parseArrayDeclaration

	jmp .end_126
.else_126:

;.if_127:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_127
;then_127:

	call parseIntegerDeclaration

	jmp .end_127
.else_127:

;.if_128:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_128
;then_128:

	call parsePointerDeclaration

	jmp .end_128
.else_128:

	call unexpectedToken

.end_128:

.end_127:

.end_126:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	mov rsp, rbp
	pop rbp
	ret
parseVariableDeclaration_end:

section .data
	psosIdentifier dq 0
section .text

	jmp parseSizeOfStatement_end
parseSizeOfStatement:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_SIZEOF]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [psosIdentifier], rax
	add rsp, 0
	push qword [psosIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_129:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_129
;then_129:
	push qword [psosIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_129:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [psosIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    WriteToFile(roStr_82, [gsValue], stringAtPointer)
	mov rsp, rbp
	pop rbp
	ret
parseSizeOfStatement_end:

section .data
	pfStructFieldIdentifier dq 0
section .text

section .data
	pfType dq 0
section .text

section .data
	fpIdentifier dq 0
section .text

	jmp parseFactor_end
parseFactor:
	push rbp
	mov rbp, rsp

;.if_130:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_130
;then_130:

	call parseNumber
	mov [_], rax
	add rsp, 0

;.if_131:
	mov r15, [_]
	cmp r15, 2147483647
	jle .else_131
;then_131:

            WriteToFile(roStr_83, [_])
	jmp .end_131
.else_131:

            WriteToFile(roStr_84, [_])
.end_131:

	jmp .end_130
.else_130:

;.if_132:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_132
;then_132:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	jmp .end_132
.else_132:

;.if_133:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_133
;then_133:

;.if_134:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_134
;then_134:

	call parseArrayAccess
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_135:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_135
;then_135:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_135:

;.if_136:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_136
;then_136:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_137:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_137
;then_137:

                    WriteToFile(roStr_85)
                    WriteToFile(roStr_86, stringAtPointer)
	jmp .end_137
.else_137:

;.if_138:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_138
;then_138:

                    WriteToFile(roStr_87)
                    WriteToFile(roStr_88, stringAtPointer)
	jmp .end_138
.else_138:

;.if_139:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_139
;then_139:

                    WriteToFile(roStr_89)
                    WriteToFile(roStr_90, stringAtPointer)
	jmp .end_139
.else_139:

;.if_140:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_140
;then_140:

                    WriteToFile(roStr_91)
                    WriteToFile(roStr_92, stringAtPointer)
	jmp .end_140
.else_140:
 
                    printf(roStr_93, [gsSubType])
                    ExitProcess(1)
.end_140:

.end_139:

.end_138:

.end_137:

	jmp .end_136
.else_136:
	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [gsSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_141:
	mov r15, [_]
	cmp r15, -1
	jne .end_141
;then_141:

                    printf(roStr_94, [gsSubType])
                    ExitProcess(1)
.end_141:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

                WriteToFile(roStr_95)
                WriteToFile(roStr_96, [gsValue], stringAtPointer)
                
;.if_142:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DOT]
	jne .else_142
;then_142:
	push qword [TOKEN_DOT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [pfStructFieldIdentifier], rax
	add rsp, 0
	push qword [pfStructFieldIdentifier]
	push qword [pfType]

	call findUserTypeField
	mov [fgsIndex], rax
	add rsp, 16

                    WriteToFile(roStr_97)
                    WriteToFile(roStr_98, [utOffset])
	jmp .end_142
.else_142:

                    printf(roStr_99)
.end_142:

.end_136:

            ;printf(roStr_100)
	jmp .end_134
.else_134:

;.if_143:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_143
;then_143:

	call parseProcedureCall

            ;printf(roStr_101)
            WriteToFile(roStr_102)
	jmp .end_143
.else_143:

;.if_144:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_144
;then_144:

	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_145:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_145
;then_145:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_145:
	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_103)
            WriteToFile(roStr_104, stringAtPointer)
            	push qword [TOKEN_DOT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [pfStructFieldIdentifier], rax
	add rsp, 0
	push qword [pfStructFieldIdentifier]
	push qword [pfType]

	call findUserTypeField
	mov [fgsIndex], rax
	add rsp, 16

            WriteToFile(roStr_105, [utOffset])
	jmp .end_144
.else_144:

            ; procedure stuff
            	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [_], rax

            ;printf(roStr_106, [_])
            
	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_146:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_146
;then_146:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_146:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_147:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_147
;then_147:

;.if_148:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT8]
	jne .else_148
;then_148:
 
                    WriteToFile(roStr_107, stringAtPointer)
	jmp .end_148
.else_148:

;.if_149:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT64]
	jne .else_149
;then_149:
 
                    WriteToFile(roStr_108, stringAtPointer)
	jmp .end_149
.else_149:

;.if_150:
	mov r15, [gsType]
	cmp r15, [TYPE_POINTER]
	jne .else_150
;then_150:

                    WriteToFile(roStr_109, stringAtPointer)
	jmp .end_150
.else_150:

;.if_151:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_151
;then_151:

                    WriteToFile(roStr_110, stringAtPointer)
	jmp .end_151
.else_151:

;.if_152:
	mov r15, [gsType]
	cmp r15, [TYPE_ARRAY]
	jne .else_152
;then_152:
 
                    WriteToFile(roStr_111, stringAtPointer)
	jmp .end_152
.else_152:

;.if_153:
	mov r15, [gsType]
	cmp r15, [TYPE_DEFINE]
	jne .else_153
;then_153:

                    WriteToFile(roStr_112, [gsValue], stringAtPointer)
	jmp .end_153
.else_153:
 
                    printf(roStr_113, [gsType])
                    ExitProcess(1)
.end_153:

.end_152:

.end_151:

.end_150:

.end_149:

.end_148:

	jmp .end_147
.else_147:

;.if_154:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .else_154
;then_154:
 
                    WriteToFile(roStr_114, [gsValue])
	jmp .end_154
.else_154:

;.if_155:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_155
;then_155:
 
                    WriteToFile(roStr_115, [gsValue])
	jmp .end_155
.else_155:
 
                    printf(roStr_116, [gsType])
                    ExitProcess(1)
.end_155:

.end_154:

.end_147:

.end_144:

.end_143:

.end_134:

	jmp .end_133
.else_133:

;.if_156:
	mov r15, [currentToken]
	cmp r15, [TOKEN_AMPERSAND]
	jne .else_156
;then_156:
	push qword [TOKEN_AMPERSAND]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_157:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_157
;then_157:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_157:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_117, stringAtPointer)
	jmp .end_156
.else_156:

;.if_158:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_158
;then_158:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_159:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_159
;then_159:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_159:

        printf(roStr_118, [gsType])
        	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_160:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_160
;then_160:

        printf(roStr_119)
        	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_120)
            WriteToFile(roStr_121, stringAtPointer)
            	push qword [TOKEN_DOT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [pfStructFieldIdentifier], rax
	add rsp, 0
	push qword [pfStructFieldIdentifier]
	push qword [pfType]

	call findUserTypeField
	mov [fgsIndex], rax
	add rsp, 16

            WriteToFile(roStr_122, [utOffset])
	jmp .end_160
.else_160:

;.if_161:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_161
;then_161:

                WriteToFile(roStr_123, stringAtPointer)
	jmp .end_161
.else_161:

;.if_162:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_162
;then_162:

                WriteToFile(roStr_124, stringAtPointer)
	jmp .end_162
.else_162:

                printf(roStr_125, [gsType])
                ExitProcess(1)
.end_162:

.end_161:

.end_160:

	jmp .end_158
.else_158:

;.if_163:
	mov r15, [currentToken]
	cmp r15, [TOKEN_SIZEOF]
	jne .else_163
;then_163:

	call parseSizeOfStatement

	jmp .end_163
.else_163:

	call unexpectedToken

.end_163:

.end_158:

.end_156:

.end_133:

.end_132:

.end_130:

	mov rsp, rbp
	pop rbp
	ret
parseFactor_end:

	jmp parseMultiplicativeExpression_end
parseMultiplicativeExpression:
	push rbp
	mov rbp, rsp

	call parseFactor

.while_164:
	mov r15, [true]
	cmp r15, 1
	jne .end_164
;do_164:

;.if_165:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_165
;then_165:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_126)
            WriteToFile(roStr_127)
	jmp .end_165
.else_165:

;.if_166:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DIVIDE]
	jne .else_166
;then_166:
	push qword [TOKEN_DIVIDE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_128)
            WriteToFile(roStr_129)
	jmp .end_166
.else_166:

;.if_167:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MODULO]
	jne .else_167
;then_167:
	push qword [TOKEN_MODULO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_130)
            WriteToFile(roStr_131)
	jmp .end_167
.else_167:

    jmp .end_164

.end_167:

.end_166:

.end_165:

    jmp .while_164
    ; end while_164
.end_164:

	mov rsp, rbp
	pop rbp
	ret
parseMultiplicativeExpression_end:

	jmp parseAdditiveExpression_end
parseAdditiveExpression:
	push rbp
	mov rbp, rsp

	call parseMultiplicativeExpression

.while_168:
	mov r15, [true]
	cmp r15, 1
	jne .end_168
;do_168:

;.if_169:
	mov r15, [currentToken]
	cmp r15, [TOKEN_PLUS]
	jne .else_169
;then_169:
	push qword [TOKEN_PLUS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseMultiplicativeExpression

            WriteToFile(roStr_132)
            WriteToFile(roStr_133)
	jmp .end_169
.else_169:

;.if_170:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MINUS]
	jne .else_170
;then_170:
	push qword [TOKEN_MINUS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseMultiplicativeExpression

            WriteToFile(roStr_134)
            WriteToFile(roStr_135)
	jmp .end_170
.else_170:

    jmp .end_168

.end_170:

.end_169:

    jmp .while_168
    ; end while_168
.end_168:

	mov rsp, rbp
	pop rbp
	ret
parseAdditiveExpression_end:

section .data
	preIndex dq 0
section .text

	jmp parseRelationalExpression_end
parseRelationalExpression:
	push rbp
	mov rbp, rsp

	call parseAdditiveExpression

;.if_171:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LESS_THAN]
	jne .else_171
;then_171:
	push qword [TOKEN_LESS_THAN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_136)
        WriteToFile(roStr_137, [preIndex], [preIndex])
        WriteToFile(roStr_138, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_171
.else_171:

;.if_172:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LESS_THAN_OR_EQUAL_TO]
	jne .else_172
;then_172:
	push qword [TOKEN_LESS_THAN_OR_EQUAL_TO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_139)
        WriteToFile(roStr_140, [preIndex], [preIndex])
        WriteToFile(roStr_141, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_172
.else_172:

;.if_173:
	mov r15, [currentToken]
	cmp r15, [TOKEN_GREATER_THAN]
	jne .else_173
;then_173:
	push qword [TOKEN_GREATER_THAN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_142)
        WriteToFile(roStr_143, [preIndex], [preIndex])
        WriteToFile(roStr_144, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_173
.else_173:

;.if_174:
	mov r15, [currentToken]
	cmp r15, [TOKEN_GREATER_THAN_OR_EQUAL_TO]
	jne .else_174
;then_174:
	push qword [TOKEN_GREATER_THAN_OR_EQUAL_TO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_145)
        WriteToFile(roStr_146, [preIndex], [preIndex])
        WriteToFile(roStr_147, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_174
.else_174:

;.if_175:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EQUALS]
	jne .else_175
;then_175:
	push qword [TOKEN_EQUALS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_148)
        WriteToFile(roStr_149, [preIndex], [preIndex])
        WriteToFile(roStr_150, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_175
.else_175:

;.if_176:
	mov r15, [currentToken]
	cmp r15, [TOKEN_NOT_EQUALS]
	jne .end_176
;then_176:
	push qword [TOKEN_NOT_EQUALS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_151)
        WriteToFile(roStr_152, [preIndex], [preIndex])
        WriteToFile(roStr_153, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

.end_176:

.end_175:

.end_174:

.end_173:

.end_172:

.end_171:

	mov rsp, rbp
	pop rbp
	ret
parseRelationalExpression_end:

	jmp parseLogicalAndExpression_end
parseLogicalAndExpression:
	push rbp
	mov rbp, rsp

	call parseRelationalExpression

.while_177:
	mov r15, [true]
	cmp r15, 1
	jne .end_177
;do_177:

;.if_178:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LOGICAL_AND]
	jne .else_178
;then_178:
	push qword [TOKEN_LOGICAL_AND]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseRelationalExpression

            WriteToFile(roStr_154)
            WriteToFile(roStr_155)
	jmp .end_178
.else_178:

    jmp .end_177

.end_178:

    jmp .while_177
    ; end while_177
.end_177:

	mov rsp, rbp
	pop rbp
	ret
parseLogicalAndExpression_end:

	jmp parseLogicalOrExpression_end
parseLogicalOrExpression:
	push rbp
	mov rbp, rsp

    WriteToFile(roStr_156)
    
	call parseLogicalAndExpression

.while_179:
	mov r15, [true]
	cmp r15, 1
	jne .end_179
;do_179:

;.if_180:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LOGICAL_OR]
	jne .else_180
;then_180:
	push qword [TOKEN_LOGICAL_OR]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseLogicalAndExpression

            WriteToFile(roStr_157)
            WriteToFile(roStr_158)
	jmp .end_180
.else_180:

    jmp .end_179

.end_180:

    jmp .while_179
    ; end while_179
.end_179:

	mov rsp, rbp
	pop rbp
	ret
parseLogicalOrExpression_end:

section .data
	paaIdentifier dq 0
section .text

	jmp parseArrayAccess_end
parseArrayAccess:
	push rbp
	mov rbp, rsp

	call parseIdentifier
	mov [paaIdentifier], rax
	add rsp, 0
	push qword [TOKEN_LEFT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression
	push qword [TOKEN_RIGHT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    mov rax, [paaIdentifier]
	mov rsp, rbp
	pop rbp
	ret
parseArrayAccess_end:

section .data
	psaType dq 0
section .text

section .data
	psaIdentifier dq 0
section .text

section .data
	psaStructFieldIdentifier dq 0
section .text

	jmp parseStructAccess_end
parseStructAccess:
	push rbp
	mov rbp, rsp

	call parseIdentifier
	mov [psaIdentifier], rax
	add rsp, 0
	push qword [psaIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_181:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_181
;then_181:
	push qword [psaIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_181:
	push qword [gsSubType]
	pop rax
	mov qword [psaType], rax
	push qword [psaIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_182:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_182
;then_182:

        WriteToFile(roStr_159)
        WriteToFile(roStr_160, stringAtPointer)
	jmp .end_182
.else_182:

        WriteToFile(roStr_161)
        WriteToFile(roStr_162, stringAtPointer)
.end_182:
	push qword [TOKEN_DOT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [psaStructFieldIdentifier], rax
	add rsp, 0
	push qword [psaStructFieldIdentifier]
	push qword [psaType]

	call findUserTypeField
	mov [fgsIndex], rax
	add rsp, 16

    WriteToFile(roStr_163, [utOffset])
    mov rax, [psaIdentifier]
	mov rsp, rbp
	pop rbp
	ret
parseStructAccess_end:

section .data
	paIdentifier dq 0
section .text

section .data
	paUTFieldIdentifier dq 0
section .text

section .data
	paType dq 0
section .text

section .data
	paStructFieldIdentifier dq 0
section .text

	jmp parseAssignable_end
parseAssignable:
	push rbp
	mov rbp, rsp

;.if_183:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_183
;then_183:

	call parseArrayAccess
	mov [paIdentifier], rax
	add rsp, 0
	push qword [paIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_184:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_184
;then_184:
	push qword [paIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_184:

;.if_185:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_185
;then_185:
	push qword [paIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_186:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_186
;then_186:

                WriteToFile(roStr_164)
                WriteToFile(roStr_165, stringAtPointer)
	jmp .end_186
.else_186:

;.if_187:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_187
;then_187:

                WriteToFile(roStr_166)
                WriteToFile(roStr_167, stringAtPointer)
	jmp .end_187
.else_187:

;.if_188:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_188
;then_188:

                WriteToFile(roStr_168)
                WriteToFile(roStr_169, stringAtPointer)
	jmp .end_188
.else_188:

;.if_189:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_189
;then_189:

                WriteToFile(roStr_170)
                WriteToFile(roStr_171, stringAtPointer)
	jmp .end_189
.else_189:
 
                printf(roStr_172, [gsSubType])
                ExitProcess(1)
.end_189:

.end_188:

.end_187:

.end_186:

            ;printf(roStr_173, [currentToken])
	jmp .end_185
.else_185:
	push qword [gsSubType]
	pop rax
	mov qword [paType], rax
	push qword [gsSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_190:
	mov r15, [_]
	cmp r15, -1
	jne .end_190
;then_190:

                printf(roStr_174, [gsSubType])
                ExitProcess(1)
.end_190:
	push qword [paIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_175)
            WriteToFile(roStr_176, [gsValue], stringAtPointer)
            
;.if_191:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DOT]
	jne .else_191
;then_191:
	push qword [TOKEN_DOT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [paStructFieldIdentifier], rax
	add rsp, 0
	push qword [paStructFieldIdentifier]
	push qword [paType]

	call findUserTypeField
	mov [fgsIndex], rax
	add rsp, 16

                WriteToFile(roStr_177)
                WriteToFile(roStr_178, [utOffset])
	jmp .end_191
.else_191:

                printf(roStr_179)
.end_191:

.end_185:

	jmp .end_183
.else_183:

;.if_192:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_192
;then_192:

	call parseStructAccess
	mov [paIdentifier], rax
	add rsp, 0

	jmp .end_192
.else_192:

	call parseIdentifier
	mov [paIdentifier], rax
	add rsp, 0
	push qword [paIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_193:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_193
;then_193:
	push qword [paIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_193:

        ;printf(roStr_180)
.end_192:

.end_183:

    mov rax, [paIdentifier]
	mov rsp, rbp
	pop rbp
	ret
parseAssignable_end:

section .data
	pasIdentifier dq 0
section .text

section .data
	pasIsDereference dq 0
section .text

	jmp parseAssignmentStatement_end
parseAssignmentStatement:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [pasIsDereference], rax

    WriteToFile(roStr_181)
;.if_194:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .end_194
;then_194:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 1
	pop rax
	mov qword [pasIsDereference], rax

.end_194:

	call parseAssignable
	mov [pasIdentifier], rax
	add rsp, 0
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseLogicalOrExpression
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [pasIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_195:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_195
;then_195:
	push qword [pasIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_195:
	push qword [pasIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_196:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT8]
	jne .else_196
;then_196:

;.if_197:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_197
;then_197:

            WriteToFile(roStr_182, stringAtPointer)
            WriteToFile(roStr_183, stringAtPointer)
	jmp .end_197
.else_197:

;.if_198:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_198
;then_198:

            WriteToFile(roStr_184)
            WriteToFile(roStr_185, [gsValue])
	jmp .end_198
.else_198:

;.if_199:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_199
;then_199:

            printf(roStr_186)
.end_199:

.end_198:

.end_197:

	jmp .end_196
.else_196:

;.if_200:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT64]
	jne .else_200
;then_200:

;.if_201:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_201
;then_201:

            WriteToFile(roStr_187, stringAtPointer)
            WriteToFile(roStr_188, stringAtPointer)
	jmp .end_201
.else_201:

;.if_202:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_202
;then_202:

            WriteToFile(roStr_189)
            WriteToFile(roStr_190, [gsValue])
	jmp .end_202
.else_202:

;.if_203:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_203
;then_203:

            printf(roStr_191)
.end_203:

.end_202:

.end_201:

	jmp .end_200
.else_200:

;.if_204:
	mov r15, [gsType]
	cmp r15, [TYPE_POINTER]
	jne .else_204
;then_204:

;.if_205:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_205
;then_205:

;.if_206:
	mov r15, [pasIsDereference]
	cmp r15, 1
	jne .else_206
;then_206:

                WriteToFile(roStr_192, stringAtPointer, [gsSubType])
;.if_207:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_207
;then_207:

                    WriteToFile(roStr_193, stringAtPointer)
	jmp .end_207
.else_207:

;.if_208:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_208
;then_208:

                    WriteToFile(roStr_194, stringAtPointer)
	jmp .end_208
.else_208:

                    printf(roStr_195, [gsSubType])
                    ExitProcess(1)
.end_208:

.end_207:

	jmp .end_206
.else_206:

                WriteToFile(roStr_196, stringAtPointer)
                WriteToFile(roStr_197, stringAtPointer)
.end_206:

	jmp .end_205
.else_205:

;.if_209:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_209
;then_209:

            WriteToFile(roStr_198)
            WriteToFile(roStr_199, [gsValue])
	jmp .end_209
.else_209:

;.if_210:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_210
;then_210:

            printf(roStr_200)
.end_210:

.end_209:

.end_205:

	jmp .end_204
.else_204:

;.if_211:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_211
;then_211:

;.if_212:
	mov r15, [pasIsDereference]
	cmp r15, 1
	jne .else_212
;then_212:

            WriteToFile(roStr_201, stringAtPointer)
            WriteToFile(roStr_202, stringAtPointer)
	jmp .end_212
.else_212:

            WriteToFile(roStr_203, stringAtPointer)
            WriteToFile(roStr_204, stringAtPointer)
.end_212:

	jmp .end_211
.else_211:

;.if_213:
	mov r15, [gsType]
	cmp r15, [TYPE_ARRAY]
	jne .else_213
;then_213:

;.if_214:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_214
;then_214:

;.if_215:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_215
;then_215:

                WriteToFile(roStr_205)
                WriteToFile(roStr_206)
	jmp .end_215
.else_215:

;.if_216:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_216
;then_216:

                WriteToFile(roStr_207)
                WriteToFile(roStr_208)
	jmp .end_216
.else_216:

;.if_217:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_217
;then_217:

                WriteToFile(roStr_209)
                WriteToFile(roStr_210)
	jmp .end_217
.else_217:

;.if_218:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_218
;then_218:

                WriteToFile(roStr_211)
                WriteToFile(roStr_212)
	jmp .end_218
.else_218:
 
                printf(roStr_213, [gsType])
                ExitProcess(1)
.end_218:

.end_217:

.end_216:

.end_215:

	jmp .end_214
.else_214:

;.if_219:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_USER_DEFINED]
	jne .else_219
;then_219:

            WriteToFile(roStr_214)
            WriteToFile(roStr_215)
	jmp .end_219
.else_219:
 
            printf(roStr_216, [gsKind])
            ExitProcess(1)
.end_219:

.end_214:

	jmp .end_213
.else_213:

;.if_220:
	mov r15, [gsType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_220
;then_220:

        WriteToFile(roStr_217)
        WriteToFile(roStr_218)
	jmp .end_220
.else_220:

        printf(roStr_219, [gsType])
        ExitProcess(1)
.end_220:

.end_213:

.end_211:

.end_204:

.end_200:

.end_196:

    ;printf(roStr_220, stringAtPointer)
	mov rsp, rbp
	pop rbp
	ret
parseAssignmentStatement_end:

	jmp parseIfStatement_end
parseIfStatement:
	push rbp
	mov rbp, rsp
	push qword [globalBlockId]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalBlockId], rax
	push qword [TOKEN_IF]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_221)
    WriteToFile(roStr_222, [rbp + 16])
    
	call parseLogicalOrExpression
	push qword [TOKEN_THEN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_223)
    WriteToFile(roStr_224, [rbp + 16], [rbp + 16])
    
	call parseStatements

;.if_221:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ELSE]
	jne .end_221
;then_221:
	push 1
	pop rax
	mov qword [rbp + 24], rax
	push qword [TOKEN_ELSE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

        WriteToFile(roStr_225, [rbp + 16])
        WriteToFile(roStr_226, [rbp + 16], [rbp + 16])
        ;printf(roStr_227)
        
	call parseStatements

.end_221:
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [rbp + 24]
	pop rax
	mov qword [_], rax

;.if_222:
	mov r15, [_]
	cmp r15, 1
	jne .else_222
;then_222:

        WriteToFile(roStr_228, [rbp + 16])
	jmp .end_222
.else_222:

        WriteToFile(roStr_229, [rbp + 16])
.end_222:

    ;printf(roStr_230)
	mov rsp, rbp
	pop rbp
	ret
parseIfStatement_end:

section .data
	wsBlockId dq 0
section .text

	jmp parseWhileStatement_end
parseWhileStatement:
	push rbp
	mov rbp, rsp
	push qword [rbp + 16]
	pop rax
	mov qword [wsBlockId], rax
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [wsBlockId]
	mov [rdx], rax
	push qword [globalBlockId]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalBlockId], rax
	push qword [TOKEN_WHILE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_231)
    WriteToFile(roStr_232, [rbp + 16])
    
	call parseLogicalOrExpression
	push qword [TOKEN_DO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_233)
    WriteToFile(roStr_234, [rbp + 16], [rbp + 16])
    
	call parseStatements
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_235)
    WriteToFile(roStr_236, [rbp + 16])
    WriteToFile(roStr_237, [rbp + 16])
	mov rsp, rbp
	pop rbp
	ret
parseWhileStatement_end:

section .data
	pbsBlockId dq 0
section .text

section .data
	pbsIndex dq 0
section .text

section .data
	pbsCurrentToken dq 0
section .text

	jmp parseBreakStatement_end
parseBreakStatement:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_BREAK]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [i]
	push qword [tokenSize]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pbsIndex], rax

.while_223:
	mov r15, [pbsIndex]
	cmp r15, 0
	jl .end_223
;do_223:
	mov rax, [pbsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pbsCurrentToken], rax

;.if_224:
	mov r15, [pbsCurrentToken]
	cmp r15, [TOKEN_WHILE]
	jne .end_224
;then_224:
	push qword [pbsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [pbsIndex], rax
	mov rax, [pbsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pbsBlockId], rax

            WriteToFile(roStr_238)
            WriteToFile(roStr_239, [pbsBlockId])
    jmp .end_223

.end_224:
	push qword [pbsIndex]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pbsIndex], rax

    jmp .while_223
    ; end while_223
.end_223:

	mov rsp, rbp
	pop rbp
	ret
parseBreakStatement_end:

section .data
	pcsBlockId dq 0
section .text

section .data
	pcsIndex dq 0
section .text

section .data
	pcsCurrentToken dq 0
section .text

	jmp parseContinueStatement_end
parseContinueStatement:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_CONTINUE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [i]
	push qword [tokenSize]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pcsIndex], rax

.while_225:
	mov r15, [pcsIndex]
	cmp r15, 0
	jl .end_225
;do_225:
	mov rax, [pcsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pcsCurrentToken], rax

;.if_226:
	mov r15, [pcsCurrentToken]
	cmp r15, [TOKEN_WHILE]
	jne .end_226
;then_226:
	push qword [pcsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [pcsIndex], rax
	mov rax, [pcsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pcsBlockId], rax

            WriteToFile(roStr_240)
            WriteToFile(roStr_241, [pcsBlockId])
    jmp .end_225

.end_226:
	push qword [pcsIndex]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pcsIndex], rax

    jmp .while_225
    ; end while_225
.end_225:

	mov rsp, rbp
	pop rbp
	ret
parseContinueStatement_end:

section .data
	paProArgumentCount dq 0
section .text

	jmp parseArguments_end
parseArguments:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [paProArgumentCount], rax

	call parseType
	mov [gvType], rax
	add rsp, 0

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [globalProcedureId]
	push qword [ppdRbpOffset]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_PARAMETER]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [globalProcedureId]
	push qword [ppdRbpOffset]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_PARAMETER]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [ppdRbpOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax
	push qword [paProArgumentCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [paProArgumentCount], rax

.while_227:
	mov r15, [true]
	cmp r15, 1
	jne .end_227
;do_227:

;.if_228:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .else_228
;then_228:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseType
	mov [gvType], rax
	add rsp, 0

	call parseIdentifier
	mov [gvNamePointer], rax
	add rsp, 0
	push qword [globalProcedureId]
	push qword [ppdRbpOffset]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_PARAMETER]
	push qword [gvType]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [globalProcedureId]
	push qword [ppdRbpOffset]
	push qword [gvNamePointer]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [VARTYPE_PARAMETER]
	push qword [gvType]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [ppdRbpOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax
	push qword [paProArgumentCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [paProArgumentCount], rax

	jmp .end_228
.else_228:

    jmp .end_227

.end_228:

    jmp .while_227
    ; end while_227
.end_227:

    mov rax, [paProArgumentCount]
	mov rsp, rbp
	pop rbp
	ret
parseArguments_end:

section .data
	ppdIdentifier dq 0
section .text

section .data
	ppdHasReturnValue dq 0
section .text

section .data
	ppdReturnStatementCount dq 0
section .text

	jmp parseProcedureDeclaration_end
parseProcedureDeclaration:
	push rbp
	mov rbp, rsp

;.if_229:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 1
	jne .end_229
;then_229:
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
 
        printf(roStr_242, [errorAtLine], [errorAtColumn])
        printf(roStr_243)
        ExitProcess(1)
.end_229:
	push qword [TOKEN_PROC]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [ppdIdentifier], rax
	add rsp, 0
	push qword [ppdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_230:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_230
;then_230:
	push qword [ppdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_230:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [paProArgumentCount], rax

;.if_231:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_231
;then_231:
	push 16
	pop rax
	mov qword [ppdRbpOffset], rax

	call parseArguments

.end_231:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [ppdHasReturnValue], rax

;.if_232:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ARROW_RIGHT]
	jne .end_232
;then_232:
	push qword [TOKEN_ARROW_RIGHT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseType
	mov [gvType], rax
	add rsp, 0
	push 1
	pop rax
	mov qword [ppdHasReturnValue], rax

.end_232:
	push 1
	pop rax
	mov qword [globalBoolParsingProcedure], rax
	push 8
	pop rax
	mov qword [ppdRbpOffset], rax
	push 0
	pop rax
	mov qword [ppdLocalVariableCount], rax

;.if_233:
	mov r15, [currentToken]
	cmp r15, [TOKEN_VARS]
	jne .end_233
;then_233:
	push qword [TOKEN_VARS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.while_234:
	mov r15, [true]
	cmp r15, 1
	jne .end_234
;do_234:

	call parseVariableDeclaration

;.if_235:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CODE]
	jne .end_235
;then_235:

    jmp .end_234

.end_235:

    jmp .while_234
    ; end while_234
.end_234:

.end_233:
	push qword [ppdLocalVariableCount]
	push 8
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [ppdLocalVariableCount], rax
	push qword [ppdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    ;printf(roStr_244, stringAtPointer)
    WriteToFile(roStr_245, stringAtPointer)
    WriteToFile(roStr_246, stringAtPointer, stringAtPointer)
    WriteToFile(roStr_247)
    WriteToFile(roStr_248, [ppdLocalVariableCount])
    	push qword [TOKEN_CODE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [globalAllowVariableDeclaration], rax
	push 0
	pop rax
	mov qword [ppdReturnStatementCount], rax

	call parseStatements
	push 1
	pop rax
	mov qword [globalAllowVariableDeclaration], rax
	push 0
	pop rax
	mov qword [globalBoolParsingProcedure], rax
	push qword [globalProcedureId]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalProcedureId], rax
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_236:
	mov r15, [ppdReturnStatementCount]
	cmp r15, 0
	jne .end_236
;then_236:

;.if_237:
	mov r15, [ppdHasReturnValue]
	cmp r15, 1
	jne .end_237
;then_237:
	push qword [ppdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            printf(roStr_249, stringAtPointer)
            ExitProcess(1)
.end_237:

        WriteToFile(roStr_250)
.end_236:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [paProArgumentCount]
	push qword [ppdIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [gvType]
	push qword [TYPE_PROCEDURE]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [ppdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    ;printf(roStr_251, stringAtPointer, [paProArgumentCount])
    WriteToFile(roStr_252, stringAtPointer)
    WriteToFile(roStr_253, stringAtPointer)
	mov rsp, rbp
	pop rbp
	ret
parseProcedureDeclaration_end:

section .data
	prsIsEmptyResult dq 0
section .text

	jmp parseReturnStatement_end
parseReturnStatement:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_RETURN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [ppdReturnStatementCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdReturnStatementCount], rax
	push 1
	pop rax
	mov qword [prsIsEmptyResult], rax

;.if_238:
	mov r15, [currentToken]
	cmp r15, [TOKEN_SEMICOLON]
	je .end_238
;then_238:
	push 0
	pop rax
	mov qword [prsIsEmptyResult], rax

	call parseLogicalOrExpression

.end_238:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    WriteToFile(roStr_254)
    
;.if_239:
	mov r15, [prsIsEmptyResult]
	cmp r15, 0
	jne .else_239
;then_239:

        ; has result
        WriteToFile(roStr_255)
	jmp .end_239
.else_239:

        ; no result
        WriteToFile(roStr_256)
.end_239:

	mov rsp, rbp
	pop rbp
	ret
parseReturnStatement_end:

section .data
	ppcIdentifier dq 0
section .text

section .data
	ppcPrcArgumentCount dq 0
section .text

section .data
	ppcPrcCallArgumentCount dq 0
section .text

section .data
	ppcShadowSpace dq 0
section .text

section .data
	ppcIndex dq 0
section .text

section .data
	ppcCallCounter dq 0
section .text

	jmp parseProcedureCall_end
parseProcedureCall:
	push rbp
	mov rbp, rsp
	push qword [ppcCallCounter]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppcCallCounter], rax

	call parseIdentifier
	mov [ppcIdentifier], rax
	add rsp, 0
	push qword [ppcIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8
	push qword [ppcIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    ;printf(roStr_257, stringAtPointer)
    
;.if_240:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_240
;then_240:
	push qword [ppcIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_240:

;.if_241:
	mov r15, [gsType]
	cmp r15, [TYPE_PROCEDURE]
	jne .else_241
;then_241:
	push qword [gsValue]
	pop rax
	mov qword [ppcPrcArgumentCount], rax
	push qword [ppcPrcArgumentCount]
	push 8
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [ppcShadowSpace], rax
	push 8
	pop rax
	mov qword [ppdRbpOffset], rax
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_242:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_242
;then_242:

            WriteToFile(roStr_258)
            WriteToFile(roStr_259, [ppcShadowSpace])
.end_242:
	push 0
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax

.while_243:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_243
;do_243:

	call parseLogicalOrExpression

            WriteToFile(roStr_260, [ppdRbpOffset])
            	push qword [ppcPrcCallArgumentCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax
	push qword [ppdRbpOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax

;.if_244:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_244
;then_244:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_244:

    jmp .while_243
    ; end while_243
.end_243:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_245:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, [ppcPrcCallArgumentCount]
	je .end_245
;then_245:
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
 
            printf(roStr_261, [errorAtLine], [errorAtColumn])
            printf(roStr_262, [ppcPrcArgumentCount], [ppcPrcCallArgumentCount])
            ExitProcess(1)
.end_245:
	push qword [ppcIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_246:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, 0
	je .else_246
;then_246:

            WriteToFile(roStr_263, stringAtPointer, [ppcShadowSpace])
	jmp .end_246
.else_246:

            WriteToFile(roStr_264, stringAtPointer, [ppcShadowSpace])
.end_246:

        WriteToFile(roStr_265, stringAtPointer, [ppcPrcArgumentCount])
	jmp .end_241
.else_241:

;.if_247:
	mov r15, [gsType]
	cmp r15, [TYPE_EXTERNAL_PROCEDURE]
	jne .else_247
;then_247:
	push qword [gsValue]
	pop rax
	mov qword [ppcPrcArgumentCount], rax
	push qword [ppcPrcArgumentCount]
	push 8
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [ppcShadowSpace], rax

;.if_248:
	mov r15, [ppcShadowSpace]
	cmp r15, 32
	jge .end_248
;then_248:
	push 32
	pop rax
	mov qword [ppcShadowSpace], rax

.end_248:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

        WriteToFile(roStr_266)
        WriteToFile(roStr_267, [ppcShadowSpace])
        	push 0
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax
	push 8
	pop rax
	mov qword [ppdRbpOffset], rax

.while_249:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_249
;do_249:

	call parseLogicalOrExpression

            ;WriteToFile(roStr_268, [ppdRbpOffset])
            	push qword [ppcPrcCallArgumentCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax
	push qword [ppdRbpOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax

;.if_250:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_250
;then_250:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_250:

    jmp .while_249
    ; end while_249
.end_249:
	push qword [ppcPrcCallArgumentCount]
	pop rax
	mov qword [ppcIndex], rax
	push qword [ppdRbpOffset]
	push 8
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax

.while_251:
	mov r15, [ppcIndex]
	cmp r15, 0
	jl .end_251
;do_251:

;.if_252:
	mov r15, [ppcIndex]
	cmp r15, 4
	jle .else_252
;then_252:

                WriteToFile(roStr_269, [ppdRbpOffset])
	jmp .end_252
.else_252:

;.if_253:
	mov r15, [ppcIndex]
	cmp r15, 4
	jne .else_253
;then_253:

                WriteToFile(roStr_270, [ppdRbpOffset])
	jmp .end_253
.else_253:

;.if_254:
	mov r15, [ppcIndex]
	cmp r15, 3
	jne .else_254
;then_254:

                WriteToFile(roStr_271, [ppdRbpOffset])
	jmp .end_254
.else_254:

;.if_255:
	mov r15, [ppcIndex]
	cmp r15, 2
	jne .else_255
;then_255:

                WriteToFile(roStr_272, [ppdRbpOffset])
	jmp .end_255
.else_255:

;.if_256:
	mov r15, [ppcIndex]
	cmp r15, 1
	jne .end_256
;then_256:

                WriteToFile(roStr_273, [ppdRbpOffset])
.end_256:

.end_255:

.end_254:

.end_253:

.end_252:
	push qword [ppcIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [ppcIndex], rax
	push qword [ppdRbpOffset]
	push 8
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [ppdRbpOffset], rax

    jmp .while_251
    ; end while_251
.end_251:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_257:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, [ppcPrcCallArgumentCount]
	je .end_257
;then_257:
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
 
            printf(roStr_274, [errorAtLine], [errorAtColumn])
            printf(roStr_275, [ppcPrcArgumentCount], [ppcPrcCallArgumentCount])
            ExitProcess(1)
.end_257:
	push qword [ppcIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_276, stringAtPointer, [ppcCallCounter])
        WriteToFile(roStr_277, stringAtPointer, [ppcShadowSpace])
        WriteToFile(roStr_278, stringAtPointer, [ppcPrcArgumentCount])
	jmp .end_247
.else_247:

        printf(roStr_279)
        ExitProcess(1)
.end_247:

.end_241:

	mov rsp, rbp
	pop rbp
	ret
parseProcedureCall_end:

	jmp parseProcedureCallStatement_end
parseProcedureCallStatement:
	push rbp
	mov rbp, rsp

	call parseProcedureCall
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	mov rsp, rbp
	pop rbp
	ret
parseProcedureCallStatement_end:

section .data
	psbType dq 0
section .text

section .data
	psbIdentifier dq 0
section .text

section .data
	psbSizeOfStruct dq 0
section .text

section .data
	psbCurrentOffset dq 0
section .text

	jmp parseStructBody_end
parseStructBody:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [psbSizeOfStruct], rax
	push 0
	pop rax
	mov qword [psbCurrentOffset], rax

.while_258:
	mov r15, [true]
	cmp r15, 1
	jne .end_258
;do_258:

;.if_259:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_259
;then_259:
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtLine], rax
	push qword [i]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	push qword [_]
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [errorAtColumn], rax
 
            printf(roStr_280, [errorAtLine], [errorAtColumn])
            printf(roStr_281)
            ExitProcess(1)
	jmp .end_259
.else_259:

;.if_260:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_260
;then_260:

	call parseType
	mov [psbType], rax
	add rsp, 0
	push qword [psbSizeOfStruct]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [psbSizeOfStruct], rax

	jmp .end_260
.else_260:

;.if_261:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_261
;then_261:

	call parseType
	mov [psbType], rax
	add rsp, 0
	push qword [psbSizeOfStruct]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [psbSizeOfStruct], rax

	jmp .end_261
.else_261:

    jmp .end_258

.end_261:

.end_260:

.end_259:

	call parseIdentifier
	mov [psbIdentifier], rax
	add rsp, 0
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [psbCurrentOffset]
	push qword [psbIdentifier]
	push qword [psbType]
	push qword [globalUserTypeId]

	call addUserTypeField
	mov [_], rax
	add rsp, 32
	push qword [psbIdentifier]

	call readString
	mov [_], rax
	add rsp, 8
	push qword [psbCurrentOffset]
	push 8
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [psbCurrentOffset], rax

        ;printf(roStr_282, stringAtPointer, [psbType])
    jmp .while_258
    ; end while_258
.end_258:

	mov rsp, rbp
	pop rbp
	ret
parseStructBody_end:

section .data
	psdIdentifier dq 0
section .text

	jmp parseStructDefinition_end
parseStructDefinition:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_STRUCT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [psdIdentifier], rax
	add rsp, 0
	push qword [psdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_262:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_262
;then_262:
	push qword [psdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_262:

	call parseStructBody
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [psbSizeOfStruct]
	push qword [psdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [globalUserTypeId]
	push qword [TYPE_USER_DEFINED]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [psdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    ;printf(roStr_283, stringAtPointer, [psbSizeOfStruct])
    	push qword [globalUserTypeId]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [globalUserTypeId], rax

	mov rsp, rbp
	pop rbp
	ret
parseStructDefinition_end:

section .data
	putvdTypeIdentifier dq 0
section .text

section .data
	putvdIdentifier dq 0
section .text

	jmp parseUserTypeVariableDeclaration_end
parseUserTypeVariableDeclaration:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_IDENTIFIER]
	pop rax
	mov qword [expectedToken], rax
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [putvdTypeIdentifier], rax

	call consumeToken
	push qword [putvdTypeIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_263:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_263
;then_263:
	push qword [putvdTypeIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_263:
	push qword [gsSubType]
	pop rax
	mov qword [putvdTypeIdentifier], rax

;.if_264:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_264
;then_264:
	push qword [TOKEN_LEFT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseNumber
	mov [gvValue], rax
	add rsp, 0
	push qword [TOKEN_RIGHT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [putvdIdentifier], rax
	add rsp, 0
	push qword [putvdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_265:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_265
;then_265:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_265:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [putvdIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_ARRAY]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [putvdIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_ARRAY]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [putvdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        ;printf(roStr_284, stringAtPointer)
	jmp .end_264
.else_264:

;.if_266:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_266
;then_266:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [putvdIdentifier], rax
	add rsp, 0
	push qword [putvdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_267:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_267
;then_267:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_267:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [putvdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_STRUCT_POINTER]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [putvdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_STRUCT_POINTER]

	call addSymbol
	mov [_], rax
	add rsp, 48

	jmp .end_266
.else_266:

	call parseIdentifier
	mov [putvdIdentifier], rax
	add rsp, 0
	push qword [putvdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_268:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_268
;then_268:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_268:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [putvdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_USER_DEFINED]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [putvdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [putvdTypeIdentifier]
	push qword [TYPE_USER_DEFINED]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [putvdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        ;printf(roStr_285, stringAtPointer)
.end_266:

.end_264:

	mov rsp, rbp
	pop rbp
	ret
parseUserTypeVariableDeclaration_end:

section .data
	pedIdentifier dq 0
section .text

	jmp parseExternDeclaration_end
parseExternDeclaration:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_EXTERN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_PROC]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [pedIdentifier], rax
	add rsp, 0
	push qword [pedIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_269:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_269
;then_269:
	push qword [pedIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_269:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [paProArgumentCount], rax

;.if_270:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_270
;then_270:
	push 16
	pop rax
	mov qword [ppdRbpOffset], rax

	call parseArguments

.end_270:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_271:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ARROW_RIGHT]
	jne .end_271
;then_271:
	push qword [TOKEN_ARROW_RIGHT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseType
	mov [gvType], rax
	add rsp, 0

.end_271:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [paProArgumentCount]
	push qword [pedIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [gvType]
	push qword [TYPE_EXTERNAL_PROCEDURE]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [pedIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    WriteToFile(roStr_286, stringAtPointer)
	mov rsp, rbp
	pop rbp
	ret
parseExternDeclaration_end:

section .data
	pesNumber dq 0
section .text

	jmp parseExitStatement_end
parseExitStatement:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_EXIT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseNumber
	mov [pesNumber], rax
	add rsp, 0
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    WriteToFile(roStr_287)
    WriteToFile(roStr_288, [pesNumber])
    WriteToFile(roStr_289)
	mov rsp, rbp
	pop rbp
	ret
parseExitStatement_end:

section .data
	pppdIdentifier dq 0
section .text

section .data
	pppdValue dq 0
section .text

	jmp parsePreprocessorDirective_end
parsePreprocessorDirective:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_AT_SIGN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_DEFINE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [pppdIdentifier], rax
	add rsp, 0

	call parseNumber
	mov [pppdValue], rax
	add rsp, 0
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [pppdValue]
	push qword [pppdIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword 0
	push qword [TYPE_DEFINE]

	call addSymbol
	mov [_], rax
	add rsp, 48

	mov rsp, rbp
	pop rbp
	ret
parsePreprocessorDirective_end:

section .data
	psIdentifier dq 0
section .text

	jmp parseStatement_end
parseStatement:
	push rbp
	mov rbp, rsp

;.if_272:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_272
;then_272:

	call parseVariableDeclaration

	jmp .end_272
.else_272:

;.if_273:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_273
;then_273:

	call parseVariableDeclaration

	jmp .end_273
.else_273:

;.if_274:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_274
;then_274:

	call parseVariableDeclaration

	jmp .end_274
.else_274:

;.if_275:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_275
;then_275:
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [psIdentifier], rax
	push qword [psIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8
	push qword [psIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_276:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .else_276
;then_276:

;.if_277:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_277
;then_277:

	call parseAssignmentStatement

	jmp .end_277
.else_277:

;.if_278:
	mov r15, [gsType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_278
;then_278:

	call parseUserTypeVariableDeclaration

	jmp .end_278
.else_278:

;.if_279:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_279
;then_279:

	call parseProcedureCallStatement

	jmp .end_279
.else_279:

	call parseAssignmentStatement

.end_279:

.end_278:

.end_277:

	jmp .end_276
.else_276:
	push qword [psIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_276:

	jmp .end_275
.else_275:

;.if_280:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IF]
	jne .else_280
;then_280:
	push qword 0
	push qword 0
	push qword [globalBlockId]

	call parseIfStatement
	mov [_], rax
	add rsp, 24

	jmp .end_280
.else_280:

;.if_281:
	mov r15, [currentToken]
	cmp r15, [TOKEN_WHILE]
	jne .else_281
;then_281:
	push qword [globalBlockId]

	call parseWhileStatement
	mov [_], rax
	add rsp, 8

	jmp .end_281
.else_281:

;.if_282:
	mov r15, [currentToken]
	cmp r15, [TOKEN_BREAK]
	jne .else_282
;then_282:

	call parseBreakStatement

	jmp .end_282
.else_282:

;.if_283:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONTINUE]
	jne .else_283
;then_283:

	call parseContinueStatement

	jmp .end_283
.else_283:

;.if_284:
	mov r15, [currentToken]
	cmp r15, [TOKEN_PROC]
	jne .else_284
;then_284:

	call parseProcedureDeclaration

	jmp .end_284
.else_284:

;.if_285:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RETURN]
	jne .else_285
;then_285:

	call parseReturnStatement

	jmp .end_285
.else_285:

;.if_286:
	mov r15, [currentToken]
	cmp r15, [TOKEN_STRUCT]
	jne .else_286
;then_286:

	call parseStructDefinition

	jmp .end_286
.else_286:

;.if_287:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EXTERN]
	jne .else_287
;then_287:

	call parseExternDeclaration

	jmp .end_287
.else_287:

;.if_288:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EXIT]
	jne .else_288
;then_288:

	call parseExitStatement

	jmp .end_288
.else_288:

;.if_289:
	mov r15, [currentToken]
	cmp r15, [TOKEN_AT_SIGN]
	jne .else_289
;then_289:

	call parsePreprocessorDirective

	jmp .end_289
.else_289:

;.if_290:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_290
;then_290:

	call parseAssignmentStatement

	jmp .end_290
.else_290:

	call unexpectedToken

.end_290:

.end_289:

.end_288:

.end_287:

.end_286:

.end_285:

.end_284:

.end_283:

.end_282:

.end_281:

.end_280:

.end_275:

.end_274:

.end_273:

.end_272:

	mov rsp, rbp
	pop rbp
	ret
parseStatement_end:

	jmp parseStatements_end
parseStatements:
	push rbp
	mov rbp, rsp

.while_291:
	mov r15, [true]
	cmp r15, 1
	jne .end_291
;do_291:

;.if_292:
	mov r15, [currentToken]
	cmp r15, [TOKEN_END]
	jne .else_292
;then_292:

    jmp .end_291

	jmp .end_292
.else_292:

;.if_293:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ELSE]
	jne .else_293
;then_293:

    jmp .end_291

	jmp .end_293
.else_293:

	call parseStatement

.end_293:

.end_292:

    jmp .while_291
    ; end while_291
.end_291:

	mov rsp, rbp
	pop rbp
	ret
parseStatements_end:
	push 0
	pop rax
	mov qword [i], rax

.while_294:
	mov r15, [i]
	cmp r15, [tokenCount]
	jge .end_294
;do_294:
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax

	call parseStatement

    jmp .while_294
    ; end while_294
.end_294:
	push 0
	pop rax
	mov qword [i], rax

WriteToFile(roStr_290)
WriteToFile(roStr_291)
WriteToFile(roStr_292)
WriteToFile(roStr_293)
section .bss
	encodedString resb 512
section .text

section .data
	esIndex dq 0
section .text

section .data
	esDestIndex dq 0
section .text

section .data
	esChar db 0
section .text

	jmp encodeString_end
encodeString:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [esIndex], rax
	push 0
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 34
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, stringAtPointer
	add rdx, [esIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [esChar], al

.while_295:
	movzx r15, byte [esChar]
	cmp r15, 0
	jle .end_295
;do_295:

;.if_296:
	movzx r15, byte [esChar]
	cmp r15, 32
	jl .else_296
;then_296:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	movzx rax, byte [esChar]
	mov byte [rdx], al
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

	jmp .end_296
.else_296:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 34
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 44
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

;.if_297:
	movzx r15, byte [esChar]
	cmp r15, 13
	jne .else_297
;then_297:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 49
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 51
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

	jmp .end_297
.else_297:

;.if_298:
	movzx r15, byte [esChar]
	cmp r15, 10
	jne .else_298
;then_298:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 49
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 48
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

	jmp .end_298
.else_298:

;.if_299:
	movzx r15, byte [esChar]
	cmp r15, 9
	jne .end_299
;then_299:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 57
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

.end_299:

.end_298:

.end_297:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 44
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 34
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax

.end_296:
	push qword [esIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esIndex], rax
	mov rdx, stringAtPointer
	add rdx, [esIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [esChar], al

    jmp .while_295
    ; end while_295
.end_295:
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 34
	push qword [esDestIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [esDestIndex], rax
	mov rdx, encodedString
	add rdx, [esDestIndex]
	mov byte [rdx], 0

	mov rsp, rbp
	pop rbp
	ret
encodeString_end:

section .data
	wsdIdentifier dq 0
section .text

.while_300:
	mov r15, [i]
	cmp r15, [globalVariableCount]
	jge .end_300
;do_300:
	push qword [gvTypeOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvType], rax
	push qword [gvSubTypeOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvSubType], rax
	push qword [gvKindOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvKind], rax
	push qword [gvNameOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvNamePointer], rax
	push qword [gvValueOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvValue], rax
	push qword [gvScopeOffset]
	push qword [i]
	push qword [globalVariableSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [_], rax
	mov rax, [_]
	mov rdx, 8
	mul rdx
	mov rdx, globalVariables
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [gvScope], rax

;.if_301:
	mov r15, [gvScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_301
;then_301:
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax

    jmp .while_300

.end_301:
	push qword [gvNamePointer]

	call readString
	mov [_], rax
	add rsp, 8

;.if_302:
	mov r15, [gvType]
	cmp r15, [TYPE_UINT8]
	jne .else_302
;then_302:

        WriteToFile(roStr_294, stringAtPointer, [gvValue])
	jmp .end_302
.else_302:

;.if_303:
	mov r15, [gvType]
	cmp r15, [TYPE_UINT64]
	jne .else_303
;then_303:

        WriteToFile(roStr_295, stringAtPointer, [gvValue])
	jmp .end_303
.else_303:

;.if_304:
	mov r15, [gvType]
	cmp r15, [TYPE_POINTER]
	jne .else_304
;then_304:

        WriteToFile(roStr_296, stringAtPointer, [gvValue])
	jmp .end_304
.else_304:

;.if_305:
	mov r15, [gvType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_305
;then_305:

        WriteToFile(roStr_297, stringAtPointer)
	jmp .end_305
.else_305:

;.if_306:
	mov r15, [gvType]
	cmp r15, [TYPE_ARRAY]
	jne .else_306
;then_306:

;.if_307:
	mov r15, [gvKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_307
;then_307:

;.if_308:
	mov r15, [gvSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_308
;then_308:

                WriteToFile(roStr_298, stringAtPointer, [gvValue])
	jmp .end_308
.else_308:

;.if_309:
	mov r15, [gvSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_309
;then_309:

                WriteToFile(roStr_299, stringAtPointer, [gvValue])
	jmp .end_309
.else_309:

;.if_310:
	mov r15, [gvSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_310
;then_310:

                WriteToFile(roStr_300, stringAtPointer, [gvValue])
	jmp .end_310
.else_310:

;.if_311:
	mov r15, [gvSubType]
	cmp r15, [TYPE_STRING]
	jne .else_311
;then_311:

                WriteToFile(roStr_301, stringAtPointer)
                	push qword [gvValue]

	call readString
	mov [_], rax
	add rsp, 8

	call encodeString

                WriteToFile(roStr_302, encodedString)
	jmp .end_311
.else_311:

                printf(roStr_303, [gvType])
                ExitProcess(1)
.end_311:

.end_310:

.end_309:

.end_308:

	jmp .end_307
.else_307:
	push qword [gvNamePointer]
	pop rax
	mov qword [wsdIdentifier], rax
	push qword [gvSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_312:
	mov r15, [_]
	cmp r15, -1
	jne .end_312
;then_312:

                printf(roStr_304, [gvSubType])
                ExitProcess(1)
.end_312:
	push qword [gvValue]
	push qword [gsValue]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [gvValue], rax
	push qword [wsdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_305, stringAtPointer, [gvValue])
.end_307:

	jmp .end_306
.else_306:

;.if_313:
	mov r15, [gvType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_313
;then_313:
	push qword [gvNamePointer]
	pop rax
	mov qword [wsdIdentifier], rax
	push qword [gvSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_314:
	mov r15, [_]
	cmp r15, -1
	jne .end_314
;then_314:

            printf(roStr_306, [gvSubType])
            ExitProcess(1)
.end_314:
	push qword [wsdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_307, stringAtPointer, [gsValue])
	jmp .end_313
.else_313:

        printf(roStr_308, [gvType])
        ExitProcess(1)
.end_313:

.end_306:

.end_305:

.end_304:

.end_303:

.end_302:
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax

    jmp .while_300
    ; end while_300
.end_300:

	call CloseOutputFile

section .bss
    lpStartupInfo: resb 104
    lpProcessInformation: resb 24
    lpExitCode: resq 1

section .text    
    extern CreateProcessA
    extern WaitForSingleObject
    extern GetExitCodeProcess

    sprintf(buffer1, roStr_309, cStrOutputFile, cStrObjectFile)
    printf(roStr_310, buffer1)

    memset(lpProcessInformation, 0, 24)
    memset(lpStartupInfo, 0, 104)

    mov rax, STARTUPINFOA.size
    mov [lpStartupInfo], rax

    mov rax, lpProcessInformation
    mov rbx, lpStartupInfo
    mov [rbx], dword 104
    and rsp, 0xfffffffffffffff0
    push     rax                        ; lpProcessInformation   
    push     rbx                        ; lpStartupInfo  
    push     NULL                       ; lpCurrentDirectory
    push     NULL                       ; lpEnvironment
    push     0x00000000                 ; dwCreationFlags
    push     0x00000001                 ; bInheritHandles
    sub rsp, 0x20
    mov r9,  NULL                       ; lpThreadAttributes
    mov r8,  NULL                       ; lpProcessAttributes
    mov rdx, buffer1                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8 
;.if_315:
    cmp rax, 0
	jne .end_315
;then_315:

        printf(roStr_311)
        ExitProcess(1)
.end_315:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_312, [lpExitCode])
    mov rax, [lpExitCode]
    
;.if_316:
    cmp rax, 0
	je .end_316
;then_316:

        printf(roStr_313)
        ExitProcess(1)
.end_316:


    sprintf(buffer1, roStr_314, cStrObjectFile, cStrLinkerFile)
    printf(roStr_315, buffer1)
    
    memset(lpProcessInformation, 0, 24)
    memset(lpStartupInfo, 0, 104)

    mov rax, STARTUPINFOA.size
    mov [lpStartupInfo], rax

    mov rax, lpProcessInformation
    mov rbx, lpStartupInfo
    mov [rbx], dword 104
    and rsp, 0xfffffffffffffff0
    push     rax                        ; lpProcessInformation   
    push     rbx                        ; lpStartupInfo  
    push     NULL                       ; lpCurrentDirectory
    push     NULL                       ; lpEnvironment
    push     0x00000000                 ; dwCreationFlags
    push     0x00000001                 ; bInheritHandles
    sub rsp, 0x20
    mov r9,  NULL                       ; lpThreadAttributes
    mov r8,  NULL                       ; lpProcessAttributes
    mov rdx, buffer1                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8
;.if_317:
    cmp rax, 0
	jne .end_317
;then_317:

        printf(roStr_316)
        ExitProcess(1)
.end_317:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
;.if_318:
    cmp rax, 0
	je .end_318
;then_318:

        printf(roStr_317)
        ExitProcess(1)
.end_318:


    printf(roStr_318, cStrLinkerFile)

    ExitProcess(0)
section .rodata
    roStr_318 db "[\#27[92mINFO\#27[0m] Generated %s\r\n", 0
    roStr_317 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_316 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_315 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_314 db "ld -e _start %s -o %s -lkernel32 -Llib", 0
    roStr_313 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_312 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_311 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_310 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_309 db "nasm.exe -f win64 %s -o %s -w+all -w+error", 0
    roStr_308 db "Error: unknown type %d in 'writeVars'", 0
    roStr_307 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_306 db "Error: unknown user type %d\n", 0
    roStr_305 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_304 db "Error: unknown user type %d\n", 0
    roStr_303 db "Error: unknown array type %d\n", 0
    roStr_302 db " db %s,0\n", 0
    roStr_301 db "section .data\r\n\t%s", 0
    roStr_300 db "section .bss\r\n\t%s resq %d\n", 0
    roStr_299 db "section .bss\r\n\t%s resq %d\n", 0
    roStr_298 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_297 db "section .bss\r\n\t%s resq 1\n", 0
    roStr_296 db "section .data\r\n\t%s dq %d\n", 0
    roStr_295 db "section .data\r\n\t%s dq %d\n", 0
    roStr_294 db "section .data\r\n\t%s db %d\n", 0
    roStr_293 db ";==== global variables ====\n", 0
    roStr_292 db "\tcall ExitProcess\n\n", 0
    roStr_291 db "\tmov rcx, 0\n", 0
    roStr_290 db "; -- exit process -- \n", 0
    roStr_289 db "\tcall ExitProcess\n\n", 0
    roStr_288 db "\tmov rcx, %d\n", 0
    roStr_287 db "; -- exit process -- \n", 0
    roStr_286 db "section .text\n\textern %s\n", 0
    roStr_285 db "[Trace] Variable definition for user type: %s\n", 0
    roStr_284 db "[Trace] Variable definition for user type array: %s\n", 0
    roStr_283 db "[Trace] Struct definition: %s with %d bytes\n", 0
    roStr_282 db "[Trace] Struct field: %s of type %d\n", 0
    roStr_281 db "valid struct member types are 'uint64' and 'pointer'\n", 0
    roStr_280 db "parser.strata:%d:%d: ", 0
    roStr_279 db "NOT A PROCEDURE\n", 0
    roStr_278 db "; external procedure call: %s with %d arguments\n\n", 0
    roStr_277 db "\tmov rsp, r15\n\tpop r15\n\tcall %s\n\tadd rsp, %d\n", 0
    roStr_276 db "external_%s_%d:\n", 0
    roStr_275 db "external procedure requires %d arguments, but %d arguments are provided\n", 0
    roStr_274 db "parser.strata:%d:%d: ", 0
    roStr_273 db "\tpop rcx\n", 0
    roStr_272 db "\tpop rdx\n", 0
    roStr_271 db "\tpop r8\n", 0
    roStr_270 db "\tpop r9\n", 0
    roStr_269 db "\tpop qword [r15 + %d]\n", 0
    roStr_268 db "\tpop qword [r15 + %d]\n", 0
    roStr_267 db "\tsub rsp, %d\n\tpush r15\n\tmov r15, rsp\n", 0
    roStr_266 db "; -- external procedure call --\n", 0
    roStr_265 db "; procedure call: %s with %d arguments\n\n", 0
    roStr_264 db "\tcall %s\n\tadd rsp, %d\n", 0
    roStr_263 db "\tmov rsp, rbp\n\tpop rbp\n\tcall %s\n\tadd rsp, %d\n", 0
    roStr_262 db "procedure requires %d arguments, but %d arguments are provided\n", 0
    roStr_261 db "parser.strata:%d:%d: ", 0
    roStr_260 db "\tpop qword [rbp + %d]\n", 0
    roStr_259 db "\tsub rsp, %d\n\tpush rbp\n\tmov rbp, rsp\n", 0
    roStr_258 db "; -- procedure call --\n", 0
    roStr_257 db "[Trace] Procedure call: %s\n", 0
    roStr_256 db "\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_255 db "\tpop rax\n\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_254 db "; -- return --\n", 0
    roStr_253 db ";==== end proc %s ====\n\n", 0
    roStr_252 db "%s_end:\n", 0
    roStr_251 db "[Trace] Procedure declaration: %s with %d parameters\n", 0
    roStr_250 db "\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_249 db "Error: procedure %s has no return statement\n", 0
    roStr_248 db "\tsub rsp, %d\n\n", 0
    roStr_247 db "\tpush rbp\n\tmov rbp, rsp\n", 0
    roStr_246 db "\tjmp %s_end\n%s:\n", 0
    roStr_245 db ";==== proc %s ====\n", 0
    roStr_244 db "[Trace] Procedure declaration: %s\n", 0
    roStr_243 db "nested procedure declaration is not allowed\n", 0
    roStr_242 db "parser.strata:%d:%d: ", 0
    roStr_241 db "\tjmp while_%d\n", 0
    roStr_240 db "; -- continue --\n", 0
    roStr_239 db "\tjmp end_while_%d\n", 0
    roStr_238 db "; -- break --\n", 0
    roStr_237 db "end_while_%d:\n", 0
    roStr_236 db "\tjmp while_%d\n", 0
    roStr_235 db "[Trace] While statement: END\n", 0
    roStr_234 db "\tpop rax\n\tcmp rax, 0\n\tjz end_while_%d\n; do statement %d\n", 0
    roStr_233 db "[Trace] While statement: DO\n", 0
    roStr_232 db "while_%d:\n", 0
    roStr_231 db "[Trace] While statement: WHILE\n", 0
    roStr_230 db "[Trace] If statement: END\n", 0
    roStr_229 db "condition_false_%d:\n", 0
    roStr_228 db "end_if_%d:\n", 0
    roStr_227 db "[Trace] If statement: ELSE\n", 0
    roStr_226 db "condition_false_%d:\n; else statement block id %d\n", 0
    roStr_225 db "\tjmp end_if_%d\n", 0
    roStr_224 db "\tpop rax\n\tcmp rax, 0\n\tjz condition_false_%d\n; then statement block id %d\n", 0
    roStr_223 db "[Trace] If statement: THEN\n", 0
    roStr_222 db "; if statement block id: %d\n", 0
    roStr_221 db "[Trace] If statement: IF\n", 0
    roStr_220 db "[Trace] Assignment statement for: '%s'\n", 0
    roStr_219 db "[Error] Error: unknown type %d in 'parseAssignmentStatement'\n", 0
    roStr_218 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_217 db "; assigning value to a struct field\n", 0
    roStr_216 db "[Error] Error: unknown array kind %d\n", 0
    roStr_215 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_214 db "; assigning value to a struct array element\n", 0
    roStr_213 db "[Error] Error: unknown array type %d\n", 0
    roStr_212 db "\tpop rbx\n\tpop rax\n\tmov byte [rax], bl\n\n", 0
    roStr_211 db "; -- (string) set value --\n", 0
    roStr_210 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_209 db "; -- (pointer[]) set value --\n", 0
    roStr_208 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_207 db "; -- (uint64[]) set value --\n", 0
    roStr_206 db "\tpop rbx\n\tpop rax\n\tmov byte [rax], bl\n\n", 0
    roStr_205 db "; -- (uint8[]) set value --\n", 0
    roStr_204 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_203 db "; -- (struct pointer) set value of '%s' --\n", 0
    roStr_202 db "\tpop rax\n\tpop rbx\n\tmov [rbx], rax\n\n", 0
    roStr_201 db "; -- (struct pointer) set value of '%s' --\n", 0
    roStr_200 db "Cannot assign to a parameter\n", 0
    roStr_199 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_198 db "; assigning value to a local pointer\n", 0
    roStr_197 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_196 db "; -- (pointer) set value of '%s' --\n", 0
    roStr_195 db "[Error] Error: unknown pointer type %d\n", 0
    roStr_194 db "\tmov rbx, [%s]\n\tpop rax\n\tmov [rbx], rax\n\n", 0
    roStr_193 db "\tmov rbx, [%s]\n\tpop rax\n\tmov [rbx], al\n\n", 0
    roStr_192 db "; -- (pointer deref) set value of '%s' subtype %d --\n", 0
    roStr_191 db "Cannot assign to a parameter\n", 0
    roStr_190 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_189 db "; assigning value to a local uint64\n", 0
    roStr_188 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_187 db "; -- (uint64) set value of '%s' --\n", 0
    roStr_186 db "Cannot assign to a parameter\n", 0
    roStr_185 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_184 db "; assigning value to a local uint8\n", 0
    roStr_183 db "\tpop rax\n\tmov byte [%s], al\n\n", 0
    roStr_182 db "; -- (uint8) set value of '%s' --\n", 0
    roStr_181 db "; -- assignment statement --\n", 0
    roStr_180 db "[Trace] Assignable: variable\n", 0
    roStr_179 db "\tpush rax\n", 0
    roStr_178 db "\tadd rax, %d\n\tpush rax\n", 0
    roStr_177 db "; -- accessing struct field --\n", 0
    roStr_176 db "\tpop rax\n\tmov rdx, %d\n\tmul rdx\n\tmov rbx, %s\n\tadd rax, rbx\n", 0
    roStr_175 db "; -- indexing n-th element of struct array --\n", 0
    roStr_174 db "Error: unknown user type %d\n", 0
    roStr_173 db "[Trace] Assignable: array, ct %d\n", 0
    roStr_172 db "[Error] Error: unknown array type %d\n", 0
    roStr_171 db "\tpop rax\n\tmov rbx, %s\n\tshl rax, 3\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_170 db "; -- indexing n-th element of array --\n", 0
    roStr_169 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_168 db "; -- indexing n-th element of array --\n", 0
    roStr_167 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_166 db "; -- indexing n-th element of array --\n", 0
    roStr_165 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_164 db "; -- indexing n-th element of array --\n", 0
    roStr_163 db "\tadd rax, %d\n\tpush rax\n", 0
    roStr_162 db "\tmov rax, %s\n", 0
    roStr_161 db "; -- accessing struct field --\n", 0
    roStr_160 db "\tmov rax, [%s]\n", 0
    roStr_159 db "; -- accessing struct pointer field --\n", 0
    roStr_158 db "\tpop rbx\n\tpop rax\n\tor rax, rbx\n\tpush rax\n", 0
    roStr_157 db "; -- || --\n", 0
    roStr_156 db "; -- eval expression --\n", 0
    roStr_155 db "\tpop rbx\n\tpop rax\n\tand rax, rbx\n\tpush rax\n", 0
    roStr_154 db "; -- && --\n", 0
    roStr_153 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_152 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjne .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_151 db "; -- != --\n", 0
    roStr_150 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_149 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tje .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_148 db "; -- == --\n", 0
    roStr_147 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_146 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjge .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_145 db "; -- >= --\n", 0
    roStr_144 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_143 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjg .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_142 db "; -- > --\n", 0
    roStr_141 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_140 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjle .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_139 db "; -- <= --\n", 0
    roStr_138 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_137 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjl .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_136 db "; -- < --\n", 0
    roStr_135 db "\tpop rbx\n\tpop rax\n\tsub rax, rbx\n\tpush rax\n", 0
    roStr_134 db "; -- - --\n", 0
    roStr_133 db "\tpop rbx\n\tpop rax\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_132 db "; -- + --\n", 0
    roStr_131 db "\tpop rbx\n\tpop rax\n\tdiv rbx\n\tpush rdx\n", 0
    roStr_130 db "; -- %% --\n", 0
    roStr_129 db "\tpop rbx\n\tpop rax\n\tdiv rbx\n\tpush rax\n", 0
    roStr_128 db "; -- / --\n", 0
    roStr_127 db "\tpop rbx\n\tpop rax\n\tmul rbx\n\tpush rax\n", 0
    roStr_126 db "; -- * --\n", 0
    roStr_125 db "[Error] Error: unknown type %d in 'parseFactor*'\n", 0
    roStr_124 db "\tmov rax, [%s]\n\tpush qword [rax]\n", 0
    roStr_123 db "\tmov rbx, [%s]\n\tmovzx rax, byte [rbx]\n\tpush qword rax\n", 0
    roStr_122 db "\tadd rax, %d\n\tmov rbx, [rax]\n\tpush qword [rbx]\n", 0
    roStr_121 db "\tmov rax, [%s]\n", 0
    roStr_120 db "; -- accessing struct field value --\n", 0
    roStr_119 db "[Trace] Factor: dereference\n", 0
    roStr_118 db "[Trace] parseFactor, gsType: %d\n", 0
    roStr_117 db "\tmov rax, %s\n\tpush rax\n", 0
    roStr_116 db "[Error] Error: unknown subtype %d\n", 0
    roStr_115 db "\tpush qword [rbp - %d]\n", 0
    roStr_114 db "\tpush qword [rbp + %d]\n", 0
    roStr_113 db "[Error] Error: unknown type %d in 'parseFactor'\n", 0
    roStr_112 db "\tmov rax, %d ; %s\n\tpush rax\n", 0
    roStr_111 db "\tmov rax, %s\n\tpush rax\n", 0
    roStr_110 db "\tpush qword [%s]\n", 0
    roStr_109 db "\tpush qword [%s]\n", 0
    roStr_108 db "\tpush qword [%s]\n", 0
    roStr_107 db "\tmovzx rax, byte [%s]\n\tpush rax\n", 0
    roStr_106 db "[Trace] Factor: variable #%d\n", 0
    roStr_105 db "\tadd rax, %d\n\tpush qword [rax]\n", 0
    roStr_104 db "\tmov rax, %s\n", 0
    roStr_103 db "; -- accessing struct field value --\n", 0
    roStr_102 db "\tpush rax\n", 0
    roStr_101 db "[Trace] Factor: procedure call\n", 0
    roStr_100 db "[Trace] Factor: array\n", 0
    roStr_99 db "\tpush qword [rax]\n", 0
    roStr_98 db "\tadd rax, %d\n\tpush qword [rax]\n", 0
    roStr_97 db "; -- accessing struct field value --\n", 0
    roStr_96 db "\tpop rax\n\tmov rdx, %d\n\tmul rdx\n\tmov rbx, %s\n\tadd rax, rbx\n", 0
    roStr_95 db "; -- indexing struct[] array --\n", 0
    roStr_94 db "Error: unknown user type %d\n", 0
    roStr_93 db "[Error] Error: unknown array type %d\n", 0
    roStr_92 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_91 db "; -- string access\n", 0
    roStr_90 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_89 db "; -- pointer[] access\n", 0
    roStr_88 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_87 db "; -- uint64[] access\n", 0
    roStr_86 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_85 db "; -- uint8[] access\n", 0
    roStr_84 db "\tpush %d\n", 0
    roStr_83 db "\tmov rax, %d\n\tpush rax\n", 0
    roStr_82 db "\tpush %d ; sizeof %s\n", 0
    roStr_81 db "variable declarations are not allowed in procedure code section\n", 0
    roStr_80 db "parser.strata:%d:%d: ", 0
    roStr_79 db "[Trace] Variable declaration: type %d, value %d\n", 0
    roStr_78 db "[Error] Error: pointer declaration in procedures is not supported\n", 0
    roStr_77 db "\tpop rax\n\tmov qword [%s], rax\n", 0
    roStr_76 db "[Trace] String declaration: type %d, value %d\n", 0
    roStr_75 db "[Trace] String declaration: type %d, subtype %d\n", 0
    roStr_74 db "[Trace] Array declaration: type %d, value %d\n", 0
    roStr_73 db "[Trace] Array declaration: type %d, subtype %d\n", 0
    roStr_72 db "global array size must be known at compile time\n", 0
    roStr_71 db "parser.strata:%d:%d: ", 0
    roStr_70 db "[Trace] Array declaration: type %d, value %d\n", 0
    roStr_69 db "[Trace] Array declaration: type %d, subtype %d\n", 0
    roStr_68 db "gvValue: %d\n", 0
    roStr_67 db "arrays declarations are not allowed in procedures\n", 0
    roStr_66 db "parser.strata:%d:%d: ", 0
    roStr_65 db "[Trace] Identifier: #%d\n", 0
    roStr_64 db "[Trace] Identifier: #%d\n", 0
    roStr_63 db "[Trace] Number: %d\n", 0
    roStr_62 db "unexpected token %d\n", 0
    roStr_61 db "parser.strata:%d:%d: ", 0
    roStr_60 db "unknown identifier: %s\n", 0
    roStr_59 db "parser.strata:%d:%d: ", 0
    roStr_58 db "identifier redeclared: %s\n", 0
    roStr_57 db "parser.strata:%d:%d: ", 0
    roStr_56 db "expected token %d but got %d\n", 0
    roStr_55 db "parser.strata:%d:%d: ", 0
    roStr_54 db "[Trace] Read string: #%d with length %d.\n", 0
    roStr_53 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_52 db "[Trace] Did not find user type field.\n", 0
    roStr_51 db "[Trace] Found user type field: #%d with offset %d.\n", 0
    roStr_50 db "[Trace] Did not find user type.\n", 0
    roStr_49 db "[Trace] Found user type: #%d with value %d.\n", 0
    roStr_48 db "[Trace] Did not find global symbol.\n", 0
    roStr_47 db "[Trace] Found global symbol: #%d with value %d.\n", 0
    roStr_46 db "[Trace] Comparing strings: %s and %s\n", 0
    roStr_45 db "[\#27[92mINFO\#27[0m] Token count: %d\n", 0
    roStr_44 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_43 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_42 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_41 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_40 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_39 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_38 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_37 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_36 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_35 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_34 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_33 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_32 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_31 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_30 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_29 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_28 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_27 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_26 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_25 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_24 db "[\#27[92mINFO\#27[0m] Token: [!] '%s'\n", 0
    roStr_23 db "[\#27[91mERROR\#27[0m] Invalid escape sequence\n", 0
    roStr_22 db "---------------SCIndex: %d, col: %d\n", 0
    roStr_21 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'; ", 0
    roStr_20 db "Token dictionary count: %d\n", 0
    roStr_19 db "[Trace] Comparing strings: %s and %s\n", 0
    roStr_18 db "[Trace] Read string: #%d with length %d.\n", 0
    roStr_17 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_16 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_15 db " %d %d\n", 0
    roStr_14 db "[Trace] Pushed token: %d %d", 0
    roStr_13 db "[\#27[92mINFO\#27[0m] Read %d bytes from input file\n", 0
    roStr_12 db "[\#27[92mINFO\#27[0m] Successfully opened input file '%s'\n", 0
    roStr_11 db "[\#27[91mERROR\#27[0m] Failed to open input file '%s'\n", 0
    roStr_10 db "_start:\n", 0
    roStr_9 db "    global _start\n", 0
    roStr_8 db "    extern ExitProcess\n", 0
    roStr_7 db "section .text\n", 0
    roStr_6 db "\n", 0
    roStr_5 db "default rel\n", 0
    roStr_4 db "bits 64\n", 0
    roStr_3 db "\n", 0
    roStr_2 db "; Generated by Strata v2.0\n", 0
    roStr_1 db "[\#27[92mINFO\#27[0m] Output file '%s'\r\n", 0
    roStr_0 db "[\#27[92mINFO\#27[0m] Input file '%s'\r\n", 0
