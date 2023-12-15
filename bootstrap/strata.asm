bits 64
default rel


%include "inc/std.inc"
; %define DEBUG 0
%define SOURCE_CODE_SIZE 1024*2048
%define TINY_BUFFER_SIZE 64
%define SMALL_BUFFER_SIZE 64
%define MED_BUFFER_SIZE 256
%define OPERATOR_BUFFER_SIZE 64

section .data
	currentTokenType dq 0
section .text

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

%define MAX_TOKEN_COUNT 1024 * 128

%define BLOCK_ITEM_SIZE 8
section .bss
    currentProcArgCount resq 1
    szSourceCode resb SOURCE_CODE_SIZE
    szTokenValue resb SMALL_BUFFER_SIZE
    pBufferTiny resb TINY_BUFFER_SIZE
    ptrBuffer64 resb SMALL_BUFFER_SIZE
    ptr2Buffer64 resb SMALL_BUFFER_SIZE
    ptr3Buffer64 resb SMALL_BUFFER_SIZE
    ptrBuffer256 resb MED_BUFFER_SIZE
    blockStack resb 512 * Block.size ; todo - revisit this
    blockCount resq 1
    lpProcessInformation resb 24
    lpStartupInfo resb 104
    tokenList resq MAX_TOKEN_COUNT * Token.size
    dwTokenCount resd 1
    bProcessingIfCondition resq 1
    dqCurrentLine resq 1
    dqLineStart resq 1
    pOperatorStack resq 64
    dqOperatorCount resq 1
    pOperandStack resq 64
    dqOperandCount resq 1
    dqStatementOpCount resq 1
    
    szNames resb 2048 * 128
    pszNameEndPointer resq 1
    pNames resb 2048 * Name.size
    dqNameCount resq 1

    hndSourceFile resq 1
    hndDestFile resq 1
    dwBytesRead resd 1
    dwBytesWritten resd 1
    szSourceFile resb 256
    szDestFile resb 256
    szFilenameWithoutExtension resb 256
    lpExitCode resq 1

    memory resb 1024 * 2048
    pFreePointer resq 1
    symbolTables resb 512 * SymbolTable.size

    dqSymbolTableCount resq 1
    pCurrentSymbolTable resq 1
    pCurrentProcedureSymbolTable resq 1
    dqCurrentAssignedOperandValue resq 1 ; this is used to store the offset from rbp, in case of paramaters
    dqCurrentParamValue resq 1 ; this is used to store the offset from rbp, in case of paramaters

%define CONST_STRING_COUNT 1048
%define CONST_STRING_CAPACITY 1048*256 

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
;.if_0:
    cmp r8, 0
	jne .end_0
;then_0:

    inc rdi
    jmp .arg_loop
.end_0:


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
    printf(roStr_0, szSourceFile)
    printf(roStr_1, szDestFile)

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
;.if_1:
    cmp rax, 0
	jge .end_1
;then_1:

        call GetLastError
        printf(roStr_2, szSourceFile, rax)
        ExitProcess(1)
.end_1:


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
;.if_2:
    cmp rax, 0
	jne .end_2
;then_2:

        call GetLastError
        printf(roStr_3, rax)
        ExitProcess(1)
.end_2:


    printf(roStr_4, [dwBytesRead], szSourceFile)

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
;.if_3:
    cmp rax, 0
	jge .end_3
;then_3:

        call GetLastError
        printf(roStr_5, szDestFile, rax)
        ExitProcess(1)
.end_3:


    mov [hndDestFile], rax

    printf(roStr_6, szSourceFile)

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

    ;printf(roStr_7, [currentLine])


.token_found:
    ; is token length 0?
;.if_4:
    cmp r9, 0
	jne .end_4
;then_4:

        inc rdi
        inc r8
        jmp .read_token_loop
.end_4:


.print_token:
    mov r10, szSourceCode
    add r10, r8

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; reserve space on the stack for the token type
    mov [rbp], word 0 ; initialize token type to 0

;.if_5:
    CompareTokenWith(szKeywordIf)
    jne .else_5
;then_5:

    mov [rbp], word KeywordIf
    	push 256
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_5
.else_5:

;.if_6:
    CompareTokenWith(szKeywordThen)
    jne .else_6
;then_6:

    mov [rbp], word KeywordThen
    	push 257
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_6
.else_6:

;.if_7:
    CompareTokenWith(szKeywordElse)
    jne .else_7
;then_7:

    mov [rbp], word KeywordElse
    	push 258
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_7
.else_7:

;.if_8:
    CompareTokenWith(szKeywordEndProc)
    jne .else_8
;then_8:

    mov [rbp], word KeywordEndProc
    	push 270
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_8
.else_8:

;.if_9:
    CompareTokenWith(szKeywordEnd)
    jne .else_9
;then_9:

    mov [rbp], word KeywordEnd
    	push 259
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_9
.else_9:

;.if_10:
    CompareTokenWith(szKeywordWhile)
    jne .else_10
;then_10:

    mov [rbp], word KeywordWhile
    	push 260
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_10
.else_10:

;.if_11:
    CompareTokenWith(szKeywordDo)
    jne .else_11
;then_11:

    mov [rbp], word KeywordDo
    	push 261
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_11
.else_11:

;.if_12:
    CompareTokenWith(szKeywordContinue)
    jne .else_12
;then_12:

    mov [rbp], word KeywordContinue
    	push 262
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_12
.else_12:

;.if_13:
    CompareTokenWith(szKeywordBreak)
    jne .else_13
;then_13:

    mov [rbp], word KeywordBreak
    	push 263
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_13
.else_13:

;.if_14:
    CompareTokenWith(szKeywordUInt8)
    jne .else_14
;then_14:

    mov [rbp], word KeywordDefineUInt8
    	push 264
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_14
.else_14:

;.if_15:
    CompareTokenWith(szKeywordUInt64)
    jne .else_15
;then_15:

    mov [rbp], word KeywordDefineUInt64
    	push 265
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_15
.else_15:

;.if_16:
    CompareTokenWith(szKeywordEval)
    jne .else_16
;then_16:

    mov [rbp], word KeywordEval
    	push 267
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_16
.else_16:

;.if_17:
    CompareTokenWith(szKeywordArray)
    jne .else_17
;then_17:

    mov [rbp], word KeywordArray
    	push 268
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_17
.else_17:

;.if_18:
    CompareTokenWith(szKeywordProc)
    jne .else_18
;then_18:

    mov [rbp], word KeywordProc
    	push 269
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_18
.else_18:

;.if_19:
    CompareTokenWith(szKeywordForward)
    jne .else_19
;then_19:

    mov [rbp], word KeywordForward
    	push 269
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_19
.else_19:

;.if_20:
    CompareTokenWith(szOperatorEquals)
    jne .else_20
;then_20:

    mov [rbp], word OperatorEquals
    	push 1
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_20
.else_20:

;.if_21:
    CompareTokenWith(szOperatorNotEquals)
    jne .else_21
;then_21:

    mov [rbp], word OperatorNotEquals
    	push 2
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_21
.else_21:

;.if_22:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .else_22
;then_22:

    mov [rbp], word OperatorLessOrEqual
    	push 4
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_22
.else_22:

;.if_23:
    CompareTokenWith(szOperatorLess)
    jne .else_23
;then_23:

    mov [rbp], word OperatorLess
    	push 3
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_23
.else_23:

;.if_24:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .else_24
;then_24:

    mov [rbp], word OperatorGreaterOrEqual
    	push 6
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_24
.else_24:

