bits 64
default rel

%include "inc/std.inc"

%define SOURCE_CODE_SIZE 1024*1024
%define SMALL_BUFFER_SIZE 64
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
%define KeywordGStr 3 + (1 << (4 + 4))


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
%define defKeywordGStr word KeywordGStr

%define TOKEN_TYPE_SIZE 2

struc Token
    .TokenType:    resw 1 ; if you change this, also update TOKEN_TYPE_SIZE
    .TokenStart:   resq 1
    .TokenLength:  resq 1
    .size equ $ - .TokenType
endstruc

%define MAX_TOKEN_COUNT 1024

section .bss
    szSourceCode resb SOURCE_CODE_SIZE
    ptrBuffer64 resb SMALL_BUFFER_SIZE
    pBuffer resb SOURCE_CODE_SIZE
    blockStack resw 256 ; todo - revisit this
    blockCount resq 1

    tokenList resq MAX_TOKEN_COUNT * Token.size
    dwTokenCount resd 1

    hndSourceFile resq 1
    hndDestFile resq 1
    dwBytesRead resd 1
    dwBytesWritten resd 1
    t1 resb 32
    t1Length resq 1
    t2 resb 32
    t2Length resq 1
    op resb OPERATOR_BUFFER_SIZE
    opLength resq 1
    firstArgStart resq 1
    szSourceFile resb 256
    szDestFile resb 256
    szGlobalConstants resb 1024*64
    qwGlobalConstantsLength resq 1
    ptrGlobalConstants resq 1
    szLastLabel resb 128
    szLastLabelLength resb 1

section .data
    hStdOut dq 0
    bExpectLabel db 0
    bIsIfCondition db 0
    dwIfKeywordCount dq 0
    chAsmStart equ 0x60
    chDoubleQuote equ 0x22
    chComma equ 0x2c
    
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

    cStrSourceFile db "%s.strata", 0
    cStrInputFileMessage db "Input file %s", 0xd, 0xa, 0
    cStrOutputFileMessage db "Output file %s", 0xd, 0xa, 0
    cStrCompileMessageFormat db "Compiling file %s...", 0xd, 0xa, 0
    cStrDoneCompiling db "Done compiling.", 0xd, 0xa, 0

    ; asm output labels
    cStrIfLabelFormat db 0xd, 0xa, ".if_%d:", 0xd, 0xa, 0
    cStrThenLabelFormat db 0xd, 0xa, ".then_%d:", 0xd, 0xa, 0
    cStrEndLabelFormat db 0xd, 0xa, ".endif_%d:", 0xd, 0xa, 0

    ; error messages
    cStrErrorThenNotAfterIf db "Error: '", VT_91, "then", VT_END, "' not after '", VT_91, "if", VT_END, "'.", 0xd, 0xa, 0
    cStrErrorEndNotAfterThen db "Error: '", VT_91, "end", VT_END, "' not after '", VT_91, "then", VT_END, "'.", 0xd, 0xa, 0

    ; generic formats
    cStrDecimalFormatNL db "%d", 0xd, 0xa, 0

section .text
    global _start
    extern CreateFileA
    extern ReadFile
    extern WriteFile
    extern GetLastError
    extern GetCommandLineA

_start:
    mov rax, szGlobalConstants
    mov [ptrGlobalConstants], rax
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
    memcpy(szDestFile, r14, r13)
    
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

    printf([hStdOut], cStrCompileMessageFormat, szSourceFile)

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
    WriteConsoleA([hStdOut], szFileOpenError, szFileOpenError.length, 0)
    call GetLastError
    mov rcx, rax
    mov rdx, ptrBuffer64
    call itoa
    WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)
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
    cmp rax, 0
    je .error

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
    cmp rax, 0
    je .error

    mov [hndDestFile], rax
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

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
.if_1:
    cmp r9, 0
    jne .endif_1
.then_1:
    inc rdi
    inc r8
    jmp .read_token_loop
.endif_1:


.print_token:
    mov r10, szSourceCode
    add r10, r8

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; reserve space on the stack for the token type
    mov [rbp], word OperandLiteral ; initialize token type to 0
    

.if_token_is_if:
    CompareTokenWith(szKeywordIf)
    jne .endif_token_is_if
.then_token_is_if:
    mov [rbp], word KeywordIf
.endif_token_is_if:

.if_token_is_then:
    CompareTokenWith(szKeywordThen)
    jne .endif_token_is_then
.then_token_is_then:
    mov [rbp], word KeywordThen
.endif_token_is_then:

.if_token_is_end:
    CompareTokenWith(szKeywordEnd)
    jne .endif_token_is_end
.then_token_is_end:
    mov [rbp], word KeywordEnd
.endif_token_is_end:

.if_token_is_eq:
    CompareTokenWith(szOperatorEquals)
    jne .endif_token_is_eq
.then_token_is_eq:
    mov [rbp], word OperatorEquals
.endif_token_is_eq:

.if_token_is_neq:
    CompareTokenWith(szOperatorNotEquals)
    jne .endif_token_is_neq
.then_token_is_neq:
    mov [rbp], word OperatorNotEquals
.endif_token_is_neq:

.if_token_is_lteq:
    CompareTokenWith(szOperatorLessOrEqual)
    jne .endif_token_is_lteq
.then_token_is_lteq:
    mov [rbp], word OperatorLessOrEqual
.endif_token_is_lteq:

.if_token_is_lt:
    CompareTokenWith(szOperatorLess)
    jne .endif_token_is_lt
.then_token_is_lt:
    mov [rbp], word OperatorLess
.endif_token_is_lt:

.if_token_is_gteq:
    CompareTokenWith(szOperatorGreaterOrEqual)
    jne .endif_token_is_gteq
.then_token_is_gteq:
    mov [rbp], word OperatorGreaterOrEqual
.endif_token_is_gteq:

.if_token_is_gt:
    CompareTokenWith(szOperatorGreater)
    jne .endif_token_is_gt
.then_token_is_gt:
    mov [rbp], word OperatorGreater
.endif_token_is_gt:

.if_token_is_assign:
    CompareTokenWith(szOperatorAssignment)
    jne .endif_token_is_assign
.then_token_is_assign:
    mov [rbp], word OperatorAssignment
.endif_token_is_assign:

.if_token_is_gstr:
    CompareTokenWith(szKeywordGStr)
    jne .endif_token_is_gstr
.then_token_is_gstr:
    mov [rbp], word KeywordGStr
.endif_token_is_gstr:

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
    mov [rbx + Token.TokenType], word ax ; token start
    mov [rbx + Token.TokenStart], r8 ; token start
    mov [rbx + Token.TokenLength], r9 ; token start
    inc dword [dwTokenCount]
    multipop rax, rbx, rcx, rdx, r15

    pop rbp

    add rsp, 8 ; restore stack pointer

.if_label_expected:
    cmp byte [bExpectLabel], 1
    jne .endif_label_expected
.then_label_expected:
    multipush rax, rcx, rdi, rsi
    ; write szTab
    memcpy([ptrGlobalConstants], szTab, szTab.length)
    add qword [qwGlobalConstantsLength], szTab.length
    add qword [ptrGlobalConstants], szTab.length
    
    ; write label
    memcpy([ptrGlobalConstants], r10, r9)
    add qword [qwGlobalConstantsLength], r9
    add qword [ptrGlobalConstants], r9

    ; save last label
    memcpy(szLastLabel, r10, r9)
    mov [szLastLabelLength], r9

    ; write separator
    memcpy([ptrGlobalConstants], szAsmDataStringType, szAsmDataStringType.length)
    add qword [qwGlobalConstantsLength], szAsmDataStringType.length
    add qword [ptrGlobalConstants], szAsmDataStringType.length

    multipop rax, rcx, rdi, rsi
    ; multipush r8, r9, rdi
    ; WriteFile([hndDestFile], r10, r9, dwBytesWritten, 0)
    ; multipop r8, r9, rdi

    mov [bExpectLabel], byte 0
    
    _reset_counters_
