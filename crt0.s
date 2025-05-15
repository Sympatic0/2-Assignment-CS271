.equ SYS_exit, 60

.globl main
.type main @function

.globl _start
.type _start @function
_start:
	xorq %rbp, %rbp

	movl 8(%rsp), %edi
	leaq 8(%rsp), %rsi
	leaq 16(%rsp, %rsi, 8), %rdx

	call main

	movl %eax, %edi
	call _exit
