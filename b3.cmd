nasm.exe -f win64 v3.asm -o v3.o -w+all -w+error
ld -e proc_main v3.o -o v3.exe -lkernel32 -Llib