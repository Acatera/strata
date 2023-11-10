%ifndef _STD_INC_
%define _STD_INC_

%define DEFAULT_BUFFER_SIZE 1024

section .bss
    _internal_printf_buffer resb DEFAULT_BUFFER_SIZE
    _internal_printf_output_buffer resb DEFAULT_BUFFER_SIZE
    itoh_buffer resb 32

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

%define WriteFile(hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped) _WriteFile_ hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped
%macro _WriteFile_ 5
    mov rcx, %1
    mov rdx, %2
    mov r8, %3
    mov r9, %4
    push %5
    sub rsp, 32
    call WriteFile
    add rsp, 32 + 8
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
;-------------------------------------------------------------------------------------------------------------
; sprintf - writes formatted data to a buffer
;-------------------------------------------------------------------------------------------------------------
sprintf:
    multipush rcx, rdx, r8, r9, r12, r13, r14, r15, rdi, rsi
    mov r13, rsp
    xor r14, r14 ; total length
    xor r12, r12 ; arg count
    mov rbx, '%'
    mov rdi, rcx
    mov rsi, rdx

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
    je .decimal_r8
    cmp r12, 1
    je .decimal_r9
    mov rcx, [r13+8]
    add r13, 8
    jmp .decimal_start

.decimal_r8:
    mov rcx, r8
    jmp .decimal_start

.decimal_r9:
    mov rcx, r9
    jmp .decimal_start

.decimal_start:
    mov rdx, _internal_printf_buffer
    call itoa
    mov rsi, _internal_printf_buffer
    cmp rax, DEFAULT_BUFFER_SIZE
    jg .done
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
    je .string_r8
    cmp r12, 1
    je .string_r9
    mov rsi, [r13+8]
    add r13, 8
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
    and r15, 0xFF
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
    mov byte [rdi], 0 ; NULL terminate buffer
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

