bits 64
default rel


%include "inc/std.inc"
; %define DEBUG 0

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

; Reserve 4 bits for operand type
%define KeywordIf                0 + (1 << (4 + 4))
%define KeywordThen              1 + (1 << (4 + 4))
%define KeywordElse              2 + (1 << (4 + 4))
%define KeywordEnd               3 + (1 << (4 + 4))
%define KeywordWhile             4 + (1 << (4 + 4))
%define KeywordDo                5 + (1 << (4 + 4))
%define KeywordContinue          6 + (1 << (4 + 4))
%define KeywordBreak             7 + (1 << (4 + 4))
%define KeywordDefineNumberVar   8 + (1 << (4 + 4))
%define KeywordDefineStringVar   9 + (1 << (4 + 4))
%define KeywordEval             10 + (1 << (4 + 4))
%define KeywordArray            11 + (1 << (4 + 4))

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

%define defKeywordIf              word KeywordIf
%define defKeywordThen            word KeywordThen
%define defKeywordElse            word KeywordElse
%define defKeywordEnd             word KeywordEnd
%define defKeywordWhile           word KeywordWhile
%define defKeywordDo              word KeywordDo
%define defKeywordContinue        word KeywordContinue
%define defKeywordBreak           word KeywordBreak
%define defKeywordDefineNumberVar word KeywordDefineNumberVar
%define defKeywordDefineStringVar word KeywordDefineStringVar
%define defKeywordEval            word KeywordEval
%define defKeywordArray           word KeywordArray


%define TYPE_UINT64    1
%define TYPE_ARRAY     2
%define TYPE_STRING    3

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
    .Pointer resq 1
    .Type    resq 1
    .size equ $ - .Pointer
endstruc

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
        printf(roStr_4, szDestFile, rax)
        ExitProcess(1)
.end_3:


    mov [hndDestFile], rax

    printf(roStr_5, szSourceFile)

    ; initialize string count
    mov rax, 0
    mov [dwStringCount], rax

    ; initialize string list end pointer
    mov rax, pStringList
    mov [pStringListEnd], rax

    ; initialize name list
    mov rax, szNames
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
    je .token_found
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
	jmp .end_5
.else_5:

;.if_6:
    CompareTokenWith(szKeywordThen)
    jne .else_6
;then_6:

    mov [rbp], word KeywordThen
	jmp .end_6
.else_6:

;.if_7:
    CompareTokenWith(szKeywordElse)
    jne .else_7
;then_7:

    mov [rbp], word KeywordElse
	jmp .end_7
.else_7:

;.if_8:
    CompareTokenWith(szKeywordEnd)
    jne .else_8
;then_8:

    mov [rbp], word KeywordEnd
	jmp .end_8
.else_8:

;.if_9:
    CompareTokenWith(szKeywordWhile)
    jne .else_9
;then_9:

    mov [rbp], word KeywordWhile
	jmp .end_9
.else_9:

;.if_10:
    CompareTokenWith(szKeywordDo)
    jne .else_10
;then_10:

    mov [rbp], word KeywordDo
	jmp .end_10
.else_10:

;.if_11:
    CompareTokenWith(szKeywordContinue)
    jne .else_11
;then_11:

    mov [rbp], word KeywordContinue
	jmp .end_11
.else_11:

;.if_12:
    CompareTokenWith(szKeywordBreak)
    jne .else_12
;then_12:

    mov [rbp], word KeywordBreak
	jmp .end_12
.else_12:

;.if_13:
    CompareTokenWith(szKeywordNumber)
    jne .else_13
;then_13:

    mov [rbp], word KeywordDefineNumberVar
	jmp .end_13
.else_13:

;.if_14:
    CompareTokenWith(szKeywordString)
    jne .else_14
;then_14:

    mov [rbp], word KeywordDefineStringVar
	jmp .end_14
.else_14:

;.if_15:
    CompareTokenWith(szKeywordEval)
    jne .else_15
;then_15:

    mov [rbp], word KeywordEval
	jmp .end_15
.else_15:

;.if_16:
    CompareTokenWith(szKeywordArray)
    jne .else_16
;then_16:

    mov [rbp], word KeywordArray
	jmp .end_16
.else_16:

;.if_17:
    CompareTokenWith(szOperatorEquals)
    jne .else_17
;then_17:

    mov [rbp], word OperatorEquals
	jmp .end_17
.else_17:

;.if_18:
    CompareTokenWith(szOperatorNotEquals)
    jne .else_18
;then_18:

    mov [rbp], word OperatorNotEquals
	jmp .end_18
.else_18:

;.if_19:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .else_19
;then_19:

    mov [rbp], word OperatorLessOrEqual
	jmp .end_19
.else_19:

