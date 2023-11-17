bits 64
default rel


%include "inc/std.inc"
; %define DEBUG 0

%define SOURCE_CODE_SIZE 1024*1024
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

; Reserve 4 bits for operator type
%define OperandStringLiteral     0 + (1 << 4)
%define OperandAsmLiteral        1 + (1 << 4)
%define OperandLiteral           2 + (1 << 4)
%define OperandInteger           3 + (1 << 4)

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

; todo - revisit this
%define defOperatorEquals         word OperatorEquals
%define defOperatorNotEquals      word OperatorNotEquals
%define defOperatorLess           word OperatorLess
%define defOperatorLessOrEqual    word OperatorLessOrEqual
%define defOperatorGreater        word OperatorGreater
%define defOperatorGreaterOrEqual word OperatorGreaterOrEqual
%define defOperatorAssignment     word OperatorAssignment
%define defOperatorPlus           word OperatorPlus

%define defOperandStringLiteral   word OperandStringLiteral
%define defOperandAsmLiteral      word OperandAsmLiteral
%define defOperandLiteral         word OperandLiteral
%define defOperandInteger         word OperandInteger

%define defKeywordIf              word KeywordIf
%define defKeywordThen            word KeywordThen
%define defKeywordElse            word KeywordElse
%define defKeywordEnd             word KeywordEnd
%define defKeywordWhile           word KeywordWhile
%define defKeywordDo              word KeywordDo
%define defKeywordContinue        word KeywordContinue
%define defKeywordBreak           word KeywordBreak
%define defKeywordDefineNumberVar word KeywordDefineNumberVar

%define TOKEN_TYPE_SIZE 2

struc Token
    .TokenType:    resw 1 ; if you change this, also update TOKEN_TYPE_SIZE
    .TokenStart:   resq 1
    .TokenLength:  resq 1
    .size equ $ - .TokenType
endstruc

struc Block
    .TokenIndex   resd 1
    .BlockId   resw 1
    .TokenType resw 1
    .size equ $ - .TokenIndex
endstruc

%define MAX_TOKEN_COUNT 1024 * 16

%define BLOCK_ITEM_SIZE 8
section .bss
    szSourceCode resb SOURCE_CODE_SIZE
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
.if_0:
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
.if_1:
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
.if_2:
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
.if_3:
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

.token_found:
    ; is token length 0?
.if_4:
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
.if_5:
    CompareTokenWith(szKeywordIf)
    jne .else_5
;then_5:

    mov [rbp], word KeywordIf
	jmp .end_5
.else_5:

.if_6:
    CompareTokenWith(szKeywordThen)
    jne .else_6
;then_6:

    mov [rbp], word KeywordThen
	jmp .end_6
.else_6:

.if_7:
    CompareTokenWith(szKeywordElse)
    jne .else_7
;then_7:

    mov [rbp], word KeywordElse
	jmp .end_7
.else_7:

.if_8:
    CompareTokenWith(szKeywordEnd)
    jne .else_8
;then_8:

    mov [rbp], word KeywordEnd
	jmp .end_8
.else_8:

.if_9:
    CompareTokenWith(szKeywordWhile)
    jne .else_9
;then_9:

    mov [rbp], word KeywordWhile
	jmp .end_9
.else_9:

.if_10:
    CompareTokenWith(szKeywordDo)
    jne .else_10
;then_10:

    mov [rbp], word KeywordDo
	jmp .end_10
.else_10:

.if_11:
    CompareTokenWith(szKeywordContinue)
    jne .else_11
;then_11:

    mov [rbp], word KeywordContinue
	jmp .end_11
.else_11:

.if_12:
    CompareTokenWith(szKeywordBreak)
    jne .else_12
;then_12:

    mov [rbp], word KeywordBreak
	jmp .end_12
.else_12:

.if_13:
    CompareTokenWith(szKeywordNumber)
    jne .else_13
;then_13:

    mov [rbp], word KeywordDefineNumberVar
	jmp .end_13
