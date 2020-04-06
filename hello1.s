# ----------------------------------------------------------------------------------------
# Writes "Hello, World" to the console using only system calls. Runs on 64-bit Linux only.
# To assemble and run:
#
#     gcc -c hello1.s && ld hello1.o && ./a.out
#
# or
#
#     gcc -nostdlib hello1.s && ./a.out
# ----------------------------------------------------------------------------------------

.section .text

.globl _start
_start:

mov  $60, %eax
xor  %ebx, %ebx
syscall
