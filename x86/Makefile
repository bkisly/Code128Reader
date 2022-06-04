CC=gcc
ASMBIN=nasm
ASM_SRC=code128reader

all: assemble compile link clean

assemble: $(ASM_SRC).asm
	$(ASMBIN) -o $(ASM_SRC).o -f elf -g -l $(ASM_SRC).lst $(ASM_SRC).asm

compile: assemble image.c main.c
	$(CC) -m32 -c -g -O0 image.c
	$(CC) -m32 -c -g -O0 main.c

link: compile
	$(CC) -m32 -g -o code128reader image.o main.o $(ASM_SRC).o

clean:
	rm *.o
	rm $(ASM_SRC).lst