;.if_25:
    CompareTokenWith(szOperatorGreater)
    jne .else_25
;then_25:

    mov [rbp], word OperatorGreater
    	push 5
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_25
.else_25:

;.if_26:
    CompareTokenWith(szOperatorAssignment)
    jne .else_26
;then_26:

    mov [rbp], word OperatorAssignment
    	push 7
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_26
.else_26:

;.if_27:
    CompareTokenWith(szOperatorPlus)
    jne .else_27
;then_27:

    mov [rbp], word OperatorPlus
    	push 8
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_27
.else_27:

;.if_28:
    CompareTokenWith(szOperatorMinus)
    jne .else_28
;then_28:

    mov [rbp], word OperatorMinus
    	push 9
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_28
.else_28:

;.if_29:
    CompareTokenWith(szOperatorMultiply)
    jne .else_29
;then_29:

    mov [rbp], word OperatorMultiply
    	push 10
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_29
.else_29:

;.if_30:
    CompareTokenWith(szOperatorDivide)
    jne .else_30
;then_30:

    mov [rbp], word OperatorDivide
    	push 11
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_30
.else_30:

;.if_31:
    CompareTokenWith(szOperatorModulo)
    jne .else_31
;then_31:

    mov [rbp], word OperatorModulo
    	push 12
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_31
.else_31:

;.if_32:
    CompareTokenWith(szStatementEnd)
    jne .else_32
;then_32:

    mov [rbp], word StatemendEnd
    	push 20
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_32
.else_32:

;.if_33:
    CompareTokenWith(szSquareBracketOpen)
    jne .else_33
;then_33:

    mov [rbp], word SquareBracketOpen
    	push 21
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_33
.else_33:

;.if_34:
    CompareTokenWith(szSquareBracketClose)
    jne .else_34
;then_34:

    mov [rbp], word SquareBracketClose
    	push 22
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_34
.else_34:

;.if_35:
    CompareTokenWith(szParenOpen)
    jne .else_35
;then_35:

    mov [rbp], word ParenOpen
    	push 23
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_35
.else_35:

;.if_36:
    CompareTokenWith(szParenClose)
    jne .else_36
;then_36:

    mov [rbp], word ParenClose
    	push 24
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_36
.else_36:

    ; check if token is a number
    PushCallerSavedRegs()
    strcpy(ptrBuffer64, r10, r9)
    mov rcx, ptrBuffer64
    call atoi
;.if_37:
    cmp rdx, 0
	je .else_37
;then_37:

        mov [rbp], word OperandInteger
        	push 19
	pop rax
	mov qword [currentTokenType], rax

	jmp .end_37
.else_37:

        ; otherwise, it's a literal
        mov [rbp], word OperandLiteral
        	push 18
	pop rax
	mov qword [currentTokenType], rax

.end_37:

    PopCallerSavedRegs()
.end_36:

.end_35:

.end_34:

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

    PushCallerSavedRegs()
    PushCalleeSavedRegs()
    mov r10, szSourceCode
    add r8, r10
    strcpy(szTokenValue, r8, r9)
    printf(roStr_8, szTokenValue)

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

    PopCalleeSavedRegs()
    PopCallerSavedRegs()
    jmp .read_token_loop
;-----------------------------------source code parsing----------------------------------

.source_code_parsed:
    mov r15d, dword [dwTokenCount]
    printf(roStr_9, r15)
    mov r14, 0
    mov r13, tokenList
    mov rcx, pNames
    call push_symbol_table
    mov rax, memory
    mov qword [pFreePointer], rax

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
    printf(roStr_10, rbx)
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
%define currentToken.Start qword [rdx + Token.TokenStart]
%define currentToken.Length qword [rdx + Token.TokenLength]

.while_counter_less_than_token_count:
    mov rbx, [tokenIndex]
    cmp ebx, [dwTokenCount]
    jge .end_counter_less_than_token_count
    mov r14w, currentToken.Type
    ; printf(roStr_11, r14)
%ifdef DEBUG    
    PushCallerSavedRegs()
    printf(roStr_12, rbx)
    PopCallerSavedRegs()
%endif
;.if_38:
    cmp currentToken.Type, defKeywordThen
	jne .end_38
;then_38:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_38:

;.if_39:
    cmp currentToken.Type, defKeywordDo
	jne .end_39
;then_39:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_39:


    cmp qword [bProcessingIfCondition], 0
    je .continue_processing
    NextToken()

.continue_processing:

;.if_40:
    cmp currentToken.Type, defOperandAsmLiteral
	jne .end_40
;then_40:

        PushCallerSavedRegs()
  
        ; write asm code
        mov r10, currentToken.Start
        mov r11, szSourceCode
        add r10, r11
        inc r10 ; skip leading '0x40'
        mov r11, currentToken.Length
        dec r11 ; skip trailing '0x40'

        WriteFile([hndDestFile], r10, r11, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_40:
 ; keyword 'if'
;.if_41:
    cmp currentToken.Type, defKeywordIf
	jne .end_41
;then_41:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_13, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordIf, [wScopedBlockCurrentId])
        
        inc word [wScopedBlockCurrentId]
        push r15
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15
        PopCallerSavedRegs()
        NextToken()
.end_41:
; keyword 'then'
;.if_42:
    cmp currentToken.Type, defKeywordThen
	jne .end_42
;then_42:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_14, rbx)
        %endif 
;.if_43:
    cmp bx, KeywordIf
	je .end_43
;then_43:

            printf(roStr_15, szSourceFile)
            jmp .exit
.end_43:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_44:
    cmp r10d, 3
	je .end_44
;then_44:

;.if_45:
    cmp r10d, 1
	je .end_45
;then_45:

                printf(roStr_16, r10)
                jmp .exit
.end_45:

.end_44:

;.if_46:
    cmp r10d, 3
	jne .else_46
;then_46:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_46
.else_46:

;.if_47:
    cmp r10d, 1
	jne .end_47
;then_47:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_47:

.end_46:

    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_17, rbx)
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
.end_42:
; keyword 'else'
;.if_48:
    cmp currentToken.Type, defKeywordElse
	jne .end_48
;then_48:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_49:
    cmp bx, KeywordThen
	je .end_49
;then_49:

            printf(roStr_18, szSourceFile)
            jmp .exit
.end_49:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_19, rbx, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_48:
; keyword 'end'
;.if_50:
    cmp currentToken.Type, defKeywordEnd
	jne .end_50
;then_50:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_51:
    cmp bx, KeywordThen
	je .end_51
;then_51:

;.if_52:
    cmp bx, KeywordElse
	je .end_52
;then_52:

;.if_53:
    cmp bx, KeywordDo
	je .end_53
;then_53:

                    printf(roStr_20, szSourceFile)
                    jmp .exit
                    
.end_53:

.end_52:

.end_51:

;.if_54:
    cmp bx, KeywordDo
	jne .end_54
;then_54:

            mov bx, word [rax + Block.BlockId]
            and rbx, 0xffff 
            sprintf(ptrBuffer64, roStr_21, rbx, rbx)
            WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_54:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_22, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        QuickPopBlockToken() ; pop 'then' or 'do'
        QuickPopBlockToken() ; pop 'if' or 'while'

        PopCallerSavedRegs()
        NextToken()
.end_50:
; keyword 'while'
;.if_55:
    cmp currentToken.Type, defKeywordWhile
	jne .end_55
