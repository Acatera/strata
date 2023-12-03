bits 64
default rel


%include "inc/std.inc"
; %define DEBUG 0
;state machine
section .data
	EXPECTING_ANYTHING dq 0
section .text

section .data
	EXPECTING_IDENTIFIER dq 1
section .text

section .data
	EXPECTING_ASSIGNMENT dq 2
section .text

section .data
	EXPECTING_CONSTANT_INTEGER dq 3
section .text

section .data
	EXPECTING_SEMICOLON dq 4
section .text

section .data
	machineState dq 0
section .text
; array of pointers to statements of any sort
section .bss
	program resq 65536
section .text

section .data
	programCount dq 0
section .text

section .data
	currentProcArgCount dq 0
section .text

section .data
	currentProcArgIndex dq 0
section .text
section .bss
	tokens resq 65536
section .text

section .data
	tokenCount dq 0
section .text

section .data
	tokenSize dq 4
section .text

section .data
	tokenI dq 0
section .text

section .data
	tokenTypeIndex dq 0
section .text

section .data
	tokenTypeValue dq 0
section .text

section .data
	tokenLineIndex dq 0
section .text

section .data
	tokenLineValue dq 0
section .text

section .data
	tokenStartIndex dq 0
section .text

section .data
	tokenStartValue dq 0
section .text

section .data
	tokenLengthIndex dq 0
section .text

section .data
	tokenLengthValue dq 0
section .text

section .data
	currentTokenType dq 0
section .text

section .data
	nextBLockId dq 0
section .text

section .data
	currentLine dq 1
section .text

section .data
	currentTokenStart dq 0
section .text

section .data
	currentTokenLength dq 0
section .text
section .bss
	currentIdentifier resb 256
section .text
section .bss
	irStack resq 65536
section .text

section .data
	irStackCount dq 0
section .text

section .data
	irStackTokenTypeIndex dq 0
section .text

section .data
	irStackTokenValueIndex dq 0
section .text

section .data
	irStackTokenTypeValue dq 0
section .text

section .data
	irStackTokenValueValue dq 0
section .text

section .data
	irStackSize dq 2
section .text

section .data
	irStackI dq 0
section .text

section .data
	tokenTypeToPush dq 0
section .text

section .data
	tokenValueToPush dq 0
section .text

	jmp pushTokenToIRStack_end
