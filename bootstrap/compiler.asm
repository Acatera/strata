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
	tokens resq 75000
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
	stringBuffer resb 150000
section .text

section .data
	sbIndex dq 0
section .text

section .data
	stringBufferTop dq 0
section .text
section .bss
	stringPointers resq 7500
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

;.if_1:
	mov r15, [stringPointersTop]
	cmp r15, 7500
	jle .end_1
;then_1:

        printf(roStr_16)
        ExitProcess(1) 
.end_1:
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

.while_2:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_2
;do_2:
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

    jmp .while_2
    ; end while_2
.end_2:
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

    ;printf(roStr_17, [stringPointersTop], [freeStringIndex])
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
	TOKEN_INCREMENT dq 48
section .text

section .data
	TOKEN_DECREMENT dq 49
section .text

section .data
	TOKEN_ENUM dq 50
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
	TYPE_PROCEDURE_FWD dq 11
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

.while_3:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_3
;do_3:
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

    jmp .while_3
    ; end while_3
.end_3:
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

    ;printf(roStr_18, [token_dictionary_pointers_top], [freeStringIndex])
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

.while_4:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_4
;do_4:
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

    jmp .while_4
    ; end while_4
.end_4:
	mov rdx, token_at_pointer
	add rdx, [freeStringIndex]
	mov byte [rdx], 0

    ;printf(roStr_19, [rbp + 16], [freeStringIndex])
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

    ;printf(roStr_20, rsi, rdi)
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

.while_5:
	mov r15, [gttCount]
	cmp r15, [token_dictionary_pointers_top]
	jge .end_5
;do_5:
	push qword [gttIndex]

	call token_equals
	mov [gttEqual], rax
	add rsp, 8

;.if_6:
	mov r15, [gttEqual]
	cmp r15, 0
	je .end_6
;then_6:

    jmp .end_5

.end_6:
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

    jmp .while_5
    ; end while_5
.end_5:

;.if_7:
	mov r15, [gttEqual]
	cmp r15, [true]
	jne .else_7
;then_7:
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
	jmp .end_7
.else_7:

        mov rax, 0
.end_7:

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

;.if_8:
	movzx r15, byte [tnChar]
	cmp r15, 0
	je .end_8
;then_8:
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

;.if_9:
	movzx r15, byte [tnChar]
	cmp r15, 48
	jne .end_9
;then_9:

;.if_10:
	mov r15, [_]
	cmp r15, 88
	jne .end_10
;then_10:
	push 1
	pop rax
	mov qword [tnIsHex], rax

.end_10:

.end_9:

;.if_11:
	movzx r15, byte [tnChar]
	cmp r15, 48
	jne .end_11
;then_11:

;.if_12:
	mov r15, [_]
	cmp r15, 120
	jne .end_12
;then_12:
	push 1
	pop rax
	mov qword [tnIsHex], rax

.end_12:

.end_11:

.end_8:

;.if_13:
	mov r15, [tnIsHex]
	cmp r15, 1
	jne .end_13
;then_13:
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

.end_13:

.while_14:
	movzx r15, byte [tnChar]
	cmp r15, 0
	je .end_14
;do_14:
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

;.if_15:
	mov r15, [tnBase]
	cmp r15, 10
	jne .else_15
;then_15:

;.if_16:
	mov r15, [tnDigit]
	cmp r15, 47
	jle .else_16
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

    jmp .end_14

.end_17:

	jmp .end_16
.else_16:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_14

.end_16:

	jmp .end_15
.else_15:

;.if_18:
	mov r15, [tnBase]
	cmp r15, 16
	jne .else_18
;then_18:

;.if_19:
	mov r15, [tnDigit]
	cmp r15, 96
	jle .else_19
;then_19:

;.if_20:
	mov r15, [tnDigit]
	cmp r15, 103
	jge .else_20
;then_20:
	push qword [tnDigit]
	push 87
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_20
.else_20:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_14

.end_20:

	jmp .end_19
.else_19:

;.if_21:
	mov r15, [tnDigit]
	cmp r15, 64
	jle .else_21
;then_21:

;.if_22:
	mov r15, [tnDigit]
	cmp r15, 71
	jge .else_22
;then_22:
	push qword [tnDigit]
	push 55
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_22
.else_22:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_14

.end_22:

	jmp .end_21
.else_21:

;.if_23:
	mov r15, [tnDigit]
	cmp r15, 47
	jle .end_23
;then_23:

;.if_24:
	mov r15, [tnDigit]
	cmp r15, 58
	jge .else_24
;then_24:
	push qword [tnDigit]
	push 48
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [tnDigit], rax

	jmp .end_24
.else_24:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_14

.end_24:

.end_23:

.end_21:

.end_19:

	jmp .end_18
.else_18:
	push 0
	pop rax
	mov qword [tnSuccess], rax

    jmp .end_14

.end_18:

.end_15:
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

    jmp .while_14
    ; end while_14
.end_14:

    mov rax, [tnSuccess]
	mov rsp, rbp
	pop rbp
	ret
to_number_end:

	jmp isSpace_end
isSpace:
	push rbp
	mov rbp, rsp

;.if_25:
	movzx r15, byte [c]
	cmp r15, 32
	jne .else_25
;then_25:

        mov rax, 1
	jmp .end_25
.else_25:

;.if_26:
	movzx r15, byte [c]
	cmp r15, 10
	jne .else_26
;then_26:

        mov rax, 1
	jmp .end_26
.else_26:

;.if_27:
	movzx r15, byte [c]
	cmp r15, 13
	jne .else_27
;then_27:

        mov rax, 1
	jmp .end_27
.else_27:

;.if_28:
	movzx r15, byte [c]
	cmp r15, 9
	jne .else_28
;then_28:

        mov rax, 1
	jmp .end_28
.else_28:

        mov rax, 0
.end_28:

.end_27:

.end_26:

.end_25:

	mov rsp, rbp
	pop rbp
	ret
isSpace_end:

	jmp isSeparator_end
isSeparator:
	push rbp
	mov rbp, rsp

;.if_29:
	movzx r15, byte [c]
	cmp r15, 59
	jne .else_29
;then_29:

        mov rax, 1
	jmp .end_29
.else_29:

;.if_30:
	movzx r15, byte [c]
	cmp r15, 44
	jne .else_30
;then_30:

        mov rax, 1
	jmp .end_30
.else_30:

;.if_31:
	movzx r15, byte [c]
	cmp r15, 40
	jne .else_31
;then_31:

        mov rax, 1
	jmp .end_31
.else_31:

;.if_32:
	movzx r15, byte [c]
	cmp r15, 41
	jne .else_32
;then_32:

        mov rax, 1
	jmp .end_32
.else_32:

;.if_33:
	movzx r15, byte [c]
	cmp r15, 91
	jne .else_33
;then_33:

        mov rax, 1
	jmp .end_33
.else_33:

;.if_34:
	movzx r15, byte [c]
	cmp r15, 93
	jne .else_34
;then_34:

        mov rax, 1
	jmp .end_34
.else_34:

;.if_35:
	movzx r15, byte [c]
	cmp r15, 46
	jne .else_35
;then_35:

        mov rax, 1
	jmp .end_35
.else_35:

;.if_36:
	movzx r15, byte [c]
	cmp r15, 64
	jne .else_36
;then_36:

        mov rax, 1
	jmp .end_36
.else_36:

;.if_37:
	movzx r15, byte [c]
	cmp r15, 38
	jne .else_37
;then_37:

        mov rax, 1
	jmp .end_37
.else_37:

        mov rax, 0
.end_37:

.end_36:

.end_35:

.end_34:

.end_33:

.end_32:

.end_31:

.end_30:

.end_29:

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
	mov rdx, stringToPush
	add rdx, 0
	mov byte [rdx], 101
	mov rdx, stringToPush
	add rdx, 1
	mov byte [rdx], 110
	mov rdx, stringToPush
	add rdx, 2
	mov byte [rdx], 117
	mov rdx, stringToPush
	add rdx, 3
	mov byte [rdx], 109
	mov rdx, stringToPush
	add rdx, 4
	mov byte [rdx], 0
	push qword [TOKEN_ENUM]

	call register_token_type
	mov [_], rax
	add rsp, 8

;printf(roStr_21, [token_dictionary_pointers_top])

section .data
	token_type dq 0
section .text

	jmp push_and_print_token_end
push_and_print_token:
	push rbp
	mov rbp, rsp

    ;printf(roStr_22, token)
    
	call to_number
	mov [_], rax
	add rsp, 0

;.if_38:
	mov r15, [_]
	cmp r15, 1
	jne .else_38
;then_38:
	push qword [col]
	push qword [line]
	push qword [tnNumber]
	push qword [TOKEN_CONSTANT_INTEGER]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_38
.else_38:

	call get_token_type
	mov [token_type], rax
	add rsp, 0

;.if_39:
	mov r15, [token_type]
	cmp r15, 0
	jne .else_39
;then_39:
	push qword [col]
	push qword [line]
	push qword [stringPointersTop]
	push qword [TOKEN_IDENTIFIER]

	call push_token
	mov [_], rax
	add rsp, 32

	call push_identifier

	jmp .end_39
.else_39:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [token_type]

	call push_token
	mov [_], rax
	add rsp, 32

.end_39:

.end_38:

	mov rsp, rbp
	pop rbp
	ret
push_and_print_token_end:

.while_40:
	mov r15, [scIndex]
	cmp r15, [bytesRead]
	jge .end_40
;do_40:
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

;.if_41:
	mov r15, [_]
	cmp r15, 1
	jne .else_41
;then_41:

;.if_42:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_42
;then_42:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_42:

;.if_43:
	movzx r15, byte [c]
	cmp r15, 10
	jne .end_43
;then_43:
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

.end_43:
	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, sourceCode
	add rdx, [scIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov byte [c], al

.while_44:
	mov r15, [true]
	cmp r15, 1
	jne .end_44
;do_44:
	push qword [c]

	call isSpace
	mov [_], rax
	add rsp, 8

;.if_45:
	mov r15, [_]
	cmp r15, 1
	jne .else_45
;then_45:

;.if_46:
	movzx r15, byte [c]
	cmp r15, 10
	jne .end_46
;then_46:
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

.end_46:
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

    jmp .end_44

    jmp .end_40

.end_45:

    jmp .while_44
    ; end while_44
.end_44:
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

        ;printf(roStr_23, [scIndex], [col])
        
	jmp .end_41
.else_41:

;.if_47:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_47
;then_47:

;.if_48:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_48
;then_48:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_48:
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

.while_49:
	mov r15, [scIndex]
	cmp r15, [bytesRead]
	jge .end_49
;do_49:

;.if_50:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_50
;then_50:
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

;.if_51:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_51
;then_51:
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

	jmp .end_51
.else_51:

;.if_52:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_52
;then_52:
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

	jmp .end_52
.else_52:

;.if_53:
	movzx r15, byte [c]
	cmp r15, 110
	jne .else_53
;then_53:
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

	jmp .end_53
.else_53:

;.if_54:
	movzx r15, byte [c]
	cmp r15, 114
	jne .else_54
;then_54:
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

	jmp .end_54
.else_54:

;.if_55:
	movzx r15, byte [c]
	cmp r15, 116
	jne .else_55
;then_55:
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

	jmp .end_55
.else_55:

;.if_56:
	movzx r15, byte [c]
	cmp r15, 48
	jne .else_56
;then_56:
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

	jmp .end_56
.else_56:

;.if_57:
	movzx r15, byte [c]
	cmp r15, 39
	jne .else_57
;then_57:
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

	jmp .end_57
.else_57:

;.if_58:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_58
;then_58:
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

	jmp .end_58
.else_58:

                    printf(roStr_24)
                    ExitProcess(1)
.end_58:

.end_57:

.end_56:

.end_55:

.end_54:

.end_53:

.end_52:

.end_51:

	jmp .end_50
.else_50:

;.if_59:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_59
;then_59:

    jmp .end_49

    jmp .end_40

	jmp .end_59
.else_59:
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

.end_59:

.end_50:

    jmp .while_49
    ; end while_49
.end_49:

        ;token [ tokenIndex ] = c ; 
        ;tokenIndex = tokenIndex + 1 ;
        	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

        ;printf(roStr_25, token)
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

	jmp .end_47
.else_47:

;.if_60:
	movzx r15, byte [c]
	cmp r15, 39
	jne .else_60
;then_60:

;.if_61:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_61
;then_61:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_61:
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

.while_62:
	mov r15, [scIndex]
	cmp r15, [bytesRead]
	jge .end_62
;do_62:

;.if_63:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_63
;then_63:
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

;.if_64:
	movzx r15, byte [c]
	cmp r15, 34
	jne .else_64
;then_64:
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

	jmp .end_64
.else_64:

;.if_65:
	movzx r15, byte [c]
	cmp r15, 92
	jne .else_65
;then_65:
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

	jmp .end_65
.else_65:

;.if_66:
	movzx r15, byte [c]
	cmp r15, 110
	jne .else_66
;then_66:
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

	jmp .end_66
.else_66:

;.if_67:
	movzx r15, byte [c]
	cmp r15, 114
	jne .else_67
;then_67:
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

	jmp .end_67
.else_67:

;.if_68:
	movzx r15, byte [c]
	cmp r15, 116
	jne .else_68
;then_68:
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

	jmp .end_68
.else_68:

;.if_69:
	movzx r15, byte [c]
	cmp r15, 48
	jne .else_69
;then_69:
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

	jmp .end_69
.else_69:

;.if_70:
	movzx r15, byte [c]
	cmp r15, 39
	jne .else_70
;then_70:
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

	jmp .end_70
.else_70:

                    printf(roStr_26)
                    ExitProcess(1)
.end_70:

.end_69:

.end_68:

.end_67:

.end_66:

.end_65:

.end_64:

	jmp .end_63
.else_63:

;.if_71:
	movzx r15, byte [c]
	cmp r15, 39
	jne .else_71
;then_71:

    jmp .end_62

    jmp .end_40

	jmp .end_71
.else_71:
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

.end_71:

.end_63:

    jmp .while_62
    ; end while_62
.end_62:

        ;token [ tokenIndex ] = c ; 
        ;tokenIndex = tokenIndex + 1 ;
        	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

        ;printf(roStr_27, token)
        	push 0
	pop rax
	mov qword [tokenIndex], rax
	mov rdx, token
	add rdx, [tokenIndex]
	movzx rax, byte [rdx]
	push qword rax
	pop rax
	mov qword [_], rax
	push qword [col]
	push qword [line]
	push qword [_]
	push qword [TOKEN_CONSTANT_INTEGER]

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

	jmp .end_60
.else_60:

;.if_72:
	mov r15, [isSep]
	cmp r15, 1
	jne .else_72
;then_72:

;.if_73:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_73
;then_73:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_73:
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

        ;printf(roStr_28, token)
        
;.if_74:
	movzx r15, byte [c]
	cmp r15, 59
	jne .else_74
;then_74:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_SEMICOLON]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_74
.else_74:

