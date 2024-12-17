global atof

section .data
    neg_mask dq 0x8000000000000000

section .bss
    align 64
    storedata resb 832

section .text
atof:
    ; Back up
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8 
    push    r9 
    push    r10
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15
    pushf

    mov     rax, 7
    mov     rdx, 0
    xsave   [storedata]    

    ; Parameters
    mov     r15, rdi            ; An array of char with null termination expected

    ; Find where the radix point is, if it exists
    xor     r14, r14            ; Index for the radix point
    mov     r13, -1              ; Flag for decimal point (-1 means not found)

find_radix_loop:
    cmp     byte[r15 + r14], '.'
    je      found_radix_point

    cmp     byte[r15 + r14], 0  ; Check for null terminator
    je      no_radix_point

    inc     r14
    jmp     find_radix_loop

found_radix_point:
    mov     r13, r14            ; Store the radix point index
    jmp     parse_integer_start

no_radix_point:
    mov     r14, 0              ; Reset index to start of string
    mov     r13, -1             ; Indicate no decimal point

parse_integer_start:
    ; Set up registers for integer part parsing
    xor     r12, r12            ; Integer total
    mov     r11, r14            ; Make a copy of the start index
    dec     r11                 
    xor     r10, r10            ; Flag 0 = positive, 1 = negative
    mov     rax, 1              ; Integer multiplier 1, 10, 100, 1000,...

parse_integer:
    cmp     r11, 0
    jl      finish_parse_integer

    mov     cl, byte[r15 + r11]
    cmp     cl, '+'
    je      finish_parse_integer
    cmp     cl, '-'
    je      parse_integer_negative

    ; Convert the ASCII character to integer and add it to the total
    sub     cl, '0'             ; Subtract 48 from the ASCII to get integer value
    movzx   rcx, cl             ; Zero-extend the character to 64 bits
    mul     rcx                 ; Multiply current multiplier by digit
    add     r12, rax            ; Add the multiplied value to the total
    mov     rax, 10             ; Reset multiplier for next iteration
    mul     rax                 ; Increase the multiplier exponentially by 10

    dec     r11                 ; Move the index toward the front of the string
    jmp     parse_integer    

parse_integer_negative:
    mov     r10, 1              ; Set r10 to 1 to flag the number as negative

finish_parse_integer:
    ; Set up values for decimal part parsing  
    xorpd   xmm13, xmm13        ; Decimal total
    movsd   xmm11, [rel ten_double]  ; 10.0 for divisor calculations
    movsd   xmm12, xmm11        ; Decimal divisor 10, 100, 1000,...
    
    ; Check if we have a decimal point
    cmp     r13, -1
    je      convert_integer

    ; Parsing decimal part
    inc     r13
parse_decimal:
    mov     al, byte [r15 + r13]
    cmp     al, 0               ; Stop at null terminator
    je      convert_integer

    sub     al, '0'             ; Subtract 48 from the ASCII to get integer value
    movzx   rax, al             ; Zero-extend the character to 64 bits

    ; Convert the ASCII character to decimal value
    cvtsi2sd xmm0, rax          ; Load the integer value into an xmm register for division
    divsd   xmm0, xmm12         ; Divide the integer value by 10, 100, 1000,...
    addsd   xmm13, xmm0         ; Add the decimal value to the total
    mulsd   xmm12, xmm11        ; Increase the decimal divisor exponentially by 10

    inc     r13
    jmp     parse_decimal

convert_integer:
    ; Add the parsed integer and decimal part together
    cvtsi2sd xmm0, r12
    addsd   xmm0, xmm13

    ; Check the negative flag 0 = positive, 1 = negative
    cmp     r10, 0
    je      return

    ; Negate the number if the flag is 1
    movsd xmm1, [neg_mask]      ; Load the negation mask into xmm1
    xorpd xmm0, xmm1 

return:
    ; Return
    push    qword 0
    movsd   [rsp], xmm0

    mov     rax, 7
    mov     rdx, 0
    xrstor  [storedata]

    movsd   xmm0, [rsp]
    pop     rax

    ; Restore
    popf          
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     r10
    pop     r9 
    pop     r8 
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rbp

    ret

section .data
    ten_double dq 10.0