pushTokenToIRStack:

    ;printf(roStr_0, [tokenTypeToPush], [tokenValueToPush])
    	push qword [irStackCount]
	push qword [irStackSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	pop rax
	mov qword [irStackTokenTypeIndex], rax
	push qword [irStackCount]
	push qword [irStackSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [irStackTokenValueIndex], rax

    ;printf(roStr_1, [irStackTokenTypeIndex])
    ;printf(roStr_2, [irStackTokenValueIndex])
    	mov rax, [irStackTokenTypeIndex]
	mov rdx, 8
	mul rdx
	mov rdx, irStack
	add rdx, rax
	mov rax, [tokenTypeToPush]
	mov [rdx], rax
	mov rax, [irStackTokenValueIndex]
	mov rdx, 8
	mul rdx
	mov rdx, irStack
	add rdx, rax
	mov rax, [tokenValueToPush]
	mov [rdx], rax
	push qword [irStackCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [irStackCount], rax

	ret
pushTokenToIRStack_end:

	jmp incrementCurrentLine_end
incrementCurrentLine:
	push qword [currentLine]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [currentLine], rax

	ret
incrementCurrentLine_end:

	jmp writeVariableDeclaration_end
writeVariableDeclaration:

	ret
writeVariableDeclaration_end:

section .data
	printHumanTokenTypeArg1 dq 0
section .text

	jmp printHumanTokenType_end
printHumanTokenType:

;.if_0:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 1
	jne .else_0
;then_0:

        printf(roStr_3)
        
	jmp .end_0
.else_0:

;.if_1:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 2
	jne .else_1
;then_1:

        printf(roStr_4)
        
	jmp .end_1
.else_1:

;.if_2:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 3
	jne .else_2
;then_2:

        printf(roStr_5)
        
	jmp .end_2
.else_2:

;.if_3:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 4
	jne .else_3
;then_3:

        printf(roStr_6)
        
	jmp .end_3
.else_3:

;.if_4:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 5
	jne .else_4
;then_4:

        printf(roStr_7)
        
	jmp .end_4
.else_4:

;.if_5:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 6
	jne .else_5
;then_5:

        printf(roStr_8)
        
	jmp .end_5
.else_5:

;.if_6:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 7
	jne .else_6
;then_6:

        printf(roStr_9)
        
	jmp .end_6
.else_6:

;.if_7:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 8
	jne .else_7
;then_7:

        printf(roStr_10)
        
	jmp .end_7
.else_7:

;.if_8:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 9
	jne .else_8
;then_8:

        printf(roStr_11)
        
	jmp .end_8
.else_8:

;.if_9:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 10
	jne .else_9
;then_9:

        printf(roStr_12)
        
	jmp .end_9
.else_9:

;.if_10:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 11
	jne .else_10
;then_10:

        printf(roStr_13)
        
	jmp .end_10
.else_10:

;.if_11:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 12
	jne .else_11
;then_11:

        printf(roStr_14)
        
	jmp .end_11
.else_11:

;.if_12:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 256
	jne .else_12
;then_12:

        printf(roStr_15)
        
	jmp .end_12
.else_12:

;.if_13:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 257
	jne .else_13
;then_13:

        printf(roStr_16)
        
	jmp .end_13
.else_13:

;.if_14:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 258
	jne .else_14
;then_14:

        printf(roStr_17)
        
	jmp .end_14
.else_14:

;.if_15:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 259
	jne .else_15
;then_15:

        printf(roStr_18)
        
	jmp .end_15
.else_15:

;.if_16:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 260
	jne .else_16
;then_16:

        printf(roStr_19)
        
	jmp .end_16
.else_16:

;.if_17:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 261
	jne .else_17
;then_17:

        printf(roStr_20)
        
	jmp .end_17
.else_17:

;.if_18:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 262
	jne .else_18
;then_18:

        printf(roStr_21)
        
	jmp .end_18
.else_18:

;.if_19:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 263
	jne .else_19
;then_19:

        printf(roStr_22)
        
	jmp .end_19
.else_19:

;.if_20:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 264
	jne .else_20
;then_20:

        printf(roStr_23)
        
	jmp .end_20
.else_20:

;.if_21:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 265
	jne .else_21
;then_21:

        printf(roStr_24)
        
	jmp .end_21
.else_21:

;.if_22:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 266
	jne .else_22
;then_22:

        printf(roStr_25)
        
	jmp .end_22
.else_22:

;.if_23:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 267
	jne .else_23
;then_23:

        printf(roStr_26)
        
	jmp .end_23
.else_23:

;.if_24:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 268
	jne .else_24
;then_24:

        printf(roStr_27)
        
	jmp .end_24
.else_24:

;.if_25:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 269
	jne .else_25
;then_25:

        printf(roStr_28)
        
	jmp .end_25
.else_25:

;.if_26:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 270
	jne .else_26
;then_26:

        printf(roStr_29)
        
	jmp .end_26
.else_26:

;.if_27:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 16
	jne .else_27
;then_27:

        printf(roStr_30)
        
	jmp .end_27
.else_27:

;.if_28:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 17
	jne .else_28
;then_28:

        printf(roStr_31)
        
	jmp .end_28
.else_28:

;.if_29:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 18
	jne .else_29
;then_29:

        printf(roStr_32)
        
	jmp .end_29
.else_29:

;.if_30:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 19
	jne .else_30
;then_30:

        printf(roStr_33)
        
	jmp .end_30
.else_30:

;.if_31:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 20
	jne .else_31
;then_31:

        printf(roStr_34)
        
	jmp .end_31
.else_31:

;.if_32:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 21
	jne .else_32
;then_32:

        printf(roStr_35)
        
	jmp .end_32
.else_32:

;.if_33:
	mov r15, [printHumanTokenTypeArg1]
	cmp r15, 22
	jne .else_33
;then_33:

        printf(roStr_36)
        
	jmp .end_33
.else_33:

        printf(roStr_37, [printHumanTokenTypeArg1])
        
.end_33:

.end_32:

.end_31:

.end_30:

.end_29:

.end_28:

.end_27:

.end_26:

.end_25:

.end_24:

.end_23:

.end_22:

.end_21:

.end_20:

.end_19:

.end_18:

.end_17:

.end_16:

.end_15:

.end_14:

.end_13:

.end_12:

.end_11:

.end_10:

.end_9:

.end_8:

.end_7:

.end_6:

.end_5:

.end_4:

.end_3:

.end_2:

.end_1:

.end_0:

	ret
printHumanTokenType_end:

	jmp printUnexpectedToken_end
printUnexpectedToken:

    printf(roStr_38, [currentLine])
    	push qword [tokenTypeValue]
	pop rax
	mov qword [printHumanTokenTypeArg1], rax

call printHumanTokenType

    ExitProcess(1)
    
	ret
printUnexpectedToken_end:

%define SOURCE_CODE_SIZE 1024*1024
%define TINY_BUFFER_SIZE 32
%define SMALL_BUFFER_SIZE 64
%define MED_BUFFER_SIZE 256
%define OPERATOR_BUFFER_SIZE 16

%macro _reset_counters_ 0
    ; r8 - offset in source code, token start
    ; r9 - token length
    ; rdi - source code pointer
    add r8, r9
    inc r8
    inc rdi
    xor r9, r9

    cmp r8, [dwBytesRead]
    jge .source_code_parsed

    jmp .read_token_loop
%endmacro

%define CompareTokenWith(c) _CompareTokenWith_ c
%macro _CompareTokenWith_ 1
    multipush rdi, rsi, rcx, r10
    strcmp(r10, %1, %1.length)
    multipop rdi, rsi, rcx, r10
%endmacro

%define OperatorEquals           1
%define OperatorNotEquals        2
%define OperatorLess             3
%define OperatorLessOrEqual      4
%define OperatorGreater          5
%define OperatorGreaterOrEqual   6
%define OperatorAssignment       7
%define OperatorPlus             8
%define OperatorMinus            9
%define OperatorMultiply        10
%define OperatorDivide          11
%define OperatorModulo          12

; Reserve 4 bits for operator type
%define OperandStringLiteral     0 + (1 << 4)
%define OperandAsmLiteral        1 + (1 << 4)
%define OperandLiteral           2 + (1 << 4)
%define OperandInteger           3 + (1 << 4)
%define StatemendEnd             4 + (1 << 4)
%define SquareBracketOpen        5 + (1 << 4)
%define SquareBracketClose       6 + (1 << 4)
%define ParenOpen                7 + (1 << 4)
%define ParenClose               8 + (1 << 4)

; Reserve 4 bits for operand type
%define KeywordIf                0 + (1 << (4 + 4))
%define KeywordThen              1 + (1 << (4 + 4))
%define KeywordElse              2 + (1 << (4 + 4))
%define KeywordEnd               3 + (1 << (4 + 4))
%define KeywordWhile             4 + (1 << (4 + 4))
%define KeywordDo                5 + (1 << (4 + 4))
%define KeywordContinue          6 + (1 << (4 + 4))
%define KeywordBreak             7 + (1 << (4 + 4))
%define KeywordDefineUInt8       8 + (1 << (4 + 4))
%define KeywordDefineUInt64      9 + (1 << (4 + 4))
%define KeywordEval             10 + (1 << (4 + 4))
%define KeywordArray            11 + (1 << (4 + 4))
%define KeywordProc             12 + (1 << (4 + 4))
%define KeywordEndProc          13 + (1 << (4 + 4))
%define KeywordForward          14 + (1 << (4 + 4))

; todo - revisit this
%define defOperatorEquals         word OperatorEquals
%define defOperatorNotEquals      word OperatorNotEquals
%define defOperatorLess           word OperatorLess
%define defOperatorLessOrEqual    word OperatorLessOrEqual
%define defOperatorGreater        word OperatorGreater
%define defOperatorGreaterOrEqual word OperatorGreaterOrEqual
%define defOperatorAssignment     word OperatorAssignment
%define defOperatorPlus           word OperatorPlus
%define defOperatorMinus          word OperatorMinus
%define defOperatorMultiply       word OperatorMultiply
%define defOperatorDivide         word OperatorDivide
%define defOperatorModulo         word OperatorModulo

%define defOperandStringLiteral   word OperandStringLiteral
%define defOperandAsmLiteral      word OperandAsmLiteral
%define defOperandLiteral         word OperandLiteral
%define defOperandInteger         word OperandInteger
%define defStatemendEnd           word StatemendEnd
%define defSquareBracketOpen      word SquareBracketOpen
%define defSquareBracketClose     word SquareBracketClose
%define defParenOpen              word ParenOpen
%define defParenClose             word ParenClose

%define defKeywordIf              word KeywordIf
%define defKeywordThen            word KeywordThen
%define defKeywordElse            word KeywordElse
%define defKeywordEnd             word KeywordEnd
%define defKeywordWhile           word KeywordWhile
%define defKeywordDo              word KeywordDo
%define defKeywordContinue        word KeywordContinue
%define defKeywordBreak           word KeywordBreak
%define defKeywordDefineUInt8     word KeywordDefineUInt8
%define defKeywordDefineUInt64    word KeywordDefineUInt64
%define defKeywordEval            word KeywordEval
%define defKeywordArray           word KeywordArray
%define defKeywordProc            word KeywordProc
%define defKeywordEndProc         word KeywordEndProc
%define defKeywordForward         word KeywordForward


%define TYPE_UINT8     1
%define TYPE_UINT64    2
%define TYPE_ARRAY     3
%define TYPE_STRING    4
%define TYPE_PROC      5

%define TOKEN_TYPE_SIZE 2

struc Token
    .TokenType:    resw 1 ; if you change this, also update TOKEN_TYPE_SIZE
    .TokenStart:   resq 1
    .TokenLength:  resq 1
    .Line:         resq 1
    .Column:       resq 1
    .size equ $ - .TokenType
endstruc

struc Block
    .TokenIndex   resd 1
    .BlockId   resw 1
    .TokenType resw 1
    .size equ $ - .TokenIndex
endstruc

struc Name
    .Pointer  resq 1 ; pointer to the name
    .Type     resq 1 ; uint64 type
    .DataSize resq 1 ; uint64 size of the data
    .Value    resq 1 ; uint64 value or pointer to a struct
    .size equ $ - .Pointer
endstruc

struc SymbolTable
    .Pointer     resq 1
    .SymbolCount resq 1
    .size equ $ - .Pointer

%define MAX_TOKEN_COUNT 1024 * 16

%define BLOCK_ITEM_SIZE 8
section .bss
    szSourceCode resb SOURCE_CODE_SIZE
    szTokenValue resb SMALL_BUFFER_SIZE
    pBufferTiny resb TINY_BUFFER_SIZE
    ptrBuffer64 resb SMALL_BUFFER_SIZE
    ptr2Buffer64 resb SMALL_BUFFER_SIZE
    ptr3Buffer64 resb SMALL_BUFFER_SIZE
    ptrBuffer256 resb MED_BUFFER_SIZE
    blockStack resb 256 * Block.size ; todo - revisit this
    blockCount resq 1
    lpProcessInformation resb 24
    lpStartupInfo resb 104
    tokenList resq MAX_TOKEN_COUNT * Token.size
    dwTokenCount resd 1
    bProcessingIfCondition resq 1
    dqCurrentLine resq 1
    dqLineStart resq 1
    pOperatorStack resq 32
    dqOperatorCount resq 1
    pOperandStack resq 32
    dqOperandCount resq 1
    dqStatementOpCount resq 1
    
    szNames resb 1024 * 64
    pszNameEndPointer resq 1
    pNames resb 1024 * Name.size
    dqNameCount resq 1

    hndSourceFile resq 1
    hndDestFile resq 1
    dwBytesRead resd 1
    dwBytesWritten resd 1
    szSourceFile resb 256
    szDestFile resb 256
    szFilenameWithoutExtension resb 256
    lpExitCode resq 1

    memory resb 1024 * 1024
    pFreePointer resq 1
    symbolTables resb 256 * SymbolTable.size

    dqSymbolTableCount resq 1
    pCurrentSymbolTable resq 1
    pCurrentProcedureSymbolTable resq 1
    dqCurrentAssignedOperandValue resq 1 ; this is used to store the offset from rbp, in case of paramaters
    dqCurrentParamValue resq 1 ; this is used to store the offset from rbp, in case of paramaters

%define CONST_STRING_COUNT 1024
%define CONST_STRING_CAPACITY 1024*256 

    ; constant string literals
    ; allow for 1024 constant string literal pointers
    pStringListPointers resq CONST_STRING_COUNT 
    dwStringCount resq 1
    ; pointer to a buffer that holds the string literals
    ; all strings are NULL terminated
    ; to index this, use 'pStringListPointers'
    pStringList resb CONST_STRING_CAPACITY
    ; this points to the next available byte in the string list
    pStringListEnd resq 1

section .data
    tokenIndex dq 0
    chAsmStart equ 0x60
    chDoubleQuote equ 0x22
    wScopedBlockCurrentId dw 0
    argCount dq 0

    ; asm output 
    cStrAsmHeader db "bits 64", 0xd, 0xa
                  db "default rel", 0xd, 0xa, 0xd, 0xa, 0
    cStrAsmHeader.length equ $ - cStrAsmHeader - 1
    cStrReadOnlySectionHeader db 0xd, 0xa, "section .rodata", 0xd, 0xa, 0
    cStrReadOnlySectionHeader.length equ $ - cStrReadOnlySectionHeader - 1

section .text
    global _start
    extern CreateFileA
    extern ReadFile
    extern WriteFile
    extern CloseHandle
    extern DeleteFileA
    extern GetLastError
    extern GetCommandLineA
    extern CreateProcessA
    extern WaitForSingleObject
    extern GetExitCodeProcess

alloc_mem:
    mov rax, [pFreePointer]
    add rcx, rax
    mov [pFreePointer], rcx
    ret

free_mem:
    mov rax, [pFreePointer]
    sub rax, rcx
    mov [pFreePointer], rax
    ret

push_symbol_table:
    PushCalleeSavedRegs()
    mov rax, [dqSymbolTableCount]
    mov rbx, SymbolTable.size
    xor rdx, rdx
    mul rbx
    mov rbx, symbolTables
    add rbx, rax

    ; point to old symbol table and save current symbol count
    sub rbx, SymbolTable.size
    mov rax, [dqNameCount]
    mov [rbx + SymbolTable.SymbolCount], rax

    ; point to new symbol table 
    add rbx, SymbolTable.size
    mov [rbx + SymbolTable.Pointer], rcx
    mov qword [rbx + SymbolTable.SymbolCount], qword 0
    mov [pCurrentSymbolTable], rcx
    mov qword [dqNameCount], qword 0
    
    inc qword [dqSymbolTableCount]
    PopCalleeSavedRegs()
    ret


pop_symbol_table:
    PushCalleeSavedRegs()
    dec qword [dqSymbolTableCount]
    mov rax, [dqSymbolTableCount]
    dec rax     ; because we start counting from 0
    mov rbx, SymbolTable.size
    xor rdx, rdx
    mul rbx
    mov rbx, symbolTables
    add rbx, rax
    
    mov r15, [rbx + SymbolTable.Pointer]
    mov [pCurrentSymbolTable], r15
    mov r15, [rbx + SymbolTable.SymbolCount]
    mov [dqNameCount], r15
    PopCalleeSavedRegs()
    ret

_start:
    sub rsp, 32
    call GetCommandLineA
    add rsp, 32

    mov qword [argCount], 0

    ; get length of command line
    mov rdi, rax
    mov rax, ' '
    xor rcx, rcx
    xor r8, r8

.arg_loop:    
    cmp byte [rdi], 0
    je .arg_loop_end
    cmp byte [rdi], al
    je .arg_loop_found_space
    inc rdi
    inc r8
    jmp .arg_loop

.arg_loop_found_space:
;.if_34:
    cmp r8, 0
	jne .end_34
;then_34:

    inc rdi
    jmp .arg_loop
.end_34:


.if_first_arg:
    cmp byte [argCount], 0
    jne .endif_first_arg
.then_first_arg:
    inc qword [argCount]
    inc rdi
    xor r8, r8
    push rdi
    jmp .arg_loop
.endif_first_arg:    

.arg_loop_end:
    pop rdi
.if_trim:
    cmp byte [rdi], ' '
    jne .endif_trim
.then_trim:
    inc rdi
.endif_trim:    

    multipush rax, rcx, rdi, rsi
    mov r14, rdi
    strlen(rdi)
    mov r13, rax

    push r14
    memcpy(szSourceFile, r14, r13)
    pop r14
    push r14
    memcpy(szDestFile, r14, r13)
    pop r14
    strcpy(szFilenameWithoutExtension, szSourceFile, r13)
    
    mov r14, szSourceFile
    add r14, r13
    memcpy(r14, szStrataFileExtension, szStrataFileExtension.length)

    mov r14, szDestFile
    add r14, r13
    memcpy(r14, szAsmFileExtension, szAsmFileExtension.length)

    multipop rax, rcx, rdi, rsi
    
    InitStandardOutput()

    ; print input and output file names
    printf(roStr_39, szSourceFile)
    printf(roStr_40, szDestFile)

    ; Preparing the parameters for CreateFileA to open a file for reading
    mov rcx, szSourceFile                       ; First parameter: Pointer to the filename (LPCSTR)
    mov rdx, GENERIC_READ                       ; Second parameter: Access to the file (DWORD), for reading use GENERIC_READ
    mov r8, 1                                   ; Third parameter: File sharing mode (DWORD)
    mov r9, 0                                   ; Fourth parameter: Pointer to security attributes (LPSECURITY_ATTRIBUTES)
    sub rsp, 4*8 + 3*8                          ; Shadow space for 4 register parameters + 3 additional stack parameters
    mov [rsp+4*8], dword 3                      ; Fifth parameter: Action to take on files that exist or do not exist (DWORD)
    mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; Sixth parameter: File attributes and flags (DWORD)
    mov [rsp+6*8], dword 0                      ; Seventh parameter: Handle to a template file (HANDLE)
    call CreateFileA
    add rsp, 4*8 + 3*8

    ; check if the file handle is valid
;.if_35:
    cmp rax, 0
	jge .end_35
;then_35:

        call GetLastError
        printf(roStr_41, szSourceFile, rax)
        ExitProcess(1)
.end_35:


    ; file opened
    mov [hndSourceFile], rax

    ; Preparing the parameters for ReadFile
    mov rcx, [hndSourceFile]      ; Handle to the file (HANDLE)
    mov rdx, szSourceCode        ; Pointer to the buffer that receives the data read from the file (LPVOID)
    mov r8, dword SOURCE_CODE_SIZE   ; Number of bytes to be read from the file (DWORD)
    mov r9, dwBytesRead         ; Pointer to the variable that receives the number of bytes read (LPDWORD)
    sub rsp, 32
    push 0
    call ReadFile

    ; check if the function succeeded
;.if_36:
    cmp rax, 0
	jne .end_36
;then_36:

        call GetLastError
        printf(roStr_42, rax)
        ExitProcess(1)
.end_36:


    ; Preparing the parameters for CreateFileA to open a file for writing
    mov rcx, szDestFile                         ; Pointer to the filename (LPCSTR)
    mov rdx, GENERIC_WRITE                      ; Access to the file (DWORD), for reading use GENERIC_READ
    mov r8, 2                                   ; File sharing mode (DWORD)
    mov r9, 0                                   ; Pointer to security attributes (LPSECURITY_ATTRIBUTES)
    sub rsp, 4*8 + 3*8                          ; 4 register parameters + 3 additional stack parameters
    mov [rsp+4*8], dword 2                      ; Action to take on files that exist or do not exist (DWORD)
    mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; File attributes and flags (DWORD)
    mov [rsp+6*8], dword 0                      ; Handle to a template file (HANDLE)
    call CreateFileA
    add rsp, 4*8 + 3*8

    ; check if the function succeeded
;.if_37:
    cmp rax, 0
	jge .end_37
;then_37:

        call GetLastError
        printf(roStr_43, szDestFile, rax)
        ExitProcess(1)
.end_37:


    mov [hndDestFile], rax

    printf(roStr_44, szSourceFile)

    ; initialize string count
    mov rax, 0
    mov [dwStringCount], rax

    ; initialize string list end pointer
    mov rax, pStringList
    mov [pStringListEnd], rax

    ; initialize name list
    mov rax, szNames
    mov [pszNameEndPointer], rax
    mov [pNames + Name.Pointer], rax

;-----------------------------------source code parsing----------------------------------
.start_parsing_source_code:
    ; reset offset
    xor r8, r8          ; token start
    xor r9, r9          ; token length
    mov rdi, szSourceCode

.read_token_loop:
    mov rbx, 0xd    ; CR
    mov rax, ' '
    mov rcx, 0xa    ; LF
    mov rdx, 0x9    ; szTab
    cmp byte [rdi], 0
    je .source_code_end
    cmp byte [rdi], al
    je .token_found
    cmp byte [rdi], bl
    je .token_found
    cmp byte [rdi], cl
    je .newline_found
    cmp byte [rdi], dl
    je .token_found
    cmp byte [rdi], chAsmStart
    je .asm_literal_start
    cmp byte [rdi], chDoubleQuote
    je .string_literal_start
    inc r9
    inc rdi
    jmp .read_token_loop

.source_code_end:
    cmp r9, 0
    je .source_code_parsed

.newline_found:
    inc qword [dqCurrentLine]
    add r8, 2
    mov [dqLineStart], r8
    sub r8, 2
    	push qword [currentLine]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [currentLine], rax

    ;printf(roStr_45, [currentLine])


.token_found:
    ; is token length 0?
;.if_38:
    cmp r9, 0
	jne .end_38
;then_38:

        inc rdi
        inc r8
        jmp .read_token_loop
.end_38:


.print_token:
    mov r10, szSourceCode
    add r10, r8

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; reserve space on the stack for the token type
    mov [rbp], word 0 ; initialize token type to 0
	push 0
	pop rax
	mov qword [currentTokenType], rax

;.if_39:
    CompareTokenWith(szKeywordIf)
    jne .else_39
;then_39:

    mov [rbp], word KeywordIf
    	push 256
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_39
.else_39:

;.if_40:
    CompareTokenWith(szKeywordThen)
    jne .else_40
;then_40:

    mov [rbp], word KeywordThen
    	push 257
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_40
.else_40:

;.if_41:
    CompareTokenWith(szKeywordElse)
    jne .else_41
;then_41:

    mov [rbp], word KeywordElse
    	push 258
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_41
.else_41:

;.if_42:
    CompareTokenWith(szKeywordEndProc)
    jne .else_42
;then_42:

    mov [rbp], word KeywordEndProc
    	push 270
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_42
.else_42:

;.if_43:
    CompareTokenWith(szKeywordEnd)
    jne .else_43
;then_43:

    mov [rbp], word KeywordEnd
    	push 259
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_43
.else_43:

;.if_44:
    CompareTokenWith(szKeywordWhile)
    jne .else_44
;then_44:

    mov [rbp], word KeywordWhile
    	push 260
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_44
.else_44:

;.if_45:
    CompareTokenWith(szKeywordDo)
    jne .else_45
;then_45:

    mov [rbp], word KeywordDo
    	push 261
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_45
.else_45:

;.if_46:
    CompareTokenWith(szKeywordContinue)
    jne .else_46
;then_46:

    mov [rbp], word KeywordContinue
    	push 262
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_46
.else_46:

;.if_47:
    CompareTokenWith(szKeywordBreak)
    jne .else_47
;then_47:

    mov [rbp], word KeywordBreak
    	push 263
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_47
.else_47:

;.if_48:
    CompareTokenWith(szKeywordUInt8)
    jne .else_48
;then_48:

    mov [rbp], word KeywordDefineUInt8
    	push 264
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_48
.else_48:

;.if_49:
    CompareTokenWith(szKeywordUInt64)
    jne .else_49
;then_49:

    mov [rbp], word KeywordDefineUInt64
    	push 265
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_49
.else_49:

;.if_50:
    CompareTokenWith(szKeywordEval)
    jne .else_50
;then_50:

    mov [rbp], word KeywordEval
    	push 267
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_50
.else_50:

;.if_51:
    CompareTokenWith(szKeywordArray)
    jne .else_51
;then_51:

    mov [rbp], word KeywordArray
    	push 268
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_51
.else_51:

;.if_52:
    CompareTokenWith(szKeywordProc)
    jne .else_52
;then_52:

    mov [rbp], word KeywordProc
    	push 269
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_52
.else_52:

;.if_53:
    CompareTokenWith(szKeywordForward)
    jne .else_53
;then_53:

    mov [rbp], word KeywordForward
    	push 269
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_53
.else_53:

;.if_54:
    CompareTokenWith(szOperatorEquals)
    jne .else_54
;then_54:

    mov [rbp], word OperatorEquals
    	push 1
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_54
.else_54:

;.if_55:
    CompareTokenWith(szOperatorNotEquals)
    jne .else_55
;then_55:

    mov [rbp], word OperatorNotEquals
    	push 2
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_55
.else_55:

;.if_56:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .else_56
;then_56:

    mov [rbp], word OperatorLessOrEqual
    	push 4
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_56
.else_56:

;.if_57:
    CompareTokenWith(szOperatorLess)
    jne .else_57
;then_57:

    mov [rbp], word OperatorLess
    	push 3
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_57
.else_57:

;.if_58:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .else_58
;then_58:

    mov [rbp], word OperatorGreaterOrEqual
    	push 6
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_58
.else_58:

;.if_59:
    CompareTokenWith(szOperatorGreater)
    jne .else_59
;then_59:

    mov [rbp], word OperatorGreater
    	push 5
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_59
.else_59:

;.if_60:
    CompareTokenWith(szOperatorAssignment)
    jne .else_60
;then_60:

    mov [rbp], word OperatorAssignment
    	push 7
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_60
.else_60:

;.if_61:
    CompareTokenWith(szOperatorPlus)
    jne .else_61
;then_61:

    mov [rbp], word OperatorPlus
    	push 8
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_61
.else_61:

;.if_62:
    CompareTokenWith(szOperatorMinus)
    jne .else_62
;then_62:

    mov [rbp], word OperatorMinus
    	push 9
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_62
.else_62:

;.if_63:
    CompareTokenWith(szOperatorMultiply)
    jne .else_63
;then_63:

    mov [rbp], word OperatorMultiply
    	push 10
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_63
.else_63:

;.if_64:
    CompareTokenWith(szOperatorDivide)
    jne .else_64
;then_64:

    mov [rbp], word OperatorDivide
    	push 11
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_64
.else_64:

;.if_65:
    CompareTokenWith(szOperatorModulo)
    jne .else_65
;then_65:

    mov [rbp], word OperatorModulo
    	push 12
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_65
.else_65:

;.if_66:
    CompareTokenWith(szStatementEnd)
    jne .else_66
;then_66:

    mov [rbp], word StatemendEnd
    	push 20
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_66
.else_66:

;.if_67:
    CompareTokenWith(szSquareBracketOpen)
    jne .else_67
;then_67:

    mov [rbp], word SquareBracketOpen
    	push 21
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_67
.else_67:

;.if_68:
    CompareTokenWith(szSquareBracketClose)
    jne .else_68
;then_68:

    mov [rbp], word SquareBracketClose
    	push 22
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_68
.else_68:

;.if_69:
    CompareTokenWith(szParenOpen)
    jne .else_69
;then_69:

    mov [rbp], word ParenOpen
    	push 23
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_69
.else_69:

;.if_70:
    CompareTokenWith(szParenClose)
    jne .else_70
;then_70:

    mov [rbp], word ParenClose
    	push 24
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_70
.else_70:

    ; check if token is a number
    PushCallerSavedRegs()
    strcpy(ptrBuffer64, r10, r9)
    mov rcx, ptrBuffer64
    call atoi
;.if_71:
    cmp rdx, 0
	je .else_71
;then_71:

        mov [rbp], word OperandInteger
        	push 19
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_71
.else_71:

        ; otherwise, it's a literal
        mov [rbp], word OperandLiteral
        	push 18
	pop rax
	mov qword [currentTokenType], rax

.end_71:

    PopCallerSavedRegs()
.end_70:

.end_69:

.end_68:

.end_67:

.end_66:

.end_65:

.end_64:

.end_63:

.end_62:

.end_61:

.end_60:

.end_59:

.end_58:

.end_57:

.end_56:

.end_55:

.end_54:

.end_53:

.end_52:

.end_51:

.end_50:

.end_49:

.end_48:

.end_47:

.end_46:

.end_45:

.end_44:

.end_43:

.end_42:

.end_41:

.end_40:

.end_39:

    ; test if token type is 0
    push rax
    mov ax, word [rbp]
    cmp rax, 0
    pop rax
    jne .endif_token_type_is_not_zero

    ; todo - test atoi thoroughly

.endif_token_type_is_not_zero:
    ; create a token
    ; r8 - offset in source code, token start
    ; r9 - token length
    multipush rax, rbx, rcx, rdx, r15
    mov rbx, tokenList         ; load pointer to list
    mov eax, [dwTokenCount]    ; load token count
    mov rdx, Token.size        ; and size
    mul rdx                    ; calculate offset
    add rbx, rax               ; add offset to pointer
    mov rax, [rbp]    ; token type
    and rax, 0xffff
    mov [rbx + Token.TokenType], word ax ; token type
    mov [rbx + Token.TokenStart], r8 ; token start
    mov [rbx + Token.TokenLength], r9 ; token length
    mov rax, [dqCurrentLine]
    mov [rbx + Token.Line], rax ; line
    mov rax, r8
    sub rax, [dqLineStart]
    mov [rbx + Token.Column], rax ; column
    inc dword [dwTokenCount]
    multipop rax, rbx, rcx, rdx, r15

    mov [currentTokenStart], r8
    mov [currentTokenLength], r9

    PushCallerSavedRegs()
    PushCalleeSavedRegs()

	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 0
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenTypeIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLineIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenStartIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLengthIndex], rax
	mov rax, [tokenTypeIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenType]
	mov [rdx], rax
	mov rax, [tokenLineIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentLine]
	mov [rdx], rax
	mov rax, [tokenStartIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenStart]
	mov [rdx], rax
	mov rax, [tokenLengthIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenLength]
	mov [rdx], rax
	push qword [tokenCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenCount], rax

    PopCalleeSavedRegs()
    PopCallerSavedRegs()

    pop rbp
    add rsp, 8 ; restore stack pointer

    ; advance token start and reset token length
    _reset_counters_

.asm_literal_start:
    ; iterate until we find another '0x40'
    inc rdi
    push rdi
    xor r14, r14 ; store length of asm code

.asm_literal_loop:
    cmp byte [rdi], chAsmStart
    je .asm_literal_end
    cmp byte [rdi], 0xa
    je .asm_newline
.after_asm_newline:
    inc r14
    inc rdi
    jmp .asm_literal_loop

.asm_newline:
    call incrementCurrentLine
    jmp .after_asm_newline

.asm_literal_end:
    inc rdi ; move offset past trailing '0x40'
    pop r10 ; restore start of asm code from rdi to r10
    add r8, r14
    add r8, 2 

    multipush rax, rbx, rcx, rdx, r10, r14
    dec r10
    push r11
    mov r11, szSourceCode
    sub r10, r11
    pop r11
    add r14, 1
    mov rbx, tokenList         ; load pointer to list
    mov eax, [dwTokenCount]    ; load token count
    mov rdx, Token.size        ; and size
    mul rdx                    ; calculate offset
    add rbx, rax               ; add offset to pointer
    mov [rbx + Token.TokenType], word OperandAsmLiteral ; token type
    mov [rbx + Token.TokenStart], r10 ; token start
    mov [rbx + Token.TokenLength], r14 ; token start
    inc dword [dwTokenCount]
    multipop rax, rbx, rcx, rdx, r10, r14
    PushCallerSavedRegs()
    PushCalleeSavedRegs()
	push 17
	pop rax
	mov qword [currentTokenType], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 0
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenTypeIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLineIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenStartIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLengthIndex], rax
	mov rax, [tokenTypeIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenType]
	mov [rdx], rax
	mov rax, [tokenLineIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentLine]
	mov [rdx], rax
	mov rax, [tokenStartIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenStart]
	mov [rdx], rax
	mov rax, [tokenLengthIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenLength]
	mov [rdx], rax
	push qword [tokenCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenCount], rax

    PopCalleeSavedRegs()
    PopCallerSavedRegs()
    jmp .read_token_loop

.string_literal_start:
    inc rdi
    push rdi
    xor r14, r14 ; store length of string literal

.string_literal_loop:
    cmp byte [rdi], chDoubleQuote
    je .string_literal_end
    inc r14
    inc rdi
    jmp .string_literal_loop

.string_literal_end:
    inc rdi ; move offset past trailing '0x22'
    pop r10 ; restore start of string literal from rdi to r10
    add r8, r14
    add r8, 2 

    ; add token to token list
    multipush rax, rbx, rcx, rdx, r10, r14
    dec r10
    push r11
    mov r11, szSourceCode
    sub r10, r11
    pop r11
    add r14, 2
    mov rbx, tokenList         ; load pointer to list
    mov eax, [dwTokenCount]    ; load token count
    mov rdx, Token.size        ; and size
    mul rdx                    ; calculate offset
    add rbx, rax               ; add offset to pointer
    mov [rbx + Token.TokenType], word OperandStringLiteral ; token type
    mov [rbx + Token.TokenStart], r10 ; token start
    mov [rbx + Token.TokenLength], r14 ; token start
    inc dword [dwTokenCount]
    multipop rax, rbx, rcx, rdx, r10, r14
    PushCallerSavedRegs()
    PushCalleeSavedRegs()
	push 16
	pop rax
	mov qword [currentTokenType], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 0
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenTypeIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLineIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 2
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenStartIndex], rax
	push qword [tokenCount]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 3
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLengthIndex], rax
	mov rax, [tokenTypeIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenType]
	mov [rdx], rax
	mov rax, [tokenLineIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentLine]
	mov [rdx], rax
	mov rax, [tokenStartIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenStart]
	mov [rdx], rax
	mov rax, [tokenLengthIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	mov rax, [currentTokenLength]
	mov [rdx], rax
	push qword [tokenCount]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenCount], rax

    PopCalleeSavedRegs()
    PopCallerSavedRegs()
    jmp .read_token_loop