;.if_75:
	movzx r15, byte [c]
	cmp r15, 44
	jne .else_75
;then_75:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_COMMA]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_75
.else_75:

;.if_76:
	movzx r15, byte [c]
	cmp r15, 40
	jne .else_76
;then_76:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LEFT_PARENTHESIS]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_76
.else_76:

;.if_77:
	movzx r15, byte [c]
	cmp r15, 41
	jne .else_77
;then_77:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_RIGHT_PARENTHESIS]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_77
.else_77:

;.if_78:
	movzx r15, byte [c]
	cmp r15, 91
	jne .else_78
;then_78:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_LEFT_BRACKET]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_78
.else_78:

;.if_79:
	movzx r15, byte [c]
	cmp r15, 93
	jne .else_79
;then_79:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_RIGHT_BRACKET]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_79
.else_79:

;.if_80:
	movzx r15, byte [c]
	cmp r15, 46
	jne .else_80
;then_80:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_DOT]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_80
.else_80:

;.if_81:
	movzx r15, byte [c]
	cmp r15, 64
	jne .else_81
;then_81:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_AT_SIGN]

	call push_token
	mov [_], rax
	add rsp, 32

	jmp .end_81
.else_81:

;.if_82:
	movzx r15, byte [c]
	cmp r15, 38
	jne .end_82
;then_82:
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_AMPERSAND]

	call push_token
	mov [_], rax
	add rsp, 32

.end_82:

.end_81:

.end_80:

.end_79:

.end_78:

.end_77:

.end_76:

.end_75:

.end_74:
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

	jmp .end_72
.else_72:

;.if_83:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_83
;then_83:

;.if_84:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_84
;then_84:
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

.end_84:
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

;.if_85:
	movzx r15, byte [c]
	cmp r15, 61
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

            ;printf(roStr_29, token)
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

	jmp .end_85
.else_85:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_30, token)
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

.end_85:

	jmp .end_83
.else_83:

;.if_86:
	movzx r15, byte [c]
	cmp r15, 33
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

            ;printf(roStr_31, token)
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

	jmp .end_88
.else_88:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_32, token)
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

.end_88:

	jmp .end_86
.else_86:

;.if_89:
	movzx r15, byte [c]
	cmp r15, 60
	jne .else_89
;then_89:

;.if_90:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_90
;then_90:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_90:
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

;.if_91:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_91
;then_91:
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

            ;printf(roStr_33, token)
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

	jmp .end_91
.else_91:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_34, token)
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

.end_91:

	jmp .end_89
.else_89:

;.if_92:
	movzx r15, byte [c]
	cmp r15, 62
	jne .else_92
;then_92:

;.if_93:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_93
;then_93:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_93:
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

;.if_94:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_94
;then_94:
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

            ;printf(roStr_35, token)
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

	jmp .end_94
.else_94:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_36, token)
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

.end_94:

	jmp .end_92
.else_92:

;.if_95:
	movzx r15, byte [c]
	cmp r15, 43
	jne .else_95
;then_95:

;.if_96:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_96
;then_96:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_96:
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

;.if_97:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_97
;then_97:
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

            ;printf(roStr_37, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_97
.else_97:

;.if_98:
	movzx r15, byte [c]
	cmp r15, 43
	jne .else_98
;then_98:
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
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_INCREMENT]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_98
.else_98:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_38, token)
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

.end_98:

.end_97:

	jmp .end_95
.else_95:

;.if_99:
	movzx r15, byte [c]
	cmp r15, 42
	jne .else_99
;then_99:

;.if_100:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_100
;then_100:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_100:
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

;.if_101:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_101
;then_101:
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
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_101
.else_101:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_40, token)
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

.end_101:

	jmp .end_99
.else_99:

;.if_102:
	movzx r15, byte [c]
	cmp r15, 45
	jne .else_102
;then_102:

;.if_103:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_103
;then_103:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_103:
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

;.if_104:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_104
;then_104:
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

	jmp .end_104
.else_104:

;.if_105:
	movzx r15, byte [c]
	cmp r15, 62
	jne .else_105
;then_105:
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

            ;printf(roStr_42, token)
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

	jmp .end_105
.else_105:

;.if_106:
	movzx r15, byte [c]
	cmp r15, 45
	jne .else_106
;then_106:
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
	push qword [col]
	push qword [line]
	push qword 0
	push qword [TOKEN_DECREMENT]

	call push_token
	mov [_], rax
	add rsp, 32
	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_106
.else_106:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_43, token)
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

.end_106:

.end_105:

.end_104:

	jmp .end_102
.else_102:

;.if_107:
	movzx r15, byte [c]
	cmp r15, 47
	jne .else_107
;then_107:

;.if_108:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_108
;then_108:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_108:
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

;.if_109:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_109
;then_109:
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

            ;printf(roStr_44, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_109
.else_109:

;.if_110:
	movzx r15, byte [c]
	cmp r15, 47
	jne .else_110
;then_110:
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

.while_111:
	movzx r15, byte [c]
	cmp r15, 10
	je .end_111
;do_111:
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

    jmp .while_111
    ; end while_111
.end_111:
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

	jmp .end_110
.else_110:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_45, token)
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

.end_110:

.end_109:

	jmp .end_107
.else_107:

;.if_112:
	movzx r15, byte [c]
	cmp r15, 37
	jne .else_112
;then_112:

;.if_113:
	mov r15, [tokenIndex]
	cmp r15, 0
	jle .end_113
;then_113:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

	call push_and_print_token

.end_113:
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

;.if_114:
	movzx r15, byte [c]
	cmp r15, 61
	jne .else_114
;then_114:
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

            ;printf(roStr_46, token)
            	push 0
	pop rax
	mov qword [tokenIndex], rax

	jmp .end_114
.else_114:
	mov rdx, token
	add rdx, [tokenIndex]
	mov byte [rdx], 0

            ;printf(roStr_47, token)
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

.end_114:

	jmp .end_112
.else_112:
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

.end_112:

.end_107:

.end_102:

.end_99:

.end_95:

.end_92:

.end_89:

.end_86:

.end_83:

.end_72:

.end_60:

.end_47:

