%ifndef _STD_INC_
%define _STD_INC_

%define DEFAULT_BUFFER_SIZE 1024

struc STARTUPINFOA 
    .cb               resd 1 ; x offset 0
    .padding1         resd 1
    .lpReserved       resq 1 ; xoffset 8
    .lpDesktop        resq 1 ; xoffset 16
    .lpTitle          resq 1 ; xoffset 24
    .dwX              resd 1 ; xoffset 32
    .dwY              resd 1 ; xoffset 36
    .dwXSize          resd 1 ; xoffset 40
    .dwYSize          resd 1 ; xoffset 44
    .dwXCountChars    resd 1 ; xoffset 48
    .dwYCountChars    resd 1 ; xoffset 52
    .dwFillAttribute  resd 1 ; xoffset 56
    .dwFlags          resd 1 ; xoffset 60
    .wShowWindow      resw 1 ; xoffset 64
    .cbReserved2      resw 1 ; xoffset 66
    .padding2         resd 1 ; offset 68
    .lpReserved2      resq 1 ; offset 72
    .hStdInput        resq 1 ; offset 80
    .hStdOutput       resq 1 ; offset 88
    .hStdError        resq 1 ; offset 96
    .size equ $ - STARTUPINFOA
endstruc
    
struc PROCESS_INFORMATION
    .hProcess    resq 1
    .hThread     resq 1
    .dwProcessId resd 1
    .dwThreadId  resd 1
endstruc

section .bss
    _internal_printf_std_out resq 1
    _internal_printf_buffer resb DEFAULT_BUFFER_SIZE
    _internal_printf_output_buffer resb DEFAULT_BUFFER_SIZE
    itoh_buffer resb 32
    sprintfBuffer resb 32
    printfBuffer resb 128
    escapeBuffer resb 128

section d.data    
    itoh_digits db "0123456789abcdef"

.initialize:
    mov r12, rdx
    mov rdi, itoh_buffer

section .text
    extern GetStdHandle                 ; Declare external function 'GetStdHandle'.
    extern WriteConsoleA                ; Declare external function 'WriteConsoleA'.
    extern ExitProcess                  ; Declare external function 'ExitProcess'.

%define STD_INPUT_HANDLE  -10
%define STD_OUTPUT_HANDLE -11
%define STD_ERROR_HANDLE  -12

%define GENERIC_READ     0x80000000
%define GENERIC_WRITE    0x40000000

%define FILE_ATTRIBUTE_NORMAL 0x00000080

%define CallInto(routine, dest) _assign_result routine, dest
%macro _assign_result 2
    %1
    mov %2, rax
%endmacro

%define setc(a, i, b) _array_ a, i, b
%macro _array_ 3
    mov rax, %1
    add rax, %2
    mov [rax], byte %3
%endmacro

%define NULL 0
%define TRUE 1
%define FALSE 0

; to be used with index as static int
%define array_nth(type, array, index, result) mov result, array + index * type %+.size

; to be used with index as register. 
%define array_ith(type, array, index, result) array_ith type, array, index, result
%macro array_ith 4
    mov rax, %3
    mov rdx, %1.size
    mul rdx
    mov %4, %2
    add %4, rax
%endmacro

; advance pointer by one element
%define array_next(type, result) add result, type%+.size

%define WriteFile(hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped) _WriteFile_ hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped
%define WriteFile(hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten) _WriteFile_ hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten, 0
%macro _WriteFile_ 5
    PushCallerSavedRegs()
    mov rcx, %1
    mov rdx, %2
    mov r8, %3
    mov r9, %4
    push %5
    sub rsp, 32
    call WriteFile
    add rsp, 32 + 8
    PopCallerSavedRegs()
%endmacro

%ifndef  _multipush_
    %define _multipush_ 1
    %macro  multipush 1-* 

    %rep  %0 
            push    %1 
    %rotate 1 
    %endrep 

    %endmacro
%endif

%ifndef  _multipop_
    %define _multipop_ 1
    %macro  multipop 1-* 

    %rep  %0 
    %rotate -1 
            pop    %1 
    %endrep 

    %endmacro
%endif

%define InitStandardOutput() GetStdHandle(STD_OUTPUT_HANDLE, [_internal_printf_std_out])

