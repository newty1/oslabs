
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 90 11 40       	mov    $0x40119000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 90 11 00       	mov    %eax,0x119000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 80 11 00       	mov    $0x118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  100041:	2d 36 8a 11 00       	sub    $0x118a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 8a 11 00 	movl   $0x118a36,(%esp)
  100059:	e8 c5 5c 00 00       	call   105d23 <memset>

    cons_init();                // init the console
  10005e:	e8 ea 15 00 00       	call   10164d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 c0 5e 10 00 	movl   $0x105ec0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 dc 5e 10 00 	movl   $0x105edc,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management  完成物理内存管理
  100087:	e8 a1 43 00 00       	call   10442d <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 3d 17 00 00       	call   1017ce <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 c4 18 00 00       	call   10195a <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 11 0d 00 00       	call   100dac <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 8c 16 00 00       	call   10172c <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a0:	eb fe                	jmp    1000a0 <kern_init+0x6a>

001000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000af:	00 
  1000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000b7:	00 
  1000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000bf:	e8 03 0c 00 00       	call   100cc7 <mon_backtrace>
}
  1000c4:	90                   	nop
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
  1000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b0 ff ff ff       	call   1000a2 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000f6:	89 ec                	mov    %ebp,%esp
  1000f8:	5d                   	pop    %ebp
  1000f9:	c3                   	ret    

001000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100100:	8b 45 10             	mov    0x10(%ebp),%eax
  100103:	89 44 24 04          	mov    %eax,0x4(%esp)
  100107:	8b 45 08             	mov    0x8(%ebp),%eax
  10010a:	89 04 24             	mov    %eax,(%esp)
  10010d:	e8 b7 ff ff ff       	call   1000c9 <grade_backtrace1>
}
  100112:	90                   	nop
  100113:	89 ec                	mov    %ebp,%esp
  100115:	5d                   	pop    %ebp
  100116:	c3                   	ret    

00100117 <grade_backtrace>:

void
grade_backtrace(void) {
  100117:	55                   	push   %ebp
  100118:	89 e5                	mov    %esp,%ebp
  10011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011d:	b8 36 00 10 00       	mov    $0x100036,%eax
  100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100129:	ff 
  10012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100135:	e8 c0 ff ff ff       	call   1000fa <grade_backtrace0>
}
  10013a:	90                   	nop
  10013b:	89 ec                	mov    %ebp,%esp
  10013d:	5d                   	pop    %ebp
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 e1 5e 10 00 	movl   $0x105ee1,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 ef 5e 10 00 	movl   $0x105eef,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 fd 5e 10 00 	movl   $0x105efd,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 0b 5f 10 00 	movl   $0x105f0b,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 19 5f 10 00 	movl   $0x105f19,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 b0 11 00       	mov    %eax,0x11b000
}
  1001fa:	90                   	nop
  1001fb:	89 ec                	mov    %ebp,%esp
  1001fd:	5d                   	pop    %ebp
  1001fe:	c3                   	ret    

001001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001ff:	55                   	push   %ebp
  100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100208:	90                   	nop
  100209:	5d                   	pop    %ebp
  10020a:	c3                   	ret    

0010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020b:	55                   	push   %ebp
  10020c:	89 e5                	mov    %esp,%ebp
  10020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100211:	e8 29 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100216:	c7 04 24 28 5f 10 00 	movl   $0x105f28,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 48 5f 10 00 	movl   $0x105f48,(%esp)
  100233:	e8 1e 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_kernel();
  100238:	e8 c8 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023d:	e8 fd fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100242:	90                   	nop
  100243:	89 ec                	mov    %ebp,%esp
  100245:	5d                   	pop    %ebp
  100246:	c3                   	ret    

00100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100247:	55                   	push   %ebp
  100248:	89 e5                	mov    %esp,%ebp
  10024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100251:	74 13                	je     100266 <readline+0x1f>
        cprintf("%s", prompt);
  100253:	8b 45 08             	mov    0x8(%ebp),%eax
  100256:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025a:	c7 04 24 67 5f 10 00 	movl   $0x105f67,(%esp)
  100261:	e8 f0 00 00 00       	call   100356 <cprintf>
    }
    int i = 0, c;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10026d:	e8 73 01 00 00       	call   1003e5 <getchar>
  100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100279:	79 07                	jns    100282 <readline+0x3b>
            return NULL;
  10027b:	b8 00 00 00 00       	mov    $0x0,%eax
  100280:	eb 78                	jmp    1002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100286:	7e 28                	jle    1002b0 <readline+0x69>
  100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028f:	7f 1f                	jg     1002b0 <readline+0x69>
            cputchar(c);
  100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100294:	89 04 24             	mov    %eax,(%esp)
  100297:	e8 e2 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  10029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029f:	8d 50 01             	lea    0x1(%eax),%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a8:	88 90 20 b0 11 00    	mov    %dl,0x11b020(%eax)
  1002ae:	eb 45                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b4:	75 16                	jne    1002cc <readline+0x85>
  1002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ba:	7e 10                	jle    1002cc <readline+0x85>
            cputchar(c);
  1002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bf:	89 04 24             	mov    %eax,(%esp)
  1002c2:	e8 b7 00 00 00       	call   10037e <cputchar>
            i --;
  1002c7:	ff 4d f4             	decl   -0xc(%ebp)
  1002ca:	eb 29                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d0:	74 06                	je     1002d8 <readline+0x91>
  1002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d6:	75 95                	jne    10026d <readline+0x26>
            cputchar(c);
  1002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002db:	89 04 24             	mov    %eax,(%esp)
  1002de:	e8 9b 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e6:	05 20 b0 11 00       	add    $0x11b020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 b0 11 00       	mov    $0x11b020,%eax
  1002f3:	eb 05                	jmp    1002fa <readline+0xb3>
        c = getchar();
  1002f5:	e9 73 ff ff ff       	jmp    10026d <readline+0x26>
        }
    }
}
  1002fa:	89 ec                	mov    %ebp,%esp
  1002fc:	5d                   	pop    %ebp
  1002fd:	c3                   	ret    

001002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100304:	8b 45 08             	mov    0x8(%ebp),%eax
  100307:	89 04 24             	mov    %eax,(%esp)
  10030a:	e8 6d 13 00 00       	call   10167c <cons_putc>
    (*cnt) ++;
  10030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100312:	8b 00                	mov    (%eax),%eax
  100314:	8d 50 01             	lea    0x1(%eax),%edx
  100317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031a:	89 10                	mov    %edx,(%eax)
}
  10031c:	90                   	nop
  10031d:	89 ec                	mov    %ebp,%esp
  10031f:	5d                   	pop    %ebp
  100320:	c3                   	ret    

00100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100321:	55                   	push   %ebp
  100322:	89 e5                	mov    %esp,%ebp
  100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100343:	c7 04 24 fe 02 10 00 	movl   $0x1002fe,(%esp)
  10034a:	e8 ff 51 00 00       	call   10554e <vprintfmt>
    return cnt;
  10034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100352:	89 ec                	mov    %ebp,%esp
  100354:	5d                   	pop    %ebp
  100355:	c3                   	ret    

00100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100356:	55                   	push   %ebp
  100357:	89 e5                	mov    %esp,%ebp
  100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100365:	89 44 24 04          	mov    %eax,0x4(%esp)
  100369:	8b 45 08             	mov    0x8(%ebp),%eax
  10036c:	89 04 24             	mov    %eax,(%esp)
  10036f:	e8 ad ff ff ff       	call   100321 <vcprintf>
  100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	89 ec                	mov    %ebp,%esp
  10037c:	5d                   	pop    %ebp
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 ed 12 00 00       	call   10167c <cons_putc>
}
  10038f:	90                   	nop
  100390:	89 ec                	mov    %ebp,%esp
  100392:	5d                   	pop    %ebp
  100393:	c3                   	ret    

00100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100394:	55                   	push   %ebp
  100395:	89 e5                	mov    %esp,%ebp
  100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003a1:	eb 13                	jmp    1003b6 <cputs+0x22>
        cputch(c, &cnt);
  1003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ae:	89 04 24             	mov    %eax,(%esp)
  1003b1:	e8 48 ff ff ff       	call   1002fe <cputch>
    while ((c = *str ++) != '\0') {
  1003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b9:	8d 50 01             	lea    0x1(%eax),%edx
  1003bc:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bf:	0f b6 00             	movzbl (%eax),%eax
  1003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c9:	75 d8                	jne    1003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d9:	e8 20 ff ff ff       	call   1002fe <cputch>
    return cnt;
  1003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003e1:	89 ec                	mov    %ebp,%esp
  1003e3:	5d                   	pop    %ebp
  1003e4:	c3                   	ret    

001003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e5:	55                   	push   %ebp
  1003e6:	89 e5                	mov    %esp,%ebp
  1003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003eb:	90                   	nop
  1003ec:	e8 ca 12 00 00       	call   1016bb <cons_getc>
  1003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f8:	74 f2                	je     1003ec <getchar+0x7>
        /* do nothing */;
    return c;
  1003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003fd:	89 ec                	mov    %ebp,%esp
  1003ff:	5d                   	pop    %ebp
  100400:	c3                   	ret    

00100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100401:	55                   	push   %ebp
  100402:	89 e5                	mov    %esp,%ebp
  100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	8b 00                	mov    (%eax),%eax
  100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10041e:	e9 ca 00 00 00       	jmp    1004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100429:	01 d0                	add    %edx,%eax
  10042b:	89 c2                	mov    %eax,%edx
  10042d:	c1 ea 1f             	shr    $0x1f,%edx
  100430:	01 d0                	add    %edx,%eax
  100432:	d1 f8                	sar    %eax
  100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043d:	eb 03                	jmp    100442 <stab_binsearch+0x41>
            m --;
  10043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100448:	7c 1f                	jl     100469 <stab_binsearch+0x68>
  10044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044d:	89 d0                	mov    %edx,%eax
  10044f:	01 c0                	add    %eax,%eax
  100451:	01 d0                	add    %edx,%eax
  100453:	c1 e0 02             	shl    $0x2,%eax
  100456:	89 c2                	mov    %eax,%edx
  100458:	8b 45 08             	mov    0x8(%ebp),%eax
  10045b:	01 d0                	add    %edx,%eax
  10045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100461:	0f b6 c0             	movzbl %al,%eax
  100464:	39 45 14             	cmp    %eax,0x14(%ebp)
  100467:	75 d6                	jne    10043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046f:	7d 09                	jge    10047a <stab_binsearch+0x79>
            l = true_m + 1;
  100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100474:	40                   	inc    %eax
  100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100478:	eb 73                	jmp    1004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100484:	89 d0                	mov    %edx,%eax
  100486:	01 c0                	add    %eax,%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	89 c2                	mov    %eax,%edx
  10048f:	8b 45 08             	mov    0x8(%ebp),%eax
  100492:	01 d0                	add    %edx,%eax
  100494:	8b 40 08             	mov    0x8(%eax),%eax
  100497:	39 45 18             	cmp    %eax,0x18(%ebp)
  10049a:	76 11                	jbe    1004ad <stab_binsearch+0xac>
            *region_left = m;
  10049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a7:	40                   	inc    %eax
  1004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ab:	eb 40                	jmp    1004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b0:	89 d0                	mov    %edx,%eax
  1004b2:	01 c0                	add    %eax,%eax
  1004b4:	01 d0                	add    %edx,%eax
  1004b6:	c1 e0 02             	shl    $0x2,%eax
  1004b9:	89 c2                	mov    %eax,%edx
  1004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004be:	01 d0                	add    %edx,%eax
  1004c0:	8b 40 08             	mov    0x8(%eax),%eax
  1004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c6:	73 14                	jae    1004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	48                   	dec    %eax
  1004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004da:	eb 11                	jmp    1004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e2:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 2a ff ff ff    	jle    100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10050c:	eb 3e                	jmp    10054c <stab_binsearch+0x14b>
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 03                	jmp    10051b <stab_binsearch+0x11a>
  100518:	ff 4d fc             	decl   -0x4(%ebp)
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100523:	7e 1f                	jle    100544 <stab_binsearch+0x143>
  100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100528:	89 d0                	mov    %edx,%eax
  10052a:	01 c0                	add    %eax,%eax
  10052c:	01 d0                	add    %edx,%eax
  10052e:	c1 e0 02             	shl    $0x2,%eax
  100531:	89 c2                	mov    %eax,%edx
  100533:	8b 45 08             	mov    0x8(%ebp),%eax
  100536:	01 d0                	add    %edx,%eax
  100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053c:	0f b6 c0             	movzbl %al,%eax
  10053f:	39 45 14             	cmp    %eax,0x14(%ebp)
  100542:	75 d4                	jne    100518 <stab_binsearch+0x117>
        *region_left = l;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054a:	89 10                	mov    %edx,(%eax)
}
  10054c:	90                   	nop
  10054d:	89 ec                	mov    %ebp,%esp
  10054f:	5d                   	pop    %ebp
  100550:	c3                   	ret    

00100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100551:	55                   	push   %ebp
  100552:	89 e5                	mov    %esp,%ebp
  100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 00 6c 5f 10 00    	movl   $0x105f6c,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 6c 5f 10 00 	movl   $0x105f6c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100581:	8b 55 08             	mov    0x8(%ebp),%edx
  100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100587:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100591:	c7 45 f4 18 72 10 00 	movl   $0x107218,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 60 26 11 00 	movl   $0x112660,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec 61 26 11 00 	movl   $0x112661,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 cf 5b 11 00 	movl   $0x115bcf,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b3:	76 0b                	jbe    1005c0 <debuginfo_eip+0x6f>
  1005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b8:	48                   	dec    %eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x79>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 ab 02 00 00       	jmp    100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d7:	c1 f8 02             	sar    $0x2,%eax
  1005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e0:	48                   	dec    %eax
  1005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f2:	00 
  1005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100604:	89 04 24             	mov    %eax,(%esp)
  100607:	e8 f5 fd ff ff       	call   100401 <stab_binsearch>
    if (lfile == 0)
  10060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	75 0a                	jne    10061d <debuginfo_eip+0xcc>
        return -1;
  100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100618:	e9 58 02 00 00       	jmp    100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100637:	00 
  100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 b0 fd ff ff       	call   100401 <stab_binsearch>

    if (lfun <= rfun) {
  100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100657:	39 c2                	cmp    %eax,%edx
  100659:	7f 78                	jg     1006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	01 c0                	add    %eax,%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	c1 e0 02             	shl    $0x2,%eax
  100669:	89 c2                	mov    %eax,%edx
  10066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066e:	01 d0                	add    %edx,%eax
  100670:	8b 10                	mov    (%eax),%edx
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100678:	39 c2                	cmp    %eax,%edx
  10067a:	73 22                	jae    10069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067f:	89 c2                	mov    %eax,%edx
  100681:	89 d0                	mov    %edx,%eax
  100683:	01 c0                	add    %eax,%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	c1 e0 02             	shl    $0x2,%eax
  10068a:	89 c2                	mov    %eax,%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	8b 10                	mov    (%eax),%edx
  100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100696:	01 c2                	add    %eax,%edx
  100698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a1:	89 c2                	mov    %eax,%edx
  1006a3:	89 d0                	mov    %edx,%eax
  1006a5:	01 c0                	add    %eax,%eax
  1006a7:	01 d0                	add    %edx,%eax
  1006a9:	c1 e0 02             	shl    $0x2,%eax
  1006ac:	89 c2                	mov    %eax,%edx
  1006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	8b 50 08             	mov    0x8(%eax),%edx
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 10             	mov    0x10(%eax),%eax
  1006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d1:	eb 15                	jmp    1006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006eb:	8b 40 08             	mov    0x8(%eax),%eax
  1006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f5:	00 
  1006f6:	89 04 24             	mov    %eax,(%esp)
  1006f9:	e8 9d 54 00 00       	call   105b9b <strfind>
  1006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100701:	8b 4a 08             	mov    0x8(%edx),%ecx
  100704:	29 c8                	sub    %ecx,%eax
  100706:	89 c2                	mov    %eax,%edx
  100708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070e:	8b 45 08             	mov    0x8(%ebp),%eax
  100711:	89 44 24 10          	mov    %eax,0x10(%esp)
  100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10071c:	00 
  10071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100720:	89 44 24 08          	mov    %eax,0x8(%esp)
  100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100727:	89 44 24 04          	mov    %eax,0x4(%esp)
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	89 04 24             	mov    %eax,(%esp)
  100731:	e8 cb fc ff ff       	call   100401 <stab_binsearch>
    if (lline <= rline) {
  100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	39 c2                	cmp    %eax,%edx
  10073e:	7f 23                	jg     100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	89 d0                	mov    %edx,%eax
  100747:	01 c0                	add    %eax,%eax
  100749:	01 d0                	add    %edx,%eax
  10074b:	c1 e0 02             	shl    $0x2,%eax
  10074e:	89 c2                	mov    %eax,%edx
  100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100759:	89 c2                	mov    %eax,%edx
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100761:	eb 11                	jmp    100774 <debuginfo_eip+0x223>
        return -1;
  100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100768:	e9 08 01 00 00       	jmp    100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100770:	48                   	dec    %eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10077a:	39 c2                	cmp    %eax,%edx
  10077c:	7c 56                	jl     1007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100781:	89 c2                	mov    %eax,%edx
  100783:	89 d0                	mov    %edx,%eax
  100785:	01 c0                	add    %eax,%eax
  100787:	01 d0                	add    %edx,%eax
  100789:	c1 e0 02             	shl    $0x2,%eax
  10078c:	89 c2                	mov    %eax,%edx
  10078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100791:	01 d0                	add    %edx,%eax
  100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100797:	3c 84                	cmp    $0x84,%al
  100799:	74 39                	je     1007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	89 d0                	mov    %edx,%eax
  1007a2:	01 c0                	add    %eax,%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	c1 e0 02             	shl    $0x2,%eax
  1007a9:	89 c2                	mov    %eax,%edx
  1007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b4:	3c 64                	cmp    $0x64,%al
  1007b6:	75 b5                	jne    10076d <debuginfo_eip+0x21c>
  1007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	89 d0                	mov    %edx,%eax
  1007bf:	01 c0                	add    %eax,%eax
  1007c1:	01 d0                	add    %edx,%eax
  1007c3:	c1 e0 02             	shl    $0x2,%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007cb:	01 d0                	add    %edx,%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	85 c0                	test   %eax,%eax
  1007d2:	74 99                	je     10076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007da:	39 c2                	cmp    %eax,%edx
  1007dc:	7c 42                	jl     100820 <debuginfo_eip+0x2cf>
  1007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e1:	89 c2                	mov    %eax,%edx
  1007e3:	89 d0                	mov    %edx,%eax
  1007e5:	01 c0                	add    %eax,%eax
  1007e7:	01 d0                	add    %edx,%eax
  1007e9:	c1 e0 02             	shl    $0x2,%eax
  1007ec:	89 c2                	mov    %eax,%edx
  1007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f1:	01 d0                	add    %edx,%eax
  1007f3:	8b 10                	mov    (%eax),%edx
  1007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 46                	jge    100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	40                   	inc    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100831:	eb 16                	jmp    100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100833:	8b 45 0c             	mov    0xc(%ebp),%eax
  100836:	8b 40 14             	mov    0x14(%eax),%eax
  100839:	8d 50 01             	lea    0x1(%eax),%edx
  10083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100845:	40                   	inc    %eax
  100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10084f:	39 c2                	cmp    %eax,%edx
  100851:	7d 1d                	jge    100870 <debuginfo_eip+0x31f>
  100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	89 d0                	mov    %edx,%eax
  10085a:	01 c0                	add    %eax,%eax
  10085c:	01 d0                	add    %edx,%eax
  10085e:	c1 e0 02             	shl    $0x2,%eax
  100861:	89 c2                	mov    %eax,%edx
  100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086c:	3c a0                	cmp    $0xa0,%al
  10086e:	74 c3                	je     100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100875:	89 ec                	mov    %ebp,%esp
  100877:	5d                   	pop    %ebp
  100878:	c3                   	ret    

00100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100879:	55                   	push   %ebp
  10087a:	89 e5                	mov    %esp,%ebp
  10087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087f:	c7 04 24 76 5f 10 00 	movl   $0x105f76,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 8f 5f 10 00 	movl   $0x105f8f,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 af 5e 10 	movl   $0x105eaf,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 a7 5f 10 00 	movl   $0x105fa7,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 bf 5f 10 00 	movl   $0x105fbf,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 2c bf 11 	movl   $0x11bf2c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 d7 5f 10 00 	movl   $0x105fd7,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 f0 5f 10 00 	movl   $0x105ff0,(%esp)
  100903:	e8 4e fa ff ff       	call   100356 <cprintf>
}
  100908:	90                   	nop
  100909:	89 ec                	mov    %ebp,%esp
  10090b:	5d                   	pop    %ebp
  10090c:	c3                   	ret    

0010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100919:	89 44 24 04          	mov    %eax,0x4(%esp)
  10091d:	8b 45 08             	mov    0x8(%ebp),%eax
  100920:	89 04 24             	mov    %eax,(%esp)
  100923:	e8 29 fc ff ff       	call   100551 <debuginfo_eip>
  100928:	85 c0                	test   %eax,%eax
  10092a:	74 15                	je     100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100933:	c7 04 24 1a 60 10 00 	movl   $0x10601a,(%esp)
  10093a:	e8 17 fa ff ff       	call   100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093f:	eb 6c                	jmp    1009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100948:	eb 1b                	jmp    100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100950:	01 d0                	add    %edx,%eax
  100952:	0f b6 10             	movzbl (%eax),%edx
  100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095e:	01 c8                	add    %ecx,%eax
  100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100962:	ff 45 f4             	incl   -0xc(%ebp)
  100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10096b:	7c dd                	jl     10094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100976:	01 d0                	add    %edx,%eax
  100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097e:	8b 45 08             	mov    0x8(%ebp),%eax
  100981:	29 d0                	sub    %edx,%eax
  100983:	89 c1                	mov    %eax,%ecx
  100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100999:	89 54 24 08          	mov    %edx,0x8(%esp)
  10099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a1:	c7 04 24 36 60 10 00 	movl   $0x106036,(%esp)
  1009a8:	e8 a9 f9 ff ff       	call   100356 <cprintf>
}
  1009ad:	90                   	nop
  1009ae:	89 ec                	mov    %ebp,%esp
  1009b0:	5d                   	pop    %ebp
  1009b1:	c3                   	ret    

001009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b2:	55                   	push   %ebp
  1009b3:	89 e5                	mov    %esp,%ebp
  1009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c1:	89 ec                	mov    %ebp,%esp
  1009c3:	5d                   	pop    %ebp
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry,在跳转到kernel entry时 已经被置为0了, the value of ebp has been set to zero, that's the boundary.
 * 已经置为0
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cb:	89 e8                	mov    %ebp,%eax
  1009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp , eip ;
    ebp=read_ebp();
  1009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    eip=read_eip();
  1009d6:	e8 d7 ff ff ff       	call   1009b2 <read_eip>
  1009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i=0;
  1009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(i<STACKFRAME_DEPTH && ebp!=0){//宏定义20
  1009e5:	e9 84 00 00 00       	jmp    100a6e <print_stackframe+0xa9>
        i++;
  1009ea:	ff 45 ec             	incl   -0x14(%ebp)
       cprintf("ebp:0x%08x eip: 0x%08x ",ebp,eip);
  1009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fb:	c7 04 24 48 60 10 00 	movl   $0x106048,(%esp)
  100a02:	e8 4f f9 ff ff       	call   100356 <cprintf>
       uint32_t *temp =(uint32_t*)ebp +2;//参数的首地址 一个是4 所以加2 而不是加八
  100a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a0a:	83 c0 08             	add    $0x8,%eax
  100a0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 0; j < 4; j ++) {
  100a10:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a17:	eb 24                	jmp    100a3d <print_stackframe+0x78>
            cprintf("0x%08x ", temp[j]); //打印4个参数
  100a19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a26:	01 d0                	add    %edx,%eax
  100a28:	8b 00                	mov    (%eax),%eax
  100a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2e:	c7 04 24 60 60 10 00 	movl   $0x106060,(%esp)
  100a35:	e8 1c f9 ff ff       	call   100356 <cprintf>
        for (int j = 0; j < 4; j ++) {
  100a3a:	ff 45 e8             	incl   -0x18(%ebp)
  100a3d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a41:	7e d6                	jle    100a19 <print_stackframe+0x54>
        }
        
        cprintf("\n");
  100a43:	c7 04 24 68 60 10 00 	movl   $0x106068,(%esp)
  100a4a:	e8 07 f9 ff ff       	call   100356 <cprintf>
        print_debuginfo(eip-1);
  100a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a52:	48                   	dec    %eax
  100a53:	89 04 24             	mov    %eax,(%esp)
  100a56:	e8 b2 fe ff ff       	call   10090d <print_debuginfo>
       eip = ((uint32_t *)ebp)[1]; //更新eip //eip就是返回地址 存在ebp+4个字节处
  100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5e:	83 c0 04             	add    $0x4,%eax
  100a61:	8b 00                	mov    (%eax),%eax
  100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0]; //更新ebp
  100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a69:	8b 00                	mov    (%eax),%eax
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(i<STACKFRAME_DEPTH && ebp!=0){//宏定义20
  100a6e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a72:	7f 0a                	jg     100a7e <print_stackframe+0xb9>
  100a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a78:	0f 85 6c ff ff ff    	jne    1009ea <print_stackframe+0x25>

}
} 
  100a7e:	90                   	nop
  100a7f:	89 ec                	mov    %ebp,%esp
  100a81:	5d                   	pop    %ebp
  100a82:	c3                   	ret    

00100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a90:	eb 0c                	jmp    100a9e <parse+0x1b>
            *buf ++ = '\0';
  100a92:	8b 45 08             	mov    0x8(%ebp),%eax
  100a95:	8d 50 01             	lea    0x1(%eax),%edx
  100a98:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9b:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa1:	0f b6 00             	movzbl (%eax),%eax
  100aa4:	84 c0                	test   %al,%al
  100aa6:	74 1d                	je     100ac5 <parse+0x42>
  100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  100aab:	0f b6 00             	movzbl (%eax),%eax
  100aae:	0f be c0             	movsbl %al,%eax
  100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab5:	c7 04 24 ec 60 10 00 	movl   $0x1060ec,(%esp)
  100abc:	e8 a6 50 00 00       	call   105b67 <strchr>
  100ac1:	85 c0                	test   %eax,%eax
  100ac3:	75 cd                	jne    100a92 <parse+0xf>
        }
        if (*buf == '\0') {
  100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac8:	0f b6 00             	movzbl (%eax),%eax
  100acb:	84 c0                	test   %al,%al
  100acd:	74 65                	je     100b34 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100acf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad3:	75 14                	jne    100ae9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100adc:	00 
  100add:	c7 04 24 f1 60 10 00 	movl   $0x1060f1,(%esp)
  100ae4:	e8 6d f8 ff ff       	call   100356 <cprintf>
        }
        argv[argc ++] = buf;
  100ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aec:	8d 50 01             	lea    0x1(%eax),%edx
  100aef:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  100afc:	01 c2                	add    %eax,%edx
  100afe:	8b 45 08             	mov    0x8(%ebp),%eax
  100b01:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b03:	eb 03                	jmp    100b08 <parse+0x85>
            buf ++;
  100b05:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b08:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0b:	0f b6 00             	movzbl (%eax),%eax
  100b0e:	84 c0                	test   %al,%al
  100b10:	74 8c                	je     100a9e <parse+0x1b>
  100b12:	8b 45 08             	mov    0x8(%ebp),%eax
  100b15:	0f b6 00             	movzbl (%eax),%eax
  100b18:	0f be c0             	movsbl %al,%eax
  100b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b1f:	c7 04 24 ec 60 10 00 	movl   $0x1060ec,(%esp)
  100b26:	e8 3c 50 00 00       	call   105b67 <strchr>
  100b2b:	85 c0                	test   %eax,%eax
  100b2d:	74 d6                	je     100b05 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b2f:	e9 6a ff ff ff       	jmp    100a9e <parse+0x1b>
            break;
  100b34:	90                   	nop
        }
    }
    return argc;
  100b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b38:	89 ec                	mov    %ebp,%esp
  100b3a:	5d                   	pop    %ebp
  100b3b:	c3                   	ret    

00100b3c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3c:	55                   	push   %ebp
  100b3d:	89 e5                	mov    %esp,%ebp
  100b3f:	83 ec 68             	sub    $0x68,%esp
  100b42:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4f:	89 04 24             	mov    %eax,(%esp)
  100b52:	e8 2c ff ff ff       	call   100a83 <parse>
  100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5e:	75 0a                	jne    100b6a <runcmd+0x2e>
        return 0;
  100b60:	b8 00 00 00 00       	mov    $0x0,%eax
  100b65:	e9 83 00 00 00       	jmp    100bed <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b71:	eb 5a                	jmp    100bcd <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b73:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b76:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b79:	89 c8                	mov    %ecx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 c8                	add    %ecx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 80 11 00       	add    $0x118000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 36 4f 00 00       	call   105acb <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 31                	jne    100bca <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 08 80 11 00       	add    $0x118008,%eax
  100baa:	8b 10                	mov    (%eax),%edx
  100bac:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100baf:	83 c0 04             	add    $0x4,%eax
  100bb2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bb5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bc3:	89 1c 24             	mov    %ebx,(%esp)
  100bc6:	ff d2                	call   *%edx
  100bc8:	eb 23                	jmp    100bed <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bca:	ff 45 f4             	incl   -0xc(%ebp)
  100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd0:	83 f8 02             	cmp    $0x2,%eax
  100bd3:	76 9e                	jbe    100b73 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdc:	c7 04 24 0f 61 10 00 	movl   $0x10610f,(%esp)
  100be3:	e8 6e f7 ff ff       	call   100356 <cprintf>
    return 0;
  100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100bf0:	89 ec                	mov    %ebp,%esp
  100bf2:	5d                   	pop    %ebp
  100bf3:	c3                   	ret    

00100bf4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf4:	55                   	push   %ebp
  100bf5:	89 e5                	mov    %esp,%ebp
  100bf7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bfa:	c7 04 24 28 61 10 00 	movl   $0x106128,(%esp)
  100c01:	e8 50 f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c06:	c7 04 24 50 61 10 00 	movl   $0x106150,(%esp)
  100c0d:	e8 44 f7 ff ff       	call   100356 <cprintf>

    if (tf != NULL) {
  100c12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c16:	74 0b                	je     100c23 <kmonitor+0x2f>
        print_trapframe(tf);
  100c18:	8b 45 08             	mov    0x8(%ebp),%eax
  100c1b:	89 04 24             	mov    %eax,(%esp)
  100c1e:	e8 f2 0e 00 00       	call   101b15 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c23:	c7 04 24 75 61 10 00 	movl   $0x106175,(%esp)
  100c2a:	e8 18 f6 ff ff       	call   100247 <readline>
  100c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c36:	74 eb                	je     100c23 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c38:	8b 45 08             	mov    0x8(%ebp),%eax
  100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c42:	89 04 24             	mov    %eax,(%esp)
  100c45:	e8 f2 fe ff ff       	call   100b3c <runcmd>
  100c4a:	85 c0                	test   %eax,%eax
  100c4c:	78 02                	js     100c50 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c4e:	eb d3                	jmp    100c23 <kmonitor+0x2f>
                break;
  100c50:	90                   	nop
            }
        }
    }
}
  100c51:	90                   	nop
  100c52:	89 ec                	mov    %ebp,%esp
  100c54:	5d                   	pop    %ebp
  100c55:	c3                   	ret    

00100c56 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c56:	55                   	push   %ebp
  100c57:	89 e5                	mov    %esp,%ebp
  100c59:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c63:	eb 3d                	jmp    100ca2 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c68:	89 d0                	mov    %edx,%eax
  100c6a:	01 c0                	add    %eax,%eax
  100c6c:	01 d0                	add    %edx,%eax
  100c6e:	c1 e0 02             	shl    $0x2,%eax
  100c71:	05 04 80 11 00       	add    $0x118004,%eax
  100c76:	8b 10                	mov    (%eax),%edx
  100c78:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c7b:	89 c8                	mov    %ecx,%eax
  100c7d:	01 c0                	add    %eax,%eax
  100c7f:	01 c8                	add    %ecx,%eax
  100c81:	c1 e0 02             	shl    $0x2,%eax
  100c84:	05 00 80 11 00       	add    $0x118000,%eax
  100c89:	8b 00                	mov    (%eax),%eax
  100c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c93:	c7 04 24 79 61 10 00 	movl   $0x106179,(%esp)
  100c9a:	e8 b7 f6 ff ff       	call   100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9f:	ff 45 f4             	incl   -0xc(%ebp)
  100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca5:	83 f8 02             	cmp    $0x2,%eax
  100ca8:	76 bb                	jbe    100c65 <mon_help+0xf>
    }
    return 0;
  100caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caf:	89 ec                	mov    %ebp,%esp
  100cb1:	5d                   	pop    %ebp
  100cb2:	c3                   	ret    

00100cb3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cb3:	55                   	push   %ebp
  100cb4:	89 e5                	mov    %esp,%ebp
  100cb6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb9:	e8 bb fb ff ff       	call   100879 <print_kerninfo>
    return 0;
  100cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc3:	89 ec                	mov    %ebp,%esp
  100cc5:	5d                   	pop    %ebp
  100cc6:	c3                   	ret    

00100cc7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cc7:	55                   	push   %ebp
  100cc8:	89 e5                	mov    %esp,%ebp
  100cca:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ccd:	e8 f3 fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd7:	89 ec                	mov    %ebp,%esp
  100cd9:	5d                   	pop    %ebp
  100cda:	c3                   	ret    

00100cdb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cdb:	55                   	push   %ebp
  100cdc:	89 e5                	mov    %esp,%ebp
  100cde:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ce1:	a1 20 b4 11 00       	mov    0x11b420,%eax
  100ce6:	85 c0                	test   %eax,%eax
  100ce8:	75 5b                	jne    100d45 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cea:	c7 05 20 b4 11 00 01 	movl   $0x1,0x11b420
  100cf1:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cf4:	8d 45 14             	lea    0x14(%ebp),%eax
  100cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d01:	8b 45 08             	mov    0x8(%ebp),%eax
  100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d08:	c7 04 24 82 61 10 00 	movl   $0x106182,(%esp)
  100d0f:	e8 42 f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  100d1e:	89 04 24             	mov    %eax,(%esp)
  100d21:	e8 fb f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d26:	c7 04 24 9e 61 10 00 	movl   $0x10619e,(%esp)
  100d2d:	e8 24 f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d32:	c7 04 24 a0 61 10 00 	movl   $0x1061a0,(%esp)
  100d39:	e8 18 f6 ff ff       	call   100356 <cprintf>
    print_stackframe();
  100d3e:	e8 82 fc ff ff       	call   1009c5 <print_stackframe>
  100d43:	eb 01                	jmp    100d46 <__panic+0x6b>
        goto panic_dead;
  100d45:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d46:	e8 e9 09 00 00       	call   101734 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d52:	e8 9d fe ff ff       	call   100bf4 <kmonitor>
  100d57:	eb f2                	jmp    100d4b <__panic+0x70>

00100d59 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d59:	55                   	push   %ebp
  100d5a:	89 e5                	mov    %esp,%ebp
  100d5c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d5f:	8d 45 14             	lea    0x14(%ebp),%eax
  100d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d68:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  100d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d73:	c7 04 24 b2 61 10 00 	movl   $0x1061b2,(%esp)
  100d7a:	e8 d7 f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d86:	8b 45 10             	mov    0x10(%ebp),%eax
  100d89:	89 04 24             	mov    %eax,(%esp)
  100d8c:	e8 90 f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d91:	c7 04 24 9e 61 10 00 	movl   $0x10619e,(%esp)
  100d98:	e8 b9 f5 ff ff       	call   100356 <cprintf>
    va_end(ap);
}
  100d9d:	90                   	nop
  100d9e:	89 ec                	mov    %ebp,%esp
  100da0:	5d                   	pop    %ebp
  100da1:	c3                   	ret    

00100da2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100da2:	55                   	push   %ebp
  100da3:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100da5:	a1 20 b4 11 00       	mov    0x11b420,%eax
}
  100daa:	5d                   	pop    %ebp
  100dab:	c3                   	ret    

00100dac <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dac:	55                   	push   %ebp
  100dad:	89 e5                	mov    %esp,%ebp
  100daf:	83 ec 28             	sub    $0x28,%esp
  100db2:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100db8:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dbc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dc0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dc4:	ee                   	out    %al,(%dx)
}
  100dc5:	90                   	nop
  100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd8:	ee                   	out    %al,(%dx)
}
  100dd9:	90                   	nop
  100dda:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100de0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100de4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100de8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dec:	ee                   	out    %al,(%dx)
}
  100ded:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dee:	c7 05 24 b4 11 00 00 	movl   $0x0,0x11b424
  100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df8:	c7 04 24 d0 61 10 00 	movl   $0x1061d0,(%esp)
  100dff:	e8 52 f5 ff ff       	call   100356 <cprintf>
    pic_enable(IRQ_TIMER);
  100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e0b:	e8 89 09 00 00       	call   101799 <pic_enable>
}
  100e10:	90                   	nop
  100e11:	89 ec                	mov    %ebp,%esp
  100e13:	5d                   	pop    %ebp
  100e14:	c3                   	ret    

00100e15 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e15:	55                   	push   %ebp
  100e16:	89 e5                	mov    %esp,%ebp
  100e18:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e1b:	9c                   	pushf  
  100e1c:	58                   	pop    %eax
  100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e23:	25 00 02 00 00       	and    $0x200,%eax
  100e28:	85 c0                	test   %eax,%eax
  100e2a:	74 0c                	je     100e38 <__intr_save+0x23>
        intr_disable();
  100e2c:	e8 03 09 00 00       	call   101734 <intr_disable>
        return 1;
  100e31:	b8 01 00 00 00       	mov    $0x1,%eax
  100e36:	eb 05                	jmp    100e3d <__intr_save+0x28>
    }
    return 0;
  100e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e3d:	89 ec                	mov    %ebp,%esp
  100e3f:	5d                   	pop    %ebp
  100e40:	c3                   	ret    

00100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e41:	55                   	push   %ebp
  100e42:	89 e5                	mov    %esp,%ebp
  100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e4b:	74 05                	je     100e52 <__intr_restore+0x11>
        intr_enable();
  100e4d:	e8 da 08 00 00       	call   10172c <intr_enable>
    }
}
  100e52:	90                   	nop
  100e53:	89 ec                	mov    %ebp,%esp
  100e55:	5d                   	pop    %ebp
  100e56:	c3                   	ret    