.end_41:
	push qword [scIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [scIndex], rax

    jmp .while_40
    ; end while_40
.end_40:

printf(roStr_48, [tokenCount])

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
    ;printf(roStr_49, rsi, rdi)
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

.while_115:
	mov r15, [fgsIndex]
	cmp r15, 0
	jl .end_115
;do_115:
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

;.if_116:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 1
	jne .else_116
;then_116:

;.if_117:
	mov r15, [fgsScope]
	cmp r15, [globalProcedureId]
	je .end_117
;then_117:

;.if_118:
	mov r15, [fgsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_118
;then_118:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_115

.end_118:

.end_117:

	jmp .end_116
.else_116:

;.if_119:
	mov r15, [fgsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_119
;then_119:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_115

.end_119:

.end_116:
	push qword [fgsNamePointer]
	push qword [rbp + 16]

	call stringsEqual
	mov [fgsEqual], rax
	add rsp, 16

;.if_120:
	mov r15, [fgsEqual]
	cmp r15, 0
	je .end_120
;then_120:

    jmp .end_115

.end_120:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_115
    ; end while_115
.end_115:

;.if_121:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_121
;then_121:
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

        ;printf(roStr_50, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_121
.else_121:
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

        ;printf(roStr_51)
        mov rax, -1 
.end_121:

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

.while_122:
	mov r15, [fgsIndex]
	cmp r15, [globalSymbolsCount]
	jge .end_122
;do_122:
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

;.if_123:
	mov r15, [_]
	cmp r15, [TYPE_USER_DEFINED]
	je .end_123
;then_123:
	push qword [fgsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_122

.end_123:
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

;.if_124:
	mov r15, [_]
	cmp r15, [futUserType]
	jne .end_124
;then_124:
	push 1
	pop rax
	mov qword [fgsEqual], rax

    jmp .end_122

.end_124:
	push qword [fgsIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_122
    ; end while_122
.end_122:

;.if_125:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_125
;then_125:
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

        ;printf(roStr_52, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_125
.else_125:
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

        ;printf(roStr_53)
        mov rax, -1 
.end_125:

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

.while_126:
	mov r15, [userTypeCount]
	cmp r15, 0
	jl .end_126
;do_126:
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

;.if_127:
	mov r15, [utParent]
	cmp r15, [_]
	je .end_127
;then_127:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_126

.end_127:
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

;.if_128:
	mov r15, [fgsEqual]
	cmp r15, 0
	je .end_128
;then_128:

    jmp .end_126

.end_128:
	push qword [fgsIndex]
	push 1
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [fgsIndex], rax

    jmp .while_126
    ; end while_126
.end_126:

;.if_129:
	mov r15, [fgsEqual]
	cmp r15, [true]
	jne .else_129
;then_129:
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

        ;printf(roStr_54, [fgsIndex], [_])
        mov rax, [_] 
	jmp .end_129
.else_129:
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

        ;printf(roStr_55)
        mov rax, -1 
.end_129:

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

.while_130:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_130
;do_130:
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

    jmp .while_130
    ; end while_130
.end_130:
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

    ;printf(roStr_56, [stringPointersTop], [freeStringIndex])
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

.while_131:
	movzx r15, byte [freeChar]
	cmp r15, 0
	je .end_131
;do_131:
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

    jmp .while_131
    ; end while_131
.end_131:
	mov rdx, stringAtPointer
	add rdx, [freeStringIndex]
	mov byte [rdx], 0

    ;printf(roStr_57, [rbp + 16], [freeStringIndex])
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

;.if_132:
	mov r15, [currentToken]
	cmp r15, [expectedToken]
	jne .else_132
;then_132:
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

	jmp .end_132
.else_132:
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

        printf(roStr_58, [errorAtLine], [errorAtColumn])
        printf(roStr_59, [expectedToken], [currentToken])
        ExitProcess(1) 
.end_132:

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
 
    printf(roStr_60, [errorAtLine], [errorAtColumn])
    printf(roStr_61, stringAtPointer) ;
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
 
    printf(roStr_62, [errorAtLine], [errorAtColumn])
    printf(roStr_63, stringAtPointer) ;
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

    printf(roStr_64, [errorAtLine], [errorAtColumn])
    printf(roStr_65, [currentToken])
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

    ;printf(roStr_66, [_])
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

    ;printf(roStr_67, [_])
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

;.if_133:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_133
;then_133:
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

	jmp .end_133
.else_133:

;.if_134:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_134
;then_134:
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

	jmp .end_134
.else_134:

;.if_135:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_135
;then_135:
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

	jmp .end_135
.else_135:

	call unexpectedToken

.end_135:

.end_134:

.end_133:

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

    ;printf(roStr_68, [_])
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

;.if_136:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	je .end_136
;then_136:
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

        printf(roStr_69, [errorAtLine], [errorAtColumn])
        printf(roStr_70)
.end_136:
	push qword [TOKEN_LEFT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_137:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_137
;then_137:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

        ;printf(roStr_71, [gvValue])
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

        ;printf(roStr_72, [gvType], [gvSubType])
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

        ;printf(roStr_73, [gvType], [gvValue])
	jmp .end_137
.else_137:

;.if_138:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_138
;then_138:

	call parseIdentifier
	mov [padIdentifier], rax
	add rsp, 0
	push qword [padIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_139:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_139
;then_139:
	push qword [padIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_139:

;.if_140:
	mov r15, [gsType]
	cmp r15, [TYPE_DEFINE]
	je .end_140
;then_140:
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

            printf(roStr_74, [errorAtLine], [errorAtColumn])
            printf(roStr_75)
            ExitProcess(1)
.end_140:
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

        ;printf(roStr_76, [gvType], [gvSubType])
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

        ;printf(roStr_77, [gvType], [gvValue])
	jmp .end_138
.else_138:
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

        ;printf(roStr_78, [gvType], [gvSubType])
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

        ;printf(roStr_79, [gvType], [gvValue])
.end_138:

.end_137:

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

;.if_141:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_141
;then_141:
	push qword [pidIndentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_141:
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_142:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_142
;then_142:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

        WriteToFile(roStr_80, [gvValue])
	jmp .end_142
.else_142:
	push 0
	pop rax
	mov qword [gvValue], rax

	call parseLogicalOrExpression

.end_142:

;.if_143:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	jne .else_143
;then_143:
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

        WriteToFile(roStr_81, stringAtPointer)
	jmp .end_143
.else_143:
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

.end_143:

	mov rsp, rbp
	pop rbp
	ret
parseIntegerDeclaration_end:

section .data
	ptrIdentifier dq 0
section .text

	jmp parsePointerDeclaration_end
parsePointerDeclaration:
	push rbp
	mov rbp, rsp
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [ptrIdentifier], rax
	add rsp, 0
	push qword [ptrIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_144:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_144
;then_144:
	push qword [ptrIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_144:
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_145:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_145
;then_145:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

        WriteToFile(roStr_82, [gvValue])
	jmp .end_145
.else_145:
	push 0
	pop rax
	mov qword [gvValue], rax

	call parseLogicalOrExpression

.end_145:

;.if_146:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 0
	jne .else_146
;then_146:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [gvValue]
	push qword [ptrIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvType]
	push qword [TYPE_POINTER]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword 0
	push qword [ptrIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword [gvType]
	push qword [TYPE_POINTER]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [ptrIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_83, stringAtPointer)
	jmp .end_146
.else_146:

        printf(roStr_84)
        ExitProcess(1)
.end_146:

    ;printf(roStr_85, [gvType], [gvValue])
	mov rsp, rbp
	pop rbp
	ret
parsePointerDeclaration_end:

	jmp parseVariableDeclaration_end
parseVariableDeclaration:
	push rbp
	mov rbp, rsp

;.if_147:
	mov r15, [globalAllowVariableDeclaration]
	cmp r15, 0
	jne .end_147
;then_147:
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

        printf(roStr_86, [errorAtLine], [errorAtColumn])
        printf(roStr_87)
.end_147:
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

;.if_148:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_148
;then_148:

	call parseArrayDeclaration

	jmp .end_148
.else_148:

;.if_149:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_149
;then_149:

	call parseIntegerDeclaration

	jmp .end_149
.else_149:

;.if_150:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_150
;then_150:

	call parsePointerDeclaration

	jmp .end_150
.else_150:

	call unexpectedToken

.end_150:

.end_149:

.end_148:
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

;.if_151:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_151
;then_151:
	push qword [psosIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_151:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [psosIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    WriteToFile(roStr_88, [gsValue], stringAtPointer)
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

;.if_152:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_INTEGER]
	jne .else_152
;then_152:

	call parseNumber
	mov [_], rax
	add rsp, 0

;.if_153:
	mov r15, [_]
	cmp r15, 2147483647
	jle .else_153
;then_153:

            WriteToFile(roStr_89, [_])
	jmp .end_153
.else_153:

            WriteToFile(roStr_90, [_])
.end_153:

	jmp .end_152
.else_152:

;.if_154:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_154
;then_154:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	jmp .end_154
.else_154:

;.if_155:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_155
;then_155:

;.if_156:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_156
;then_156:

	call parseArrayAccess
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

;.if_158:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_158
;then_158:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_159:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_159
;then_159:

                    WriteToFile(roStr_91)
                    WriteToFile(roStr_92, stringAtPointer)
	jmp .end_159
.else_159:

;.if_160:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_160
;then_160:

                    WriteToFile(roStr_93)
                    WriteToFile(roStr_94, stringAtPointer)
	jmp .end_160
.else_160:

;.if_161:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_161
;then_161:

                    WriteToFile(roStr_95)
                    WriteToFile(roStr_96, stringAtPointer)
	jmp .end_161
.else_161:

;.if_162:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_162
;then_162:

                    WriteToFile(roStr_97)
                    WriteToFile(roStr_98, stringAtPointer)
	jmp .end_162
.else_162:
 
                    printf(roStr_99, [gsSubType])
                    ExitProcess(1)
.end_162:

.end_161:

.end_160:

.end_159:

	jmp .end_158
.else_158:
	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [gsSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_163:
	mov r15, [_]
	cmp r15, -1
	jne .end_163
;then_163:

                    printf(roStr_100, [gsSubType])
                    ExitProcess(1)
.end_163:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

                WriteToFile(roStr_101)
                WriteToFile(roStr_102, [gsValue], stringAtPointer)
                
;.if_164:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DOT]
	jne .else_164
;then_164:
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

;.if_165:
	mov r15, [utOffset]
	cmp r15, 0
	je .else_165
;then_165:

                        WriteToFile(roStr_103)
                        WriteToFile(roStr_104, [utOffset])
	jmp .end_165
.else_165:

                        WriteToFile(roStr_105, [utOffset])
.end_165:

	jmp .end_164
.else_164:

                    WriteToFile(roStr_106)
.end_164:

.end_158:

            ;printf(roStr_107)
	jmp .end_156
.else_156:

;.if_166:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_166
;then_166:

	call parseProcedureCall

            ;printf(roStr_108)
            WriteToFile(roStr_109)
	jmp .end_166
.else_166:

;.if_167:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_167
;then_167:

	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_168:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_168
;then_168:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_168:
	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_110)
            WriteToFile(roStr_111, stringAtPointer)
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

            WriteToFile(roStr_112, [utOffset])
	jmp .end_167
.else_167:

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

            ;printf(roStr_113, [_])
            
	call parseIdentifier
	mov [fpIdentifier], rax
	add rsp, 0
	push qword [fpIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_169:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_169
;then_169:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_169:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_170:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_170
;then_170:

;.if_171:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT8]
	jne .else_171
;then_171:
 
                    WriteToFile(roStr_114, stringAtPointer)
	jmp .end_171
.else_171:

;.if_172:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT64]
	jne .else_172
;then_172:
 
                    WriteToFile(roStr_115, stringAtPointer)
	jmp .end_172
.else_172:

;.if_173:
	mov r15, [gsType]
	cmp r15, [TYPE_POINTER]
	jne .else_173
;then_173:

                    WriteToFile(roStr_116, stringAtPointer)
	jmp .end_173
.else_173:

;.if_174:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_174
;then_174:

                    WriteToFile(roStr_117, stringAtPointer)
	jmp .end_174
.else_174:

;.if_175:
	mov r15, [gsType]
	cmp r15, [TYPE_ARRAY]
	jne .else_175
;then_175:
 
                    WriteToFile(roStr_118, stringAtPointer)
	jmp .end_175
.else_175:

;.if_176:
	mov r15, [gsType]
	cmp r15, [TYPE_DEFINE]
	jne .else_176
;then_176:

                    WriteToFile(roStr_119, [gsValue], stringAtPointer)
	jmp .end_176
.else_176:
 
                    printf(roStr_120, [gsType])
                    ExitProcess(1)
.end_176:

.end_175:

.end_174:

.end_173:

.end_172:

.end_171:

	jmp .end_170
.else_170:

;.if_177:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .else_177
;then_177:
 
                    WriteToFile(roStr_121, [gsValue])
	jmp .end_177
.else_177:

;.if_178:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_178
;then_178:
 
                    WriteToFile(roStr_122, [gsValue])
	jmp .end_178
.else_178:
 
                    printf(roStr_123, [gsType])
                    ExitProcess(1)
.end_178:

.end_177:

.end_170:

.end_167:

.end_166:

.end_156:

	jmp .end_155
.else_155:

;.if_179:
	mov r15, [currentToken]
	cmp r15, [TOKEN_AMPERSAND]
	jne .else_179
;then_179:
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

;.if_180:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_180
;then_180:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_180:
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_124, stringAtPointer)
	jmp .end_179
.else_179:

;.if_181:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_181
;then_181:
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

;.if_182:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_182
;then_182:
	push qword [fpIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_182:

        ;printf(roStr_125, [gsType])
        	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_183:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_183
;then_183:

        ;printf(roStr_126)
        	push qword [gsSubType]
	pop rax
	mov qword [pfType], rax
	push qword [fpIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_127)
            WriteToFile(roStr_128, stringAtPointer)
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

;.if_184:
	mov r15, [utType]
	cmp r15, [TYPE_UINT64]
	jne .else_184
;then_184:

                WriteToFile(roStr_129, [utOffset])
	jmp .end_184
.else_184:

                WriteToFile(roStr_130, [utOffset])
.end_184:

	jmp .end_183
.else_183:

;.if_185:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_185
;then_185:

                WriteToFile(roStr_131, stringAtPointer)
	jmp .end_185
.else_185:

;.if_186:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_186
;then_186:

                WriteToFile(roStr_132, stringAtPointer)
	jmp .end_186
.else_186:

                printf(roStr_133, [gsType])
                ExitProcess(1)
.end_186:

.end_185:

.end_183:

	jmp .end_181
.else_181:

;.if_187:
	mov r15, [currentToken]
	cmp r15, [TOKEN_SIZEOF]
	jne .else_187
;then_187:

	call parseSizeOfStatement

	jmp .end_187
.else_187:

	call unexpectedToken

.end_187:

.end_181:

.end_179:

.end_155:

.end_154:

.end_152:

	mov rsp, rbp
	pop rbp
	ret
parseFactor_end:

	jmp parseMultiplicativeExpression_end
parseMultiplicativeExpression:
	push rbp
	mov rbp, rsp

	call parseFactor

.while_188:
	mov r15, [true]
	cmp r15, 1
	jne .end_188
;do_188:

;.if_189:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_189
;then_189:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_134)
            WriteToFile(roStr_135)
	jmp .end_189
.else_189:

;.if_190:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DIVIDE]
	jne .else_190
;then_190:
	push qword [TOKEN_DIVIDE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_136)
            WriteToFile(roStr_137)
	jmp .end_190
.else_190:

;.if_191:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MODULO]
	jne .else_191
;then_191:
	push qword [TOKEN_MODULO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseFactor

            WriteToFile(roStr_138)
            WriteToFile(roStr_139)
	jmp .end_191
.else_191:

    jmp .end_188

.end_191:

.end_190:

.end_189:

    jmp .while_188
    ; end while_188
.end_188:

	mov rsp, rbp
	pop rbp
	ret
parseMultiplicativeExpression_end:

	jmp parseAdditiveExpression_end
parseAdditiveExpression:
	push rbp
	mov rbp, rsp

	call parseMultiplicativeExpression

.while_192:
	mov r15, [true]
	cmp r15, 1
	jne .end_192
;do_192:

;.if_193:
	mov r15, [currentToken]
	cmp r15, [TOKEN_PLUS]
	jne .else_193
;then_193:
	push qword [TOKEN_PLUS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseMultiplicativeExpression

            WriteToFile(roStr_140)
            WriteToFile(roStr_141)
	jmp .end_193
.else_193:

;.if_194:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MINUS]
	jne .else_194
;then_194:
	push qword [TOKEN_MINUS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseMultiplicativeExpression

            WriteToFile(roStr_142)
            WriteToFile(roStr_143)
	jmp .end_194
.else_194:

    jmp .end_192

.end_194:

.end_193:

    jmp .while_192
    ; end while_192
.end_192:

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

;.if_195:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LESS_THAN]
	jne .else_195
;then_195:
	push qword [TOKEN_LESS_THAN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_144)
        WriteToFile(roStr_145, [preIndex], [preIndex])
        WriteToFile(roStr_146, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_195
.else_195:

;.if_196:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LESS_THAN_OR_EQUAL_TO]
	jne .else_196
;then_196:
	push qword [TOKEN_LESS_THAN_OR_EQUAL_TO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_147)
        WriteToFile(roStr_148, [preIndex], [preIndex])
        WriteToFile(roStr_149, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_196
.else_196:

;.if_197:
	mov r15, [currentToken]
	cmp r15, [TOKEN_GREATER_THAN]
	jne .else_197
;then_197:
	push qword [TOKEN_GREATER_THAN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_150)
        WriteToFile(roStr_151, [preIndex], [preIndex])
        WriteToFile(roStr_152, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_197
.else_197:

;.if_198:
	mov r15, [currentToken]
	cmp r15, [TOKEN_GREATER_THAN_OR_EQUAL_TO]
	jne .else_198
;then_198:
	push qword [TOKEN_GREATER_THAN_OR_EQUAL_TO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_153)
        WriteToFile(roStr_154, [preIndex], [preIndex])
        WriteToFile(roStr_155, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_198
.else_198:

;.if_199:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EQUALS]
	jne .else_199
;then_199:
	push qword [TOKEN_EQUALS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_156)
        WriteToFile(roStr_157, [preIndex], [preIndex])
        WriteToFile(roStr_158, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

	jmp .end_199
.else_199:

;.if_200:
	mov r15, [currentToken]
	cmp r15, [TOKEN_NOT_EQUALS]
	jne .end_200
;then_200:
	push qword [TOKEN_NOT_EQUALS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseAdditiveExpression

        WriteToFile(roStr_159)
        WriteToFile(roStr_160, [preIndex], [preIndex])
        WriteToFile(roStr_161, [preIndex], [preIndex])
        	push qword [preIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [preIndex], rax

.end_200:

.end_199:

.end_198:

.end_197:

.end_196:

.end_195:

	mov rsp, rbp
	pop rbp
	ret
parseRelationalExpression_end:

	jmp parseLogicalAndExpression_end
parseLogicalAndExpression:
	push rbp
	mov rbp, rsp

	call parseRelationalExpression

.while_201:
	mov r15, [true]
	cmp r15, 1
	jne .end_201
;do_201:

;.if_202:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LOGICAL_AND]
	jne .else_202
;then_202:
	push qword [TOKEN_LOGICAL_AND]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseRelationalExpression

            WriteToFile(roStr_162)
            WriteToFile(roStr_163)
	jmp .end_202
.else_202:

    jmp .end_201

.end_202:

    jmp .while_201
    ; end while_201
.end_201:

	mov rsp, rbp
	pop rbp
	ret
parseLogicalAndExpression_end:

	jmp parseLogicalOrExpression_end
parseLogicalOrExpression:
	push rbp
	mov rbp, rsp

    WriteToFile(roStr_164)
    
	call parseLogicalAndExpression

.while_203:
	mov r15, [true]
	cmp r15, 1
	jne .end_203
;do_203:

;.if_204:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LOGICAL_OR]
	jne .else_204
;then_204:
	push qword [TOKEN_LOGICAL_OR]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseLogicalAndExpression

            WriteToFile(roStr_165)
            WriteToFile(roStr_166)
	jmp .end_204
.else_204:

    jmp .end_203

.end_204:

    jmp .while_203
    ; end while_203
.end_203:

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

;.if_205:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_205
;then_205:
	push qword [psaIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_205:
	push qword [gsSubType]
	pop rax
	mov qword [psaType], rax
	push qword [psaIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_206:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_206
;then_206:

        WriteToFile(roStr_167)
        WriteToFile(roStr_168, stringAtPointer)
	jmp .end_206
.else_206:

        WriteToFile(roStr_169)
        WriteToFile(roStr_170, stringAtPointer)
.end_206:
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

    WriteToFile(roStr_171, [utOffset])
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

;.if_207:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_207
;then_207:

	call parseArrayAccess
	mov [paIdentifier], rax
	add rsp, 0
	push qword [paIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_208:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_208
;then_208:
	push qword [paIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_208:

;.if_209:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_209
;then_209:
	push qword [paIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_210:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_210
;then_210:

                WriteToFile(roStr_172)
                WriteToFile(roStr_173, stringAtPointer)
	jmp .end_210
.else_210:

;.if_211:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_211
;then_211:

                WriteToFile(roStr_174)
                WriteToFile(roStr_175, stringAtPointer)
	jmp .end_211
.else_211:

;.if_212:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_212
;then_212:

                WriteToFile(roStr_176)
                WriteToFile(roStr_177, stringAtPointer)
	jmp .end_212
.else_212:

;.if_213:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_213
;then_213:

                WriteToFile(roStr_178)
                WriteToFile(roStr_179, stringAtPointer)
	jmp .end_213
.else_213:
 
                printf(roStr_180, [gsSubType])
                ExitProcess(1)
.end_213:

.end_212:

.end_211:

.end_210:

            ;printf(roStr_181, [currentToken])
	jmp .end_209
.else_209:
	push qword [gsSubType]
	pop rax
	mov qword [paType], rax
	push qword [gsSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_214:
	mov r15, [_]
	cmp r15, -1
	jne .end_214
;then_214:

                printf(roStr_182, [gsSubType])
                ExitProcess(1)
.end_214:
	push qword [paIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

            WriteToFile(roStr_183)
            WriteToFile(roStr_184, [gsValue], stringAtPointer)
            
;.if_215:
	mov r15, [currentToken]
	cmp r15, [TOKEN_DOT]
	jne .else_215
;then_215:
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

                WriteToFile(roStr_185)
                WriteToFile(roStr_186, [utOffset])
	jmp .end_215
.else_215:

                printf(roStr_187)
.end_215:

.end_209:

	jmp .end_207
.else_207:

;.if_216:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_216
;then_216:

	call parseStructAccess
	mov [paIdentifier], rax
	add rsp, 0

	jmp .end_216
.else_216:

	call parseIdentifier
	mov [paIdentifier], rax
	add rsp, 0
	push qword [paIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_217:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_217
;then_217:
	push qword [paIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_217:

        ;printf(roStr_188)
.end_216:

.end_207:

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

    WriteToFile(roStr_189)
;.if_218:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .end_218
;then_218:
	push qword [TOKEN_MULTIPLY]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 1
	pop rax
	mov qword [pasIsDereference], rax

.end_218:

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

;.if_219:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_219
;then_219:
	push qword [pasIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_219:
	push qword [pasIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_220:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT8]
	jne .else_220
;then_220:

;.if_221:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_221
;then_221:

            WriteToFile(roStr_190, stringAtPointer)
            WriteToFile(roStr_191, stringAtPointer)
	jmp .end_221
.else_221:

;.if_222:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_222
;then_222:

            WriteToFile(roStr_192)
            WriteToFile(roStr_193, [gsValue])
	jmp .end_222
.else_222:

;.if_223:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_223
;then_223:

            printf(roStr_194)
.end_223:

.end_222:

.end_221:

	jmp .end_220
.else_220:

;.if_224:
	mov r15, [gsType]
	cmp r15, [TYPE_UINT64]
	jne .else_224
;then_224:

;.if_225:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_225
;then_225:

            WriteToFile(roStr_195, stringAtPointer)
            WriteToFile(roStr_196, stringAtPointer)
	jmp .end_225
.else_225:

;.if_226:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_226
;then_226:

            WriteToFile(roStr_197)
            WriteToFile(roStr_198, [gsValue])
	jmp .end_226
.else_226:

;.if_227:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_227
;then_227:

            printf(roStr_199)
.end_227:

.end_226:

.end_225:

	jmp .end_224
.else_224:

;.if_228:
	mov r15, [gsType]
	cmp r15, [TYPE_POINTER]
	jne .else_228
;then_228:

;.if_229:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_229
;then_229:

;.if_230:
	mov r15, [pasIsDereference]
	cmp r15, 1
	jne .else_230
;then_230:

                WriteToFile(roStr_200, stringAtPointer, [gsSubType])
;.if_231:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_231
;then_231:

                    WriteToFile(roStr_201, stringAtPointer)
	jmp .end_231
.else_231:

;.if_232:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_232
;then_232:

                    WriteToFile(roStr_202, stringAtPointer)
	jmp .end_232
.else_232:

                    printf(roStr_203, [gsSubType])
                    ExitProcess(1)
.end_232:

.end_231:

	jmp .end_230
.else_230:

                WriteToFile(roStr_204, stringAtPointer)
                WriteToFile(roStr_205, stringAtPointer)
.end_230:

	jmp .end_229
.else_229:

;.if_233:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_233
;then_233:

            WriteToFile(roStr_206)
            WriteToFile(roStr_207, [gsValue])
	jmp .end_233
.else_233:

;.if_234:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .end_234
;then_234:

            printf(roStr_208)
.end_234:

.end_233:

.end_229:

	jmp .end_228
.else_228:

;.if_235:
	mov r15, [gsType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_235
;then_235:

;.if_236:
	mov r15, [pasIsDereference]
	cmp r15, 1
	jne .else_236
;then_236:

            WriteToFile(roStr_209, stringAtPointer)
            WriteToFile(roStr_210, stringAtPointer)
	jmp .end_236
.else_236:

            WriteToFile(roStr_211, stringAtPointer)
            WriteToFile(roStr_212, stringAtPointer)
.end_236:

	jmp .end_235
.else_235:

;.if_237:
	mov r15, [gsType]
	cmp r15, [TYPE_ARRAY]
	jne .else_237
;then_237:

;.if_238:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_238
;then_238:

;.if_239:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_239
;then_239:

                WriteToFile(roStr_213)
                WriteToFile(roStr_214)
	jmp .end_239
.else_239:

;.if_240:
	mov r15, [gsSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_240
;then_240:

                WriteToFile(roStr_215)
                WriteToFile(roStr_216)
	jmp .end_240
.else_240:

;.if_241:
	mov r15, [gsSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_241
;then_241:

                WriteToFile(roStr_217)
                WriteToFile(roStr_218)
	jmp .end_241
.else_241:

;.if_242:
	mov r15, [gsSubType]
	cmp r15, [TYPE_STRING]
	jne .else_242
;then_242:

                WriteToFile(roStr_219)
                WriteToFile(roStr_220)
	jmp .end_242
.else_242:
 
                printf(roStr_221, [gsType])
                ExitProcess(1)
.end_242:

.end_241:

.end_240:

.end_239:

	jmp .end_238
.else_238:

;.if_243:
	mov r15, [gsKind]
	cmp r15, [VAR_KIND_USER_DEFINED]
	jne .else_243
;then_243:

            WriteToFile(roStr_222)
            WriteToFile(roStr_223)
	jmp .end_243
.else_243:
 
            printf(roStr_224, [gsKind])
            ExitProcess(1)
.end_243:

.end_238:

	jmp .end_237
.else_237:

;.if_244:
	mov r15, [gsType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_244
;then_244:

        WriteToFile(roStr_225)
        WriteToFile(roStr_226)
	jmp .end_244
.else_244:

        printf(roStr_227, [gsType])
        ExitProcess(1)
.end_244:

.end_237:

.end_235:

.end_228:

.end_224:

.end_220:

    ;printf(roStr_228, stringAtPointer)
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

    ;printf(roStr_229)
    WriteToFile(roStr_230, [rbp + 16])
    
	call parseLogicalOrExpression
	push qword [TOKEN_THEN]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_231)
    WriteToFile(roStr_232, [rbp + 16], [rbp + 16])
    
	call parseStatements

;.if_245:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ELSE]
	jne .end_245
;then_245:
	push 1
	pop rax
	mov qword [rbp + 24], rax
	push qword [TOKEN_ELSE]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

        WriteToFile(roStr_233, [rbp + 16])
        WriteToFile(roStr_234, [rbp + 16], [rbp + 16])
        ;printf(roStr_235)
        
	call parseStatements

.end_245:
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [rbp + 24]
	pop rax
	mov qword [_], rax

;.if_246:
	mov r15, [_]
	cmp r15, 1
	jne .else_246
;then_246:

        WriteToFile(roStr_236, [rbp + 16])
	jmp .end_246
.else_246:

        WriteToFile(roStr_237, [rbp + 16])
.end_246:

    ;printf(roStr_238)
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

    ;printf(roStr_239)
    WriteToFile(roStr_240, [rbp + 16])
    
	call parseLogicalOrExpression
	push qword [TOKEN_DO]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_241)
    WriteToFile(roStr_242, [rbp + 16], [rbp + 16])
    
	call parseStatements
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    ;printf(roStr_243)
    WriteToFile(roStr_244, [rbp + 16])
    WriteToFile(roStr_245, [rbp + 16])
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

.while_247:
	mov r15, [pbsIndex]
	cmp r15, 0
	jl .end_247
;do_247:
	mov rax, [pbsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pbsCurrentToken], rax

;.if_248:
	mov r15, [pbsCurrentToken]
	cmp r15, [TOKEN_WHILE]
	jne .end_248
;then_248:
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

            WriteToFile(roStr_246)
            WriteToFile(roStr_247, [pbsBlockId])
    jmp .end_247

.end_248:
	push qword [pbsIndex]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pbsIndex], rax

    jmp .while_247
    ; end while_247
.end_247:

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

.while_249:
	mov r15, [pcsIndex]
	cmp r15, 0
	jl .end_249
;do_249:
	mov rax, [pcsIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [pcsCurrentToken], rax

;.if_250:
	mov r15, [pcsCurrentToken]
	cmp r15, [TOKEN_WHILE]
	jne .end_250
;then_250:
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

            WriteToFile(roStr_248)
            WriteToFile(roStr_249, [pcsBlockId])
    jmp .end_249

.end_250:
	push qword [pcsIndex]
	push qword [tokenSize]
	pop rcx
	pop rax
	sub rax, rcx
	push rax
	pop rax
	mov qword [pcsIndex], rax

    jmp .while_249
    ; end while_249
.end_249:

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

.while_251:
	mov r15, [true]
	cmp r15, 1
	jne .end_251
;do_251:

;.if_252:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .else_252
;then_252:
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

	jmp .end_252
.else_252:

    jmp .end_251

.end_252:

    jmp .while_251
    ; end while_251
.end_251:

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

;.if_253:
	mov r15, [globalBoolParsingProcedure]
	cmp r15, 1
	jne .end_253
;then_253:
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
 
        printf(roStr_250, [errorAtLine], [errorAtColumn])
        printf(roStr_251)
        ExitProcess(1)
.end_253:
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

;.if_254:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_254
;then_254:

;.if_255:
	mov r15, [gsType]
	cmp r15, [TYPE_PROCEDURE_FWD]
	je .end_255
;then_255:
	push qword [ppdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_255:

.end_254:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [paProArgumentCount], rax

;.if_256:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_256
;then_256:
	push 16
	pop rax
	mov qword [ppdRbpOffset], rax

	call parseArguments

.end_256:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [ppdHasReturnValue], rax

;.if_257:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ARROW_RIGHT]
	jne .end_257
;then_257:
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

.end_257:

;.if_258:
	mov r15, [currentToken]
	cmp r15, [TOKEN_SEMICOLON]
	jne .else_258
;then_258:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [paProArgumentCount]
	push qword [ppdIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [gvType]
	push qword [TYPE_PROCEDURE_FWD]

	call addSymbol
	mov [_], rax
	add rsp, 48

	jmp .end_258
.else_258:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [paProArgumentCount]
	push qword [ppdIdentifier]
	push qword [VAR_KIND_USER_DEFINED]
	push qword [gvType]
	push qword [TYPE_PROCEDURE]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push 1
	pop rax
	mov qword [globalBoolParsingProcedure], rax
	push 8
	pop rax
	mov qword [ppdRbpOffset], rax
	push 0
	pop rax
	mov qword [ppdLocalVariableCount], rax

;.if_259:
	mov r15, [currentToken]
	cmp r15, [TOKEN_VARS]
	jne .end_259
;then_259:
	push qword [TOKEN_VARS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.while_260:
	mov r15, [true]
	cmp r15, 1
	jne .end_260
;do_260:

	call parseVariableDeclaration

;.if_261:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CODE]
	jne .end_261
;then_261:

    jmp .end_260

.end_261:

    jmp .while_260
    ; end while_260
.end_260:

.end_259:
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

        ;printf(roStr_252, stringAtPointer)
        WriteToFile(roStr_253, stringAtPointer)
        WriteToFile(roStr_254, stringAtPointer, stringAtPointer)
        WriteToFile(roStr_255)
        WriteToFile(roStr_256, [ppdLocalVariableCount])
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

;.if_262:
	mov r15, [ppdReturnStatementCount]
	cmp r15, 0
	jne .end_262
;then_262:

;.if_263:
	mov r15, [ppdHasReturnValue]
	cmp r15, 1
	jne .end_263
;then_263:
	push qword [ppdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

                printf(roStr_257, stringAtPointer)
                ExitProcess(1)
.end_263:

            WriteToFile(roStr_258)
.end_262:
	push qword [ppdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        ;printf(roStr_259, stringAtPointer, [paProArgumentCount])
        WriteToFile(roStr_260, stringAtPointer)
        WriteToFile(roStr_261, stringAtPointer)
.end_258:

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

;.if_264:
	mov r15, [currentToken]
	cmp r15, [TOKEN_SEMICOLON]
	je .end_264
;then_264:
	push 0
	pop rax
	mov qword [prsIsEmptyResult], rax

	call parseLogicalOrExpression

.end_264:
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

    WriteToFile(roStr_262)
    
;.if_265:
	mov r15, [prsIsEmptyResult]
	cmp r15, 0
	jne .else_265
;then_265:

        ; has result
        WriteToFile(roStr_263)
	jmp .end_265
.else_265:

        ; no result
        WriteToFile(roStr_264)
.end_265:

	mov rsp, rbp
	pop rbp
	ret
parseReturnStatement_end:

section .data
	pcsaIdentifier dq 0
section .text

section .data
	pcsaIndex dq 0
section .text

	jmp parseConstantStringArgument_end
parseConstantStringArgument:
	push rbp
	mov rbp, rsp
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
	mov qword [pcsaIdentifier], rax
	push qword [TOKEN_CONSTANT_STRING]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [pcsaIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

    WriteToFile(roStr_265, [pcsaIndex])
    	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [pcsaIdentifier]
	push qword 0
	push qword [VAR_KIND_PRIMITIVE]
	push qword [pcsaIndex]
	push qword [TYPE_STRING]

	call addVariable
	mov [_], rax
	add rsp, 48
	push qword [pcsaIndex]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [pcsaIndex], rax

	mov rsp, rbp
	pop rbp
	ret
parseConstantStringArgument_end:

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

section .data
	ppcIsProcOrFwdProc dq 0
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

    ;printf(roStr_266, stringAtPointer)
    
;.if_266:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_266
;then_266:
	push qword [ppcIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_266:
	push 0
	pop rax
	mov qword [ppcIsProcOrFwdProc], rax

;.if_267:
	mov r15, [gsType]
	cmp r15, [TYPE_PROCEDURE_FWD]
	jne .else_267
;then_267:
	push 1
	pop rax
	mov qword [ppcIsProcOrFwdProc], rax

	jmp .end_267
.else_267:

;.if_268:
	mov r15, [gsType]
	cmp r15, [TYPE_PROCEDURE]
	jne .end_268
;then_268:
	push 1
	pop rax
	mov qword [ppcIsProcOrFwdProc], rax

.end_268:

.end_267:

;.if_269:
	mov r15, [ppcIsProcOrFwdProc]
	cmp r15, 1
	jne .else_269
;then_269:
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

;.if_270:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_270
;then_270:

            WriteToFile(roStr_267)
            WriteToFile(roStr_268, [ppcShadowSpace])
.end_270:
	push 0
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax

.while_271:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_271
;do_271:

;.if_272:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_STRING]
	jne .else_272
;then_272:

	call parseConstantStringArgument

                WriteToFile(roStr_269, [ppdRbpOffset])
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

;.if_273:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_273
;then_273:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_273:

	jmp .end_272
.else_272:

	call parseLogicalOrExpression

                WriteToFile(roStr_270, [ppdRbpOffset])
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

;.if_274:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_274
;then_274:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_274:

.end_272:

    jmp .while_271
    ; end while_271
.end_271:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_275:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, [ppcPrcCallArgumentCount]
	je .end_275
;then_275:
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
 
            printf(roStr_271, [errorAtLine], [errorAtColumn])
            printf(roStr_272, [ppcPrcArgumentCount], [ppcPrcCallArgumentCount])
            ExitProcess(1)
.end_275:
	push qword [ppcIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_276:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, 0
	je .else_276
;then_276:

            WriteToFile(roStr_273, stringAtPointer, [ppcShadowSpace])
	jmp .end_276
.else_276:

            WriteToFile(roStr_274, stringAtPointer, [ppcShadowSpace])
.end_276:

        WriteToFile(roStr_275, stringAtPointer, [ppcPrcArgumentCount])
	jmp .end_269
.else_269:

;.if_277:
	mov r15, [gsType]
	cmp r15, [TYPE_EXTERNAL_PROCEDURE]
	jne .else_277
;then_277:
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

;.if_278:
	mov r15, [ppcShadowSpace]
	cmp r15, 32
	jge .end_278
;then_278:
	push 32
	pop rax
	mov qword [ppcShadowSpace], rax

.end_278:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

        WriteToFile(roStr_276)
        WriteToFile(roStr_277, [ppcShadowSpace])
        	push 0
	pop rax
	mov qword [ppcPrcCallArgumentCount], rax
	push 8
	pop rax
	mov qword [ppdRbpOffset], rax

.while_279:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_279
;do_279:

;.if_280:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONSTANT_STRING]
	jne .else_280
;then_280:

	call parseConstantStringArgument
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

;.if_281:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_281
;then_281:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_281:

	jmp .end_280
.else_280:

	call parseLogicalOrExpression

                ;WriteToFile(roStr_278, [ppdRbpOffset])
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

;.if_282:
	mov r15, [currentToken]
	cmp r15, [TOKEN_COMMA]
	jne .end_282
;then_282:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

.end_282:

.end_280:

    jmp .while_279
    ; end while_279
.end_279:
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

.while_283:
	mov r15, [ppcIndex]
	cmp r15, 0
	jl .end_283
;do_283:

;.if_284:
	mov r15, [ppcIndex]
	cmp r15, 4
	jle .else_284
;then_284:

                WriteToFile(roStr_279, [ppdRbpOffset])
	jmp .end_284
.else_284:

;.if_285:
	mov r15, [ppcIndex]
	cmp r15, 4
	jne .else_285
;then_285:

                WriteToFile(roStr_280, [ppdRbpOffset])
	jmp .end_285
.else_285:

;.if_286:
	mov r15, [ppcIndex]
	cmp r15, 3
	jne .else_286
;then_286:

                WriteToFile(roStr_281, [ppdRbpOffset])
	jmp .end_286
.else_286:

;.if_287:
	mov r15, [ppcIndex]
	cmp r15, 2
	jne .else_287
;then_287:

                WriteToFile(roStr_282, [ppdRbpOffset])
	jmp .end_287
.else_287:

;.if_288:
	mov r15, [ppcIndex]
	cmp r15, 1
	jne .end_288
;then_288:

                WriteToFile(roStr_283, [ppdRbpOffset])
.end_288:

.end_287:

.end_286:

.end_285:

.end_284:
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

    jmp .while_283
    ; end while_283
.end_283:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_289:
	mov r15, [ppcPrcArgumentCount]
	cmp r15, [ppcPrcCallArgumentCount]
	je .end_289
;then_289:
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
 
            printf(roStr_284, [errorAtLine], [errorAtColumn])
            printf(roStr_285, [ppcPrcArgumentCount], [ppcPrcCallArgumentCount])
            ExitProcess(1)
.end_289:
	push qword [ppcIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_286, stringAtPointer, [ppcCallCounter])
        WriteToFile(roStr_287, stringAtPointer, [ppcShadowSpace])
        WriteToFile(roStr_288, stringAtPointer, [ppcPrcArgumentCount])
	jmp .end_277
.else_277:

        printf(roStr_289)
        ExitProcess(1)
.end_277:

.end_269:

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

.while_290:
	mov r15, [true]
	cmp r15, 1
	jne .end_290
;do_290:

;.if_291:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_291
;then_291:
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
 
            printf(roStr_290, [errorAtLine], [errorAtColumn])
            printf(roStr_291)
            ExitProcess(1)
	jmp .end_291
.else_291:

;.if_292:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_292
;then_292:

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

	jmp .end_292
.else_292:

;.if_293:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_293
;then_293:

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

	jmp .end_293
.else_293:

    jmp .end_290

.end_293:

.end_292:

.end_291:

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

        ;printf(roStr_292, stringAtPointer, [psbType])
    jmp .while_290
    ; end while_290
.end_290:

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

;.if_294:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_294
;then_294:
	push qword [psdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_294:

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

    ;printf(roStr_293, stringAtPointer, [psbSizeOfStruct])
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

section .data
	putvdDefineIdentifier dq 0
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

;.if_295:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_295
;then_295:
	push qword [putvdTypeIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_295:
	push qword [gsSubType]
	pop rax
	mov qword [putvdTypeIdentifier], rax

;.if_296:
	mov r15, [currentToken]
	cmp r15, [TOKEN_LEFT_BRACKET]
	jne .else_296
;then_296:
	push qword [TOKEN_LEFT_BRACKET]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_297:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_297
;then_297:

	call parseIdentifier
	mov [putvdDefineIdentifier], rax
	add rsp, 0
	push qword [putvdDefineIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_298:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_298
;then_298:
	push qword [putvdDefineIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_298:

;.if_299:
	mov r15, [gsType]
	cmp r15, [TYPE_DEFINE]
	je .end_299
;then_299:

                printf(roStr_294)
                ExitProcess(1)
.end_299:
	push qword [gsValue]
	pop rax
	mov qword [gvValue], rax

	jmp .end_297
.else_297:

	call parseNumber
	mov [gvValue], rax
	add rsp, 0

.end_297:
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

;.if_300:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_300
;then_300:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_300:
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

        ;printf(roStr_295, stringAtPointer)
	jmp .end_296
.else_296:

;.if_301:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_301
;then_301:
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

;.if_302:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_302
;then_302:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_302:
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

	jmp .end_301
.else_301:

	call parseIdentifier
	mov [putvdIdentifier], rax
	add rsp, 0
	push qword [putvdIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_303:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_303
;then_303:
	push qword [putvdIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_303:
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

        ;printf(roStr_296, stringAtPointer)
.end_301:

.end_296:

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

;.if_304:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_304
;then_304:
	push qword [pedIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_304:
	push qword [TOKEN_LEFT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push 0
	pop rax
	mov qword [paProArgumentCount], rax

;.if_305:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RIGHT_PARENTHESIS]
	je .end_305
;then_305:
	push 16
	pop rax
	mov qword [ppdRbpOffset], rax

	call parseArguments

.end_305:
	push qword [TOKEN_RIGHT_PARENTHESIS]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

;.if_306:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ARROW_RIGHT]
	jne .end_306
;then_306:
	push qword [TOKEN_ARROW_RIGHT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseType
	mov [gvType], rax
	add rsp, 0

.end_306:
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

    WriteToFile(roStr_297, stringAtPointer)
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

    WriteToFile(roStr_298)
    WriteToFile(roStr_299, [pesNumber])
    WriteToFile(roStr_300)
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
	pisIdentifier dq 0
section .text

	jmp parseIncrementStatement_end
parseIncrementStatement:
	push rbp
	mov rbp, rsp

	call parseIdentifier
	mov [pisIdentifier], rax
	add rsp, 0
	push qword [pisIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_307:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_307
;then_307:
	push qword [pisIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_307:
	push qword [TOKEN_INCREMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [pisIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_308:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_308
;then_308:

        WriteToFile(roStr_301, stringAtPointer)
        WriteToFile(roStr_302, stringAtPointer, stringAtPointer)
	jmp .end_308
.else_308:

;.if_309:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .else_309
;then_309:

            printf(roStr_303, [stringAtPointer])
	jmp .end_309
.else_309:

;.if_310:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_310
;then_310:
 
            WriteToFile(roStr_304, stringAtPointer)
            WriteToFile(roStr_305, [gsValue])
	jmp .end_310
.else_310:
 
            printf(roStr_306, [gsType])
            ExitProcess(1)
.end_310:

.end_309:

.end_308:

	mov rsp, rbp
	pop rbp
	ret
parseIncrementStatement_end:

section .data
	pdsIdentifier dq 0
section .text

	jmp parseDecrementStatement_end
parseDecrementStatement:
	push rbp
	mov rbp, rsp

	call parseIdentifier
	mov [pdsIdentifier], rax
	add rsp, 0
	push qword [pdsIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_311:
	mov r15, [fgsIndex]
	cmp r15, -1
	jne .end_311
;then_311:
	push qword [pdsIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_311:
	push qword [TOKEN_DECREMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [TOKEN_SEMICOLON]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [pisIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

;.if_312:
	mov r15, [gsScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	jne .else_312
;then_312:

        WriteToFile(roStr_307, stringAtPointer)
        WriteToFile(roStr_308, stringAtPointer, stringAtPointer)
	jmp .end_312
.else_312:

;.if_313:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_PARAMETER]
	jne .else_313
;then_313:

            printf(roStr_309, [stringAtPointer])
	jmp .end_313
.else_313:

;.if_314:
	mov r15, [gsSubType]
	cmp r15, [VARTYPE_LOCAL]
	jne .else_314
;then_314:
 
            WriteToFile(roStr_310, stringAtPointer)
            WriteToFile(roStr_311, [gsValue])
	jmp .end_314
.else_314:
 
            printf(roStr_312, [gsType])
            ExitProcess(1)
.end_314:

.end_313:

.end_312:

	mov rsp, rbp
	pop rbp
	ret
parseDecrementStatement_end:

section .data
	penumIdentifier dq 0
section .text

section .data
	penumValue dq 0
section .text

	jmp parseEnumDefinition_end
parseEnumDefinition:
	push rbp
	mov rbp, rsp
	push 0
	pop rax
	mov qword [penumValue], rax
	push qword [TOKEN_ENUM]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseIdentifier
	mov [_], rax
	add rsp, 0

.while_315:
	mov r15, [currentToken]
	cmp r15, [TOKEN_END]
	je .end_315
;do_315:

	call parseIdentifier
	mov [penumIdentifier], rax
	add rsp, 0
	push qword [penumIdentifier]

	call findSymbol
	mov [fgsIndex], rax
	add rsp, 8

;.if_316:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .end_316
;then_316:
	push qword [penumIdentifier]

	call indentifierRedeclared
	mov [_], rax
	add rsp, 8

.end_316:

;.if_317:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ASSIGNMENT]
	jne .end_317
;then_317:
	push qword [TOKEN_ASSIGNMENT]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	call parseNumber
	mov [penumValue], rax
	add rsp, 0

.end_317:

;.if_318:
	mov r15, [currentToken]
	cmp r15, [TOKEN_END]
	jne .end_318
;then_318:
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [penumValue]
	push qword [penumIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword 0
	push qword [TYPE_DEFINE]

	call addSymbol
	mov [_], rax
	add rsp, 48

    jmp .end_315

.end_318:
	push qword [TOKEN_COMMA]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken
	push qword [VARIABLE_SCOPE_GLOBAL]
	push qword [penumValue]
	push qword [penumIdentifier]
	push qword [VAR_KIND_PRIMITIVE]
	push qword 0
	push qword [TYPE_DEFINE]

	call addSymbol
	mov [_], rax
	add rsp, 48
	push qword [penumValue]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [penumValue], rax

    jmp .while_315
    ; end while_315
.end_315:
	push qword [TOKEN_END]
	pop rax
	mov qword [expectedToken], rax

	call consumeToken

	mov rsp, rbp
	pop rbp
	ret
parseEnumDefinition_end:

section .data
	psIdentifier dq 0
section .text

	jmp parseStatement_end
parseStatement:
	push rbp
	mov rbp, rsp

;.if_319:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT8]
	jne .else_319
;then_319:

	call parseVariableDeclaration

	jmp .end_319
.else_319:

;.if_320:
	mov r15, [currentToken]
	cmp r15, [TOKEN_UINT64]
	jne .else_320
;then_320:

	call parseVariableDeclaration

	jmp .end_320
.else_320:

;.if_321:
	mov r15, [currentToken]
	cmp r15, [TOKEN_POINTER]
	jne .else_321
;then_321:

	call parseVariableDeclaration

	jmp .end_321
.else_321:

;.if_322:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IDENTIFIER]
	jne .else_322
;then_322:
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

;.if_323:
	mov r15, [fgsIndex]
	cmp r15, -1
	je .else_323
;then_323:

;.if_324:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DOT]
	jne .else_324
;then_324:

	call parseAssignmentStatement

	jmp .end_324
.else_324:

;.if_325:
	mov r15, [nextToken]
	cmp r15, [TOKEN_INCREMENT]
	jne .else_325
;then_325:

	call parseIncrementStatement

	jmp .end_325
.else_325:

;.if_326:
	mov r15, [nextToken]
	cmp r15, [TOKEN_DECREMENT]
	jne .else_326
;then_326:

	call parseDecrementStatement

	jmp .end_326
.else_326:

;.if_327:
	mov r15, [gsType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_327
;then_327:

	call parseUserTypeVariableDeclaration

	jmp .end_327
.else_327:

;.if_328:
	mov r15, [nextToken]
	cmp r15, [TOKEN_LEFT_PARENTHESIS]
	jne .else_328
;then_328:

	call parseProcedureCallStatement

	jmp .end_328
.else_328:

	call parseAssignmentStatement

.end_328:

.end_327:

.end_326:

.end_325:

.end_324:

	jmp .end_323
.else_323:
	push qword [psIdentifier]

	call identifierUnknown
	mov [_], rax
	add rsp, 8

.end_323:

	jmp .end_322
.else_322:

;.if_329:
	mov r15, [currentToken]
	cmp r15, [TOKEN_IF]
	jne .else_329
;then_329:
	push qword 0
	push qword 0
	push qword [globalBlockId]

	call parseIfStatement
	mov [_], rax
	add rsp, 24

	jmp .end_329
.else_329:

;.if_330:
	mov r15, [currentToken]
	cmp r15, [TOKEN_WHILE]
	jne .else_330
;then_330:
	push qword [globalBlockId]

	call parseWhileStatement
	mov [_], rax
	add rsp, 8

	jmp .end_330
.else_330:

;.if_331:
	mov r15, [currentToken]
	cmp r15, [TOKEN_BREAK]
	jne .else_331
;then_331:

	call parseBreakStatement

	jmp .end_331
.else_331:

;.if_332:
	mov r15, [currentToken]
	cmp r15, [TOKEN_CONTINUE]
	jne .else_332
;then_332:

	call parseContinueStatement

	jmp .end_332
.else_332:

;.if_333:
	mov r15, [currentToken]
	cmp r15, [TOKEN_PROC]
	jne .else_333
;then_333:

	call parseProcedureDeclaration

	jmp .end_333
.else_333:

;.if_334:
	mov r15, [currentToken]
	cmp r15, [TOKEN_RETURN]
	jne .else_334
;then_334:

	call parseReturnStatement

	jmp .end_334
.else_334:

;.if_335:
	mov r15, [currentToken]
	cmp r15, [TOKEN_STRUCT]
	jne .else_335
;then_335:

	call parseStructDefinition

	jmp .end_335
.else_335:

;.if_336:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ENUM]
	jne .else_336
;then_336:

	call parseEnumDefinition

	jmp .end_336
.else_336:

;.if_337:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EXTERN]
	jne .else_337
;then_337:

	call parseExternDeclaration

	jmp .end_337
.else_337:

;.if_338:
	mov r15, [currentToken]
	cmp r15, [TOKEN_EXIT]
	jne .else_338
;then_338:

	call parseExitStatement

	jmp .end_338
.else_338:

;.if_339:
	mov r15, [currentToken]
	cmp r15, [TOKEN_AT_SIGN]
	jne .else_339
;then_339:

	call parsePreprocessorDirective

	jmp .end_339
.else_339:

;.if_340:
	mov r15, [currentToken]
	cmp r15, [TOKEN_MULTIPLY]
	jne .else_340
;then_340:

	call parseAssignmentStatement

	jmp .end_340
.else_340:

	call unexpectedToken

.end_340:

.end_339:

.end_338:

.end_337:

.end_336:

.end_335:

.end_334:

.end_333:

.end_332:

.end_331:

.end_330:

.end_329:

.end_322:

.end_321:

.end_320:

.end_319:

	mov rsp, rbp
	pop rbp
	ret
parseStatement_end:

	jmp parseStatements_end
parseStatements:
	push rbp
	mov rbp, rsp

.while_341:
	mov r15, [true]
	cmp r15, 1
	jne .end_341
;do_341:

;.if_342:
	mov r15, [currentToken]
	cmp r15, [TOKEN_END]
	jne .else_342
;then_342:

    jmp .end_341

	jmp .end_342
.else_342:

;.if_343:
	mov r15, [currentToken]
	cmp r15, [TOKEN_ELSE]
	jne .else_343
;then_343:

    jmp .end_341

	jmp .end_343
.else_343:

	call parseStatement

.end_343:

.end_342:

    jmp .while_341
    ; end while_341
.end_341:

	mov rsp, rbp
	pop rbp
	ret
parseStatements_end:
	push 0
	pop rax
	mov qword [i], rax

.while_344:
	mov r15, [i]
	cmp r15, [tokenCount]
	jge .end_344
;do_344:
	mov rax, [i]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [currentToken], rax

	call parseStatement

    jmp .while_344
    ; end while_344
.end_344:
	push 0
	pop rax
	mov qword [i], rax

WriteToFile(roStr_313)
WriteToFile(roStr_314)
WriteToFile(roStr_315)
WriteToFile(roStr_316)
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

.while_345:
	movzx r15, byte [esChar]
	cmp r15, 0
	jle .end_345
;do_345:

;.if_346:
	movzx r15, byte [esChar]
	cmp r15, 32
	jl .else_346
;then_346:
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

	jmp .end_346
.else_346:
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

;.if_347:
	movzx r15, byte [esChar]
	cmp r15, 13
	jne .else_347
;then_347:
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

	jmp .end_347
.else_347:

;.if_348:
	movzx r15, byte [esChar]
	cmp r15, 10
	jne .else_348
;then_348:
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

	jmp .end_348
.else_348:

;.if_349:
	movzx r15, byte [esChar]
	cmp r15, 9
	jne .end_349
;then_349:
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

.end_349:

.end_348:

.end_347:
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

.end_346:
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

    jmp .while_345
    ; end while_345
.end_345:
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

.while_350:
	mov r15, [i]
	cmp r15, [globalVariableCount]
	jge .end_350
;do_350:
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

;.if_351:
	mov r15, [gvScope]
	cmp r15, [VARIABLE_SCOPE_GLOBAL]
	je .end_351
;then_351:
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax

    jmp .while_350

.end_351:
	push qword [gvNamePointer]

	call readString
	mov [_], rax
	add rsp, 8

;.if_352:
	mov r15, [gvType]
	cmp r15, [TYPE_UINT8]
	jne .else_352
;then_352:

        WriteToFile(roStr_317, stringAtPointer, [gvValue])
	jmp .end_352
.else_352:

;.if_353:
	mov r15, [gvType]
	cmp r15, [TYPE_UINT64]
	jne .else_353
;then_353:

        WriteToFile(roStr_318, stringAtPointer, [gvValue])
	jmp .end_353
.else_353:

;.if_354:
	mov r15, [gvType]
	cmp r15, [TYPE_POINTER]
	jne .else_354
;then_354:

        WriteToFile(roStr_319, stringAtPointer, [gvValue])
	jmp .end_354
.else_354:

;.if_355:
	mov r15, [gvType]
	cmp r15, [TYPE_STRUCT_POINTER]
	jne .else_355
;then_355:

        WriteToFile(roStr_320, stringAtPointer)
	jmp .end_355
.else_355:

;.if_356:
	mov r15, [gvType]
	cmp r15, [TYPE_ARRAY]
	jne .else_356
;then_356:

;.if_357:
	mov r15, [gvKind]
	cmp r15, [VAR_KIND_PRIMITIVE]
	jne .else_357
;then_357:

;.if_358:
	mov r15, [gvSubType]
	cmp r15, [TYPE_UINT8]
	jne .else_358
;then_358:

                WriteToFile(roStr_321, stringAtPointer, [gvValue])
	jmp .end_358
.else_358:

;.if_359:
	mov r15, [gvSubType]
	cmp r15, [TYPE_UINT64]
	jne .else_359
;then_359:

                WriteToFile(roStr_322, stringAtPointer, [gvValue])
	jmp .end_359
.else_359:

;.if_360:
	mov r15, [gvSubType]
	cmp r15, [TYPE_POINTER]
	jne .else_360
;then_360:

                WriteToFile(roStr_323, stringAtPointer, [gvValue])
	jmp .end_360
.else_360:

;.if_361:
	mov r15, [gvSubType]
	cmp r15, [TYPE_STRING]
	jne .else_361
;then_361:

                WriteToFile(roStr_324, stringAtPointer)
                	push qword [gvValue]

	call readString
	mov [_], rax
	add rsp, 8

	call encodeString

                WriteToFile(roStr_325, encodedString)
	jmp .end_361
.else_361:

                printf(roStr_326, [gvType])
                ExitProcess(1)
.end_361:

.end_360:

.end_359:

.end_358:

	jmp .end_357
.else_357:
	push qword [gvNamePointer]
	pop rax
	mov qword [wsdIdentifier], rax
	push qword [gvSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_362:
	mov r15, [_]
	cmp r15, -1
	jne .end_362
;then_362:

                printf(roStr_327, [gvSubType])
                ExitProcess(1)
.end_362:
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

            WriteToFile(roStr_328, stringAtPointer, [gvValue])
.end_357:

	jmp .end_356
.else_356:

;.if_363:
	mov r15, [gvType]
	cmp r15, [TYPE_STRING]
	jne .else_363
;then_363:

        WriteToFile(roStr_329, [gvSubType])
        	push qword [gvValue]

	call readString
	mov [_], rax
	add rsp, 8

	call encodeString

        WriteToFile(roStr_330, encodedString)
	jmp .end_363
.else_363:

;.if_364:
	mov r15, [gvType]
	cmp r15, [TYPE_USER_DEFINED]
	jne .else_364
;then_364:
	push qword [gvNamePointer]
	pop rax
	mov qword [wsdIdentifier], rax
	push qword [gvSubType]

	call findUserType
	mov [_], rax
	add rsp, 8

;.if_365:
	mov r15, [_]
	cmp r15, -1
	jne .end_365
;then_365:

            printf(roStr_331, [gvSubType])
            ExitProcess(1)
.end_365:
	push qword [wsdIdentifier]

	call readString
	mov [_], rax
	add rsp, 8

        WriteToFile(roStr_332, stringAtPointer, [gsValue])
	jmp .end_364
.else_364:

        printf(roStr_333, [gvType])
        ExitProcess(1)
.end_364:

.end_363:

.end_356:

.end_355:

.end_354:

.end_353:

.end_352:
	push qword [i]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [i], rax

    jmp .while_350
    ; end while_350
.end_350:

	call CloseOutputFile

section .bss
    lpStartupInfo: resb 104
    lpProcessInformation: resb 24
    lpExitCode: resq 1

section .text    
    extern CreateProcessA
    extern WaitForSingleObject
    extern GetExitCodeProcess

    sprintf(buffer1, roStr_334, cStrOutputFile, cStrObjectFile)
    printf(roStr_335, buffer1)

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
;.if_366:
    cmp rax, 0
	jne .end_366
;then_366:

        printf(roStr_336)
        ExitProcess(1)
.end_366:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_337, [lpExitCode])
    mov rax, [lpExitCode]
    
;.if_367:
    cmp rax, 0
	je .end_367
;then_367:

        printf(roStr_338)
        ExitProcess(1)
.end_367:


    sprintf(buffer1, roStr_339, cStrObjectFile, cStrLinkerFile)
    printf(roStr_340, buffer1)
    
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
;.if_368:
    cmp rax, 0
	jne .end_368
;then_368:

        printf(roStr_341)
        ExitProcess(1)
.end_368:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
;.if_369:
    cmp rax, 0
	je .end_369
;then_369:

        printf(roStr_342)
        ExitProcess(1)
.end_369:


    printf(roStr_343, cStrLinkerFile)

    ExitProcess(0)
section .rodata
    roStr_343 db "[\#27[92mINFO\#27[0m] Generated %s\r\n", 0
    roStr_342 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_341 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_340 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_339 db "ld -e _start %s -o %s -lkernel32 -Llib", 0
    roStr_338 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_337 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_336 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_335 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_334 db "nasm.exe -f win64 %s -o %s -w+all -w+error", 0
    roStr_333 db "Error: unknown type %d in 'writeVars'", 0
    roStr_332 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_331 db "Error: unknown user type %d\n", 0
    roStr_330 db " db %s,0\n", 0
    roStr_329 db "section .rodata\r\n\tro_str_%d", 0
    roStr_328 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_327 db "Error: unknown user type %d\n", 0
    roStr_326 db "Error: unknown array type %d\n", 0
    roStr_325 db " db %s,0\n", 0
    roStr_324 db "section .data\r\n\t%s", 0
    roStr_323 db "section .bss\r\n\t%s resq %d\n", 0
    roStr_322 db "section .bss\r\n\t%s resq %d\n", 0
    roStr_321 db "section .bss\r\n\t%s resb %d\n", 0
    roStr_320 db "section .bss\r\n\t%s resq 1\n", 0
    roStr_319 db "section .data\r\n\t%s dq %d\n", 0
    roStr_318 db "section .data\r\n\t%s dq %d\n", 0
    roStr_317 db "section .data\r\n\t%s db %d\n", 0
    roStr_316 db ";==== global variables ====\n", 0
    roStr_315 db "\tcall ExitProcess\n\n", 0
    roStr_314 db "\tmov rcx, 0\n", 0
    roStr_313 db "; -- exit process -- \n", 0
    roStr_312 db "[Error] Error: unknown subtype %d 'parseDecrementStatement'\n", 0
    roStr_311 db "\tdec qword [rbp - %d]\n", 0
    roStr_310 db "; -- increment local '%s' -- \n", 0
    roStr_309 db "[Error] Error: cannot decrement parameter '%s'\n", 0
    roStr_308 db "\tmov rax, [%s]\n\tdec rax\n\tmov [%s], rax\n\n", 0
    roStr_307 db "; -- decrement '%s' -- \n", 0
    roStr_306 db "[Error] Error: unknown subtype %d 'parseIncrementStatement'\n", 0
    roStr_305 db "\tinc qword [rbp - %d]\n", 0
    roStr_304 db "; -- increment local '%s' -- \n", 0
    roStr_303 db "[Error] Error: cannot increment parameter '%s'\n", 0
    roStr_302 db "\tmov rax, [%s]\n\tinc rax\n\tmov [%s], rax\n\n", 0
    roStr_301 db "; -- increment '%s' -- \n", 0
    roStr_300 db "\tcall ExitProcess\n\n", 0
    roStr_299 db "\tmov rcx, %d\n", 0
    roStr_298 db "; -- exit process -- \n", 0
    roStr_297 db "section .text\n\textern %s\n", 0
    roStr_296 db "[Trace] Variable definition for user type: %s\n", 0
    roStr_295 db "[Trace] Variable definition for user type array: %s\n", 0
    roStr_294 db "Error: expected a define identifier\n", 0
    roStr_293 db "[Trace] Struct definition: %s with %d bytes\n", 0
    roStr_292 db "[Trace] Struct field: %s of type %d\n", 0
    roStr_291 db "valid struct member types are 'uint64' and 'pointer'\n", 0
    roStr_290 db "parser.strata:%d:%d: ", 0
    roStr_289 db "NOT A PROCEDURE\n", 0
    roStr_288 db "; external procedure call: %s with %d arguments\n\n", 0
    roStr_287 db "\tmov rsp, r15\n\tpop r15\n\tcall %s\n\tadd rsp, %d\n", 0
    roStr_286 db "external_%s_%d:\n", 0
    roStr_285 db "external procedure requires %d arguments, but %d arguments are provided\n", 0
    roStr_284 db "parser.strata:%d:%d: ", 0
    roStr_283 db "\tpop rcx\n", 0
    roStr_282 db "\tpop rdx\n", 0
    roStr_281 db "\tpop r8\n", 0
    roStr_280 db "\tpop r9\n", 0
    roStr_279 db "\tpop qword [r15 + %d]\n", 0
    roStr_278 db "\tpop qword [r15 + %d]\n", 0
    roStr_277 db "\tsub rsp, %d\n\tpush r15\n\tmov r15, rsp\n", 0
    roStr_276 db "; -- external procedure call --\n", 0
    roStr_275 db "; procedure call: %s with %d arguments\n\n", 0
    roStr_274 db "\tcall %s\n\tadd rsp, %d\n", 0
    roStr_273 db "\tmov rsp, r15\n\tpop r15\n\tcall %s\n\tadd rsp, %d\n", 0
    roStr_272 db "procedure requires %d arguments, but %d arguments are provided\n", 0
    roStr_271 db "parser.strata:%d:%d: ", 0
    roStr_270 db "\tpop qword [r15 + %d]\n", 0
    roStr_269 db "\tpop qword [r15 + %d]\n", 0
    roStr_268 db "\tsub rsp, %d\n\tpush r15\n\tmov r15, rsp\n", 0
    roStr_267 db "; -- procedure call --\n", 0
    roStr_266 db "[Trace] Procedure call: %s\n", 0
    roStr_265 db "\tmov rax, ro_str_%d\n\tpush rax\n", 0
    roStr_264 db "\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_263 db "\tpop rax\n\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_262 db "; -- return --\n", 0
    roStr_261 db ";==== end proc %s ====\n\n", 0
    roStr_260 db "\tret\n%s_end:\n", 0
    roStr_259 db "[Trace] Procedure declaration: %s with %d parameters\n", 0
    roStr_258 db "\tmov rsp, rbp\n\tpop rbp\n\tret\n", 0
    roStr_257 db "Error: procedure %s has no return statement\n", 0
    roStr_256 db "\tsub rsp, %d\n\n", 0
    roStr_255 db "\tpush rbp\n\tmov rbp, rsp\n", 0
    roStr_254 db "\tjmp %s_end\n%s:\n", 0
    roStr_253 db ";==== proc %s ====\n", 0
    roStr_252 db "[Trace] Procedure declaration: %s\n", 0
    roStr_251 db "nested procedure declaration is not allowed\n", 0
    roStr_250 db "parser.strata:%d:%d: ", 0
    roStr_249 db "\tjmp while_%d\n", 0
    roStr_248 db "; -- continue --\n", 0
    roStr_247 db "\tjmp end_while_%d\n", 0
    roStr_246 db "; -- break --\n", 0
    roStr_245 db "end_while_%d:\n", 0
    roStr_244 db "\tjmp while_%d\n", 0
    roStr_243 db "[Trace] While statement: END\n", 0
    roStr_242 db "\tpop rax\n\tcmp rax, 0\n\tjz end_while_%d\n; do statement %d\n", 0
    roStr_241 db "[Trace] While statement: DO\n", 0
    roStr_240 db "while_%d:\n", 0
    roStr_239 db "[Trace] While statement: WHILE\n", 0
    roStr_238 db "[Trace] If statement: END\n", 0
    roStr_237 db "condition_false_%d:\n", 0
    roStr_236 db "end_if_%d:\n", 0
    roStr_235 db "[Trace] If statement: ELSE\n", 0
    roStr_234 db "condition_false_%d:\n; else statement block id %d\n", 0
    roStr_233 db "\tjmp end_if_%d\n", 0
    roStr_232 db "\tpop rax\n\tcmp rax, 0\n\tjz condition_false_%d\n; then statement block id %d\n", 0
    roStr_231 db "[Trace] If statement: THEN\n", 0
    roStr_230 db "; if statement block id: %d\n", 0
    roStr_229 db "[Trace] If statement: IF\n", 0
    roStr_228 db "[Trace] Assignment statement for: '%s'\n", 0
    roStr_227 db "[Error] Error: unknown type %d in 'parseAssignmentStatement'\n", 0
    roStr_226 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_225 db "; assigning value to a struct field\n", 0
    roStr_224 db "[Error] Error: unknown array kind %d\n", 0
    roStr_223 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_222 db "; assigning value to a struct array element\n", 0
    roStr_221 db "[Error] Error: unknown array type %d\n", 0
    roStr_220 db "\tpop rbx\n\tpop rax\n\tmov byte [rax], bl\n\n", 0
    roStr_219 db "; -- (string) set value --\n", 0
    roStr_218 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_217 db "; -- (pointer[]) set value --\n", 0
    roStr_216 db "\tpop rbx\n\tpop rax\n\tmov qword [rax], rbx\n\n", 0
    roStr_215 db "; -- (uint64[]) set value --\n", 0
    roStr_214 db "\tpop rbx\n\tpop rax\n\tmov byte [rax], bl\n\n", 0
    roStr_213 db "; -- (uint8[]) set value --\n", 0
    roStr_212 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_211 db "; -- (struct pointer) set value of '%s' --\n", 0
    roStr_210 db "\tpop rax\n\tpop rbx\n\tmov [rbx], rax\n\n", 0
    roStr_209 db "; -- (struct pointer) set value of '%s' --\n", 0
    roStr_208 db "Cannot assign to a parameter\n", 0
    roStr_207 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_206 db "; assigning value to a local pointer\n", 0
    roStr_205 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_204 db "; -- (pointer) set value of '%s' --\n", 0
    roStr_203 db "[Error] Error: unknown pointer type %d\n", 0
    roStr_202 db "\tmov rbx, [%s]\n\tpop rax\n\tmov [rbx], rax\n\n", 0
    roStr_201 db "\tmov rbx, [%s]\n\tpop rax\n\tmov [rbx], al\n\n", 0
    roStr_200 db "; -- (pointer deref) set value of '%s' subtype %d --\n", 0
    roStr_199 db "Cannot assign to a parameter\n", 0
    roStr_198 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_197 db "; assigning value to a local uint64\n", 0
    roStr_196 db "\tpop rax\n\tmov qword [%s], rax\n\n", 0
    roStr_195 db "; -- (uint64) set value of '%s' --\n", 0
    roStr_194 db "Cannot assign to a parameter\n", 0
    roStr_193 db "\tpop rax\n\tmov qword [rbp - %d], rax\n\n", 0
    roStr_192 db "; assigning value to a local uint8\n", 0
    roStr_191 db "\tpop rax\n\tmov byte [%s], al\n\n", 0
    roStr_190 db "; -- (uint8) set value of '%s' --\n", 0
    roStr_189 db "; -- assignment statement --\n", 0
    roStr_188 db "[Trace] Assignable: variable\n", 0
    roStr_187 db "\tpush rax\n", 0
    roStr_186 db "\tadd rax, %d\n\tpush rax\n", 0
    roStr_185 db "; -- accessing struct field --\n", 0
    roStr_184 db "\tpop rax\n\tmov rdx, %d\n\tmul rdx\n\tmov rbx, %s\n\tadd rax, rbx\n", 0
    roStr_183 db "; -- indexing n-th element of struct array --\n", 0
    roStr_182 db "Error: unknown user type %d\n", 0
    roStr_181 db "[Trace] Assignable: array, ct %d\n", 0
    roStr_180 db "[Error] Error: unknown array type %d\n", 0
    roStr_179 db "\tpop rax\n\tmov rbx, %s\n\tshl rax, 3\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_178 db "; -- indexing n-th element of array --\n", 0
    roStr_177 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_176 db "; -- indexing n-th element of array --\n", 0
    roStr_175 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_174 db "; -- indexing n-th element of array --\n", 0
    roStr_173 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_172 db "; -- indexing n-th element of array --\n", 0
    roStr_171 db "\tadd rax, %d\n\tpush rax\n", 0
    roStr_170 db "\tmov rax, %s\n", 0
    roStr_169 db "; -- accessing struct field --\n", 0
    roStr_168 db "\tmov rax, [%s]\n", 0
    roStr_167 db "; -- accessing struct pointer field --\n", 0
    roStr_166 db "\tpop rbx\n\tpop rax\n\tor rax, rbx\n\tpush rax\n", 0
    roStr_165 db "; -- || --\n", 0
    roStr_164 db "; -- eval expression --\n", 0
    roStr_163 db "\tpop rbx\n\tpop rax\n\tand rax, rbx\n\tpush rax\n", 0
    roStr_162 db "; -- && --\n", 0
    roStr_161 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_160 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjne .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_159 db "; -- != --\n", 0
    roStr_158 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_157 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tje .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_156 db "; -- == --\n", 0
    roStr_155 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_154 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjge .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_153 db "; -- >= --\n", 0
    roStr_152 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_151 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjg .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_150 db "; -- > --\n", 0
    roStr_149 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_148 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjle .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_147 db "; -- <= --\n", 0
    roStr_146 db ".true_%d:\n\tpush 1\n.end_%d:\n", 0
    roStr_145 db "\tpop rbx\n\tpop rax\n\tcmp rax, rbx\n\tjl .true_%d\n\tpush 0\n\tjmp .end_%d\n", 0
    roStr_144 db "; -- < --\n", 0
    roStr_143 db "\tpop rbx\n\tpop rax\n\tsub rax, rbx\n\tpush rax\n", 0
    roStr_142 db "; -- - --\n", 0
    roStr_141 db "\tpop rbx\n\tpop rax\n\tadd rax, rbx\n\tpush rax\n", 0
    roStr_140 db "; -- + --\n", 0
    roStr_139 db "\tpop rbx\n\tpop rax\n\tcqo\n\tdiv rbx\n\tpush rdx\n", 0
    roStr_138 db "; -- %% --\n", 0
    roStr_137 db "\tpop rbx\n\tpop rax\n\tcqo\n\tdiv rbx\n\tpush rax\n", 0
    roStr_136 db "; -- / --\n", 0
    roStr_135 db "\tpop rbx\n\tpop rax\n\tmul rbx\n\tpush rax\n", 0
    roStr_134 db "; -- * --\n", 0
    roStr_133 db "[Error] Error: unknown type %d in 'parseFactor*'\n", 0
    roStr_132 db "\tmov rax, [%s]\n\tpush qword [rax]\n", 0
    roStr_131 db "\tmov rbx, [%s]\n\tmovzx rax, byte [rbx]\n\tpush qword rax\n", 0
    roStr_130 db "\tadd rax, %d\n\tmov rbx, [rax]\n\tpush qword rbx\n", 0
    roStr_129 db "\tadd rax, %d\n\tmov rbx, [rax]\n\tpush qword rbx\n", 0
    roStr_128 db "\tmov rax, [%s]\n", 0
    roStr_127 db "; -- accessing struct field value --\n", 0
    roStr_126 db "[Trace] Factor: dereference\n", 0
    roStr_125 db "[Trace] parseFactor, gsType: %d\n", 0
    roStr_124 db "\tmov rax, %s\n\tpush rax\n", 0
    roStr_123 db "[Error] Error: unknown subtype %d\n", 0
    roStr_122 db "\tpush qword [rbp - %d]\n", 0
    roStr_121 db "\tpush qword [rbp + %d]\n", 0
    roStr_120 db "[Error] Error: unknown type %d in 'parseFactor'\n", 0
    roStr_119 db "\tmov rax, %d ; %s\n\tpush rax\n", 0
    roStr_118 db "\tmov rax, %s\n\tpush rax\n", 0
    roStr_117 db "\tpush qword [%s]\n", 0
    roStr_116 db "\tpush qword [%s]\n", 0
    roStr_115 db "\tpush qword [%s]\n", 0
    roStr_114 db "\tmovzx rax, byte [%s]\n\tpush rax\n", 0
    roStr_113 db "[Trace] Factor: variable #%d\n", 0
    roStr_112 db "\tadd rax, %d\n\tpush qword [rax]\n", 0
    roStr_111 db "\tmov rax, %s\n", 0
    roStr_110 db "; -- accessing struct field value --\n", 0
    roStr_109 db "\tpush rax\n", 0
    roStr_108 db "[Trace] Factor: procedure call\n", 0
    roStr_107 db "[Trace] Factor: array\n", 0
    roStr_106 db "\tpush qword [rax]\n", 0
    roStr_105 db "\tpush qword [rax]\n", 0
    roStr_104 db "\tadd rax, %d\n\tpush qword [rax]\n", 0
    roStr_103 db "; -- accessing struct field value --\n", 0
    roStr_102 db "\tpop rax\n\tmov rdx, %d\n\tmul rdx\n\tmov rbx, %s\n\tadd rax, rbx\n", 0
    roStr_101 db "; -- indexing struct[] array --\n", 0
    roStr_100 db "Error: unknown user type %d\n", 0
    roStr_99 db "[Error] Error: unknown array type %d\n", 0
    roStr_98 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_97 db "; -- string access\n", 0
    roStr_96 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_95 db "; -- pointer[] access\n", 0
    roStr_94 db "\tpop rax\n\tshl rax, 3\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_93 db "; -- uint64[] access\n", 0
    roStr_92 db "\tpop rax\n\tmov rbx, %s\n\tadd rax, rbx\n\tpush qword [rax]\n", 0
    roStr_91 db "; -- uint8[] access\n", 0
    roStr_90 db "\tpush %d\n", 0
    roStr_89 db "\tmov rax, %d\n\tpush rax\n", 0
    roStr_88 db "\tpush %d ; sizeof %s\n", 0
    roStr_87 db "variable declarations are not allowed in procedure code section\n", 0
    roStr_86 db "parser.strata:%d:%d: ", 0
    roStr_85 db "[Trace] Variable declaration: type %d, value %d\n", 0
    roStr_84 db "[Error] Error: pointer declaration in procedures is not supported\n", 0
    roStr_83 db "\tpop rax\n\tmov qword [%s], rax\n", 0
    roStr_82 db "\tpush %d\n", 0
    roStr_81 db "\tpop rax\n\tmov qword [%s], rax\n", 0
    roStr_80 db "\tpush %d\n", 0
    roStr_79 db "[Trace] String declaration: type %d, value %d\n", 0
    roStr_78 db "[Trace] String declaration: type %d, subtype %d\n", 0
    roStr_77 db "[Trace] Array declaration: type %d, value %d\n", 0
    roStr_76 db "[Trace] Array declaration: type %d, subtype %d\n", 0
    roStr_75 db "global array size must be known at compile time\n", 0
    roStr_74 db "parser.strata:%d:%d: ", 0
    roStr_73 db "[Trace] Array declaration: type %d, value %d\n", 0
    roStr_72 db "[Trace] Array declaration: type %d, subtype %d\n", 0
    roStr_71 db "gvValue: %d\n", 0
    roStr_70 db "arrays declarations are not allowed in procedures\n", 0
    roStr_69 db "parser.strata:%d:%d: ", 0
    roStr_68 db "[Trace] Identifier: #%d\n", 0
    roStr_67 db "[Trace] Identifier: #%d\n", 0
    roStr_66 db "[Trace] Number: %d\n", 0
    roStr_65 db "unexpected token %d\n", 0
    roStr_64 db "parser.strata:%d:%d: ", 0
    roStr_63 db "unknown identifier: %s\n", 0
    roStr_62 db "parser.strata:%d:%d: ", 0
    roStr_61 db "identifier redeclared: %s\n", 0
    roStr_60 db "parser.strata:%d:%d: ", 0
    roStr_59 db "expected token %d but got %d\n", 0
    roStr_58 db "parser.strata:%d:%d: ", 0
    roStr_57 db "[Trace] Read string: #%d with length %d.\n", 0
    roStr_56 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_55 db "[Trace] Did not find user type field.\n", 0
    roStr_54 db "[Trace] Found user type field: #%d with offset %d.\n", 0
    roStr_53 db "[Trace] Did not find user type.\n", 0
    roStr_52 db "[Trace] Found user type: #%d with value %d.\n", 0
    roStr_51 db "[Trace] Did not find global symbol.\n", 0
    roStr_50 db "[Trace] Found global symbol: #%d with value %d.\n", 0
    roStr_49 db "[Trace] Comparing strings: %s and %s\n", 0
    roStr_48 db "[\#27[92mINFO\#27[0m] Token count: %d\n", 0
    roStr_47 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_46 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_45 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_44 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_43 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_42 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_41 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_40 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_39 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_38 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_37 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_36 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_35 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_34 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_33 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_32 db "[\#27[92mINFO\#27[0m] Token: '%s'\n", 0
    roStr_31 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_30 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_29 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_28 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'\n", 0
    roStr_27 db "[\#27[92mINFO\#27[0m] Token: [!] '%s'\n", 0
    roStr_26 db "[\#27[91mERROR\#27[0m] Invalid escape sequence\n", 0
    roStr_25 db "[\#27[92mINFO\#27[0m] Token: [!] '%s'\n", 0
    roStr_24 db "[\#27[91mERROR\#27[0m] Invalid escape sequence\n", 0
    roStr_23 db "---------------SCIndex: %d, col: %d\n", 0
    roStr_22 db "[\#27[92mINFO\#27[0m] Token: [x] '%s'; ", 0
    roStr_21 db "Token dictionary count: %d\n", 0
    roStr_20 db "[Trace] Comparing strings: %s and %s\n", 0
    roStr_19 db "[Trace] Read string: #%d with length %d.\n", 0
    roStr_18 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_17 db "[Trace] Pushed string: #%d with length %d.\n", 0
    roStr_16 db "[\#27[91mERROR\#27[0m] Too many identifiers\n", 0
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
    roStr_2 db "; Generated by Strata v1.0\n", 0
    roStr_1 db "[\#27[92mINFO\#27[0m] Output file '%s'\r\n", 0
    roStr_0 db "[\#27[92mINFO\#27[0m] Input file '%s'\r\n", 0