;.if_20:
    CompareTokenWith(szOperatorLess)
    jne .else_20
;then_20:

    mov [rbp], word OperatorLess
	jmp .end_20
.else_20:

;.if_21:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .else_21
;then_21:

    mov [rbp], word OperatorGreaterOrEqual
	jmp .end_21
.else_21:

;.if_22:
    CompareTokenWith(szOperatorGreater)
    jne .else_22
;then_22:

    mov [rbp], word OperatorGreater
	jmp .end_22
.else_22:

;.if_23:
    CompareTokenWith(szOperatorAssignment)
    jne .else_23
;then_23:

    mov [rbp], word OperatorAssignment
	jmp .end_23
.else_23:

;.if_24:
    CompareTokenWith(szOperatorPlus)
    jne .else_24
;then_24:

    mov [rbp], word OperatorPlus
	jmp .end_24
.else_24:

;.if_25:
    CompareTokenWith(szOperatorMinus)
    jne .else_25
;then_25:

    mov [rbp], word OperatorMinus
	jmp .end_25
.else_25:

;.if_26:
    CompareTokenWith(szOperatorMultiply)
    jne .else_26
;then_26:

    mov [rbp], word OperatorMultiply
	jmp .end_26
.else_26:

;.if_27:
    CompareTokenWith(szOperatorDivide)
    jne .else_27
;then_27:

    mov [rbp], word OperatorDivide
	jmp .end_27
.else_27:

;.if_28:
    CompareTokenWith(szOperatorModulo)
    jne .else_28
;then_28:

    mov [rbp], word OperatorModulo
	jmp .end_28
.else_28:

;.if_29:
    CompareTokenWith(szStatementEnd)
    jne .else_29
;then_29:

    mov [rbp], word StatemendEnd
	jmp .end_29
.else_29:

    ; check if token is a number
    PushCallerSavedRegs()
    strcpy(ptrBuffer64, r10, r9)
    mov rcx, ptrBuffer64
    call atoi
;.if_30:
    cmp rdx, 0
	je .else_30
;then_30:

        mov [rbp], word OperandInteger
	jmp .end_30
.else_30:

        ; otherwise, it's a literal
        mov [rbp], word OperandLiteral
.end_30:

    PopCallerSavedRegs()
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
    inc r14
    inc rdi
    jmp .asm_literal_loop

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

    jmp .read_token_loop
;-----------------------------------source code parsing----------------------------------

.source_code_parsed:
    mov r15d, dword [dwTokenCount]
    printf(roStr_6, r15)
    mov r14, 0
    mov r13, tokenList

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
    printf(roStr_7, rbx)
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
    ; printf(roStr_8, r14)
%ifdef DEBUG    
    PushCallerSavedRegs()
    printf(roStr_9, rbx)
    PopCallerSavedRegs()
%endif
;.if_31:
    cmp currentToken.Type, defKeywordThen
	jne .end_31
;then_31:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_31:

;.if_32:
    cmp currentToken.Type, defKeywordDo
	jne .end_32
;then_32:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_32:


    cmp qword [bProcessingIfCondition], 0
    je .continue_processing
    NextToken()

.continue_processing:

;.if_33:
    cmp currentToken.Type, defOperandAsmLiteral
	jne .end_33
;then_33:

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
.end_33:
 ; keyword 'if'
;.if_34:
    cmp currentToken.Type, defKeywordIf
	jne .end_34
;then_34:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_10, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordIf, [wScopedBlockCurrentId])
        
        inc word [wScopedBlockCurrentId]
        push r15
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15
        PopCallerSavedRegs()
        NextToken()
.end_34:
; keyword 'then'
;.if_35:
    cmp currentToken.Type, defKeywordThen
	jne .end_35
;then_35:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_11, rbx)
        %endif 
;.if_36:
    cmp bx, KeywordIf
	je .end_36
;then_36:

            printf(roStr_12, szSourceFile)
            jmp .exit
.end_36:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_37:
    cmp r10d, 3
	je .end_37
;then_37:

;.if_38:
    cmp r10d, 1
	je .end_38
;then_38:

                printf(roStr_13, r10)
                jmp .exit
.end_38:

.end_37:

;.if_39:
    cmp r10d, 3
	jne .else_39
;then_39:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_39
.else_39:

;.if_40:
    cmp r10d, 1
	jne .end_40
;then_40:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_40:

.end_39:

    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_14, rbx)
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
.end_35:
; keyword 'else'
;.if_41:
    cmp currentToken.Type, defKeywordElse
	jne .end_41
;then_41:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_42:
    cmp bx, KeywordThen
	je .end_42
;then_42:

            printf(roStr_15, szSourceFile)
            jmp .exit