.endif_label_expected:

    ; this is temporary, we will write to file as we go
.if_keyword_gstr:
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordGStr, szKeywordGStr.length)
    multipop rdi, rsi, rcx, r10
    jne .endif_keyword_gstr
.then_keyword_gstr:
    mov [bExpectLabel], byte 1

    _reset_counters_
.endif_keyword_gstr:

.if_keyword_if:
    ; check if token is 'if'
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordIf, szKeywordIf.length)
    multipop rdi, rsi, rcx, r10
    jne .endif_keyword_if
.then_keyword_if:
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szIfLabel, szIfLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrBuffer64
    call itoa
    mov rdx, ptrBuffer64
    add rdx, rax
    inc rax
    mov byte [rdx], ':'
    inc rdx
    inc rax
    mov byte [rdx], 0xd
    inc rdx
    inc rax
    mov byte [rdx], 0xa
    multipush r8, r9, rdi
    WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi
    inc qword [dwIfKeywordCount]

    mov [bIsIfCondition], byte 1

    _reset_counters_
.endif_keyword_if:

.if_keyword_then:
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordThen, szKeywordThen.length)
    multipop rdi, rsi, rcx, r10
    jne .endif_keyword_then
.then_keyword_then:
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szThenLabel, szThenLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrBuffer64
    call itoa
    mov rdx, ptrBuffer64
    add rdx, rax
    inc rax
    mov byte [rdx], ':'
    inc rdx
    inc rax
    mov byte [rdx], 0xd
    inc rdx
    inc rax
    mov byte [rdx], 0xa
    multipush r8, r9, rdi
    WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi

    inc qword [dwIfKeywordCount] ; restore the counter

    _reset_counters_  
.endif_keyword_then:

.if_keyword_end:
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordEnd, szKeywordEnd.length)
    multipop rdi, rsi, rcx, r10
    jne .endif_keyword_end
.then_keyword_end:
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szEndLabel, szEndLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrBuffer64
    call itoa
    mov rdx, ptrBuffer64
    add rdx, rax
    inc rax
    mov byte [rdx], ':'
    inc rdx
    inc rax
    mov byte [rdx], 0xd
    inc rdx
    inc rax
    mov byte [rdx], 0xa
    multipush r8, r9, rdi
    WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi

    inc qword [dwIfKeywordCount] ; restore the counter

    _reset_counters_
.endif_keyword_end:

.if_is_first_if_condition_operand:
    cmp [bIsIfCondition], byte 1
    jne .endif_is_first_if_condition_operand
.then_is_first_if_condition_operand:
    ; set t1
    multipush rcx, rdx, r8, rdi, rsi
    memcpy(t1, r10, r9)
    mov [t1Length], r9
    multipop rcx, rdx, r8, rdi, rsi
    inc byte [bIsIfCondition]
    jmp .advance_token
.endif_is_first_if_condition_operand:

.if_is_if_condition_operator:
    cmp [bIsIfCondition], byte 2
    jne .endif_is_if_condition_operator
.then_is_if_condition_operator:
    ; set op
    multipush rcx, rdx, r8, rdi, rsi
    memset(op, 0, OPERATOR_BUFFER_SIZE)
    memcpy(op, r10, r9)
    mov [opLength], r9
    multipop rcx, rdx, r8, rdi, rsi
    inc byte [bIsIfCondition]
    jmp .advance_token
.endif_is_if_condition_operator:

.if_is_second_if_condition_operand:
    cmp [bIsIfCondition], byte 3
    jne .endif_is_second_if_condition_operand