00100e57 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e57:	55                   	push   %ebp
  100e58:	89 e5                	mov    %esp,%ebp
  100e5a:	83 ec 10             	sub    $0x10,%esp
  100e5d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e63:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e67:	89 c2                	mov    %eax,%edx
  100e69:	ec                   	in     (%dx),%al
  100e6a:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e6d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e73:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e77:	89 c2                	mov    %eax,%edx
  100e79:	ec                   	in     (%dx),%al
  100e7a:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e7d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e83:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e87:	89 c2                	mov    %eax,%edx
  100e89:	ec                   	in     (%dx),%al
  100e8a:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e8d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e93:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e97:	89 c2                	mov    %eax,%edx
  100e99:	ec                   	in     (%dx),%al
  100e9a:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e9d:	90                   	nop
  100e9e:	89 ec                	mov    %ebp,%esp
  100ea0:	5d                   	pop    %ebp
  100ea1:	c3                   	ret    

00100ea2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ea2:	55                   	push   %ebp
  100ea3:	89 e5                	mov    %esp,%ebp
  100ea5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100ea8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb2:	0f b7 00             	movzwl (%eax),%eax
  100eb5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec4:	0f b7 00             	movzwl (%eax),%eax
  100ec7:	0f b7 c0             	movzwl %ax,%eax
  100eca:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ecf:	74 12                	je     100ee3 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ed1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ed8:	66 c7 05 46 b4 11 00 	movw   $0x3b4,0x11b446
  100edf:	b4 03 
  100ee1:	eb 13                	jmp    100ef6 <cga_init+0x54>
    } else {
        *cp = was;
  100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eea:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100eed:	66 c7 05 46 b4 11 00 	movw   $0x3d4,0x11b446
  100ef4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ef6:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100efd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f01:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f05:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f09:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f0d:	ee                   	out    %al,(%dx)
}
  100f0e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f0f:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f16:	40                   	inc    %eax
  100f17:	0f b7 c0             	movzwl %ax,%eax
  100f1a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f1e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f22:	89 c2                	mov    %eax,%edx
  100f24:	ec                   	in     (%dx),%al
  100f25:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f28:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f2c:	0f b6 c0             	movzbl %al,%eax
  100f2f:	c1 e0 08             	shl    $0x8,%eax
  100f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f35:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f3c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f40:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f44:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f48:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f4c:	ee                   	out    %al,(%dx)
}
  100f4d:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f4e:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f55:	40                   	inc    %eax
  100f56:	0f b7 c0             	movzwl %ax,%eax
  100f59:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f5d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f61:	89 c2                	mov    %eax,%edx
  100f63:	ec                   	in     (%dx),%al
  100f64:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f67:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f6b:	0f b6 c0             	movzbl %al,%eax
  100f6e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f74:	a3 40 b4 11 00       	mov    %eax,0x11b440
    crt_pos = pos;
  100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7c:	0f b7 c0             	movzwl %ax,%eax
  100f7f:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
}
  100f85:	90                   	nop
  100f86:	89 ec                	mov    %ebp,%esp
  100f88:	5d                   	pop    %ebp
  100f89:	c3                   	ret    

00100f8a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f8a:	55                   	push   %ebp
  100f8b:	89 e5                	mov    %esp,%ebp
  100f8d:	83 ec 48             	sub    $0x48,%esp
  100f90:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f96:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f9a:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f9e:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fa2:	ee                   	out    %al,(%dx)
}
  100fa3:	90                   	nop
  100fa4:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100faa:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fb2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fb6:	ee                   	out    %al,(%dx)
}
  100fb7:	90                   	nop
  100fb8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fbe:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fc2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fc6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fca:	ee                   	out    %al,(%dx)
}
  100fcb:	90                   	nop
  100fcc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fd2:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fd6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fda:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fde:	ee                   	out    %al,(%dx)
}
  100fdf:	90                   	nop
  100fe0:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fe6:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fea:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fee:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ff2:	ee                   	out    %al,(%dx)
}
  100ff3:	90                   	nop
  100ff4:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100ffa:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ffe:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101002:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101006:	ee                   	out    %al,(%dx)
}
  101007:	90                   	nop
  101008:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  10100e:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101012:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101016:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10101a:	ee                   	out    %al,(%dx)
}
  10101b:	90                   	nop
  10101c:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101022:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101026:	89 c2                	mov    %eax,%edx
  101028:	ec                   	in     (%dx),%al
  101029:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  10102c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101030:	3c ff                	cmp    $0xff,%al
  101032:	0f 95 c0             	setne  %al
  101035:	0f b6 c0             	movzbl %al,%eax
  101038:	a3 48 b4 11 00       	mov    %eax,0x11b448
  10103d:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101043:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101047:	89 c2                	mov    %eax,%edx
  101049:	ec                   	in     (%dx),%al
  10104a:	88 45 f1             	mov    %al,-0xf(%ebp)
  10104d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101053:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101057:	89 c2                	mov    %eax,%edx
  101059:	ec                   	in     (%dx),%al
  10105a:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10105d:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101062:	85 c0                	test   %eax,%eax
  101064:	74 0c                	je     101072 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101066:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10106d:	e8 27 07 00 00       	call   101799 <pic_enable>
    }
}
  101072:	90                   	nop
  101073:	89 ec                	mov    %ebp,%esp
  101075:	5d                   	pop    %ebp
  101076:	c3                   	ret    

00101077 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101077:	55                   	push   %ebp
  101078:	89 e5                	mov    %esp,%ebp
  10107a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10107d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101084:	eb 08                	jmp    10108e <lpt_putc_sub+0x17>
        delay();
  101086:	e8 cc fd ff ff       	call   100e57 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10108b:	ff 45 fc             	incl   -0x4(%ebp)
  10108e:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101094:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101098:	89 c2                	mov    %eax,%edx
  10109a:	ec                   	in     (%dx),%al
  10109b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10109e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010a2:	84 c0                	test   %al,%al
  1010a4:	78 09                	js     1010af <lpt_putc_sub+0x38>
  1010a6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010ad:	7e d7                	jle    101086 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010af:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b2:	0f b6 c0             	movzbl %al,%eax
  1010b5:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010bb:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c6:	ee                   	out    %al,(%dx)
}
  1010c7:	90                   	nop
  1010c8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010ce:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010d2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010d6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010da:	ee                   	out    %al,(%dx)
}
  1010db:	90                   	nop
  1010dc:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010e2:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010ee:	ee                   	out    %al,(%dx)
}
  1010ef:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010f0:	90                   	nop
  1010f1:	89 ec                	mov    %ebp,%esp
  1010f3:	5d                   	pop    %ebp
  1010f4:	c3                   	ret    

001010f5 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010f5:	55                   	push   %ebp
  1010f6:	89 e5                	mov    %esp,%ebp
  1010f8:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010fb:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010ff:	74 0d                	je     10110e <lpt_putc+0x19>
        lpt_putc_sub(c);
  101101:	8b 45 08             	mov    0x8(%ebp),%eax
  101104:	89 04 24             	mov    %eax,(%esp)
  101107:	e8 6b ff ff ff       	call   101077 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10110c:	eb 24                	jmp    101132 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  10110e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101115:	e8 5d ff ff ff       	call   101077 <lpt_putc_sub>
        lpt_putc_sub(' ');
  10111a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101121:	e8 51 ff ff ff       	call   101077 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101126:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10112d:	e8 45 ff ff ff       	call   101077 <lpt_putc_sub>
}
  101132:	90                   	nop
  101133:	89 ec                	mov    %ebp,%esp
  101135:	5d                   	pop    %ebp
  101136:	c3                   	ret    

00101137 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101137:	55                   	push   %ebp
  101138:	89 e5                	mov    %esp,%ebp
  10113a:	83 ec 38             	sub    $0x38,%esp
  10113d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  101140:	8b 45 08             	mov    0x8(%ebp),%eax
  101143:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101148:	85 c0                	test   %eax,%eax
  10114a:	75 07                	jne    101153 <cga_putc+0x1c>
        c |= 0x0700;
  10114c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101153:	8b 45 08             	mov    0x8(%ebp),%eax
  101156:	0f b6 c0             	movzbl %al,%eax
  101159:	83 f8 0d             	cmp    $0xd,%eax
  10115c:	74 72                	je     1011d0 <cga_putc+0x99>
  10115e:	83 f8 0d             	cmp    $0xd,%eax
  101161:	0f 8f a3 00 00 00    	jg     10120a <cga_putc+0xd3>
  101167:	83 f8 08             	cmp    $0x8,%eax
  10116a:	74 0a                	je     101176 <cga_putc+0x3f>
  10116c:	83 f8 0a             	cmp    $0xa,%eax
  10116f:	74 4c                	je     1011bd <cga_putc+0x86>
  101171:	e9 94 00 00 00       	jmp    10120a <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101176:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10117d:	85 c0                	test   %eax,%eax
  10117f:	0f 84 af 00 00 00    	je     101234 <cga_putc+0xfd>
            crt_pos --;
  101185:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10118c:	48                   	dec    %eax
  10118d:	0f b7 c0             	movzwl %ax,%eax
  101190:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101196:	8b 45 08             	mov    0x8(%ebp),%eax
  101199:	98                   	cwtl   
  10119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10119f:	98                   	cwtl   
  1011a0:	83 c8 20             	or     $0x20,%eax
  1011a3:	98                   	cwtl   
  1011a4:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  1011aa:	0f b7 15 44 b4 11 00 	movzwl 0x11b444,%edx
  1011b1:	01 d2                	add    %edx,%edx
  1011b3:	01 ca                	add    %ecx,%edx
  1011b5:	0f b7 c0             	movzwl %ax,%eax
  1011b8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011bb:	eb 77                	jmp    101234 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011bd:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011c4:	83 c0 50             	add    $0x50,%eax
  1011c7:	0f b7 c0             	movzwl %ax,%eax
  1011ca:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011d0:	0f b7 1d 44 b4 11 00 	movzwl 0x11b444,%ebx
  1011d7:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  1011de:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011e3:	89 c8                	mov    %ecx,%eax
  1011e5:	f7 e2                	mul    %edx
  1011e7:	c1 ea 06             	shr    $0x6,%edx
  1011ea:	89 d0                	mov    %edx,%eax
  1011ec:	c1 e0 02             	shl    $0x2,%eax
  1011ef:	01 d0                	add    %edx,%eax
  1011f1:	c1 e0 04             	shl    $0x4,%eax
  1011f4:	29 c1                	sub    %eax,%ecx
  1011f6:	89 ca                	mov    %ecx,%edx
  1011f8:	0f b7 d2             	movzwl %dx,%edx
  1011fb:	89 d8                	mov    %ebx,%eax
  1011fd:	29 d0                	sub    %edx,%eax
  1011ff:	0f b7 c0             	movzwl %ax,%eax
  101202:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
        break;
  101208:	eb 2b                	jmp    101235 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10120a:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  101210:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101217:	8d 50 01             	lea    0x1(%eax),%edx
  10121a:	0f b7 d2             	movzwl %dx,%edx
  10121d:	66 89 15 44 b4 11 00 	mov    %dx,0x11b444
  101224:	01 c0                	add    %eax,%eax
  101226:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101229:	8b 45 08             	mov    0x8(%ebp),%eax
  10122c:	0f b7 c0             	movzwl %ax,%eax
  10122f:	66 89 02             	mov    %ax,(%edx)
        break;
  101232:	eb 01                	jmp    101235 <cga_putc+0xfe>
        break;
  101234:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101235:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10123c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101241:	76 5e                	jbe    1012a1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101243:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101248:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10124e:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101253:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10125a:	00 
  10125b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10125f:	89 04 24             	mov    %eax,(%esp)
  101262:	e8 fe 4a 00 00       	call   105d65 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101267:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10126e:	eb 15                	jmp    101285 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101270:	8b 15 40 b4 11 00    	mov    0x11b440,%edx
  101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101279:	01 c0                	add    %eax,%eax
  10127b:	01 d0                	add    %edx,%eax
  10127d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101282:	ff 45 f4             	incl   -0xc(%ebp)
  101285:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10128c:	7e e2                	jle    101270 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  10128e:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101295:	83 e8 50             	sub    $0x50,%eax
  101298:	0f b7 c0             	movzwl %ax,%eax
  10129b:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012a1:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012a8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012ac:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
}
  1012b9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012ba:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1012c1:	c1 e8 08             	shr    $0x8,%eax
  1012c4:	0f b7 c0             	movzwl %ax,%eax
  1012c7:	0f b6 c0             	movzbl %al,%eax
  1012ca:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  1012d1:	42                   	inc    %edx
  1012d2:	0f b7 d2             	movzwl %dx,%edx
  1012d5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012d9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012dc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012e0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012e4:	ee                   	out    %al,(%dx)
}
  1012e5:	90                   	nop
    outb(addr_6845, 15);
  1012e6:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012ed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012f1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012fd:	ee                   	out    %al,(%dx)
}
  1012fe:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012ff:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101306:	0f b6 c0             	movzbl %al,%eax
  101309:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  101310:	42                   	inc    %edx
  101311:	0f b7 d2             	movzwl %dx,%edx
  101314:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101318:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10131b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10131f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101323:	ee                   	out    %al,(%dx)
}
  101324:	90                   	nop
}
  101325:	90                   	nop
  101326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101329:	89 ec                	mov    %ebp,%esp
  10132b:	5d                   	pop    %ebp
  10132c:	c3                   	ret    

0010132d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10132d:	55                   	push   %ebp
  10132e:	89 e5                	mov    %esp,%ebp
  101330:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101333:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10133a:	eb 08                	jmp    101344 <serial_putc_sub+0x17>
        delay();
  10133c:	e8 16 fb ff ff       	call   100e57 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101341:	ff 45 fc             	incl   -0x4(%ebp)
  101344:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10134a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10134e:	89 c2                	mov    %eax,%edx
  101350:	ec                   	in     (%dx),%al
  101351:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101354:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101358:	0f b6 c0             	movzbl %al,%eax
  10135b:	83 e0 20             	and    $0x20,%eax
  10135e:	85 c0                	test   %eax,%eax
  101360:	75 09                	jne    10136b <serial_putc_sub+0x3e>
  101362:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101369:	7e d1                	jle    10133c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10136b:	8b 45 08             	mov    0x8(%ebp),%eax
  10136e:	0f b6 c0             	movzbl %al,%eax
  101371:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101377:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10137a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10137e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101382:	ee                   	out    %al,(%dx)
}
  101383:	90                   	nop
}
  101384:	90                   	nop
  101385:	89 ec                	mov    %ebp,%esp
  101387:	5d                   	pop    %ebp
  101388:	c3                   	ret    

00101389 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101389:	55                   	push   %ebp
  10138a:	89 e5                	mov    %esp,%ebp
  10138c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10138f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101393:	74 0d                	je     1013a2 <serial_putc+0x19>
        serial_putc_sub(c);
  101395:	8b 45 08             	mov    0x8(%ebp),%eax
  101398:	89 04 24             	mov    %eax,(%esp)
  10139b:	e8 8d ff ff ff       	call   10132d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1013a0:	eb 24                	jmp    1013c6 <serial_putc+0x3d>
        serial_putc_sub('\b');
  1013a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013a9:	e8 7f ff ff ff       	call   10132d <serial_putc_sub>
        serial_putc_sub(' ');
  1013ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013b5:	e8 73 ff ff ff       	call   10132d <serial_putc_sub>
        serial_putc_sub('\b');
  1013ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013c1:	e8 67 ff ff ff       	call   10132d <serial_putc_sub>
}
  1013c6:	90                   	nop
  1013c7:	89 ec                	mov    %ebp,%esp
  1013c9:	5d                   	pop    %ebp
  1013ca:	c3                   	ret    

001013cb <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013cb:	55                   	push   %ebp
  1013cc:	89 e5                	mov    %esp,%ebp
  1013ce:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013d1:	eb 33                	jmp    101406 <cons_intr+0x3b>
        if (c != 0) {
  1013d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013d7:	74 2d                	je     101406 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013d9:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013de:	8d 50 01             	lea    0x1(%eax),%edx
  1013e1:	89 15 64 b6 11 00    	mov    %edx,0x11b664
  1013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013ea:	88 90 60 b4 11 00    	mov    %dl,0x11b460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013f0:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013f5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013fa:	75 0a                	jne    101406 <cons_intr+0x3b>
                cons.wpos = 0;
  1013fc:	c7 05 64 b6 11 00 00 	movl   $0x0,0x11b664
  101403:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101406:	8b 45 08             	mov    0x8(%ebp),%eax
  101409:	ff d0                	call   *%eax
  10140b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10140e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101412:	75 bf                	jne    1013d3 <cons_intr+0x8>
            }
        }
    }
}
  101414:	90                   	nop
  101415:	90                   	nop
  101416:	89 ec                	mov    %ebp,%esp
  101418:	5d                   	pop    %ebp
  101419:	c3                   	ret    

0010141a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10141a:	55                   	push   %ebp
  10141b:	89 e5                	mov    %esp,%ebp
  10141d:	83 ec 10             	sub    $0x10,%esp
  101420:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101426:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10142a:	89 c2                	mov    %eax,%edx
  10142c:	ec                   	in     (%dx),%al
  10142d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101430:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101434:	0f b6 c0             	movzbl %al,%eax
  101437:	83 e0 01             	and    $0x1,%eax
  10143a:	85 c0                	test   %eax,%eax
  10143c:	75 07                	jne    101445 <serial_proc_data+0x2b>
        return -1;
  10143e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101443:	eb 2a                	jmp    10146f <serial_proc_data+0x55>
  101445:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10144b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10144f:	89 c2                	mov    %eax,%edx
  101451:	ec                   	in     (%dx),%al
  101452:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101455:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101459:	0f b6 c0             	movzbl %al,%eax
  10145c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10145f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101463:	75 07                	jne    10146c <serial_proc_data+0x52>
        c = '\b';
  101465:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10146f:	89 ec                	mov    %ebp,%esp
  101471:	5d                   	pop    %ebp
  101472:	c3                   	ret    

00101473 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101473:	55                   	push   %ebp
  101474:	89 e5                	mov    %esp,%ebp
  101476:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101479:	a1 48 b4 11 00       	mov    0x11b448,%eax
  10147e:	85 c0                	test   %eax,%eax
  101480:	74 0c                	je     10148e <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101482:	c7 04 24 1a 14 10 00 	movl   $0x10141a,(%esp)
  101489:	e8 3d ff ff ff       	call   1013cb <cons_intr>
    }
}
  10148e:	90                   	nop
  10148f:	89 ec                	mov    %ebp,%esp
  101491:	5d                   	pop    %ebp
  101492:	c3                   	ret    

00101493 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101493:	55                   	push   %ebp
  101494:	89 e5                	mov    %esp,%ebp
  101496:	83 ec 38             	sub    $0x38,%esp
  101499:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014a2:	89 c2                	mov    %eax,%edx
  1014a4:	ec                   	in     (%dx),%al
  1014a5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014ac:	0f b6 c0             	movzbl %al,%eax
  1014af:	83 e0 01             	and    $0x1,%eax
  1014b2:	85 c0                	test   %eax,%eax
  1014b4:	75 0a                	jne    1014c0 <kbd_proc_data+0x2d>
        return -1;
  1014b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014bb:	e9 56 01 00 00       	jmp    101616 <kbd_proc_data+0x183>
  1014c0:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014c9:	89 c2                	mov    %eax,%edx
  1014cb:	ec                   	in     (%dx),%al
  1014cc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014cf:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014d3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014d6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014da:	75 17                	jne    1014f3 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014dc:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014e1:	83 c8 40             	or     $0x40,%eax
  1014e4:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ee:	e9 23 01 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f7:	84 c0                	test   %al,%al
  1014f9:	79 45                	jns    101540 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014fb:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101500:	83 e0 40             	and    $0x40,%eax
  101503:	85 c0                	test   %eax,%eax
  101505:	75 08                	jne    10150f <kbd_proc_data+0x7c>
  101507:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150b:	24 7f                	and    $0x7f,%al
  10150d:	eb 04                	jmp    101513 <kbd_proc_data+0x80>
  10150f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101513:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151a:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  101521:	0c 40                	or     $0x40,%al
  101523:	0f b6 c0             	movzbl %al,%eax
  101526:	f7 d0                	not    %eax
  101528:	89 c2                	mov    %eax,%edx
  10152a:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10152f:	21 d0                	and    %edx,%eax
  101531:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  101536:	b8 00 00 00 00       	mov    $0x0,%eax
  10153b:	e9 d6 00 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101540:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101545:	83 e0 40             	and    $0x40,%eax
  101548:	85 c0                	test   %eax,%eax
  10154a:	74 11                	je     10155d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10154c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101550:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101555:	83 e0 bf             	and    $0xffffffbf,%eax
  101558:	a3 68 b6 11 00       	mov    %eax,0x11b668
    }

    shift |= shiftcode[data];
  10155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101561:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  101568:	0f b6 d0             	movzbl %al,%edx
  10156b:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101570:	09 d0                	or     %edx,%eax
  101572:	a3 68 b6 11 00       	mov    %eax,0x11b668
    shift ^= togglecode[data];
  101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10157b:	0f b6 80 40 81 11 00 	movzbl 0x118140(%eax),%eax
  101582:	0f b6 d0             	movzbl %al,%edx
  101585:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10158a:	31 d0                	xor    %edx,%eax
  10158c:	a3 68 b6 11 00       	mov    %eax,0x11b668

    c = charcode[shift & (CTL | SHIFT)][data];
  101591:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101596:	83 e0 03             	and    $0x3,%eax
  101599:	8b 14 85 40 85 11 00 	mov    0x118540(,%eax,4),%edx
  1015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a4:	01 d0                	add    %edx,%eax
  1015a6:	0f b6 00             	movzbl (%eax),%eax
  1015a9:	0f b6 c0             	movzbl %al,%eax
  1015ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015af:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1015b4:	83 e0 08             	and    $0x8,%eax
  1015b7:	85 c0                	test   %eax,%eax
  1015b9:	74 22                	je     1015dd <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015bb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015bf:	7e 0c                	jle    1015cd <kbd_proc_data+0x13a>
  1015c1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015c5:	7f 06                	jg     1015cd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1015c7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015cb:	eb 10                	jmp    1015dd <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1015cd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015d1:	7e 0a                	jle    1015dd <kbd_proc_data+0x14a>
  1015d3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015d7:	7f 04                	jg     1015dd <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015d9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015dd:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1015e2:	f7 d0                	not    %eax
  1015e4:	83 e0 06             	and    $0x6,%eax
  1015e7:	85 c0                	test   %eax,%eax
  1015e9:	75 28                	jne    101613 <kbd_proc_data+0x180>
  1015eb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015f2:	75 1f                	jne    101613 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015f4:	c7 04 24 eb 61 10 00 	movl   $0x1061eb,(%esp)
  1015fb:	e8 56 ed ff ff       	call   100356 <cprintf>
  101600:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101606:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10160a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10160e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101611:	ee                   	out    %al,(%dx)
}
  101612:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101616:	89 ec                	mov    %ebp,%esp
  101618:	5d                   	pop    %ebp
  101619:	c3                   	ret    

0010161a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10161a:	55                   	push   %ebp
  10161b:	89 e5                	mov    %esp,%ebp
  10161d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101620:	c7 04 24 93 14 10 00 	movl   $0x101493,(%esp)
  101627:	e8 9f fd ff ff       	call   1013cb <cons_intr>
}
  10162c:	90                   	nop
  10162d:	89 ec                	mov    %ebp,%esp
  10162f:	5d                   	pop    %ebp
  101630:	c3                   	ret    

00101631 <kbd_init>:

static void
kbd_init(void) {
  101631:	55                   	push   %ebp
  101632:	89 e5                	mov    %esp,%ebp
  101634:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101637:	e8 de ff ff ff       	call   10161a <kbd_intr>
    pic_enable(IRQ_KBD);
  10163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101643:	e8 51 01 00 00       	call   101799 <pic_enable>
}
  101648:	90                   	nop
  101649:	89 ec                	mov    %ebp,%esp
  10164b:	5d                   	pop    %ebp
  10164c:	c3                   	ret    

0010164d <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10164d:	55                   	push   %ebp
  10164e:	89 e5                	mov    %esp,%ebp
  101650:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101653:	e8 4a f8 ff ff       	call   100ea2 <cga_init>
    serial_init();
  101658:	e8 2d f9 ff ff       	call   100f8a <serial_init>
    kbd_init();
  10165d:	e8 cf ff ff ff       	call   101631 <kbd_init>
    if (!serial_exists) {
  101662:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101667:	85 c0                	test   %eax,%eax
  101669:	75 0c                	jne    101677 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10166b:	c7 04 24 f7 61 10 00 	movl   $0x1061f7,(%esp)
  101672:	e8 df ec ff ff       	call   100356 <cprintf>
    }
}
  101677:	90                   	nop
  101678:	89 ec                	mov    %ebp,%esp
  10167a:	5d                   	pop    %ebp
  10167b:	c3                   	ret    

0010167c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10167c:	55                   	push   %ebp
  10167d:	89 e5                	mov    %esp,%ebp
  10167f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101682:	e8 8e f7 ff ff       	call   100e15 <__intr_save>
  101687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10168a:	8b 45 08             	mov    0x8(%ebp),%eax
  10168d:	89 04 24             	mov    %eax,(%esp)
  101690:	e8 60 fa ff ff       	call   1010f5 <lpt_putc>
        cga_putc(c);
  101695:	8b 45 08             	mov    0x8(%ebp),%eax
  101698:	89 04 24             	mov    %eax,(%esp)
  10169b:	e8 97 fa ff ff       	call   101137 <cga_putc>
        serial_putc(c);
  1016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a3:	89 04 24             	mov    %eax,(%esp)
  1016a6:	e8 de fc ff ff       	call   101389 <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016ae:	89 04 24             	mov    %eax,(%esp)
  1016b1:	e8 8b f7 ff ff       	call   100e41 <__intr_restore>
}
  1016b6:	90                   	nop
  1016b7:	89 ec                	mov    %ebp,%esp
  1016b9:	5d                   	pop    %ebp
  1016ba:	c3                   	ret    

001016bb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016bb:	55                   	push   %ebp
  1016bc:	89 e5                	mov    %esp,%ebp
  1016be:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  1016c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1016c8:	e8 48 f7 ff ff       	call   100e15 <__intr_save>
  1016cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1016d0:	e8 9e fd ff ff       	call   101473 <serial_intr>
        kbd_intr();
  1016d5:	e8 40 ff ff ff       	call   10161a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1016da:	8b 15 60 b6 11 00    	mov    0x11b660,%edx
  1016e0:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1016e5:	39 c2                	cmp    %eax,%edx
  1016e7:	74 31                	je     10171a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016e9:	a1 60 b6 11 00       	mov    0x11b660,%eax
  1016ee:	8d 50 01             	lea    0x1(%eax),%edx
  1016f1:	89 15 60 b6 11 00    	mov    %edx,0x11b660
  1016f7:	0f b6 80 60 b4 11 00 	movzbl 0x11b460(%eax),%eax
  1016fe:	0f b6 c0             	movzbl %al,%eax
  101701:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101704:	a1 60 b6 11 00       	mov    0x11b660,%eax
  101709:	3d 00 02 00 00       	cmp    $0x200,%eax
  10170e:	75 0a                	jne    10171a <cons_getc+0x5f>
                cons.rpos = 0;
  101710:	c7 05 60 b6 11 00 00 	movl   $0x0,0x11b660
  101717:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10171d:	89 04 24             	mov    %eax,(%esp)
  101720:	e8 1c f7 ff ff       	call   100e41 <__intr_restore>
    return c;
  101725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101728:	89 ec                	mov    %ebp,%esp
  10172a:	5d                   	pop    %ebp
  10172b:	c3                   	ret    

0010172c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10172c:	55                   	push   %ebp
  10172d:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  10172f:	fb                   	sti    
}
  101730:	90                   	nop
    sti();
}
  101731:	90                   	nop
  101732:	5d                   	pop    %ebp
  101733:	c3                   	ret    

00101734 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101734:	55                   	push   %ebp
  101735:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101737:	fa                   	cli    
}
  101738:	90                   	nop
    cli();
}
  101739:	90                   	nop
  10173a:	5d                   	pop    %ebp
  10173b:	c3                   	ret    

0010173c <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10173c:	55                   	push   %ebp
  10173d:	89 e5                	mov    %esp,%ebp
  10173f:	83 ec 14             	sub    $0x14,%esp
  101742:	8b 45 08             	mov    0x8(%ebp),%eax
  101745:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10174c:	66 a3 50 85 11 00    	mov    %ax,0x118550
    if (did_init) {
  101752:	a1 6c b6 11 00       	mov    0x11b66c,%eax
  101757:	85 c0                	test   %eax,%eax
  101759:	74 39                	je     101794 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  10175b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10175e:	0f b6 c0             	movzbl %al,%eax
  101761:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101767:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10176a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10176e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101772:	ee                   	out    %al,(%dx)
}
  101773:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101774:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101778:	c1 e8 08             	shr    $0x8,%eax
  10177b:	0f b7 c0             	movzwl %ax,%eax
  10177e:	0f b6 c0             	movzbl %al,%eax
  101781:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101787:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10178a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10178e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101792:	ee                   	out    %al,(%dx)
}
  101793:	90                   	nop
    }
}
  101794:	90                   	nop
  101795:	89 ec                	mov    %ebp,%esp
  101797:	5d                   	pop    %ebp
  101798:	c3                   	ret    

00101799 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101799:	55                   	push   %ebp
  10179a:	89 e5                	mov    %esp,%ebp
  10179c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10179f:	8b 45 08             	mov    0x8(%ebp),%eax
  1017a2:	ba 01 00 00 00       	mov    $0x1,%edx
  1017a7:	88 c1                	mov    %al,%cl
  1017a9:	d3 e2                	shl    %cl,%edx
  1017ab:	89 d0                	mov    %edx,%eax
  1017ad:	98                   	cwtl   
  1017ae:	f7 d0                	not    %eax
  1017b0:	0f bf d0             	movswl %ax,%edx
  1017b3:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  1017ba:	98                   	cwtl   
  1017bb:	21 d0                	and    %edx,%eax
  1017bd:	98                   	cwtl   
  1017be:	0f b7 c0             	movzwl %ax,%eax
  1017c1:	89 04 24             	mov    %eax,(%esp)
  1017c4:	e8 73 ff ff ff       	call   10173c <pic_setmask>
}
  1017c9:	90                   	nop
  1017ca:	89 ec                	mov    %ebp,%esp
  1017cc:	5d                   	pop    %ebp
  1017cd:	c3                   	ret    

001017ce <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017ce:	55                   	push   %ebp
  1017cf:	89 e5                	mov    %esp,%ebp
  1017d1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017d4:	c7 05 6c b6 11 00 01 	movl   $0x1,0x11b66c
  1017db:	00 00 00 
  1017de:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017e4:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017e8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017ec:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017f0:	ee                   	out    %al,(%dx)
}
  1017f1:	90                   	nop
  1017f2:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1017f8:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017fc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101800:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
}
  101805:	90                   	nop
  101806:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10180c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101810:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101814:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101818:	ee                   	out    %al,(%dx)
}
  101819:	90                   	nop
  10181a:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101820:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101824:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101828:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10182c:	ee                   	out    %al,(%dx)
}
  10182d:	90                   	nop
  10182e:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101834:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101838:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10183c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101840:	ee                   	out    %al,(%dx)
}
  101841:	90                   	nop
  101842:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101848:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10184c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101850:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101854:	ee                   	out    %al,(%dx)
}
  101855:	90                   	nop
  101856:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  10185c:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101860:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101864:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101868:	ee                   	out    %al,(%dx)
}
  101869:	90                   	nop
  10186a:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101870:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101874:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101878:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10187c:	ee                   	out    %al,(%dx)
}
  10187d:	90                   	nop
  10187e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101884:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101888:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10188c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101890:	ee                   	out    %al,(%dx)
}
  101891:	90                   	nop
  101892:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101898:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10189c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1018a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1018a4:	ee                   	out    %al,(%dx)
}
  1018a5:	90                   	nop
  1018a6:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018ac:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018b8:	ee                   	out    %al,(%dx)
}
  1018b9:	90                   	nop
  1018ba:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018c0:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018c4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018c8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018cc:	ee                   	out    %al,(%dx)
}
  1018cd:	90                   	nop
  1018ce:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018d4:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018d8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018dc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018e0:	ee                   	out    %al,(%dx)
}
  1018e1:	90                   	nop
  1018e2:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018e8:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ec:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018f0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1018f4:	ee                   	out    %al,(%dx)
}
  1018f5:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1018f6:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  1018fd:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101902:	74 0f                	je     101913 <pic_init+0x145>
        pic_setmask(irq_mask);
  101904:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10190b:	89 04 24             	mov    %eax,(%esp)
  10190e:	e8 29 fe ff ff       	call   10173c <pic_setmask>
    }
}
  101913:	90                   	nop
  101914:	89 ec                	mov    %ebp,%esp
  101916:	5d                   	pop    %ebp
  101917:	c3                   	ret    

00101918 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101918:	55                   	push   %ebp
  101919:	89 e5                	mov    %esp,%ebp
  10191b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10191e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101925:	00 
  101926:	c7 04 24 20 62 10 00 	movl   $0x106220,(%esp)
  10192d:	e8 24 ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101932:	c7 04 24 2a 62 10 00 	movl   $0x10622a,(%esp)
  101939:	e8 18 ea ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  10193e:	c7 44 24 08 38 62 10 	movl   $0x106238,0x8(%esp)
  101945:	00 
  101946:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  10194d:	00 
  10194e:	c7 04 24 4e 62 10 00 	movl   $0x10624e,(%esp)
  101955:	e8 81 f3 ff ff       	call   100cdb <__panic>

0010195a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10195a:	55                   	push   %ebp
  10195b:	89 e5                	mov    %esp,%ebp
  10195d:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
   //使用SETGATE宏，对中断描述符表中的每一个表项进行设置
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) { //IDT表项的个数
  101960:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101967:	e9 c4 00 00 00       	jmp    101a30 <idt_init+0xd6>
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]，特权级为DPL_KERNEL。这样通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  10196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196f:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  101983:	00 
  101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101987:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  10198e:	00 08 00 
  101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101994:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10199b:	00 
  10199c:	80 e2 e0             	and    $0xe0,%dl
  10199f:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a9:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  1019b0:	00 
  1019b1:	80 e2 1f             	and    $0x1f,%dl
  1019b4:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019c5:	00 
  1019c6:	80 e2 f0             	and    $0xf0,%dl
  1019c9:	80 ca 0e             	or     $0xe,%dl
  1019cc:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d6:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019dd:	00 
  1019de:	80 e2 ef             	and    $0xef,%dl
  1019e1:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019eb:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019f2:	00 
  1019f3:	80 e2 9f             	and    $0x9f,%dl
  1019f6:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a00:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a07:	00 
  101a08:	80 ca 80             	or     $0x80,%dl
  101a0b:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a15:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101a1c:	c1 e8 10             	shr    $0x10,%eax
  101a1f:	0f b7 d0             	movzwl %ax,%edx
  101a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a25:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  101a2c:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) { //IDT表项的个数
  101a2d:	ff 45 fc             	incl   -0x4(%ebp)
  101a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a33:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a38:	0f 86 2e ff ff ff    	jbe    10196c <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,     
  101a3e:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  101a43:	0f b7 c0             	movzwl %ax,%eax
  101a46:	66 a3 48 ba 11 00    	mov    %ax,0x11ba48
  101a4c:	66 c7 05 4a ba 11 00 	movw   $0x8,0x11ba4a
  101a53:	08 00 
  101a55:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  101a5c:	24 e0                	and    $0xe0,%al
  101a5e:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  101a63:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  101a6a:	24 1f                	and    $0x1f,%al
  101a6c:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  101a71:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a78:	24 f0                	and    $0xf0,%al
  101a7a:	0c 0e                	or     $0xe,%al
  101a7c:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a81:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a88:	24 ef                	and    $0xef,%al
  101a8a:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a8f:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a96:	0c 60                	or     $0x60,%al
  101a98:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a9d:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101aa4:	0c 80                	or     $0x80,%al
  101aa6:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101aab:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  101ab0:	c1 e8 10             	shr    $0x10,%eax
  101ab3:	0f b7 c0             	movzwl %ax,%eax
  101ab6:	66 a3 4e ba 11 00    	mov    %ax,0x11ba4e
  101abc:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101ac6:	0f 01 18             	lidtl  (%eax)
}
  101ac9:	90                   	nop
    __vectors[T_SWITCH_TOK], DPL_USER);
     //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
  101aca:	90                   	nop
  101acb:	89 ec                	mov    %ebp,%esp
  101acd:	5d                   	pop    %ebp
  101ace:	c3                   	ret    

00101acf <trapname>:

static const char *
trapname(int trapno) {
  101acf:	55                   	push   %ebp
  101ad0:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	83 f8 13             	cmp    $0x13,%eax
  101ad8:	77 0c                	ja     101ae6 <trapname+0x17>
        return excnames[trapno];
  101ada:	8b 45 08             	mov    0x8(%ebp),%eax
  101add:	8b 04 85 a0 65 10 00 	mov    0x1065a0(,%eax,4),%eax
  101ae4:	eb 18                	jmp    101afe <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ae6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101aea:	7e 0d                	jle    101af9 <trapname+0x2a>
  101aec:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101af0:	7f 07                	jg     101af9 <trapname+0x2a>
        return "Hardware Interrupt";
  101af2:	b8 5f 62 10 00       	mov    $0x10625f,%eax
  101af7:	eb 05                	jmp    101afe <trapname+0x2f>
    }
    return "(unknown trap)";
  101af9:	b8 72 62 10 00       	mov    $0x106272,%eax
}
  101afe:	5d                   	pop    %ebp
  101aff:	c3                   	ret    

00101b00 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b00:	55                   	push   %ebp
  101b01:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b03:	8b 45 08             	mov    0x8(%ebp),%eax
  101b06:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b0a:	83 f8 08             	cmp    $0x8,%eax
  101b0d:	0f 94 c0             	sete   %al
  101b10:	0f b6 c0             	movzbl %al,%eax
}
  101b13:	5d                   	pop    %ebp
  101b14:	c3                   	ret    

