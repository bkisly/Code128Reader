CC=gcc
ASMBIN=nasm
ASM_SRC=code128reader
ASM_ARR=setcarray

all: assemble compile link clean

assemble: $(ASM_ARR).asm $(ASM_SRC).asm
	$(ASMBIN) -o $(ASM_ARR).o -f elf -g -l $(ASM_ARR).lst $(ASM_ARR).asm	
	$(ASMBIN) -o $(ASM_SRC).o -f elf -g -l $(ASM_SRC).lst $(ASM_SRC).asm

compile: assemble image.c main.c
	$(CC) -m32 -c -g -O0 image.c
	$(CC) -m32 -c -g -O0 main.c

link: compile
	$(CC) -m32 -g -o code128reader image.o main.o $(ASM_ARR).o $(ASM_SRC).o

clean:
	rm *.o
	rm *.lst