;-----------------------------------source code parsing----------------------------------

.source_code_parsed:
    mov r15d, dword [dwTokenCount]
    printf(roStr_46, r15)
    mov r14, 0
    mov r13, tokenList
    mov rcx, pNames
    call push_symbol_table
    mov rax, memory
    mov qword [pFreePointer], rax
	push 0
	pop rax
	mov qword [tokenI], rax

.while_72:
	mov r15, [tokenI]
	cmp r15, [tokenCount]
	jge .end_72
;do_72:
	push qword [tokenI]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 0
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenTypeIndex], rax
	push qword [tokenI]
	push qword [tokenSize]
	pop rax
	pop rcx
	xor rdx, rdx
	mul rcx
	push rax
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenLineIndex], rax
	mov rax, [tokenTypeIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [tokenTypeValue], rax
	mov rax, [tokenLineIndex]
	mov rdx, 8
	mul rdx
	mov rdx, tokens
	add rdx, rax
	push qword [rdx]
	pop rax
	mov qword [tokenLineValue], rax
	push qword [tokenI]
	push 1
	pop rax
	pop rcx
	add rax, rcx
	push rax
	pop rax
	mov qword [tokenI], rax

    jmp .while_72
    ; end while_72
.end_72:

%define NextToken() nextToken
%macro nextToken 0
    add rdx, Token.size ; jump to next token
    mov rbx, [tokenIndex]
    inc rbx
    mov [tokenIndex], rbx
    jmp .while_counter_less_than_token_count
%endmacro

%define SkipTokens(n) skip_tokens n
%macro skip_tokens 1
    multipush rax, rdx
    mov rax, Token.size
    mov rdx, %1
    mul rdx
    pop rdx
    add rdx, rax
    pop rax
    mov rbx, [tokenIndex]
    add rbx, %1
    mov [tokenIndex], rbx
%endmacro

%define PushBlockToken(tokenType, scopeId) pushBlockToken tokenType, scopeId
%macro pushBlockToken 2
    multipush rax, rbx, rdx
    mov rbx, blockStack
    mov rax, [blockCount]
    mov rdx, Block.size 
    mul rdx
    add rbx, rax                          ; rbx points to just after the top of the stack
    mov rax, [tokenIndex]
    mov [rbx + Block.TokenIndex], rax
    ; this is a bug, current scope needs to be passed as arg
    mov rax, %2
    mov [rbx + Block.BlockId], rax
    mov [rbx + Block.TokenType], word %1  ; push token type
    inc qword [blockCount]                ; increment block count
    multipop rax, rbx, rdx
%endmacro

%define PopBlockToken() popBlockToken
%macro popBlockToken 0
    multipush rbx, rdx
    mov rbx, blockStack
    dec qword [blockCount]   ; decrement block count
    mov rax, [blockCount]
    mov rdx, Block.size 
    mul rdx
    add rax, rbx             ; rbx points to top of the stack
    multipop rbx, rdx
%endmacro

%define PeekBlockToken() peekBlockToken
%macro peekBlockToken 0
    multipush rbx, rdx
    mov rbx, blockStack
    mov rax, [blockCount]
    mov rdx, Block.size 
    mul rdx
    add rax, rbx
    sub rax, Block.size ; rbx points to top of the stack
    multipop rbx, rdx
%endmacro

; this will only decrement the block count
%define QuickPopBlockToken() dec qword [blockCount]

%ifdef DEBUG    
    push rbx
    mov ebx, dword [dwTokenCount]
    printf(roStr_47, rbx)
    pop rbx
%endif

; ---------------------- START OF ASM OUTPUT ----------------------
    ; write asm header
    WriteFile([hndDestFile], cStrAsmHeader, cStrAsmHeader.length, dwBytesWritten)

    ; iterate over tokens
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 ; reserve space on the stack for the token index

    xor rbx, rbx ; counter
    mov rdx, tokenList
    
    ; initialize counters
    mov r10, 0
    mov [wScopedBlockCurrentId], r10

%define currentToken.Type word [rdx + Token.TokenType]
%define currentToken.Start dword [rdx + Token.TokenStart]
%define currentToken.Length dword [rdx + Token.TokenLength]

.while_counter_less_than_token_count:
    mov rbx, [tokenIndex]
    cmp ebx, [dwTokenCount]
    jge .end_counter_less_than_token_count
    mov r14w, currentToken.Type
    ; printf(roStr_48, r14)
%ifdef DEBUG    
    PushCallerSavedRegs()
    printf(roStr_49, rbx)
    PopCallerSavedRegs()
%endif
;.if_73:
    cmp currentToken.Type, defKeywordThen
	jne .end_73
;then_73:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_73:

;.if_74:
    cmp currentToken.Type, defKeywordDo
	jne .end_74
;then_74:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_74:


    cmp qword [bProcessingIfCondition], 0
    je .continue_processing
    NextToken()

.continue_processing:

;.if_75:
    cmp currentToken.Type, defOperandAsmLiteral
	jne .end_75
;then_75:

        PushCallerSavedRegs()
  
        ; write asm code
        mov r10d, currentToken.Start
        mov r11, szSourceCode
        add r10, r11
        inc r10 ; skip leading '0x40'
        mov r11d, currentToken.Length
        dec r11 ; skip trailing '0x40'

        WriteFile([hndDestFile], r10, r11, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_75:
 ; keyword 'if'
;.if_76:
    cmp currentToken.Type, defKeywordIf
	jne .end_76
;then_76:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_50, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordIf, [wScopedBlockCurrentId])
        
        inc word [wScopedBlockCurrentId]
        push r15
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15
        PopCallerSavedRegs()
        NextToken()
.end_76:
; keyword 'then'
;.if_77:
    cmp currentToken.Type, defKeywordThen
	jne .end_77
;then_77:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_51, rbx)
        %endif 
