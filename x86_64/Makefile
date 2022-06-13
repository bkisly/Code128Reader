CC=gcc
ASMBIN=nasm
ASM_SRC_WIN=code128reader_win
ASM_SRC_UNIX=code128reader_unix
ASM_ARR=setcarray

win: assemble_win compile_win link_win clean
unix: assemble_unix compile_unix link_unix clean

# Makefile commands for Windows
assemble_win: $(ASM_ARR).asm $(ASM_SRC_WIN).asm
	$(ASMBIN) -o $(ASM_ARR).o -f elf64 -g $(ASM_ARR).asm
	$(ASMBIN) -o $(ASM_SRC_WIN).o -f elf64 -g $(ASM_SRC_WIN).asm

compile_win: assemble_win image.c main.c
	$(CC) -c -g -O0 image.c
	$(CC) -c -g -O0 main.c

link_win: compile_win
	$(CC) -g -o code128reader image.o main.o $(ASM_ARR).o $(ASM_SRC_WIN).o

# Makefile commands for Unix systems
assemble_unix: $(ASM_ARR).asm $(ASM_SRC_UNIX).asm
	$(ASMBIN) -o $(ASM_ARR).o -f elf64 -g $(ASM_ARR).asm
	$(ASMBIN) -o $(ASM_SRC_UNIX).o -f elf64 -g $(ASM_SRC_UNIX).asm

compile_unix: assemble_unix image.c main.c
	$(CC) -c -g -O0 image.c
	$(CC) -c -g -O0 main.c

link_unix: compile_unix
	$(CC) -g -o code128reader image.o main.o $(ASM_ARR).o $(ASM_SRC_UNIX).o

# Cleaning .o files
clean:
	rm *.o