00101b15 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b15:	55                   	push   %ebp
  101b16:	89 e5                	mov    %esp,%ebp
  101b18:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b22:	c7 04 24 b3 62 10 00 	movl   $0x1062b3,(%esp)
  101b29:	e8 28 e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b31:	89 04 24             	mov    %eax,(%esp)
  101b34:	e8 8f 01 00 00       	call   101cc8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b39:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b44:	c7 04 24 c4 62 10 00 	movl   $0x1062c4,(%esp)
  101b4b:	e8 06 e8 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b50:	8b 45 08             	mov    0x8(%ebp),%eax
  101b53:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5b:	c7 04 24 d7 62 10 00 	movl   $0x1062d7,(%esp)
  101b62:	e8 ef e7 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b72:	c7 04 24 ea 62 10 00 	movl   $0x1062ea,(%esp)
  101b79:	e8 d8 e7 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b81:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b89:	c7 04 24 fd 62 10 00 	movl   $0x1062fd,(%esp)
  101b90:	e8 c1 e7 ff ff       	call   100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b95:	8b 45 08             	mov    0x8(%ebp),%eax
  101b98:	8b 40 30             	mov    0x30(%eax),%eax
  101b9b:	89 04 24             	mov    %eax,(%esp)
  101b9e:	e8 2c ff ff ff       	call   101acf <trapname>
  101ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  101ba6:	8b 52 30             	mov    0x30(%edx),%edx
  101ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
  101bad:	89 54 24 04          	mov    %edx,0x4(%esp)
  101bb1:	c7 04 24 10 63 10 00 	movl   $0x106310,(%esp)
  101bb8:	e8 99 e7 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc0:	8b 40 34             	mov    0x34(%eax),%eax
  101bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc7:	c7 04 24 22 63 10 00 	movl   $0x106322,(%esp)
  101bce:	e8 83 e7 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd6:	8b 40 38             	mov    0x38(%eax),%eax
  101bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdd:	c7 04 24 31 63 10 00 	movl   $0x106331,(%esp)
  101be4:	e8 6d e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101be9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf4:	c7 04 24 40 63 10 00 	movl   $0x106340,(%esp)
  101bfb:	e8 56 e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c00:	8b 45 08             	mov    0x8(%ebp),%eax
  101c03:	8b 40 40             	mov    0x40(%eax),%eax
  101c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0a:	c7 04 24 53 63 10 00 	movl   $0x106353,(%esp)
  101c11:	e8 40 e7 ff ff       	call   100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c1d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c24:	eb 3d                	jmp    101c63 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c26:	8b 45 08             	mov    0x8(%ebp),%eax
  101c29:	8b 50 40             	mov    0x40(%eax),%edx
  101c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c2f:	21 d0                	and    %edx,%eax
  101c31:	85 c0                	test   %eax,%eax
  101c33:	74 28                	je     101c5d <print_trapframe+0x148>
  101c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c38:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101c3f:	85 c0                	test   %eax,%eax
  101c41:	74 1a                	je     101c5d <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c46:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c51:	c7 04 24 62 63 10 00 	movl   $0x106362,(%esp)
  101c58:	e8 f9 e6 ff ff       	call   100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c5d:	ff 45 f4             	incl   -0xc(%ebp)
  101c60:	d1 65 f0             	shll   -0x10(%ebp)
  101c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c66:	83 f8 17             	cmp    $0x17,%eax
  101c69:	76 bb                	jbe    101c26 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6e:	8b 40 40             	mov    0x40(%eax),%eax
  101c71:	c1 e8 0c             	shr    $0xc,%eax
  101c74:	83 e0 03             	and    $0x3,%eax
  101c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7b:	c7 04 24 66 63 10 00 	movl   $0x106366,(%esp)
  101c82:	e8 cf e6 ff ff       	call   100356 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c87:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8a:	89 04 24             	mov    %eax,(%esp)
  101c8d:	e8 6e fe ff ff       	call   101b00 <trap_in_kernel>
  101c92:	85 c0                	test   %eax,%eax
  101c94:	75 2d                	jne    101cc3 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c96:	8b 45 08             	mov    0x8(%ebp),%eax
  101c99:	8b 40 44             	mov    0x44(%eax),%eax
  101c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca0:	c7 04 24 6f 63 10 00 	movl   $0x10636f,(%esp)
  101ca7:	e8 aa e6 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101cac:	8b 45 08             	mov    0x8(%ebp),%eax
  101caf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb7:	c7 04 24 7e 63 10 00 	movl   $0x10637e,(%esp)
  101cbe:	e8 93 e6 ff ff       	call   100356 <cprintf>
    }
}
  101cc3:	90                   	nop
  101cc4:	89 ec                	mov    %ebp,%esp
  101cc6:	5d                   	pop    %ebp
  101cc7:	c3                   	ret    

00101cc8 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101cc8:	55                   	push   %ebp
  101cc9:	89 e5                	mov    %esp,%ebp
  101ccb:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cce:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd1:	8b 00                	mov    (%eax),%eax
  101cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd7:	c7 04 24 91 63 10 00 	movl   $0x106391,(%esp)
  101cde:	e8 73 e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce6:	8b 40 04             	mov    0x4(%eax),%eax
  101ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ced:	c7 04 24 a0 63 10 00 	movl   $0x1063a0,(%esp)
  101cf4:	e8 5d e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cfc:	8b 40 08             	mov    0x8(%eax),%eax
  101cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d03:	c7 04 24 af 63 10 00 	movl   $0x1063af,(%esp)
  101d0a:	e8 47 e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d12:	8b 40 0c             	mov    0xc(%eax),%eax
  101d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d19:	c7 04 24 be 63 10 00 	movl   $0x1063be,(%esp)
  101d20:	e8 31 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d25:	8b 45 08             	mov    0x8(%ebp),%eax
  101d28:	8b 40 10             	mov    0x10(%eax),%eax
  101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d2f:	c7 04 24 cd 63 10 00 	movl   $0x1063cd,(%esp)
  101d36:	e8 1b e6 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3e:	8b 40 14             	mov    0x14(%eax),%eax
  101d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d45:	c7 04 24 dc 63 10 00 	movl   $0x1063dc,(%esp)
  101d4c:	e8 05 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d51:	8b 45 08             	mov    0x8(%ebp),%eax
  101d54:	8b 40 18             	mov    0x18(%eax),%eax
  101d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d5b:	c7 04 24 eb 63 10 00 	movl   $0x1063eb,(%esp)
  101d62:	e8 ef e5 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d67:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6a:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d71:	c7 04 24 fa 63 10 00 	movl   $0x1063fa,(%esp)
  101d78:	e8 d9 e5 ff ff       	call   100356 <cprintf>
}
  101d7d:	90                   	nop
  101d7e:	89 ec                	mov    %ebp,%esp
  101d80:	5d                   	pop    %ebp
  101d81:	c3                   	ret    

00101d82 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d82:	55                   	push   %ebp
  101d83:	89 e5                	mov    %esp,%ebp
  101d85:	83 ec 28             	sub    $0x28,%esp
    char c;
    switch (tf->tf_trapno) {
  101d88:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8b:	8b 40 30             	mov    0x30(%eax),%eax
  101d8e:	83 f8 79             	cmp    $0x79,%eax
  101d91:	0f 87 e6 00 00 00    	ja     101e7d <trap_dispatch+0xfb>
  101d97:	83 f8 78             	cmp    $0x78,%eax
  101d9a:	0f 83 c1 00 00 00    	jae    101e61 <trap_dispatch+0xdf>
  101da0:	83 f8 2f             	cmp    $0x2f,%eax
  101da3:	0f 87 d4 00 00 00    	ja     101e7d <trap_dispatch+0xfb>
  101da9:	83 f8 2e             	cmp    $0x2e,%eax
  101dac:	0f 83 00 01 00 00    	jae    101eb2 <trap_dispatch+0x130>
  101db2:	83 f8 24             	cmp    $0x24,%eax
  101db5:	74 5e                	je     101e15 <trap_dispatch+0x93>
  101db7:	83 f8 24             	cmp    $0x24,%eax
  101dba:	0f 87 bd 00 00 00    	ja     101e7d <trap_dispatch+0xfb>
  101dc0:	83 f8 20             	cmp    $0x20,%eax
  101dc3:	74 0a                	je     101dcf <trap_dispatch+0x4d>
  101dc5:	83 f8 21             	cmp    $0x21,%eax
  101dc8:	74 71                	je     101e3b <trap_dispatch+0xb9>
  101dca:	e9 ae 00 00 00       	jmp    101e7d <trap_dispatch+0xfb>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101dcf:	a1 24 b4 11 00       	mov    0x11b424,%eax
  101dd4:	40                   	inc    %eax
  101dd5:	a3 24 b4 11 00       	mov    %eax,0x11b424
        if (ticks % TICK_NUM == 0) {
  101dda:	8b 0d 24 b4 11 00    	mov    0x11b424,%ecx
  101de0:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101de5:	89 c8                	mov    %ecx,%eax
  101de7:	f7 e2                	mul    %edx
  101de9:	c1 ea 05             	shr    $0x5,%edx
  101dec:	89 d0                	mov    %edx,%eax
  101dee:	c1 e0 02             	shl    $0x2,%eax
  101df1:	01 d0                	add    %edx,%eax
  101df3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101dfa:	01 d0                	add    %edx,%eax
  101dfc:	c1 e0 02             	shl    $0x2,%eax
  101dff:	29 c1                	sub    %eax,%ecx
  101e01:	89 ca                	mov    %ecx,%edx
  101e03:	85 d2                	test   %edx,%edx
  101e05:	0f 85 aa 00 00 00    	jne    101eb5 <trap_dispatch+0x133>
            print_ticks();
  101e0b:	e8 08 fb ff ff       	call   101918 <print_ticks>
        }
        break;
  101e10:	e9 a0 00 00 00       	jmp    101eb5 <trap_dispatch+0x133>
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e15:	e8 a1 f8 ff ff       	call   1016bb <cons_getc>
  101e1a:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e1d:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e21:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e25:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e29:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e2d:	c7 04 24 09 64 10 00 	movl   $0x106409,(%esp)
  101e34:	e8 1d e5 ff ff       	call   100356 <cprintf>
        break;
  101e39:	eb 7b                	jmp    101eb6 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e3b:	e8 7b f8 ff ff       	call   1016bb <cons_getc>
  101e40:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e43:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e47:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e53:	c7 04 24 1b 64 10 00 	movl   $0x10641b,(%esp)
  101e5a:	e8 f7 e4 ff ff       	call   100356 <cprintf>
        break;
  101e5f:	eb 55                	jmp    101eb6 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101e61:	c7 44 24 08 2a 64 10 	movl   $0x10642a,0x8(%esp)
  101e68:	00 
  101e69:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  101e70:	00 
  101e71:	c7 04 24 4e 62 10 00 	movl   $0x10624e,(%esp)
  101e78:	e8 5e ee ff ff       	call   100cdb <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e84:	83 e0 03             	and    $0x3,%eax
  101e87:	85 c0                	test   %eax,%eax
  101e89:	75 2b                	jne    101eb6 <trap_dispatch+0x134>
            print_trapframe(tf);
  101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8e:	89 04 24             	mov    %eax,(%esp)
  101e91:	e8 7f fc ff ff       	call   101b15 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e96:	c7 44 24 08 3a 64 10 	movl   $0x10643a,0x8(%esp)
  101e9d:	00 
  101e9e:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
  101ea5:	00 
  101ea6:	c7 04 24 4e 62 10 00 	movl   $0x10624e,(%esp)
  101ead:	e8 29 ee ff ff       	call   100cdb <__panic>
        break;
  101eb2:	90                   	nop
  101eb3:	eb 01                	jmp    101eb6 <trap_dispatch+0x134>
        break;
  101eb5:	90                   	nop
        }
    }
}
  101eb6:	90                   	nop
  101eb7:	89 ec                	mov    %ebp,%esp
  101eb9:	5d                   	pop    %ebp
  101eba:	c3                   	ret    

00101ebb <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101ebb:	55                   	push   %ebp
  101ebc:	89 e5                	mov    %esp,%ebp
  101ebe:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec4:	89 04 24             	mov    %eax,(%esp)
  101ec7:	e8 b6 fe ff ff       	call   101d82 <trap_dispatch>
}
  101ecc:	90                   	nop
  101ecd:	89 ec                	mov    %ebp,%esp
  101ecf:	5d                   	pop    %ebp
  101ed0:	c3                   	ret    

00101ed1 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ed1:	1e                   	push   %ds
    pushl %es
  101ed2:	06                   	push   %es
    pushl %fs
  101ed3:	0f a0                	push   %fs
    pushl %gs
  101ed5:	0f a8                	push   %gs
    pushal
  101ed7:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101ed8:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101edd:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101edf:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101ee1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101ee2:	e8 d4 ff ff ff       	call   101ebb <trap>

    # pop the pushed stack pointer
    popl %esp
  101ee7:	5c                   	pop    %esp

00101ee8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101ee8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101ee9:	0f a9                	pop    %gs
    popl %fs
  101eeb:	0f a1                	pop    %fs
    popl %es
  101eed:	07                   	pop    %es
    popl %ds
  101eee:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101eef:	83 c4 08             	add    $0x8,%esp
    iret
  101ef2:	cf                   	iret   

00101ef3 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101ef3:	6a 00                	push   $0x0
  pushl $0
  101ef5:	6a 00                	push   $0x0
  jmp __alltraps
  101ef7:	e9 d5 ff ff ff       	jmp    101ed1 <__alltraps>

00101efc <vector1>:
.globl vector1
vector1:
  pushl $0
  101efc:	6a 00                	push   $0x0
  pushl $1
  101efe:	6a 01                	push   $0x1
  jmp __alltraps
  101f00:	e9 cc ff ff ff       	jmp    101ed1 <__alltraps>

00101f05 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f05:	6a 00                	push   $0x0
  pushl $2
  101f07:	6a 02                	push   $0x2
  jmp __alltraps
  101f09:	e9 c3 ff ff ff       	jmp    101ed1 <__alltraps>

00101f0e <vector3>:
.globl vector3
vector3:
  pushl $0
  101f0e:	6a 00                	push   $0x0
  pushl $3
  101f10:	6a 03                	push   $0x3
  jmp __alltraps
  101f12:	e9 ba ff ff ff       	jmp    101ed1 <__alltraps>

00101f17 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f17:	6a 00                	push   $0x0
  pushl $4
  101f19:	6a 04                	push   $0x4
  jmp __alltraps
  101f1b:	e9 b1 ff ff ff       	jmp    101ed1 <__alltraps>

00101f20 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f20:	6a 00                	push   $0x0
  pushl $5
  101f22:	6a 05                	push   $0x5
  jmp __alltraps
  101f24:	e9 a8 ff ff ff       	jmp    101ed1 <__alltraps>

00101f29 <vector6>:
.globl vector6
vector6:
  pushl $0
  101f29:	6a 00                	push   $0x0
  pushl $6
  101f2b:	6a 06                	push   $0x6
  jmp __alltraps
  101f2d:	e9 9f ff ff ff       	jmp    101ed1 <__alltraps>

00101f32 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f32:	6a 00                	push   $0x0
  pushl $7
  101f34:	6a 07                	push   $0x7
  jmp __alltraps
  101f36:	e9 96 ff ff ff       	jmp    101ed1 <__alltraps>

00101f3b <vector8>:
.globl vector8
vector8:
  pushl $8
  101f3b:	6a 08                	push   $0x8
  jmp __alltraps
  101f3d:	e9 8f ff ff ff       	jmp    101ed1 <__alltraps>

00101f42 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f42:	6a 00                	push   $0x0
  pushl $9
  101f44:	6a 09                	push   $0x9
  jmp __alltraps
  101f46:	e9 86 ff ff ff       	jmp    101ed1 <__alltraps>

00101f4b <vector10>:
.globl vector10
vector10:
  pushl $10
  101f4b:	6a 0a                	push   $0xa
  jmp __alltraps
  101f4d:	e9 7f ff ff ff       	jmp    101ed1 <__alltraps>

00101f52 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f52:	6a 0b                	push   $0xb
  jmp __alltraps
  101f54:	e9 78 ff ff ff       	jmp    101ed1 <__alltraps>

00101f59 <vector12>:
.globl vector12
vector12:
  pushl $12
  101f59:	6a 0c                	push   $0xc
  jmp __alltraps
  101f5b:	e9 71 ff ff ff       	jmp    101ed1 <__alltraps>

00101f60 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f60:	6a 0d                	push   $0xd
  jmp __alltraps
  101f62:	e9 6a ff ff ff       	jmp    101ed1 <__alltraps>

00101f67 <vector14>:
.globl vector14
vector14:
  pushl $14
  101f67:	6a 0e                	push   $0xe
  jmp __alltraps
  101f69:	e9 63 ff ff ff       	jmp    101ed1 <__alltraps>

00101f6e <vector15>:
.globl vector15
vector15:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $15
  101f70:	6a 0f                	push   $0xf
  jmp __alltraps
  101f72:	e9 5a ff ff ff       	jmp    101ed1 <__alltraps>

00101f77 <vector16>:
.globl vector16
vector16:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $16
  101f79:	6a 10                	push   $0x10
  jmp __alltraps
  101f7b:	e9 51 ff ff ff       	jmp    101ed1 <__alltraps>

00101f80 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f80:	6a 11                	push   $0x11
  jmp __alltraps
  101f82:	e9 4a ff ff ff       	jmp    101ed1 <__alltraps>

00101f87 <vector18>:
.globl vector18
vector18:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $18
  101f89:	6a 12                	push   $0x12
  jmp __alltraps
  101f8b:	e9 41 ff ff ff       	jmp    101ed1 <__alltraps>

00101f90 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $19
  101f92:	6a 13                	push   $0x13
  jmp __alltraps
  101f94:	e9 38 ff ff ff       	jmp    101ed1 <__alltraps>

00101f99 <vector20>:
.globl vector20
vector20:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $20
  101f9b:	6a 14                	push   $0x14
  jmp __alltraps
  101f9d:	e9 2f ff ff ff       	jmp    101ed1 <__alltraps>

00101fa2 <vector21>:
.globl vector21
vector21:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $21
  101fa4:	6a 15                	push   $0x15
  jmp __alltraps
  101fa6:	e9 26 ff ff ff       	jmp    101ed1 <__alltraps>

00101fab <vector22>:
.globl vector22
vector22:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $22
  101fad:	6a 16                	push   $0x16
  jmp __alltraps
  101faf:	e9 1d ff ff ff       	jmp    101ed1 <__alltraps>

00101fb4 <vector23>:
.globl vector23
vector23:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $23
  101fb6:	6a 17                	push   $0x17
  jmp __alltraps
  101fb8:	e9 14 ff ff ff       	jmp    101ed1 <__alltraps>

00101fbd <vector24>:
.globl vector24
vector24:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $24
  101fbf:	6a 18                	push   $0x18
  jmp __alltraps
  101fc1:	e9 0b ff ff ff       	jmp    101ed1 <__alltraps>

00101fc6 <vector25>:
.globl vector25
vector25:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $25
  101fc8:	6a 19                	push   $0x19
  jmp __alltraps
  101fca:	e9 02 ff ff ff       	jmp    101ed1 <__alltraps>

00101fcf <vector26>:
.globl vector26
vector26:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $26
  101fd1:	6a 1a                	push   $0x1a
  jmp __alltraps
  101fd3:	e9 f9 fe ff ff       	jmp    101ed1 <__alltraps>

00101fd8 <vector27>:
.globl vector27
vector27:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $27
  101fda:	6a 1b                	push   $0x1b
  jmp __alltraps
  101fdc:	e9 f0 fe ff ff       	jmp    101ed1 <__alltraps>

00101fe1 <vector28>:
.globl vector28
vector28:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $28
  101fe3:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fe5:	e9 e7 fe ff ff       	jmp    101ed1 <__alltraps>

00101fea <vector29>:
.globl vector29
vector29:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $29
  101fec:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fee:	e9 de fe ff ff       	jmp    101ed1 <__alltraps>

00101ff3 <vector30>:
.globl vector30
vector30:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $30
  101ff5:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ff7:	e9 d5 fe ff ff       	jmp    101ed1 <__alltraps>

00101ffc <vector31>:
.globl vector31
vector31:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $31
  101ffe:	6a 1f                	push   $0x1f
  jmp __alltraps
  102000:	e9 cc fe ff ff       	jmp    101ed1 <__alltraps>

00102005 <vector32>:
.globl vector32
vector32:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $32
  102007:	6a 20                	push   $0x20
  jmp __alltraps
  102009:	e9 c3 fe ff ff       	jmp    101ed1 <__alltraps>

0010200e <vector33>:
.globl vector33
vector33:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $33
  102010:	6a 21                	push   $0x21
  jmp __alltraps
  102012:	e9 ba fe ff ff       	jmp    101ed1 <__alltraps>

00102017 <vector34>:
.globl vector34
vector34:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $34
  102019:	6a 22                	push   $0x22
  jmp __alltraps
  10201b:	e9 b1 fe ff ff       	jmp    101ed1 <__alltraps>

00102020 <vector35>:
.globl vector35
vector35:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $35
  102022:	6a 23                	push   $0x23
  jmp __alltraps
  102024:	e9 a8 fe ff ff       	jmp    101ed1 <__alltraps>

00102029 <vector36>:
.globl vector36
vector36:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $36
  10202b:	6a 24                	push   $0x24
  jmp __alltraps
  10202d:	e9 9f fe ff ff       	jmp    101ed1 <__alltraps>

00102032 <vector37>:
.globl vector37
vector37:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $37
  102034:	6a 25                	push   $0x25
  jmp __alltraps
  102036:	e9 96 fe ff ff       	jmp    101ed1 <__alltraps>

0010203b <vector38>:
.globl vector38
vector38:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $38
  10203d:	6a 26                	push   $0x26
  jmp __alltraps
  10203f:	e9 8d fe ff ff       	jmp    101ed1 <__alltraps>

00102044 <vector39>:
.globl vector39
vector39:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $39
  102046:	6a 27                	push   $0x27
  jmp __alltraps
  102048:	e9 84 fe ff ff       	jmp    101ed1 <__alltraps>

0010204d <vector40>:
.globl vector40
vector40:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $40
  10204f:	6a 28                	push   $0x28
  jmp __alltraps
  102051:	e9 7b fe ff ff       	jmp    101ed1 <__alltraps>

00102056 <vector41>:
.globl vector41
vector41:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $41
  102058:	6a 29                	push   $0x29
  jmp __alltraps
  10205a:	e9 72 fe ff ff       	jmp    101ed1 <__alltraps>

0010205f <vector42>:
.globl vector42
vector42:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $42
  102061:	6a 2a                	push   $0x2a
  jmp __alltraps
  102063:	e9 69 fe ff ff       	jmp    101ed1 <__alltraps>

00102068 <vector43>:
.globl vector43
vector43:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $43
  10206a:	6a 2b                	push   $0x2b
  jmp __alltraps
  10206c:	e9 60 fe ff ff       	jmp    101ed1 <__alltraps>

00102071 <vector44>:
.globl vector44
vector44:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $44
  102073:	6a 2c                	push   $0x2c
  jmp __alltraps
  102075:	e9 57 fe ff ff       	jmp    101ed1 <__alltraps>

0010207a <vector45>:
.globl vector45
vector45:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $45
  10207c:	6a 2d                	push   $0x2d
  jmp __alltraps
  10207e:	e9 4e fe ff ff       	jmp    101ed1 <__alltraps>

00102083 <vector46>:
.globl vector46
vector46:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $46
  102085:	6a 2e                	push   $0x2e
  jmp __alltraps
  102087:	e9 45 fe ff ff       	jmp    101ed1 <__alltraps>

0010208c <vector47>:
.globl vector47
vector47:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $47
  10208e:	6a 2f                	push   $0x2f
  jmp __alltraps
  102090:	e9 3c fe ff ff       	jmp    101ed1 <__alltraps>

00102095 <vector48>:
.globl vector48
vector48:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $48
  102097:	6a 30                	push   $0x30
  jmp __alltraps
  102099:	e9 33 fe ff ff       	jmp    101ed1 <__alltraps>

0010209e <vector49>:
.globl vector49
vector49:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $49
  1020a0:	6a 31                	push   $0x31
  jmp __alltraps
  1020a2:	e9 2a fe ff ff       	jmp    101ed1 <__alltraps>

001020a7 <vector50>:
.globl vector50
vector50:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $50
  1020a9:	6a 32                	push   $0x32
  jmp __alltraps
  1020ab:	e9 21 fe ff ff       	jmp    101ed1 <__alltraps>

001020b0 <vector51>:
.globl vector51
vector51:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $51
  1020b2:	6a 33                	push   $0x33
  jmp __alltraps
  1020b4:	e9 18 fe ff ff       	jmp    101ed1 <__alltraps>

001020b9 <vector52>:
.globl vector52
vector52:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $52
  1020bb:	6a 34                	push   $0x34
  jmp __alltraps
  1020bd:	e9 0f fe ff ff       	jmp    101ed1 <__alltraps>

001020c2 <vector53>:
.globl vector53
vector53:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $53
  1020c4:	6a 35                	push   $0x35
  jmp __alltraps
  1020c6:	e9 06 fe ff ff       	jmp    101ed1 <__alltraps>

001020cb <vector54>:
.globl vector54
vector54:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $54
  1020cd:	6a 36                	push   $0x36
  jmp __alltraps
  1020cf:	e9 fd fd ff ff       	jmp    101ed1 <__alltraps>

001020d4 <vector55>:
.globl vector55
vector55:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $55
  1020d6:	6a 37                	push   $0x37
  jmp __alltraps
  1020d8:	e9 f4 fd ff ff       	jmp    101ed1 <__alltraps>

001020dd <vector56>:
.globl vector56
vector56:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $56
  1020df:	6a 38                	push   $0x38
  jmp __alltraps
  1020e1:	e9 eb fd ff ff       	jmp    101ed1 <__alltraps>

001020e6 <vector57>:
.globl vector57
vector57:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $57
  1020e8:	6a 39                	push   $0x39
  jmp __alltraps
  1020ea:	e9 e2 fd ff ff       	jmp    101ed1 <__alltraps>

001020ef <vector58>:
.globl vector58
vector58:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $58
  1020f1:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020f3:	e9 d9 fd ff ff       	jmp    101ed1 <__alltraps>

001020f8 <vector59>:
.globl vector59
vector59:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $59
  1020fa:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020fc:	e9 d0 fd ff ff       	jmp    101ed1 <__alltraps>

00102101 <vector60>:
.globl vector60
vector60:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $60
  102103:	6a 3c                	push   $0x3c
  jmp __alltraps
  102105:	e9 c7 fd ff ff       	jmp    101ed1 <__alltraps>

0010210a <vector61>:
.globl vector61
vector61:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $61
  10210c:	6a 3d                	push   $0x3d
  jmp __alltraps
  10210e:	e9 be fd ff ff       	jmp    101ed1 <__alltraps>

00102113 <vector62>:
.globl vector62
vector62:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $62
  102115:	6a 3e                	push   $0x3e
  jmp __alltraps
  102117:	e9 b5 fd ff ff       	jmp    101ed1 <__alltraps>

0010211c <vector63>:
.globl vector63
vector63:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $63
  10211e:	6a 3f                	push   $0x3f
  jmp __alltraps
  102120:	e9 ac fd ff ff       	jmp    101ed1 <__alltraps>

00102125 <vector64>:
.globl vector64
vector64:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $64
  102127:	6a 40                	push   $0x40
  jmp __alltraps
  102129:	e9 a3 fd ff ff       	jmp    101ed1 <__alltraps>

0010212e <vector65>:
.globl vector65
vector65:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $65
  102130:	6a 41                	push   $0x41
  jmp __alltraps
  102132:	e9 9a fd ff ff       	jmp    101ed1 <__alltraps>

00102137 <vector66>:
.globl vector66
vector66:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $66
  102139:	6a 42                	push   $0x42
  jmp __alltraps
  10213b:	e9 91 fd ff ff       	jmp    101ed1 <__alltraps>

00102140 <vector67>:
.globl vector67
vector67:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $67
  102142:	6a 43                	push   $0x43
  jmp __alltraps
  102144:	e9 88 fd ff ff       	jmp    101ed1 <__alltraps>

00102149 <vector68>:
.globl vector68
vector68:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $68
  10214b:	6a 44                	push   $0x44
  jmp __alltraps
  10214d:	e9 7f fd ff ff       	jmp    101ed1 <__alltraps>

00102152 <vector69>:
.globl vector69
vector69:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $69
  102154:	6a 45                	push   $0x45
  jmp __alltraps
  102156:	e9 76 fd ff ff       	jmp    101ed1 <__alltraps>

0010215b <vector70>:
.globl vector70
vector70:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $70
  10215d:	6a 46                	push   $0x46
  jmp __alltraps
  10215f:	e9 6d fd ff ff       	jmp    101ed1 <__alltraps>

00102164 <vector71>:
.globl vector71
vector71:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $71
  102166:	6a 47                	push   $0x47
  jmp __alltraps
  102168:	e9 64 fd ff ff       	jmp    101ed1 <__alltraps>

0010216d <vector72>:
.globl vector72
vector72:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $72
  10216f:	6a 48                	push   $0x48
  jmp __alltraps
  102171:	e9 5b fd ff ff       	jmp    101ed1 <__alltraps>

00102176 <vector73>:
.globl vector73
vector73:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $73
  102178:	6a 49                	push   $0x49
  jmp __alltraps
  10217a:	e9 52 fd ff ff       	jmp    101ed1 <__alltraps>

0010217f <vector74>:
.globl vector74
vector74:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $74
  102181:	6a 4a                	push   $0x4a
  jmp __alltraps
  102183:	e9 49 fd ff ff       	jmp    101ed1 <__alltraps>

00102188 <vector75>:
.globl vector75
vector75:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $75
  10218a:	6a 4b                	push   $0x4b
  jmp __alltraps
  10218c:	e9 40 fd ff ff       	jmp    101ed1 <__alltraps>

00102191 <vector76>:
.globl vector76
vector76:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $76
  102193:	6a 4c                	push   $0x4c
  jmp __alltraps
  102195:	e9 37 fd ff ff       	jmp    101ed1 <__alltraps>

0010219a <vector77>:
.globl vector77
vector77:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $77
  10219c:	6a 4d                	push   $0x4d
  jmp __alltraps
  10219e:	e9 2e fd ff ff       	jmp    101ed1 <__alltraps>

001021a3 <vector78>:
.globl vector78
vector78:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $78
  1021a5:	6a 4e                	push   $0x4e
  jmp __alltraps
  1021a7:	e9 25 fd ff ff       	jmp    101ed1 <__alltraps>

001021ac <vector79>:
.globl vector79
vector79:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $79
  1021ae:	6a 4f                	push   $0x4f
  jmp __alltraps
  1021b0:	e9 1c fd ff ff       	jmp    101ed1 <__alltraps>

001021b5 <vector80>:
.globl vector80
vector80:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $80
  1021b7:	6a 50                	push   $0x50
  jmp __alltraps
  1021b9:	e9 13 fd ff ff       	jmp    101ed1 <__alltraps>

001021be <vector81>:
.globl vector81
vector81:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $81
  1021c0:	6a 51                	push   $0x51
  jmp __alltraps
  1021c2:	e9 0a fd ff ff       	jmp    101ed1 <__alltraps>

001021c7 <vector82>:
.globl vector82
vector82:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $82
  1021c9:	6a 52                	push   $0x52
  jmp __alltraps
  1021cb:	e9 01 fd ff ff       	jmp    101ed1 <__alltraps>

001021d0 <vector83>:
.globl vector83
vector83:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $83
  1021d2:	6a 53                	push   $0x53
  jmp __alltraps
  1021d4:	e9 f8 fc ff ff       	jmp    101ed1 <__alltraps>

001021d9 <vector84>:
.globl vector84
vector84:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $84
  1021db:	6a 54                	push   $0x54
  jmp __alltraps
  1021dd:	e9 ef fc ff ff       	jmp    101ed1 <__alltraps>

001021e2 <vector85>:
.globl vector85
vector85:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $85
  1021e4:	6a 55                	push   $0x55
  jmp __alltraps
  1021e6:	e9 e6 fc ff ff       	jmp    101ed1 <__alltraps>

001021eb <vector86>:
.globl vector86
vector86:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $86
  1021ed:	6a 56                	push   $0x56
  jmp __alltraps
  1021ef:	e9 dd fc ff ff       	jmp    101ed1 <__alltraps>

001021f4 <vector87>:
.globl vector87
vector87:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $87
  1021f6:	6a 57                	push   $0x57
  jmp __alltraps
  1021f8:	e9 d4 fc ff ff       	jmp    101ed1 <__alltraps>

001021fd <vector88>:
.globl vector88
vector88:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $88
  1021ff:	6a 58                	push   $0x58
  jmp __alltraps
  102201:	e9 cb fc ff ff       	jmp    101ed1 <__alltraps>

00102206 <vector89>:
.globl vector89
vector89:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $89
  102208:	6a 59                	push   $0x59
  jmp __alltraps
  10220a:	e9 c2 fc ff ff       	jmp    101ed1 <__alltraps>

0010220f <vector90>:
.globl vector90
vector90:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $90
  102211:	6a 5a                	push   $0x5a
  jmp __alltraps
  102213:	e9 b9 fc ff ff       	jmp    101ed1 <__alltraps>

00102218 <vector91>:
.globl vector91
vector91:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $91
  10221a:	6a 5b                	push   $0x5b
  jmp __alltraps
  10221c:	e9 b0 fc ff ff       	jmp    101ed1 <__alltraps>

00102221 <vector92>:
.globl vector92
vector92:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $92
  102223:	6a 5c                	push   $0x5c
  jmp __alltraps
  102225:	e9 a7 fc ff ff       	jmp    101ed1 <__alltraps>

0010222a <vector93>:
.globl vector93
vector93:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $93
  10222c:	6a 5d                	push   $0x5d
  jmp __alltraps
  10222e:	e9 9e fc ff ff       	jmp    101ed1 <__alltraps>

00102233 <vector94>:
.globl vector94
vector94:
  pushl $0
  102233:	6a 00                	push   $0x0
  pushl $94
  102235:	6a 5e                	push   $0x5e
  jmp __alltraps
  102237:	e9 95 fc ff ff       	jmp    101ed1 <__alltraps>

0010223c <vector95>:
.globl vector95
vector95:
  pushl $0
  10223c:	6a 00                	push   $0x0
  pushl $95
  10223e:	6a 5f                	push   $0x5f
  jmp __alltraps
  102240:	e9 8c fc ff ff       	jmp    101ed1 <__alltraps>

00102245 <vector96>:
.globl vector96
vector96:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $96
  102247:	6a 60                	push   $0x60
  jmp __alltraps
  102249:	e9 83 fc ff ff       	jmp    101ed1 <__alltraps>

0010224e <vector97>:
.globl vector97
vector97:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $97
  102250:	6a 61                	push   $0x61
  jmp __alltraps
  102252:	e9 7a fc ff ff       	jmp    101ed1 <__alltraps>

00102257 <vector98>:
.globl vector98
vector98:
  pushl $0
  102257:	6a 00                	push   $0x0
  pushl $98
  102259:	6a 62                	push   $0x62
  jmp __alltraps
  10225b:	e9 71 fc ff ff       	jmp    101ed1 <__alltraps>

00102260 <vector99>:
.globl vector99
vector99:
  pushl $0
  102260:	6a 00                	push   $0x0
  pushl $99
  102262:	6a 63                	push   $0x63
  jmp __alltraps
  102264:	e9 68 fc ff ff       	jmp    101ed1 <__alltraps>

00102269 <vector100>:
.globl vector100
vector100:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $100
  10226b:	6a 64                	push   $0x64
  jmp __alltraps
  10226d:	e9 5f fc ff ff       	jmp    101ed1 <__alltraps>

00102272 <vector101>:
.globl vector101
vector101:
  pushl $0
  102272:	6a 00                	push   $0x0
  pushl $101
  102274:	6a 65                	push   $0x65
  jmp __alltraps
  102276:	e9 56 fc ff ff       	jmp    101ed1 <__alltraps>

0010227b <vector102>:
.globl vector102
vector102:
  pushl $0
  10227b:	6a 00                	push   $0x0
  pushl $102
  10227d:	6a 66                	push   $0x66
  jmp __alltraps
  10227f:	e9 4d fc ff ff       	jmp    101ed1 <__alltraps>

00102284 <vector103>:
.globl vector103
vector103:
  pushl $0
  102284:	6a 00                	push   $0x0
  pushl $103
  102286:	6a 67                	push   $0x67
  jmp __alltraps
  102288:	e9 44 fc ff ff       	jmp    101ed1 <__alltraps>

0010228d <vector104>:
.globl vector104
vector104:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $104
  10228f:	6a 68                	push   $0x68
  jmp __alltraps
  102291:	e9 3b fc ff ff       	jmp    101ed1 <__alltraps>

00102296 <vector105>:
.globl vector105
vector105:
  pushl $0
  102296:	6a 00                	push   $0x0
  pushl $105
  102298:	6a 69                	push   $0x69
  jmp __alltraps
  10229a:	e9 32 fc ff ff       	jmp    101ed1 <__alltraps>

0010229f <vector106>:
.globl vector106
vector106:
  pushl $0
  10229f:	6a 00                	push   $0x0
  pushl $106
  1022a1:	6a 6a                	push   $0x6a
  jmp __alltraps
  1022a3:	e9 29 fc ff ff       	jmp    101ed1 <__alltraps>

001022a8 <vector107>:
.globl vector107
vector107:
  pushl $0
  1022a8:	6a 00                	push   $0x0
  pushl $107
  1022aa:	6a 6b                	push   $0x6b
  jmp __alltraps
  1022ac:	e9 20 fc ff ff       	jmp    101ed1 <__alltraps>

001022b1 <vector108>:
.globl vector108
vector108:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $108
  1022b3:	6a 6c                	push   $0x6c
  jmp __alltraps
  1022b5:	e9 17 fc ff ff       	jmp    101ed1 <__alltraps>

001022ba <vector109>:
.globl vector109
vector109:
  pushl $0
  1022ba:	6a 00                	push   $0x0
  pushl $109
  1022bc:	6a 6d                	push   $0x6d
  jmp __alltraps
  1022be:	e9 0e fc ff ff       	jmp    101ed1 <__alltraps>

001022c3 <vector110>:
.globl vector110
vector110:
  pushl $0
  1022c3:	6a 00                	push   $0x0
  pushl $110
  1022c5:	6a 6e                	push   $0x6e
  jmp __alltraps
  1022c7:	e9 05 fc ff ff       	jmp    101ed1 <__alltraps>

001022cc <vector111>:
.globl vector111
vector111:
  pushl $0
  1022cc:	6a 00                	push   $0x0
  pushl $111
  1022ce:	6a 6f                	push   $0x6f
  jmp __alltraps
  1022d0:	e9 fc fb ff ff       	jmp    101ed1 <__alltraps>

001022d5 <vector112>:
.globl vector112
vector112:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $112
  1022d7:	6a 70                	push   $0x70
  jmp __alltraps
  1022d9:	e9 f3 fb ff ff       	jmp    101ed1 <__alltraps>

001022de <vector113>:
.globl vector113
vector113:
  pushl $0
  1022de:	6a 00                	push   $0x0
  pushl $113
  1022e0:	6a 71                	push   $0x71
  jmp __alltraps
  1022e2:	e9 ea fb ff ff       	jmp    101ed1 <__alltraps>

001022e7 <vector114>:
.globl vector114
vector114:
  pushl $0
  1022e7:	6a 00                	push   $0x0
  pushl $114
  1022e9:	6a 72                	push   $0x72
  jmp __alltraps
  1022eb:	e9 e1 fb ff ff       	jmp    101ed1 <__alltraps>

001022f0 <vector115>:
.globl vector115
vector115:
  pushl $0
  1022f0:	6a 00                	push   $0x0
  pushl $115
  1022f2:	6a 73                	push   $0x73
  jmp __alltraps
  1022f4:	e9 d8 fb ff ff       	jmp    101ed1 <__alltraps>