;.if_78:
    cmp bx, KeywordIf
	je .end_78
;then_78:

            printf(roStr_52, szSourceFile)
            jmp .exit
.end_78:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_79:
    cmp r10d, 3
	je .end_79
;then_79:

;.if_80:
    cmp r10d, 1
	je .end_80
;then_80:

                printf(roStr_53, r10)
                jmp .exit
.end_80:

.end_79:

;.if_81:
    cmp r10d, 3
	jne .else_81
;then_81:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_81
.else_81:

;.if_82:
    cmp r10d, 1
	jne .end_82
;then_82:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_82:

.end_81:

    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_54, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        ; bx stores block id
        mov cx, bx
        PushBlockToken(KeywordThen, rcx)

        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_77:
; keyword 'else'
;.if_83:
    cmp currentToken.Type, defKeywordElse
	jne .end_83
;then_83:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_84:
    cmp bx, KeywordThen
	je .end_84
;then_84:

            printf(roStr_55, szSourceFile)
            jmp .exit
.end_84:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_56, rbx, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_83:
; keyword 'end'
;.if_85:
    cmp currentToken.Type, defKeywordEnd
	jne .end_85
;then_85:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_86:
    cmp bx, KeywordThen
	je .end_86
;then_86:

;.if_87:
    cmp bx, KeywordElse
	je .end_87
;then_87:

;.if_88:
    cmp bx, KeywordDo
	je .end_88
;then_88:

                    printf(roStr_57, szSourceFile)
                    jmp .exit
                    
.end_88:

.end_87:

.end_86:

;.if_89:
    cmp bx, KeywordDo
	jne .end_89
;then_89:

            mov bx, word [rax + Block.BlockId]
            and rbx, 0xffff 
            sprintf(ptrBuffer64, roStr_58, rbx, rbx)
            WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_89:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_59, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        QuickPopBlockToken() ; pop 'then' or 'do'
        QuickPopBlockToken() ; pop 'if' or 'while'

        PopCallerSavedRegs()
        NextToken()
.end_85:
; keyword 'while'
;.if_90:
    cmp currentToken.Type, defKeywordWhile
	jne .end_90
;then_90:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_60, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordWhile, [wScopedBlockCurrentId])
        
        push r15    
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15

        inc word [wScopedBlockCurrentId]
        PopCallerSavedRegs()
        NextToken()
.end_90:
; keyword 'do'
;.if_91:
    cmp currentToken.Type, defKeywordDo
	jne .end_91
;then_91:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_61, rbx)
        %endif 
;.if_92:
    cmp bx, KeywordWhile
	je .end_92
;then_92:

            printf(roStr_62, szSourceFile)
            jmp .exit
.end_92:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_93:
    cmp r10d, 3
	je .end_93
;then_93:

;.if_94:
    cmp r10d, 1
	je .end_94
;then_94:

                printf(roStr_63, r10)
                jmp .exit
.end_94:

.end_93:

;.if_95:
    cmp r10d, 3
	jne .else_95
;then_95:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_while_condition_3
            PopCallerSavedRegs()
	jmp .end_95
.else_95:

;.if_96:
    cmp r10d, 1
	jne .end_96
;then_96:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_96:

.end_95:


    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_64, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        ; bx stores block id
        mov cx, bx
        PushBlockToken(KeywordDo, rcx)

        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_91:
; keyword 'continue'
;.if_97:
    cmp currentToken.Type, defKeywordContinue
	jne .end_97
;then_97:

        PushCallerSavedRegs()

        ; find the nearest 'while' block
        multipush r15, rax, rdx
        mov rbx, [blockCount]
        mov rax, rbx
        mov rdx, Block.size
        mul rdx
        mov r15, blockStack
        add r15, rax
        multipop rax, rdx
.while_98:
    cmp rbx, 0
	jle .end_98
;do_98:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_99:
    cmp r10, KeywordWhile
	jne .end_99
;then_99:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_65, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_99:

    jmp .while_98
    ; end while_98
.end_98:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_97:
; keyword 'break'
;.if_100:
    cmp currentToken.Type, defKeywordBreak
	jne .end_100
;then_100:

        PushCallerSavedRegs()

        ; find the nearest 'while' block
        multipush r15, rax, rdx
        mov rbx, [blockCount]
        mov rax, rbx
        mov rdx, Block.size
        mul rdx
        mov r15, blockStack
        add r15, rax
        multipop rax, rdx
.while_101:
    cmp rbx, 0
	jle .end_101
;do_101:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_102:
    cmp r10, KeywordWhile
	jne .end_102
;then_102:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_66, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_102:

    jmp .while_101
    ; end while_101
.end_101:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_100:
 ; keyword 'uint64'
;.if_103:
    cmp currentToken.Type, defKeywordDefineUInt64
	jne .end_103
;then_103:

        PushCallerSavedRegs()

        ; look ahead for identifier
        multipush rax, rbx, r13, r14, r15
        mov rax, rbx
        inc rax
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax
        
        ; get identifier
        mov r12w, word [rbx + Token.TokenType]
        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
;.if_104:
    cmp r12w, defOperandLiteral
	je .end_104
;then_104:

            printf(roStr_67)
            jmp .exit
.end_104:


        strcpy(ptrBuffer64, r13, r15)

        multipush rax, rcx, rdx
        mov rcx, ptrBuffer64
        mov rdx, TYPE_UINT64
        mov r8, 8
        call push_variable
        multipop rax, rcx, rdx
        
        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_105:
    cmp r12w, defOperatorAssignment
	je .end_105
;then_105:

            push rbx
            printf(roStr_68)
            pop rbx
            sub rbx, Token.size
            mov r13, qword [rbx + Token.Line]
            mov r14, qword [rbx + Token.Column]
            printf(roStr_69, r13, r14)
            jmp .exit
.end_105:


        ; get value
        add rbx, Token.size

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15)

        multipop rax, rbx, r13, r14, r15
        sub rbx, Token.size

        ; todo - write them at the top of asm file
        ; write variable declaration
        sprintf(ptrBuffer256, roStr_70, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_103:
 ; keyword 'uint8'
;.if_106:
    cmp currentToken.Type, defKeywordDefineUInt8
	jne .end_106
;then_106:

        PushCallerSavedRegs()

        ; look ahead for identifier
        multipush rax, rbx, r13, r14, r15
        mov rax, rbx
        inc rax
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax
        
        ; get identifier
        mov r12w, word [rbx + Token.TokenType]
        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
;.if_107:
    cmp r12w, defOperandLiteral
	je .end_107
;then_107:

            printf(roStr_71)
            jmp .exit
.end_107:


        strcpy(ptrBuffer64, r13, r15)

        multipush rax, rcx, rdx
        mov rcx, ptrBuffer64
        mov rdx, TYPE_UINT8
        mov r8, 1
        call push_variable
        multipop rax, rcx, rdx
        
        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_108:
    cmp r12w, defOperatorAssignment
	je .end_108
;then_108:

            push rbx
            printf(roStr_72)
            pop rbx
            sub rbx, Token.size
            mov r13, qword [rbx + Token.Line]
            mov r14, qword [rbx + Token.Column]
            printf(roStr_73, r13, r14)
            jmp .exit
.end_108:


        ; get value
        add rbx, Token.size

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15)

        multipop rax, rbx, r13, r14, r15
        sub rbx, Token.size

        ; todo - write them at the top of asm file
        ; write variable declaration
        sprintf(ptrBuffer256, roStr_74, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_106:
; literal 
;.if_109:
    cmp currentToken.Type, defOperandLiteral
	jne .end_109
;then_109:

        PushCallerSavedRegs()

        ; look ahead for assignment operator
        multipush rax, rbx, rdx, r10, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr3Buffer64, r13, r15) ; literal name

        printf(roStr_75, ptr3Buffer64)
   
        ; fetch data type from names table
        multipush rax, rcx
        mov rcx, ptr3Buffer64
        call get_data_type
        mov r15, rax
        mov r11, rdx ; data type size in bytes
        mov [dqCurrentAssignedOperandValue], r8  ; value (or pointer to a structure)
        multipop rax, rcx
        printf(roStr_76, ptr3Buffer64, r15)
        
;.if_110:
    cmp r15, TYPE_PROC
	jne .else_110
;then_110:

            sprintf(ptrBuffer256, roStr_77, ptr3Buffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
            multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

            PopCallerSavedRegs()
            NextToken()
	jmp .end_110
.else_110:

;.if_111:
    cmp r15, TYPE_ARRAY
	jne .else_111
;then_111:

            mov qword [dqStatementOpCount], 1
            
            ; todo - verify that the next token is a '['            
            add rbx, Token.size
            inc qword [dqStatementOpCount]

            ; read index
            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            mov r10, r12 ; store index type
            strcpy(ptrBuffer64, r15, r14)
            
            inc qword [dqStatementOpCount]
            
            ; todo - verify that the next token is a ']'
            add rbx, Token.size
            inc qword [dqStatementOpCount]

            ; todo - verify that the next token is an assignment operator
            add rbx, Token.size
            inc qword [dqStatementOpCount]

            ; read value
            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13

            strcpy(ptr2Buffer64, r15, r14)
            inc qword [dqStatementOpCount]
;.if_112:
    cmp r10w, defOperandInteger
	jne .else_112
;then_112:

;.if_113:
    cmp r11, 1
	jne .else_113
;then_113:

                    sprintf(ptrBuffer256, roStr_78, ptr3Buffer64, ptrBuffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_113
.else_113:

;.if_114:
    cmp r11, 8
	jne .else_114
;then_114:

                    sprintf(ptrBuffer256, roStr_79, ptrBuffer64, ptr3Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_114
.else_114:

                    printf(roStr_80, r11)
                    printf(roStr_81, qword [rbx + Token.Line], qword [rbx + Token.Column])
                    jmp .exit
.end_114:

.end_113:

	jmp .end_112
.else_112:

;.if_115:
    cmp r11, 1
	jne .else_115
;then_115:

                sprintf(ptrBuffer256, roStr_82, ptr3Buffer64, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_115
.else_115:

;.if_116:
    cmp r11, 8
	jne .else_116
;then_116:

                sprintf(ptrBuffer256, roStr_83, ptrBuffer64, ptr3Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_116
.else_116:

                printf(roStr_84, r11)
                printf(roStr_85, qword [rbx + Token.Line], qword [rbx + Token.Column])
                jmp .exit
.end_116:

.end_115:

.end_112:

;.if_117:
    cmp r12w, defOperandInteger
	jne .else_117
;then_117:

;.if_118:
    cmp r11, 1
	jne .else_118
;then_118:

                    sprintf(ptrBuffer256, roStr_86, ptr2Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_118
.else_118:

;.if_119:
    cmp r11, 8
	jne .else_119
;then_119:

                    sprintf(ptrBuffer256, roStr_87, ptr2Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_119
.else_119:

                    printf(roStr_88, r11)
                    printf(roStr_89, qword [rbx + Token.Line], qword [rbx + Token.Column])
                    jmp .exit
.end_119:

.end_118:

	jmp .end_117
.else_117:

                multipush rax, rcx
                mov rcx, ptr2Buffer64
                call get_data_type
                mov r15, rax
                mov r11, rdx ; data type size in bytes
                multipop rax, rcx 
;.if_120:
    cmp r8, 0
	je .else_120
;then_120:

                    sprintf(ptrBuffer256, roStr_90, r8)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_120
.else_120:

;.if_121:
    cmp r11, 1
	jne .else_121
;then_121:

                        sprintf(ptrBuffer256, roStr_91, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_121
.else_121:

;.if_122:
    cmp r11, 8
	jne .else_122
;then_122:

                        sprintf(ptrBuffer256, roStr_92, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_122
.else_122:

                        printf(roStr_93, r11)
                        printf(roStr_94, qword [rbx + Token.Line], qword [rbx + Token.Column])
                        jmp .exit
.end_122:

.end_121:

.end_120:

.end_117:

            ; todo - verify that the next token is a ';'
            add rbx, Token.size
	jmp .end_111
.else_111:

            ; check if assignment operator is next
            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]
;.if_123:
    cmp r12w, defOperatorAssignment
	je .end_123
;then_123:

                printf(roStr_95)
                jmp .exit
.end_123:


            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]

            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            strcpy(ptrBuffer64, r15, r14) 
            mov qword [dqStatementOpCount], 1
            ; fetch data type from names table
            multipush rax, rcx
            mov rcx, ptrBuffer64
            call get_data_type
            mov r15, rax ; date type
            mov r11, rdx ; data type size in bytes
            multipop rax, rcx

            printf(roStr_96, r15, ptrBuffer64)
            
;.if_124:
    cmp r15, TYPE_PROC
	jne .end_124
;then_124:

                printf(roStr_97)
                ; look for opening parenthesis
                add rbx, Token.size
                mov qword [dqStatementOpCount], 3
                
                add rbx, Token.size
                mov r12w, word [rbx + Token.TokenType]
                movzx r13, word [rbx + Token.TokenStart]
                movzx r14, word [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptr2Buffer64, r15, r14) 
                xor r10, r10
                
.while_125:
    cmp r12w, defParenClose
	je .end_125
;do_125:

                    ; just advance to parenthesis close
                    ; then we walk back and process the arguments
                    inc qword [dqStatementOpCount]
                    add rbx, Token.size
                    mov r12w, word [rbx + Token.TokenType]
                    add r10, 8
    jmp .while_125
    ; end while_125
.end_125:


                ; go back to last argument
                sub rbx, Token.size
                mov r12w, word [rbx + Token.TokenType]
                movzx r13, word [rbx + Token.TokenStart]
                movzx r14, word [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptr2Buffer64, r15, r14)
                
                multipush rax, rcx, r10
                mov rcx, ptr2Buffer64
                call get_data_type
                mov r15, rax
                mov r11, rdx ; data type size in bytes
                mov [dqCurrentParamValue], r8  ; value (or pointer to a structure)
                multipop rax, rcx, r10
.while_126:
    cmp r12w, defParenOpen
	je .end_126
;do_126:

;.if_127:
    cmp r12w, defOperandInteger
	jne .else_127
;then_127:

                        ; push to operator stack
                        sprintf(ptrBuffer256, roStr_98, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_127
.else_127:

;.if_128:
    cmp r8, 0
	je .else_128
;then_128:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_99, [dqCurrentParamValue])
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_128
.else_128:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_100, ptr2Buffer64)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_128:

.end_127:

                    sub rbx, Token.size
                    mov r12w, word [rbx + Token.TokenType]
                    movzx r13, word [rbx + Token.TokenStart]
                    movzx r14, word [rbx + Token.TokenLength]
                    mov r15, szSourceCode
                    add r15, r13
                    strcpy(ptr2Buffer64, r15, r14) 
                    
                    multipush rax, rcx, r10
                    mov rcx, ptr2Buffer64
                    call get_data_type
                    mov r15, rax
                    mov r11, rdx ; data type size in bytes
                    mov [dqCurrentParamValue], r8  ; value (or pointer to a structure)
                    multipop rax, rcx, r10
    jmp .while_126
    ; end while_126
.end_126:



                inc qword [dqStatementOpCount] ; skip ')' token
                inc qword [dqStatementOpCount] ; skip ';' token
                sprintf(ptrBuffer256, roStr_101, ptrBuffer64, ptr3Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                sprintf(ptrBuffer256, roStr_102, r10)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

                PopCallerSavedRegs()
                SkipTokens([dqStatementOpCount])
                NextToken()
.end_124:

.while_129:
    cmp r12w, defStatemendEnd
	je .end_129
;do_129:

;.if_130:
    cmp r12w, defOperandInteger
	jne .else_130
;then_130:

                    ; push to operator stack
                    sprintf(ptrBuffer256, roStr_103, ptrBuffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_130
.else_130:

;.if_131:
    cmp r12w, defOperandLiteral
	jne .else_131
;then_131:

                    ; fetch data type from names table
                    multipush rax, rcx
                    mov rcx, ptrBuffer64
                    call get_data_type
                    mov r15, rax
                    mov r11, rdx ; data type size in bytes
                    mov r10, r8 ; value (or pointer to a structure)
                    multipop rax, rcx
;.if_132:
    cmp r15, TYPE_ARRAY
	jne .else_132
;then_132:

                        push rax
                        ; todo - verify that the next token is a '['
                        add rbx, Token.size * 2
                        movzx r12, word [rbx + Token.TokenType]
                        movzx r13, word [rbx + Token.TokenStart]
                        movzx r14, word [rbx + Token.TokenLength]
                        mov r15, szSourceCode
                        add r15, r13
                        strcpy(ptr2Buffer64, r15, r14) 
;.if_133:
    cmp r11, 1
	jne .else_133
;then_133:

                            sprintf(ptrBuffer256, roStr_104, ptrBuffer64, ptr2Buffer64)
	jmp .end_133
.else_133:

;.if_134:
    cmp r11, 8
	jne .else_134
;then_134:

                            sprintf(ptrBuffer256, roStr_105, ptr2Buffer64, ptrBuffer64)
	jmp .end_134
.else_134:

                            printf(roStr_106, r11)
                            printf(roStr_107, qword [rbx + Token.Line], qword [rbx + Token.Column])
                            jmp .exit
.end_134:

.end_133:

                        
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                        mov rax, [dqStatementOpCount]
                        add rax, 3
                        mov [dqStatementOpCount], rax
                        pop rax
                        add rbx, Token.size
	jmp .end_132
.else_132:

;.if_135:
    cmp r10, 0
	je .else_135
;then_135:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_108, r10)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_135
.else_135:
    
                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_109, ptrBuffer64)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_135:

.end_132:

	jmp .end_131
.else_131:

;.if_136:
    cmp r12w, defOperandInteger
	je .end_136
;then_136:

                    multipush rax, rcx, rdx
                    mov rcx, r12
                    call push_operator
                    multipop rax, rcx, rdx
.end_136:

.end_131:

.end_130:

                add rbx, Token.size
                movzx r12, word [rbx + Token.TokenType]
                movzx r13, word [rbx + Token.TokenStart]
                movzx r14, word [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptrBuffer64, r15, r14)
                inc qword [dqStatementOpCount]
    jmp .while_129
    ; end while_129
.end_129:

.while_137:
    cmp qword[dqOperatorCount], 0
	jl .end_137
;do_137:

                call write_operator
    jmp .while_137
    ; end while_137
.end_137:

            
             ; fetch data type from names table
            multipush rax, rcx
            mov rcx, ptr3Buffer64
            call get_data_type
            mov r15, rax
            mov r11, rdx ; data type size in bytes
            multipop rax, rcx
            
;.if_138:
    cmp r15, 0
	jne .end_138
;then_138:

                printf(roStr_110, ptr3Buffer64)
                jmp .exit
.end_138:

;.if_139:
    cmp r15, TYPE_UINT8
	jne .else_139
;then_139:

                sprintf(ptrBuffer256, roStr_111, ptr3Buffer64)
	jmp .end_139
.else_139:

;.if_140:
    cmp r15, TYPE_UINT64
	jne .else_140
;then_140:

                mov r10, [dqCurrentAssignedOperandValue]
;.if_141:
    cmp r10, 0
	je .else_141
;then_141:

                    sprintf(ptrBuffer256, roStr_112, r10)
	jmp .end_141
.else_141:

                    sprintf(ptrBuffer256, roStr_113, ptr3Buffer64)
.end_141:

	jmp .end_140
.else_140:

                printf(roStr_114, ptr3Buffer64, r11)
                printf(roStr_115, qword [rbx + Token.Line], qword [rbx + Token.Column])
                jmp .exit
.end_140:

.end_139:

            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_111:

.end_110:


        multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_109:
; eval 
;.if_142:
    cmp currentToken.Type, defKeywordEval
	jne .end_142
;then_142:

        PushCallerSavedRegs()

        ; look ahead for assignment operator
        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
        add rbx, 2
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax

        ; todo - check if assignment operator is present

        movzx r12, word [rbx + Token.TokenType]
        movzx r13, word [rbx + Token.TokenStart]
        movzx r14, word [rbx + Token.TokenLength]
        mov r15, szSourceCode
        add r15, r13
        strcpy(ptrBuffer64, r15, r14) 
        mov qword [dqStatementOpCount], 1
        
.while_143:
    cmp r12w, defStatemendEnd
	je .end_143
;do_143:

;.if_144:
    cmp r12w, defOperandInteger
	jne .else_144
;then_144:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_116, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_144
.else_144:

;.if_145:
    cmp r12w, defOperandLiteral
	jne .else_145
;then_145:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_117, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_145
.else_145:

;.if_146:
    cmp r12w, defOperandInteger
	je .end_146
;then_146:

                multipush rax, rcx, rdx
                mov rcx, r12
                call push_operator
                multipop rax, rcx, rdx
.end_146:

.end_145:

.end_144:

            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            strcpy(ptrBuffer64, r15, r14)
            inc qword [dqStatementOpCount]
    jmp .while_143
    ; end while_143
.end_143:

.while_147:
    cmp qword[dqOperatorCount], 0
	jl .end_147
;do_147:

            call write_operator
    jmp .while_147
    ; end while_147
.end_147:


        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_142:
; array 
;.if_148:
    cmp currentToken.Type, defKeywordArray
	jne .end_148
;then_148:

        PushCallerSavedRegs()

        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax ; this points to 'array' token

        ; look ahead for identifier
        add rbx, Token.size

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; literal name

        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_149:
    cmp r12w, defOperatorAssignment
	je .end_149
;then_149:

            printf(roStr_118)
            jmp .exit
.end_149:


        ; get element type
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_150:
    cmp r12w, defKeywordDefineUInt8
	jne .else_150
;then_150:

            mov r11, 1
	jmp .end_150
.else_150:

;.if_151:
    cmp r12w, defKeywordDefineUInt64
	jne .else_151
;then_151:

            mov r11, 8
	jmp .end_151
.else_151:

            printf(roStr_119)
            jmp .exit
.end_151:

.end_150:


        ; skip '['
        ; todo - check if '[' is present
        add rbx, Token.size

        ; get array size
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_152:
    cmp r12w, defOperandInteger
	je .end_152
;then_152:

            printf(roStr_120)
            jmp .exit
.end_152:


        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15) ; array size

        ; skip ']'
        ; todo - check if ']' is present
        add rbx, Token.size

        ; check if ';' is present
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_153:
    cmp r12w, defStatemendEnd
	je .end_153
;then_153:

            printf(roStr_121)
            jmp .exit
.end_153:


        multipush rax, rcx, rdx, r8
        mov rcx, ptrBuffer64
        mov rdx, TYPE_ARRAY
        mov r8, r11
        call push_variable
        multipop rax, rcx, rdx, r8
;.if_154:
    cmp r11, 1
	jne .else_154
;then_154:

            sprintf(ptrBuffer256, roStr_122, ptrBuffer64, ptr2Buffer64)
	jmp .end_154
.else_154:

;.if_155:
    cmp r11, 8
	jne .else_155
;then_155:

            sprintf(ptrBuffer256, roStr_123, ptrBuffer64, ptr2Buffer64)
	jmp .end_155
.else_155:

            printf(roStr_124)
            jmp .exit
.end_155:

.end_154:


        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(7)
        NextToken()
.end_148:
; keyword 'proc'
;.if_156:
    cmp currentToken.Type, defKeywordProc
	jne .end_156
;then_156:

        PushCallerSavedRegs()

        multipush rax, rbx, rdx, r10, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax ; rax now points to 'proc' token

        ; look ahead for identifier
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
        mov qword [dqStatementOpCount], 1 
;.if_157:
    cmp r12w, defKeywordForward
	jne .end_157
;then_157:

            ; skip 'forward'
            add rbx, Token.size
            inc qword [dqStatementOpCount]
.end_157:


        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; name of the procedure
;.if_158:
    cmp r12w, defKeywordForward
	jne .end_158
;then_158:

            ; save current procedure and its symbol table
            multipush rax, rcx, rdx, r8, r9
            mov rcx, ptrBuffer64
            mov rdx, TYPE_PROC
            mov r8, 0
            mov r9, 0
            call push_variable
            multipop rax, rcx, rdx, r8, r9
            
            multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

            PopCallerSavedRegs()
            SkipTokens([dqStatementOpCount])
            NextToken()
.end_158:

        sprintf(ptrBuffer256, roStr_125, ptrBuffer64, ptrBuffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
        inc qword [dqStatementOpCount]
;.if_159:
    cmp r12w, defParenOpen
	je .end_159
;then_159:

            printf(roStr_126)
            jmp .exit
.end_159:


        ; move to first argument
        add rbx, Token.size
        push rbx ; save rbx for later. right now we only count the number of arguments
        mov r12w, word [rbx + Token.TokenType]
        inc qword [dqStatementOpCount]
        mov qword [currentProcArgCount], 0
.while_160:
    cmp r12w, defParenClose
	je .end_160
;do_160:

            inc qword [currentProcArgCount]

            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]
            inc qword [dqStatementOpCount]
    jmp .while_160
    ; end while_160
.end_160:


        pop rbx ; restore rbx
        mov r12w, word [rbx + Token.TokenType]
        printf(roStr_127, ptrBuffer64, qword [currentProcArgCount])
        
        ; allocate symbol table for the procedure
        mov rax, qword [currentProcArgCount] 
        mov rdx, Name.size
        mul rdx
        mov rcx, rax
        call alloc_mem
        mov [pCurrentProcedureSymbolTable], rax

        ; save current procedure and its symbol table
        multipush rax, rcx, rdx, r8, r9
        mov rcx, ptrBuffer64
        mov rdx, TYPE_PROC
        mov r8, 0
        mov r9, rax
        call push_variable
        multipop rax, rcx, rdx, r8, r9

        ; push arguments to proc's symbol table
        ; all arguments should be of type uint64
        ; and can be used inside the proc body
        mov rcx, [pCurrentProcedureSymbolTable]
        call push_symbol_table

        ; this will be offset from rbp
        mov qword [currentProcArgCount], 16
        
.while_161:
    cmp r12w, defParenClose
	je .end_161
;do_161:

            ; get argument name
            mov r14w, word [rbx + Token.TokenStart]
            mov r15w, word [rbx + Token.TokenLength]
            mov r13, szSourceCode
            add r13, r14
            strcpy(ptr2Buffer64, r13, r15) ; name of the argument

            printf(roStr_128, ptr2Buffer64)
            
            ; push argument name to proc's symbol table
            multipush rax, rcx, rdx, r8, r9
            mov rcx, ptr2Buffer64
            mov rdx, TYPE_UINT64
            mov r8, 8
            mov r9, [currentProcArgCount]
            call push_variable
            add qword [currentProcArgCount], 8
            multipop rax, rcx, rdx, r8, r9

            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]
    jmp .while_161
    ; end while_161
.end_161:


        printf(roStr_129, ptrBuffer64)

        multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_156:
; keyword 'endproc'
;.if_162:
    cmp currentToken.Type, defKeywordEndProc
	jne .end_162
;then_162:

        PushCallerSavedRegs()

        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax ; this points to 'array' token

        ; look ahead for identifier
        add rbx, Token.size

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; literal name

        sprintf(ptrBuffer256, roStr_130, ptrBuffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        ; it's now safe to pop the current procedure and its symbol table
        call pop_symbol_table

        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(1)
        NextToken()
.end_162:

;.if_163:
    cmp currentToken.Type, defOperandStringLiteral
	jne .end_163
;then_163:

        ; todo - optimize strings by removing duplicate strings
        PushCallerSavedRegs()

        push rdx
        sprintf(ptrBuffer64, roStr_131, [dwStringCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        pop rdx

        mov ecx, currentToken.Start
        mov edx, currentToken.Length
        call push_string_literal

        PopCallerSavedRegs()

        NextToken()
.end_163:


    mov r10w, currentToken.Type
    mov r11d, currentToken.Start
    mov r12d, currentToken.Length

%ifdef DEBUG
    printf(roStr_132, r10, r11, r12)
%endif

    push rax
    mov rax, szSourceCode
    add r11, rax
    strcpy(ptrBuffer64, r11, r12)

    ; printf(roStr_133, ptrBuffer64)
    ; jmp .exit
    pop rax

    NextToken()
.end_counter_less_than_token_count:

%undef currentToken.Type
%undef currentToken.Start
%undef currentToken.Length

    call write_string_list

    pop rbp

    mov rcx, [hndDestFile]
    call CloseHandle

    printf(roStr_134, szSourceFile)

    jmp .assemble_object_file

.exit:
    ExitProcess(0)
    
.assemble_object_file:
    sprintf(ptrBuffer256, roStr_135, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_136, ptrBuffer256)

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
    mov rdx, ptrBuffer256                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8 
;.if_164:
    cmp rax, 0
	jne .end_164
;then_164:

        printf(roStr_137)
        ExitProcess(1)
.end_164:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_138, [lpExitCode])
    mov rax, [lpExitCode]
    
;.if_165:
    cmp rax, 0
	je .end_165
;then_165:

        printf(roStr_139)
        ExitProcess(1)
.end_165:


    sprintf(ptrBuffer256, roStr_140, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_141, ptrBuffer256)
    
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
    mov rdx, ptrBuffer256                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8
;.if_166:
    cmp rax, 0
	jne .end_166
;then_166:

        printf(roStr_142)
        ExitProcess(1)
.end_166:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
;.if_167:
    cmp rax, 0
	je .end_167
;then_167:

        printf(roStr_143)
        ExitProcess(1)
.end_167:


    ; delete object file
%ifdef DEBUG
    printf(roStr_144)
%endif

    sprintf(ptrBuffer256, roStr_145, szFilenameWithoutExtension)
    mov rcx, ptrBuffer256
    call DeleteFileA
;.if_168:
    cmp rax, 0
	jne .end_168
;then_168:

        printf(roStr_146)
.end_168:


    printf(roStr_147, szFilenameWithoutExtension, szFilenameWithoutExtension)
    jmp .exit

get_data_type:
    PushCalleeSavedRegs()

    mov r15, rcx ; r15 holds pointer to name
    xor r11, r11
    mov r14, [dqNameCount]
    mov r13, 0
    mov r10, [pCurrentSymbolTable]
.while_169:
    cmp r13, r14
	jge .end_169
;do_169:

        mov r12, [r10 + Name.Pointer]
        strcmp(r12, r15)
;.if_170:
    cmp rax, 0
	jne .end_170
;then_170:

            mov r11, [r10 + Name.Type]
            mov rdx, [r10 + Name.DataSize]
            mov r8, [r10 + Name.Value]
    jmp .end_169

.end_170:

        add r10, Name.size
        inc r13
    jmp .while_169
    ; end while_169
.end_169:

;.if_171:
    cmp r11, 0
	jne .end_171
;then_171:

        mov rcx, r15
        call get_global_data_type
        mov r11, rax
.end_171:


.end:
    mov rax, r11
    PopCalleeSavedRegs()
    ret

get_global_data_type:
    PushCalleeSavedRegs()

    mov r15, symbolTables
    add r15, SymbolTable.SymbolCount

    xor r11, r11
    mov r14, [r15]
    mov r13, 0
    mov r10, pNames
    mov r15, rcx ; r15 holds pointer to name
    
.while_172:
    cmp r13, r14
	jge .end_172
;do_172:

        mov r12, [r10 + Name.Pointer]
        strcmp(r12, r15)
;.if_173:
    cmp rax, 0
	jne .end_173
;then_173:

            mov r11, [r10 + Name.Type]
            mov rdx, [r10 + Name.DataSize]
            mov r8, [r10 + Name.Value]
    jmp .end_172

.end_173:

        add r10, Name.size
        inc r13
    jmp .while_172
    ; end while_172
.end_172:


.end:
    mov rax, r11
    PopCalleeSavedRegs()
    ret

; this routine will save a name to the variable list, along with its type
; rcx holds a null terminated string
; rdx holds the type
; r8 holds the data size
; r9 holds the value (or pointer to a structure)
push_variable:
    PushCalleeSavedRegs()
    
    mov r15, rdx
    mov r14, rcx

    ; set up array
    mov rax, [dqNameCount]
    mov rdx, Name.size
    mul rdx
    mov rdx, [pCurrentSymbolTable]
    add rax, rdx
    mov r13, rax

    ; store name
    mov r12, [pszNameEndPointer]
    mov rsi, r14
    mov rdi, r12

.loop:
    cmp byte [rsi], 0
    je .end_loop
    movsb
    jmp .loop

.end_loop:
    ; store pointer to name
    mov [r13 + Name.Pointer], r12

    ; store type
    mov [r13 + Name.Type], r15

    ; store data size
    mov [r13 + Name.DataSize], r8
    mov [r13 + Name.Value], r9

    ; increment name count  
    add r13, Name.size
    inc rdi
    mov [pszNameEndPointer], rdi
    
    inc qword [dqNameCount]

.end:
    PopCalleeSavedRegs()
    mov rax, r12
    ret

; this routine will save a string literal to the string list
; rcx holds token start, rdx holds token length
push_string_literal:
    PushCalleeSavedRegs()

    mov r15, szSourceCode
    add r15, rcx
    mov r14, rdx

    ; todo - check if string literal already exists

    ; load next available string list pointer into rax
    mov rax, [dwStringCount]
;.if_174:
    cmp rax, CONST_STRING_COUNT
	jl .end_174
;then_174:

        printf(roStr_148, CONST_STRING_COUNT)
        ExitProcess(1)
.end_174:


    mov rdx, qword 8 ; size of pointer
    mul rdx
    mov rdx, pStringListPointers
    add rax, rdx

    ; store pointer to string in pointer list
    mov rbx, [pStringListEnd]
    mov [rax], rbx 
    
    ; increment pointer count
    mov rcx, [dwStringCount]
    inc rcx
    mov [dwStringCount], rcx

    ; copy string literal to string list
    strcpy(rbx, r15, r14)

    ; advance string list end pointer
    mov rax, [pStringListEnd]
    add rax, r14
    inc rax ; null terminator
    mov [pStringListEnd], rax
.end:
    PopCalleeSavedRegs()
    ret

; this routine writes constant string literals to file
; they will be stored in the readonly section (rodata)
write_string_list:
    PushCalleeSavedRegs()

    mov r13, [dwStringCount]
    dec r13 
    mov rax, r13
    mov rdx, qword 8 ; size of pointer
    mul rdx
    ; rax hold offset
    mov rdx, pStringListPointers
    add rax, rdx 
    mov r15, rax ; r15 holds pointer to last string literal

    WriteFile([hndDestFile], cStrReadOnlySectionHeader, cStrReadOnlySectionHeader.length, dwBytesWritten)

.while_not_less_than_0:
    cmp r13, 0
    jl .end_not_less_than_0
.do_not_less_than_0:   
    mov r14, [r15]

    sprintf(ptrBuffer256, roStr_149, r13, r14)
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

    dec r13
    sub r15, qword 8 ; move back to previous string literal
    jmp .while_not_less_than_0
.end_not_less_than_0:

.end:
    PopCalleeSavedRegs()
    ret

compile_condition_1:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 ; reserve space on the stack for the token index
    mov [rbp], rcx ; store token index on the stack
    mov [rbp - 0x8], rdx ; store scope id on the stack
    PushCalleeSavedRegs()

    ; get first operand
    mov rax, rcx
    mov rdx, Token.size
    mul rdx
    mov rcx, tokenList
    add rcx, rax
    mov rbx, rcx

    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptrBuffer64, r10, r12)

    sprintf(ptrBuffer256, roStr_150, ptrBuffer64)

    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
    
    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 1
.while_175:
    cmp r14, r13
	jg .end_175
;do_175:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_176:
    cmp r10w, defKeywordElse
	jne .end_176
;then_176:

            jmp .found_matching_keyword
.end_176:

;.if_177:
    cmp r10w, defKeywordEnd
	jne .end_177
;then_177:

            jmp .found_matching_keyword
.end_177:

        
        inc r14
        add rbx, Token.size
    jmp .while_175
    ; end while_175
.end_175:

    printf(roStr_151)
    ExitProcess(1)

.found_matching_keyword:    
    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_178:
    cmp r10w, defKeywordElse
	jne .else_178
;then_178:

        sprintf(ptrBuffer64, roStr_152, r13)
	jmp .end_178
.else_178:
    
        sprintf(ptrBuffer64, roStr_153, r13)
.end_178:


    multipop r10, r13, r14

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer256, roStr_154, ptrBuffer64)

    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

.end:
    PopCalleeSavedRegs()
    add rsp, 0x10
    pop rbp
    mov rax, 0
    ret     

; this routine will compile simple if conditions
; the *MUST* be in the form of:
;   <operand> <operator> <operand>
; it will simply write this asm code:
;   cmp <operand>, <operand>
;   !<operator> <label>
; rcx must hold the token index of the first token of the if condition
; rdx must hold the scope id of the current scope
compile_condition_3:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 ; reserve space on the stack for the token index
    mov [rbp], rcx ; store token index on the stack
    mov [rbp - 0x8], rdx ; store scope id on the stack
    PushCalleeSavedRegs()

    ; get first operand
    mov rax, rcx
    mov rdx, Token.size
    mul rdx
    mov rcx, tokenList
    add rcx, rax
    mov rbx, rcx

    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptrBuffer64, r10, r12)

    ; fetch data type for first operand
    multipush rax, rcx
    mov rcx, ptrBuffer64
    call get_data_type
    mov r15, rax
    multipop rax, rcx

    add rbx, Token.size * 2 ; advance to second operand
    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptr2Buffer64, r10, r12)
;.if_179:
    cmp r15, TYPE_UINT8
	jne .else_179
;then_179:

        sprintf(ptrBuffer256, roStr_155, ptrBuffer64, ptr2Buffer64)
	jmp .end_179
.else_179:

;.if_180:
    cmp r15, TYPE_UINT64
	jne .else_180
;then_180:

        sprintf(ptrBuffer256, roStr_156, ptrBuffer64, ptr2Buffer64)
	jmp .end_180
.else_180:

        sprintf(ptrBuffer256, roStr_157, ptrBuffer64, ptr2Buffer64)
.end_180:

.end_179:


    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
   
    ; write operator
    sub rbx, Token.size ; move back to operator
    mov r10, [rbx - Token.TokenType]
    and r10, 0xffff

    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 2
    mov r15, 0 ; count of encountered if keywords
.while_181:
    cmp r14, r13
	jg .end_181
;do_181:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_182:
    cmp r10w, defKeywordElse
	jne .end_182
;then_182:

;.if_183:
    cmp r15, 0
	jne .end_183
;then_183:

                jmp .found_matching_keyword
.end_183:

.end_182:

;.if_184:
    cmp r10w, defKeywordEnd
	jne .end_184
;then_184:

;.if_185:
    cmp r15, 0
	je .end_185
;then_185:

                inc r14
                add rbx, Token.size
                dec r15
    jmp .while_181

.end_185:

            jmp .found_matching_keyword
.end_184:

;.if_186:
    cmp r10w, defKeywordIf
	jne .end_186
;then_186:

            inc r15
.end_186:

;.if_187:
    cmp r10w, defKeywordWhile
	jne .end_187
;then_187:

            inc r15
.end_187:

        
        inc r14
        add rbx, Token.size
    jmp .while_181
    ; end while_181
.end_181:

    printf(roStr_158)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_188:
    cmp r10w, defKeywordElse
	jne .else_188
;then_188:

        sprintf(ptrBuffer64, roStr_159, r13)
	jmp .end_188
.else_188:
    
        sprintf(ptrBuffer64, roStr_160, r13)
.end_188:


    multipop r10, r13, r14
    
;.if_189:
    cmp r10, OperatorEquals
	jne .else_189
;then_189:

        sprintf(ptrBuffer256, roStr_161, ptrBuffer64)
	jmp .end_189
.else_189:

;.if_190:
    cmp r10, OperatorNotEquals
	jne .else_190
;then_190:

        sprintf(ptrBuffer256, roStr_162, ptrBuffer64)
	jmp .end_190
.else_190:

;.if_191:
    cmp r10, OperatorLess
	jne .else_191
;then_191:

        sprintf(ptrBuffer256, roStr_163, ptrBuffer64)
	jmp .end_191
.else_191:

;.if_192:
    cmp r10, OperatorLessOrEqual
	jne .else_192
;then_192:

        sprintf(ptrBuffer256, roStr_164, ptrBuffer64)
	jmp .end_192
.else_192:

;.if_193:
    cmp r10, OperatorGreater
	jne .else_193
;then_193:

        sprintf(ptrBuffer256, roStr_165, ptrBuffer64)
	jmp .end_193
.else_193:

;.if_194:
    cmp r10, OperatorGreaterOrEqual
	jne .else_194
;then_194:

        sprintf(ptrBuffer256, roStr_166, ptrBuffer64)
	jmp .end_194
.else_194:

        printf(roStr_167, r10)
        ExitProcess(1)
.end_194:

.end_193:

.end_192:

.end_191:

.end_190:

.end_189:


    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

.end:
    PopCalleeSavedRegs()
    add rsp, 0x10
    pop rbp
    ; mov rax, 0
    ret

compile_while_condition_3:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 ; reserve space on the stack for the token index
    mov [rbp], rcx ; store token index on the stack
    mov [rbp - 0x8], rdx ; store scope id on the stack
    PushCalleeSavedRegs()

    ; get first operand
    mov rax, rcx
    mov rdx, Token.size
    mul rdx
    mov rcx, tokenList
    add rcx, rax
    mov rbx, rcx

    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptrBuffer64, r10, r12)

    ; fetch data type for first operand
    multipush rax, rcx
    mov rcx, ptrBuffer64
    call get_data_type
    mov r15, rax
    multipop rax, rcx

    add rbx, Token.size * 2 ; advance to second operand
    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptr2Buffer64, r10, r12)