.then_is_second_if_condition_operand:
    ; set t2
    multipush rcx, rdx, r8, rdi, rsi
    memcpy(t2, r10, r9)
    mov [t2Length], r9
    multipop rcx, rdx, r8, rdi, rsi

    ; write t1 <comparison> t2
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmCmp, szAsmCmp.length)
    add r8, szAsmCmp.length ; r8 stores counter
    add r11, szAsmCmp.length
    memcpy(r11, t1, [t1Length])
    add r8, [t1Length]
    add r11, [t1Length]
    ; add comma
    mov byte [r11], ','
    inc r11
    inc r8
    ; add space
    mov byte [r11], ' '
    inc r11
    inc r8
    memcpy(r11, t2, [t2Length])
    add r8, [t2Length]
    add r11, [t2Length]
    ; inc r11
    inc r8
    mov byte [r11], 0xd
    inc r11
    inc r8
    mov byte [r11], 0xa
    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11

    mov [bIsIfCondition], byte 0

.if_if_operator_is_equal:
    CompareOperatorWith(szOperatorEquals)
    jne .endif_if_operator_is_equal
.then_if_operator_is_equal:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmEqual, szAsmEqual.length)
    add r8, szAsmEqual.length 
    add r11, szAsmEqual.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_equal:

.if_if_operator_is_not_equal:
    CompareOperatorWith(szOperatorNotEquals)
    jne .endif_if_operator_is_not_equal
.then_if_operator_is_not_equal:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmNotEqual, szAsmNotEqual.length)
    add r8, szAsmNotEqual.length 
    add r11, szAsmNotEqual.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_not_equal:

.if_if_operator_is_less_or_equal:
    CompareOperatorWith(szOperatorLessOrEqual)
    jne .endif_if_operator_is_less_or_equal
.then_if_operator_is_less_or_equal:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmLessOrEqual, szAsmLessOrEqual.length)
    add r8, szAsmLessOrEqual.length 
    add r11, szAsmLessOrEqual.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_less_or_equal:

.if_if_operator_is_less:
    CompareOperatorWith(szOperatorLess)
    jne .endif_if_operator_is_less
.then_if_operator_is_less:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmLess, szAsmLess.length)
    add r8, szAsmLess.length 
    add r11, szAsmLess.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_less:

.if_if_operator_is_greater_or_equal:
    CompareOperatorWith(szOperatorGreaterOrEqual)
    jne .endif_if_operator_is_greater_or_equal
.then_if_operator_is_greater_or_equal:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmGreaterOrEqual, szAsmGreaterOrEqual.length)
    add r8, szAsmGreaterOrEqual.length 
    add r11, szAsmGreaterOrEqual.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_greater_or_equal:

.if_if_operator_is_greater:
    CompareOperatorWith(szOperatorGreater)
    jne .endif_if_operator_is_greater
.then_if_operator_is_greater:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrBuffer64
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmGreater, szAsmGreater.length)
    add r8, szAsmGreater.length 
    add r11, szAsmGreater.length
    memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
    add r8, szEndLabelForJump.length
    add r11, szEndLabelForJump.length
    multipush rax, rcx, rdx

    mov rcx, [dwIfKeywordCount]
    dec rcx ; decrement the counter
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11
    _reset_counters_
.endif_if_operator_is_greater:

