
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
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
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
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
  10003c:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  100041:	2d 36 9a 11 00       	sub    $0x119a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  100059:	e8 ba 5e 00 00       	call   105f18 <memset>

    cons_init();                // init the console
  10005e:	e8 ea 15 00 00       	call   10164d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 c0 60 10 00 	movl   $0x1060c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 dc 60 10 00 	movl   $0x1060dc,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management  完成物理内存管理
  100087:	e8 03 44 00 00       	call   10448f <pmm_init>

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
  10015a:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 e1 60 10 00 	movl   $0x1060e1,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 ef 60 10 00 	movl   $0x1060ef,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 fd 60 10 00 	movl   $0x1060fd,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 0b 61 10 00 	movl   $0x10610b,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 19 61 10 00 	movl   $0x106119,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
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
  100216:	c7 04 24 28 61 10 00 	movl   $0x106128,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 48 61 10 00 	movl   $0x106148,(%esp)
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
  10025a:	c7 04 24 67 61 10 00 	movl   $0x106167,(%esp)
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
  1002a8:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
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
  1002e6:	05 20 c0 11 00       	add    $0x11c020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 c0 11 00       	mov    $0x11c020,%eax
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
  10034a:	e8 f4 53 00 00       	call   105743 <vprintfmt>
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
  10055a:	c7 00 6c 61 10 00    	movl   $0x10616c,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 6c 61 10 00 	movl   $0x10616c,0x8(%eax)
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
  100591:	c7 45 f4 00 74 10 00 	movl   $0x107400,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 c0 2b 11 00 	movl   $0x112bc0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec c1 2b 11 00 	movl   $0x112bc1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 59 61 11 00 	movl   $0x116159,-0x18(%ebp)

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
  1006f9:	e8 92 56 00 00       	call   105d90 <strfind>
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
  10087f:	c7 04 24 76 61 10 00 	movl   $0x106176,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 8f 61 10 00 	movl   $0x10618f,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 a4 60 10 	movl   $0x1060a4,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 a7 61 10 00 	movl   $0x1061a7,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 bf 61 10 00 	movl   $0x1061bf,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 2c cf 11 	movl   $0x11cf2c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 d7 61 10 00 	movl   $0x1061d7,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 f0 61 10 00 	movl   $0x1061f0,(%esp)
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
  100933:	c7 04 24 1a 62 10 00 	movl   $0x10621a,(%esp)
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
  1009a1:	c7 04 24 36 62 10 00 	movl   $0x106236,(%esp)
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
  1009fb:	c7 04 24 48 62 10 00 	movl   $0x106248,(%esp)
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
  100a2e:	c7 04 24 60 62 10 00 	movl   $0x106260,(%esp)
  100a35:	e8 1c f9 ff ff       	call   100356 <cprintf>
        for (int j = 0; j < 4; j ++) {
  100a3a:	ff 45 e8             	incl   -0x18(%ebp)
  100a3d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a41:	7e d6                	jle    100a19 <print_stackframe+0x54>
        }
        
        cprintf("\n");
  100a43:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
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
  100ab5:	c7 04 24 ec 62 10 00 	movl   $0x1062ec,(%esp)
  100abc:	e8 9b 52 00 00       	call   105d5c <strchr>
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
  100add:	c7 04 24 f1 62 10 00 	movl   $0x1062f1,(%esp)
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
  100b1f:	c7 04 24 ec 62 10 00 	movl   $0x1062ec,(%esp)
  100b26:	e8 31 52 00 00       	call   105d5c <strchr>
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
  100b82:	05 00 90 11 00       	add    $0x119000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 2b 51 00 00       	call   105cc0 <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 31                	jne    100bca <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 08 90 11 00       	add    $0x119008,%eax
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
  100bdc:	c7 04 24 0f 63 10 00 	movl   $0x10630f,(%esp)
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
  100bfa:	c7 04 24 28 63 10 00 	movl   $0x106328,(%esp)
  100c01:	e8 50 f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c06:	c7 04 24 50 63 10 00 	movl   $0x106350,(%esp)
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
  100c23:	c7 04 24 75 63 10 00 	movl   $0x106375,(%esp)
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
  100c71:	05 04 90 11 00       	add    $0x119004,%eax
  100c76:	8b 10                	mov    (%eax),%edx
  100c78:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c7b:	89 c8                	mov    %ecx,%eax
  100c7d:	01 c0                	add    %eax,%eax
  100c7f:	01 c8                	add    %ecx,%eax
  100c81:	c1 e0 02             	shl    $0x2,%eax
  100c84:	05 00 90 11 00       	add    $0x119000,%eax
  100c89:	8b 00                	mov    (%eax),%eax
  100c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c93:	c7 04 24 79 63 10 00 	movl   $0x106379,(%esp)
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
  100ce1:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100ce6:	85 c0                	test   %eax,%eax
  100ce8:	75 5b                	jne    100d45 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cea:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
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
  100d08:	c7 04 24 82 63 10 00 	movl   $0x106382,(%esp)
  100d0f:	e8 42 f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  100d1e:	89 04 24             	mov    %eax,(%esp)
  100d21:	e8 fb f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d26:	c7 04 24 9e 63 10 00 	movl   $0x10639e,(%esp)
  100d2d:	e8 24 f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d32:	c7 04 24 a0 63 10 00 	movl   $0x1063a0,(%esp)
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
  100d73:	c7 04 24 b2 63 10 00 	movl   $0x1063b2,(%esp)
  100d7a:	e8 d7 f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d86:	8b 45 10             	mov    0x10(%ebp),%eax
  100d89:	89 04 24             	mov    %eax,(%esp)
  100d8c:	e8 90 f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d91:	c7 04 24 9e 63 10 00 	movl   $0x10639e,(%esp)
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
  100da5:	a1 20 c4 11 00       	mov    0x11c420,%eax
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
  100dee:	c7 05 24 c4 11 00 00 	movl   $0x0,0x11c424
  100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df8:	c7 04 24 d0 63 10 00 	movl   $0x1063d0,(%esp)
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
  100ed8:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100edf:	b4 03 
  100ee1:	eb 13                	jmp    100ef6 <cga_init+0x54>
    } else {
        *cp = was;
  100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eea:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100eed:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100ef4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ef6:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100efd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f01:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f05:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f09:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f0d:	ee                   	out    %al,(%dx)
}
  100f0e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f0f:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
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
  100f35:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f3c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f40:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f44:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f48:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f4c:	ee                   	out    %al,(%dx)
}
  100f4d:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f4e:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
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
  100f74:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7c:	0f b7 c0             	movzwl %ax,%eax
  100f7f:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
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
  101038:	a3 48 c4 11 00       	mov    %eax,0x11c448
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
  10105d:	a1 48 c4 11 00       	mov    0x11c448,%eax
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
  101176:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10117d:	85 c0                	test   %eax,%eax
  10117f:	0f 84 af 00 00 00    	je     101234 <cga_putc+0xfd>
            crt_pos --;
  101185:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10118c:	48                   	dec    %eax
  10118d:	0f b7 c0             	movzwl %ax,%eax
  101190:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101196:	8b 45 08             	mov    0x8(%ebp),%eax
  101199:	98                   	cwtl   
  10119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10119f:	98                   	cwtl   
  1011a0:	83 c8 20             	or     $0x20,%eax
  1011a3:	98                   	cwtl   
  1011a4:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011aa:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  1011b1:	01 d2                	add    %edx,%edx
  1011b3:	01 ca                	add    %ecx,%edx
  1011b5:	0f b7 c0             	movzwl %ax,%eax
  1011b8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011bb:	eb 77                	jmp    101234 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011bd:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011c4:	83 c0 50             	add    $0x50,%eax
  1011c7:	0f b7 c0             	movzwl %ax,%eax
  1011ca:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011d0:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  1011d7:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
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
  101202:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  101208:	eb 2b                	jmp    101235 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10120a:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  101210:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101217:	8d 50 01             	lea    0x1(%eax),%edx
  10121a:	0f b7 d2             	movzwl %dx,%edx
  10121d:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
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
  101235:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10123c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101241:	76 5e                	jbe    1012a1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101243:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101248:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10124e:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101253:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10125a:	00 
  10125b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10125f:	89 04 24             	mov    %eax,(%esp)
  101262:	e8 f3 4c 00 00       	call   105f5a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101267:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10126e:	eb 15                	jmp    101285 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101270:	8b 15 40 c4 11 00    	mov    0x11c440,%edx
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
  10128e:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101295:	83 e8 50             	sub    $0x50,%eax
  101298:	0f b7 c0             	movzwl %ax,%eax
  10129b:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012a1:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012a8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012ac:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
}
  1012b9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012ba:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012c1:	c1 e8 08             	shr    $0x8,%eax
  1012c4:	0f b7 c0             	movzwl %ax,%eax
  1012c7:	0f b6 c0             	movzbl %al,%eax
  1012ca:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
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
  1012e6:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012ed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012f1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012fd:	ee                   	out    %al,(%dx)
}
  1012fe:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012ff:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101306:	0f b6 c0             	movzbl %al,%eax
  101309:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
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
  1013d9:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1013de:	8d 50 01             	lea    0x1(%eax),%edx
  1013e1:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  1013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013ea:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013f0:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1013f5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013fa:	75 0a                	jne    101406 <cons_intr+0x3b>
                cons.wpos = 0;
  1013fc:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
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
  101479:	a1 48 c4 11 00       	mov    0x11c448,%eax
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
  1014dc:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014e1:	83 c8 40             	or     $0x40,%eax
  1014e4:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ee:	e9 23 01 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f7:	84 c0                	test   %al,%al
  1014f9:	79 45                	jns    101540 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014fb:	a1 68 c6 11 00       	mov    0x11c668,%eax
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
  10151a:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101521:	0c 40                	or     $0x40,%al
  101523:	0f b6 c0             	movzbl %al,%eax
  101526:	f7 d0                	not    %eax
  101528:	89 c2                	mov    %eax,%edx
  10152a:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10152f:	21 d0                	and    %edx,%eax
  101531:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  101536:	b8 00 00 00 00       	mov    $0x0,%eax
  10153b:	e9 d6 00 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101540:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101545:	83 e0 40             	and    $0x40,%eax
  101548:	85 c0                	test   %eax,%eax
  10154a:	74 11                	je     10155d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10154c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101550:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101555:	83 e0 bf             	and    $0xffffffbf,%eax
  101558:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  10155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101561:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101568:	0f b6 d0             	movzbl %al,%edx
  10156b:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101570:	09 d0                	or     %edx,%eax
  101572:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10157b:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  101582:	0f b6 d0             	movzbl %al,%edx
  101585:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10158a:	31 d0                	xor    %edx,%eax
  10158c:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  101591:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101596:	83 e0 03             	and    $0x3,%eax
  101599:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  1015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a4:	01 d0                	add    %edx,%eax
  1015a6:	0f b6 00             	movzbl (%eax),%eax
  1015a9:	0f b6 c0             	movzbl %al,%eax
  1015ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015af:	a1 68 c6 11 00       	mov    0x11c668,%eax
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
  1015dd:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015e2:	f7 d0                	not    %eax
  1015e4:	83 e0 06             	and    $0x6,%eax
  1015e7:	85 c0                	test   %eax,%eax
  1015e9:	75 28                	jne    101613 <kbd_proc_data+0x180>
  1015eb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015f2:	75 1f                	jne    101613 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015f4:	c7 04 24 eb 63 10 00 	movl   $0x1063eb,(%esp)
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
  101662:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101667:	85 c0                	test   %eax,%eax
  101669:	75 0c                	jne    101677 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10166b:	c7 04 24 f7 63 10 00 	movl   $0x1063f7,(%esp)
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
  1016da:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  1016e0:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1016e5:	39 c2                	cmp    %eax,%edx
  1016e7:	74 31                	je     10171a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016e9:	a1 60 c6 11 00       	mov    0x11c660,%eax
  1016ee:	8d 50 01             	lea    0x1(%eax),%edx
  1016f1:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  1016f7:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  1016fe:	0f b6 c0             	movzbl %al,%eax
  101701:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101704:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101709:	3d 00 02 00 00       	cmp    $0x200,%eax
  10170e:	75 0a                	jne    10171a <cons_getc+0x5f>
                cons.rpos = 0;
  101710:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
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
  10174c:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  101752:	a1 6c c6 11 00       	mov    0x11c66c,%eax
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
  1017b3:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
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
  1017d4:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
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
  1018f6:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1018fd:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101902:	74 0f                	je     101913 <pic_init+0x145>
        pic_setmask(irq_mask);
  101904:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
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
  101926:	c7 04 24 20 64 10 00 	movl   $0x106420,(%esp)
  10192d:	e8 24 ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101932:	c7 04 24 2a 64 10 00 	movl   $0x10642a,(%esp)
  101939:	e8 18 ea ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  10193e:	c7 44 24 08 38 64 10 	movl   $0x106438,0x8(%esp)
  101945:	00 
  101946:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  10194d:	00 
  10194e:	c7 04 24 4e 64 10 00 	movl   $0x10644e,(%esp)
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
  10196f:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 80 c6 11 	mov    %dx,0x11c680(,%eax,8)
  101983:	00 
  101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101987:	66 c7 04 c5 82 c6 11 	movw   $0x8,0x11c682(,%eax,8)
  10198e:	00 08 00 
  101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101994:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  10199b:	00 
  10199c:	80 e2 e0             	and    $0xe0,%dl
  10199f:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  1019a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a9:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  1019b0:	00 
  1019b1:	80 e2 1f             	and    $0x1f,%dl
  1019b4:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  1019c5:	00 
  1019c6:	80 e2 f0             	and    $0xf0,%dl
  1019c9:	80 ca 0e             	or     $0xe,%dl
  1019cc:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  1019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d6:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  1019dd:	00 
  1019de:	80 e2 ef             	and    $0xef,%dl
  1019e1:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  1019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019eb:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  1019f2:	00 
  1019f3:	80 e2 9f             	and    $0x9f,%dl
  1019f6:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  1019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a00:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a07:	00 
  101a08:	80 ca 80             	or     $0x80,%dl
  101a0b:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a15:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101a1c:	c1 e8 10             	shr    $0x10,%eax
  101a1f:	0f b7 d0             	movzwl %ax,%edx
  101a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a25:	66 89 14 c5 86 c6 11 	mov    %dx,0x11c686(,%eax,8)
  101a2c:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) { //IDT表项的个数
  101a2d:	ff 45 fc             	incl   -0x4(%ebp)
  101a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a33:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a38:	0f 86 2e ff ff ff    	jbe    10196c <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,     
  101a3e:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101a43:	0f b7 c0             	movzwl %ax,%eax
  101a46:	66 a3 48 ca 11 00    	mov    %ax,0x11ca48
  101a4c:	66 c7 05 4a ca 11 00 	movw   $0x8,0x11ca4a
  101a53:	08 00 
  101a55:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101a5c:	24 e0                	and    $0xe0,%al
  101a5e:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101a63:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101a6a:	24 1f                	and    $0x1f,%al
  101a6c:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101a71:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a78:	24 f0                	and    $0xf0,%al
  101a7a:	0c 0e                	or     $0xe,%al
  101a7c:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a81:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a88:	24 ef                	and    $0xef,%al
  101a8a:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a8f:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a96:	0c 60                	or     $0x60,%al
  101a98:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a9d:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101aa4:	0c 80                	or     $0x80,%al
  101aa6:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101aab:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101ab0:	c1 e8 10             	shr    $0x10,%eax
  101ab3:	0f b7 c0             	movzwl %ax,%eax
  101ab6:	66 a3 4e ca 11 00    	mov    %ax,0x11ca4e
  101abc:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
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
  101add:	8b 04 85 a0 67 10 00 	mov    0x1067a0(,%eax,4),%eax
  101ae4:	eb 18                	jmp    101afe <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ae6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101aea:	7e 0d                	jle    101af9 <trapname+0x2a>
  101aec:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101af0:	7f 07                	jg     101af9 <trapname+0x2a>
        return "Hardware Interrupt";
  101af2:	b8 5f 64 10 00       	mov    $0x10645f,%eax
  101af7:	eb 05                	jmp    101afe <trapname+0x2f>
    }
    return "(unknown trap)";
  101af9:	b8 72 64 10 00       	mov    $0x106472,%eax
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
  101b22:	c7 04 24 b3 64 10 00 	movl   $0x1064b3,(%esp)
  101b29:	e8 28 e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b31:	89 04 24             	mov    %eax,(%esp)
  101b34:	e8 8f 01 00 00       	call   101cc8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b39:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b44:	c7 04 24 c4 64 10 00 	movl   $0x1064c4,(%esp)
  101b4b:	e8 06 e8 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b50:	8b 45 08             	mov    0x8(%ebp),%eax
  101b53:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5b:	c7 04 24 d7 64 10 00 	movl   $0x1064d7,(%esp)
  101b62:	e8 ef e7 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b72:	c7 04 24 ea 64 10 00 	movl   $0x1064ea,(%esp)
  101b79:	e8 d8 e7 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b81:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b89:	c7 04 24 fd 64 10 00 	movl   $0x1064fd,(%esp)
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
  101bb1:	c7 04 24 10 65 10 00 	movl   $0x106510,(%esp)
  101bb8:	e8 99 e7 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc0:	8b 40 34             	mov    0x34(%eax),%eax
  101bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc7:	c7 04 24 22 65 10 00 	movl   $0x106522,(%esp)
  101bce:	e8 83 e7 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd6:	8b 40 38             	mov    0x38(%eax),%eax
  101bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdd:	c7 04 24 31 65 10 00 	movl   $0x106531,(%esp)
  101be4:	e8 6d e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101be9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf4:	c7 04 24 40 65 10 00 	movl   $0x106540,(%esp)
  101bfb:	e8 56 e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c00:	8b 45 08             	mov    0x8(%ebp),%eax
  101c03:	8b 40 40             	mov    0x40(%eax),%eax
  101c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0a:	c7 04 24 53 65 10 00 	movl   $0x106553,(%esp)
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
  101c38:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c3f:	85 c0                	test   %eax,%eax
  101c41:	74 1a                	je     101c5d <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c46:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c51:	c7 04 24 62 65 10 00 	movl   $0x106562,(%esp)
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
  101c7b:	c7 04 24 66 65 10 00 	movl   $0x106566,(%esp)
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
  101ca0:	c7 04 24 6f 65 10 00 	movl   $0x10656f,(%esp)
  101ca7:	e8 aa e6 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101cac:	8b 45 08             	mov    0x8(%ebp),%eax
  101caf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb7:	c7 04 24 7e 65 10 00 	movl   $0x10657e,(%esp)
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
  101cd7:	c7 04 24 91 65 10 00 	movl   $0x106591,(%esp)
  101cde:	e8 73 e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce6:	8b 40 04             	mov    0x4(%eax),%eax
  101ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ced:	c7 04 24 a0 65 10 00 	movl   $0x1065a0,(%esp)
  101cf4:	e8 5d e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cfc:	8b 40 08             	mov    0x8(%eax),%eax
  101cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d03:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
  101d0a:	e8 47 e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d12:	8b 40 0c             	mov    0xc(%eax),%eax
  101d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d19:	c7 04 24 be 65 10 00 	movl   $0x1065be,(%esp)
  101d20:	e8 31 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d25:	8b 45 08             	mov    0x8(%ebp),%eax
  101d28:	8b 40 10             	mov    0x10(%eax),%eax
  101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d2f:	c7 04 24 cd 65 10 00 	movl   $0x1065cd,(%esp)
  101d36:	e8 1b e6 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3e:	8b 40 14             	mov    0x14(%eax),%eax
  101d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d45:	c7 04 24 dc 65 10 00 	movl   $0x1065dc,(%esp)
  101d4c:	e8 05 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d51:	8b 45 08             	mov    0x8(%ebp),%eax
  101d54:	8b 40 18             	mov    0x18(%eax),%eax
  101d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d5b:	c7 04 24 eb 65 10 00 	movl   $0x1065eb,(%esp)
  101d62:	e8 ef e5 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d67:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6a:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d71:	c7 04 24 fa 65 10 00 	movl   $0x1065fa,(%esp)
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
  101dcf:	a1 24 c4 11 00       	mov    0x11c424,%eax
  101dd4:	40                   	inc    %eax
  101dd5:	a3 24 c4 11 00       	mov    %eax,0x11c424
        if (ticks % TICK_NUM == 0) {
  101dda:	8b 0d 24 c4 11 00    	mov    0x11c424,%ecx
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
  101e2d:	c7 04 24 09 66 10 00 	movl   $0x106609,(%esp)
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
  101e53:	c7 04 24 1b 66 10 00 	movl   $0x10661b,(%esp)
  101e5a:	e8 f7 e4 ff ff       	call   100356 <cprintf>
        break;
  101e5f:	eb 55                	jmp    101eb6 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101e61:	c7 44 24 08 2a 66 10 	movl   $0x10662a,0x8(%esp)
  101e68:	00 
  101e69:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  101e70:	00 
  101e71:	c7 04 24 4e 64 10 00 	movl   $0x10644e,(%esp)
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
  101e96:	c7 44 24 08 3a 66 10 	movl   $0x10663a,0x8(%esp)
  101e9d:	00 
  101e9e:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
  101ea5:	00 
  101ea6:	c7 04 24 4e 64 10 00 	movl   $0x10644e,(%esp)
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
  102968:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
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
  1029b4:	c7 45 fc 80 ce 11 00 	movl   $0x11ce80,-0x4(%ebp)
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
  1029d0:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
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
  1029eb:	c7 44 24 0c f0 67 10 	movl   $0x1067f0,0xc(%esp)
  1029f2:	00 
  1029f3:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1029fa:	00 
  1029fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102a02:	00 
  102a03:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
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
  102a43:	c7 44 24 0c 21 68 10 	movl   $0x106821,0xc(%esp)
  102a4a:	00 
  102a4b:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  102a52:	00 
  102a53:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102a5a:	00 
  102a5b:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
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
  102ad4:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  102ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  102add:	01 d0                	add    %edx,%eax
  102adf:	a3 88 ce 11 00       	mov    %eax,0x11ce88
    list_add(&free_list, &(base->page_link));
  102ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae7:	83 c0 0c             	add    $0xc,%eax
  102aea:	c7 45 e4 80 ce 11 00 	movl   $0x11ce80,-0x1c(%ebp)
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
  102b4d:	c7 44 24 0c f0 67 10 	movl   $0x1067f0,0xc(%esp)
  102b54:	00 
  102b55:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  102b5c:	00 
  102b5d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102b64:	00 
  102b65:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  102b6c:	e8 6a e1 ff ff       	call   100cdb <__panic>
    if (n > nr_free) {
  102b71:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102b76:	39 45 08             	cmp    %eax,0x8(%ebp)
  102b79:	76 0a                	jbe    102b85 <default_alloc_pages+0x44>
        return NULL;
  102b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  102b80:	e9 43 01 00 00       	jmp    102cc8 <default_alloc_pages+0x187>
    }
    struct Page *page = NULL;
  102b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102b8c:	c7 45 f0 80 ce 11 00 	movl   $0x11ce80,-0x10(%ebp)
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
  102bc0:	81 7d f0 80 ce 11 00 	cmpl   $0x11ce80,-0x10(%ebp)
  102bc7:	75 cc                	jne    102b95 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  102bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102bcd:	0f 84 f2 00 00 00    	je     102cc5 <default_alloc_pages+0x184>
        //list_del(&(page->page_link));
        if (page->property > n) {
  102bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bd6:	8b 40 08             	mov    0x8(%eax),%eax
  102bd9:	39 45 08             	cmp    %eax,0x8(%ebp)
  102bdc:	0f 83 8f 00 00 00    	jae    102c71 <default_alloc_pages+0x130>
            struct Page *p = page + n;
  102be2:	8b 55 08             	mov    0x8(%ebp),%edx
  102be5:	89 d0                	mov    %edx,%eax
  102be7:	c1 e0 02             	shl    $0x2,%eax
  102bea:	01 d0                	add    %edx,%eax
  102bec:	c1 e0 02             	shl    $0x2,%eax
  102bef:	89 c2                	mov    %eax,%edx
  102bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bf4:	01 d0                	add    %edx,%eax
  102bf6:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    //do
            p->property = page->property - n;
  102bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bfc:	8b 40 08             	mov    0x8(%eax),%eax
  102bff:	2b 45 08             	sub    0x8(%ebp),%eax
  102c02:	89 c2                	mov    %eax,%edx
  102c04:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c07:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102c0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c0d:	83 c0 04             	add    $0x4,%eax
  102c10:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  102c17:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c1a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102c1d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102c20:	0f ab 10             	bts    %edx,(%eax)
}
  102c23:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
  102c24:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c27:	83 c0 0c             	add    $0xc,%eax
  102c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c2d:	83 c2 0c             	add    $0xc,%edx
  102c30:	89 55 e0             	mov    %edx,-0x20(%ebp)
  102c33:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
  102c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102c39:	8b 40 04             	mov    0x4(%eax),%eax
  102c3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c3f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102c42:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c45:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102c48:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
  102c4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c4e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102c51:	89 10                	mov    %edx,(%eax)
  102c53:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c56:	8b 10                	mov    (%eax),%edx
  102c58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102c5b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102c5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102c61:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102c64:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102c67:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102c6a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102c6d:	89 10                	mov    %edx,(%eax)
}
  102c6f:	90                   	nop
}
  102c70:	90                   	nop
        }
        list_del(&(page->page_link));
  102c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c74:	83 c0 0c             	add    $0xc,%eax
  102c77:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
  102c7a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c7d:	8b 40 04             	mov    0x4(%eax),%eax
  102c80:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102c83:	8b 12                	mov    (%edx),%edx
  102c85:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102c88:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102c8b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102c8e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102c91:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102c94:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102c97:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102c9a:	89 10                	mov    %edx,(%eax)
}
  102c9c:	90                   	nop
}
  102c9d:	90                   	nop
        nr_free -= n;
  102c9e:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102ca3:	2b 45 08             	sub    0x8(%ebp),%eax
  102ca6:	a3 88 ce 11 00       	mov    %eax,0x11ce88
        ClearPageProperty(page);
  102cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cae:	83 c0 04             	add    $0x4,%eax
  102cb1:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102cb8:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cbb:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102cbe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102cc1:	0f b3 10             	btr    %edx,(%eax)
}
  102cc4:	90                   	nop
    }
    return page;
  102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102cc8:	89 ec                	mov    %ebp,%esp
  102cca:	5d                   	pop    %ebp
  102ccb:	c3                   	ret    