.else_13:

.if_14:
    CompareTokenWith(szOperatorEquals)
    jne .else_14
;then_14:

    mov [rbp], word OperatorEquals
	jmp .end_14
.else_14:

.if_15:
    CompareTokenWith(szOperatorNotEquals)
    jne .else_15
;then_15:

    mov [rbp], word OperatorNotEquals
	jmp .end_15
.else_15:

.if_16:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .else_16
;then_16:

    mov [rbp], word OperatorLessOrEqual
	jmp .end_16
.else_16:

.if_17:
    CompareTokenWith(szOperatorLess)
    jne .else_17
;then_17:

    mov [rbp], word OperatorLess
	jmp .end_17
.else_17:

.if_18:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .else_18
;then_18:

    mov [rbp], word OperatorGreaterOrEqual
	jmp .end_18
.else_18:

.if_19:
    CompareTokenWith(szOperatorGreater)
    jne .else_19
;then_19:

    mov [rbp], word OperatorGreater
	jmp .end_19
.else_19:

.if_20:
    CompareTokenWith(szOperatorAssignment)
    jne .else_20
;then_20:

    mov [rbp], word OperatorAssignment
	jmp .end_20
.else_20:

.if_21:
    CompareTokenWith(szOperatorPlus)
    jne .else_21
;then_21:

    mov [rbp], word OperatorPlus
	jmp .end_21
.else_21:

    ; check if token is a number
    PushCallerSavedRegs()
    strcpy(ptrBuffer64, r10, r9)
    mov rcx, ptrBuffer64
    call atoi
.if_22:
    cmp rdx, 0
	je .else_22
;then_22:

        mov [rbp], word OperandInteger
	jmp .end_22
.else_22:

        ; otherwise, it's a literal
        mov [rbp], word OperandLiteral
.end_22:

    PopCallerSavedRegs()
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


.token_type_set:
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
    inc dword [dwTokenCount]
    multipop rax, rbx, rcx, rdx, r15

    pop rbp

    add rsp, 8 ; restore stack pointer

.advance_token:
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
.if_23:
    cmp currentToken.Type, defKeywordThen
	jne .end_23
;then_23:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_23:

.if_24:
    cmp currentToken.Type, defKeywordDo
	jne .end_24
;then_24:
   
        push r15    
        xor r15, r15
        mov [bProcessingIfCondition], r15
        pop r15
.end_24:


    cmp qword [bProcessingIfCondition], 0
    je .continue_processing
    NextToken()

.continue_processing:

.if_25:
    cmp currentToken.Type, defOperandAsmLiteral
	jne .end_25
;then_25:

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
.end_25:
 ; keyword 'if'
.if_26:
    cmp currentToken.Type, defKeywordIf
	jne .end_26
;then_26:

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
.end_26:
; keyword 'then'
.if_27:
    cmp currentToken.Type, defKeywordThen
	jne .end_27
;then_27:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_11, rbx)
        %endif 
.if_28:
    cmp bx, KeywordIf
	je .end_28
;then_28:

            printf(roStr_12, szSourceFile)
            jmp .exit
.end_28:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
.if_29:
    cmp r10d, 3
	je .end_29
;then_29:

.if_30:
    cmp r10d, 1
	je .end_30
;then_30:

                printf(roStr_13, r10)
                jmp .exit
.end_30:

.end_29:

.if_31:
    cmp r10d, 3
	jne .else_31
;then_31:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_31
.else_31:

.if_32:
    cmp r10d, 1
	jne .end_32
;then_32:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_32:

.end_31:

    
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
.end_27:
; keyword 'else'
.if_33:
    cmp currentToken.Type, defKeywordElse
	jne .end_33
;then_33:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
.if_34:
    cmp bx, KeywordThen
	je .end_34
;then_34:

            printf(roStr_15, szSourceFile)
            jmp .exit
.end_34:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_16, rbx, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PopCallerSavedRegs()
        NextToken()