.endif_is_second_if_condition_operand:
    ; jg .error

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

    multipush r8, r9, r10, rdi 
    WriteFile([hndDestFile], r10, r14, dwBytesWritten, 0)
    multipop r8, r9, r10, rdi

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

    ; write to global constants
    multipush rax, rcx, rdi, rsi
    ; Add leading quotes
    mov rax, [ptrGlobalConstants]
    mov byte [rax], chDoubleQuote
    add qword [qwGlobalConstantsLength], 1
    add qword [ptrGlobalConstants], 1
    ; Write string literal
    memcpy([ptrGlobalConstants], r10, r14)
    add qword [qwGlobalConstantsLength], r14
    add qword [ptrGlobalConstants], r14
    ; Add trailing quotes
    mov rax, [ptrGlobalConstants]
    mov byte [rax], chDoubleQuote
    add qword [qwGlobalConstantsLength], 1
    add qword [ptrGlobalConstants], 1
    ; ; Add trailing null terminator
    ; memcpy([ptrGlobalConstants], szAsmStringLiteralNullTerminator, szAsmStringLiteralNullTerminator.length)
    ; add qword [qwGlobalConstantsLength], szAsmStringLiteralNullTerminator.length
    ; add qword [ptrGlobalConstants], szAsmStringLiteralNullTerminator.length
    ; add newline
    memcpy([ptrGlobalConstants], endline, 2)
    add qword [qwGlobalConstantsLength], 2
    add qword [ptrGlobalConstants], 2

    ; write length of string literal
    ; write a szTab
    memcpy([ptrGlobalConstants], szTab, szTab.length)
    add qword [qwGlobalConstantsLength], szTab.length
    add qword [ptrGlobalConstants], szTab.length
    ; write last label
    memcpy([ptrGlobalConstants], szLastLabel, [szLastLabelLength])
    mov rax, [szLastLabelLength]
    add qword [qwGlobalConstantsLength], rax
    add qword [ptrGlobalConstants], rax
    ; write suffix
    memcpy([ptrGlobalConstants], szAsmDataStringSuffix, szAsmDataStringSuffix.length)
    add qword [qwGlobalConstantsLength], szAsmDataStringSuffix.length
    add qword [ptrGlobalConstants], szAsmDataStringSuffix.length
    ; write type (aka "equ $ - ")
    memcpy([ptrGlobalConstants], szAsmDataStringLengthType, szAsmDataStringLengthType.length)
    add qword [qwGlobalConstantsLength], szAsmDataStringLengthType.length
    add qword [ptrGlobalConstants], szAsmDataStringLengthType.length
    ; write last label
    memcpy([ptrGlobalConstants], szLastLabel, [szLastLabelLength])
    mov rax, [szLastLabelLength]
    add qword [qwGlobalConstantsLength], rax
    add qword [ptrGlobalConstants], rax
    ; write newline
    memcpy([ptrGlobalConstants], endline, 2)
    add qword [qwGlobalConstantsLength], 2
    add qword [ptrGlobalConstants], 2
    multipop rax, rcx, rdi, rsi
    ; multipush r8, r9, rdi
    ; WriteFile([hndDestFile], r10, r14, dwBytesWritten, 0)

    ; multipop r8, r9, rdi

    jmp .read_token_loop
.error:
    WriteConsoleA([hStdOut], szGenericError, szGenericError.length, 0)

.source_code_parsed:
%define NextToken() nextToken
%macro nextToken 0
    add rdx, Token.size ; jump to next token
    inc rbx
    jmp .while_counter_less_than_token_count
%endmacro

%define PushBlockToken(tokenType) pushBlockToken tokenType
%macro pushBlockToken 1
    multipush rax, rbx, rdx
    mov rbx, blockStack
    mov rax, [blockCount]
    mov rdx, TOKEN_TYPE_SIZE 
    mul rdx
    add rbx, rax             ; rbx points to just after the top of the stack
    mov word [rbx], word %1  ; push token type
    inc qword [blockCount]   ; increment block count
    multipop rax, rbx, rdx
%endmacro

; this will only decrement the block count
%define QuickPopBlockToken() quickPopBlockToken
%macro quickPopBlockToken 0
    dec qword [blockCount]
%endmacro

%define PopBlockToken() popBlockToken
%macro popBlockToken 0
    multipush rbx, rdx
    mov rbx, blockStack
    dec qword [blockCount]   ; decrement block count
    mov rax, [blockCount]
    mov rdx, TOKEN_TYPE_SIZE 
    mul rdx
    add rbx, rax             ; rbx points to top of the stack
    mov word ax, word [rbx]  ; load token type
    multipop rbx, rdx
%endmacro

%define PeekBlockToken() peekBlockToken
%macro peekBlockToken 0
    multipush rbx, rdx
    mov rbx, blockStack
    mov rax, [blockCount]
    mov rdx, TOKEN_TYPE_SIZE 
    mul rdx
    add rbx, rax             
    sub rbx, TOKEN_TYPE_SIZE ; rbx points to top of the stack
    mov word ax, word [rbx]  ; load token type
    multipop rbx, rdx
