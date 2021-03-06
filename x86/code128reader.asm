%include "setcarray.asm"

    section .text
    global _getNarrowestBar
    global getNarrowestBar
    global _readSequence
    global readSequence
    global _addressAfterQuiet
    global addressAfterQuiet
    global _convertSequence
    global convertSequence

; unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress)
;   returns the address of first black pixel after quiet zone
_addressAfterQuiet:
addressAfterQuiet:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov ecx, [ebp+12]

.loop:
    cmp eax, ecx
    jge .ret

    mov dl, BYTE [eax]
    add eax, 3
    test dl, dl
    jnz .loop

.ret:
    mov esp, ebp
    pop ebp
    ret

; uint8_t getNarrowestBar(char *beginAddress, char* endAddress)
;   returns the length of the narrowest bar in the image
_getNarrowestBar:
getNarrowestBar:
    ; prologue
    ; eax - current address
    ; ebx - last address
    ; cl - current B value
    ; ch - previous B value
    ; dl - current pixel count
    ; dh - min pixel count

    push ebp
    mov ebp, esp
    push ebx

    mov dh, 0xff

    ; 1. save arguments into registers
    mov eax, [ebp+8]
    mov ebx, [ebp+12]

    ; 2. reset the temporary counter for the next group of pixels
.loop_resetcounter:
    xor dl, dl

    ; 3. check if current pixel is not equal to previous, update counters
.loop_findnarrowest:
    cmp eax, ebx
    jge .ret

    mov cl, BYTE [eax]
    mov ch, BYTE [eax-3]
    inc dl
    add eax, 3
    cmp cl, ch
    je .loop_findnarrowest

    cmp dh, dl
    jb .loop_resetcounter

    mov dh, dl
    jmp .loop_resetcounter

.ret:
    ; epilogue
    xor eax, eax
    mov al, dh
    pop ebx
    mov esp, ebp
    pop ebp
    ret


; unsigned int readSequnece(unsigned char *beginAddress, uint8_t barLength)
;   returns the calculated binary value of bars sequence, starting from the given address
;   and basing on the minimum bar length
_readSequence:
readSequence:
    ; prologue
    ; eax - begin address
    ; bl - current pixel
    ; cl - sequence counter (counts to 11, because every sequence has 11 bits)
    ; ch - minimum bar length
    ; edx - stores sequence

    push ebp
    mov ebp, esp
    push ebx
    xor ebx, ebx
    xor edx, edx
    xor ecx, ecx

    mov eax, [ebp+8]
    mov cl, BYTE [ebp+12]
    lea ecx, [ecx + ecx*2]  ; multiply bar length by 3, this is the increment of the address
    mov ch, cl
    xor cl, cl

.read_loop:
    cmp cl, 11
    jae .ret

    mov bl, BYTE [eax]    ; 1. load bar value
    not bl  ; 2. store 0 if white pixel, otherwise 1
    and bl, 1
    or edx, ebx
    shl edx, 1  ; 3. save the bit into the result binary sequence
    inc cl

    xor ebx, ebx    ; 4. increment the address
    mov bl, ch
    add eax, ebx
    jmp .read_loop

.ret:
    shr edx, 1
    mov eax, edx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; int8_t convertSequence(unsigned int sequence)
;   converts the given sequence to its matching Code128C decoded value
;   returns -1 if the sequence is not valid
_convertSequence:
convertSequence:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov ecx, [ebp+8]
    mov al, BYTE [setcarray+ecx]

    mov esp, ebp
    pop ebp
    ret