.end_33:
; keyword 'end'
.if_35:
    cmp currentToken.Type, defKeywordEnd
	jne .end_35
;then_35:

        PushCallerSavedRegs()

        PeekBlockToken()
        push rax
        mov rbx, [rax + Block.TokenType]
.if_36:
    cmp bx, KeywordThen
	je .end_36
;then_36:

.if_37:
    cmp bx, KeywordElse
	je .end_37
;then_37:

.if_38:
    cmp bx, KeywordDo
	je .end_38
;then_38:

                    printf(roStr_17, szSourceFile)
                    jmp .exit
                    
.end_38:

.end_37:

.end_36:

.if_39:
    cmp bx, KeywordDo
	jne .end_39
;then_39:

            mov bx, word [rax + Block.BlockId]
            and rbx, 0xffff 
            sprintf(ptrBuffer64, roStr_18, rbx, rbx)
            WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_39:

        
        pop rax
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff 
        sprintf(ptrBuffer64, roStr_19, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        QuickPopBlockToken() ; pop 'then' or 'do'
        QuickPopBlockToken() ; pop 'if' or 'while'

        PopCallerSavedRegs()
        NextToken()
.end_35:
; keyword 'while'
.if_40:
    cmp currentToken.Type, defKeywordWhile
	jne .end_40
;then_40:

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
.end_40:
; keyword 'do'
.if_41:
    cmp currentToken.Type, defKeywordDo
	jne .end_41
;then_41:

        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

        %ifdef DEBUG
            printf(roStr_21, rbx)
        %endif 
.if_42:
    cmp bx, KeywordWhile
	je .end_42
;then_42:

            printf(roStr_22, szSourceFile)
            jmp .exit
.end_42:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
.if_43:
    cmp r10d, 3
	je .end_43
;then_43:

.if_44:
    cmp r10d, 1
	je .end_44
;then_44:

                printf(roStr_23, r10)
                jmp .exit
.end_44:

.end_43:

.if_45:
    cmp r10d, 3
	jne .else_45
;then_45:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_3
            PopCallerSavedRegs()
	jmp .end_45
.else_45:

.if_46:
    cmp r10d, 1
	jne .end_46
;then_46:

            mov rcx, r11 ; rcx stores token index of first token of if condition
            mov dx, word [rax + Block.BlockId]
            and rdx, 0xffff
            PushCallerSavedRegs()
            call compile_condition_1
            PopCallerSavedRegs()
.end_46:

.end_45:


    
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
.end_41:
; keyword 'continue'
.if_47:
    cmp currentToken.Type, defKeywordContinue
	jne .end_47
;then_47:

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
.while_48:
    cmp rbx, 0
	jle .end_48
;do_48:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
.if_49:
    cmp r10, KeywordWhile
	jne .end_49
;then_49:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_25, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_49:

    jmp .while_48
    ; end while_48
.end_48:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_47:
; keyword 'break'
.if_50:
    cmp currentToken.Type, defKeywordBreak
	jne .end_50
;then_50:

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
.while_51:
    cmp rbx, 0
	jle .end_51
;do_51:

            dec rbx
            sub r15, Block.size
            mov r10w, word [r15 + Block.TokenType]
.if_52:
    cmp r10, KeywordWhile
	jne .end_52
;then_52:

                mov r10w, [r15 + Block.BlockId]
                and r10, 0xffff
                sprintf(ptrBuffer64, roStr_26, r10)
                WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
.end_52:

    jmp .while_51
    ; end while_51
.end_51:


        pop r15

        PopCallerSavedRegs()
        NextToken()
.end_50:
 ; keyword 'num'
.if_53:
    cmp currentToken.Type, defKeywordDefineNumberVar
	jne .end_53
;then_53:

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
.if_54:
    cmp r12w, defOperandLiteral
	je .end_54
;then_54:

            printf(roStr_27)
            jmp .exit
.end_54:


        strcpy(ptrBuffer64, r13, r15)
        
        ; check if assignment operator is next
        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
.if_55:
    cmp r12w, defOperatorAssignment
	je .end_55
;then_55:

            printf(roStr_28)
            jmp .exit
.end_55:


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
        sprintf(ptrBuffer256, roStr_29, ptrBuffer64, ptr2Buffer64)
        WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

        PopCallerSavedRegs()
        SkipTokens(3)
        NextToken()
.end_53:
; literal 
.if_56:
    cmp currentToken.Type, defOperandLiteral
	jne .end_56
;then_56:

        PushCallerSavedRegs()

        ; look ahead for assignment operator
        multipush rax, rbx, r13, r14, r15
        mov rax, rbx
        mov rdx, Token.size
        mul rdx
        mov rbx, tokenList
        add rbx, rax

        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptrBuffer64, r13, r15) ; literal name

        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
