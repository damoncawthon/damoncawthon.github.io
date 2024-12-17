; Faraday Calculation Module
; Handles resistance calculation with Strlen Macro

; Macro for calculating string length
%macro STRLEN 2  ; Two parameters: destination register, source string address
    push rdi    ; Preserve rdi
    mov rdi, %2 ; Move string address to rdi
    
    xor %1, %1  ; Zero out destination register
%%strlen_loop:
    cmp byte [rdi], 0   ; Check for null terminator
    je %%strlen_done    ; If null, we're done
    inc rdi             ; Move to next character
    inc %1              ; Increment length
    jmp %%strlen_loop   ; Continue counting

%%strlen_done:
    pop rdi             ; Restore rdi
%endmacro

section .data
    welcome_msg db "Welcome to Electricity brought to you by Damon Cawthon.", 10, 0
    name_prompt db "Please enter your full name: ", 0
    career_prompt db "Please enter the career path you are following: ", 0
    emf_prompt db "Please enter the EMF of your circuit in volts: ", 0
    current_prompt db "Please enter the current in this circuit in amps: ", 0
    result_msg db "The resistance in this circuit is ", 0
    outro_msg db "Thank you ", 0
    dot_msg db ".", 10, 0

section .bss
    input_buffer resb 100
    result_buffer resb 100
    emf_value resq 1
    current_value resq 1
    resistance_value resq 1

section .text
    global _start
    extern atof
    extern ftoa


_start:
    ; Display welcome message
    STRLEN r9, welcome_msg
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, welcome_msg
    mov rdx, r9
    syscall

    ; Prompt and get name
    STRLEN r9, name_prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, name_prompt
    mov rdx, r9
    syscall

    ; Read name
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 100
    syscall

    ; Prompt and get career path
    STRLEN r9, career_prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, career_prompt
    mov rdx, r9
    syscall

    ; Read career
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 100
    syscall

    ; Prompt and get EMF
    STRLEN r9, emf_prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, emf_prompt
    mov rdx, r9
    syscall

    ; Read EMF
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 100
    syscall

    ; Convert EMF to float
    mov rdi, input_buffer
    call atof
    movsd [emf_value], xmm0

    ; Prompt and get current
    STRLEN r9, current_prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, current_prompt
    mov rdx, r9
    syscall

    ; Read current
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 100
    syscall

    ; Convert current to float
    mov rdi, input_buffer
    call atof
    movsd [current_value], xmm0

    ; Calculate resistance
    movsd xmm0, [emf_value]
    movsd xmm1, [current_value]
    divsd xmm0, xmm1    ; EMF / Current
    movsd [resistance_value], xmm0

    ; Convert resistance to string
    mov rdi, resistance_value
    mov rsi, result_buffer
    mov rdx, 100
    call ftoa

    ; Display result message
    STRLEN r9, result_msg
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, result_msg
    mov rdx, r9
    syscall

    ; Display resistance value
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, result_buffer
    mov rdx, 100
    syscall

    ; Exit program
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit code 0
    syscall