;then_55:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_23, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordWhile, [wScopedBlockCurrentId])
        
        push r15    
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15

        inc word [wScopedBlockCurrentId]
        PopCallerSavedRegs()
        NextToken()
.end_55:
; keyword 'do'
;.if_56:
    cmp currentToken.Type, defKeywordDo
	jne .end_56
;then_56:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_24, rbx)
        %endif 
;.if_57:
    cmp bx, KeywordWhile
	je .end_57
;then_57:

            printf(roStr_25, szSourceFile)
            jmp .exit
.end_57:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_58:
    cmp r10d, 3
	je .end_58
;then_58:

;.if_59:
    cmp r10d, 1
	je .end_59
;then_59:

                printf(roStr_26, r10)
                jmp .exit
.end_59:

.end_58:

;.if_60:
    cmp r10d, 3
	jne .else_60
;then_60:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_while_condition_3
            PopCallerSavedRegs()
	jmp .end_60
.else_60:

;.if_61:
    cmp r10d, 1
	jne .end_61
;then_61:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_61:

.end_60:


    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_27, rbx)
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
.end_56:
; keyword 'continue'
;.if_62:
    cmp currentToken.Type, defKeywordContinue
	jne .end_62
;then_62:

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
.while_63:
    cmp rbx, 0
	jle .end_63
;do_63:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_64:
    cmp r10, KeywordWhile
	jne .end_64
;then_64:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_28, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_64:

    jmp .while_63
    ; end while_63
.end_63:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_62:
; keyword 'break'
;.if_65:
    cmp currentToken.Type, defKeywordBreak
	jne .end_65
;then_65:

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
.while_66:
    cmp rbx, 0
	jle .end_66
;do_66:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_67:
    cmp r10, KeywordWhile
	jne .end_67
;then_67:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_29, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_67:

    jmp .while_66
    ; end while_66
.end_66:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_65:
 ; keyword 'uint64'
;.if_68:
    cmp currentToken.Type, defKeywordDefineUInt64
	jne .end_68
;then_68:

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
        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
;.if_69:
    cmp r12w, defOperandLiteral
	je .end_69
;then_69:

            printf(roStr_30)
            jmp .exit
.end_69:


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
;.if_70:
    cmp r12w, defOperatorAssignment
	je .end_70
;then_70:

            push rbx
            printf(roStr_31)
            pop rbx
            sub rbx, Token.size
            mov r13, qword [rbx + Token.Line]
            mov r14, qword [rbx + Token.Column]
            printf(roStr_32, r13, r14)
            jmp .exit
.end_70:


        ; get value
        add rbx, Token.size

        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15)

        multipop rax, rbx, r13, r14, r15
        sub rbx, Token.size

        ; todo - write them at the top of asm file
        ; write variable declaration
        sprintf(ptrBuffer256, roStr_33, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_68:
 ; keyword 'uint8'
;.if_71:
    cmp currentToken.Type, defKeywordDefineUInt8
	jne .end_71
;then_71:

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
        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
;.if_72:
    cmp r12w, defOperandLiteral
	je .end_72
;then_72:

            printf(roStr_34)
            jmp .exit
.end_72:


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
;.if_73:
    cmp r12w, defOperatorAssignment
	je .end_73
;then_73:

            push rbx
            printf(roStr_35)
            pop rbx
            sub rbx, Token.size
            mov r13, qword [rbx + Token.Line]
            mov r14, qword [rbx + Token.Column]
            printf(roStr_36, r13, r14)
            jmp .exit
.end_73:


        ; get value
        add rbx, Token.size

        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15)

        multipop rax, rbx, r13, r14, r15
        sub rbx, Token.size

        ; todo - write them at the top of asm file
        ; write variable declaration
        sprintf(ptrBuffer256, roStr_37, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_71:
; literal 
;.if_74:
    cmp currentToken.Type, defOperandLiteral
	jne .end_74
;then_74:

        PushCallerSavedRegs()

        ; look ahead for assignment operator
        multipush rax, rbx, rdx, r10, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax

        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr3Buffer64, r13, r15) ; literal name

        printf(roStr_38, ptr3Buffer64)
   
        ; fetch data type from names table
        multipush rax, rcx
        mov rcx, ptr3Buffer64
        call get_data_type
        mov r15, rax
        mov r11, rdx ; data type size in bytes
        mov [dqCurrentAssignedOperandValue], r8  ; value (or pointer to a structure)
        multipop rax, rcx
        printf(roStr_39, ptr3Buffer64, r15)
        
;.if_75:
    cmp r15, TYPE_PROC
	jne .else_75