%define CallerSavedRegs rcx, rdx, r8, r9, r10, r11
%define CalleeSavedRegs rbx, rbp, rdi, rsi, rsp, r12, r13, r14, r15

%define PushCallerSavedRegs() multipush CallerSavedRegs
%define PopCallerSavedRegs() multipop CallerSavedRegs

%define PushCalleeSavedRegs() multipush CalleeSavedRegs
%define PopCalleeSavedRegs() multipop CalleeSavedRegs

;------------------------------------------------------------------------------------------------------------
; Copy `n` bytes from `src` to `dest`. 
;------------------------------------------------------------------------------------------------------------
; Returns `dest`.
;------------------------------------------------------------------------------------------------------------
; notes: 
;   - equivalent-ish to C void *memset(void *s, int c, size_t n)
;   - `dest` and `src` must not overlap.
;   - `dest` and `src` must be at least `n` bytes long.
;------------------------------------------------------------------------------------------------------------
%define memcpy(dest, src, num) _memcpy_ dest, src, num
%macro _memcpy_ 3
    mov rax, %1 ; return `dest`
    mov rcx, %3 ; `num` bytes
    mov rdi, %1 ; `dest`
    mov rsi, %2 ; `src`
    rep movsb   ; `rep` = repeat while `rcx` != 0; `movsb` = move byte from `rsi` to `rdi`
%endmacro

%define strcpy(dest, src, num) _strcpy dest, src, num    
%macro _strcpy 3
    PushCallerSavedRegs()
    mov rcx, %1
    mov rdx, %2
    mov r8, %3
    call strcpy
    PopCallerSavedRegs()
%endmacro
strcpy:
    multipush rcx, rdx, rdi, rsi, r8
    mov rdi, rcx ; dest
    mov rsi, rdx ; src
    mov rcx, r8 ; num bytes
    rep movsb   ; rep
    mov byte [rdi], 0
.end:
    multipop rcx, rdx, rdi, rsi, r8
    ret

;------------------------------------------------------------------------------------------------------------
; Set `n` bytes of `s` to `c`.
;------------------------------------------------------------------------------------------------------------
; Returns `s`.
;------------------------------------------------------------------------------------------------------------
; notes:
;   - equivalent-ish to C void * memset(void * ptr, int value, size_t num);
;   - `s` must be at least `n` bytes long.
;------------------------------------------------------------------------------------------------------------
%define memset(ptr, value, num) _memset_ ptr, value, num
%macro _memset_ 3
    mov rax, %1 ; return ptr
    mov rcx, %3 ; `num` bytes
    mov rdi, %1 ; `ptr`
    mov al, %2  ; `value`
    rep stosb   ; `rep` = repeat while `rcx` != 0; `stosb` = store byte from `al` to `rdi`
%endmacro  

%define strcmp(s1, s2, count) _strcmp_ s1, s2, count
%macro _strcmp_ 3
    mov rdi, %1
    mov rsi, %2
    mov rcx, %3
    repe cmpsb
%endmacro

%define strcmp(s1, s2) strcmp s1, s2
%macro strcmp 2
    PushCallerSavedRegs()
    mov rcx, %1
    mov rdx, %2
    call _strcmp
    PopCallerSavedRegs()
%endmacro
_strcmp:
    PushCalleeSavedRegs()
    mov rdi, rcx
    mov rsi, rdx
    xor rax, rax
    xor rbx, rbx

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
    sub rax, rbx
    jmp .end

.str_eq:
    xor rax, rax

.end:
    PopCalleeSavedRegs()
    ret   
    
%define GetStdHandle(nStdHandle, outHANDLE) _GetStdHandle_ nStdHandle, outHANDLE
%macro _GetStdHandle_ 2
    ; Arguments: %1=handleType (rcx)
    
    sub rsp, 32  ; Allocate shadow space
    mov rcx, %1  ; Handle type
    call GetStdHandle
    add rsp, 32  ; Deallocate shadow space
    mov %2, rax  ; Store result
%endmacro