001022f9 <vector116>:
.globl vector116
vector116:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $116
  1022fb:	6a 74                	push   $0x74
  jmp __alltraps
  1022fd:	e9 cf fb ff ff       	jmp    101ed1 <__alltraps>

00102302 <vector117>:
.globl vector117
vector117:
  pushl $0
  102302:	6a 00                	push   $0x0
  pushl $117
  102304:	6a 75                	push   $0x75
  jmp __alltraps
  102306:	e9 c6 fb ff ff       	jmp    101ed1 <__alltraps>

0010230b <vector118>:
.globl vector118
vector118:
  pushl $0
  10230b:	6a 00                	push   $0x0
  pushl $118
  10230d:	6a 76                	push   $0x76
  jmp __alltraps
  10230f:	e9 bd fb ff ff       	jmp    101ed1 <__alltraps>

00102314 <vector119>:
.globl vector119
vector119:
  pushl $0
  102314:	6a 00                	push   $0x0
  pushl $119
  102316:	6a 77                	push   $0x77
  jmp __alltraps
  102318:	e9 b4 fb ff ff       	jmp    101ed1 <__alltraps>

0010231d <vector120>:
.globl vector120
vector120:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $120
  10231f:	6a 78                	push   $0x78
  jmp __alltraps
  102321:	e9 ab fb ff ff       	jmp    101ed1 <__alltraps>

00102326 <vector121>:
.globl vector121
vector121:
  pushl $0
  102326:	6a 00                	push   $0x0
  pushl $121
  102328:	6a 79                	push   $0x79
  jmp __alltraps
  10232a:	e9 a2 fb ff ff       	jmp    101ed1 <__alltraps>

0010232f <vector122>:
.globl vector122
vector122:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $122
  102331:	6a 7a                	push   $0x7a
  jmp __alltraps
  102333:	e9 99 fb ff ff       	jmp    101ed1 <__alltraps>

00102338 <vector123>:
.globl vector123
vector123:
  pushl $0
  102338:	6a 00                	push   $0x0
  pushl $123
  10233a:	6a 7b                	push   $0x7b
  jmp __alltraps
  10233c:	e9 90 fb ff ff       	jmp    101ed1 <__alltraps>

00102341 <vector124>:
.globl vector124
vector124:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $124
  102343:	6a 7c                	push   $0x7c
  jmp __alltraps
  102345:	e9 87 fb ff ff       	jmp    101ed1 <__alltraps>

0010234a <vector125>:
.globl vector125
vector125:
  pushl $0
  10234a:	6a 00                	push   $0x0
  pushl $125
  10234c:	6a 7d                	push   $0x7d
  jmp __alltraps
  10234e:	e9 7e fb ff ff       	jmp    101ed1 <__alltraps>

00102353 <vector126>:
.globl vector126
vector126:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $126
  102355:	6a 7e                	push   $0x7e
  jmp __alltraps
  102357:	e9 75 fb ff ff       	jmp    101ed1 <__alltraps>

0010235c <vector127>:
.globl vector127
vector127:
  pushl $0
  10235c:	6a 00                	push   $0x0
  pushl $127
  10235e:	6a 7f                	push   $0x7f
  jmp __alltraps
  102360:	e9 6c fb ff ff       	jmp    101ed1 <__alltraps>

00102365 <vector128>:
.globl vector128
vector128:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $128
  102367:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10236c:	e9 60 fb ff ff       	jmp    101ed1 <__alltraps>

00102371 <vector129>:
.globl vector129
vector129:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $129
  102373:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102378:	e9 54 fb ff ff       	jmp    101ed1 <__alltraps>

0010237d <vector130>:
.globl vector130
vector130:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $130
  10237f:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102384:	e9 48 fb ff ff       	jmp    101ed1 <__alltraps>

00102389 <vector131>:
.globl vector131
vector131:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $131
  10238b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102390:	e9 3c fb ff ff       	jmp    101ed1 <__alltraps>

00102395 <vector132>:
.globl vector132
vector132:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $132
  102397:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10239c:	e9 30 fb ff ff       	jmp    101ed1 <__alltraps>

001023a1 <vector133>:
.globl vector133
vector133:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $133
  1023a3:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1023a8:	e9 24 fb ff ff       	jmp    101ed1 <__alltraps>

001023ad <vector134>:
.globl vector134
vector134:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $134
  1023af:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1023b4:	e9 18 fb ff ff       	jmp    101ed1 <__alltraps>

001023b9 <vector135>:
.globl vector135
vector135:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $135
  1023bb:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1023c0:	e9 0c fb ff ff       	jmp    101ed1 <__alltraps>

001023c5 <vector136>:
.globl vector136
vector136:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $136
  1023c7:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1023cc:	e9 00 fb ff ff       	jmp    101ed1 <__alltraps>

001023d1 <vector137>:
.globl vector137
vector137:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $137
  1023d3:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1023d8:	e9 f4 fa ff ff       	jmp    101ed1 <__alltraps>

001023dd <vector138>:
.globl vector138
vector138:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $138
  1023df:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023e4:	e9 e8 fa ff ff       	jmp    101ed1 <__alltraps>

001023e9 <vector139>:
.globl vector139
vector139:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $139
  1023eb:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023f0:	e9 dc fa ff ff       	jmp    101ed1 <__alltraps>

001023f5 <vector140>:
.globl vector140
vector140:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $140
  1023f7:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023fc:	e9 d0 fa ff ff       	jmp    101ed1 <__alltraps>

00102401 <vector141>:
.globl vector141
vector141:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $141
  102403:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102408:	e9 c4 fa ff ff       	jmp    101ed1 <__alltraps>

0010240d <vector142>:
.globl vector142
vector142:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $142
  10240f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102414:	e9 b8 fa ff ff       	jmp    101ed1 <__alltraps>

00102419 <vector143>:
.globl vector143
vector143:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $143
  10241b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102420:	e9 ac fa ff ff       	jmp    101ed1 <__alltraps>

00102425 <vector144>:
.globl vector144
vector144:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $144
  102427:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10242c:	e9 a0 fa ff ff       	jmp    101ed1 <__alltraps>

00102431 <vector145>:
.globl vector145
vector145:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $145
  102433:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102438:	e9 94 fa ff ff       	jmp    101ed1 <__alltraps>

0010243d <vector146>:
.globl vector146
vector146:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $146
  10243f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102444:	e9 88 fa ff ff       	jmp    101ed1 <__alltraps>

00102449 <vector147>:
.globl vector147
vector147:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $147
  10244b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102450:	e9 7c fa ff ff       	jmp    101ed1 <__alltraps>

00102455 <vector148>:
.globl vector148
vector148:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $148
  102457:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10245c:	e9 70 fa ff ff       	jmp    101ed1 <__alltraps>

00102461 <vector149>:
.globl vector149
vector149:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $149
  102463:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102468:	e9 64 fa ff ff       	jmp    101ed1 <__alltraps>

0010246d <vector150>:
.globl vector150
vector150:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $150
  10246f:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102474:	e9 58 fa ff ff       	jmp    101ed1 <__alltraps>

00102479 <vector151>:
.globl vector151
vector151:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $151
  10247b:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102480:	e9 4c fa ff ff       	jmp    101ed1 <__alltraps>

00102485 <vector152>:
.globl vector152
vector152:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $152
  102487:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10248c:	e9 40 fa ff ff       	jmp    101ed1 <__alltraps>

00102491 <vector153>:
.globl vector153
vector153:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $153
  102493:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102498:	e9 34 fa ff ff       	jmp    101ed1 <__alltraps>

0010249d <vector154>:
.globl vector154
vector154:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $154
  10249f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1024a4:	e9 28 fa ff ff       	jmp    101ed1 <__alltraps>

001024a9 <vector155>:
.globl vector155
vector155:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $155
  1024ab:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1024b0:	e9 1c fa ff ff       	jmp    101ed1 <__alltraps>

001024b5 <vector156>:
.globl vector156
vector156:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $156
  1024b7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1024bc:	e9 10 fa ff ff       	jmp    101ed1 <__alltraps>

001024c1 <vector157>:
.globl vector157
vector157:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $157
  1024c3:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1024c8:	e9 04 fa ff ff       	jmp    101ed1 <__alltraps>

001024cd <vector158>:
.globl vector158
vector158:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $158
  1024cf:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1024d4:	e9 f8 f9 ff ff       	jmp    101ed1 <__alltraps>

001024d9 <vector159>:
.globl vector159
vector159:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $159
  1024db:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1024e0:	e9 ec f9 ff ff       	jmp    101ed1 <__alltraps>

001024e5 <vector160>:
.globl vector160
vector160:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $160
  1024e7:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024ec:	e9 e0 f9 ff ff       	jmp    101ed1 <__alltraps>

001024f1 <vector161>:
.globl vector161
vector161:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $161
  1024f3:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024f8:	e9 d4 f9 ff ff       	jmp    101ed1 <__alltraps>

001024fd <vector162>:
.globl vector162
vector162:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $162
  1024ff:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102504:	e9 c8 f9 ff ff       	jmp    101ed1 <__alltraps>

00102509 <vector163>:
.globl vector163
vector163:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $163
  10250b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102510:	e9 bc f9 ff ff       	jmp    101ed1 <__alltraps>

00102515 <vector164>:
.globl vector164
vector164:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $164
  102517:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10251c:	e9 b0 f9 ff ff       	jmp    101ed1 <__alltraps>

00102521 <vector165>:
.globl vector165
vector165:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $165
  102523:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102528:	e9 a4 f9 ff ff       	jmp    101ed1 <__alltraps>

0010252d <vector166>:
.globl vector166
vector166:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $166
  10252f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102534:	e9 98 f9 ff ff       	jmp    101ed1 <__alltraps>

00102539 <vector167>:
.globl vector167
vector167:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $167
  10253b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102540:	e9 8c f9 ff ff       	jmp    101ed1 <__alltraps>

00102545 <vector168>:
.globl vector168
vector168:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $168
  102547:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10254c:	e9 80 f9 ff ff       	jmp    101ed1 <__alltraps>

00102551 <vector169>:
.globl vector169
vector169:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $169
  102553:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102558:	e9 74 f9 ff ff       	jmp    101ed1 <__alltraps>

0010255d <vector170>:
.globl vector170
vector170:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $170
  10255f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102564:	e9 68 f9 ff ff       	jmp    101ed1 <__alltraps>

00102569 <vector171>:
.globl vector171
vector171:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $171
  10256b:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102570:	e9 5c f9 ff ff       	jmp    101ed1 <__alltraps>

00102575 <vector172>:
.globl vector172
vector172:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $172
  102577:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10257c:	e9 50 f9 ff ff       	jmp    101ed1 <__alltraps>

00102581 <vector173>:
.globl vector173
vector173:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $173
  102583:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102588:	e9 44 f9 ff ff       	jmp    101ed1 <__alltraps>

0010258d <vector174>:
.globl vector174
vector174:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $174
  10258f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102594:	e9 38 f9 ff ff       	jmp    101ed1 <__alltraps>

00102599 <vector175>:
.globl vector175
vector175:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $175
  10259b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1025a0:	e9 2c f9 ff ff       	jmp    101ed1 <__alltraps>

001025a5 <vector176>:
.globl vector176
vector176:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $176
  1025a7:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1025ac:	e9 20 f9 ff ff       	jmp    101ed1 <__alltraps>

001025b1 <vector177>:
.globl vector177
vector177:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $177
  1025b3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1025b8:	e9 14 f9 ff ff       	jmp    101ed1 <__alltraps>

001025bd <vector178>:
.globl vector178
vector178:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $178
  1025bf:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1025c4:	e9 08 f9 ff ff       	jmp    101ed1 <__alltraps>

001025c9 <vector179>:
.globl vector179
vector179:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $179
  1025cb:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1025d0:	e9 fc f8 ff ff       	jmp    101ed1 <__alltraps>

001025d5 <vector180>:
.globl vector180
vector180:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $180
  1025d7:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1025dc:	e9 f0 f8 ff ff       	jmp    101ed1 <__alltraps>

001025e1 <vector181>:
.globl vector181
vector181:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $181
  1025e3:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025e8:	e9 e4 f8 ff ff       	jmp    101ed1 <__alltraps>

001025ed <vector182>:
.globl vector182
vector182:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $182
  1025ef:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025f4:	e9 d8 f8 ff ff       	jmp    101ed1 <__alltraps>

001025f9 <vector183>:
.globl vector183
vector183:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $183
  1025fb:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102600:	e9 cc f8 ff ff       	jmp    101ed1 <__alltraps>

00102605 <vector184>:
.globl vector184
vector184:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $184
  102607:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10260c:	e9 c0 f8 ff ff       	jmp    101ed1 <__alltraps>

00102611 <vector185>:
.globl vector185
vector185:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $185
  102613:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102618:	e9 b4 f8 ff ff       	jmp    101ed1 <__alltraps>

0010261d <vector186>:
.globl vector186
vector186:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $186
  10261f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102624:	e9 a8 f8 ff ff       	jmp    101ed1 <__alltraps>

00102629 <vector187>:
.globl vector187
vector187:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $187
  10262b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102630:	e9 9c f8 ff ff       	jmp    101ed1 <__alltraps>

00102635 <vector188>:
.globl vector188
vector188:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $188
  102637:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10263c:	e9 90 f8 ff ff       	jmp    101ed1 <__alltraps>

00102641 <vector189>:
.globl vector189
vector189:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $189
  102643:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102648:	e9 84 f8 ff ff       	jmp    101ed1 <__alltraps>

0010264d <vector190>:
.globl vector190
vector190:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $190
  10264f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102654:	e9 78 f8 ff ff       	jmp    101ed1 <__alltraps>

00102659 <vector191>:
.globl vector191
vector191:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $191
  10265b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102660:	e9 6c f8 ff ff       	jmp    101ed1 <__alltraps>

00102665 <vector192>:
.globl vector192
vector192:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $192
  102667:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10266c:	e9 60 f8 ff ff       	jmp    101ed1 <__alltraps>

00102671 <vector193>:
.globl vector193
vector193:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $193
  102673:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102678:	e9 54 f8 ff ff       	jmp    101ed1 <__alltraps>

0010267d <vector194>:
.globl vector194
vector194:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $194
  10267f:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102684:	e9 48 f8 ff ff       	jmp    101ed1 <__alltraps>

00102689 <vector195>:
.globl vector195
vector195:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $195
  10268b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102690:	e9 3c f8 ff ff       	jmp    101ed1 <__alltraps>

00102695 <vector196>:
.globl vector196
vector196:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $196
  102697:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10269c:	e9 30 f8 ff ff       	jmp    101ed1 <__alltraps>

001026a1 <vector197>:
.globl vector197
vector197:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $197
  1026a3:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1026a8:	e9 24 f8 ff ff       	jmp    101ed1 <__alltraps>

001026ad <vector198>:
.globl vector198
vector198:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $198
  1026af:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1026b4:	e9 18 f8 ff ff       	jmp    101ed1 <__alltraps>

001026b9 <vector199>:
.globl vector199
vector199:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $199
  1026bb:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1026c0:	e9 0c f8 ff ff       	jmp    101ed1 <__alltraps>

001026c5 <vector200>:
.globl vector200
vector200:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $200
  1026c7:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1026cc:	e9 00 f8 ff ff       	jmp    101ed1 <__alltraps>

001026d1 <vector201>:
.globl vector201
vector201:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $201
  1026d3:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1026d8:	e9 f4 f7 ff ff       	jmp    101ed1 <__alltraps>

001026dd <vector202>:
.globl vector202
vector202:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $202
  1026df:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026e4:	e9 e8 f7 ff ff       	jmp    101ed1 <__alltraps>

001026e9 <vector203>:
.globl vector203
vector203:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $203
  1026eb:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026f0:	e9 dc f7 ff ff       	jmp    101ed1 <__alltraps>

001026f5 <vector204>:
.globl vector204
vector204:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $204
  1026f7:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026fc:	e9 d0 f7 ff ff       	jmp    101ed1 <__alltraps>

00102701 <vector205>:
.globl vector205
vector205:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $205
  102703:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102708:	e9 c4 f7 ff ff       	jmp    101ed1 <__alltraps>

0010270d <vector206>:
.globl vector206
vector206:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $206
  10270f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102714:	e9 b8 f7 ff ff       	jmp    101ed1 <__alltraps>

00102719 <vector207>:
.globl vector207
vector207:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $207
  10271b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102720:	e9 ac f7 ff ff       	jmp    101ed1 <__alltraps>

00102725 <vector208>:
.globl vector208
vector208:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $208
  102727:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10272c:	e9 a0 f7 ff ff       	jmp    101ed1 <__alltraps>

00102731 <vector209>:
.globl vector209
vector209:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $209
  102733:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102738:	e9 94 f7 ff ff       	jmp    101ed1 <__alltraps>

0010273d <vector210>:
.globl vector210
vector210:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $210
  10273f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102744:	e9 88 f7 ff ff       	jmp    101ed1 <__alltraps>

00102749 <vector211>:
.globl vector211
vector211:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $211
  10274b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102750:	e9 7c f7 ff ff       	jmp    101ed1 <__alltraps>

00102755 <vector212>:
.globl vector212
vector212:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $212
  102757:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10275c:	e9 70 f7 ff ff       	jmp    101ed1 <__alltraps>

00102761 <vector213>:
.globl vector213
vector213:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $213
  102763:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102768:	e9 64 f7 ff ff       	jmp    101ed1 <__alltraps>

0010276d <vector214>:
.globl vector214
vector214:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $214
  10276f:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102774:	e9 58 f7 ff ff       	jmp    101ed1 <__alltraps>

00102779 <vector215>:
.globl vector215
vector215:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $215
  10277b:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102780:	e9 4c f7 ff ff       	jmp    101ed1 <__alltraps>

00102785 <vector216>:
.globl vector216
vector216:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $216
  102787:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10278c:	e9 40 f7 ff ff       	jmp    101ed1 <__alltraps>

00102791 <vector217>:
.globl vector217
vector217:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $217
  102793:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102798:	e9 34 f7 ff ff       	jmp    101ed1 <__alltraps>

0010279d <vector218>:
.globl vector218
vector218:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $218
  10279f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1027a4:	e9 28 f7 ff ff       	jmp    101ed1 <__alltraps>

001027a9 <vector219>:
.globl vector219
vector219:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $219
  1027ab:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1027b0:	e9 1c f7 ff ff       	jmp    101ed1 <__alltraps>

001027b5 <vector220>:
.globl vector220
vector220:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $220
  1027b7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1027bc:	e9 10 f7 ff ff       	jmp    101ed1 <__alltraps>

001027c1 <vector221>:
.globl vector221
vector221:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $221
  1027c3:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1027c8:	e9 04 f7 ff ff       	jmp    101ed1 <__alltraps>

001027cd <vector222>:
.globl vector222
vector222:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $222
  1027cf:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1027d4:	e9 f8 f6 ff ff       	jmp    101ed1 <__alltraps>

001027d9 <vector223>:
.globl vector223
vector223:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $223
  1027db:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1027e0:	e9 ec f6 ff ff       	jmp    101ed1 <__alltraps>

001027e5 <vector224>:
.globl vector224
vector224:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $224
  1027e7:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027ec:	e9 e0 f6 ff ff       	jmp    101ed1 <__alltraps>

001027f1 <vector225>:
.globl vector225
vector225:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $225
  1027f3:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027f8:	e9 d4 f6 ff ff       	jmp    101ed1 <__alltraps>

001027fd <vector226>:
.globl vector226
vector226:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $226
  1027ff:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102804:	e9 c8 f6 ff ff       	jmp    101ed1 <__alltraps>

00102809 <vector227>:
.globl vector227
vector227:
  pushl $0
  102809:	6a 00                	push   $0x0
  pushl $227
  10280b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102810:	e9 bc f6 ff ff       	jmp    101ed1 <__alltraps>

00102815 <vector228>:
.globl vector228
vector228:
  pushl $0
  102815:	6a 00                	push   $0x0
  pushl $228
  102817:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10281c:	e9 b0 f6 ff ff       	jmp    101ed1 <__alltraps>

00102821 <vector229>:
.globl vector229
vector229:
  pushl $0
  102821:	6a 00                	push   $0x0
  pushl $229
  102823:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102828:	e9 a4 f6 ff ff       	jmp    101ed1 <__alltraps>

0010282d <vector230>:
.globl vector230
vector230:
  pushl $0
  10282d:	6a 00                	push   $0x0
  pushl $230
  10282f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102834:	e9 98 f6 ff ff       	jmp    101ed1 <__alltraps>

00102839 <vector231>:
.globl vector231
vector231:
  pushl $0
  102839:	6a 00                	push   $0x0
  pushl $231
  10283b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102840:	e9 8c f6 ff ff       	jmp    101ed1 <__alltraps>

00102845 <vector232>:
.globl vector232
vector232:
  pushl $0
  102845:	6a 00                	push   $0x0
  pushl $232
  102847:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10284c:	e9 80 f6 ff ff       	jmp    101ed1 <__alltraps>

00102851 <vector233>:
.globl vector233
vector233:
  pushl $0
  102851:	6a 00                	push   $0x0
  pushl $233
  102853:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102858:	e9 74 f6 ff ff       	jmp    101ed1 <__alltraps>

0010285d <vector234>:
.globl vector234
vector234:
  pushl $0
  10285d:	6a 00                	push   $0x0
  pushl $234
  10285f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102864:	e9 68 f6 ff ff       	jmp    101ed1 <__alltraps>

00102869 <vector235>:
.globl vector235
vector235:
  pushl $0
  102869:	6a 00                	push   $0x0
  pushl $235
  10286b:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102870:	e9 5c f6 ff ff       	jmp    101ed1 <__alltraps>

00102875 <vector236>:
.globl vector236
vector236:
  pushl $0
  102875:	6a 00                	push   $0x0
  pushl $236
  102877:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10287c:	e9 50 f6 ff ff       	jmp    101ed1 <__alltraps>

00102881 <vector237>:
.globl vector237
vector237:
  pushl $0
  102881:	6a 00                	push   $0x0
  pushl $237
  102883:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102888:	e9 44 f6 ff ff       	jmp    101ed1 <__alltraps>

0010288d <vector238>:
.globl vector238
vector238:
  pushl $0
  10288d:	6a 00                	push   $0x0
  pushl $238
  10288f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102894:	e9 38 f6 ff ff       	jmp    101ed1 <__alltraps>

00102899 <vector239>:
.globl vector239
vector239:
  pushl $0
  102899:	6a 00                	push   $0x0
  pushl $239
  10289b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1028a0:	e9 2c f6 ff ff       	jmp    101ed1 <__alltraps>

001028a5 <vector240>:
.globl vector240
vector240:
  pushl $0
  1028a5:	6a 00                	push   $0x0
  pushl $240
  1028a7:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1028ac:	e9 20 f6 ff ff       	jmp    101ed1 <__alltraps>

001028b1 <vector241>:
.globl vector241
vector241:
  pushl $0
  1028b1:	6a 00                	push   $0x0
  pushl $241
  1028b3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1028b8:	e9 14 f6 ff ff       	jmp    101ed1 <__alltraps>

001028bd <vector242>:
.globl vector242
vector242:
  pushl $0
  1028bd:	6a 00                	push   $0x0
  pushl $242
  1028bf:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1028c4:	e9 08 f6 ff ff       	jmp    101ed1 <__alltraps>

001028c9 <vector243>:
.globl vector243
vector243:
  pushl $0
  1028c9:	6a 00                	push   $0x0
  pushl $243
  1028cb:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1028d0:	e9 fc f5 ff ff       	jmp    101ed1 <__alltraps>

001028d5 <vector244>:
.globl vector244
vector244:
  pushl $0
  1028d5:	6a 00                	push   $0x0
  pushl $244
  1028d7:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1028dc:	e9 f0 f5 ff ff       	jmp    101ed1 <__alltraps>

001028e1 <vector245>:
.globl vector245
vector245:
  pushl $0
  1028e1:	6a 00                	push   $0x0
  pushl $245
  1028e3:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028e8:	e9 e4 f5 ff ff       	jmp    101ed1 <__alltraps>

001028ed <vector246>:
.globl vector246
vector246:
  pushl $0
  1028ed:	6a 00                	push   $0x0
  pushl $246
  1028ef:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028f4:	e9 d8 f5 ff ff       	jmp    101ed1 <__alltraps>

001028f9 <vector247>:
.globl vector247
vector247:
  pushl $0
  1028f9:	6a 00                	push   $0x0
  pushl $247
  1028fb:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102900:	e9 cc f5 ff ff       	jmp    101ed1 <__alltraps>

00102905 <vector248>:
.globl vector248
vector248:
  pushl $0
  102905:	6a 00                	push   $0x0
  pushl $248
  102907:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10290c:	e9 c0 f5 ff ff       	jmp    101ed1 <__alltraps>

00102911 <vector249>:
.globl vector249
vector249:
  pushl $0
  102911:	6a 00                	push   $0x0
  pushl $249
  102913:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102918:	e9 b4 f5 ff ff       	jmp    101ed1 <__alltraps>

0010291d <vector250>:
.globl vector250
vector250:
  pushl $0
  10291d:	6a 00                	push   $0x0
  pushl $250
  10291f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102924:	e9 a8 f5 ff ff       	jmp    101ed1 <__alltraps>

00102929 <vector251>:
.globl vector251
vector251:
  pushl $0
  102929:	6a 00                	push   $0x0
  pushl $251
  10292b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102930:	e9 9c f5 ff ff       	jmp    101ed1 <__alltraps>

00102935 <vector252>:
.globl vector252
vector252:
  pushl $0
  102935:	6a 00                	push   $0x0
  pushl $252
  102937:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  10293c:	e9 90 f5 ff ff       	jmp    101ed1 <__alltraps>

00102941 <vector253>:
.globl vector253
vector253:
  pushl $0
  102941:	6a 00                	push   $0x0
  pushl $253
  102943:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102948:	e9 84 f5 ff ff       	jmp    101ed1 <__alltraps>

0010294d <vector254>:
.globl vector254
vector254:
  pushl $0
  10294d:	6a 00                	push   $0x0
  pushl $254
  10294f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102954:	e9 78 f5 ff ff       	jmp    101ed1 <__alltraps>

00102959 <vector255>:
.globl vector255
vector255:
  pushl $0
  102959:	6a 00                	push   $0x0
  pushl $255
  10295b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102960:	e9 6c f5 ff ff       	jmp    101ed1 <__alltraps>

00102965 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102965:	55                   	push   %ebp
  102966:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102968:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  10296e:	8b 45 08             	mov    0x8(%ebp),%eax
  102971:	29 d0                	sub    %edx,%eax
  102973:	c1 f8 02             	sar    $0x2,%eax
  102976:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10297c:	5d                   	pop    %ebp
  10297d:	c3                   	ret    

0010297e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  10297e:	55                   	push   %ebp
  10297f:	89 e5                	mov    %esp,%ebp
  102981:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102984:	8b 45 08             	mov    0x8(%ebp),%eax
  102987:	89 04 24             	mov    %eax,(%esp)
  10298a:	e8 d6 ff ff ff       	call   102965 <page2ppn>
  10298f:	c1 e0 0c             	shl    $0xc,%eax
}
  102992:	89 ec                	mov    %ebp,%esp
  102994:	5d                   	pop    %ebp
  102995:	c3                   	ret    

00102996 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102996:	55                   	push   %ebp
  102997:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102999:	8b 45 08             	mov    0x8(%ebp),%eax
  10299c:	8b 00                	mov    (%eax),%eax
}
  10299e:	5d                   	pop    %ebp
  10299f:	c3                   	ret    

001029a0 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029a0:	55                   	push   %ebp
  1029a1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029a9:	89 10                	mov    %edx,(%eax)
}
  1029ab:	90                   	nop
  1029ac:	5d                   	pop    %ebp
  1029ad:	c3                   	ret    

001029ae <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1029ae:	55                   	push   %ebp
  1029af:	89 e5                	mov    %esp,%ebp
  1029b1:	83 ec 10             	sub    $0x10,%esp
  1029b4:	c7 45 fc 80 be 11 00 	movl   $0x11be80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1029bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029be:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1029c1:	89 50 04             	mov    %edx,0x4(%eax)
  1029c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029c7:	8b 50 04             	mov    0x4(%eax),%edx
  1029ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029cd:	89 10                	mov    %edx,(%eax)
}
  1029cf:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  1029d0:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  1029d7:	00 00 00 
}
  1029da:	90                   	nop
  1029db:	89 ec                	mov    %ebp,%esp
  1029dd:	5d                   	pop    %ebp
  1029de:	c3                   	ret    

001029df <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1029df:	55                   	push   %ebp
  1029e0:	89 e5                	mov    %esp,%ebp
  1029e2:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  1029e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1029e9:	75 24                	jne    102a0f <default_init_memmap+0x30>
  1029eb:	c7 44 24 0c f0 65 10 	movl   $0x1065f0,0xc(%esp)
  1029f2:	00 
  1029f3:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1029fa:	00 
  1029fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102a02:	00 
  102a03:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102a0a:	e8 cc e2 ff ff       	call   100cdb <__panic>
    struct Page *p = base;
  102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  102a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102a15:	eb 7d                	jmp    102a94 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a1a:	83 c0 04             	add    $0x4,%eax
  102a1d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102a24:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a2d:	0f a3 10             	bt     %edx,(%eax)
  102a30:	19 c0                	sbb    %eax,%eax
  102a32:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102a35:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102a39:	0f 95 c0             	setne  %al
  102a3c:	0f b6 c0             	movzbl %al,%eax
  102a3f:	85 c0                	test   %eax,%eax
  102a41:	75 24                	jne    102a67 <default_init_memmap+0x88>
  102a43:	c7 44 24 0c 21 66 10 	movl   $0x106621,0xc(%esp)
  102a4a:	00 
  102a4b:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102a52:	00 
  102a53:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102a5a:	00 
  102a5b:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102a62:	e8 74 e2 ff ff       	call   100cdb <__panic>
        p->flags = p->property = 0;
  102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a74:	8b 50 08             	mov    0x8(%eax),%edx
  102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a7a:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102a7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102a84:	00 
  102a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a88:	89 04 24             	mov    %eax,(%esp)
  102a8b:	e8 10 ff ff ff       	call   1029a0 <set_page_ref>
    for (; p != base + n; p ++) {
  102a90:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a97:	89 d0                	mov    %edx,%eax
  102a99:	c1 e0 02             	shl    $0x2,%eax
  102a9c:	01 d0                	add    %edx,%eax
  102a9e:	c1 e0 02             	shl    $0x2,%eax
  102aa1:	89 c2                	mov    %eax,%edx
  102aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  102aa6:	01 d0                	add    %edx,%eax
  102aa8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102aab:	0f 85 66 ff ff ff    	jne    102a17 <default_init_memmap+0x38>
    }
    base->property = n;
  102ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ab7:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102aba:	8b 45 08             	mov    0x8(%ebp),%eax
  102abd:	83 c0 04             	add    $0x4,%eax
  102ac0:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  102ac7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102aca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102acd:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102ad0:	0f ab 10             	bts    %edx,(%eax)
}
  102ad3:	90                   	nop
    nr_free += n;
  102ad4:	8b 15 88 be 11 00    	mov    0x11be88,%edx
  102ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  102add:	01 d0                	add    %edx,%eax
  102adf:	a3 88 be 11 00       	mov    %eax,0x11be88
    list_add(&free_list, &(base->page_link));
  102ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae7:	83 c0 0c             	add    $0xc,%eax
  102aea:	c7 45 e4 80 be 11 00 	movl   $0x11be80,-0x1c(%ebp)
  102af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102af7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b00:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b03:	8b 40 04             	mov    0x4(%eax),%eax
  102b06:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102b09:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102b0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102b0f:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102b12:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b15:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b1b:	89 10                	mov    %edx,(%eax)
  102b1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b20:	8b 10                	mov    (%eax),%edx
  102b22:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b25:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b2b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b2e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b34:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b37:	89 10                	mov    %edx,(%eax)
}
  102b39:	90                   	nop
}
  102b3a:	90                   	nop
}
  102b3b:	90                   	nop
}
  102b3c:	90                   	nop
  102b3d:	89 ec                	mov    %ebp,%esp
  102b3f:	5d                   	pop    %ebp
  102b40:	c3                   	ret    

00102b41 <default_alloc_pages>:
//页的分配函数
static struct Page *  
default_alloc_pages(size_t n) {
  102b41:	55                   	push   %ebp
  102b42:	89 e5                	mov    %esp,%ebp
  102b44:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102b47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102b4b:	75 24                	jne    102b71 <default_alloc_pages+0x30>
  102b4d:	c7 44 24 0c f0 65 10 	movl   $0x1065f0,0xc(%esp)
  102b54:	00 
  102b55:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102b5c:	00 
  102b5d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102b64:	00 
  102b65:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102b6c:	e8 6a e1 ff ff       	call   100cdb <__panic>
    if (n > nr_free) {
  102b71:	a1 88 be 11 00       	mov    0x11be88,%eax
  102b76:	39 45 08             	cmp    %eax,0x8(%ebp)
  102b79:	76 0a                	jbe    102b85 <default_alloc_pages+0x44>
        return NULL;
  102b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  102b80:	e9 34 01 00 00       	jmp    102cb9 <default_alloc_pages+0x178>
    }
    struct Page *page = NULL;
  102b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102b8c:	c7 45 f0 80 be 11 00 	movl   $0x11be80,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102b93:	eb 1c                	jmp    102bb1 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b98:	83 e8 0c             	sub    $0xc,%eax
  102b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ba1:	8b 40 08             	mov    0x8(%eax),%eax
  102ba4:	39 45 08             	cmp    %eax,0x8(%ebp)
  102ba7:	77 08                	ja     102bb1 <default_alloc_pages+0x70>
            page = p;
  102ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102baf:	eb 18                	jmp    102bc9 <default_alloc_pages+0x88>
  102bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  102bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102bba:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  102bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102bc0:	81 7d f0 80 be 11 00 	cmpl   $0x11be80,-0x10(%ebp)
  102bc7:	75 cc                	jne    102b95 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  102bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102bcd:	0f 84 e3 00 00 00    	je     102cb6 <default_alloc_pages+0x175>
        list_del(&(page->page_link));
  102bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bd6:	83 c0 0c             	add    $0xc,%eax
  102bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
  102bdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102bdf:	8b 40 04             	mov    0x4(%eax),%eax
  102be2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102be5:	8b 12                	mov    (%edx),%edx
  102be7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102bea:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102bed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102bf0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102bf3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102bf6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102bf9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102bfc:	89 10                	mov    %edx,(%eax)
}
  102bfe:	90                   	nop
}
  102bff:	90                   	nop
        if (page->property > n) {
  102c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c03:	8b 40 08             	mov    0x8(%eax),%eax
  102c06:	39 45 08             	cmp    %eax,0x8(%ebp)
  102c09:	0f 83 80 00 00 00    	jae    102c8f <default_alloc_pages+0x14e>
            struct Page *p = page + n;
  102c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  102c12:	89 d0                	mov    %edx,%eax
  102c14:	c1 e0 02             	shl    $0x2,%eax
  102c17:	01 d0                	add    %edx,%eax
  102c19:	c1 e0 02             	shl    $0x2,%eax
  102c1c:	89 c2                	mov    %eax,%edx
  102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c21:	01 d0                	add    %edx,%eax
  102c23:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c29:	8b 40 08             	mov    0x8(%eax),%eax
  102c2c:	2b 45 08             	sub    0x8(%ebp),%eax
  102c2f:	89 c2                	mov    %eax,%edx
  102c31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c34:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
  102c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c3a:	83 c0 0c             	add    $0xc,%eax
  102c3d:	c7 45 d4 80 be 11 00 	movl   $0x11be80,-0x2c(%ebp)
  102c44:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102c47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102c4a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  102c4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c50:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
  102c53:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102c56:	8b 40 04             	mov    0x4(%eax),%eax
  102c59:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102c5c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  102c5f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102c62:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102c65:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
  102c68:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c6b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102c6e:	89 10                	mov    %edx,(%eax)
  102c70:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c73:	8b 10                	mov    (%eax),%edx
  102c75:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102c78:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102c7b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102c7e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102c81:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102c84:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102c87:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102c8a:	89 10                	mov    %edx,(%eax)
}
  102c8c:	90                   	nop
}
  102c8d:	90                   	nop
}
  102c8e:	90                   	nop
    }
        nr_free -= n;
  102c8f:	a1 88 be 11 00       	mov    0x11be88,%eax
  102c94:	2b 45 08             	sub    0x8(%ebp),%eax
  102c97:	a3 88 be 11 00       	mov    %eax,0x11be88
        ClearPageProperty(page);
  102c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c9f:	83 c0 04             	add    $0x4,%eax
  102ca2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102ca9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cac:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102caf:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102cb2:	0f b3 10             	btr    %edx,(%eax)
}
  102cb5:	90                   	nop
    }
    return page;
  102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102cb9:	89 ec                	mov    %ebp,%esp
  102cbb:	5d                   	pop    %ebp
  102cbc:	c3                   	ret    

