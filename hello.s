#hello.s 
#
#     gcc -c hello.s && ld hello.o && ./a.out
#
# or
#
#     gcc -nostdlib hello.s && ./a.out
# ----------------------------------------------------------------------------------------

# gcc -m64 -c hello.s -gstabs  
#  ld -m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L /lib64 -L /usr/lib -lc -o hello hello.o
.data                    # 数据段声明
        msg : .string "Hello, world!\\n" # 要输出的字符串
        len = . - msg                   # 字串长度
.text                    # 代码段声明
.global _start           # 指定入口函数
         
_start:                  # 在屏幕上显示一个字符串
        movl $len, %edx  # 参数三：字符串长度
        movl $msg, %ecx  # 参数二：要显示的字符串
        movl $1, %ebx    # 参数一：文件描述符(stdout) 
        movl $1, %eax    # 系统调用号(sys_write) 
       	syscall       # 调用内核功能
         
                         # 退出程序
        #movl $0,%ebx     # 参数一：退出代码
        #movl $1,%eax     # 系统调用号(sys_exit) 
        #int  $0x80       # 调用内核功能

		## exit call
		#movq $0x2000001, %rax  
		## return code
		#movq $0, %rdi   
		## call exit
		#syscall 
	exit:
		mov  $60, %eax
		xor  %ebx, %ebx
		syscall 
		
