dlltool -D KERNEL32.dll -d kernel32.def -l libkernel32.a
dlltool -D shell32.dll -d shell32.def -l libshell32.a
dlltool -D ws2_32.dll -d ws2_32.def -l libws2_32.a