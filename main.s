.equ STDIN_FILENO, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2

.equ SYS_read, 0
.equ SYS_write, 2
.equ SYS_exit, 60

.section .text
.globl main
main:

	pushq %rbp
	movq %rsp, %rbp

	cmp $1, %rdi
	jle end
	
	movq (%rsi), %r8
	movq %r8, progname(%rip)

	leaq -16(%rbp), %r15

loop:
	leaq 8(%rsi), %rsi
	movq (%rsi), %r12
	test %r12, %r12

	je print_result
		
plus_cmp:
	push %rsi
	movq %r12, %rsi
	leaq plus_str(%rip), %rdi

	movq %rsp, %r13
	andq $-16, %rsp

	call strcmp

	movq %r13, %rsp
	pop %rsi

	test %eax, %eax
	jne minus_cmp

	cmpq %r15, %rsp
	ja reduction_error_operator
	
	pop %r8
	add %r8, (%rsp)
	jmp loop

minus_cmp:
	
	push %rsi
	movq %r12, %rsi	
	leaq minus_str(%rip), %rdi

	movq %rsp, %r13
	andq $-16, %rsp

	call strcmp

	movq %r13, %rsp
	pop %rsi

	test %eax, %eax
	jne mult_cmp

	cmpq %r15, %rsp
	ja reduction_error_operator

	pop %r8
	sub %r8, (%rsp)
	jmp loop

mult_cmp:

	push %rsi
	movq %r12, %rsi
	leaq mult_str(%rip), %rdi

	movq %rsp, %r13
	andq $-16, %rsp

	call strcmp

	movq %r13, %rsp
	pop %rsi

	test %eax, %eax
	jne div_cmp

	cmpq %r15, %rsp
	ja reduction_error_operator

	pop %rax
	imulq (%rsp)
	movq %rax, (%rsp)
	jmp loop

div_cmp:
	
	push %rsi
	movq %r12, %rsi
	leaq div_str(%rip), %rdi

	movq %rsp, %r13
	andq $-16, %rsp
	
	call strcmp
		
	movq %r13, %rsp
	pop %rsi

	test %eax, %eax
	jne num_conv

	cmpq %r15, %rsp
	ja reduction_error_operator

	pop %r8
	pop %rax
	cqo
	idivq %r8
	push %rax
	jmp loop

num_conv:
	
	push %rsi
	movq %r12, %rdi
	leaq endptr(%rip), %rsi
	xor %rdx, %rdx
	
	movq %rsp, %r13
	andq $-16, %rsp

	call strtol

	movq %r13, %rsp
	pop %rsi

	movq endptr(%rip), %r8
	cmp %r8, %r12
	je parse_error

	//cmp $0, %r8
	//jne parse_error

	push %rax
	jmp loop

print_result:
	leaq 8(%r15), %r15
	cmp %r15, %rsp
	jne reduction_error_operand

	leaq print_result_str(%rip), %rdi
	pop %rsi
	xor %rax, %rax

	call printf

	jmp end

parse_error:
	leaq parse_error_str(%rip), %rsi
	jmp err_end

reduction_error_operator:
	leaq reduction_error_operator_str(%rip), %rsi
	jmp err_end

reduction_error_operand:
	pop %r12
	leaq reduction_error_operand_str(%rip), %rsi
	jmp err_end

err_end:

	movq %rbp, %rsp
	movq stderr(%rip), %rdi
	movq progname(%rip), %rdx
	movq %r12, %rcx
	xor %rax, %rax
	
	call fprintf
	pop %rbp
	movl $1, %eax
	ret
	
end:
	xor %eax, %eax
	leave
	ret		

.section .bss
endptr:
	.space 8
progname:
	.space 8

.section .rodata

	plus_str:
	 .asciz "+"
	minus_str:
	 .asciz "-"
	mult_str:
	 .asciz "*"
	div_str:
	 .asciz "/"
	error_str:
	 .asciz "Error: Invalid Input"
	print_result_str:
	 .asciz "%ld\n"
	reduction_error_operand_str:
	 .asciz "%s: reduction error, too many operands: %ld\n"
	reduction_error_operator_str:
	 .asciz "%s: reduction error, too many operators: %ld\n"
	parse_error_str:
	 .asciz "%s: parse error :%s\n"

