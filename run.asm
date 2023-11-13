bits 64
default rel

%include "inc/std.inc"

section .bss
    hStdOut resq 1
   
section .bss
    lpProcessInformation resb 24
    lpStartupInfo resb 104

section .data
    string0           db "Starting process...", 0xd, 0xa, 0
    string1           db "Application name: '%s'", 0xd, 0xa, 0
    string2           db "Command line: '%s'", 0xd, 0xa, 0
    string3           db "Done", 0xd, 0xa, 0
    lpApplicationName db "calc.exe", 0
    lpCommandLine     db "-f win64 -g gstr.asm -o gstr.o -w+all -w+error", 0
    pStartupInfo      db 104 dup 0

section .text
    global _start
    extern CreateProcessA

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])

    printf([hStdOut], string0)
    printf([hStdOut], string1, lpApplicationName)
    printf([hStdOut], string2, lpCommandLine)

    ; CreateProcessA(lpApplicationName, lpCommandLine, lpProcessAttributes,
    ;     lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment,
    ;     lpCurrentDirectory, lpStartupInfo, lpProcessInformation
    ; )
    memset(lpProcessInformation, 0, 24)
    memset(lpStartupInfo, 0, 104)

    mov rax, lpProcessInformation
    mov rbx, lpStartupInfo
    mov [rbx], dword 104

t:
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
    mov rdx, lpApplicationName                       ; lpCommandLine
    mov rcx, NULL
    call CreateProcessA
    add rsp, 0x20 + 7 * 0x8

    
    printf([hStdOut], string3)

    ExitProcess(0)