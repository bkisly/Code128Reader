    section .text
    global _getNarrowestBar
    global getNarrowestBar

; int getNarrowestBar(char *beginAddress, char* endAddress)
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

    ; 2. skip the quiet zone
.loop_quietzone:
    mov cl, BYTE [eax]
    add eax, 3
    test cl, cl
    jnz .loop_quietzone

    ; 3. reset the temporary counter for the next group of pixels
.loop_resetcounter:
    xor dl, dl

    ; 4. check if current pixel is not equal to previous, update counters
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