;.if_195:
    cmp r15, TYPE_UINT8
	jne .else_195
;then_195:

        sprintf(ptrBuffer256, roStr_168, ptrBuffer64, ptr2Buffer64)
	jmp .end_195
.else_195:

;.if_196:
    cmp r15, TYPE_UINT64
	jne .else_196
;then_196:

        sprintf(ptrBuffer256, roStr_169, ptrBuffer64, ptr2Buffer64)
	jmp .end_196
.else_196:

        sprintf(ptrBuffer256, roStr_170, ptrBuffer64, ptr2Buffer64)
.end_196:

.end_195:


    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
   
    ; write operator
    sub rbx, Token.size ; move back to operator
    mov r10, [rbx - Token.TokenType]
    and r10, 0xffff

    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 2
    mov r15, 0 ; count of encountered if keywords
.while_197:
    cmp r14, r13
	jg .end_197
;do_197:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_198:
    cmp r10w, defKeywordElse
	jne .end_198
;then_198:

;.if_199:
    cmp r15, 0
	jne .end_199
;then_199:

                jmp .found_matching_keyword
.end_199:

.end_198:

;.if_200:
    cmp r10w, defKeywordEnd
	jne .end_200
;then_200:

;.if_201:
    cmp r15, 0
	je .end_201
