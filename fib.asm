; Fibonacci sequence in x86 assembly

section .data
	number_size dd 12
	num_loops dd 10

; bass is a section to declare uninitialized data, resb stands for reserve byte
section .bss
	number resb 12 ; Reserve 12 bytes for the largest 32-bit integer when converted to string

global _start

section .text
_start:
	mov eax, 1
	mov ebx, 1
	mov ecx, [num_loops] ; [pointer] is a dereference
	call fib
	call print_result
	mov eax, 1 ;sys_exit system call
	mov ebx, 0 ;exit status is 0
	int 0x80

fib:
    ; Compute the next number in the sequence
    mov edx, eax
    add edx, ebx
    mov eax, ebx
    mov ebx, edx
    dec ecx
    cmp ecx, 0
    jg fib
    ; At this point, edx contains the last Fibonacci number calculated.
    ; We need to move this into a memory location pointed to by [number].
    mov [number], edx
    ret

print_result:
    ; Print the result to stdout
    ; Before calling this, edx should contain the Fibonacci number to print.
	mov eax, [number]
	mov edi, number
	mov ecx, 0 ; Counter
	call integer_to_string_setup
	call convert_loop
    mov eax, 4          ; sys_write
    mov ebx, 1          ; File descriptor 1 is stdout
    mov ecx, number     ; Pointer to the string
    mov edx, 12         ; Assume the string will not be longer than 12 characters
    int 0x80            ; System call to write the string to stdout
    ret

integer_to_string_setup:
	mov ebx, 10 ; Divisor
	mov ecx, edi ; Store start of the string
	ret

convert_loop:
	xor edx, edx ; Clear edx
	div ebx ; affects only eax, quotient is now divided by 10 and edx contains the remainder
	add dl, '0'
	mov [edi], dl
	inc edi
	cmp eax, 0
	jne convert_loop
	; Get ready to reverse the string
	mov edx, edi ; we want to keep end of string address in edi for new line char
	call reverse_loop
	mov byte [edi+1], 0x0a ; add new string byte to end of string
	ret

reverse_loop:
	mov eax, 0
	cmp ecx, edx
	jge end_reverse_loop
	mov al, [ecx]
	mov bl, [edx]
	mov [ecx], bl
	mov [edx], al
	inc ecx
	dec edx
	jmp reverse_loop

end_reverse_loop:
	ret
	
	
