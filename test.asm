bits 64
default rel

%include "inc/std.inc"

%define BUFFER_SIZE 1024*16

struc OP
    .opType:    resw 1
    .size equ $ - .opType
endstruc

section .bss
    hStdOut resq 0
    szSouceCode resb 1024*1024 ; 1MB
    hndSourceFile resq 1
    hndDestFile resq 1
    dwBytesRead resd 1
    dwBytesWritten resd 1
    ptrSmallBuffer resb 64
    t1 resb 32
    t1Length resq 1
    t2 resb 32
    t2Length resq 1
    op resb 16
    opLength resq 1
    firstArgStart resq 1
    szSourceFile resb 256
    szDestFile resb 256

section .data
    szStrataFileExtension db ".strata", 0
    szAsmFileExtension db ".asm", 0
    bIsIfCondition db 0
    dwIfKeywordCount dq 0
    chAsmStart equ 0x60
    szCmp db "cmp "
    szAsmEqual db "jne " ; yes, it's intentionally reversed
    szAsmNotEqual db "je " ; yes, it's intentionally reversed
    szKeywordIf db "if"
    szKeywordThen db "then"
    szKeywordEnd db "end"
    szKeywordGStr db "gstr"
    szKeywordEqual db "=="
    szKeywordNotEqual db "!="
    szIfLabel db 0xd, 0xa, ".if_"
    szIfLabelLength equ $ - szIfLabel
    szThenLabel db 0xd, 0xa, ".then_"
    szThenLabelLength equ $ - szThenLabel
    szEndLabel db 0xd, 0xa, ".endif_"
    szEndLabelLength equ $ - szEndLabel
    szEndLabelForJump db ".endif_"
    szEndLabelForJumpLength equ $ - szEndLabelForJump
    szGenericError db "Error", 0
    szFileOpenError db "Error opening file ", 0
    szFileOpenError.length equ $ - szFileOpenError
    szFileReadError db "Error reading file ", 0
    szFileReadError.length equ $ - szFileReadError
    argCount dq 0
    endline db 0xd, 0xa, 0

section .text
    global _start
    global t
    extern CreateFileA
    extern ReadFile
    extern WriteFile
    extern GetLastError
    extern GetCommandLineA

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
t:

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
    memcpy(r14, szStrataFileExtension, 7)

    mov r14, szDestFile
    add r14, r13
    memcpy(r14, szAsmFileExtension, 4)

    multipop rax, rcx, rdi, rsi
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])
    add r13, 7
    WriteConsoleA([hStdOut], szSourceFile, r13, 0)
    WriteConsoleA([hStdOut], endline, 2, 0)

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
    cmp rax, 0
    jge .file_opened
    WriteConsoleA([hStdOut], szFileOpenError, szFileOpenError.length, 0)
    call GetLastError
    mov rcx, rax
    mov rdx, ptrSmallBuffer
    call itoa
    WriteConsoleA([hStdOut], ptrSmallBuffer, rax, 0)
    ExitProcess(1)

.file_opened:    
    mov [hndSourceFile], rax

    ; Preparing the parameters for ReadFile
    mov rcx, [hndSourceFile]      ; Handle to the file (HANDLE)
    mov rdx, szSouceCode        ; Pointer to the buffer that receives the data read from the file (LPVOID)
    mov r8, dword BUFFER_SIZE   ; Number of bytes to be read from the file (DWORD)
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

.start_parsing_source_code:
    ; reset offset
    xor r8, r8          ; token start
    xor r9, r9          ; token length
    mov rdi, szSouceCode

.read_token_loop:
    mov rbx, 0xd    ; CR
    mov rax, ' '
    mov rcx, 0xa    ; LF
    mov rdx, 0x9    ; TAB
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
    je .consume_asm_code
    inc r9
    inc rdi
    jmp .read_token_loop

.source_code_end:
    cmp r9, 0
    je .exit

.token_found:
; is token length 0?
.if_0:
    cmp r9, 0
    jne .endif_0
.then_0:
    inc rdi
    inc r8
    jmp .read_token_loop
.endif_0:


.print_token:
    mov r10, szSouceCode
    add r10, r8

    ; this is temporary, we will write to file as we go

    ; check if token is 'if'
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordIf, 2)
    multipop rdi, rsi, rcx, r10
    jne .lexeme_not_if
.if:    
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szIfLabel, szIfLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrSmallBuffer
    call itoa
    mov rdx, ptrSmallBuffer
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
    WriteFile([hndDestFile], ptrSmallBuffer, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi
    inc qword [dwIfKeywordCount]

    add r8, r9
    inc r8
    xor r9, r9
    inc rdi

    cmp r8, [dwBytesRead]
    jge .exit

    mov [bIsIfCondition], byte 1

    jmp .read_token_loop

.lexeme_not_if:
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordThen, 4)
    multipop rdi, rsi, rcx, r10
    jne .lexeme_not_then

