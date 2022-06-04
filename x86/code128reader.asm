    section .text
    global _readColors
    global readColors

_readColors:
readColors:
    ; prologue
    push ebp
    mov ebp, esp
    xor ecx, ecx
    xor eax, eax

    ; body
    mov edx, [ebp+8]
    mov al, BYTE [edx]

    inc edx
    mov cl, BYTE [edx]
    shl ecx, 8
    or eax, ecx
    xor ecx, ecx

    inc edx
    mov cl, BYTE [edx]
    shl ecx, 16
    or eax, ecx

    ; epilogue
    mov esp, ebp
    pop ebp
    ret
