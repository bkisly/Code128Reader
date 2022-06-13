; INFO: The following file contains assembly functions, which are compatible with Unix System V x86_64 calling convention

%include "setcarray.asm"

    section .text
    global getNarrowestBar
    global readSequence
    global addressAfterQuiet
    global convertSequence

; unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress)
;   returns the address of first black pixel after quiet zone

addressAfterQuiet:
    ; arg1 - RDI
    ; arg2 - RSI

    cmp rdi, rsi
    jge .ret

    mov al, BYTE [rdi]
    add rdi, 3
    test al, al
    jnz addressAfterQuiet

.ret:
    mov rax, rdi
    ret

; uint8_t getNarrowestBar(char *beginAddress, char* endAddress)
;   returns the length of the narrowest bar in the image

getNarrowestBar:
    ; rdi - current address
    ; rsi - last address
    ; cl - current B value
    ; ch - previous B value
    ; al - current pixel count
    ; ah - min pixel count

    mov ah, 0xff

    ; 2. reset the temporary counter for the next group of pixels
.loop_resetcounter:
    xor al, al

    ; 3. check if current pixel is not equal to previous, update counters
.loop_findnarrowest:
    cmp rdi, rsi
    jge .ret

    mov cl, BYTE [rdi]
    mov ch, BYTE [rdi-3]
    inc al
    add rdi, 3
    cmp cl, ch
    je .loop_findnarrowest

    cmp ah, al
    jb .loop_resetcounter

    mov ah, al
    jmp .loop_resetcounter

.ret:
    ; epilogue
    mov al, ah
    and rax, 0xff
    ret


; unsigned int readSequnece(unsigned char *beginAddress, uint8_t barLength)
;   returns the calculated binary value of bars sequence, starting from the given address
;   and basing on the minimum bar length

readSequence:
    ; rdi - begin address
    ; rsi - minimum bar length
    ; rax - stores sequence
    ; cl - sequence counter
    ; r8b - current pixel

    xor rax, rax
    xor rcx, rcx
    xor r8, r8

    lea rsi, [rdx + rdx*2]  ; multiply bar length by 3, this is the increment of the address
    and rsi, 0xff

.read_loop:
    cmp cl, 11
    jae .ret

    mov r8b, BYTE [rdi]    ; 1. load bar value
    not r8b  ; 2. store 0 if white pixel, otherwise 1
    and r8b, 1
    or rax, r8
    shl rax, 1  ; 3. save the bit into the result binary sequence
    inc cl

    ; 4. increment the address
    add rdi, rsi
    jmp .read_loop

.ret:
    shr rax, 1
    ret

; int8_t convertSequence(unsigned int sequence)
;   converts the given sequence to its matching Code128C decoded value
;   returns -1 if the sequence is not valid

convertSequence:
    ; rdi - sequence

    xor rax, rax
    lea rdx, [setcarray]
    mov al, BYTE [rdx+rdi]
    ret