.end_42:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_16, rbx, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_41:
; keyword 'end'
;.if_43:
    cmp currentToken.Type, defKeywordEnd
	jne .end_43
;then_43:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
;.if_44:
    cmp bx, KeywordThen
	je .end_44
;then_44:

;.if_45:
    cmp bx, KeywordElse
	je .end_45
;then_45:

;.if_46:
    cmp bx, KeywordDo
	je .end_46
;then_46:

                    printf(roStr_17, szSourceFile)
                    jmp .exit
                    
.end_46:

.end_45:

.end_44:

;.if_47:
    cmp bx, KeywordDo
	jne .end_47
;then_47:

            mov bx, word [rax + Block.BlockId]
            and rbx, 0xffff 
            sprintf(ptrBuffer64, roStr_18, rbx, rbx)
            WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_47:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_19, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        QuickPopBlockToken() ; pop 'then' or 'do'
        QuickPopBlockToken() ; pop 'if' or 'while'

        PopCallerSavedRegs()
        NextToken()
.end_43:
; keyword 'while'
;.if_48:
    cmp currentToken.Type, defKeywordWhile
	jne .end_48
;then_48:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, roStr_20, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordWhile, [wScopedBlockCurrentId])
        
        push r15    
        mov r15, 1
        mov [bProcessingIfCondition], r15
        pop r15

        inc word [wScopedBlockCurrentId]
        PopCallerSavedRegs()
        NextToken()
.end_48:
; keyword 'do'
;.if_49:
    cmp currentToken.Type, defKeywordDo
	jne .end_49
;then_49:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_21, rbx)
        %endif 
;.if_50:
    cmp bx, KeywordWhile
	je .end_50
;then_50:

            printf(roStr_22, szSourceFile)
            jmp .exit
.end_50:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
;.if_51:
    cmp r10d, 3
	je .end_51
;then_51:

;.if_52:
    cmp r10d, 1
	je .end_52
;then_52:

                printf(roStr_23, r10)
                jmp .exit
.end_52:

.end_51:

;.if_53:
    cmp r10d, 3
	jne .else_53
;then_53:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_53
.else_53:

;.if_54:
    cmp r10d, 1
	jne .end_54
;then_54:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_54:

.end_53:


    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, roStr_24, rbx)
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
.end_49:
; keyword 'continue'
;.if_55:
    cmp currentToken.Type, defKeywordContinue
	jne .end_55
;then_55:

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
.while_56:
    cmp rbx, 0
	jle .end_56
;do_56:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_57:
    cmp r10, KeywordWhile
	jne .end_57
;then_57:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_25, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_57:

    jmp .while_56
    ; end while_56
.end_56:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_55:
; keyword 'break'
;.if_58:
    cmp currentToken.Type, defKeywordBreak
	jne .end_58
;then_58:

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
.while_59:
    cmp rbx, 0
	jle .end_59
;do_59:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
;.if_60:
    cmp r10, KeywordWhile
	jne .end_60
;then_60:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_26, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_60:

    jmp .while_59
    ; end while_59
.end_59:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_58:
 ; keyword 'uint64'
;.if_61:
    cmp currentToken.Type, defKeywordDefineNumberVar
	jne .end_61
;then_61:

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
;.if_62:
    cmp r12w, defOperandLiteral
	je .end_62
;then_62:

            printf(roStr_27)
            jmp .exit
.end_62:


        strcpy(ptrBuffer64, r13, r15)

        multipush rax, rcx, rdx
        mov rcx, ptrBuffer64
        mov rdx, TYPE_UINT64
        call push_variable
        multipop rax, rcx, rdx
        
        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_63:
    cmp r12w, defOperatorAssignment
	je .end_63
;then_63:

            push rbx
            printf(roStr_28)
            pop rbx
            sub rbx, Token.size
            mov r13, qword [rbx + Token.Line]
            mov r14, qword [rbx + Token.Column]
            printf(roStr_29, r13, r14)
            jmp .exit
