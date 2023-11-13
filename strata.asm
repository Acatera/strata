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

%define CompareOperatorWith(candidate) _CompareOperatorWith_ candidate
%macro _CompareOperatorWith_ 1
    multipush rdi, rsi, rcx, r10
    strcmp(op, %1, %1.length)
    multipop rdi, rsi, rcx, r10
%endmacro

%define CompareTokenWith(c) _CompareTokenWith_ c
%macro _CompareTokenWith_ 1
    multipush rdi, rsi, rcx, r10
    strcmp(r10, %1, %1.length)
    multipop rdi, rsi, rcx, r10
%endmacro

%define OperatorEquals         1
%define OperatorNotEquals      2
%define OperatorLess           3
%define OperatorLessOrEqual    4
%define OperatorGreater        5
%define OperatorGreaterOrEqual 6
%define OperatorAssignment     7

; Reserve 4 bits for operator type
%define OperandStringLiteral 0 + (1 << 4)
%define OperandAsmLiteral    1 + (1 << 4)
%define OperandLiteral       2 + (1 << 4)

; Reserve 4 bits for operand type
%define KeywordIf   0 + (1 << (4 + 4))
%define KeywordThen 1 + (1 << (4 + 4))
%define KeywordEnd  2 + (1 << (4 + 4))

; todo - revisit this
%define defOperatorEquals word OperatorEquals
%define defOperatorNotEquals word OperatorNotEquals
%define defOperatorLess word OperatorLess
%define defOperatorLessOrEqual word OperatorLessOrEqual
%define defOperatorGreater word OperatorGreater
%define defOperatorGreaterOrEqual word OperatorGreaterOrEqual
%define defOperatorAssignment word OperatorAssignment

%define defOperandStringLiteral word OperandStringLiteral
%define defOperandAsmLiteral word OperandAsmLiteral
%define defOperandLiteral word OperandLiteral