00102ccc <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102ccc:	55                   	push   %ebp
  102ccd:	89 e5                	mov    %esp,%ebp
  102ccf:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102cd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102cd9:	75 24                	jne    102cff <default_free_pages+0x33>
  102cdb:	c7 44 24 0c f0 67 10 	movl   $0x1067f0,0xc(%esp)
  102ce2:	00 
  102ce3:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  102cea:	00 
  102ceb:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  102cf2:	00 
  102cf3:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  102cfa:	e8 dc df ff ff       	call   100cdb <__panic>
    struct Page *p = base;
  102cff:	8b 45 08             	mov    0x8(%ebp),%eax
  102d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102d05:	e9 9d 00 00 00       	jmp    102da7 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d0d:	83 c0 04             	add    $0x4,%eax
  102d10:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102d17:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d1d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102d20:	0f a3 10             	bt     %edx,(%eax)
  102d23:	19 c0                	sbb    %eax,%eax
  102d25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102d28:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d2c:	0f 95 c0             	setne  %al
  102d2f:	0f b6 c0             	movzbl %al,%eax
  102d32:	85 c0                	test   %eax,%eax
  102d34:	75 2c                	jne    102d62 <default_free_pages+0x96>
  102d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d39:	83 c0 04             	add    $0x4,%eax
  102d3c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102d43:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d46:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d49:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102d4c:	0f a3 10             	bt     %edx,(%eax)
  102d4f:	19 c0                	sbb    %eax,%eax
  102d51:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102d54:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102d58:	0f 95 c0             	setne  %al
  102d5b:	0f b6 c0             	movzbl %al,%eax
  102d5e:	85 c0                	test   %eax,%eax
  102d60:	74 24                	je     102d86 <default_free_pages+0xba>
  102d62:	c7 44 24 0c 34 68 10 	movl   $0x106834,0xc(%esp)
  102d69:	00 
  102d6a:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  102d71:	00 
  102d72:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  102d79:	00 
  102d7a:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  102d81:	e8 55 df ff ff       	call   100cdb <__panic>
        p->flags = 0;
  102d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d89:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102d90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d97:	00 
  102d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d9b:	89 04 24             	mov    %eax,(%esp)
  102d9e:	e8 fd fb ff ff       	call   1029a0 <set_page_ref>
    for (; p != base + n; p ++) {
  102da3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102daa:	89 d0                	mov    %edx,%eax
  102dac:	c1 e0 02             	shl    $0x2,%eax
  102daf:	01 d0                	add    %edx,%eax
  102db1:	c1 e0 02             	shl    $0x2,%eax
  102db4:	89 c2                	mov    %eax,%edx
  102db6:	8b 45 08             	mov    0x8(%ebp),%eax
  102db9:	01 d0                	add    %edx,%eax
  102dbb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102dbe:	0f 85 46 ff ff ff    	jne    102d0a <default_free_pages+0x3e>
    }
    base->property = n;
  102dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dca:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd0:	83 c0 04             	add    $0x4,%eax
  102dd3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102dda:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ddd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102de0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102de3:	0f ab 10             	bts    %edx,(%eax)
}
  102de6:	90                   	nop
  102de7:	c7 45 d4 80 ce 11 00 	movl   $0x11ce80,-0x2c(%ebp)
    return listelm->next;
  102dee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102df1:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102df7:	e9 0e 01 00 00       	jmp    102f0a <default_free_pages+0x23e>
        p = le2page(le, page_link);
  102dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102dff:	83 e8 0c             	sub    $0xc,%eax
  102e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e08:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102e0b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102e0e:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102e11:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  102e14:	8b 45 08             	mov    0x8(%ebp),%eax
  102e17:	8b 50 08             	mov    0x8(%eax),%edx
  102e1a:	89 d0                	mov    %edx,%eax
  102e1c:	c1 e0 02             	shl    $0x2,%eax
  102e1f:	01 d0                	add    %edx,%eax
  102e21:	c1 e0 02             	shl    $0x2,%eax
  102e24:	89 c2                	mov    %eax,%edx
  102e26:	8b 45 08             	mov    0x8(%ebp),%eax
  102e29:	01 d0                	add    %edx,%eax
  102e2b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102e2e:	75 5d                	jne    102e8d <default_free_pages+0x1c1>
            base->property += p->property;
  102e30:	8b 45 08             	mov    0x8(%ebp),%eax
  102e33:	8b 50 08             	mov    0x8(%eax),%edx
  102e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e39:	8b 40 08             	mov    0x8(%eax),%eax
  102e3c:	01 c2                	add    %eax,%edx
  102e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  102e41:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e47:	83 c0 04             	add    $0x4,%eax
  102e4a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102e51:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e54:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102e57:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102e5a:	0f b3 10             	btr    %edx,(%eax)
}
  102e5d:	90                   	nop
            list_del(&(p->page_link));
  102e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e61:	83 c0 0c             	add    $0xc,%eax
  102e64:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102e67:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102e6a:	8b 40 04             	mov    0x4(%eax),%eax
  102e6d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102e70:	8b 12                	mov    (%edx),%edx
  102e72:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102e75:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  102e78:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e7b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102e7e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102e81:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e84:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102e87:	89 10                	mov    %edx,(%eax)
}
  102e89:	90                   	nop
}
  102e8a:	90                   	nop
  102e8b:	eb 7d                	jmp    102f0a <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
  102e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e90:	8b 50 08             	mov    0x8(%eax),%edx
  102e93:	89 d0                	mov    %edx,%eax
  102e95:	c1 e0 02             	shl    $0x2,%eax
  102e98:	01 d0                	add    %edx,%eax
  102e9a:	c1 e0 02             	shl    $0x2,%eax
  102e9d:	89 c2                	mov    %eax,%edx
  102e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ea2:	01 d0                	add    %edx,%eax
  102ea4:	39 45 08             	cmp    %eax,0x8(%ebp)
  102ea7:	75 61                	jne    102f0a <default_free_pages+0x23e>
            p->property += base->property;
  102ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eac:	8b 50 08             	mov    0x8(%eax),%edx
  102eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  102eb2:	8b 40 08             	mov    0x8(%eax),%eax
  102eb5:	01 c2                	add    %eax,%edx
  102eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eba:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec0:	83 c0 04             	add    $0x4,%eax
  102ec3:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  102eca:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ecd:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ed0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ed3:	0f b3 10             	btr    %edx,(%eax)
}
  102ed6:	90                   	nop
            base = p;
  102ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eda:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ee0:	83 c0 0c             	add    $0xc,%eax
  102ee3:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  102ee6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102ee9:	8b 40 04             	mov    0x4(%eax),%eax
  102eec:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102eef:	8b 12                	mov    (%edx),%edx
  102ef1:	89 55 ac             	mov    %edx,-0x54(%ebp)
  102ef4:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  102ef7:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102efa:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102efd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102f00:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f03:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102f06:	89 10                	mov    %edx,(%eax)
}
  102f08:	90                   	nop
}
  102f09:	90                   	nop
    while (le != &free_list) {
  102f0a:	81 7d f0 80 ce 11 00 	cmpl   $0x11ce80,-0x10(%ebp)
  102f11:	0f 85 e5 fe ff ff    	jne    102dfc <default_free_pages+0x130>
        }
    }
    nr_free += n;
  102f17:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  102f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f20:	01 d0                	add    %edx,%eax
  102f22:	a3 88 ce 11 00       	mov    %eax,0x11ce88
  102f27:	c7 45 9c 80 ce 11 00 	movl   $0x11ce80,-0x64(%ebp)
    return listelm->next;
  102f2e:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f31:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  102f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102f37:	eb 74                	jmp    102fad <default_free_pages+0x2e1>
        p = le2page(le, page_link);
  102f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f3c:	83 e8 0c             	sub    $0xc,%eax
  102f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102f42:	8b 45 08             	mov    0x8(%ebp),%eax
  102f45:	8b 50 08             	mov    0x8(%eax),%edx
  102f48:	89 d0                	mov    %edx,%eax
  102f4a:	c1 e0 02             	shl    $0x2,%eax
  102f4d:	01 d0                	add    %edx,%eax
  102f4f:	c1 e0 02             	shl    $0x2,%eax
  102f52:	89 c2                	mov    %eax,%edx
  102f54:	8b 45 08             	mov    0x8(%ebp),%eax
  102f57:	01 d0                	add    %edx,%eax
  102f59:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102f5c:	72 40                	jb     102f9e <default_free_pages+0x2d2>
            assert(base + base->property != p);
  102f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f61:	8b 50 08             	mov    0x8(%eax),%edx
  102f64:	89 d0                	mov    %edx,%eax
  102f66:	c1 e0 02             	shl    $0x2,%eax
  102f69:	01 d0                	add    %edx,%eax
  102f6b:	c1 e0 02             	shl    $0x2,%eax
  102f6e:	89 c2                	mov    %eax,%edx
  102f70:	8b 45 08             	mov    0x8(%ebp),%eax
  102f73:	01 d0                	add    %edx,%eax
  102f75:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102f78:	75 3e                	jne    102fb8 <default_free_pages+0x2ec>
  102f7a:	c7 44 24 0c 59 68 10 	movl   $0x106859,0xc(%esp)
  102f81:	00 
  102f82:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  102f89:	00 
  102f8a:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  102f91:	00 
  102f92:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  102f99:	e8 3d dd ff ff       	call   100cdb <__panic>
  102f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fa1:	89 45 98             	mov    %eax,-0x68(%ebp)
  102fa4:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fa7:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  102faa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102fad:	81 7d f0 80 ce 11 00 	cmpl   $0x11ce80,-0x10(%ebp)
  102fb4:	75 83                	jne    102f39 <default_free_pages+0x26d>
  102fb6:	eb 01                	jmp    102fb9 <default_free_pages+0x2ed>
            break;
  102fb8:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
  102fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102fbc:	8d 50 0c             	lea    0xc(%eax),%edx
  102fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fc2:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102fc5:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  102fc8:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fcb:	8b 00                	mov    (%eax),%eax
  102fcd:	8b 55 90             	mov    -0x70(%ebp),%edx
  102fd0:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102fd3:	89 45 88             	mov    %eax,-0x78(%ebp)
  102fd6:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fd9:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  102fdc:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102fdf:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102fe2:	89 10                	mov    %edx,(%eax)
  102fe4:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102fe7:	8b 10                	mov    (%eax),%edx
  102fe9:	8b 45 88             	mov    -0x78(%ebp),%eax
  102fec:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102fef:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102ff2:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102ff5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102ff8:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102ffb:	8b 55 88             	mov    -0x78(%ebp),%edx
  102ffe:	89 10                	mov    %edx,(%eax)
}
  103000:	90                   	nop
}
  103001:	90                   	nop
}
  103002:	90                   	nop
  103003:	89 ec                	mov    %ebp,%esp
  103005:	5d                   	pop    %ebp
  103006:	c3                   	ret    

00103007 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  103007:	55                   	push   %ebp
  103008:	89 e5                	mov    %esp,%ebp
    return nr_free;
  10300a:	a1 88 ce 11 00       	mov    0x11ce88,%eax
}
  10300f:	5d                   	pop    %ebp
  103010:	c3                   	ret    

00103011 <basic_check>:

static void
basic_check(void) {
  103011:	55                   	push   %ebp
  103012:	89 e5                	mov    %esp,%ebp
  103014:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103017:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10301e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103021:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103024:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103027:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  10302a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103031:	e8 af 0e 00 00       	call   103ee5 <alloc_pages>
  103036:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103039:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10303d:	75 24                	jne    103063 <basic_check+0x52>
  10303f:	c7 44 24 0c 74 68 10 	movl   $0x106874,0xc(%esp)
  103046:	00 
  103047:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10304e:	00 
  10304f:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  103056:	00 
  103057:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10305e:	e8 78 dc ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  103063:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10306a:	e8 76 0e 00 00       	call   103ee5 <alloc_pages>
  10306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103072:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103076:	75 24                	jne    10309c <basic_check+0x8b>
  103078:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  10307f:	00 
  103080:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103087:	00 
  103088:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  10308f:	00 
  103090:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103097:	e8 3f dc ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  10309c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030a3:	e8 3d 0e 00 00       	call   103ee5 <alloc_pages>
  1030a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030af:	75 24                	jne    1030d5 <basic_check+0xc4>
  1030b1:	c7 44 24 0c ac 68 10 	movl   $0x1068ac,0xc(%esp)
  1030b8:	00 
  1030b9:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1030c0:	00 
  1030c1:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  1030c8:	00 
  1030c9:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1030d0:	e8 06 dc ff ff       	call   100cdb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  1030d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030d8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1030db:	74 10                	je     1030ed <basic_check+0xdc>
  1030dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1030e3:	74 08                	je     1030ed <basic_check+0xdc>
  1030e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1030eb:	75 24                	jne    103111 <basic_check+0x100>
  1030ed:	c7 44 24 0c c8 68 10 	movl   $0x1068c8,0xc(%esp)
  1030f4:	00 
  1030f5:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1030fc:	00 
  1030fd:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  103104:	00 
  103105:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10310c:	e8 ca db ff ff       	call   100cdb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103111:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103114:	89 04 24             	mov    %eax,(%esp)
  103117:	e8 7a f8 ff ff       	call   102996 <page_ref>
  10311c:	85 c0                	test   %eax,%eax
  10311e:	75 1e                	jne    10313e <basic_check+0x12d>
  103120:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103123:	89 04 24             	mov    %eax,(%esp)
  103126:	e8 6b f8 ff ff       	call   102996 <page_ref>
  10312b:	85 c0                	test   %eax,%eax
  10312d:	75 0f                	jne    10313e <basic_check+0x12d>
  10312f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103132:	89 04 24             	mov    %eax,(%esp)
  103135:	e8 5c f8 ff ff       	call   102996 <page_ref>
  10313a:	85 c0                	test   %eax,%eax
  10313c:	74 24                	je     103162 <basic_check+0x151>
  10313e:	c7 44 24 0c ec 68 10 	movl   $0x1068ec,0xc(%esp)
  103145:	00 
  103146:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10314d:	00 
  10314e:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103155:	00 
  103156:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10315d:	e8 79 db ff ff       	call   100cdb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103162:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103165:	89 04 24             	mov    %eax,(%esp)
  103168:	e8 11 f8 ff ff       	call   10297e <page2pa>
  10316d:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  103173:	c1 e2 0c             	shl    $0xc,%edx
  103176:	39 d0                	cmp    %edx,%eax
  103178:	72 24                	jb     10319e <basic_check+0x18d>
  10317a:	c7 44 24 0c 28 69 10 	movl   $0x106928,0xc(%esp)
  103181:	00 
  103182:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103189:	00 
  10318a:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  103191:	00 
  103192:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103199:	e8 3d db ff ff       	call   100cdb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10319e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031a1:	89 04 24             	mov    %eax,(%esp)
  1031a4:	e8 d5 f7 ff ff       	call   10297e <page2pa>
  1031a9:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  1031af:	c1 e2 0c             	shl    $0xc,%edx
  1031b2:	39 d0                	cmp    %edx,%eax
  1031b4:	72 24                	jb     1031da <basic_check+0x1c9>
  1031b6:	c7 44 24 0c 45 69 10 	movl   $0x106945,0xc(%esp)
  1031bd:	00 
  1031be:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1031c5:	00 
  1031c6:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  1031cd:	00 
  1031ce:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1031d5:	e8 01 db ff ff       	call   100cdb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1031da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031dd:	89 04 24             	mov    %eax,(%esp)
  1031e0:	e8 99 f7 ff ff       	call   10297e <page2pa>
  1031e5:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  1031eb:	c1 e2 0c             	shl    $0xc,%edx
  1031ee:	39 d0                	cmp    %edx,%eax
  1031f0:	72 24                	jb     103216 <basic_check+0x205>
  1031f2:	c7 44 24 0c 62 69 10 	movl   $0x106962,0xc(%esp)
  1031f9:	00 
  1031fa:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103201:	00 
  103202:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  103209:	00 
  10320a:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103211:	e8 c5 da ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  103216:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  10321b:	8b 15 84 ce 11 00    	mov    0x11ce84,%edx
  103221:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103224:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103227:	c7 45 dc 80 ce 11 00 	movl   $0x11ce80,-0x24(%ebp)
    elm->prev = elm->next = elm;
  10322e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103231:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103234:	89 50 04             	mov    %edx,0x4(%eax)
  103237:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10323a:	8b 50 04             	mov    0x4(%eax),%edx
  10323d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103240:	89 10                	mov    %edx,(%eax)
}
  103242:	90                   	nop
  103243:	c7 45 e0 80 ce 11 00 	movl   $0x11ce80,-0x20(%ebp)
    return list->next == list;
  10324a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10324d:	8b 40 04             	mov    0x4(%eax),%eax
  103250:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103253:	0f 94 c0             	sete   %al
  103256:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103259:	85 c0                	test   %eax,%eax
  10325b:	75 24                	jne    103281 <basic_check+0x270>
  10325d:	c7 44 24 0c 7f 69 10 	movl   $0x10697f,0xc(%esp)
  103264:	00 
  103265:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10326c:	00 
  10326d:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  103274:	00 
  103275:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10327c:	e8 5a da ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  103281:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103286:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103289:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
  103290:	00 00 00 

    assert(alloc_page() == NULL);
  103293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10329a:	e8 46 0c 00 00       	call   103ee5 <alloc_pages>
  10329f:	85 c0                	test   %eax,%eax
  1032a1:	74 24                	je     1032c7 <basic_check+0x2b6>
  1032a3:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  1032aa:	00 
  1032ab:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1032b2:	00 
  1032b3:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  1032ba:	00 
  1032bb:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1032c2:	e8 14 da ff ff       	call   100cdb <__panic>

    free_page(p0);
  1032c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032ce:	00 
  1032cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032d2:	89 04 24             	mov    %eax,(%esp)
  1032d5:	e8 45 0c 00 00       	call   103f1f <free_pages>
    free_page(p1);
  1032da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032e1:	00 
  1032e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032e5:	89 04 24             	mov    %eax,(%esp)
  1032e8:	e8 32 0c 00 00       	call   103f1f <free_pages>
    free_page(p2);
  1032ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032f4:	00 
  1032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f8:	89 04 24             	mov    %eax,(%esp)
  1032fb:	e8 1f 0c 00 00       	call   103f1f <free_pages>
    assert(nr_free == 3);
  103300:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103305:	83 f8 03             	cmp    $0x3,%eax
  103308:	74 24                	je     10332e <basic_check+0x31d>
  10330a:	c7 44 24 0c ab 69 10 	movl   $0x1069ab,0xc(%esp)
  103311:	00 
  103312:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103319:	00 
  10331a:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  103321:	00 
  103322:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103329:	e8 ad d9 ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) != NULL);
  10332e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103335:	e8 ab 0b 00 00       	call   103ee5 <alloc_pages>
  10333a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10333d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103341:	75 24                	jne    103367 <basic_check+0x356>
  103343:	c7 44 24 0c 74 68 10 	movl   $0x106874,0xc(%esp)
  10334a:	00 
  10334b:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103352:	00 
  103353:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10335a:	00 
  10335b:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103362:	e8 74 d9 ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  103367:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10336e:	e8 72 0b 00 00       	call   103ee5 <alloc_pages>
  103373:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103376:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10337a:	75 24                	jne    1033a0 <basic_check+0x38f>
  10337c:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  103383:	00 
  103384:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10338b:	00 
  10338c:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  103393:	00 
  103394:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10339b:	e8 3b d9 ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  1033a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033a7:	e8 39 0b 00 00       	call   103ee5 <alloc_pages>
  1033ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033b3:	75 24                	jne    1033d9 <basic_check+0x3c8>
  1033b5:	c7 44 24 0c ac 68 10 	movl   $0x1068ac,0xc(%esp)
  1033bc:	00 
  1033bd:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1033c4:	00 
  1033c5:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  1033cc:	00 
  1033cd:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1033d4:	e8 02 d9 ff ff       	call   100cdb <__panic>

    assert(alloc_page() == NULL);
  1033d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033e0:	e8 00 0b 00 00       	call   103ee5 <alloc_pages>
  1033e5:	85 c0                	test   %eax,%eax
  1033e7:	74 24                	je     10340d <basic_check+0x3fc>
  1033e9:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  1033f0:	00 
  1033f1:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1033f8:	00 
  1033f9:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  103400:	00 
  103401:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103408:	e8 ce d8 ff ff       	call   100cdb <__panic>

    free_page(p0);
  10340d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103414:	00 
  103415:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103418:	89 04 24             	mov    %eax,(%esp)
  10341b:	e8 ff 0a 00 00       	call   103f1f <free_pages>
  103420:	c7 45 d8 80 ce 11 00 	movl   $0x11ce80,-0x28(%ebp)
  103427:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10342a:	8b 40 04             	mov    0x4(%eax),%eax
  10342d:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103430:	0f 94 c0             	sete   %al
  103433:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103436:	85 c0                	test   %eax,%eax
  103438:	74 24                	je     10345e <basic_check+0x44d>
  10343a:	c7 44 24 0c b8 69 10 	movl   $0x1069b8,0xc(%esp)
  103441:	00 
  103442:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103449:	00 
  10344a:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  103451:	00 
  103452:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103459:	e8 7d d8 ff ff       	call   100cdb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  10345e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103465:	e8 7b 0a 00 00       	call   103ee5 <alloc_pages>
  10346a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10346d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103470:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103473:	74 24                	je     103499 <basic_check+0x488>
  103475:	c7 44 24 0c d0 69 10 	movl   $0x1069d0,0xc(%esp)
  10347c:	00 
  10347d:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103484:	00 
  103485:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  10348c:	00 
  10348d:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103494:	e8 42 d8 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034a0:	e8 40 0a 00 00       	call   103ee5 <alloc_pages>
  1034a5:	85 c0                	test   %eax,%eax
  1034a7:	74 24                	je     1034cd <basic_check+0x4bc>
  1034a9:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  1034b0:	00 
  1034b1:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1034b8:	00 
  1034b9:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  1034c0:	00 
  1034c1:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1034c8:	e8 0e d8 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  1034cd:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  1034d2:	85 c0                	test   %eax,%eax
  1034d4:	74 24                	je     1034fa <basic_check+0x4e9>
  1034d6:	c7 44 24 0c e9 69 10 	movl   $0x1069e9,0xc(%esp)
  1034dd:	00 
  1034de:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1034e5:	00 
  1034e6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  1034ed:	00 
  1034ee:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1034f5:	e8 e1 d7 ff ff       	call   100cdb <__panic>
    free_list = free_list_store;
  1034fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1034fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103500:	a3 80 ce 11 00       	mov    %eax,0x11ce80
  103505:	89 15 84 ce 11 00    	mov    %edx,0x11ce84
    nr_free = nr_free_store;
  10350b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10350e:	a3 88 ce 11 00       	mov    %eax,0x11ce88

    free_page(p);
  103513:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10351a:	00 
  10351b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10351e:	89 04 24             	mov    %eax,(%esp)
  103521:	e8 f9 09 00 00       	call   103f1f <free_pages>
    free_page(p1);
  103526:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10352d:	00 
  10352e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103531:	89 04 24             	mov    %eax,(%esp)
  103534:	e8 e6 09 00 00       	call   103f1f <free_pages>
    free_page(p2);
  103539:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103540:	00 
  103541:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103544:	89 04 24             	mov    %eax,(%esp)
  103547:	e8 d3 09 00 00       	call   103f1f <free_pages>
}
  10354c:	90                   	nop
  10354d:	89 ec                	mov    %ebp,%esp
  10354f:	5d                   	pop    %ebp
  103550:	c3                   	ret    

00103551 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103551:	55                   	push   %ebp
  103552:	89 e5                	mov    %esp,%ebp
  103554:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  10355a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103561:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103568:	c7 45 ec 80 ce 11 00 	movl   $0x11ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10356f:	eb 6a                	jmp    1035db <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  103571:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103574:	83 e8 0c             	sub    $0xc,%eax
  103577:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  10357a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10357d:	83 c0 04             	add    $0x4,%eax
  103580:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103587:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10358a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10358d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103590:	0f a3 10             	bt     %edx,(%eax)
  103593:	19 c0                	sbb    %eax,%eax
  103595:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103598:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10359c:	0f 95 c0             	setne  %al
  10359f:	0f b6 c0             	movzbl %al,%eax
  1035a2:	85 c0                	test   %eax,%eax
  1035a4:	75 24                	jne    1035ca <default_check+0x79>
  1035a6:	c7 44 24 0c f6 69 10 	movl   $0x1069f6,0xc(%esp)
  1035ad:	00 
  1035ae:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1035b5:	00 
  1035b6:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  1035bd:	00 
  1035be:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1035c5:	e8 11 d7 ff ff       	call   100cdb <__panic>
        count ++, total += p->property;
  1035ca:	ff 45 f4             	incl   -0xc(%ebp)
  1035cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1035d0:	8b 50 08             	mov    0x8(%eax),%edx
  1035d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035d6:	01 d0                	add    %edx,%eax
  1035d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1035db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1035e1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1035e4:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1035e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1035ea:	81 7d ec 80 ce 11 00 	cmpl   $0x11ce80,-0x14(%ebp)
  1035f1:	0f 85 7a ff ff ff    	jne    103571 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  1035f7:	e8 58 09 00 00       	call   103f54 <nr_free_pages>
  1035fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1035ff:	39 d0                	cmp    %edx,%eax
  103601:	74 24                	je     103627 <default_check+0xd6>
  103603:	c7 44 24 0c 06 6a 10 	movl   $0x106a06,0xc(%esp)
  10360a:	00 
  10360b:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103612:	00 
  103613:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  10361a:	00 
  10361b:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103622:	e8 b4 d6 ff ff       	call   100cdb <__panic>

    basic_check();
  103627:	e8 e5 f9 ff ff       	call   103011 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10362c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103633:	e8 ad 08 00 00       	call   103ee5 <alloc_pages>
  103638:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  10363b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10363f:	75 24                	jne    103665 <default_check+0x114>
  103641:	c7 44 24 0c 1f 6a 10 	movl   $0x106a1f,0xc(%esp)
  103648:	00 
  103649:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103650:	00 
  103651:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103658:	00 
  103659:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103660:	e8 76 d6 ff ff       	call   100cdb <__panic>
    assert(!PageProperty(p0));
  103665:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103668:	83 c0 04             	add    $0x4,%eax
  10366b:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103672:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103675:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103678:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10367b:	0f a3 10             	bt     %edx,(%eax)
  10367e:	19 c0                	sbb    %eax,%eax
  103680:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  103683:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103687:	0f 95 c0             	setne  %al
  10368a:	0f b6 c0             	movzbl %al,%eax
  10368d:	85 c0                	test   %eax,%eax
  10368f:	74 24                	je     1036b5 <default_check+0x164>
  103691:	c7 44 24 0c 2a 6a 10 	movl   $0x106a2a,0xc(%esp)
  103698:	00 
  103699:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1036a0:	00 
  1036a1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1036a8:	00 
  1036a9:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1036b0:	e8 26 d6 ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  1036b5:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1036ba:	8b 15 84 ce 11 00    	mov    0x11ce84,%edx
  1036c0:	89 45 80             	mov    %eax,-0x80(%ebp)
  1036c3:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1036c6:	c7 45 b0 80 ce 11 00 	movl   $0x11ce80,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1036cd:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1036d0:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1036d3:	89 50 04             	mov    %edx,0x4(%eax)
  1036d6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1036d9:	8b 50 04             	mov    0x4(%eax),%edx
  1036dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1036df:	89 10                	mov    %edx,(%eax)
}
  1036e1:	90                   	nop
  1036e2:	c7 45 b4 80 ce 11 00 	movl   $0x11ce80,-0x4c(%ebp)
    return list->next == list;
  1036e9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1036ec:	8b 40 04             	mov    0x4(%eax),%eax
  1036ef:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  1036f2:	0f 94 c0             	sete   %al
  1036f5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1036f8:	85 c0                	test   %eax,%eax
  1036fa:	75 24                	jne    103720 <default_check+0x1cf>
  1036fc:	c7 44 24 0c 7f 69 10 	movl   $0x10697f,0xc(%esp)
  103703:	00 
  103704:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10370b:	00 
  10370c:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  103713:	00 
  103714:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10371b:	e8 bb d5 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103720:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103727:	e8 b9 07 00 00       	call   103ee5 <alloc_pages>
  10372c:	85 c0                	test   %eax,%eax
  10372e:	74 24                	je     103754 <default_check+0x203>
  103730:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  103737:	00 
  103738:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10373f:	00 
  103740:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  103747:	00 
  103748:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10374f:	e8 87 d5 ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  103754:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  10375c:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
  103763:	00 00 00 

    free_pages(p0 + 2, 3);
  103766:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103769:	83 c0 28             	add    $0x28,%eax
  10376c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103773:	00 
  103774:	89 04 24             	mov    %eax,(%esp)
  103777:	e8 a3 07 00 00       	call   103f1f <free_pages>
    assert(alloc_pages(4) == NULL);
  10377c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  103783:	e8 5d 07 00 00       	call   103ee5 <alloc_pages>
  103788:	85 c0                	test   %eax,%eax
  10378a:	74 24                	je     1037b0 <default_check+0x25f>
  10378c:	c7 44 24 0c 3c 6a 10 	movl   $0x106a3c,0xc(%esp)
  103793:	00 
  103794:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10379b:	00 
  10379c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1037a3:	00 
  1037a4:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1037ab:	e8 2b d5 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1037b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037b3:	83 c0 28             	add    $0x28,%eax
  1037b6:	83 c0 04             	add    $0x4,%eax
  1037b9:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1037c0:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037c3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1037c6:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1037c9:	0f a3 10             	bt     %edx,(%eax)
  1037cc:	19 c0                	sbb    %eax,%eax
  1037ce:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1037d1:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1037d5:	0f 95 c0             	setne  %al
  1037d8:	0f b6 c0             	movzbl %al,%eax
  1037db:	85 c0                	test   %eax,%eax
  1037dd:	74 0e                	je     1037ed <default_check+0x29c>
  1037df:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037e2:	83 c0 28             	add    $0x28,%eax
  1037e5:	8b 40 08             	mov    0x8(%eax),%eax
  1037e8:	83 f8 03             	cmp    $0x3,%eax
  1037eb:	74 24                	je     103811 <default_check+0x2c0>
  1037ed:	c7 44 24 0c 54 6a 10 	movl   $0x106a54,0xc(%esp)
  1037f4:	00 
  1037f5:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1037fc:	00 
  1037fd:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  103804:	00 
  103805:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10380c:	e8 ca d4 ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103811:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103818:	e8 c8 06 00 00       	call   103ee5 <alloc_pages>
  10381d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103820:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103824:	75 24                	jne    10384a <default_check+0x2f9>
  103826:	c7 44 24 0c 80 6a 10 	movl   $0x106a80,0xc(%esp)
  10382d:	00 
  10382e:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103835:	00 
  103836:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10383d:	00 
  10383e:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103845:	e8 91 d4 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  10384a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103851:	e8 8f 06 00 00       	call   103ee5 <alloc_pages>
  103856:	85 c0                	test   %eax,%eax
  103858:	74 24                	je     10387e <default_check+0x32d>
  10385a:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  103861:	00 
  103862:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103869:	00 
  10386a:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  103871:	00 
  103872:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103879:	e8 5d d4 ff ff       	call   100cdb <__panic>
    assert(p0 + 2 == p1);
  10387e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103881:	83 c0 28             	add    $0x28,%eax
  103884:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103887:	74 24                	je     1038ad <default_check+0x35c>
  103889:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  103890:	00 
  103891:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103898:	00 
  103899:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1038a0:	00 
  1038a1:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1038a8:	e8 2e d4 ff ff       	call   100cdb <__panic>

    p2 = p0 + 1;
  1038ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038b0:	83 c0 14             	add    $0x14,%eax
  1038b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1038b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038bd:	00 
  1038be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038c1:	89 04 24             	mov    %eax,(%esp)
  1038c4:	e8 56 06 00 00       	call   103f1f <free_pages>
    free_pages(p1, 3);
  1038c9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1038d0:	00 
  1038d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1038d4:	89 04 24             	mov    %eax,(%esp)
  1038d7:	e8 43 06 00 00       	call   103f1f <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1038dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038df:	83 c0 04             	add    $0x4,%eax
  1038e2:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1038e9:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1038ec:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1038ef:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1038f2:	0f a3 10             	bt     %edx,(%eax)
  1038f5:	19 c0                	sbb    %eax,%eax
  1038f7:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1038fa:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1038fe:	0f 95 c0             	setne  %al
  103901:	0f b6 c0             	movzbl %al,%eax
  103904:	85 c0                	test   %eax,%eax
  103906:	74 0b                	je     103913 <default_check+0x3c2>
  103908:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10390b:	8b 40 08             	mov    0x8(%eax),%eax
  10390e:	83 f8 01             	cmp    $0x1,%eax
  103911:	74 24                	je     103937 <default_check+0x3e6>
  103913:	c7 44 24 0c ac 6a 10 	movl   $0x106aac,0xc(%esp)
  10391a:	00 
  10391b:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103922:	00 
  103923:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10392a:	00 
  10392b:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103932:	e8 a4 d3 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103937:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10393a:	83 c0 04             	add    $0x4,%eax
  10393d:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103944:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103947:	8b 45 90             	mov    -0x70(%ebp),%eax
  10394a:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10394d:	0f a3 10             	bt     %edx,(%eax)
  103950:	19 c0                	sbb    %eax,%eax
  103952:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103955:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103959:	0f 95 c0             	setne  %al
  10395c:	0f b6 c0             	movzbl %al,%eax
  10395f:	85 c0                	test   %eax,%eax
  103961:	74 0b                	je     10396e <default_check+0x41d>
  103963:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103966:	8b 40 08             	mov    0x8(%eax),%eax
  103969:	83 f8 03             	cmp    $0x3,%eax
  10396c:	74 24                	je     103992 <default_check+0x441>
  10396e:	c7 44 24 0c d4 6a 10 	movl   $0x106ad4,0xc(%esp)
  103975:	00 
  103976:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  10397d:	00 
  10397e:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  103985:	00 
  103986:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  10398d:	e8 49 d3 ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103992:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103999:	e8 47 05 00 00       	call   103ee5 <alloc_pages>
  10399e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1039a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1039a4:	83 e8 14             	sub    $0x14,%eax
  1039a7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1039aa:	74 24                	je     1039d0 <default_check+0x47f>
  1039ac:	c7 44 24 0c fa 6a 10 	movl   $0x106afa,0xc(%esp)
  1039b3:	00 
  1039b4:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  1039bb:	00 
  1039bc:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  1039c3:	00 
  1039c4:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1039cb:	e8 0b d3 ff ff       	call   100cdb <__panic>
    free_page(p0);
  1039d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1039d7:	00 
  1039d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039db:	89 04 24             	mov    %eax,(%esp)
  1039de:	e8 3c 05 00 00       	call   103f1f <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1039e3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1039ea:	e8 f6 04 00 00       	call   103ee5 <alloc_pages>
  1039ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1039f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1039f5:	83 c0 14             	add    $0x14,%eax
  1039f8:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1039fb:	74 24                	je     103a21 <default_check+0x4d0>
  1039fd:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  103a04:	00 
  103a05:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103a0c:	00 
  103a0d:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  103a14:	00 
  103a15:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103a1c:	e8 ba d2 ff ff       	call   100cdb <__panic>

    free_pages(p0, 2);
  103a21:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103a28:	00 
  103a29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a2c:	89 04 24             	mov    %eax,(%esp)
  103a2f:	e8 eb 04 00 00       	call   103f1f <free_pages>
    free_page(p2);
  103a34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103a3b:	00 
  103a3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103a3f:	89 04 24             	mov    %eax,(%esp)
  103a42:	e8 d8 04 00 00       	call   103f1f <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103a47:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103a4e:	e8 92 04 00 00       	call   103ee5 <alloc_pages>
  103a53:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103a56:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103a5a:	75 24                	jne    103a80 <default_check+0x52f>
  103a5c:	c7 44 24 0c 38 6b 10 	movl   $0x106b38,0xc(%esp)
  103a63:	00 
  103a64:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103a6b:	00 
  103a6c:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  103a73:	00 
  103a74:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103a7b:	e8 5b d2 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103a80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103a87:	e8 59 04 00 00       	call   103ee5 <alloc_pages>
  103a8c:	85 c0                	test   %eax,%eax
  103a8e:	74 24                	je     103ab4 <default_check+0x563>
  103a90:	c7 44 24 0c 96 69 10 	movl   $0x106996,0xc(%esp)
  103a97:	00 
  103a98:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103a9f:	00 
  103aa0:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  103aa7:	00 
  103aa8:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103aaf:	e8 27 d2 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  103ab4:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103ab9:	85 c0                	test   %eax,%eax
  103abb:	74 24                	je     103ae1 <default_check+0x590>
  103abd:	c7 44 24 0c e9 69 10 	movl   $0x1069e9,0xc(%esp)
  103ac4:	00 
  103ac5:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103acc:	00 
  103acd:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103ad4:	00 
  103ad5:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103adc:	e8 fa d1 ff ff       	call   100cdb <__panic>
    nr_free = nr_free_store;
  103ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ae4:	a3 88 ce 11 00       	mov    %eax,0x11ce88

    free_list = free_list_store;
  103ae9:	8b 45 80             	mov    -0x80(%ebp),%eax
  103aec:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103aef:	a3 80 ce 11 00       	mov    %eax,0x11ce80
  103af4:	89 15 84 ce 11 00    	mov    %edx,0x11ce84
    free_pages(p0, 5);
  103afa:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103b01:	00 
  103b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103b05:	89 04 24             	mov    %eax,(%esp)
  103b08:	e8 12 04 00 00       	call   103f1f <free_pages>

    le = &free_list;
  103b0d:	c7 45 ec 80 ce 11 00 	movl   $0x11ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103b14:	eb 1c                	jmp    103b32 <default_check+0x5e1>
        //assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
  103b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b19:	83 e8 0c             	sub    $0xc,%eax
  103b1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103b1f:	ff 4d f4             	decl   -0xc(%ebp)
  103b22:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103b25:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103b28:	8b 48 08             	mov    0x8(%eax),%ecx
  103b2b:	89 d0                	mov    %edx,%eax
  103b2d:	29 c8                	sub    %ecx,%eax
  103b2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b35:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103b38:	8b 45 88             	mov    -0x78(%ebp),%eax
  103b3b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103b41:	81 7d ec 80 ce 11 00 	cmpl   $0x11ce80,-0x14(%ebp)
  103b48:	75 cc                	jne    103b16 <default_check+0x5c5>
    }
    assert(count == 0);
  103b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103b4e:	74 24                	je     103b74 <default_check+0x623>
  103b50:	c7 44 24 0c 56 6b 10 	movl   $0x106b56,0xc(%esp)
  103b57:	00 
  103b58:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103b5f:	00 
  103b60:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  103b67:	00 
  103b68:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103b6f:	e8 67 d1 ff ff       	call   100cdb <__panic>
    assert(total == 0);
  103b74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103b78:	74 24                	je     103b9e <default_check+0x64d>
  103b7a:	c7 44 24 0c 61 6b 10 	movl   $0x106b61,0xc(%esp)
  103b81:	00 
  103b82:	c7 44 24 08 f6 67 10 	movl   $0x1067f6,0x8(%esp)
  103b89:	00 
  103b8a:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  103b91:	00 
  103b92:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  103b99:	e8 3d d1 ff ff       	call   100cdb <__panic>
}
  103b9e:	90                   	nop
  103b9f:	89 ec                	mov    %ebp,%esp
  103ba1:	5d                   	pop    %ebp
  103ba2:	c3                   	ret    

00103ba3 <page2ppn>:
page2ppn(struct Page *page) {
  103ba3:	55                   	push   %ebp
  103ba4:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103ba6:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  103bac:	8b 45 08             	mov    0x8(%ebp),%eax
  103baf:	29 d0                	sub    %edx,%eax
  103bb1:	c1 f8 02             	sar    $0x2,%eax
  103bb4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103bba:	5d                   	pop    %ebp
  103bbb:	c3                   	ret    

00103bbc <page2pa>:
page2pa(struct Page *page) {
  103bbc:	55                   	push   %ebp
  103bbd:	89 e5                	mov    %esp,%ebp
  103bbf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  103bc5:	89 04 24             	mov    %eax,(%esp)
  103bc8:	e8 d6 ff ff ff       	call   103ba3 <page2ppn>
  103bcd:	c1 e0 0c             	shl    $0xc,%eax
}
  103bd0:	89 ec                	mov    %ebp,%esp
  103bd2:	5d                   	pop    %ebp
  103bd3:	c3                   	ret    

00103bd4 <pa2page>:
pa2page(uintptr_t pa) {
  103bd4:	55                   	push   %ebp
  103bd5:	89 e5                	mov    %esp,%ebp
  103bd7:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103bda:	8b 45 08             	mov    0x8(%ebp),%eax
  103bdd:	c1 e8 0c             	shr    $0xc,%eax
  103be0:	89 c2                	mov    %eax,%edx
  103be2:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  103be7:	39 c2                	cmp    %eax,%edx
  103be9:	72 1c                	jb     103c07 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103beb:	c7 44 24 08 9c 6b 10 	movl   $0x106b9c,0x8(%esp)
  103bf2:	00 
  103bf3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  103bfa:	00 
  103bfb:	c7 04 24 bb 6b 10 00 	movl   $0x106bbb,(%esp)
  103c02:	e8 d4 d0 ff ff       	call   100cdb <__panic>
    return &pages[PPN(pa)];
  103c07:	8b 0d a0 ce 11 00    	mov    0x11cea0,%ecx
  103c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c10:	c1 e8 0c             	shr    $0xc,%eax
  103c13:	89 c2                	mov    %eax,%edx
  103c15:	89 d0                	mov    %edx,%eax
  103c17:	c1 e0 02             	shl    $0x2,%eax
  103c1a:	01 d0                	add    %edx,%eax
  103c1c:	c1 e0 02             	shl    $0x2,%eax
  103c1f:	01 c8                	add    %ecx,%eax
}
  103c21:	89 ec                	mov    %ebp,%esp
  103c23:	5d                   	pop    %ebp
  103c24:	c3                   	ret    

00103c25 <page2kva>:
page2kva(struct Page *page) {
  103c25:	55                   	push   %ebp
  103c26:	89 e5                	mov    %esp,%ebp
  103c28:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  103c2e:	89 04 24             	mov    %eax,(%esp)
  103c31:	e8 86 ff ff ff       	call   103bbc <page2pa>
  103c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c3c:	c1 e8 0c             	shr    $0xc,%eax
  103c3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c42:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  103c47:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103c4a:	72 23                	jb     103c6f <page2kva+0x4a>
  103c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c53:	c7 44 24 08 cc 6b 10 	movl   $0x106bcc,0x8(%esp)
  103c5a:	00 
  103c5b:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  103c62:	00 
  103c63:	c7 04 24 bb 6b 10 00 	movl   $0x106bbb,(%esp)
  103c6a:	e8 6c d0 ff ff       	call   100cdb <__panic>
  103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c72:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103c77:	89 ec                	mov    %ebp,%esp
  103c79:	5d                   	pop    %ebp
  103c7a:	c3                   	ret    

00103c7b <pte2page>:
pte2page(pte_t pte) {
  103c7b:	55                   	push   %ebp
  103c7c:	89 e5                	mov    %esp,%ebp
  103c7e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103c81:	8b 45 08             	mov    0x8(%ebp),%eax
  103c84:	83 e0 01             	and    $0x1,%eax
  103c87:	85 c0                	test   %eax,%eax
  103c89:	75 1c                	jne    103ca7 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103c8b:	c7 44 24 08 f0 6b 10 	movl   $0x106bf0,0x8(%esp)
  103c92:	00 
  103c93:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  103c9a:	00 
  103c9b:	c7 04 24 bb 6b 10 00 	movl   $0x106bbb,(%esp)
  103ca2:	e8 34 d0 ff ff       	call   100cdb <__panic>
    return pa2page(PTE_ADDR(pte));
  103ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  103caa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103caf:	89 04 24             	mov    %eax,(%esp)
  103cb2:	e8 1d ff ff ff       	call   103bd4 <pa2page>
}
  103cb7:	89 ec                	mov    %ebp,%esp
  103cb9:	5d                   	pop    %ebp
  103cba:	c3                   	ret    

00103cbb <pde2page>:
pde2page(pde_t pde) {
  103cbb:	55                   	push   %ebp
  103cbc:	89 e5                	mov    %esp,%ebp
  103cbe:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  103cc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103cc9:	89 04 24             	mov    %eax,(%esp)
  103ccc:	e8 03 ff ff ff       	call   103bd4 <pa2page>
}
  103cd1:	89 ec                	mov    %ebp,%esp
  103cd3:	5d                   	pop    %ebp
  103cd4:	c3                   	ret    

00103cd5 <page_ref>:
page_ref(struct Page *page) {
  103cd5:	55                   	push   %ebp
  103cd6:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  103cdb:	8b 00                	mov    (%eax),%eax
}
  103cdd:	5d                   	pop    %ebp
  103cde:	c3                   	ret    

00103cdf <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  103cdf:	55                   	push   %ebp
  103ce0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  103ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  103ce8:	89 10                	mov    %edx,(%eax)
}
  103cea:	90                   	nop
  103ceb:	5d                   	pop    %ebp
  103cec:	c3                   	ret    

00103ced <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103ced:	55                   	push   %ebp
  103cee:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  103cf3:	8b 00                	mov    (%eax),%eax
  103cf5:	8d 50 01             	lea    0x1(%eax),%edx
  103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  103cfb:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  103d00:	8b 00                	mov    (%eax),%eax
}
  103d02:	5d                   	pop    %ebp
  103d03:	c3                   	ret    

00103d04 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103d04:	55                   	push   %ebp
  103d05:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103d07:	8b 45 08             	mov    0x8(%ebp),%eax
  103d0a:	8b 00                	mov    (%eax),%eax
  103d0c:	8d 50 ff             	lea    -0x1(%eax),%edx
  103d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  103d12:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103d14:	8b 45 08             	mov    0x8(%ebp),%eax
  103d17:	8b 00                	mov    (%eax),%eax
}
  103d19:	5d                   	pop    %ebp
  103d1a:	c3                   	ret    

00103d1b <__intr_save>:
__intr_save(void) {
  103d1b:	55                   	push   %ebp
  103d1c:	89 e5                	mov    %esp,%ebp
  103d1e:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103d21:	9c                   	pushf  
  103d22:	58                   	pop    %eax
  103d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103d29:	25 00 02 00 00       	and    $0x200,%eax
  103d2e:	85 c0                	test   %eax,%eax
  103d30:	74 0c                	je     103d3e <__intr_save+0x23>
        intr_disable();
  103d32:	e8 fd d9 ff ff       	call   101734 <intr_disable>
        return 1;
  103d37:	b8 01 00 00 00       	mov    $0x1,%eax
  103d3c:	eb 05                	jmp    103d43 <__intr_save+0x28>
    return 0;
  103d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103d43:	89 ec                	mov    %ebp,%esp
  103d45:	5d                   	pop    %ebp
  103d46:	c3                   	ret    

00103d47 <__intr_restore>:
__intr_restore(bool flag) {
  103d47:	55                   	push   %ebp
  103d48:	89 e5                	mov    %esp,%ebp
  103d4a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103d4d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103d51:	74 05                	je     103d58 <__intr_restore+0x11>
        intr_enable();
  103d53:	e8 d4 d9 ff ff       	call   10172c <intr_enable>
}
  103d58:	90                   	nop
  103d59:	89 ec                	mov    %ebp,%esp
  103d5b:	5d                   	pop    %ebp
  103d5c:	c3                   	ret    

00103d5d <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103d5d:	55                   	push   %ebp
  103d5e:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103d60:	8b 45 08             	mov    0x8(%ebp),%eax
  103d63:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103d66:	b8 23 00 00 00       	mov    $0x23,%eax
  103d6b:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103d6d:	b8 23 00 00 00       	mov    $0x23,%eax
  103d72:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103d74:	b8 10 00 00 00       	mov    $0x10,%eax
  103d79:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103d7b:	b8 10 00 00 00       	mov    $0x10,%eax
  103d80:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103d82:	b8 10 00 00 00       	mov    $0x10,%eax
  103d87:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103d89:	ea 90 3d 10 00 08 00 	ljmp   $0x8,$0x103d90
}
  103d90:	90                   	nop
  103d91:	5d                   	pop    %ebp
  103d92:	c3                   	ret    

00103d93 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103d93:	55                   	push   %ebp
  103d94:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103d96:	8b 45 08             	mov    0x8(%ebp),%eax
  103d99:	a3 c4 ce 11 00       	mov    %eax,0x11cec4
}
  103d9e:	90                   	nop
  103d9f:	5d                   	pop    %ebp
  103da0:	c3                   	ret    

00103da1 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103da1:	55                   	push   %ebp
  103da2:	89 e5                	mov    %esp,%ebp
  103da4:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103da7:	b8 00 90 11 00       	mov    $0x119000,%eax
  103dac:	89 04 24             	mov    %eax,(%esp)
  103daf:	e8 df ff ff ff       	call   103d93 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103db4:	66 c7 05 c8 ce 11 00 	movw   $0x10,0x11cec8
  103dbb:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103dbd:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  103dc4:	68 00 
  103dc6:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103dcb:	0f b7 c0             	movzwl %ax,%eax
  103dce:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  103dd4:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103dd9:	c1 e8 10             	shr    $0x10,%eax
  103ddc:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  103de1:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103de8:	24 f0                	and    $0xf0,%al
  103dea:	0c 09                	or     $0x9,%al
  103dec:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103df1:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103df8:	24 ef                	and    $0xef,%al
  103dfa:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103dff:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103e06:	24 9f                	and    $0x9f,%al
  103e08:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103e0d:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103e14:	0c 80                	or     $0x80,%al
  103e16:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103e1b:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103e22:	24 f0                	and    $0xf0,%al
  103e24:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103e29:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103e30:	24 ef                	and    $0xef,%al
  103e32:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103e37:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103e3e:	24 df                	and    $0xdf,%al
  103e40:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103e45:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103e4c:	0c 40                	or     $0x40,%al
  103e4e:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103e53:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103e5a:	24 7f                	and    $0x7f,%al
  103e5c:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103e61:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103e66:	c1 e8 18             	shr    $0x18,%eax
  103e69:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103e6e:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  103e75:	e8 e3 fe ff ff       	call   103d5d <lgdt>
  103e7a:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103e80:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103e84:	0f 00 d8             	ltr    %ax
}
  103e87:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  103e88:	90                   	nop
  103e89:	89 ec                	mov    %ebp,%esp
  103e8b:	5d                   	pop    %ebp
  103e8c:	c3                   	ret    

00103e8d <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103e8d:	55                   	push   %ebp
  103e8e:	89 e5                	mov    %esp,%ebp
  103e90:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103e93:	c7 05 ac ce 11 00 80 	movl   $0x106b80,0x11ceac
  103e9a:	6b 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103e9d:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103ea2:	8b 00                	mov    (%eax),%eax
  103ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ea8:	c7 04 24 1c 6c 10 00 	movl   $0x106c1c,(%esp)
  103eaf:	e8 a2 c4 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  103eb4:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103eb9:	8b 40 04             	mov    0x4(%eax),%eax
  103ebc:	ff d0                	call   *%eax
}
  103ebe:	90                   	nop
  103ebf:	89 ec                	mov    %ebp,%esp
  103ec1:	5d                   	pop    %ebp
  103ec2:	c3                   	ret    

00103ec3 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103ec3:	55                   	push   %ebp
  103ec4:	89 e5                	mov    %esp,%ebp
  103ec6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103ec9:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103ece:	8b 40 08             	mov    0x8(%eax),%eax
  103ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
  103ed4:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  103edb:	89 14 24             	mov    %edx,(%esp)
  103ede:	ff d0                	call   *%eax
}
  103ee0:	90                   	nop
  103ee1:	89 ec                	mov    %ebp,%esp
  103ee3:	5d                   	pop    %ebp
  103ee4:	c3                   	ret    

00103ee5 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103ee5:	55                   	push   %ebp
  103ee6:	89 e5                	mov    %esp,%ebp
  103ee8:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103eeb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103ef2:	e8 24 fe ff ff       	call   103d1b <__intr_save>
  103ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103efa:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103eff:	8b 40 0c             	mov    0xc(%eax),%eax
  103f02:	8b 55 08             	mov    0x8(%ebp),%edx
  103f05:	89 14 24             	mov    %edx,(%esp)
  103f08:	ff d0                	call   *%eax
  103f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f10:	89 04 24             	mov    %eax,(%esp)
  103f13:	e8 2f fe ff ff       	call   103d47 <__intr_restore>
    return page;
  103f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103f1b:	89 ec                	mov    %ebp,%esp
  103f1d:	5d                   	pop    %ebp
  103f1e:	c3                   	ret    

00103f1f <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103f1f:	55                   	push   %ebp
  103f20:	89 e5                	mov    %esp,%ebp
  103f22:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103f25:	e8 f1 fd ff ff       	call   103d1b <__intr_save>
  103f2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103f2d:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103f32:	8b 40 10             	mov    0x10(%eax),%eax
  103f35:	8b 55 0c             	mov    0xc(%ebp),%edx
  103f38:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  103f3f:	89 14 24             	mov    %edx,(%esp)
  103f42:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f47:	89 04 24             	mov    %eax,(%esp)
  103f4a:	e8 f8 fd ff ff       	call   103d47 <__intr_restore>
}
  103f4f:	90                   	nop
  103f50:	89 ec                	mov    %ebp,%esp
  103f52:	5d                   	pop    %ebp
  103f53:	c3                   	ret    

00103f54 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103f54:	55                   	push   %ebp
  103f55:	89 e5                	mov    %esp,%ebp
  103f57:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103f5a:	e8 bc fd ff ff       	call   103d1b <__intr_save>
  103f5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103f62:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103f67:	8b 40 14             	mov    0x14(%eax),%eax
  103f6a:	ff d0                	call   *%eax
  103f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f72:	89 04 24             	mov    %eax,(%esp)
  103f75:	e8 cd fd ff ff       	call   103d47 <__intr_restore>
    return ret;
  103f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103f7d:	89 ec                	mov    %ebp,%esp
  103f7f:	5d                   	pop    %ebp
  103f80:	c3                   	ret    

00103f81 <page_init>:

/* pmm_init - initialize the physical memory management  负责确定探查到的物理内存块与对应的struct Page之间的映射关系*/
static void
page_init(void) {
  103f81:	55                   	push   %ebp
  103f82:	89 e5                	mov    %esp,%ebp
  103f84:	57                   	push   %edi
  103f85:	56                   	push   %esi
  103f86:	53                   	push   %ebx
  103f87:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103f8d:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;//最大的物理内存地址
  103f94:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103f9b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103fa2:	c7 04 24 33 6c 10 00 	movl   $0x106c33,(%esp)
  103fa9:	e8 a8 c3 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {//nr_map 探测到的内存总块数
  103fae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fb5:	e9 0c 01 00 00       	jmp    1040c6 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103fba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fc0:	89 d0                	mov    %edx,%eax
  103fc2:	c1 e0 02             	shl    $0x2,%eax
  103fc5:	01 d0                	add    %edx,%eax
  103fc7:	c1 e0 02             	shl    $0x2,%eax
  103fca:	01 c8                	add    %ecx,%eax
  103fcc:	8b 50 08             	mov    0x8(%eax),%edx
  103fcf:	8b 40 04             	mov    0x4(%eax),%eax
  103fd2:	89 45 a0             	mov    %eax,-0x60(%ebp)
  103fd5:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  103fd8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fdb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fde:	89 d0                	mov    %edx,%eax
  103fe0:	c1 e0 02             	shl    $0x2,%eax
  103fe3:	01 d0                	add    %edx,%eax
  103fe5:	c1 e0 02             	shl    $0x2,%eax
  103fe8:	01 c8                	add    %ecx,%eax
  103fea:	8b 48 0c             	mov    0xc(%eax),%ecx
  103fed:	8b 58 10             	mov    0x10(%eax),%ebx
  103ff0:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103ff3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103ff6:	01 c8                	add    %ecx,%eax
  103ff8:	11 da                	adc    %ebx,%edx
  103ffa:	89 45 98             	mov    %eax,-0x68(%ebp)
  103ffd:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104000:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104003:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104006:	89 d0                	mov    %edx,%eax
  104008:	c1 e0 02             	shl    $0x2,%eax
  10400b:	01 d0                	add    %edx,%eax
  10400d:	c1 e0 02             	shl    $0x2,%eax
  104010:	01 c8                	add    %ecx,%eax
  104012:	83 c0 14             	add    $0x14,%eax
  104015:	8b 00                	mov    (%eax),%eax
  104017:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  10401d:	8b 45 98             	mov    -0x68(%ebp),%eax
  104020:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104023:	83 c0 ff             	add    $0xffffffff,%eax
  104026:	83 d2 ff             	adc    $0xffffffff,%edx
  104029:	89 c6                	mov    %eax,%esi
  10402b:	89 d7                	mov    %edx,%edi
  10402d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104030:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104033:	89 d0                	mov    %edx,%eax
  104035:	c1 e0 02             	shl    $0x2,%eax
  104038:	01 d0                	add    %edx,%eax
  10403a:	c1 e0 02             	shl    $0x2,%eax
  10403d:	01 c8                	add    %ecx,%eax
  10403f:	8b 48 0c             	mov    0xc(%eax),%ecx
  104042:	8b 58 10             	mov    0x10(%eax),%ebx
  104045:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  10404b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  10404f:	89 74 24 14          	mov    %esi,0x14(%esp)
  104053:	89 7c 24 18          	mov    %edi,0x18(%esp)
  104057:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10405a:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10405d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104061:	89 54 24 10          	mov    %edx,0x10(%esp)
  104065:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  10406d:	c7 04 24 40 6c 10 00 	movl   $0x106c40,(%esp)
  104074:	e8 dd c2 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104079:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10407c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10407f:	89 d0                	mov    %edx,%eax
  104081:	c1 e0 02             	shl    $0x2,%eax
  104084:	01 d0                	add    %edx,%eax
  104086:	c1 e0 02             	shl    $0x2,%eax
  104089:	01 c8                	add    %ecx,%eax
  10408b:	83 c0 14             	add    $0x14,%eax
  10408e:	8b 00                	mov    (%eax),%eax
  104090:	83 f8 01             	cmp    $0x1,%eax
  104093:	75 2e                	jne    1040c3 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  104095:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104098:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10409b:	3b 45 98             	cmp    -0x68(%ebp),%eax
  10409e:	89 d0                	mov    %edx,%eax
  1040a0:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  1040a3:	73 1e                	jae    1040c3 <page_init+0x142>
  1040a5:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  1040aa:	b8 00 00 00 00       	mov    $0x0,%eax
  1040af:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  1040b2:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  1040b5:	72 0c                	jb     1040c3 <page_init+0x142>
                maxpa = end;
  1040b7:	8b 45 98             	mov    -0x68(%ebp),%eax
  1040ba:	8b 55 9c             	mov    -0x64(%ebp),%edx
  1040bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1040c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {//nr_map 探测到的内存总块数
  1040c3:	ff 45 dc             	incl   -0x24(%ebp)
  1040c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1040c9:	8b 00                	mov    (%eax),%eax
  1040cb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1040ce:	0f 8c e6 fe ff ff    	jl     103fba <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  1040d4:	ba 00 00 00 38       	mov    $0x38000000,%edx
  1040d9:	b8 00 00 00 00       	mov    $0x0,%eax
  1040de:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  1040e1:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  1040e4:	73 0e                	jae    1040f4 <page_init+0x173>
        maxpa = KMEMSIZE;
  1040e6:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  1040ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];//全局变量end记录bootloader加载ucore的结束地址

    npage = maxpa / PGSIZE;//求出所要管理的页数
  1040f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1040f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1040fa:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1040fe:	c1 ea 0c             	shr    $0xc,%edx
  104101:	a3 a4 ce 11 00       	mov    %eax,0x11cea4
    //把end按页大小为边界取整后，作为管理页级物理内存空间所需的Page结构的内存空间
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  104106:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  10410d:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  104112:	8d 50 ff             	lea    -0x1(%eax),%edx
  104115:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104118:	01 d0                	add    %edx,%eax
  10411a:	89 45 bc             	mov    %eax,-0x44(%ebp)
  10411d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104120:	ba 00 00 00 00       	mov    $0x0,%edx
  104125:	f7 75 c0             	divl   -0x40(%ebp)
  104128:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10412b:	29 d0                	sub    %edx,%eax
  10412d:	a3 a0 ce 11 00       	mov    %eax,0x11cea0
    //将所有可用的page设置为reserved，被硬件保留，实现非空闲标记。
    for (i = 0; i < npage; i ++) {
  104132:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104139:	eb 2f                	jmp    10416a <page_init+0x1e9>
        
        SetPageReserved(pages + i);
  10413b:	8b 0d a0 ce 11 00    	mov    0x11cea0,%ecx
  104141:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104144:	89 d0                	mov    %edx,%eax
  104146:	c1 e0 02             	shl    $0x2,%eax
  104149:	01 d0                	add    %edx,%eax
  10414b:	c1 e0 02             	shl    $0x2,%eax
  10414e:	01 c8                	add    %ecx,%eax
  104150:	83 c0 04             	add    $0x4,%eax
  104153:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  10415a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10415d:	8b 45 90             	mov    -0x70(%ebp),%eax
  104160:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104163:	0f ab 10             	bts    %edx,(%eax)
}
  104166:	90                   	nop
    for (i = 0; i < npage; i ++) {
  104167:	ff 45 dc             	incl   -0x24(%ebp)
  10416a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10416d:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104172:	39 c2                	cmp    %eax,%edx
  104174:	72 c5                	jb     10413b <page_init+0x1ba>
    }
    
    //sizeof(struct Page) * npage 预估出管理页级物理内存空间所需的Page结构的内存空间大小
    //空闲空间的起始地址为freemem
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104176:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  10417c:	89 d0                	mov    %edx,%eax
  10417e:	c1 e0 02             	shl    $0x2,%eax
  104181:	01 d0                	add    %edx,%eax
  104183:	c1 e0 02             	shl    $0x2,%eax
  104186:	89 c2                	mov    %eax,%edx
  104188:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  10418d:	01 d0                	add    %edx,%eax
  10418f:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104192:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  104199:	77 23                	ja     1041be <page_init+0x23d>
  10419b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10419e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1041a2:	c7 44 24 08 70 6c 10 	movl   $0x106c70,0x8(%esp)
  1041a9:	00 
  1041aa:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  1041b1:	00 
  1041b2:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1041b9:	e8 1d cb ff ff       	call   100cdb <__panic>
  1041be:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1041c1:	05 00 00 00 40       	add    $0x40000000,%eax
  1041c6:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1041c9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1041d0:	e9 53 01 00 00       	jmp    104328 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1041d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1041d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041db:	89 d0                	mov    %edx,%eax
  1041dd:	c1 e0 02             	shl    $0x2,%eax
  1041e0:	01 d0                	add    %edx,%eax
  1041e2:	c1 e0 02             	shl    $0x2,%eax
  1041e5:	01 c8                	add    %ecx,%eax
  1041e7:	8b 50 08             	mov    0x8(%eax),%edx
  1041ea:	8b 40 04             	mov    0x4(%eax),%eax
  1041ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1041f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1041f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1041f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041f9:	89 d0                	mov    %edx,%eax
  1041fb:	c1 e0 02             	shl    $0x2,%eax
  1041fe:	01 d0                	add    %edx,%eax
  104200:	c1 e0 02             	shl    $0x2,%eax
  104203:	01 c8                	add    %ecx,%eax
  104205:	8b 48 0c             	mov    0xc(%eax),%ecx
  104208:	8b 58 10             	mov    0x10(%eax),%ebx
  10420b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10420e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104211:	01 c8                	add    %ecx,%eax
  104213:	11 da                	adc    %ebx,%edx
  104215:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104218:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10421b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10421e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104221:	89 d0                	mov    %edx,%eax
  104223:	c1 e0 02             	shl    $0x2,%eax
  104226:	01 d0                	add    %edx,%eax
  104228:	c1 e0 02             	shl    $0x2,%eax
  10422b:	01 c8                	add    %ecx,%eax
  10422d:	83 c0 14             	add    $0x14,%eax
  104230:	8b 00                	mov    (%eax),%eax
  104232:	83 f8 01             	cmp    $0x1,%eax
  104235:	0f 85 ea 00 00 00    	jne    104325 <page_init+0x3a4>
            if (begin < freemem) {
  10423b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10423e:	ba 00 00 00 00       	mov    $0x0,%edx
  104243:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104246:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  104249:	19 d1                	sbb    %edx,%ecx
  10424b:	73 0d                	jae    10425a <page_init+0x2d9>
                begin = freemem;
  10424d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104250:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104253:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  10425a:	ba 00 00 00 38       	mov    $0x38000000,%edx
  10425f:	b8 00 00 00 00       	mov    $0x0,%eax
  104264:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  104267:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  10426a:	73 0e                	jae    10427a <page_init+0x2f9>
                end = KMEMSIZE;
  10426c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104273:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  10427a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10427d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104280:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104283:	89 d0                	mov    %edx,%eax
  104285:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104288:	0f 83 97 00 00 00    	jae    104325 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  10428e:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  104295:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104298:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10429b:	01 d0                	add    %edx,%eax
  10429d:	48                   	dec    %eax
  10429e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  1042a1:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1042a4:	ba 00 00 00 00       	mov    $0x0,%edx
  1042a9:	f7 75 b0             	divl   -0x50(%ebp)
  1042ac:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1042af:	29 d0                	sub    %edx,%eax
  1042b1:	ba 00 00 00 00       	mov    $0x0,%edx
  1042b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1042b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1042bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1042bf:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1042c2:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1042c5:	ba 00 00 00 00       	mov    $0x0,%edx
  1042ca:	89 c7                	mov    %eax,%edi
  1042cc:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1042d2:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1042d5:	89 d0                	mov    %edx,%eax
  1042d7:	83 e0 00             	and    $0x0,%eax
  1042da:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1042dd:	8b 45 80             	mov    -0x80(%ebp),%eax
  1042e0:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1042e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1042e6:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {//负责确定探查到的物理内存块与对应的struct Page之间的映射关系
  1042e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1042ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042ef:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1042f2:	89 d0                	mov    %edx,%eax
  1042f4:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1042f7:	73 2c                	jae    104325 <page_init+0x3a4>
                    //实现空闲标记 把空闲物理页对应的Page结构中的flags和引用计数ref清零，
                    //并加到free_area.free_list指向的双向列表中，为将来的空闲页管理做好初始化准备工作。
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1042f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1042fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1042ff:	2b 45 d0             	sub    -0x30(%ebp),%eax
  104302:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  104305:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104309:	c1 ea 0c             	shr    $0xc,%edx
  10430c:	89 c3                	mov    %eax,%ebx
  10430e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104311:	89 04 24             	mov    %eax,(%esp)
  104314:	e8 bb f8 ff ff       	call   103bd4 <pa2page>
  104319:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10431d:	89 04 24             	mov    %eax,(%esp)
  104320:	e8 9e fb ff ff       	call   103ec3 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  104325:	ff 45 dc             	incl   -0x24(%ebp)
  104328:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10432b:	8b 00                	mov    (%eax),%eax
  10432d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104330:	0f 8c 9f fe ff ff    	jl     1041d5 <page_init+0x254>
                }
            }
        }
    }
}
  104336:	90                   	nop
  104337:	90                   	nop
  104338:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10433e:	5b                   	pop    %ebx
  10433f:	5e                   	pop    %esi
  104340:	5f                   	pop    %edi
  104341:	5d                   	pop    %ebp
  104342:	c3                   	ret    

00104343 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104343:	55                   	push   %ebp
  104344:	89 e5                	mov    %esp,%ebp
  104346:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104349:	8b 45 0c             	mov    0xc(%ebp),%eax
  10434c:	33 45 14             	xor    0x14(%ebp),%eax
  10434f:	25 ff 0f 00 00       	and    $0xfff,%eax
  104354:	85 c0                	test   %eax,%eax
  104356:	74 24                	je     10437c <boot_map_segment+0x39>
  104358:	c7 44 24 0c a2 6c 10 	movl   $0x106ca2,0xc(%esp)
  10435f:	00 
  104360:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104367:	00 
  104368:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  10436f:	00 
  104370:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104377:	e8 5f c9 ff ff       	call   100cdb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10437c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104383:	8b 45 0c             	mov    0xc(%ebp),%eax
  104386:	25 ff 0f 00 00       	and    $0xfff,%eax
  10438b:	89 c2                	mov    %eax,%edx
  10438d:	8b 45 10             	mov    0x10(%ebp),%eax
  104390:	01 c2                	add    %eax,%edx
  104392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104395:	01 d0                	add    %edx,%eax
  104397:	48                   	dec    %eax
  104398:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10439b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10439e:	ba 00 00 00 00       	mov    $0x0,%edx
  1043a3:	f7 75 f0             	divl   -0x10(%ebp)
  1043a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1043a9:	29 d0                	sub    %edx,%eax
  1043ab:	c1 e8 0c             	shr    $0xc,%eax
  1043ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1043b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1043b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1043ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1043bf:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1043c2:	8b 45 14             	mov    0x14(%ebp),%eax
  1043c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1043c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1043d0:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1043d3:	eb 68                	jmp    10443d <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1043d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1043dc:	00 
  1043dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1043e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1043e7:	89 04 24             	mov    %eax,(%esp)
  1043ea:	e8 88 01 00 00       	call   104577 <get_pte>
  1043ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1043f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1043f6:	75 24                	jne    10441c <boot_map_segment+0xd9>
  1043f8:	c7 44 24 0c ce 6c 10 	movl   $0x106cce,0xc(%esp)
  1043ff:	00 
  104400:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104407:	00 
  104408:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  10440f:	00 
  104410:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104417:	e8 bf c8 ff ff       	call   100cdb <__panic>
        *ptep = pa | PTE_P | perm;
  10441c:	8b 45 14             	mov    0x14(%ebp),%eax
  10441f:	0b 45 18             	or     0x18(%ebp),%eax
  104422:	83 c8 01             	or     $0x1,%eax
  104425:	89 c2                	mov    %eax,%edx
  104427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10442a:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10442c:	ff 4d f4             	decl   -0xc(%ebp)
  10442f:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104436:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10443d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104441:	75 92                	jne    1043d5 <boot_map_segment+0x92>
    }
}
  104443:	90                   	nop
  104444:	90                   	nop
  104445:	89 ec                	mov    %ebp,%esp
  104447:	5d                   	pop    %ebp
  104448:	c3                   	ret    

00104449 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104449:	55                   	push   %ebp
  10444a:	89 e5                	mov    %esp,%ebp
  10444c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10444f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104456:	e8 8a fa ff ff       	call   103ee5 <alloc_pages>
  10445b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10445e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104462:	75 1c                	jne    104480 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  104464:	c7 44 24 08 db 6c 10 	movl   $0x106cdb,0x8(%esp)
  10446b:	00 
  10446c:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104473:	00 
  104474:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10447b:	e8 5b c8 ff ff       	call   100cdb <__panic>
    }
    return page2kva(p);
  104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104483:	89 04 24             	mov    %eax,(%esp)
  104486:	e8 9a f7 ff ff       	call   103c25 <page2kva>
}
  10448b:	89 ec                	mov    %ebp,%esp
  10448d:	5d                   	pop    %ebp
  10448e:	c3                   	ret    

0010448f <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10448f:	55                   	push   %ebp
  104490:	89 e5                	mov    %esp,%ebp
  104492:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104495:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10449a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10449d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1044a4:	77 23                	ja     1044c9 <pmm_init+0x3a>
  1044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044ad:	c7 44 24 08 70 6c 10 	movl   $0x106c70,0x8(%esp)
  1044b4:	00 
  1044b5:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1044bc:	00 
  1044bd:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1044c4:	e8 12 c8 ff ff       	call   100cdb <__panic>
  1044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044cc:	05 00 00 00 40       	add    $0x40000000,%eax
  1044d1:	a3 a8 ce 11 00       	mov    %eax,0x11cea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1044d6:	e8 b2 f9 ff ff       	call   103e8d <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1044db:	e8 a1 fa ff ff       	call   103f81 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1044e0:	e8 ed 03 00 00       	call   1048d2 <check_alloc_page>

    check_pgdir();
  1044e5:	e8 09 04 00 00       	call   1048f3 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1044ea:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1044ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1044f2:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1044f9:	77 23                	ja     10451e <pmm_init+0x8f>
  1044fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104502:	c7 44 24 08 70 6c 10 	movl   $0x106c70,0x8(%esp)
  104509:	00 
  10450a:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  104511:	00 
  104512:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104519:	e8 bd c7 ff ff       	call   100cdb <__panic>
  10451e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104521:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  104527:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10452c:	05 ac 0f 00 00       	add    $0xfac,%eax
  104531:	83 ca 03             	or     $0x3,%edx
  104534:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  104536:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10453b:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104542:	00 
  104543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10454a:	00 
  10454b:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104552:	38 
  104553:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10455a:	c0 
  10455b:	89 04 24             	mov    %eax,(%esp)
  10455e:	e8 e0 fd ff ff       	call   104343 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  104563:	e8 39 f8 ff ff       	call   103da1 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  104568:	e8 24 0a 00 00       	call   104f91 <check_boot_pgdir>

    print_pgdir();
  10456d:	e8 a1 0e 00 00       	call   105413 <print_pgdir>

}
  104572:	90                   	nop
  104573:	89 ec                	mov    %ebp,%esp
  104575:	5d                   	pop    %ebp
  104576:	c3                   	ret    

00104577 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104577:	55                   	push   %ebp
  104578:	89 e5                	mov    %esp,%ebp
  10457a:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
//todo
    pde_t *pdep = &pgdir[PDX(la)];
  10457d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104580:	c1 e8 16             	shr    $0x16,%eax
  104583:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10458a:	8b 45 08             	mov    0x8(%ebp),%eax
  10458d:	01 d0                	add    %edx,%eax
  10458f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104595:	8b 00                	mov    (%eax),%eax
  104597:	83 e0 01             	and    $0x1,%eax
  10459a:	85 c0                	test   %eax,%eax
  10459c:	0f 85 af 00 00 00    	jne    104651 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1045a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1045a6:	74 15                	je     1045bd <get_pte+0x46>
  1045a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1045af:	e8 31 f9 ff ff       	call   103ee5 <alloc_pages>
  1045b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1045b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1045bb:	75 0a                	jne    1045c7 <get_pte+0x50>
            return NULL;
  1045bd:	b8 00 00 00 00       	mov    $0x0,%eax
  1045c2:	e9 e7 00 00 00       	jmp    1046ae <get_pte+0x137>
        }
        set_page_ref(page, 1);
  1045c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1045ce:	00 
  1045cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045d2:	89 04 24             	mov    %eax,(%esp)
  1045d5:	e8 05 f7 ff ff       	call   103cdf <set_page_ref>
        uintptr_t pa = page2pa(page);
  1045da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045dd:	89 04 24             	mov    %eax,(%esp)
  1045e0:	e8 d7 f5 ff ff       	call   103bbc <page2pa>
  1045e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  1045e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1045ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045f1:	c1 e8 0c             	shr    $0xc,%eax
  1045f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1045f7:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  1045fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1045ff:	72 23                	jb     104624 <get_pte+0xad>
  104601:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104604:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104608:	c7 44 24 08 cc 6b 10 	movl   $0x106bcc,0x8(%esp)
  10460f:	00 
  104610:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  104617:	00 
  104618:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10461f:	e8 b7 c6 ff ff       	call   100cdb <__panic>
  104624:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104627:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10462c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104633:	00 
  104634:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10463b:	00 
  10463c:	89 04 24             	mov    %eax,(%esp)
  10463f:	e8 d4 18 00 00       	call   105f18 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  104644:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104647:	83 c8 07             	or     $0x7,%eax
  10464a:	89 c2                	mov    %eax,%edx
  10464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464f:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104654:	8b 00                	mov    (%eax),%eax
  104656:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10465b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10465e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104661:	c1 e8 0c             	shr    $0xc,%eax
  104664:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104667:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  10466c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10466f:	72 23                	jb     104694 <get_pte+0x11d>
  104671:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104674:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104678:	c7 44 24 08 cc 6b 10 	movl   $0x106bcc,0x8(%esp)
  10467f:	00 
  104680:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
  104687:	00 
  104688:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10468f:	e8 47 c6 ff ff       	call   100cdb <__panic>
  104694:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104697:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10469c:	89 c2                	mov    %eax,%edx
  10469e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046a1:	c1 e8 0c             	shr    $0xc,%eax
  1046a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  1046a9:	c1 e0 02             	shl    $0x2,%eax
  1046ac:	01 d0                	add    %edx,%eax
}
  1046ae:	89 ec                	mov    %ebp,%esp
  1046b0:	5d                   	pop    %ebp
  1046b1:	c3                   	ret    

001046b2 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1046b2:	55                   	push   %ebp
  1046b3:	89 e5                	mov    %esp,%ebp
  1046b5:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1046b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1046bf:	00 
  1046c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1046ca:	89 04 24             	mov    %eax,(%esp)
  1046cd:	e8 a5 fe ff ff       	call   104577 <get_pte>
  1046d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1046d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1046d9:	74 08                	je     1046e3 <get_page+0x31>
        *ptep_store = ptep;
  1046db:	8b 45 10             	mov    0x10(%ebp),%eax
  1046de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1046e1:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1046e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046e7:	74 1b                	je     104704 <get_page+0x52>
  1046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ec:	8b 00                	mov    (%eax),%eax
  1046ee:	83 e0 01             	and    $0x1,%eax
  1046f1:	85 c0                	test   %eax,%eax
  1046f3:	74 0f                	je     104704 <get_page+0x52>
        return pte2page(*ptep);
  1046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046f8:	8b 00                	mov    (%eax),%eax
  1046fa:	89 04 24             	mov    %eax,(%esp)
  1046fd:	e8 79 f5 ff ff       	call   103c7b <pte2page>
  104702:	eb 05                	jmp    104709 <get_page+0x57>
    }
    return NULL;
  104704:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104709:	89 ec                	mov    %ebp,%esp
  10470b:	5d                   	pop    %ebp
  10470c:	c3                   	ret    

0010470d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10470d:	55                   	push   %ebp
  10470e:	89 e5                	mov    %esp,%ebp
  104710:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//todo
    if (*ptep & PTE_P) {
  104713:	8b 45 10             	mov    0x10(%ebp),%eax
  104716:	8b 00                	mov    (%eax),%eax
  104718:	83 e0 01             	and    $0x1,%eax
  10471b:	85 c0                	test   %eax,%eax
  10471d:	74 4d                	je     10476c <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  10471f:	8b 45 10             	mov    0x10(%ebp),%eax
  104722:	8b 00                	mov    (%eax),%eax
  104724:	89 04 24             	mov    %eax,(%esp)
  104727:	e8 4f f5 ff ff       	call   103c7b <pte2page>
  10472c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  10472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104732:	89 04 24             	mov    %eax,(%esp)
  104735:	e8 ca f5 ff ff       	call   103d04 <page_ref_dec>
  10473a:	85 c0                	test   %eax,%eax
  10473c:	75 13                	jne    104751 <page_remove_pte+0x44>
            free_page(page);
  10473e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104745:	00 
  104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104749:	89 04 24             	mov    %eax,(%esp)
  10474c:	e8 ce f7 ff ff       	call   103f1f <free_pages>
        }
        *ptep = 0;
  104751:	8b 45 10             	mov    0x10(%ebp),%eax
  104754:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  10475a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10475d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104761:	8b 45 08             	mov    0x8(%ebp),%eax
  104764:	89 04 24             	mov    %eax,(%esp)
  104767:	e8 07 01 00 00       	call   104873 <tlb_invalidate>
    }
}
  10476c:	90                   	nop
  10476d:	89 ec                	mov    %ebp,%esp
  10476f:	5d                   	pop    %ebp
  104770:	c3                   	ret    

00104771 <page_remove>:
//todo
//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104771:	55                   	push   %ebp
  104772:	89 e5                	mov    %esp,%ebp
  104774:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104777:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10477e:	00 
  10477f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104782:	89 44 24 04          	mov    %eax,0x4(%esp)
  104786:	8b 45 08             	mov    0x8(%ebp),%eax
  104789:	89 04 24             	mov    %eax,(%esp)
  10478c:	e8 e6 fd ff ff       	call   104577 <get_pte>
  104791:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104794:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104798:	74 19                	je     1047b3 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10479d:	89 44 24 08          	mov    %eax,0x8(%esp)
  1047a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1047ab:	89 04 24             	mov    %eax,(%esp)
  1047ae:	e8 5a ff ff ff       	call   10470d <page_remove_pte>
    }
}
  1047b3:	90                   	nop
  1047b4:	89 ec                	mov    %ebp,%esp
  1047b6:	5d                   	pop    %ebp
  1047b7:	c3                   	ret    

001047b8 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1047b8:	55                   	push   %ebp
  1047b9:	89 e5                	mov    %esp,%ebp
  1047bb:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1047be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1047c5:	00 
  1047c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1047c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1047d0:	89 04 24             	mov    %eax,(%esp)
  1047d3:	e8 9f fd ff ff       	call   104577 <get_pte>
  1047d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1047db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1047df:	75 0a                	jne    1047eb <page_insert+0x33>
        return -E_NO_MEM;
  1047e1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1047e6:	e9 84 00 00 00       	jmp    10486f <page_insert+0xb7>
    }
    page_ref_inc(page);
  1047eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047ee:	89 04 24             	mov    %eax,(%esp)
  1047f1:	e8 f7 f4 ff ff       	call   103ced <page_ref_inc>
    if (*ptep & PTE_P) {
  1047f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047f9:	8b 00                	mov    (%eax),%eax
  1047fb:	83 e0 01             	and    $0x1,%eax
  1047fe:	85 c0                	test   %eax,%eax
  104800:	74 3e                	je     104840 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104805:	8b 00                	mov    (%eax),%eax
  104807:	89 04 24             	mov    %eax,(%esp)
  10480a:	e8 6c f4 ff ff       	call   103c7b <pte2page>
  10480f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104815:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104818:	75 0d                	jne    104827 <page_insert+0x6f>
            page_ref_dec(page);
  10481a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10481d:	89 04 24             	mov    %eax,(%esp)
  104820:	e8 df f4 ff ff       	call   103d04 <page_ref_dec>
  104825:	eb 19                	jmp    104840 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10482a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10482e:	8b 45 10             	mov    0x10(%ebp),%eax
  104831:	89 44 24 04          	mov    %eax,0x4(%esp)
  104835:	8b 45 08             	mov    0x8(%ebp),%eax
  104838:	89 04 24             	mov    %eax,(%esp)
  10483b:	e8 cd fe ff ff       	call   10470d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104840:	8b 45 0c             	mov    0xc(%ebp),%eax
  104843:	89 04 24             	mov    %eax,(%esp)
  104846:	e8 71 f3 ff ff       	call   103bbc <page2pa>
  10484b:	0b 45 14             	or     0x14(%ebp),%eax
  10484e:	83 c8 01             	or     $0x1,%eax
  104851:	89 c2                	mov    %eax,%edx
  104853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104856:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104858:	8b 45 10             	mov    0x10(%ebp),%eax
  10485b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10485f:	8b 45 08             	mov    0x8(%ebp),%eax
  104862:	89 04 24             	mov    %eax,(%esp)
  104865:	e8 09 00 00 00       	call   104873 <tlb_invalidate>
    return 0;
  10486a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10486f:	89 ec                	mov    %ebp,%esp
  104871:	5d                   	pop    %ebp
  104872:	c3                   	ret    

00104873 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104873:	55                   	push   %ebp
  104874:	89 e5                	mov    %esp,%ebp
  104876:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104879:	0f 20 d8             	mov    %cr3,%eax
  10487c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10487f:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  104882:	8b 45 08             	mov    0x8(%ebp),%eax
  104885:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104888:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10488f:	77 23                	ja     1048b4 <tlb_invalidate+0x41>
  104891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104894:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104898:	c7 44 24 08 70 6c 10 	movl   $0x106c70,0x8(%esp)
  10489f:	00 
  1048a0:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  1048a7:	00 
  1048a8:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1048af:	e8 27 c4 ff ff       	call   100cdb <__panic>
  1048b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048b7:	05 00 00 00 40       	add    $0x40000000,%eax
  1048bc:	39 d0                	cmp    %edx,%eax
  1048be:	75 0d                	jne    1048cd <tlb_invalidate+0x5a>
        invlpg((void *)la);
  1048c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1048c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048c9:	0f 01 38             	invlpg (%eax)
}
  1048cc:	90                   	nop
    }
}
  1048cd:	90                   	nop
  1048ce:	89 ec                	mov    %ebp,%esp
  1048d0:	5d                   	pop    %ebp
  1048d1:	c3                   	ret    

001048d2 <check_alloc_page>:

static void
check_alloc_page(void) {
  1048d2:	55                   	push   %ebp
  1048d3:	89 e5                	mov    %esp,%ebp
  1048d5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1048d8:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  1048dd:	8b 40 18             	mov    0x18(%eax),%eax
  1048e0:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1048e2:	c7 04 24 f4 6c 10 00 	movl   $0x106cf4,(%esp)
  1048e9:	e8 68 ba ff ff       	call   100356 <cprintf>
}
  1048ee:	90                   	nop
  1048ef:	89 ec                	mov    %ebp,%esp
  1048f1:	5d                   	pop    %ebp
  1048f2:	c3                   	ret    

001048f3 <check_pgdir>:

static void
check_pgdir(void) {
  1048f3:	55                   	push   %ebp
  1048f4:	89 e5                	mov    %esp,%ebp
  1048f6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1048f9:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  1048fe:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104903:	76 24                	jbe    104929 <check_pgdir+0x36>
  104905:	c7 44 24 0c 13 6d 10 	movl   $0x106d13,0xc(%esp)
  10490c:	00 
  10490d:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104914:	00 
  104915:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  10491c:	00 
  10491d:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104924:	e8 b2 c3 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104929:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10492e:	85 c0                	test   %eax,%eax
  104930:	74 0e                	je     104940 <check_pgdir+0x4d>
  104932:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104937:	25 ff 0f 00 00       	and    $0xfff,%eax
  10493c:	85 c0                	test   %eax,%eax
  10493e:	74 24                	je     104964 <check_pgdir+0x71>
  104940:	c7 44 24 0c 30 6d 10 	movl   $0x106d30,0xc(%esp)
  104947:	00 
  104948:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  10494f:	00 
  104950:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104957:	00 
  104958:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10495f:	e8 77 c3 ff ff       	call   100cdb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104964:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104969:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104970:	00 
  104971:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104978:	00 
  104979:	89 04 24             	mov    %eax,(%esp)
  10497c:	e8 31 fd ff ff       	call   1046b2 <get_page>
  104981:	85 c0                	test   %eax,%eax
  104983:	74 24                	je     1049a9 <check_pgdir+0xb6>
  104985:	c7 44 24 0c 68 6d 10 	movl   $0x106d68,0xc(%esp)
  10498c:	00 
  10498d:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104994:	00 
  104995:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  10499c:	00 
  10499d:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1049a4:	e8 32 c3 ff ff       	call   100cdb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1049a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049b0:	e8 30 f5 ff ff       	call   103ee5 <alloc_pages>
  1049b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1049b8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1049bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1049c4:	00 
  1049c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049cc:	00 
  1049cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1049d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1049d4:	89 04 24             	mov    %eax,(%esp)
  1049d7:	e8 dc fd ff ff       	call   1047b8 <page_insert>
  1049dc:	85 c0                	test   %eax,%eax
  1049de:	74 24                	je     104a04 <check_pgdir+0x111>
  1049e0:	c7 44 24 0c 90 6d 10 	movl   $0x106d90,0xc(%esp)
  1049e7:	00 
  1049e8:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  1049ef:	00 
  1049f0:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  1049f7:	00 
  1049f8:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1049ff:	e8 d7 c2 ff ff       	call   100cdb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104a04:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104a09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a10:	00 
  104a11:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104a18:	00 
  104a19:	89 04 24             	mov    %eax,(%esp)
  104a1c:	e8 56 fb ff ff       	call   104577 <get_pte>
  104a21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a28:	75 24                	jne    104a4e <check_pgdir+0x15b>
  104a2a:	c7 44 24 0c bc 6d 10 	movl   $0x106dbc,0xc(%esp)
  104a31:	00 
  104a32:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104a39:	00 
  104a3a:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104a41:	00 
  104a42:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104a49:	e8 8d c2 ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a51:	8b 00                	mov    (%eax),%eax
  104a53:	89 04 24             	mov    %eax,(%esp)
  104a56:	e8 20 f2 ff ff       	call   103c7b <pte2page>
  104a5b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104a5e:	74 24                	je     104a84 <check_pgdir+0x191>
  104a60:	c7 44 24 0c e9 6d 10 	movl   $0x106de9,0xc(%esp)
  104a67:	00 
  104a68:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104a6f:	00 
  104a70:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104a77:	00 
  104a78:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104a7f:	e8 57 c2 ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 1);
  104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a87:	89 04 24             	mov    %eax,(%esp)
  104a8a:	e8 46 f2 ff ff       	call   103cd5 <page_ref>
  104a8f:	83 f8 01             	cmp    $0x1,%eax
  104a92:	74 24                	je     104ab8 <check_pgdir+0x1c5>
  104a94:	c7 44 24 0c ff 6d 10 	movl   $0x106dff,0xc(%esp)
  104a9b:	00 
  104a9c:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104aa3:	00 
  104aa4:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104aab:	00 
  104aac:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104ab3:	e8 23 c2 ff ff       	call   100cdb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104ab8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104abd:	8b 00                	mov    (%eax),%eax
  104abf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104ac4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ac7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104aca:	c1 e8 0c             	shr    $0xc,%eax
  104acd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ad0:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104ad5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104ad8:	72 23                	jb     104afd <check_pgdir+0x20a>
  104ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104add:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ae1:	c7 44 24 08 cc 6b 10 	movl   $0x106bcc,0x8(%esp)
  104ae8:	00 
  104ae9:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104af0:	00 
  104af1:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104af8:	e8 de c1 ff ff       	call   100cdb <__panic>
  104afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b00:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104b05:	83 c0 04             	add    $0x4,%eax
  104b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104b0b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b17:	00 
  104b18:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b1f:	00 
  104b20:	89 04 24             	mov    %eax,(%esp)
  104b23:	e8 4f fa ff ff       	call   104577 <get_pte>
  104b28:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104b2b:	74 24                	je     104b51 <check_pgdir+0x25e>
  104b2d:	c7 44 24 0c 14 6e 10 	movl   $0x106e14,0xc(%esp)
  104b34:	00 
  104b35:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104b3c:	00 
  104b3d:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104b44:	00 
  104b45:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104b4c:	e8 8a c1 ff ff       	call   100cdb <__panic>

    p2 = alloc_page();
  104b51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b58:	e8 88 f3 ff ff       	call   103ee5 <alloc_pages>
  104b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104b60:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b65:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104b6c:	00 
  104b6d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104b74:	00 
  104b75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104b78:	89 54 24 04          	mov    %edx,0x4(%esp)
  104b7c:	89 04 24             	mov    %eax,(%esp)
  104b7f:	e8 34 fc ff ff       	call   1047b8 <page_insert>
  104b84:	85 c0                	test   %eax,%eax
  104b86:	74 24                	je     104bac <check_pgdir+0x2b9>
  104b88:	c7 44 24 0c 3c 6e 10 	movl   $0x106e3c,0xc(%esp)
  104b8f:	00 
  104b90:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104b97:	00 
  104b98:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104b9f:	00 
  104ba0:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104ba7:	e8 2f c1 ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104bac:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104bb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104bb8:	00 
  104bb9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104bc0:	00 
  104bc1:	89 04 24             	mov    %eax,(%esp)
  104bc4:	e8 ae f9 ff ff       	call   104577 <get_pte>
  104bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104bcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104bd0:	75 24                	jne    104bf6 <check_pgdir+0x303>
  104bd2:	c7 44 24 0c 74 6e 10 	movl   $0x106e74,0xc(%esp)
  104bd9:	00 
  104bda:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104be1:	00 
  104be2:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104be9:	00 
  104bea:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104bf1:	e8 e5 c0 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_U);
  104bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bf9:	8b 00                	mov    (%eax),%eax
  104bfb:	83 e0 04             	and    $0x4,%eax
  104bfe:	85 c0                	test   %eax,%eax
  104c00:	75 24                	jne    104c26 <check_pgdir+0x333>
  104c02:	c7 44 24 0c a4 6e 10 	movl   $0x106ea4,0xc(%esp)
  104c09:	00 
  104c0a:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104c11:	00 
  104c12:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104c19:	00 
  104c1a:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104c21:	e8 b5 c0 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_W);
  104c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c29:	8b 00                	mov    (%eax),%eax
  104c2b:	83 e0 02             	and    $0x2,%eax
  104c2e:	85 c0                	test   %eax,%eax
  104c30:	75 24                	jne    104c56 <check_pgdir+0x363>
  104c32:	c7 44 24 0c b2 6e 10 	movl   $0x106eb2,0xc(%esp)
  104c39:	00 
  104c3a:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104c41:	00 
  104c42:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104c49:	00 
  104c4a:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104c51:	e8 85 c0 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104c56:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104c5b:	8b 00                	mov    (%eax),%eax
  104c5d:	83 e0 04             	and    $0x4,%eax
  104c60:	85 c0                	test   %eax,%eax
  104c62:	75 24                	jne    104c88 <check_pgdir+0x395>
  104c64:	c7 44 24 0c c0 6e 10 	movl   $0x106ec0,0xc(%esp)
  104c6b:	00 
  104c6c:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104c73:	00 
  104c74:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104c7b:	00 
  104c7c:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104c83:	e8 53 c0 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 1);
  104c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c8b:	89 04 24             	mov    %eax,(%esp)
  104c8e:	e8 42 f0 ff ff       	call   103cd5 <page_ref>
  104c93:	83 f8 01             	cmp    $0x1,%eax
  104c96:	74 24                	je     104cbc <check_pgdir+0x3c9>
  104c98:	c7 44 24 0c d6 6e 10 	movl   $0x106ed6,0xc(%esp)
  104c9f:	00 
  104ca0:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104ca7:	00 
  104ca8:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  104caf:	00 
  104cb0:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104cb7:	e8 1f c0 ff ff       	call   100cdb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104cbc:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104cc8:	00 
  104cc9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104cd0:	00 
  104cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104cd4:	89 54 24 04          	mov    %edx,0x4(%esp)
  104cd8:	89 04 24             	mov    %eax,(%esp)
  104cdb:	e8 d8 fa ff ff       	call   1047b8 <page_insert>
  104ce0:	85 c0                	test   %eax,%eax
  104ce2:	74 24                	je     104d08 <check_pgdir+0x415>
  104ce4:	c7 44 24 0c e8 6e 10 	movl   $0x106ee8,0xc(%esp)
  104ceb:	00 
  104cec:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104cf3:	00 
  104cf4:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104cfb:	00 
  104cfc:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104d03:	e8 d3 bf ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 2);
  104d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d0b:	89 04 24             	mov    %eax,(%esp)
  104d0e:	e8 c2 ef ff ff       	call   103cd5 <page_ref>
  104d13:	83 f8 02             	cmp    $0x2,%eax
  104d16:	74 24                	je     104d3c <check_pgdir+0x449>
  104d18:	c7 44 24 0c 14 6f 10 	movl   $0x106f14,0xc(%esp)
  104d1f:	00 
  104d20:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104d27:	00 
  104d28:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104d2f:	00 
  104d30:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104d37:	e8 9f bf ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d3f:	89 04 24             	mov    %eax,(%esp)
  104d42:	e8 8e ef ff ff       	call   103cd5 <page_ref>
  104d47:	85 c0                	test   %eax,%eax
  104d49:	74 24                	je     104d6f <check_pgdir+0x47c>
  104d4b:	c7 44 24 0c 26 6f 10 	movl   $0x106f26,0xc(%esp)
  104d52:	00 
  104d53:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104d5a:	00 
  104d5b:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  104d62:	00 
  104d63:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104d6a:	e8 6c bf ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104d6f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104d74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104d7b:	00 
  104d7c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d83:	00 
  104d84:	89 04 24             	mov    %eax,(%esp)
  104d87:	e8 eb f7 ff ff       	call   104577 <get_pte>
  104d8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104d93:	75 24                	jne    104db9 <check_pgdir+0x4c6>
  104d95:	c7 44 24 0c 74 6e 10 	movl   $0x106e74,0xc(%esp)
  104d9c:	00 
  104d9d:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104da4:	00 
  104da5:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104dac:	00 
  104dad:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104db4:	e8 22 bf ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dbc:	8b 00                	mov    (%eax),%eax
  104dbe:	89 04 24             	mov    %eax,(%esp)
  104dc1:	e8 b5 ee ff ff       	call   103c7b <pte2page>
  104dc6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104dc9:	74 24                	je     104def <check_pgdir+0x4fc>
  104dcb:	c7 44 24 0c e9 6d 10 	movl   $0x106de9,0xc(%esp)
  104dd2:	00 
  104dd3:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104dda:	00 
  104ddb:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  104de2:	00 
  104de3:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104dea:	e8 ec be ff ff       	call   100cdb <__panic>
    assert((*ptep & PTE_U) == 0);
  104def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104df2:	8b 00                	mov    (%eax),%eax
  104df4:	83 e0 04             	and    $0x4,%eax
  104df7:	85 c0                	test   %eax,%eax
  104df9:	74 24                	je     104e1f <check_pgdir+0x52c>
  104dfb:	c7 44 24 0c 38 6f 10 	movl   $0x106f38,0xc(%esp)
  104e02:	00 
  104e03:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104e0a:	00 
  104e0b:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104e12:	00 
  104e13:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104e1a:	e8 bc be ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, 0x0);
  104e1f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104e24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104e2b:	00 
  104e2c:	89 04 24             	mov    %eax,(%esp)
  104e2f:	e8 3d f9 ff ff       	call   104771 <page_remove>
    assert(page_ref(p1) == 1);
  104e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e37:	89 04 24             	mov    %eax,(%esp)
  104e3a:	e8 96 ee ff ff       	call   103cd5 <page_ref>
  104e3f:	83 f8 01             	cmp    $0x1,%eax
  104e42:	74 24                	je     104e68 <check_pgdir+0x575>
  104e44:	c7 44 24 0c ff 6d 10 	movl   $0x106dff,0xc(%esp)
  104e4b:	00 
  104e4c:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104e53:	00 
  104e54:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  104e5b:	00 
  104e5c:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104e63:	e8 73 be ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e6b:	89 04 24             	mov    %eax,(%esp)
  104e6e:	e8 62 ee ff ff       	call   103cd5 <page_ref>
  104e73:	85 c0                	test   %eax,%eax
  104e75:	74 24                	je     104e9b <check_pgdir+0x5a8>
  104e77:	c7 44 24 0c 26 6f 10 	movl   $0x106f26,0xc(%esp)
  104e7e:	00 
  104e7f:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104e86:	00 
  104e87:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104e8e:	00 
  104e8f:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104e96:	e8 40 be ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104e9b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ea0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104ea7:	00 
  104ea8:	89 04 24             	mov    %eax,(%esp)
  104eab:	e8 c1 f8 ff ff       	call   104771 <page_remove>
    assert(page_ref(p1) == 0);
  104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104eb3:	89 04 24             	mov    %eax,(%esp)
  104eb6:	e8 1a ee ff ff       	call   103cd5 <page_ref>
  104ebb:	85 c0                	test   %eax,%eax
  104ebd:	74 24                	je     104ee3 <check_pgdir+0x5f0>
  104ebf:	c7 44 24 0c 4d 6f 10 	movl   $0x106f4d,0xc(%esp)
  104ec6:	00 
  104ec7:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104ece:	00 
  104ecf:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  104ed6:	00 
  104ed7:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104ede:	e8 f8 bd ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ee6:	89 04 24             	mov    %eax,(%esp)
  104ee9:	e8 e7 ed ff ff       	call   103cd5 <page_ref>
  104eee:	85 c0                	test   %eax,%eax
  104ef0:	74 24                	je     104f16 <check_pgdir+0x623>
  104ef2:	c7 44 24 0c 26 6f 10 	movl   $0x106f26,0xc(%esp)
  104ef9:	00 
  104efa:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104f01:	00 
  104f02:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  104f09:	00 
  104f0a:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104f11:	e8 c5 bd ff ff       	call   100cdb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104f16:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f1b:	8b 00                	mov    (%eax),%eax
  104f1d:	89 04 24             	mov    %eax,(%esp)
  104f20:	e8 96 ed ff ff       	call   103cbb <pde2page>
  104f25:	89 04 24             	mov    %eax,(%esp)
  104f28:	e8 a8 ed ff ff       	call   103cd5 <page_ref>
  104f2d:	83 f8 01             	cmp    $0x1,%eax
  104f30:	74 24                	je     104f56 <check_pgdir+0x663>
  104f32:	c7 44 24 0c 60 6f 10 	movl   $0x106f60,0xc(%esp)
  104f39:	00 
  104f3a:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  104f41:	00 
  104f42:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104f49:	00 
  104f4a:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104f51:	e8 85 bd ff ff       	call   100cdb <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104f56:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f5b:	8b 00                	mov    (%eax),%eax
  104f5d:	89 04 24             	mov    %eax,(%esp)
  104f60:	e8 56 ed ff ff       	call   103cbb <pde2page>
  104f65:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f6c:	00 
  104f6d:	89 04 24             	mov    %eax,(%esp)
  104f70:	e8 aa ef ff ff       	call   103f1f <free_pages>
    boot_pgdir[0] = 0;
  104f75:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104f80:	c7 04 24 87 6f 10 00 	movl   $0x106f87,(%esp)
  104f87:	e8 ca b3 ff ff       	call   100356 <cprintf>
}
  104f8c:	90                   	nop
  104f8d:	89 ec                	mov    %ebp,%esp
  104f8f:	5d                   	pop    %ebp
  104f90:	c3                   	ret    

00104f91 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104f91:	55                   	push   %ebp
  104f92:	89 e5                	mov    %esp,%ebp
  104f94:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104f9e:	e9 ca 00 00 00       	jmp    10506d <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104fa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fac:	c1 e8 0c             	shr    $0xc,%eax
  104faf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104fb2:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104fb7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104fba:	72 23                	jb     104fdf <check_boot_pgdir+0x4e>
  104fbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fc3:	c7 44 24 08 cc 6b 10 	movl   $0x106bcc,0x8(%esp)
  104fca:	00 
  104fcb:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  104fd2:	00 
  104fd3:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  104fda:	e8 fc bc ff ff       	call   100cdb <__panic>
  104fdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fe2:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104fe7:	89 c2                	mov    %eax,%edx
  104fe9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104fee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ff5:	00 
  104ff6:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ffa:	89 04 24             	mov    %eax,(%esp)
  104ffd:	e8 75 f5 ff ff       	call   104577 <get_pte>
  105002:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105005:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105009:	75 24                	jne    10502f <check_boot_pgdir+0x9e>
  10500b:	c7 44 24 0c a4 6f 10 	movl   $0x106fa4,0xc(%esp)
  105012:	00 
  105013:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  10501a:	00 
  10501b:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  105022:	00 
  105023:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10502a:	e8 ac bc ff ff       	call   100cdb <__panic>
        assert(PTE_ADDR(*ptep) == i);
  10502f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105032:	8b 00                	mov    (%eax),%eax
  105034:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105039:	89 c2                	mov    %eax,%edx
  10503b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10503e:	39 c2                	cmp    %eax,%edx
  105040:	74 24                	je     105066 <check_boot_pgdir+0xd5>
  105042:	c7 44 24 0c e1 6f 10 	movl   $0x106fe1,0xc(%esp)
  105049:	00 
  10504a:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  105051:	00 
  105052:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  105059:	00 
  10505a:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  105061:	e8 75 bc ff ff       	call   100cdb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  105066:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  10506d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105070:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  105075:	39 c2                	cmp    %eax,%edx
  105077:	0f 82 26 ff ff ff    	jb     104fa3 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  10507d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105082:	05 ac 0f 00 00       	add    $0xfac,%eax
  105087:	8b 00                	mov    (%eax),%eax
  105089:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10508e:	89 c2                	mov    %eax,%edx
  105090:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105095:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105098:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10509f:	77 23                	ja     1050c4 <check_boot_pgdir+0x133>
  1050a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1050a8:	c7 44 24 08 70 6c 10 	movl   $0x106c70,0x8(%esp)
  1050af:	00 
  1050b0:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050b7:	00 
  1050b8:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1050bf:	e8 17 bc ff ff       	call   100cdb <__panic>
  1050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050c7:	05 00 00 00 40       	add    $0x40000000,%eax
  1050cc:	39 d0                	cmp    %edx,%eax
  1050ce:	74 24                	je     1050f4 <check_boot_pgdir+0x163>
  1050d0:	c7 44 24 0c f8 6f 10 	movl   $0x106ff8,0xc(%esp)
  1050d7:	00 
  1050d8:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  1050df:	00 
  1050e0:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050e7:	00 
  1050e8:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1050ef:	e8 e7 bb ff ff       	call   100cdb <__panic>

    assert(boot_pgdir[0] == 0);
  1050f4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050f9:	8b 00                	mov    (%eax),%eax
  1050fb:	85 c0                	test   %eax,%eax
  1050fd:	74 24                	je     105123 <check_boot_pgdir+0x192>
  1050ff:	c7 44 24 0c 2c 70 10 	movl   $0x10702c,0xc(%esp)
  105106:	00 
  105107:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  10510e:	00 
  10510f:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  105116:	00 
  105117:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10511e:	e8 b8 bb ff ff       	call   100cdb <__panic>

    struct Page *p;
    p = alloc_page();
  105123:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10512a:	e8 b6 ed ff ff       	call   103ee5 <alloc_pages>
  10512f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105132:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105137:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10513e:	00 
  10513f:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105146:	00 
  105147:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10514a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10514e:	89 04 24             	mov    %eax,(%esp)
  105151:	e8 62 f6 ff ff       	call   1047b8 <page_insert>
  105156:	85 c0                	test   %eax,%eax
  105158:	74 24                	je     10517e <check_boot_pgdir+0x1ed>
  10515a:	c7 44 24 0c 40 70 10 	movl   $0x107040,0xc(%esp)
  105161:	00 
  105162:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  105169:	00 
  10516a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  105171:	00 
  105172:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  105179:	e8 5d bb ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 1);
  10517e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105181:	89 04 24             	mov    %eax,(%esp)
  105184:	e8 4c eb ff ff       	call   103cd5 <page_ref>
  105189:	83 f8 01             	cmp    $0x1,%eax
  10518c:	74 24                	je     1051b2 <check_boot_pgdir+0x221>
  10518e:	c7 44 24 0c 6e 70 10 	movl   $0x10706e,0xc(%esp)
  105195:	00 
  105196:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  10519d:	00 
  10519e:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  1051a5:	00 
  1051a6:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1051ad:	e8 29 bb ff ff       	call   100cdb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1051b2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1051b7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1051be:	00 
  1051bf:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1051c6:	00 
  1051c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1051ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  1051ce:	89 04 24             	mov    %eax,(%esp)
  1051d1:	e8 e2 f5 ff ff       	call   1047b8 <page_insert>
  1051d6:	85 c0                	test   %eax,%eax
  1051d8:	74 24                	je     1051fe <check_boot_pgdir+0x26d>
  1051da:	c7 44 24 0c 80 70 10 	movl   $0x107080,0xc(%esp)
  1051e1:	00 
  1051e2:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  1051e9:	00 
  1051ea:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  1051f1:	00 
  1051f2:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1051f9:	e8 dd ba ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 2);
  1051fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105201:	89 04 24             	mov    %eax,(%esp)
  105204:	e8 cc ea ff ff       	call   103cd5 <page_ref>
  105209:	83 f8 02             	cmp    $0x2,%eax
  10520c:	74 24                	je     105232 <check_boot_pgdir+0x2a1>
  10520e:	c7 44 24 0c b7 70 10 	movl   $0x1070b7,0xc(%esp)
  105215:	00 
  105216:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  10521d:	00 
  10521e:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  105225:	00 
  105226:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  10522d:	e8 a9 ba ff ff       	call   100cdb <__panic>

    const char *str = "ucore: Hello world!!";
  105232:	c7 45 e8 c8 70 10 00 	movl   $0x1070c8,-0x18(%ebp)
    strcpy((void *)0x100, str);
  105239:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10523c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105240:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105247:	e8 fc 09 00 00       	call   105c48 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  10524c:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105253:	00 
  105254:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10525b:	e8 60 0a 00 00       	call   105cc0 <strcmp>
  105260:	85 c0                	test   %eax,%eax
  105262:	74 24                	je     105288 <check_boot_pgdir+0x2f7>
  105264:	c7 44 24 0c e0 70 10 	movl   $0x1070e0,0xc(%esp)
  10526b:	00 
  10526c:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  105273:	00 
  105274:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  10527b:	00 
  10527c:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  105283:	e8 53 ba ff ff       	call   100cdb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105288:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10528b:	89 04 24             	mov    %eax,(%esp)
  10528e:	e8 92 e9 ff ff       	call   103c25 <page2kva>
  105293:	05 00 01 00 00       	add    $0x100,%eax
  105298:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10529b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1052a2:	e8 47 09 00 00       	call   105bee <strlen>
  1052a7:	85 c0                	test   %eax,%eax
  1052a9:	74 24                	je     1052cf <check_boot_pgdir+0x33e>
  1052ab:	c7 44 24 0c 18 71 10 	movl   $0x107118,0xc(%esp)
  1052b2:	00 
  1052b3:	c7 44 24 08 b9 6c 10 	movl   $0x106cb9,0x8(%esp)
  1052ba:	00 
  1052bb:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  1052c2:	00 
  1052c3:	c7 04 24 94 6c 10 00 	movl   $0x106c94,(%esp)
  1052ca:	e8 0c ba ff ff       	call   100cdb <__panic>

    free_page(p);
  1052cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052d6:	00 
  1052d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052da:	89 04 24             	mov    %eax,(%esp)
  1052dd:	e8 3d ec ff ff       	call   103f1f <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1052e2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1052e7:	8b 00                	mov    (%eax),%eax
  1052e9:	89 04 24             	mov    %eax,(%esp)
  1052ec:	e8 ca e9 ff ff       	call   103cbb <pde2page>
  1052f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052f8:	00 
  1052f9:	89 04 24             	mov    %eax,(%esp)
  1052fc:	e8 1e ec ff ff       	call   103f1f <free_pages>
    boot_pgdir[0] = 0;
  105301:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105306:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10530c:	c7 04 24 3c 71 10 00 	movl   $0x10713c,(%esp)
  105313:	e8 3e b0 ff ff       	call   100356 <cprintf>
}
  105318:	90                   	nop
  105319:	89 ec                	mov    %ebp,%esp
  10531b:	5d                   	pop    %ebp
  10531c:	c3                   	ret    

0010531d <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  10531d:	55                   	push   %ebp
  10531e:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105320:	8b 45 08             	mov    0x8(%ebp),%eax
  105323:	83 e0 04             	and    $0x4,%eax
  105326:	85 c0                	test   %eax,%eax
  105328:	74 04                	je     10532e <perm2str+0x11>
  10532a:	b0 75                	mov    $0x75,%al
  10532c:	eb 02                	jmp    105330 <perm2str+0x13>
  10532e:	b0 2d                	mov    $0x2d,%al
  105330:	a2 28 cf 11 00       	mov    %al,0x11cf28
    str[1] = 'r';
  105335:	c6 05 29 cf 11 00 72 	movb   $0x72,0x11cf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10533c:	8b 45 08             	mov    0x8(%ebp),%eax
  10533f:	83 e0 02             	and    $0x2,%eax
  105342:	85 c0                	test   %eax,%eax
  105344:	74 04                	je     10534a <perm2str+0x2d>
  105346:	b0 77                	mov    $0x77,%al
  105348:	eb 02                	jmp    10534c <perm2str+0x2f>
  10534a:	b0 2d                	mov    $0x2d,%al
  10534c:	a2 2a cf 11 00       	mov    %al,0x11cf2a
    str[3] = '\0';
  105351:	c6 05 2b cf 11 00 00 	movb   $0x0,0x11cf2b
    return str;
  105358:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
}
  10535d:	5d                   	pop    %ebp
  10535e:	c3                   	ret    

0010535f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  10535f:	55                   	push   %ebp
  105360:	89 e5                	mov    %esp,%ebp
  105362:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105365:	8b 45 10             	mov    0x10(%ebp),%eax
  105368:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10536b:	72 0d                	jb     10537a <get_pgtable_items+0x1b>
        return 0;
  10536d:	b8 00 00 00 00       	mov    $0x0,%eax
  105372:	e9 98 00 00 00       	jmp    10540f <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  105377:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10537a:	8b 45 10             	mov    0x10(%ebp),%eax
  10537d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105380:	73 18                	jae    10539a <get_pgtable_items+0x3b>
  105382:	8b 45 10             	mov    0x10(%ebp),%eax
  105385:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10538c:	8b 45 14             	mov    0x14(%ebp),%eax
  10538f:	01 d0                	add    %edx,%eax
  105391:	8b 00                	mov    (%eax),%eax
  105393:	83 e0 01             	and    $0x1,%eax
  105396:	85 c0                	test   %eax,%eax
  105398:	74 dd                	je     105377 <get_pgtable_items+0x18>
    }
    if (start < right) {
  10539a:	8b 45 10             	mov    0x10(%ebp),%eax
  10539d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053a0:	73 68                	jae    10540a <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1053a2:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1053a6:	74 08                	je     1053b0 <get_pgtable_items+0x51>
            *left_store = start;
  1053a8:	8b 45 18             	mov    0x18(%ebp),%eax
  1053ab:	8b 55 10             	mov    0x10(%ebp),%edx
  1053ae:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1053b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1053b3:	8d 50 01             	lea    0x1(%eax),%edx
  1053b6:	89 55 10             	mov    %edx,0x10(%ebp)
  1053b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1053c0:	8b 45 14             	mov    0x14(%ebp),%eax
  1053c3:	01 d0                	add    %edx,%eax
  1053c5:	8b 00                	mov    (%eax),%eax
  1053c7:	83 e0 07             	and    $0x7,%eax
  1053ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1053cd:	eb 03                	jmp    1053d2 <get_pgtable_items+0x73>
            start ++;
  1053cf:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1053d2:	8b 45 10             	mov    0x10(%ebp),%eax
  1053d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053d8:	73 1d                	jae    1053f7 <get_pgtable_items+0x98>
  1053da:	8b 45 10             	mov    0x10(%ebp),%eax
  1053dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1053e4:	8b 45 14             	mov    0x14(%ebp),%eax
  1053e7:	01 d0                	add    %edx,%eax
  1053e9:	8b 00                	mov    (%eax),%eax
  1053eb:	83 e0 07             	and    $0x7,%eax
  1053ee:	89 c2                	mov    %eax,%edx
  1053f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1053f3:	39 c2                	cmp    %eax,%edx
  1053f5:	74 d8                	je     1053cf <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  1053f7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1053fb:	74 08                	je     105405 <get_pgtable_items+0xa6>
            *right_store = start;
  1053fd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105400:	8b 55 10             	mov    0x10(%ebp),%edx
  105403:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105405:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105408:	eb 05                	jmp    10540f <get_pgtable_items+0xb0>
    }
    return 0;
  10540a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10540f:	89 ec                	mov    %ebp,%esp
  105411:	5d                   	pop    %ebp
  105412:	c3                   	ret    

