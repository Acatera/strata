gdb -ex "b _start" -ex "r" -ex "layout asm" -ex "layout regs" -ex "set disassembly-flavor intel" -iex "set auto-load safe-path F:/asm/disasm/" --args %1 src