;then_201:

                inc r14
                add rbx, Token.size
                dec r15
    jmp .while_197

.end_201:

            jmp .found_matching_keyword
.end_200:

;.if_202:
    cmp r10w, defKeywordIf
	jne .end_202
;then_202:

            inc r15
.end_202:

        
        inc r14
        add rbx, Token.size
    jmp .while_197
    ; end while_197
.end_197:

    printf(roStr_171)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer64, roStr_172, r13)
    multipop r10, r13, r14
    
;.if_203:
    cmp r10, OperatorEquals
	jne .else_203
;then_203:

        sprintf(ptrBuffer256, roStr_173, ptrBuffer64)
	jmp .end_203
.else_203:

;.if_204:
    cmp r10, OperatorNotEquals
	jne .else_204
;then_204:

        sprintf(ptrBuffer256, roStr_174, ptrBuffer64)
	jmp .end_204
.else_204:

;.if_205:
    cmp r10, OperatorLess
	jne .else_205
;then_205:

        sprintf(ptrBuffer256, roStr_175, ptrBuffer64)
	jmp .end_205
.else_205:

;.if_206:
    cmp r10, OperatorLessOrEqual
	jne .else_206
;then_206:

        sprintf(ptrBuffer256, roStr_176, ptrBuffer64)
	jmp .end_206
.else_206:

;.if_207:
    cmp r10, OperatorGreater
	jne .else_207
;then_207:

        sprintf(ptrBuffer256, roStr_177, ptrBuffer64)
	jmp .end_207
.else_207:

;.if_208:
    cmp r10, OperatorGreaterOrEqual
	jne .else_208
;then_208:

        sprintf(ptrBuffer256, roStr_178, ptrBuffer64)
	jmp .end_208
.else_208:

        printf(roStr_179, r10)
        ExitProcess(1)
.end_208:

.end_207:

.end_206:

.end_205:

.end_204:

.end_203:


    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

.end:
    PopCalleeSavedRegs()
    add rsp, 0x10
    pop rbp
    ; mov rax, 0
    ret

push_operator:
    PushCalleeSavedRegs()

    mov rax, [dqOperatorCount]
    mov rdx, qword 8 ; size of pointer
    mul rdx
    mov rdx, pOperatorStack
    add rax, rdx
;.if_209:
    cmp qword[dqOperatorCount], 0
	jne .end_209
;then_209:

        mov [rax], rcx
        mov r15, [rax]
        inc qword [dqOperatorCount]
        PopCalleeSavedRegs()
        ret
.end_209:

    sub rax, 8
    mov r15, [rax]
    mov r15, rcx
.while_210:
    cmp [rax], rcx
	jle .end_210
;do_210:

;.if_211:
    cmp qword[dqOperatorCount], 0
	jg .end_211
;then_211:

    jmp .end_210

.end_211:

        PushCallerSavedRegs()
        call write_operator
        PopCallerSavedRegs()
        push rax
        pop rax
        sub rax, 8 
    jmp .while_210
    ; end while_210
.end_210:

    add rax, 8
    mov [rax], r15
    inc qword [dqOperatorCount]

.end:    
    PopCalleeSavedRegs()
    ret

write_operator:
    PushCalleeSavedRegs()

    mov rax, [dqOperatorCount]
    dec rax
    mov rdx, qword 8 ; size of pointer
    mul rdx
    mov rdx, pOperatorStack
    add rax, rdx
    mov r15, [rax]
;.if_212:
    cmp r15w, defOperatorPlus
	jne .end_212
;then_212:

        push rax
        sprintf(ptrBuffer256, roStr_180)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_212:

;.if_213:
    cmp r15w, defOperatorMinus
	jne .end_213
;then_213:

        push rax
        sprintf(ptrBuffer256, roStr_181)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_213:

;.if_214:
    cmp r15w, defOperatorMultiply
	jne .end_214
;then_214:

        push rax
        sprintf(ptrBuffer256, roStr_182)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_214:

;.if_215:
    cmp r15w, defOperatorDivide
	jne .end_215
;then_215:

        push rax
        sprintf(ptrBuffer256, roStr_183)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_215:

;.if_216:
    cmp r15w, defOperatorModulo
	jne .end_216
;then_216:

        push rax
        sprintf(ptrBuffer256, roStr_184)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_216:


    dec qword [dqOperatorCount]

.end:
    PopCalleeSavedRegs()
    ret    

section .data
    szStrataFileExtension db ".strata"
    szStrataFileExtension.length equ $ - szStrataFileExtension
    szAsmFileExtension db ".asm"
    szAsmFileExtension.length equ $ - szAsmFileExtension
    szTab db "    "
    szTab.length equ $ - szTab
    szAsmDataStringType db " db "
    szAsmDataStringType.length equ $ - szAsmDataStringType
    szAsmDataStringLengthType db " equ $ - "
    szAsmDataStringLengthType.length equ $ - szAsmDataStringLengthType
    szAsmDataStringSuffix db ".length"
    szAsmDataStringSuffix.length equ $ - szAsmDataStringSuffix
    szKeywordIf db "if"
    szKeywordIf.length equ $ - szKeywordIf
    szKeywordThen db "then"
    szKeywordThen.length equ $ - szKeywordThen
    szKeywordElse db "else"
    szKeywordElse.length equ $ - szKeywordElse
    szKeywordEnd db "end"
    szKeywordEnd.length equ $ - szKeywordEnd
    szKeywordWhile db "while"
    szKeywordWhile.length equ $ - szKeywordWhile
    szKeywordDo db "do"
    szKeywordDo.length equ $ - szKeywordDo
    szKeywordContinue db "continue"
    szKeywordContinue.length equ $ - szKeywordContinue
    szKeywordBreak db "break"
    szKeywordBreak.length equ $ - szKeywordBreak
    szKeywordUInt8 db "uint8"
    szKeywordUInt8.length equ $ - szKeywordUInt8
    szKeywordUInt64 db "uint64"
    szKeywordUInt64.length equ $ - szKeywordUInt64
    szKeywordEval db "eval"
    szKeywordEval.length equ $ - szKeywordEval
    szKeywordArray db "array"
    szKeywordArray.length equ $ - szKeywordArray
    szKeywordProc db "proc"
    szKeywordProc.length equ $ - szKeywordProc
    szKeywordEndProc db "endproc"
    szKeywordEndProc.length equ $ - szKeywordEndProc
    szKeywordForward db "forward"
    szKeywordForward.length equ $ - szKeywordForward
    szOperatorEquals db "=="
    szOperatorEquals.length equ $ - szOperatorEquals
    szOperatorNotEquals db "!="
    szOperatorNotEquals.length equ $ - szOperatorNotEquals
    szOperatorLess db "<"
    szOperatorLess.length equ $ - szOperatorLess
    szOperatorLessOrEqual db "<="
    szOperatorLessOrEqual.length equ $ - szOperatorLessOrEqual
    szOperatorGreater db ">"
    szOperatorGreater.length equ $ - szOperatorGreater
    szOperatorGreaterOrEqual db ">="
    szOperatorGreaterOrEqual.length equ $ - szOperatorGreaterOrEqual
    szOperatorAssignment db "="
    szOperatorAssignment.length equ $ - szOperatorAssignment
    szOperatorPlus db "+"
    szOperatorPlus.length equ $ - szOperatorPlus
    szOperatorMinus db "-"
    szOperatorMinus.length equ $ - szOperatorMinus
    szOperatorMultiply db "*"
    szOperatorMultiply.length equ $ - szOperatorMultiply
    szOperatorDivide db "/"
    szOperatorDivide.length equ $ - szOperatorDivide
    szOperatorModulo db "%"
    szOperatorModulo.length equ $ - szOperatorModulo
    szStatementEnd db ";"
    szStatementEnd.length equ $ - szStatementEnd
    szSquareBracketOpen db "["
    szSquareBracketOpen.length equ $ - szSquareBracketOpen
    szSquareBracketClose db "]"
    szSquareBracketClose.length equ $ - szSquareBracketClose
    szParenOpen db "("
    szParenOpen.length equ $ - szParenOpen
    szParenClose db ")"
    szParenClose.length equ $ - szParenClose