00105413 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105413:	55                   	push   %ebp
  105414:	89 e5                	mov    %esp,%ebp
  105416:	57                   	push   %edi
  105417:	56                   	push   %esi
  105418:	53                   	push   %ebx
  105419:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10541c:	c7 04 24 5c 71 10 00 	movl   $0x10715c,(%esp)
  105423:	e8 2e af ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  105428:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10542f:	e9 f2 00 00 00       	jmp    105526 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105437:	89 04 24             	mov    %eax,(%esp)
  10543a:	e8 de fe ff ff       	call   10531d <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10543f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105442:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  105445:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105447:	89 d6                	mov    %edx,%esi
  105449:	c1 e6 16             	shl    $0x16,%esi
  10544c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10544f:	89 d3                	mov    %edx,%ebx
  105451:	c1 e3 16             	shl    $0x16,%ebx
  105454:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105457:	89 d1                	mov    %edx,%ecx
  105459:	c1 e1 16             	shl    $0x16,%ecx
  10545c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10545f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  105462:	29 fa                	sub    %edi,%edx
  105464:	89 44 24 14          	mov    %eax,0x14(%esp)
  105468:	89 74 24 10          	mov    %esi,0x10(%esp)
  10546c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105470:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105474:	89 54 24 04          	mov    %edx,0x4(%esp)
  105478:	c7 04 24 8d 71 10 00 	movl   $0x10718d,(%esp)
  10547f:	e8 d2 ae ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  105484:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105487:	c1 e0 0a             	shl    $0xa,%eax
  10548a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10548d:	eb 50                	jmp    1054df <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10548f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105492:	89 04 24             	mov    %eax,(%esp)
  105495:	e8 83 fe ff ff       	call   10531d <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10549a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10549d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  1054a0:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1054a2:	89 d6                	mov    %edx,%esi
  1054a4:	c1 e6 0c             	shl    $0xc,%esi
  1054a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054aa:	89 d3                	mov    %edx,%ebx
  1054ac:	c1 e3 0c             	shl    $0xc,%ebx
  1054af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1054b2:	89 d1                	mov    %edx,%ecx
  1054b4:	c1 e1 0c             	shl    $0xc,%ecx
  1054b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054ba:	8b 7d d8             	mov    -0x28(%ebp),%edi
  1054bd:	29 fa                	sub    %edi,%edx
  1054bf:	89 44 24 14          	mov    %eax,0x14(%esp)
  1054c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  1054c7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1054cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1054cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1054d3:	c7 04 24 ac 71 10 00 	movl   $0x1071ac,(%esp)
  1054da:	e8 77 ae ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1054df:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1054e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1054ea:	89 d3                	mov    %edx,%ebx
  1054ec:	c1 e3 0a             	shl    $0xa,%ebx
  1054ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1054f2:	89 d1                	mov    %edx,%ecx
  1054f4:	c1 e1 0a             	shl    $0xa,%ecx
  1054f7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1054fa:	89 54 24 14          	mov    %edx,0x14(%esp)
  1054fe:	8d 55 d8             	lea    -0x28(%ebp),%edx
  105501:	89 54 24 10          	mov    %edx,0x10(%esp)
  105505:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105509:	89 44 24 08          	mov    %eax,0x8(%esp)
  10550d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  105511:	89 0c 24             	mov    %ecx,(%esp)
  105514:	e8 46 fe ff ff       	call   10535f <get_pgtable_items>
  105519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10551c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105520:	0f 85 69 ff ff ff    	jne    10548f <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105526:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10552b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10552e:	8d 55 dc             	lea    -0x24(%ebp),%edx
  105531:	89 54 24 14          	mov    %edx,0x14(%esp)
  105535:	8d 55 e0             	lea    -0x20(%ebp),%edx
  105538:	89 54 24 10          	mov    %edx,0x10(%esp)
  10553c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  105540:	89 44 24 08          	mov    %eax,0x8(%esp)
  105544:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10554b:	00 
  10554c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105553:	e8 07 fe ff ff       	call   10535f <get_pgtable_items>
  105558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10555b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10555f:	0f 85 cf fe ff ff    	jne    105434 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105565:	c7 04 24 d0 71 10 00 	movl   $0x1071d0,(%esp)
  10556c:	e8 e5 ad ff ff       	call   100356 <cprintf>
}
  105571:	90                   	nop
  105572:	83 c4 4c             	add    $0x4c,%esp
  105575:	5b                   	pop    %ebx
  105576:	5e                   	pop    %esi
  105577:	5f                   	pop    %edi
  105578:	5d                   	pop    %ebp
  105579:	c3                   	ret    

0010557a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10557a:	55                   	push   %ebp
  10557b:	89 e5                	mov    %esp,%ebp
  10557d:	83 ec 58             	sub    $0x58,%esp
  105580:	8b 45 10             	mov    0x10(%ebp),%eax
  105583:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105586:	8b 45 14             	mov    0x14(%ebp),%eax
  105589:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10558c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10558f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105592:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105595:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105598:	8b 45 18             	mov    0x18(%ebp),%eax
  10559b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10559e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1055a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1055a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1055a7:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1055aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1055b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1055b4:	74 1c                	je     1055d2 <printnum+0x58>
  1055b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055b9:	ba 00 00 00 00       	mov    $0x0,%edx
  1055be:	f7 75 e4             	divl   -0x1c(%ebp)
  1055c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1055c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055c7:	ba 00 00 00 00       	mov    $0x0,%edx
  1055cc:	f7 75 e4             	divl   -0x1c(%ebp)
  1055cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1055d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1055d8:	f7 75 e4             	divl   -0x1c(%ebp)
  1055db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1055de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1055e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1055e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1055ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1055ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1055f0:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1055f3:	8b 45 18             	mov    0x18(%ebp),%eax
  1055f6:	ba 00 00 00 00       	mov    $0x0,%edx
  1055fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1055fe:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105601:	19 d1                	sbb    %edx,%ecx
  105603:	72 4c                	jb     105651 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  105605:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105608:	8d 50 ff             	lea    -0x1(%eax),%edx
  10560b:	8b 45 20             	mov    0x20(%ebp),%eax
  10560e:	89 44 24 18          	mov    %eax,0x18(%esp)
  105612:	89 54 24 14          	mov    %edx,0x14(%esp)
  105616:	8b 45 18             	mov    0x18(%ebp),%eax
  105619:	89 44 24 10          	mov    %eax,0x10(%esp)
  10561d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105620:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105623:	89 44 24 08          	mov    %eax,0x8(%esp)
  105627:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10562b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10562e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105632:	8b 45 08             	mov    0x8(%ebp),%eax
  105635:	89 04 24             	mov    %eax,(%esp)
  105638:	e8 3d ff ff ff       	call   10557a <printnum>
  10563d:	eb 1b                	jmp    10565a <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10563f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105642:	89 44 24 04          	mov    %eax,0x4(%esp)
  105646:	8b 45 20             	mov    0x20(%ebp),%eax
  105649:	89 04 24             	mov    %eax,(%esp)
  10564c:	8b 45 08             	mov    0x8(%ebp),%eax
  10564f:	ff d0                	call   *%eax
        while (-- width > 0)
  105651:	ff 4d 1c             	decl   0x1c(%ebp)
  105654:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105658:	7f e5                	jg     10563f <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10565a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10565d:	05 84 72 10 00       	add    $0x107284,%eax
  105662:	0f b6 00             	movzbl (%eax),%eax
  105665:	0f be c0             	movsbl %al,%eax
  105668:	8b 55 0c             	mov    0xc(%ebp),%edx
  10566b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10566f:	89 04 24             	mov    %eax,(%esp)
  105672:	8b 45 08             	mov    0x8(%ebp),%eax
  105675:	ff d0                	call   *%eax
}
  105677:	90                   	nop
  105678:	89 ec                	mov    %ebp,%esp
  10567a:	5d                   	pop    %ebp
  10567b:	c3                   	ret    

0010567c <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  10567c:	55                   	push   %ebp
  10567d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10567f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105683:	7e 14                	jle    105699 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105685:	8b 45 08             	mov    0x8(%ebp),%eax
  105688:	8b 00                	mov    (%eax),%eax
  10568a:	8d 48 08             	lea    0x8(%eax),%ecx
  10568d:	8b 55 08             	mov    0x8(%ebp),%edx
  105690:	89 0a                	mov    %ecx,(%edx)
  105692:	8b 50 04             	mov    0x4(%eax),%edx
  105695:	8b 00                	mov    (%eax),%eax
  105697:	eb 30                	jmp    1056c9 <getuint+0x4d>
    }
    else if (lflag) {
  105699:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10569d:	74 16                	je     1056b5 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10569f:	8b 45 08             	mov    0x8(%ebp),%eax
  1056a2:	8b 00                	mov    (%eax),%eax
  1056a4:	8d 48 04             	lea    0x4(%eax),%ecx
  1056a7:	8b 55 08             	mov    0x8(%ebp),%edx
  1056aa:	89 0a                	mov    %ecx,(%edx)
  1056ac:	8b 00                	mov    (%eax),%eax
  1056ae:	ba 00 00 00 00       	mov    $0x0,%edx
  1056b3:	eb 14                	jmp    1056c9 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1056b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b8:	8b 00                	mov    (%eax),%eax
  1056ba:	8d 48 04             	lea    0x4(%eax),%ecx
  1056bd:	8b 55 08             	mov    0x8(%ebp),%edx
  1056c0:	89 0a                	mov    %ecx,(%edx)
  1056c2:	8b 00                	mov    (%eax),%eax
  1056c4:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1056c9:	5d                   	pop    %ebp
  1056ca:	c3                   	ret    

001056cb <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1056cb:	55                   	push   %ebp
  1056cc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1056ce:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1056d2:	7e 14                	jle    1056e8 <getint+0x1d>
        return va_arg(*ap, long long);
  1056d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1056d7:	8b 00                	mov    (%eax),%eax
  1056d9:	8d 48 08             	lea    0x8(%eax),%ecx
  1056dc:	8b 55 08             	mov    0x8(%ebp),%edx
  1056df:	89 0a                	mov    %ecx,(%edx)
  1056e1:	8b 50 04             	mov    0x4(%eax),%edx
  1056e4:	8b 00                	mov    (%eax),%eax
  1056e6:	eb 28                	jmp    105710 <getint+0x45>
    }
    else if (lflag) {
  1056e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1056ec:	74 12                	je     105700 <getint+0x35>
        return va_arg(*ap, long);
  1056ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f1:	8b 00                	mov    (%eax),%eax
  1056f3:	8d 48 04             	lea    0x4(%eax),%ecx
  1056f6:	8b 55 08             	mov    0x8(%ebp),%edx
  1056f9:	89 0a                	mov    %ecx,(%edx)
  1056fb:	8b 00                	mov    (%eax),%eax
  1056fd:	99                   	cltd   
  1056fe:	eb 10                	jmp    105710 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105700:	8b 45 08             	mov    0x8(%ebp),%eax
  105703:	8b 00                	mov    (%eax),%eax
  105705:	8d 48 04             	lea    0x4(%eax),%ecx
  105708:	8b 55 08             	mov    0x8(%ebp),%edx
  10570b:	89 0a                	mov    %ecx,(%edx)
  10570d:	8b 00                	mov    (%eax),%eax
  10570f:	99                   	cltd   
    }
}
  105710:	5d                   	pop    %ebp
  105711:	c3                   	ret    

00105712 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105712:	55                   	push   %ebp
  105713:	89 e5                	mov    %esp,%ebp
  105715:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105718:	8d 45 14             	lea    0x14(%ebp),%eax
  10571b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10571e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105721:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105725:	8b 45 10             	mov    0x10(%ebp),%eax
  105728:	89 44 24 08          	mov    %eax,0x8(%esp)
  10572c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10572f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105733:	8b 45 08             	mov    0x8(%ebp),%eax
  105736:	89 04 24             	mov    %eax,(%esp)
  105739:	e8 05 00 00 00       	call   105743 <vprintfmt>
    va_end(ap);
}
  10573e:	90                   	nop
  10573f:	89 ec                	mov    %ebp,%esp
  105741:	5d                   	pop    %ebp
  105742:	c3                   	ret    

00105743 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105743:	55                   	push   %ebp
  105744:	89 e5                	mov    %esp,%ebp
  105746:	56                   	push   %esi
  105747:	53                   	push   %ebx
  105748:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10574b:	eb 17                	jmp    105764 <vprintfmt+0x21>
            if (ch == '\0') {
  10574d:	85 db                	test   %ebx,%ebx
  10574f:	0f 84 bf 03 00 00    	je     105b14 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105755:	8b 45 0c             	mov    0xc(%ebp),%eax
  105758:	89 44 24 04          	mov    %eax,0x4(%esp)
  10575c:	89 1c 24             	mov    %ebx,(%esp)
  10575f:	8b 45 08             	mov    0x8(%ebp),%eax
  105762:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105764:	8b 45 10             	mov    0x10(%ebp),%eax
  105767:	8d 50 01             	lea    0x1(%eax),%edx
  10576a:	89 55 10             	mov    %edx,0x10(%ebp)
  10576d:	0f b6 00             	movzbl (%eax),%eax
  105770:	0f b6 d8             	movzbl %al,%ebx
  105773:	83 fb 25             	cmp    $0x25,%ebx
  105776:	75 d5                	jne    10574d <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105778:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10577c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105786:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105789:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105790:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105793:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105796:	8b 45 10             	mov    0x10(%ebp),%eax
  105799:	8d 50 01             	lea    0x1(%eax),%edx
  10579c:	89 55 10             	mov    %edx,0x10(%ebp)
  10579f:	0f b6 00             	movzbl (%eax),%eax
  1057a2:	0f b6 d8             	movzbl %al,%ebx
  1057a5:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1057a8:	83 f8 55             	cmp    $0x55,%eax
  1057ab:	0f 87 37 03 00 00    	ja     105ae8 <vprintfmt+0x3a5>
  1057b1:	8b 04 85 a8 72 10 00 	mov    0x1072a8(,%eax,4),%eax
  1057b8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1057ba:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1057be:	eb d6                	jmp    105796 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1057c0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1057c4:	eb d0                	jmp    105796 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1057c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1057cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1057d0:	89 d0                	mov    %edx,%eax
  1057d2:	c1 e0 02             	shl    $0x2,%eax
  1057d5:	01 d0                	add    %edx,%eax
  1057d7:	01 c0                	add    %eax,%eax
  1057d9:	01 d8                	add    %ebx,%eax
  1057db:	83 e8 30             	sub    $0x30,%eax
  1057de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1057e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1057e4:	0f b6 00             	movzbl (%eax),%eax
  1057e7:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1057ea:	83 fb 2f             	cmp    $0x2f,%ebx
  1057ed:	7e 38                	jle    105827 <vprintfmt+0xe4>
  1057ef:	83 fb 39             	cmp    $0x39,%ebx
  1057f2:	7f 33                	jg     105827 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  1057f4:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1057f7:	eb d4                	jmp    1057cd <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1057f9:	8b 45 14             	mov    0x14(%ebp),%eax
  1057fc:	8d 50 04             	lea    0x4(%eax),%edx
  1057ff:	89 55 14             	mov    %edx,0x14(%ebp)
  105802:	8b 00                	mov    (%eax),%eax
  105804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105807:	eb 1f                	jmp    105828 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105809:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10580d:	79 87                	jns    105796 <vprintfmt+0x53>
                width = 0;
  10580f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105816:	e9 7b ff ff ff       	jmp    105796 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  10581b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105822:	e9 6f ff ff ff       	jmp    105796 <vprintfmt+0x53>
            goto process_precision;
  105827:	90                   	nop

        process_precision:
            if (width < 0)
  105828:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10582c:	0f 89 64 ff ff ff    	jns    105796 <vprintfmt+0x53>
                width = precision, precision = -1;
  105832:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105835:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105838:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10583f:	e9 52 ff ff ff       	jmp    105796 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105844:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105847:	e9 4a ff ff ff       	jmp    105796 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10584c:	8b 45 14             	mov    0x14(%ebp),%eax
  10584f:	8d 50 04             	lea    0x4(%eax),%edx
  105852:	89 55 14             	mov    %edx,0x14(%ebp)
  105855:	8b 00                	mov    (%eax),%eax
  105857:	8b 55 0c             	mov    0xc(%ebp),%edx
  10585a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10585e:	89 04 24             	mov    %eax,(%esp)
  105861:	8b 45 08             	mov    0x8(%ebp),%eax
  105864:	ff d0                	call   *%eax
            break;
  105866:	e9 a4 02 00 00       	jmp    105b0f <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10586b:	8b 45 14             	mov    0x14(%ebp),%eax
  10586e:	8d 50 04             	lea    0x4(%eax),%edx
  105871:	89 55 14             	mov    %edx,0x14(%ebp)
  105874:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105876:	85 db                	test   %ebx,%ebx
  105878:	79 02                	jns    10587c <vprintfmt+0x139>
                err = -err;
  10587a:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10587c:	83 fb 06             	cmp    $0x6,%ebx
  10587f:	7f 0b                	jg     10588c <vprintfmt+0x149>
  105881:	8b 34 9d 68 72 10 00 	mov    0x107268(,%ebx,4),%esi
  105888:	85 f6                	test   %esi,%esi
  10588a:	75 23                	jne    1058af <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  10588c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105890:	c7 44 24 08 95 72 10 	movl   $0x107295,0x8(%esp)
  105897:	00 
  105898:	8b 45 0c             	mov    0xc(%ebp),%eax
  10589b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10589f:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a2:	89 04 24             	mov    %eax,(%esp)
  1058a5:	e8 68 fe ff ff       	call   105712 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1058aa:	e9 60 02 00 00       	jmp    105b0f <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  1058af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1058b3:	c7 44 24 08 9e 72 10 	movl   $0x10729e,0x8(%esp)
  1058ba:	00 
  1058bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1058c5:	89 04 24             	mov    %eax,(%esp)
  1058c8:	e8 45 fe ff ff       	call   105712 <printfmt>
            break;
  1058cd:	e9 3d 02 00 00       	jmp    105b0f <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1058d2:	8b 45 14             	mov    0x14(%ebp),%eax
  1058d5:	8d 50 04             	lea    0x4(%eax),%edx
  1058d8:	89 55 14             	mov    %edx,0x14(%ebp)
  1058db:	8b 30                	mov    (%eax),%esi
  1058dd:	85 f6                	test   %esi,%esi
  1058df:	75 05                	jne    1058e6 <vprintfmt+0x1a3>
                p = "(null)";
  1058e1:	be a1 72 10 00       	mov    $0x1072a1,%esi
            }
            if (width > 0 && padc != '-') {
  1058e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1058ea:	7e 76                	jle    105962 <vprintfmt+0x21f>
  1058ec:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1058f0:	74 70                	je     105962 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1058f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058f9:	89 34 24             	mov    %esi,(%esp)
  1058fc:	e8 16 03 00 00       	call   105c17 <strnlen>
  105901:	89 c2                	mov    %eax,%edx
  105903:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105906:	29 d0                	sub    %edx,%eax
  105908:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10590b:	eb 16                	jmp    105923 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  10590d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105911:	8b 55 0c             	mov    0xc(%ebp),%edx
  105914:	89 54 24 04          	mov    %edx,0x4(%esp)
  105918:	89 04 24             	mov    %eax,(%esp)
  10591b:	8b 45 08             	mov    0x8(%ebp),%eax
  10591e:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105920:	ff 4d e8             	decl   -0x18(%ebp)
  105923:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105927:	7f e4                	jg     10590d <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105929:	eb 37                	jmp    105962 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  10592b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10592f:	74 1f                	je     105950 <vprintfmt+0x20d>
  105931:	83 fb 1f             	cmp    $0x1f,%ebx
  105934:	7e 05                	jle    10593b <vprintfmt+0x1f8>
  105936:	83 fb 7e             	cmp    $0x7e,%ebx
  105939:	7e 15                	jle    105950 <vprintfmt+0x20d>
                    putch('?', putdat);
  10593b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10593e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105942:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105949:	8b 45 08             	mov    0x8(%ebp),%eax
  10594c:	ff d0                	call   *%eax
  10594e:	eb 0f                	jmp    10595f <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105950:	8b 45 0c             	mov    0xc(%ebp),%eax
  105953:	89 44 24 04          	mov    %eax,0x4(%esp)
  105957:	89 1c 24             	mov    %ebx,(%esp)
  10595a:	8b 45 08             	mov    0x8(%ebp),%eax
  10595d:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10595f:	ff 4d e8             	decl   -0x18(%ebp)
  105962:	89 f0                	mov    %esi,%eax
  105964:	8d 70 01             	lea    0x1(%eax),%esi
  105967:	0f b6 00             	movzbl (%eax),%eax
  10596a:	0f be d8             	movsbl %al,%ebx
  10596d:	85 db                	test   %ebx,%ebx
  10596f:	74 27                	je     105998 <vprintfmt+0x255>
  105971:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105975:	78 b4                	js     10592b <vprintfmt+0x1e8>
  105977:	ff 4d e4             	decl   -0x1c(%ebp)
  10597a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10597e:	79 ab                	jns    10592b <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105980:	eb 16                	jmp    105998 <vprintfmt+0x255>
                putch(' ', putdat);
  105982:	8b 45 0c             	mov    0xc(%ebp),%eax
  105985:	89 44 24 04          	mov    %eax,0x4(%esp)
  105989:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105990:	8b 45 08             	mov    0x8(%ebp),%eax
  105993:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105995:	ff 4d e8             	decl   -0x18(%ebp)
  105998:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10599c:	7f e4                	jg     105982 <vprintfmt+0x23f>
            }
            break;
  10599e:	e9 6c 01 00 00       	jmp    105b0f <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1059a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059aa:	8d 45 14             	lea    0x14(%ebp),%eax
  1059ad:	89 04 24             	mov    %eax,(%esp)
  1059b0:	e8 16 fd ff ff       	call   1056cb <getint>
  1059b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1059bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059c1:	85 d2                	test   %edx,%edx
  1059c3:	79 26                	jns    1059eb <vprintfmt+0x2a8>
                putch('-', putdat);
  1059c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1059d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d6:	ff d0                	call   *%eax
                num = -(long long)num;
  1059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059de:	f7 d8                	neg    %eax
  1059e0:	83 d2 00             	adc    $0x0,%edx
  1059e3:	f7 da                	neg    %edx
  1059e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1059eb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1059f2:	e9 a8 00 00 00       	jmp    105a9f <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1059f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059fe:	8d 45 14             	lea    0x14(%ebp),%eax
  105a01:	89 04 24             	mov    %eax,(%esp)
  105a04:	e8 73 fc ff ff       	call   10567c <getuint>
  105a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105a0f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105a16:	e9 84 00 00 00       	jmp    105a9f <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105a1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a22:	8d 45 14             	lea    0x14(%ebp),%eax
  105a25:	89 04 24             	mov    %eax,(%esp)
  105a28:	e8 4f fc ff ff       	call   10567c <getuint>
  105a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a30:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105a33:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105a3a:	eb 63                	jmp    105a9f <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a43:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  105a4d:	ff d0                	call   *%eax
            putch('x', putdat);
  105a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a56:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  105a60:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105a62:	8b 45 14             	mov    0x14(%ebp),%eax
  105a65:	8d 50 04             	lea    0x4(%eax),%edx
  105a68:	89 55 14             	mov    %edx,0x14(%ebp)
  105a6b:	8b 00                	mov    (%eax),%eax
  105a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105a77:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105a7e:	eb 1f                	jmp    105a9f <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a87:	8d 45 14             	lea    0x14(%ebp),%eax
  105a8a:	89 04 24             	mov    %eax,(%esp)
  105a8d:	e8 ea fb ff ff       	call   10567c <getuint>
  105a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a95:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105a98:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105a9f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105aa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105aa6:	89 54 24 18          	mov    %edx,0x18(%esp)
  105aaa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105aad:	89 54 24 14          	mov    %edx,0x14(%esp)
  105ab1:	89 44 24 10          	mov    %eax,0x10(%esp)
  105ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  105abf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aca:	8b 45 08             	mov    0x8(%ebp),%eax
  105acd:	89 04 24             	mov    %eax,(%esp)
  105ad0:	e8 a5 fa ff ff       	call   10557a <printnum>
            break;
  105ad5:	eb 38                	jmp    105b0f <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ada:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ade:	89 1c 24             	mov    %ebx,(%esp)
  105ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae4:	ff d0                	call   *%eax
            break;
  105ae6:	eb 27                	jmp    105b0f <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105af6:	8b 45 08             	mov    0x8(%ebp),%eax
  105af9:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105afb:	ff 4d 10             	decl   0x10(%ebp)
  105afe:	eb 03                	jmp    105b03 <vprintfmt+0x3c0>
  105b00:	ff 4d 10             	decl   0x10(%ebp)
  105b03:	8b 45 10             	mov    0x10(%ebp),%eax
  105b06:	48                   	dec    %eax
  105b07:	0f b6 00             	movzbl (%eax),%eax
  105b0a:	3c 25                	cmp    $0x25,%al
  105b0c:	75 f2                	jne    105b00 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105b0e:	90                   	nop
    while (1) {
  105b0f:	e9 37 fc ff ff       	jmp    10574b <vprintfmt+0x8>
                return;
  105b14:	90                   	nop
        }
    }
}
  105b15:	83 c4 40             	add    $0x40,%esp
  105b18:	5b                   	pop    %ebx
  105b19:	5e                   	pop    %esi
  105b1a:	5d                   	pop    %ebp
  105b1b:	c3                   	ret    

