; ftoa.asm - Float to ASCII Conversion without External Calls
; Input:
;   xmm0 - Float value to convert
;   rdi  - Return address for converted string
;   rdx  - Size of buffer

global ftoa

section .text
ftoa:
    ; Preserve used registers
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Clear the return buffer 
    mov rcx, rdx
    mov al, 0
    mov rsi, rdi
    rep stosb

    ; Reset destination pointer
    mov rdi, rsi

    ; Check for negative number
    xorps xmm1, xmm1
    ucomiss xmm0, xmm1
    jae .positive

    ; Handle negative number
    mov byte [rdi], '-'
    inc rdi
    movss xmm1, xmm0
    andps xmm1, [rel abs_mask]  ; Get absolute value
    movss xmm0, xmm1

.positive:
    ; Extract whole number part
    cvttss2si r12, xmm0   ; Convert float to integer
    
    ; Convert integer part to string (reverse)
    mov rbx, rdi          ; Save start of integer conversion
.int_convert_loop:
    mov rdx, 0
    mov rax, r12
    mov rcx, 10
    div rcx
    
    ; Convert remainder to character
    add rdx, '0'
    mov byte [rdi], dl
    inc rdi
    
    mov r12, rax
    test r12, r12
    jnz .int_convert_loop

    ; Reverse integer part
    mov r13, rdi          ; Save end of integer part
    dec r13
.reverse_int:
    cmp rbx, r13
    jge .decimal_point
    
    mov al, [rbx]
    mov cl, [r13]
    mov [rbx], cl
    mov [r13], al
    
    inc rbx
    dec r13
    jmp .reverse_int

.decimal_point:
    ; Add decimal point
    mov byte [rdi], '.'
    inc rdi

    ; Extract fractional part
    movss xmm1, xmm0
    cvttss2si r12, xmm1   ; Whole number part again
    subss xmm0, xmm1      ; Subtract whole part to get fractional

    ; Multiply fractional part to get precision (6 decimal places)
    movss xmm1, [rel million]
    mulss xmm0, xmm1
    
    ; Convert fractional part
    cvttss2si r12, xmm0   ; Convert fractional part to integer

    ; Pad with zeros if needed
    mov rcx, 6
.frac_zero_pad:
    mov rdx, 0
    mov rax, r12
    mov rbx, 10
    div rbx
    
    ; Convert remainder to character
    add rdx, '0'
    mov byte [rdi], dl
    inc rdi
    
    mov r12, rax
    dec rcx
    jnz .frac_zero_pad

    ; Null terminate
    mov byte [rdi], 0

    ; Restore registers
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

section .data
    abs_mask: dd 0x7FFFFFFF, 0, 0, 0
    million:  dd 1000000.0, 0, 0, 0