%define WriteConsoleA(a, b, c, d) _WriteConsoleA_ a, b, c, d
%macro _WriteConsoleA_ 4
    ; Arguments: %1=handle (RDI), %2=string (RSI), %3=length (RDX), %4=bytesWritten (RCX)
    
    sub rsp, 32  ; Allocate shadow space
    ; Set up parameters
    mov rcx, %1  ; Console handle
    mov rdx, %2  ; String pointer
    mov r8,  %3  ; String length
    mov r9,  %4  ; Pointer to bytesWritten

    call WriteConsoleA
    add rsp, 32  ; Deallocate shadow space
%endmacro

%define ExitProcess(exitCode) _ExitProcess_ exitCode
%macro _ExitProcess_ 1
    ; Arguments: %1=exitCode (RCX)
    
    sub rsp, 32  ; Allocate shadow space
    mov rcx, %1  ; Exit code
    call ExitProcess
    add rsp, 32  ; Deallocate shadow space
%endmacro

; TODO: Research how to add a variadic macro
printf:
    multipush rcx, rdx, r8, r9, r12, r13, r14, r15, rdi, rsi
    mov r13, rsp
    xor r14, r14 ; total length
    xor r12, r12 ; arg count
    mov rbx, '%'
    mov rdi, _internal_printf_output_buffer
    mov rsi, rcx

.loop:    
    cmp byte [rsi], 0
    je .done
    cmp bl, [rsi]
    jne .write_char
    je .format
    
.write_char:
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rdi
    inc rsi
    inc r14
    jmp .loop

.format:    
    inc rsi
    cmp byte [rsi], 'd'
    je .decimal
    cmp byte [rsi], 's'
    je .string
    mov [rdi], byte '%'
    inc rdi
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rdi
    inc rsi
    jmp .loop

.decimal:
    push rsi
    cmp r12, 0
    je .decimal_rdx
    cmp r12, 1
    je .decimal_r8
    cmp r12, 2
    je .decimal_r9
    mov rcx, [r13+8]
    add r13, 8
    jmp .decimal_start

.decimal_rdx:
    mov rcx, rdx
    jmp .decimal_start

.decimal_r8:
    mov rcx, r8
    jmp .decimal_start

.decimal_r9:
    mov rcx, r9

.decimal_start:
    mov rdx, _internal_printf_buffer
    call itoa
    mov rsi, _internal_printf_buffer
    mov rcx, rax
    add r14, rax
    rep movsb
    pop rsi
    inc rsi
    inc r12
    jmp .loop

.string:
    push rsi
    cmp r12, 0
    je .string_rdx
    cmp r12, 1
    je .string_r8
    cmp r12, 2
    je .string_r9
    mov rsi, [r13+8]
    add r13, 8
    jmp .string_start

.string_rdx:
    mov rsi, rdx
    jmp .string_start

.string_r8:
    mov rsi, r8
    jmp .string_start

.string_r9:
    mov rsi, r9

.string_start:
    inc r12

.string_loop:
    cmp byte [rsi], 0
    je .string_done
    mov r15, [rsi]
    mov [rdi], r15
    inc rdi
    inc rsi
    inc r14
    jmp .string_loop

.string_done:
    pop rsi
    inc rsi
    jmp .loop    

.done:
    mov rax, r14
    multipop rcx, rdx, r8, r9, r12, r13, r14, r15, rdi, rsi
    ret

;------------------------------------------------------------------------------------------------------------
; itoa - converts a signed integer to a string in base 10
;------------------------------------------------------------------------------------------------------------
; arguments:
;   rcx - integer to convert
;   rdx - pointer to buffer to store string
;------------------------------------------------------------------------------------------------------------
; returns: 
;   rax - number of characters written to buffer
;------------------------------------------------------------------------------------------------------------
; notes:
;   - buffer must be large enough to store the string
;   - if buffer is NULL, returns 0
;------------------------------------------------------------------------------------------------------------
%define itoa(a, b) _itoa_ a, b
%macro _itoa_ 2
    ; Arguments: %1=integer (rcx), %2=buffer (rdx)
    mov rcx, %1  
    mov rdx, %2  
    call itoa
%endmacro
itoa: 
    multipush rbx, rcx, rdx, r10, r11, r12
    ; push rcx
    ; push rdx

    ; check if buffer is NULL
    cmp rdx, NULL
    jz .error

    cmp rcx, 0              ; check if number is zero
    jnz .prepare_count