00105b1c <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105b1c:	55                   	push   %ebp
  105b1d:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b22:	8b 40 08             	mov    0x8(%eax),%eax
  105b25:	8d 50 01             	lea    0x1(%eax),%edx
  105b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b2b:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b31:	8b 10                	mov    (%eax),%edx
  105b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b36:	8b 40 04             	mov    0x4(%eax),%eax
  105b39:	39 c2                	cmp    %eax,%edx
  105b3b:	73 12                	jae    105b4f <sprintputch+0x33>
        *b->buf ++ = ch;
  105b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b40:	8b 00                	mov    (%eax),%eax
  105b42:	8d 48 01             	lea    0x1(%eax),%ecx
  105b45:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b48:	89 0a                	mov    %ecx,(%edx)
  105b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  105b4d:	88 10                	mov    %dl,(%eax)
    }
}
  105b4f:	90                   	nop
  105b50:	5d                   	pop    %ebp
  105b51:	c3                   	ret    

00105b52 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105b52:	55                   	push   %ebp
  105b53:	89 e5                	mov    %esp,%ebp
  105b55:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105b58:	8d 45 14             	lea    0x14(%ebp),%eax
  105b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105b65:	8b 45 10             	mov    0x10(%ebp),%eax
  105b68:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b73:	8b 45 08             	mov    0x8(%ebp),%eax
  105b76:	89 04 24             	mov    %eax,(%esp)
  105b79:	e8 0a 00 00 00       	call   105b88 <vsnprintf>
  105b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105b84:	89 ec                	mov    %ebp,%esp
  105b86:	5d                   	pop    %ebp
  105b87:	c3                   	ret    

00105b88 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105b88:	55                   	push   %ebp
  105b89:	89 e5                	mov    %esp,%ebp
  105b8b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  105b91:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b97:	8d 50 ff             	lea    -0x1(%eax),%edx
  105b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9d:	01 d0                	add    %edx,%eax
  105b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ba2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105ba9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105bad:	74 0a                	je     105bb9 <vsnprintf+0x31>
  105baf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bb5:	39 c2                	cmp    %eax,%edx
  105bb7:	76 07                	jbe    105bc0 <vsnprintf+0x38>
        return -E_INVAL;
  105bb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105bbe:	eb 2a                	jmp    105bea <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105bc0:	8b 45 14             	mov    0x14(%ebp),%eax
  105bc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  105bca:	89 44 24 08          	mov    %eax,0x8(%esp)
  105bce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd5:	c7 04 24 1c 5b 10 00 	movl   $0x105b1c,(%esp)
  105bdc:	e8 62 fb ff ff       	call   105743 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105be4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105bea:	89 ec                	mov    %ebp,%esp
  105bec:	5d                   	pop    %ebp
  105bed:	c3                   	ret    

00105bee <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105bee:	55                   	push   %ebp
  105bef:	89 e5                	mov    %esp,%ebp
  105bf1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105bf4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105bfb:	eb 03                	jmp    105c00 <strlen+0x12>
        cnt ++;
  105bfd:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105c00:	8b 45 08             	mov    0x8(%ebp),%eax
  105c03:	8d 50 01             	lea    0x1(%eax),%edx
  105c06:	89 55 08             	mov    %edx,0x8(%ebp)
  105c09:	0f b6 00             	movzbl (%eax),%eax
  105c0c:	84 c0                	test   %al,%al
  105c0e:	75 ed                	jne    105bfd <strlen+0xf>
    }
    return cnt;
  105c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105c13:	89 ec                	mov    %ebp,%esp
  105c15:	5d                   	pop    %ebp
  105c16:	c3                   	ret    

00105c17 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105c17:	55                   	push   %ebp
  105c18:	89 e5                	mov    %esp,%ebp
  105c1a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105c1d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105c24:	eb 03                	jmp    105c29 <strnlen+0x12>
        cnt ++;
  105c26:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105c2c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105c2f:	73 10                	jae    105c41 <strnlen+0x2a>
  105c31:	8b 45 08             	mov    0x8(%ebp),%eax
  105c34:	8d 50 01             	lea    0x1(%eax),%edx
  105c37:	89 55 08             	mov    %edx,0x8(%ebp)
  105c3a:	0f b6 00             	movzbl (%eax),%eax
  105c3d:	84 c0                	test   %al,%al
  105c3f:	75 e5                	jne    105c26 <strnlen+0xf>
    }
    return cnt;
  105c41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105c44:	89 ec                	mov    %ebp,%esp
  105c46:	5d                   	pop    %ebp
  105c47:	c3                   	ret    

00105c48 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105c48:	55                   	push   %ebp
  105c49:	89 e5                	mov    %esp,%ebp
  105c4b:	57                   	push   %edi
  105c4c:	56                   	push   %esi
  105c4d:	83 ec 20             	sub    $0x20,%esp
  105c50:	8b 45 08             	mov    0x8(%ebp),%eax
  105c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105c5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c62:	89 d1                	mov    %edx,%ecx
  105c64:	89 c2                	mov    %eax,%edx
  105c66:	89 ce                	mov    %ecx,%esi
  105c68:	89 d7                	mov    %edx,%edi
  105c6a:	ac                   	lods   %ds:(%esi),%al
  105c6b:	aa                   	stos   %al,%es:(%edi)
  105c6c:	84 c0                	test   %al,%al
  105c6e:	75 fa                	jne    105c6a <strcpy+0x22>
  105c70:	89 fa                	mov    %edi,%edx
  105c72:	89 f1                	mov    %esi,%ecx
  105c74:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105c77:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105c80:	83 c4 20             	add    $0x20,%esp
  105c83:	5e                   	pop    %esi
  105c84:	5f                   	pop    %edi
  105c85:	5d                   	pop    %ebp
  105c86:	c3                   	ret    

00105c87 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105c87:	55                   	push   %ebp
  105c88:	89 e5                	mov    %esp,%ebp
  105c8a:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c90:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105c93:	eb 1e                	jmp    105cb3 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c98:	0f b6 10             	movzbl (%eax),%edx
  105c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105c9e:	88 10                	mov    %dl,(%eax)
  105ca0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105ca3:	0f b6 00             	movzbl (%eax),%eax
  105ca6:	84 c0                	test   %al,%al
  105ca8:	74 03                	je     105cad <strncpy+0x26>
            src ++;
  105caa:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105cad:	ff 45 fc             	incl   -0x4(%ebp)
  105cb0:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  105cb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105cb7:	75 dc                	jne    105c95 <strncpy+0xe>
    }
    return dst;
  105cb9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105cbc:	89 ec                	mov    %ebp,%esp
  105cbe:	5d                   	pop    %ebp
  105cbf:	c3                   	ret    

00105cc0 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105cc0:	55                   	push   %ebp
  105cc1:	89 e5                	mov    %esp,%ebp
  105cc3:	57                   	push   %edi
  105cc4:	56                   	push   %esi
  105cc5:	83 ec 20             	sub    $0x20,%esp
  105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105cd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cda:	89 d1                	mov    %edx,%ecx
  105cdc:	89 c2                	mov    %eax,%edx
  105cde:	89 ce                	mov    %ecx,%esi
  105ce0:	89 d7                	mov    %edx,%edi
  105ce2:	ac                   	lods   %ds:(%esi),%al
  105ce3:	ae                   	scas   %es:(%edi),%al
  105ce4:	75 08                	jne    105cee <strcmp+0x2e>
  105ce6:	84 c0                	test   %al,%al
  105ce8:	75 f8                	jne    105ce2 <strcmp+0x22>
  105cea:	31 c0                	xor    %eax,%eax
  105cec:	eb 04                	jmp    105cf2 <strcmp+0x32>
  105cee:	19 c0                	sbb    %eax,%eax
  105cf0:	0c 01                	or     $0x1,%al
  105cf2:	89 fa                	mov    %edi,%edx
  105cf4:	89 f1                	mov    %esi,%ecx
  105cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105cf9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105cfc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105cff:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105d02:	83 c4 20             	add    $0x20,%esp
  105d05:	5e                   	pop    %esi
  105d06:	5f                   	pop    %edi
  105d07:	5d                   	pop    %ebp
  105d08:	c3                   	ret    

00105d09 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105d09:	55                   	push   %ebp
  105d0a:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105d0c:	eb 09                	jmp    105d17 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105d0e:	ff 4d 10             	decl   0x10(%ebp)
  105d11:	ff 45 08             	incl   0x8(%ebp)
  105d14:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105d17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d1b:	74 1a                	je     105d37 <strncmp+0x2e>
  105d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d20:	0f b6 00             	movzbl (%eax),%eax
  105d23:	84 c0                	test   %al,%al
  105d25:	74 10                	je     105d37 <strncmp+0x2e>
  105d27:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2a:	0f b6 10             	movzbl (%eax),%edx
  105d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d30:	0f b6 00             	movzbl (%eax),%eax
  105d33:	38 c2                	cmp    %al,%dl
  105d35:	74 d7                	je     105d0e <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105d37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d3b:	74 18                	je     105d55 <strncmp+0x4c>
  105d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d40:	0f b6 00             	movzbl (%eax),%eax
  105d43:	0f b6 d0             	movzbl %al,%edx
  105d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d49:	0f b6 00             	movzbl (%eax),%eax
  105d4c:	0f b6 c8             	movzbl %al,%ecx
  105d4f:	89 d0                	mov    %edx,%eax
  105d51:	29 c8                	sub    %ecx,%eax
  105d53:	eb 05                	jmp    105d5a <strncmp+0x51>
  105d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105d5a:	5d                   	pop    %ebp
  105d5b:	c3                   	ret    

00105d5c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105d5c:	55                   	push   %ebp
  105d5d:	89 e5                	mov    %esp,%ebp
  105d5f:	83 ec 04             	sub    $0x4,%esp
  105d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d65:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105d68:	eb 13                	jmp    105d7d <strchr+0x21>
        if (*s == c) {
  105d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  105d6d:	0f b6 00             	movzbl (%eax),%eax
  105d70:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105d73:	75 05                	jne    105d7a <strchr+0x1e>
            return (char *)s;
  105d75:	8b 45 08             	mov    0x8(%ebp),%eax
  105d78:	eb 12                	jmp    105d8c <strchr+0x30>
        }
        s ++;
  105d7a:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d80:	0f b6 00             	movzbl (%eax),%eax
  105d83:	84 c0                	test   %al,%al
  105d85:	75 e3                	jne    105d6a <strchr+0xe>
    }
    return NULL;
  105d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105d8c:	89 ec                	mov    %ebp,%esp
  105d8e:	5d                   	pop    %ebp
  105d8f:	c3                   	ret    

00105d90 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105d90:	55                   	push   %ebp
  105d91:	89 e5                	mov    %esp,%ebp
  105d93:	83 ec 04             	sub    $0x4,%esp
  105d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d99:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105d9c:	eb 0e                	jmp    105dac <strfind+0x1c>
        if (*s == c) {
  105d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  105da1:	0f b6 00             	movzbl (%eax),%eax
  105da4:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105da7:	74 0f                	je     105db8 <strfind+0x28>
            break;
        }
        s ++;
  105da9:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105dac:	8b 45 08             	mov    0x8(%ebp),%eax
  105daf:	0f b6 00             	movzbl (%eax),%eax
  105db2:	84 c0                	test   %al,%al
  105db4:	75 e8                	jne    105d9e <strfind+0xe>
  105db6:	eb 01                	jmp    105db9 <strfind+0x29>
            break;
  105db8:	90                   	nop
    }
    return (char *)s;
  105db9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105dbc:	89 ec                	mov    %ebp,%esp
  105dbe:	5d                   	pop    %ebp
  105dbf:	c3                   	ret    

00105dc0 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105dc0:	55                   	push   %ebp
  105dc1:	89 e5                	mov    %esp,%ebp
  105dc3:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105dc6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105dcd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105dd4:	eb 03                	jmp    105dd9 <strtol+0x19>
        s ++;
  105dd6:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ddc:	0f b6 00             	movzbl (%eax),%eax
  105ddf:	3c 20                	cmp    $0x20,%al
  105de1:	74 f3                	je     105dd6 <strtol+0x16>
  105de3:	8b 45 08             	mov    0x8(%ebp),%eax
  105de6:	0f b6 00             	movzbl (%eax),%eax
  105de9:	3c 09                	cmp    $0x9,%al
  105deb:	74 e9                	je     105dd6 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105ded:	8b 45 08             	mov    0x8(%ebp),%eax
  105df0:	0f b6 00             	movzbl (%eax),%eax
  105df3:	3c 2b                	cmp    $0x2b,%al
  105df5:	75 05                	jne    105dfc <strtol+0x3c>
        s ++;
  105df7:	ff 45 08             	incl   0x8(%ebp)
  105dfa:	eb 14                	jmp    105e10 <strtol+0x50>
    }
    else if (*s == '-') {
  105dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  105dff:	0f b6 00             	movzbl (%eax),%eax
  105e02:	3c 2d                	cmp    $0x2d,%al
  105e04:	75 0a                	jne    105e10 <strtol+0x50>
        s ++, neg = 1;
  105e06:	ff 45 08             	incl   0x8(%ebp)
  105e09:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105e10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e14:	74 06                	je     105e1c <strtol+0x5c>
  105e16:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105e1a:	75 22                	jne    105e3e <strtol+0x7e>
  105e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  105e1f:	0f b6 00             	movzbl (%eax),%eax
  105e22:	3c 30                	cmp    $0x30,%al
  105e24:	75 18                	jne    105e3e <strtol+0x7e>
  105e26:	8b 45 08             	mov    0x8(%ebp),%eax
  105e29:	40                   	inc    %eax
  105e2a:	0f b6 00             	movzbl (%eax),%eax
  105e2d:	3c 78                	cmp    $0x78,%al
  105e2f:	75 0d                	jne    105e3e <strtol+0x7e>
        s += 2, base = 16;
  105e31:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105e35:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105e3c:	eb 29                	jmp    105e67 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105e3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e42:	75 16                	jne    105e5a <strtol+0x9a>
  105e44:	8b 45 08             	mov    0x8(%ebp),%eax
  105e47:	0f b6 00             	movzbl (%eax),%eax
  105e4a:	3c 30                	cmp    $0x30,%al
  105e4c:	75 0c                	jne    105e5a <strtol+0x9a>
        s ++, base = 8;
  105e4e:	ff 45 08             	incl   0x8(%ebp)
  105e51:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105e58:	eb 0d                	jmp    105e67 <strtol+0xa7>
    }
    else if (base == 0) {
  105e5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e5e:	75 07                	jne    105e67 <strtol+0xa7>
        base = 10;
  105e60:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105e67:	8b 45 08             	mov    0x8(%ebp),%eax
  105e6a:	0f b6 00             	movzbl (%eax),%eax
  105e6d:	3c 2f                	cmp    $0x2f,%al
  105e6f:	7e 1b                	jle    105e8c <strtol+0xcc>
  105e71:	8b 45 08             	mov    0x8(%ebp),%eax
  105e74:	0f b6 00             	movzbl (%eax),%eax
  105e77:	3c 39                	cmp    $0x39,%al
  105e79:	7f 11                	jg     105e8c <strtol+0xcc>
            dig = *s - '0';
  105e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e7e:	0f b6 00             	movzbl (%eax),%eax
  105e81:	0f be c0             	movsbl %al,%eax
  105e84:	83 e8 30             	sub    $0x30,%eax
  105e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e8a:	eb 48                	jmp    105ed4 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  105e8f:	0f b6 00             	movzbl (%eax),%eax
  105e92:	3c 60                	cmp    $0x60,%al
  105e94:	7e 1b                	jle    105eb1 <strtol+0xf1>
  105e96:	8b 45 08             	mov    0x8(%ebp),%eax
  105e99:	0f b6 00             	movzbl (%eax),%eax
  105e9c:	3c 7a                	cmp    $0x7a,%al
  105e9e:	7f 11                	jg     105eb1 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ea3:	0f b6 00             	movzbl (%eax),%eax
  105ea6:	0f be c0             	movsbl %al,%eax
  105ea9:	83 e8 57             	sub    $0x57,%eax
  105eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105eaf:	eb 23                	jmp    105ed4 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb4:	0f b6 00             	movzbl (%eax),%eax
  105eb7:	3c 40                	cmp    $0x40,%al
  105eb9:	7e 3b                	jle    105ef6 <strtol+0x136>
  105ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  105ebe:	0f b6 00             	movzbl (%eax),%eax
  105ec1:	3c 5a                	cmp    $0x5a,%al
  105ec3:	7f 31                	jg     105ef6 <strtol+0x136>
            dig = *s - 'A' + 10;
  105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec8:	0f b6 00             	movzbl (%eax),%eax
  105ecb:	0f be c0             	movsbl %al,%eax
  105ece:	83 e8 37             	sub    $0x37,%eax
  105ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ed7:	3b 45 10             	cmp    0x10(%ebp),%eax
  105eda:	7d 19                	jge    105ef5 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105edc:	ff 45 08             	incl   0x8(%ebp)
  105edf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105ee2:	0f af 45 10          	imul   0x10(%ebp),%eax
  105ee6:	89 c2                	mov    %eax,%edx
  105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105eeb:	01 d0                	add    %edx,%eax
  105eed:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105ef0:	e9 72 ff ff ff       	jmp    105e67 <strtol+0xa7>
            break;
  105ef5:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  105ef6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105efa:	74 08                	je     105f04 <strtol+0x144>
        *endptr = (char *) s;
  105efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eff:	8b 55 08             	mov    0x8(%ebp),%edx
  105f02:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105f04:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105f08:	74 07                	je     105f11 <strtol+0x151>
  105f0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f0d:	f7 d8                	neg    %eax
  105f0f:	eb 03                	jmp    105f14 <strtol+0x154>
  105f11:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105f14:	89 ec                	mov    %ebp,%esp
  105f16:	5d                   	pop    %ebp
  105f17:	c3                   	ret    

00105f18 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105f18:	55                   	push   %ebp
  105f19:	89 e5                	mov    %esp,%ebp
  105f1b:	83 ec 28             	sub    $0x28,%esp
  105f1e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  105f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f24:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105f27:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  105f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105f2e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  105f31:	88 55 f7             	mov    %dl,-0x9(%ebp)
  105f34:	8b 45 10             	mov    0x10(%ebp),%eax
  105f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105f3a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105f3d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105f41:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105f44:	89 d7                	mov    %edx,%edi
  105f46:	f3 aa                	rep stos %al,%es:(%edi)
  105f48:	89 fa                	mov    %edi,%edx
  105f4a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105f4d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105f50:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105f53:	8b 7d fc             	mov    -0x4(%ebp),%edi
  105f56:	89 ec                	mov    %ebp,%esp
  105f58:	5d                   	pop    %ebp
  105f59:	c3                   	ret    

00105f5a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105f5a:	55                   	push   %ebp
  105f5b:	89 e5                	mov    %esp,%ebp
  105f5d:	57                   	push   %edi
  105f5e:	56                   	push   %esi
  105f5f:	53                   	push   %ebx
  105f60:	83 ec 30             	sub    $0x30,%esp
  105f63:	8b 45 08             	mov    0x8(%ebp),%eax
  105f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105f6f:	8b 45 10             	mov    0x10(%ebp),%eax
  105f72:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105f7b:	73 42                	jae    105fbf <memmove+0x65>
  105f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105f89:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f8c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105f8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f92:	c1 e8 02             	shr    $0x2,%eax
  105f95:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105f97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f9d:	89 d7                	mov    %edx,%edi
  105f9f:	89 c6                	mov    %eax,%esi
  105fa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105fa3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105fa6:	83 e1 03             	and    $0x3,%ecx
  105fa9:	74 02                	je     105fad <memmove+0x53>
  105fab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105fad:	89 f0                	mov    %esi,%eax
  105faf:	89 fa                	mov    %edi,%edx
  105fb1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105fb4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105fb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  105fbd:	eb 36                	jmp    105ff5 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105fbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105fc2:	8d 50 ff             	lea    -0x1(%eax),%edx
  105fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105fc8:	01 c2                	add    %eax,%edx
  105fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105fcd:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fd3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105fd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105fd9:	89 c1                	mov    %eax,%ecx
  105fdb:	89 d8                	mov    %ebx,%eax
  105fdd:	89 d6                	mov    %edx,%esi
  105fdf:	89 c7                	mov    %eax,%edi
  105fe1:	fd                   	std    
  105fe2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105fe4:	fc                   	cld    
  105fe5:	89 f8                	mov    %edi,%eax
  105fe7:	89 f2                	mov    %esi,%edx
  105fe9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105fec:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105fef:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105ff5:	83 c4 30             	add    $0x30,%esp
  105ff8:	5b                   	pop    %ebx
  105ff9:	5e                   	pop    %esi
  105ffa:	5f                   	pop    %edi
  105ffb:	5d                   	pop    %ebp
  105ffc:	c3                   	ret    

00105ffd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105ffd:	55                   	push   %ebp
  105ffe:	89 e5                	mov    %esp,%ebp
  106000:	57                   	push   %edi
  106001:	56                   	push   %esi
  106002:	83 ec 20             	sub    $0x20,%esp
  106005:	8b 45 08             	mov    0x8(%ebp),%eax
  106008:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10600b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10600e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106011:	8b 45 10             	mov    0x10(%ebp),%eax
  106014:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106017:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10601a:	c1 e8 02             	shr    $0x2,%eax
  10601d:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10601f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106022:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106025:	89 d7                	mov    %edx,%edi
  106027:	89 c6                	mov    %eax,%esi
  106029:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10602b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10602e:	83 e1 03             	and    $0x3,%ecx
  106031:	74 02                	je     106035 <memcpy+0x38>
  106033:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106035:	89 f0                	mov    %esi,%eax
  106037:	89 fa                	mov    %edi,%edx
  106039:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10603c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10603f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106045:	83 c4 20             	add    $0x20,%esp
  106048:	5e                   	pop    %esi
  106049:	5f                   	pop    %edi
  10604a:	5d                   	pop    %ebp
  10604b:	c3                   	ret    

0010604c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10604c:	55                   	push   %ebp
  10604d:	89 e5                	mov    %esp,%ebp
  10604f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106052:	8b 45 08             	mov    0x8(%ebp),%eax
  106055:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  106058:	8b 45 0c             	mov    0xc(%ebp),%eax
  10605b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10605e:	eb 2e                	jmp    10608e <memcmp+0x42>
        if (*s1 != *s2) {
  106060:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106063:	0f b6 10             	movzbl (%eax),%edx
  106066:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106069:	0f b6 00             	movzbl (%eax),%eax
  10606c:	38 c2                	cmp    %al,%dl
  10606e:	74 18                	je     106088 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  106070:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106073:	0f b6 00             	movzbl (%eax),%eax
  106076:	0f b6 d0             	movzbl %al,%edx
  106079:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10607c:	0f b6 00             	movzbl (%eax),%eax
  10607f:	0f b6 c8             	movzbl %al,%ecx
  106082:	89 d0                	mov    %edx,%eax
  106084:	29 c8                	sub    %ecx,%eax
  106086:	eb 18                	jmp    1060a0 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  106088:	ff 45 fc             	incl   -0x4(%ebp)
  10608b:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10608e:	8b 45 10             	mov    0x10(%ebp),%eax
  106091:	8d 50 ff             	lea    -0x1(%eax),%edx
  106094:	89 55 10             	mov    %edx,0x10(%ebp)
  106097:	85 c0                	test   %eax,%eax
  106099:	75 c5                	jne    106060 <memcmp+0x14>
    }
    return 0;
  10609b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1060a0:	89 ec                	mov    %ebp,%esp
  1060a2:	5d                   	pop    %ebp
  1060a3:	c3                   	ret    