;then_75:

            sprintf(ptrBuffer256, roStr_40, ptr3Buffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
            multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

            PopCallerSavedRegs()
            NextToken()
	jmp .end_75
.else_75:

;.if_76:
    cmp r15, TYPE_ARRAY
	jne .else_76
;then_76:

            mov qword [dqStatementOpCount], 1
            
            ; todo - verify that the next token is a '['            
            add rbx, Token.size
            inc qword [dqStatementOpCount]

            ; read index
            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            mov r13, qword [rbx + Token.TokenStart]
            mov r14, qword [rbx + Token.TokenLength]
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
            mov r13, qword [rbx + Token.TokenStart]
            mov r14, qword [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13

            strcpy(ptr2Buffer64, r15, r14)
            inc qword [dqStatementOpCount]
;.if_77:
    cmp r10w, defOperandInteger
	jne .else_77
;then_77:

;.if_78:
    cmp r11, 1
	jne .else_78
;then_78:

                    sprintf(ptrBuffer256, roStr_41, ptr3Buffer64, ptrBuffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_78
.else_78:

;.if_79:
    cmp r11, 8
	jne .else_79
;then_79:

                    sprintf(ptrBuffer256, roStr_42, ptrBuffer64, ptr3Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_79
.else_79:

                    printf(roStr_43, r11)
                    printf(roStr_44, qword [rbx + Token.Line], qword [rbx + Token.Column])
                    jmp .exit
.end_79:

.end_78:

	jmp .end_77
.else_77:

;.if_80:
    cmp r11, 1
	jne .else_80
;then_80:

                sprintf(ptrBuffer256, roStr_45, ptr3Buffer64, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_80
.else_80:

;.if_81:
    cmp r11, 8
	jne .else_81
;then_81:

                sprintf(ptrBuffer256, roStr_46, ptrBuffer64, ptr3Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_81
.else_81:

                printf(roStr_47, r11)
                printf(roStr_48, qword [rbx + Token.Line], qword [rbx + Token.Column])
                jmp .exit
.end_81:

.end_80:

.end_77:

;.if_82:
    cmp r12w, defOperandInteger
	jne .else_82
;then_82:

;.if_83:
    cmp r11, 1
	jne .else_83
;then_83:

                    sprintf(ptrBuffer256, roStr_49, ptr2Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_83
.else_83:

;.if_84:
    cmp r11, 8
	jne .else_84
;then_84:

                    sprintf(ptrBuffer256, roStr_50, ptr2Buffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_84
.else_84:

                    printf(roStr_51, r11)
                    printf(roStr_52, qword [rbx + Token.Line], qword [rbx + Token.Column])
                    jmp .exit
.end_84:

.end_83:

	jmp .end_82
.else_82:

                multipush rax, rcx
                mov rcx, ptr2Buffer64
                call get_data_type
                mov r15, rax
                mov r11, rdx ; data type size in bytes
                multipop rax, rcx 
;.if_85:
    cmp r8, 0
	je .else_85
;then_85:

                    sprintf(ptrBuffer256, roStr_53, r8)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_85
.else_85:

;.if_86:
    cmp r11, 1
	jne .else_86
;then_86:

                        sprintf(ptrBuffer256, roStr_54, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_86
.else_86:

;.if_87:
    cmp r11, 8
	jne .else_87
;then_87:

                        sprintf(ptrBuffer256, roStr_55, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_87
.else_87:

                        printf(roStr_56, r11)
                        printf(roStr_57, qword [rbx + Token.Line], qword [rbx + Token.Column])
                        jmp .exit
.end_87:

.end_86:

.end_85:

.end_82:

            ; todo - verify that the next token is a ';'
            add rbx, Token.size
	jmp .end_76
.else_76:

            ; check if assignment operator is next
            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]
;.if_88:
    cmp r12w, defOperatorAssignment
	je .end_88
;then_88:

                printf(roStr_58)
                jmp .exit
.end_88:


            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]

            movzx r12, word [rbx + Token.TokenType]
            mov r13, qword [rbx + Token.TokenStart]
            mov r14, qword [rbx + Token.TokenLength]
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

            printf(roStr_59, r15, ptrBuffer64)
            
;.if_89:
    cmp r15, TYPE_PROC
	jne .end_89
;then_89:

                printf(roStr_60)
                ; look for opening parenthesis
                add rbx, Token.size
                mov qword [dqStatementOpCount], 3
                
                add rbx, Token.size
                mov r12w, word [rbx + Token.TokenType]
                mov r13, qword [rbx + Token.TokenStart]
                mov r14, qword [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptr2Buffer64, r15, r14) 
                xor r10, r10
                
.while_90:
    cmp r12w, defParenClose
	je .end_90
;do_90:

                    ; just advance to parenthesis close
                    ; then we walk back and process the arguments
                    inc qword [dqStatementOpCount]
                    add rbx, Token.size
                    mov r12w, word [rbx + Token.TokenType]
                    add r10, 8
    jmp .while_90
    ; end while_90
.end_90:


                ; go back to last argument
                sub rbx, Token.size
                mov r12w, word [rbx + Token.TokenType]
                mov r13, qword [rbx + Token.TokenStart]
                mov r14, qword [rbx + Token.TokenLength]
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
.while_91:
    cmp r12w, defParenOpen
	je .end_91
;do_91:

;.if_92:
    cmp r12w, defOperandInteger
	jne .else_92
;then_92:

                        ; push to operator stack
                        sprintf(ptrBuffer256, roStr_61, ptr2Buffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_92
.else_92:

;.if_93:
    cmp r8, 0
	je .else_93
;then_93:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_62, [dqCurrentParamValue])
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_93
.else_93:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_63, ptr2Buffer64)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_93:

.end_92:

                    sub rbx, Token.size
                    mov r12w, word [rbx + Token.TokenType]
                    mov r13, qword [rbx + Token.TokenStart]
                    mov r14, qword [rbx + Token.TokenLength]
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
    jmp .while_91
    ; end while_91
.end_91:



                inc qword [dqStatementOpCount] ; skip ')' token
                inc qword [dqStatementOpCount] ; skip ';' token
                sprintf(ptrBuffer256, roStr_64, ptrBuffer64, ptr3Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                sprintf(ptrBuffer256, roStr_65, r10)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

                PopCallerSavedRegs()
                SkipTokens([dqStatementOpCount])
                NextToken()
.end_89:

.while_94:
    cmp r12w, defStatemendEnd
	je .end_94
;do_94:

;.if_95:
    cmp r12w, defOperandInteger
	jne .else_95
;then_95:

                    ; push to operator stack
                    sprintf(ptrBuffer256, roStr_66, ptrBuffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_95
.else_95:

;.if_96:
    cmp r12w, defOperandLiteral
	jne .else_96
;then_96:

                    ; fetch data type from names table
                    multipush rax, rcx
                    mov rcx, ptrBuffer64
                    call get_data_type
                    mov r15, rax
                    mov r11, rdx ; data type size in bytes
                    mov r10, r8 ; value (or pointer to a structure)
                    multipop rax, rcx
;.if_97:
    cmp r15, TYPE_ARRAY
	jne .else_97
;then_97:

                        push rax
                        ; todo - verify that the next token is a '['
                        add rbx, Token.size * 2
                        movzx r12, word [rbx + Token.TokenType]
                        mov r13, qword [rbx + Token.TokenStart]
                        mov r14, qword [rbx + Token.TokenLength]
                        mov r15, szSourceCode
                        add r15, r13
                        strcpy(ptr2Buffer64, r15, r14) 
;.if_98:
    cmp r11, 1
	jne .else_98
;then_98:

                            sprintf(ptrBuffer256, roStr_67, ptrBuffer64, ptr2Buffer64)
	jmp .end_98
.else_98:

;.if_99:
    cmp r11, 8
	jne .else_99
;then_99:

                            sprintf(ptrBuffer256, roStr_68, ptr2Buffer64, ptrBuffer64)
	jmp .end_99
.else_99:

                            printf(roStr_69, r11)
                            printf(roStr_70, qword [rbx + Token.Line], qword [rbx + Token.Column])
                            jmp .exit
.end_99:

.end_98:

                        
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                        mov rax, [dqStatementOpCount]
                        add rax, 3
                        mov [dqStatementOpCount], rax
                        pop rax
                        add rbx, Token.size
	jmp .end_97
.else_97:

;.if_100:
    cmp r10, 0
	je .else_100
;then_100:

                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_71, r10)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_100
.else_100:
    
                            ; push to operator stack
                            sprintf(ptrBuffer256, roStr_72, ptrBuffer64)
                            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_100:

.end_97:

	jmp .end_96
.else_96:

;.if_101:
    cmp r12w, defOperandInteger
	je .end_101
;then_101:

                    multipush rax, rcx, rdx
                    mov rcx, r12
                    call push_operator
                    multipop rax, rcx, rdx
.end_101:

.end_96:

.end_95:

                add rbx, Token.size
                movzx r12, word [rbx + Token.TokenType]
                mov r13, qword [rbx + Token.TokenStart]
                mov r14, qword [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptrBuffer64, r15, r14)
                inc qword [dqStatementOpCount]
    jmp .while_94
    ; end while_94
.end_94:

.while_102:
    cmp qword[dqOperatorCount], 0
	jl .end_102
;do_102:

                call write_operator
    jmp .while_102
    ; end while_102
.end_102:

            
             ; fetch data type from names table
            multipush rax, rcx
            mov rcx, ptr3Buffer64
            call get_data_type
            mov r15, rax
            mov r11, rdx ; data type size in bytes
            multipop rax, rcx
            
;.if_103:
    cmp r15, 0
	jne .end_103
;then_103:

                printf(roStr_73, ptr3Buffer64)
                jmp .exit
.end_103:

;.if_104:
    cmp r15, TYPE_UINT8
	jne .else_104
;then_104:

                sprintf(ptrBuffer256, roStr_74, ptr3Buffer64)
	jmp .end_104
.else_104:

;.if_105:
    cmp r15, TYPE_UINT64
	jne .else_105
;then_105:

                mov r10, [dqCurrentAssignedOperandValue]
;.if_106:
    cmp r10, 0
	je .else_106
;then_106:

                    sprintf(ptrBuffer256, roStr_75, r10)
	jmp .end_106
.else_106:

                    sprintf(ptrBuffer256, roStr_76, ptr3Buffer64)
.end_106:

	jmp .end_105
.else_105:

                printf(roStr_77, ptr3Buffer64, r11)
                printf(roStr_78, qword [rbx + Token.Line], qword [rbx + Token.Column])
                jmp .exit
.end_105:

.end_104:

            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_76:

.end_75:


        multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_74:
; eval 
;.if_107:
    cmp currentToken.Type, defKeywordEval
	jne .end_107
;then_107:

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
        mov r13, qword [rbx + Token.TokenStart]
        mov r14, qword [rbx + Token.TokenLength]
        mov r15, szSourceCode
        add r15, r13
        strcpy(ptrBuffer64, r15, r14) 
        mov qword [dqStatementOpCount], 1
        
.while_108:
    cmp r12w, defStatemendEnd
	je .end_108
;do_108:

;.if_109:
    cmp r12w, defOperandInteger
	jne .else_109
;then_109:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_79, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_109
.else_109:

;.if_110:
    cmp r12w, defOperandLiteral
	jne .else_110
;then_110:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_80, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_110
.else_110:

;.if_111:
    cmp r12w, defOperandInteger
	je .end_111
;then_111:

                multipush rax, rcx, rdx
                mov rcx, r12
                call push_operator
                multipop rax, rcx, rdx
.end_111:

.end_110:

.end_109:

            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            mov r13, qword [rbx + Token.TokenStart]
            mov r14, qword [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            strcpy(ptrBuffer64, r15, r14)
            inc qword [dqStatementOpCount]
    jmp .while_108
    ; end while_108
.end_108:

.while_112:
    cmp qword[dqOperatorCount], 0
	jl .end_112
;do_112:

            call write_operator
    jmp .while_112
    ; end while_112
.end_112:


        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_107:
; array 
;.if_113:
    cmp currentToken.Type, defKeywordArray
	jne .end_113
;then_113:

        PushCallerSavedRegs()

        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax ; this points to 'array' token

        ; look ahead for identifier
        add rbx, Token.size

        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; literal name

        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_114:
    cmp r12w, defOperatorAssignment
	je .end_114
;then_114:

            printf(roStr_81)
            jmp .exit
.end_114:


        ; get element type
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_115:
    cmp r12w, defKeywordDefineUInt8
	jne .else_115
;then_115:

            mov r11, 1
	jmp .end_115
.else_115:

;.if_116:
    cmp r12w, defKeywordDefineUInt64
	jne .else_116
;then_116:

            mov r11, 8
	jmp .end_116
.else_116:

            printf(roStr_82)
            jmp .exit
.end_116:

.end_115:


        ; skip '['
        ; todo - check if '[' is present
        add rbx, Token.size

        ; get array size
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_117:
    cmp r12w, defOperandInteger
	je .end_117
;then_117:

            printf(roStr_83)
            jmp .exit
.end_117:


        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15) ; array size

        ; skip ']'
        ; todo - check if ']' is present
        add rbx, Token.size

        ; check if ';' is present
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_118:
    cmp r12w, defStatemendEnd
	je .end_118
;then_118:

            printf(roStr_84)
            jmp .exit
.end_118:


        multipush rax, rcx, rdx, r8
        mov rcx, ptrBuffer64
        mov rdx, TYPE_ARRAY
        mov r8, r11
        call push_variable
        multipop rax, rcx, rdx, r8
;.if_119:
    cmp r11, 1
	jne .else_119
;then_119:

            sprintf(ptrBuffer256, roStr_85, ptrBuffer64, ptr2Buffer64)
	jmp .end_119
.else_119:

;.if_120:
    cmp r11, 8
	jne .else_120
;then_120:

            sprintf(ptrBuffer256, roStr_86, ptrBuffer64, ptr2Buffer64)
	jmp .end_120
.else_120:

            printf(roStr_87)
            jmp .exit
.end_120:

.end_119:


        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(7)
        NextToken()
.end_113:
; keyword 'proc'
;.if_121:
    cmp currentToken.Type, defKeywordProc
	jne .end_121
;then_121:

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
;.if_122:
    cmp r12w, defKeywordForward
	jne .end_122
;then_122:

            ; skip 'forward'
            add rbx, Token.size
            inc qword [dqStatementOpCount]
.end_122:


        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; name of the procedure
;.if_123:
    cmp r12w, defKeywordForward
	jne .end_123
;then_123:

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
.end_123:

        sprintf(ptrBuffer256, roStr_88, ptrBuffer64, ptrBuffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
        inc qword [dqStatementOpCount]
;.if_124:
    cmp r12w, defParenOpen
	je .end_124
;then_124:

            printf(roStr_89)
            jmp .exit
.end_124:


        ; move to first argument
        add rbx, Token.size
        push rbx ; save rbx for later. right now we only count the number of arguments
        mov r12w, word [rbx + Token.TokenType]
        inc qword [dqStatementOpCount]
        mov qword [currentProcArgCount], 0
.while_125:
    cmp r12w, defParenClose
	je .end_125
;do_125:

            inc qword [currentProcArgCount]

            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]
            inc qword [dqStatementOpCount]
    jmp .while_125
    ; end while_125
.end_125:


        pop rbx ; restore rbx
        mov r12w, word [rbx + Token.TokenType]
        printf(roStr_90, ptrBuffer64, qword [currentProcArgCount])
        
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
        
.while_126:
    cmp r12w, defParenClose
	je .end_126
;do_126:

            ; get argument name
            mov r14, qword [rbx + Token.TokenStart]
            mov r15, qword [rbx + Token.TokenLength]
            mov r13, szSourceCode
            add r13, r14
            strcpy(ptr2Buffer64, r13, r15) ; name of the argument

            printf(roStr_91, ptr2Buffer64)
            
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
    jmp .while_126
    ; end while_126
.end_126:


        printf(roStr_92, ptrBuffer64)

        multipop rax, rbx, rdx, r10, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_121:
; keyword 'endproc'
;.if_127:
    cmp currentToken.Type, defKeywordEndProc
	jne .end_127
;then_127:

        PushCallerSavedRegs()

        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax ; this points to 'array' token

        ; look ahead for identifier
        add rbx, Token.size

        mov r14, qword [rbx + Token.TokenStart]
        mov r15, qword [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; literal name

        sprintf(ptrBuffer256, roStr_93, ptrBuffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        ; it's now safe to pop the current procedure and its symbol table
        call pop_symbol_table

        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(1)
        NextToken()
.end_127:

;.if_128:
    cmp currentToken.Type, defOperandStringLiteral
	jne .end_128
;then_128:

        ; todo - optimize strings by removing duplicate strings
        PushCallerSavedRegs()

        push rdx
        sprintf(ptrBuffer64, roStr_94, [dwStringCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        pop rdx

        mov rcx, currentToken.Start
        mov rdx, currentToken.Length
        call push_string_literal

        PopCallerSavedRegs()

        NextToken()
.end_128:


    mov r10w, currentToken.Type
    mov r11, currentToken.Start
    mov r12, currentToken.Length

%ifdef DEBUG
    printf(roStr_95, r10, r11, r12)
%endif

    push rax
    mov rax, szSourceCode
    add r11, rax
    strcpy(ptrBuffer64, r11, r12)

    ; printf(roStr_96, ptrBuffer64)
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

    printf(roStr_97, szSourceFile)

    jmp .assemble_object_file

.exit:
    ExitProcess(0)
    
.assemble_object_file:
    sprintf(ptrBuffer256, roStr_98, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_99, ptrBuffer256)

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
;.if_129:
    cmp rax, 0
	jne .end_129
;then_129:

        printf(roStr_100)
        ExitProcess(1)
.end_129:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_101, [lpExitCode])
    mov rax, [lpExitCode]
    
;.if_130:
    cmp rax, 0
	je .end_130
;then_130:

        printf(roStr_102)
        ExitProcess(1)
.end_130:


    sprintf(ptrBuffer256, roStr_103, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_104, ptrBuffer256)
    
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
;.if_131:
    cmp rax, 0
	jne .end_131
;then_131:

        printf(roStr_105)
        ExitProcess(1)
.end_131:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
;.if_132:
    cmp rax, 0
	je .end_132
;then_132:

        printf(roStr_106)
        ExitProcess(1)
.end_132:


    ; delete object file
%ifdef DEBUG
    printf(roStr_107)
%endif

    sprintf(ptrBuffer256, roStr_108, szFilenameWithoutExtension)
    mov rcx, ptrBuffer256
    call DeleteFileA
;.if_133:
    cmp rax, 0
	jne .end_133
;then_133:

        printf(roStr_109)
.end_133:


    printf(roStr_110, szFilenameWithoutExtension, szFilenameWithoutExtension)
    jmp .exit

get_data_type:
    PushCalleeSavedRegs()

    mov r15, rcx ; r15 holds pointer to name
    xor r11, r11
    mov r14, [dqNameCount]
    mov r13, 0
    mov r10, [pCurrentSymbolTable]
.while_134:
    cmp r13, r14
	jge .end_134
;do_134:

        mov r12, [r10 + Name.Pointer]
        strcmp(r12, r15)
;.if_135:
    cmp rax, 0
	jne .end_135
;then_135:

            mov r11, [r10 + Name.Type]
            mov rdx, [r10 + Name.DataSize]
            mov r8, [r10 + Name.Value]
    jmp .end_134

.end_135:

        add r10, Name.size
        inc r13
    jmp .while_134
    ; end while_134
.end_134:

;.if_136:
    cmp r11, 0
	jne .end_136
;then_136:

        mov rcx, r15
        call get_global_data_type
        mov r11, rax
.end_136:


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
    
.while_137:
    cmp r13, r14
	jge .end_137
;do_137:

        mov r12, [r10 + Name.Pointer]
        strcmp(r12, r15)
;.if_138:
    cmp rax, 0
	jne .end_138
;then_138:

            mov r11, [r10 + Name.Type]
            mov rdx, [r10 + Name.DataSize]
            mov r8, [r10 + Name.Value]
    jmp .end_137

.end_138:

        add r10, Name.size
        inc r13
    jmp .while_137
    ; end while_137
.end_137:


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
;.if_139:
    cmp rax, CONST_STRING_COUNT
	jl .end_139
;then_139:

        printf(roStr_111, CONST_STRING_COUNT)
        ExitProcess(1)
.end_139:


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

    sprintf(ptrBuffer256, roStr_112, r13, r14)
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

    sprintf(ptrBuffer256, roStr_113, ptrBuffer64)

    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
    
    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 1
.while_140:
    cmp r14, r13
	jg .end_140
;do_140:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_141:
    cmp r10w, defKeywordElse
	jne .end_141
;then_141:

            jmp .found_matching_keyword
.end_141:

;.if_142:
    cmp r10w, defKeywordEnd
	jne .end_142
;then_142:

            jmp .found_matching_keyword
.end_142:

        
        inc r14
        add rbx, Token.size
    jmp .while_140
    ; end while_140
.end_140:

    printf(roStr_114)
    ExitProcess(1)

.found_matching_keyword:    
    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_143:
    cmp r10w, defKeywordElse
	jne .else_143
;then_143:

        sprintf(ptrBuffer64, roStr_115, r13)
	jmp .end_143
.else_143:
    
        sprintf(ptrBuffer64, roStr_116, r13)
.end_143:


    multipop r10, r13, r14

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer256, roStr_117, ptrBuffer64)

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
;.if_144:
    cmp r15, TYPE_UINT8
	jne .else_144
;then_144:

        sprintf(ptrBuffer256, roStr_118, ptrBuffer64, ptr2Buffer64)
	jmp .end_144
.else_144:

;.if_145:
    cmp r15, TYPE_UINT64
	jne .else_145
;then_145:

        sprintf(ptrBuffer256, roStr_119, ptrBuffer64, ptr2Buffer64)
	jmp .end_145
.else_145:

        sprintf(ptrBuffer256, roStr_120, ptrBuffer64, ptr2Buffer64)
.end_145:

.end_144:


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
.while_146:
    cmp r14, r13
	jg .end_146
;do_146:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_147:
    cmp r10w, defKeywordElse
	jne .end_147
;then_147:

;.if_148:
    cmp r15, 0
	jne .end_148
;then_148:

                jmp .found_matching_keyword
.end_148:

.end_147:

;.if_149:
    cmp r10w, defKeywordEnd
	jne .end_149
;then_149:

;.if_150:
    cmp r15, 0
	je .end_150
;then_150:

                inc r14
                add rbx, Token.size
                dec r15
    jmp .while_146

.end_150:

            jmp .found_matching_keyword
.end_149:

;.if_151:
    cmp r10w, defKeywordIf
	jne .end_151
;then_151:

            inc r15
.end_151:

;.if_152:
    cmp r10w, defKeywordWhile
	jne .end_152
;then_152:

            inc r15
.end_152:

        
        inc r14
        add rbx, Token.size
    jmp .while_146
    ; end while_146
.end_146:

    printf(roStr_121)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_153:
    cmp r10w, defKeywordElse
	jne .else_153
;then_153:

        sprintf(ptrBuffer64, roStr_122, r13)
	jmp .end_153
.else_153:
    
        sprintf(ptrBuffer64, roStr_123, r13)
.end_153:


    multipop r10, r13, r14
    
;.if_154:
    cmp r10, OperatorEquals
	jne .else_154
;then_154:

        sprintf(ptrBuffer256, roStr_124, ptrBuffer64)
	jmp .end_154
.else_154:

;.if_155:
    cmp r10, OperatorNotEquals
	jne .else_155
;then_155:

        sprintf(ptrBuffer256, roStr_125, ptrBuffer64)
	jmp .end_155
.else_155:

;.if_156:
    cmp r10, OperatorLess
	jne .else_156
;then_156:

        sprintf(ptrBuffer256, roStr_126, ptrBuffer64)
	jmp .end_156
.else_156:

;.if_157:
    cmp r10, OperatorLessOrEqual
	jne .else_157
;then_157:

        sprintf(ptrBuffer256, roStr_127, ptrBuffer64)
	jmp .end_157
.else_157:

;.if_158:
    cmp r10, OperatorGreater
	jne .else_158
;then_158:

        sprintf(ptrBuffer256, roStr_128, ptrBuffer64)
	jmp .end_158
.else_158:

;.if_159:
    cmp r10, OperatorGreaterOrEqual
	jne .else_159
;then_159:

        sprintf(ptrBuffer256, roStr_129, ptrBuffer64)
	jmp .end_159
.else_159:

        printf(roStr_130, r10)
        ExitProcess(1)
.end_159:

.end_158:

.end_157:

.end_156:

.end_155:

.end_154:


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
;.if_160:
    cmp r15, TYPE_UINT8
	jne .else_160
;then_160:

        sprintf(ptrBuffer256, roStr_131, ptrBuffer64, ptr2Buffer64)
	jmp .end_160
.else_160:

;.if_161:
    cmp r15, TYPE_UINT64
	jne .else_161
;then_161:

        sprintf(ptrBuffer256, roStr_132, ptrBuffer64, ptr2Buffer64)
	jmp .end_161
.else_161:

        sprintf(ptrBuffer256, roStr_133, ptrBuffer64, ptr2Buffer64)
.end_161:

.end_160:


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
.while_162:
    cmp r14, r13
	jg .end_162
;do_162:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_163:
    cmp r10w, defKeywordElse
	jne .end_163
;then_163:

;.if_164:
    cmp r15, 0
	jne .end_164
;then_164:

                jmp .found_matching_keyword
.end_164:

.end_163:

;.if_165:
    cmp r10w, defKeywordEnd
	jne .end_165
;then_165:

;.if_166:
    cmp r15, 0
	je .end_166
;then_166:

                inc r14
                add rbx, Token.size
                dec r15
    jmp .while_162

.end_166:

            jmp .found_matching_keyword
.end_165:

;.if_167:
    cmp r10w, defKeywordIf
	jne .end_167
;then_167:

            inc r15
.end_167:

        
        inc r14
        add rbx, Token.size
    jmp .while_162
    ; end while_162
.end_162:

    printf(roStr_134)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer64, roStr_135, r13)
    multipop r10, r13, r14
    
;.if_168:
    cmp r10, OperatorEquals
	jne .else_168
;then_168:

        sprintf(ptrBuffer256, roStr_136, ptrBuffer64)
	jmp .end_168
.else_168:

;.if_169:
    cmp r10, OperatorNotEquals
	jne .else_169
;then_169:

        sprintf(ptrBuffer256, roStr_137, ptrBuffer64)
	jmp .end_169
.else_169:

;.if_170:
    cmp r10, OperatorLess
	jne .else_170
;then_170:

        sprintf(ptrBuffer256, roStr_138, ptrBuffer64)
	jmp .end_170
.else_170:

;.if_171:
    cmp r10, OperatorLessOrEqual
	jne .else_171
;then_171:

        sprintf(ptrBuffer256, roStr_139, ptrBuffer64)
	jmp .end_171
.else_171:

;.if_172:
    cmp r10, OperatorGreater
	jne .else_172
;then_172:

        sprintf(ptrBuffer256, roStr_140, ptrBuffer64)
	jmp .end_172
.else_172:

;.if_173:
    cmp r10, OperatorGreaterOrEqual
	jne .else_173
;then_173:

        sprintf(ptrBuffer256, roStr_141, ptrBuffer64)
	jmp .end_173
.else_173:

        printf(roStr_142, r10)
        ExitProcess(1)
.end_173:

.end_172:

.end_171:

.end_170:

.end_169:

.end_168:


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
;.if_174:
    cmp qword[dqOperatorCount], 0
	jne .end_174
;then_174:

        mov [rax], rcx
        mov r15, [rax]
        inc qword [dqOperatorCount]
        PopCalleeSavedRegs()
        ret
.end_174:

    sub rax, 8
    mov r15, [rax]
    mov r15, rcx
.while_175:
    cmp [rax], rcx
	jle .end_175
;do_175:

;.if_176:
    cmp qword[dqOperatorCount], 0
	jg .end_176
;then_176:

    jmp .end_175

.end_176:

        PushCallerSavedRegs()
        call write_operator
        PopCallerSavedRegs()
        push rax
        pop rax
        sub rax, 8 
    jmp .while_175
    ; end while_175
.end_175:

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
;.if_177:
    cmp r15w, defOperatorPlus
	jne .end_177
;then_177:

        push rax
        sprintf(ptrBuffer256, roStr_143)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_177:

;.if_178:
    cmp r15w, defOperatorMinus
	jne .end_178
;then_178:

        push rax
        sprintf(ptrBuffer256, roStr_144)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_178:

;.if_179:
    cmp r15w, defOperatorMultiply
	jne .end_179
;then_179:

        push rax
        sprintf(ptrBuffer256, roStr_145)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_179:

;.if_180:
    cmp r15w, defOperatorDivide
	jne .end_180
;then_180:

        push rax
        sprintf(ptrBuffer256, roStr_146)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_180:

;.if_181:
    cmp r15w, defOperatorModulo
	jne .end_181
;then_181:

        push rax
        sprintf(ptrBuffer256, roStr_147)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_181:


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
    roStr_147 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rdx\r\n", 0
    roStr_146 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rax\r\n", 0
    roStr_145 db "\tpop rax\r\n\tpop rcx\r\n\txor rdx, rdx\r\n\tmul rcx\r\n\tpush rax\r\n", 0
    roStr_144 db "\tpop rcx\r\n\tpop rax\r\n\tsub rax, rcx\r\n\tpush rax\r\n", 0
    roStr_143 db "\tpop rax\r\n\tpop rcx\r\n\tadd rax, rcx\r\n\tpush rax\r\n", 0
    roStr_142 db "[\#27[91mERROR\#27[0m] 7Unsupported operator %x\r\n", 0
    roStr_141 db "\tjl %s\r\n", 0
    roStr_140 db "\tjle %s\r\n", 0
    roStr_139 db "\tjg %s\r\n", 0
    roStr_138 db "\tjge %s\r\n", 0
    roStr_137 db "\tje %s\r\n", 0
    roStr_136 db "\tjne %s\r\n", 0
    roStr_135 db ".end_%d", 0
    roStr_134 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_133 db "    cmp %s, %s\r\n", 0
    roStr_132 db "\tmov r15, [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_131 db "\tmovzx r15, byte [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_130 db "[\#27[91mERROR\#27[0m] 7Unsupported operator %x\r\n", 0
    roStr_129 db "\tjl %s\r\n", 0
    roStr_128 db "\tjle %s\r\n", 0
    roStr_127 db "\tjg %s\r\n", 0
    roStr_126 db "\tjge %s\r\n", 0
    roStr_125 db "\tje %s\r\n", 0
    roStr_124 db "\tjne %s\r\n", 0
    roStr_123 db ".end_%d", 0
    roStr_122 db ".else_%d", 0
    roStr_121 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_120 db "    cmp %s, %s\r\n", 0
    roStr_119 db "\tmov r15, [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_118 db "\tmovzx r15, byte [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_117 db "    jne %s\r\n", 0
    roStr_116 db ".end_%d", 0
    roStr_115 db ".else_%d", 0
    roStr_114 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_113 db "    %s\r\n", 0
    roStr_112 db "    roStr_%d db %s, 0\r\n", 0
    roStr_111 db "[\#27[91mERROR\#27[0m]: String list full. Max strings allowed: %d\r\n", 0
    roStr_110 db "[\#27[92mINFO\#27[0m] Generated %s.exe\r\n", 0
    roStr_109 db "[WARN] Deleting object file failed.\r\n", 0
    roStr_108 db "%s.o", 0
    roStr_107 db "[DEBUG] Deleting object file.\r\n", 0
    roStr_106 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_105 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_104 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_103 db "ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0
    roStr_102 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_101 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_100 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_99 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_98 db "nasm.exe -f win64 -g %s.asm -o %s.o -w+all -w+error", 0
    roStr_97 db "[\#27[92mINFO\#27[0m] Done compiling.\r\n", 0
    roStr_96 db "[WARN] Unknown token '%s'\r\n", 0
    roStr_95 db "[DEBUG] Token type %x; start: %d; length: %d\r\n", 0
    roStr_94 db "roStr_%d", 0
    roStr_93 db "\r\n\tmov rsp, rbp\r\n\tpop rbp\r\n\tret\r\n%s_end:\r\n", 0
    roStr_92 db "[\#27[92mINFO\#27[0m] Procedure '%s' found\r\n", 0
    roStr_91 db "[\#27[92mINFO\#27[0m] Argument '%s' found\r\n", 0
    roStr_90 db "[\#27[92mINFO\#27[0m] Procedure '%s' has %d arguments\r\n", 0
    roStr_89 db "[\#27[91mERROR\#27[0m] Expected '(' after 'proc'\r\n", 0
    roStr_88 db "\r\n\tjmp %s_end\r\n%s:\r\n\tpush rbp\r\n\tmov rbp, rsp\r\n", 0
    roStr_87 db "[\#27[91mERROR\#27[0m] Unsupported array type\r\n", 0
    roStr_86 db "section .bss\r\n\t%s resq %s\r\nsection .text\r\n", 0
    roStr_85 db "section .bss\r\n\t%s resb %s\r\nsection .text\r\n", 0
    roStr_84 db "[\#27[91mERROR\#27[0m] Expected ';' after array definition\r\n", 0
    roStr_83 db "[\#27[91mERROR\#27[0m] Expected array size after '['\r\n", 0
    roStr_82 db "[\#27[91mERROR\#27[0m] Expected 'uint64' after 'array'\r\n", 0
    roStr_81 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'array'\r\n", 0
    roStr_80 db "\tpush qword [%s]\r\n", 0
    roStr_79 db "\tpush %s\r\n", 0
    roStr_78 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_77 db "[\#27[91mERROR\#27[0m] 5Unsupported operand %s with data type of size %d\r\n", 0
    roStr_76 db "\tpop rax\r\n\tmov qword [%s], rax\r\n", 0
    roStr_75 db "\tpop rax\r\n\tmov qword [rbp + %d], rax\r\n", 0
    roStr_74 db "\tpop rax\r\n\tmov byte [%s], al\r\n", 0
    roStr_73 db "[\#27[91mERROR\#27[0m] Unknown identifier '%s'\r\n", 0
    roStr_72 db "\tpush qword [%s]\r\n", 0
    roStr_71 db "\tpush qword [rbp + %d]\r\n", 0
    roStr_70 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_69 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_68 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n\tpush qword [rdx]\r\n", 0
    roStr_67 db "\tmov rdx, %s\r\n\tadd rdx, [%s]\r\n\tmovzx rax, byte [rdx]\r\n\tpush qword rax\r\n", 0
    roStr_66 db "\tpush %s\r\n", 0
    roStr_65 db "\tadd rsp, %d\r\n", 0
    roStr_64 db "\r\n\tcall %s\r\n\tmov [%s], rax\r\n", 0
    roStr_63 db "\tpush qword [%s]\r\n", 0
    roStr_62 db "\tpush qword [rbp + %d]\r\n", 0
    roStr_61 db "\tpush qword %s\r\n", 0
    roStr_60 db "Found proc call\r\n", 0
    roStr_59 db "Found operand of type %d:  %s\r\n", 0
    roStr_58 db "[\#27[91mERROR\#27[0m] Expected assignment operator after literal\r\n", 0
    roStr_57 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_56 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_55 db "\tmov rax, [%s]\r\n\tmov [rdx], rax\r\n", 0
    roStr_54 db "\tmovzx rax, byte [%s]\r\n\tmov byte [rdx], al\r\n", 0
    roStr_53 db "\tmov rax, qword [rbp + %d]\r\n\tmov byte [rdx], al\r\n", 0
    roStr_52 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_51 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_50 db "\tmov qword [rdx], %s\r\n", 0
    roStr_49 db "\tmov byte [rdx], %s\r\n", 0
    roStr_48 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_47 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_46 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n", 0
    roStr_45 db "\tmov rdx, %s\r\n\tadd rdx, [%s]\r\n", 0
    roStr_44 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_43 db "[\#27[91mERROR\#27[0m] Unsupported data type of size %d\r\n", 0
    roStr_42 db "\tmov rax, %s\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n", 0
    roStr_41 db "\tmov rdx, %s\r\n\tadd rdx, %s\r\n", 0
    roStr_40 db "\r\n\tcall %s\r\n", 0
    roStr_39 db "[\#27[92mINFO\#27[0m] Symbol '%s' has %d data type\r\n", 0
    roStr_38 db "[\#27[92mINFO\#27[0m] Processing assignment to '%s'\r\n", 0
    roStr_37 db "\r\nsection .data\r\n\t%s db %s\r\nsection .text\r\n", 0
    roStr_36 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_35 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'uint8'\r\n", 0
    roStr_34 db "[\#27[91mERROR\#27[0m] Expected identifier after 'uint8'\r\n", 0
    roStr_33 db "\r\nsection .data\r\n\t%s dq %s\r\nsection .text\r\n", 0
    roStr_32 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_31 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'uint64'\r\n", 0
    roStr_30 db "[\#27[91mERROR\#27[0m] Expected identifier after 'uint64'\r\n", 0
    roStr_29 db "\r\n    jmp .end_%d\r\n", 0
    roStr_28 db "\r\n    jmp .while_%d\r\n", 0
    roStr_27 db ";do_%d:\r\n", 0
    roStr_26 db "[\#27[91mERROR\#27[0m] Unsupported 'while' condition. Found %d tokens\r\n", 0
    roStr_25 db "[\#27[91mERROR\#27[0m] Keyword 'do' is not after 'while'\r\n", 0
    roStr_24 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_23 db "\r\n.while_%d:\r\n", 0
    roStr_22 db "\r\n.end_%d:\r\n", 0
    roStr_21 db "\r\n    jmp .while_%d\r\n    ; end while_%d", 0
    roStr_20 db "[\#27[91mERROR\#27[0m] Keyword 'end' is not after 'then', 'else' or 'do'\r\n", 0
    roStr_19 db "\r\n\tjmp .end_%d\r\n.else_%d:\r\n", 0
    roStr_18 db "[\#27[91mERROR\#27[0m] Keyword 'else' is not after 'then'\r\n", 0
    roStr_17 db ";then_%d:\r\n", 0
    roStr_16 db "[\#27[91mERROR\#27[0m] Unsupported 'if' condition. Found %d tokens\r\n", 0
    roStr_15 db "[\#27[91mERROR\#27[0m] Keyword 'then' is not after 'if'\r\n", 0
    roStr_14 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_13 db "\r\n;.if_%d:\r\n", 0
    roStr_12 db "[DEBUG] Current token index: %d\r\n", 0
    roStr_11 db "[DEBUG] Current token type: %x\r\n", 0
    roStr_10 db "[DEBUG] Found %d tokens.\r\n", 0
    roStr_9 db "[\#27[92mINFO\#27[0m] Found %d tokens.\r\n", 0
    roStr_8 db "Token: %s\r\n", 0
    roStr_7 db "Newline %d\n", 0
    roStr_6 db "[\#27[92mINFO\#27[0m] Compiling file '%s'...\r\n", 0
    roStr_5 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_4 db "Read %d bytes from file '%s'.\r\n", 0
    roStr_3 db "[\#27[91mERROR\#27[0m] Error reading file '%s'. Error code: %d\r\n", 0
    roStr_2 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_1 db "[\#27[92mINFO\#27[0m] Output file '%s'\r\n", 0
    roStr_0 db "[\#27[92mINFO\#27[0m] Input file '%s'\r\n", 0