%define defKeywordIf word KeywordIf
%define defKeywordThen word KeywordThen
%define defKeywordEnd word KeywordEnd

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
    ptrBuffer256 resb MED_BUFFER_SIZE
    blockStack resb 256 * Block.size ; todo - revisit this
    blockCount resq 1
    lpProcessInformation resb 24
    lpStartupInfo resb 104
    tokenList resq MAX_TOKEN_COUNT * Token.size
    dwTokenCount resd 1

    hndSourceFile resq 1
    hndDestFile resq 1
    dwBytesRead resd 1
    dwBytesWritten resd 1
    szSourceFile resb 256
    szDestFile resb 256
    szFilenameWithoutExtension resb 256

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
    hStdOut dq 0
    bExpectLabel db 0
    bIsIfCondition db 0
    dwIfKeywordCount dq 0
    chAsmStart equ 0x60
    chDoubleQuote equ 0x22
    chComma equ 0x2c
    wScopedBlockCurrentId dw 0
    
    szIfLabel db 0xd, 0xa, ".if_"
    szIfLabelLength equ $ - szIfLabel
    szThenLabel db 0xd, 0xa, ".then_"
    szThenLabelLength equ $ - szThenLabel
    szEndLabel db 0xd, 0xa, ".endif_"
    szEndLabelLength equ $ - szEndLabel
    argCount dq 0
    endline db 0xd, 0xa
    szSectionData db "section .data", 0xd, 0xa
    szSectionDataLength equ $ - szSectionData

    cStrPrintTokenFormat db " TokenStart: %d, Length: %d, Token: ", 0
    cStrPrintTokenValueFormat db "%s", 0xd, 0xa, 0

    cStrInputFileMessage db "[Debug] Input file %s", 0xd, 0xa, 0
    cStrOutputFileMessage db "[Debug] Output file %s", 0xd, 0xa, 0
    cStrCompileMessageFormat db "Compiling file %s...", 0xd, 0xa, 0
    cStrDoneCompiling db "Done compiling.", 0xd, 0xa, 0
    cStrAssemblyMessage db "[INFO] nasm -f win64 -g %s.asm -o %s.o -w+all -w+error", 0xd, 0xa, 0
    cStrAssemblyApplication db "nasm.exe", 0
    cStrAssemblyCommand db "nasm.exe -f win64 -g %s.asm -o %s.o -w+all -w+error", 0
    cStrLinkingMessage db "[INFO] ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0xd, 0xa, 0
    cStrLinkingCommand db "ld -e _start %s.o -o %s.exe -lkernel32 -lWs2_32 -Llib", 0
    cStrGeneratedMessage db "[INFO] Generated %s.exe", 0xd, 0xa, 0

    ; filenames
    cStrObjectFile db "%s.o", 0

    ; asm output 
    cStrIfLabelFormat db 0xd, 0xa, ".if_%d:", 0xd, 0xa, 0
    cStrThenLabelFormat db ".then_%d:", 0xd, 0xa, 0
    cStrEndLabelFormat db 0xd, 0xa, ".endif_%d:", 0xd, 0xa, 0
    cStrEndLabelFormatForJump db ".endif_%d", 0
    cStrCmpFormat db "    cmp %s, %s", 0xd, 0xa, 0
    cStrJmpEquals db "    jne %s", 0xd, 0xa, 0
    cStrJmpNotEquals db "    je %s", 0xd, 0xa, 0
    cStrJmpLess db "    jge %s", 0xd, 0xa, 0
    cStrJmpLessOrEqual db "    jg %s", 0xd, 0xa, 0
    cStrJmpGreater db "    jle %s", 0xd, 0xa, 0
    cStrJmpGreaterOrEqual db "    jl %s", 0xd, 0xa, 0
    cStrStringLiteral db "roStr_%d", 0
    cStrReadOnlySectionHeader db "section .rdata", 0xd, 0xa, 0
    cStrReadOnlySectionHeaderLength equ $ - cStrReadOnlySectionHeader - 1
    cStrReadOnlySectionEntry db "    roStr_%d db %s, 0", 0xd, 0xa, 0

    ; error messages
    cStrFileOpenError db "Error opening file '%s'. Error code: %d", 0
    cStrFileReadError db "Error reading file '%s'. Error code: %d", 0
    cStrErrorThenNotAfterIf db "Error: '", VT_91, "then", VT_END, "' not after '", VT_91, "if", VT_END, "'.", 0xd, 0xa, 0
    cStrErrorEndNotAfterThen db "Error: '", VT_91, "end", VT_END, "' not after '", VT_91, "then", VT_END, "'.", 0xd, 0xa, 0
    cStrUnknownWord db "Error: unknown word '", VT_91, "%s", VT_END, "'", 0xd, 0xa, 0
    cStrGenericError db "Error: generic error.", 0xd, 0xa, 0
    cStrErrorUnsupportedIfCondition db "Error: Unsupported if condition. Found %d tokens", 0xd, 0xa, 0
    cStrErrorUnsupportedOperator db "Error: Unsupported operator: %d", 0xd, 0xa, 0
    cStrErrorAssembling db "Error: Assembling failed.", 0xd, 0xa, 0
    cStrErrorLinking db "Error: Linking failed.", 0xd, 0xa, 0
    cStrErrorStringListFull db "Error: String list full.", 0xd, 0xa, 0

    ; generic formats
    cStrInfoString db "[INFO] %s", 0xd, 0xa, 0
    cStrDecimalFormatNL db "%d", 0xd, 0xa, 0
    cStrHexFormatNL db "%x", 0xd, 0xa, 0
    cStrDebugToken db "Type %x, Start: %d, Length: %d", 0xd, 0xa, 0
    cStrDebugTokenValue db "[Debug] Token value: %s", 0xd, 0xa, 0
    cStrDebugTokenCount db 0xd, 0xa, "[Debug] Token count: %d", 0xd, 0xa, 0
    cStrDebugTokenCurrentTokenIndex db "[Debug] Current token index: %d", 0xd, 0xa, 0

    ;junk 
    cStrDebugWritingExpression db "Writing expression -------------", 0xd, 0xa, 0
    cStrDebugToken2 db "Writing token to file: start: %d, length: %d", 0xd, 0xa, 0
    cStrpush_string_literal db "push_string_literal", 0xd, 0xa, 0

section .text
    global _start
    extern CreateFileA
    extern ReadFile
    extern WriteFile
    extern CloseHandle
    extern DeleteFile
    extern GetLastError
    extern GetCommandLineA
    extern CreateProcessA

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
.if_current_arg_empty:
    cmp r8, 0
    jne .endif_current_arg_empty
.then_current_arg_empty:
    inc rdi
    jmp .arg_loop
