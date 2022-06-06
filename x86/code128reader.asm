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

    ; 1. save arguments into registers
    mov eax, [ebp+8]
    mov ebx, [ebp+12]

    ; 2. skip the quiet zone
.loop_quietzone:
    mov cl, BYTE [eax]
    inc dl
    add eax, 3
    test cl, cl
    jnz .loop_quietzone

    mov eax, edx
    
    ; epilogue
    pop ebx
    mov esp, ebp
    pop ebp
    ret