.if_57:
    cmp r12w, defOperatorAssignment
	je .end_57
;then_57:

            printf(roStr_30, ptrBuffer64)
            jmp .exit
.end_57:


        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
.if_58:
    cmp r12w, defOperandLiteral
	je .end_58
;then_58:

.if_59:
    cmp r12w, defOperandInteger
	je .end_59
;then_59:

                printf(roStr_31)
                jmp .exit
.end_59:

.end_58:


        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15) ; literal name
.if_60:
    cmp r12w, defOperandInteger
	jne .else_60
;then_60:

            sprintf(ptr3Buffer64, roStr_32, ptr2Buffer64)
            WriteFile([hndDestFile], ptr3Buffer64, rax, dwBytesWritten)
	jmp .end_60
.else_60:

.if_61:
    cmp r12w, defOperandLiteral
	jne .end_61
;then_61:

            sprintf(ptr3Buffer64, roStr_33, ptr2Buffer64)
            WriteFile([hndDestFile], ptr3Buffer64, rax, dwBytesWritten)
.end_61:

.end_60:

        

        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
.if_62:
    cmp r12w, defOperatorPlus
	je .end_62
;then_62:

            printf(roStr_34)
            jmp .exit
.end_62:


        add rbx, Token.size
        mov r12w, word [rbx + Token.TokenType]
.if_63:
    cmp r12w, defOperandLiteral
	je .end_63
;then_63:

.if_64:
    cmp r12w, defOperandInteger
	je .end_64
;then_64:

                printf(roStr_35)
                jmp .exit
.end_64:

.end_63:


        mov r14w, word [rbx + Token.TokenStart]
        mov r15w, word [rbx + Token.TokenLength]
        mov r13, szSourceCode
        add r13, r14
        strcpy(ptr2Buffer64, r13, r15) ; literal name

        ; mov r14, [%2]
        ; mov r15, [%3]
        ; add r14, r15
        ; mov [%1], r14
        ; for some reason, i can't push three params
.if_65:
    cmp r12w, defOperandInteger
	jne .else_65
