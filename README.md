# Assembly for x64 linux
## Notice:注意!!! 
本项目是以AT&T语法为基础的汇编语言,而不是NASM.两者语法是明显差别的.具体差别,可以参考本文后面的参考文献[1][8].
## 32位汇编和64位汇编的差别

刚开始踩了一个坑,以为32位汇编和x64的汇编调用是一样的,后来发现不是的.明显的差别是在系统调用上.
32位机器上的退出程序如下:
```as
        movl $0,%ebx     # 参数一：退出代码
        movl $1,%eax     # 系统调用号(sys_exit) 
        int  $0x80       # 调用内核功能
```
64位机器上退出程序写法如下:
```as
        # exit(0)
        mov     $60, %rax               # system call 60 is exit
        xor     %rdi, %rdi              # we want return code 0
        syscall                         # invoke operating system to exit
```

区别1: 32位调用系统调用用的是`int $0x80`中断,64位用的是`syscall`,如果64位用32位的`int $0x80`将会造成系统错误.
区别2: 系统调用的中断号不一样.具体参考参考文献[9](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)

## 汇编函数调用
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

## 调试汇编程序

编译的之后添加`-gstabs`这个参数. 

like: `gcc -c hello.s -gstabs && ld hello.o && ./a.out`

然后gdb连接程序,进行调试:
```sh
gdb a.out
```
然后进行调试...(是不是懵逼了?不知道怎么继续...)

1. break `函数名称` :在函数名称上设置断点.也可以简写以为 `b _start`.在_start入口函数处设置断点
```sh
(gdb) break _start
Breakpoint 1 at 0x400078: file hello.s, line 17.
```
2. `r`:run.开始运行程序,进行debug.
```sh
(gdb) r
Starting program: /mnt/d/codes/learn_assembly/7/a.out 

Breakpoint 1, _start () at hello.s:17
17              mov     $1, %rax                # system call 1 is write
```

3. `l`:断到断到后,显示断点附近的上下文
```sh
(gdb) l
12              .global _start
13
14              .text
15      _start:
16              # write(1, message, 13)
17              mov     $1, %rax                # system call 1 is write
18              mov     $1, %rdi                # file handle 1 is stdout
19              mov     $message, %rsi          # address of string to output
20              mov     $13, %rdx               # number of bytes
21              syscall                         # invoke operating system to do the write
```

4. `n`:下一步
```sh
(gdb) n
18              mov     $1, %rdi                # file handle 1 is stdout
(gdb) n
19              mov     $message, %rsi          # address of string to output
```
5. `s`:step in;步入

6. `p $xx`:打印变量,相当于显示指针地址

7. `x/s $xx`: 以s的格式来显示变量的内容.相当于显示指针内容.
  >  x命令也可以使用修饰符修改输出，其格式为：
  >  x/nyz
  > n为要显示的字段数；
  > y是输出格式，可以是c（字符）、d（十进制）、x（十六进制）；
  > z是要显示的字段的长度，可以是b（字节）、h（16位字）、w（32位字）。
  ```sh
    (gdb) p ($rsi)
    $6 = 4194466
    (gdb) x/s $rsi
    0x4000a2 <message>:     "Hello, world\n"
  ```

8. `q/quit`:退出调试.

9. `info breakpoints`:显示左右的断点信息
```sh
(gdb) info breakpoints 
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400078 hello.s:17
        breakpoint already hit 1 time
```
10. `info registers`:显示所有的寄存器信息
```sh
(gdb) info registers 
rax            0x1      1
rbx            0x0      0
rcx            0x0      0
rdx            0xd      13
rsi            0x4000a2 4194466
rdi            0x1      1
rbp            0x0      0x0
rsp            0x7ffffffedf50   0x7ffffffedf50
r8             0x0      0
r9             0x0      0
r10            0x0      0
r11            0x0      0
r12            0x0      0
r13            0x0      0
r14            0x0      0
r15            0x0      0
rip            0x400094 0x400094 <_start+28>
```

11. 从寄存器很容易看,汇编传参的顺序, 
---

| 函数传入的参数  | 对应的寄存器 |
| ------------- | ------------- |
| 1  | rdi  |
| 2  | rsi  |
| 3  | rdx  |
| 4  | rcx  |
| 5  | r8  |
| 6  | r9  |

12. `info` 可以查看所有可以名的命令
```sh
info address -- Describe where symbol SYM is stored
info all-registers -- List of all registers and their contents
info args -- Argument variables of current stack frame
info auto-load -- Print current status of auto-loaded files
info auxv -- Display the inferior's auxiliary vector
info bookmarks -- Status of user-settable bookmarks
info breakpoints -- Status of specified breakpoints (all user-settable breakpoints if no argument)
info checkpoints -- IDs of currently known checkpoints
info classes -- All Objective-C classes
info common -- Print out the values contained in a Fortran COMMON block
info copying -- Conditions for redistributing copies of GDB
info dcache -- Print information on the dcache performance
info display -- Expressions to display when program stops
info exceptions -- List all Ada exception names
info extensions -- All filename extensions associated with a source language
info files -- Names of targets and files being debugged
info float -- Print the status of the floating point unit
info frame -- All about selected stack frame
info frame-filter -- List all registered Python frame-filters
info functions -- All function names
info guile -- Prefix command for Guile info displays
info handle -- What debugger does when program gets various signals
info inferiors -- IDs of specified inferiors (all inferiors if no argument)
info line -- Core addresses of the code for a source line
info locals -- Local variables of current stack frame
info macro -- Show the definition of MACRO
info macros -- Show the definitions of all macros at LINESPEC
info mem -- Memory region attributes
info os -- Show OS data ARG
info pretty-printer -- GDB command to list all registered pretty-printers
info probes -- Show available static probes
info proc -- Show /proc process information about any running process
info program -- Execution status of the program
info record -- Info record options
info registers -- List of integer registers and their contents
info scope -- List the variables local to a scope
info selectors -- All Objective-C selectors
info set -- Show all GDB settings
info sharedlibrary -- Status of loaded shared object libraries
info signals -- What debugger does when program gets various signals
info skip -- Display the status of skips
info source -- Information about the current source file
info sources -- Source files in the program
info stack -- Backtrace of the stack
info static-tracepoint-markers -- List target static tracepoints markers
info symbol -- Describe what symbol is at location ADDR
info target -- Names of targets and files being debugged
info tasks -- Provide information about all known Ada tasks
info terminal -- Print inferior's saved terminal status
info threads -- Display currently known threads
info tracepoints -- Status of specified tracepoints (all tracepoints if no argument)
info tvariables -- Status of trace state variables and their values
info type-printers -- GDB command to list all registered type-printers
info tracepoints -- Status of specified tracepoints (all tracepoints if no argument)
info types -- All type names
info unwinder -- GDB command to list unwinders
info variables -- All global and static variable names
info vector -- Print the status of the vector unit
info vtbl -- Show the virtual function table for a C++ object
info warranty -- Various kinds of warranty you do not have
info watchpoints -- Status of specified watchpoints (all watchpoints if no argument)
info win -- List of all displayed windows
info xmethod -- GDB command to list registered xmethod matchers

Type "help info" followed by info subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

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

17. 打造最小的elf可执行文件(英文视频交互版本) http://www.muppetlabs.com/~breadbox/software/tiny/techtalk.html

16. gdb调试 https://blog.csdn.net/gentleliu/article/details/45588011?depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2&utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2