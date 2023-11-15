bits 64
default rel

%include "inc/std.inc"

struc Person
    .name: resb 32
    .age: resq 1
    ; .email: resb 64
    .size equ $ - Person
endstruc

%define MAX_PEOPLE 3

section .bss
    hStdOut resq 1
    pPeople resb Person.size * MAX_PEOPLE

section .text
    global _start

_start:
    GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])
    
    printf([hStdOut], roStr_0)

    ; fill first record
    array_nth(Person, pPeople, 0, rbx)
    strcpy(rbx, roStr_1, 4)
    mov qword [rbx + Person.age], 42

    ; fill second record
    array_nth(Person, pPeople, 1, rbx)
    strcpy(rbx, roStr_2, 4)
    mov qword [rbx + Person.age], 43

    ; print all records
    array_nth(Person, pPeople, 0, rbx) ; rbx = &pPeople[0]
.while_0:
    cmp r15, MAX_PEOPLE
    jge .end_while_0
.do_while_0:
    printf([hStdOut], roStr_3, r15, rbx, qword [rbx + Person.age])
    array_next(Person, rbx)

    inc r15
    jmp .while_0
.end_while_0:

    ExitProcess(0)
section .rodata
    roStr_3 db "Record #%d, Name: %s, age: %d\n", 0
    roStr_2 db "Jane", 0
    roStr_1 db "John", 0
    roStr_0 db "Hello World!\n", 0