.then:    
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szThenLabel, szThenLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrSmallBuffer
    call itoa
    mov rdx, ptrSmallBuffer
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
    WriteFile([hndDestFile], ptrSmallBuffer, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi

    inc qword [dwIfKeywordCount] ; restore the counter

    add r8, r9
    inc r8
    xor r9, r9
    inc rdi

    cmp r8, [dwBytesRead]
    jge .exit

    jmp .read_token_loop    

.lexeme_not_then:
    multipush rdi, rsi, rcx, r10
    strcmp(r10, szKeywordEnd, 3)
    multipop rdi, rsi, rcx, r10
    jne .lexeme_not_end

.end:
    ; write label
    multipush r8, r9, rdi
    WriteFile([hndDestFile], szEndLabel, szEndLabelLength, dwBytesWritten, 0)
    multipop r8, r9, rdi
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, ptrSmallBuffer
    call itoa
    mov rdx, ptrSmallBuffer
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
    WriteFile([hndDestFile], ptrSmallBuffer, rax, dwBytesWritten, 0)
    multipop r8, r9, rdi

    inc qword [dwIfKeywordCount] ; restore the counter

    add r8, r9
    inc r8
    xor r9, r9
    inc rdi

    cmp r8, [dwBytesRead]
    jge .exit

    jmp .read_token_loop   

.lexeme_not_end:

; .if_keyword_gstr:
    ; multipush rdi, rsi, rcx, r10
    ; strcmp(r10, szKeywordGStr, 4)
    ; multipop rdi, rsi, rcx, r10
    ; jne .endif_keyword_gstr
; .then_keyword_gstr:
    ; multipush r8, r9, rdi
    ; WriteFile([hndDestFile], r10, r8, dwBytesWritten, 0)
    ; multipop r8, r9, rdi
; .endif_keyword_gstr:

    ; other lexemes. Only structures like (t1 <comparison> t2) are supported
    ; for now
    cmp [bIsIfCondition], byte 1
    je .write_if_condition_1
    cmp [bIsIfCondition], byte 2
    je .write_if_condition_2
    cmp [bIsIfCondition], byte 3
    je .write_if_condition_3
    jg .error

.write_if_condition_1:    
    ; set t1
    multipush rcx, rdx, r8, rdi, rsi
    memcpy(t1, r10, r9)
    mov [t1Length], r9
    multipop rcx, rdx, r8, rdi, rsi
    inc byte [bIsIfCondition]
    jmp .advance_token

.write_if_condition_2:
    ; set op
    multipush rcx, rdx, r8, rdi, rsi
    memcpy(op, r10, r9)
    mov [opLength], r9
    multipop rcx, rdx, r8, rdi, rsi
    inc byte [bIsIfCondition]
    jmp .advance_token

.write_if_condition_3:    
    ; set t2
    multipush rcx, rdx, r8, rdi, rsi
    memcpy(t2, r10, r9)
    mov [t2Length], r9
    multipop rcx, rdx, r8, rdi, rsi

    ; write t1 <comparison> t2
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrSmallBuffer
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szCmp, 4)
    add r8, 4 ; r8 stores counter
    add r11, 4
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
    WriteFile([hndDestFile], ptrSmallBuffer, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11

    mov [bIsIfCondition], byte 0

    ; write jump
    multipush rdi, rsi, rcx, r10
    strcmp(op, szKeywordEqual, 2)
    multipop rdi, rsi, rcx, r10
    jne .op_not_equal

.equal:
    ; when equal, we need to jump if not equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrSmallBuffer
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmEqual, 4)
    add r8, 4 
    add r11, 4
    memcpy(r11, szEndLabelForJump, szEndLabelForJumpLength)
    add r8, szEndLabelForJumpLength
    add r11, szEndLabelForJumpLength
    multipush rax, rcx, rdx
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    inc qword [dwIfKeywordCount] ; restore the counter

    WriteFile([hndDestFile], ptrSmallBuffer, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11

.op_not_equal:    
    multipush rdi, rsi, rcx, r10
    strcmp(op, szKeywordNotEqual, 2)
    multipop rdi, rsi, rcx, r10
    jne .op_not_nequal
.nequal:
    ; when not equal, we need to jump if equal
    multipush rcx, rdx, r8, r9, rdi, rsi, r11
    mov r11, ptrSmallBuffer
    memset(r11, ' ', 4)
    add r11, 4
    mov r8, 4
    memcpy(r11, szAsmNotEqual, 3)
    add r8, 3 
    add r11, 3
    memcpy(r11, szEndLabelForJump, szEndLabelForJumpLength)
    add r8, szEndLabelForJumpLength
    add r11, szEndLabelForJumpLength
    multipush rax, rcx, rdx
    dec qword [dwIfKeywordCount] ; temporarly decrement the counter

    mov rcx, [dwIfKeywordCount]
    mov rdx, r11
    call itoa
    add r11, rax
    add r8, rax
    multipop rax, rcx, rdx

    inc qword [dwIfKeywordCount] ; restore the counter

    WriteFile([hndDestFile], ptrSmallBuffer, r8, dwBytesWritten, 0)
    multipop rcx, rdx, r8, r9, rdi, rsi, r11

.op_not_nequal:    
; .t:

    ; multipush r8, r9, rdi
    ; WriteFile([hndDestFile], r10, r9, dwBytesWritten, 0)
    ; multipop r8, r9, rdi
    ; end of temporary

.advance_token:
    ; advance token start and reset token length
    add r8, r9
    inc r8
    xor r9, r9
    inc rdi

    cmp r8, [dwBytesRead]
    jge .exit

    jmp .read_token_loop

.consume_asm_code:
    ; iterate until we find another '0x40'
    inc rdi
    push rdi
    xor r14, r14 ; store length of asm code

.consume_asm_code_loop:
    cmp byte [rdi], chAsmStart
    je .consume_asm_code_end
    inc r14
    inc rdi
    jmp .consume_asm_code_loop

.consume_asm_code_end:
    inc rdi ; move offset past trailing '0x40'
    pop r10
    add r8, r14
    add r8, 2 
    multipush r8, r9, rdi

    WriteFile([hndDestFile], r10, r14, dwBytesWritten, 0)

    ; WriteConsoleA([hStdOut], r10, r14, 0)

    multipop r8, r9, rdi

    jmp .read_token_loop
.error:
    WriteConsoleA([hStdOut], szGenericError, 5, 0)
    
.exit:
    ExitProcess(0)