%endmacro

    WriteFile([hndDestFile], szHorizontalLine, szHorizontalLine.length, dwBytesWritten, 0)

    ; iterate over tokens
    push rbp
    mov rbp, rsp

    ; cannot directly move mem to mem
    mov eax, [dwTokenCount]
    mov [rbp], rax
    xor rbx, rbx ; counter
    mov rdx, tokenList
    ; pa
    ; initialize counters
    mov [dwIfKeywordCount], dword 0

%define currentToken.Type word [rdx + Token.TokenType]
%define currentToken.Start dword [rdx + Token.TokenStart]
%define currentToken.Length dword [rdx + Token.TokenLength]

.while_counter_less_than_token_count:
    cmp ebx, [rbp]
    jge .end_counter_less_than_token_count

.if_2:
    cmp currentToken.Type, defOperandAsmLiteral
    jne .endif_2
.then_2:

        multipush rcx, rdx, r8, r9, r10, r11, r12
  
        ; write asm code
        mov r10d, currentToken.Start
        mov r11, szSourceCode
        add r10, r11
        inc r10 ; skip leading '0x40'
        mov r11d, currentToken.Length
        dec r11 ; skip trailing '0x40'

        WriteFile([hndDestFile], r10, r11, dwBytesWritten)
        multipop rcx, rdx, r8, r9, r10, r11, r12

        nextToken
