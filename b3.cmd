v2
nasm.exe -f win64 v3.asm -o v3.o 
ld -e init_program v3.o -o v3.exe -lkernel32 -Llib
v3