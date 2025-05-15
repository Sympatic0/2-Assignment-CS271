.equ STDIN_FILENO, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2

.equ SYS_read, 0
.equ SYS_write, 2
.equ SYS_exit, 60

.section .text
.globl main
main:


loop:
	leaq 8(%rsi), %rsi
	movq (%rsi), %r12
	test %r12, %r12

	/*je print_result*/
		
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

	pop %r8
	pop %rax
	imulq %r8
	push %rax

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

	pop %r8
	pop %rax
	cqo
	idivq %r8
	push %rax

num_conv:

	movq %r12, %rdi
	leaq endptr(%rip), %rsi
	xor %rdx, %rdx
	
	call strtol

	leaq endptr(%rip), %r8
	cmp %r8, %r12
	je error
	cmp $0, %r8


error:
	
	

end:
	xor %eax, %eax
	leave
	ret		

.section .bss
endptr:
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

