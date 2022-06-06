    section .text
    global _getNarrowestBar
    global getNarrowestBar

; getNarrowestBar(char *beginAddress, char* endAddress)
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

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
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

.loop_resetcounter:
    xor dl, dl

.loop_findnarrowest:
    cmp eax, ebx
    jge .ret

    mov cl, BYTE [eax]
    mov ch, BYTE [eax-3]
    add dl, 1
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