.endif_2:


    .if_token_is_asm_0:
        cmp currentToken.Type, defOperandAsmLiteral
        jne .endif_token_is_asm_0
    .then_token_is_asm_0:
        multipush rcx, rdx, r8, r9, r10, r11, r12
  
        ; write asm code
        mov r10d, currentToken.Start
        mov r11, szSourceCode
        add r10, r11
        inc r10 ; skip leading '0x40'
        mov r11d, currentToken.Length
        dec r11 ; skip trailing '0x40'

        WriteFile([hndDestFile], r10, r11, dwBytesWritten)
        multipop rcx, rdx, r8, r9, r10, r11, r12

        nextToken
    .endif_token_is_asm_0:

    .if_token_is_if_0:
        cmp currentToken.Type, word KeywordIf
        jne .endif_token_is_if_0
    .then_token_is_if_0:
        PushCallerSavedRegs()

        sprintf(ptrBuffer64, cStrIfLabelFormat, [dwIfKeywordCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
        inc qword [dwIfKeywordCount]

        PushBlockToken(KeywordIf)
        
        PopCallerSavedRegs()
        NextToken()
    .endif_token_is_if_0:

    .if_token_is_then_0:
        cmp currentToken.Type, word KeywordThen
        jne .endif_token_is_then_0
    .then_token_is_then_0:
        PushCallerSavedRegs()

        PeekBlockToken()
.if_3:
    cmp rax, KeywordIf
    je .endif_3
.then_3:

            printf([hStdOut], cStrErrorThenNotAfterIf, szSourceFile)
            jmp .exit
.endif_3:


        ; todo - construct condition
        ; todo - revisit temporary decrement
        dec qword [dwIfKeywordCount] 

        sprintf(ptrBuffer64, cStrThenLabelFormat, [dwIfKeywordCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        inc qword [dwIfKeywordCount] 
        PushBlockToken(KeywordThen)

        PopCallerSavedRegs()
        NextToken()
    .endif_token_is_then_0:

    .if_token_is_end_0:
        cmp currentToken.Type, word KeywordEnd
        jne .endif_token_is_end_0
    .then_token_is_end_0:
        PushCallerSavedRegs()

        PeekBlockToken()
.if_4:
    cmp rax, KeywordThen
    je .endif_4
.then_4:

            printf([hStdOut], cStrErrorEndNotAfterThen, szSourceFile)
            jmp .exit
.endif_4:


        ; todo - revisit temporary decrement
        dec qword [dwIfKeywordCount] 

        sprintf(ptrBuffer64, cStrEndLabelFormat, [dwIfKeywordCount])
        WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)

        inc qword [dwIfKeywordCount] 
        QuickPopBlockToken() ; pop 'then'
        QuickPopBlockToken() ; pop 'if'

        PopCallerSavedRegs()
        NextToken()
    .endif_token_is_end_0:
        
    nextToken
.end_counter_less_than_token_count:

%undef currentToken.Type
%undef currentToken.Start
%undef currentToken.Length

    pop rbp

    printf([hStdOut], cStrDoneCompiling, szSourceFile)

    jmp .exit
    ; disable for the moment
    ; write global constants
    ; WriteFile([hndDestFile], endline, 2, dwBytesWritten, 0)
    ; WriteFile([hndDestFile], szSectionData, szSectionDataLength, dwBytesWritten, 0)
    ; ; strlen(szGlobalConstants)
    ; WriteFile([hndDestFile], szGlobalConstants, [qwGlobalConstantsLength], dwBytesWritten, 0)

.print_tokens:
    mov r15, 0
    mov r14, tokenList
.tloop:
    movzx rcx, word [r14 + Token.TokenType]
    mov rdx, ptrBuffer64
    mov r8, 16
    call itoagb
    WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)

    mov rcx, ptrBuffer64
    mov rdx, cStrPrintTokenFormat
    mov r8, [r14 + Token.TokenStart]
    mov r9, [r14 + Token.TokenLength]
.t:
    push r14
    mov r13, szSourceCode
    add r13, r8
    call sprintf
    push r9
    WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)
    pop r9
    WriteConsoleA([hStdOut], r13, r9, 0)
    WriteConsoleA([hStdOut], endline, 2, 0)
    pop r14

    ; print token type


    inc r15
    add r14, Token.size
    cmp r15d, [dwTokenCount]
    jl .tloop

.exit:
    ExitProcess(0)
section .data
    szFileOpenError db "Error opening file. Error code:"
    szFileOpenError.length equ $ - szFileOpenError
    szFileReadError db "Error reading file. Error code:"
    szFileReadError.length equ $ - szFileReadError
    szGenericError db "Generic error."
    szGenericError.length equ $ - szGenericError
    szStrataFileExtension db ".strata"
    szStrataFileExtension.length equ $ - szStrataFileExtension
    szAsmFileExtension db ".asm"
    szAsmFileExtension.length equ $ - szAsmFileExtension
    szTab db "    "
    szTab.length equ $ - szTab
    szAsmCmp db "cmp "
    szAsmCmp.length equ $ - szAsmCmp
    szAsmDataStringType db " db "
    szAsmDataStringType.length equ $ - szAsmDataStringType
    szAsmStringLiteralNullTerminator db ", 0"
    szAsmStringLiteralNullTerminator.length equ $ - szAsmStringLiteralNullTerminator
    szAsmDataStringLengthType db " equ $ - "
    szAsmDataStringLengthType.length equ $ - szAsmDataStringLengthType
    szAsmDataStringSuffix db ".length"
    szAsmDataStringSuffix.length equ $ - szAsmDataStringSuffix
    szAsmEqual db "jne "
    szAsmEqual.length equ $ - szAsmEqual
    szAsmNotEqual db "je "
    szAsmNotEqual.length equ $ - szAsmNotEqual
    szAsmLess db "jge "
    szAsmLess.length equ $ - szAsmLess
    szAsmLessOrEqual db "jg "
    szAsmLessOrEqual.length equ $ - szAsmLessOrEqual
    szAsmGreater db "jle "
    szAsmGreater.length equ $ - szAsmGreater
    szAsmGreaterOrEqual db "jl "
    szAsmGreaterOrEqual.length equ $ - szAsmGreaterOrEqual
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
    szEndLabelForJump db ".endif_"
    szEndLabelForJump.length equ $ - szEndLabelForJump
    szHorizontalLine db ";-----------------------------  refactored output -------------------------------"
    szHorizontalLine.length equ $ - szHorizontalLine