.endif_current_arg_empty:

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
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    ; print input and output file names
    printf([hStdOut], cStrInputFileMessage, szSourceFile)
    printf([hStdOut], cStrOutputFileMessage, szDestFile)


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

    ; Check if the file handle is valid
.if_0:
    cmp rax, 0
    jge .endif_0
.then_0:
   call GetLastError
    printf([hStdOut], cStrFileOpenError, szSourceFile, rax)
    ExitProcess(1)
.endif_0:


.file_opened:    
    mov [hndSourceFile], rax

    ; Preparing the parameters for ReadFile
    mov rcx, [hndSourceFile]      ; Handle to the file (HANDLE)
    mov rdx, szSourceCode        ; Pointer to the buffer that receives the data read from the file (LPVOID)
    mov r8, dword SOURCE_CODE_SIZE   ; Number of bytes to be read from the file (DWORD)
    mov r9, dwBytesRead         ; Pointer to the variable that receives the number of bytes read (LPDWORD)
    sub rsp, 32
    push 0
    call ReadFile

    ; Check if the function succeeded
.if_1:
    cmp rax, 0
    jne .endif_1
.then_1:
   call GetLastError
    printf([hStdOut], cStrFileReadError, rax)
    ExitProcess(1)
.endif_1:


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

    ; Check if the function succeeded
.if_2:
    cmp rax, 0
    jge .endif_2
.then_2:
   call GetLastError
    printf([hStdOut], cStrFileOpenError, szDestFile, rax)
    ExitProcess(1)
.endif_2:


    mov [hndDestFile], rax
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    printf([hStdOut], cStrCompileMessageFormat, szSourceFile)

.init_string_literal_buffer:
    ; initialize string count
    mov rax, 0
    mov [dwStringCount], rax

    ; initialize string list end pointer
    mov rax, pStringList
    mov [pStringListEnd], rax

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
.if_3:
    cmp r9, 0
    jne .endif_3
.then_3:

        inc rdi
        inc r8
        jmp .read_token_loop
.endif_3:


.print_token:
    mov r10, szSourceCode
    add r10, r8

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; reserve space on the stack for the token type
    mov [rbp], word 0 ; initialize token type to 0
    

.if_token_is_if:
    CompareTokenWith(szKeywordIf)
    jne .endif_token_is_if
.then_token_is_if:
    mov [rbp], word KeywordIf
    jmp .token_type_set
.endif_token_is_if:

.if_token_is_then:
    CompareTokenWith(szKeywordThen)
    jne .endif_token_is_then
.then_token_is_then:
    mov [rbp], word KeywordThen
    jmp .token_type_set
.endif_token_is_then:

.if_token_is_end:
    CompareTokenWith(szKeywordEnd)
    jne .endif_token_is_end
.then_token_is_end:
    mov [rbp], word KeywordEnd
    jmp .token_type_set
.endif_token_is_end:

.if_token_is_eq:
    CompareTokenWith(szOperatorEquals)
    jne .endif_token_is_eq
.then_token_is_eq:
    mov [rbp], word OperatorEquals
    jmp .token_type_set
.endif_token_is_eq:

.if_token_is_neq:
    CompareTokenWith(szOperatorNotEquals)
    jne .endif_token_is_neq
.then_token_is_neq:
    mov [rbp], word OperatorNotEquals
    jmp .token_type_set
.endif_token_is_neq:

.if_token_is_lteq:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .endif_token_is_lteq
.then_token_is_lteq:
    mov [rbp], word OperatorLessOrEqual
    jmp .token_type_set
.endif_token_is_lteq:

.if_token_is_lt:
    CompareTokenWith(szOperatorLess)
    jne .endif_token_is_lt
.then_token_is_lt:
    mov [rbp], word OperatorLess
    jmp .token_type_set
.endif_token_is_lt:

.if_token_is_gteq:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .endif_token_is_gteq
.then_token_is_gteq:
    mov [rbp], word OperatorGreaterOrEqual
    jmp .token_type_set
.endif_token_is_gteq:

.if_token_is_gt:
    CompareTokenWith(szOperatorGreater)
    jne .endif_token_is_gt
.then_token_is_gt:
    mov [rbp], word OperatorGreater
    jmp .token_type_set
.endif_token_is_gt:

.if_token_is_assign:
    CompareTokenWith(szOperatorAssignment)
    jne .endif_token_is_assign