;then_65:

            sprintf(ptrBuffer256, roStr_36, ptr2Buffer64, ptrBuffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
	jmp .end_65
.else_65:

.if_66:
    cmp r12w, defOperandLiteral
	jne .end_66
;then_66:

            sprintf(ptrBuffer256, roStr_37, ptr2Buffer64, ptrBuffer64)
            WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
.end_66:

.end_65:
        

        multipop rax, rbx, r13, r14, r15

        PopCallerSavedRegs()
        SkipTokens(4)
        NextToken()
.end_56:

.if_67:
    cmp currentToken.Type, defOperandStringLiteral
	jne .end_67
;then_67:

        ; todo - optimize strings by removing duplicate strings
        PushCallerSavedRegs()

        push rdx
        sprintf(ptrBuffer64, roStr_38, [dwStringCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        pop rdx

        mov ecx, currentToken.Start
        mov edx, currentToken.Length
        call push_string_literal

        PopCallerSavedRegs()

        NextToken()
.end_67:


    mov r10w, currentToken.Type
    mov r11d, currentToken.Start
    mov r12d, currentToken.Length

%ifdef DEBUG
    printf(roStr_39, r10, r11, r12)
%endif

    push rax
    mov rax, szSourceCode
    add r11, rax
    strcpy(ptrBuffer64, r11, r12)

    ; printf(roStr_40, ptrBuffer64)
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

    printf(roStr_41, szSourceFile)

    jmp .assemble_object_file

.exit:
    ExitProcess(0)
    
.assemble_object_file:
    sprintf(ptrBuffer256, roStr_42, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_43, ptrBuffer256)

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
.if_68:
    cmp rax, 0
	jne .end_68
;then_68:

        printf(roStr_44)
        ExitProcess(1)
.end_68:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    
    ; printf(roStr_45, [lpExitCode])
    mov rax, [lpExitCode]
    
.if_69:
    cmp rax, 0
	je .end_69
;then_69:

        printf(roStr_46)
        ExitProcess(1)
.end_69:


    sprintf(ptrBuffer256, roStr_47, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf(roStr_48, ptrBuffer256)
    
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
.if_70:
    cmp rax, 0
	jne .end_70
;then_70:

        printf(roStr_49)
        ExitProcess(1)
.end_70:


    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , 0xFFFFFFFF
    call WaitForSingleObject

    mov rcx , [lpProcessInformation + PROCESS_INFORMATION.hProcess]
    mov rdx , lpExitCode
    call GetExitCodeProcess 
    mov rax, [lpExitCode]
    
.if_71:
    cmp rax, 0
	je .end_71
;then_71:

        printf(roStr_50)
        ExitProcess(1)
.end_71:


    ; delete object file
%ifdef DEBUG
    printf(roStr_51)
%endif

    sprintf(ptrBuffer256, roStr_52, szFilenameWithoutExtension)
    mov rcx, ptrBuffer256
    call DeleteFileA
.if_72:
    cmp rax, 0
	jne .end_72
;then_72:

        printf(roStr_53)
.end_72:


    printf(roStr_54, szFilenameWithoutExtension, szFilenameWithoutExtension)
    jmp .exit

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
.if_73:
    cmp rax, CONST_STRING_COUNT
	jl .end_73
;then_73:

        printf(roStr_55, CONST_STRING_COUNT)
        ExitProcess(1)
.end_73:


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

    sprintf(ptrBuffer256, roStr_56, r13, r14)
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

    sprintf(ptrBuffer256, roStr_57, ptrBuffer64)

    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
    
    multipush r10, r13, r14
    mov r13d, dword [dwTokenCount]
    mov r14, [rbp] ; token index points to the first operand
    add r14, 1
.while_74:
    cmp r14, r13
	jg .end_74
;do_74:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
.if_75:
    cmp r10w, defKeywordElse
	jne .end_75
;then_75:

            jmp .found_matching_keyword
.end_75:

.if_76:
    cmp r10w, defKeywordEnd
	jne .end_76
;then_76:

            jmp .found_matching_keyword
.end_76:

        
        inc r14
        add rbx, Token.size
    jmp .while_74
    ; end while_74
.end_74:

    printf(roStr_58)
    ExitProcess(1)

.found_matching_keyword:    
    mov r13, [rbp - 0x8] ; r13 stores scope id
.if_77:
    cmp r10w, defKeywordElse
	jne .else_77
;then_77:

        sprintf(ptrBuffer64, roStr_59, r13)
	jmp .end_77
.else_77:
    
        sprintf(ptrBuffer64, roStr_60, r13)
.end_77:


    multipop r10, r13, r14

    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer256, roStr_61, ptrBuffer64)

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

    add rbx, Token.size * 2 ; advance to second operand
    mov r10, szSourceCode
    mov r11, [rbx + Token.TokenStart]
    mov r12, [rbx + Token.TokenLength]
    add r10, r11
    strcpy(ptr2Buffer64, r10, r12)

    sprintf(ptrBuffer256, roStr_62, ptrBuffer64, ptr2Buffer64)

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
.while_78:
    cmp r14, r13
	jg .end_78
;do_78:

        ; lacking an 'or', I have to do this for now
        mov r10w, word [rbx + Token.TokenType]
.if_79:
    cmp r10w, defKeywordElse
	jne .end_79
;then_79:

            jmp .found_matching_keyword
.end_79:

.if_80:
    cmp r10w, defKeywordEnd
	jne .end_80
;then_80:

            jmp .found_matching_keyword
.end_80:

        
        inc r14
        add rbx, Token.size
    jmp .while_78
    ; end while_78
.end_78:

    printf(roStr_63)
    ExitProcess(1)

.found_matching_keyword:    

    mov r13, [rbp - 0x8] ; r13 stores scope id
.if_81:
    cmp r10w, defKeywordElse
	jne .else_81
;then_81:

        sprintf(ptrBuffer64, roStr_64, r13)
	jmp .end_81
.else_81:
    
        sprintf(ptrBuffer64, roStr_65, r13)
.end_81:


    multipop r10, r13, r14
    
.if_82:
    cmp r10, OperatorEquals
	jne .else_82
;then_82:

        sprintf(ptrBuffer256, roStr_66, ptrBuffer64)
	jmp .end_82
.else_82:

.if_83:
    cmp r10, OperatorNotEquals
	jne .else_83
;then_83:

        sprintf(ptrBuffer256, roStr_67, ptrBuffer64)
	jmp .end_83
.else_83:

.if_84:
    cmp r10, OperatorLess
	jne .else_84
;then_84:

        sprintf(ptrBuffer256, roStr_68, ptrBuffer64)
	jmp .end_84
.else_84:

.if_85:
    cmp r10, OperatorLessOrEqual
	jne .else_85
;then_85:

        sprintf(ptrBuffer256, roStr_69, ptrBuffer64)
	jmp .end_85
.else_85:

.if_86:
    cmp r10, OperatorGreater
	jne .else_86
;then_86:

        sprintf(ptrBuffer256, roStr_70, ptrBuffer64)
	jmp .end_86
.else_86:

.if_87:
    cmp r10, OperatorGreaterOrEqual
	jne .else_87
;then_87:

        sprintf(ptrBuffer256, roStr_71, ptrBuffer64)
	jmp .end_87
.else_87:

        printf(roStr_72, r10)
        ExitProcess(1)
.end_87:

.end_86:

.end_85:

.end_84:

.end_83:

.end_82:


    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

.end:
    PopCalleeSavedRegs()
    add rsp, 0x10
    pop rbp
    ; mov rax, 0
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
    szKeywordNumber db "num"
    szKeywordNumber.length equ $ - szKeywordNumber
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


section .rodata
    roStr_72 db "[\#27[91mERROR\#27[0m] Unsupported operator %x\r\n", 0
    roStr_71 db "\tjl %s\r\n", 0
    roStr_70 db "\tjle %s\r\n", 0
    roStr_69 db "\tjg %s\r\n", 0
    roStr_68 db "\tjge %s\r\n", 0
    roStr_67 db "\tje %s\r\n", 0
    roStr_66 db "\tjne %s\r\n", 0
    roStr_65 db ".end_%d", 0
    roStr_64 db ".else_%d", 0
    roStr_63 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_62 db "    cmp %s, %s\r\n", 0
    roStr_61 db "    jne %s\r\n", 0
    roStr_60 db ".end_%d", 0
    roStr_59 db ".else_%d", 0
    roStr_58 db "[\#27[91mERROR\#27[0m] Expected 'then' or 'else' after if condition\r\n", 0
    roStr_57 db "    %s\r\n", 0
    roStr_56 db "    roStr_%d db %s, 0\r\n", 0
    roStr_55 db "[\#27[91mERROR\#27[0m]: String list full. Max strings allowed: %d\r\n", 0
    roStr_54 db "[\#27[92mINFO\#27[0m] Generated %s.exe\r\n", 0
    roStr_53 db "[WARN] Deleting object file failed.\r\n", 0
    roStr_52 db "%s.o", 0
    roStr_51 db "[DEBUG] Deleting object file.\r\n", 0
    roStr_50 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_49 db "[\#27[91mERROR\#27[0m] Linking failed.", 0
    roStr_48 db "[\#27[92mINFO\#27[0m] Linking using 'ld':\r\n\t%s\r\n", 0
    roStr_47 db "ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0
    roStr_46 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_45 db "[DEBUG] Exit code: %d.\r\n", 0
    roStr_44 db "[\#27[91mERROR\#27[0m] Assembling failed.", 0
    roStr_43 db "[\#27[92mINFO\#27[0m] Assembling using 'nasm':\r\n\t%s\r\n", 0
    roStr_42 db "nasm.exe -f win64 -g %s.asm -o %s.o -w+all -w+error", 0
    roStr_41 db "[\#27[92mINFO\#27[0m] Done compiling.\r\n", 0
    roStr_40 db "[WARN] Unknown token '%s'\r\n", 0
    roStr_39 db "[DEBUG] Token type %x; start: %d; length: %d\r\n", 0
    roStr_38 db "roStr_%d", 0
    roStr_37 db "\tmov rdx, [%s]\r\n\tadd rax, rdx\r\n\tmov [%s], rax\r\n", 0
    roStr_36 db "\tmov rdx, %s\r\n\tadd rax, rdx\r\n\tmov [%s], rax\r\n", 0
    roStr_35 db "[\#27[91mERROR\#27[0m] Expected literal or integer after operator\r\n", 0
    roStr_34 db "[\#27[91mERROR\#27[0m] Expected operator after assignment\r\n", 0
    roStr_33 db "\r\n\tmov rax, [%s]\r\n", 0
    roStr_32 db "\r\n\tmov rax, %s\r\n", 0
    roStr_31 db "[\#27[91mERROR\#27[0m] Expected literal or integer after assignment\r\n", 0
    roStr_30 db "[\#27[91mERROR\#27[0m] Expected assignment operator after literal '%s'\r\n", 0
    roStr_29 db "\r\nsection .data\r\n\t%s dq %s\r\nsection .text\r\n", 0
    roStr_28 db "[\#27[91mERROR\#27[0m] Expected assignment operator after 'num'\r\n", 0
    roStr_27 db "[\#27[91mERROR\#27[0m] Expected identifier after 'num'\r\n", 0
    roStr_26 db "\r\n    jmp .end_%d\r\n", 0
    roStr_25 db "\r\n    jmp .while_%d\r\n", 0
    roStr_24 db ";do_%d:\r\n", 0
    roStr_23 db "[\#27[91mERROR\#27[0m] Unsupported 'while' condition. Found %d tokens\r\n", 0
    roStr_22 db "[\#27[91mERROR\#27[0m] Keyword 'do' is not after 'while'\r\n", 0
    roStr_21 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_20 db "\r\n.while_%d:\r\n", 0
    roStr_19 db "\r\n.end_%d:\r\n", 0
    roStr_18 db "\r\n    jmp .while_%d\r\n    ; end while_%d", 0
    roStr_17 db "[\#27[91mERROR\#27[0m] Keyw ord 'end' is not after 'then', 'else' or 'do'\r\n", 0
    roStr_16 db "\r\n\tjmp .end_%d\r\n.else_%d:\r\n", 0
    roStr_15 db "[\#27[91mERROR\#27[0m] Keyword 'else' is not after 'then'\r\n", 0
    roStr_14 db ";then_%d:\r\n", 0
    roStr_13 db "[\#27[91mERROR\#27[0m] Unsupported 'if' condition. Found %d tokens\r\n", 0
    roStr_12 db "[\#27[91mERROR\#27[0m] Keyword 'then' is not after 'if'\r\n", 0
    roStr_11 db "[DEBUG] .if_token_is_then_0 - rbx %x\r\n", 0
    roStr_10 db "\r\n.if_%d:\r\n", 0
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
