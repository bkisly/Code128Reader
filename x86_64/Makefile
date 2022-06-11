CC=gcc
ASMBIN=nasm
ASM_SRC=code128reader
ASM_ARR=setcarray

all: assemble compile link clean

assemble: $(ASM_ARR).asm $(ASM_SRC).asm
	$(ASMBIN) -o $(ASM_ARR).o -f elf64 -g $(ASM_ARR).asm	
	$(ASMBIN) -o $(ASM_SRC).o -f elf64 -g $(ASM_SRC).asm

compile: assemble image.c main.c
	$(CC) -c -g -O0 image.c
	$(CC) -c -g -O0 main.c

link: compile
	$(CC) -g -o code128reader image.o main.o $(ASM_ARR).o $(ASM_SRC).o

clean:
	rm *.o