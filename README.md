# Assembly for x64 linux
## 参数调用
64位汇编
当参数少于7个时， 参数从左到右放入寄存器: rdi, rsi, rdx, rcx, r8, r9。
当参数为7个以上时， 前 6 个与前面一样， 但后面的依次从 “右向左” 放入栈中，即和32位汇编一样。

参数个数大于 7 个的时候
H(a, b, c, d, e, f, g, h);
a->%rdi, b->%rsi, c->%rdx, d->%rcx, e->%r8, f->%r9
h->8(%esp)
g->(%esp)
call H

Linux (and Windows) x86-64 calling conventionhas the first few arguments noton the stack, but in registers instead
See http://www.x86-64.org/documentation/abi.pdf (page 20)
Specifically:
If the class is MEMORY, pass the argument on the stack.
If the class is INTEGER, the next available register of the sequence %rdi, %rsi, %rdx, %rcx, %r8 and %r9 is used.
If the class is SSE, the next available vector register is used, the registers are taken in the order from %xmm0 to %xmm7.
If the class is SSEUP, the eightbyte is passed in the next available eightbyte chunk of the last used vector register.
If the class is X87, X87UP or COMPLEX_X87, it is passed in memory.
The INTEGERclass is anything that will fit in a general purpose register

> 参考文章: http://abcdxyzk.github.io/blog/2012/11/23/assembly-args/

## 参考链接

1. nasm和AT&T汇编的区别:
    https://www.tldp.org/HOWTO/Assembly-HOWTO/index.html
2. nasm的教程 https://0xax.github.io/asm_1/

3. nasm的教程 https://www.nasm.us/doc/nasmdo11.html#section-11.3

4. nasm的入门教程 https://p403n1x87.github.io/assembly/x86_64/2016/08/10/getting-started-with-x68-asm.html

5. AT&T的小抄:https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf

6. GAS http://web.mit.edu/gnu/doc/html/as_1.html

7. gas的简单入门示例:https://cs.lmu.edu/~ray/notes/gasexamples/

8. AT&T 和Intel汇编的区别 https://www.ibm.com/developerworks/cn/linux/l-assembly/index.html

9. 系统调用 https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl

10. Assembly Guide https://www.cs.yale.edu/flint/cs421/papers/x86-asm/asm.html

11. 手册 https://docs.oracle.com/cd/E26502_01/html/E28388/eoiyg.html

12. system call http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

13. gdb 调试 https://blog.csdn.net/gentleliu/article/details/45588011?depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2&utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2

14. The Definitive Guide to Linux System Calls https://blog.packagecloud.io/eng/2016/04/05/the-definitive-guide-to-linux-system-calls/#syscallsysret

15. 打造最小的elf可执行文件 https://www.w3cschool.cn/cbook/7to1eozt.html