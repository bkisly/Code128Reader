    section .text
    global _add
    global add

_add:
add:
    ; prologue
    push ebp
    mov ebp, esp

    ; body
    mov eax, [ebp+8]
    add eax, [ebp+12]

    ; epilogue
    mov esp, ebp
    pop ebp
    ret