00102cbd <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102cbd:	55                   	push   %ebp
  102cbe:	89 e5                	mov    %esp,%ebp
  102cc0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102cc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102cca:	75 24                	jne    102cf0 <default_free_pages+0x33>
  102ccc:	c7 44 24 0c f0 65 10 	movl   $0x1065f0,0xc(%esp)
  102cd3:	00 
  102cd4:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102cdb:	00 
  102cdc:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  102ce3:	00 
  102ce4:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102ceb:	e8 eb df ff ff       	call   100cdb <__panic>
    struct Page *p = base;
  102cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102cf6:	e9 9d 00 00 00       	jmp    102d98 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cfe:	83 c0 04             	add    $0x4,%eax
  102d01:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102d08:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102d11:	0f a3 10             	bt     %edx,(%eax)
  102d14:	19 c0                	sbb    %eax,%eax
  102d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102d19:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d1d:	0f 95 c0             	setne  %al
  102d20:	0f b6 c0             	movzbl %al,%eax
  102d23:	85 c0                	test   %eax,%eax
  102d25:	75 2c                	jne    102d53 <default_free_pages+0x96>
  102d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d2a:	83 c0 04             	add    $0x4,%eax
  102d2d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102d34:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d37:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d3a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102d3d:	0f a3 10             	bt     %edx,(%eax)
  102d40:	19 c0                	sbb    %eax,%eax
  102d42:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102d45:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102d49:	0f 95 c0             	setne  %al
  102d4c:	0f b6 c0             	movzbl %al,%eax
  102d4f:	85 c0                	test   %eax,%eax
  102d51:	74 24                	je     102d77 <default_free_pages+0xba>
  102d53:	c7 44 24 0c 34 66 10 	movl   $0x106634,0xc(%esp)
  102d5a:	00 
  102d5b:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102d62:	00 
  102d63:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  102d6a:	00 
  102d6b:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102d72:	e8 64 df ff ff       	call   100cdb <__panic>
        p->flags = 0;
  102d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d7a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102d81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d88:	00 
  102d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d8c:	89 04 24             	mov    %eax,(%esp)
  102d8f:	e8 0c fc ff ff       	call   1029a0 <set_page_ref>
    for (; p != base + n; p ++) {
  102d94:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d9b:	89 d0                	mov    %edx,%eax
  102d9d:	c1 e0 02             	shl    $0x2,%eax
  102da0:	01 d0                	add    %edx,%eax
  102da2:	c1 e0 02             	shl    $0x2,%eax
  102da5:	89 c2                	mov    %eax,%edx
  102da7:	8b 45 08             	mov    0x8(%ebp),%eax
  102daa:	01 d0                	add    %edx,%eax
  102dac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102daf:	0f 85 46 ff ff ff    	jne    102cfb <default_free_pages+0x3e>
    }
    base->property = n;
  102db5:	8b 45 08             	mov    0x8(%ebp),%eax
  102db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dbb:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc1:	83 c0 04             	add    $0x4,%eax
  102dc4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102dcb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102dd1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102dd4:	0f ab 10             	bts    %edx,(%eax)
}
  102dd7:	90                   	nop
  102dd8:	c7 45 d4 80 be 11 00 	movl   $0x11be80,-0x2c(%ebp)
    return listelm->next;
  102ddf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102de2:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102de5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102de8:	e9 0e 01 00 00       	jmp    102efb <default_free_pages+0x23e>
        p = le2page(le, page_link);
  102ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102df0:	83 e8 0c             	sub    $0xc,%eax
  102df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102df9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102dfc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102dff:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102e05:	8b 45 08             	mov    0x8(%ebp),%eax
  102e08:	8b 50 08             	mov    0x8(%eax),%edx
  102e0b:	89 d0                	mov    %edx,%eax
  102e0d:	c1 e0 02             	shl    $0x2,%eax
  102e10:	01 d0                	add    %edx,%eax
  102e12:	c1 e0 02             	shl    $0x2,%eax
  102e15:	89 c2                	mov    %eax,%edx
  102e17:	8b 45 08             	mov    0x8(%ebp),%eax
  102e1a:	01 d0                	add    %edx,%eax
  102e1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102e1f:	75 5d                	jne    102e7e <default_free_pages+0x1c1>
            base->property += p->property;
  102e21:	8b 45 08             	mov    0x8(%ebp),%eax
  102e24:	8b 50 08             	mov    0x8(%eax),%edx
  102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e2a:	8b 40 08             	mov    0x8(%eax),%eax
  102e2d:	01 c2                	add    %eax,%edx
  102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  102e32:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e38:	83 c0 04             	add    $0x4,%eax
  102e3b:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102e42:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e45:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102e48:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102e4b:	0f b3 10             	btr    %edx,(%eax)
}
  102e4e:	90                   	nop
            list_del(&(p->page_link));
  102e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e52:	83 c0 0c             	add    $0xc,%eax
  102e55:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102e58:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102e5b:	8b 40 04             	mov    0x4(%eax),%eax
  102e5e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102e61:	8b 12                	mov    (%edx),%edx
  102e63:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102e66:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  102e69:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e6c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102e6f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102e72:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e75:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102e78:	89 10                	mov    %edx,(%eax)
}
  102e7a:	90                   	nop
}
  102e7b:	90                   	nop
  102e7c:	eb 7d                	jmp    102efb <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
  102e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e81:	8b 50 08             	mov    0x8(%eax),%edx
  102e84:	89 d0                	mov    %edx,%eax
  102e86:	c1 e0 02             	shl    $0x2,%eax
  102e89:	01 d0                	add    %edx,%eax
  102e8b:	c1 e0 02             	shl    $0x2,%eax
  102e8e:	89 c2                	mov    %eax,%edx
  102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e93:	01 d0                	add    %edx,%eax
  102e95:	39 45 08             	cmp    %eax,0x8(%ebp)
  102e98:	75 61                	jne    102efb <default_free_pages+0x23e>
            p->property += base->property;
  102e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e9d:	8b 50 08             	mov    0x8(%eax),%edx
  102ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea3:	8b 40 08             	mov    0x8(%eax),%eax
  102ea6:	01 c2                	add    %eax,%edx
  102ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eab:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102eae:	8b 45 08             	mov    0x8(%ebp),%eax
  102eb1:	83 c0 04             	add    $0x4,%eax
  102eb4:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  102ebb:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ebe:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ec1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ec4:	0f b3 10             	btr    %edx,(%eax)
}
  102ec7:	90                   	nop
            base = p;
  102ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ecb:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ed1:	83 c0 0c             	add    $0xc,%eax
  102ed4:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  102ed7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102eda:	8b 40 04             	mov    0x4(%eax),%eax
  102edd:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102ee0:	8b 12                	mov    (%edx),%edx
  102ee2:	89 55 ac             	mov    %edx,-0x54(%ebp)
  102ee5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  102ee8:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102eeb:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102eee:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ef1:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102ef4:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102ef7:	89 10                	mov    %edx,(%eax)
}
  102ef9:	90                   	nop
}
  102efa:	90                   	nop
    while (le != &free_list) {
  102efb:	81 7d f0 80 be 11 00 	cmpl   $0x11be80,-0x10(%ebp)
  102f02:	0f 85 e5 fe ff ff    	jne    102ded <default_free_pages+0x130>
        }
    }
    nr_free += n;
  102f08:	8b 15 88 be 11 00    	mov    0x11be88,%edx
  102f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f11:	01 d0                	add    %edx,%eax
  102f13:	a3 88 be 11 00       	mov    %eax,0x11be88
    list_add(&free_list, &(base->page_link));
  102f18:	8b 45 08             	mov    0x8(%ebp),%eax
  102f1b:	83 c0 0c             	add    $0xc,%eax
  102f1e:	c7 45 9c 80 be 11 00 	movl   $0x11be80,-0x64(%ebp)
  102f25:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f28:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f2b:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102f2e:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f31:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm, listelm->next);
  102f34:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102f37:	8b 40 04             	mov    0x4(%eax),%eax
  102f3a:	8b 55 90             	mov    -0x70(%ebp),%edx
  102f3d:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102f40:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102f43:	89 55 88             	mov    %edx,-0x78(%ebp)
  102f46:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  102f49:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102f4c:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102f4f:	89 10                	mov    %edx,(%eax)
  102f51:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102f54:	8b 10                	mov    (%eax),%edx
  102f56:	8b 45 88             	mov    -0x78(%ebp),%eax
  102f59:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102f5c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f5f:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102f62:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102f65:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f68:	8b 55 88             	mov    -0x78(%ebp),%edx
  102f6b:	89 10                	mov    %edx,(%eax)
}
  102f6d:	90                   	nop
}
  102f6e:	90                   	nop
}
  102f6f:	90                   	nop
}
  102f70:	90                   	nop
  102f71:	89 ec                	mov    %ebp,%esp
  102f73:	5d                   	pop    %ebp
  102f74:	c3                   	ret    

00102f75 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102f75:	55                   	push   %ebp
  102f76:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102f78:	a1 88 be 11 00       	mov    0x11be88,%eax
}
  102f7d:	5d                   	pop    %ebp
  102f7e:	c3                   	ret    

00102f7f <basic_check>:

static void
basic_check(void) {
  102f7f:	55                   	push   %ebp
  102f80:	89 e5                	mov    %esp,%ebp
  102f82:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f95:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f9f:	e8 df 0e 00 00       	call   103e83 <alloc_pages>
  102fa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102fa7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102fab:	75 24                	jne    102fd1 <basic_check+0x52>
  102fad:	c7 44 24 0c 59 66 10 	movl   $0x106659,0xc(%esp)
  102fb4:	00 
  102fb5:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102fbc:	00 
  102fbd:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  102fc4:	00 
  102fc5:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  102fcc:	e8 0a dd ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  102fd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102fd8:	e8 a6 0e 00 00       	call   103e83 <alloc_pages>
  102fdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fe0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102fe4:	75 24                	jne    10300a <basic_check+0x8b>
  102fe6:	c7 44 24 0c 75 66 10 	movl   $0x106675,0xc(%esp)
  102fed:	00 
  102fee:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  102ff5:	00 
  102ff6:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  102ffd:	00 
  102ffe:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103005:	e8 d1 dc ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  10300a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103011:	e8 6d 0e 00 00       	call   103e83 <alloc_pages>
  103016:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103019:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10301d:	75 24                	jne    103043 <basic_check+0xc4>
  10301f:	c7 44 24 0c 91 66 10 	movl   $0x106691,0xc(%esp)
  103026:	00 
  103027:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10302e:	00 
  10302f:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  103036:	00 
  103037:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10303e:	e8 98 dc ff ff       	call   100cdb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  103043:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103046:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103049:	74 10                	je     10305b <basic_check+0xdc>
  10304b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10304e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103051:	74 08                	je     10305b <basic_check+0xdc>
  103053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103056:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103059:	75 24                	jne    10307f <basic_check+0x100>
  10305b:	c7 44 24 0c b0 66 10 	movl   $0x1066b0,0xc(%esp)
  103062:	00 
  103063:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10306a:	00 
  10306b:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  103072:	00 
  103073:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10307a:	e8 5c dc ff ff       	call   100cdb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10307f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103082:	89 04 24             	mov    %eax,(%esp)
  103085:	e8 0c f9 ff ff       	call   102996 <page_ref>
  10308a:	85 c0                	test   %eax,%eax
  10308c:	75 1e                	jne    1030ac <basic_check+0x12d>
  10308e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103091:	89 04 24             	mov    %eax,(%esp)
  103094:	e8 fd f8 ff ff       	call   102996 <page_ref>
  103099:	85 c0                	test   %eax,%eax
  10309b:	75 0f                	jne    1030ac <basic_check+0x12d>
  10309d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030a0:	89 04 24             	mov    %eax,(%esp)
  1030a3:	e8 ee f8 ff ff       	call   102996 <page_ref>
  1030a8:	85 c0                	test   %eax,%eax
  1030aa:	74 24                	je     1030d0 <basic_check+0x151>
  1030ac:	c7 44 24 0c d4 66 10 	movl   $0x1066d4,0xc(%esp)
  1030b3:	00 
  1030b4:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1030bb:	00 
  1030bc:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  1030c3:	00 
  1030c4:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1030cb:	e8 0b dc ff ff       	call   100cdb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1030d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030d3:	89 04 24             	mov    %eax,(%esp)
  1030d6:	e8 a3 f8 ff ff       	call   10297e <page2pa>
  1030db:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  1030e1:	c1 e2 0c             	shl    $0xc,%edx
  1030e4:	39 d0                	cmp    %edx,%eax
  1030e6:	72 24                	jb     10310c <basic_check+0x18d>
  1030e8:	c7 44 24 0c 10 67 10 	movl   $0x106710,0xc(%esp)
  1030ef:	00 
  1030f0:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1030f7:	00 
  1030f8:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  1030ff:	00 
  103100:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103107:	e8 cf db ff ff       	call   100cdb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10310c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10310f:	89 04 24             	mov    %eax,(%esp)
  103112:	e8 67 f8 ff ff       	call   10297e <page2pa>
  103117:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  10311d:	c1 e2 0c             	shl    $0xc,%edx
  103120:	39 d0                	cmp    %edx,%eax
  103122:	72 24                	jb     103148 <basic_check+0x1c9>
  103124:	c7 44 24 0c 2d 67 10 	movl   $0x10672d,0xc(%esp)
  10312b:	00 
  10312c:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103133:	00 
  103134:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  10313b:	00 
  10313c:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103143:	e8 93 db ff ff       	call   100cdb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10314b:	89 04 24             	mov    %eax,(%esp)
  10314e:	e8 2b f8 ff ff       	call   10297e <page2pa>
  103153:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  103159:	c1 e2 0c             	shl    $0xc,%edx
  10315c:	39 d0                	cmp    %edx,%eax
  10315e:	72 24                	jb     103184 <basic_check+0x205>
  103160:	c7 44 24 0c 4a 67 10 	movl   $0x10674a,0xc(%esp)
  103167:	00 
  103168:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10316f:	00 
  103170:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  103177:	00 
  103178:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10317f:	e8 57 db ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  103184:	a1 80 be 11 00       	mov    0x11be80,%eax
  103189:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  10318f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103192:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103195:	c7 45 dc 80 be 11 00 	movl   $0x11be80,-0x24(%ebp)
    elm->prev = elm->next = elm;
  10319c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10319f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031a2:	89 50 04             	mov    %edx,0x4(%eax)
  1031a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1031a8:	8b 50 04             	mov    0x4(%eax),%edx
  1031ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1031ae:	89 10                	mov    %edx,(%eax)
}
  1031b0:	90                   	nop
  1031b1:	c7 45 e0 80 be 11 00 	movl   $0x11be80,-0x20(%ebp)
    return list->next == list;
  1031b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1031bb:	8b 40 04             	mov    0x4(%eax),%eax
  1031be:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1031c1:	0f 94 c0             	sete   %al
  1031c4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1031c7:	85 c0                	test   %eax,%eax
  1031c9:	75 24                	jne    1031ef <basic_check+0x270>
  1031cb:	c7 44 24 0c 67 67 10 	movl   $0x106767,0xc(%esp)
  1031d2:	00 
  1031d3:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1031da:	00 
  1031db:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  1031e2:	00 
  1031e3:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1031ea:	e8 ec da ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  1031ef:	a1 88 be 11 00       	mov    0x11be88,%eax
  1031f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1031f7:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  1031fe:	00 00 00 

    assert(alloc_page() == NULL);
  103201:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103208:	e8 76 0c 00 00       	call   103e83 <alloc_pages>
  10320d:	85 c0                	test   %eax,%eax
  10320f:	74 24                	je     103235 <basic_check+0x2b6>
  103211:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  103218:	00 
  103219:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103220:	00 
  103221:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103228:	00 
  103229:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103230:	e8 a6 da ff ff       	call   100cdb <__panic>

    free_page(p0);
  103235:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10323c:	00 
  10323d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103240:	89 04 24             	mov    %eax,(%esp)
  103243:	e8 75 0c 00 00       	call   103ebd <free_pages>
    free_page(p1);
  103248:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10324f:	00 
  103250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103253:	89 04 24             	mov    %eax,(%esp)
  103256:	e8 62 0c 00 00       	call   103ebd <free_pages>
    free_page(p2);
  10325b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103262:	00 
  103263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103266:	89 04 24             	mov    %eax,(%esp)
  103269:	e8 4f 0c 00 00       	call   103ebd <free_pages>
    assert(nr_free == 3);
  10326e:	a1 88 be 11 00       	mov    0x11be88,%eax
  103273:	83 f8 03             	cmp    $0x3,%eax
  103276:	74 24                	je     10329c <basic_check+0x31d>
  103278:	c7 44 24 0c 93 67 10 	movl   $0x106793,0xc(%esp)
  10327f:	00 
  103280:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103287:	00 
  103288:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  10328f:	00 
  103290:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103297:	e8 3f da ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) != NULL);
  10329c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032a3:	e8 db 0b 00 00       	call   103e83 <alloc_pages>
  1032a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1032ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1032af:	75 24                	jne    1032d5 <basic_check+0x356>
  1032b1:	c7 44 24 0c 59 66 10 	movl   $0x106659,0xc(%esp)
  1032b8:	00 
  1032b9:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1032c0:	00 
  1032c1:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  1032c8:	00 
  1032c9:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1032d0:	e8 06 da ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  1032d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032dc:	e8 a2 0b 00 00       	call   103e83 <alloc_pages>
  1032e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1032e8:	75 24                	jne    10330e <basic_check+0x38f>
  1032ea:	c7 44 24 0c 75 66 10 	movl   $0x106675,0xc(%esp)
  1032f1:	00 
  1032f2:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1032f9:	00 
  1032fa:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  103301:	00 
  103302:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103309:	e8 cd d9 ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  10330e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103315:	e8 69 0b 00 00       	call   103e83 <alloc_pages>
  10331a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10331d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103321:	75 24                	jne    103347 <basic_check+0x3c8>
  103323:	c7 44 24 0c 91 66 10 	movl   $0x106691,0xc(%esp)
  10332a:	00 
  10332b:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103332:	00 
  103333:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  10333a:	00 
  10333b:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103342:	e8 94 d9 ff ff       	call   100cdb <__panic>

    assert(alloc_page() == NULL);
  103347:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10334e:	e8 30 0b 00 00       	call   103e83 <alloc_pages>
  103353:	85 c0                	test   %eax,%eax
  103355:	74 24                	je     10337b <basic_check+0x3fc>
  103357:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  10335e:	00 
  10335f:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103366:	00 
  103367:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10336e:	00 
  10336f:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103376:	e8 60 d9 ff ff       	call   100cdb <__panic>

    free_page(p0);
  10337b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103382:	00 
  103383:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103386:	89 04 24             	mov    %eax,(%esp)
  103389:	e8 2f 0b 00 00       	call   103ebd <free_pages>
  10338e:	c7 45 d8 80 be 11 00 	movl   $0x11be80,-0x28(%ebp)
  103395:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103398:	8b 40 04             	mov    0x4(%eax),%eax
  10339b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10339e:	0f 94 c0             	sete   %al
  1033a1:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1033a4:	85 c0                	test   %eax,%eax
  1033a6:	74 24                	je     1033cc <basic_check+0x44d>
  1033a8:	c7 44 24 0c a0 67 10 	movl   $0x1067a0,0xc(%esp)
  1033af:	00 
  1033b0:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1033b7:	00 
  1033b8:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  1033bf:	00 
  1033c0:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1033c7:	e8 0f d9 ff ff       	call   100cdb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1033cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033d3:	e8 ab 0a 00 00       	call   103e83 <alloc_pages>
  1033d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1033db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1033de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1033e1:	74 24                	je     103407 <basic_check+0x488>
  1033e3:	c7 44 24 0c b8 67 10 	movl   $0x1067b8,0xc(%esp)
  1033ea:	00 
  1033eb:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1033f2:	00 
  1033f3:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  1033fa:	00 
  1033fb:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103402:	e8 d4 d8 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103407:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10340e:	e8 70 0a 00 00       	call   103e83 <alloc_pages>
  103413:	85 c0                	test   %eax,%eax
  103415:	74 24                	je     10343b <basic_check+0x4bc>
  103417:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  10341e:	00 
  10341f:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103426:	00 
  103427:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  10342e:	00 
  10342f:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103436:	e8 a0 d8 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  10343b:	a1 88 be 11 00       	mov    0x11be88,%eax
  103440:	85 c0                	test   %eax,%eax
  103442:	74 24                	je     103468 <basic_check+0x4e9>
  103444:	c7 44 24 0c d1 67 10 	movl   $0x1067d1,0xc(%esp)
  10344b:	00 
  10344c:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103453:	00 
  103454:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10345b:	00 
  10345c:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103463:	e8 73 d8 ff ff       	call   100cdb <__panic>
    free_list = free_list_store;
  103468:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10346b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10346e:	a3 80 be 11 00       	mov    %eax,0x11be80
  103473:	89 15 84 be 11 00    	mov    %edx,0x11be84
    nr_free = nr_free_store;
  103479:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10347c:	a3 88 be 11 00       	mov    %eax,0x11be88

    free_page(p);
  103481:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103488:	00 
  103489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10348c:	89 04 24             	mov    %eax,(%esp)
  10348f:	e8 29 0a 00 00       	call   103ebd <free_pages>
    free_page(p1);
  103494:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10349b:	00 
  10349c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10349f:	89 04 24             	mov    %eax,(%esp)
  1034a2:	e8 16 0a 00 00       	call   103ebd <free_pages>
    free_page(p2);
  1034a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1034ae:	00 
  1034af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034b2:	89 04 24             	mov    %eax,(%esp)
  1034b5:	e8 03 0a 00 00       	call   103ebd <free_pages>
}
  1034ba:	90                   	nop
  1034bb:	89 ec                	mov    %ebp,%esp
  1034bd:	5d                   	pop    %ebp
  1034be:	c3                   	ret    

001034bf <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1034bf:	55                   	push   %ebp
  1034c0:	89 e5                	mov    %esp,%ebp
  1034c2:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  1034c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1034cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1034d6:	c7 45 ec 80 be 11 00 	movl   $0x11be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1034dd:	eb 6a                	jmp    103549 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  1034df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034e2:	83 e8 0c             	sub    $0xc,%eax
  1034e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  1034e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1034eb:	83 c0 04             	add    $0x4,%eax
  1034ee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1034f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1034fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1034fe:	0f a3 10             	bt     %edx,(%eax)
  103501:	19 c0                	sbb    %eax,%eax
  103503:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103506:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10350a:	0f 95 c0             	setne  %al
  10350d:	0f b6 c0             	movzbl %al,%eax
  103510:	85 c0                	test   %eax,%eax
  103512:	75 24                	jne    103538 <default_check+0x79>
  103514:	c7 44 24 0c de 67 10 	movl   $0x1067de,0xc(%esp)
  10351b:	00 
  10351c:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103523:	00 
  103524:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  10352b:	00 
  10352c:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103533:	e8 a3 d7 ff ff       	call   100cdb <__panic>
        count ++, total += p->property;
  103538:	ff 45 f4             	incl   -0xc(%ebp)
  10353b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10353e:	8b 50 08             	mov    0x8(%eax),%edx
  103541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103544:	01 d0                	add    %edx,%eax
  103546:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103549:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10354c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  10354f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103552:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103555:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103558:	81 7d ec 80 be 11 00 	cmpl   $0x11be80,-0x14(%ebp)
  10355f:	0f 85 7a ff ff ff    	jne    1034df <default_check+0x20>
    }
    assert(total == nr_free_pages());
  103565:	e8 88 09 00 00       	call   103ef2 <nr_free_pages>
  10356a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10356d:	39 d0                	cmp    %edx,%eax
  10356f:	74 24                	je     103595 <default_check+0xd6>
  103571:	c7 44 24 0c ee 67 10 	movl   $0x1067ee,0xc(%esp)
  103578:	00 
  103579:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103580:	00 
  103581:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  103588:	00 
  103589:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103590:	e8 46 d7 ff ff       	call   100cdb <__panic>

    basic_check();
  103595:	e8 e5 f9 ff ff       	call   102f7f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10359a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1035a1:	e8 dd 08 00 00       	call   103e83 <alloc_pages>
  1035a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  1035a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1035ad:	75 24                	jne    1035d3 <default_check+0x114>
  1035af:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  1035b6:	00 
  1035b7:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1035be:	00 
  1035bf:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  1035c6:	00 
  1035c7:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1035ce:	e8 08 d7 ff ff       	call   100cdb <__panic>
    assert(!PageProperty(p0));
  1035d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1035d6:	83 c0 04             	add    $0x4,%eax
  1035d9:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1035e0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1035e3:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1035e6:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1035e9:	0f a3 10             	bt     %edx,(%eax)
  1035ec:	19 c0                	sbb    %eax,%eax
  1035ee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1035f1:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1035f5:	0f 95 c0             	setne  %al
  1035f8:	0f b6 c0             	movzbl %al,%eax
  1035fb:	85 c0                	test   %eax,%eax
  1035fd:	74 24                	je     103623 <default_check+0x164>
  1035ff:	c7 44 24 0c 12 68 10 	movl   $0x106812,0xc(%esp)
  103606:	00 
  103607:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10360e:	00 
  10360f:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  103616:	00 
  103617:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10361e:	e8 b8 d6 ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  103623:	a1 80 be 11 00       	mov    0x11be80,%eax
  103628:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  10362e:	89 45 80             	mov    %eax,-0x80(%ebp)
  103631:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103634:	c7 45 b0 80 be 11 00 	movl   $0x11be80,-0x50(%ebp)
    elm->prev = elm->next = elm;
  10363b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10363e:	8b 55 b0             	mov    -0x50(%ebp),%edx
  103641:	89 50 04             	mov    %edx,0x4(%eax)
  103644:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103647:	8b 50 04             	mov    0x4(%eax),%edx
  10364a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10364d:	89 10                	mov    %edx,(%eax)
}
  10364f:	90                   	nop
  103650:	c7 45 b4 80 be 11 00 	movl   $0x11be80,-0x4c(%ebp)
    return list->next == list;
  103657:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10365a:	8b 40 04             	mov    0x4(%eax),%eax
  10365d:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  103660:	0f 94 c0             	sete   %al
  103663:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103666:	85 c0                	test   %eax,%eax
  103668:	75 24                	jne    10368e <default_check+0x1cf>
  10366a:	c7 44 24 0c 67 67 10 	movl   $0x106767,0xc(%esp)
  103671:	00 
  103672:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103679:	00 
  10367a:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  103681:	00 
  103682:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103689:	e8 4d d6 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  10368e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103695:	e8 e9 07 00 00       	call   103e83 <alloc_pages>
  10369a:	85 c0                	test   %eax,%eax
  10369c:	74 24                	je     1036c2 <default_check+0x203>
  10369e:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  1036a5:	00 
  1036a6:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1036ad:	00 
  1036ae:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  1036b5:	00 
  1036b6:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1036bd:	e8 19 d6 ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  1036c2:	a1 88 be 11 00       	mov    0x11be88,%eax
  1036c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  1036ca:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  1036d1:	00 00 00 

    free_pages(p0 + 2, 3);
  1036d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1036d7:	83 c0 28             	add    $0x28,%eax
  1036da:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1036e1:	00 
  1036e2:	89 04 24             	mov    %eax,(%esp)
  1036e5:	e8 d3 07 00 00       	call   103ebd <free_pages>
    assert(alloc_pages(4) == NULL);
  1036ea:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1036f1:	e8 8d 07 00 00       	call   103e83 <alloc_pages>
  1036f6:	85 c0                	test   %eax,%eax
  1036f8:	74 24                	je     10371e <default_check+0x25f>
  1036fa:	c7 44 24 0c 24 68 10 	movl   $0x106824,0xc(%esp)
  103701:	00 
  103702:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103709:	00 
  10370a:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  103711:	00 
  103712:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103719:	e8 bd d5 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10371e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103721:	83 c0 28             	add    $0x28,%eax
  103724:	83 c0 04             	add    $0x4,%eax
  103727:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10372e:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103731:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103734:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103737:	0f a3 10             	bt     %edx,(%eax)
  10373a:	19 c0                	sbb    %eax,%eax
  10373c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10373f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103743:	0f 95 c0             	setne  %al
  103746:	0f b6 c0             	movzbl %al,%eax
  103749:	85 c0                	test   %eax,%eax
  10374b:	74 0e                	je     10375b <default_check+0x29c>
  10374d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103750:	83 c0 28             	add    $0x28,%eax
  103753:	8b 40 08             	mov    0x8(%eax),%eax
  103756:	83 f8 03             	cmp    $0x3,%eax
  103759:	74 24                	je     10377f <default_check+0x2c0>
  10375b:	c7 44 24 0c 3c 68 10 	movl   $0x10683c,0xc(%esp)
  103762:	00 
  103763:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10376a:	00 
  10376b:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103772:	00 
  103773:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10377a:	e8 5c d5 ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10377f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103786:	e8 f8 06 00 00       	call   103e83 <alloc_pages>
  10378b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10378e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103792:	75 24                	jne    1037b8 <default_check+0x2f9>
  103794:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  10379b:	00 
  10379c:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1037a3:	00 
  1037a4:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1037ab:	00 
  1037ac:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1037b3:	e8 23 d5 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  1037b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037bf:	e8 bf 06 00 00       	call   103e83 <alloc_pages>
  1037c4:	85 c0                	test   %eax,%eax
  1037c6:	74 24                	je     1037ec <default_check+0x32d>
  1037c8:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  1037cf:	00 
  1037d0:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1037d7:	00 
  1037d8:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1037df:	00 
  1037e0:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1037e7:	e8 ef d4 ff ff       	call   100cdb <__panic>
    assert(p0 + 2 == p1);
  1037ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037ef:	83 c0 28             	add    $0x28,%eax
  1037f2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1037f5:	74 24                	je     10381b <default_check+0x35c>
  1037f7:	c7 44 24 0c 86 68 10 	movl   $0x106886,0xc(%esp)
  1037fe:	00 
  1037ff:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103806:	00 
  103807:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  10380e:	00 
  10380f:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103816:	e8 c0 d4 ff ff       	call   100cdb <__panic>

    p2 = p0 + 1;
  10381b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10381e:	83 c0 14             	add    $0x14,%eax
  103821:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  103824:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10382b:	00 
  10382c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10382f:	89 04 24             	mov    %eax,(%esp)
  103832:	e8 86 06 00 00       	call   103ebd <free_pages>
    free_pages(p1, 3);
  103837:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10383e:	00 
  10383f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103842:	89 04 24             	mov    %eax,(%esp)
  103845:	e8 73 06 00 00       	call   103ebd <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10384a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10384d:	83 c0 04             	add    $0x4,%eax
  103850:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103857:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10385a:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10385d:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103860:	0f a3 10             	bt     %edx,(%eax)
  103863:	19 c0                	sbb    %eax,%eax
  103865:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103868:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10386c:	0f 95 c0             	setne  %al
  10386f:	0f b6 c0             	movzbl %al,%eax
  103872:	85 c0                	test   %eax,%eax
  103874:	74 0b                	je     103881 <default_check+0x3c2>
  103876:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103879:	8b 40 08             	mov    0x8(%eax),%eax
  10387c:	83 f8 01             	cmp    $0x1,%eax
  10387f:	74 24                	je     1038a5 <default_check+0x3e6>
  103881:	c7 44 24 0c 94 68 10 	movl   $0x106894,0xc(%esp)
  103888:	00 
  103889:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103890:	00 
  103891:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  103898:	00 
  103899:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1038a0:	e8 36 d4 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1038a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1038a8:	83 c0 04             	add    $0x4,%eax
  1038ab:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1038b2:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1038b5:	8b 45 90             	mov    -0x70(%ebp),%eax
  1038b8:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1038bb:	0f a3 10             	bt     %edx,(%eax)
  1038be:	19 c0                	sbb    %eax,%eax
  1038c0:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1038c3:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1038c7:	0f 95 c0             	setne  %al
  1038ca:	0f b6 c0             	movzbl %al,%eax
  1038cd:	85 c0                	test   %eax,%eax
  1038cf:	74 0b                	je     1038dc <default_check+0x41d>
  1038d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1038d4:	8b 40 08             	mov    0x8(%eax),%eax
  1038d7:	83 f8 03             	cmp    $0x3,%eax
  1038da:	74 24                	je     103900 <default_check+0x441>
  1038dc:	c7 44 24 0c bc 68 10 	movl   $0x1068bc,0xc(%esp)
  1038e3:	00 
  1038e4:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1038eb:	00 
  1038ec:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1038f3:	00 
  1038f4:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1038fb:	e8 db d3 ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103900:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103907:	e8 77 05 00 00       	call   103e83 <alloc_pages>
  10390c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10390f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103912:	83 e8 14             	sub    $0x14,%eax
  103915:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103918:	74 24                	je     10393e <default_check+0x47f>
  10391a:	c7 44 24 0c e2 68 10 	movl   $0x1068e2,0xc(%esp)
  103921:	00 
  103922:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103929:	00 
  10392a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  103931:	00 
  103932:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103939:	e8 9d d3 ff ff       	call   100cdb <__panic>
    free_page(p0);
  10393e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103945:	00 
  103946:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103949:	89 04 24             	mov    %eax,(%esp)
  10394c:	e8 6c 05 00 00       	call   103ebd <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103951:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103958:	e8 26 05 00 00       	call   103e83 <alloc_pages>
  10395d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103960:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103963:	83 c0 14             	add    $0x14,%eax
  103966:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103969:	74 24                	je     10398f <default_check+0x4d0>
  10396b:	c7 44 24 0c 00 69 10 	movl   $0x106900,0xc(%esp)
  103972:	00 
  103973:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  10397a:	00 
  10397b:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  103982:	00 
  103983:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  10398a:	e8 4c d3 ff ff       	call   100cdb <__panic>

    free_pages(p0, 2);
  10398f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103996:	00 
  103997:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10399a:	89 04 24             	mov    %eax,(%esp)
  10399d:	e8 1b 05 00 00       	call   103ebd <free_pages>
    free_page(p2);
  1039a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1039a9:	00 
  1039aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1039ad:	89 04 24             	mov    %eax,(%esp)
  1039b0:	e8 08 05 00 00       	call   103ebd <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1039b5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1039bc:	e8 c2 04 00 00       	call   103e83 <alloc_pages>
  1039c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1039c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1039c8:	75 24                	jne    1039ee <default_check+0x52f>
  1039ca:	c7 44 24 0c 20 69 10 	movl   $0x106920,0xc(%esp)
  1039d1:	00 
  1039d2:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  1039d9:	00 
  1039da:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1039e1:	00 
  1039e2:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  1039e9:	e8 ed d2 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  1039ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039f5:	e8 89 04 00 00       	call   103e83 <alloc_pages>
  1039fa:	85 c0                	test   %eax,%eax
  1039fc:	74 24                	je     103a22 <default_check+0x563>
  1039fe:	c7 44 24 0c 7e 67 10 	movl   $0x10677e,0xc(%esp)
  103a05:	00 
  103a06:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103a0d:	00 
  103a0e:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  103a15:	00 
  103a16:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103a1d:	e8 b9 d2 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  103a22:	a1 88 be 11 00       	mov    0x11be88,%eax
  103a27:	85 c0                	test   %eax,%eax
  103a29:	74 24                	je     103a4f <default_check+0x590>
  103a2b:	c7 44 24 0c d1 67 10 	movl   $0x1067d1,0xc(%esp)
  103a32:	00 
  103a33:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103a3a:	00 
  103a3b:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  103a42:	00 
  103a43:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103a4a:	e8 8c d2 ff ff       	call   100cdb <__panic>
    nr_free = nr_free_store;
  103a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a52:	a3 88 be 11 00       	mov    %eax,0x11be88

    free_list = free_list_store;
  103a57:	8b 45 80             	mov    -0x80(%ebp),%eax
  103a5a:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103a5d:	a3 80 be 11 00       	mov    %eax,0x11be80
  103a62:	89 15 84 be 11 00    	mov    %edx,0x11be84
    free_pages(p0, 5);
  103a68:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103a6f:	00 
  103a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a73:	89 04 24             	mov    %eax,(%esp)
  103a76:	e8 42 04 00 00       	call   103ebd <free_pages>

    le = &free_list;
  103a7b:	c7 45 ec 80 be 11 00 	movl   $0x11be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103a82:	eb 5a                	jmp    103ade <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
  103a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a87:	8b 40 04             	mov    0x4(%eax),%eax
  103a8a:	8b 00                	mov    (%eax),%eax
  103a8c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103a8f:	75 0d                	jne    103a9e <default_check+0x5df>
  103a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a94:	8b 00                	mov    (%eax),%eax
  103a96:	8b 40 04             	mov    0x4(%eax),%eax
  103a99:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103a9c:	74 24                	je     103ac2 <default_check+0x603>
  103a9e:	c7 44 24 0c 40 69 10 	movl   $0x106940,0xc(%esp)
  103aa5:	00 
  103aa6:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103aad:	00 
  103aae:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  103ab5:	00 
  103ab6:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103abd:	e8 19 d2 ff ff       	call   100cdb <__panic>
        struct Page *p = le2page(le, page_link);
  103ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ac5:	83 e8 0c             	sub    $0xc,%eax
  103ac8:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103acb:	ff 4d f4             	decl   -0xc(%ebp)
  103ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103ad1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103ad4:	8b 48 08             	mov    0x8(%eax),%ecx
  103ad7:	89 d0                	mov    %edx,%eax
  103ad9:	29 c8                	sub    %ecx,%eax
  103adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ae1:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103ae4:	8b 45 88             	mov    -0x78(%ebp),%eax
  103ae7:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103aed:	81 7d ec 80 be 11 00 	cmpl   $0x11be80,-0x14(%ebp)
  103af4:	75 8e                	jne    103a84 <default_check+0x5c5>
    }
    assert(count == 0);
  103af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103afa:	74 24                	je     103b20 <default_check+0x661>
  103afc:	c7 44 24 0c 6d 69 10 	movl   $0x10696d,0xc(%esp)
  103b03:	00 
  103b04:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103b0b:	00 
  103b0c:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  103b13:	00 
  103b14:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103b1b:	e8 bb d1 ff ff       	call   100cdb <__panic>
    assert(total == 0);
  103b20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103b24:	74 24                	je     103b4a <default_check+0x68b>
  103b26:	c7 44 24 0c 78 69 10 	movl   $0x106978,0xc(%esp)
  103b2d:	00 
  103b2e:	c7 44 24 08 f6 65 10 	movl   $0x1065f6,0x8(%esp)
  103b35:	00 
  103b36:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103b3d:	00 
  103b3e:	c7 04 24 0b 66 10 00 	movl   $0x10660b,(%esp)
  103b45:	e8 91 d1 ff ff       	call   100cdb <__panic>
}
  103b4a:	90                   	nop
  103b4b:	89 ec                	mov    %ebp,%esp
  103b4d:	5d                   	pop    %ebp
  103b4e:	c3                   	ret    

