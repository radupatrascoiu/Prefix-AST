%include "includes/io.inc"

extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1
    array: resd 400
    result: resd 1
    
section .data 

    ARRAY_LEN dd 0

section .text
global main

out:
    leave
    ret

parcurgere_recursiva:
    push ebp
    mov ebp, esp
    
    cmp dword [ebp+8], 0 ; conditia de oprire: nod null
    jz out
    
    mov eax, [ebp + 8]
    mov ebx, [eax]
            
    push eax
    push ebx
    push ebx
    call my_atoi
    add esp, 4
    pop ebx
    pop eax
    
    push eax
    push dword [eax+4] ; subarborele stang
    call parcurgere_recursiva
    add esp, 4
    pop eax
    
                  
    push eax 
    push dword [eax+8] ; subarborele drept
    call parcurgere_recursiva
    add esp, 4
    pop eax
    
    jmp out
   
my_atoi:
    push ebp
    mov ebp, esp
    cmp dword [ebp+8], 0 ; daca ajung la nod null
    je out

    mov eax, [ebp + 8]

    xor esi, esi
    xor ebx, ebx
    xor ecx, ecx
    
    cmp byte [eax], '-'
    jne transform_char ; nu e '-' => nu e nr negativ 
        
    cmp byte [eax+1], 0 ; daca e doar semn se opreste
    je sign

    mov ecx, 1 ; se activeaza flagul pentru numere negative
    inc eax ; merge la urmatorul caracter
   
transform_char:
    movzx edx, byte [eax]
    
    push edx
    and edx, edx
    jz compute_number
    pop edx
    
    cmp edx, '9' ; daca e mai mare, nu e cifra
    jg sign
    
    cmp edx, '0' ; daca e mai mic, nu e cifra
    jl sign
    
    jmp construct_number

after_construct:
    inc eax  
    jmp transform_char
    
sign:
        mov eax, [eax]
        mov [array + 4 * edi], eax
        inc edi
        jmp out
            
compute_number:
        cmp ecx, 1 
        ; daca e 0 e pozitiv, daca ecx e 1 => nr e negativ
        je neg_number
    
        ; se ajunge doar pentru numere pozitive
        add esi, ebx
        jmp put_in_array
    
neg_number:
        sub esi, ebx
    
put_in_array:
        mov [array + 4 * edi], esi
        inc edi 
        jmp out

construct_number:
        imul ebx, 10
        sub edx, 48
        add ebx, edx
        jmp after_construct
                        
main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor edi, edi
    xor esi, esi
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax    
    ; Implementati rezolvarea aici:
    push eax
    call parcurgere_recursiva
    add esp, 4   
    
push_to_stack:  
    mov eax, dword [array + 4 * edi - 4]
    push eax
    
    cmp eax, 42 ; *
    je multiplication

    cmp eax, 43 ; +
    je sum

    cmp eax, 45 ; -
    je subtraction

    cmp eax, 47 ; /
    je division

return:

    dec edi
    cmp edi, 0
    jg push_to_stack
    
    PRINT_DEC 4, [result]
    NEWLINE
    
    leave
    ret
 
multiplication:
    pop ecx
    pop eax
    pop ebx
        
    imul ebx
    
    mov [result], eax
    push dword [result]
    jmp return

sum:
    pop ecx
    pop eax
    pop ebx
        
    add eax, ebx
    
    mov [result], eax
    push dword [result]
    jmp return
   
subtraction:
    pop ecx
    pop eax
    pop ebx
    
    sub eax, ebx

    mov [result], eax
    push dword [result]
    jmp return
 
division:
    pop ecx
    pop eax
    pop ebx
    cdq 
    idiv ebx

    mov [result], eax
    push dword [result]
    jmp return
        
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
                  
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret