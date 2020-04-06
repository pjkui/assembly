.globl _start

extern print

section .text

_start:
		call print

		movq $60,   %rax
		movq $0,    %rdx
		syscall