00103b4f <page2ppn>:
page2ppn(struct Page *page) {
  103b4f:	55                   	push   %ebp
  103b50:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103b52:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  103b58:	8b 45 08             	mov    0x8(%ebp),%eax
  103b5b:	29 d0                	sub    %edx,%eax
  103b5d:	c1 f8 02             	sar    $0x2,%eax
  103b60:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103b66:	5d                   	pop    %ebp
  103b67:	c3                   	ret    

00103b68 <page2pa>:
page2pa(struct Page *page) {
  103b68:	55                   	push   %ebp
  103b69:	89 e5                	mov    %esp,%ebp
  103b6b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  103b71:	89 04 24             	mov    %eax,(%esp)
  103b74:	e8 d6 ff ff ff       	call   103b4f <page2ppn>
  103b79:	c1 e0 0c             	shl    $0xc,%eax
}
  103b7c:	89 ec                	mov    %ebp,%esp
  103b7e:	5d                   	pop    %ebp
  103b7f:	c3                   	ret    

00103b80 <pa2page>:
pa2page(uintptr_t pa) {
  103b80:	55                   	push   %ebp
  103b81:	89 e5                	mov    %esp,%ebp
  103b83:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103b86:	8b 45 08             	mov    0x8(%ebp),%eax
  103b89:	c1 e8 0c             	shr    $0xc,%eax
  103b8c:	89 c2                	mov    %eax,%edx
  103b8e:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  103b93:	39 c2                	cmp    %eax,%edx
  103b95:	72 1c                	jb     103bb3 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103b97:	c7 44 24 08 b4 69 10 	movl   $0x1069b4,0x8(%esp)
  103b9e:	00 
  103b9f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103ba6:	00 
  103ba7:	c7 04 24 d3 69 10 00 	movl   $0x1069d3,(%esp)
  103bae:	e8 28 d1 ff ff       	call   100cdb <__panic>
    return &pages[PPN(pa)];
  103bb3:	8b 0d a0 be 11 00    	mov    0x11bea0,%ecx
  103bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  103bbc:	c1 e8 0c             	shr    $0xc,%eax
  103bbf:	89 c2                	mov    %eax,%edx
  103bc1:	89 d0                	mov    %edx,%eax
  103bc3:	c1 e0 02             	shl    $0x2,%eax
  103bc6:	01 d0                	add    %edx,%eax
  103bc8:	c1 e0 02             	shl    $0x2,%eax
  103bcb:	01 c8                	add    %ecx,%eax
}
  103bcd:	89 ec                	mov    %ebp,%esp
  103bcf:	5d                   	pop    %ebp
  103bd0:	c3                   	ret    

00103bd1 <page2kva>:
page2kva(struct Page *page) {
  103bd1:	55                   	push   %ebp
  103bd2:	89 e5                	mov    %esp,%ebp
  103bd4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  103bda:	89 04 24             	mov    %eax,(%esp)
  103bdd:	e8 86 ff ff ff       	call   103b68 <page2pa>
  103be2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103be8:	c1 e8 0c             	shr    $0xc,%eax
  103beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103bee:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  103bf3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103bf6:	72 23                	jb     103c1b <page2kva+0x4a>
  103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103bff:	c7 44 24 08 e4 69 10 	movl   $0x1069e4,0x8(%esp)
  103c06:	00 
  103c07:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103c0e:	00 
  103c0f:	c7 04 24 d3 69 10 00 	movl   $0x1069d3,(%esp)
  103c16:	e8 c0 d0 ff ff       	call   100cdb <__panic>
  103c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c1e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103c23:	89 ec                	mov    %ebp,%esp
  103c25:	5d                   	pop    %ebp
  103c26:	c3                   	ret    

00103c27 <pte2page>:
pte2page(pte_t pte) {
  103c27:	55                   	push   %ebp
  103c28:	89 e5                	mov    %esp,%ebp
  103c2a:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c30:	83 e0 01             	and    $0x1,%eax
  103c33:	85 c0                	test   %eax,%eax
  103c35:	75 1c                	jne    103c53 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103c37:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  103c3e:	00 
  103c3f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103c46:	00 
  103c47:	c7 04 24 d3 69 10 00 	movl   $0x1069d3,(%esp)
  103c4e:	e8 88 d0 ff ff       	call   100cdb <__panic>
    return pa2page(PTE_ADDR(pte));
  103c53:	8b 45 08             	mov    0x8(%ebp),%eax
  103c56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c5b:	89 04 24             	mov    %eax,(%esp)
  103c5e:	e8 1d ff ff ff       	call   103b80 <pa2page>
}
  103c63:	89 ec                	mov    %ebp,%esp
  103c65:	5d                   	pop    %ebp
  103c66:	c3                   	ret    

00103c67 <pde2page>:
pde2page(pde_t pde) {
  103c67:	55                   	push   %ebp
  103c68:	89 e5                	mov    %esp,%ebp
  103c6a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c75:	89 04 24             	mov    %eax,(%esp)
  103c78:	e8 03 ff ff ff       	call   103b80 <pa2page>
}
  103c7d:	89 ec                	mov    %ebp,%esp
  103c7f:	5d                   	pop    %ebp
  103c80:	c3                   	ret    

00103c81 <page_ref>:
page_ref(struct Page *page) {
  103c81:	55                   	push   %ebp
  103c82:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103c84:	8b 45 08             	mov    0x8(%ebp),%eax
  103c87:	8b 00                	mov    (%eax),%eax
}
  103c89:	5d                   	pop    %ebp
  103c8a:	c3                   	ret    

00103c8b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103c8b:	55                   	push   %ebp
  103c8c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  103c91:	8b 00                	mov    (%eax),%eax
  103c93:	8d 50 01             	lea    0x1(%eax),%edx
  103c96:	8b 45 08             	mov    0x8(%ebp),%eax
  103c99:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  103c9e:	8b 00                	mov    (%eax),%eax
}
  103ca0:	5d                   	pop    %ebp
  103ca1:	c3                   	ret    

00103ca2 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103ca2:	55                   	push   %ebp
  103ca3:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  103ca8:	8b 00                	mov    (%eax),%eax
  103caa:	8d 50 ff             	lea    -0x1(%eax),%edx
  103cad:	8b 45 08             	mov    0x8(%ebp),%eax
  103cb0:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  103cb5:	8b 00                	mov    (%eax),%eax
}
  103cb7:	5d                   	pop    %ebp
  103cb8:	c3                   	ret    

00103cb9 <__intr_save>:
__intr_save(void) {
  103cb9:	55                   	push   %ebp
  103cba:	89 e5                	mov    %esp,%ebp
  103cbc:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103cbf:	9c                   	pushf  
  103cc0:	58                   	pop    %eax
  103cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103cc7:	25 00 02 00 00       	and    $0x200,%eax
  103ccc:	85 c0                	test   %eax,%eax
  103cce:	74 0c                	je     103cdc <__intr_save+0x23>
        intr_disable();
  103cd0:	e8 5f da ff ff       	call   101734 <intr_disable>
        return 1;
  103cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  103cda:	eb 05                	jmp    103ce1 <__intr_save+0x28>
    return 0;
  103cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103ce1:	89 ec                	mov    %ebp,%esp
  103ce3:	5d                   	pop    %ebp
  103ce4:	c3                   	ret    

00103ce5 <__intr_restore>:
__intr_restore(bool flag) {
  103ce5:	55                   	push   %ebp
  103ce6:	89 e5                	mov    %esp,%ebp
  103ce8:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103ceb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103cef:	74 05                	je     103cf6 <__intr_restore+0x11>
        intr_enable();
  103cf1:	e8 36 da ff ff       	call   10172c <intr_enable>
}
  103cf6:	90                   	nop
  103cf7:	89 ec                	mov    %ebp,%esp
  103cf9:	5d                   	pop    %ebp
  103cfa:	c3                   	ret    

00103cfb <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103cfb:	55                   	push   %ebp
  103cfc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  103d01:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103d04:	b8 23 00 00 00       	mov    $0x23,%eax
  103d09:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103d0b:	b8 23 00 00 00       	mov    $0x23,%eax
  103d10:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103d12:	b8 10 00 00 00       	mov    $0x10,%eax
  103d17:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103d19:	b8 10 00 00 00       	mov    $0x10,%eax
  103d1e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103d20:	b8 10 00 00 00       	mov    $0x10,%eax
  103d25:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103d27:	ea 2e 3d 10 00 08 00 	ljmp   $0x8,$0x103d2e
}
  103d2e:	90                   	nop
  103d2f:	5d                   	pop    %ebp
  103d30:	c3                   	ret    

00103d31 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103d31:	55                   	push   %ebp
  103d32:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103d34:	8b 45 08             	mov    0x8(%ebp),%eax
  103d37:	a3 c4 be 11 00       	mov    %eax,0x11bec4
}
  103d3c:	90                   	nop
  103d3d:	5d                   	pop    %ebp
  103d3e:	c3                   	ret    

00103d3f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103d3f:	55                   	push   %ebp
  103d40:	89 e5                	mov    %esp,%ebp
  103d42:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103d45:	b8 00 80 11 00       	mov    $0x118000,%eax
  103d4a:	89 04 24             	mov    %eax,(%esp)
  103d4d:	e8 df ff ff ff       	call   103d31 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103d52:	66 c7 05 c8 be 11 00 	movw   $0x10,0x11bec8
  103d59:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103d5b:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  103d62:	68 00 
  103d64:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103d69:	0f b7 c0             	movzwl %ax,%eax
  103d6c:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  103d72:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103d77:	c1 e8 10             	shr    $0x10,%eax
  103d7a:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  103d7f:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103d86:	24 f0                	and    $0xf0,%al
  103d88:	0c 09                	or     $0x9,%al
  103d8a:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103d8f:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103d96:	24 ef                	and    $0xef,%al
  103d98:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103d9d:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103da4:	24 9f                	and    $0x9f,%al
  103da6:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103dab:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103db2:	0c 80                	or     $0x80,%al
  103db4:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103db9:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103dc0:	24 f0                	and    $0xf0,%al
  103dc2:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103dc7:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103dce:	24 ef                	and    $0xef,%al
  103dd0:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103dd5:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103ddc:	24 df                	and    $0xdf,%al
  103dde:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103de3:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103dea:	0c 40                	or     $0x40,%al
  103dec:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103df1:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103df8:	24 7f                	and    $0x7f,%al
  103dfa:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103dff:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103e04:	c1 e8 18             	shr    $0x18,%eax
  103e07:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103e0c:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
  103e13:	e8 e3 fe ff ff       	call   103cfb <lgdt>
  103e18:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103e1e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103e22:	0f 00 d8             	ltr    %ax
}
  103e25:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  103e26:	90                   	nop
  103e27:	89 ec                	mov    %ebp,%esp
  103e29:	5d                   	pop    %ebp
  103e2a:	c3                   	ret    

00103e2b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103e2b:	55                   	push   %ebp
  103e2c:	89 e5                	mov    %esp,%ebp
  103e2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103e31:	c7 05 ac be 11 00 98 	movl   $0x106998,0x11beac
  103e38:	69 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103e3b:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e40:	8b 00                	mov    (%eax),%eax
  103e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  103e46:	c7 04 24 34 6a 10 00 	movl   $0x106a34,(%esp)
  103e4d:	e8 04 c5 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  103e52:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e57:	8b 40 04             	mov    0x4(%eax),%eax
  103e5a:	ff d0                	call   *%eax
}
  103e5c:	90                   	nop
  103e5d:	89 ec                	mov    %ebp,%esp
  103e5f:	5d                   	pop    %ebp
  103e60:	c3                   	ret    

00103e61 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103e61:	55                   	push   %ebp
  103e62:	89 e5                	mov    %esp,%ebp
  103e64:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103e67:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e6c:	8b 40 08             	mov    0x8(%eax),%eax
  103e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e72:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e76:	8b 55 08             	mov    0x8(%ebp),%edx
  103e79:	89 14 24             	mov    %edx,(%esp)
  103e7c:	ff d0                	call   *%eax
}
  103e7e:	90                   	nop
  103e7f:	89 ec                	mov    %ebp,%esp
  103e81:	5d                   	pop    %ebp
  103e82:	c3                   	ret    

00103e83 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103e83:	55                   	push   %ebp
  103e84:	89 e5                	mov    %esp,%ebp
  103e86:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103e89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103e90:	e8 24 fe ff ff       	call   103cb9 <__intr_save>
  103e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103e98:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e9d:	8b 40 0c             	mov    0xc(%eax),%eax
  103ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  103ea3:	89 14 24             	mov    %edx,(%esp)
  103ea6:	ff d0                	call   *%eax
  103ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103eae:	89 04 24             	mov    %eax,(%esp)
  103eb1:	e8 2f fe ff ff       	call   103ce5 <__intr_restore>
    return page;
  103eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103eb9:	89 ec                	mov    %ebp,%esp
  103ebb:	5d                   	pop    %ebp
  103ebc:	c3                   	ret    

00103ebd <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103ebd:	55                   	push   %ebp
  103ebe:	89 e5                	mov    %esp,%ebp
  103ec0:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103ec3:	e8 f1 fd ff ff       	call   103cb9 <__intr_save>
  103ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103ecb:	a1 ac be 11 00       	mov    0x11beac,%eax
  103ed0:	8b 40 10             	mov    0x10(%eax),%eax
  103ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  103ed6:	89 54 24 04          	mov    %edx,0x4(%esp)
  103eda:	8b 55 08             	mov    0x8(%ebp),%edx
  103edd:	89 14 24             	mov    %edx,(%esp)
  103ee0:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ee5:	89 04 24             	mov    %eax,(%esp)
  103ee8:	e8 f8 fd ff ff       	call   103ce5 <__intr_restore>
}
  103eed:	90                   	nop
  103eee:	89 ec                	mov    %ebp,%esp
  103ef0:	5d                   	pop    %ebp
  103ef1:	c3                   	ret    

00103ef2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103ef2:	55                   	push   %ebp
  103ef3:	89 e5                	mov    %esp,%ebp
  103ef5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103ef8:	e8 bc fd ff ff       	call   103cb9 <__intr_save>
  103efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103f00:	a1 ac be 11 00       	mov    0x11beac,%eax
  103f05:	8b 40 14             	mov    0x14(%eax),%eax
  103f08:	ff d0                	call   *%eax
  103f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f10:	89 04 24             	mov    %eax,(%esp)
  103f13:	e8 cd fd ff ff       	call   103ce5 <__intr_restore>
    return ret;
  103f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103f1b:	89 ec                	mov    %ebp,%esp
  103f1d:	5d                   	pop    %ebp
  103f1e:	c3                   	ret    

00103f1f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103f1f:	55                   	push   %ebp
  103f20:	89 e5                	mov    %esp,%ebp
  103f22:	57                   	push   %edi
  103f23:	56                   	push   %esi
  103f24:	53                   	push   %ebx
  103f25:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103f2b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103f32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103f39:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103f40:	c7 04 24 4b 6a 10 00 	movl   $0x106a4b,(%esp)
  103f47:	e8 0a c4 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f4c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103f53:	e9 0c 01 00 00       	jmp    104064 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103f58:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f5e:	89 d0                	mov    %edx,%eax
  103f60:	c1 e0 02             	shl    $0x2,%eax
  103f63:	01 d0                	add    %edx,%eax
  103f65:	c1 e0 02             	shl    $0x2,%eax
  103f68:	01 c8                	add    %ecx,%eax
  103f6a:	8b 50 08             	mov    0x8(%eax),%edx
  103f6d:	8b 40 04             	mov    0x4(%eax),%eax
  103f70:	89 45 a0             	mov    %eax,-0x60(%ebp)
  103f73:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  103f76:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f79:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f7c:	89 d0                	mov    %edx,%eax
  103f7e:	c1 e0 02             	shl    $0x2,%eax
  103f81:	01 d0                	add    %edx,%eax
  103f83:	c1 e0 02             	shl    $0x2,%eax
  103f86:	01 c8                	add    %ecx,%eax
  103f88:	8b 48 0c             	mov    0xc(%eax),%ecx
  103f8b:	8b 58 10             	mov    0x10(%eax),%ebx
  103f8e:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103f91:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103f94:	01 c8                	add    %ecx,%eax
  103f96:	11 da                	adc    %ebx,%edx
  103f98:	89 45 98             	mov    %eax,-0x68(%ebp)
  103f9b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103f9e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fa1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fa4:	89 d0                	mov    %edx,%eax
  103fa6:	c1 e0 02             	shl    $0x2,%eax
  103fa9:	01 d0                	add    %edx,%eax
  103fab:	c1 e0 02             	shl    $0x2,%eax
  103fae:	01 c8                	add    %ecx,%eax
  103fb0:	83 c0 14             	add    $0x14,%eax
  103fb3:	8b 00                	mov    (%eax),%eax
  103fb5:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103fbb:	8b 45 98             	mov    -0x68(%ebp),%eax
  103fbe:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103fc1:	83 c0 ff             	add    $0xffffffff,%eax
  103fc4:	83 d2 ff             	adc    $0xffffffff,%edx
  103fc7:	89 c6                	mov    %eax,%esi
  103fc9:	89 d7                	mov    %edx,%edi
  103fcb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fd1:	89 d0                	mov    %edx,%eax
  103fd3:	c1 e0 02             	shl    $0x2,%eax
  103fd6:	01 d0                	add    %edx,%eax
  103fd8:	c1 e0 02             	shl    $0x2,%eax
  103fdb:	01 c8                	add    %ecx,%eax
  103fdd:	8b 48 0c             	mov    0xc(%eax),%ecx
  103fe0:	8b 58 10             	mov    0x10(%eax),%ebx
  103fe3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103fe9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103fed:	89 74 24 14          	mov    %esi,0x14(%esp)
  103ff1:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103ff5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103ff8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103fff:	89 54 24 10          	mov    %edx,0x10(%esp)
  104003:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104007:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  10400b:	c7 04 24 58 6a 10 00 	movl   $0x106a58,(%esp)
  104012:	e8 3f c3 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104017:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10401a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10401d:	89 d0                	mov    %edx,%eax
  10401f:	c1 e0 02             	shl    $0x2,%eax
  104022:	01 d0                	add    %edx,%eax
  104024:	c1 e0 02             	shl    $0x2,%eax
  104027:	01 c8                	add    %ecx,%eax
  104029:	83 c0 14             	add    $0x14,%eax
  10402c:	8b 00                	mov    (%eax),%eax
  10402e:	83 f8 01             	cmp    $0x1,%eax
  104031:	75 2e                	jne    104061 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  104033:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104039:	3b 45 98             	cmp    -0x68(%ebp),%eax
  10403c:	89 d0                	mov    %edx,%eax
  10403e:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  104041:	73 1e                	jae    104061 <page_init+0x142>
  104043:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  104048:	b8 00 00 00 00       	mov    $0x0,%eax
  10404d:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  104050:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  104053:	72 0c                	jb     104061 <page_init+0x142>
                maxpa = end;
  104055:	8b 45 98             	mov    -0x68(%ebp),%eax
  104058:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10405b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10405e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  104061:	ff 45 dc             	incl   -0x24(%ebp)
  104064:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104067:	8b 00                	mov    (%eax),%eax
  104069:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10406c:	0f 8c e6 fe ff ff    	jl     103f58 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104072:	ba 00 00 00 38       	mov    $0x38000000,%edx
  104077:	b8 00 00 00 00       	mov    $0x0,%eax
  10407c:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  10407f:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  104082:	73 0e                	jae    104092 <page_init+0x173>
        maxpa = KMEMSIZE;
  104084:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  10408b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104092:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104095:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104098:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10409c:	c1 ea 0c             	shr    $0xc,%edx
  10409f:	a3 a4 be 11 00       	mov    %eax,0x11bea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  1040a4:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  1040ab:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  1040b0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1040b3:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1040b6:	01 d0                	add    %edx,%eax
  1040b8:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1040bb:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1040be:	ba 00 00 00 00       	mov    $0x0,%edx
  1040c3:	f7 75 c0             	divl   -0x40(%ebp)
  1040c6:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1040c9:	29 d0                	sub    %edx,%eax
  1040cb:	a3 a0 be 11 00       	mov    %eax,0x11bea0

    for (i = 0; i < npage; i ++) {
  1040d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1040d7:	eb 2f                	jmp    104108 <page_init+0x1e9>
        SetPageReserved(pages + i);
  1040d9:	8b 0d a0 be 11 00    	mov    0x11bea0,%ecx
  1040df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040e2:	89 d0                	mov    %edx,%eax
  1040e4:	c1 e0 02             	shl    $0x2,%eax
  1040e7:	01 d0                	add    %edx,%eax
  1040e9:	c1 e0 02             	shl    $0x2,%eax
  1040ec:	01 c8                	add    %ecx,%eax
  1040ee:	83 c0 04             	add    $0x4,%eax
  1040f1:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  1040f8:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1040fb:	8b 45 90             	mov    -0x70(%ebp),%eax
  1040fe:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104101:	0f ab 10             	bts    %edx,(%eax)
}
  104104:	90                   	nop
    for (i = 0; i < npage; i ++) {
  104105:	ff 45 dc             	incl   -0x24(%ebp)
  104108:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10410b:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104110:	39 c2                	cmp    %eax,%edx
  104112:	72 c5                	jb     1040d9 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104114:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  10411a:	89 d0                	mov    %edx,%eax
  10411c:	c1 e0 02             	shl    $0x2,%eax
  10411f:	01 d0                	add    %edx,%eax
  104121:	c1 e0 02             	shl    $0x2,%eax
  104124:	89 c2                	mov    %eax,%edx
  104126:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  10412b:	01 d0                	add    %edx,%eax
  10412d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104130:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  104137:	77 23                	ja     10415c <page_init+0x23d>
  104139:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10413c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104140:	c7 44 24 08 88 6a 10 	movl   $0x106a88,0x8(%esp)
  104147:	00 
  104148:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10414f:	00 
  104150:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104157:	e8 7f cb ff ff       	call   100cdb <__panic>
  10415c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10415f:	05 00 00 00 40       	add    $0x40000000,%eax
  104164:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104167:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10416e:	e9 53 01 00 00       	jmp    1042c6 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104173:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104176:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104179:	89 d0                	mov    %edx,%eax
  10417b:	c1 e0 02             	shl    $0x2,%eax
  10417e:	01 d0                	add    %edx,%eax
  104180:	c1 e0 02             	shl    $0x2,%eax
  104183:	01 c8                	add    %ecx,%eax
  104185:	8b 50 08             	mov    0x8(%eax),%edx
  104188:	8b 40 04             	mov    0x4(%eax),%eax
  10418b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10418e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104191:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104194:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104197:	89 d0                	mov    %edx,%eax
  104199:	c1 e0 02             	shl    $0x2,%eax
  10419c:	01 d0                	add    %edx,%eax
  10419e:	c1 e0 02             	shl    $0x2,%eax
  1041a1:	01 c8                	add    %ecx,%eax
  1041a3:	8b 48 0c             	mov    0xc(%eax),%ecx
  1041a6:	8b 58 10             	mov    0x10(%eax),%ebx
  1041a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041af:	01 c8                	add    %ecx,%eax
  1041b1:	11 da                	adc    %ebx,%edx
  1041b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1041b6:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1041b9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1041bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041bf:	89 d0                	mov    %edx,%eax
  1041c1:	c1 e0 02             	shl    $0x2,%eax
  1041c4:	01 d0                	add    %edx,%eax
  1041c6:	c1 e0 02             	shl    $0x2,%eax
  1041c9:	01 c8                	add    %ecx,%eax
  1041cb:	83 c0 14             	add    $0x14,%eax
  1041ce:	8b 00                	mov    (%eax),%eax
  1041d0:	83 f8 01             	cmp    $0x1,%eax
  1041d3:	0f 85 ea 00 00 00    	jne    1042c3 <page_init+0x3a4>
            if (begin < freemem) {
  1041d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1041dc:	ba 00 00 00 00       	mov    $0x0,%edx
  1041e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1041e4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1041e7:	19 d1                	sbb    %edx,%ecx
  1041e9:	73 0d                	jae    1041f8 <page_init+0x2d9>
                begin = freemem;
  1041eb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1041ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1041f1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1041f8:	ba 00 00 00 38       	mov    $0x38000000,%edx
  1041fd:	b8 00 00 00 00       	mov    $0x0,%eax
  104202:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  104205:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104208:	73 0e                	jae    104218 <page_init+0x2f9>
                end = KMEMSIZE;
  10420a:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104211:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104218:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10421b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10421e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104221:	89 d0                	mov    %edx,%eax
  104223:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104226:	0f 83 97 00 00 00    	jae    1042c3 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  10422c:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  104233:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104236:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104239:	01 d0                	add    %edx,%eax
  10423b:	48                   	dec    %eax
  10423c:	89 45 ac             	mov    %eax,-0x54(%ebp)
  10423f:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104242:	ba 00 00 00 00       	mov    $0x0,%edx
  104247:	f7 75 b0             	divl   -0x50(%ebp)
  10424a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10424d:	29 d0                	sub    %edx,%eax
  10424f:	ba 00 00 00 00       	mov    $0x0,%edx
  104254:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104257:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10425a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10425d:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104260:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104263:	ba 00 00 00 00       	mov    $0x0,%edx
  104268:	89 c7                	mov    %eax,%edi
  10426a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104270:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104273:	89 d0                	mov    %edx,%eax
  104275:	83 e0 00             	and    $0x0,%eax
  104278:	89 45 84             	mov    %eax,-0x7c(%ebp)
  10427b:	8b 45 80             	mov    -0x80(%ebp),%eax
  10427e:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104281:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104284:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104287:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10428a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10428d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104290:	89 d0                	mov    %edx,%eax
  104292:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104295:	73 2c                	jae    1042c3 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104297:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10429a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10429d:	2b 45 d0             	sub    -0x30(%ebp),%eax
  1042a0:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  1042a3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1042a7:	c1 ea 0c             	shr    $0xc,%edx
  1042aa:	89 c3                	mov    %eax,%ebx
  1042ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1042af:	89 04 24             	mov    %eax,(%esp)
  1042b2:	e8 c9 f8 ff ff       	call   103b80 <pa2page>
  1042b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1042bb:	89 04 24             	mov    %eax,(%esp)
  1042be:	e8 9e fb ff ff       	call   103e61 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  1042c3:	ff 45 dc             	incl   -0x24(%ebp)
  1042c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1042c9:	8b 00                	mov    (%eax),%eax
  1042cb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1042ce:	0f 8c 9f fe ff ff    	jl     104173 <page_init+0x254>
                }
            }
        }
    }
}
  1042d4:	90                   	nop
  1042d5:	90                   	nop
  1042d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1042dc:	5b                   	pop    %ebx
  1042dd:	5e                   	pop    %esi
  1042de:	5f                   	pop    %edi
  1042df:	5d                   	pop    %ebp
  1042e0:	c3                   	ret    

001042e1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1042e1:	55                   	push   %ebp
  1042e2:	89 e5                	mov    %esp,%ebp
  1042e4:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042ea:	33 45 14             	xor    0x14(%ebp),%eax
  1042ed:	25 ff 0f 00 00       	and    $0xfff,%eax
  1042f2:	85 c0                	test   %eax,%eax
  1042f4:	74 24                	je     10431a <boot_map_segment+0x39>
  1042f6:	c7 44 24 0c ba 6a 10 	movl   $0x106aba,0xc(%esp)
  1042fd:	00 
  1042fe:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104305:	00 
  104306:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  10430d:	00 
  10430e:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104315:	e8 c1 c9 ff ff       	call   100cdb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10431a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104321:	8b 45 0c             	mov    0xc(%ebp),%eax
  104324:	25 ff 0f 00 00       	and    $0xfff,%eax
  104329:	89 c2                	mov    %eax,%edx
  10432b:	8b 45 10             	mov    0x10(%ebp),%eax
  10432e:	01 c2                	add    %eax,%edx
  104330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104333:	01 d0                	add    %edx,%eax
  104335:	48                   	dec    %eax
  104336:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104339:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10433c:	ba 00 00 00 00       	mov    $0x0,%edx
  104341:	f7 75 f0             	divl   -0x10(%ebp)
  104344:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104347:	29 d0                	sub    %edx,%eax
  104349:	c1 e8 0c             	shr    $0xc,%eax
  10434c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10434f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104352:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104355:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104358:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10435d:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104360:	8b 45 14             	mov    0x14(%ebp),%eax
  104363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104369:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10436e:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104371:	eb 68                	jmp    1043db <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104373:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10437a:	00 
  10437b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10437e:	89 44 24 04          	mov    %eax,0x4(%esp)
  104382:	8b 45 08             	mov    0x8(%ebp),%eax
  104385:	89 04 24             	mov    %eax,(%esp)
  104388:	e8 88 01 00 00       	call   104515 <get_pte>
  10438d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104390:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104394:	75 24                	jne    1043ba <boot_map_segment+0xd9>
  104396:	c7 44 24 0c e6 6a 10 	movl   $0x106ae6,0xc(%esp)
  10439d:	00 
  10439e:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1043a5:	00 
  1043a6:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1043ad:	00 
  1043ae:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1043b5:	e8 21 c9 ff ff       	call   100cdb <__panic>
        *ptep = pa | PTE_P | perm;
  1043ba:	8b 45 14             	mov    0x14(%ebp),%eax
  1043bd:	0b 45 18             	or     0x18(%ebp),%eax
  1043c0:	83 c8 01             	or     $0x1,%eax
  1043c3:	89 c2                	mov    %eax,%edx
  1043c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043c8:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1043ca:	ff 4d f4             	decl   -0xc(%ebp)
  1043cd:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1043d4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1043db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1043df:	75 92                	jne    104373 <boot_map_segment+0x92>
    }
}
  1043e1:	90                   	nop
  1043e2:	90                   	nop
  1043e3:	89 ec                	mov    %ebp,%esp
  1043e5:	5d                   	pop    %ebp
  1043e6:	c3                   	ret    

001043e7 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1043e7:	55                   	push   %ebp
  1043e8:	89 e5                	mov    %esp,%ebp
  1043ea:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1043ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1043f4:	e8 8a fa ff ff       	call   103e83 <alloc_pages>
  1043f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1043fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104400:	75 1c                	jne    10441e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  104402:	c7 44 24 08 f3 6a 10 	movl   $0x106af3,0x8(%esp)
  104409:	00 
  10440a:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104411:	00 
  104412:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104419:	e8 bd c8 ff ff       	call   100cdb <__panic>
    }
    return page2kva(p);
  10441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104421:	89 04 24             	mov    %eax,(%esp)
  104424:	e8 a8 f7 ff ff       	call   103bd1 <page2kva>
}
  104429:	89 ec                	mov    %ebp,%esp
  10442b:	5d                   	pop    %ebp
  10442c:	c3                   	ret    

0010442d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10442d:	55                   	push   %ebp
  10442e:	89 e5                	mov    %esp,%ebp
  104430:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104433:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104438:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10443b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104442:	77 23                	ja     104467 <pmm_init+0x3a>
  104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10444b:	c7 44 24 08 88 6a 10 	movl   $0x106a88,0x8(%esp)
  104452:	00 
  104453:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10445a:	00 
  10445b:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104462:	e8 74 c8 ff ff       	call   100cdb <__panic>
  104467:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10446a:	05 00 00 00 40       	add    $0x40000000,%eax
  10446f:	a3 a8 be 11 00       	mov    %eax,0x11bea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  104474:	e8 b2 f9 ff ff       	call   103e2b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104479:	e8 a1 fa ff ff       	call   103f1f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10447e:	e8 5a 02 00 00       	call   1046dd <check_alloc_page>

    check_pgdir();
  104483:	e8 76 02 00 00       	call   1046fe <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104488:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10448d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104490:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104497:	77 23                	ja     1044bc <pmm_init+0x8f>
  104499:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10449c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044a0:	c7 44 24 08 88 6a 10 	movl   $0x106a88,0x8(%esp)
  1044a7:	00 
  1044a8:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1044af:	00 
  1044b0:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1044b7:	e8 1f c8 ff ff       	call   100cdb <__panic>
  1044bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044bf:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1044c5:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1044ca:	05 ac 0f 00 00       	add    $0xfac,%eax
  1044cf:	83 ca 03             	or     $0x3,%edx
  1044d2:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1044d4:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1044d9:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1044e0:	00 
  1044e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1044e8:	00 
  1044e9:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1044f0:	38 
  1044f1:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1044f8:	c0 
  1044f9:	89 04 24             	mov    %eax,(%esp)
  1044fc:	e8 e0 fd ff ff       	call   1042e1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  104501:	e8 39 f8 ff ff       	call   103d3f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  104506:	e8 91 08 00 00       	call   104d9c <check_boot_pgdir>

    print_pgdir();
  10450b:	e8 0e 0d 00 00       	call   10521e <print_pgdir>

}
  104510:	90                   	nop
  104511:	89 ec                	mov    %ebp,%esp
  104513:	5d                   	pop    %ebp
  104514:	c3                   	ret    

00104515 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104515:	55                   	push   %ebp
  104516:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  104518:	90                   	nop
  104519:	5d                   	pop    %ebp
  10451a:	c3                   	ret    

0010451b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10451b:	55                   	push   %ebp
  10451c:	89 e5                	mov    %esp,%ebp
  10451e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104521:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104528:	00 
  104529:	8b 45 0c             	mov    0xc(%ebp),%eax
  10452c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104530:	8b 45 08             	mov    0x8(%ebp),%eax
  104533:	89 04 24             	mov    %eax,(%esp)
  104536:	e8 da ff ff ff       	call   104515 <get_pte>
  10453b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10453e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104542:	74 08                	je     10454c <get_page+0x31>
        *ptep_store = ptep;
  104544:	8b 45 10             	mov    0x10(%ebp),%eax
  104547:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10454a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10454c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104550:	74 1b                	je     10456d <get_page+0x52>
  104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104555:	8b 00                	mov    (%eax),%eax
  104557:	83 e0 01             	and    $0x1,%eax
  10455a:	85 c0                	test   %eax,%eax
  10455c:	74 0f                	je     10456d <get_page+0x52>
        return pte2page(*ptep);
  10455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104561:	8b 00                	mov    (%eax),%eax
  104563:	89 04 24             	mov    %eax,(%esp)
  104566:	e8 bc f6 ff ff       	call   103c27 <pte2page>
  10456b:	eb 05                	jmp    104572 <get_page+0x57>
    }
    return NULL;
  10456d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104572:	89 ec                	mov    %ebp,%esp
  104574:	5d                   	pop    %ebp
  104575:	c3                   	ret    

00104576 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104576:	55                   	push   %ebp
  104577:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  104579:	90                   	nop
  10457a:	5d                   	pop    %ebp
  10457b:	c3                   	ret    

0010457c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10457c:	55                   	push   %ebp
  10457d:	89 e5                	mov    %esp,%ebp
  10457f:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104582:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104589:	00 
  10458a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10458d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104591:	8b 45 08             	mov    0x8(%ebp),%eax
  104594:	89 04 24             	mov    %eax,(%esp)
  104597:	e8 79 ff ff ff       	call   104515 <get_pte>
  10459c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  10459f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1045a3:	74 19                	je     1045be <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1045a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1045a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1045ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1045b6:	89 04 24             	mov    %eax,(%esp)
  1045b9:	e8 b8 ff ff ff       	call   104576 <page_remove_pte>
    }
}
  1045be:	90                   	nop
  1045bf:	89 ec                	mov    %ebp,%esp
  1045c1:	5d                   	pop    %ebp
  1045c2:	c3                   	ret    

001045c3 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1045c3:	55                   	push   %ebp
  1045c4:	89 e5                	mov    %esp,%ebp
  1045c6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1045c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1045d0:	00 
  1045d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1045d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1045db:	89 04 24             	mov    %eax,(%esp)
  1045de:	e8 32 ff ff ff       	call   104515 <get_pte>
  1045e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1045e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1045ea:	75 0a                	jne    1045f6 <page_insert+0x33>
        return -E_NO_MEM;
  1045ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1045f1:	e9 84 00 00 00       	jmp    10467a <page_insert+0xb7>
    }
    page_ref_inc(page);
  1045f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045f9:	89 04 24             	mov    %eax,(%esp)
  1045fc:	e8 8a f6 ff ff       	call   103c8b <page_ref_inc>
    if (*ptep & PTE_P) {
  104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104604:	8b 00                	mov    (%eax),%eax
  104606:	83 e0 01             	and    $0x1,%eax
  104609:	85 c0                	test   %eax,%eax
  10460b:	74 3e                	je     10464b <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10460d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104610:	8b 00                	mov    (%eax),%eax
  104612:	89 04 24             	mov    %eax,(%esp)
  104615:	e8 0d f6 ff ff       	call   103c27 <pte2page>
  10461a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10461d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104620:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104623:	75 0d                	jne    104632 <page_insert+0x6f>
            page_ref_dec(page);
  104625:	8b 45 0c             	mov    0xc(%ebp),%eax
  104628:	89 04 24             	mov    %eax,(%esp)
  10462b:	e8 72 f6 ff ff       	call   103ca2 <page_ref_dec>
  104630:	eb 19                	jmp    10464b <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104635:	89 44 24 08          	mov    %eax,0x8(%esp)
  104639:	8b 45 10             	mov    0x10(%ebp),%eax
  10463c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104640:	8b 45 08             	mov    0x8(%ebp),%eax
  104643:	89 04 24             	mov    %eax,(%esp)
  104646:	e8 2b ff ff ff       	call   104576 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  10464b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10464e:	89 04 24             	mov    %eax,(%esp)
  104651:	e8 12 f5 ff ff       	call   103b68 <page2pa>
  104656:	0b 45 14             	or     0x14(%ebp),%eax
  104659:	83 c8 01             	or     $0x1,%eax
  10465c:	89 c2                	mov    %eax,%edx
  10465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104661:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104663:	8b 45 10             	mov    0x10(%ebp),%eax
  104666:	89 44 24 04          	mov    %eax,0x4(%esp)
  10466a:	8b 45 08             	mov    0x8(%ebp),%eax
  10466d:	89 04 24             	mov    %eax,(%esp)
  104670:	e8 09 00 00 00       	call   10467e <tlb_invalidate>
    return 0;
  104675:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10467a:	89 ec                	mov    %ebp,%esp
  10467c:	5d                   	pop    %ebp
  10467d:	c3                   	ret    

0010467e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10467e:	55                   	push   %ebp
  10467f:	89 e5                	mov    %esp,%ebp
  104681:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104684:	0f 20 d8             	mov    %cr3,%eax
  104687:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10468a:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  10468d:	8b 45 08             	mov    0x8(%ebp),%eax
  104690:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104693:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10469a:	77 23                	ja     1046bf <tlb_invalidate+0x41>
  10469c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10469f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1046a3:	c7 44 24 08 88 6a 10 	movl   $0x106a88,0x8(%esp)
  1046aa:	00 
  1046ab:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  1046b2:	00 
  1046b3:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1046ba:	e8 1c c6 ff ff       	call   100cdb <__panic>
  1046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046c2:	05 00 00 00 40       	add    $0x40000000,%eax
  1046c7:	39 d0                	cmp    %edx,%eax
  1046c9:	75 0d                	jne    1046d8 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  1046cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1046d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046d4:	0f 01 38             	invlpg (%eax)
}
  1046d7:	90                   	nop
    }
}
  1046d8:	90                   	nop
  1046d9:	89 ec                	mov    %ebp,%esp
  1046db:	5d                   	pop    %ebp
  1046dc:	c3                   	ret    

001046dd <check_alloc_page>:

static void
check_alloc_page(void) {
  1046dd:	55                   	push   %ebp
  1046de:	89 e5                	mov    %esp,%ebp
  1046e0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1046e3:	a1 ac be 11 00       	mov    0x11beac,%eax
  1046e8:	8b 40 18             	mov    0x18(%eax),%eax
  1046eb:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1046ed:	c7 04 24 0c 6b 10 00 	movl   $0x106b0c,(%esp)
  1046f4:	e8 5d bc ff ff       	call   100356 <cprintf>
}
  1046f9:	90                   	nop
  1046fa:	89 ec                	mov    %ebp,%esp
  1046fc:	5d                   	pop    %ebp
  1046fd:	c3                   	ret    

001046fe <check_pgdir>:

static void
check_pgdir(void) {
  1046fe:	55                   	push   %ebp
  1046ff:	89 e5                	mov    %esp,%ebp
  104701:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104704:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104709:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10470e:	76 24                	jbe    104734 <check_pgdir+0x36>
  104710:	c7 44 24 0c 2b 6b 10 	movl   $0x106b2b,0xc(%esp)
  104717:	00 
  104718:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  10471f:	00 
  104720:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  104727:	00 
  104728:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  10472f:	e8 a7 c5 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104734:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104739:	85 c0                	test   %eax,%eax
  10473b:	74 0e                	je     10474b <check_pgdir+0x4d>
  10473d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104742:	25 ff 0f 00 00       	and    $0xfff,%eax
  104747:	85 c0                	test   %eax,%eax
  104749:	74 24                	je     10476f <check_pgdir+0x71>
  10474b:	c7 44 24 0c 48 6b 10 	movl   $0x106b48,0xc(%esp)
  104752:	00 
  104753:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  10475a:	00 
  10475b:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  104762:	00 
  104763:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  10476a:	e8 6c c5 ff ff       	call   100cdb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10476f:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104774:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10477b:	00 
  10477c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104783:	00 
  104784:	89 04 24             	mov    %eax,(%esp)
  104787:	e8 8f fd ff ff       	call   10451b <get_page>
  10478c:	85 c0                	test   %eax,%eax
  10478e:	74 24                	je     1047b4 <check_pgdir+0xb6>
  104790:	c7 44 24 0c 80 6b 10 	movl   $0x106b80,0xc(%esp)
  104797:	00 
  104798:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  10479f:	00 
  1047a0:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  1047a7:	00 
  1047a8:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1047af:	e8 27 c5 ff ff       	call   100cdb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1047b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047bb:	e8 c3 f6 ff ff       	call   103e83 <alloc_pages>
  1047c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1047c3:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1047c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1047cf:	00 
  1047d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1047d7:	00 
  1047d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1047db:	89 54 24 04          	mov    %edx,0x4(%esp)
  1047df:	89 04 24             	mov    %eax,(%esp)
  1047e2:	e8 dc fd ff ff       	call   1045c3 <page_insert>
  1047e7:	85 c0                	test   %eax,%eax
  1047e9:	74 24                	je     10480f <check_pgdir+0x111>
  1047eb:	c7 44 24 0c a8 6b 10 	movl   $0x106ba8,0xc(%esp)
  1047f2:	00 
  1047f3:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1047fa:	00 
  1047fb:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  104802:	00 
  104803:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  10480a:	e8 cc c4 ff ff       	call   100cdb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  10480f:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104814:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10481b:	00 
  10481c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104823:	00 
  104824:	89 04 24             	mov    %eax,(%esp)
  104827:	e8 e9 fc ff ff       	call   104515 <get_pte>
  10482c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10482f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104833:	75 24                	jne    104859 <check_pgdir+0x15b>
  104835:	c7 44 24 0c d4 6b 10 	movl   $0x106bd4,0xc(%esp)
  10483c:	00 
  10483d:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104844:	00 
  104845:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  10484c:	00 
  10484d:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104854:	e8 82 c4 ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10485c:	8b 00                	mov    (%eax),%eax
  10485e:	89 04 24             	mov    %eax,(%esp)
  104861:	e8 c1 f3 ff ff       	call   103c27 <pte2page>
  104866:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104869:	74 24                	je     10488f <check_pgdir+0x191>
  10486b:	c7 44 24 0c 01 6c 10 	movl   $0x106c01,0xc(%esp)
  104872:	00 
  104873:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  10487a:	00 
  10487b:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  104882:	00 
  104883:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  10488a:	e8 4c c4 ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 1);
  10488f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104892:	89 04 24             	mov    %eax,(%esp)
  104895:	e8 e7 f3 ff ff       	call   103c81 <page_ref>
  10489a:	83 f8 01             	cmp    $0x1,%eax
  10489d:	74 24                	je     1048c3 <check_pgdir+0x1c5>
  10489f:	c7 44 24 0c 17 6c 10 	movl   $0x106c17,0xc(%esp)
  1048a6:	00 
  1048a7:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1048ae:	00 
  1048af:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  1048b6:	00 
  1048b7:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1048be:	e8 18 c4 ff ff       	call   100cdb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1048c3:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1048c8:	8b 00                	mov    (%eax),%eax
  1048ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1048cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1048d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048d5:	c1 e8 0c             	shr    $0xc,%eax
  1048d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1048db:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  1048e0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1048e3:	72 23                	jb     104908 <check_pgdir+0x20a>
  1048e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1048ec:	c7 44 24 08 e4 69 10 	movl   $0x1069e4,0x8(%esp)
  1048f3:	00 
  1048f4:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  1048fb:	00 
  1048fc:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104903:	e8 d3 c3 ff ff       	call   100cdb <__panic>
  104908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10490b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104910:	83 c0 04             	add    $0x4,%eax
  104913:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104916:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10491b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104922:	00 
  104923:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10492a:	00 
  10492b:	89 04 24             	mov    %eax,(%esp)
  10492e:	e8 e2 fb ff ff       	call   104515 <get_pte>
  104933:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104936:	74 24                	je     10495c <check_pgdir+0x25e>
  104938:	c7 44 24 0c 2c 6c 10 	movl   $0x106c2c,0xc(%esp)
  10493f:	00 
  104940:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104947:	00 
  104948:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  10494f:	00 
  104950:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104957:	e8 7f c3 ff ff       	call   100cdb <__panic>

    p2 = alloc_page();
  10495c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104963:	e8 1b f5 ff ff       	call   103e83 <alloc_pages>
  104968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10496b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104970:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104977:	00 
  104978:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10497f:	00 
  104980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104983:	89 54 24 04          	mov    %edx,0x4(%esp)
  104987:	89 04 24             	mov    %eax,(%esp)
  10498a:	e8 34 fc ff ff       	call   1045c3 <page_insert>
  10498f:	85 c0                	test   %eax,%eax
  104991:	74 24                	je     1049b7 <check_pgdir+0x2b9>
  104993:	c7 44 24 0c 54 6c 10 	movl   $0x106c54,0xc(%esp)
  10499a:	00 
  10499b:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1049a2:	00 
  1049a3:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  1049aa:	00 
  1049ab:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1049b2:	e8 24 c3 ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1049b7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1049bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049c3:	00 
  1049c4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1049cb:	00 
  1049cc:	89 04 24             	mov    %eax,(%esp)
  1049cf:	e8 41 fb ff ff       	call   104515 <get_pte>
  1049d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1049d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1049db:	75 24                	jne    104a01 <check_pgdir+0x303>
  1049dd:	c7 44 24 0c 8c 6c 10 	movl   $0x106c8c,0xc(%esp)
  1049e4:	00 
  1049e5:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1049ec:	00 
  1049ed:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1049f4:	00 
  1049f5:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1049fc:	e8 da c2 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_U);
  104a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a04:	8b 00                	mov    (%eax),%eax
  104a06:	83 e0 04             	and    $0x4,%eax
  104a09:	85 c0                	test   %eax,%eax
  104a0b:	75 24                	jne    104a31 <check_pgdir+0x333>
  104a0d:	c7 44 24 0c bc 6c 10 	movl   $0x106cbc,0xc(%esp)
  104a14:	00 
  104a15:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104a1c:	00 
  104a1d:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  104a24:	00 
  104a25:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104a2c:	e8 aa c2 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_W);
  104a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a34:	8b 00                	mov    (%eax),%eax
  104a36:	83 e0 02             	and    $0x2,%eax
  104a39:	85 c0                	test   %eax,%eax
  104a3b:	75 24                	jne    104a61 <check_pgdir+0x363>
  104a3d:	c7 44 24 0c ca 6c 10 	movl   $0x106cca,0xc(%esp)
  104a44:	00 
  104a45:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104a4c:	00 
  104a4d:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  104a54:	00 
  104a55:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104a5c:	e8 7a c2 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104a61:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104a66:	8b 00                	mov    (%eax),%eax
  104a68:	83 e0 04             	and    $0x4,%eax
  104a6b:	85 c0                	test   %eax,%eax
  104a6d:	75 24                	jne    104a93 <check_pgdir+0x395>
  104a6f:	c7 44 24 0c d8 6c 10 	movl   $0x106cd8,0xc(%esp)
  104a76:	00 
  104a77:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104a7e:	00 
  104a7f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104a86:	00 
  104a87:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104a8e:	e8 48 c2 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 1);
  104a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a96:	89 04 24             	mov    %eax,(%esp)
  104a99:	e8 e3 f1 ff ff       	call   103c81 <page_ref>
  104a9e:	83 f8 01             	cmp    $0x1,%eax
  104aa1:	74 24                	je     104ac7 <check_pgdir+0x3c9>
  104aa3:	c7 44 24 0c ee 6c 10 	movl   $0x106cee,0xc(%esp)
  104aaa:	00 
  104aab:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104ab2:	00 
  104ab3:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104aba:	00 
  104abb:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104ac2:	e8 14 c2 ff ff       	call   100cdb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104ac7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104acc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104ad3:	00 
  104ad4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104adb:	00 
  104adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104adf:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ae3:	89 04 24             	mov    %eax,(%esp)
  104ae6:	e8 d8 fa ff ff       	call   1045c3 <page_insert>
  104aeb:	85 c0                	test   %eax,%eax
  104aed:	74 24                	je     104b13 <check_pgdir+0x415>
  104aef:	c7 44 24 0c 00 6d 10 	movl   $0x106d00,0xc(%esp)
  104af6:	00 
  104af7:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104afe:	00 
  104aff:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  104b06:	00 
  104b07:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104b0e:	e8 c8 c1 ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 2);
  104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b16:	89 04 24             	mov    %eax,(%esp)
  104b19:	e8 63 f1 ff ff       	call   103c81 <page_ref>
  104b1e:	83 f8 02             	cmp    $0x2,%eax
  104b21:	74 24                	je     104b47 <check_pgdir+0x449>
  104b23:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104b2a:	00 
  104b2b:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104b32:	00 
  104b33:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  104b3a:	00 
  104b3b:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104b42:	e8 94 c1 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b4a:	89 04 24             	mov    %eax,(%esp)
  104b4d:	e8 2f f1 ff ff       	call   103c81 <page_ref>
  104b52:	85 c0                	test   %eax,%eax
  104b54:	74 24                	je     104b7a <check_pgdir+0x47c>
  104b56:	c7 44 24 0c 3e 6d 10 	movl   $0x106d3e,0xc(%esp)
  104b5d:	00 
  104b5e:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104b65:	00 
  104b66:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  104b6d:	00 
  104b6e:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104b75:	e8 61 c1 ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104b7a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104b7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b86:	00 
  104b87:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b8e:	00 
  104b8f:	89 04 24             	mov    %eax,(%esp)
  104b92:	e8 7e f9 ff ff       	call   104515 <get_pte>
  104b97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b9e:	75 24                	jne    104bc4 <check_pgdir+0x4c6>
  104ba0:	c7 44 24 0c 8c 6c 10 	movl   $0x106c8c,0xc(%esp)
  104ba7:	00 
  104ba8:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104baf:	00 
  104bb0:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  104bb7:	00 
  104bb8:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104bbf:	e8 17 c1 ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bc7:	8b 00                	mov    (%eax),%eax
  104bc9:	89 04 24             	mov    %eax,(%esp)
  104bcc:	e8 56 f0 ff ff       	call   103c27 <pte2page>
  104bd1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104bd4:	74 24                	je     104bfa <check_pgdir+0x4fc>
  104bd6:	c7 44 24 0c 01 6c 10 	movl   $0x106c01,0xc(%esp)
  104bdd:	00 
  104bde:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104be5:	00 
  104be6:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  104bed:	00 
  104bee:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104bf5:	e8 e1 c0 ff ff       	call   100cdb <__panic>
    assert((*ptep & PTE_U) == 0);
  104bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bfd:	8b 00                	mov    (%eax),%eax
  104bff:	83 e0 04             	and    $0x4,%eax
  104c02:	85 c0                	test   %eax,%eax
  104c04:	74 24                	je     104c2a <check_pgdir+0x52c>
  104c06:	c7 44 24 0c 50 6d 10 	movl   $0x106d50,0xc(%esp)
  104c0d:	00 
  104c0e:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104c15:	00 
  104c16:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104c1d:	00 
  104c1e:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104c25:	e8 b1 c0 ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, 0x0);
  104c2a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104c2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104c36:	00 
  104c37:	89 04 24             	mov    %eax,(%esp)
  104c3a:	e8 3d f9 ff ff       	call   10457c <page_remove>
    assert(page_ref(p1) == 1);
  104c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c42:	89 04 24             	mov    %eax,(%esp)
  104c45:	e8 37 f0 ff ff       	call   103c81 <page_ref>
  104c4a:	83 f8 01             	cmp    $0x1,%eax
  104c4d:	74 24                	je     104c73 <check_pgdir+0x575>
  104c4f:	c7 44 24 0c 17 6c 10 	movl   $0x106c17,0xc(%esp)
  104c56:	00 
  104c57:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104c5e:	00 
  104c5f:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  104c66:	00 
  104c67:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104c6e:	e8 68 c0 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c76:	89 04 24             	mov    %eax,(%esp)
  104c79:	e8 03 f0 ff ff       	call   103c81 <page_ref>
  104c7e:	85 c0                	test   %eax,%eax
  104c80:	74 24                	je     104ca6 <check_pgdir+0x5a8>
  104c82:	c7 44 24 0c 3e 6d 10 	movl   $0x106d3e,0xc(%esp)
  104c89:	00 
  104c8a:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104c91:	00 
  104c92:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104c99:	00 
  104c9a:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104ca1:	e8 35 c0 ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104ca6:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104cab:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104cb2:	00 
  104cb3:	89 04 24             	mov    %eax,(%esp)
  104cb6:	e8 c1 f8 ff ff       	call   10457c <page_remove>
    assert(page_ref(p1) == 0);
  104cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cbe:	89 04 24             	mov    %eax,(%esp)
  104cc1:	e8 bb ef ff ff       	call   103c81 <page_ref>
  104cc6:	85 c0                	test   %eax,%eax
  104cc8:	74 24                	je     104cee <check_pgdir+0x5f0>
  104cca:	c7 44 24 0c 65 6d 10 	movl   $0x106d65,0xc(%esp)
  104cd1:	00 
  104cd2:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104cd9:	00 
  104cda:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104ce1:	00 
  104ce2:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104ce9:	e8 ed bf ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cf1:	89 04 24             	mov    %eax,(%esp)
  104cf4:	e8 88 ef ff ff       	call   103c81 <page_ref>
  104cf9:	85 c0                	test   %eax,%eax
  104cfb:	74 24                	je     104d21 <check_pgdir+0x623>
  104cfd:	c7 44 24 0c 3e 6d 10 	movl   $0x106d3e,0xc(%esp)
  104d04:	00 
  104d05:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104d0c:	00 
  104d0d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104d14:	00 
  104d15:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104d1c:	e8 ba bf ff ff       	call   100cdb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104d21:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104d26:	8b 00                	mov    (%eax),%eax
  104d28:	89 04 24             	mov    %eax,(%esp)
  104d2b:	e8 37 ef ff ff       	call   103c67 <pde2page>
  104d30:	89 04 24             	mov    %eax,(%esp)
  104d33:	e8 49 ef ff ff       	call   103c81 <page_ref>
  104d38:	83 f8 01             	cmp    $0x1,%eax
  104d3b:	74 24                	je     104d61 <check_pgdir+0x663>
  104d3d:	c7 44 24 0c 78 6d 10 	movl   $0x106d78,0xc(%esp)
  104d44:	00 
  104d45:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104d4c:	00 
  104d4d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104d54:	00 
  104d55:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104d5c:	e8 7a bf ff ff       	call   100cdb <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104d61:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104d66:	8b 00                	mov    (%eax),%eax
  104d68:	89 04 24             	mov    %eax,(%esp)
  104d6b:	e8 f7 ee ff ff       	call   103c67 <pde2page>
  104d70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d77:	00 
  104d78:	89 04 24             	mov    %eax,(%esp)
  104d7b:	e8 3d f1 ff ff       	call   103ebd <free_pages>
    boot_pgdir[0] = 0;
  104d80:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104d85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104d8b:	c7 04 24 9f 6d 10 00 	movl   $0x106d9f,(%esp)
  104d92:	e8 bf b5 ff ff       	call   100356 <cprintf>
}
  104d97:	90                   	nop
  104d98:	89 ec                	mov    %ebp,%esp
  104d9a:	5d                   	pop    %ebp
  104d9b:	c3                   	ret    

00104d9c <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104d9c:	55                   	push   %ebp
  104d9d:	89 e5                	mov    %esp,%ebp
  104d9f:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104da2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104da9:	e9 ca 00 00 00       	jmp    104e78 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104db7:	c1 e8 0c             	shr    $0xc,%eax
  104dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104dbd:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104dc2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104dc5:	72 23                	jb     104dea <check_boot_pgdir+0x4e>
  104dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104dce:	c7 44 24 08 e4 69 10 	movl   $0x1069e4,0x8(%esp)
  104dd5:	00 
  104dd6:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104ddd:	00 
  104dde:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104de5:	e8 f1 be ff ff       	call   100cdb <__panic>
  104dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ded:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104df2:	89 c2                	mov    %eax,%edx
  104df4:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104df9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104e00:	00 
  104e01:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e05:	89 04 24             	mov    %eax,(%esp)
  104e08:	e8 08 f7 ff ff       	call   104515 <get_pte>
  104e0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104e10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104e14:	75 24                	jne    104e3a <check_boot_pgdir+0x9e>
  104e16:	c7 44 24 0c bc 6d 10 	movl   $0x106dbc,0xc(%esp)
  104e1d:	00 
  104e1e:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104e25:	00 
  104e26:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104e2d:	00 
  104e2e:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104e35:	e8 a1 be ff ff       	call   100cdb <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104e3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104e3d:	8b 00                	mov    (%eax),%eax
  104e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104e44:	89 c2                	mov    %eax,%edx
  104e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e49:	39 c2                	cmp    %eax,%edx
  104e4b:	74 24                	je     104e71 <check_boot_pgdir+0xd5>
  104e4d:	c7 44 24 0c f9 6d 10 	movl   $0x106df9,0xc(%esp)
  104e54:	00 
  104e55:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104e5c:	00 
  104e5d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104e64:	00 
  104e65:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104e6c:	e8 6a be ff ff       	call   100cdb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  104e71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104e7b:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104e80:	39 c2                	cmp    %eax,%edx
  104e82:	0f 82 26 ff ff ff    	jb     104dae <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104e88:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104e8d:	05 ac 0f 00 00       	add    $0xfac,%eax
  104e92:	8b 00                	mov    (%eax),%eax
  104e94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104e99:	89 c2                	mov    %eax,%edx
  104e9b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ea3:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104eaa:	77 23                	ja     104ecf <check_boot_pgdir+0x133>
  104eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104eb3:	c7 44 24 08 88 6a 10 	movl   $0x106a88,0x8(%esp)
  104eba:	00 
  104ebb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104ec2:	00 
  104ec3:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104eca:	e8 0c be ff ff       	call   100cdb <__panic>
  104ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ed2:	05 00 00 00 40       	add    $0x40000000,%eax
  104ed7:	39 d0                	cmp    %edx,%eax
  104ed9:	74 24                	je     104eff <check_boot_pgdir+0x163>
  104edb:	c7 44 24 0c 10 6e 10 	movl   $0x106e10,0xc(%esp)
  104ee2:	00 
  104ee3:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104eea:	00 
  104eeb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104ef2:	00 
  104ef3:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104efa:	e8 dc bd ff ff       	call   100cdb <__panic>

    assert(boot_pgdir[0] == 0);
  104eff:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104f04:	8b 00                	mov    (%eax),%eax
  104f06:	85 c0                	test   %eax,%eax
  104f08:	74 24                	je     104f2e <check_boot_pgdir+0x192>
  104f0a:	c7 44 24 0c 44 6e 10 	movl   $0x106e44,0xc(%esp)
  104f11:	00 
  104f12:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104f19:	00 
  104f1a:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104f21:	00 
  104f22:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104f29:	e8 ad bd ff ff       	call   100cdb <__panic>

    struct Page *p;
    p = alloc_page();
  104f2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f35:	e8 49 ef ff ff       	call   103e83 <alloc_pages>
  104f3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104f3d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104f42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104f49:	00 
  104f4a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104f51:	00 
  104f52:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104f55:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f59:	89 04 24             	mov    %eax,(%esp)
  104f5c:	e8 62 f6 ff ff       	call   1045c3 <page_insert>
  104f61:	85 c0                	test   %eax,%eax
  104f63:	74 24                	je     104f89 <check_boot_pgdir+0x1ed>
  104f65:	c7 44 24 0c 58 6e 10 	movl   $0x106e58,0xc(%esp)
  104f6c:	00 
  104f6d:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104f74:	00 
  104f75:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104f7c:	00 
  104f7d:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104f84:	e8 52 bd ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 1);
  104f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f8c:	89 04 24             	mov    %eax,(%esp)
  104f8f:	e8 ed ec ff ff       	call   103c81 <page_ref>
  104f94:	83 f8 01             	cmp    $0x1,%eax
  104f97:	74 24                	je     104fbd <check_boot_pgdir+0x221>
  104f99:	c7 44 24 0c 86 6e 10 	movl   $0x106e86,0xc(%esp)
  104fa0:	00 
  104fa1:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104fa8:	00 
  104fa9:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  104fb0:	00 
  104fb1:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  104fb8:	e8 1e bd ff ff       	call   100cdb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  104fbd:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104fc2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104fc9:	00 
  104fca:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  104fd1:	00 
  104fd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104fd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  104fd9:	89 04 24             	mov    %eax,(%esp)
  104fdc:	e8 e2 f5 ff ff       	call   1045c3 <page_insert>
  104fe1:	85 c0                	test   %eax,%eax
  104fe3:	74 24                	je     105009 <check_boot_pgdir+0x26d>
  104fe5:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  104fec:	00 
  104fed:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  104ff4:	00 
  104ff5:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104ffc:	00 
  104ffd:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  105004:	e8 d2 bc ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 2);
  105009:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10500c:	89 04 24             	mov    %eax,(%esp)
  10500f:	e8 6d ec ff ff       	call   103c81 <page_ref>
  105014:	83 f8 02             	cmp    $0x2,%eax
  105017:	74 24                	je     10503d <check_boot_pgdir+0x2a1>
  105019:	c7 44 24 0c cf 6e 10 	movl   $0x106ecf,0xc(%esp)
  105020:	00 
  105021:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  105028:	00 
  105029:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  105030:	00 
  105031:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  105038:	e8 9e bc ff ff       	call   100cdb <__panic>

    const char *str = "ucore: Hello world!!";
  10503d:	c7 45 e8 e0 6e 10 00 	movl   $0x106ee0,-0x18(%ebp)
    strcpy((void *)0x100, str);
  105044:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105047:	89 44 24 04          	mov    %eax,0x4(%esp)
  10504b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105052:	e8 fc 09 00 00       	call   105a53 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105057:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10505e:	00 
  10505f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105066:	e8 60 0a 00 00       	call   105acb <strcmp>
  10506b:	85 c0                	test   %eax,%eax
  10506d:	74 24                	je     105093 <check_boot_pgdir+0x2f7>
  10506f:	c7 44 24 0c f8 6e 10 	movl   $0x106ef8,0xc(%esp)
  105076:	00 
  105077:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  10507e:	00 
  10507f:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  105086:	00 
  105087:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  10508e:	e8 48 bc ff ff       	call   100cdb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105093:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105096:	89 04 24             	mov    %eax,(%esp)
  105099:	e8 33 eb ff ff       	call   103bd1 <page2kva>
  10509e:	05 00 01 00 00       	add    $0x100,%eax
  1050a3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1050a6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1050ad:	e8 47 09 00 00       	call   1059f9 <strlen>
  1050b2:	85 c0                	test   %eax,%eax
  1050b4:	74 24                	je     1050da <check_boot_pgdir+0x33e>
  1050b6:	c7 44 24 0c 30 6f 10 	movl   $0x106f30,0xc(%esp)
  1050bd:	00 
  1050be:	c7 44 24 08 d1 6a 10 	movl   $0x106ad1,0x8(%esp)
  1050c5:	00 
  1050c6:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  1050cd:	00 
  1050ce:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  1050d5:	e8 01 bc ff ff       	call   100cdb <__panic>

    free_page(p);
  1050da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050e1:	00 
  1050e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1050e5:	89 04 24             	mov    %eax,(%esp)
  1050e8:	e8 d0 ed ff ff       	call   103ebd <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1050ed:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1050f2:	8b 00                	mov    (%eax),%eax
  1050f4:	89 04 24             	mov    %eax,(%esp)
  1050f7:	e8 6b eb ff ff       	call   103c67 <pde2page>
  1050fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105103:	00 
  105104:	89 04 24             	mov    %eax,(%esp)
  105107:	e8 b1 ed ff ff       	call   103ebd <free_pages>
    boot_pgdir[0] = 0;
  10510c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  105111:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105117:	c7 04 24 54 6f 10 00 	movl   $0x106f54,(%esp)
  10511e:	e8 33 b2 ff ff       	call   100356 <cprintf>
}
  105123:	90                   	nop
  105124:	89 ec                	mov    %ebp,%esp
  105126:	5d                   	pop    %ebp
  105127:	c3                   	ret    

00105128 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105128:	55                   	push   %ebp
  105129:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10512b:	8b 45 08             	mov    0x8(%ebp),%eax
  10512e:	83 e0 04             	and    $0x4,%eax
  105131:	85 c0                	test   %eax,%eax
  105133:	74 04                	je     105139 <perm2str+0x11>
  105135:	b0 75                	mov    $0x75,%al
  105137:	eb 02                	jmp    10513b <perm2str+0x13>
  105139:	b0 2d                	mov    $0x2d,%al
  10513b:	a2 28 bf 11 00       	mov    %al,0x11bf28
    str[1] = 'r';
  105140:	c6 05 29 bf 11 00 72 	movb   $0x72,0x11bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105147:	8b 45 08             	mov    0x8(%ebp),%eax
  10514a:	83 e0 02             	and    $0x2,%eax
  10514d:	85 c0                	test   %eax,%eax
  10514f:	74 04                	je     105155 <perm2str+0x2d>
  105151:	b0 77                	mov    $0x77,%al
  105153:	eb 02                	jmp    105157 <perm2str+0x2f>
  105155:	b0 2d                	mov    $0x2d,%al
  105157:	a2 2a bf 11 00       	mov    %al,0x11bf2a
    str[3] = '\0';
  10515c:	c6 05 2b bf 11 00 00 	movb   $0x0,0x11bf2b
    return str;
  105163:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
}
  105168:	5d                   	pop    %ebp
  105169:	c3                   	ret    

0010516a <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  10516a:	55                   	push   %ebp
  10516b:	89 e5                	mov    %esp,%ebp
  10516d:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105170:	8b 45 10             	mov    0x10(%ebp),%eax
  105173:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105176:	72 0d                	jb     105185 <get_pgtable_items+0x1b>
        return 0;
  105178:	b8 00 00 00 00       	mov    $0x0,%eax
  10517d:	e9 98 00 00 00       	jmp    10521a <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  105182:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  105185:	8b 45 10             	mov    0x10(%ebp),%eax
  105188:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10518b:	73 18                	jae    1051a5 <get_pgtable_items+0x3b>
  10518d:	8b 45 10             	mov    0x10(%ebp),%eax
  105190:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105197:	8b 45 14             	mov    0x14(%ebp),%eax
  10519a:	01 d0                	add    %edx,%eax
  10519c:	8b 00                	mov    (%eax),%eax
  10519e:	83 e0 01             	and    $0x1,%eax
  1051a1:	85 c0                	test   %eax,%eax
  1051a3:	74 dd                	je     105182 <get_pgtable_items+0x18>
    }
    if (start < right) {
  1051a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1051a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1051ab:	73 68                	jae    105215 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1051ad:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1051b1:	74 08                	je     1051bb <get_pgtable_items+0x51>
            *left_store = start;
  1051b3:	8b 45 18             	mov    0x18(%ebp),%eax
  1051b6:	8b 55 10             	mov    0x10(%ebp),%edx
  1051b9:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1051bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1051be:	8d 50 01             	lea    0x1(%eax),%edx
  1051c1:	89 55 10             	mov    %edx,0x10(%ebp)
  1051c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1051cb:	8b 45 14             	mov    0x14(%ebp),%eax
  1051ce:	01 d0                	add    %edx,%eax
  1051d0:	8b 00                	mov    (%eax),%eax
  1051d2:	83 e0 07             	and    $0x7,%eax
  1051d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1051d8:	eb 03                	jmp    1051dd <get_pgtable_items+0x73>
            start ++;
  1051da:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1051dd:	8b 45 10             	mov    0x10(%ebp),%eax
  1051e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1051e3:	73 1d                	jae    105202 <get_pgtable_items+0x98>
  1051e5:	8b 45 10             	mov    0x10(%ebp),%eax
  1051e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1051ef:	8b 45 14             	mov    0x14(%ebp),%eax
  1051f2:	01 d0                	add    %edx,%eax
  1051f4:	8b 00                	mov    (%eax),%eax
  1051f6:	83 e0 07             	and    $0x7,%eax
  1051f9:	89 c2                	mov    %eax,%edx
  1051fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1051fe:	39 c2                	cmp    %eax,%edx
  105200:	74 d8                	je     1051da <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  105202:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105206:	74 08                	je     105210 <get_pgtable_items+0xa6>
            *right_store = start;
  105208:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10520b:	8b 55 10             	mov    0x10(%ebp),%edx
  10520e:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105210:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105213:	eb 05                	jmp    10521a <get_pgtable_items+0xb0>
    }
    return 0;
  105215:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10521a:	89 ec                	mov    %ebp,%esp
  10521c:	5d                   	pop    %ebp
  10521d:	c3                   	ret    

0010521e <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10521e:	55                   	push   %ebp
  10521f:	89 e5                	mov    %esp,%ebp
  105221:	57                   	push   %edi
  105222:	56                   	push   %esi
  105223:	53                   	push   %ebx
  105224:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105227:	c7 04 24 74 6f 10 00 	movl   $0x106f74,(%esp)
  10522e:	e8 23 b1 ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  105233:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10523a:	e9 f2 00 00 00       	jmp    105331 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10523f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105242:	89 04 24             	mov    %eax,(%esp)
  105245:	e8 de fe ff ff       	call   105128 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10524a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10524d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  105250:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105252:	89 d6                	mov    %edx,%esi
  105254:	c1 e6 16             	shl    $0x16,%esi
  105257:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10525a:	89 d3                	mov    %edx,%ebx
  10525c:	c1 e3 16             	shl    $0x16,%ebx
  10525f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105262:	89 d1                	mov    %edx,%ecx
  105264:	c1 e1 16             	shl    $0x16,%ecx
  105267:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10526a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  10526d:	29 fa                	sub    %edi,%edx
  10526f:	89 44 24 14          	mov    %eax,0x14(%esp)
  105273:	89 74 24 10          	mov    %esi,0x10(%esp)
  105277:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10527b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10527f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105283:	c7 04 24 a5 6f 10 00 	movl   $0x106fa5,(%esp)
  10528a:	e8 c7 b0 ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10528f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105292:	c1 e0 0a             	shl    $0xa,%eax
  105295:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105298:	eb 50                	jmp    1052ea <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10529a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10529d:	89 04 24             	mov    %eax,(%esp)
  1052a0:	e8 83 fe ff ff       	call   105128 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1052a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1052a8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  1052ab:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1052ad:	89 d6                	mov    %edx,%esi
  1052af:	c1 e6 0c             	shl    $0xc,%esi
  1052b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1052b5:	89 d3                	mov    %edx,%ebx
  1052b7:	c1 e3 0c             	shl    $0xc,%ebx
  1052ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1052bd:	89 d1                	mov    %edx,%ecx
  1052bf:	c1 e1 0c             	shl    $0xc,%ecx
  1052c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1052c5:	8b 7d d8             	mov    -0x28(%ebp),%edi
  1052c8:	29 fa                	sub    %edi,%edx
  1052ca:	89 44 24 14          	mov    %eax,0x14(%esp)
  1052ce:	89 74 24 10          	mov    %esi,0x10(%esp)
  1052d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1052d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1052da:	89 54 24 04          	mov    %edx,0x4(%esp)
  1052de:	c7 04 24 c4 6f 10 00 	movl   $0x106fc4,(%esp)
  1052e5:	e8 6c b0 ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1052ea:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1052ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1052f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1052f5:	89 d3                	mov    %edx,%ebx
  1052f7:	c1 e3 0a             	shl    $0xa,%ebx
  1052fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1052fd:	89 d1                	mov    %edx,%ecx
  1052ff:	c1 e1 0a             	shl    $0xa,%ecx
  105302:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  105305:	89 54 24 14          	mov    %edx,0x14(%esp)
  105309:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10530c:	89 54 24 10          	mov    %edx,0x10(%esp)
  105310:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105314:	89 44 24 08          	mov    %eax,0x8(%esp)
  105318:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10531c:	89 0c 24             	mov    %ecx,(%esp)
  10531f:	e8 46 fe ff ff       	call   10516a <get_pgtable_items>
  105324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10532b:	0f 85 69 ff ff ff    	jne    10529a <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105331:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  105336:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105339:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10533c:	89 54 24 14          	mov    %edx,0x14(%esp)
  105340:	8d 55 e0             	lea    -0x20(%ebp),%edx
  105343:	89 54 24 10          	mov    %edx,0x10(%esp)
  105347:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10534b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10534f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105356:	00 
  105357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10535e:	e8 07 fe ff ff       	call   10516a <get_pgtable_items>
  105363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105366:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10536a:	0f 85 cf fe ff ff    	jne    10523f <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105370:	c7 04 24 e8 6f 10 00 	movl   $0x106fe8,(%esp)
  105377:	e8 da af ff ff       	call   100356 <cprintf>
}
  10537c:	90                   	nop
  10537d:	83 c4 4c             	add    $0x4c,%esp
  105380:	5b                   	pop    %ebx
  105381:	5e                   	pop    %esi
  105382:	5f                   	pop    %edi
  105383:	5d                   	pop    %ebp
  105384:	c3                   	ret    

00105385 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105385:	55                   	push   %ebp
  105386:	89 e5                	mov    %esp,%ebp
  105388:	83 ec 58             	sub    $0x58,%esp
  10538b:	8b 45 10             	mov    0x10(%ebp),%eax
  10538e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105391:	8b 45 14             	mov    0x14(%ebp),%eax
  105394:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105397:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10539a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10539d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1053a0:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1053a3:	8b 45 18             	mov    0x18(%ebp),%eax
  1053a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1053a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1053af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1053b2:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1053b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1053bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1053bf:	74 1c                	je     1053dd <printnum+0x58>
  1053c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053c4:	ba 00 00 00 00       	mov    $0x0,%edx
  1053c9:	f7 75 e4             	divl   -0x1c(%ebp)
  1053cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1053cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053d2:	ba 00 00 00 00       	mov    $0x0,%edx
  1053d7:	f7 75 e4             	divl   -0x1c(%ebp)
  1053da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1053e3:	f7 75 e4             	divl   -0x1c(%ebp)
  1053e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1053e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1053ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1053f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1053f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053fb:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1053fe:	8b 45 18             	mov    0x18(%ebp),%eax
  105401:	ba 00 00 00 00       	mov    $0x0,%edx
  105406:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105409:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10540c:	19 d1                	sbb    %edx,%ecx
  10540e:	72 4c                	jb     10545c <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  105410:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105413:	8d 50 ff             	lea    -0x1(%eax),%edx
  105416:	8b 45 20             	mov    0x20(%ebp),%eax
  105419:	89 44 24 18          	mov    %eax,0x18(%esp)
  10541d:	89 54 24 14          	mov    %edx,0x14(%esp)
  105421:	8b 45 18             	mov    0x18(%ebp),%eax
  105424:	89 44 24 10          	mov    %eax,0x10(%esp)
  105428:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10542b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10542e:	89 44 24 08          	mov    %eax,0x8(%esp)
  105432:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105436:	8b 45 0c             	mov    0xc(%ebp),%eax
  105439:	89 44 24 04          	mov    %eax,0x4(%esp)
  10543d:	8b 45 08             	mov    0x8(%ebp),%eax
  105440:	89 04 24             	mov    %eax,(%esp)
  105443:	e8 3d ff ff ff       	call   105385 <printnum>
  105448:	eb 1b                	jmp    105465 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10544a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10544d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105451:	8b 45 20             	mov    0x20(%ebp),%eax
  105454:	89 04 24             	mov    %eax,(%esp)
  105457:	8b 45 08             	mov    0x8(%ebp),%eax
  10545a:	ff d0                	call   *%eax
        while (-- width > 0)
  10545c:	ff 4d 1c             	decl   0x1c(%ebp)
  10545f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105463:	7f e5                	jg     10544a <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105465:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105468:	05 9c 70 10 00       	add    $0x10709c,%eax
  10546d:	0f b6 00             	movzbl (%eax),%eax
  105470:	0f be c0             	movsbl %al,%eax
  105473:	8b 55 0c             	mov    0xc(%ebp),%edx
  105476:	89 54 24 04          	mov    %edx,0x4(%esp)
  10547a:	89 04 24             	mov    %eax,(%esp)
  10547d:	8b 45 08             	mov    0x8(%ebp),%eax
  105480:	ff d0                	call   *%eax
}
  105482:	90                   	nop
  105483:	89 ec                	mov    %ebp,%esp
  105485:	5d                   	pop    %ebp
  105486:	c3                   	ret    

00105487 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105487:	55                   	push   %ebp
  105488:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10548a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10548e:	7e 14                	jle    1054a4 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105490:	8b 45 08             	mov    0x8(%ebp),%eax
  105493:	8b 00                	mov    (%eax),%eax
  105495:	8d 48 08             	lea    0x8(%eax),%ecx
  105498:	8b 55 08             	mov    0x8(%ebp),%edx
  10549b:	89 0a                	mov    %ecx,(%edx)
  10549d:	8b 50 04             	mov    0x4(%eax),%edx
  1054a0:	8b 00                	mov    (%eax),%eax
  1054a2:	eb 30                	jmp    1054d4 <getuint+0x4d>
    }
    else if (lflag) {
  1054a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1054a8:	74 16                	je     1054c0 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1054aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ad:	8b 00                	mov    (%eax),%eax
  1054af:	8d 48 04             	lea    0x4(%eax),%ecx
  1054b2:	8b 55 08             	mov    0x8(%ebp),%edx
  1054b5:	89 0a                	mov    %ecx,(%edx)
  1054b7:	8b 00                	mov    (%eax),%eax
  1054b9:	ba 00 00 00 00       	mov    $0x0,%edx
  1054be:	eb 14                	jmp    1054d4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1054c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1054c3:	8b 00                	mov    (%eax),%eax
  1054c5:	8d 48 04             	lea    0x4(%eax),%ecx
  1054c8:	8b 55 08             	mov    0x8(%ebp),%edx
  1054cb:	89 0a                	mov    %ecx,(%edx)
  1054cd:	8b 00                	mov    (%eax),%eax
  1054cf:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1054d4:	5d                   	pop    %ebp
  1054d5:	c3                   	ret    

001054d6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1054d6:	55                   	push   %ebp
  1054d7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1054d9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1054dd:	7e 14                	jle    1054f3 <getint+0x1d>
        return va_arg(*ap, long long);
  1054df:	8b 45 08             	mov    0x8(%ebp),%eax
  1054e2:	8b 00                	mov    (%eax),%eax
  1054e4:	8d 48 08             	lea    0x8(%eax),%ecx
  1054e7:	8b 55 08             	mov    0x8(%ebp),%edx
  1054ea:	89 0a                	mov    %ecx,(%edx)
  1054ec:	8b 50 04             	mov    0x4(%eax),%edx
  1054ef:	8b 00                	mov    (%eax),%eax
  1054f1:	eb 28                	jmp    10551b <getint+0x45>
    }
    else if (lflag) {
  1054f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1054f7:	74 12                	je     10550b <getint+0x35>
        return va_arg(*ap, long);
  1054f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054fc:	8b 00                	mov    (%eax),%eax
  1054fe:	8d 48 04             	lea    0x4(%eax),%ecx
  105501:	8b 55 08             	mov    0x8(%ebp),%edx
  105504:	89 0a                	mov    %ecx,(%edx)
  105506:	8b 00                	mov    (%eax),%eax
  105508:	99                   	cltd   
  105509:	eb 10                	jmp    10551b <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10550b:	8b 45 08             	mov    0x8(%ebp),%eax
  10550e:	8b 00                	mov    (%eax),%eax
  105510:	8d 48 04             	lea    0x4(%eax),%ecx
  105513:	8b 55 08             	mov    0x8(%ebp),%edx
  105516:	89 0a                	mov    %ecx,(%edx)
  105518:	8b 00                	mov    (%eax),%eax
  10551a:	99                   	cltd   
    }
}
  10551b:	5d                   	pop    %ebp
  10551c:	c3                   	ret    

