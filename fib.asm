; Fibonacci sequence in x86_64 assembly

section .data
    number_size dd 12
    num_loops dd 11 

section .bss
    number resb 12

global _start

section .text
_start:
    mov rcx, [num_loops]
    call fib
    call print_result
    mov rax, 60 ;sys_exit system call number for x86_64
    xor rdi, rdi ;exit status is 0
    syscall

fib:
	push rbp
	mov rbp, rsp
	; Push initial values to the stack
	push 1
	push 1
	call fib_loop
	add rsp, 16 ; Clean the stack of the initially pushed values
	pop rbp
    ret
	

fib_loop:
	push rbp
	mov rbp, rsp
	call fib_calc
	pop rbp
    dec rcx
    cmp rcx, 0
    jg fib_loop
	mov rax, [rsp + 8] ; Last fib. number
	mov [number], rax
    ret

fib_calc:
	push rbp
	mov rbp, rsp
	mov rdx, [rsp + 32]
	add rdx, [rsp + 40]
	mov rax, [rsp + 40]
	mov [rsp + 32], rax
	mov [rsp + 40], rdx
	pop rbp
	ret

print_result:
    mov rax, [number]
    mov rdi, number
    xor rcx, rcx
    call integer_to_string_setup
    call convert_loop
    mov rax, 1          ; sys_write system call number for x86_64
    mov rdi, 1          ; File descriptor 1 is stdout
    mov rsi, number     ; Pointer to the string
    mov rdx, 12         ; Assume the string will not be longer than 12 characters
    syscall
    ret

integer_to_string_setup:
    mov rbx, 10
    mov rcx, rdi
    ret

convert_loop:
    xor rdx, rdx
    div rbx
	; add ascii 42 i.e. '0', to turn value into ascii
    add dl, '0'
    mov [rdi], dl
    inc rdi
    cmp rax, 0
    jne convert_loop
    mov rdx, rdi
    call reverse_loop
    mov byte [rdi+1], 0x0a
    ret

reverse_loop:
    mov rax, 0
    cmp rcx, rdx
    jge end_reverse_loop
    mov al, [rcx]
    mov bl, [rdx]
    mov [rcx], bl
    mov [rdx], al
    inc rcx
    dec rdx
    jmp reverse_loop

end_reverse_loop:
    ret