.zero:
    mov byte [rdx], '0'     ; store '0' in buffer
    inc rdx                 ; point to last byte in buffer
    mov byte [rdx], NULL       ; and store NULL
    mov r11, 1
    jmp .end

.prepare_count:
    mov rax, rcx            ; move number to rax
    xor r11, r11            ; clear r11. r11 will be used to store number of characters
    xor r12, r12            ; clear r12. r12 will be used to store sign
    mov r10, 10             ; divisor    
    mov rbx, rdx            ; store buffer address in rbx
    cmp rax, 0
    jns .count_digits       ; if number is positive, count digits

.negative:    
    mov r11, 1              ; if number is negative, start count at 1
    mov r12, 1              ; and set r12 to 1
    inc rbx                 ; increment buffer pointer
    neg rcx                 ; negate number
    mov rax, rcx            ; move number to rax

.count_digits:
    xor rdx, rdx            ; clear rdx
    div r10                 ; divide number by 10. quotient is stored in rax, remainder in rdx
    inc r11                 ; increment r11
    inc rbx                 ; increment buffer pointer
    cmp rax, 0              ; check if quotient is zero
    jnz .count_digits       ; if not, repeat

    ; r11 now contains number of digits in number. rbx points to last byte in buffer. rcx contains absolute value of number
    mov byte [rbx], NULL    ; write NULL terminator
    dec rbx                 ; decrement buffer pointer
    mov rax, rcx            ; move number to rax

.write_digits:              
    ; we perform the zero check at the beninning of the loop, so we don't decrement rbx past the start of the buffer
    cmp rax, 0              ; check if quotient is zero
    jz .wrote_digits        ; if it is, we're done
    xor rdx, rdx            ; clear rdx
    div r10                 ; divide number by 10. quotient is stored in rax, remainder in rdx
    add dl, '0'             ; convert remainder to ASCII
    mov [rbx], dl           ; write digit to buffer
    dec rbx                 ; decrement buffer pointer
    jmp .write_digits       ; repeat

.wrote_digits:
    ; buffer now contains all digits. We'll check if number was negative and write '-' if it was
    cmp r12, 0
    jz .end                 ; if number was positive, we're done
    mov byte [rbx], '-'     ; write '-' to buffer
    jmp .end

.error:
    xor r11, r11            ; return 0

.end:
    mov rax, r11            ; move number of characters to rax
    multipop rbx, rcx, rdx, r10, r11, r12
    ret    

%define itoab(a, b) _itoab_ a, b, 2
%define itoao(a, b) _itoab_ a, b, 8
%define itoad(a, b) _itoab_ a, b, 10
%define itoah(a, b) _itoab_ a, b, 16
%macro _itoab_ 3
    ; Arguments: %1=integer (RCX), %2=buffer (RDX), %3=base (R8)
    mov rcx, %1  
    mov rdx, %2  
    mov r8,  %3
    call itoagb
%endmacro
itoagb:
    multipush rbx, rcx, rdx, r8, r9, r10, r12, rsi, rdi
.initialize:
    mov r12, rdx
    mov rdi, itoh_buffer
    mov rsi, itoh_digits
    mov r10, r8
    mov rax, rcx
    xor r9, r9 ; used to store digit count
.build_buffer:
    xor rdx, rdx
    div r10
    add rsi, rdx
    movzx rcx, byte [rsi]
    mov [rdi], cl
    sub rsi, rdx
    inc rdi
    inc r9
    cmp rax, 0
    jne .build_buffer

.prepare_reverse:
    ; reverse buffer
    mov rsi, rdi ; use rsi to store buffer pointer
    dec rsi
    mov rdi, r12 ; use rdi to store buffer pointer
    mov rax, r9  ; use rax to store digit count

.write_chars:
    movzx rbx, byte [rsi]
    mov [rdi], byte bl
    inc rdi
    dec rsi
    dec r9
    cmp r9, 0
    jne .write_chars

.add_null:
    mov byte [rdi], NULL

.done:
    multipop rbx, rcx, rdx, r8, r9, r10, r12, rsi, rdi
    ret    