section .rodata
    roStr_184 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rdx\r\n", 0
    roStr_183 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rax\r\n", 0
    roStr_182 db "\tpop rax\r\n\tpop rcx\r\n\txor rdx, rdx\r\n\tmul rcx\r\n\tpush rax\r\n", 0
    roStr_181 db "\tpop rcx\r\n\tpop rax\r\n\tsub rax, rcx\r\n\tpush rax\r\n", 0
    roStr_180 db "\tpop rax\r\n\tpop rcx\r\n\tadd rax, rcx\r\n\tpush rax\r\n", 0
    roStr_179 db "[\#27[91mERROR\#27[0m] 7Unsupported operator %x\r\n", 0
    roStr_178 db "\tjl %s\r\n", 0
    roStr_177 db "\tjle %s\r\n", 0
    roStr_176 db "\tjg %s\r\n", 0
    roStr_175 db "\tjge %s\r\n", 0
    roStr_174 db "\tje %s\r\n", 0
    roStr_173 db "\tjne %s\r\n", 0
    roStr_172 db ".end_%d", 0
    roStr_171 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_170 db "    cmp %s, %s\r\n", 0
    roStr_169 db "\tmov r15, [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_168 db "\tmovzx r15, byte [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_167 db "[\#27[91mERROR\#27[0m] 7Unsupported operator %x\r\n", 0
    roStr_166 db "\tjl %s\r\n", 0
    roStr_165 db "\tjle %s\r\n", 0
    roStr_164 db "\tjg %s\r\n", 0
    roStr_163 db "\tjge %s\r\n", 0
    roStr_162 db "\tje %s\r\n", 0
    roStr_161 db "\tjne %s\r\n", 0
    roStr_160 db ".end_%d", 0
    roStr_159 db ".else_%d", 0
    roStr_158 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_157 db "    cmp %s, %s\r\n", 0
    roStr_156 db "\tmov r15, [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_155 db "\tmovzx r15, byte [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_154 db "    jne %s\r\n", 0
    roStr_153 db ".end_%d", 0
    roStr_152 db ".else_%d", 0
    roStr_151 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_150 db "    %s\r\n", 0
    roStr_149 db "    roStr_%d db %s, 0\r\n", 0
    roStr_148 db "[\#27[91mERROR\#27[0m]: String list full. Max strings allowed: %d\r\n", 0
    roStr_147 db "[\#27[92mINFO\#27[0m] Generated %s.exe\r\n", 0
    roStr_146 db "[WARN] Deleting object file failed.\r\n", 0
    roStr_145 db "%s.o", 0
    roStr_144 db "[DEBUG] Deleting object file.\r\n", 0
    roStr_143 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_142 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_141 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_140 db "ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0
    roStr_139 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_138 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_137 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_136 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_135 db "nasm.exe -f win64 -g %s.asm -o %s.o -w+all -w+error", 0
    roStr_134 db "[\#27[92mINFO\#27[0m] Done compiling.\r\n", 0
    roStr_133 db "[WARN] Unknown token '%s'\r\n", 0
    roStr_132 db "[DEBUG] Token type %x; start: %d; length: %d\r\n", 0
    roStr_131 db "roStr_%d", 0
    roStr_130 db "\r\n\tmov rsp, rbp\r\n\tpop rbp\r\n\tret\r\n%s_end:\r\n", 0
    roStr_129 db "[\#27[92mINFO\#27[0m] Procedure '%s' found\r\n", 0
    roStr_128 db "[\#27[92mINFO\#27[0m] Argument '%s' found\r\n", 0
    roStr_127 db "[\#27[92mINFO\#27[0m] Procedure '%s' has %d arguments\r\n", 0
    roStr_126 db "[\#27[91mERROR\#27[0m] Expected '(' after 'proc'\r\n", 0
    roStr_125 db "\r\n\tjmp %s_end\r\n%s:\r\n\tpush rbp\r\n\tmov rbp, rsp\r\n", 0
    roStr_124 db "[\#27[91mERROR\#27[0m] Unsupported array type\r\n", 0
    roStr_123 db "section .bss\r\n\t%s resq %s\r\nsection .text\r\n", 0
    roStr_122 db "section .bss\r\n\t%s resb %s\r\nsection .text\r\n", 0
    roStr_121 db "[\#27[91mERROR\#27[0m] Expected ';' after array definition\r\n", 0
    roStr_120 db "[\#27[91mERROR\#27[0m] Expected array size after '['\r\n", 0
    roStr_119 db "[\#27[91mERROR\#27[0m] Expected 'uint64' after 'array'\r\n", 0
    roStr_118 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'array'\r\n", 0
    roStr_117 db "\tpush qword [%s]\r\n", 0
    roStr_116 db "\tpush %s\r\n", 0
    roStr_115 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_114 db "[\#27[91mERROR\#27[0m] 5Unsupported operand %s with data type of size %d\r\n", 0
    roStr_113 db "\tpop rax\r\n\tmov qword [%s], rax\r\n", 0
    roStr_112 db "\tpop rax\r\n\tmov qword [rbp + %d], rax\r\n", 0
    roStr_111 db "\tpop rax\r\n\tmov byte [%s], al\r\n", 0
    roStr_110 db "[\#27[91mERROR\#27[0m] Unknown identifier '%s'\r\n", 0
    roStr_109 db "\tpush qword [%s]\r\n", 0
    roStr_108 db "\tpush qword [rbp + %d]\r\n", 0
    roStr_107 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_106 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_105 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n\tpush qword [rdx]\r\n", 0
    roStr_104 db "\tmov rdx, %s\r\n\tadd rdx, [%s]\r\n\tmovzx rax, byte [rdx]\r\n\tpush qword rax\r\n", 0
    roStr_103 db "\tpush %s\r\n", 0
    roStr_102 db "\tadd rsp, %d\r\n", 0
    roStr_101 db "\r\n\tcall %s\r\n\tmov [%s], rax\r\n", 0
    roStr_100 db "\tpush qword [%s]\r\n", 0
    roStr_99 db "\tpush qword [rbp + %d]\r\n", 0
    roStr_98 db "\tpush qword %s\r\n", 0
    roStr_97 db "Found proc call\r\n", 0
    roStr_96 db "Found operand of type %d:  %s\r\n", 0
    roStr_95 db "[\#27[91mERROR\#27[0m] Expected assignment operator after literal\r\n", 0
    roStr_94 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_93 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_92 db "\tmov rax, [%s]\r\n\tmov [rdx], rax\r\n", 0
    roStr_91 db "\tmovzx rax, byte [%s]\r\n\tmov byte [rdx], al\r\n", 0
    roStr_90 db "\tmov rax, qword [rbp + %d]\r\n\tmov byte [rdx], al\r\n", 0
    roStr_89 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_88 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_87 db "\tmov qword [rdx], %s\r\n", 0
    roStr_86 db "\tmov byte [rdx], %s\r\n", 0
    roStr_85 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_84 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_83 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n", 0
    roStr_82 db "\tmov rdx, %s\r\n\tadd rdx, [%s]\r\n", 0
    roStr_81 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_80 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_79 db "\tmov rax, %s\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n", 0
    roStr_78 db "\tmov rdx, %s\r\n\tadd rdx, %s\r\n", 0
    roStr_77 db "\r\n\tcall %s\r\n", 0
    roStr_76 db "[\#27[92mINFO\#27[0m] Symbol '%s' has %d data type\r\n", 0
    roStr_75 db "[\#27[92mINFO\#27[0m] Processing assignment to '%s'\r\n", 0
    roStr_74 db "\r\nsection .data\r\n\t%s db %s\r\nsection .text\r\n", 0
    roStr_73 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_72 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'uint8'\r\n", 0
    roStr_71 db "[\#27[91mERROR\#27[0m] Expected identifier after 'uint8'\r\n", 0
    roStr_70 db "\r\nsection .data\r\n\t%s dq %s\r\nsection .text\r\n", 0
    roStr_69 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_68 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'uint64'\r\n", 0
    roStr_67 db "[\#27[91mERROR\#27[0m] Expected identifier after 'uint64'\r\n", 0
    roStr_66 db "\r\n    jmp .end_%d\r\n", 0
    roStr_65 db "\r\n    jmp .while_%d\r\n", 0
    roStr_64 db ";do_%d:\r\n", 0
    roStr_63 db "[\#27[91mERROR\#27[0m] Unsupported 'while' condition. Found %d tokens\r\n", 0
    roStr_62 db "[\#27[91mERROR\#27[0m] Keyword 'do' is not after 'while'\r\n", 0
    roStr_61 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_60 db "\r\n.while_%d:\r\n", 0
    roStr_59 db "\r\n.end_%d:\r\n", 0
    roStr_58 db "\r\n    jmp .while_%d\r\n    ; end while_%d", 0
    roStr_57 db "[\#27[91mERROR\#27[0m] Keyword 'end' is not after 'then', 'else' or 'do'\r\n", 0
    roStr_56 db "\r\n\tjmp .end_%d\r\n.else_%d:\r\n", 0
    roStr_55 db "[\#27[91mERROR\#27[0m] Keyword 'else' is not after 'then'\r\n", 0
    roStr_54 db ";then_%d:\r\n", 0
    roStr_53 db "[\#27[91mERROR\#27[0m] Unsupported 'if' condition. Found %d tokens\r\n", 0
    roStr_52 db "[\#27[91mERROR\#27[0m] Keyword 'then' is not after 'if'\r\n", 0
    roStr_51 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_50 db "\r\n;.if_%d:\r\n", 0
    roStr_49 db "[DEBUG] Current token index: %d\r\n", 0
    roStr_48 db "[DEBUG] Current token type: %x\r\n", 0
    roStr_47 db "[DEBUG] Found %d tokens.\r\n", 0
    roStr_46 db "[\#27[92mINFO\#27[0m] Found %d tokens.\r\n", 0
    roStr_45 db "Newline %d\n", 0
    roStr_44 db "[\#27[92mINFO\#27[0m] Compiling file '%s'...\r\n", 0
    roStr_43 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_42 db "[\#27[91mERROR\#27[0m] Error reading file '%s'. Error code: %d\r\n", 0
    roStr_41 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_40 db "[\#27[92mINFO\#27[0m] Output file '%s'\r\n", 0
    roStr_39 db "[\#27[92mINFO\#27[0m] Input file '%s'\r\n", 0
    roStr_38 db "[\#27[91mERROR\#27[0m] line %d - Unexpected token: ", 0
    roStr_37 db "Unknown token type %x\n", 0
    roStr_36 db "SQBRACKET_CLOSE\n", 0
    roStr_35 db "SQBRACKET_OPEN\n", 0
    roStr_34 db "SEMICOLON\n", 0
    roStr_33 db "CONSTANT_INTEGER\n", 0
    roStr_32 db "IDENTIFIER\n", 0
    roStr_31 db "ASM_LITERAL\n", 0
    roStr_30 db "CONSTANT_STRING\n", 0
    roStr_29 db "KEYWORD_ENDPROC\n", 0
    roStr_28 db "KEYWORD_PROC\n", 0
    roStr_27 db "KEYWORD_ARRAY\n", 0
    roStr_26 db "KEYWORD_EVAL--\n", 0
    roStr_25 db "KEYWORD_STRING--\n", 0
    roStr_24 db "KEYWORD_UINT64\n", 0
    roStr_23 db "KEYWORD_UINT8\n", 0
    roStr_22 db "KEYWORD_BREAK\n", 0
    roStr_21 db "KEYWORD_CONTINUE\n", 0
    roStr_20 db "KEYWORD_DO\n", 0
    roStr_19 db "KEYWORD_WHILE\n", 0
    roStr_18 db "KEYWORD_END\n", 0
    roStr_17 db "KEYWORD_ELSE\n", 0
    roStr_16 db "KEYWORD_THEN\n", 0
    roStr_15 db "KEYWORD_IF\n", 0
    roStr_14 db "OP_MOD\n", 0
    roStr_13 db "OP_DIV\n", 0
    roStr_12 db "OP_MUL\n", 0
    roStr_11 db "OP_MINUS\n", 0
    roStr_10 db "OP_PLUS\n", 0
    roStr_9 db "OP_ASSIGNMENT\n", 0
    roStr_8 db "OP_GREATER_OR_EQUAL\n", 0
    roStr_7 db "OP_GREATER\n", 0
    roStr_6 db "OP_LESS_OR_EQAL\n", 0
    roStr_5 db "OP_LESS\n", 0
    roStr_4 db "OP_NOT_EQUALS\n", 0
    roStr_3 db "OP_EQUALS\n", 0
    roStr_2 db "Offset for Value: %d\n", 0
    roStr_1 db "Offset for Type: %d\n", 0
    roStr_0 db "Pushing token to IR stack - t: %x; v: %d\n", 0