.then_token_is_assign:
    mov [rbp], word OperatorAssignment
    jmp .token_type_set
.endif_token_is_assign:

.token_type_set:
    ; test if token type is 0
    push rax
    mov rax, [rbp]
    cmp rax, 0
    pop rax
    jne .endif_token_type_is_not_zero
    ; printf([hStdOut], cStrGenericError)

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

    ; multipush r8, r9, rdi, rsi, rcx, rdx, r10, r11
    ; mov r11, szSourceCode
    ; add r8, r11
    ; memcpy(ptrBuffer64, r8, r9)
    ; inc rdi
    ; mov byte [rdi], 0
    ; printf([hStdOut], cStrDebugTokenValue, ptrBuffer64)
    ; multipop r8, r9, rdi, rsi, rcx, rdx, r10, r11

    pop rbp

    add rsp, 8 ; restore stack pointer

    ; multipush r8, r9, rdi
    ; WriteFile([hndDestFile], r10, r9, dwBytesWritten, 0)
    ; multipop r8, r9, rdi
    ; end of temporary

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

.source_code_parsed:
%define NextToken() nextToken
%macro nextToken 0
    add rdx, Token.size ; jump to next token
    mov rbx, [tokenIndex]
    inc rbx
    mov [tokenIndex], rbx
    jmp .while_counter_less_than_token_count
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

    ; todo - remove this temp code
    push rbx
    mov ebx, dword [dwTokenCount]
    printf([hStdOut], cStrDebugTokenCount, rbx)
    pop rbx
    ; end of temp code

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
    ; printf([hStdOut], cStrHexFormatNL, rbx)
    cmp ebx, [dwTokenCount]
    jge .end_counter_less_than_token_count

    ; mov r10w, currentToken.Type
    ; mov r11d, currentToken.Start
    ; mov r12d, currentToken.Length

%ifdef DEBUG    
    PushCallerSavedRegs()
    printf([hStdOut], cStrDebugTokenCurrentTokenIndex, rbx)
    PopCallerSavedRegs()
%endif

.if_4:
    cmp currentToken.Type, defOperandAsmLiteral
    jne .endif_4
.then_4:

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
.endif_4:
 ; keyword 'if'
.if_5:
    cmp currentToken.Type, defKeywordIf
    jne .endif_5
.then_5:

        PushCallerSavedRegs()
        sprintf(ptrBuffer64, cStrIfLabelFormat, [wScopedBlockCurrentId])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        PushBlockToken(defKeywordIf, [wScopedBlockCurrentId])
        
        inc word [wScopedBlockCurrentId]
        PopCallerSavedRegs()
        NextToken()
.endif_5:


    
    .if_token_is_then_0:
        cmp currentToken.Type, word KeywordThen
        jne .endif_token_is_then_0
    .then_token_is_then_0:
        PushCallerSavedRegs()
        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]

%ifdef DEBUG
        printf([hStdOut], cStrHexFormatNL, rbx)
%endif
        
.if_6:
    cmp bx, KeywordIf
    je .endif_6
.then_6:

            printf([hStdOut], cStrErrorThenNotAfterIf, szSourceFile)
            jmp .exit
.endif_6:

        
        push rax ; rax stores pointer to block struct

        ; get number of tokens in if condition
        mov r10d, [tokenIndex] ; current token index
        mov r11d, dword [rax + Block.TokenIndex] ; if token index
        inc r11d ; skip 'if' token
        sub r10d, r11d ; r10d stores number of tokens in if condition
        
.if_7:
    cmp r10d, 3
    je .endif_7
.then_7:

            printf([hStdOut], cStrErrorUnsupportedIfCondition, r10)
            jmp .exit
.endif_7:


        ; todo - construct condition
        mov rcx, r11 ; rcx stores token index of first token of if condition
        mov dx, word [rax + Block.BlockId]
        and rdx, 0xffff
        PushCallerSavedRegs()
        call compile_condition_3
        PopCallerSavedRegs()
    
        pop rax ; rax stores pointer to block struct
        
        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, cStrThenLabelFormat, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        ; bx stores block id
        mov cx, bx
        PushBlockToken(KeywordThen, rcx)

        PopCallerSavedRegs()
        NextToken()
    .endif_token_is_then_0:

    
    .if_token_is_end_0:
        cmp currentToken.Type, word KeywordEnd
        jne .endif_token_is_end_0
    .then_token_is_end_0:
        PushCallerSavedRegs()

        PeekBlockToken()
        mov rbx, [rax + Block.TokenType]