;------------------------------------------------------------------------------------------------------------
; strlen - returns the length of a NULL terminated string. Does not include NULL terminator in length
;------------------------------------------------------------------------------------------------------------
; arguments:
;   rcx - pointer to a NULL terminated string
;------------------------------------------------------------------------------------------------------------
; returns: 
;   rax - length of string
;------------------------------------------------------------------------------------------------------------
; notes:
;   - if pointer to string is NULL, returns -1
;------------------------------------------------------------------------------------------------------------
%define strlen(a) _strlen_ a
%macro _strlen_ 1
    ; Arguments: %1=string (rcx)
    mov rcx, %1  
    call strlen
%endmacro
strlen:
    ; check if pointer to string is NULL
    cmp rcx, 0
    jz .error

.initialize:
    xor rax, rax            ; clear rax. rax will be used to store length

    ; use string instructions where possible
.count_loop:    
    cmp byte [rcx], 0       ; check if we've reached the end of the string
    jz .end                 ; if we have, we're done
    inc rcx                 ; increment string pointer
    inc rax                 ; increment length
    jmp .count_loop         ; repeat

.error:
    mov rax, -1             ; return -1 if pointer to string is NULL

.end:
    ret

%endif


;-------------------------------------------------------------------------------------------------------------
; sprintf - writes formatted data to a buffer
;-------------------------------------------------------------------------------------------------------------
%define sprintf(buf, fmt) _sprintf2_ buf, fmt
%macro _sprintf2_ 2
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    sub rsp, 0x20
    mov rdx, escapeBuffer
    mov rcx, %1
    call sprintf
    add rsp, 0x20
%endmacro

%define sprintf(buf, fmt, a) _sprintf3_ buf, fmt, a
%macro _sprintf3_ 3
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    sub rsp, 0x20
    mov r8,  %3
    mov rdx, escapeBuffer
    mov rcx, %1
    call sprintf
    add rsp, 0x20
%endmacro

%define sprintf(buf, fmt, a, b) _sprintf4_ buf, fmt, a, b
%macro _sprintf4_ 4
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    sub rsp, 0x20
    mov r9,  %4
    mov r8,  %3
    mov rdx, escapeBuffer
    mov rcx, %1
    call sprintf
    add rsp, 0x20
%endmacro

%define printf(fmt) printf2 [_internal_printf_std_out], fmt
%define printfh(hnd, fmt) printf2 hnd, fmt
%macro printf2 2
    multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    sub rsp, 0x20
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    mov rdx, escapeBuffer
    mov rcx, printfBuffer
    call sprintf
    add rsp, 0x20
    WriteConsoleA(%1, printfBuffer, rax, 0)
    multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
%endmacro

%define printf(fmt, a) printf3 [_internal_printf_std_out], fmt, a
%define printfh(hnd, fmt, a) printf3 hnd, fmt, a
%macro printf3 3
    multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    sub rsp, 0x20
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    mov r8,  %3
    mov rdx, escapeBuffer
    mov rcx, printfBuffer
    call sprintf
    add rsp, 0x20
    WriteConsoleA(%1, printfBuffer, rax, 0)
    multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
%endmacro

%define printf(fmt, a, b) printf4 [_internal_printf_std_out], fmt, a, b
%define printfh(hnd, fmt, a, b) printf4 hnd, fmt, a, b
%macro printf4 4
    PushCallerSavedRegs()
    sub rsp, 0x20
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    mov r9,  %4
    mov r8,  %3
    mov rdx, escapeBuffer
    mov rcx, printfBuffer
    call sprintf
    add rsp, 0x20
    WriteConsoleA(%1, printfBuffer, rax, 0)
    PopCallerSavedRegs()
%endmacro

%define printf(fmt, a, b, c) printf5 [_internal_printf_std_out], fmt, a, b, c
%define printfh(hnd, fmt, a, b, c) printf5 hnd, fmt, a, b, c
%macro printf5 5
    multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    mov rdx, %2
    mov rcx, escapeBuffer
    call escape
    sub rsp, 0x20
    mov rcx, %5
    push rcx
    mov r9,  %4
    mov r8,  %3
    mov rdx, escapeBuffer
    mov rcx, printfBuffer
    call sprintf
    add rsp, 0x20 + 8
    WriteConsoleA(%1, printfBuffer, rax, 0)
    multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
%endmacro


