; INFO: The following file contains assembly functions, which are compatible with Microsoft's x86_64 calling convention

%include "setcarray.asm"

    section .text
    global getNarrowestBar
    global readSequence
    global addressAfterQuiet
    global convertSequence

; unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress)
;   returns the address of first black pixel after quiet zone

addressAfterQuiet:
    ; begin address - RCX
    ; end address - RDX
    cmp rcx, rdx
    jge .ret

    mov al, BYTE [rcx]
    add rcx, 3
    test al, al
    jnz addressAfterQuiet

.ret:
    mov rax, rcx
    ret

; uint8_t getNarrowestBar(char *beginAddress, char* endAddress)
;   returns the length of the narrowest bar in the image

getNarrowestBar:
    ; rcx - current address
    ; rdx - last address
    ; r8b - current B value
    ; r9b - previous B value
    ; al - current pixel count
    ; ah - min pixel count

    mov ah, 0xff

    ; 2. reset the temporary counter for the next group of pixels
.loop_resetcounter:
    xor al, al

    ; 3. check if current pixel is not equal to previous, update counters
.loop_findnarrowest:
    cmp rcx, rdx
    jge .ret

    mov r8b, BYTE [rcx]
    mov r9b, BYTE [rcx-3]
    inc al
    add rcx, 3
    cmp r8b, r9b
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
    ; rcx - begin address
    ; rdx - minimum bar length
    ; rax - stores sequence
    ; dh - sequence counter
    ; r8b - current pixel

    xor r8, r8
    xor rax, rax

    lea rdx, [rdx + rdx*2]  ; multiply bar length by 3, this is the increment of the address
    xor dh, dh

.read_loop:
    cmp dh, 11
    jae .ret

    mov r8b, BYTE [rcx]    ; 1. load bar value
    not r8b  ; 2. store 0 if white pixel, otherwise 1
    and r8b, 1
    or al, r8b
    shl rax, 1  ; 3. save the bit into the result binary sequence
    inc dh

    ; 4. increment the address
    xor r8, r8
    mov r8b, dl
    add rcx, r8
    jmp .read_loop

.ret:
    shr rax, 1
    ret

; int8_t convertSequence(unsigned int sequence)
;   converts the given sequence to its matching Code128C decoded value
;   returns -1 if the sequence is not valid

convertSequence:
    ; rcx - sequence

    xor rax, rax
    lea rdx, [setcarray]
    mov al, BYTE [rdx+rcx]
    ret