0010551d <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10551d:	55                   	push   %ebp
  10551e:	89 e5                	mov    %esp,%ebp
  105520:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105523:	8d 45 14             	lea    0x14(%ebp),%eax
  105526:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10552c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105530:	8b 45 10             	mov    0x10(%ebp),%eax
  105533:	89 44 24 08          	mov    %eax,0x8(%esp)
  105537:	8b 45 0c             	mov    0xc(%ebp),%eax
  10553a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10553e:	8b 45 08             	mov    0x8(%ebp),%eax
  105541:	89 04 24             	mov    %eax,(%esp)
  105544:	e8 05 00 00 00       	call   10554e <vprintfmt>
    va_end(ap);
}
  105549:	90                   	nop
  10554a:	89 ec                	mov    %ebp,%esp
  10554c:	5d                   	pop    %ebp
  10554d:	c3                   	ret    

0010554e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10554e:	55                   	push   %ebp
  10554f:	89 e5                	mov    %esp,%ebp
  105551:	56                   	push   %esi
  105552:	53                   	push   %ebx
  105553:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105556:	eb 17                	jmp    10556f <vprintfmt+0x21>
            if (ch == '\0') {
  105558:	85 db                	test   %ebx,%ebx
  10555a:	0f 84 bf 03 00 00    	je     10591f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105560:	8b 45 0c             	mov    0xc(%ebp),%eax
  105563:	89 44 24 04          	mov    %eax,0x4(%esp)
  105567:	89 1c 24             	mov    %ebx,(%esp)
  10556a:	8b 45 08             	mov    0x8(%ebp),%eax
  10556d:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10556f:	8b 45 10             	mov    0x10(%ebp),%eax
  105572:	8d 50 01             	lea    0x1(%eax),%edx
  105575:	89 55 10             	mov    %edx,0x10(%ebp)
  105578:	0f b6 00             	movzbl (%eax),%eax
  10557b:	0f b6 d8             	movzbl %al,%ebx
  10557e:	83 fb 25             	cmp    $0x25,%ebx
  105581:	75 d5                	jne    105558 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105583:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105587:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10558e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105591:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105594:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10559b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10559e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1055a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1055a4:	8d 50 01             	lea    0x1(%eax),%edx
  1055a7:	89 55 10             	mov    %edx,0x10(%ebp)
  1055aa:	0f b6 00             	movzbl (%eax),%eax
  1055ad:	0f b6 d8             	movzbl %al,%ebx
  1055b0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1055b3:	83 f8 55             	cmp    $0x55,%eax
  1055b6:	0f 87 37 03 00 00    	ja     1058f3 <vprintfmt+0x3a5>
  1055bc:	8b 04 85 c0 70 10 00 	mov    0x1070c0(,%eax,4),%eax
  1055c3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1055c5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1055c9:	eb d6                	jmp    1055a1 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1055cb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1055cf:	eb d0                	jmp    1055a1 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1055d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1055d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1055db:	89 d0                	mov    %edx,%eax
  1055dd:	c1 e0 02             	shl    $0x2,%eax
  1055e0:	01 d0                	add    %edx,%eax
  1055e2:	01 c0                	add    %eax,%eax
  1055e4:	01 d8                	add    %ebx,%eax
  1055e6:	83 e8 30             	sub    $0x30,%eax
  1055e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1055ec:	8b 45 10             	mov    0x10(%ebp),%eax
  1055ef:	0f b6 00             	movzbl (%eax),%eax
  1055f2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1055f5:	83 fb 2f             	cmp    $0x2f,%ebx
  1055f8:	7e 38                	jle    105632 <vprintfmt+0xe4>
  1055fa:	83 fb 39             	cmp    $0x39,%ebx
  1055fd:	7f 33                	jg     105632 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  1055ff:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105602:	eb d4                	jmp    1055d8 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105604:	8b 45 14             	mov    0x14(%ebp),%eax
  105607:	8d 50 04             	lea    0x4(%eax),%edx
  10560a:	89 55 14             	mov    %edx,0x14(%ebp)
  10560d:	8b 00                	mov    (%eax),%eax
  10560f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105612:	eb 1f                	jmp    105633 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105614:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105618:	79 87                	jns    1055a1 <vprintfmt+0x53>
                width = 0;
  10561a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105621:	e9 7b ff ff ff       	jmp    1055a1 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105626:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10562d:	e9 6f ff ff ff       	jmp    1055a1 <vprintfmt+0x53>
            goto process_precision;
  105632:	90                   	nop

        process_precision:
            if (width < 0)
  105633:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105637:	0f 89 64 ff ff ff    	jns    1055a1 <vprintfmt+0x53>
                width = precision, precision = -1;
  10563d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105640:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105643:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10564a:	e9 52 ff ff ff       	jmp    1055a1 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10564f:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105652:	e9 4a ff ff ff       	jmp    1055a1 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105657:	8b 45 14             	mov    0x14(%ebp),%eax
  10565a:	8d 50 04             	lea    0x4(%eax),%edx
  10565d:	89 55 14             	mov    %edx,0x14(%ebp)
  105660:	8b 00                	mov    (%eax),%eax
  105662:	8b 55 0c             	mov    0xc(%ebp),%edx
  105665:	89 54 24 04          	mov    %edx,0x4(%esp)
  105669:	89 04 24             	mov    %eax,(%esp)
  10566c:	8b 45 08             	mov    0x8(%ebp),%eax
  10566f:	ff d0                	call   *%eax
            break;
  105671:	e9 a4 02 00 00       	jmp    10591a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105676:	8b 45 14             	mov    0x14(%ebp),%eax
  105679:	8d 50 04             	lea    0x4(%eax),%edx
  10567c:	89 55 14             	mov    %edx,0x14(%ebp)
  10567f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105681:	85 db                	test   %ebx,%ebx
  105683:	79 02                	jns    105687 <vprintfmt+0x139>
                err = -err;
  105685:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105687:	83 fb 06             	cmp    $0x6,%ebx
  10568a:	7f 0b                	jg     105697 <vprintfmt+0x149>
  10568c:	8b 34 9d 80 70 10 00 	mov    0x107080(,%ebx,4),%esi
  105693:	85 f6                	test   %esi,%esi
  105695:	75 23                	jne    1056ba <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105697:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10569b:	c7 44 24 08 ad 70 10 	movl   $0x1070ad,0x8(%esp)
  1056a2:	00 
  1056a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1056ad:	89 04 24             	mov    %eax,(%esp)
  1056b0:	e8 68 fe ff ff       	call   10551d <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1056b5:	e9 60 02 00 00       	jmp    10591a <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  1056ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1056be:	c7 44 24 08 b6 70 10 	movl   $0x1070b6,0x8(%esp)
  1056c5:	00 
  1056c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1056d0:	89 04 24             	mov    %eax,(%esp)
  1056d3:	e8 45 fe ff ff       	call   10551d <printfmt>
            break;
  1056d8:	e9 3d 02 00 00       	jmp    10591a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1056dd:	8b 45 14             	mov    0x14(%ebp),%eax
  1056e0:	8d 50 04             	lea    0x4(%eax),%edx
  1056e3:	89 55 14             	mov    %edx,0x14(%ebp)
  1056e6:	8b 30                	mov    (%eax),%esi
  1056e8:	85 f6                	test   %esi,%esi
  1056ea:	75 05                	jne    1056f1 <vprintfmt+0x1a3>
                p = "(null)";
  1056ec:	be b9 70 10 00       	mov    $0x1070b9,%esi
            }
            if (width > 0 && padc != '-') {
  1056f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056f5:	7e 76                	jle    10576d <vprintfmt+0x21f>
  1056f7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1056fb:	74 70                	je     10576d <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1056fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105700:	89 44 24 04          	mov    %eax,0x4(%esp)
  105704:	89 34 24             	mov    %esi,(%esp)
  105707:	e8 16 03 00 00       	call   105a22 <strnlen>
  10570c:	89 c2                	mov    %eax,%edx
  10570e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105711:	29 d0                	sub    %edx,%eax
  105713:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105716:	eb 16                	jmp    10572e <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105718:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  10571c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10571f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105723:	89 04 24             	mov    %eax,(%esp)
  105726:	8b 45 08             	mov    0x8(%ebp),%eax
  105729:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  10572b:	ff 4d e8             	decl   -0x18(%ebp)
  10572e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105732:	7f e4                	jg     105718 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105734:	eb 37                	jmp    10576d <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105736:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10573a:	74 1f                	je     10575b <vprintfmt+0x20d>
  10573c:	83 fb 1f             	cmp    $0x1f,%ebx
  10573f:	7e 05                	jle    105746 <vprintfmt+0x1f8>
  105741:	83 fb 7e             	cmp    $0x7e,%ebx
  105744:	7e 15                	jle    10575b <vprintfmt+0x20d>
                    putch('?', putdat);
  105746:	8b 45 0c             	mov    0xc(%ebp),%eax
  105749:	89 44 24 04          	mov    %eax,0x4(%esp)
  10574d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105754:	8b 45 08             	mov    0x8(%ebp),%eax
  105757:	ff d0                	call   *%eax
  105759:	eb 0f                	jmp    10576a <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  10575b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10575e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105762:	89 1c 24             	mov    %ebx,(%esp)
  105765:	8b 45 08             	mov    0x8(%ebp),%eax
  105768:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10576a:	ff 4d e8             	decl   -0x18(%ebp)
  10576d:	89 f0                	mov    %esi,%eax
  10576f:	8d 70 01             	lea    0x1(%eax),%esi
  105772:	0f b6 00             	movzbl (%eax),%eax
  105775:	0f be d8             	movsbl %al,%ebx
  105778:	85 db                	test   %ebx,%ebx
  10577a:	74 27                	je     1057a3 <vprintfmt+0x255>
  10577c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105780:	78 b4                	js     105736 <vprintfmt+0x1e8>
  105782:	ff 4d e4             	decl   -0x1c(%ebp)
  105785:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105789:	79 ab                	jns    105736 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  10578b:	eb 16                	jmp    1057a3 <vprintfmt+0x255>
                putch(' ', putdat);
  10578d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105790:	89 44 24 04          	mov    %eax,0x4(%esp)
  105794:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10579b:	8b 45 08             	mov    0x8(%ebp),%eax
  10579e:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  1057a0:	ff 4d e8             	decl   -0x18(%ebp)
  1057a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057a7:	7f e4                	jg     10578d <vprintfmt+0x23f>
            }
            break;
  1057a9:	e9 6c 01 00 00       	jmp    10591a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1057ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057b5:	8d 45 14             	lea    0x14(%ebp),%eax
  1057b8:	89 04 24             	mov    %eax,(%esp)
  1057bb:	e8 16 fd ff ff       	call   1054d6 <getint>
  1057c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1057c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057cc:	85 d2                	test   %edx,%edx
  1057ce:	79 26                	jns    1057f6 <vprintfmt+0x2a8>
                putch('-', putdat);
  1057d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1057de:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e1:	ff d0                	call   *%eax
                num = -(long long)num;
  1057e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057e9:	f7 d8                	neg    %eax
  1057eb:	83 d2 00             	adc    $0x0,%edx
  1057ee:	f7 da                	neg    %edx
  1057f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1057f6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1057fd:	e9 a8 00 00 00       	jmp    1058aa <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105802:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105805:	89 44 24 04          	mov    %eax,0x4(%esp)
  105809:	8d 45 14             	lea    0x14(%ebp),%eax
  10580c:	89 04 24             	mov    %eax,(%esp)
  10580f:	e8 73 fc ff ff       	call   105487 <getuint>
  105814:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105817:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10581a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105821:	e9 84 00 00 00       	jmp    1058aa <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105826:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105829:	89 44 24 04          	mov    %eax,0x4(%esp)
  10582d:	8d 45 14             	lea    0x14(%ebp),%eax
  105830:	89 04 24             	mov    %eax,(%esp)
  105833:	e8 4f fc ff ff       	call   105487 <getuint>
  105838:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10583b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10583e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105845:	eb 63                	jmp    1058aa <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105847:	8b 45 0c             	mov    0xc(%ebp),%eax
  10584a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10584e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105855:	8b 45 08             	mov    0x8(%ebp),%eax
  105858:	ff d0                	call   *%eax
            putch('x', putdat);
  10585a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10585d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105861:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105868:	8b 45 08             	mov    0x8(%ebp),%eax
  10586b:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  10586d:	8b 45 14             	mov    0x14(%ebp),%eax
  105870:	8d 50 04             	lea    0x4(%eax),%edx
  105873:	89 55 14             	mov    %edx,0x14(%ebp)
  105876:	8b 00                	mov    (%eax),%eax
  105878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10587b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105882:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105889:	eb 1f                	jmp    1058aa <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10588b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10588e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105892:	8d 45 14             	lea    0x14(%ebp),%eax
  105895:	89 04 24             	mov    %eax,(%esp)
  105898:	e8 ea fb ff ff       	call   105487 <getuint>
  10589d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1058a3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1058aa:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1058ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058b1:	89 54 24 18          	mov    %edx,0x18(%esp)
  1058b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1058b8:	89 54 24 14          	mov    %edx,0x14(%esp)
  1058bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  1058c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1058ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1058d8:	89 04 24             	mov    %eax,(%esp)
  1058db:	e8 a5 fa ff ff       	call   105385 <printnum>
            break;
  1058e0:	eb 38                	jmp    10591a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1058e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058e9:	89 1c 24             	mov    %ebx,(%esp)
  1058ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1058ef:	ff d0                	call   *%eax
            break;
  1058f1:	eb 27                	jmp    10591a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1058f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105901:	8b 45 08             	mov    0x8(%ebp),%eax
  105904:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105906:	ff 4d 10             	decl   0x10(%ebp)
  105909:	eb 03                	jmp    10590e <vprintfmt+0x3c0>
  10590b:	ff 4d 10             	decl   0x10(%ebp)
  10590e:	8b 45 10             	mov    0x10(%ebp),%eax
  105911:	48                   	dec    %eax
  105912:	0f b6 00             	movzbl (%eax),%eax
  105915:	3c 25                	cmp    $0x25,%al
  105917:	75 f2                	jne    10590b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105919:	90                   	nop
    while (1) {
  10591a:	e9 37 fc ff ff       	jmp    105556 <vprintfmt+0x8>
                return;
  10591f:	90                   	nop
        }
    }
}
  105920:	83 c4 40             	add    $0x40,%esp
  105923:	5b                   	pop    %ebx
  105924:	5e                   	pop    %esi
  105925:	5d                   	pop    %ebp
  105926:	c3                   	ret    

00105927 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105927:	55                   	push   %ebp
  105928:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10592a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10592d:	8b 40 08             	mov    0x8(%eax),%eax
  105930:	8d 50 01             	lea    0x1(%eax),%edx
  105933:	8b 45 0c             	mov    0xc(%ebp),%eax
  105936:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105939:	8b 45 0c             	mov    0xc(%ebp),%eax
  10593c:	8b 10                	mov    (%eax),%edx
  10593e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105941:	8b 40 04             	mov    0x4(%eax),%eax
  105944:	39 c2                	cmp    %eax,%edx
  105946:	73 12                	jae    10595a <sprintputch+0x33>
        *b->buf ++ = ch;
  105948:	8b 45 0c             	mov    0xc(%ebp),%eax
  10594b:	8b 00                	mov    (%eax),%eax
  10594d:	8d 48 01             	lea    0x1(%eax),%ecx
  105950:	8b 55 0c             	mov    0xc(%ebp),%edx
  105953:	89 0a                	mov    %ecx,(%edx)
  105955:	8b 55 08             	mov    0x8(%ebp),%edx
  105958:	88 10                	mov    %dl,(%eax)
    }
}
  10595a:	90                   	nop
  10595b:	5d                   	pop    %ebp
  10595c:	c3                   	ret    

0010595d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10595d:	55                   	push   %ebp
  10595e:	89 e5                	mov    %esp,%ebp
  105960:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105963:	8d 45 14             	lea    0x14(%ebp),%eax
  105966:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10596c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105970:	8b 45 10             	mov    0x10(%ebp),%eax
  105973:	89 44 24 08          	mov    %eax,0x8(%esp)
  105977:	8b 45 0c             	mov    0xc(%ebp),%eax
  10597a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10597e:	8b 45 08             	mov    0x8(%ebp),%eax
  105981:	89 04 24             	mov    %eax,(%esp)
  105984:	e8 0a 00 00 00       	call   105993 <vsnprintf>
  105989:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10598f:	89 ec                	mov    %ebp,%esp
  105991:	5d                   	pop    %ebp
  105992:	c3                   	ret    

00105993 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105993:	55                   	push   %ebp
  105994:	89 e5                	mov    %esp,%ebp
  105996:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105999:	8b 45 08             	mov    0x8(%ebp),%eax
  10599c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10599f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059a2:	8d 50 ff             	lea    -0x1(%eax),%edx
  1059a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a8:	01 d0                	add    %edx,%eax
  1059aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1059b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1059b8:	74 0a                	je     1059c4 <vsnprintf+0x31>
  1059ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1059bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059c0:	39 c2                	cmp    %eax,%edx
  1059c2:	76 07                	jbe    1059cb <vsnprintf+0x38>
        return -E_INVAL;
  1059c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1059c9:	eb 2a                	jmp    1059f5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1059cb:	8b 45 14             	mov    0x14(%ebp),%eax
  1059ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1059d2:	8b 45 10             	mov    0x10(%ebp),%eax
  1059d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1059dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059e0:	c7 04 24 27 59 10 00 	movl   $0x105927,(%esp)
  1059e7:	e8 62 fb ff ff       	call   10554e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1059ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059ef:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1059f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1059f5:	89 ec                	mov    %ebp,%esp
  1059f7:	5d                   	pop    %ebp
  1059f8:	c3                   	ret    

001059f9 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1059f9:	55                   	push   %ebp
  1059fa:	89 e5                	mov    %esp,%ebp
  1059fc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1059ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105a06:	eb 03                	jmp    105a0b <strlen+0x12>
        cnt ++;
  105a08:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a0e:	8d 50 01             	lea    0x1(%eax),%edx
  105a11:	89 55 08             	mov    %edx,0x8(%ebp)
  105a14:	0f b6 00             	movzbl (%eax),%eax
  105a17:	84 c0                	test   %al,%al
  105a19:	75 ed                	jne    105a08 <strlen+0xf>
    }
    return cnt;
  105a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105a1e:	89 ec                	mov    %ebp,%esp
  105a20:	5d                   	pop    %ebp
  105a21:	c3                   	ret    

00105a22 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105a22:	55                   	push   %ebp
  105a23:	89 e5                	mov    %esp,%ebp
  105a25:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105a28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105a2f:	eb 03                	jmp    105a34 <strnlen+0x12>
        cnt ++;
  105a31:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a37:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105a3a:	73 10                	jae    105a4c <strnlen+0x2a>
  105a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105a3f:	8d 50 01             	lea    0x1(%eax),%edx
  105a42:	89 55 08             	mov    %edx,0x8(%ebp)
  105a45:	0f b6 00             	movzbl (%eax),%eax
  105a48:	84 c0                	test   %al,%al
  105a4a:	75 e5                	jne    105a31 <strnlen+0xf>
    }
    return cnt;
  105a4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105a4f:	89 ec                	mov    %ebp,%esp
  105a51:	5d                   	pop    %ebp
  105a52:	c3                   	ret    

00105a53 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105a53:	55                   	push   %ebp
  105a54:	89 e5                	mov    %esp,%ebp
  105a56:	57                   	push   %edi
  105a57:	56                   	push   %esi
  105a58:	83 ec 20             	sub    $0x20,%esp
  105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105a67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a6d:	89 d1                	mov    %edx,%ecx
  105a6f:	89 c2                	mov    %eax,%edx
  105a71:	89 ce                	mov    %ecx,%esi
  105a73:	89 d7                	mov    %edx,%edi
  105a75:	ac                   	lods   %ds:(%esi),%al
  105a76:	aa                   	stos   %al,%es:(%edi)
  105a77:	84 c0                	test   %al,%al
  105a79:	75 fa                	jne    105a75 <strcpy+0x22>
  105a7b:	89 fa                	mov    %edi,%edx
  105a7d:	89 f1                	mov    %esi,%ecx
  105a7f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105a82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105a8b:	83 c4 20             	add    $0x20,%esp
  105a8e:	5e                   	pop    %esi
  105a8f:	5f                   	pop    %edi
  105a90:	5d                   	pop    %ebp
  105a91:	c3                   	ret    

00105a92 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105a92:	55                   	push   %ebp
  105a93:	89 e5                	mov    %esp,%ebp
  105a95:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105a98:	8b 45 08             	mov    0x8(%ebp),%eax
  105a9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105a9e:	eb 1e                	jmp    105abe <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa3:	0f b6 10             	movzbl (%eax),%edx
  105aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105aa9:	88 10                	mov    %dl,(%eax)
  105aab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105aae:	0f b6 00             	movzbl (%eax),%eax
  105ab1:	84 c0                	test   %al,%al
  105ab3:	74 03                	je     105ab8 <strncpy+0x26>
            src ++;
  105ab5:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105ab8:	ff 45 fc             	incl   -0x4(%ebp)
  105abb:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  105abe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105ac2:	75 dc                	jne    105aa0 <strncpy+0xe>
    }
    return dst;
  105ac4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ac7:	89 ec                	mov    %ebp,%esp
  105ac9:	5d                   	pop    %ebp
  105aca:	c3                   	ret    

00105acb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105acb:	55                   	push   %ebp
  105acc:	89 e5                	mov    %esp,%ebp
  105ace:	57                   	push   %edi
  105acf:	56                   	push   %esi
  105ad0:	83 ec 20             	sub    $0x20,%esp
  105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ae5:	89 d1                	mov    %edx,%ecx
  105ae7:	89 c2                	mov    %eax,%edx
  105ae9:	89 ce                	mov    %ecx,%esi
  105aeb:	89 d7                	mov    %edx,%edi
  105aed:	ac                   	lods   %ds:(%esi),%al
  105aee:	ae                   	scas   %es:(%edi),%al
  105aef:	75 08                	jne    105af9 <strcmp+0x2e>
  105af1:	84 c0                	test   %al,%al
  105af3:	75 f8                	jne    105aed <strcmp+0x22>
  105af5:	31 c0                	xor    %eax,%eax
  105af7:	eb 04                	jmp    105afd <strcmp+0x32>
  105af9:	19 c0                	sbb    %eax,%eax
  105afb:	0c 01                	or     $0x1,%al
  105afd:	89 fa                	mov    %edi,%edx
  105aff:	89 f1                	mov    %esi,%ecx
  105b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105b04:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105b07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105b0d:	83 c4 20             	add    $0x20,%esp
  105b10:	5e                   	pop    %esi
  105b11:	5f                   	pop    %edi
  105b12:	5d                   	pop    %ebp
  105b13:	c3                   	ret    

00105b14 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105b14:	55                   	push   %ebp
  105b15:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105b17:	eb 09                	jmp    105b22 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105b19:	ff 4d 10             	decl   0x10(%ebp)
  105b1c:	ff 45 08             	incl   0x8(%ebp)
  105b1f:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105b22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b26:	74 1a                	je     105b42 <strncmp+0x2e>
  105b28:	8b 45 08             	mov    0x8(%ebp),%eax
  105b2b:	0f b6 00             	movzbl (%eax),%eax
  105b2e:	84 c0                	test   %al,%al
  105b30:	74 10                	je     105b42 <strncmp+0x2e>
  105b32:	8b 45 08             	mov    0x8(%ebp),%eax
  105b35:	0f b6 10             	movzbl (%eax),%edx
  105b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b3b:	0f b6 00             	movzbl (%eax),%eax
  105b3e:	38 c2                	cmp    %al,%dl
  105b40:	74 d7                	je     105b19 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105b42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b46:	74 18                	je     105b60 <strncmp+0x4c>
  105b48:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4b:	0f b6 00             	movzbl (%eax),%eax
  105b4e:	0f b6 d0             	movzbl %al,%edx
  105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b54:	0f b6 00             	movzbl (%eax),%eax
  105b57:	0f b6 c8             	movzbl %al,%ecx
  105b5a:	89 d0                	mov    %edx,%eax
  105b5c:	29 c8                	sub    %ecx,%eax
  105b5e:	eb 05                	jmp    105b65 <strncmp+0x51>
  105b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105b65:	5d                   	pop    %ebp
  105b66:	c3                   	ret    

00105b67 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105b67:	55                   	push   %ebp
  105b68:	89 e5                	mov    %esp,%ebp
  105b6a:	83 ec 04             	sub    $0x4,%esp
  105b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b70:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105b73:	eb 13                	jmp    105b88 <strchr+0x21>
        if (*s == c) {
  105b75:	8b 45 08             	mov    0x8(%ebp),%eax
  105b78:	0f b6 00             	movzbl (%eax),%eax
  105b7b:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105b7e:	75 05                	jne    105b85 <strchr+0x1e>
            return (char *)s;
  105b80:	8b 45 08             	mov    0x8(%ebp),%eax
  105b83:	eb 12                	jmp    105b97 <strchr+0x30>
        }
        s ++;
  105b85:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105b88:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8b:	0f b6 00             	movzbl (%eax),%eax
  105b8e:	84 c0                	test   %al,%al
  105b90:	75 e3                	jne    105b75 <strchr+0xe>
    }
    return NULL;
  105b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105b97:	89 ec                	mov    %ebp,%esp
  105b99:	5d                   	pop    %ebp
  105b9a:	c3                   	ret    

00105b9b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105b9b:	55                   	push   %ebp
  105b9c:	89 e5                	mov    %esp,%ebp
  105b9e:	83 ec 04             	sub    $0x4,%esp
  105ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ba4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ba7:	eb 0e                	jmp    105bb7 <strfind+0x1c>
        if (*s == c) {
  105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bac:	0f b6 00             	movzbl (%eax),%eax
  105baf:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105bb2:	74 0f                	je     105bc3 <strfind+0x28>
            break;
        }
        s ++;
  105bb4:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  105bba:	0f b6 00             	movzbl (%eax),%eax
  105bbd:	84 c0                	test   %al,%al
  105bbf:	75 e8                	jne    105ba9 <strfind+0xe>
  105bc1:	eb 01                	jmp    105bc4 <strfind+0x29>
            break;
  105bc3:	90                   	nop
    }
    return (char *)s;
  105bc4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105bc7:	89 ec                	mov    %ebp,%esp
  105bc9:	5d                   	pop    %ebp
  105bca:	c3                   	ret    

00105bcb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105bcb:	55                   	push   %ebp
  105bcc:	89 e5                	mov    %esp,%ebp
  105bce:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105bd8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105bdf:	eb 03                	jmp    105be4 <strtol+0x19>
        s ++;
  105be1:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105be4:	8b 45 08             	mov    0x8(%ebp),%eax
  105be7:	0f b6 00             	movzbl (%eax),%eax
  105bea:	3c 20                	cmp    $0x20,%al
  105bec:	74 f3                	je     105be1 <strtol+0x16>
  105bee:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf1:	0f b6 00             	movzbl (%eax),%eax
  105bf4:	3c 09                	cmp    $0x9,%al
  105bf6:	74 e9                	je     105be1 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfb:	0f b6 00             	movzbl (%eax),%eax
  105bfe:	3c 2b                	cmp    $0x2b,%al
  105c00:	75 05                	jne    105c07 <strtol+0x3c>
        s ++;
  105c02:	ff 45 08             	incl   0x8(%ebp)
  105c05:	eb 14                	jmp    105c1b <strtol+0x50>
    }
    else if (*s == '-') {
  105c07:	8b 45 08             	mov    0x8(%ebp),%eax
  105c0a:	0f b6 00             	movzbl (%eax),%eax
  105c0d:	3c 2d                	cmp    $0x2d,%al
  105c0f:	75 0a                	jne    105c1b <strtol+0x50>
        s ++, neg = 1;
  105c11:	ff 45 08             	incl   0x8(%ebp)
  105c14:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105c1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c1f:	74 06                	je     105c27 <strtol+0x5c>
  105c21:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105c25:	75 22                	jne    105c49 <strtol+0x7e>
  105c27:	8b 45 08             	mov    0x8(%ebp),%eax
  105c2a:	0f b6 00             	movzbl (%eax),%eax
  105c2d:	3c 30                	cmp    $0x30,%al
  105c2f:	75 18                	jne    105c49 <strtol+0x7e>
  105c31:	8b 45 08             	mov    0x8(%ebp),%eax
  105c34:	40                   	inc    %eax
  105c35:	0f b6 00             	movzbl (%eax),%eax
  105c38:	3c 78                	cmp    $0x78,%al
  105c3a:	75 0d                	jne    105c49 <strtol+0x7e>
        s += 2, base = 16;
  105c3c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105c40:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105c47:	eb 29                	jmp    105c72 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105c49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c4d:	75 16                	jne    105c65 <strtol+0x9a>
  105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c52:	0f b6 00             	movzbl (%eax),%eax
  105c55:	3c 30                	cmp    $0x30,%al
  105c57:	75 0c                	jne    105c65 <strtol+0x9a>
        s ++, base = 8;
  105c59:	ff 45 08             	incl   0x8(%ebp)
  105c5c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105c63:	eb 0d                	jmp    105c72 <strtol+0xa7>
    }
    else if (base == 0) {
  105c65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c69:	75 07                	jne    105c72 <strtol+0xa7>
        base = 10;
  105c6b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105c72:	8b 45 08             	mov    0x8(%ebp),%eax
  105c75:	0f b6 00             	movzbl (%eax),%eax
  105c78:	3c 2f                	cmp    $0x2f,%al
  105c7a:	7e 1b                	jle    105c97 <strtol+0xcc>
  105c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7f:	0f b6 00             	movzbl (%eax),%eax
  105c82:	3c 39                	cmp    $0x39,%al
  105c84:	7f 11                	jg     105c97 <strtol+0xcc>
            dig = *s - '0';
  105c86:	8b 45 08             	mov    0x8(%ebp),%eax
  105c89:	0f b6 00             	movzbl (%eax),%eax
  105c8c:	0f be c0             	movsbl %al,%eax
  105c8f:	83 e8 30             	sub    $0x30,%eax
  105c92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c95:	eb 48                	jmp    105cdf <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105c97:	8b 45 08             	mov    0x8(%ebp),%eax
  105c9a:	0f b6 00             	movzbl (%eax),%eax
  105c9d:	3c 60                	cmp    $0x60,%al
  105c9f:	7e 1b                	jle    105cbc <strtol+0xf1>
  105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ca4:	0f b6 00             	movzbl (%eax),%eax
  105ca7:	3c 7a                	cmp    $0x7a,%al
  105ca9:	7f 11                	jg     105cbc <strtol+0xf1>
            dig = *s - 'a' + 10;
  105cab:	8b 45 08             	mov    0x8(%ebp),%eax
  105cae:	0f b6 00             	movzbl (%eax),%eax
  105cb1:	0f be c0             	movsbl %al,%eax
  105cb4:	83 e8 57             	sub    $0x57,%eax
  105cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105cba:	eb 23                	jmp    105cdf <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  105cbf:	0f b6 00             	movzbl (%eax),%eax
  105cc2:	3c 40                	cmp    $0x40,%al
  105cc4:	7e 3b                	jle    105d01 <strtol+0x136>
  105cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc9:	0f b6 00             	movzbl (%eax),%eax
  105ccc:	3c 5a                	cmp    $0x5a,%al
  105cce:	7f 31                	jg     105d01 <strtol+0x136>
            dig = *s - 'A' + 10;
  105cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd3:	0f b6 00             	movzbl (%eax),%eax
  105cd6:	0f be c0             	movsbl %al,%eax
  105cd9:	83 e8 37             	sub    $0x37,%eax
  105cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ce2:	3b 45 10             	cmp    0x10(%ebp),%eax
  105ce5:	7d 19                	jge    105d00 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105ce7:	ff 45 08             	incl   0x8(%ebp)
  105cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105ced:	0f af 45 10          	imul   0x10(%ebp),%eax
  105cf1:	89 c2                	mov    %eax,%edx
  105cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105cf6:	01 d0                	add    %edx,%eax
  105cf8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105cfb:	e9 72 ff ff ff       	jmp    105c72 <strtol+0xa7>
            break;
  105d00:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  105d01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105d05:	74 08                	je     105d0f <strtol+0x144>
        *endptr = (char *) s;
  105d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  105d0d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105d0f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105d13:	74 07                	je     105d1c <strtol+0x151>
  105d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105d18:	f7 d8                	neg    %eax
  105d1a:	eb 03                	jmp    105d1f <strtol+0x154>
  105d1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105d1f:	89 ec                	mov    %ebp,%esp
  105d21:	5d                   	pop    %ebp
  105d22:	c3                   	ret    

00105d23 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105d23:	55                   	push   %ebp
  105d24:	89 e5                	mov    %esp,%ebp
  105d26:	83 ec 28             	sub    $0x28,%esp
  105d29:	89 7d fc             	mov    %edi,-0x4(%ebp)
  105d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d2f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105d32:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  105d36:	8b 45 08             	mov    0x8(%ebp),%eax
  105d39:	89 45 f8             	mov    %eax,-0x8(%ebp)
  105d3c:	88 55 f7             	mov    %dl,-0x9(%ebp)
  105d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  105d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105d45:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105d48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105d4c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105d4f:	89 d7                	mov    %edx,%edi
  105d51:	f3 aa                	rep stos %al,%es:(%edi)
  105d53:	89 fa                	mov    %edi,%edx
  105d55:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105d58:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105d5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105d5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  105d61:	89 ec                	mov    %ebp,%esp
  105d63:	5d                   	pop    %ebp
  105d64:	c3                   	ret    

00105d65 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105d65:	55                   	push   %ebp
  105d66:	89 e5                	mov    %esp,%ebp
  105d68:	57                   	push   %edi
  105d69:	56                   	push   %esi
  105d6a:	53                   	push   %ebx
  105d6b:	83 ec 30             	sub    $0x30,%esp
  105d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105d7a:	8b 45 10             	mov    0x10(%ebp),%eax
  105d7d:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105d86:	73 42                	jae    105dca <memmove+0x65>
  105d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105d8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d97:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105d9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d9d:	c1 e8 02             	shr    $0x2,%eax
  105da0:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105da2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105da8:	89 d7                	mov    %edx,%edi
  105daa:	89 c6                	mov    %eax,%esi
  105dac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105dae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105db1:	83 e1 03             	and    $0x3,%ecx
  105db4:	74 02                	je     105db8 <memmove+0x53>
  105db6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105db8:	89 f0                	mov    %esi,%eax
  105dba:	89 fa                	mov    %edi,%edx
  105dbc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105dbf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105dc2:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  105dc8:	eb 36                	jmp    105e00 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105dca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105dcd:	8d 50 ff             	lea    -0x1(%eax),%edx
  105dd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105dd3:	01 c2                	add    %eax,%edx
  105dd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105dd8:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105dde:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105de4:	89 c1                	mov    %eax,%ecx
  105de6:	89 d8                	mov    %ebx,%eax
  105de8:	89 d6                	mov    %edx,%esi
  105dea:	89 c7                	mov    %eax,%edi
  105dec:	fd                   	std    
  105ded:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105def:	fc                   	cld    
  105df0:	89 f8                	mov    %edi,%eax
  105df2:	89 f2                	mov    %esi,%edx
  105df4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105df7:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105dfa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105e00:	83 c4 30             	add    $0x30,%esp
  105e03:	5b                   	pop    %ebx
  105e04:	5e                   	pop    %esi
  105e05:	5f                   	pop    %edi
  105e06:	5d                   	pop    %ebp
  105e07:	c3                   	ret    

00105e08 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105e08:	55                   	push   %ebp
  105e09:	89 e5                	mov    %esp,%ebp
  105e0b:	57                   	push   %edi
  105e0c:	56                   	push   %esi
  105e0d:	83 ec 20             	sub    $0x20,%esp
  105e10:	8b 45 08             	mov    0x8(%ebp),%eax
  105e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  105e1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e25:	c1 e8 02             	shr    $0x2,%eax
  105e28:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e30:	89 d7                	mov    %edx,%edi
  105e32:	89 c6                	mov    %eax,%esi
  105e34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105e36:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105e39:	83 e1 03             	and    $0x3,%ecx
  105e3c:	74 02                	je     105e40 <memcpy+0x38>
  105e3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e40:	89 f0                	mov    %esi,%eax
  105e42:	89 fa                	mov    %edi,%edx
  105e44:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105e47:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105e4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105e50:	83 c4 20             	add    $0x20,%esp
  105e53:	5e                   	pop    %esi
  105e54:	5f                   	pop    %edi
  105e55:	5d                   	pop    %ebp
  105e56:	c3                   	ret    

00105e57 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105e57:	55                   	push   %ebp
  105e58:	89 e5                	mov    %esp,%ebp
  105e5a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  105e60:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105e63:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e66:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105e69:	eb 2e                	jmp    105e99 <memcmp+0x42>
        if (*s1 != *s2) {
  105e6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105e6e:	0f b6 10             	movzbl (%eax),%edx
  105e71:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e74:	0f b6 00             	movzbl (%eax),%eax
  105e77:	38 c2                	cmp    %al,%dl
  105e79:	74 18                	je     105e93 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105e7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105e7e:	0f b6 00             	movzbl (%eax),%eax
  105e81:	0f b6 d0             	movzbl %al,%edx
  105e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e87:	0f b6 00             	movzbl (%eax),%eax
  105e8a:	0f b6 c8             	movzbl %al,%ecx
  105e8d:	89 d0                	mov    %edx,%eax
  105e8f:	29 c8                	sub    %ecx,%eax
  105e91:	eb 18                	jmp    105eab <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105e93:	ff 45 fc             	incl   -0x4(%ebp)
  105e96:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105e99:	8b 45 10             	mov    0x10(%ebp),%eax
  105e9c:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e9f:	89 55 10             	mov    %edx,0x10(%ebp)
  105ea2:	85 c0                	test   %eax,%eax
  105ea4:	75 c5                	jne    105e6b <memcmp+0x14>
    }
    return 0;
  105ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105eab:	89 ec                	mov    %ebp,%esp
  105ead:	5d                   	pop    %ebp
  105eae:	c3                   	ret    
