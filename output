     1                                  bits 64
     2                                  default rel
     3                                  
     4                                  %include "inc/std.inc"
     1                              <1> %ifndef _STD_INC_
     2                              <1> %define _STD_INC_
     3                              <1> 
     4                              <1> %define DEFAULT_BUFFER_SIZE 1024
     5                              <1> 
     6                              <1> section .bss
     7 00000000 <res 400h>          <1>     _internal_printf_buffer resb DEFAULT_BUFFER_SIZE
     8 00000400 <res 400h>          <1>     _internal_printf_output_buffer resb DEFAULT_BUFFER_SIZE
     9 00000800 <res 20h>           <1>     itoh_buffer resb 32
    10 00000820 <res 20h>           <1>     sprintfBuffer resb 32
    11 00000840 <res 80h>           <1>     printfBuffer resb 128
    12                              <1> 
    13                              <1> section d.data    
    14 00000000 303132333435363738- <1>     itoh_digits db "0123456789abcdef"
    14 00000009 39616263646566      <1>
    15                              <1> 
    16                              <1> .initialize:
    17 00000010 4989D4              <1>     mov r12, rdx
    18 00000013 48BF-               <1>     mov rdi, itoh_buffer
    18 00000015 [0008000000000000]  <1>
    19                              <1> 
    20                              <1> section .text
    21                              <1>     extern GetStdHandle                 ; Declare external function 'GetStdHandle'.
    22                              <1>     extern WriteConsoleA                ; Declare external function 'WriteConsoleA'.
    23                              <1>     extern ExitProcess                  ; Declare external function 'ExitProcess'.
    24                              <1> 
    25                              <1> %define STD_INPUT_HANDLE  -10
    26                              <1> %define STD_OUTPUT_HANDLE -11
    27                              <1> %define STD_ERROR_HANDLE  -12
    28                              <1> 
    29                              <1> %define GENERIC_READ     0x80000000
    30                              <1> %define GENERIC_WRITE    0x40000000
    31                              <1> 
    32                              <1> %define FILE_ATTRIBUTE_NORMAL 0x00000080
    33                              <1> 
    34                              <1> %define CallInto(routine, dest) _assign_result routine, dest
    35                              <1> %macro _assign_result 2
    36                              <1>     %1
    37                              <1>     mov %2, rax
    38                              <1> %endmacro
    39                              <1> 
    40                              <1> %define setc(a, i, b) _array_ a, i, b
    41                              <1> %macro _array_ 3
    42                              <1>     mov rax, %1
    43                              <1>     add rax, %2
    44                              <1>     mov [rax], byte %3
    45                              <1> %endmacro
    46                              <1> 
    47                              <1> %define NULL 0
    48                              <1> %define TRUE 1
    49                              <1> %define FALSE 0
    50                              <1> 
    51                              <1> %define VT_91 0x1b, "[91m"
    52                              <1> %define VT_END 0x1b, "[0m"
    53                              <1> 
    54                              <1> %define WriteFile(hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped) _WriteFile_ hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten,lpOverlapped
    55                              <1> %define WriteFile(hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten) _WriteFile_ hFile,lpBuffer,nNumberOfBytesToWrite,lpNumberOfBytesWritten, 0
    56                              <1> %macro _WriteFile_ 5
    57                              <1>     mov rcx, %1
    58                              <1>     mov rdx, %2
    59                              <1>     mov r8, %3
    60                              <1>     mov r9, %4
    61                              <1>     push %5
    62                              <1>     sub rsp, 32
    63                              <1>     call WriteFile
    64                              <1>     add rsp, 32 + 8
    65                              <1> %endmacro
    66                              <1> 
    67                              <1> %ifndef  _multipush_
    68                              <1>     %define _multipush_ 1
    69                              <1>     %macro  multipush 1-* 
    70                              <1> 
    71                              <1>     %rep  %0 
    72                              <1>             push    %1 
    73                              <1>     %rotate 1 
    74                              <1>     %endrep 
    75                              <1> 
    76                              <1>     %endmacro
    77                              <1> %endif
    78                              <1> 
    79                              <1> %ifndef  _multipop_
    80                              <1>     %define _multipop_ 1
    81                              <1>     %macro  multipop 1-* 
    82                              <1> 
    83                              <1>     %rep  %0 
    84                              <1>     %rotate -1 
    85                              <1>             pop    %1 
    86                              <1>     %endrep 
    87                              <1> 
    88                              <1>     %endmacro
    89                              <1> %endif
    90                              <1> 
    91                              <1> %define CallerSavedRegs rcx, rdx, r8, r9, r10, r11
    92                              <1> %define CalleeSavedRegs rbx, rbp, rdi, rsi, rsp, r12, r13, r14, r15
    93                              <1> 
    94                              <1> %define PushCallerSavedRegs() multipush CallerSavedRegs
    95                              <1> %define PopCallerSavedRegs() multipop CallerSavedRegs
    96                              <1> 
    97                              <1> %define PushCalleeSavedRegs() multipush CalleeSavedRegs
    98                              <1> %define PopCalleeSavedRegs() multipop CalleeSavedRegs
    99                              <1> 
   100                              <1> ;------------------------------------------------------------------------------------------------------------
   101                              <1> ; Copy `n` bytes from `src` to `dest`. 
   102                              <1> ;------------------------------------------------------------------------------------------------------------
   103                              <1> ; Returns `dest`.
   104                              <1> ;------------------------------------------------------------------------------------------------------------
   105                              <1> ; notes: 
   106                              <1> ;   - equivalent-ish to C void *memset(void *s, int c, size_t n)
   107                              <1> ;   - `dest` and `src` must not overlap.
   108                              <1> ;   - `dest` and `src` must be at least `n` bytes long.
   109                              <1> ;------------------------------------------------------------------------------------------------------------
   110                              <1> %define memcpy(dest, src, num) _memcpy_ dest, src, num
   111                              <1> %macro _memcpy_ 3
   112                              <1>     mov rax, %1 ; return `dest`
   113                              <1>     mov rcx, %3 ; `num` bytes
   114                              <1>     mov rdi, %1 ; `dest`
   115                              <1>     mov rsi, %2 ; `src`
   116                              <1>     rep movsb   ; `rep` = repeat while `rcx` != 0; `movsb` = move byte from `rsi` to `rdi`
   117                              <1> %endmacro
   118                              <1> 
   119                              <1> ;------------------------------------------------------------------------------------------------------------
   120                              <1> ; Set `n` bytes of `s` to `c`.
   121                              <1> ;------------------------------------------------------------------------------------------------------------
   122                              <1> ; Returns `s`.
   123                              <1> ;------------------------------------------------------------------------------------------------------------
   124                              <1> ; notes:
   125                              <1> ;   - equivalent-ish to C void * memset(void * ptr, int value, size_t num);
   126                              <1> ;   - `s` must be at least `n` bytes long.
   127                              <1> ;------------------------------------------------------------------------------------------------------------
   128                              <1> %define memset(ptr, value, num) _memset_ ptr, value, num
   129                              <1> %macro _memset_ 3
   130                              <1>     mov rax, %1 ; return ptr
   131                              <1>     mov rcx, %3 ; `num` bytes
   132                              <1>     mov rdi, %1 ; `ptr`
   133                              <1>     mov al, %2  ; `value`
   134                              <1>     rep stosb   ; `rep` = repeat while `rcx` != 0; `stosb` = store byte from `al` to `rdi`
   135                              <1> %endmacro  
   136                              <1> 
   137                              <1> %define strcmp(s1, s2, count) _strcmp_ s1, s2, count
   138                              <1> %macro _strcmp_ 3
   139                              <1>     mov rdi, %1
   140                              <1>     mov rsi, %2
   141                              <1>     mov rcx, %3
   142                              <1>     repe cmpsb
   143                              <1> %endmacro
   144                              <1> 
   145                              <1> %define strcmp(s1, s2) strcmp s1, s2
   146                              <1> %macro strcmp 2
   147                              <1>     PushCallerSavedRegs()
   148                              <1>     mov rcx, %1
   149                              <1>     mov rdx, %2
   150                              <1>     call _strcmp
   151                              <1>     PopCallerSavedRegs()
   152                              <1> %endmacro
   153                              <1> _strcmp:
   154                              <1>     PushCalleeSavedRegs()
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000000 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000001 55                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000002 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000003 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000004 54                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000005 4154                <3>  push %1
    73                              <3>  %rotate 1
    72 00000007 4155                <3>  push %1
    73                              <3>  %rotate 1
    72 00000009 4156                <3>  push %1
    73                              <3>  %rotate 1
    72 0000000B 4157                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   155 0000000D 4889CF              <1>     mov rdi, rcx
   156 00000010 4889D6              <1>     mov rsi, rdx
   157 00000013 4831C0              <1>     xor rax, rax
   158 00000016 4831DB              <1>     xor rbx, rbx
   159                              <1> 
   160                              <1> .loop:
   161 00000019 8A07                <1>     mov al, byte [rdi]
   162 0000001B 8A1E                <1>     mov bl, byte [rsi]
   163 0000001D 38D8                <1>     cmp al, bl
   164 0000001F 751E                <1>     jne .str_neq
   165 00000021 3C00                <1>     cmp al, 0
   166 00000023 740D                <1>     je .str1_null
   167 00000025 80FB00              <1>     cmp bl, 0
   168 00000028 740F                <1>     je .str2_null
   169 0000002A 48FFC7              <1>     inc rdi
   170 0000002D 48FFC6              <1>     inc rsi
   171 00000030 EBE7                <1>     jmp .loop
   172                              <1> 
   173                              <1> .str1_null:
   174 00000032 80FB00              <1>     cmp bl, 0
   175 00000035 740D                <1>     je .str_eq
   176 00000037 EB06                <1>     jmp .str_neq
   177                              <1> 
   178                              <1> .str2_null:
   179 00000039 3C00                <1>     cmp al, 0
   180 0000003B 7407                <1>     je .str_eq
   181 0000003D EB00                <1>     jmp .str_neq    
   182                              <1> 
   183                              <1> .str_neq:
   184 0000003F 4829D8              <1>     sub rax, rbx
   185 00000042 EB03                <1>     jmp .end
   186                              <1> 
   187                              <1> .str_eq:
   188 00000044 4831C0              <1>     xor rax, rax
   189                              <1> 
   190                              <1> .end:
   191                              <1>     PopCalleeSavedRegs()
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000047 415F                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000049 415E                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000004B 415D                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000004D 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000004F 5C                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000050 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000051 5F                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000052 5D                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000053 5B                  <3>  pop %1
    87                              <2> 
   192 00000054 C3                  <1>     ret   
   193                              <1>     
   194                              <1> %define GetStdHandle(nStdHandle, outHANDLE) _GetStdHandle_ nStdHandle, outHANDLE
   195                              <1> %macro _GetStdHandle_ 2
   196                              <1>     ; Arguments: %1=handleType (rcx)
   197                              <1>     
   198                              <1>     sub rsp, 32  ; Allocate shadow space
   199                              <1>     mov rcx, %1  ; Handle type
   200                              <1>     call GetStdHandle
   201                              <1>     add rsp, 32  ; Deallocate shadow space
   202                              <1>     mov %2, rax  ; Store result
   203                              <1> %endmacro
   204                              <1> 
   205                              <1> %define WriteConsoleA(a, b, c, d) _WriteConsoleA_ a, b, c, d
   206                              <1> %macro _WriteConsoleA_ 4
   207                              <1>     ; Arguments: %1=handle (RDI), %2=string (RSI), %3=length (RDX), %4=bytesWritten (RCX)
   208                              <1>     
   209                              <1>     sub rsp, 32  ; Allocate shadow space
   210                              <1>     ; Set up parameters
   211                              <1>     mov rcx, %1  ; Console handle
   212                              <1>     mov rdx, %2  ; String pointer
   213                              <1>     mov r8,  %3  ; String length
   214                              <1>     mov r9,  %4  ; Pointer to bytesWritten
   215                              <1> 
   216                              <1>     call WriteConsoleA
   217                              <1>     add rsp, 32  ; Deallocate shadow space
   218                              <1> %endmacro
   219                              <1> 
   220                              <1> %define ExitProcess(exitCode) _ExitProcess_ exitCode
   221                              <1> %macro _ExitProcess_ 1
   222                              <1>     ; Arguments: %1=exitCode (RCX)
   223                              <1>     
   224                              <1>     sub rsp, 32  ; Allocate shadow space
   225                              <1>     mov rcx, %1  ; Exit code
   226                              <1>     call ExitProcess
   227                              <1>     add rsp, 32  ; Deallocate shadow space
   228                              <1> %endmacro
   229                              <1> 
   230                              <1> ; TODO: Research how to add a variadic macro
   231                              <1> printf:
   232                              <1>     multipush rcx, rdx, r8, r9, r12, r13, r14, r15, rdi, rsi
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000055 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000056 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000057 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00000059 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 0000005B 4154                <3>  push %1
    73                              <3>  %rotate 1
    72 0000005D 4155                <3>  push %1
    73                              <3>  %rotate 1
    72 0000005F 4156                <3>  push %1
    73                              <3>  %rotate 1
    72 00000061 4157                <3>  push %1
    73                              <3>  %rotate 1
    72 00000063 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000064 56                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   233 00000065 4989E5              <1>     mov r13, rsp
   234 00000068 4D31F6              <1>     xor r14, r14 ; total length
   235 0000006B 4D31E4              <1>     xor r12, r12 ; arg count
   236 0000006E BB25000000          <1>     mov rbx, '%'
   237 00000073 48BF-               <1>     mov rdi, _internal_printf_output_buffer
   237 00000075 [0004000000000000]  <1>
   238 0000007D 4889CE              <1>     mov rsi, rcx
   239                              <1> 
   240                              <1> .loop:    
   241 00000080 803E00              <1>     cmp byte [rsi], 0
   242 00000083 0F84DD000000        <1>     je .done
   243 00000089 3A1E                <1>     cmp bl, [rsi]
   244 0000008B 7502                <1>     jne .write_char
   245 0000008D 7412                <1>     je .format
   246                              <1>     
   247                              <1> .write_char:
   248 0000008F 4C0FB63E            <1>     movzx r15, byte [rsi]
   249 00000093 4C893F              <1>     mov [rdi], r15
   250 00000096 48FFC7              <1>     inc rdi
   251 00000099 48FFC6              <1>     inc rsi
   252 0000009C 49FFC6              <1>     inc r14
   253 0000009F EBDF                <1>     jmp .loop
   254                              <1> 
   255                              <1> .format:    
   256 000000A1 48FFC6              <1>     inc rsi
   257 000000A4 803E64              <1>     cmp byte [rsi], 'd'
   258 000000A7 741A                <1>     je .decimal
   259 000000A9 803E73              <1>     cmp byte [rsi], 's'
   260 000000AC 746C                <1>     je .string
   261 000000AE C60725              <1>     mov [rdi], byte '%'
   262 000000B1 48FFC7              <1>     inc rdi
   263 000000B4 4C0FB63E            <1>     movzx r15, byte [rsi]
   264 000000B8 4C893F              <1>     mov [rdi], r15
   265 000000BB 48FFC7              <1>     inc rdi
   266 000000BE 48FFC6              <1>     inc rsi
   267 000000C1 EBBD                <1>     jmp .loop
   268                              <1> 
   269                              <1> .decimal:
   270 000000C3 56                  <1>     push rsi
   271 000000C4 4983FC00            <1>     cmp r12, 0
   272 000000C8 7416                <1>     je .decimal_rdx
   273 000000CA 4983FC01            <1>     cmp r12, 1
   274 000000CE 7415                <1>     je .decimal_r8
   275 000000D0 4983FC02            <1>     cmp r12, 2
   276 000000D4 7414                <1>     je .decimal_r9
   277 000000D6 498B4D08            <1>     mov rcx, [r13+8]
   278 000000DA 4983C508            <1>     add r13, 8
   279 000000DE EB0D                <1>     jmp .decimal_start
   280                              <1> 
   281                              <1> .decimal_rdx:
   282 000000E0 4889D1              <1>     mov rcx, rdx
   283 000000E3 EB08                <1>     jmp .decimal_start
   284                              <1> 
   285                              <1> .decimal_r8:
   286 000000E5 4C89C1              <1>     mov rcx, r8
   287 000000E8 EB03                <1>     jmp .decimal_start
   288                              <1> 
   289                              <1> .decimal_r9:
   290 000000EA 4C89C9              <1>     mov rcx, r9
   291                              <1> 
   292                              <1> .decimal_start:
   293 000000ED 48BA-               <1>     mov rdx, _internal_printf_buffer
   293 000000EF [0000000000000000]  <1>
   294 000000F7 E87E000000          <1>     call itoa
   295 000000FC 48BE-               <1>     mov rsi, _internal_printf_buffer
   295 000000FE [0000000000000000]  <1>
   296 00000106 4889C1              <1>     mov rcx, rax
   297 00000109 4901C6              <1>     add r14, rax
   298 0000010C F3A4                <1>     rep movsb
   299 0000010E 5E                  <1>     pop rsi
   300 0000010F 48FFC6              <1>     inc rsi
   301 00000112 49FFC4              <1>     inc r12
   302 00000115 E966FFFFFF          <1>     jmp .loop
   303                              <1> 
   304                              <1> .string:
   305 0000011A 56                  <1>     push rsi
   306 0000011B 4983FC00            <1>     cmp r12, 0
   307 0000011F 7416                <1>     je .string_rdx
   308 00000121 4983FC01            <1>     cmp r12, 1
   309 00000125 7415                <1>     je .string_r8
   310 00000127 4983FC02            <1>     cmp r12, 2
   311 0000012B 7414                <1>     je .string_r9
   312 0000012D 498B7508            <1>     mov rsi, [r13+8]
   313 00000131 4983C508            <1>     add r13, 8
   314 00000135 EB0D                <1>     jmp .string_start
   315                              <1> 
   316                              <1> .string_rdx:
   317 00000137 4889D6              <1>     mov rsi, rdx
   318 0000013A EB08                <1>     jmp .string_start
   319                              <1> 
   320                              <1> .string_r8:
   321 0000013C 4C89C6              <1>     mov rsi, r8
   322 0000013F EB03                <1>     jmp .string_start
   323                              <1> 
   324                              <1> .string_r9:
   325 00000141 4C89CE              <1>     mov rsi, r9
   326                              <1> 
   327                              <1> .string_start:
   328 00000144 49FFC4              <1>     inc r12
   329                              <1> 
   330                              <1> .string_loop:
   331 00000147 803E00              <1>     cmp byte [rsi], 0
   332 0000014A 7411                <1>     je .string_done
   333 0000014C 4C8B3E              <1>     mov r15, [rsi]
   334 0000014F 4C893F              <1>     mov [rdi], r15
   335 00000152 48FFC7              <1>     inc rdi
   336 00000155 48FFC6              <1>     inc rsi
   337 00000158 49FFC6              <1>     inc r14
   338 0000015B EBEA                <1>     jmp .string_loop
   339                              <1> 
   340                              <1> .string_done:
   341 0000015D 5E                  <1>     pop rsi
   342 0000015E 48FFC6              <1>     inc rsi
   343 00000161 E91AFFFFFF          <1>     jmp .loop    
   344                              <1> 
   345                              <1> .done:
   346 00000166 4C89F0              <1>     mov rax, r14
   347                              <1>     multipop rcx, rdx, r8, r9, r12, r13, r14, r15, rdi, rsi
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000169 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000016A 5F                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000016B 415F                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000016D 415E                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000016F 415D                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000171 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000173 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000175 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000177 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000178 59                  <3>  pop %1
    87                              <2> 
   348 00000179 C3                  <1>     ret
   349                              <1> 
   350                              <1> ;------------------------------------------------------------------------------------------------------------
   351                              <1> ; itoa - converts a signed integer to a string in base 10
   352                              <1> ;------------------------------------------------------------------------------------------------------------
   353                              <1> ; arguments:
   354                              <1> ;   rcx - integer to convert
   355                              <1> ;   rdx - pointer to buffer to store string
   356                              <1> ;------------------------------------------------------------------------------------------------------------
   357                              <1> ; returns: 
   358                              <1> ;   rax - number of characters written to buffer
   359                              <1> ;------------------------------------------------------------------------------------------------------------
   360                              <1> ; notes:
   361                              <1> ;   - buffer must be large enough to store the string
   362                              <1> ;   - if buffer is NULL, returns 0
   363                              <1> ;------------------------------------------------------------------------------------------------------------
   364                              <1> %define itoa(a, b) _itoa_ a, b
   365                              <1> %macro _itoa_ 2
   366                              <1>     ; Arguments: %1=integer (rcx), %2=buffer (rdx)
   367                              <1>     mov rcx, %1  
   368                              <1>     mov rdx, %2  
   369                              <1>     call itoa
   370                              <1> %endmacro
   371                              <1> itoa: 
   372                              <1>     multipush rbx, rcx, rdx, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 0000017A 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000017B 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000017C 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000017D 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 0000017F 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00000181 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   373                              <1>     ; push rcx
   374                              <1>     ; push rdx
   375                              <1> 
   376                              <1>     ; check if buffer is NULL
   377 00000183 4883FA00            <1>     cmp rdx, NULL
   378 00000187 0F8480000000        <1>     jz .error
   379                              <1> 
   380 0000018D 4883F900            <1>     cmp rcx, 0              ; check if number is zero
   381 00000191 7511                <1>     jnz .prepare_count
   382                              <1> 
   383                              <1> .zero:
   384 00000193 C60230              <1>     mov byte [rdx], '0'     ; store '0' in buffer
   385 00000196 48FFC2              <1>     inc rdx                 ; point to last byte in buffer
   386 00000199 C60200              <1>     mov byte [rdx], NULL       ; and store NULL
   387 0000019C 41BB01000000        <1>     mov r11, 1
   388 000001A2 EB6C                <1>     jmp .end
   389                              <1> 
   390                              <1> .prepare_count:
   391 000001A4 4889C8              <1>     mov rax, rcx            ; move number to rax
   392 000001A7 4D31DB              <1>     xor r11, r11            ; clear r11. r11 will be used to store number of characters
   393 000001AA 4D31E4              <1>     xor r12, r12            ; clear r12. r12 will be used to store sign
   394 000001AD 41BA0A000000        <1>     mov r10, 10             ; divisor    
   395 000001B3 4889D3              <1>     mov rbx, rdx            ; store buffer address in rbx
   396 000001B6 4883F800            <1>     cmp rax, 0
   397 000001BA 7915                <1>     jns .count_digits       ; if number is positive, count digits
   398                              <1> 
   399                              <1> .negative:    
   400 000001BC 41BB01000000        <1>     mov r11, 1              ; if number is negative, start count at 1
   401 000001C2 41BC01000000        <1>     mov r12, 1              ; and set r12 to 1
   402 000001C8 48FFC3              <1>     inc rbx                 ; increment buffer pointer
   403 000001CB 48F7D9              <1>     neg rcx                 ; negate number
   404 000001CE 4889C8              <1>     mov rax, rcx            ; move number to rax
   405                              <1> 
   406                              <1> .count_digits:
   407 000001D1 4831D2              <1>     xor rdx, rdx            ; clear rdx
   408 000001D4 49F7F2              <1>     div r10                 ; divide number by 10. quotient is stored in rax, remainder in rdx
   409 000001D7 49FFC3              <1>     inc r11                 ; increment r11
   410 000001DA 48FFC3              <1>     inc rbx                 ; increment buffer pointer
   411 000001DD 4883F800            <1>     cmp rax, 0              ; check if quotient is zero
   412 000001E1 75EE                <1>     jnz .count_digits       ; if not, repeat
   413                              <1> 
   414                              <1>     ; r11 now contains number of digits in number. rbx points to last byte in buffer. rcx contains absolute value of number
   415 000001E3 C60300              <1>     mov byte [rbx], NULL    ; write NULL terminator
   416 000001E6 48FFCB              <1>     dec rbx                 ; decrement buffer pointer
   417 000001E9 4889C8              <1>     mov rax, rcx            ; move number to rax
   418                              <1> 
   419                              <1> .write_digits:              
   420                              <1>     ; we perform the zero check at the beninning of the loop, so we don't decrement rbx past the start of the buffer
   421 000001EC 4883F800            <1>     cmp rax, 0              ; check if quotient is zero
   422 000001F0 7410                <1>     jz .wrote_digits        ; if it is, we're done
   423 000001F2 4831D2              <1>     xor rdx, rdx            ; clear rdx
   424 000001F5 49F7F2              <1>     div r10                 ; divide number by 10. quotient is stored in rax, remainder in rdx
   425 000001F8 80C230              <1>     add dl, '0'             ; convert remainder to ASCII
   426 000001FB 8813                <1>     mov [rbx], dl           ; write digit to buffer
   427 000001FD 48FFCB              <1>     dec rbx                 ; decrement buffer pointer
   428 00000200 EBEA                <1>     jmp .write_digits       ; repeat
   429                              <1> 
   430                              <1> .wrote_digits:
   431                              <1>     ; buffer now contains all digits. We'll check if number was negative and write '-' if it was
   432 00000202 4983FC00            <1>     cmp r12, 0
   433 00000206 7408                <1>     jz .end                 ; if number was positive, we're done
   434 00000208 C6032D              <1>     mov byte [rbx], '-'     ; write '-' to buffer
   435 0000020B EB03                <1>     jmp .end
   436                              <1> 
   437                              <1> .error:
   438 0000020D 4D31DB              <1>     xor r11, r11            ; return 0
   439                              <1> 
   440                              <1> .end:
   441 00000210 4C89D8              <1>     mov rax, r11            ; move number of characters to rax
   442                              <1>     multipop rbx, rcx, rdx, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000213 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000215 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000217 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000219 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000021A 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000021B 5B                  <3>  pop %1
    87                              <2> 
   443 0000021C C3                  <1>     ret    
   444                              <1> 
   445                              <1> %define itoab(a, b) _itoab_ a, b, 2
   446                              <1> %define itoao(a, b) _itoab_ a, b, 8
   447                              <1> %define itoad(a, b) _itoab_ a, b, 10
   448                              <1> %define itoah(a, b) _itoab_ a, b, 16
   449                              <1> %macro _itoab_ 3
   450                              <1>     ; Arguments: %1=integer (RCX), %2=buffer (RDX), %3=base (R8)
   451                              <1>     mov rcx, %1  
   452                              <1>     mov rdx, %2  
   453                              <1>     mov r8,  %3
   454                              <1>     call itoagb
   455                              <1> %endmacro
   456                              <1> itoagb:
   457                              <1>     multipush rbx, rcx, rdx, r8, r9, r10, r12, rsi, rdi
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 0000021D 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000021E 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000021F 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000220 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00000222 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00000224 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00000226 4154                <3>  push %1
    73                              <3>  %rotate 1
    72 00000228 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000229 57                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   458                              <1> .initialize:
   459 0000022A 4989D4              <1>     mov r12, rdx
   460 0000022D 48BF-               <1>     mov rdi, itoh_buffer
   460 0000022F [0008000000000000]  <1>
   461 00000237 48BE-               <1>     mov rsi, itoh_digits
   461 00000239 [0000000000000000]  <1>
   462 00000241 4D89C2              <1>     mov r10, r8
   463 00000244 4889C8              <1>     mov rax, rcx
   464 00000247 4D31C9              <1>     xor r9, r9 ; used to store digit count
   465                              <1> .build_buffer:
   466 0000024A 4831D2              <1>     xor rdx, rdx
   467 0000024D 49F7F2              <1>     div r10
   468 00000250 4801D6              <1>     add rsi, rdx
   469 00000253 480FB60E            <1>     movzx rcx, byte [rsi]
   470 00000257 880F                <1>     mov [rdi], cl
   471 00000259 4829D6              <1>     sub rsi, rdx
   472 0000025C 48FFC7              <1>     inc rdi
   473 0000025F 49FFC1              <1>     inc r9
   474 00000262 4883F800            <1>     cmp rax, 0
   475 00000266 75E2                <1>     jne .build_buffer
   476                              <1> 
   477                              <1> .prepare_reverse:
   478                              <1>     ; reverse buffer
   479 00000268 4889FE              <1>     mov rsi, rdi ; use rsi to store buffer pointer
   480 0000026B 48FFCE              <1>     dec rsi
   481 0000026E 4C89E7              <1>     mov rdi, r12 ; use rdi to store buffer pointer
   482 00000271 4C89C8              <1>     mov rax, r9  ; use rax to store digit count
   483                              <1> 
   484                              <1> .write_chars:
   485 00000274 480FB61E            <1>     movzx rbx, byte [rsi]
   486 00000278 881F                <1>     mov [rdi], byte bl
   487 0000027A 48FFC7              <1>     inc rdi
   488 0000027D 48FFCE              <1>     dec rsi
   489 00000280 49FFC9              <1>     dec r9
   490 00000283 4983F900            <1>     cmp r9, 0
   491 00000287 75EB                <1>     jne .write_chars
   492                              <1> 
   493                              <1> .add_null:
   494 00000289 C60700              <1>     mov byte [rdi], NULL
   495                              <1> 
   496                              <1> .done:
   497                              <1>     multipop rbx, rcx, rdx, r8, r9, r10, r12, rsi, rdi
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000028C 5F                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000028D 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000028E 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000290 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000292 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000294 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000296 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000297 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000298 5B                  <3>  pop %1
    87                              <2> 
   498 00000299 C3                  <1>     ret    
   499                              <1> ;------------------------------------------------------------------------------------------------------------
   500                              <1> ; strlen - returns the length of a NULL terminated string. Does not include NULL terminator in length
   501                              <1> ;------------------------------------------------------------------------------------------------------------
   502                              <1> ; arguments:
   503                              <1> ;   rcx - pointer to a NULL terminated string
   504                              <1> ;------------------------------------------------------------------------------------------------------------
   505                              <1> ; returns: 
   506                              <1> ;   rax - length of string
   507                              <1> ;------------------------------------------------------------------------------------------------------------
   508                              <1> ; notes:
   509                              <1> ;   - if pointer to string is NULL, returns -1
   510                              <1> ;------------------------------------------------------------------------------------------------------------
   511                              <1> %define strlen(a) _strlen_ a
   512                              <1> %macro _strlen_ 1
   513                              <1>     ; Arguments: %1=string (rcx)
   514                              <1>     mov rcx, %1  
   515                              <1>     call strlen
   516                              <1> %endmacro
   517                              <1> strlen:
   518                              <1>     ; check if pointer to string is NULL
   519 0000029A 4883F900            <1>     cmp rcx, 0
   520 0000029E 7410                <1>     jz .error
   521                              <1> 
   522                              <1> .initialize:
   523 000002A0 4831C0              <1>     xor rax, rax            ; clear rax. rax will be used to store length
   524                              <1> 
   525                              <1>     ; use string instructions where possible
   526                              <1> .count_loop:    
   527 000002A3 803900              <1>     cmp byte [rcx], 0       ; check if we've reached the end of the string
   528 000002A6 740F                <1>     jz .end                 ; if we have, we're done
   529 000002A8 48FFC1              <1>     inc rcx                 ; increment string pointer
   530 000002AB 48FFC0              <1>     inc rax                 ; increment length
   531 000002AE EBF3                <1>     jmp .count_loop         ; repeat
   532                              <1> 
   533                              <1> .error:
   534 000002B0 48C7C0FFFFFFFF      <1>     mov rax, -1             ; return -1 if pointer to string is NULL
   535                              <1> 
   536                              <1> .end:
   537 000002B7 C3                  <1>     ret
   538                              <1> 
   539                              <1> %endif
   540                              <1> 
   541                              <1> 
   542                              <1> ;-------------------------------------------------------------------------------------------------------------
   543                              <1> ; sprintf - writes formatted data to a buffer
   544                              <1> ;-------------------------------------------------------------------------------------------------------------
   545                              <1> %define sprintf(buf, fmt, a) _sprintf3_ buf, fmt, a
   546                              <1> %macro _sprintf3_ 3
   547                              <1>     sub rsp, 0x20
   548                              <1>     mov r8,  %3
   549                              <1>     mov rdx, %2
   550                              <1>     mov rcx, %1
   551                              <1>     call sprintf
   552                              <1>     add rsp, 0x20
   553                              <1> %endmacro
   554                              <1> 
   555                              <1> %define printf(hnd, fmt, a) printf3 hnd, fmt, a
   556                              <1> %macro printf3 3
   557                              <1>     multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
   558                              <1>     sub rsp, 0x20
   559                              <1>     mov r8,  %3
   560                              <1>     mov rdx, %2
   561                              <1>     mov rcx, printfBuffer
   562                              <1>     call sprintf
   563                              <1>     add rsp, 0x20
   564                              <1>     WriteConsoleA(%1, printfBuffer, rax, 0)
   565                              <1>     multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
   566                              <1> %endmacro
   567                              <1> 
   568                              <1> %define printf(hnd, fmt, a, b, c) printf5 hnd, fmt, a, b, c
   569                              <1> %macro printf5 5
   570                              <1>     multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
   571                              <1>     push %5
   572                              <1>     sub rsp, 0x20
   573                              <1>     mov r9,  %4
   574                              <1>     mov r8,  %3
   575                              <1>     mov rdx, %2
   576                              <1>     mov rcx, printfBuffer
   577                              <1>     call sprintf
   578                              <1>     add rsp, 0x20 + 8
   579                              <1>     WriteConsoleA(%1, printfBuffer, rax, 0)
   580                              <1>     multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
   581                              <1> %endmacro
   582                              <1> 
   583                              <1> 
   584                              <1> sprintf:
   585                              <1>     ; set up stack frame
   586 000002B8 55                  <1>     push rbp
   587 000002B9 4889E5              <1>     mov rbp, rsp
   588                              <1> 
   589                              <1>     ; according to windows x64 calling convention
   590                              <1>     ; rbx, rbp, rsi, rdi, r12, r13, r14, r15 are callee-saved
   591                              <1>     ; rcx, rdx, r8, r9, r10, r11 are volatile  
   592                              <1>     multipush rbx, rsi, rdi, r12, r13, r14, r15
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000002BC 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 000002BD 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000002BE 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000002BF 4154                <3>  push %1
    73                              <3>  %rotate 1
    72 000002C1 4155                <3>  push %1
    73                              <3>  %rotate 1
    72 000002C3 4156                <3>  push %1
    73                              <3>  %rotate 1
    72 000002C5 4157                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   593                              <1> 
   594                              <1>     ; save params on the stack, to ease the use of printf
   595 000002C7 4C894D28            <1>     mov [rbp + 0x28], r9
   596 000002CB 4C894520            <1>     mov [rbp + 0x20], r8
   597 000002CF 48895518            <1>     mov [rbp + 0x18], rdx
   598 000002D3 48894D10            <1>     mov [rbp + 0x10], rcx
   599                              <1> 
   600 000002D7 4831C0              <1>     xor rax, rax    ; rax = return value
   601 000002DA 4D31F6              <1>     xor r14, r14    ; r14 = param counter
   602                              <1> 
   603                              <1>     ; todo - strata-fy this
   604                              <1> .if_buffer_is_null:
   605 000002DD 4883F900            <1>     cmp rcx, 0
   606 000002E1 750A                <1>     jne .endif_buffer_is_null
   607                              <1> .then_buffer_is_null:
   608 000002E3 B800000000          <1>     mov rax, 0
   609 000002E8 E96C010000          <1>     jmp .done 
   610                              <1> .endif_buffer_is_null:
   611                              <1> 
   612 000002ED 4889D6              <1>     mov rsi, rdx     ; rsi = format string, null terminated
   613 000002F0 4889CF              <1>     mov rdi, rcx     ; rdi = buffer
   614                              <1> 
   615                              <1> .while_format_not_null:
   616 000002F3 803E00              <1>     cmp byte [rsi], 0
   617 000002F6 0F845A010000        <1>     je .end_format_not_null
   618                              <1>     ; todo - should check for buffer overflow
   619                              <1>     ; no idea how to do that yet
   620                              <1> .do_format_not_null:
   621                              <1> .if_char_is_not_percent:
   622 000002FC 803E25              <1>     cmp byte [rsi], '%'
   623 000002FF 7412                <1>     je .endif_char_is_not_percent
   624                              <1> .then_char_is_not_percent:
   625 00000301 4C0FB63E            <1>     movzx r15, byte [rsi]
   626 00000305 4C893F              <1>     mov [rdi], r15
   627 00000308 48FFC6              <1>     inc rsi
   628 0000030B 48FFC7              <1>     inc rdi
   629 0000030E 48FFC0              <1>     inc rax
   630                              <1>     ; continue
   631 00000311 EBE0                <1>     jmp .while_format_not_null
   632                              <1> .endif_char_is_not_percent:
   633                              <1> 
   634                              <1>     ; char is percent
   635 00000313 48FFC6              <1>     inc rsi
   636                              <1> .if_percent_specifier:    
   637 00000316 803E25              <1>     cmp byte [rsi], '%'
   638 00000319 750C                <1>     jne .endif_percent_specifier
   639                              <1> .then_percent_specifier:
   640 0000031B C60725              <1>     mov byte [rdi], '%'
   641 0000031E 48FFC7              <1>     inc rdi
   642 00000321 48FFC6              <1>     inc rsi          ; next char after '%%'
   643 00000324 48FFC0              <1>     inc rax
   644                              <1> .endif_percent_specifier:
   645                              <1> 
   646                              <1> .if_decimal_specifier:    
   647 00000327 803E64              <1>     cmp byte [rsi], 'd'
   648 0000032A 7533                <1>     jne .endif_decimal_specifier
   649                              <1> .then_decimal_specifier:
   650                              <1>     multipush rsi, rax
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 0000032C 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000032D 50                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   651                              <1>     ; convert number to string
   652                              <1>     itoa([rbp + 0x20 + r14 * 8], sprintfBuffer)
   366                              <2> 
   367 0000032E 4A8B4CF520          <2>  mov rcx, %1
   368 00000333 48BA-               <2>  mov rdx, %2
   368 00000335 [2008000000000000]  <2>
   369 0000033D E838FEFFFF          <2>  call itoa
   653 00000342 48BE-               <1>     mov rsi, sprintfBuffer
   653 00000344 [2008000000000000]  <1>
   654 0000034C 4889C1              <1>     mov rcx, rax     ; char count of number
   655 0000034F F3A4                <1>     rep movsb        ; copy number to buffer
   656 00000351 4889C1              <1>     mov rcx, rax     ; char count of number
   657                              <1>     
   658                              <1>     multipop rsi, rax
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000354 58                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000355 5E                  <3>  pop %1
    87                              <2> 
   659                              <1> 
   660 00000356 48FFC6              <1>     inc rsi          ; next char after '%d'
   661 00000359 49FFC6              <1>     inc r14          ; increment param counter
   662 0000035C 4801C8              <1>     add rax, rcx     ; add char count of number to return value
   663                              <1> .endif_decimal_specifier:
   664                              <1> 
   665                              <1> .if_unsigned_specifier:    
   666 0000035F 803E75              <1>     cmp byte [rsi], 'u'
   667 00000362 7539                <1>     jne .endif_unsigned_specifier
   668                              <1> .then_unsigned_specifier:
   669                              <1>     multipush rsi, rax
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000364 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000365 50                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   670                              <1>     ; convert number to string
   671                              <1>     itoad([rbp + 0x20 + r14 * 8], sprintfBuffer)
   450                              <2> 
   451 00000366 4A8B4CF520          <2>  mov rcx, %1
   452 0000036B 48BA-               <2>  mov rdx, %2
   452 0000036D [2008000000000000]  <2>
   453 00000375 41B80A000000        <2>  mov r8, %3
   454 0000037B E89DFEFFFF          <2>  call itoagb
   672 00000380 48BE-               <1>     mov rsi, sprintfBuffer
   672 00000382 [2008000000000000]  <1>
   673 0000038A 4889C1              <1>     mov rcx, rax     ; char count of number
   674 0000038D F3A4                <1>     rep movsb        ; copy number to buffer
   675 0000038F 4889C1              <1>     mov rcx, rax     ; char count of number
   676                              <1>     
   677                              <1>     multipop rsi, rax
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000392 58                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000393 5E                  <3>  pop %1
    87                              <2> 
   678                              <1> 
   679 00000394 48FFC6              <1>     inc rsi          ; next char after '%d'
   680 00000397 49FFC6              <1>     inc r14          ; increment param counter
   681 0000039A 4801C8              <1>     add rax, rcx     ; add char count of number to return value
   682                              <1> .endif_unsigned_specifier:
   683                              <1> 
   684                              <1> .if_hexadecimal_specifier:    
   685 0000039D 803E78              <1>     cmp byte [rsi], 'x'
   686 000003A0 7539                <1>     jne .endif_hexadecimal_specifier
   687                              <1> .then_hexadecimal_specifier:
   688                              <1>     multipush rsi, rax
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000003A2 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000003A3 50                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   689                              <1> 
   690                              <1>     ; convert number to string
   691                              <1>     itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
   450                              <2> 
   451 000003A4 4A8B4CF520          <2>  mov rcx, %1
   452 000003A9 48BA-               <2>  mov rdx, %2
   452 000003AB [2008000000000000]  <2>
   453 000003B3 41B810000000        <2>  mov r8, %3
   454 000003B9 E85FFEFFFF          <2>  call itoagb
   692 000003BE 48BE-               <1>     mov rsi, sprintfBuffer
   692 000003C0 [2008000000000000]  <1>
   693 000003C8 4889C1              <1>     mov rcx, rax     ; char count of number
   694 000003CB F3A4                <1>     rep movsb        ; copy number to buffer
   695 000003CD 4889C1              <1>     mov rcx, rax     ; char count of number
   696                              <1>     
   697                              <1>     multipop rsi, rax
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000003D0 58                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000003D1 5E                  <3>  pop %1
    87                              <2> 
   698                              <1> 
   699 000003D2 48FFC6              <1>     inc rsi          ; next char after '%d'
   700 000003D5 49FFC6              <1>     inc r14          ; increment param counter
   701 000003D8 4801C8              <1>     add rax, rcx     ; add char count of number to return value
   702                              <1> .endif_hexadecimal_specifier:
   703                              <1> 
   704                              <1> .if_pointer_specifier:    
   705 000003DB 803E70              <1>     cmp byte [rsi], 'p'
   706 000003DE 7548                <1>     jne .endif_pointer_specifier
   707                              <1> .then_pointer_specifier:
   708 000003E0 4883C002            <1>     add rax, 2
   709                              <1>     multipush rsi, rax
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000003E4 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000003E5 50                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   710                              <1> 
   711                              <1>     ; add '0x' to output
   712 000003E6 C60730              <1>     mov byte [rdi], '0'
   713 000003E9 C6470178            <1>     mov byte [rdi + 1], 'x'
   714 000003ED 4883C702            <1>     add rdi, 2
   715                              <1> 
   716                              <1>     ; convert number to string
   717                              <1>     itoah([rbp + 0x20 + r14 * 8], sprintfBuffer)
   450                              <2> 
   451 000003F1 4A8B4CF520          <2>  mov rcx, %1
   452 000003F6 48BA-               <2>  mov rdx, %2
   452 000003F8 [2008000000000000]  <2>
   453 00000400 41B810000000        <2>  mov r8, %3
   454 00000406 E812FEFFFF          <2>  call itoagb
   718 0000040B 48BE-               <1>     mov rsi, sprintfBuffer
   718 0000040D [2008000000000000]  <1>
   719 00000415 4889C1              <1>     mov rcx, rax     ; char count of number
   720 00000418 F3A4                <1>     rep movsb        ; copy number to buffer
   721 0000041A 4889C1              <1>     mov rcx, rax     ; char count of number
   722                              <1>     
   723                              <1>     multipop rsi, rax
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000041D 58                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000041E 5E                  <3>  pop %1
    87                              <2> 
   724                              <1> 
   725 0000041F 48FFC6              <1>     inc rsi          ; next char after '%d'
   726 00000422 49FFC6              <1>     inc r14          ; increment param counter
   727 00000425 4801C8              <1>     add rax, rcx     ; add char count of number to return value
   728                              <1> .endif_pointer_specifier:
   729                              <1> 
   730                              <1> .if_string_specifier:
   731 00000428 803E73              <1>     cmp byte [rsi], 's'
   732 0000042B 7524                <1>     jne .endif_string_specifier
   733                              <1> .then_string_specifier:
   734 0000042D 56                  <1>     push rsi
   735                              <1> 
   736                              <1>     ; get string pointer from stack
   737 0000042E 4A8B74F520          <1>     mov rsi, [rbp + 0x20 + r14 * 8]
   738                              <1> 
   739                              <1> .while_string_not_null:
   740 00000433 803E00              <1>     cmp byte [rsi], 0
   741 00000436 7412                <1>     je .end_string_not_null
   742                              <1> .do_string_not_null:
   743 00000438 4C0FB63E            <1>     movzx r15, byte [rsi]
   744 0000043C 4C893F              <1>     mov [rdi], r15
   745 0000043F 48FFC6              <1>     inc rsi
   746 00000442 48FFC7              <1>     inc rdi
   747 00000445 48FFC0              <1>     inc rax
   748 00000448 EBE9                <1>     jmp .while_string_not_null
   749                              <1> .end_string_not_null:    
   750                              <1> 
   751 0000044A 5E                  <1>     pop rsi
   752 0000044B 48FFC6              <1>     inc rsi          ; next char after '%d'
   753 0000044E 49FFC6              <1>     inc r14          ; increment param counter
   754                              <1> .endif_string_specifier:
   755 00000451 E99DFEFFFF          <1>     jmp .while_format_not_null
   756                              <1> .end_format_not_null:
   757                              <1> 
   758                              <1>     ; add null terminator
   759 00000456 C60700              <1>     mov byte [rdi], 0
   760                              <1> 
   761                              <1> .done:
   762                              <1>     multipop rbx, rsi, rdi, r12, r13, r14, r15
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000459 415F                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000045B 415E                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000045D 415D                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000045F 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000461 5F                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000462 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000463 5B                  <3>  pop %1
    87                              <2> 
   763                              <1> 
   764                              <1>     ; tear down stack frame
   765 00000464 5D                  <1>     pop rbp
   766 00000465 C3                  <1>     ret
     5                                  
     6                                  %define SOURCE_CODE_SIZE 1024*1024
     7                                  %define SMALL_BUFFER_SIZE 64
     8                                  %define OPERATOR_BUFFER_SIZE 16
     9                                  
    10                                  %macro _reset_counters_ 0
    11                                      ; r8 - offset in source code, token start
    12                                      ; r9 - token length
    13                                      ; rdi - source code pointer
    14                                      add r8, r9
    15                                      inc r8
    16                                      inc rdi
    17                                      xor r9, r9
    18                                  
    19                                      cmp r8, [dwBytesRead]
    20                                      jge .source_code_parsed
    21                                  
    22                                      jmp .read_token_loop
    23                                  %endmacro
    24                                  
    25                                  %define CompareOperatorWith(candidate) _CompareOperatorWith_ candidate
    26                                  %macro _CompareOperatorWith_ 1
    27                                      multipush rdi, rsi, rcx, r10
    28                                      strcmp(op, %1, %1.length)
    29                                      multipop rdi, rsi, rcx, r10
    30                                  %endmacro
    31                                  
    32                                  %define CompareTokenWith(c) _CompareTokenWith_ c
    33                                  %macro _CompareTokenWith_ 1
    34                                      multipush rdi, rsi, rcx, r10
    35                                      strcmp(r10, %1, %1.length)
    36                                      multipop rdi, rsi, rcx, r10
    37                                  %endmacro
    38                                  
    39                                  %define OperatorEquals         1
    40                                  %define OperatorNotEquals      2
    41                                  %define OperatorLess           3
    42                                  %define OperatorLessOrEqual    4
    43                                  %define OperatorGreater        5
    44                                  %define OperatorGreaterOrEqual 6
    45                                  %define OperatorAssignment     7
    46                                  
    47                                  ; Reserve 4 bits for operator type
    48                                  %define OperandStringLiteral 0 + (1 << 4)
    49                                  %define OperandAsmLiteral    1 + (1 << 4)
    50                                  %define OperandLiteral       2 + (1 << 4)
    51                                  
    52                                  ; Reserve 4 bits for operand type
    53                                  %define KeywordIf   0 + (1 << (4 + 4))
    54                                  %define KeywordThen 1 + (1 << (4 + 4))
    55                                  %define KeywordEnd  2 + (1 << (4 + 4))
    56                                  %define KeywordGStr 3 + (1 << (4 + 4))
    57                                  
    58                                  
    59                                  ; todo - revisit this
    60                                  %define defOperatorEquals word OperatorEquals
    61                                  %define defOperatorNotEquals word OperatorNotEquals
    62                                  %define defOperatorLess word OperatorLess
    63                                  %define defOperatorLessOrEqual word OperatorLessOrEqual
    64                                  %define defOperatorGreater word OperatorGreater
    65                                  %define defOperatorGreaterOrEqual word OperatorGreaterOrEqual
    66                                  %define defOperatorAssignment word OperatorAssignment
    67                                  
    68                                  %define defOperandStringLiteral word OperandStringLiteral
    69                                  %define defOperandAsmLiteral word OperandAsmLiteral
    70                                  %define defOperandLiteral word OperandLiteral
    71                                  
    72                                  %define defKeywordIf word KeywordIf
    73                                  %define defKeywordThen word KeywordThen
    74                                  %define defKeywordEnd word KeywordEnd
    75                                  %define defKeywordGStr word KeywordGStr
    76                                  
    77                                  %define TOKEN_TYPE_SIZE 2
    78                                  
    79                                  struc Token
    80 00000000 ????                        .TokenType:    resw 1 ; if you change this, also update TOKEN_TYPE_SIZE
    81 00000002 ????????????????            .TokenStart:   resq 1
    82 0000000A ????????????????            .TokenLength:  resq 1
    83                                      .size equ $ - .TokenType
    84                                  endstruc
    85                                  
    86                                  struc Block
    87 00000000 ????????                    .TokenIndex   resd 1
    88 00000004 ????                        .BlockId   resw 1
    89 00000006 ????                        .TokenType resw 1
    90                                      .size equ $ - .TokenIndex
    91                                  endstruc
    92                                  
    93                                  %define MAX_TOKEN_COUNT 1024
    94                                  
    95                                  %define BLOCK_ITEM_SIZE 8
    96                                  section .bss
    97 000008C0 <res 100000h>               szSourceCode resb SOURCE_CODE_SIZE
    98 001008C0 <res 40h>                   ptrBuffer64 resb SMALL_BUFFER_SIZE
    99 00100900 <res 100000h>               pBuffer resb SOURCE_CODE_SIZE
   100 00200900 <res 800h>                  blockStack resb 256 * Block.size ; todo - revisit this
   101 00201100 ????????????????            blockCount resq 1
   102                                  
   103 00201108 <res 24000h>                tokenList resq MAX_TOKEN_COUNT * Token.size
   104 00225108 ????????                    dwTokenCount resd 1
   105                                  
   106                                  
   107 0022510C ????????????????            hndSourceFile resq 1
   108 00225114 ????????????????            hndDestFile resq 1
   109 0022511C ????????                    dwBytesRead resd 1
   110 00225120 ????????                    dwBytesWritten resd 1
   111 00225124 <res 20h>                   t1 resb 32
   112 00225144 ????????????????            t1Length resq 1
   113 0022514C <res 20h>                   t2 resb 32
   114 0022516C ????????????????            t2Length resq 1
   115 00225174 <res 10h>                   op resb OPERATOR_BUFFER_SIZE
   116 00225184 ????????????????            opLength resq 1
   117 0022518C ????????????????            firstArgStart resq 1
   118 00225194 <res 100h>                  szSourceFile resb 256
   119 00225294 <res 100h>                  szDestFile resb 256
   120 00225394 <res 10000h>                szGlobalConstants resb 1024*64
   121 00235394 ????????????????            qwGlobalConstantsLength resq 1
   122 0023539C ????????????????            ptrGlobalConstants resq 1
   123 002353A4 <res 80h>                   szLastLabel resb 128
   124 00235424 ??                          szLastLabelLength resb 1
   125                                  
   126                                  section .data
   127 00000000 0000000000000000            tokenIndex dq 0
   128 00000008 0000000000000000            hStdOut dq 0
   129 00000010 00                          bExpectLabel db 0
   130 00000011 00                          bIsIfCondition db 0
   131 00000012 0000000000000000            dwIfKeywordCount dq 0
   132                                      chAsmStart equ 0x60
   133                                      chDoubleQuote equ 0x22
   134                                      chComma equ 0x2c
   135 0000001A 0000                        wScopedBlockCurrentId dw 0
   136                                      
   137 0000001C 0D0A2E69665F                szIfLabel db 0xd, 0xa, ".if_"
   138                                      szIfLabelLength equ $ - szIfLabel
   139 00000022 0D0A2E7468656E5F            szThenLabel db 0xd, 0xa, ".then_"
   140                                      szThenLabelLength equ $ - szThenLabel
   141 0000002A 0D0A2E656E6469665F          szEndLabel db 0xd, 0xa, ".endif_"
   142                                      szEndLabelLength equ $ - szEndLabel
   143 00000033 0000000000000000            argCount dq 0
   144 0000003B 0D0A                        endline db 0xd, 0xa
   145 0000003D 73656374696F6E202E-         szSectionData db "section .data", 0xd, 0xa
   145 00000046 646174610D0A       
   146                                      szSectionDataLength equ $ - szSectionData
   147                                  
   148 0000004C 20546F6B656E537461-         cStrPrintTokenFormat db " TokenStart: %d, Length: %d, Token: ", 0
   148 00000055 72743A2025642C204C-
   148 0000005E 656E6774683A202564-
   148 00000067 2C20546F6B656E3A20-
   148 00000070 00                 
   149 00000071 25730D0A00                  cStrPrintTokenValueFormat db "%s", 0xd, 0xa, 0
   150                                  
   151 00000076 25732E737472617461-         cStrSourceFile db "%s.strata", 0
   151 0000007F 00                 
   152 00000080 496E7075742066696C-         cStrInputFileMessage db "Input file %s", 0xd, 0xa, 0
   152 00000089 652025730D0A00     
   153 00000090 4F7574707574206669-         cStrOutputFileMessage db "Output file %s", 0xd, 0xa, 0
   153 00000099 6C652025730D0A00   
   154 000000A1 436F6D70696C696E67-         cStrCompileMessageFormat db "Compiling file %s...", 0xd, 0xa, 0
   154 000000AA 2066696C652025732E-
   154 000000B3 2E2E0D0A00         
   155 000000B8 446F6E6520636F6D70-         cStrDoneCompiling db "Done compiling.", 0xd, 0xa, 0
   155 000000C1 696C696E672E0D0A00 
   156                                  
   157                                      ; asm output labels
   158 000000CA 0D0A2E69665F25643A-         cStrIfLabelFormat db 0xd, 0xa, ".if_%d:", 0xd, 0xa, 0
   158 000000D3 0D0A00             
   159 000000D6 0D0A2E7468656E5F25-         cStrThenLabelFormat db 0xd, 0xa, ".then_%d:", 0xd, 0xa, 0
   159 000000DF 643A0D0A00         
   160 000000E4 0D0A2E656E6469665F-         cStrEndLabelFormat db 0xd, 0xa, ".endif_%d:", 0xd, 0xa, 0
   160 000000ED 25643A0D0A00       
   161                                  
   162                                      ; error messages
   163 000000F3 4572726F723A20271B-         cStrErrorThenNotAfterIf db "Error: '", VT_91, "then", VT_END, "' not after '", VT_91, "if", VT_END, "'.", 0xd, 0xa, 0
   163 000000FC 5B39316D7468656E1B-
   163 00000105 5B306D27206E6F7420-
   163 0000010E 616674657220271B5B-
   163 00000117 39316D69661B5B306D-
   163 00000120 272E0D0A00         
   164 00000125 4572726F723A20271B-         cStrErrorEndNotAfterThen db "Error: '", VT_91, "end", VT_END, "' not after '", VT_91, "then", VT_END, "'.", 0xd, 0xa, 0
   164 0000012E 5B39316D656E641B5B-
   164 00000137 306D27206E6F742061-
   164 00000140 6674657220271B5B39-
   164 00000149 316D7468656E1B5B30-
   164 00000152 6D272E0D0A00       
   165                                  
   166                                      ; generic formats
   167 00000158 25640D0A00                  cStrDecimalFormatNL db "%d", 0xd, 0xa, 0
   168 0000015D 25780D0A00                  cStrHexFormatNL db "%x", 0xd, 0xa, 0
   169 00000162 54547970652025782C-         tformat db "TType %x, Start: %d, Len: %d", 0xd, 0xa, 0
   169 0000016B 2053746172743A2025-
   169 00000174 642C204C656E3A2025-
   169 0000017D 640D0A00           
   170 00000181 617364660D0A00              asdf db "asdf", 0xd, 0xa, 0
   171                                  
   172                                  section .text
   173                                      global _start
   174                                      extern CreateFileA
   175                                      extern ReadFile
   176                                      extern WriteFile
   177                                      extern GetLastError
   178                                      extern GetCommandLineA
   179                                  
   180                                  _start:
   181 00000466 48B8-                       mov rax, szGlobalConstants
   181 00000468 [9453220000000000] 
   182 00000470 488905(9C532300)            mov [ptrGlobalConstants], rax
   183 00000477 4883EC20                    sub rsp, 32
   184 0000047B E8(00000000)                call GetCommandLineA
   185 00000480 4883C420                    add rsp, 32
   186                                  
   187 00000484 48C705(33000000)00-         mov qword [argCount], 0
   187 0000048C 000000             
   188                                  
   189                                      ; get length of command line
   190 0000048F 4889C7                      mov rdi, rax
   191 00000492 B820000000                  mov rax, ' '
   192 00000497 4831C9                      xor rcx, rcx
   193 0000049A 4D31C0                      xor r8, r8
   194                                  
   195                                  .arg_loop:    
   196 0000049D 803F00                      cmp byte [rdi], 0
   197 000004A0 7430                        je .arg_loop_end
   198 000004A2 3807                        cmp byte [rdi], al
   199 000004A4 7408                        je .arg_loop_found_space
   200 000004A6 48FFC7                      inc rdi
   201 000004A9 49FFC0                      inc r8
   202 000004AC EBEF                        jmp .arg_loop
   203                                  
   204                                  .arg_loop_found_space:
   205                                  .if_current_arg_empty:
   206 000004AE 4983F800                    cmp r8, 0
   207 000004B2 7505                        jne .endif_current_arg_empty
   208                                  .then_current_arg_empty:
   209 000004B4 48FFC7                      inc rdi
   210 000004B7 EBE4                        jmp .arg_loop
   211                                  .endif_current_arg_empty:
   212                                  
   213                                  .if_first_arg:
   214 000004B9 803D(33000000)00            cmp byte [argCount], 0
   215 000004C0 7510                        jne .endif_first_arg
   216                                  .then_first_arg:
   217 000004C2 48FF05(33000000)            inc qword [argCount]
   218 000004C9 48FFC7                      inc rdi
   219 000004CC 4D31C0                      xor r8, r8
   220 000004CF 57                          push rdi
   221 000004D0 EBCB                        jmp .arg_loop
   222                                  .endif_first_arg:    
   223                                  
   224                                  .arg_loop_end:
   225 000004D2 5F                          pop rdi
   226                                  .if_trim:
   227 000004D3 803F20                      cmp byte [rdi], ' '
   228 000004D6 7503                        jne .endif_trim
   229                                  .then_trim:
   230 000004D8 48FFC7                      inc rdi
   231                                  .endif_trim:    
   232                                  
   233                                      multipush rax, rcx, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000004DB 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 000004DC 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000004DD 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000004DE 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   234 000004DF 4989FE                      mov r14, rdi
   235                                      strlen(rdi)
   513                              <1> 
   514 000004E2 4889F9              <1>  mov rcx, %1
   515 000004E5 E8B0FDFFFF          <1>  call strlen
   236 000004EA 4989C5                      mov r13, rax
   237                                  
   238 000004ED 4156                        push r14
   239                                      memcpy(szSourceFile, r14, r13)
   112 000004EF 48B8-               <1>  mov rax, %1
   112 000004F1 [9451220000000000]  <1>
   113 000004F9 4C89E9              <1>  mov rcx, %3
   114 000004FC 48BF-               <1>  mov rdi, %1
   114 000004FE [9451220000000000]  <1>
   115 00000506 4C89F6              <1>  mov rsi, %2
   116 00000509 F3A4                <1>  rep movsb
   240 0000050B 415E                        pop r14
   241                                      memcpy(szDestFile, r14, r13)
   112 0000050D 48B8-               <1>  mov rax, %1
   112 0000050F [9452220000000000]  <1>
   113 00000517 4C89E9              <1>  mov rcx, %3
   114 0000051A 48BF-               <1>  mov rdi, %1
   114 0000051C [9452220000000000]  <1>
   115 00000524 4C89F6              <1>  mov rsi, %2
   116 00000527 F3A4                <1>  rep movsb
   242                                      
   243 00000529 49BE-                       mov r14, szSourceFile
   243 0000052B [9451220000000000] 
   244 00000533 4D01EE                      add r14, r13
   245                                      memcpy(r14, szStrataFileExtension, szStrataFileExtension.length)
   112 00000536 4C89F0              <1>  mov rax, %1
   113 00000539 B907000000          <1>  mov rcx, %3
   114 0000053E 4C89F7              <1>  mov rdi, %1
   115 00000541 48BE-               <1>  mov rsi, %2
   115 00000543 [D401000000000000]  <1>
   116 0000054B F3A4                <1>  rep movsb
   246                                  
   247 0000054D 49BE-                       mov r14, szDestFile
   247 0000054F [9452220000000000] 
   248 00000557 4D01EE                      add r14, r13
   249                                      memcpy(r14, szAsmFileExtension, szAsmFileExtension.length)
   112 0000055A 4C89F0              <1>  mov rax, %1
   113 0000055D B904000000          <1>  mov rcx, %3
   114 00000562 4C89F7              <1>  mov rdi, %1
   115 00000565 48BE-               <1>  mov rsi, %2
   115 00000567 [DB01000000000000]  <1>
   116 0000056F F3A4                <1>  rep movsb
   250                                  
   251                                      multipop rax, rcx, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000571 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000572 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000573 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000574 58                  <2>  pop %1
    87                              <1> 
   252                                      GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])
   196                              <1> 
   197                              <1> 
   198 00000575 4883EC20            <1>  sub rsp, 32
   199 00000579 48C7C1F5FFFFFF      <1>  mov rcx, %1
   200 00000580 E8(00000000)        <1>  call GetStdHandle
   201 00000585 4883C420            <1>  add rsp, 32
   202 00000589 488905(08000000)    <1>  mov %2, rax
   253                                  
   254                                      ; print input and output file names
   255                                      printf([hStdOut], cStrInputFileMessage, szSourceFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000590 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000591 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000592 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000593 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000594 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00000596 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00000598 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 0000059A 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 0000059C 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 0000059E 4883EC20            <1>  sub rsp, 0x20
   559 000005A2 49B8-               <1>  mov r8, %3
   559 000005A4 [9451220000000000]  <1>
   560 000005AC 48BA-               <1>  mov rdx, %2
   560 000005AE [8000000000000000]  <1>
   561 000005B6 48B9-               <1>  mov rcx, printfBuffer
   561 000005B8 [4008000000000000]  <1>
   562 000005C0 E8F3FCFFFF          <1>  call sprintf
   563 000005C5 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 000005C9 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 000005CD 488B0D(08000000)    <2>  mov rcx, %1
   212 000005D4 48BA-               <2>  mov rdx, %2
   212 000005D6 [4008000000000000]  <2>
   213 000005DE 4989C0              <2>  mov r8, %3
   214 000005E1 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 000005E7 E8(00000000)        <2>  call WriteConsoleA
   217 000005EC 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000005F0 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 000005F2 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 000005F4 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000005F6 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 000005F8 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 000005FA 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000005FB 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000005FC 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000005FD 58                  <3>  pop %1
    87                              <2> 
   256                                      printf([hStdOut], cStrOutputFileMessage, szDestFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000005FE 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 000005FF 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000600 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000601 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000602 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00000604 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00000606 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00000608 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 0000060A 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 0000060C 4883EC20            <1>  sub rsp, 0x20
   559 00000610 49B8-               <1>  mov r8, %3
   559 00000612 [9452220000000000]  <1>
   560 0000061A 48BA-               <1>  mov rdx, %2
   560 0000061C [9000000000000000]  <1>
   561 00000624 48B9-               <1>  mov rcx, printfBuffer
   561 00000626 [4008000000000000]  <1>
   562 0000062E E885FCFFFF          <1>  call sprintf
   563 00000633 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00000637 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 0000063B 488B0D(08000000)    <2>  mov rcx, %1
   212 00000642 48BA-               <2>  mov rdx, %2
   212 00000644 [4008000000000000]  <2>
   213 0000064C 4989C0              <2>  mov r8, %3
   214 0000064F 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00000655 E8(00000000)        <2>  call WriteConsoleA
   217 0000065A 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000065E 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000660 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000662 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000664 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000666 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000668 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000669 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000066A 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000066B 58                  <3>  pop %1
    87                              <2> 
   257                                  
   258                                      printf([hStdOut], cStrCompileMessageFormat, szSourceFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 0000066C 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000066D 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000066E 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000066F 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000670 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00000672 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00000674 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00000676 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00000678 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 0000067A 4883EC20            <1>  sub rsp, 0x20
   559 0000067E 49B8-               <1>  mov r8, %3
   559 00000680 [9451220000000000]  <1>
   560 00000688 48BA-               <1>  mov rdx, %2
   560 0000068A [A100000000000000]  <1>
   561 00000692 48B9-               <1>  mov rcx, printfBuffer
   561 00000694 [4008000000000000]  <1>
   562 0000069C E817FCFFFF          <1>  call sprintf
   563 000006A1 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 000006A5 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 000006A9 488B0D(08000000)    <2>  mov rcx, %1
   212 000006B0 48BA-               <2>  mov rdx, %2
   212 000006B2 [4008000000000000]  <2>
   213 000006BA 4989C0              <2>  mov r8, %3
   214 000006BD 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 000006C3 E8(00000000)        <2>  call WriteConsoleA
   217 000006C8 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000006CC 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 000006CE 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D0 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D2 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D4 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D6 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D7 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D8 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000006D9 58                  <3>  pop %1
    87                              <2> 
   259                                  
   260                                      ; Preparing the parameters for CreateFileA to open a file for reading
   261 000006DA 48B9-                       mov rcx, szSourceFile                       ; First parameter: Pointer to the filename (LPCSTR)
   261 000006DC [9451220000000000] 
   262 000006E4 BA00000080                  mov rdx, GENERIC_READ                       ; Second parameter: Access to the file (DWORD), for reading use GENERIC_READ
   263 000006E9 41B801000000                mov r8, 1                                   ; Third parameter: File sharing mode (DWORD)
   264 000006EF 41B900000000                mov r9, 0                                   ; Fourth parameter: Pointer to security attributes (LPSECURITY_ATTRIBUTES)
   265 000006F5 4883EC38                    sub rsp, 4*8 + 3*8                          ; Shadow space for 4 register parameters + 3 additional stack parameters
   266 000006F9 C744242003000000            mov [rsp+4*8], dword 3                      ; Fifth parameter: Action to take on files that exist or do not exist (DWORD)
   267 00000701 C744242880000000            mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; Sixth parameter: File attributes and flags (DWORD)
   268 00000709 C744243000000000            mov [rsp+6*8], dword 0                      ; Seventh parameter: Handle to a template file (HANDLE)
   269 00000711 E8(00000000)                call CreateFileA
   270 00000716 4883C438                    add rsp, 4*8 + 3*8
   271                                  
   272                                      ; Check if the file handle is valid
   273                                  .if_0:
   274 0000071A 4883F800                    cmp rax, 0
   275 0000071E 7D7A                        jge .endif_0
   276                                  .then_0:
   277                                      WriteConsoleA([hStdOut], szFileOpenError, szFileOpenError.length, 0)
   207                              <1> 
   208                              <1> 
   209 00000720 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 00000724 488B0D(08000000)    <1>  mov rcx, %1
   212 0000072B 48BA-               <1>  mov rdx, %2
   212 0000072D [8801000000000000]  <1>
   213 00000735 41B81F000000        <1>  mov r8, %3
   214 0000073B 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 00000741 E8(00000000)        <1>  call WriteConsoleA
   217 00000746 4883C420            <1>  add rsp, 32
   278 0000074A E8(00000000)                call GetLastError
   279 0000074F 4889C1                      mov rcx, rax
   280 00000752 48BA-                       mov rdx, ptrBuffer64
   280 00000754 [C008100000000000] 
   281 0000075C E819FAFFFF                  call itoa
   282                                      WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)
   207                              <1> 
   208                              <1> 
   209 00000761 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 00000765 488B0D(08000000)    <1>  mov rcx, %1
   212 0000076C 48BA-               <1>  mov rdx, %2
   212 0000076E [C008100000000000]  <1>
   213 00000776 4989C0              <1>  mov r8, %3
   214 00000779 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 0000077F E8(00000000)        <1>  call WriteConsoleA
   217 00000784 4883C420            <1>  add rsp, 32
   283                                      ExitProcess(1)
   222                              <1> 
   223                              <1> 
   224 00000788 4883EC20            <1>  sub rsp, 32
   225 0000078C B901000000          <1>  mov rcx, %1
   226 00000791 E8(00000000)        <1>  call ExitProcess
   227 00000796 4883C420            <1>  add rsp, 32
   284                                  .endif_0:
   285                                  
   286                                     
   287                                  .file_opened:    
   288 0000079A 488905(0C512200)            mov [hndSourceFile], rax
   289                                  
   290                                      ; Preparing the parameters for ReadFile
   291 000007A1 488B0D(0C512200)            mov rcx, [hndSourceFile]      ; Handle to the file (HANDLE)
   292 000007A8 48BA-                       mov rdx, szSourceCode        ; Pointer to the buffer that receives the data read from the file (LPVOID)
   292 000007AA [C008000000000000] 
   293 000007B2 49C7C000001000              mov r8, dword SOURCE_CODE_SIZE   ; Number of bytes to be read from the file (DWORD)
   294 000007B9 49B9-                       mov r9, dwBytesRead         ; Pointer to the variable that receives the number of bytes read (LPDWORD)
   294 000007BB [1C51220000000000] 
   295 000007C3 4883EC20                    sub rsp, 32
   296 000007C7 6A00                        push 0
   297 000007C9 E8(00000000)                call ReadFile
   298                                  
   299                                      ; Check if the function succeeded
   300 000007CE 4883F800                    cmp rax, 0
   301 000007D2 0F8404120000                je .error
   302                                  
   303                                      ; Preparing the parameters for CreateFileA to open a file for writing
   304 000007D8 48B9-                       mov rcx, szDestFile                         ; Pointer to the filename (LPCSTR)
   304 000007DA [9452220000000000] 
   305 000007E2 BA00000040                  mov rdx, GENERIC_WRITE                      ; Access to the file (DWORD), for reading use GENERIC_READ
   306 000007E7 41B802000000                mov r8, 2                                   ; File sharing mode (DWORD)
   307 000007ED 41B900000000                mov r9, 0                                   ; Pointer to security attributes (LPSECURITY_ATTRIBUTES)
   308 000007F3 4883EC38                    sub rsp, 4*8 + 3*8                          ; 4 register parameters + 3 additional stack parameters
   309 000007F7 C744242002000000            mov [rsp+4*8], dword 2                      ; Action to take on files that exist or do not exist (DWORD)
   310 000007FF C744242880000000            mov [rsp+5*8], dword FILE_ATTRIBUTE_NORMAL  ; File attributes and flags (DWORD)
   311 00000807 C744243000000000            mov [rsp+6*8], dword 0                      ; Handle to a template file (HANDLE)
   312 0000080F E8(00000000)                call CreateFileA
   313 00000814 4883C438                    add rsp, 4*8 + 3*8
   314                                  
   315                                      ; Check if the function succeeded
   316 00000818 4883F800                    cmp rax, 0
   317 0000081C 0F84BA110000                je .error
   318                                  
   319 00000822 488905(14512200)            mov [hndDestFile], rax
   320                                      GetStdHandle(STD_OUTPUT_HANDLE, [hStdOut])
   196                              <1> 
   197                              <1> 
   198 00000829 4883EC20            <1>  sub rsp, 32
   199 0000082D 48C7C1F5FFFFFF      <1>  mov rcx, %1
   200 00000834 E8(00000000)        <1>  call GetStdHandle
   201 00000839 4883C420            <1>  add rsp, 32
   202 0000083D 488905(08000000)    <1>  mov %2, rax
   321                                  
   322                                  .start_parsing_source_code:
   323                                      ; reset offset
   324 00000844 4D31C0                      xor r8, r8          ; token start
   325 00000847 4D31C9                      xor r9, r9          ; token length
   326 0000084A 48BF-                       mov rdi, szSourceCode
   326 0000084C [C008000000000000] 
   327                                  
   328                                  .read_token_loop:
   329 00000854 BB0D000000                  mov rbx, 0xd    ; CR
   330 00000859 B820000000                  mov rax, ' '
   331 0000085E B90A000000                  mov rcx, 0xa    ; LF
   332 00000863 BA09000000                  mov rdx, 0x9    ; szTab
   333 00000868 803F00                      cmp byte [rdi], 0
   334 0000086B 742A                        je .source_code_end
   335 0000086D 3807                        cmp byte [rdi], al
   336 0000086F 7430                        je .token_found
   337 00000871 381F                        cmp byte [rdi], bl
   338 00000873 742C                        je .token_found
   339 00000875 380F                        cmp byte [rdi], cl
   340 00000877 7428                        je .token_found
   341 00000879 3817                        cmp byte [rdi], dl
   342 0000087B 7424                        je .token_found
   343 0000087D 803F60                      cmp byte [rdi], chAsmStart
   344 00000880 0F84750E0000                je .asm_literal_start
   345 00000886 803F22                      cmp byte [rdi], chDoubleQuote
   346 00000889 0F841B0F0000                je .string_literal_start
   347 0000088F 49FFC1                      inc r9
   348 00000892 48FFC7                      inc rdi
   349 00000895 EBBD                        jmp .read_token_loop
   350                                  
   351                                  .source_code_end:
   352 00000897 4983F900                    cmp r9, 0
   353 0000089B 0F8465110000                je .source_code_parsed
   354                                  
   355                                  .token_found:
   356                                  ; is token length 0?
   357                                  .if_1:
   358 000008A1 4983F900                    cmp r9, 0
   359 000008A5 7508                        jne .endif_1
   360                                  .then_1:
   361 000008A7 48FFC7                      inc rdi
   362 000008AA 49FFC0                      inc r8
   363 000008AD EBA5                        jmp .read_token_loop
   364                                  .endif_1:
   365                                  
   366                                  
   367                                  .print_token:
   368 000008AF 49BA-                       mov r10, szSourceCode
   368 000008B1 [C008000000000000] 
   369 000008B9 4D01C2                      add r10, r8
   370                                  
   371 000008BC 55                          push rbp
   372 000008BD 4889E5                      mov rbp, rsp
   373 000008C0 4883EC08                    sub rsp, 8 ; reserve space on the stack for the token type
   374 000008C4 66C745001200                mov [rbp], word OperandLiteral ; initialize token type to 0
   375                                      
   376                                  
   377                                  .if_token_is_if:
   378                                      CompareTokenWith(szKeywordIf)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000008CA 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008CB 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008CC 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008CD 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 000008CF 4C89D7              <2>  mov rdi, %1
   140 000008D2 48BE-               <2>  mov rsi, %2
   140 000008D4 [1302000000000000]  <2>
   141 000008DC B902000000          <2>  mov rcx, %3
   142 000008E1 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000008E3 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000008E5 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000008E6 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000008E7 5F                  <3>  pop %1
    87                              <2> 
   379 000008E8 7506                        jne .endif_token_is_if
   380                                  .then_token_is_if:
   381 000008EA 66C745000001                mov [rbp], word KeywordIf
   382                                  .endif_token_is_if:
   383                                  
   384                                  .if_token_is_then:
   385                                      CompareTokenWith(szKeywordThen)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000008F0 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008F1 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008F2 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000008F3 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 000008F5 4C89D7              <2>  mov rdi, %1
   140 000008F8 48BE-               <2>  mov rsi, %2
   140 000008FA [1502000000000000]  <2>
   141 00000902 B904000000          <2>  mov rcx, %3
   142 00000907 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000909 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000090B 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000090C 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000090D 5F                  <3>  pop %1
    87                              <2> 
   386 0000090E 7506                        jne .endif_token_is_then
   387                                  .then_token_is_then:
   388 00000910 66C745000101                mov [rbp], word KeywordThen
   389                                  .endif_token_is_then:
   390                                  
   391                                  .if_token_is_end:
   392                                      CompareTokenWith(szKeywordEnd)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000916 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000917 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000918 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000919 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 0000091B 4C89D7              <2>  mov rdi, %1
   140 0000091E 48BE-               <2>  mov rsi, %2
   140 00000920 [1902000000000000]  <2>
   141 00000928 B903000000          <2>  mov rcx, %3
   142 0000092D F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000092F 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000931 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000932 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000933 5F                  <3>  pop %1
    87                              <2> 
   393 00000934 7506                        jne .endif_token_is_end
   394                                  .then_token_is_end:
   395 00000936 66C745000201                mov [rbp], word KeywordEnd
   396                                  .endif_token_is_end:
   397                                  
   398                                  .if_token_is_eq:
   399                                      CompareTokenWith(szOperatorEquals)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 0000093C 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000093D 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000093E 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000093F 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 00000941 4C89D7              <2>  mov rdi, %1
   140 00000944 48BE-               <2>  mov rsi, %2
   140 00000946 [2002000000000000]  <2>
   141 0000094E B902000000          <2>  mov rcx, %3
   142 00000953 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000955 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000957 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000958 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000959 5F                  <3>  pop %1
    87                              <2> 
   400 0000095A 7506                        jne .endif_token_is_eq
   401                                  .then_token_is_eq:
   402 0000095C 66C745000100                mov [rbp], word OperatorEquals
   403                                  .endif_token_is_eq:
   404                                  
   405                                  .if_token_is_neq:
   406                                      CompareTokenWith(szOperatorNotEquals)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000962 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000963 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000964 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000965 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 00000967 4C89D7              <2>  mov rdi, %1
   140 0000096A 48BE-               <2>  mov rsi, %2
   140 0000096C [2202000000000000]  <2>
   141 00000974 B902000000          <2>  mov rcx, %3
   142 00000979 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000097B 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000097D 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000097E 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000097F 5F                  <3>  pop %1
    87                              <2> 
   407 00000980 7506                        jne .endif_token_is_neq
   408                                  .then_token_is_neq:
   409 00000982 66C745000200                mov [rbp], word OperatorNotEquals
   410                                  .endif_token_is_neq:
   411                                  
   412                                  .if_token_is_lteq:
   413                                      CompareTokenWith(szOperatorLessOrEqual)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000988 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000989 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000098A 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 0000098B 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 0000098D 4C89D7              <2>  mov rdi, %1
   140 00000990 48BE-               <2>  mov rsi, %2
   140 00000992 [2502000000000000]  <2>
   141 0000099A B902000000          <2>  mov rcx, %3
   142 0000099F F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000009A1 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000009A3 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009A4 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009A5 5F                  <3>  pop %1
    87                              <2> 
   414 000009A6 7506                        jne .endif_token_is_lteq
   415                                  .then_token_is_lteq:
   416 000009A8 66C745000400                mov [rbp], word OperatorLessOrEqual
   417                                  .endif_token_is_lteq:
   418                                  
   419                                  .if_token_is_lt:
   420                                      CompareTokenWith(szOperatorLess)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000009AE 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009AF 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009B0 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009B1 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 000009B3 4C89D7              <2>  mov rdi, %1
   140 000009B6 48BE-               <2>  mov rsi, %2
   140 000009B8 [2402000000000000]  <2>
   141 000009C0 B901000000          <2>  mov rcx, %3
   142 000009C5 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000009C7 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000009C9 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009CA 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009CB 5F                  <3>  pop %1
    87                              <2> 
   421 000009CC 7506                        jne .endif_token_is_lt
   422                                  .then_token_is_lt:
   423 000009CE 66C745000300                mov [rbp], word OperatorLess
   424                                  .endif_token_is_lt:
   425                                  
   426                                  .if_token_is_gteq:
   427                                      CompareTokenWith(szOperatorGreaterOrEqual)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000009D4 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009D5 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009D6 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009D7 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 000009D9 4C89D7              <2>  mov rdi, %1
   140 000009DC 48BE-               <2>  mov rsi, %2
   140 000009DE [2802000000000000]  <2>
   141 000009E6 B902000000          <2>  mov rcx, %3
   142 000009EB F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000009ED 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000009EF 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009F0 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000009F1 5F                  <3>  pop %1
    87                              <2> 
   428 000009F2 7506                        jne .endif_token_is_gteq
   429                                  .then_token_is_gteq:
   430 000009F4 66C745000600                mov [rbp], word OperatorGreaterOrEqual
   431                                  .endif_token_is_gteq:
   432                                  
   433                                  .if_token_is_gt:
   434                                      CompareTokenWith(szOperatorGreater)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000009FA 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009FB 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009FC 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000009FD 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 000009FF 4C89D7              <2>  mov rdi, %1
   140 00000A02 48BE-               <2>  mov rsi, %2
   140 00000A04 [2702000000000000]  <2>
   141 00000A0C B901000000          <2>  mov rcx, %3
   142 00000A11 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000A13 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A15 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A16 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A17 5F                  <3>  pop %1
    87                              <2> 
   435 00000A18 7506                        jne .endif_token_is_gt
   436                                  .then_token_is_gt:
   437 00000A1A 66C745000500                mov [rbp], word OperatorGreater
   438                                  .endif_token_is_gt:
   439                                  
   440                                  .if_token_is_assign:
   441                                      CompareTokenWith(szOperatorAssignment)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000A20 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A21 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A22 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A23 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 00000A25 4C89D7              <2>  mov rdi, %1
   140 00000A28 48BE-               <2>  mov rsi, %2
   140 00000A2A [2A02000000000000]  <2>
   141 00000A32 B901000000          <2>  mov rcx, %3
   142 00000A37 F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000A39 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A3B 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A3C 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A3D 5F                  <3>  pop %1
    87                              <2> 
   442 00000A3E 7506                        jne .endif_token_is_assign
   443                                  .then_token_is_assign:
   444 00000A40 66C745000700                mov [rbp], word OperatorAssignment
   445                                  .endif_token_is_assign:
   446                                  
   447                                  .if_token_is_gstr:
   448                                      CompareTokenWith(szKeywordGStr)
    34                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00000A46 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A47 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A48 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00000A49 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    35                              <1>  strcmp(r10, %1, %1.length)
   139 00000A4B 4C89D7              <2>  mov rdi, %1
   140 00000A4E 48BE-               <2>  mov rsi, %2
   140 00000A50 [1C02000000000000]  <2>
   141 00000A58 B904000000          <2>  mov rcx, %3
   142 00000A5D F3A6                <2>  repe cmpsb
    36                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00000A5F 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A61 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A62 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00000A63 5F                  <3>  pop %1
    87                              <2> 
   449 00000A64 7506                        jne .endif_token_is_gstr
   450                                  .then_token_is_gstr:
   451 00000A66 66C745000301                mov [rbp], word KeywordGStr
   452                                  .endif_token_is_gstr:
   453                                  
   454                                      ; create a token
   455                                      ; r8 - offset in source code, token start
   456                                      ; r9 - token length
   457                                      multipush rax, rbx, rcx, rdx, r15
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000A6C 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000A6D 53                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000A6E 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000A6F 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000A70 4157                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   458 00000A72 48BB-                       mov rbx, tokenList         ; load pointer to list
   458 00000A74 [0811200000000000] 
   459 00000A7C 8B05(08512200)              mov eax, [dwTokenCount]    ; load token count
   460 00000A82 BA12000000                  mov rdx, Token.size        ; and size
   461 00000A87 48F7E2                      mul rdx                    ; calculate offset
   462 00000A8A 4801C3                      add rbx, rax               ; add offset to pointer
   463 00000A8D 488B4500                    mov rax, [rbp]    ; token type
   464 00000A91 4825FFFF0000                and rax, 0xffff
   465 00000A97 668903                      mov [rbx + Token.TokenType], word ax ; token start
   466 00000A9A 4C894302                    mov [rbx + Token.TokenStart], r8 ; token start
   467 00000A9E 4C894B0A                    mov [rbx + Token.TokenLength], r9 ; token start
   468 00000AA2 FF05(08512200)              inc dword [dwTokenCount]
   469                                      multipop rax, rbx, rcx, rdx, r15
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000AA8 415F                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000AAA 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000AAB 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000AAC 5B                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000AAD 58                  <2>  pop %1
    87                              <1> 
   470                                  
   471 00000AAE 5D                          pop rbp
   472                                  
   473 00000AAF 4883C408                    add rsp, 8 ; restore stack pointer
   474                                  
   475                                  .if_label_expected:
   476 00000AB3 803D(10000000)01            cmp byte [bExpectLabel], 1
   477 00000ABA 0F85D2000000                jne .endif_label_expected
   478                                  .then_label_expected:
   479                                      multipush rax, rcx, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000AC0 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000AC1 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000AC2 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000AC3 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   480                                      ; write szTab
   481                                      memcpy([ptrGlobalConstants], szTab, szTab.length)
   112 00000AC4 488B05(9C532300)    <1>  mov rax, %1
   113 00000ACB B904000000          <1>  mov rcx, %3
   114 00000AD0 488B3D(9C532300)    <1>  mov rdi, %1
   115 00000AD7 48BE-               <1>  mov rsi, %2
   115 00000AD9 [DF01000000000000]  <1>
   116 00000AE1 F3A4                <1>  rep movsb
   482 00000AE3 488305(94532300)04          add qword [qwGlobalConstantsLength], szTab.length
   483 00000AEB 488305(9C532300)04          add qword [ptrGlobalConstants], szTab.length
   484                                      
   485                                      ; write label
   486                                      memcpy([ptrGlobalConstants], r10, r9)
   112 00000AF3 488B05(9C532300)    <1>  mov rax, %1
   113 00000AFA 4C89C9              <1>  mov rcx, %3
   114 00000AFD 488B3D(9C532300)    <1>  mov rdi, %1
   115 00000B04 4C89D6              <1>  mov rsi, %2
   116 00000B07 F3A4                <1>  rep movsb
   487 00000B09 4C010D(94532300)            add qword [qwGlobalConstantsLength], r9
   488 00000B10 4C010D(9C532300)            add qword [ptrGlobalConstants], r9
   489                                  
   490                                      ; save last label
   491                                      memcpy(szLastLabel, r10, r9)
   112 00000B17 48B8-               <1>  mov rax, %1
   112 00000B19 [A453230000000000]  <1>
   113 00000B21 4C89C9              <1>  mov rcx, %3
   114 00000B24 48BF-               <1>  mov rdi, %1
   114 00000B26 [A453230000000000]  <1>
   115 00000B2E 4C89D6              <1>  mov rsi, %2
   116 00000B31 F3A4                <1>  rep movsb
   492 00000B33 4C890D(24542300)            mov [szLastLabelLength], r9
   493                                  
   494                                      ; write separator
   495                                      memcpy([ptrGlobalConstants], szAsmDataStringType, szAsmDataStringType.length)
   112 00000B3A 488B05(9C532300)    <1>  mov rax, %1
   113 00000B41 B904000000          <1>  mov rcx, %3
   114 00000B46 488B3D(9C532300)    <1>  mov rdi, %1
   115 00000B4D 48BE-               <1>  mov rsi, %2
   115 00000B4F [E701000000000000]  <1>
   116 00000B57 F3A4                <1>  rep movsb
   496 00000B59 488305(94532300)04          add qword [qwGlobalConstantsLength], szAsmDataStringType.length
   497 00000B61 488305(9C532300)04          add qword [ptrGlobalConstants], szAsmDataStringType.length
   498                                  
   499                                      multipop rax, rcx, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000B69 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000B6A 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000B6B 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000B6C 58                  <2>  pop %1
    87                              <1> 
   500                                      ; multipush r8, r9, rdi
   501                                      ; WriteFile([hndDestFile], r10, r9, dwBytesWritten, 0)
   502                                      ; multipop r8, r9, rdi
   503                                  
   504 00000B6D C605(10000000)00            mov [bExpectLabel], byte 0
   505                                      
   506                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00000B74 4D01C8              <1>  add r8, r9
    15 00000B77 49FFC0              <1>  inc r8
    16 00000B7A 48FFC7              <1>  inc rdi
    17 00000B7D 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 00000B80 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 00000B87 0F8D790E0000        <1>  jge .source_code_parsed
    21                              <1> 
    22 00000B8D E9C2FCFFFF          <1>  jmp .read_token_loop
   507                                  .endif_label_expected:
   508                                  
   509                                      ; this is temporary, we will write to file as we go
   510                                  .if_keyword_gstr:
   511                                      multipush rdi, rsi, rcx, r10
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000B92 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000B93 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000B94 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000B95 4152                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   512                                      strcmp(r10, szKeywordGStr, szKeywordGStr.length)
   139 00000B97 4C89D7              <1>  mov rdi, %1
   140 00000B9A 48BE-               <1>  mov rsi, %2
   140 00000B9C [1C02000000000000]  <1>
   141 00000BA4 B904000000          <1>  mov rcx, %3
   142 00000BA9 F3A6                <1>  repe cmpsb
   513                                      multipop rdi, rsi, rcx, r10
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000BAB 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BAD 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BAE 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BAF 5F                  <2>  pop %1
    87                              <1> 
   514 00000BB0 7525                        jne .endif_keyword_gstr
   515                                  .then_keyword_gstr:
   516 00000BB2 C605(10000000)01            mov [bExpectLabel], byte 1
   517                                  
   518                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00000BB9 4D01C8              <1>  add r8, r9
    15 00000BBC 49FFC0              <1>  inc r8
    16 00000BBF 48FFC7              <1>  inc rdi
    17 00000BC2 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 00000BC5 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 00000BCC 0F8D340E0000        <1>  jge .source_code_parsed
    21                              <1> 
    22 00000BD2 E97DFCFFFF          <1>  jmp .read_token_loop
   519                                  .endif_keyword_gstr:
   520                                  
   521                                  .if_keyword_if:
   522                                      ; check if token is 'if'
   523                                      multipush rdi, rsi, rcx, r10
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000BD7 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000BD8 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000BD9 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000BDA 4152                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   524                                      strcmp(r10, szKeywordIf, szKeywordIf.length)
   139 00000BDC 4C89D7              <1>  mov rdi, %1
   140 00000BDF 48BE-               <1>  mov rsi, %2
   140 00000BE1 [1302000000000000]  <1>
   141 00000BE9 B902000000          <1>  mov rcx, %3
   142 00000BEE F3A6                <1>  repe cmpsb
   525                                      multipop rdi, rsi, rcx, r10
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000BF0 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BF2 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BF3 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000BF4 5F                  <2>  pop %1
    87                              <1> 
   526 00000BF5 0F85D8000000                jne .endif_keyword_if
   527                                  .then_keyword_if:
   528                                      ; write label
   529                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000BFB 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000BFD 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000BFF 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   530                                      WriteFile([hndDestFile], szIfLabel, szIfLabelLength, dwBytesWritten, 0)
    57 00000C00 488B0D(14512200)    <1>  mov rcx, %1
    58 00000C07 48BA-               <1>  mov rdx, %2
    58 00000C09 [1C00000000000000]  <1>
    59 00000C11 41B806000000        <1>  mov r8, %3
    60 00000C17 49B9-               <1>  mov r9, %4
    60 00000C19 [2051220000000000]  <1>
    61 00000C21 6A00                <1>  push %5
    62 00000C23 4883EC20            <1>  sub rsp, 32
    63 00000C27 E8(00000000)        <1>  call WriteFile
    64 00000C2C 4883C428            <1>  add rsp, 32 + 8
   531                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000C30 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000C31 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000C33 4158                <2>  pop %1
    87                              <1> 
   532 00000C35 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   533 00000C3C 48BA-                       mov rdx, ptrBuffer64
   533 00000C3E [C008100000000000] 
   534 00000C46 E82FF5FFFF                  call itoa
   535 00000C4B 48BA-                       mov rdx, ptrBuffer64
   535 00000C4D [C008100000000000] 
   536 00000C55 4801C2                      add rdx, rax
   537 00000C58 48FFC0                      inc rax
   538 00000C5B C6023A                      mov byte [rdx], ':'
   539 00000C5E 48FFC2                      inc rdx
   540 00000C61 48FFC0                      inc rax
   541 00000C64 C6020D                      mov byte [rdx], 0xd
   542 00000C67 48FFC2                      inc rdx
   543 00000C6A 48FFC0                      inc rax
   544 00000C6D C6020A                      mov byte [rdx], 0xa
   545                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000C70 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000C72 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000C74 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   546                                      WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    57 00000C75 488B0D(14512200)    <1>  mov rcx, %1
    58 00000C7C 48BA-               <1>  mov rdx, %2
    58 00000C7E [C008100000000000]  <1>
    59 00000C86 4989C0              <1>  mov r8, %3
    60 00000C89 49B9-               <1>  mov r9, %4
    60 00000C8B [2051220000000000]  <1>
    61 00000C93 6A00                <1>  push %5
    62 00000C95 4883EC20            <1>  sub rsp, 32
    63 00000C99 E8(00000000)        <1>  call WriteFile
    64 00000C9E 4883C428            <1>  add rsp, 32 + 8
   547                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000CA2 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000CA3 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000CA5 4158                <2>  pop %1
    87                              <1> 
   548 00000CA7 48FF05(12000000)            inc qword [dwIfKeywordCount]
   549                                  
   550 00000CAE C605(11000000)01            mov [bIsIfCondition], byte 1
   551                                  
   552                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00000CB5 4D01C8              <1>  add r8, r9
    15 00000CB8 49FFC0              <1>  inc r8
    16 00000CBB 48FFC7              <1>  inc rdi
    17 00000CBE 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 00000CC1 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 00000CC8 0F8D380D0000        <1>  jge .source_code_parsed
    21                              <1> 
    22 00000CCE E981FBFFFF          <1>  jmp .read_token_loop
   553                                  .endif_keyword_if:
   554                                  
   555                                  .if_keyword_then:
   556                                      multipush rdi, rsi, rcx, r10
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000CD3 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000CD4 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000CD5 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000CD6 4152                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   557                                      strcmp(r10, szKeywordThen, szKeywordThen.length)
   139 00000CD8 4C89D7              <1>  mov rdi, %1
   140 00000CDB 48BE-               <1>  mov rsi, %2
   140 00000CDD [1502000000000000]  <1>
   141 00000CE5 B904000000          <1>  mov rcx, %3
   142 00000CEA F3A6                <1>  repe cmpsb
   558                                      multipop rdi, rsi, rcx, r10
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000CEC 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000CEE 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000CEF 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000CF0 5F                  <2>  pop %1
    87                              <1> 
   559 00000CF1 0F85D8000000                jne .endif_keyword_then
   560                                  .then_keyword_then:
   561                                      ; write label
   562                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000CF7 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000CF9 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000CFB 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   563                                      WriteFile([hndDestFile], szThenLabel, szThenLabelLength, dwBytesWritten, 0)
    57 00000CFC 488B0D(14512200)    <1>  mov rcx, %1
    58 00000D03 48BA-               <1>  mov rdx, %2
    58 00000D05 [2200000000000000]  <1>
    59 00000D0D 41B808000000        <1>  mov r8, %3
    60 00000D13 49B9-               <1>  mov r9, %4
    60 00000D15 [2051220000000000]  <1>
    61 00000D1D 6A00                <1>  push %5
    62 00000D1F 4883EC20            <1>  sub rsp, 32
    63 00000D23 E8(00000000)        <1>  call WriteFile
    64 00000D28 4883C428            <1>  add rsp, 32 + 8
   564                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000D2C 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000D2D 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000D2F 4158                <2>  pop %1
    87                              <1> 
   565 00000D31 48FF0D(12000000)            dec qword [dwIfKeywordCount] ; temporarly decrement the counter
   566                                  
   567 00000D38 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   568 00000D3F 48BA-                       mov rdx, ptrBuffer64
   568 00000D41 [C008100000000000] 
   569 00000D49 E82CF4FFFF                  call itoa
   570 00000D4E 48BA-                       mov rdx, ptrBuffer64
   570 00000D50 [C008100000000000] 
   571 00000D58 4801C2                      add rdx, rax
   572 00000D5B 48FFC0                      inc rax
   573 00000D5E C6023A                      mov byte [rdx], ':'
   574 00000D61 48FFC2                      inc rdx
   575 00000D64 48FFC0                      inc rax
   576 00000D67 C6020D                      mov byte [rdx], 0xd
   577 00000D6A 48FFC2                      inc rdx
   578 00000D6D 48FFC0                      inc rax
   579 00000D70 C6020A                      mov byte [rdx], 0xa
   580                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000D73 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000D75 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000D77 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   581                                      WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    57 00000D78 488B0D(14512200)    <1>  mov rcx, %1
    58 00000D7F 48BA-               <1>  mov rdx, %2
    58 00000D81 [C008100000000000]  <1>
    59 00000D89 4989C0              <1>  mov r8, %3
    60 00000D8C 49B9-               <1>  mov r9, %4
    60 00000D8E [2051220000000000]  <1>
    61 00000D96 6A00                <1>  push %5
    62 00000D98 4883EC20            <1>  sub rsp, 32
    63 00000D9C E8(00000000)        <1>  call WriteFile
    64 00000DA1 4883C428            <1>  add rsp, 32 + 8
   582                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000DA5 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000DA6 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000DA8 4158                <2>  pop %1
    87                              <1> 
   583                                  
   584 00000DAA 48FF05(12000000)            inc qword [dwIfKeywordCount] ; restore the counter
   585                                  
   586                                      _reset_counters_  
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00000DB1 4D01C8              <1>  add r8, r9
    15 00000DB4 49FFC0              <1>  inc r8
    16 00000DB7 48FFC7              <1>  inc rdi
    17 00000DBA 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 00000DBD 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 00000DC4 0F8D3C0C0000        <1>  jge .source_code_parsed
    21                              <1> 
    22 00000DCA E985FAFFFF          <1>  jmp .read_token_loop
   587                                  .endif_keyword_then:
   588                                  
   589                                  .if_keyword_end:
   590                                      multipush rdi, rsi, rcx, r10
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000DCF 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000DD0 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000DD1 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000DD2 4152                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   591                                      strcmp(r10, szKeywordEnd, szKeywordEnd.length)
   139 00000DD4 4C89D7              <1>  mov rdi, %1
   140 00000DD7 48BE-               <1>  mov rsi, %2
   140 00000DD9 [1902000000000000]  <1>
   141 00000DE1 B903000000          <1>  mov rcx, %3
   142 00000DE6 F3A6                <1>  repe cmpsb
   592                                      multipop rdi, rsi, rcx, r10
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000DE8 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000DEA 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000DEB 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000DEC 5F                  <2>  pop %1
    87                              <1> 
   593 00000DED 0F85D8000000                jne .endif_keyword_end
   594                                  .then_keyword_end:
   595                                      ; write label
   596                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000DF3 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000DF5 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000DF7 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   597                                      WriteFile([hndDestFile], szEndLabel, szEndLabelLength, dwBytesWritten, 0)
    57 00000DF8 488B0D(14512200)    <1>  mov rcx, %1
    58 00000DFF 48BA-               <1>  mov rdx, %2
    58 00000E01 [2A00000000000000]  <1>
    59 00000E09 41B809000000        <1>  mov r8, %3
    60 00000E0F 49B9-               <1>  mov r9, %4
    60 00000E11 [2051220000000000]  <1>
    61 00000E19 6A00                <1>  push %5
    62 00000E1B 4883EC20            <1>  sub rsp, 32
    63 00000E1F E8(00000000)        <1>  call WriteFile
    64 00000E24 4883C428            <1>  add rsp, 32 + 8
   598                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000E28 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000E29 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000E2B 4158                <2>  pop %1
    87                              <1> 
   599 00000E2D 48FF0D(12000000)            dec qword [dwIfKeywordCount] ; temporarly decrement the counter
   600                                  
   601 00000E34 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   602 00000E3B 48BA-                       mov rdx, ptrBuffer64
   602 00000E3D [C008100000000000] 
   603 00000E45 E830F3FFFF                  call itoa
   604 00000E4A 48BA-                       mov rdx, ptrBuffer64
   604 00000E4C [C008100000000000] 
   605 00000E54 4801C2                      add rdx, rax
   606 00000E57 48FFC0                      inc rax
   607 00000E5A C6023A                      mov byte [rdx], ':'
   608 00000E5D 48FFC2                      inc rdx
   609 00000E60 48FFC0                      inc rax
   610 00000E63 C6020D                      mov byte [rdx], 0xd
   611 00000E66 48FFC2                      inc rdx
   612 00000E69 48FFC0                      inc rax
   613 00000E6C C6020A                      mov byte [rdx], 0xa
   614                                      multipush r8, r9, rdi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000E6F 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000E71 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000E73 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   615                                      WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten, 0)
    57 00000E74 488B0D(14512200)    <1>  mov rcx, %1
    58 00000E7B 48BA-               <1>  mov rdx, %2
    58 00000E7D [C008100000000000]  <1>
    59 00000E85 4989C0              <1>  mov r8, %3
    60 00000E88 49B9-               <1>  mov r9, %4
    60 00000E8A [2051220000000000]  <1>
    61 00000E92 6A00                <1>  push %5
    62 00000E94 4883EC20            <1>  sub rsp, 32
    63 00000E98 E8(00000000)        <1>  call WriteFile
    64 00000E9D 4883C428            <1>  add rsp, 32 + 8
   616                                      multipop r8, r9, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000EA1 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000EA2 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000EA4 4158                <2>  pop %1
    87                              <1> 
   617                                  
   618 00000EA6 48FF05(12000000)            inc qword [dwIfKeywordCount] ; restore the counter
   619                                  
   620                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00000EAD 4D01C8              <1>  add r8, r9
    15 00000EB0 49FFC0              <1>  inc r8
    16 00000EB3 48FFC7              <1>  inc rdi
    17 00000EB6 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 00000EB9 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 00000EC0 0F8D400B0000        <1>  jge .source_code_parsed
    21                              <1> 
    22 00000EC6 E989F9FFFF          <1>  jmp .read_token_loop
   621                                  .endif_keyword_end:
   622                                  
   623                                  .if_is_first_if_condition_operand:
   624 00000ECB 803D(11000000)01            cmp [bIsIfCondition], byte 1
   625 00000ED2 753A                        jne .endif_is_first_if_condition_operand
   626                                  .then_is_first_if_condition_operand:
   627                                      ; set t1
   628                                      multipush rcx, rdx, r8, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000ED4 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000ED5 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000ED6 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000ED8 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000ED9 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   629                                      memcpy(t1, r10, r9)
   112 00000EDA 48B8-               <1>  mov rax, %1
   112 00000EDC [2451220000000000]  <1>
   113 00000EE4 4C89C9              <1>  mov rcx, %3
   114 00000EE7 48BF-               <1>  mov rdi, %1
   114 00000EE9 [2451220000000000]  <1>
   115 00000EF1 4C89D6              <1>  mov rsi, %2
   116 00000EF4 F3A4                <1>  rep movsb
   630 00000EF6 4C890D(44512200)            mov [t1Length], r9
   631                                      multipop rcx, rdx, r8, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000EFD 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000EFE 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000EFF 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F01 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F02 59                  <2>  pop %1
    87                              <1> 
   632 00000F03 FE05(11000000)              inc byte [bIsIfCondition]
   633 00000F09 E9CF070000                  jmp .advance_token
   634                                  .endif_is_first_if_condition_operand:
   635                                  
   636                                  .if_is_if_condition_operator:
   637 00000F0E 803D(11000000)02            cmp [bIsIfCondition], byte 2
   638 00000F15 7557                        jne .endif_is_if_condition_operator
   639                                  .then_is_if_condition_operator:
   640                                      ; set op
   641                                      multipush rcx, rdx, r8, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000F17 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F18 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F19 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000F1B 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F1C 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   642                                      memset(op, 0, OPERATOR_BUFFER_SIZE)
   130 00000F1D 48B8-               <1>  mov rax, %1
   130 00000F1F [7451220000000000]  <1>
   131 00000F27 B910000000          <1>  mov rcx, %3
   132 00000F2C 48BF-               <1>  mov rdi, %1
   132 00000F2E [7451220000000000]  <1>
   133 00000F36 B000                <1>  mov al, %2
   134 00000F38 F3AA                <1>  rep stosb
   643                                      memcpy(op, r10, r9)
   112 00000F3A 48B8-               <1>  mov rax, %1
   112 00000F3C [7451220000000000]  <1>
   113 00000F44 4C89C9              <1>  mov rcx, %3
   114 00000F47 48BF-               <1>  mov rdi, %1
   114 00000F49 [7451220000000000]  <1>
   115 00000F51 4C89D6              <1>  mov rsi, %2
   116 00000F54 F3A4                <1>  rep movsb
   644 00000F56 4C890D(84512200)            mov [opLength], r9
   645                                      multipop rcx, rdx, r8, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000F5D 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F5E 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F5F 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F61 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000F62 59                  <2>  pop %1
    87                              <1> 
   646 00000F63 FE05(11000000)              inc byte [bIsIfCondition]
   647 00000F69 E96F070000                  jmp .advance_token
   648                                  .endif_is_if_condition_operator:
   649                                  
   650                                  .if_is_second_if_condition_operand:
   651 00000F6E 803D(11000000)03            cmp [bIsIfCondition], byte 3
   652 00000F75 0F8562070000                jne .endif_is_second_if_condition_operand
   653                                  .then_is_second_if_condition_operand:
   654                                      ; set t2
   655                                      multipush rcx, rdx, r8, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000F7B 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F7C 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F7D 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000F7F 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000F80 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   656                                      memcpy(t2, r10, r9)
   112 00000F81 48B8-               <1>  mov rax, %1
   112 00000F83 [4C51220000000000]  <1>
   113 00000F8B 4C89C9              <1>  mov rcx, %3
   114 00000F8E 48BF-               <1>  mov rdi, %1
   114 00000F90 [4C51220000000000]  <1>
   115 00000F98 4C89D6              <1>  mov rsi, %2
   116 00000F9B F3A4                <1>  rep movsb
   657 00000F9D 4C890D(6C512200)            mov [t2Length], r9
   658                                      multipop rcx, rdx, r8, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00000FA4 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000FA5 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000FA6 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00000FA8 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00000FA9 59                  <2>  pop %1
    87                              <1> 
   659                                  
   660                                      ; write t1 <comparison> t2
   661                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00000FAA 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000FAB 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000FAC 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00000FAE 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00000FB0 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000FB1 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00000FB2 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   662 00000FB4 49BB-                       mov r11, ptrBuffer64
   662 00000FB6 [C008100000000000] 
   663                                      memset(r11, ' ', 4)
   130 00000FBE 4C89D8              <1>  mov rax, %1
   131 00000FC1 B904000000          <1>  mov rcx, %3
   132 00000FC6 4C89DF              <1>  mov rdi, %1
   133 00000FC9 B020                <1>  mov al, %2
   134 00000FCB F3AA                <1>  rep stosb
   664 00000FCD 4983C304                    add r11, 4
   665 00000FD1 41B804000000                mov r8, 4
   666                                      memcpy(r11, szAsmCmp, szAsmCmp.length)
   112 00000FD7 4C89D8              <1>  mov rax, %1
   113 00000FDA B904000000          <1>  mov rcx, %3
   114 00000FDF 4C89DF              <1>  mov rdi, %1
   115 00000FE2 48BE-               <1>  mov rsi, %2
   115 00000FE4 [E301000000000000]  <1>
   116 00000FEC F3A4                <1>  rep movsb
   667 00000FEE 4983C004                    add r8, szAsmCmp.length ; r8 stores counter
   668 00000FF2 4983C304                    add r11, szAsmCmp.length
   669                                      memcpy(r11, t1, [t1Length])
   112 00000FF6 4C89D8              <1>  mov rax, %1
   113 00000FF9 488B0D(44512200)    <1>  mov rcx, %3
   114 00001000 4C89DF              <1>  mov rdi, %1
   115 00001003 48BE-               <1>  mov rsi, %2
   115 00001005 [2451220000000000]  <1>
   116 0000100D F3A4                <1>  rep movsb
   670 0000100F 4C0305(44512200)            add r8, [t1Length]
   671 00001016 4C031D(44512200)            add r11, [t1Length]
   672                                      ; add comma
   673 0000101D 41C6032C                    mov byte [r11], ','
   674 00001021 49FFC3                      inc r11
   675 00001024 49FFC0                      inc r8
   676                                      ; add space
   677 00001027 41C60320                    mov byte [r11], ' '
   678 0000102B 49FFC3                      inc r11
   679 0000102E 49FFC0                      inc r8
   680                                      memcpy(r11, t2, [t2Length])
   112 00001031 4C89D8              <1>  mov rax, %1
   113 00001034 488B0D(6C512200)    <1>  mov rcx, %3
   114 0000103B 4C89DF              <1>  mov rdi, %1
   115 0000103E 48BE-               <1>  mov rsi, %2
   115 00001040 [4C51220000000000]  <1>
   116 00001048 F3A4                <1>  rep movsb
   681 0000104A 4C0305(6C512200)            add r8, [t2Length]
   682 00001051 4C031D(6C512200)            add r11, [t2Length]
   683                                      ; inc r11
   684 00001058 49FFC0                      inc r8
   685 0000105B 41C6030D                    mov byte [r11], 0xd
   686 0000105F 49FFC3                      inc r11
   687 00001062 49FFC0                      inc r8
   688 00001065 41C6030A                    mov byte [r11], 0xa
   689                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 00001069 488B0D(14512200)    <1>  mov rcx, %1
    58 00001070 48BA-               <1>  mov rdx, %2
    58 00001072 [C008100000000000]  <1>
    59 0000107A 4D89C0              <1>  mov r8, %3
    60 0000107D 49B9-               <1>  mov r9, %4
    60 0000107F [2051220000000000]  <1>
    61 00001087 6A00                <1>  push %5
    62 00001089 4883EC20            <1>  sub rsp, 32
    63 0000108D E8(00000000)        <1>  call WriteFile
    64 00001092 4883C428            <1>  add rsp, 32 + 8
   690                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001096 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001098 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001099 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000109A 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000109C 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000109E 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000109F 59                  <2>  pop %1
    87                              <1> 
   691                                  
   692 000010A0 C605(11000000)00            mov [bIsIfCondition], byte 0
   693                                  
   694                                  .if_if_operator_is_equal:
   695                                      CompareOperatorWith(szOperatorEquals)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000010A7 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000010A8 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000010A9 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000010AA 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000010AC 48BF-               <2>  mov rdi, %1
   139 000010AE [7451220000000000]  <2>
   140 000010B6 48BE-               <2>  mov rsi, %2
   140 000010B8 [2002000000000000]  <2>
   141 000010C0 B902000000          <2>  mov rcx, %3
   142 000010C5 F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000010C7 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000010C9 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000010CA 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000010CB 5F                  <3>  pop %1
    87                              <2> 
   696 000010CC 0F85DE000000                jne .endif_if_operator_is_equal
   697                                  .then_if_operator_is_equal:
   698                                      ; when equal, we need to jump if not equal
   699                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000010D2 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000010D3 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000010D4 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 000010D6 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 000010D8 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000010D9 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 000010DA 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   700 000010DC 49BB-                       mov r11, ptrBuffer64
   700 000010DE [C008100000000000] 
   701                                      memset(r11, ' ', 4)
   130 000010E6 4C89D8              <1>  mov rax, %1
   131 000010E9 B904000000          <1>  mov rcx, %3
   132 000010EE 4C89DF              <1>  mov rdi, %1
   133 000010F1 B020                <1>  mov al, %2
   134 000010F3 F3AA                <1>  rep stosb
   702 000010F5 4983C304                    add r11, 4
   703 000010F9 41B804000000                mov r8, 4
   704                                      memcpy(r11, szAsmEqual, szAsmEqual.length)
   112 000010FF 4C89D8              <1>  mov rax, %1
   113 00001102 B904000000          <1>  mov rcx, %3
   114 00001107 4C89DF              <1>  mov rdi, %1
   115 0000110A 48BE-               <1>  mov rsi, %2
   115 0000110C [FE01000000000000]  <1>
   116 00001114 F3A4                <1>  rep movsb
   705 00001116 4983C004                    add r8, szAsmEqual.length 
   706 0000111A 4983C304                    add r11, szAsmEqual.length
   707                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 0000111E 4C89D8              <1>  mov rax, %1
   113 00001121 B907000000          <1>  mov rcx, %3
   114 00001126 4C89DF              <1>  mov rdi, %1
   115 00001129 48BE-               <1>  mov rsi, %2
   115 0000112B [2B02000000000000]  <1>
   116 00001133 F3A4                <1>  rep movsb
   708 00001135 4983C007                    add r8, szEndLabelForJump.length
   709 00001139 4983C307                    add r11, szEndLabelForJump.length
   710                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 0000113D 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 0000113E 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 0000113F 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   711                                  
   712 00001140 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   713 00001147 48FFC9                      dec rcx ; decrement the counter
   714 0000114A 4C89DA                      mov rdx, r11
   715 0000114D E828F0FFFF                  call itoa
   716 00001152 4901C3                      add r11, rax
   717 00001155 4901C0                      add r8, rax
   718                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001158 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001159 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000115A 58                  <2>  pop %1
    87                              <1> 
   719                                  
   720                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 0000115B 488B0D(14512200)    <1>  mov rcx, %1
    58 00001162 48BA-               <1>  mov rdx, %2
    58 00001164 [C008100000000000]  <1>
    59 0000116C 4D89C0              <1>  mov r8, %3
    60 0000116F 49B9-               <1>  mov r9, %4
    60 00001171 [2051220000000000]  <1>
    61 00001179 6A00                <1>  push %5
    62 0000117B 4883EC20            <1>  sub rsp, 32
    63 0000117F E8(00000000)        <1>  call WriteFile
    64 00001184 4883C428            <1>  add rsp, 32 + 8
   721                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001188 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000118A 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000118B 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000118C 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000118E 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001190 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001191 59                  <2>  pop %1
    87                              <1> 
   722                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 00001192 4D01C8              <1>  add r8, r9
    15 00001195 49FFC0              <1>  inc r8
    16 00001198 48FFC7              <1>  inc rdi
    17 0000119B 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 0000119E 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000011A5 0F8D5B080000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000011AB E9A4F6FFFF          <1>  jmp .read_token_loop
   723                                  .endif_if_operator_is_equal:
   724                                  
   725                                  .if_if_operator_is_not_equal:
   726                                      CompareOperatorWith(szOperatorNotEquals)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000011B0 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000011B1 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000011B2 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000011B3 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000011B5 48BF-               <2>  mov rdi, %1
   139 000011B7 [7451220000000000]  <2>
   140 000011BF 48BE-               <2>  mov rsi, %2
   140 000011C1 [2202000000000000]  <2>
   141 000011C9 B902000000          <2>  mov rcx, %3
   142 000011CE F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000011D0 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000011D2 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000011D3 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000011D4 5F                  <3>  pop %1
    87                              <2> 
   727 000011D5 0F85DE000000                jne .endif_if_operator_is_not_equal
   728                                  .then_if_operator_is_not_equal:
   729                                      ; when equal, we need to jump if not equal
   730                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000011DB 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000011DC 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000011DD 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 000011DF 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 000011E1 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000011E2 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 000011E3 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   731 000011E5 49BB-                       mov r11, ptrBuffer64
   731 000011E7 [C008100000000000] 
   732                                      memset(r11, ' ', 4)
   130 000011EF 4C89D8              <1>  mov rax, %1
   131 000011F2 B904000000          <1>  mov rcx, %3
   132 000011F7 4C89DF              <1>  mov rdi, %1
   133 000011FA B020                <1>  mov al, %2
   134 000011FC F3AA                <1>  rep stosb
   733 000011FE 4983C304                    add r11, 4
   734 00001202 41B804000000                mov r8, 4
   735                                      memcpy(r11, szAsmNotEqual, szAsmNotEqual.length)
   112 00001208 4C89D8              <1>  mov rax, %1
   113 0000120B B903000000          <1>  mov rcx, %3
   114 00001210 4C89DF              <1>  mov rdi, %1
   115 00001213 48BE-               <1>  mov rsi, %2
   115 00001215 [0202000000000000]  <1>
   116 0000121D F3A4                <1>  rep movsb
   736 0000121F 4983C003                    add r8, szAsmNotEqual.length 
   737 00001223 4983C303                    add r11, szAsmNotEqual.length
   738                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 00001227 4C89D8              <1>  mov rax, %1
   113 0000122A B907000000          <1>  mov rcx, %3
   114 0000122F 4C89DF              <1>  mov rdi, %1
   115 00001232 48BE-               <1>  mov rsi, %2
   115 00001234 [2B02000000000000]  <1>
   116 0000123C F3A4                <1>  rep movsb
   739 0000123E 4983C007                    add r8, szEndLabelForJump.length
   740 00001242 4983C307                    add r11, szEndLabelForJump.length
   741                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001246 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001247 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001248 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   742                                  
   743 00001249 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   744 00001250 48FFC9                      dec rcx ; decrement the counter
   745 00001253 4C89DA                      mov rdx, r11
   746 00001256 E81FEFFFFF                  call itoa
   747 0000125B 4901C3                      add r11, rax
   748 0000125E 4901C0                      add r8, rax
   749                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001261 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001262 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001263 58                  <2>  pop %1
    87                              <1> 
   750                                  
   751                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 00001264 488B0D(14512200)    <1>  mov rcx, %1
    58 0000126B 48BA-               <1>  mov rdx, %2
    58 0000126D [C008100000000000]  <1>
    59 00001275 4D89C0              <1>  mov r8, %3
    60 00001278 49B9-               <1>  mov r9, %4
    60 0000127A [2051220000000000]  <1>
    61 00001282 6A00                <1>  push %5
    62 00001284 4883EC20            <1>  sub rsp, 32
    63 00001288 E8(00000000)        <1>  call WriteFile
    64 0000128D 4883C428            <1>  add rsp, 32 + 8
   752                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001291 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001293 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001294 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001295 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001297 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001299 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000129A 59                  <2>  pop %1
    87                              <1> 
   753                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 0000129B 4D01C8              <1>  add r8, r9
    15 0000129E 49FFC0              <1>  inc r8
    16 000012A1 48FFC7              <1>  inc rdi
    17 000012A4 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000012A7 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000012AE 0F8D52070000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000012B4 E99BF5FFFF          <1>  jmp .read_token_loop
   754                                  .endif_if_operator_is_not_equal:
   755                                  
   756                                  .if_if_operator_is_less_or_equal:
   757                                      CompareOperatorWith(szOperatorLessOrEqual)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000012B9 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000012BA 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000012BB 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000012BC 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000012BE 48BF-               <2>  mov rdi, %1
   139 000012C0 [7451220000000000]  <2>
   140 000012C8 48BE-               <2>  mov rsi, %2
   140 000012CA [2502000000000000]  <2>
   141 000012D2 B902000000          <2>  mov rcx, %3
   142 000012D7 F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000012D9 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000012DB 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000012DC 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000012DD 5F                  <3>  pop %1
    87                              <2> 
   758 000012DE 0F85DE000000                jne .endif_if_operator_is_less_or_equal
   759                                  .then_if_operator_is_less_or_equal:
   760                                      ; when equal, we need to jump if not equal
   761                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000012E4 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000012E5 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000012E6 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 000012E8 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 000012EA 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000012EB 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 000012EC 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   762 000012EE 49BB-                       mov r11, ptrBuffer64
   762 000012F0 [C008100000000000] 
   763                                      memset(r11, ' ', 4)
   130 000012F8 4C89D8              <1>  mov rax, %1
   131 000012FB B904000000          <1>  mov rcx, %3
   132 00001300 4C89DF              <1>  mov rdi, %1
   133 00001303 B020                <1>  mov al, %2
   134 00001305 F3AA                <1>  rep stosb
   764 00001307 4983C304                    add r11, 4
   765 0000130B 41B804000000                mov r8, 4
   766                                      memcpy(r11, szAsmLessOrEqual, szAsmLessOrEqual.length)
   112 00001311 4C89D8              <1>  mov rax, %1
   113 00001314 B903000000          <1>  mov rcx, %3
   114 00001319 4C89DF              <1>  mov rdi, %1
   115 0000131C 48BE-               <1>  mov rsi, %2
   115 0000131E [0902000000000000]  <1>
   116 00001326 F3A4                <1>  rep movsb
   767 00001328 4983C003                    add r8, szAsmLessOrEqual.length 
   768 0000132C 4983C303                    add r11, szAsmLessOrEqual.length
   769                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 00001330 4C89D8              <1>  mov rax, %1
   113 00001333 B907000000          <1>  mov rcx, %3
   114 00001338 4C89DF              <1>  mov rdi, %1
   115 0000133B 48BE-               <1>  mov rsi, %2
   115 0000133D [2B02000000000000]  <1>
   116 00001345 F3A4                <1>  rep movsb
   770 00001347 4983C007                    add r8, szEndLabelForJump.length
   771 0000134B 4983C307                    add r11, szEndLabelForJump.length
   772                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 0000134F 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001350 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001351 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   773                                  
   774 00001352 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   775 00001359 48FFC9                      dec rcx ; decrement the counter
   776 0000135C 4C89DA                      mov rdx, r11
   777 0000135F E816EEFFFF                  call itoa
   778 00001364 4901C3                      add r11, rax
   779 00001367 4901C0                      add r8, rax
   780                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 0000136A 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000136B 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000136C 58                  <2>  pop %1
    87                              <1> 
   781                                  
   782                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 0000136D 488B0D(14512200)    <1>  mov rcx, %1
    58 00001374 48BA-               <1>  mov rdx, %2
    58 00001376 [C008100000000000]  <1>
    59 0000137E 4D89C0              <1>  mov r8, %3
    60 00001381 49B9-               <1>  mov r9, %4
    60 00001383 [2051220000000000]  <1>
    61 0000138B 6A00                <1>  push %5
    62 0000138D 4883EC20            <1>  sub rsp, 32
    63 00001391 E8(00000000)        <1>  call WriteFile
    64 00001396 4883C428            <1>  add rsp, 32 + 8
   783                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 0000139A 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000139C 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000139D 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000139E 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 000013A0 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 000013A2 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000013A3 59                  <2>  pop %1
    87                              <1> 
   784                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 000013A4 4D01C8              <1>  add r8, r9
    15 000013A7 49FFC0              <1>  inc r8
    16 000013AA 48FFC7              <1>  inc rdi
    17 000013AD 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000013B0 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000013B7 0F8D49060000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000013BD E992F4FFFF          <1>  jmp .read_token_loop
   785                                  .endif_if_operator_is_less_or_equal:
   786                                  
   787                                  .if_if_operator_is_less:
   788                                      CompareOperatorWith(szOperatorLess)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000013C2 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000013C3 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000013C4 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000013C5 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000013C7 48BF-               <2>  mov rdi, %1
   139 000013C9 [7451220000000000]  <2>
   140 000013D1 48BE-               <2>  mov rsi, %2
   140 000013D3 [2402000000000000]  <2>
   141 000013DB B901000000          <2>  mov rcx, %3
   142 000013E0 F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000013E2 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000013E4 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000013E5 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000013E6 5F                  <3>  pop %1
    87                              <2> 
   789 000013E7 0F85DE000000                jne .endif_if_operator_is_less
   790                                  .then_if_operator_is_less:
   791                                      ; when equal, we need to jump if not equal
   792                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000013ED 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000013EE 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000013EF 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 000013F1 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 000013F3 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000013F4 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 000013F5 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   793 000013F7 49BB-                       mov r11, ptrBuffer64
   793 000013F9 [C008100000000000] 
   794                                      memset(r11, ' ', 4)
   130 00001401 4C89D8              <1>  mov rax, %1
   131 00001404 B904000000          <1>  mov rcx, %3
   132 00001409 4C89DF              <1>  mov rdi, %1
   133 0000140C B020                <1>  mov al, %2
   134 0000140E F3AA                <1>  rep stosb
   795 00001410 4983C304                    add r11, 4
   796 00001414 41B804000000                mov r8, 4
   797                                      memcpy(r11, szAsmLess, szAsmLess.length)
   112 0000141A 4C89D8              <1>  mov rax, %1
   113 0000141D B904000000          <1>  mov rcx, %3
   114 00001422 4C89DF              <1>  mov rdi, %1
   115 00001425 48BE-               <1>  mov rsi, %2
   115 00001427 [0502000000000000]  <1>
   116 0000142F F3A4                <1>  rep movsb
   798 00001431 4983C004                    add r8, szAsmLess.length 
   799 00001435 4983C304                    add r11, szAsmLess.length
   800                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 00001439 4C89D8              <1>  mov rax, %1
   113 0000143C B907000000          <1>  mov rcx, %3
   114 00001441 4C89DF              <1>  mov rdi, %1
   115 00001444 48BE-               <1>  mov rsi, %2
   115 00001446 [2B02000000000000]  <1>
   116 0000144E F3A4                <1>  rep movsb
   801 00001450 4983C007                    add r8, szEndLabelForJump.length
   802 00001454 4983C307                    add r11, szEndLabelForJump.length
   803                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001458 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001459 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 0000145A 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   804                                  
   805 0000145B 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   806 00001462 48FFC9                      dec rcx ; decrement the counter
   807 00001465 4C89DA                      mov rdx, r11
   808 00001468 E80DEDFFFF                  call itoa
   809 0000146D 4901C3                      add r11, rax
   810 00001470 4901C0                      add r8, rax
   811                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001473 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001474 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001475 58                  <2>  pop %1
    87                              <1> 
   812                                  
   813                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 00001476 488B0D(14512200)    <1>  mov rcx, %1
    58 0000147D 48BA-               <1>  mov rdx, %2
    58 0000147F [C008100000000000]  <1>
    59 00001487 4D89C0              <1>  mov r8, %3
    60 0000148A 49B9-               <1>  mov r9, %4
    60 0000148C [2051220000000000]  <1>
    61 00001494 6A00                <1>  push %5
    62 00001496 4883EC20            <1>  sub rsp, 32
    63 0000149A E8(00000000)        <1>  call WriteFile
    64 0000149F 4883C428            <1>  add rsp, 32 + 8
   814                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 000014A3 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 000014A5 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000014A6 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000014A7 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 000014A9 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 000014AB 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000014AC 59                  <2>  pop %1
    87                              <1> 
   815                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 000014AD 4D01C8              <1>  add r8, r9
    15 000014B0 49FFC0              <1>  inc r8
    16 000014B3 48FFC7              <1>  inc rdi
    17 000014B6 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000014B9 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000014C0 0F8D40050000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000014C6 E989F3FFFF          <1>  jmp .read_token_loop
   816                                  .endif_if_operator_is_less:
   817                                  
   818                                  .if_if_operator_is_greater_or_equal:
   819                                      CompareOperatorWith(szOperatorGreaterOrEqual)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000014CB 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000014CC 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000014CD 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000014CE 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000014D0 48BF-               <2>  mov rdi, %1
   139 000014D2 [7451220000000000]  <2>
   140 000014DA 48BE-               <2>  mov rsi, %2
   140 000014DC [2802000000000000]  <2>
   141 000014E4 B902000000          <2>  mov rcx, %3
   142 000014E9 F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000014EB 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000014ED 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000014EE 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000014EF 5F                  <3>  pop %1
    87                              <2> 
   820 000014F0 0F85DE000000                jne .endif_if_operator_is_greater_or_equal
   821                                  .then_if_operator_is_greater_or_equal:
   822                                      ; when equal, we need to jump if not equal
   823                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000014F6 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000014F7 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000014F8 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 000014FA 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 000014FC 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 000014FD 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 000014FE 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   824 00001500 49BB-                       mov r11, ptrBuffer64
   824 00001502 [C008100000000000] 
   825                                      memset(r11, ' ', 4)
   130 0000150A 4C89D8              <1>  mov rax, %1
   131 0000150D B904000000          <1>  mov rcx, %3
   132 00001512 4C89DF              <1>  mov rdi, %1
   133 00001515 B020                <1>  mov al, %2
   134 00001517 F3AA                <1>  rep stosb
   826 00001519 4983C304                    add r11, 4
   827 0000151D 41B804000000                mov r8, 4
   828                                      memcpy(r11, szAsmGreaterOrEqual, szAsmGreaterOrEqual.length)
   112 00001523 4C89D8              <1>  mov rax, %1
   113 00001526 B903000000          <1>  mov rcx, %3
   114 0000152B 4C89DF              <1>  mov rdi, %1
   115 0000152E 48BE-               <1>  mov rsi, %2
   115 00001530 [1002000000000000]  <1>
   116 00001538 F3A4                <1>  rep movsb
   829 0000153A 4983C003                    add r8, szAsmGreaterOrEqual.length 
   830 0000153E 4983C303                    add r11, szAsmGreaterOrEqual.length
   831                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 00001542 4C89D8              <1>  mov rax, %1
   113 00001545 B907000000          <1>  mov rcx, %3
   114 0000154A 4C89DF              <1>  mov rdi, %1
   115 0000154D 48BE-               <1>  mov rsi, %2
   115 0000154F [2B02000000000000]  <1>
   116 00001557 F3A4                <1>  rep movsb
   832 00001559 4983C007                    add r8, szEndLabelForJump.length
   833 0000155D 4983C307                    add r11, szEndLabelForJump.length
   834                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001561 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001562 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001563 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   835                                  
   836 00001564 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   837 0000156B 48FFC9                      dec rcx ; decrement the counter
   838 0000156E 4C89DA                      mov rdx, r11
   839 00001571 E804ECFFFF                  call itoa
   840 00001576 4901C3                      add r11, rax
   841 00001579 4901C0                      add r8, rax
   842                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 0000157C 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000157D 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000157E 58                  <2>  pop %1
    87                              <1> 
   843                                  
   844                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 0000157F 488B0D(14512200)    <1>  mov rcx, %1
    58 00001586 48BA-               <1>  mov rdx, %2
    58 00001588 [C008100000000000]  <1>
    59 00001590 4D89C0              <1>  mov r8, %3
    60 00001593 49B9-               <1>  mov r9, %4
    60 00001595 [2051220000000000]  <1>
    61 0000159D 6A00                <1>  push %5
    62 0000159F 4883EC20            <1>  sub rsp, 32
    63 000015A3 E8(00000000)        <1>  call WriteFile
    64 000015A8 4883C428            <1>  add rsp, 32 + 8
   845                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 000015AC 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 000015AE 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000015AF 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000015B0 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 000015B2 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 000015B4 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000015B5 59                  <2>  pop %1
    87                              <1> 
   846                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 000015B6 4D01C8              <1>  add r8, r9
    15 000015B9 49FFC0              <1>  inc r8
    16 000015BC 48FFC7              <1>  inc rdi
    17 000015BF 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000015C2 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000015C9 0F8D37040000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000015CF E980F2FFFF          <1>  jmp .read_token_loop
   847                                  .endif_if_operator_is_greater_or_equal:
   848                                  
   849                                  .if_if_operator_is_greater:
   850                                      CompareOperatorWith(szOperatorGreater)
    27                              <1>  multipush rdi, rsi, rcx, r10
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 000015D4 57                  <3>  push %1
    73                              <3>  %rotate 1
    72 000015D5 56                  <3>  push %1
    73                              <3>  %rotate 1
    72 000015D6 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 000015D7 4152                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
    28                              <1>  strcmp(op, %1, %1.length)
   139 000015D9 48BF-               <2>  mov rdi, %1
   139 000015DB [7451220000000000]  <2>
   140 000015E3 48BE-               <2>  mov rsi, %2
   140 000015E5 [2702000000000000]  <2>
   141 000015ED B901000000          <2>  mov rcx, %3
   142 000015F2 F3A6                <2>  repe cmpsb
    29                              <1>  multipop rdi, rsi, rcx, r10
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 000015F4 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 000015F6 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000015F7 5E                  <3>  pop %1
    84                              <3>  %rotate -1
    85 000015F8 5F                  <3>  pop %1
    87                              <2> 
   851 000015F9 0F85DE000000                jne .endif_if_operator_is_greater
   852                                  .then_if_operator_is_greater:
   853                                      ; when equal, we need to jump if not equal
   854                                      multipush rcx, rdx, r8, r9, rdi, rsi, r11
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000015FF 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001600 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001601 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00001603 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00001605 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001606 56                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001607 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   855 00001609 49BB-                       mov r11, ptrBuffer64
   855 0000160B [C008100000000000] 
   856                                      memset(r11, ' ', 4)
   130 00001613 4C89D8              <1>  mov rax, %1
   131 00001616 B904000000          <1>  mov rcx, %3
   132 0000161B 4C89DF              <1>  mov rdi, %1
   133 0000161E B020                <1>  mov al, %2
   134 00001620 F3AA                <1>  rep stosb
   857 00001622 4983C304                    add r11, 4
   858 00001626 41B804000000                mov r8, 4
   859                                      memcpy(r11, szAsmGreater, szAsmGreater.length)
   112 0000162C 4C89D8              <1>  mov rax, %1
   113 0000162F B904000000          <1>  mov rcx, %3
   114 00001634 4C89DF              <1>  mov rdi, %1
   115 00001637 48BE-               <1>  mov rsi, %2
   115 00001639 [0C02000000000000]  <1>
   116 00001641 F3A4                <1>  rep movsb
   860 00001643 4983C004                    add r8, szAsmGreater.length 
   861 00001647 4983C304                    add r11, szAsmGreater.length
   862                                      memcpy(r11, szEndLabelForJump, szEndLabelForJump.length)
   112 0000164B 4C89D8              <1>  mov rax, %1
   113 0000164E B907000000          <1>  mov rcx, %3
   114 00001653 4C89DF              <1>  mov rdi, %1
   115 00001656 48BE-               <1>  mov rsi, %2
   115 00001658 [2B02000000000000]  <1>
   116 00001660 F3A4                <1>  rep movsb
   863 00001662 4983C007                    add r8, szEndLabelForJump.length
   864 00001666 4983C307                    add r11, szEndLabelForJump.length
   865                                      multipush rax, rcx, rdx
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 0000166A 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 0000166B 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 0000166C 52                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   866                                  
   867 0000166D 488B0D(12000000)            mov rcx, [dwIfKeywordCount]
   868 00001674 48FFC9                      dec rcx ; decrement the counter
   869 00001677 4C89DA                      mov rdx, r11
   870 0000167A E8FBEAFFFF                  call itoa
   871 0000167F 4901C3                      add r11, rax
   872 00001682 4901C0                      add r8, rax
   873                                      multipop rax, rcx, rdx
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001685 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001686 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001687 58                  <2>  pop %1
    87                              <1> 
   874                                  
   875                                      WriteFile([hndDestFile], ptrBuffer64, r8, dwBytesWritten, 0)
    57 00001688 488B0D(14512200)    <1>  mov rcx, %1
    58 0000168F 48BA-               <1>  mov rdx, %2
    58 00001691 [C008100000000000]  <1>
    59 00001699 4D89C0              <1>  mov r8, %3
    60 0000169C 49B9-               <1>  mov r9, %4
    60 0000169E [2051220000000000]  <1>
    61 000016A6 6A00                <1>  push %5
    62 000016A8 4883EC20            <1>  sub rsp, 32
    63 000016AC E8(00000000)        <1>  call WriteFile
    64 000016B1 4883C428            <1>  add rsp, 32 + 8
   876                                      multipop rcx, rdx, r8, r9, rdi, rsi, r11
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 000016B5 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 000016B7 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000016B8 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000016B9 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 000016BB 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 000016BD 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000016BE 59                  <2>  pop %1
    87                              <1> 
   877                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 000016BF 4D01C8              <1>  add r8, r9
    15 000016C2 49FFC0              <1>  inc r8
    16 000016C5 48FFC7              <1>  inc rdi
    17 000016C8 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000016CB 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000016D2 0F8D2E030000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000016D8 E977F1FFFF          <1>  jmp .read_token_loop
   878                                  .endif_if_operator_is_greater:
   879                                  
   880                                  .endif_is_second_if_condition_operand:
   881                                      ; jg .error
   882                                  
   883                                      ; multipush r8, r9, rdi
   884                                      ; WriteFile([hndDestFile], r10, r9, dwBytesWritten, 0)
   885                                      ; multipop r8, r9, rdi
   886                                      ; end of temporary
   887                                  
   888                                  .advance_token:
   889                                      ; advance token start and reset token length
   890                                      _reset_counters_
    11                              <1> 
    12                              <1> 
    13                              <1> 
    14 000016DD 4D01C8              <1>  add r8, r9
    15 000016E0 49FFC0              <1>  inc r8
    16 000016E3 48FFC7              <1>  inc rdi
    17 000016E6 4D31C9              <1>  xor r9, r9
    18                              <1> 
    19 000016E9 4C3B05(1C512200)    <1>  cmp r8, [dwBytesRead]
    20 000016F0 0F8D10030000        <1>  jge .source_code_parsed
    21                              <1> 
    22 000016F6 E959F1FFFF          <1>  jmp .read_token_loop
   891                                  
   892                                  .asm_literal_start:
   893                                      ; iterate until we find another '0x40'
   894 000016FB 48FFC7                      inc rdi
   895 000016FE 57                          push rdi
   896 000016FF 4D31F6                      xor r14, r14 ; store length of asm code
   897                                  
   898                                  .asm_literal_loop:
   899 00001702 803F60                      cmp byte [rdi], chAsmStart
   900 00001705 7408                        je .asm_literal_end
   901 00001707 49FFC6                      inc r14
   902 0000170A 48FFC7                      inc rdi
   903 0000170D EBF3                        jmp .asm_literal_loop
   904                                  
   905                                  .asm_literal_end:
   906 0000170F 48FFC7                      inc rdi ; move offset past trailing '0x40'
   907 00001712 415A                        pop r10 ; restore start of asm code from rdi to r10
   908 00001714 4D01F0                      add r8, r14
   909 00001717 4983C002                    add r8, 2 
   910                                  
   911                                      multipush r8, r9, r10, rdi 
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 0000171B 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 0000171D 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 0000171F 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001721 57                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   912                                      WriteFile([hndDestFile], r10, r14, dwBytesWritten, 0)
    57 00001722 488B0D(14512200)    <1>  mov rcx, %1
    58 00001729 4C89D2              <1>  mov rdx, %2
    59 0000172C 4D89F0              <1>  mov r8, %3
    60 0000172F 49B9-               <1>  mov r9, %4
    60 00001731 [2051220000000000]  <1>
    61 00001739 6A00                <1>  push %5
    62 0000173B 4883EC20            <1>  sub rsp, 32
    63 0000173F E8(00000000)        <1>  call WriteFile
    64 00001744 4883C428            <1>  add rsp, 32 + 8
   913                                      multipop r8, r9, r10, rdi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001748 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001749 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000174B 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000174D 4158                <2>  pop %1
    87                              <1> 
   914                                  
   915                                      multipush rax, rbx, rcx, rdx, r10, r14
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 0000174F 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001750 53                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001751 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001752 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001753 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001755 4156                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   916 00001757 49FFCA                      dec r10
   917 0000175A 4153                        push r11
   918 0000175C 49BB-                       mov r11, szSourceCode
   918 0000175E [C008000000000000] 
   919 00001766 4D29DA                      sub r10, r11
   920 00001769 415B                        pop r11
   921 0000176B 4983C601                    add r14, 1
   922 0000176F 48BB-                       mov rbx, tokenList         ; load pointer to list
   922 00001771 [0811200000000000] 
   923 00001779 8B05(08512200)              mov eax, [dwTokenCount]    ; load token count
   924 0000177F BA12000000                  mov rdx, Token.size        ; and size
   925 00001784 48F7E2                      mul rdx                    ; calculate offset
   926 00001787 4801C3                      add rbx, rax               ; add offset to pointer
   927 0000178A 66C7031100                  mov [rbx + Token.TokenType], word OperandAsmLiteral ; token type
   928 0000178F 4C895302                    mov [rbx + Token.TokenStart], r10 ; token start
   929 00001793 4C89730A                    mov [rbx + Token.TokenLength], r14 ; token start
   930 00001797 FF05(08512200)              inc dword [dwTokenCount]
   931                                      multipop rax, rbx, rcx, rdx, r10, r14
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 0000179D 415E                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000179F 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 000017A1 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000017A2 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000017A3 5B                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000017A4 58                  <2>  pop %1
    87                              <1> 
   932                                  
   933 000017A5 E9AAF0FFFF                  jmp .read_token_loop
   934                                  
   935                                  .string_literal_start:
   936 000017AA 48FFC7                      inc rdi
   937 000017AD 57                          push rdi
   938 000017AE 4D31F6                      xor r14, r14 ; store length of string literal
   939                                  
   940                                  .string_literal_loop:
   941 000017B1 803F22                      cmp byte [rdi], chDoubleQuote
   942 000017B4 7408                        je .string_literal_end
   943 000017B6 49FFC6                      inc r14
   944 000017B9 48FFC7                      inc rdi
   945 000017BC EBF3                        jmp .string_literal_loop
   946                                  
   947                                  .string_literal_end:
   948 000017BE 48FFC7                      inc rdi ; move offset past trailing '0x22'
   949 000017C1 415A                        pop r10 ; restore start of string literal from rdi to r10
   950 000017C3 4D01F0                      add r8, r14
   951 000017C6 4983C002                    add r8, 2 
   952                                  
   953                                      ; add token to token list
   954                                      multipush rax, rbx, rcx, rdx, r10, r14
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 000017CA 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 000017CB 53                  <2>  push %1
    73                              <2>  %rotate 1
    72 000017CC 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 000017CD 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 000017CE 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 000017D0 4156                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   955 000017D2 49FFCA                      dec r10
   956 000017D5 4153                        push r11
   957 000017D7 49BB-                       mov r11, szSourceCode
   957 000017D9 [C008000000000000] 
   958 000017E1 4D29DA                      sub r10, r11
   959 000017E4 415B                        pop r11
   960 000017E6 4983C602                    add r14, 2
   961 000017EA 48BB-                       mov rbx, tokenList         ; load pointer to list
   961 000017EC [0811200000000000] 
   962 000017F4 8B05(08512200)              mov eax, [dwTokenCount]    ; load token count
   963 000017FA BA12000000                  mov rdx, Token.size        ; and size
   964 000017FF 48F7E2                      mul rdx                    ; calculate offset
   965 00001802 4801C3                      add rbx, rax               ; add offset to pointer
   966 00001805 66C7031000                  mov [rbx + Token.TokenType], word OperandStringLiteral ; token type
   967 0000180A 4C895302                    mov [rbx + Token.TokenStart], r10 ; token start
   968 0000180E 4C89730A                    mov [rbx + Token.TokenLength], r14 ; token start
   969 00001812 FF05(08512200)              inc dword [dwTokenCount]
   970                                      multipop rax, rbx, rcx, rdx, r10, r14
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001818 415E                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000181A 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 0000181C 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000181D 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000181E 5B                  <2>  pop %1
    84                              <2>  %rotate -1
    85 0000181F 58                  <2>  pop %1
    87                              <1> 
   971                                  
   972                                      ; write to global constants
   973                                      multipush rax, rcx, rdi, rsi
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001820 50                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001821 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001822 57                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001823 56                  <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
   974                                      ; Add leading quotes
   975 00001824 488B05(9C532300)            mov rax, [ptrGlobalConstants]
   976 0000182B C60022                      mov byte [rax], chDoubleQuote
   977 0000182E 488305(94532300)01          add qword [qwGlobalConstantsLength], 1
   978 00001836 488305(9C532300)01          add qword [ptrGlobalConstants], 1
   979                                      ; Write string literal
   980                                      memcpy([ptrGlobalConstants], r10, r14)
   112 0000183E 488B05(9C532300)    <1>  mov rax, %1
   113 00001845 4C89F1              <1>  mov rcx, %3
   114 00001848 488B3D(9C532300)    <1>  mov rdi, %1
   115 0000184F 4C89D6              <1>  mov rsi, %2
   116 00001852 F3A4                <1>  rep movsb
   981 00001854 4C0135(94532300)            add qword [qwGlobalConstantsLength], r14
   982 0000185B 4C0135(9C532300)            add qword [ptrGlobalConstants], r14
   983                                      ; Add trailing quotes
   984 00001862 488B05(9C532300)            mov rax, [ptrGlobalConstants]
   985 00001869 C60022                      mov byte [rax], chDoubleQuote
   986 0000186C 488305(94532300)01          add qword [qwGlobalConstantsLength], 1
   987 00001874 488305(9C532300)01          add qword [ptrGlobalConstants], 1
   988                                      ; ; Add trailing null terminator
   989                                      ; memcpy([ptrGlobalConstants], szAsmStringLiteralNullTerminator, szAsmStringLiteralNullTerminator.length)
   990                                      ; add qword [qwGlobalConstantsLength], szAsmStringLiteralNullTerminator.length
   991                                      ; add qword [ptrGlobalConstants], szAsmStringLiteralNullTerminator.length
   992                                      ; add newline
   993                                      memcpy([ptrGlobalConstants], endline, 2)
   112 0000187C 488B05(9C532300)    <1>  mov rax, %1
   113 00001883 B902000000          <1>  mov rcx, %3
   114 00001888 488B3D(9C532300)    <1>  mov rdi, %1
   115 0000188F 48BE-               <1>  mov rsi, %2
   115 00001891 [3B00000000000000]  <1>
   116 00001899 F3A4                <1>  rep movsb
   994 0000189B 488305(94532300)02          add qword [qwGlobalConstantsLength], 2
   995 000018A3 488305(9C532300)02          add qword [ptrGlobalConstants], 2
   996                                  
   997                                      ; write length of string literal
   998                                      ; write a szTab
   999                                      memcpy([ptrGlobalConstants], szTab, szTab.length)
   112 000018AB 488B05(9C532300)    <1>  mov rax, %1
   113 000018B2 B904000000          <1>  mov rcx, %3
   114 000018B7 488B3D(9C532300)    <1>  mov rdi, %1
   115 000018BE 48BE-               <1>  mov rsi, %2
   115 000018C0 [DF01000000000000]  <1>
   116 000018C8 F3A4                <1>  rep movsb
  1000 000018CA 488305(94532300)04          add qword [qwGlobalConstantsLength], szTab.length
  1001 000018D2 488305(9C532300)04          add qword [ptrGlobalConstants], szTab.length
  1002                                      ; write last label
  1003                                      memcpy([ptrGlobalConstants], szLastLabel, [szLastLabelLength])
   112 000018DA 488B05(9C532300)    <1>  mov rax, %1
   113 000018E1 488B0D(24542300)    <1>  mov rcx, %3
   114 000018E8 488B3D(9C532300)    <1>  mov rdi, %1
   115 000018EF 48BE-               <1>  mov rsi, %2
   115 000018F1 [A453230000000000]  <1>
   116 000018F9 F3A4                <1>  rep movsb
  1004 000018FB 488B05(24542300)            mov rax, [szLastLabelLength]
  1005 00001902 480105(94532300)            add qword [qwGlobalConstantsLength], rax
  1006 00001909 480105(9C532300)            add qword [ptrGlobalConstants], rax
  1007                                      ; write suffix
  1008                                      memcpy([ptrGlobalConstants], szAsmDataStringSuffix, szAsmDataStringSuffix.length)
   112 00001910 488B05(9C532300)    <1>  mov rax, %1
   113 00001917 B907000000          <1>  mov rcx, %3
   114 0000191C 488B3D(9C532300)    <1>  mov rdi, %1
   115 00001923 48BE-               <1>  mov rsi, %2
   115 00001925 [F701000000000000]  <1>
   116 0000192D F3A4                <1>  rep movsb
  1009 0000192F 488305(94532300)07          add qword [qwGlobalConstantsLength], szAsmDataStringSuffix.length
  1010 00001937 488305(9C532300)07          add qword [ptrGlobalConstants], szAsmDataStringSuffix.length
  1011                                      ; write type (aka "equ $ - ")
  1012                                      memcpy([ptrGlobalConstants], szAsmDataStringLengthType, szAsmDataStringLengthType.length)
   112 0000193F 488B05(9C532300)    <1>  mov rax, %1
   113 00001946 B909000000          <1>  mov rcx, %3
   114 0000194B 488B3D(9C532300)    <1>  mov rdi, %1
   115 00001952 48BE-               <1>  mov rsi, %2
   115 00001954 [EE01000000000000]  <1>
   116 0000195C F3A4                <1>  rep movsb
  1013 0000195E 488305(94532300)09          add qword [qwGlobalConstantsLength], szAsmDataStringLengthType.length
  1014 00001966 488305(9C532300)09          add qword [ptrGlobalConstants], szAsmDataStringLengthType.length
  1015                                      ; write last label
  1016                                      memcpy([ptrGlobalConstants], szLastLabel, [szLastLabelLength])
   112 0000196E 488B05(9C532300)    <1>  mov rax, %1
   113 00001975 488B0D(24542300)    <1>  mov rcx, %3
   114 0000197C 488B3D(9C532300)    <1>  mov rdi, %1
   115 00001983 48BE-               <1>  mov rsi, %2
   115 00001985 [A453230000000000]  <1>
   116 0000198D F3A4                <1>  rep movsb
  1017 0000198F 488B05(24542300)            mov rax, [szLastLabelLength]
  1018 00001996 480105(94532300)            add qword [qwGlobalConstantsLength], rax
  1019 0000199D 480105(9C532300)            add qword [ptrGlobalConstants], rax
  1020                                      ; write newline
  1021                                      memcpy([ptrGlobalConstants], endline, 2)
   112 000019A4 488B05(9C532300)    <1>  mov rax, %1
   113 000019AB B902000000          <1>  mov rcx, %3
   114 000019B0 488B3D(9C532300)    <1>  mov rdi, %1
   115 000019B7 48BE-               <1>  mov rsi, %2
   115 000019B9 [3B00000000000000]  <1>
   116 000019C1 F3A4                <1>  rep movsb
  1022 000019C3 488305(94532300)02          add qword [qwGlobalConstantsLength], 2
  1023 000019CB 488305(9C532300)02          add qword [ptrGlobalConstants], 2
  1024                                      multipop rax, rcx, rdi, rsi
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 000019D3 5E                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000019D4 5F                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000019D5 59                  <2>  pop %1
    84                              <2>  %rotate -1
    85 000019D6 58                  <2>  pop %1
    87                              <1> 
  1025                                      ; multipush r8, r9, rdi
  1026                                      ; WriteFile([hndDestFile], r10, r14, dwBytesWritten, 0)
  1027                                  
  1028                                      ; multipop r8, r9, rdi
  1029                                  
  1030 000019D7 E978EEFFFF                  jmp .read_token_loop
  1031                                  .error:
  1032                                      WriteConsoleA([hStdOut], szGenericError, szGenericError.length, 0)
   207                              <1> 
   208                              <1> 
   209 000019DC 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 000019E0 488B0D(08000000)    <1>  mov rcx, %1
   212 000019E7 48BA-               <1>  mov rdx, %2
   212 000019E9 [C601000000000000]  <1>
   213 000019F1 41B80E000000        <1>  mov r8, %3
   214 000019F7 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 000019FD E8(00000000)        <1>  call WriteConsoleA
   217 00001A02 4883C420            <1>  add rsp, 32
  1033                                  
  1034                                  .source_code_parsed:
  1035                                  %define NextToken() nextToken
  1036                                  %macro nextToken 0
  1037                                      add rdx, Token.size ; jump to next token
  1038                                      inc rbx
  1039                                      mov [tokenIndex], rbx
  1040                                      jmp .while_counter_less_than_token_count
  1041                                  %endmacro
  1042                                  
  1043                                  %define PushBlockToken(tokenType) pushBlockToken tokenType
  1044                                  %macro pushBlockToken 1
  1045                                      multipush rax, rbx, rdx
  1046                                      mov rbx, blockStack
  1047                                      mov rax, [blockCount]
  1048                                      mov rdx, Block.size 
  1049                                      mul rdx
  1050                                      add rbx, rax                          ; rbx points to just after the top of the stack
  1051                                  %ifndef labele
  1052                                  %define labele 0
  1053                                  .e:    
  1054                                  %endif
  1055                                      mov rax, [tokenIndex]
  1056                                      mov [rbx + Block.TokenIndex], rax
  1057                                      ; this is a bug, current scope needs to be passed as arg
  1058                                      mov rax, [wScopedBlockCurrentId]
  1059                                      mov [rbx + Block.BlockId], rax
  1060                                      mov [rbx + Block.TokenType], word %1  ; push token type
  1061                                      inc qword [blockCount]                ; increment block count
  1062                                      multipop rax, rbx, rdx
  1063                                  %endmacro
  1064                                  
  1065                                  %define PopBlockToken() popBlockToken
  1066                                  %macro popBlockToken 0
  1067                                      multipush rbx, rdx
  1068                                      mov rbx, blockStack
  1069                                      dec qword [blockCount]   ; decrement block count
  1070                                      mov rax, [blockCount]
  1071                                      mov rdx, Block.size 
  1072                                      mul rdx
  1073                                      add rax, rbx             ; rbx points to top of the stack
  1074                                      multipop rbx, rdx
  1075                                  %endmacro
  1076                                  
  1077                                  %define PeekBlockToken() peekBlockToken
  1078                                  %macro peekBlockToken 0
  1079                                      multipush rbx, rdx
  1080                                      mov rbx, blockStack
  1081                                      mov rax, [blockCount]
  1082                                      mov rdx, Block.size 
  1083                                      mul rdx
  1084                                      add rax, rbx
  1085                                      sub rax, Block.size ; rbx points to top of the stack
  1086                                      multipop rbx, rdx
  1087                                  %endmacro
  1088                                  
  1089                                  ; this will only decrement the block count
  1090                                  %define QuickPopBlockToken() dec qword [blockCount]
  1091                                  
  1092                                      WriteFile([hndDestFile], szHorizontalLine, szHorizontalLine.length, dwBytesWritten, 0)
    57 00001A06 488B0D(14512200)    <1>  mov rcx, %1
    58 00001A0D 48BA-               <1>  mov rdx, %2
    58 00001A0F [3202000000000000]  <1>
    59 00001A17 41B851000000        <1>  mov r8, %3
    60 00001A1D 49B9-               <1>  mov r9, %4
    60 00001A1F [2051220000000000]  <1>
    61 00001A27 6A00                <1>  push %5
    62 00001A29 4883EC20            <1>  sub rsp, 32
    63 00001A2D E8(00000000)        <1>  call WriteFile
    64 00001A32 4883C428            <1>  add rsp, 32 + 8
  1093                                   
  1094                                  
  1095                                      ; iterate over tokens
  1096 00001A36 55                          push rbp
  1097 00001A37 4889E5                      mov rbp, rsp
  1098 00001A3A 4883EC10                    sub rsp, 0x10 ; reserve space on the stack for the token index
  1099                                  
  1100 00001A3E 4831DB                      xor rbx, rbx ; counter
  1101 00001A41 48BA-                       mov rdx, tokenList
  1101 00001A43 [0811200000000000] 
  1102                                      
  1103                                      ; initialize counters
  1104 00001A4B 41BA00000000                mov r10, 0
  1105 00001A51 4C8915(1A000000)            mov [wScopedBlockCurrentId], r10
  1106                                  
  1107                                  %define currentToken.Type word [rdx + Token.TokenType]
  1108                                  %define currentToken.Start dword [rdx + Token.TokenStart]
  1109                                  %define currentToken.Length dword [rdx + Token.TokenLength]
  1110                                  
  1111                                  .while_counter_less_than_token_count:
  1112 00001A58 488B1D(00000000)            mov rbx, [tokenIndex]
  1113                                      ; printf([hStdOut], cStrHexFormatNL, rbx)
  1114 00001A5F 3B1D(08512200)              cmp ebx, [dwTokenCount]
  1115 00001A65 0F8D41050000                jge .end_counter_less_than_token_count
  1116                                  
  1117                                  .if_2:
  1118 00001A6B 66833A11                    cmp currentToken.Type, defOperandAsmLiteral
  1119 00001A6F 7565                        jne .endif_2
  1120                                  .then_2:
  1121                                  
  1122                                          PushCallerSavedRegs()
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001A71 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001A72 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001A73 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00001A75 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00001A77 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001A79 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
  1123                                    
  1124                                          ; write asm code
  1125 00001A7B 448B5202                        mov r10d, currentToken.Start
  1126 00001A7F 49BB-                           mov r11, szSourceCode
  1126 00001A81 [C008000000000000] 
  1127 00001A89 4D01DA                          add r10, r11
  1128 00001A8C 49FFC2                          inc r10 ; skip leading '0x40'
  1129 00001A8F 448B5A0A                        mov r11d, currentToken.Length
  1130 00001A93 49FFCB                          dec r11 ; skip trailing '0x40'
  1131                                  
  1132                                          WriteFile([hndDestFile], r10, r11, dwBytesWritten)
    57 00001A96 488B0D(14512200)    <1>  mov rcx, %1
    58 00001A9D 4C89D2              <1>  mov rdx, %2
    59 00001AA0 4D89D8              <1>  mov r8, %3
    60 00001AA3 49B9-               <1>  mov r9, %4
    60 00001AA5 [2051220000000000]  <1>
    61 00001AAD 6A00                <1>  push %5
    62 00001AAF 4883EC20            <1>  sub rsp, 32
    63 00001AB3 E8(00000000)        <1>  call WriteFile
    64 00001AB8 4883C428            <1>  add rsp, 32 + 8
  1133                                  
  1134                                          PopCallerSavedRegs()
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001ABC 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001ABE 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001AC0 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001AC2 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001AC4 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001AC5 59                  <2>  pop %1
    87                              <1> 
  1135                                          NextToken()
  1037 00001AC6 4883C212            <1>  add rdx, Token.size
  1038 00001ACA 48FFC3              <1>  inc rbx
  1039 00001ACD 48891D(00000000)    <1>  mov [tokenIndex], rbx
  1040 00001AD4 EB82                <1>  jmp .while_counter_less_than_token_count
  1136                                  .endif_2:
  1137                                   ; keyword 'if'
  1138                                  .if_3:
  1139 00001AD6 66813A0001                  cmp currentToken.Type, defKeywordIf
  1140 00001ADB 0F85C7000000                jne .endif_3
  1141                                  .then_3:
  1142                                  
  1143                                          PushCallerSavedRegs()
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001AE1 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001AE2 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001AE3 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00001AE5 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00001AE7 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001AE9 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
  1144                                          sprintf(ptrBuffer64, cStrIfLabelFormat, [wScopedBlockCurrentId])
   547 00001AEB 4883EC20            <1>  sub rsp, 0x20
   548 00001AEF 4C8B05(1A000000)    <1>  mov r8, %3
   549 00001AF6 48BA-               <1>  mov rdx, %2
   549 00001AF8 [CA00000000000000]  <1>
   550 00001B00 48B9-               <1>  mov rcx, %1
   550 00001B02 [C008100000000000]  <1>
   551 00001B0A E8A9E7FFFF          <1>  call sprintf
   552 00001B0F 4883C420            <1>  add rsp, 0x20
  1145                                          WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
    57 00001B13 488B0D(14512200)    <1>  mov rcx, %1
    58 00001B1A 48BA-               <1>  mov rdx, %2
    58 00001B1C [C008100000000000]  <1>
    59 00001B24 4989C0              <1>  mov r8, %3
    60 00001B27 49B9-               <1>  mov r9, %4
    60 00001B29 [2051220000000000]  <1>
    61 00001B31 6A00                <1>  push %5
    62 00001B33 4883EC20            <1>  sub rsp, 32
    63 00001B37 E8(00000000)        <1>  call WriteFile
    64 00001B3C 4883C428            <1>  add rsp, 32 + 8
  1146                                  
  1147                                          PushBlockToken(defKeywordIf)
  1045                              <1>  multipush rax, rbx, rdx
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001B40 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001B41 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001B42 52                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
  1046 00001B43 48BB-               <1>  mov rbx, blockStack
  1046 00001B45 [0009200000000000]  <1>
  1047 00001B4D 488B05(00112000)    <1>  mov rax, [blockCount]
  1048 00001B54 BA08000000          <1>  mov rdx, Block.size
  1049 00001B59 48F7E2              <1>  mul rdx
  1050 00001B5C 4801C3              <1>  add rbx, rax
  1051                              <1> %ifndef labele
  1052                              <1> %define labele 0
  1053                              <1> .e:
  1054                              <1> %endif
  1055 00001B5F 488B05(00000000)    <1>  mov rax, [tokenIndex]
  1056 00001B66 488903              <1>  mov [rbx + Block.TokenIndex], rax
  1057                              <1> 
  1058 00001B69 488B05(1A000000)    <1>  mov rax, [wScopedBlockCurrentId]
  1059 00001B70 48894304            <1>  mov [rbx + Block.BlockId], rax
  1060 00001B74 66C743060001        <1>  mov [rbx + Block.TokenType], word %1
  1061 00001B7A 48FF05(00112000)    <1>  inc qword [blockCount]
  1062                              <1>  multipop rax, rbx, rdx
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001B81 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001B82 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001B83 58                  <3>  pop %1
    87                              <2> 
  1148                                          
  1149 00001B84 66FF05(1A000000)                inc word [wScopedBlockCurrentId]
  1150                                          PopCallerSavedRegs()
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001B8B 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001B8D 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001B8F 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001B91 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001B93 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001B94 59                  <2>  pop %1
    87                              <1> 
  1151                                          NextToken()
  1037 00001B95 4883C212            <1>  add rdx, Token.size
  1038 00001B99 48FFC3              <1>  inc rbx
  1039 00001B9C 48891D(00000000)    <1>  mov [tokenIndex], rbx
  1040 00001BA3 E9B0FEFFFF          <1>  jmp .while_counter_less_than_token_count
  1152                                  .endif_3:
  1153                                  
  1154                                  
  1155                                      
  1156                                      .if_token_is_then_0:
  1157 00001BA8 66813A0101                      cmp currentToken.Type, word KeywordThen
  1158 00001BAD 0F8564010000                    jne .endif_token_is_then_0
  1159                                      .then_token_is_then_0:
  1160                                          PushCallerSavedRegs()
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001BB3 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001BB4 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001BB5 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00001BB7 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00001BB9 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001BBB 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
  1161                                          PeekBlockToken()
  1079                              <1>  multipush rbx, rdx
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001BBD 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001BBE 52                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
  1080 00001BBF 48BB-               <1>  mov rbx, blockStack
  1080 00001BC1 [0009200000000000]  <1>
  1081 00001BC9 488B05(00112000)    <1>  mov rax, [blockCount]
  1082 00001BD0 BA08000000          <1>  mov rdx, Block.size
  1083 00001BD5 48F7E2              <1>  mul rdx
  1084 00001BD8 4801D8              <1>  add rax, rbx
  1085 00001BDB 4883E808            <1>  sub rax, Block.size
  1086                              <1>  multipop rbx, rdx
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001BDF 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001BE0 5B                  <3>  pop %1
    87                              <2> 
  1162 00001BE1 488B5806                        mov rbx, [rax + Block.TokenType]
  1163                                  .if_4:
  1164 00001BE5 4881FB00010000              cmp rbx, KeywordIf
  1165 00001BEC 7473                        je .endif_4
  1166                                  .then_4:
  1167                                  
  1168                                              printf([hStdOut], cStrErrorThenNotAfterIf, szSourceFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001BEE 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001BEF 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF0 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF1 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF2 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF4 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF6 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001BF8 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001BFA 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 00001BFC 4883EC20            <1>  sub rsp, 0x20
   559 00001C00 49B8-               <1>  mov r8, %3
   559 00001C02 [9451220000000000]  <1>
   560 00001C0A 48BA-               <1>  mov rdx, %2
   560 00001C0C [F300000000000000]  <1>
   561 00001C14 48B9-               <1>  mov rcx, printfBuffer
   561 00001C16 [4008000000000000]  <1>
   562 00001C1E E895E6FFFF          <1>  call sprintf
   563 00001C23 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001C27 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001C2B 488B0D(08000000)    <2>  mov rcx, %1
   212 00001C32 48BA-               <2>  mov rdx, %2
   212 00001C34 [4008000000000000]  <2>
   213 00001C3C 4989C0              <2>  mov r8, %3
   214 00001C3F 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00001C45 E8(00000000)        <2>  call WriteConsoleA
   217 00001C4A 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001C4E 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C50 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C52 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C54 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C56 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C58 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C59 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C5A 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001C5B 58                  <3>  pop %1
    87                              <2> 
  1169 00001C5C E9CA040000                          jmp .exit
  1170                                  .endif_4:
  1171                                  
  1172                                          
  1173                                          ; investigate why then has then_16777216
  1174                                          ; todo - construct condition
  1175                                          
  1176 00001C61 668B5804                        mov bx, word [rax + Block.BlockId]
  1177                                          sprintf(ptrBuffer64, cStrThenLabelFormat, rbx)
   547 00001C65 4883EC20            <1>  sub rsp, 0x20
   548 00001C69 4989D8              <1>  mov r8, %3
   549 00001C6C 48BA-               <1>  mov rdx, %2
   549 00001C6E [D600000000000000]  <1>
   550 00001C76 48B9-               <1>  mov rcx, %1
   550 00001C78 [C008100000000000]  <1>
   551 00001C80 E833E6FFFF          <1>  call sprintf
   552 00001C85 4883C420            <1>  add rsp, 0x20
  1178                                          WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
    57 00001C89 488B0D(14512200)    <1>  mov rcx, %1
    58 00001C90 48BA-               <1>  mov rdx, %2
    58 00001C92 [C008100000000000]  <1>
    59 00001C9A 4989C0              <1>  mov r8, %3
    60 00001C9D 49B9-               <1>  mov r9, %4
    60 00001C9F [2051220000000000]  <1>
    61 00001CA7 6A00                <1>  push %5
    62 00001CA9 4883EC20            <1>  sub rsp, 32
    63 00001CAD E8(00000000)        <1>  call WriteFile
    64 00001CB2 4883C428            <1>  add rsp, 32 + 8
  1179                                  .t:
  1180                                          PushBlockToken(KeywordThen)
  1045                              <1>  multipush rax, rbx, rdx
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001CB6 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001CB7 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001CB8 52                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
  1046 00001CB9 48BB-               <1>  mov rbx, blockStack
  1046 00001CBB [0009200000000000]  <1>
  1047 00001CC3 488B05(00112000)    <1>  mov rax, [blockCount]
  1048 00001CCA BA08000000          <1>  mov rdx, Block.size
  1049 00001CCF 48F7E2              <1>  mul rdx
  1050 00001CD2 4801C3              <1>  add rbx, rax
  1051                              <1> %ifndef labele
  1052                              <1> %define labele 0
  1053                              <1> .e:
  1054                              <1> %endif
  1055 00001CD5 488B05(00000000)    <1>  mov rax, [tokenIndex]
  1056 00001CDC 488903              <1>  mov [rbx + Block.TokenIndex], rax
  1057                              <1> 
  1058 00001CDF 488B05(1A000000)    <1>  mov rax, [wScopedBlockCurrentId]
  1059 00001CE6 48894304            <1>  mov [rbx + Block.BlockId], rax
  1060 00001CEA 66C743060101        <1>  mov [rbx + Block.TokenType], word %1
  1061 00001CF0 48FF05(00112000)    <1>  inc qword [blockCount]
  1062                              <1>  multipop rax, rbx, rdx
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001CF7 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001CF8 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001CF9 58                  <3>  pop %1
    87                              <2> 
  1181                                  
  1182                                          PopCallerSavedRegs()
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001CFA 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001CFC 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001CFE 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001D00 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001D02 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001D03 59                  <2>  pop %1
    87                              <1> 
  1183                                          NextToken()
  1037 00001D04 4883C212            <1>  add rdx, Token.size
  1038 00001D08 48FFC3              <1>  inc rbx
  1039 00001D0B 48891D(00000000)    <1>  mov [tokenIndex], rbx
  1040 00001D12 E941FDFFFF          <1>  jmp .while_counter_less_than_token_count
  1184                                      .endif_token_is_then_0:
  1185                                  
  1186                                      
  1187                                      .if_token_is_end_0:
  1188 00001D17 66813A0201                      cmp currentToken.Type, word KeywordEnd
  1189 00001D1C 0F85FF010000                    jne .endif_token_is_end_0
  1190                                      .then_token_is_end_0:
  1191                                          PushCallerSavedRegs()
    70                              <1> 
    71                              <1>  %rep %0
    72                              <1>  push %1
    73                              <1>  %rotate 1
    74                              <1>  %endrep
    72 00001D22 51                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001D23 52                  <2>  push %1
    73                              <2>  %rotate 1
    72 00001D24 4150                <2>  push %1
    73                              <2>  %rotate 1
    72 00001D26 4151                <2>  push %1
    73                              <2>  %rotate 1
    72 00001D28 4152                <2>  push %1
    73                              <2>  %rotate 1
    72 00001D2A 4153                <2>  push %1
    73                              <2>  %rotate 1
    75                              <1> 
  1192                                  
  1193                                          PeekBlockToken()
  1079                              <1>  multipush rbx, rdx
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001D2C 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001D2D 52                  <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
  1080 00001D2E 48BB-               <1>  mov rbx, blockStack
  1080 00001D30 [0009200000000000]  <1>
  1081 00001D38 488B05(00112000)    <1>  mov rax, [blockCount]
  1082 00001D3F BA08000000          <1>  mov rdx, Block.size
  1083 00001D44 48F7E2              <1>  mul rdx
  1084 00001D47 4801D8              <1>  add rax, rbx
  1085 00001D4A 4883E808            <1>  sub rax, Block.size
  1086                              <1>  multipop rbx, rdx
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001D4E 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001D4F 5B                  <3>  pop %1
    87                              <2> 
  1194 00001D50 488B5806                        mov rbx, [rax + Block.TokenType]
  1195                                          ; printf([hStdOut], cStrHexFormatNL, rbx)
  1196                                          
  1197                                  .if_5:
  1198 00001D54 4881FB01010000              cmp rbx, KeywordThen
  1199 00001D5B 7473                        je .endif_5
  1200                                  .then_5:
  1201                                  
  1202                                              printf([hStdOut], cStrErrorEndNotAfterThen, szSourceFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001D5D 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001D5E 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001D5F 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001D60 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001D61 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001D63 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001D65 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001D67 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001D69 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 00001D6B 4883EC20            <1>  sub rsp, 0x20
   559 00001D6F 49B8-               <1>  mov r8, %3
   559 00001D71 [9451220000000000]  <1>
   560 00001D79 48BA-               <1>  mov rdx, %2
   560 00001D7B [2501000000000000]  <1>
   561 00001D83 48B9-               <1>  mov rcx, printfBuffer
   561 00001D85 [4008000000000000]  <1>
   562 00001D8D E826E5FFFF          <1>  call sprintf
   563 00001D92 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001D96 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001D9A 488B0D(08000000)    <2>  mov rcx, %1
   212 00001DA1 48BA-               <2>  mov rdx, %2
   212 00001DA3 [4008000000000000]  <2>
   213 00001DAB 4989C0              <2>  mov r8, %3
   214 00001DAE 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00001DB4 E8(00000000)        <2>  call WriteConsoleA
   217 00001DB9 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001DBD 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DBF 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC1 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC3 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC5 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC7 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC8 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DC9 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001DCA 58                  <3>  pop %1
    87                              <2> 
  1203 00001DCB E95B030000                          jmp .exit
  1204                                  .endif_5:
  1205                                  
  1206                                          ; printf([hStdOut], cStrHexFormatNL, rbx)
  1207 00001DD0 668B5804                        mov bx, word [rax + Block.BlockId]
  1208                                          printf([hStdOut], cStrHexFormatNL, Block.BlockId)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001DD4 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001DD5 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001DD6 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001DD7 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001DD8 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001DDA 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001DDC 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001DDE 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001DE0 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 00001DE2 4883EC20            <1>  sub rsp, 0x20
   559 00001DE6 41B804000000        <1>  mov r8, %3
   560 00001DEC 48BA-               <1>  mov rdx, %2
   560 00001DEE [5D01000000000000]  <1>
   561 00001DF6 48B9-               <1>  mov rcx, printfBuffer
   561 00001DF8 [4008000000000000]  <1>
   562 00001E00 E8B3E4FFFF          <1>  call sprintf
   563 00001E05 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001E09 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001E0D 488B0D(08000000)    <2>  mov rcx, %1
   212 00001E14 48BA-               <2>  mov rdx, %2
   212 00001E16 [4008000000000000]  <2>
   213 00001E1E 4989C0              <2>  mov r8, %3
   214 00001E21 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00001E27 E8(00000000)        <2>  call WriteConsoleA
   217 00001E2C 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001E30 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E32 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E34 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E36 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E38 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E3A 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E3B 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E3C 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E3D 58                  <3>  pop %1
    87                              <2> 
  1209                                          printf([hStdOut], cStrEndLabelFormat, rbx)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001E3E 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001E3F 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001E40 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001E41 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001E42 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001E44 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001E46 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001E48 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001E4A 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 00001E4C 4883EC20            <1>  sub rsp, 0x20
   559 00001E50 4989D8              <1>  mov r8, %3
   560 00001E53 48BA-               <1>  mov rdx, %2
   560 00001E55 [E400000000000000]  <1>
   561 00001E5D 48B9-               <1>  mov rcx, printfBuffer
   561 00001E5F [4008000000000000]  <1>
   562 00001E67 E84CE4FFFF          <1>  call sprintf
   563 00001E6C 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001E70 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001E74 488B0D(08000000)    <2>  mov rcx, %1
   212 00001E7B 48BA-               <2>  mov rdx, %2
   212 00001E7D [4008000000000000]  <2>
   213 00001E85 4989C0              <2>  mov r8, %3
   214 00001E88 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00001E8E E8(00000000)        <2>  call WriteConsoleA
   217 00001E93 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001E97 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E99 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E9B 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E9D 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001E9F 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001EA1 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001EA2 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001EA3 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001EA4 58                  <3>  pop %1
    87                              <2> 
  1210                                          sprintf(ptrBuffer64, cStrEndLabelFormat, rbx)
   547 00001EA5 4883EC20            <1>  sub rsp, 0x20
   548 00001EA9 4989D8              <1>  mov r8, %3
   549 00001EAC 48BA-               <1>  mov rdx, %2
   549 00001EAE [E400000000000000]  <1>
   550 00001EB6 48B9-               <1>  mov rcx, %1
   550 00001EB8 [C008100000000000]  <1>
   551 00001EC0 E8F3E3FFFF          <1>  call sprintf
   552 00001EC5 4883C420            <1>  add rsp, 0x20
  1211                                          WriteFile([hndDestFile], ptrBuffer64, rax, dwBytesWritten)
    57 00001EC9 488B0D(14512200)    <1>  mov rcx, %1
    58 00001ED0 48BA-               <1>  mov rdx, %2
    58 00001ED2 [C008100000000000]  <1>
    59 00001EDA 4989C0              <1>  mov r8, %3
    60 00001EDD 49B9-               <1>  mov r9, %4
    60 00001EDF [2051220000000000]  <1>
    61 00001EE7 6A00                <1>  push %5
    62 00001EE9 4883EC20            <1>  sub rsp, 32
    63 00001EED E8(00000000)        <1>  call WriteFile
    64 00001EF2 4883C428            <1>  add rsp, 32 + 8
  1212 00001EF6 48FF0D(00112000)                QuickPopBlockToken() ; pop 'then'
  1213 00001EFD 48FF0D(00112000)                QuickPopBlockToken() ; pop 'if'
  1214                                  
  1215                                          PopCallerSavedRegs()
    82                              <1> 
    83                              <1>  %rep %0
    84                              <1>  %rotate -1
    85                              <1>  pop %1
    86                              <1>  %endrep
    84                              <2>  %rotate -1
    85 00001F04 415B                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001F06 415A                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001F08 4159                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001F0A 4158                <2>  pop %1
    84                              <2>  %rotate -1
    85 00001F0C 5A                  <2>  pop %1
    84                              <2>  %rotate -1
    85 00001F0D 59                  <2>  pop %1
    87                              <1> 
  1216                                          NextToken()
  1037 00001F0E 4883C212            <1>  add rdx, Token.size
  1038 00001F12 48FFC3              <1>  inc rbx
  1039 00001F15 48891D(00000000)    <1>  mov [tokenIndex], rbx
  1040 00001F1C E937FBFFFF          <1>  jmp .while_counter_less_than_token_count
  1217                                      .endif_token_is_end_0:
  1218                                  
  1219                                  
  1220                                      ; mov r10d, currentToken.Start
  1221                                      ; mov r11, szSourceCode
  1222                                      ; add r10, r11
  1223                                      ; mov r11d, currentToken.Length
  1224                                  
  1225                                      ; WriteFile([hndDestFile], r10, r11, dwBytesWritten)
  1226                                  
  1227 00001F21 66448B12                    mov r10w, currentToken.Type
  1228 00001F25 448B5A02                    mov r11d, currentToken.Start
  1229 00001F29 448B620A                    mov r12d, currentToken.Length
  1230                                  
  1231                                      printf([hStdOut], tformat, r10, r11, r12)
   570                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001F2D 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001F2E 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001F2F 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001F30 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001F31 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001F33 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001F35 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001F37 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001F39 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   571 00001F3B 4154                <1>  push %5
   572 00001F3D 4883EC20            <1>  sub rsp, 0x20
   573 00001F41 4D89D9              <1>  mov r9, %4
   574 00001F44 4D89D0              <1>  mov r8, %3
   575 00001F47 48BA-               <1>  mov rdx, %2
   575 00001F49 [6201000000000000]  <1>
   576 00001F51 48B9-               <1>  mov rcx, printfBuffer
   576 00001F53 [4008000000000000]  <1>
   577 00001F5B E858E3FFFF          <1>  call sprintf
   578 00001F60 4883C428            <1>  add rsp, 0x20 + 8
   579                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001F64 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001F68 488B0D(08000000)    <2>  mov rcx, %1
   212 00001F6F 48BA-               <2>  mov rdx, %2
   212 00001F71 [4008000000000000]  <2>
   213 00001F79 4989C0              <2>  mov r8, %3
   214 00001F7C 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00001F82 E8(00000000)        <2>  call WriteConsoleA
   217 00001F87 4883C420            <2>  add rsp, 32
   580                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 00001F8B 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F8D 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F8F 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F91 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F93 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F95 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F96 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F97 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00001F98 58                  <3>  pop %1
    87                              <2> 
  1232                                  
  1233                                      NextToken()
  1037 00001F99 4883C212            <1>  add rdx, Token.size
  1038 00001F9D 48FFC3              <1>  inc rbx
  1039 00001FA0 48891D(00000000)    <1>  mov [tokenIndex], rbx
  1040 00001FA7 E9ACFAFFFF          <1>  jmp .while_counter_less_than_token_count
  1234                                  .end_counter_less_than_token_count:
  1235                                  
  1236                                  %undef currentToken.Type
  1237                                  %undef currentToken.Start
  1238                                  %undef currentToken.Length
  1239                                  
  1240 00001FAC 5D                          pop rbp
  1241                                  
  1242                                      printf([hStdOut], cStrDoneCompiling, szSourceFile)
   557                              <1>  multipush rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    70                              <2> 
    71                              <2>  %rep %0
    72                              <2>  push %1
    73                              <2>  %rotate 1
    74                              <2>  %endrep
    72 00001FAD 50                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001FAE 53                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001FAF 51                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB0 52                  <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB1 4150                <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB3 4151                <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB5 4152                <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB7 4153                <3>  push %1
    73                              <3>  %rotate 1
    72 00001FB9 4154                <3>  push %1
    73                              <3>  %rotate 1
    75                              <2> 
   558 00001FBB 4883EC20            <1>  sub rsp, 0x20
   559 00001FBF 49B8-               <1>  mov r8, %3
   559 00001FC1 [9451220000000000]  <1>
   560 00001FC9 48BA-               <1>  mov rdx, %2
   560 00001FCB [B800000000000000]  <1>
   561 00001FD3 48B9-               <1>  mov rcx, printfBuffer
   561 00001FD5 [4008000000000000]  <1>
   562 00001FDD E8D6E2FFFF          <1>  call sprintf
   563 00001FE2 4883C420            <1>  add rsp, 0x20
   564                              <1>  WriteConsoleA(%1, printfBuffer, rax, 0)
   207                              <2> 
   208                              <2> 
   209 00001FE6 4883EC20            <2>  sub rsp, 32
   210                              <2> 
   211 00001FEA 488B0D(08000000)    <2>  mov rcx, %1
   212 00001FF1 48BA-               <2>  mov rdx, %2
   212 00001FF3 [4008000000000000]  <2>
   213 00001FFB 4989C0              <2>  mov r8, %3
   214 00001FFE 41B900000000        <2>  mov r9, %4
   215                              <2> 
   216 00002004 E8(00000000)        <2>  call WriteConsoleA
   217 00002009 4883C420            <2>  add rsp, 32
   565                              <1>  multipop rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
    82                              <2> 
    83                              <2>  %rep %0
    84                              <2>  %rotate -1
    85                              <2>  pop %1
    86                              <2>  %endrep
    84                              <3>  %rotate -1
    85 0000200D 415C                <3>  pop %1
    84                              <3>  %rotate -1
    85 0000200F 415B                <3>  pop %1
    84                              <3>  %rotate -1
    85 00002011 415A                <3>  pop %1
    84                              <3>  %rotate -1
    85 00002013 4159                <3>  pop %1
    84                              <3>  %rotate -1
    85 00002015 4158                <3>  pop %1
    84                              <3>  %rotate -1
    85 00002017 5A                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00002018 59                  <3>  pop %1
    84                              <3>  %rotate -1
    85 00002019 5B                  <3>  pop %1
    84                              <3>  %rotate -1
    85 0000201A 58                  <3>  pop %1
    87                              <2> 
  1243                                  
  1244 0000201B E90B010000                  jmp .exit
  1245                                      ; disable for the moment
  1246                                      ; write global constants
  1247                                      ; WriteFile([hndDestFile], endline, 2, dwBytesWritten, 0)
  1248                                      ; WriteFile([hndDestFile], szSectionData, szSectionDataLength, dwBytesWritten, 0)
  1249                                      ; ; strlen(szGlobalConstants)
  1250                                      ; WriteFile([hndDestFile], szGlobalConstants, [qwGlobalConstantsLength], dwBytesWritten, 0)
  1251                                  
  1252                                  .print_tokens:
  1253 00002020 41BF00000000                mov r15, 0
  1254 00002026 49BE-                       mov r14, tokenList
  1254 00002028 [0811200000000000] 
  1255                                  .tloop:
  1256 00002030 490FB70E                    movzx rcx, word [r14 + Token.TokenType]
  1257 00002034 48BA-                       mov rdx, ptrBuffer64
  1257 00002036 [C008100000000000] 
  1258 0000203E 41B810000000                mov r8, 16
  1259 00002044 E8D4E1FFFF                  call itoagb
  1260                                      WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)
   207                              <1> 
   208                              <1> 
   209 00002049 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 0000204D 488B0D(08000000)    <1>  mov rcx, %1
   212 00002054 48BA-               <1>  mov rdx, %2
   212 00002056 [C008100000000000]  <1>
   213 0000205E 4989C0              <1>  mov r8, %3
   214 00002061 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 00002067 E8(00000000)        <1>  call WriteConsoleA
   217 0000206C 4883C420            <1>  add rsp, 32
  1261                                  
  1262 00002070 48B9-                       mov rcx, ptrBuffer64
  1262 00002072 [C008100000000000] 
  1263 0000207A 48BA-                       mov rdx, cStrPrintTokenFormat
  1263 0000207C [4C00000000000000] 
  1264 00002084 4D8B4602                    mov r8, [r14 + Token.TokenStart]
  1265 00002088 4D8B4E0A                    mov r9, [r14 + Token.TokenLength]
  1266 0000208C 4156                        push r14
  1267 0000208E 49BD-                       mov r13, szSourceCode
  1267 00002090 [C008000000000000] 
  1268 00002098 4D01C5                      add r13, r8
  1269 0000209B E818E2FFFF                  call sprintf
  1270 000020A0 4151                        push r9
  1271                                      WriteConsoleA([hStdOut], ptrBuffer64, rax, 0)
   207                              <1> 
   208                              <1> 
   209 000020A2 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 000020A6 488B0D(08000000)    <1>  mov rcx, %1
   212 000020AD 48BA-               <1>  mov rdx, %2
   212 000020AF [C008100000000000]  <1>
   213 000020B7 4989C0              <1>  mov r8, %3
   214 000020BA 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 000020C0 E8(00000000)        <1>  call WriteConsoleA
   217 000020C5 4883C420            <1>  add rsp, 32
  1272 000020C9 4159                        pop r9
  1273                                      WriteConsoleA([hStdOut], r13, r9, 0)
   207                              <1> 
   208                              <1> 
   209 000020CB 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 000020CF 488B0D(08000000)    <1>  mov rcx, %1
   212 000020D6 4C89EA              <1>  mov rdx, %2
   213 000020D9 4D89C8              <1>  mov r8, %3
   214 000020DC 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 000020E2 E8(00000000)        <1>  call WriteConsoleA
   217 000020E7 4883C420            <1>  add rsp, 32
  1274                                      WriteConsoleA([hStdOut], endline, 2, 0)
   207                              <1> 
   208                              <1> 
   209 000020EB 4883EC20            <1>  sub rsp, 32
   210                              <1> 
   211 000020EF 488B0D(08000000)    <1>  mov rcx, %1
   212 000020F6 48BA-               <1>  mov rdx, %2
   212 000020F8 [3B00000000000000]  <1>
   213 00002100 41B802000000        <1>  mov r8, %3
   214 00002106 41B900000000        <1>  mov r9, %4
   215                              <1> 
   216 0000210C E8(00000000)        <1>  call WriteConsoleA
   217 00002111 4883C420            <1>  add rsp, 32
  1275 00002115 415E                        pop r14
  1276                                  
  1277                                      ; print token type
  1278                                  
  1279                                  
  1280 00002117 49FFC7                      inc r15
  1281 0000211A 4983C612                    add r14, Token.size
  1282 0000211E 443B3D(08512200)            cmp r15d, [dwTokenCount]
  1283 00002125 0F8C05FFFFFF                jl .tloop
  1284                                  
  1285                                  .exit:
  1286                                      ExitProcess(0)
   222                              <1> 
   223                              <1> 
   224 0000212B 4883EC20            <1>  sub rsp, 32
   225 0000212F B900000000          <1>  mov rcx, %1
   226 00002134 E8(00000000)        <1>  call ExitProcess
   227 00002139 4883C420            <1>  add rsp, 32
  1287                                  section .data
  1288 00000188 4572726F72206F7065-         szFileOpenError db "Error opening file. Error code:"
  1288 00000191 6E696E672066696C65-
  1288 0000019A 2E204572726F722063-
  1288 000001A3 6F64653A           
  1289                                      szFileOpenError.length equ $ - szFileOpenError
  1290 000001A7 4572726F7220726561-         szFileReadError db "Error reading file. Error code:"
  1290 000001B0 64696E672066696C65-
  1290 000001B9 2E204572726F722063-
  1290 000001C2 6F64653A           
  1291                                      szFileReadError.length equ $ - szFileReadError
  1292 000001C6 47656E657269632065-         szGenericError db "Generic error."
  1292 000001CF 72726F722E         
  1293                                      szGenericError.length equ $ - szGenericError
  1294 000001D4 2E737472617461              szStrataFileExtension db ".strata"
  1295                                      szStrataFileExtension.length equ $ - szStrataFileExtension
  1296 000001DB 2E61736D                    szAsmFileExtension db ".asm"
  1297                                      szAsmFileExtension.length equ $ - szAsmFileExtension
  1298 000001DF 20202020                    szTab db "    "
  1299                                      szTab.length equ $ - szTab
  1300 000001E3 636D7020                    szAsmCmp db "cmp "
  1301                                      szAsmCmp.length equ $ - szAsmCmp
  1302 000001E7 20646220                    szAsmDataStringType db " db "
  1303                                      szAsmDataStringType.length equ $ - szAsmDataStringType
  1304 000001EB 2C2030                      szAsmStringLiteralNullTerminator db ", 0"
  1305                                      szAsmStringLiteralNullTerminator.length equ $ - szAsmStringLiteralNullTerminator
  1306 000001EE 206571752024202D20          szAsmDataStringLengthType db " equ $ - "
  1307                                      szAsmDataStringLengthType.length equ $ - szAsmDataStringLengthType
  1308 000001F7 2E6C656E677468              szAsmDataStringSuffix db ".length"
  1309                                      szAsmDataStringSuffix.length equ $ - szAsmDataStringSuffix
  1310 000001FE 6A6E6520                    szAsmEqual db "jne "
  1311                                      szAsmEqual.length equ $ - szAsmEqual
  1312 00000202 6A6520                      szAsmNotEqual db "je "
  1313                                      szAsmNotEqual.length equ $ - szAsmNotEqual
  1314 00000205 6A676520                    szAsmLess db "jge "
  1315                                      szAsmLess.length equ $ - szAsmLess
  1316 00000209 6A6720                      szAsmLessOrEqual db "jg "
  1317                                      szAsmLessOrEqual.length equ $ - szAsmLessOrEqual
  1318 0000020C 6A6C6520                    szAsmGreater db "jle "
  1319                                      szAsmGreater.length equ $ - szAsmGreater
  1320 00000210 6A6C20                      szAsmGreaterOrEqual db "jl "
  1321                                      szAsmGreaterOrEqual.length equ $ - szAsmGreaterOrEqual
  1322 00000213 6966                        szKeywordIf db "if"
  1323                                      szKeywordIf.length equ $ - szKeywordIf
  1324 00000215 7468656E                    szKeywordThen db "then"
  1325                                      szKeywordThen.length equ $ - szKeywordThen
  1326 00000219 656E64                      szKeywordEnd db "end"
  1327                                      szKeywordEnd.length equ $ - szKeywordEnd
  1328 0000021C 67737472                    szKeywordGStr db "gstr"
  1329                                      szKeywordGStr.length equ $ - szKeywordGStr
  1330 00000220 3D3D                        szOperatorEquals db "=="
  1331                                      szOperatorEquals.length equ $ - szOperatorEquals
  1332 00000222 213D                        szOperatorNotEquals db "!="
  1333                                      szOperatorNotEquals.length equ $ - szOperatorNotEquals
  1334 00000224 3C                          szOperatorLess db "<"
  1335                                      szOperatorLess.length equ $ - szOperatorLess
  1336 00000225 3C3D                        szOperatorLessOrEqual db "<="
  1337                                      szOperatorLessOrEqual.length equ $ - szOperatorLessOrEqual
  1338 00000227 3E                          szOperatorGreater db ">"
  1339                                      szOperatorGreater.length equ $ - szOperatorGreater
  1340 00000228 3E3D                        szOperatorGreaterOrEqual db ">="
  1341                                      szOperatorGreaterOrEqual.length equ $ - szOperatorGreaterOrEqual
  1342 0000022A 3D                          szOperatorAssignment db "="
  1343                                      szOperatorAssignment.length equ $ - szOperatorAssignment
  1344 0000022B 2E656E6469665F              szEndLabelForJump db ".endif_"
  1345                                      szEndLabelForJump.length equ $ - szEndLabelForJump
  1346 00000232 3B2D2D2D2D2D2D2D2D-         szHorizontalLine db ";-----------------------------  refactored output -------------------------------"
  1346 0000023B 2D2D2D2D2D2D2D2D2D-
  1346 00000244 2D2D2D2D2D2D2D2D2D-
  1346 0000024D 2D2D2D202072656661-
  1346 00000256 63746F726564206F75-
  1346 0000025F 74707574202D2D2D2D-
  1346 00000268 2D2D2D2D2D2D2D2D2D-
  1346 00000271 2D2D2D2D2D2D2D2D2D-
  1346 0000027A 2D2D2D2D2D2D2D2D2D 
  1347                                      szHorizontalLine.length equ $ - szHorizontalLine