sprintf:
    ; set up stack frame
    push rbp
    mov rbp, rsp

    ; according to windows x64 calling convention
    ; rbx, rbp, rsi, rdi, r12, r13, r14, r15 are callee-saved
    ; rcx, rdx, r8, r9, r10, r11 are volatile  
    multipush rbx, rsi, rdi, r12, r13, r14, r15

    ; save params on the stack, to ease the use of printf
    mov [rbp + 0x28], r9
    mov [rbp + 0x20], r8
    mov [rbp + 0x18], rdx
    mov [rbp + 0x10], rcx

    xor rax, rax    ; rax = return value
    xor r14, r14    ; r14 = param counter

    ; todo - strata-fy this
.if_buffer_is_null:
    cmp rcx, 0
    jne .endif_buffer_is_null
.then_buffer_is_null:
    mov rax, 0
    jmp .done 
.endif_buffer_is_null:

    mov rsi, rdx     ; rsi = format string, null terminated
    mov rdi, rcx     ; rdi = buffer

.while_format_not_null:
    cmp byte [rsi], 0
    je .end_format_not_null
    ; todo - should check for buffer overflow
    ; no idea how to do that yet
.do_format_not_null:
.if_char_is_not_percent:
    cmp byte [rsi], '%'
    je .endif_char_is_not_percent
.then_char_is_not_percent:
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rsi
    inc rdi
    inc rax
    ; continue
    jmp .while_format_not_null
.endif_char_is_not_percent:

    ; char is percent
    inc rsi
.if_percent_specifier:    
    cmp byte [rsi], '%'
    jne .endif_percent_specifier
.then_percent_specifier:
    mov byte [rdi], '%'
    inc rdi
    inc rsi          ; next char after '%%'
    inc rax
.endif_percent_specifier:

.if_decimal_specifier:    
    cmp byte [rsi], 'd'
    jne .endif_decimal_specifier