.end_63:


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
        sprintf(ptrBuffer256, roStr_30, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_61:
 ; keyword 'string'
;.if_64:
    cmp currentToken.Type, defKeywordDefineStringVar
	jne .end_64
;then_64:

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
;.if_65:
    cmp r12w, defOperandLiteral
	je .end_65
;then_65:

            printf(roStr_31)
            jmp .exit
.end_65:


        strcpy(ptrBuffer64, r13, r15)

        multipush rax, rcx, rdx
        mov rcx, ptrBuffer64
        mov rdx, TYPE_STRING
        call push_variable
        multipop rax, rcx, rdx
        
        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_66:
    cmp r12w, defOperatorAssignment
	je .end_66
;then_66:

            printf(roStr_32)
            jmp .exit
.end_66:


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
        sprintf(ptrBuffer256, roStr_33, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_64:
; literal 
;.if_67:
    cmp currentToken.Type, defOperandLiteral
	jne .end_67
;then_67:

        PushCallerSavedRegs()

        ; look ahead for assignment operator
        multipush rax, rbx, rdx, r11, r12, r13, r14, r15
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

        ; fetch data type from names table
        multipush rax, rcx
        mov rcx, ptr3Buffer64
        call get_data_type
        mov r15, rax
        multipop rax, rcx
;.if_68:
    cmp r15, TYPE_ARRAY
	jne .else_68
;then_68:

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

            sprintf(ptrBuffer256, roStr_34, ptrBuffer64, ptr3Buffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
;.if_69:
    cmp r12w, defOperandInteger
	jne .else_69
;then_69:

                sprintf(ptrBuffer256, roStr_35, ptr2Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_69
.else_69:

                sprintf(ptrBuffer256, roStr_36, ptr2Buffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_69:

            ; todo - verify that the next token is a ';'
            add rbx, Token.size
	jmp .end_68
.else_68:

            add rbx, Token.size
            mov r12w, word [rbx + Token.TokenType]

            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            strcpy(ptrBuffer64, r15, r14) 
            mov qword [dqStatementOpCount], 1
.while_70:
    cmp r12w, defStatemendEnd
	je .end_70
;do_70:

;.if_71:
    cmp r12w, defOperandInteger
	jne .else_71
;then_71:

                    ; push to operator stack
                    sprintf(ptrBuffer256, roStr_37, ptrBuffer64)
                    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_71
.else_71:

;.if_72:
    cmp r12w, defOperandLiteral
	jne .else_72
;then_72:

                    ; fetch data type from names table
                    multipush rax, rcx
                    mov rcx, ptrBuffer64
                    call get_data_type
                    mov r15, rax
                    multipop rax, rcx
;.if_73:
    cmp r15, TYPE_ARRAY
	jne .else_73
;then_73:

                        push rax
                        ; todo - verify that the next token is a '['
                        add rbx, Token.size * 2
                        movzx r12, word [rbx + Token.TokenType]
                        movzx r13, word [rbx + Token.TokenStart]
                        movzx r14, word [rbx + Token.TokenLength]
                        mov r15, szSourceCode
                        add r15, r13
                        strcpy(ptr2Buffer64, r15, r14) 
                        sprintf(ptrBuffer256, roStr_38, ptr2Buffer64, ptrBuffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
                        mov rax, [dqStatementOpCount]
                        add rax, 3
                        mov [dqStatementOpCount], rax
                        pop rax
                        add rbx, Token.size
	jmp .end_73
.else_73:
    
                        ; push to operator stack
                        sprintf(ptrBuffer256, roStr_39, ptrBuffer64)
                        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_73:

	jmp .end_72
.else_72:

;.if_74:
    cmp r12w, defOperandInteger
	je .end_74
;then_74:

                    multipush rax, rcx, rdx
                    mov rcx, r12
                    call push_operator
                    multipop rax, rcx, rdx
.end_74:

.end_72:

.end_71:

                add rbx, Token.size
                movzx r12, word [rbx + Token.TokenType]
                movzx r13, word [rbx + Token.TokenStart]
                movzx r14, word [rbx + Token.TokenLength]
                mov r15, szSourceCode
                add r15, r13
                strcpy(ptrBuffer64, r15, r14)
                inc qword [dqStatementOpCount]
    jmp .while_70
    ; end while_70
.end_70:

.while_75:
    cmp qword[dqOperatorCount], 0
	jl .end_75
;do_75:

                call write_operator
    jmp .while_75
    ; end while_75
.end_75:

            
            sprintf(ptrBuffer256, roStr_40, ptr3Buffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_68:


        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_67:
; eval 
;.if_76:
    cmp currentToken.Type, defKeywordEval
	jne .end_76
;then_76:

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
        
.while_77:
    cmp r12w, defStatemendEnd
	je .end_77
;do_77:

;.if_78:
    cmp r12w, defOperandInteger
	jne .else_78
;then_78:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_41, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_78
.else_78:

;.if_79:
    cmp r12w, defOperandLiteral
	jne .else_79
;then_79:

                ; push to operator stack
                sprintf(ptrBuffer256, roStr_42, ptrBuffer64)
                WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_79
.else_79:

;.if_80:
    cmp r12w, defOperandInteger
	je .end_80
;then_80:

                multipush rax, rcx, rdx
                mov rcx, r12
                call push_operator
                multipop rax, rcx, rdx
.end_80:

.end_79:

.end_78:

            add rbx, Token.size
            movzx r12, word [rbx + Token.TokenType]
            movzx r13, word [rbx + Token.TokenStart]
            movzx r14, word [rbx + Token.TokenLength]
            mov r15, szSourceCode
            add r15, r13
            strcpy(ptrBuffer64, r15, r14)
            inc qword [dqStatementOpCount]
    jmp .while_77
    ; end while_77
.end_77:

.while_81:
    cmp qword[dqOperatorCount], 0
	jl .end_81
;do_81:

            call write_operator
    jmp .while_81
    ; end while_81
.end_81:


        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens([dqStatementOpCount])
        NextToken()
.end_76:

;.if_82:
    cmp currentToken.Type, defKeywordArray
	jne .end_82
;then_82:

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
;.if_83:
    cmp r12w, defOperatorAssignment
	je .end_83
;then_83:

            printf(roStr_43)
            jmp .exit
.end_83:


        ; get element type
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_84:
    cmp r12w, defKeywordDefineNumberVar
	je .end_84
;then_84:

            printf(roStr_44)
            jmp .exit
.end_84:


        ; skip '['
        ; todo - check if '[' is present
        add rbx, Token.size

        ; get array size
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
;.if_85:
    cmp r12w, defOperandInteger
	je .end_85
;then_85:

            printf(roStr_45)
            jmp .exit
.end_85:


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
;.if_86:
    cmp r12w, defStatemendEnd
	je .end_86
;then_86:

            printf(roStr_46)
            jmp .exit
.end_86:


        multipush rax, rcx, rdx
        mov rcx, ptrBuffer64
        mov rdx, TYPE_ARRAY
        call push_variable
        multipop rax, rcx, rdx
        
        sprintf(ptrBuffer256, roStr_47, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        multipop rax, rbx, rdx, r11, r12, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(7)
        NextToken()
.end_82:

;.if_87:
    cmp currentToken.Type, defOperandStringLiteral
	jne .end_87
;then_87:

        ; todo - optimize strings by removing duplicate strings
        PushCallerSavedRegs()

        push rdx
        sprintf(ptrBuffer64, roStr_48, [dwStringCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        pop rdx

        mov ecx, currentToken.Start
        mov edx, currentToken.Length
        call push_string_literal

        PopCallerSavedRegs()

        NextToken()
.end_87:


    mov r10w, currentToken.Type
    mov r11d, currentToken.Start
    mov r12d, currentToken.Length

%ifdef DEBUG
    printf(roStr_49, r10, r11, r12)
%endif

    push rax
    mov rax, szSourceCode
    add r11, rax
    strcpy(ptrBuffer64, r11, r12)

    ; printf(roStr_50, ptrBuffer64)
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

    printf(roStr_51, szSourceFile)

    jmp .assemble_object_file

.exit:
    ExitProcess(0)
    
.assemble_object_file:
    sprintf(ptrBuffer256, roStr_52, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_53, ptrBuffer256)

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
;.if_88:
    cmp rax, 0
	jne .end_88
;then_88:

        printf(roStr_54)
        ExitProcess(1)
.end_88:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_55, [lpExitCode])
    mov rax, [lpExitCode]
    
;.if_89:
    cmp rax, 0
	je .end_89
;then_89:

        printf(roStr_56)
        ExitProcess(1)
.end_89:


    sprintf(ptrBuffer256, roStr_57, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_58, ptrBuffer256)
    
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
;.if_90:
    cmp rax, 0
	jne .end_90
;then_90:

        printf(roStr_59)
        ExitProcess(1)
.end_90:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
;.if_91:
    cmp rax, 0
	je .end_91
;then_91:

        printf(roStr_60)
        ExitProcess(1)
.end_91:


    ; delete object file
%ifdef DEBUG
    printf(roStr_61)
%endif

    sprintf(ptrBuffer256, roStr_62, szFilenameWithoutExtension)
    mov rcx, ptrBuffer256
    call DeleteFileA
;.if_92:
    cmp rax, 0
	jne .end_92
;then_92:

        printf(roStr_63)
.end_92:


    printf(roStr_64, szFilenameWithoutExtension, szFilenameWithoutExtension)
    jmp .exit

get_data_type:
    PushCalleeSavedRegs()

    mov r15, rcx ; r15 holds pointer to name
    xor r11, r11
    mov r14, [dqNameCount]
    mov r13, 0
    mov r10, pNames
.while_93:
    cmp r13, r14
	jge .end_93
;do_93:

        mov r12, [r10 + Name.Pointer]
        strcmp(r12, r15)
;.if_94:
    cmp rax, 0
	jne .end_94
;then_94:

            mov r11, [r10 + Name.Type]
    jmp .end_93

.end_94:

        add r10, Name.size
        inc r13
    jmp .while_93
    ; end while_93
.end_93:


.end:
    mov rax, r11
    PopCalleeSavedRegs()
    ret

; this routine will save a name to the variable list, along with its type
; rcx holds a null terminated string, rdx holds the type
push_variable:
    PushCalleeSavedRegs()
    
    mov r15, rdx
    mov r14, rcx

    ; set up array
    mov rax, [dqNameCount]
    mov rdx, Name.size
    mul rdx
    mov rdx, pNames
    add rax, rdx
    mov r13, rax

    ; store name
    mov r12, [r13 + Name.Pointer]
    mov rsi, r14
    mov rdi, r12

.loop:
    cmp byte [rsi], 0
    je .end_loop
    movsb
    jmp .loop

.end_loop:
    ; store type
    mov [r13 + Name.Type], r15

    ; increment name count  
    add r13, Name.size
    inc rdi
    mov [r13 + Name.Pointer], rdi
    
    inc qword [dqNameCount]

.end:
    PopCalleeSavedRegs()
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
;.if_95:
    cmp rax, CONST_STRING_COUNT
	jl .end_95
;then_95:

        printf(roStr_65, CONST_STRING_COUNT)
        ExitProcess(1)
.end_95:


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

    sprintf(ptrBuffer256, roStr_66, r13, r14)
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

    sprintf(ptrBuffer256, roStr_67, ptrBuffer64)

    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
    
    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 1
.while_96:
    cmp r14, r13
	jg .end_96
;do_96:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_97:
    cmp r10w, defKeywordElse
	jne .end_97
;then_97:

            jmp .found_matching_keyword
.end_97:

;.if_98:
    cmp r10w, defKeywordEnd
	jne .end_98
;then_98:

            jmp .found_matching_keyword
.end_98:

        
        inc r14
        add rbx, Token.size
    jmp .while_96
    ; end while_96
.end_96:

    printf(roStr_68)
    ExitProcess(1)

.found_matching_keyword:    
    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_99:
    cmp r10w, defKeywordElse
	jne .else_99
;then_99:

        sprintf(ptrBuffer64, roStr_69, r13)
	jmp .end_99
.else_99:
    
        sprintf(ptrBuffer64, roStr_70, r13)
.end_99:


    multipop r10, r13, r14

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer256, roStr_71, ptrBuffer64)

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

    ; fetch data type from names table
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
;.if_100:
    cmp r15, TYPE_UINT64
	jne .else_100
;then_100:

        sprintf(ptrBuffer256, roStr_72, ptrBuffer64, ptr2Buffer64)
	jmp .end_100
.else_100:

        sprintf(ptrBuffer256, roStr_73, ptrBuffer64, ptr2Buffer64)
.end_100:


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
.while_101:
    cmp r14, r13
	jg .end_101
;do_101:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
;.if_102:
    cmp r10w, defKeywordElse
	jne .end_102
;then_102:

;.if_103:
    cmp r15, 0
	jne .end_103
;then_103:

                jmp .found_matching_keyword
.end_103:

.end_102:

;.if_104:
    cmp r10w, defKeywordEnd
	jne .end_104
;then_104:

;.if_105:
    cmp r15, 0
	je .end_105
;then_105:

                inc r14
                add rbx, Token.size
                dec r15
    jmp .while_101

.end_105:

            jmp .found_matching_keyword
.end_104:

;.if_106:
    cmp r10w, defKeywordIf
	jne .end_106
;then_106:

            inc r15
.end_106:

        
        inc r14
        add rbx, Token.size
    jmp .while_101
    ; end while_101
.end_101:

    printf(roStr_74)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
;.if_107:
    cmp r10w, defKeywordElse
	jne .else_107
;then_107:

        sprintf(ptrBuffer64, roStr_75, r13)
	jmp .end_107
.else_107:
    
        sprintf(ptrBuffer64, roStr_76, r13)
.end_107:


    multipop r10, r13, r14
    
;.if_108:
    cmp r10, OperatorEquals
	jne .else_108
;then_108:

        sprintf(ptrBuffer256, roStr_77, ptrBuffer64)
	jmp .end_108
.else_108:

;.if_109:
    cmp r10, OperatorNotEquals
	jne .else_109
;then_109:

        sprintf(ptrBuffer256, roStr_78, ptrBuffer64)
	jmp .end_109
.else_109:

;.if_110:
    cmp r10, OperatorLess
	jne .else_110
;then_110:

        sprintf(ptrBuffer256, roStr_79, ptrBuffer64)
	jmp .end_110
.else_110:

;.if_111:
    cmp r10, OperatorLessOrEqual
	jne .else_111
;then_111:

        sprintf(ptrBuffer256, roStr_80, ptrBuffer64)
	jmp .end_111
.else_111:

;.if_112:
    cmp r10, OperatorGreater
	jne .else_112
;then_112:

        sprintf(ptrBuffer256, roStr_81, ptrBuffer64)
	jmp .end_112
.else_112:

;.if_113:
    cmp r10, OperatorGreaterOrEqual
	jne .else_113
;then_113:

        sprintf(ptrBuffer256, roStr_82, ptrBuffer64)
	jmp .end_113
.else_113:

        printf(roStr_83, r10)
        ExitProcess(1)
.end_113:

.end_112:

.end_111:

.end_110:

.end_109:

.end_108:


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
;.if_114:
    cmp qword[dqOperatorCount], 0
	jne .end_114
;then_114:

        mov [rax], rcx
        mov r15, [rax]
        inc qword [dqOperatorCount]
        PopCalleeSavedRegs()
        ret
.end_114:

    sub rax, 8
    mov r15, [rax]
    mov r15, rcx
.while_115:
    cmp [rax], rcx
	jle .end_115
;do_115:

;.if_116:
    cmp qword[dqOperatorCount], 0
	jg .end_116
;then_116:

    jmp .end_115

.end_116:

        PushCallerSavedRegs()
        call write_operator
        PopCallerSavedRegs()
        push rax
        pop rax
        sub rax, 8 
    jmp .while_115
    ; end while_115
.end_115:

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
;.if_117:
    cmp r15w, defOperatorPlus
	jne .end_117
;then_117:

        push rax
        sprintf(ptrBuffer256, roStr_84)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_117:

;.if_118:
    cmp r15w, defOperatorMinus
	jne .end_118
;then_118:

        push rax
        sprintf(ptrBuffer256, roStr_85)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_118:

;.if_119:
    cmp r15w, defOperatorMultiply
	jne .end_119
;then_119:

        push rax
        sprintf(ptrBuffer256, roStr_86)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_119:

;.if_120:
    cmp r15w, defOperatorDivide
	jne .end_120
;then_120:

        push rax
        sprintf(ptrBuffer256, roStr_87)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_120:

;.if_121:
    cmp r15w, defOperatorModulo
	jne .end_121
;then_121:

        push rax
        sprintf(ptrBuffer256, roStr_88)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
        pop rax
.end_121:


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
    szKeywordNumber db "uint64"
    szKeywordNumber.length equ $ - szKeywordNumber
    szKeywordString db "string"
    szKeywordString.length equ $ - szKeywordString
    szKeywordEval db "eval"
    szKeywordEval.length equ $ - szKeywordEval
    szKeywordArray db "array"
    szKeywordArray.length equ $ - szKeywordArray
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

section .rodata
    roStr_88 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rdx\r\n", 0
    roStr_87 db "\tpop rcx\r\n\tpop rax\r\n\txor rdx, rdx\r\n\tdiv rcx\r\n\tpush rax\r\n", 0
    roStr_86 db "\tpop rax\r\n\tpop rcx\r\n\txor rdx, rdx\r\n\tmul rcx\r\n\tpush rax\r\n", 0
    roStr_85 db "\tpop rcx\r\n\tpop rax\r\n\tsub rax, rcx\r\n\tpush rax\r\n", 0
    roStr_84 db "\tpop rax\r\n\tpop rcx\r\n\tadd rax, rcx\r\n\tpush rax\r\n", 0
    roStr_83 db "[\#27[91mERROR\#27[0m] Unsupported operator %x\r\n", 0
    roStr_82 db "\tjl %s\r\n", 0
    roStr_81 db "\tjle %s\r\n", 0
    roStr_80 db "\tjg %s\r\n", 0
    roStr_79 db "\tjge %s\r\n", 0
    roStr_78 db "\tje %s\r\n", 0
    roStr_77 db "\tjne %s\r\n", 0
    roStr_76 db ".end_%d", 0
    roStr_75 db ".else_%d", 0
    roStr_74 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_73 db "    cmp %s, %s\r\n", 0
    roStr_72 db "\tmov r15, [%s]\r\n\tcmp r15, %s\r\n", 0
    roStr_71 db "    jne %s\r\n", 0
    roStr_70 db ".end_%d", 0
    roStr_69 db ".else_%d", 0
    roStr_68 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_67 db "    %s\r\n", 0
    roStr_66 db "    roStr_%d db %s, 0\r\n", 0
    roStr_65 db "[\#27[91mERROR\#27[0m]: String list full. Max strings allowed: %d\r\n", 0
    roStr_64 db "[\#27[92mINFO\#27[0m] Generated %s.exe\r\n", 0
    roStr_63 db "[WARN] Deleting object file failed.\r\n", 0
    roStr_62 db "%s.o", 0
    roStr_61 db "[DEBUG] Deleting object file.\r\n", 0
    roStr_60 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_59 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_58 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_57 db "ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0
    roStr_56 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_55 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_54 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_53 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_52 db "nasm.exe -f win64 -g %s.asm -o %s.o -w+all -w+error", 0
    roStr_51 db "[\#27[92mINFO\#27[0m] Done compiling.\r\n", 0
    roStr_50 db "[WARN] Unknown token '%s'\r\n", 0
    roStr_49 db "[DEBUG] Token type %x; start: %d; length: %d\r\n", 0
    roStr_48 db "roStr_%d", 0
    roStr_47 db "section .bss\r\n\t%s resq %s\r\nsection .text\r\n", 0
    roStr_46 db "[\#27[91mERROR\#27[0m] Expected ';' after array definition\r\n", 0
    roStr_45 db "[\#27[91mERROR\#27[0m] Expected array size after '['\r\n", 0
    roStr_44 db "[\#27[91mERROR\#27[0m] Expected 'uint64' after 'array'\r\n", 0
    roStr_43 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'array'\r\n", 0
    roStr_42 db "\tpush qword [%s]\r\n", 0
    roStr_41 db "\tpush %s\r\n", 0
    roStr_40 db "\tpop rax\r\n\tmov qword [%s], rax\r\n", 0
    roStr_39 db "\tpush qword [%s]\r\n", 0
    roStr_38 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n\tpush qword [rdx]\r\n", 0
    roStr_37 db "\tpush %s\r\n", 0
    roStr_36 db "\tmov rax, [%s]\r\n\tmov [rdx], rax\r\n", 0
    roStr_35 db "\tmov qword [rdx], %s\r\n", 0
    roStr_34 db "\tmov rax, [%s]\r\n\tmov rdx, 8\r\n\tmul rdx\r\n\tmov rdx, %s\r\n\tadd rdx, rax\r\n", 0
    roStr_33 db "\r\nsection .bss\r\n\t%s resb %s\r\nsection .text\r\n", 0
    roStr_32 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'string'\r\n", 0
    roStr_31 db "[\#27[91mERROR\#27[0m] Expected identifier after 'string'\r\n", 0
    roStr_30 db "\r\nsection .data\r\n\t%s dq %s\r\nsection .text\r\n", 0
    roStr_29 db "[\#27[91mERROR\#27[0m] Line %d, column %d\r\n", 0
    roStr_28 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'uint64'\r\n", 0
    roStr_27 db "[\#27[91mERROR\#27[0m] Expected identifier after 'uint64'\r\n", 0
    roStr_26 db "\r\n    jmp .end_%d\r\n", 0
    roStr_25 db "\r\n    jmp .while_%d\r\n", 0
    roStr_24 db ";do_%d:\r\n", 0
    roStr_23 db "[\#27[91mERROR\#27[0m] Unsupported 'while' condition. Found %d tokens\r\n", 0
    roStr_22 db "[\#27[91mERROR\#27[0m] Keyword 'do' is not after 'while'\r\n", 0
    roStr_21 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_20 db "\r\n.while_%d:\r\n", 0
    roStr_19 db "\r\n.end_%d:\r\n", 0
    roStr_18 db "\r\n    jmp .while_%d\r\n    ; end while_%d", 0
    roStr_17 db "[\#27[91mERROR\#27[0m] Keyword 'end' is not after 'then', 'else' or 'do'\r\n", 0
    roStr_16 db "\r\n\tjmp .end_%d\r\n.else_%d:\r\n", 0
    roStr_15 db "[\#27[91mERROR\#27[0m] Keyword 'else' is not after 'then'\r\n", 0
    roStr_14 db ";then_%d:\r\n", 0
    roStr_13 db "[\#27[91mERROR\#27[0m] Unsupported 'if' condition. Found %d tokens\r\n", 0
    roStr_12 db "[\#27[91mERROR\#27[0m] Keyword 'then' is not after 'if'\r\n", 0
    roStr_11 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_10 db "\r\n;.if_%d:\r\n", 0
    roStr_9 db "[DEBUG] Current token index: %d\r\n", 0
    roStr_8 db "[DEBUG] Current token type: %x\r\n", 0
    roStr_7 db "[DEBUG] Found %d tokens.\r\n", 0
    roStr_6 db "[\#27[92mINFO\#27[0m] Found %d tokens.\r\n", 0
    roStr_5 db "[\#27[92mINFO\#27[0m] Compiling file '%s'...\r\n", 0
    roStr_4 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_3 db "[\#27[91mERROR\#27[0m] Error reading file '%s'. Error code: %d\r\n", 0
    roStr_2 db "[\#27[91mERROR\#27[0m] Error opening file '%s'. Error code: %d\r\n", 0
    roStr_1 db "[\#27[92mINFO\#27[0m] Output file '%s'\r\n", 0
    roStr_0 db "[\#27[92mINFO\#27[0m] Input file '%s'\r\n", 0