.if_8:
    cmp bx, KeywordThen
    je .endif_8
.then_8:

            printf([hStdOut], cStrErrorEndNotAfterThen, szSourceFile)
            jmp .exit
.endif_8:


        mov bx, word [rax + Block.BlockId]
        and rbx, 0xffff
        sprintf(ptrBuffer64, cStrEndLabelFormat, rbx)
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        QuickPopBlockToken() ; pop 'then'
        QuickPopBlockToken() ; pop 'if'

        PopCallerSavedRegs()
        NextToken()
    .endif_token_is_end_0:

    .if_token_is_string_literal_0:
        cmp currentToken.Type, word OperandStringLiteral
        jne .endif_token_is_string_literal_0
    .then_token_is_string_literal_0:
        ; todo - optimize strings by removing duplicate strings
        PushCallerSavedRegs()

        push rdx
        sprintf(ptrBuffer64, cStrStringLiteral, [dwStringCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        pop rdx

        mov ecx, currentToken.Start
        mov edx, currentToken.Length
        call push_string_literal

        PopCallerSavedRegs()

        NextToken()
    .endif_token_is_string_literal_0:

%ifdef DEBUG
    mov r10w, currentToken.Type
    mov r11d, currentToken.Start
    mov r12d, currentToken.Length

    printf([hStdOut], cStrDebugToken, r10, r11, r12)

    push rax
    mov rax, szSourceCode
    add r11, rax
    memcpy(ptrBuffer64, r11, r12)
    mov rax, ptrBuffer64
    add rax, r12
    mov byte [rax], 0

    printf([hStdOut], cStrUnknownWord, ptrBuffer64)
    pop rax
%endif

    NextToken()
.end_counter_less_than_token_count:

%undef currentToken.Type
%undef currentToken.Start
%undef currentToken.Length

    call write_string_list

    pop rbp

    mov rcx, [hndDestFile]
    call CloseHandle

    printf([hStdOut], cStrDoneCompiling, szSourceFile)

    jmp .assemble_object_file

.exit:
    ExitProcess(0)
    
.assemble_object_file:
    sprintf(ptrBuffer256, cStrAssemblyCommand, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf([hStdOut], cStrInfoString, ptrBuffer256)

    memset(lpProcessInformation, 0, 24)
    memset(lpStartupInfo, 0, 104)

    mov rax, lpProcessInformation
    mov rbx, lpStartupInfo
    mov [rbx], dword 104
    and rsp, 0xfffffffffffffff0
    push     rax                        ; lpProcessInformation   
    push     rbx                        ; lpStartupInfo  
    push     NULL                       ; lpCurrentDirectory
    push     NULL                       ; lpEnvironment
    push     0x00000000                 ; dwCreationFlags
    push     0x00000000                 ; bInheritHandles
    sub rsp, 0x20
    mov r9,  NULL                       ; lpThreadAttributes
    mov r8,  NULL                       ; lpProcessAttributes
    mov rdx, ptrBuffer256                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8
.if_9:
    cmp rax, 1
    je .endif_9
.then_9:

        printf([hStdOut], cStrErrorAssembling)
        ExitProcess(1)
.endif_9:


    sprintf(ptrBuffer256, cStrLinkingCommand, szFilenameWithoutExtension, szFilenameWithoutExtension)
    printf([hStdOut], cStrInfoString, ptrBuffer256)
    
    memset(lpProcessInformation, 0, 24)
    memset(lpStartupInfo, 0, 104)

    mov rax, lpProcessInformation
    mov rbx, lpStartupInfo
    mov [rbx], dword 104
    and rsp, 0xfffffffffffffff0
    push     rax                        ; lpProcessInformation   
    push     rbx                        ; lpStartupInfo  
    push     NULL                       ; lpCurrentDirectory
    push     NULL                       ; lpEnvironment
    push     0x00000000                 ; dwCreationFlags
    push     0x00000000                 ; bInheritHandles
    sub rsp, 0x20
    mov r9,  NULL                       ; lpThreadAttributes
    mov r8,  NULL                       ; lpProcessAttributes
    mov rdx, ptrBuffer256                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8
.if_10:
    cmp rax, 1
    je .endif_10
.then_10:

        printf([hStdOut], cStrErrorLinking)
        ExitProcess(1)
.endif_10:


    ; todo - delete object file

    printf([hStdOut], cStrGeneratedMessage, szFilenameWithoutExtension, szFilenameWithoutExtension)
    jmp .exit

; this routine will save a string literal to the string list
; rcx holds token start, rdx holds token length
push_string_literal:
    PushCalleeSavedRegs()

    mov r15, szSourceCode
    add r15, rcx
    mov r14, rdx

    ; strcpy(ptrBuffer64, r15, r14)
    ; printf([hStdOut], cStrInfoString, ptrBuffer64)

    ; todo - check if string literal already exists

    ; load next available string list pointer into rax
    mov rax, [dwStringCount]
.if_11:
    cmp rax, CONST_STRING_COUNT
    jl .endif_11
.then_11:

        printf([hStdOut], cStrErrorStringListFull)
        ExitProcess(1)
.endif_11:


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

    WriteFile([hndDestFile], cStrReadOnlySectionHeader, cStrReadOnlySectionHeaderLength, dwBytesWritten)

.while_not_less_than_0:
    cmp r13, 0
    jl .end_not_less_than_0
.do_not_less_than_0:   
    mov r14, [r15]

    ; printf([hStdOut], cStrReadOnlySectionEntry, r14)

    sprintf(ptrBuffer256, cStrReadOnlySectionEntry, r13, r14)
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

    dec r13
    sub r15, qword 8 ; move back to previous string literal
    jmp .while_not_less_than_0
.end_not_less_than_0:

.end:
    PopCalleeSavedRegs()
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
%ifdef DEBUG
    printf([hStdOut], cStrDebugWritingExpression)
%endif
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

    sprintf(ptrBuffer256, cStrCmpFormat, ptrBuffer64, ptr2Buffer64)

    ; write comparison
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)
   
    ; write operator
    sub rbx, Token.size ; move back to operator
    mov r10, [rbx - Token.TokenType]
    and r10, 0xffff

    ; printf([hStdOut], cStrHexFormatNL, r10)
    mov r13, [rbp - 0x8] ; r13 stores scope id
    sprintf(ptrBuffer64, cStrEndLabelFormatForJump, r13)
    ; printf([hStdOut], cStrDebugTokenValue, ptrBuffer64)
    
.if_12:
    cmp r10, OperatorEquals
    jne .endif_12
.then_12:

        sprintf(ptrBuffer256, cStrJmpEquals, ptrBuffer64)
        jmp .valid_operator_found
.endif_12:

.if_13:
    cmp r10, OperatorNotEquals
    jne .endif_13
.then_13:

        sprintf(ptrBuffer256, cStrJmpNotEquals, ptrBuffer64)
        jmp .valid_operator_found
.endif_13:

.if_14:
    cmp r10, OperatorLess
    jne .endif_14
.then_14:

        sprintf(ptrBuffer256, cStrJmpLess, ptrBuffer64)
        jmp .valid_operator_found
.endif_14:

.if_15:
    cmp r10, OperatorLessOrEqual
    jne .endif_15
.then_15:

        sprintf(ptrBuffer256, cStrJmpLessOrEqual, ptrBuffer64)
        jmp .valid_operator_found
.endif_15:

.if_16:
    cmp r10, OperatorGreater
    jne .endif_16
.then_16:

        sprintf(ptrBuffer256, cStrJmpGreater, ptrBuffer64)
        jmp .valid_operator_found
.endif_16:

.if_17:
    cmp r10, OperatorGreaterOrEqual
    jne .endif_17
.then_17:

        sprintf(ptrBuffer256, cStrJmpGreaterOrEqual, ptrBuffer64)
        jmp .valid_operator_found
.endif_17:


    printf([hStdOut], cStrErrorUnsupportedOperator, r10)
    ExitProcess(1)

.valid_operator_found:
    WriteFile([hndDestFile], ptrBuffer256, rax, dwBytesWritten)

.end:
    PopCalleeSavedRegs()
    add rsp, 0x10
    pop rbp
    mov rax, 0
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
    szKeywordEnd db "end"
    szKeywordEnd.length equ $ - szKeywordEnd
    szKeywordGStr db "gstr"
    szKeywordGStr.length equ $ - szKeywordGStr
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