.then_decimal_specifier:
    multipush rsi, rax
    ; convert number to string
    itoa([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_decimal_specifier:

.if_unsigned_specifier:    
    cmp byte [rsi], 'u'
    jne .endif_unsigned_specifier
.then_unsigned_specifier:
    multipush rsi, rax
    ; convert number to string
    itoad([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_unsigned_specifier:

.if_hexadecimal_specifier:    
    cmp byte [rsi], 'x'
    jne .endif_hexadecimal_specifier
.then_hexadecimal_specifier:
    multipush rsi, rax

    ; convert number to string
    itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_hexadecimal_specifier:

.if_pointer_specifier:    
    cmp byte [rsi], 'p'
    jne .endif_pointer_specifier
.then_pointer_specifier:
    add rax, 2
    multipush rsi, rax

    ; add '0x' to output
    mov byte [rdi], '0'
    mov byte [rdi + 1], 'x'
    add rdi, 2

    ; convert number to string
    itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
    mov rsi, sprintfBuffer
    mov rcx, rax     ; char count of number
    rep movsb        ; copy number to buffer
    mov rcx, rax     ; char count of number
    
    multipop rsi, rax

    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
    add rax, rcx     ; add char count of number to return value
.endif_pointer_specifier:

.if_string_specifier:
    cmp byte [rsi], 's'
    jne .endif_string_specifier
.then_string_specifier:
    push rsi

    ; get string pointer from stack
    mov rsi, [rbp + 0x20 + r14 * 8]

.while_string_not_null:
    cmp byte [rsi], 0
    je .end_string_not_null
.do_string_not_null:
    movzx r15, byte [rsi]
    mov [rdi], r15
    inc rsi
    inc rdi
    inc rax
    jmp .while_string_not_null
.end_string_not_null:    

    pop rsi
    inc rsi          ; next char after '%d'
    inc r14          ; increment param counter
.endif_string_specifier:
    jmp .while_format_not_null
.end_format_not_null:

    ; add null terminator
    mov byte [rdi], 0

.done:
    multipop rbx, rsi, rdi, r12, r13, r14, r15

    ; tear down stack frame
    pop rbp
    ret



%define escape(dest, src) _escape dest, src
%macro _escape 2
    mov rcx, %1
    mov rdx, %2
    call escape
%endmacro

escape:
    PushCalleeSavedRegs()

    mov rdi, rcx
    mov rsi, rdx
    xor rax, rax

.while:
    cmp byte [rsi], NULL
    je .end_while
.do:
    
.if_backslash:
    cmp byte [rsi], '\'
    jne .end_backslash
.then_backslash:
    cmp byte [rsi + 1], NULL
    je .end_while
    ; \r: Carriage return
    cmp byte [rsi + 1], 'r'
    jne .else_newline
    mov byte [rdi], 13
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_newline:
    ; \n: New line
    cmp byte [rsi + 1], 'n'
    jne .else_tab
    mov byte [rdi], 10
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_tab:
    ; \t: Horizontal tab
    cmp byte [rsi + 1], 't'
    jne .else_backspace
    mov byte [rdi], 9
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_backspace:
    ; \b: Backspace
    cmp byte [rsi + 1], 'b'
    jne .else_null_char
    mov byte [rdi], 8
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_null_char:
    ; \0: Null character (terminates a string)
    cmp byte [rsi + 1], '0'
    jne .else_backslash
    mov byte [rdi], 0
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_backslash:
    ; \\: Backslash (\)
    cmp byte [rsi + 1], '\'
    jne .else_double_quotes
    mov byte [rdi], '\'
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_double_quotes:
    ; \": Double quotation mark (")
    cmp byte [rsi + 1], '"'
    jne .else_dec_number
    mov byte [rdi], '"'
    add rsi, 2
    add rdi, 1
    inc rax
    jmp .while

.else_dec_number:
    ; \#xx - Decimal number
    cmp byte [rsi + 1], '#'
    jne .else_undefined_escape_sequence
    push rax
    movzx rax, byte [rsi + 2]
    sub rax, '0'
    mov rdx, 10
    mul rdx
    movzx rdx, byte [rsi + 3]
    sub rdx, '0'
    add rax, rdx
    mov [rdi], al
    pop rax
    add rsi, 4
    add rdi, 1
    inc rax
    jmp .while

.else_undefined_escape_sequence:

.end_backslash:    

.undefined_escape_sequence:

    movsb
    inc rax
    jmp .while
.end_while:    

    mov byte [rdi], NULL ; Null-terminate the string

.end:
    PopCalleeSavedRegs()
    ret    

;------------------------------------------------------------------------------------------------------------
; atoi - converts a string to an integer in base 10
;------------------------------------------------------------------------------------------------------------
; arguments:
;   rcx - pointer to a NULL terminated string
;------------------------------------------------------------------------------------------------------------
; returns: 
;   rax - integer value of string
;   rdx - success flag (1 if successful, 0 if not)
;------------------------------------------------------------------------------------------------------------
atoi:
    PushCalleeSavedRegs()
    ; check if pointer to string is NULL
    cmp rcx, NULL
    jz .error

.initialize:
    xor rax, rax            ; clear rax. rax will be used to store number
    mov rbx, rcx            ; store string address in rbx
    mov r9, 1               ; default `success` flag to 1
    mov r10, 10             ; multiplier

.check_sign:
    xor r12, r12            ; clear r12. r12 will be used to store sign
    cmp byte [rbx], '-'     ; check if first character is '-'
    jnz .convert            ; if not, start conversion
    mov r12, 1              ; if it is, set r12 to 1
    inc rbx                 ; increment string pointer past '-'

.convert:
    cmp byte [rbx], 0       ; check if we've reached the end of the string
    jz .set_sign            ; if we have, we're done
    movzx r11, byte [rbx]         ; move current character to r11
    sub r11, '0'            ; convert character to integer
    js .error               ; if character is not a digit, return 0
    cmp r11, 9              ; check if character is greater than 9
    ja .error               ; if it is, return 0
    mul r10                 ; multiply number by 10
    add rax, r11            ; add current digit to number
    inc rbx                 ; increment string pointer
    jmp .convert            ; repeat

.set_sign:
    cmp r12, 0              ; check if number is positive
    jz .end                 ; if it is, we're done
    neg rax                 ; if it isn't, negate number
    jmp .end                ; and we're done

.error:    
    xor rax, rax            ; return number 0
    xor r9, r9              ; set `success` flag 0

.end:
    mov rdx, r9             ; move `success` flag to rdx
    PopCalleeSavedRegs()
    ret    