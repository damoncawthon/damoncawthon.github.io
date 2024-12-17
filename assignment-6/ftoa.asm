; Code generated by make ftoa.asm. DO NOT EDIT.

; Copyright 2022 Diamond Dinh (diamondburned), licensed under the MIT license.

; //Author information
; //  Author name: Timothy Vu
; //  Author email: timothy.vu@csu.fullerton.edu
; //  Author Section: M/W 2:00pm-3:50pm
; File name: ftoa.asm
; Language: Assembly (x86-64 NASM)
; Purpose: Convert a double-precision floating-point number to a null-terminated string.
; Input:
;   - RDI: Address of the double-precision number (num)
;   - RSI: Address of the character array (arr)
;   - RDX: Size of the character array (size)
; Output:
;   - The string representation of the number is written to `arr`.
section .data
    digits db "0123456789", 0 ; Digits for conversion
    point db ".", 0           ; Decimal point
    max_size equ 64           ; Maximum buffer size
    ten_double dq 10.0

section .text
    global ftoa

ftoa:
    ; Save caller's registers
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    ; Input validation
    test rsi, rsi         ; Check if output buffer is null
    jz .return
    test rdx, rdx         ; Check if buffer size is zero
    jz .return

    ; Load the input double (num) into xmm0
    movsd xmm0, [rdi]

    ; Check for negative numbers
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .positive

    ; Handle negative numbers
    mov byte [rsi], '-'
    inc rsi
    dec rdx
    movsd xmm1, [rel neg_mask]
    xorpd xmm0, xmm1

.positive:
    ; Save base array pointer and buffer size
    mov r12, rsi          ; Base array pointer
    mov r13, rdx          ; Remaining buffer size

    ; Integer part: convert and store
    cvttsd2si rbx, xmm0   ; Convert double to integer (truncates)
    mov rcx, r12          ; Save current pointer for integer conversion
    call convert_integer

    ; Add decimal point
    mov rax, '.'
    mov byte [r12], al
    inc r12
    dec r13

    ; Prepare for fractional part
    movsd xmm1, [rel ten_double]  ; xmm1 = 10.0
    cvttsd2si rax, xmm0
    cvtsi2sd xmm2, rax
    subsd xmm0, xmm2    ; Get fractional part
    mulsd xmm0, xmm1    ; Scale up fractional part
    cvttsd2si rbx, xmm0 ; Convert to integer
    mov rcx, r12        ; Save current pointer
    call convert_integer

    ; Null-terminate the string
    mov byte [r12], 0

.return:
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

convert_integer:
    mov r14, rcx          ; Preserve original pointer
    mov rax, rbx          ; Move number to rax for division
    mov r15, r13          ; Remaining buffer size

    ; Handle zero case
    test rax, rax
    jnz .integer_loop

    mov byte [r12], '0'
    inc r12
    dec r13
    ret

.integer_loop:
    dec r15               ; Decrement remaining size
    jz .buffer_overflow   ; Exit if buffer is full

    mov rdx, 0            ; Clear RDX (remainder)
    mov rbx, 10           ; Divisor
    div rbx               ; Divide RAX by 10
    add dl, '0'           ; Convert digit to ASCII
    
    dec r12               ; Move pointer back
    mov byte [r12], dl    ; Store digit

    test rax, rax         ; Check if quotient is 0
    jnz .integer_loop

    ret

.buffer_overflow:
    ; Reset to original pointer and null-terminate
    mov r12, r14
    mov byte [r12], 0
    ret

section .data
    neg_mask dq 0x8000000000000000