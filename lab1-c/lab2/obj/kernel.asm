
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 11 00       	mov    $0x119000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 11 c0       	mov    %eax,0xc0119000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 11 c0       	mov    $0xc0118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c0100041:	2d 00 b0 11 c0       	sub    $0xc011b000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c0100059:	e8 c5 5c 00 00       	call   c0105d23 <memset>

    cons_init();                // init the console
c010005e:	e8 ea 15 00 00       	call   c010164d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 c0 5e 10 c0 	movl   $0xc0105ec0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 dc 5e 10 c0 	movl   $0xc0105edc,(%esp)
c0100078:	e8 d9 02 00 00       	call   c0100356 <cprintf>

    print_kerninfo();
c010007d:	e8 f7 07 00 00       	call   c0100879 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 90 00 00 00       	call   c0100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 a1 43 00 00       	call   c010442d <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 3d 17 00 00       	call   c01017ce <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 c4 18 00 00       	call   c010195a <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 11 0d 00 00       	call   c0100dac <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 8c 16 00 00       	call   c010172c <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a0:	eb fe                	jmp    c01000a0 <kern_init+0x6a>

c01000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a2:	55                   	push   %ebp
c01000a3:	89 e5                	mov    %esp,%ebp
c01000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000af:	00 
c01000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000b7:	00 
c01000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000bf:	e8 03 0c 00 00       	call   c0100cc7 <mon_backtrace>
}
c01000c4:	90                   	nop
c01000c5:	89 ec                	mov    %ebp,%esp
c01000c7:	5d                   	pop    %ebp
c01000c8:	c3                   	ret    

c01000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c9:	55                   	push   %ebp
c01000ca:	89 e5                	mov    %esp,%ebp
c01000cc:	83 ec 18             	sub    $0x18,%esp
c01000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b0 ff ff ff       	call   c01000a2 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f6:	89 ec                	mov    %ebp,%esp
c01000f8:	5d                   	pop    %ebp
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100100:	8b 45 10             	mov    0x10(%ebp),%eax
c0100103:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100107:	8b 45 08             	mov    0x8(%ebp),%eax
c010010a:	89 04 24             	mov    %eax,(%esp)
c010010d:	e8 b7 ff ff ff       	call   c01000c9 <grade_backtrace1>
}
c0100112:	90                   	nop
c0100113:	89 ec                	mov    %ebp,%esp
c0100115:	5d                   	pop    %ebp
c0100116:	c3                   	ret    

c0100117 <grade_backtrace>:

void
grade_backtrace(void) {
c0100117:	55                   	push   %ebp
c0100118:	89 e5                	mov    %esp,%ebp
c010011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011d:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100129:	ff 
c010012a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100135:	e8 c0 ff ff ff       	call   c01000fa <grade_backtrace0>
}
c010013a:	90                   	nop
c010013b:	89 ec                	mov    %ebp,%esp
c010013d:	5d                   	pop    %ebp
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 e1 5e 10 c0 	movl   $0xc0105ee1,(%esp)
c010016e:	e8 e3 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 ef 5e 10 c0 	movl   $0xc0105eef,(%esp)
c010018d:	e8 c4 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 fd 5e 10 c0 	movl   $0xc0105efd,(%esp)
c01001ac:	e8 a5 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 0b 5f 10 c0 	movl   $0xc0105f0b,(%esp)
c01001cb:	e8 86 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 19 5f 10 c0 	movl   $0xc0105f19,(%esp)
c01001ea:	e8 67 01 00 00       	call   c0100356 <cprintf>
    round ++;
c01001ef:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 b0 11 c0       	mov    %eax,0xc011b000
}
c01001fa:	90                   	nop
c01001fb:	89 ec                	mov    %ebp,%esp
c01001fd:	5d                   	pop    %ebp
c01001fe:	c3                   	ret    

c01001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ff:	55                   	push   %ebp
c0100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100208:	90                   	nop
c0100209:	5d                   	pop    %ebp
c010020a:	c3                   	ret    

c010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
c010020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100211:	e8 29 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100216:	c7 04 24 28 5f 10 c0 	movl   $0xc0105f28,(%esp)
c010021d:	e8 34 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_user();
c0100222:	e8 d8 ff ff ff       	call   c01001ff <lab1_switch_to_user>
    lab1_print_cur_status();
c0100227:	e8 13 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022c:	c7 04 24 48 5f 10 c0 	movl   $0xc0105f48,(%esp)
c0100233:	e8 1e 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_kernel();
c0100238:	e8 c8 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023d:	e8 fd fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100242:	90                   	nop
c0100243:	89 ec                	mov    %ebp,%esp
c0100245:	5d                   	pop    %ebp
c0100246:	c3                   	ret    

c0100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100247:	55                   	push   %ebp
c0100248:	89 e5                	mov    %esp,%ebp
c010024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100251:	74 13                	je     c0100266 <readline+0x1f>
        cprintf("%s", prompt);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025a:	c7 04 24 67 5f 10 c0 	movl   $0xc0105f67,(%esp)
c0100261:	e8 f0 00 00 00       	call   c0100356 <cprintf>
    }
    int i = 0, c;
c0100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010026d:	e8 73 01 00 00       	call   c01003e5 <getchar>
c0100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100279:	79 07                	jns    c0100282 <readline+0x3b>
            return NULL;
c010027b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100280:	eb 78                	jmp    c01002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100286:	7e 28                	jle    c01002b0 <readline+0x69>
c0100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010028f:	7f 1f                	jg     c01002b0 <readline+0x69>
            cputchar(c);
c0100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100294:	89 04 24             	mov    %eax,(%esp)
c0100297:	e8 e2 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010029f:	8d 50 01             	lea    0x1(%eax),%edx
c01002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a8:	88 90 20 b0 11 c0    	mov    %dl,-0x3fee4fe0(%eax)
c01002ae:	eb 45                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b4:	75 16                	jne    c01002cc <readline+0x85>
c01002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ba:	7e 10                	jle    c01002cc <readline+0x85>
            cputchar(c);
c01002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 b7 00 00 00       	call   c010037e <cputchar>
            i --;
c01002c7:	ff 4d f4             	decl   -0xc(%ebp)
c01002ca:	eb 29                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d0:	74 06                	je     c01002d8 <readline+0x91>
c01002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d6:	75 95                	jne    c010026d <readline+0x26>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 9b 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e6:	05 20 b0 11 c0       	add    $0xc011b020,%eax
c01002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ee:	b8 20 b0 11 c0       	mov    $0xc011b020,%eax
c01002f3:	eb 05                	jmp    c01002fa <readline+0xb3>
        c = getchar();
c01002f5:	e9 73 ff ff ff       	jmp    c010026d <readline+0x26>
        }
    }
}
c01002fa:	89 ec                	mov    %ebp,%esp
c01002fc:	5d                   	pop    %ebp
c01002fd:	c3                   	ret    

c01002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	89 04 24             	mov    %eax,(%esp)
c010030a:	e8 6d 13 00 00       	call   c010167c <cons_putc>
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	89 ec                	mov    %ebp,%esp
c010031f:	5d                   	pop    %ebp
c0100320:	c3                   	ret    

c0100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100321:	55                   	push   %ebp
c0100322:	89 e5                	mov    %esp,%ebp
c0100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100335:	8b 45 08             	mov    0x8(%ebp),%eax
c0100338:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100343:	c7 04 24 fe 02 10 c0 	movl   $0xc01002fe,(%esp)
c010034a:	e8 ff 51 00 00       	call   c010554e <vprintfmt>
    return cnt;
c010034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100352:	89 ec                	mov    %ebp,%esp
c0100354:	5d                   	pop    %ebp
c0100355:	c3                   	ret    

c0100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100356:	55                   	push   %ebp
c0100357:	89 e5                	mov    %esp,%ebp
c0100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100369:	8b 45 08             	mov    0x8(%ebp),%eax
c010036c:	89 04 24             	mov    %eax,(%esp)
c010036f:	e8 ad ff ff ff       	call   c0100321 <vcprintf>
c0100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	89 ec                	mov    %ebp,%esp
c010037c:	5d                   	pop    %ebp
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 ed 12 00 00       	call   c010167c <cons_putc>
}
c010038f:	90                   	nop
c0100390:	89 ec                	mov    %ebp,%esp
c0100392:	5d                   	pop    %ebp
c0100393:	c3                   	ret    

c0100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100394:	55                   	push   %ebp
c0100395:	89 e5                	mov    %esp,%ebp
c0100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a1:	eb 13                	jmp    c01003b6 <cputs+0x22>
        cputch(c, &cnt);
c01003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ae:	89 04 24             	mov    %eax,(%esp)
c01003b1:	e8 48 ff ff ff       	call   c01002fe <cputch>
    while ((c = *str ++) != '\0') {
c01003b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b9:	8d 50 01             	lea    0x1(%eax),%edx
c01003bc:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bf:	0f b6 00             	movzbl (%eax),%eax
c01003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c9:	75 d8                	jne    c01003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d9:	e8 20 ff ff ff       	call   c01002fe <cputch>
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	89 ec                	mov    %ebp,%esp
c01003e3:	5d                   	pop    %ebp
c01003e4:	c3                   	ret    

c01003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e5:	55                   	push   %ebp
c01003e6:	89 e5                	mov    %esp,%ebp
c01003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003eb:	90                   	nop
c01003ec:	e8 ca 12 00 00       	call   c01016bb <cons_getc>
c01003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f8:	74 f2                	je     c01003ec <getchar+0x7>
        /* do nothing */;
    return c;
c01003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100412:	8b 00                	mov    (%eax),%eax
c0100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041e:	e9 ca 00 00 00       	jmp    c01004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100429:	01 d0                	add    %edx,%eax
c010042b:	89 c2                	mov    %eax,%edx
c010042d:	c1 ea 1f             	shr    $0x1f,%edx
c0100430:	01 d0                	add    %edx,%eax
c0100432:	d1 f8                	sar    %eax
c0100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043d:	eb 03                	jmp    c0100442 <stab_binsearch+0x41>
            m --;
c010043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x68>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100467:	75 d6                	jne    c010043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 09                	jge    c010047a <stab_binsearch+0x79>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	40                   	inc    %eax
c0100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100478:	eb 73                	jmp    c01004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100484:	89 d0                	mov    %edx,%eax
c0100486:	01 c0                	add    %eax,%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	c1 e0 02             	shl    $0x2,%eax
c010048d:	89 c2                	mov    %eax,%edx
c010048f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100492:	01 d0                	add    %edx,%eax
c0100494:	8b 40 08             	mov    0x8(%eax),%eax
c0100497:	39 45 18             	cmp    %eax,0x18(%ebp)
c010049a:	76 11                	jbe    c01004ad <stab_binsearch+0xac>
            *region_left = m;
c010049c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a7:	40                   	inc    %eax
c01004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ab:	eb 40                	jmp    c01004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b0:	89 d0                	mov    %edx,%eax
c01004b2:	01 c0                	add    %eax,%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	c1 e0 02             	shl    $0x2,%eax
c01004b9:	89 c2                	mov    %eax,%edx
c01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01004be:	01 d0                	add    %edx,%eax
c01004c0:	8b 40 08             	mov    0x8(%eax),%eax
c01004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004c6:	73 14                	jae    c01004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	48                   	dec    %eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	eb 11                	jmp    c01004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e2:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 2a ff ff ff    	jle    c0100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010050c:	eb 3e                	jmp    c010054c <stab_binsearch+0x14b>
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 03                	jmp    c010051b <stab_binsearch+0x11a>
c0100518:	ff 4d fc             	decl   -0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100523:	7e 1f                	jle    c0100544 <stab_binsearch+0x143>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100542:	75 d4                	jne    c0100518 <stab_binsearch+0x117>
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
}
c010054c:	90                   	nop
c010054d:	89 ec                	mov    %ebp,%esp
c010054f:	5d                   	pop    %ebp
c0100550:	c3                   	ret    

c0100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100551:	55                   	push   %ebp
c0100552:	89 e5                	mov    %esp,%ebp
c0100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 00 6c 5f 10 c0    	movl   $0xc0105f6c,(%eax)
    info->eip_line = 0;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 08 6c 5f 10 c0 	movl   $0xc0105f6c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	8b 55 08             	mov    0x8(%ebp),%edx
c0100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100591:	c7 45 f4 18 72 10 c0 	movl   $0xc0107218,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100598:	c7 45 f0 60 26 11 c0 	movl   $0xc0112660,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059f:	c7 45 ec 61 26 11 c0 	movl   $0xc0112661,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a6:	c7 45 e8 cf 5b 11 c0 	movl   $0xc0115bcf,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b3:	76 0b                	jbe    c01005c0 <debuginfo_eip+0x6f>
c01005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b8:	48                   	dec    %eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x79>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 ab 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005d7:	c1 f8 02             	sar    $0x2,%eax
c01005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e0:	48                   	dec    %eax
c01005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f2:	00 
c01005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100604:	89 04 24             	mov    %eax,(%esp)
c0100607:	e8 f5 fd ff ff       	call   c0100401 <stab_binsearch>
    if (lfile == 0)
c010060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	75 0a                	jne    c010061d <debuginfo_eip+0xcc>
        return -1;
c0100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100618:	e9 58 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 b0 fd ff ff       	call   c0100401 <stab_binsearch>

    if (lfun <= rfun) {
c0100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100657:	39 c2                	cmp    %eax,%edx
c0100659:	7f 78                	jg     c01006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	89 d0                	mov    %edx,%eax
c0100662:	01 c0                	add    %eax,%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	c1 e0 02             	shl    $0x2,%eax
c0100669:	89 c2                	mov    %eax,%edx
c010066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066e:	01 d0                	add    %edx,%eax
c0100670:	8b 10                	mov    (%eax),%edx
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100678:	39 c2                	cmp    %eax,%edx
c010067a:	73 22                	jae    c010069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010067f:	89 c2                	mov    %eax,%edx
c0100681:	89 d0                	mov    %edx,%eax
c0100683:	01 c0                	add    %eax,%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	c1 e0 02             	shl    $0x2,%eax
c010068a:	89 c2                	mov    %eax,%edx
c010068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	8b 10                	mov    (%eax),%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	01 c2                	add    %eax,%edx
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 50 08             	mov    0x8(%eax),%edx
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bf:	8b 40 10             	mov    0x10(%eax),%eax
c01006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d1:	eb 15                	jmp    c01006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006eb:	8b 40 08             	mov    0x8(%eax),%eax
c01006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006f5:	00 
c01006f6:	89 04 24             	mov    %eax,(%esp)
c01006f9:	e8 9d 54 00 00       	call   c0105b9b <strfind>
c01006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100701:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100704:	29 c8                	sub    %ecx,%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010070e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100711:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010071c:	00 
c010071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100720:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 cb fc ff ff       	call   c0100401 <stab_binsearch>
    if (lline <= rline) {
c0100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	39 c2                	cmp    %eax,%edx
c010073e:	7f 23                	jg     c0100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	89 d0                	mov    %edx,%eax
c0100747:	01 c0                	add    %eax,%eax
c0100749:	01 d0                	add    %edx,%eax
c010074b:	c1 e0 02             	shl    $0x2,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100759:	89 c2                	mov    %eax,%edx
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100761:	eb 11                	jmp    c0100774 <debuginfo_eip+0x223>
        return -1;
c0100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100768:	e9 08 01 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	48                   	dec    %eax
c0100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	7c 56                	jl     c01007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100797:	3c 84                	cmp    $0x84,%al
c0100799:	74 39                	je     c01007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b4:	3c 64                	cmp    $0x64,%al
c01007b6:	75 b5                	jne    c010076d <debuginfo_eip+0x21c>
c01007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	89 d0                	mov    %edx,%eax
c01007bf:	01 c0                	add    %eax,%eax
c01007c1:	01 d0                	add    %edx,%eax
c01007c3:	c1 e0 02             	shl    $0x2,%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cb:	01 d0                	add    %edx,%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	85 c0                	test   %eax,%eax
c01007d2:	74 99                	je     c010076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007da:	39 c2                	cmp    %eax,%edx
c01007dc:	7c 42                	jl     c0100820 <debuginfo_eip+0x2cf>
c01007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e1:	89 c2                	mov    %eax,%edx
c01007e3:	89 d0                	mov    %edx,%eax
c01007e5:	01 c0                	add    %eax,%eax
c01007e7:	01 d0                	add    %edx,%eax
c01007e9:	c1 e0 02             	shl    $0x2,%eax
c01007ec:	89 c2                	mov    %eax,%edx
c01007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f1:	01 d0                	add    %edx,%eax
c01007f3:	8b 10                	mov    (%eax),%edx
c01007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 46                	jge    c0100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	40                   	inc    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100831:	eb 16                	jmp    c0100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	8b 40 14             	mov    0x14(%eax),%eax
c0100839:	8d 50 01             	lea    0x1(%eax),%edx
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100845:	40                   	inc    %eax
c0100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010084f:	39 c2                	cmp    %eax,%edx
c0100851:	7d 1d                	jge    c0100870 <debuginfo_eip+0x31f>
c0100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	89 d0                	mov    %edx,%eax
c010085a:	01 c0                	add    %eax,%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	c1 e0 02             	shl    $0x2,%eax
c0100861:	89 c2                	mov    %eax,%edx
c0100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086c:	3c a0                	cmp    $0xa0,%al
c010086e:	74 c3                	je     c0100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100875:	89 ec                	mov    %ebp,%esp
c0100877:	5d                   	pop    %ebp
c0100878:	c3                   	ret    

c0100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100879:	55                   	push   %ebp
c010087a:	89 e5                	mov    %esp,%ebp
c010087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010087f:	c7 04 24 76 5f 10 c0 	movl   $0xc0105f76,(%esp)
c0100886:	e8 cb fa ff ff       	call   c0100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100892:	c0 
c0100893:	c7 04 24 8f 5f 10 c0 	movl   $0xc0105f8f,(%esp)
c010089a:	e8 b7 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010089f:	c7 44 24 04 af 5e 10 	movl   $0xc0105eaf,0x4(%esp)
c01008a6:	c0 
c01008a7:	c7 04 24 a7 5f 10 c0 	movl   $0xc0105fa7,(%esp)
c01008ae:	e8 a3 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b3:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c01008ba:	c0 
c01008bb:	c7 04 24 bf 5f 10 c0 	movl   $0xc0105fbf,(%esp)
c01008c2:	e8 8f fa ff ff       	call   c0100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c7:	c7 44 24 04 2c bf 11 	movl   $0xc011bf2c,0x4(%esp)
c01008ce:	c0 
c01008cf:	c7 04 24 d7 5f 10 c0 	movl   $0xc0105fd7,(%esp)
c01008d6:	e8 7b fa ff ff       	call   c0100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008db:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c01008e0:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f0:	85 c0                	test   %eax,%eax
c01008f2:	0f 48 c2             	cmovs  %edx,%eax
c01008f5:	c1 f8 0a             	sar    $0xa,%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	c7 04 24 f0 5f 10 c0 	movl   $0xc0105ff0,(%esp)
c0100903:	e8 4e fa ff ff       	call   c0100356 <cprintf>
}
c0100908:	90                   	nop
c0100909:	89 ec                	mov    %ebp,%esp
c010090b:	5d                   	pop    %ebp
c010090c:	c3                   	ret    

c010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010090d:	55                   	push   %ebp
c010090e:	89 e5                	mov    %esp,%ebp
c0100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100920:	89 04 24             	mov    %eax,(%esp)
c0100923:	e8 29 fc ff ff       	call   c0100551 <debuginfo_eip>
c0100928:	85 c0                	test   %eax,%eax
c010092a:	74 15                	je     c0100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100933:	c7 04 24 1a 60 10 c0 	movl   $0xc010601a,(%esp)
c010093a:	e8 17 fa ff ff       	call   c0100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010093f:	eb 6c                	jmp    c01009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100948:	eb 1b                	jmp    c0100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	01 d0                	add    %edx,%eax
c0100952:	0f b6 10             	movzbl (%eax),%edx
c0100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095e:	01 c8                	add    %ecx,%eax
c0100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100962:	ff 45 f4             	incl   -0xc(%ebp)
c0100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096b:	7c dd                	jl     c010094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100976:	01 d0                	add    %edx,%eax
c0100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010097e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100981:	29 d0                	sub    %edx,%eax
c0100983:	89 c1                	mov    %eax,%ecx
c0100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100999:	89 54 24 08          	mov    %edx,0x8(%esp)
c010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a1:	c7 04 24 36 60 10 c0 	movl   $0xc0106036,(%esp)
c01009a8:	e8 a9 f9 ff ff       	call   c0100356 <cprintf>
}
c01009ad:	90                   	nop
c01009ae:	89 ec                	mov    %ebp,%esp
c01009b0:	5d                   	pop    %ebp
c01009b1:	c3                   	ret    

c01009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b2:	55                   	push   %ebp
c01009b3:	89 e5                	mov    %esp,%ebp
c01009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009b8:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c1:	89 ec                	mov    %ebp,%esp
c01009c3:	5d                   	pop    %ebp
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cb:	89 e8                	mov    %ebp,%eax
c01009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp , eip ;
    ebp=read_ebp();
c01009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    eip=read_eip();
c01009d6:	e8 d7 ff ff ff       	call   c01009b2 <read_eip>
c01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i=0;
c01009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(i<STACKFRAME_DEPTH && ebp!=0){//宏定义20
c01009e5:	e9 84 00 00 00       	jmp    c0100a6e <print_stackframe+0xa9>
        i++;
c01009ea:	ff 45 ec             	incl   -0x14(%ebp)
       cprintf("ebp:0x%08x eip: 0x%08x ",ebp,eip);
c01009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fb:	c7 04 24 48 60 10 c0 	movl   $0xc0106048,(%esp)
c0100a02:	e8 4f f9 ff ff       	call   c0100356 <cprintf>
       uint32_t *temp =(uint32_t*)ebp +2;//参数的首地址 一个是4 所以加2 而不是加八
c0100a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a0a:	83 c0 08             	add    $0x8,%eax
c0100a0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 0; j < 4; j ++) {
c0100a10:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a17:	eb 24                	jmp    c0100a3d <print_stackframe+0x78>
            cprintf("0x%08x ", temp[j]); //打印4个参数
c0100a19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a26:	01 d0                	add    %edx,%eax
c0100a28:	8b 00                	mov    (%eax),%eax
c0100a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2e:	c7 04 24 60 60 10 c0 	movl   $0xc0106060,(%esp)
c0100a35:	e8 1c f9 ff ff       	call   c0100356 <cprintf>
        for (int j = 0; j < 4; j ++) {
c0100a3a:	ff 45 e8             	incl   -0x18(%ebp)
c0100a3d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a41:	7e d6                	jle    c0100a19 <print_stackframe+0x54>
        }
        
        cprintf("\n");
c0100a43:	c7 04 24 68 60 10 c0 	movl   $0xc0106068,(%esp)
c0100a4a:	e8 07 f9 ff ff       	call   c0100356 <cprintf>
        print_debuginfo(eip-1);
c0100a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a52:	48                   	dec    %eax
c0100a53:	89 04 24             	mov    %eax,(%esp)
c0100a56:	e8 b2 fe ff ff       	call   c010090d <print_debuginfo>
       eip = ((uint32_t *)ebp)[1]; //更新eip //eip就是返回地址 存在ebp+4个字节处
c0100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5e:	83 c0 04             	add    $0x4,%eax
c0100a61:	8b 00                	mov    (%eax),%eax
c0100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0]; //更新ebp
c0100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a69:	8b 00                	mov    (%eax),%eax
c0100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(i<STACKFRAME_DEPTH && ebp!=0){//宏定义20
c0100a6e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a72:	7f 0a                	jg     c0100a7e <print_stackframe+0xb9>
c0100a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a78:	0f 85 6c ff ff ff    	jne    c01009ea <print_stackframe+0x25>

}
} 
c0100a7e:	90                   	nop
c0100a7f:	89 ec                	mov    %ebp,%esp
c0100a81:	5d                   	pop    %ebp
c0100a82:	c3                   	ret    

c0100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a90:	eb 0c                	jmp    c0100a9e <parse+0x1b>
            *buf ++ = '\0';
c0100a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a95:	8d 50 01             	lea    0x1(%eax),%edx
c0100a98:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9b:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	0f b6 00             	movzbl (%eax),%eax
c0100aa4:	84 c0                	test   %al,%al
c0100aa6:	74 1d                	je     c0100ac5 <parse+0x42>
c0100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aab:	0f b6 00             	movzbl (%eax),%eax
c0100aae:	0f be c0             	movsbl %al,%eax
c0100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab5:	c7 04 24 ec 60 10 c0 	movl   $0xc01060ec,(%esp)
c0100abc:	e8 a6 50 00 00       	call   c0105b67 <strchr>
c0100ac1:	85 c0                	test   %eax,%eax
c0100ac3:	75 cd                	jne    c0100a92 <parse+0xf>
        }
        if (*buf == '\0') {
c0100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac8:	0f b6 00             	movzbl (%eax),%eax
c0100acb:	84 c0                	test   %al,%al
c0100acd:	74 65                	je     c0100b34 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100acf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad3:	75 14                	jne    c0100ae9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100adc:	00 
c0100add:	c7 04 24 f1 60 10 c0 	movl   $0xc01060f1,(%esp)
c0100ae4:	e8 6d f8 ff ff       	call   c0100356 <cprintf>
        }
        argv[argc ++] = buf;
c0100ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aec:	8d 50 01             	lea    0x1(%eax),%edx
c0100aef:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100afc:	01 c2                	add    %eax,%edx
c0100afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b01:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b03:	eb 03                	jmp    c0100b08 <parse+0x85>
            buf ++;
c0100b05:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0b:	0f b6 00             	movzbl (%eax),%eax
c0100b0e:	84 c0                	test   %al,%al
c0100b10:	74 8c                	je     c0100a9e <parse+0x1b>
c0100b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b15:	0f b6 00             	movzbl (%eax),%eax
c0100b18:	0f be c0             	movsbl %al,%eax
c0100b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b1f:	c7 04 24 ec 60 10 c0 	movl   $0xc01060ec,(%esp)
c0100b26:	e8 3c 50 00 00       	call   c0105b67 <strchr>
c0100b2b:	85 c0                	test   %eax,%eax
c0100b2d:	74 d6                	je     c0100b05 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b2f:	e9 6a ff ff ff       	jmp    c0100a9e <parse+0x1b>
            break;
c0100b34:	90                   	nop
        }
    }
    return argc;
c0100b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b38:	89 ec                	mov    %ebp,%esp
c0100b3a:	5d                   	pop    %ebp
c0100b3b:	c3                   	ret    

c0100b3c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3c:	55                   	push   %ebp
c0100b3d:	89 e5                	mov    %esp,%ebp
c0100b3f:	83 ec 68             	sub    $0x68,%esp
c0100b42:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2c ff ff ff       	call   c0100a83 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2e>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 83 00 00 00       	jmp    c0100bed <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5a                	jmp    c0100bcd <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b76:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b79:	89 c8                	mov    %ecx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 c8                	add    %ecx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 36 4f 00 00       	call   c0105acb <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 31                	jne    c0100bca <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 08 80 11 c0       	add    $0xc0118008,%eax
c0100baa:	8b 10                	mov    (%eax),%edx
c0100bac:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100baf:	83 c0 04             	add    $0x4,%eax
c0100bb2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bb5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bc3:	89 1c 24             	mov    %ebx,(%esp)
c0100bc6:	ff d2                	call   *%edx
c0100bc8:	eb 23                	jmp    c0100bed <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bca:	ff 45 f4             	incl   -0xc(%ebp)
c0100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd0:	83 f8 02             	cmp    $0x2,%eax
c0100bd3:	76 9e                	jbe    c0100b73 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdc:	c7 04 24 0f 61 10 c0 	movl   $0xc010610f,(%esp)
c0100be3:	e8 6e f7 ff ff       	call   c0100356 <cprintf>
    return 0;
c0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100bf0:	89 ec                	mov    %ebp,%esp
c0100bf2:	5d                   	pop    %ebp
c0100bf3:	c3                   	ret    

c0100bf4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf4:	55                   	push   %ebp
c0100bf5:	89 e5                	mov    %esp,%ebp
c0100bf7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bfa:	c7 04 24 28 61 10 c0 	movl   $0xc0106128,(%esp)
c0100c01:	e8 50 f7 ff ff       	call   c0100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c06:	c7 04 24 50 61 10 c0 	movl   $0xc0106150,(%esp)
c0100c0d:	e8 44 f7 ff ff       	call   c0100356 <cprintf>

    if (tf != NULL) {
c0100c12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c16:	74 0b                	je     c0100c23 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1b:	89 04 24             	mov    %eax,(%esp)
c0100c1e:	e8 f2 0e 00 00       	call   c0101b15 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c23:	c7 04 24 75 61 10 c0 	movl   $0xc0106175,(%esp)
c0100c2a:	e8 18 f6 ff ff       	call   c0100247 <readline>
c0100c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c36:	74 eb                	je     c0100c23 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c38:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c42:	89 04 24             	mov    %eax,(%esp)
c0100c45:	e8 f2 fe ff ff       	call   c0100b3c <runcmd>
c0100c4a:	85 c0                	test   %eax,%eax
c0100c4c:	78 02                	js     c0100c50 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c4e:	eb d3                	jmp    c0100c23 <kmonitor+0x2f>
                break;
c0100c50:	90                   	nop
            }
        }
    }
}
c0100c51:	90                   	nop
c0100c52:	89 ec                	mov    %ebp,%esp
c0100c54:	5d                   	pop    %ebp
c0100c55:	c3                   	ret    

c0100c56 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c56:	55                   	push   %ebp
c0100c57:	89 e5                	mov    %esp,%ebp
c0100c59:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c63:	eb 3d                	jmp    c0100ca2 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c68:	89 d0                	mov    %edx,%eax
c0100c6a:	01 c0                	add    %eax,%eax
c0100c6c:	01 d0                	add    %edx,%eax
c0100c6e:	c1 e0 02             	shl    $0x2,%eax
c0100c71:	05 04 80 11 c0       	add    $0xc0118004,%eax
c0100c76:	8b 10                	mov    (%eax),%edx
c0100c78:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c7b:	89 c8                	mov    %ecx,%eax
c0100c7d:	01 c0                	add    %eax,%eax
c0100c7f:	01 c8                	add    %ecx,%eax
c0100c81:	c1 e0 02             	shl    $0x2,%eax
c0100c84:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100c89:	8b 00                	mov    (%eax),%eax
c0100c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c93:	c7 04 24 79 61 10 c0 	movl   $0xc0106179,(%esp)
c0100c9a:	e8 b7 f6 ff ff       	call   c0100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9f:	ff 45 f4             	incl   -0xc(%ebp)
c0100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca5:	83 f8 02             	cmp    $0x2,%eax
c0100ca8:	76 bb                	jbe    c0100c65 <mon_help+0xf>
    }
    return 0;
c0100caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100caf:	89 ec                	mov    %ebp,%esp
c0100cb1:	5d                   	pop    %ebp
c0100cb2:	c3                   	ret    

c0100cb3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cb3:	55                   	push   %ebp
c0100cb4:	89 e5                	mov    %esp,%ebp
c0100cb6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb9:	e8 bb fb ff ff       	call   c0100879 <print_kerninfo>
    return 0;
c0100cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc3:	89 ec                	mov    %ebp,%esp
c0100cc5:	5d                   	pop    %ebp
c0100cc6:	c3                   	ret    

c0100cc7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc7:	55                   	push   %ebp
c0100cc8:	89 e5                	mov    %esp,%ebp
c0100cca:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ccd:	e8 f3 fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd7:	89 ec                	mov    %ebp,%esp
c0100cd9:	5d                   	pop    %ebp
c0100cda:	c3                   	ret    

c0100cdb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cdb:	55                   	push   %ebp
c0100cdc:	89 e5                	mov    %esp,%ebp
c0100cde:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ce1:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
c0100ce6:	85 c0                	test   %eax,%eax
c0100ce8:	75 5b                	jne    c0100d45 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100cea:	c7 05 20 b4 11 c0 01 	movl   $0x1,0xc011b420
c0100cf1:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100cf4:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d08:	c7 04 24 82 61 10 c0 	movl   $0xc0106182,(%esp)
c0100d0f:	e8 42 f6 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d1e:	89 04 24             	mov    %eax,(%esp)
c0100d21:	e8 fb f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d26:	c7 04 24 9e 61 10 c0 	movl   $0xc010619e,(%esp)
c0100d2d:	e8 24 f6 ff ff       	call   c0100356 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d32:	c7 04 24 a0 61 10 c0 	movl   $0xc01061a0,(%esp)
c0100d39:	e8 18 f6 ff ff       	call   c0100356 <cprintf>
    print_stackframe();
c0100d3e:	e8 82 fc ff ff       	call   c01009c5 <print_stackframe>
c0100d43:	eb 01                	jmp    c0100d46 <__panic+0x6b>
        goto panic_dead;
c0100d45:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d46:	e8 e9 09 00 00       	call   c0101734 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d52:	e8 9d fe ff ff       	call   c0100bf4 <kmonitor>
c0100d57:	eb f2                	jmp    c0100d4b <__panic+0x70>

c0100d59 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d59:	55                   	push   %ebp
c0100d5a:	89 e5                	mov    %esp,%ebp
c0100d5c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d5f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d68:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d73:	c7 04 24 b2 61 10 c0 	movl   $0xc01061b2,(%esp)
c0100d7a:	e8 d7 f5 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d86:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d89:	89 04 24             	mov    %eax,(%esp)
c0100d8c:	e8 90 f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d91:	c7 04 24 9e 61 10 c0 	movl   $0xc010619e,(%esp)
c0100d98:	e8 b9 f5 ff ff       	call   c0100356 <cprintf>
    va_end(ap);
}
c0100d9d:	90                   	nop
c0100d9e:	89 ec                	mov    %ebp,%esp
c0100da0:	5d                   	pop    %ebp
c0100da1:	c3                   	ret    

c0100da2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100da2:	55                   	push   %ebp
c0100da3:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100da5:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
}
c0100daa:	5d                   	pop    %ebp
c0100dab:	c3                   	ret    

c0100dac <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dac:	55                   	push   %ebp
c0100dad:	89 e5                	mov    %esp,%ebp
c0100daf:	83 ec 28             	sub    $0x28,%esp
c0100db2:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100db8:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dbc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dc0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dc4:	ee                   	out    %al,(%dx)
}
c0100dc5:	90                   	nop
c0100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd8:	ee                   	out    %al,(%dx)
}
c0100dd9:	90                   	nop
c0100dda:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100de0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100de4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100de8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dec:	ee                   	out    %al,(%dx)
}
c0100ded:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dee:	c7 05 24 b4 11 c0 00 	movl   $0x0,0xc011b424
c0100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df8:	c7 04 24 d0 61 10 c0 	movl   $0xc01061d0,(%esp)
c0100dff:	e8 52 f5 ff ff       	call   c0100356 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e0b:	e8 89 09 00 00       	call   c0101799 <pic_enable>
}
c0100e10:	90                   	nop
c0100e11:	89 ec                	mov    %ebp,%esp
c0100e13:	5d                   	pop    %ebp
c0100e14:	c3                   	ret    

c0100e15 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e15:	55                   	push   %ebp
c0100e16:	89 e5                	mov    %esp,%ebp
c0100e18:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e1b:	9c                   	pushf  
c0100e1c:	58                   	pop    %eax
c0100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e23:	25 00 02 00 00       	and    $0x200,%eax
c0100e28:	85 c0                	test   %eax,%eax
c0100e2a:	74 0c                	je     c0100e38 <__intr_save+0x23>
        intr_disable();
c0100e2c:	e8 03 09 00 00       	call   c0101734 <intr_disable>
        return 1;
c0100e31:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e36:	eb 05                	jmp    c0100e3d <__intr_save+0x28>
    }
    return 0;
c0100e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e3d:	89 ec                	mov    %ebp,%esp
c0100e3f:	5d                   	pop    %ebp
c0100e40:	c3                   	ret    

c0100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e41:	55                   	push   %ebp
c0100e42:	89 e5                	mov    %esp,%ebp
c0100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e4b:	74 05                	je     c0100e52 <__intr_restore+0x11>
        intr_enable();
c0100e4d:	e8 da 08 00 00       	call   c010172c <intr_enable>
    }
}
c0100e52:	90                   	nop
c0100e53:	89 ec                	mov    %ebp,%esp
c0100e55:	5d                   	pop    %ebp
c0100e56:	c3                   	ret    

c0100e57 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e57:	55                   	push   %ebp
c0100e58:	89 e5                	mov    %esp,%ebp
c0100e5a:	83 ec 10             	sub    $0x10,%esp
c0100e5d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e63:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e67:	89 c2                	mov    %eax,%edx
c0100e69:	ec                   	in     (%dx),%al
c0100e6a:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e6d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e73:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e77:	89 c2                	mov    %eax,%edx
c0100e79:	ec                   	in     (%dx),%al
c0100e7a:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e7d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e83:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e87:	89 c2                	mov    %eax,%edx
c0100e89:	ec                   	in     (%dx),%al
c0100e8a:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e8d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e93:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e97:	89 c2                	mov    %eax,%edx
c0100e99:	ec                   	in     (%dx),%al
c0100e9a:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e9d:	90                   	nop
c0100e9e:	89 ec                	mov    %ebp,%esp
c0100ea0:	5d                   	pop    %ebp
c0100ea1:	c3                   	ret    

c0100ea2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ea2:	55                   	push   %ebp
c0100ea3:	89 e5                	mov    %esp,%ebp
c0100ea5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ea8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb2:	0f b7 00             	movzwl (%eax),%eax
c0100eb5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec4:	0f b7 00             	movzwl (%eax),%eax
c0100ec7:	0f b7 c0             	movzwl %ax,%eax
c0100eca:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ecf:	74 12                	je     c0100ee3 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ed1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ed8:	66 c7 05 46 b4 11 c0 	movw   $0x3b4,0xc011b446
c0100edf:	b4 03 
c0100ee1:	eb 13                	jmp    c0100ef6 <cga_init+0x54>
    } else {
        *cp = was;
c0100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eea:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eed:	66 c7 05 46 b4 11 c0 	movw   $0x3d4,0xc011b446
c0100ef4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ef6:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100efd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f01:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f05:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f09:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f0d:	ee                   	out    %al,(%dx)
}
c0100f0e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f0f:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f16:	40                   	inc    %eax
c0100f17:	0f b7 c0             	movzwl %ax,%eax
c0100f1a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f1e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f22:	89 c2                	mov    %eax,%edx
c0100f24:	ec                   	in     (%dx),%al
c0100f25:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f28:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f2c:	0f b6 c0             	movzbl %al,%eax
c0100f2f:	c1 e0 08             	shl    $0x8,%eax
c0100f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f35:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f3c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f40:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f44:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f48:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f4c:	ee                   	out    %al,(%dx)
}
c0100f4d:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f4e:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f55:	40                   	inc    %eax
c0100f56:	0f b7 c0             	movzwl %ax,%eax
c0100f59:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f5d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f61:	89 c2                	mov    %eax,%edx
c0100f63:	ec                   	in     (%dx),%al
c0100f64:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f67:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f6b:	0f b6 c0             	movzbl %al,%eax
c0100f6e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f74:	a3 40 b4 11 c0       	mov    %eax,0xc011b440
    crt_pos = pos;
c0100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f7c:	0f b7 c0             	movzwl %ax,%eax
c0100f7f:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
}
c0100f85:	90                   	nop
c0100f86:	89 ec                	mov    %ebp,%esp
c0100f88:	5d                   	pop    %ebp
c0100f89:	c3                   	ret    

c0100f8a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f8a:	55                   	push   %ebp
c0100f8b:	89 e5                	mov    %esp,%ebp
c0100f8d:	83 ec 48             	sub    $0x48,%esp
c0100f90:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f96:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f9a:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f9e:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fa2:	ee                   	out    %al,(%dx)
}
c0100fa3:	90                   	nop
c0100fa4:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100faa:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fb2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fb6:	ee                   	out    %al,(%dx)
}
c0100fb7:	90                   	nop
c0100fb8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fbe:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fc2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fc6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fca:	ee                   	out    %al,(%dx)
}
c0100fcb:	90                   	nop
c0100fcc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fd2:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fda:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fde:	ee                   	out    %al,(%dx)
}
c0100fdf:	90                   	nop
c0100fe0:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fe6:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fea:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fee:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ff2:	ee                   	out    %al,(%dx)
}
c0100ff3:	90                   	nop
c0100ff4:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100ffa:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffe:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101002:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101006:	ee                   	out    %al,(%dx)
}
c0101007:	90                   	nop
c0101008:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010100e:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101012:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101016:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010101a:	ee                   	out    %al,(%dx)
}
c010101b:	90                   	nop
c010101c:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101022:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101026:	89 c2                	mov    %eax,%edx
c0101028:	ec                   	in     (%dx),%al
c0101029:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010102c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101030:	3c ff                	cmp    $0xff,%al
c0101032:	0f 95 c0             	setne  %al
c0101035:	0f b6 c0             	movzbl %al,%eax
c0101038:	a3 48 b4 11 c0       	mov    %eax,0xc011b448
c010103d:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101043:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101047:	89 c2                	mov    %eax,%edx
c0101049:	ec                   	in     (%dx),%al
c010104a:	88 45 f1             	mov    %al,-0xf(%ebp)
c010104d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101053:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101057:	89 c2                	mov    %eax,%edx
c0101059:	ec                   	in     (%dx),%al
c010105a:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010105d:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101062:	85 c0                	test   %eax,%eax
c0101064:	74 0c                	je     c0101072 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101066:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010106d:	e8 27 07 00 00       	call   c0101799 <pic_enable>
    }
}
c0101072:	90                   	nop
c0101073:	89 ec                	mov    %ebp,%esp
c0101075:	5d                   	pop    %ebp
c0101076:	c3                   	ret    

c0101077 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101077:	55                   	push   %ebp
c0101078:	89 e5                	mov    %esp,%ebp
c010107a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010107d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101084:	eb 08                	jmp    c010108e <lpt_putc_sub+0x17>
        delay();
c0101086:	e8 cc fd ff ff       	call   c0100e57 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010108b:	ff 45 fc             	incl   -0x4(%ebp)
c010108e:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101094:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101098:	89 c2                	mov    %eax,%edx
c010109a:	ec                   	in     (%dx),%al
c010109b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010109e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010a2:	84 c0                	test   %al,%al
c01010a4:	78 09                	js     c01010af <lpt_putc_sub+0x38>
c01010a6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010ad:	7e d7                	jle    c0101086 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010af:	8b 45 08             	mov    0x8(%ebp),%eax
c01010b2:	0f b6 c0             	movzbl %al,%eax
c01010b5:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010bb:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
}
c01010c7:	90                   	nop
c01010c8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010ce:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010d2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010d6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010da:	ee                   	out    %al,(%dx)
}
c01010db:	90                   	nop
c01010dc:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010e2:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010ee:	ee                   	out    %al,(%dx)
}
c01010ef:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010f0:	90                   	nop
c01010f1:	89 ec                	mov    %ebp,%esp
c01010f3:	5d                   	pop    %ebp
c01010f4:	c3                   	ret    

c01010f5 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010f5:	55                   	push   %ebp
c01010f6:	89 e5                	mov    %esp,%ebp
c01010f8:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010fb:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010ff:	74 0d                	je     c010110e <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101101:	8b 45 08             	mov    0x8(%ebp),%eax
c0101104:	89 04 24             	mov    %eax,(%esp)
c0101107:	e8 6b ff ff ff       	call   c0101077 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010110c:	eb 24                	jmp    c0101132 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010110e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101115:	e8 5d ff ff ff       	call   c0101077 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010111a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101121:	e8 51 ff ff ff       	call   c0101077 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101126:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010112d:	e8 45 ff ff ff       	call   c0101077 <lpt_putc_sub>
}
c0101132:	90                   	nop
c0101133:	89 ec                	mov    %ebp,%esp
c0101135:	5d                   	pop    %ebp
c0101136:	c3                   	ret    

c0101137 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101137:	55                   	push   %ebp
c0101138:	89 e5                	mov    %esp,%ebp
c010113a:	83 ec 38             	sub    $0x38,%esp
c010113d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101140:	8b 45 08             	mov    0x8(%ebp),%eax
c0101143:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101148:	85 c0                	test   %eax,%eax
c010114a:	75 07                	jne    c0101153 <cga_putc+0x1c>
        c |= 0x0700;
c010114c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101153:	8b 45 08             	mov    0x8(%ebp),%eax
c0101156:	0f b6 c0             	movzbl %al,%eax
c0101159:	83 f8 0d             	cmp    $0xd,%eax
c010115c:	74 72                	je     c01011d0 <cga_putc+0x99>
c010115e:	83 f8 0d             	cmp    $0xd,%eax
c0101161:	0f 8f a3 00 00 00    	jg     c010120a <cga_putc+0xd3>
c0101167:	83 f8 08             	cmp    $0x8,%eax
c010116a:	74 0a                	je     c0101176 <cga_putc+0x3f>
c010116c:	83 f8 0a             	cmp    $0xa,%eax
c010116f:	74 4c                	je     c01011bd <cga_putc+0x86>
c0101171:	e9 94 00 00 00       	jmp    c010120a <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c0101176:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010117d:	85 c0                	test   %eax,%eax
c010117f:	0f 84 af 00 00 00    	je     c0101234 <cga_putc+0xfd>
            crt_pos --;
c0101185:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010118c:	48                   	dec    %eax
c010118d:	0f b7 c0             	movzwl %ax,%eax
c0101190:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101196:	8b 45 08             	mov    0x8(%ebp),%eax
c0101199:	98                   	cwtl   
c010119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010119f:	98                   	cwtl   
c01011a0:	83 c8 20             	or     $0x20,%eax
c01011a3:	98                   	cwtl   
c01011a4:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c01011aa:	0f b7 15 44 b4 11 c0 	movzwl 0xc011b444,%edx
c01011b1:	01 d2                	add    %edx,%edx
c01011b3:	01 ca                	add    %ecx,%edx
c01011b5:	0f b7 c0             	movzwl %ax,%eax
c01011b8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011bb:	eb 77                	jmp    c0101234 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011bd:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011c4:	83 c0 50             	add    $0x50,%eax
c01011c7:	0f b7 c0             	movzwl %ax,%eax
c01011ca:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011d0:	0f b7 1d 44 b4 11 c0 	movzwl 0xc011b444,%ebx
c01011d7:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c01011de:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011e3:	89 c8                	mov    %ecx,%eax
c01011e5:	f7 e2                	mul    %edx
c01011e7:	c1 ea 06             	shr    $0x6,%edx
c01011ea:	89 d0                	mov    %edx,%eax
c01011ec:	c1 e0 02             	shl    $0x2,%eax
c01011ef:	01 d0                	add    %edx,%eax
c01011f1:	c1 e0 04             	shl    $0x4,%eax
c01011f4:	29 c1                	sub    %eax,%ecx
c01011f6:	89 ca                	mov    %ecx,%edx
c01011f8:	0f b7 d2             	movzwl %dx,%edx
c01011fb:	89 d8                	mov    %ebx,%eax
c01011fd:	29 d0                	sub    %edx,%eax
c01011ff:	0f b7 c0             	movzwl %ax,%eax
c0101202:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
        break;
c0101208:	eb 2b                	jmp    c0101235 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010120a:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c0101210:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101217:	8d 50 01             	lea    0x1(%eax),%edx
c010121a:	0f b7 d2             	movzwl %dx,%edx
c010121d:	66 89 15 44 b4 11 c0 	mov    %dx,0xc011b444
c0101224:	01 c0                	add    %eax,%eax
c0101226:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101229:	8b 45 08             	mov    0x8(%ebp),%eax
c010122c:	0f b7 c0             	movzwl %ax,%eax
c010122f:	66 89 02             	mov    %ax,(%edx)
        break;
c0101232:	eb 01                	jmp    c0101235 <cga_putc+0xfe>
        break;
c0101234:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101235:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010123c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101241:	76 5e                	jbe    c01012a1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101243:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101248:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010124e:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101253:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010125a:	00 
c010125b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010125f:	89 04 24             	mov    %eax,(%esp)
c0101262:	e8 fe 4a 00 00       	call   c0105d65 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101267:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010126e:	eb 15                	jmp    c0101285 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101270:	8b 15 40 b4 11 c0    	mov    0xc011b440,%edx
c0101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101279:	01 c0                	add    %eax,%eax
c010127b:	01 d0                	add    %edx,%eax
c010127d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101282:	ff 45 f4             	incl   -0xc(%ebp)
c0101285:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010128c:	7e e2                	jle    c0101270 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c010128e:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101295:	83 e8 50             	sub    $0x50,%eax
c0101298:	0f b7 c0             	movzwl %ax,%eax
c010129b:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012a1:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012a8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012ac:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
}
c01012b9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012ba:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01012c1:	c1 e8 08             	shr    $0x8,%eax
c01012c4:	0f b7 c0             	movzwl %ax,%eax
c01012c7:	0f b6 c0             	movzbl %al,%eax
c01012ca:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012d1:	42                   	inc    %edx
c01012d2:	0f b7 d2             	movzwl %dx,%edx
c01012d5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012d9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012dc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012e0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012e4:	ee                   	out    %al,(%dx)
}
c01012e5:	90                   	nop
    outb(addr_6845, 15);
c01012e6:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012ed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012f1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012fd:	ee                   	out    %al,(%dx)
}
c01012fe:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c01012ff:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101306:	0f b6 c0             	movzbl %al,%eax
c0101309:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c0101310:	42                   	inc    %edx
c0101311:	0f b7 d2             	movzwl %dx,%edx
c0101314:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101318:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010131f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101323:	ee                   	out    %al,(%dx)
}
c0101324:	90                   	nop
}
c0101325:	90                   	nop
c0101326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101329:	89 ec                	mov    %ebp,%esp
c010132b:	5d                   	pop    %ebp
c010132c:	c3                   	ret    

c010132d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010132d:	55                   	push   %ebp
c010132e:	89 e5                	mov    %esp,%ebp
c0101330:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101333:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010133a:	eb 08                	jmp    c0101344 <serial_putc_sub+0x17>
        delay();
c010133c:	e8 16 fb ff ff       	call   c0100e57 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101341:	ff 45 fc             	incl   -0x4(%ebp)
c0101344:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010134a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010134e:	89 c2                	mov    %eax,%edx
c0101350:	ec                   	in     (%dx),%al
c0101351:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101354:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101358:	0f b6 c0             	movzbl %al,%eax
c010135b:	83 e0 20             	and    $0x20,%eax
c010135e:	85 c0                	test   %eax,%eax
c0101360:	75 09                	jne    c010136b <serial_putc_sub+0x3e>
c0101362:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101369:	7e d1                	jle    c010133c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010136b:	8b 45 08             	mov    0x8(%ebp),%eax
c010136e:	0f b6 c0             	movzbl %al,%eax
c0101371:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101377:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010137a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010137e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101382:	ee                   	out    %al,(%dx)
}
c0101383:	90                   	nop
}
c0101384:	90                   	nop
c0101385:	89 ec                	mov    %ebp,%esp
c0101387:	5d                   	pop    %ebp
c0101388:	c3                   	ret    

c0101389 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101389:	55                   	push   %ebp
c010138a:	89 e5                	mov    %esp,%ebp
c010138c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010138f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101393:	74 0d                	je     c01013a2 <serial_putc+0x19>
        serial_putc_sub(c);
c0101395:	8b 45 08             	mov    0x8(%ebp),%eax
c0101398:	89 04 24             	mov    %eax,(%esp)
c010139b:	e8 8d ff ff ff       	call   c010132d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013a0:	eb 24                	jmp    c01013c6 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013a9:	e8 7f ff ff ff       	call   c010132d <serial_putc_sub>
        serial_putc_sub(' ');
c01013ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013b5:	e8 73 ff ff ff       	call   c010132d <serial_putc_sub>
        serial_putc_sub('\b');
c01013ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013c1:	e8 67 ff ff ff       	call   c010132d <serial_putc_sub>
}
c01013c6:	90                   	nop
c01013c7:	89 ec                	mov    %ebp,%esp
c01013c9:	5d                   	pop    %ebp
c01013ca:	c3                   	ret    

c01013cb <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013cb:	55                   	push   %ebp
c01013cc:	89 e5                	mov    %esp,%ebp
c01013ce:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013d1:	eb 33                	jmp    c0101406 <cons_intr+0x3b>
        if (c != 0) {
c01013d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013d7:	74 2d                	je     c0101406 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013d9:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013de:	8d 50 01             	lea    0x1(%eax),%edx
c01013e1:	89 15 64 b6 11 c0    	mov    %edx,0xc011b664
c01013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013ea:	88 90 60 b4 11 c0    	mov    %dl,-0x3fee4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013f0:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013f5:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013fa:	75 0a                	jne    c0101406 <cons_intr+0x3b>
                cons.wpos = 0;
c01013fc:	c7 05 64 b6 11 c0 00 	movl   $0x0,0xc011b664
c0101403:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101406:	8b 45 08             	mov    0x8(%ebp),%eax
c0101409:	ff d0                	call   *%eax
c010140b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010140e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101412:	75 bf                	jne    c01013d3 <cons_intr+0x8>
            }
        }
    }
}
c0101414:	90                   	nop
c0101415:	90                   	nop
c0101416:	89 ec                	mov    %ebp,%esp
c0101418:	5d                   	pop    %ebp
c0101419:	c3                   	ret    

c010141a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010141a:	55                   	push   %ebp
c010141b:	89 e5                	mov    %esp,%ebp
c010141d:	83 ec 10             	sub    $0x10,%esp
c0101420:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101426:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010142a:	89 c2                	mov    %eax,%edx
c010142c:	ec                   	in     (%dx),%al
c010142d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101430:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101434:	0f b6 c0             	movzbl %al,%eax
c0101437:	83 e0 01             	and    $0x1,%eax
c010143a:	85 c0                	test   %eax,%eax
c010143c:	75 07                	jne    c0101445 <serial_proc_data+0x2b>
        return -1;
c010143e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101443:	eb 2a                	jmp    c010146f <serial_proc_data+0x55>
c0101445:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010144f:	89 c2                	mov    %eax,%edx
c0101451:	ec                   	in     (%dx),%al
c0101452:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101455:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101459:	0f b6 c0             	movzbl %al,%eax
c010145c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010145f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101463:	75 07                	jne    c010146c <serial_proc_data+0x52>
        c = '\b';
c0101465:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010146f:	89 ec                	mov    %ebp,%esp
c0101471:	5d                   	pop    %ebp
c0101472:	c3                   	ret    

c0101473 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101473:	55                   	push   %ebp
c0101474:	89 e5                	mov    %esp,%ebp
c0101476:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101479:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c010147e:	85 c0                	test   %eax,%eax
c0101480:	74 0c                	je     c010148e <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101482:	c7 04 24 1a 14 10 c0 	movl   $0xc010141a,(%esp)
c0101489:	e8 3d ff ff ff       	call   c01013cb <cons_intr>
    }
}
c010148e:	90                   	nop
c010148f:	89 ec                	mov    %ebp,%esp
c0101491:	5d                   	pop    %ebp
c0101492:	c3                   	ret    

c0101493 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101493:	55                   	push   %ebp
c0101494:	89 e5                	mov    %esp,%ebp
c0101496:	83 ec 38             	sub    $0x38,%esp
c0101499:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014a2:	89 c2                	mov    %eax,%edx
c01014a4:	ec                   	in     (%dx),%al
c01014a5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014ac:	0f b6 c0             	movzbl %al,%eax
c01014af:	83 e0 01             	and    $0x1,%eax
c01014b2:	85 c0                	test   %eax,%eax
c01014b4:	75 0a                	jne    c01014c0 <kbd_proc_data+0x2d>
        return -1;
c01014b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014bb:	e9 56 01 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
c01014c0:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014c9:	89 c2                	mov    %eax,%edx
c01014cb:	ec                   	in     (%dx),%al
c01014cc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014cf:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014d3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014d6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014da:	75 17                	jne    c01014f3 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014dc:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014e1:	83 c8 40             	or     $0x40,%eax
c01014e4:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ee:	e9 23 01 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c01014f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f7:	84 c0                	test   %al,%al
c01014f9:	79 45                	jns    c0101540 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014fb:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101500:	83 e0 40             	and    $0x40,%eax
c0101503:	85 c0                	test   %eax,%eax
c0101505:	75 08                	jne    c010150f <kbd_proc_data+0x7c>
c0101507:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150b:	24 7f                	and    $0x7f,%al
c010150d:	eb 04                	jmp    c0101513 <kbd_proc_data+0x80>
c010150f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101513:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151a:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c0101521:	0c 40                	or     $0x40,%al
c0101523:	0f b6 c0             	movzbl %al,%eax
c0101526:	f7 d0                	not    %eax
c0101528:	89 c2                	mov    %eax,%edx
c010152a:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010152f:	21 d0                	and    %edx,%eax
c0101531:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c0101536:	b8 00 00 00 00       	mov    $0x0,%eax
c010153b:	e9 d6 00 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101540:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101545:	83 e0 40             	and    $0x40,%eax
c0101548:	85 c0                	test   %eax,%eax
c010154a:	74 11                	je     c010155d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010154c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101550:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101555:	83 e0 bf             	and    $0xffffffbf,%eax
c0101558:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    }

    shift |= shiftcode[data];
c010155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101561:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c0101568:	0f b6 d0             	movzbl %al,%edx
c010156b:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101570:	09 d0                	or     %edx,%eax
c0101572:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    shift ^= togglecode[data];
c0101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010157b:	0f b6 80 40 81 11 c0 	movzbl -0x3fee7ec0(%eax),%eax
c0101582:	0f b6 d0             	movzbl %al,%edx
c0101585:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010158a:	31 d0                	xor    %edx,%eax
c010158c:	a3 68 b6 11 c0       	mov    %eax,0xc011b668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101591:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101596:	83 e0 03             	and    $0x3,%eax
c0101599:	8b 14 85 40 85 11 c0 	mov    -0x3fee7ac0(,%eax,4),%edx
c01015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015a4:	01 d0                	add    %edx,%eax
c01015a6:	0f b6 00             	movzbl (%eax),%eax
c01015a9:	0f b6 c0             	movzbl %al,%eax
c01015ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015af:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01015b4:	83 e0 08             	and    $0x8,%eax
c01015b7:	85 c0                	test   %eax,%eax
c01015b9:	74 22                	je     c01015dd <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015bb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015bf:	7e 0c                	jle    c01015cd <kbd_proc_data+0x13a>
c01015c1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015c5:	7f 06                	jg     c01015cd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015c7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015cb:	eb 10                	jmp    c01015dd <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015cd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015d1:	7e 0a                	jle    c01015dd <kbd_proc_data+0x14a>
c01015d3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015d7:	7f 04                	jg     c01015dd <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015d9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015dd:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01015e2:	f7 d0                	not    %eax
c01015e4:	83 e0 06             	and    $0x6,%eax
c01015e7:	85 c0                	test   %eax,%eax
c01015e9:	75 28                	jne    c0101613 <kbd_proc_data+0x180>
c01015eb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015f2:	75 1f                	jne    c0101613 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c01015f4:	c7 04 24 eb 61 10 c0 	movl   $0xc01061eb,(%esp)
c01015fb:	e8 56 ed ff ff       	call   c0100356 <cprintf>
c0101600:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101606:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010160a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010160e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101611:	ee                   	out    %al,(%dx)
}
c0101612:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101616:	89 ec                	mov    %ebp,%esp
c0101618:	5d                   	pop    %ebp
c0101619:	c3                   	ret    

c010161a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010161a:	55                   	push   %ebp
c010161b:	89 e5                	mov    %esp,%ebp
c010161d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101620:	c7 04 24 93 14 10 c0 	movl   $0xc0101493,(%esp)
c0101627:	e8 9f fd ff ff       	call   c01013cb <cons_intr>
}
c010162c:	90                   	nop
c010162d:	89 ec                	mov    %ebp,%esp
c010162f:	5d                   	pop    %ebp
c0101630:	c3                   	ret    

c0101631 <kbd_init>:

static void
kbd_init(void) {
c0101631:	55                   	push   %ebp
c0101632:	89 e5                	mov    %esp,%ebp
c0101634:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101637:	e8 de ff ff ff       	call   c010161a <kbd_intr>
    pic_enable(IRQ_KBD);
c010163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101643:	e8 51 01 00 00       	call   c0101799 <pic_enable>
}
c0101648:	90                   	nop
c0101649:	89 ec                	mov    %ebp,%esp
c010164b:	5d                   	pop    %ebp
c010164c:	c3                   	ret    

c010164d <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010164d:	55                   	push   %ebp
c010164e:	89 e5                	mov    %esp,%ebp
c0101650:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101653:	e8 4a f8 ff ff       	call   c0100ea2 <cga_init>
    serial_init();
c0101658:	e8 2d f9 ff ff       	call   c0100f8a <serial_init>
    kbd_init();
c010165d:	e8 cf ff ff ff       	call   c0101631 <kbd_init>
    if (!serial_exists) {
c0101662:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101667:	85 c0                	test   %eax,%eax
c0101669:	75 0c                	jne    c0101677 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010166b:	c7 04 24 f7 61 10 c0 	movl   $0xc01061f7,(%esp)
c0101672:	e8 df ec ff ff       	call   c0100356 <cprintf>
    }
}
c0101677:	90                   	nop
c0101678:	89 ec                	mov    %ebp,%esp
c010167a:	5d                   	pop    %ebp
c010167b:	c3                   	ret    

c010167c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010167c:	55                   	push   %ebp
c010167d:	89 e5                	mov    %esp,%ebp
c010167f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101682:	e8 8e f7 ff ff       	call   c0100e15 <__intr_save>
c0101687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010168a:	8b 45 08             	mov    0x8(%ebp),%eax
c010168d:	89 04 24             	mov    %eax,(%esp)
c0101690:	e8 60 fa ff ff       	call   c01010f5 <lpt_putc>
        cga_putc(c);
c0101695:	8b 45 08             	mov    0x8(%ebp),%eax
c0101698:	89 04 24             	mov    %eax,(%esp)
c010169b:	e8 97 fa ff ff       	call   c0101137 <cga_putc>
        serial_putc(c);
c01016a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016a3:	89 04 24             	mov    %eax,(%esp)
c01016a6:	e8 de fc ff ff       	call   c0101389 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016ae:	89 04 24             	mov    %eax,(%esp)
c01016b1:	e8 8b f7 ff ff       	call   c0100e41 <__intr_restore>
}
c01016b6:	90                   	nop
c01016b7:	89 ec                	mov    %ebp,%esp
c01016b9:	5d                   	pop    %ebp
c01016ba:	c3                   	ret    

c01016bb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016bb:	55                   	push   %ebp
c01016bc:	89 e5                	mov    %esp,%ebp
c01016be:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016c8:	e8 48 f7 ff ff       	call   c0100e15 <__intr_save>
c01016cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016d0:	e8 9e fd ff ff       	call   c0101473 <serial_intr>
        kbd_intr();
c01016d5:	e8 40 ff ff ff       	call   c010161a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016da:	8b 15 60 b6 11 c0    	mov    0xc011b660,%edx
c01016e0:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01016e5:	39 c2                	cmp    %eax,%edx
c01016e7:	74 31                	je     c010171a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016e9:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c01016ee:	8d 50 01             	lea    0x1(%eax),%edx
c01016f1:	89 15 60 b6 11 c0    	mov    %edx,0xc011b660
c01016f7:	0f b6 80 60 b4 11 c0 	movzbl -0x3fee4ba0(%eax),%eax
c01016fe:	0f b6 c0             	movzbl %al,%eax
c0101701:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101704:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c0101709:	3d 00 02 00 00       	cmp    $0x200,%eax
c010170e:	75 0a                	jne    c010171a <cons_getc+0x5f>
                cons.rpos = 0;
c0101710:	c7 05 60 b6 11 c0 00 	movl   $0x0,0xc011b660
c0101717:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010171d:	89 04 24             	mov    %eax,(%esp)
c0101720:	e8 1c f7 ff ff       	call   c0100e41 <__intr_restore>
    return c;
c0101725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101728:	89 ec                	mov    %ebp,%esp
c010172a:	5d                   	pop    %ebp
c010172b:	c3                   	ret    

c010172c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010172c:	55                   	push   %ebp
c010172d:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010172f:	fb                   	sti    
}
c0101730:	90                   	nop
    sti();
}
c0101731:	90                   	nop
c0101732:	5d                   	pop    %ebp
c0101733:	c3                   	ret    

c0101734 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101734:	55                   	push   %ebp
c0101735:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101737:	fa                   	cli    
}
c0101738:	90                   	nop
    cli();
}
c0101739:	90                   	nop
c010173a:	5d                   	pop    %ebp
c010173b:	c3                   	ret    

c010173c <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010173c:	55                   	push   %ebp
c010173d:	89 e5                	mov    %esp,%ebp
c010173f:	83 ec 14             	sub    $0x14,%esp
c0101742:	8b 45 08             	mov    0x8(%ebp),%eax
c0101745:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101749:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010174c:	66 a3 50 85 11 c0    	mov    %ax,0xc0118550
    if (did_init) {
c0101752:	a1 6c b6 11 c0       	mov    0xc011b66c,%eax
c0101757:	85 c0                	test   %eax,%eax
c0101759:	74 39                	je     c0101794 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c010175b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010175e:	0f b6 c0             	movzbl %al,%eax
c0101761:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101767:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010176a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010176e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101772:	ee                   	out    %al,(%dx)
}
c0101773:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101774:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101778:	c1 e8 08             	shr    $0x8,%eax
c010177b:	0f b7 c0             	movzwl %ax,%eax
c010177e:	0f b6 c0             	movzbl %al,%eax
c0101781:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101787:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010178a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010178e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101792:	ee                   	out    %al,(%dx)
}
c0101793:	90                   	nop
    }
}
c0101794:	90                   	nop
c0101795:	89 ec                	mov    %ebp,%esp
c0101797:	5d                   	pop    %ebp
c0101798:	c3                   	ret    

c0101799 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101799:	55                   	push   %ebp
c010179a:	89 e5                	mov    %esp,%ebp
c010179c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010179f:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a2:	ba 01 00 00 00       	mov    $0x1,%edx
c01017a7:	88 c1                	mov    %al,%cl
c01017a9:	d3 e2                	shl    %cl,%edx
c01017ab:	89 d0                	mov    %edx,%eax
c01017ad:	98                   	cwtl   
c01017ae:	f7 d0                	not    %eax
c01017b0:	0f bf d0             	movswl %ax,%edx
c01017b3:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c01017ba:	98                   	cwtl   
c01017bb:	21 d0                	and    %edx,%eax
c01017bd:	98                   	cwtl   
c01017be:	0f b7 c0             	movzwl %ax,%eax
c01017c1:	89 04 24             	mov    %eax,(%esp)
c01017c4:	e8 73 ff ff ff       	call   c010173c <pic_setmask>
}
c01017c9:	90                   	nop
c01017ca:	89 ec                	mov    %ebp,%esp
c01017cc:	5d                   	pop    %ebp
c01017cd:	c3                   	ret    

c01017ce <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01017ce:	55                   	push   %ebp
c01017cf:	89 e5                	mov    %esp,%ebp
c01017d1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01017d4:	c7 05 6c b6 11 c0 01 	movl   $0x1,0xc011b66c
c01017db:	00 00 00 
c01017de:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01017e4:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017e8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017ec:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017f0:	ee                   	out    %al,(%dx)
}
c01017f1:	90                   	nop
c01017f2:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01017f8:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017fc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101800:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101804:	ee                   	out    %al,(%dx)
}
c0101805:	90                   	nop
c0101806:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010180c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101810:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101814:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101818:	ee                   	out    %al,(%dx)
}
c0101819:	90                   	nop
c010181a:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101820:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101824:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101828:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010182c:	ee                   	out    %al,(%dx)
}
c010182d:	90                   	nop
c010182e:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101834:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101838:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010183c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101840:	ee                   	out    %al,(%dx)
}
c0101841:	90                   	nop
c0101842:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0101848:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010184c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101850:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101854:	ee                   	out    %al,(%dx)
}
c0101855:	90                   	nop
c0101856:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c010185c:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101860:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101864:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101868:	ee                   	out    %al,(%dx)
}
c0101869:	90                   	nop
c010186a:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0101870:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101874:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101878:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010187c:	ee                   	out    %al,(%dx)
}
c010187d:	90                   	nop
c010187e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0101884:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101888:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010188c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101890:	ee                   	out    %al,(%dx)
}
c0101891:	90                   	nop
c0101892:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101898:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010189c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018a4:	ee                   	out    %al,(%dx)
}
c01018a5:	90                   	nop
c01018a6:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018ac:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018b8:	ee                   	out    %al,(%dx)
}
c01018b9:	90                   	nop
c01018ba:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01018c0:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01018c8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018cc:	ee                   	out    %al,(%dx)
}
c01018cd:	90                   	nop
c01018ce:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01018d4:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018dc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018e0:	ee                   	out    %al,(%dx)
}
c01018e1:	90                   	nop
c01018e2:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01018e8:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ec:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01018f0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01018f4:	ee                   	out    %al,(%dx)
}
c01018f5:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01018f6:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c01018fd:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101902:	74 0f                	je     c0101913 <pic_init+0x145>
        pic_setmask(irq_mask);
c0101904:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010190b:	89 04 24             	mov    %eax,(%esp)
c010190e:	e8 29 fe ff ff       	call   c010173c <pic_setmask>
    }
}
c0101913:	90                   	nop
c0101914:	89 ec                	mov    %ebp,%esp
c0101916:	5d                   	pop    %ebp
c0101917:	c3                   	ret    

c0101918 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101918:	55                   	push   %ebp
c0101919:	89 e5                	mov    %esp,%ebp
c010191b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010191e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101925:	00 
c0101926:	c7 04 24 20 62 10 c0 	movl   $0xc0106220,(%esp)
c010192d:	e8 24 ea ff ff       	call   c0100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0101932:	c7 04 24 2a 62 10 c0 	movl   $0xc010622a,(%esp)
c0101939:	e8 18 ea ff ff       	call   c0100356 <cprintf>
    panic("EOT: kernel seems ok.");
c010193e:	c7 44 24 08 38 62 10 	movl   $0xc0106238,0x8(%esp)
c0101945:	c0 
c0101946:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010194d:	00 
c010194e:	c7 04 24 4e 62 10 c0 	movl   $0xc010624e,(%esp)
c0101955:	e8 81 f3 ff ff       	call   c0100cdb <__panic>

c010195a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010195a:	55                   	push   %ebp
c010195b:	89 e5                	mov    %esp,%ebp
c010195d:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
   //使用SETGATE宏，对中断描述符表中的每一个表项进行设置
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) { //IDT表项的个数
c0101960:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101967:	e9 c4 00 00 00       	jmp    c0101a30 <idt_init+0xd6>
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]，特权级为DPL_KERNEL。这样通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196f:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101976:	0f b7 d0             	movzwl %ax,%edx
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c0101983:	c0 
c0101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101987:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c010198e:	c0 08 00 
c0101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101994:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010199b:	c0 
c010199c:	80 e2 e0             	and    $0xe0,%dl
c010199f:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a9:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c01019b0:	c0 
c01019b1:	80 e2 1f             	and    $0x1f,%dl
c01019b4:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019be:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019c5:	c0 
c01019c6:	80 e2 f0             	and    $0xf0,%dl
c01019c9:	80 ca 0e             	or     $0xe,%dl
c01019cc:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d6:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019dd:	c0 
c01019de:	80 e2 ef             	and    $0xef,%dl
c01019e1:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019eb:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019f2:	c0 
c01019f3:	80 e2 9f             	and    $0x9f,%dl
c01019f6:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a00:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a07:	c0 
c0101a08:	80 ca 80             	or     $0x80,%dl
c0101a0b:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a15:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101a1c:	c1 e8 10             	shr    $0x10,%eax
c0101a1f:	0f b7 d0             	movzwl %ax,%edx
c0101a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a25:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c0101a2c:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) { //IDT表项的个数
c0101a2d:	ff 45 fc             	incl   -0x4(%ebp)
c0101a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a33:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a38:	0f 86 2e ff ff ff    	jbe    c010196c <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,     
c0101a3e:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c0101a43:	0f b7 c0             	movzwl %ax,%eax
c0101a46:	66 a3 48 ba 11 c0    	mov    %ax,0xc011ba48
c0101a4c:	66 c7 05 4a ba 11 c0 	movw   $0x8,0xc011ba4a
c0101a53:	08 00 
c0101a55:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c0101a5c:	24 e0                	and    $0xe0,%al
c0101a5e:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c0101a63:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c0101a6a:	24 1f                	and    $0x1f,%al
c0101a6c:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c0101a71:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a78:	24 f0                	and    $0xf0,%al
c0101a7a:	0c 0e                	or     $0xe,%al
c0101a7c:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a81:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a88:	24 ef                	and    $0xef,%al
c0101a8a:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a8f:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a96:	0c 60                	or     $0x60,%al
c0101a98:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a9d:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101aa4:	0c 80                	or     $0x80,%al
c0101aa6:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101aab:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c0101ab0:	c1 e8 10             	shr    $0x10,%eax
c0101ab3:	0f b7 c0             	movzwl %ax,%eax
c0101ab6:	66 a3 4e ba 11 c0    	mov    %ax,0xc011ba4e
c0101abc:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101ac6:	0f 01 18             	lidtl  (%eax)
}
c0101ac9:	90                   	nop
    __vectors[T_SWITCH_TOK], DPL_USER);
     //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
c0101aca:	90                   	nop
c0101acb:	89 ec                	mov    %ebp,%esp
c0101acd:	5d                   	pop    %ebp
c0101ace:	c3                   	ret    

c0101acf <trapname>:

static const char *
trapname(int trapno) {
c0101acf:	55                   	push   %ebp
c0101ad0:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	83 f8 13             	cmp    $0x13,%eax
c0101ad8:	77 0c                	ja     c0101ae6 <trapname+0x17>
        return excnames[trapno];
c0101ada:	8b 45 08             	mov    0x8(%ebp),%eax
c0101add:	8b 04 85 a0 65 10 c0 	mov    -0x3fef9a60(,%eax,4),%eax
c0101ae4:	eb 18                	jmp    c0101afe <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101ae6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101aea:	7e 0d                	jle    c0101af9 <trapname+0x2a>
c0101aec:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101af0:	7f 07                	jg     c0101af9 <trapname+0x2a>
        return "Hardware Interrupt";
c0101af2:	b8 5f 62 10 c0       	mov    $0xc010625f,%eax
c0101af7:	eb 05                	jmp    c0101afe <trapname+0x2f>
    }
    return "(unknown trap)";
c0101af9:	b8 72 62 10 c0       	mov    $0xc0106272,%eax
}
c0101afe:	5d                   	pop    %ebp
c0101aff:	c3                   	ret    

c0101b00 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b00:	55                   	push   %ebp
c0101b01:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b06:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b0a:	83 f8 08             	cmp    $0x8,%eax
c0101b0d:	0f 94 c0             	sete   %al
c0101b10:	0f b6 c0             	movzbl %al,%eax
}
c0101b13:	5d                   	pop    %ebp
c0101b14:	c3                   	ret    

c0101b15 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b15:	55                   	push   %ebp
c0101b16:	89 e5                	mov    %esp,%ebp
c0101b18:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b22:	c7 04 24 b3 62 10 c0 	movl   $0xc01062b3,(%esp)
c0101b29:	e8 28 e8 ff ff       	call   c0100356 <cprintf>
    print_regs(&tf->tf_regs);
c0101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b31:	89 04 24             	mov    %eax,(%esp)
c0101b34:	e8 8f 01 00 00       	call   c0101cc8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101b39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101b40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b44:	c7 04 24 c4 62 10 c0 	movl   $0xc01062c4,(%esp)
c0101b4b:	e8 06 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b53:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5b:	c7 04 24 d7 62 10 c0 	movl   $0xc01062d7,(%esp)
c0101b62:	e8 ef e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6a:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b72:	c7 04 24 ea 62 10 c0 	movl   $0xc01062ea,(%esp)
c0101b79:	e8 d8 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b81:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b89:	c7 04 24 fd 62 10 c0 	movl   $0xc01062fd,(%esp)
c0101b90:	e8 c1 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b95:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b98:	8b 40 30             	mov    0x30(%eax),%eax
c0101b9b:	89 04 24             	mov    %eax,(%esp)
c0101b9e:	e8 2c ff ff ff       	call   c0101acf <trapname>
c0101ba3:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ba6:	8b 52 30             	mov    0x30(%edx),%edx
c0101ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101bad:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101bb1:	c7 04 24 10 63 10 c0 	movl   $0xc0106310,(%esp)
c0101bb8:	e8 99 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc0:	8b 40 34             	mov    0x34(%eax),%eax
c0101bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc7:	c7 04 24 22 63 10 c0 	movl   $0xc0106322,(%esp)
c0101bce:	e8 83 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd6:	8b 40 38             	mov    0x38(%eax),%eax
c0101bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bdd:	c7 04 24 31 63 10 c0 	movl   $0xc0106331,(%esp)
c0101be4:	e8 6d e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101be9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf4:	c7 04 24 40 63 10 c0 	movl   $0xc0106340,(%esp)
c0101bfb:	e8 56 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c03:	8b 40 40             	mov    0x40(%eax),%eax
c0101c06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c0a:	c7 04 24 53 63 10 c0 	movl   $0xc0106353,(%esp)
c0101c11:	e8 40 e7 ff ff       	call   c0100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c1d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c24:	eb 3d                	jmp    c0101c63 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c29:	8b 50 40             	mov    0x40(%eax),%edx
c0101c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c2f:	21 d0                	and    %edx,%eax
c0101c31:	85 c0                	test   %eax,%eax
c0101c33:	74 28                	je     c0101c5d <print_trapframe+0x148>
c0101c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c38:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101c3f:	85 c0                	test   %eax,%eax
c0101c41:	74 1a                	je     c0101c5d <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c46:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c51:	c7 04 24 62 63 10 c0 	movl   $0xc0106362,(%esp)
c0101c58:	e8 f9 e6 ff ff       	call   c0100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c5d:	ff 45 f4             	incl   -0xc(%ebp)
c0101c60:	d1 65 f0             	shll   -0x10(%ebp)
c0101c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c66:	83 f8 17             	cmp    $0x17,%eax
c0101c69:	76 bb                	jbe    c0101c26 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6e:	8b 40 40             	mov    0x40(%eax),%eax
c0101c71:	c1 e8 0c             	shr    $0xc,%eax
c0101c74:	83 e0 03             	and    $0x3,%eax
c0101c77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7b:	c7 04 24 66 63 10 c0 	movl   $0xc0106366,(%esp)
c0101c82:	e8 cf e6 ff ff       	call   c0100356 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8a:	89 04 24             	mov    %eax,(%esp)
c0101c8d:	e8 6e fe ff ff       	call   c0101b00 <trap_in_kernel>
c0101c92:	85 c0                	test   %eax,%eax
c0101c94:	75 2d                	jne    c0101cc3 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c99:	8b 40 44             	mov    0x44(%eax),%eax
c0101c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca0:	c7 04 24 6f 63 10 c0 	movl   $0xc010636f,(%esp)
c0101ca7:	e8 aa e6 ff ff       	call   c0100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101cac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101caf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb7:	c7 04 24 7e 63 10 c0 	movl   $0xc010637e,(%esp)
c0101cbe:	e8 93 e6 ff ff       	call   c0100356 <cprintf>
    }
}
c0101cc3:	90                   	nop
c0101cc4:	89 ec                	mov    %ebp,%esp
c0101cc6:	5d                   	pop    %ebp
c0101cc7:	c3                   	ret    

c0101cc8 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101cc8:	55                   	push   %ebp
c0101cc9:	89 e5                	mov    %esp,%ebp
c0101ccb:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd1:	8b 00                	mov    (%eax),%eax
c0101cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd7:	c7 04 24 91 63 10 c0 	movl   $0xc0106391,(%esp)
c0101cde:	e8 73 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce6:	8b 40 04             	mov    0x4(%eax),%eax
c0101ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ced:	c7 04 24 a0 63 10 c0 	movl   $0xc01063a0,(%esp)
c0101cf4:	e8 5d e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cfc:	8b 40 08             	mov    0x8(%eax),%eax
c0101cff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d03:	c7 04 24 af 63 10 c0 	movl   $0xc01063af,(%esp)
c0101d0a:	e8 47 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d12:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d19:	c7 04 24 be 63 10 c0 	movl   $0xc01063be,(%esp)
c0101d20:	e8 31 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d28:	8b 40 10             	mov    0x10(%eax),%eax
c0101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d2f:	c7 04 24 cd 63 10 c0 	movl   $0xc01063cd,(%esp)
c0101d36:	e8 1b e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d3e:	8b 40 14             	mov    0x14(%eax),%eax
c0101d41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d45:	c7 04 24 dc 63 10 c0 	movl   $0xc01063dc,(%esp)
c0101d4c:	e8 05 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101d51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d54:	8b 40 18             	mov    0x18(%eax),%eax
c0101d57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d5b:	c7 04 24 eb 63 10 c0 	movl   $0xc01063eb,(%esp)
c0101d62:	e8 ef e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d71:	c7 04 24 fa 63 10 c0 	movl   $0xc01063fa,(%esp)
c0101d78:	e8 d9 e5 ff ff       	call   c0100356 <cprintf>
}
c0101d7d:	90                   	nop
c0101d7e:	89 ec                	mov    %ebp,%esp
c0101d80:	5d                   	pop    %ebp
c0101d81:	c3                   	ret    

c0101d82 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d82:	55                   	push   %ebp
c0101d83:	89 e5                	mov    %esp,%ebp
c0101d85:	83 ec 28             	sub    $0x28,%esp
    char c;
    switch (tf->tf_trapno) {
c0101d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8b:	8b 40 30             	mov    0x30(%eax),%eax
c0101d8e:	83 f8 79             	cmp    $0x79,%eax
c0101d91:	0f 87 e6 00 00 00    	ja     c0101e7d <trap_dispatch+0xfb>
c0101d97:	83 f8 78             	cmp    $0x78,%eax
c0101d9a:	0f 83 c1 00 00 00    	jae    c0101e61 <trap_dispatch+0xdf>
c0101da0:	83 f8 2f             	cmp    $0x2f,%eax
c0101da3:	0f 87 d4 00 00 00    	ja     c0101e7d <trap_dispatch+0xfb>
c0101da9:	83 f8 2e             	cmp    $0x2e,%eax
c0101dac:	0f 83 00 01 00 00    	jae    c0101eb2 <trap_dispatch+0x130>
c0101db2:	83 f8 24             	cmp    $0x24,%eax
c0101db5:	74 5e                	je     c0101e15 <trap_dispatch+0x93>
c0101db7:	83 f8 24             	cmp    $0x24,%eax
c0101dba:	0f 87 bd 00 00 00    	ja     c0101e7d <trap_dispatch+0xfb>
c0101dc0:	83 f8 20             	cmp    $0x20,%eax
c0101dc3:	74 0a                	je     c0101dcf <trap_dispatch+0x4d>
c0101dc5:	83 f8 21             	cmp    $0x21,%eax
c0101dc8:	74 71                	je     c0101e3b <trap_dispatch+0xb9>
c0101dca:	e9 ae 00 00 00       	jmp    c0101e7d <trap_dispatch+0xfb>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101dcf:	a1 24 b4 11 c0       	mov    0xc011b424,%eax
c0101dd4:	40                   	inc    %eax
c0101dd5:	a3 24 b4 11 c0       	mov    %eax,0xc011b424
        if (ticks % TICK_NUM == 0) {
c0101dda:	8b 0d 24 b4 11 c0    	mov    0xc011b424,%ecx
c0101de0:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101de5:	89 c8                	mov    %ecx,%eax
c0101de7:	f7 e2                	mul    %edx
c0101de9:	c1 ea 05             	shr    $0x5,%edx
c0101dec:	89 d0                	mov    %edx,%eax
c0101dee:	c1 e0 02             	shl    $0x2,%eax
c0101df1:	01 d0                	add    %edx,%eax
c0101df3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101dfa:	01 d0                	add    %edx,%eax
c0101dfc:	c1 e0 02             	shl    $0x2,%eax
c0101dff:	29 c1                	sub    %eax,%ecx
c0101e01:	89 ca                	mov    %ecx,%edx
c0101e03:	85 d2                	test   %edx,%edx
c0101e05:	0f 85 aa 00 00 00    	jne    c0101eb5 <trap_dispatch+0x133>
            print_ticks();
c0101e0b:	e8 08 fb ff ff       	call   c0101918 <print_ticks>
        }
        break;
c0101e10:	e9 a0 00 00 00       	jmp    c0101eb5 <trap_dispatch+0x133>
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e15:	e8 a1 f8 ff ff       	call   c01016bb <cons_getc>
c0101e1a:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101e1d:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e21:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e25:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e2d:	c7 04 24 09 64 10 c0 	movl   $0xc0106409,(%esp)
c0101e34:	e8 1d e5 ff ff       	call   c0100356 <cprintf>
        break;
c0101e39:	eb 7b                	jmp    c0101eb6 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101e3b:	e8 7b f8 ff ff       	call   c01016bb <cons_getc>
c0101e40:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101e43:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e47:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e53:	c7 04 24 1b 64 10 c0 	movl   $0xc010641b,(%esp)
c0101e5a:	e8 f7 e4 ff ff       	call   c0100356 <cprintf>
        break;
c0101e5f:	eb 55                	jmp    c0101eb6 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101e61:	c7 44 24 08 2a 64 10 	movl   $0xc010642a,0x8(%esp)
c0101e68:	c0 
c0101e69:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0101e70:	00 
c0101e71:	c7 04 24 4e 62 10 c0 	movl   $0xc010624e,(%esp)
c0101e78:	e8 5e ee ff ff       	call   c0100cdb <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e84:	83 e0 03             	and    $0x3,%eax
c0101e87:	85 c0                	test   %eax,%eax
c0101e89:	75 2b                	jne    c0101eb6 <trap_dispatch+0x134>
            print_trapframe(tf);
c0101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8e:	89 04 24             	mov    %eax,(%esp)
c0101e91:	e8 7f fc ff ff       	call   c0101b15 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101e96:	c7 44 24 08 3a 64 10 	movl   $0xc010643a,0x8(%esp)
c0101e9d:	c0 
c0101e9e:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0101ea5:	00 
c0101ea6:	c7 04 24 4e 62 10 c0 	movl   $0xc010624e,(%esp)
c0101ead:	e8 29 ee ff ff       	call   c0100cdb <__panic>
        break;
c0101eb2:	90                   	nop
c0101eb3:	eb 01                	jmp    c0101eb6 <trap_dispatch+0x134>
        break;
c0101eb5:	90                   	nop
        }
    }
}
c0101eb6:	90                   	nop
c0101eb7:	89 ec                	mov    %ebp,%esp
c0101eb9:	5d                   	pop    %ebp
c0101eba:	c3                   	ret    

c0101ebb <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101ebb:	55                   	push   %ebp
c0101ebc:	89 e5                	mov    %esp,%ebp
c0101ebe:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec4:	89 04 24             	mov    %eax,(%esp)
c0101ec7:	e8 b6 fe ff ff       	call   c0101d82 <trap_dispatch>
}
c0101ecc:	90                   	nop
c0101ecd:	89 ec                	mov    %ebp,%esp
c0101ecf:	5d                   	pop    %ebp
c0101ed0:	c3                   	ret    

c0101ed1 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101ed1:	1e                   	push   %ds
    pushl %es
c0101ed2:	06                   	push   %es
    pushl %fs
c0101ed3:	0f a0                	push   %fs
    pushl %gs
c0101ed5:	0f a8                	push   %gs
    pushal
c0101ed7:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101ed8:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101edd:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101edf:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101ee1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101ee2:	e8 d4 ff ff ff       	call   c0101ebb <trap>

    # pop the pushed stack pointer
    popl %esp
c0101ee7:	5c                   	pop    %esp

c0101ee8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101ee8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101ee9:	0f a9                	pop    %gs
    popl %fs
c0101eeb:	0f a1                	pop    %fs
    popl %es
c0101eed:	07                   	pop    %es
    popl %ds
c0101eee:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101eef:	83 c4 08             	add    $0x8,%esp
    iret
c0101ef2:	cf                   	iret   

c0101ef3 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101ef3:	6a 00                	push   $0x0
  pushl $0
c0101ef5:	6a 00                	push   $0x0
  jmp __alltraps
c0101ef7:	e9 d5 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101efc <vector1>:
.globl vector1
vector1:
  pushl $0
c0101efc:	6a 00                	push   $0x0
  pushl $1
c0101efe:	6a 01                	push   $0x1
  jmp __alltraps
c0101f00:	e9 cc ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f05 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f05:	6a 00                	push   $0x0
  pushl $2
c0101f07:	6a 02                	push   $0x2
  jmp __alltraps
c0101f09:	e9 c3 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f0e <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f0e:	6a 00                	push   $0x0
  pushl $3
c0101f10:	6a 03                	push   $0x3
  jmp __alltraps
c0101f12:	e9 ba ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f17 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f17:	6a 00                	push   $0x0
  pushl $4
c0101f19:	6a 04                	push   $0x4
  jmp __alltraps
c0101f1b:	e9 b1 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f20 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101f20:	6a 00                	push   $0x0
  pushl $5
c0101f22:	6a 05                	push   $0x5
  jmp __alltraps
c0101f24:	e9 a8 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f29 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101f29:	6a 00                	push   $0x0
  pushl $6
c0101f2b:	6a 06                	push   $0x6
  jmp __alltraps
c0101f2d:	e9 9f ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f32 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101f32:	6a 00                	push   $0x0
  pushl $7
c0101f34:	6a 07                	push   $0x7
  jmp __alltraps
c0101f36:	e9 96 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f3b <vector8>:
.globl vector8
vector8:
  pushl $8
c0101f3b:	6a 08                	push   $0x8
  jmp __alltraps
c0101f3d:	e9 8f ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f42 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101f42:	6a 00                	push   $0x0
  pushl $9
c0101f44:	6a 09                	push   $0x9
  jmp __alltraps
c0101f46:	e9 86 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f4b <vector10>:
.globl vector10
vector10:
  pushl $10
c0101f4b:	6a 0a                	push   $0xa
  jmp __alltraps
c0101f4d:	e9 7f ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f52 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101f52:	6a 0b                	push   $0xb
  jmp __alltraps
c0101f54:	e9 78 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f59 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101f59:	6a 0c                	push   $0xc
  jmp __alltraps
c0101f5b:	e9 71 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f60 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101f60:	6a 0d                	push   $0xd
  jmp __alltraps
c0101f62:	e9 6a ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f67 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101f67:	6a 0e                	push   $0xe
  jmp __alltraps
c0101f69:	e9 63 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f6e <vector15>:
.globl vector15
vector15:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $15
c0101f70:	6a 0f                	push   $0xf
  jmp __alltraps
c0101f72:	e9 5a ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f77 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $16
c0101f79:	6a 10                	push   $0x10
  jmp __alltraps
c0101f7b:	e9 51 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f80 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101f80:	6a 11                	push   $0x11
  jmp __alltraps
c0101f82:	e9 4a ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f87 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $18
c0101f89:	6a 12                	push   $0x12
  jmp __alltraps
c0101f8b:	e9 41 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f90 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $19
c0101f92:	6a 13                	push   $0x13
  jmp __alltraps
c0101f94:	e9 38 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101f99 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $20
c0101f9b:	6a 14                	push   $0x14
  jmp __alltraps
c0101f9d:	e9 2f ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fa2 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $21
c0101fa4:	6a 15                	push   $0x15
  jmp __alltraps
c0101fa6:	e9 26 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fab <vector22>:
.globl vector22
vector22:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $22
c0101fad:	6a 16                	push   $0x16
  jmp __alltraps
c0101faf:	e9 1d ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fb4 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $23
c0101fb6:	6a 17                	push   $0x17
  jmp __alltraps
c0101fb8:	e9 14 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fbd <vector24>:
.globl vector24
vector24:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $24
c0101fbf:	6a 18                	push   $0x18
  jmp __alltraps
c0101fc1:	e9 0b ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fc6 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $25
c0101fc8:	6a 19                	push   $0x19
  jmp __alltraps
c0101fca:	e9 02 ff ff ff       	jmp    c0101ed1 <__alltraps>

c0101fcf <vector26>:
.globl vector26
vector26:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $26
c0101fd1:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101fd3:	e9 f9 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0101fd8 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $27
c0101fda:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101fdc:	e9 f0 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0101fe1 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $28
c0101fe3:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101fe5:	e9 e7 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0101fea <vector29>:
.globl vector29
vector29:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $29
c0101fec:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101fee:	e9 de fe ff ff       	jmp    c0101ed1 <__alltraps>

c0101ff3 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $30
c0101ff5:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ff7:	e9 d5 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0101ffc <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $31
c0101ffe:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102000:	e9 cc fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102005 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $32
c0102007:	6a 20                	push   $0x20
  jmp __alltraps
c0102009:	e9 c3 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010200e <vector33>:
.globl vector33
vector33:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $33
c0102010:	6a 21                	push   $0x21
  jmp __alltraps
c0102012:	e9 ba fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102017 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $34
c0102019:	6a 22                	push   $0x22
  jmp __alltraps
c010201b:	e9 b1 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102020 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $35
c0102022:	6a 23                	push   $0x23
  jmp __alltraps
c0102024:	e9 a8 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102029 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $36
c010202b:	6a 24                	push   $0x24
  jmp __alltraps
c010202d:	e9 9f fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102032 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $37
c0102034:	6a 25                	push   $0x25
  jmp __alltraps
c0102036:	e9 96 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010203b <vector38>:
.globl vector38
vector38:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $38
c010203d:	6a 26                	push   $0x26
  jmp __alltraps
c010203f:	e9 8d fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102044 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $39
c0102046:	6a 27                	push   $0x27
  jmp __alltraps
c0102048:	e9 84 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010204d <vector40>:
.globl vector40
vector40:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $40
c010204f:	6a 28                	push   $0x28
  jmp __alltraps
c0102051:	e9 7b fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102056 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $41
c0102058:	6a 29                	push   $0x29
  jmp __alltraps
c010205a:	e9 72 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010205f <vector42>:
.globl vector42
vector42:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $42
c0102061:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102063:	e9 69 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102068 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $43
c010206a:	6a 2b                	push   $0x2b
  jmp __alltraps
c010206c:	e9 60 fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102071 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $44
c0102073:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102075:	e9 57 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010207a <vector45>:
.globl vector45
vector45:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $45
c010207c:	6a 2d                	push   $0x2d
  jmp __alltraps
c010207e:	e9 4e fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102083 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $46
c0102085:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102087:	e9 45 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010208c <vector47>:
.globl vector47
vector47:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $47
c010208e:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102090:	e9 3c fe ff ff       	jmp    c0101ed1 <__alltraps>

c0102095 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $48
c0102097:	6a 30                	push   $0x30
  jmp __alltraps
c0102099:	e9 33 fe ff ff       	jmp    c0101ed1 <__alltraps>

c010209e <vector49>:
.globl vector49
vector49:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $49
c01020a0:	6a 31                	push   $0x31
  jmp __alltraps
c01020a2:	e9 2a fe ff ff       	jmp    c0101ed1 <__alltraps>

c01020a7 <vector50>:
.globl vector50
vector50:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $50
c01020a9:	6a 32                	push   $0x32
  jmp __alltraps
c01020ab:	e9 21 fe ff ff       	jmp    c0101ed1 <__alltraps>

c01020b0 <vector51>:
.globl vector51
vector51:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $51
c01020b2:	6a 33                	push   $0x33
  jmp __alltraps
c01020b4:	e9 18 fe ff ff       	jmp    c0101ed1 <__alltraps>

c01020b9 <vector52>:
.globl vector52
vector52:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $52
c01020bb:	6a 34                	push   $0x34
  jmp __alltraps
c01020bd:	e9 0f fe ff ff       	jmp    c0101ed1 <__alltraps>

c01020c2 <vector53>:
.globl vector53
vector53:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $53
c01020c4:	6a 35                	push   $0x35
  jmp __alltraps
c01020c6:	e9 06 fe ff ff       	jmp    c0101ed1 <__alltraps>

c01020cb <vector54>:
.globl vector54
vector54:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $54
c01020cd:	6a 36                	push   $0x36
  jmp __alltraps
c01020cf:	e9 fd fd ff ff       	jmp    c0101ed1 <__alltraps>

c01020d4 <vector55>:
.globl vector55
vector55:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $55
c01020d6:	6a 37                	push   $0x37
  jmp __alltraps
c01020d8:	e9 f4 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01020dd <vector56>:
.globl vector56
vector56:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $56
c01020df:	6a 38                	push   $0x38
  jmp __alltraps
c01020e1:	e9 eb fd ff ff       	jmp    c0101ed1 <__alltraps>

c01020e6 <vector57>:
.globl vector57
vector57:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $57
c01020e8:	6a 39                	push   $0x39
  jmp __alltraps
c01020ea:	e9 e2 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01020ef <vector58>:
.globl vector58
vector58:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $58
c01020f1:	6a 3a                	push   $0x3a
  jmp __alltraps
c01020f3:	e9 d9 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01020f8 <vector59>:
.globl vector59
vector59:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $59
c01020fa:	6a 3b                	push   $0x3b
  jmp __alltraps
c01020fc:	e9 d0 fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102101 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $60
c0102103:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102105:	e9 c7 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010210a <vector61>:
.globl vector61
vector61:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $61
c010210c:	6a 3d                	push   $0x3d
  jmp __alltraps
c010210e:	e9 be fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102113 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $62
c0102115:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102117:	e9 b5 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010211c <vector63>:
.globl vector63
vector63:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $63
c010211e:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102120:	e9 ac fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102125 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $64
c0102127:	6a 40                	push   $0x40
  jmp __alltraps
c0102129:	e9 a3 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010212e <vector65>:
.globl vector65
vector65:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $65
c0102130:	6a 41                	push   $0x41
  jmp __alltraps
c0102132:	e9 9a fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102137 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $66
c0102139:	6a 42                	push   $0x42
  jmp __alltraps
c010213b:	e9 91 fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102140 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $67
c0102142:	6a 43                	push   $0x43
  jmp __alltraps
c0102144:	e9 88 fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102149 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $68
c010214b:	6a 44                	push   $0x44
  jmp __alltraps
c010214d:	e9 7f fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102152 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $69
c0102154:	6a 45                	push   $0x45
  jmp __alltraps
c0102156:	e9 76 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010215b <vector70>:
.globl vector70
vector70:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $70
c010215d:	6a 46                	push   $0x46
  jmp __alltraps
c010215f:	e9 6d fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102164 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $71
c0102166:	6a 47                	push   $0x47
  jmp __alltraps
c0102168:	e9 64 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010216d <vector72>:
.globl vector72
vector72:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $72
c010216f:	6a 48                	push   $0x48
  jmp __alltraps
c0102171:	e9 5b fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102176 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $73
c0102178:	6a 49                	push   $0x49
  jmp __alltraps
c010217a:	e9 52 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010217f <vector74>:
.globl vector74
vector74:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $74
c0102181:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102183:	e9 49 fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102188 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $75
c010218a:	6a 4b                	push   $0x4b
  jmp __alltraps
c010218c:	e9 40 fd ff ff       	jmp    c0101ed1 <__alltraps>

c0102191 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $76
c0102193:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102195:	e9 37 fd ff ff       	jmp    c0101ed1 <__alltraps>

c010219a <vector77>:
.globl vector77
vector77:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $77
c010219c:	6a 4d                	push   $0x4d
  jmp __alltraps
c010219e:	e9 2e fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021a3 <vector78>:
.globl vector78
vector78:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $78
c01021a5:	6a 4e                	push   $0x4e
  jmp __alltraps
c01021a7:	e9 25 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021ac <vector79>:
.globl vector79
vector79:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $79
c01021ae:	6a 4f                	push   $0x4f
  jmp __alltraps
c01021b0:	e9 1c fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021b5 <vector80>:
.globl vector80
vector80:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $80
c01021b7:	6a 50                	push   $0x50
  jmp __alltraps
c01021b9:	e9 13 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021be <vector81>:
.globl vector81
vector81:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $81
c01021c0:	6a 51                	push   $0x51
  jmp __alltraps
c01021c2:	e9 0a fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021c7 <vector82>:
.globl vector82
vector82:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $82
c01021c9:	6a 52                	push   $0x52
  jmp __alltraps
c01021cb:	e9 01 fd ff ff       	jmp    c0101ed1 <__alltraps>

c01021d0 <vector83>:
.globl vector83
vector83:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $83
c01021d2:	6a 53                	push   $0x53
  jmp __alltraps
c01021d4:	e9 f8 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01021d9 <vector84>:
.globl vector84
vector84:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $84
c01021db:	6a 54                	push   $0x54
  jmp __alltraps
c01021dd:	e9 ef fc ff ff       	jmp    c0101ed1 <__alltraps>

c01021e2 <vector85>:
.globl vector85
vector85:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $85
c01021e4:	6a 55                	push   $0x55
  jmp __alltraps
c01021e6:	e9 e6 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01021eb <vector86>:
.globl vector86
vector86:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $86
c01021ed:	6a 56                	push   $0x56
  jmp __alltraps
c01021ef:	e9 dd fc ff ff       	jmp    c0101ed1 <__alltraps>

c01021f4 <vector87>:
.globl vector87
vector87:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $87
c01021f6:	6a 57                	push   $0x57
  jmp __alltraps
c01021f8:	e9 d4 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01021fd <vector88>:
.globl vector88
vector88:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $88
c01021ff:	6a 58                	push   $0x58
  jmp __alltraps
c0102201:	e9 cb fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102206 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $89
c0102208:	6a 59                	push   $0x59
  jmp __alltraps
c010220a:	e9 c2 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010220f <vector90>:
.globl vector90
vector90:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $90
c0102211:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102213:	e9 b9 fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102218 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $91
c010221a:	6a 5b                	push   $0x5b
  jmp __alltraps
c010221c:	e9 b0 fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102221 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $92
c0102223:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102225:	e9 a7 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010222a <vector93>:
.globl vector93
vector93:
  pushl $0
c010222a:	6a 00                	push   $0x0
  pushl $93
c010222c:	6a 5d                	push   $0x5d
  jmp __alltraps
c010222e:	e9 9e fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102233 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102233:	6a 00                	push   $0x0
  pushl $94
c0102235:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102237:	e9 95 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010223c <vector95>:
.globl vector95
vector95:
  pushl $0
c010223c:	6a 00                	push   $0x0
  pushl $95
c010223e:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102240:	e9 8c fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102245 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $96
c0102247:	6a 60                	push   $0x60
  jmp __alltraps
c0102249:	e9 83 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010224e <vector97>:
.globl vector97
vector97:
  pushl $0
c010224e:	6a 00                	push   $0x0
  pushl $97
c0102250:	6a 61                	push   $0x61
  jmp __alltraps
c0102252:	e9 7a fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102257 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102257:	6a 00                	push   $0x0
  pushl $98
c0102259:	6a 62                	push   $0x62
  jmp __alltraps
c010225b:	e9 71 fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102260 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102260:	6a 00                	push   $0x0
  pushl $99
c0102262:	6a 63                	push   $0x63
  jmp __alltraps
c0102264:	e9 68 fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102269 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $100
c010226b:	6a 64                	push   $0x64
  jmp __alltraps
c010226d:	e9 5f fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102272 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102272:	6a 00                	push   $0x0
  pushl $101
c0102274:	6a 65                	push   $0x65
  jmp __alltraps
c0102276:	e9 56 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010227b <vector102>:
.globl vector102
vector102:
  pushl $0
c010227b:	6a 00                	push   $0x0
  pushl $102
c010227d:	6a 66                	push   $0x66
  jmp __alltraps
c010227f:	e9 4d fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102284 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102284:	6a 00                	push   $0x0
  pushl $103
c0102286:	6a 67                	push   $0x67
  jmp __alltraps
c0102288:	e9 44 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010228d <vector104>:
.globl vector104
vector104:
  pushl $0
c010228d:	6a 00                	push   $0x0
  pushl $104
c010228f:	6a 68                	push   $0x68
  jmp __alltraps
c0102291:	e9 3b fc ff ff       	jmp    c0101ed1 <__alltraps>

c0102296 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102296:	6a 00                	push   $0x0
  pushl $105
c0102298:	6a 69                	push   $0x69
  jmp __alltraps
c010229a:	e9 32 fc ff ff       	jmp    c0101ed1 <__alltraps>

c010229f <vector106>:
.globl vector106
vector106:
  pushl $0
c010229f:	6a 00                	push   $0x0
  pushl $106
c01022a1:	6a 6a                	push   $0x6a
  jmp __alltraps
c01022a3:	e9 29 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01022a8 <vector107>:
.globl vector107
vector107:
  pushl $0
c01022a8:	6a 00                	push   $0x0
  pushl $107
c01022aa:	6a 6b                	push   $0x6b
  jmp __alltraps
c01022ac:	e9 20 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01022b1 <vector108>:
.globl vector108
vector108:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $108
c01022b3:	6a 6c                	push   $0x6c
  jmp __alltraps
c01022b5:	e9 17 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01022ba <vector109>:
.globl vector109
vector109:
  pushl $0
c01022ba:	6a 00                	push   $0x0
  pushl $109
c01022bc:	6a 6d                	push   $0x6d
  jmp __alltraps
c01022be:	e9 0e fc ff ff       	jmp    c0101ed1 <__alltraps>

c01022c3 <vector110>:
.globl vector110
vector110:
  pushl $0
c01022c3:	6a 00                	push   $0x0
  pushl $110
c01022c5:	6a 6e                	push   $0x6e
  jmp __alltraps
c01022c7:	e9 05 fc ff ff       	jmp    c0101ed1 <__alltraps>

c01022cc <vector111>:
.globl vector111
vector111:
  pushl $0
c01022cc:	6a 00                	push   $0x0
  pushl $111
c01022ce:	6a 6f                	push   $0x6f
  jmp __alltraps
c01022d0:	e9 fc fb ff ff       	jmp    c0101ed1 <__alltraps>

c01022d5 <vector112>:
.globl vector112
vector112:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $112
c01022d7:	6a 70                	push   $0x70
  jmp __alltraps
c01022d9:	e9 f3 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01022de <vector113>:
.globl vector113
vector113:
  pushl $0
c01022de:	6a 00                	push   $0x0
  pushl $113
c01022e0:	6a 71                	push   $0x71
  jmp __alltraps
c01022e2:	e9 ea fb ff ff       	jmp    c0101ed1 <__alltraps>

c01022e7 <vector114>:
.globl vector114
vector114:
  pushl $0
c01022e7:	6a 00                	push   $0x0
  pushl $114
c01022e9:	6a 72                	push   $0x72
  jmp __alltraps
c01022eb:	e9 e1 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01022f0 <vector115>:
.globl vector115
vector115:
  pushl $0
c01022f0:	6a 00                	push   $0x0
  pushl $115
c01022f2:	6a 73                	push   $0x73
  jmp __alltraps
c01022f4:	e9 d8 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01022f9 <vector116>:
.globl vector116
vector116:
  pushl $0
c01022f9:	6a 00                	push   $0x0
  pushl $116
c01022fb:	6a 74                	push   $0x74
  jmp __alltraps
c01022fd:	e9 cf fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102302 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102302:	6a 00                	push   $0x0
  pushl $117
c0102304:	6a 75                	push   $0x75
  jmp __alltraps
c0102306:	e9 c6 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010230b <vector118>:
.globl vector118
vector118:
  pushl $0
c010230b:	6a 00                	push   $0x0
  pushl $118
c010230d:	6a 76                	push   $0x76
  jmp __alltraps
c010230f:	e9 bd fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102314 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102314:	6a 00                	push   $0x0
  pushl $119
c0102316:	6a 77                	push   $0x77
  jmp __alltraps
c0102318:	e9 b4 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010231d <vector120>:
.globl vector120
vector120:
  pushl $0
c010231d:	6a 00                	push   $0x0
  pushl $120
c010231f:	6a 78                	push   $0x78
  jmp __alltraps
c0102321:	e9 ab fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102326 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102326:	6a 00                	push   $0x0
  pushl $121
c0102328:	6a 79                	push   $0x79
  jmp __alltraps
c010232a:	e9 a2 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010232f <vector122>:
.globl vector122
vector122:
  pushl $0
c010232f:	6a 00                	push   $0x0
  pushl $122
c0102331:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102333:	e9 99 fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102338 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102338:	6a 00                	push   $0x0
  pushl $123
c010233a:	6a 7b                	push   $0x7b
  jmp __alltraps
c010233c:	e9 90 fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102341 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102341:	6a 00                	push   $0x0
  pushl $124
c0102343:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102345:	e9 87 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010234a <vector125>:
.globl vector125
vector125:
  pushl $0
c010234a:	6a 00                	push   $0x0
  pushl $125
c010234c:	6a 7d                	push   $0x7d
  jmp __alltraps
c010234e:	e9 7e fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102353 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102353:	6a 00                	push   $0x0
  pushl $126
c0102355:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102357:	e9 75 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010235c <vector127>:
.globl vector127
vector127:
  pushl $0
c010235c:	6a 00                	push   $0x0
  pushl $127
c010235e:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102360:	e9 6c fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102365 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102365:	6a 00                	push   $0x0
  pushl $128
c0102367:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010236c:	e9 60 fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102371 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $129
c0102373:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102378:	e9 54 fb ff ff       	jmp    c0101ed1 <__alltraps>

c010237d <vector130>:
.globl vector130
vector130:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $130
c010237f:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102384:	e9 48 fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102389 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102389:	6a 00                	push   $0x0
  pushl $131
c010238b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102390:	e9 3c fb ff ff       	jmp    c0101ed1 <__alltraps>

c0102395 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $132
c0102397:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010239c:	e9 30 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01023a1 <vector133>:
.globl vector133
vector133:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $133
c01023a3:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01023a8:	e9 24 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01023ad <vector134>:
.globl vector134
vector134:
  pushl $0
c01023ad:	6a 00                	push   $0x0
  pushl $134
c01023af:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01023b4:	e9 18 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01023b9 <vector135>:
.globl vector135
vector135:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $135
c01023bb:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01023c0:	e9 0c fb ff ff       	jmp    c0101ed1 <__alltraps>

c01023c5 <vector136>:
.globl vector136
vector136:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $136
c01023c7:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01023cc:	e9 00 fb ff ff       	jmp    c0101ed1 <__alltraps>

c01023d1 <vector137>:
.globl vector137
vector137:
  pushl $0
c01023d1:	6a 00                	push   $0x0
  pushl $137
c01023d3:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01023d8:	e9 f4 fa ff ff       	jmp    c0101ed1 <__alltraps>

c01023dd <vector138>:
.globl vector138
vector138:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $138
c01023df:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01023e4:	e9 e8 fa ff ff       	jmp    c0101ed1 <__alltraps>

c01023e9 <vector139>:
.globl vector139
vector139:
  pushl $0
c01023e9:	6a 00                	push   $0x0
  pushl $139
c01023eb:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01023f0:	e9 dc fa ff ff       	jmp    c0101ed1 <__alltraps>

c01023f5 <vector140>:
.globl vector140
vector140:
  pushl $0
c01023f5:	6a 00                	push   $0x0
  pushl $140
c01023f7:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01023fc:	e9 d0 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102401 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $141
c0102403:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102408:	e9 c4 fa ff ff       	jmp    c0101ed1 <__alltraps>

c010240d <vector142>:
.globl vector142
vector142:
  pushl $0
c010240d:	6a 00                	push   $0x0
  pushl $142
c010240f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102414:	e9 b8 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102419 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102419:	6a 00                	push   $0x0
  pushl $143
c010241b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102420:	e9 ac fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102425 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102425:	6a 00                	push   $0x0
  pushl $144
c0102427:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010242c:	e9 a0 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102431 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102431:	6a 00                	push   $0x0
  pushl $145
c0102433:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102438:	e9 94 fa ff ff       	jmp    c0101ed1 <__alltraps>

c010243d <vector146>:
.globl vector146
vector146:
  pushl $0
c010243d:	6a 00                	push   $0x0
  pushl $146
c010243f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102444:	e9 88 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102449 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102449:	6a 00                	push   $0x0
  pushl $147
c010244b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102450:	e9 7c fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102455 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102455:	6a 00                	push   $0x0
  pushl $148
c0102457:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010245c:	e9 70 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102461 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102461:	6a 00                	push   $0x0
  pushl $149
c0102463:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102468:	e9 64 fa ff ff       	jmp    c0101ed1 <__alltraps>

c010246d <vector150>:
.globl vector150
vector150:
  pushl $0
c010246d:	6a 00                	push   $0x0
  pushl $150
c010246f:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102474:	e9 58 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102479 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102479:	6a 00                	push   $0x0
  pushl $151
c010247b:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102480:	e9 4c fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102485 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102485:	6a 00                	push   $0x0
  pushl $152
c0102487:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010248c:	e9 40 fa ff ff       	jmp    c0101ed1 <__alltraps>

c0102491 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102491:	6a 00                	push   $0x0
  pushl $153
c0102493:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102498:	e9 34 fa ff ff       	jmp    c0101ed1 <__alltraps>

c010249d <vector154>:
.globl vector154
vector154:
  pushl $0
c010249d:	6a 00                	push   $0x0
  pushl $154
c010249f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01024a4:	e9 28 fa ff ff       	jmp    c0101ed1 <__alltraps>

c01024a9 <vector155>:
.globl vector155
vector155:
  pushl $0
c01024a9:	6a 00                	push   $0x0
  pushl $155
c01024ab:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01024b0:	e9 1c fa ff ff       	jmp    c0101ed1 <__alltraps>

c01024b5 <vector156>:
.globl vector156
vector156:
  pushl $0
c01024b5:	6a 00                	push   $0x0
  pushl $156
c01024b7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01024bc:	e9 10 fa ff ff       	jmp    c0101ed1 <__alltraps>

c01024c1 <vector157>:
.globl vector157
vector157:
  pushl $0
c01024c1:	6a 00                	push   $0x0
  pushl $157
c01024c3:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01024c8:	e9 04 fa ff ff       	jmp    c0101ed1 <__alltraps>

c01024cd <vector158>:
.globl vector158
vector158:
  pushl $0
c01024cd:	6a 00                	push   $0x0
  pushl $158
c01024cf:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01024d4:	e9 f8 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01024d9 <vector159>:
.globl vector159
vector159:
  pushl $0
c01024d9:	6a 00                	push   $0x0
  pushl $159
c01024db:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01024e0:	e9 ec f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01024e5 <vector160>:
.globl vector160
vector160:
  pushl $0
c01024e5:	6a 00                	push   $0x0
  pushl $160
c01024e7:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01024ec:	e9 e0 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01024f1 <vector161>:
.globl vector161
vector161:
  pushl $0
c01024f1:	6a 00                	push   $0x0
  pushl $161
c01024f3:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01024f8:	e9 d4 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01024fd <vector162>:
.globl vector162
vector162:
  pushl $0
c01024fd:	6a 00                	push   $0x0
  pushl $162
c01024ff:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102504:	e9 c8 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102509 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102509:	6a 00                	push   $0x0
  pushl $163
c010250b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102510:	e9 bc f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102515 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102515:	6a 00                	push   $0x0
  pushl $164
c0102517:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010251c:	e9 b0 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102521 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102521:	6a 00                	push   $0x0
  pushl $165
c0102523:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102528:	e9 a4 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c010252d <vector166>:
.globl vector166
vector166:
  pushl $0
c010252d:	6a 00                	push   $0x0
  pushl $166
c010252f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102534:	e9 98 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102539 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102539:	6a 00                	push   $0x0
  pushl $167
c010253b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102540:	e9 8c f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102545 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102545:	6a 00                	push   $0x0
  pushl $168
c0102547:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010254c:	e9 80 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102551 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102551:	6a 00                	push   $0x0
  pushl $169
c0102553:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102558:	e9 74 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c010255d <vector170>:
.globl vector170
vector170:
  pushl $0
c010255d:	6a 00                	push   $0x0
  pushl $170
c010255f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102564:	e9 68 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102569 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102569:	6a 00                	push   $0x0
  pushl $171
c010256b:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102570:	e9 5c f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102575 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102575:	6a 00                	push   $0x0
  pushl $172
c0102577:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010257c:	e9 50 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102581 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102581:	6a 00                	push   $0x0
  pushl $173
c0102583:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102588:	e9 44 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c010258d <vector174>:
.globl vector174
vector174:
  pushl $0
c010258d:	6a 00                	push   $0x0
  pushl $174
c010258f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102594:	e9 38 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c0102599 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102599:	6a 00                	push   $0x0
  pushl $175
c010259b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01025a0:	e9 2c f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01025a5 <vector176>:
.globl vector176
vector176:
  pushl $0
c01025a5:	6a 00                	push   $0x0
  pushl $176
c01025a7:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01025ac:	e9 20 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01025b1 <vector177>:
.globl vector177
vector177:
  pushl $0
c01025b1:	6a 00                	push   $0x0
  pushl $177
c01025b3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01025b8:	e9 14 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01025bd <vector178>:
.globl vector178
vector178:
  pushl $0
c01025bd:	6a 00                	push   $0x0
  pushl $178
c01025bf:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01025c4:	e9 08 f9 ff ff       	jmp    c0101ed1 <__alltraps>

c01025c9 <vector179>:
.globl vector179
vector179:
  pushl $0
c01025c9:	6a 00                	push   $0x0
  pushl $179
c01025cb:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01025d0:	e9 fc f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01025d5 <vector180>:
.globl vector180
vector180:
  pushl $0
c01025d5:	6a 00                	push   $0x0
  pushl $180
c01025d7:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01025dc:	e9 f0 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01025e1 <vector181>:
.globl vector181
vector181:
  pushl $0
c01025e1:	6a 00                	push   $0x0
  pushl $181
c01025e3:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01025e8:	e9 e4 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01025ed <vector182>:
.globl vector182
vector182:
  pushl $0
c01025ed:	6a 00                	push   $0x0
  pushl $182
c01025ef:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01025f4:	e9 d8 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01025f9 <vector183>:
.globl vector183
vector183:
  pushl $0
c01025f9:	6a 00                	push   $0x0
  pushl $183
c01025fb:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102600:	e9 cc f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102605 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102605:	6a 00                	push   $0x0
  pushl $184
c0102607:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010260c:	e9 c0 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102611 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102611:	6a 00                	push   $0x0
  pushl $185
c0102613:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102618:	e9 b4 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c010261d <vector186>:
.globl vector186
vector186:
  pushl $0
c010261d:	6a 00                	push   $0x0
  pushl $186
c010261f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102624:	e9 a8 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102629 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102629:	6a 00                	push   $0x0
  pushl $187
c010262b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102630:	e9 9c f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102635 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102635:	6a 00                	push   $0x0
  pushl $188
c0102637:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010263c:	e9 90 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102641 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102641:	6a 00                	push   $0x0
  pushl $189
c0102643:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102648:	e9 84 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c010264d <vector190>:
.globl vector190
vector190:
  pushl $0
c010264d:	6a 00                	push   $0x0
  pushl $190
c010264f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102654:	e9 78 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102659 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102659:	6a 00                	push   $0x0
  pushl $191
c010265b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102660:	e9 6c f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102665 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102665:	6a 00                	push   $0x0
  pushl $192
c0102667:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010266c:	e9 60 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102671 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $193
c0102673:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102678:	e9 54 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c010267d <vector194>:
.globl vector194
vector194:
  pushl $0
c010267d:	6a 00                	push   $0x0
  pushl $194
c010267f:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102684:	e9 48 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102689 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102689:	6a 00                	push   $0x0
  pushl $195
c010268b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102690:	e9 3c f8 ff ff       	jmp    c0101ed1 <__alltraps>

c0102695 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $196
c0102697:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010269c:	e9 30 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01026a1 <vector197>:
.globl vector197
vector197:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $197
c01026a3:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01026a8:	e9 24 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01026ad <vector198>:
.globl vector198
vector198:
  pushl $0
c01026ad:	6a 00                	push   $0x0
  pushl $198
c01026af:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01026b4:	e9 18 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01026b9 <vector199>:
.globl vector199
vector199:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $199
c01026bb:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01026c0:	e9 0c f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01026c5 <vector200>:
.globl vector200
vector200:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $200
c01026c7:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01026cc:	e9 00 f8 ff ff       	jmp    c0101ed1 <__alltraps>

c01026d1 <vector201>:
.globl vector201
vector201:
  pushl $0
c01026d1:	6a 00                	push   $0x0
  pushl $201
c01026d3:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01026d8:	e9 f4 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01026dd <vector202>:
.globl vector202
vector202:
  pushl $0
c01026dd:	6a 00                	push   $0x0
  pushl $202
c01026df:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01026e4:	e9 e8 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01026e9 <vector203>:
.globl vector203
vector203:
  pushl $0
c01026e9:	6a 00                	push   $0x0
  pushl $203
c01026eb:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01026f0:	e9 dc f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01026f5 <vector204>:
.globl vector204
vector204:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $204
c01026f7:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01026fc:	e9 d0 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102701 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102701:	6a 00                	push   $0x0
  pushl $205
c0102703:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102708:	e9 c4 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c010270d <vector206>:
.globl vector206
vector206:
  pushl $0
c010270d:	6a 00                	push   $0x0
  pushl $206
c010270f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102714:	e9 b8 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102719 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $207
c010271b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102720:	e9 ac f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102725 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $208
c0102727:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010272c:	e9 a0 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102731 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $209
c0102733:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102738:	e9 94 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c010273d <vector210>:
.globl vector210
vector210:
  pushl $0
c010273d:	6a 00                	push   $0x0
  pushl $210
c010273f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102744:	e9 88 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102749 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $211
c010274b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102750:	e9 7c f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102755 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $212
c0102757:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010275c:	e9 70 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102761 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $213
c0102763:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102768:	e9 64 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c010276d <vector214>:
.globl vector214
vector214:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $214
c010276f:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102774:	e9 58 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102779 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102779:	6a 00                	push   $0x0
  pushl $215
c010277b:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102780:	e9 4c f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102785 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $216
c0102787:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010278c:	e9 40 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c0102791 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $217
c0102793:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102798:	e9 34 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c010279d <vector218>:
.globl vector218
vector218:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $218
c010279f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01027a4:	e9 28 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01027a9 <vector219>:
.globl vector219
vector219:
  pushl $0
c01027a9:	6a 00                	push   $0x0
  pushl $219
c01027ab:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01027b0:	e9 1c f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01027b5 <vector220>:
.globl vector220
vector220:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $220
c01027b7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01027bc:	e9 10 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01027c1 <vector221>:
.globl vector221
vector221:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $221
c01027c3:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01027c8:	e9 04 f7 ff ff       	jmp    c0101ed1 <__alltraps>

c01027cd <vector222>:
.globl vector222
vector222:
  pushl $0
c01027cd:	6a 00                	push   $0x0
  pushl $222
c01027cf:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01027d4:	e9 f8 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01027d9 <vector223>:
.globl vector223
vector223:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $223
c01027db:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01027e0:	e9 ec f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01027e5 <vector224>:
.globl vector224
vector224:
  pushl $0
c01027e5:	6a 00                	push   $0x0
  pushl $224
c01027e7:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01027ec:	e9 e0 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01027f1 <vector225>:
.globl vector225
vector225:
  pushl $0
c01027f1:	6a 00                	push   $0x0
  pushl $225
c01027f3:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01027f8:	e9 d4 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01027fd <vector226>:
.globl vector226
vector226:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $226
c01027ff:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102804:	e9 c8 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102809 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102809:	6a 00                	push   $0x0
  pushl $227
c010280b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102810:	e9 bc f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102815 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102815:	6a 00                	push   $0x0
  pushl $228
c0102817:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010281c:	e9 b0 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102821 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102821:	6a 00                	push   $0x0
  pushl $229
c0102823:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102828:	e9 a4 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c010282d <vector230>:
.globl vector230
vector230:
  pushl $0
c010282d:	6a 00                	push   $0x0
  pushl $230
c010282f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102834:	e9 98 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102839 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102839:	6a 00                	push   $0x0
  pushl $231
c010283b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102840:	e9 8c f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102845 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102845:	6a 00                	push   $0x0
  pushl $232
c0102847:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010284c:	e9 80 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102851 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102851:	6a 00                	push   $0x0
  pushl $233
c0102853:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102858:	e9 74 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c010285d <vector234>:
.globl vector234
vector234:
  pushl $0
c010285d:	6a 00                	push   $0x0
  pushl $234
c010285f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102864:	e9 68 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102869 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102869:	6a 00                	push   $0x0
  pushl $235
c010286b:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102870:	e9 5c f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102875 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102875:	6a 00                	push   $0x0
  pushl $236
c0102877:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010287c:	e9 50 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102881 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102881:	6a 00                	push   $0x0
  pushl $237
c0102883:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102888:	e9 44 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c010288d <vector238>:
.globl vector238
vector238:
  pushl $0
c010288d:	6a 00                	push   $0x0
  pushl $238
c010288f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102894:	e9 38 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c0102899 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102899:	6a 00                	push   $0x0
  pushl $239
c010289b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01028a0:	e9 2c f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01028a5 <vector240>:
.globl vector240
vector240:
  pushl $0
c01028a5:	6a 00                	push   $0x0
  pushl $240
c01028a7:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01028ac:	e9 20 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01028b1 <vector241>:
.globl vector241
vector241:
  pushl $0
c01028b1:	6a 00                	push   $0x0
  pushl $241
c01028b3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01028b8:	e9 14 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01028bd <vector242>:
.globl vector242
vector242:
  pushl $0
c01028bd:	6a 00                	push   $0x0
  pushl $242
c01028bf:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01028c4:	e9 08 f6 ff ff       	jmp    c0101ed1 <__alltraps>

c01028c9 <vector243>:
.globl vector243
vector243:
  pushl $0
c01028c9:	6a 00                	push   $0x0
  pushl $243
c01028cb:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01028d0:	e9 fc f5 ff ff       	jmp    c0101ed1 <__alltraps>

c01028d5 <vector244>:
.globl vector244
vector244:
  pushl $0
c01028d5:	6a 00                	push   $0x0
  pushl $244
c01028d7:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01028dc:	e9 f0 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c01028e1 <vector245>:
.globl vector245
vector245:
  pushl $0
c01028e1:	6a 00                	push   $0x0
  pushl $245
c01028e3:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01028e8:	e9 e4 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c01028ed <vector246>:
.globl vector246
vector246:
  pushl $0
c01028ed:	6a 00                	push   $0x0
  pushl $246
c01028ef:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01028f4:	e9 d8 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c01028f9 <vector247>:
.globl vector247
vector247:
  pushl $0
c01028f9:	6a 00                	push   $0x0
  pushl $247
c01028fb:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102900:	e9 cc f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102905 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102905:	6a 00                	push   $0x0
  pushl $248
c0102907:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010290c:	e9 c0 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102911 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102911:	6a 00                	push   $0x0
  pushl $249
c0102913:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102918:	e9 b4 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c010291d <vector250>:
.globl vector250
vector250:
  pushl $0
c010291d:	6a 00                	push   $0x0
  pushl $250
c010291f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102924:	e9 a8 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102929 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102929:	6a 00                	push   $0x0
  pushl $251
c010292b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102930:	e9 9c f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102935 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102935:	6a 00                	push   $0x0
  pushl $252
c0102937:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010293c:	e9 90 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102941 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102941:	6a 00                	push   $0x0
  pushl $253
c0102943:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102948:	e9 84 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c010294d <vector254>:
.globl vector254
vector254:
  pushl $0
c010294d:	6a 00                	push   $0x0
  pushl $254
c010294f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102954:	e9 78 f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102959 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102959:	6a 00                	push   $0x0
  pushl $255
c010295b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102960:	e9 6c f5 ff ff       	jmp    c0101ed1 <__alltraps>

c0102965 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102965:	55                   	push   %ebp
c0102966:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102968:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c010296e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102971:	29 d0                	sub    %edx,%eax
c0102973:	c1 f8 02             	sar    $0x2,%eax
c0102976:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010297c:	5d                   	pop    %ebp
c010297d:	c3                   	ret    

c010297e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010297e:	55                   	push   %ebp
c010297f:	89 e5                	mov    %esp,%ebp
c0102981:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102984:	8b 45 08             	mov    0x8(%ebp),%eax
c0102987:	89 04 24             	mov    %eax,(%esp)
c010298a:	e8 d6 ff ff ff       	call   c0102965 <page2ppn>
c010298f:	c1 e0 0c             	shl    $0xc,%eax
}
c0102992:	89 ec                	mov    %ebp,%esp
c0102994:	5d                   	pop    %ebp
c0102995:	c3                   	ret    

c0102996 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102996:	55                   	push   %ebp
c0102997:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102999:	8b 45 08             	mov    0x8(%ebp),%eax
c010299c:	8b 00                	mov    (%eax),%eax
}
c010299e:	5d                   	pop    %ebp
c010299f:	c3                   	ret    

c01029a0 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01029a0:	55                   	push   %ebp
c01029a1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01029a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029a9:	89 10                	mov    %edx,(%eax)
}
c01029ab:	90                   	nop
c01029ac:	5d                   	pop    %ebp
c01029ad:	c3                   	ret    

c01029ae <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01029ae:	55                   	push   %ebp
c01029af:	89 e5                	mov    %esp,%ebp
c01029b1:	83 ec 10             	sub    $0x10,%esp
c01029b4:	c7 45 fc 80 be 11 c0 	movl   $0xc011be80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01029bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029be:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01029c1:	89 50 04             	mov    %edx,0x4(%eax)
c01029c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029c7:	8b 50 04             	mov    0x4(%eax),%edx
c01029ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029cd:	89 10                	mov    %edx,(%eax)
}
c01029cf:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c01029d0:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c01029d7:	00 00 00 
}
c01029da:	90                   	nop
c01029db:	89 ec                	mov    %ebp,%esp
c01029dd:	5d                   	pop    %ebp
c01029de:	c3                   	ret    

c01029df <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01029df:	55                   	push   %ebp
c01029e0:	89 e5                	mov    %esp,%ebp
c01029e2:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01029e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01029e9:	75 24                	jne    c0102a0f <default_init_memmap+0x30>
c01029eb:	c7 44 24 0c f0 65 10 	movl   $0xc01065f0,0xc(%esp)
c01029f2:	c0 
c01029f3:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01029fa:	c0 
c01029fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102a02:	00 
c0102a03:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102a0a:	e8 cc e2 ff ff       	call   c0100cdb <__panic>
    struct Page *p = base;
c0102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102a15:	eb 7d                	jmp    c0102a94 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a1a:	83 c0 04             	add    $0x4,%eax
c0102a1d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102a24:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102a2d:	0f a3 10             	bt     %edx,(%eax)
c0102a30:	19 c0                	sbb    %eax,%eax
c0102a32:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102a35:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102a39:	0f 95 c0             	setne  %al
c0102a3c:	0f b6 c0             	movzbl %al,%eax
c0102a3f:	85 c0                	test   %eax,%eax
c0102a41:	75 24                	jne    c0102a67 <default_init_memmap+0x88>
c0102a43:	c7 44 24 0c 21 66 10 	movl   $0xc0106621,0xc(%esp)
c0102a4a:	c0 
c0102a4b:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102a52:	c0 
c0102a53:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102a5a:	00 
c0102a5b:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102a62:	e8 74 e2 ff ff       	call   c0100cdb <__panic>
        p->flags = p->property = 0;
c0102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a74:	8b 50 08             	mov    0x8(%eax),%edx
c0102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a7a:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102a7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102a84:	00 
c0102a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a88:	89 04 24             	mov    %eax,(%esp)
c0102a8b:	e8 10 ff ff ff       	call   c01029a0 <set_page_ref>
    for (; p != base + n; p ++) {
c0102a90:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102a94:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a97:	89 d0                	mov    %edx,%eax
c0102a99:	c1 e0 02             	shl    $0x2,%eax
c0102a9c:	01 d0                	add    %edx,%eax
c0102a9e:	c1 e0 02             	shl    $0x2,%eax
c0102aa1:	89 c2                	mov    %eax,%edx
c0102aa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aa6:	01 d0                	add    %edx,%eax
c0102aa8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102aab:	0f 85 66 ff ff ff    	jne    c0102a17 <default_init_memmap+0x38>
    }
    base->property = n;
c0102ab1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ab7:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0102abd:	83 c0 04             	add    $0x4,%eax
c0102ac0:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102ac7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102aca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102acd:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102ad0:	0f ab 10             	bts    %edx,(%eax)
}
c0102ad3:	90                   	nop
    nr_free += n;
c0102ad4:	8b 15 88 be 11 c0    	mov    0xc011be88,%edx
c0102ada:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102add:	01 d0                	add    %edx,%eax
c0102adf:	a3 88 be 11 c0       	mov    %eax,0xc011be88
    list_add(&free_list, &(base->page_link));
c0102ae4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae7:	83 c0 0c             	add    $0xc,%eax
c0102aea:	c7 45 e4 80 be 11 c0 	movl   $0xc011be80,-0x1c(%ebp)
c0102af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102af7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b00:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b03:	8b 40 04             	mov    0x4(%eax),%eax
c0102b06:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b09:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102b0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102b0f:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102b12:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b15:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b1b:	89 10                	mov    %edx,(%eax)
c0102b1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b20:	8b 10                	mov    (%eax),%edx
c0102b22:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b25:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b2b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b2e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b34:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b37:	89 10                	mov    %edx,(%eax)
}
c0102b39:	90                   	nop
}
c0102b3a:	90                   	nop
}
c0102b3b:	90                   	nop
}
c0102b3c:	90                   	nop
c0102b3d:	89 ec                	mov    %ebp,%esp
c0102b3f:	5d                   	pop    %ebp
c0102b40:	c3                   	ret    

c0102b41 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102b41:	55                   	push   %ebp
c0102b42:	89 e5                	mov    %esp,%ebp
c0102b44:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102b47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102b4b:	75 24                	jne    c0102b71 <default_alloc_pages+0x30>
c0102b4d:	c7 44 24 0c f0 65 10 	movl   $0xc01065f0,0xc(%esp)
c0102b54:	c0 
c0102b55:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102b5c:	c0 
c0102b5d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102b64:	00 
c0102b65:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102b6c:	e8 6a e1 ff ff       	call   c0100cdb <__panic>
    if (n > nr_free) {
c0102b71:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0102b76:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102b79:	76 0a                	jbe    c0102b85 <default_alloc_pages+0x44>
        return NULL;
c0102b7b:	b8 00 00 00 00       	mov    $0x0,%eax
c0102b80:	e9 34 01 00 00       	jmp    c0102cb9 <default_alloc_pages+0x178>
    }
    struct Page *page = NULL;
c0102b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102b8c:	c7 45 f0 80 be 11 c0 	movl   $0xc011be80,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102b93:	eb 1c                	jmp    c0102bb1 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b98:	83 e8 0c             	sub    $0xc,%eax
c0102b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ba1:	8b 40 08             	mov    0x8(%eax),%eax
c0102ba4:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102ba7:	77 08                	ja     c0102bb1 <default_alloc_pages+0x70>
            page = p;
c0102ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102baf:	eb 18                	jmp    c0102bc9 <default_alloc_pages+0x88>
c0102bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0102bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102bba:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0102bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102bc0:	81 7d f0 80 be 11 c0 	cmpl   $0xc011be80,-0x10(%ebp)
c0102bc7:	75 cc                	jne    c0102b95 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0102bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102bcd:	0f 84 e3 00 00 00    	je     c0102cb6 <default_alloc_pages+0x175>
        list_del(&(page->page_link));
c0102bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bd6:	83 c0 0c             	add    $0xc,%eax
c0102bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102bdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102bdf:	8b 40 04             	mov    0x4(%eax),%eax
c0102be2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102be5:	8b 12                	mov    (%edx),%edx
c0102be7:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0102bea:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102bed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102bf0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102bf3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102bf6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102bf9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102bfc:	89 10                	mov    %edx,(%eax)
}
c0102bfe:	90                   	nop
}
c0102bff:	90                   	nop
        if (page->property > n) {
c0102c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c03:	8b 40 08             	mov    0x8(%eax),%eax
c0102c06:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102c09:	0f 83 80 00 00 00    	jae    c0102c8f <default_alloc_pages+0x14e>
            struct Page *p = page + n;
c0102c0f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c12:	89 d0                	mov    %edx,%eax
c0102c14:	c1 e0 02             	shl    $0x2,%eax
c0102c17:	01 d0                	add    %edx,%eax
c0102c19:	c1 e0 02             	shl    $0x2,%eax
c0102c1c:	89 c2                	mov    %eax,%edx
c0102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c21:	01 d0                	add    %edx,%eax
c0102c23:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c29:	8b 40 08             	mov    0x8(%eax),%eax
c0102c2c:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c2f:	89 c2                	mov    %eax,%edx
c0102c31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c34:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
c0102c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c3a:	83 c0 0c             	add    $0xc,%eax
c0102c3d:	c7 45 d4 80 be 11 c0 	movl   $0xc011be80,-0x2c(%ebp)
c0102c44:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102c47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c4a:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102c4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102c50:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102c53:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c56:	8b 40 04             	mov    0x4(%eax),%eax
c0102c59:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102c5c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0102c5f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102c62:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102c65:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0102c68:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c6b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102c6e:	89 10                	mov    %edx,(%eax)
c0102c70:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c73:	8b 10                	mov    (%eax),%edx
c0102c75:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102c78:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102c7b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102c7e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102c81:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102c84:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102c87:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102c8a:	89 10                	mov    %edx,(%eax)
}
c0102c8c:	90                   	nop
}
c0102c8d:	90                   	nop
}
c0102c8e:	90                   	nop
    }
        nr_free -= n;
c0102c8f:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0102c94:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c97:	a3 88 be 11 c0       	mov    %eax,0xc011be88
        ClearPageProperty(page);
c0102c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c9f:	83 c0 04             	add    $0x4,%eax
c0102ca2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102ca9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cac:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102caf:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102cb2:	0f b3 10             	btr    %edx,(%eax)
}
c0102cb5:	90                   	nop
    }
    return page;
c0102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102cb9:	89 ec                	mov    %ebp,%esp
c0102cbb:	5d                   	pop    %ebp
c0102cbc:	c3                   	ret    

c0102cbd <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102cbd:	55                   	push   %ebp
c0102cbe:	89 e5                	mov    %esp,%ebp
c0102cc0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102cc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102cca:	75 24                	jne    c0102cf0 <default_free_pages+0x33>
c0102ccc:	c7 44 24 0c f0 65 10 	movl   $0xc01065f0,0xc(%esp)
c0102cd3:	c0 
c0102cd4:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102cdb:	c0 
c0102cdc:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0102ce3:	00 
c0102ce4:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102ceb:	e8 eb df ff ff       	call   c0100cdb <__panic>
    struct Page *p = base;
c0102cf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102cf6:	e9 9d 00 00 00       	jmp    c0102d98 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cfe:	83 c0 04             	add    $0x4,%eax
c0102d01:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102d08:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102d11:	0f a3 10             	bt     %edx,(%eax)
c0102d14:	19 c0                	sbb    %eax,%eax
c0102d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102d19:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d1d:	0f 95 c0             	setne  %al
c0102d20:	0f b6 c0             	movzbl %al,%eax
c0102d23:	85 c0                	test   %eax,%eax
c0102d25:	75 2c                	jne    c0102d53 <default_free_pages+0x96>
c0102d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d2a:	83 c0 04             	add    $0x4,%eax
c0102d2d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102d34:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d37:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102d3a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102d3d:	0f a3 10             	bt     %edx,(%eax)
c0102d40:	19 c0                	sbb    %eax,%eax
c0102d42:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102d45:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102d49:	0f 95 c0             	setne  %al
c0102d4c:	0f b6 c0             	movzbl %al,%eax
c0102d4f:	85 c0                	test   %eax,%eax
c0102d51:	74 24                	je     c0102d77 <default_free_pages+0xba>
c0102d53:	c7 44 24 0c 34 66 10 	movl   $0xc0106634,0xc(%esp)
c0102d5a:	c0 
c0102d5b:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102d62:	c0 
c0102d63:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
c0102d6a:	00 
c0102d6b:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102d72:	e8 64 df ff ff       	call   c0100cdb <__panic>
        p->flags = 0;
c0102d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d7a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102d81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102d88:	00 
c0102d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d8c:	89 04 24             	mov    %eax,(%esp)
c0102d8f:	e8 0c fc ff ff       	call   c01029a0 <set_page_ref>
    for (; p != base + n; p ++) {
c0102d94:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102d98:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d9b:	89 d0                	mov    %edx,%eax
c0102d9d:	c1 e0 02             	shl    $0x2,%eax
c0102da0:	01 d0                	add    %edx,%eax
c0102da2:	c1 e0 02             	shl    $0x2,%eax
c0102da5:	89 c2                	mov    %eax,%edx
c0102da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102daa:	01 d0                	add    %edx,%eax
c0102dac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102daf:	0f 85 46 ff ff ff    	jne    c0102cfb <default_free_pages+0x3e>
    }
    base->property = n;
c0102db5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102db8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102dbb:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dc1:	83 c0 04             	add    $0x4,%eax
c0102dc4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102dcb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dce:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102dd1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102dd4:	0f ab 10             	bts    %edx,(%eax)
}
c0102dd7:	90                   	nop
c0102dd8:	c7 45 d4 80 be 11 c0 	movl   $0xc011be80,-0x2c(%ebp)
    return listelm->next;
c0102ddf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102de2:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102de5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102de8:	e9 0e 01 00 00       	jmp    c0102efb <default_free_pages+0x23e>
        p = le2page(le, page_link);
c0102ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102df0:	83 e8 0c             	sub    $0xc,%eax
c0102df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102df9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102dfc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102dff:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102e05:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e08:	8b 50 08             	mov    0x8(%eax),%edx
c0102e0b:	89 d0                	mov    %edx,%eax
c0102e0d:	c1 e0 02             	shl    $0x2,%eax
c0102e10:	01 d0                	add    %edx,%eax
c0102e12:	c1 e0 02             	shl    $0x2,%eax
c0102e15:	89 c2                	mov    %eax,%edx
c0102e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e1a:	01 d0                	add    %edx,%eax
c0102e1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102e1f:	75 5d                	jne    c0102e7e <default_free_pages+0x1c1>
            base->property += p->property;
c0102e21:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e24:	8b 50 08             	mov    0x8(%eax),%edx
c0102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e2a:	8b 40 08             	mov    0x8(%eax),%eax
c0102e2d:	01 c2                	add    %eax,%edx
c0102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e32:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e38:	83 c0 04             	add    $0x4,%eax
c0102e3b:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102e42:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e45:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102e48:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102e4b:	0f b3 10             	btr    %edx,(%eax)
}
c0102e4e:	90                   	nop
            list_del(&(p->page_link));
c0102e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e52:	83 c0 0c             	add    $0xc,%eax
c0102e55:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102e58:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102e5b:	8b 40 04             	mov    0x4(%eax),%eax
c0102e5e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102e61:	8b 12                	mov    (%edx),%edx
c0102e63:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102e66:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0102e69:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102e6c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102e6f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102e72:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102e75:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102e78:	89 10                	mov    %edx,(%eax)
}
c0102e7a:	90                   	nop
}
c0102e7b:	90                   	nop
c0102e7c:	eb 7d                	jmp    c0102efb <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
c0102e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e81:	8b 50 08             	mov    0x8(%eax),%edx
c0102e84:	89 d0                	mov    %edx,%eax
c0102e86:	c1 e0 02             	shl    $0x2,%eax
c0102e89:	01 d0                	add    %edx,%eax
c0102e8b:	c1 e0 02             	shl    $0x2,%eax
c0102e8e:	89 c2                	mov    %eax,%edx
c0102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e93:	01 d0                	add    %edx,%eax
c0102e95:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102e98:	75 61                	jne    c0102efb <default_free_pages+0x23e>
            p->property += base->property;
c0102e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e9d:	8b 50 08             	mov    0x8(%eax),%edx
c0102ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ea3:	8b 40 08             	mov    0x8(%eax),%eax
c0102ea6:	01 c2                	add    %eax,%edx
c0102ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eab:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102eae:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eb1:	83 c0 04             	add    $0x4,%eax
c0102eb4:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0102ebb:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ebe:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ec1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102ec4:	0f b3 10             	btr    %edx,(%eax)
}
c0102ec7:	90                   	nop
            base = p;
c0102ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ecb:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ed1:	83 c0 0c             	add    $0xc,%eax
c0102ed4:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102ed7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102eda:	8b 40 04             	mov    0x4(%eax),%eax
c0102edd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102ee0:	8b 12                	mov    (%edx),%edx
c0102ee2:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0102ee5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0102ee8:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102eeb:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102eee:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ef1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102ef4:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102ef7:	89 10                	mov    %edx,(%eax)
}
c0102ef9:	90                   	nop
}
c0102efa:	90                   	nop
    while (le != &free_list) {
c0102efb:	81 7d f0 80 be 11 c0 	cmpl   $0xc011be80,-0x10(%ebp)
c0102f02:	0f 85 e5 fe ff ff    	jne    c0102ded <default_free_pages+0x130>
        }
    }
    nr_free += n;
c0102f08:	8b 15 88 be 11 c0    	mov    0xc011be88,%edx
c0102f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102f11:	01 d0                	add    %edx,%eax
c0102f13:	a3 88 be 11 c0       	mov    %eax,0xc011be88
    list_add(&free_list, &(base->page_link));
c0102f18:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f1b:	83 c0 0c             	add    $0xc,%eax
c0102f1e:	c7 45 9c 80 be 11 c0 	movl   $0xc011be80,-0x64(%ebp)
c0102f25:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102f28:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f2b:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102f2e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f31:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102f34:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102f37:	8b 40 04             	mov    0x4(%eax),%eax
c0102f3a:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102f3d:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102f40:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102f43:	89 55 88             	mov    %edx,-0x78(%ebp)
c0102f46:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0102f49:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102f4c:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102f4f:	89 10                	mov    %edx,(%eax)
c0102f51:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102f54:	8b 10                	mov    (%eax),%edx
c0102f56:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102f59:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102f5c:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f5f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102f62:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102f65:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f68:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102f6b:	89 10                	mov    %edx,(%eax)
}
c0102f6d:	90                   	nop
}
c0102f6e:	90                   	nop
}
c0102f6f:	90                   	nop
}
c0102f70:	90                   	nop
c0102f71:	89 ec                	mov    %ebp,%esp
c0102f73:	5d                   	pop    %ebp
c0102f74:	c3                   	ret    

c0102f75 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102f75:	55                   	push   %ebp
c0102f76:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102f78:	a1 88 be 11 c0       	mov    0xc011be88,%eax
}
c0102f7d:	5d                   	pop    %ebp
c0102f7e:	c3                   	ret    

c0102f7f <basic_check>:

static void
basic_check(void) {
c0102f7f:	55                   	push   %ebp
c0102f80:	89 e5                	mov    %esp,%ebp
c0102f82:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f95:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f9f:	e8 df 0e 00 00       	call   c0103e83 <alloc_pages>
c0102fa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102fa7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102fab:	75 24                	jne    c0102fd1 <basic_check+0x52>
c0102fad:	c7 44 24 0c 59 66 10 	movl   $0xc0106659,0xc(%esp)
c0102fb4:	c0 
c0102fb5:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102fbc:	c0 
c0102fbd:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0102fc4:	00 
c0102fc5:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0102fcc:	e8 0a dd ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102fd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102fd8:	e8 a6 0e 00 00       	call   c0103e83 <alloc_pages>
c0102fdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102fe0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102fe4:	75 24                	jne    c010300a <basic_check+0x8b>
c0102fe6:	c7 44 24 0c 75 66 10 	movl   $0xc0106675,0xc(%esp)
c0102fed:	c0 
c0102fee:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0102ff5:	c0 
c0102ff6:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0102ffd:	00 
c0102ffe:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103005:	e8 d1 dc ff ff       	call   c0100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
c010300a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103011:	e8 6d 0e 00 00       	call   c0103e83 <alloc_pages>
c0103016:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103019:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010301d:	75 24                	jne    c0103043 <basic_check+0xc4>
c010301f:	c7 44 24 0c 91 66 10 	movl   $0xc0106691,0xc(%esp)
c0103026:	c0 
c0103027:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010302e:	c0 
c010302f:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103036:	00 
c0103037:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010303e:	e8 98 dc ff ff       	call   c0100cdb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103043:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103046:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103049:	74 10                	je     c010305b <basic_check+0xdc>
c010304b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010304e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103051:	74 08                	je     c010305b <basic_check+0xdc>
c0103053:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103056:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103059:	75 24                	jne    c010307f <basic_check+0x100>
c010305b:	c7 44 24 0c b0 66 10 	movl   $0xc01066b0,0xc(%esp)
c0103062:	c0 
c0103063:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010306a:	c0 
c010306b:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c0103072:	00 
c0103073:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010307a:	e8 5c dc ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010307f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103082:	89 04 24             	mov    %eax,(%esp)
c0103085:	e8 0c f9 ff ff       	call   c0102996 <page_ref>
c010308a:	85 c0                	test   %eax,%eax
c010308c:	75 1e                	jne    c01030ac <basic_check+0x12d>
c010308e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103091:	89 04 24             	mov    %eax,(%esp)
c0103094:	e8 fd f8 ff ff       	call   c0102996 <page_ref>
c0103099:	85 c0                	test   %eax,%eax
c010309b:	75 0f                	jne    c01030ac <basic_check+0x12d>
c010309d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030a0:	89 04 24             	mov    %eax,(%esp)
c01030a3:	e8 ee f8 ff ff       	call   c0102996 <page_ref>
c01030a8:	85 c0                	test   %eax,%eax
c01030aa:	74 24                	je     c01030d0 <basic_check+0x151>
c01030ac:	c7 44 24 0c d4 66 10 	movl   $0xc01066d4,0xc(%esp)
c01030b3:	c0 
c01030b4:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01030bb:	c0 
c01030bc:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c01030c3:	00 
c01030c4:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01030cb:	e8 0b dc ff ff       	call   c0100cdb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01030d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030d3:	89 04 24             	mov    %eax,(%esp)
c01030d6:	e8 a3 f8 ff ff       	call   c010297e <page2pa>
c01030db:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c01030e1:	c1 e2 0c             	shl    $0xc,%edx
c01030e4:	39 d0                	cmp    %edx,%eax
c01030e6:	72 24                	jb     c010310c <basic_check+0x18d>
c01030e8:	c7 44 24 0c 10 67 10 	movl   $0xc0106710,0xc(%esp)
c01030ef:	c0 
c01030f0:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01030f7:	c0 
c01030f8:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01030ff:	00 
c0103100:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103107:	e8 cf db ff ff       	call   c0100cdb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010310c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010310f:	89 04 24             	mov    %eax,(%esp)
c0103112:	e8 67 f8 ff ff       	call   c010297e <page2pa>
c0103117:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c010311d:	c1 e2 0c             	shl    $0xc,%edx
c0103120:	39 d0                	cmp    %edx,%eax
c0103122:	72 24                	jb     c0103148 <basic_check+0x1c9>
c0103124:	c7 44 24 0c 2d 67 10 	movl   $0xc010672d,0xc(%esp)
c010312b:	c0 
c010312c:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103133:	c0 
c0103134:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c010313b:	00 
c010313c:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103143:	e8 93 db ff ff       	call   c0100cdb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103148:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010314b:	89 04 24             	mov    %eax,(%esp)
c010314e:	e8 2b f8 ff ff       	call   c010297e <page2pa>
c0103153:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c0103159:	c1 e2 0c             	shl    $0xc,%edx
c010315c:	39 d0                	cmp    %edx,%eax
c010315e:	72 24                	jb     c0103184 <basic_check+0x205>
c0103160:	c7 44 24 0c 4a 67 10 	movl   $0xc010674a,0xc(%esp)
c0103167:	c0 
c0103168:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010316f:	c0 
c0103170:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103177:	00 
c0103178:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010317f:	e8 57 db ff ff       	call   c0100cdb <__panic>

    list_entry_t free_list_store = free_list;
c0103184:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103189:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c010318f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103192:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103195:	c7 45 dc 80 be 11 c0 	movl   $0xc011be80,-0x24(%ebp)
    elm->prev = elm->next = elm;
c010319c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010319f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031a2:	89 50 04             	mov    %edx,0x4(%eax)
c01031a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01031a8:	8b 50 04             	mov    0x4(%eax),%edx
c01031ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01031ae:	89 10                	mov    %edx,(%eax)
}
c01031b0:	90                   	nop
c01031b1:	c7 45 e0 80 be 11 c0 	movl   $0xc011be80,-0x20(%ebp)
    return list->next == list;
c01031b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01031bb:	8b 40 04             	mov    0x4(%eax),%eax
c01031be:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01031c1:	0f 94 c0             	sete   %al
c01031c4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01031c7:	85 c0                	test   %eax,%eax
c01031c9:	75 24                	jne    c01031ef <basic_check+0x270>
c01031cb:	c7 44 24 0c 67 67 10 	movl   $0xc0106767,0xc(%esp)
c01031d2:	c0 
c01031d3:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01031da:	c0 
c01031db:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01031e2:	00 
c01031e3:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01031ea:	e8 ec da ff ff       	call   c0100cdb <__panic>

    unsigned int nr_free_store = nr_free;
c01031ef:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c01031f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01031f7:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c01031fe:	00 00 00 

    assert(alloc_page() == NULL);
c0103201:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103208:	e8 76 0c 00 00       	call   c0103e83 <alloc_pages>
c010320d:	85 c0                	test   %eax,%eax
c010320f:	74 24                	je     c0103235 <basic_check+0x2b6>
c0103211:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c0103218:	c0 
c0103219:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103220:	c0 
c0103221:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103228:	00 
c0103229:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103230:	e8 a6 da ff ff       	call   c0100cdb <__panic>

    free_page(p0);
c0103235:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010323c:	00 
c010323d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103240:	89 04 24             	mov    %eax,(%esp)
c0103243:	e8 75 0c 00 00       	call   c0103ebd <free_pages>
    free_page(p1);
c0103248:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010324f:	00 
c0103250:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103253:	89 04 24             	mov    %eax,(%esp)
c0103256:	e8 62 0c 00 00       	call   c0103ebd <free_pages>
    free_page(p2);
c010325b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103262:	00 
c0103263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103266:	89 04 24             	mov    %eax,(%esp)
c0103269:	e8 4f 0c 00 00       	call   c0103ebd <free_pages>
    assert(nr_free == 3);
c010326e:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0103273:	83 f8 03             	cmp    $0x3,%eax
c0103276:	74 24                	je     c010329c <basic_check+0x31d>
c0103278:	c7 44 24 0c 93 67 10 	movl   $0xc0106793,0xc(%esp)
c010327f:	c0 
c0103280:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103287:	c0 
c0103288:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010328f:	00 
c0103290:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103297:	e8 3f da ff ff       	call   c0100cdb <__panic>

    assert((p0 = alloc_page()) != NULL);
c010329c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032a3:	e8 db 0b 00 00       	call   c0103e83 <alloc_pages>
c01032a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01032ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01032af:	75 24                	jne    c01032d5 <basic_check+0x356>
c01032b1:	c7 44 24 0c 59 66 10 	movl   $0xc0106659,0xc(%esp)
c01032b8:	c0 
c01032b9:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01032c0:	c0 
c01032c1:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01032c8:	00 
c01032c9:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01032d0:	e8 06 da ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
c01032d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032dc:	e8 a2 0b 00 00       	call   c0103e83 <alloc_pages>
c01032e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01032e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01032e8:	75 24                	jne    c010330e <basic_check+0x38f>
c01032ea:	c7 44 24 0c 75 66 10 	movl   $0xc0106675,0xc(%esp)
c01032f1:	c0 
c01032f2:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01032f9:	c0 
c01032fa:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103301:	00 
c0103302:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103309:	e8 cd d9 ff ff       	call   c0100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
c010330e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103315:	e8 69 0b 00 00       	call   c0103e83 <alloc_pages>
c010331a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010331d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103321:	75 24                	jne    c0103347 <basic_check+0x3c8>
c0103323:	c7 44 24 0c 91 66 10 	movl   $0xc0106691,0xc(%esp)
c010332a:	c0 
c010332b:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103332:	c0 
c0103333:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010333a:	00 
c010333b:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103342:	e8 94 d9 ff ff       	call   c0100cdb <__panic>

    assert(alloc_page() == NULL);
c0103347:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010334e:	e8 30 0b 00 00       	call   c0103e83 <alloc_pages>
c0103353:	85 c0                	test   %eax,%eax
c0103355:	74 24                	je     c010337b <basic_check+0x3fc>
c0103357:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c010335e:	c0 
c010335f:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103366:	c0 
c0103367:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010336e:	00 
c010336f:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103376:	e8 60 d9 ff ff       	call   c0100cdb <__panic>

    free_page(p0);
c010337b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103382:	00 
c0103383:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103386:	89 04 24             	mov    %eax,(%esp)
c0103389:	e8 2f 0b 00 00       	call   c0103ebd <free_pages>
c010338e:	c7 45 d8 80 be 11 c0 	movl   $0xc011be80,-0x28(%ebp)
c0103395:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103398:	8b 40 04             	mov    0x4(%eax),%eax
c010339b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010339e:	0f 94 c0             	sete   %al
c01033a1:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01033a4:	85 c0                	test   %eax,%eax
c01033a6:	74 24                	je     c01033cc <basic_check+0x44d>
c01033a8:	c7 44 24 0c a0 67 10 	movl   $0xc01067a0,0xc(%esp)
c01033af:	c0 
c01033b0:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01033b7:	c0 
c01033b8:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01033bf:	00 
c01033c0:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01033c7:	e8 0f d9 ff ff       	call   c0100cdb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01033cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033d3:	e8 ab 0a 00 00       	call   c0103e83 <alloc_pages>
c01033d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01033db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01033de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033e1:	74 24                	je     c0103407 <basic_check+0x488>
c01033e3:	c7 44 24 0c b8 67 10 	movl   $0xc01067b8,0xc(%esp)
c01033ea:	c0 
c01033eb:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01033f2:	c0 
c01033f3:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01033fa:	00 
c01033fb:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103402:	e8 d4 d8 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c0103407:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010340e:	e8 70 0a 00 00       	call   c0103e83 <alloc_pages>
c0103413:	85 c0                	test   %eax,%eax
c0103415:	74 24                	je     c010343b <basic_check+0x4bc>
c0103417:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c010341e:	c0 
c010341f:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103426:	c0 
c0103427:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c010342e:	00 
c010342f:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103436:	e8 a0 d8 ff ff       	call   c0100cdb <__panic>

    assert(nr_free == 0);
c010343b:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0103440:	85 c0                	test   %eax,%eax
c0103442:	74 24                	je     c0103468 <basic_check+0x4e9>
c0103444:	c7 44 24 0c d1 67 10 	movl   $0xc01067d1,0xc(%esp)
c010344b:	c0 
c010344c:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103453:	c0 
c0103454:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010345b:	00 
c010345c:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103463:	e8 73 d8 ff ff       	call   c0100cdb <__panic>
    free_list = free_list_store;
c0103468:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010346b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010346e:	a3 80 be 11 c0       	mov    %eax,0xc011be80
c0103473:	89 15 84 be 11 c0    	mov    %edx,0xc011be84
    nr_free = nr_free_store;
c0103479:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010347c:	a3 88 be 11 c0       	mov    %eax,0xc011be88

    free_page(p);
c0103481:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103488:	00 
c0103489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010348c:	89 04 24             	mov    %eax,(%esp)
c010348f:	e8 29 0a 00 00       	call   c0103ebd <free_pages>
    free_page(p1);
c0103494:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010349b:	00 
c010349c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010349f:	89 04 24             	mov    %eax,(%esp)
c01034a2:	e8 16 0a 00 00       	call   c0103ebd <free_pages>
    free_page(p2);
c01034a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01034ae:	00 
c01034af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b2:	89 04 24             	mov    %eax,(%esp)
c01034b5:	e8 03 0a 00 00       	call   c0103ebd <free_pages>
}
c01034ba:	90                   	nop
c01034bb:	89 ec                	mov    %ebp,%esp
c01034bd:	5d                   	pop    %ebp
c01034be:	c3                   	ret    

c01034bf <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01034bf:	55                   	push   %ebp
c01034c0:	89 e5                	mov    %esp,%ebp
c01034c2:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01034c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01034cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01034d6:	c7 45 ec 80 be 11 c0 	movl   $0xc011be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01034dd:	eb 6a                	jmp    c0103549 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c01034df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034e2:	83 e8 0c             	sub    $0xc,%eax
c01034e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01034e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034eb:	83 c0 04             	add    $0x4,%eax
c01034ee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01034f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034fe:	0f a3 10             	bt     %edx,(%eax)
c0103501:	19 c0                	sbb    %eax,%eax
c0103503:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103506:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010350a:	0f 95 c0             	setne  %al
c010350d:	0f b6 c0             	movzbl %al,%eax
c0103510:	85 c0                	test   %eax,%eax
c0103512:	75 24                	jne    c0103538 <default_check+0x79>
c0103514:	c7 44 24 0c de 67 10 	movl   $0xc01067de,0xc(%esp)
c010351b:	c0 
c010351c:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103523:	c0 
c0103524:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c010352b:	00 
c010352c:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103533:	e8 a3 d7 ff ff       	call   c0100cdb <__panic>
        count ++, total += p->property;
c0103538:	ff 45 f4             	incl   -0xc(%ebp)
c010353b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010353e:	8b 50 08             	mov    0x8(%eax),%edx
c0103541:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103544:	01 d0                	add    %edx,%eax
c0103546:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103549:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010354c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c010354f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103552:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103555:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103558:	81 7d ec 80 be 11 c0 	cmpl   $0xc011be80,-0x14(%ebp)
c010355f:	0f 85 7a ff ff ff    	jne    c01034df <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103565:	e8 88 09 00 00       	call   c0103ef2 <nr_free_pages>
c010356a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010356d:	39 d0                	cmp    %edx,%eax
c010356f:	74 24                	je     c0103595 <default_check+0xd6>
c0103571:	c7 44 24 0c ee 67 10 	movl   $0xc01067ee,0xc(%esp)
c0103578:	c0 
c0103579:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103580:	c0 
c0103581:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103588:	00 
c0103589:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103590:	e8 46 d7 ff ff       	call   c0100cdb <__panic>

    basic_check();
c0103595:	e8 e5 f9 ff ff       	call   c0102f7f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010359a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01035a1:	e8 dd 08 00 00       	call   c0103e83 <alloc_pages>
c01035a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c01035a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01035ad:	75 24                	jne    c01035d3 <default_check+0x114>
c01035af:	c7 44 24 0c 07 68 10 	movl   $0xc0106807,0xc(%esp)
c01035b6:	c0 
c01035b7:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01035be:	c0 
c01035bf:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01035c6:	00 
c01035c7:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01035ce:	e8 08 d7 ff ff       	call   c0100cdb <__panic>
    assert(!PageProperty(p0));
c01035d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035d6:	83 c0 04             	add    $0x4,%eax
c01035d9:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01035e0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035e3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01035e6:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01035e9:	0f a3 10             	bt     %edx,(%eax)
c01035ec:	19 c0                	sbb    %eax,%eax
c01035ee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01035f1:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01035f5:	0f 95 c0             	setne  %al
c01035f8:	0f b6 c0             	movzbl %al,%eax
c01035fb:	85 c0                	test   %eax,%eax
c01035fd:	74 24                	je     c0103623 <default_check+0x164>
c01035ff:	c7 44 24 0c 12 68 10 	movl   $0xc0106812,0xc(%esp)
c0103606:	c0 
c0103607:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010360e:	c0 
c010360f:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0103616:	00 
c0103617:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010361e:	e8 b8 d6 ff ff       	call   c0100cdb <__panic>

    list_entry_t free_list_store = free_list;
c0103623:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103628:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c010362e:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103631:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103634:	c7 45 b0 80 be 11 c0 	movl   $0xc011be80,-0x50(%ebp)
    elm->prev = elm->next = elm;
c010363b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010363e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103641:	89 50 04             	mov    %edx,0x4(%eax)
c0103644:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103647:	8b 50 04             	mov    0x4(%eax),%edx
c010364a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010364d:	89 10                	mov    %edx,(%eax)
}
c010364f:	90                   	nop
c0103650:	c7 45 b4 80 be 11 c0 	movl   $0xc011be80,-0x4c(%ebp)
    return list->next == list;
c0103657:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010365a:	8b 40 04             	mov    0x4(%eax),%eax
c010365d:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0103660:	0f 94 c0             	sete   %al
c0103663:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103666:	85 c0                	test   %eax,%eax
c0103668:	75 24                	jne    c010368e <default_check+0x1cf>
c010366a:	c7 44 24 0c 67 67 10 	movl   $0xc0106767,0xc(%esp)
c0103671:	c0 
c0103672:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103679:	c0 
c010367a:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0103681:	00 
c0103682:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103689:	e8 4d d6 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c010368e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103695:	e8 e9 07 00 00       	call   c0103e83 <alloc_pages>
c010369a:	85 c0                	test   %eax,%eax
c010369c:	74 24                	je     c01036c2 <default_check+0x203>
c010369e:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c01036a5:	c0 
c01036a6:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01036ad:	c0 
c01036ae:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c01036b5:	00 
c01036b6:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01036bd:	e8 19 d6 ff ff       	call   c0100cdb <__panic>

    unsigned int nr_free_store = nr_free;
c01036c2:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c01036c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c01036ca:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c01036d1:	00 00 00 

    free_pages(p0 + 2, 3);
c01036d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036d7:	83 c0 28             	add    $0x28,%eax
c01036da:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01036e1:	00 
c01036e2:	89 04 24             	mov    %eax,(%esp)
c01036e5:	e8 d3 07 00 00       	call   c0103ebd <free_pages>
    assert(alloc_pages(4) == NULL);
c01036ea:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01036f1:	e8 8d 07 00 00       	call   c0103e83 <alloc_pages>
c01036f6:	85 c0                	test   %eax,%eax
c01036f8:	74 24                	je     c010371e <default_check+0x25f>
c01036fa:	c7 44 24 0c 24 68 10 	movl   $0xc0106824,0xc(%esp)
c0103701:	c0 
c0103702:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103709:	c0 
c010370a:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103711:	00 
c0103712:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103719:	e8 bd d5 ff ff       	call   c0100cdb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010371e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103721:	83 c0 28             	add    $0x28,%eax
c0103724:	83 c0 04             	add    $0x4,%eax
c0103727:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010372e:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103731:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103734:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103737:	0f a3 10             	bt     %edx,(%eax)
c010373a:	19 c0                	sbb    %eax,%eax
c010373c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010373f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103743:	0f 95 c0             	setne  %al
c0103746:	0f b6 c0             	movzbl %al,%eax
c0103749:	85 c0                	test   %eax,%eax
c010374b:	74 0e                	je     c010375b <default_check+0x29c>
c010374d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103750:	83 c0 28             	add    $0x28,%eax
c0103753:	8b 40 08             	mov    0x8(%eax),%eax
c0103756:	83 f8 03             	cmp    $0x3,%eax
c0103759:	74 24                	je     c010377f <default_check+0x2c0>
c010375b:	c7 44 24 0c 3c 68 10 	movl   $0xc010683c,0xc(%esp)
c0103762:	c0 
c0103763:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010376a:	c0 
c010376b:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103772:	00 
c0103773:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010377a:	e8 5c d5 ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010377f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103786:	e8 f8 06 00 00       	call   c0103e83 <alloc_pages>
c010378b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010378e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103792:	75 24                	jne    c01037b8 <default_check+0x2f9>
c0103794:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c010379b:	c0 
c010379c:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01037a3:	c0 
c01037a4:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01037ab:	00 
c01037ac:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01037b3:	e8 23 d5 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c01037b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037bf:	e8 bf 06 00 00       	call   c0103e83 <alloc_pages>
c01037c4:	85 c0                	test   %eax,%eax
c01037c6:	74 24                	je     c01037ec <default_check+0x32d>
c01037c8:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c01037cf:	c0 
c01037d0:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01037d7:	c0 
c01037d8:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01037df:	00 
c01037e0:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01037e7:	e8 ef d4 ff ff       	call   c0100cdb <__panic>
    assert(p0 + 2 == p1);
c01037ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037ef:	83 c0 28             	add    $0x28,%eax
c01037f2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01037f5:	74 24                	je     c010381b <default_check+0x35c>
c01037f7:	c7 44 24 0c 86 68 10 	movl   $0xc0106886,0xc(%esp)
c01037fe:	c0 
c01037ff:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103806:	c0 
c0103807:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c010380e:	00 
c010380f:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103816:	e8 c0 d4 ff ff       	call   c0100cdb <__panic>

    p2 = p0 + 1;
c010381b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010381e:	83 c0 14             	add    $0x14,%eax
c0103821:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0103824:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010382b:	00 
c010382c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010382f:	89 04 24             	mov    %eax,(%esp)
c0103832:	e8 86 06 00 00       	call   c0103ebd <free_pages>
    free_pages(p1, 3);
c0103837:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010383e:	00 
c010383f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103842:	89 04 24             	mov    %eax,(%esp)
c0103845:	e8 73 06 00 00       	call   c0103ebd <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010384a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010384d:	83 c0 04             	add    $0x4,%eax
c0103850:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103857:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010385a:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010385d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103860:	0f a3 10             	bt     %edx,(%eax)
c0103863:	19 c0                	sbb    %eax,%eax
c0103865:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103868:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010386c:	0f 95 c0             	setne  %al
c010386f:	0f b6 c0             	movzbl %al,%eax
c0103872:	85 c0                	test   %eax,%eax
c0103874:	74 0b                	je     c0103881 <default_check+0x3c2>
c0103876:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103879:	8b 40 08             	mov    0x8(%eax),%eax
c010387c:	83 f8 01             	cmp    $0x1,%eax
c010387f:	74 24                	je     c01038a5 <default_check+0x3e6>
c0103881:	c7 44 24 0c 94 68 10 	movl   $0xc0106894,0xc(%esp)
c0103888:	c0 
c0103889:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103890:	c0 
c0103891:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0103898:	00 
c0103899:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01038a0:	e8 36 d4 ff ff       	call   c0100cdb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01038a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038a8:	83 c0 04             	add    $0x4,%eax
c01038ab:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01038b2:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038b5:	8b 45 90             	mov    -0x70(%ebp),%eax
c01038b8:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01038bb:	0f a3 10             	bt     %edx,(%eax)
c01038be:	19 c0                	sbb    %eax,%eax
c01038c0:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01038c3:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01038c7:	0f 95 c0             	setne  %al
c01038ca:	0f b6 c0             	movzbl %al,%eax
c01038cd:	85 c0                	test   %eax,%eax
c01038cf:	74 0b                	je     c01038dc <default_check+0x41d>
c01038d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038d4:	8b 40 08             	mov    0x8(%eax),%eax
c01038d7:	83 f8 03             	cmp    $0x3,%eax
c01038da:	74 24                	je     c0103900 <default_check+0x441>
c01038dc:	c7 44 24 0c bc 68 10 	movl   $0xc01068bc,0xc(%esp)
c01038e3:	c0 
c01038e4:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01038eb:	c0 
c01038ec:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01038f3:	00 
c01038f4:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01038fb:	e8 db d3 ff ff       	call   c0100cdb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103900:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103907:	e8 77 05 00 00       	call   c0103e83 <alloc_pages>
c010390c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010390f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103912:	83 e8 14             	sub    $0x14,%eax
c0103915:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103918:	74 24                	je     c010393e <default_check+0x47f>
c010391a:	c7 44 24 0c e2 68 10 	movl   $0xc01068e2,0xc(%esp)
c0103921:	c0 
c0103922:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103929:	c0 
c010392a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0103931:	00 
c0103932:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103939:	e8 9d d3 ff ff       	call   c0100cdb <__panic>
    free_page(p0);
c010393e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103945:	00 
c0103946:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103949:	89 04 24             	mov    %eax,(%esp)
c010394c:	e8 6c 05 00 00       	call   c0103ebd <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103951:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103958:	e8 26 05 00 00       	call   c0103e83 <alloc_pages>
c010395d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103960:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103963:	83 c0 14             	add    $0x14,%eax
c0103966:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103969:	74 24                	je     c010398f <default_check+0x4d0>
c010396b:	c7 44 24 0c 00 69 10 	movl   $0xc0106900,0xc(%esp)
c0103972:	c0 
c0103973:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c010397a:	c0 
c010397b:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0103982:	00 
c0103983:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c010398a:	e8 4c d3 ff ff       	call   c0100cdb <__panic>

    free_pages(p0, 2);
c010398f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103996:	00 
c0103997:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010399a:	89 04 24             	mov    %eax,(%esp)
c010399d:	e8 1b 05 00 00       	call   c0103ebd <free_pages>
    free_page(p2);
c01039a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01039a9:	00 
c01039aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039ad:	89 04 24             	mov    %eax,(%esp)
c01039b0:	e8 08 05 00 00       	call   c0103ebd <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01039b5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01039bc:	e8 c2 04 00 00       	call   c0103e83 <alloc_pages>
c01039c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01039c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01039c8:	75 24                	jne    c01039ee <default_check+0x52f>
c01039ca:	c7 44 24 0c 20 69 10 	movl   $0xc0106920,0xc(%esp)
c01039d1:	c0 
c01039d2:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c01039d9:	c0 
c01039da:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01039e1:	00 
c01039e2:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c01039e9:	e8 ed d2 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c01039ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039f5:	e8 89 04 00 00       	call   c0103e83 <alloc_pages>
c01039fa:	85 c0                	test   %eax,%eax
c01039fc:	74 24                	je     c0103a22 <default_check+0x563>
c01039fe:	c7 44 24 0c 7e 67 10 	movl   $0xc010677e,0xc(%esp)
c0103a05:	c0 
c0103a06:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103a0d:	c0 
c0103a0e:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0103a15:	00 
c0103a16:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103a1d:	e8 b9 d2 ff ff       	call   c0100cdb <__panic>

    assert(nr_free == 0);
c0103a22:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0103a27:	85 c0                	test   %eax,%eax
c0103a29:	74 24                	je     c0103a4f <default_check+0x590>
c0103a2b:	c7 44 24 0c d1 67 10 	movl   $0xc01067d1,0xc(%esp)
c0103a32:	c0 
c0103a33:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103a3a:	c0 
c0103a3b:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0103a42:	00 
c0103a43:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103a4a:	e8 8c d2 ff ff       	call   c0100cdb <__panic>
    nr_free = nr_free_store;
c0103a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a52:	a3 88 be 11 c0       	mov    %eax,0xc011be88

    free_list = free_list_store;
c0103a57:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103a5a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103a5d:	a3 80 be 11 c0       	mov    %eax,0xc011be80
c0103a62:	89 15 84 be 11 c0    	mov    %edx,0xc011be84
    free_pages(p0, 5);
c0103a68:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103a6f:	00 
c0103a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a73:	89 04 24             	mov    %eax,(%esp)
c0103a76:	e8 42 04 00 00       	call   c0103ebd <free_pages>

    le = &free_list;
c0103a7b:	c7 45 ec 80 be 11 c0 	movl   $0xc011be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103a82:	eb 5a                	jmp    c0103ade <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0103a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a87:	8b 40 04             	mov    0x4(%eax),%eax
c0103a8a:	8b 00                	mov    (%eax),%eax
c0103a8c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103a8f:	75 0d                	jne    c0103a9e <default_check+0x5df>
c0103a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a94:	8b 00                	mov    (%eax),%eax
c0103a96:	8b 40 04             	mov    0x4(%eax),%eax
c0103a99:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103a9c:	74 24                	je     c0103ac2 <default_check+0x603>
c0103a9e:	c7 44 24 0c 40 69 10 	movl   $0xc0106940,0xc(%esp)
c0103aa5:	c0 
c0103aa6:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103aad:	c0 
c0103aae:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0103ab5:	00 
c0103ab6:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103abd:	e8 19 d2 ff ff       	call   c0100cdb <__panic>
        struct Page *p = le2page(le, page_link);
c0103ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ac5:	83 e8 0c             	sub    $0xc,%eax
c0103ac8:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0103acb:	ff 4d f4             	decl   -0xc(%ebp)
c0103ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103ad1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103ad4:	8b 48 08             	mov    0x8(%eax),%ecx
c0103ad7:	89 d0                	mov    %edx,%eax
c0103ad9:	29 c8                	sub    %ecx,%eax
c0103adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ae1:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0103ae4:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103ae7:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103aed:	81 7d ec 80 be 11 c0 	cmpl   $0xc011be80,-0x14(%ebp)
c0103af4:	75 8e                	jne    c0103a84 <default_check+0x5c5>
    }
    assert(count == 0);
c0103af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103afa:	74 24                	je     c0103b20 <default_check+0x661>
c0103afc:	c7 44 24 0c 6d 69 10 	movl   $0xc010696d,0xc(%esp)
c0103b03:	c0 
c0103b04:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103b0b:	c0 
c0103b0c:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0103b13:	00 
c0103b14:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103b1b:	e8 bb d1 ff ff       	call   c0100cdb <__panic>
    assert(total == 0);
c0103b20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b24:	74 24                	je     c0103b4a <default_check+0x68b>
c0103b26:	c7 44 24 0c 78 69 10 	movl   $0xc0106978,0xc(%esp)
c0103b2d:	c0 
c0103b2e:	c7 44 24 08 f6 65 10 	movl   $0xc01065f6,0x8(%esp)
c0103b35:	c0 
c0103b36:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0103b3d:	00 
c0103b3e:	c7 04 24 0b 66 10 c0 	movl   $0xc010660b,(%esp)
c0103b45:	e8 91 d1 ff ff       	call   c0100cdb <__panic>
}
c0103b4a:	90                   	nop
c0103b4b:	89 ec                	mov    %ebp,%esp
c0103b4d:	5d                   	pop    %ebp
c0103b4e:	c3                   	ret    

c0103b4f <page2ppn>:
page2ppn(struct Page *page) {
c0103b4f:	55                   	push   %ebp
c0103b50:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103b52:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0103b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b5b:	29 d0                	sub    %edx,%eax
c0103b5d:	c1 f8 02             	sar    $0x2,%eax
c0103b60:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103b66:	5d                   	pop    %ebp
c0103b67:	c3                   	ret    

c0103b68 <page2pa>:
page2pa(struct Page *page) {
c0103b68:	55                   	push   %ebp
c0103b69:	89 e5                	mov    %esp,%ebp
c0103b6b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b71:	89 04 24             	mov    %eax,(%esp)
c0103b74:	e8 d6 ff ff ff       	call   c0103b4f <page2ppn>
c0103b79:	c1 e0 0c             	shl    $0xc,%eax
}
c0103b7c:	89 ec                	mov    %ebp,%esp
c0103b7e:	5d                   	pop    %ebp
c0103b7f:	c3                   	ret    

c0103b80 <pa2page>:
pa2page(uintptr_t pa) {
c0103b80:	55                   	push   %ebp
c0103b81:	89 e5                	mov    %esp,%ebp
c0103b83:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b89:	c1 e8 0c             	shr    $0xc,%eax
c0103b8c:	89 c2                	mov    %eax,%edx
c0103b8e:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0103b93:	39 c2                	cmp    %eax,%edx
c0103b95:	72 1c                	jb     c0103bb3 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103b97:	c7 44 24 08 b4 69 10 	movl   $0xc01069b4,0x8(%esp)
c0103b9e:	c0 
c0103b9f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103ba6:	00 
c0103ba7:	c7 04 24 d3 69 10 c0 	movl   $0xc01069d3,(%esp)
c0103bae:	e8 28 d1 ff ff       	call   c0100cdb <__panic>
    return &pages[PPN(pa)];
c0103bb3:	8b 0d a0 be 11 c0    	mov    0xc011bea0,%ecx
c0103bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bbc:	c1 e8 0c             	shr    $0xc,%eax
c0103bbf:	89 c2                	mov    %eax,%edx
c0103bc1:	89 d0                	mov    %edx,%eax
c0103bc3:	c1 e0 02             	shl    $0x2,%eax
c0103bc6:	01 d0                	add    %edx,%eax
c0103bc8:	c1 e0 02             	shl    $0x2,%eax
c0103bcb:	01 c8                	add    %ecx,%eax
}
c0103bcd:	89 ec                	mov    %ebp,%esp
c0103bcf:	5d                   	pop    %ebp
c0103bd0:	c3                   	ret    

c0103bd1 <page2kva>:
page2kva(struct Page *page) {
c0103bd1:	55                   	push   %ebp
c0103bd2:	89 e5                	mov    %esp,%ebp
c0103bd4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bda:	89 04 24             	mov    %eax,(%esp)
c0103bdd:	e8 86 ff ff ff       	call   c0103b68 <page2pa>
c0103be2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103be8:	c1 e8 0c             	shr    $0xc,%eax
c0103beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bee:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0103bf3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103bf6:	72 23                	jb     c0103c1b <page2kva+0x4a>
c0103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103bff:	c7 44 24 08 e4 69 10 	movl   $0xc01069e4,0x8(%esp)
c0103c06:	c0 
c0103c07:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103c0e:	00 
c0103c0f:	c7 04 24 d3 69 10 c0 	movl   $0xc01069d3,(%esp)
c0103c16:	e8 c0 d0 ff ff       	call   c0100cdb <__panic>
c0103c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c1e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103c23:	89 ec                	mov    %ebp,%esp
c0103c25:	5d                   	pop    %ebp
c0103c26:	c3                   	ret    

c0103c27 <pte2page>:
pte2page(pte_t pte) {
c0103c27:	55                   	push   %ebp
c0103c28:	89 e5                	mov    %esp,%ebp
c0103c2a:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103c2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c30:	83 e0 01             	and    $0x1,%eax
c0103c33:	85 c0                	test   %eax,%eax
c0103c35:	75 1c                	jne    c0103c53 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103c37:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c0103c3e:	c0 
c0103c3f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103c46:	00 
c0103c47:	c7 04 24 d3 69 10 c0 	movl   $0xc01069d3,(%esp)
c0103c4e:	e8 88 d0 ff ff       	call   c0100cdb <__panic>
    return pa2page(PTE_ADDR(pte));
c0103c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c5b:	89 04 24             	mov    %eax,(%esp)
c0103c5e:	e8 1d ff ff ff       	call   c0103b80 <pa2page>
}
c0103c63:	89 ec                	mov    %ebp,%esp
c0103c65:	5d                   	pop    %ebp
c0103c66:	c3                   	ret    

c0103c67 <pde2page>:
pde2page(pde_t pde) {
c0103c67:	55                   	push   %ebp
c0103c68:	89 e5                	mov    %esp,%ebp
c0103c6a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c75:	89 04 24             	mov    %eax,(%esp)
c0103c78:	e8 03 ff ff ff       	call   c0103b80 <pa2page>
}
c0103c7d:	89 ec                	mov    %ebp,%esp
c0103c7f:	5d                   	pop    %ebp
c0103c80:	c3                   	ret    

c0103c81 <page_ref>:
page_ref(struct Page *page) {
c0103c81:	55                   	push   %ebp
c0103c82:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103c84:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c87:	8b 00                	mov    (%eax),%eax
}
c0103c89:	5d                   	pop    %ebp
c0103c8a:	c3                   	ret    

c0103c8b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103c8b:	55                   	push   %ebp
c0103c8c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103c8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c91:	8b 00                	mov    (%eax),%eax
c0103c93:	8d 50 01             	lea    0x1(%eax),%edx
c0103c96:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c99:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103c9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c9e:	8b 00                	mov    (%eax),%eax
}
c0103ca0:	5d                   	pop    %ebp
c0103ca1:	c3                   	ret    

c0103ca2 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103ca2:	55                   	push   %ebp
c0103ca3:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ca8:	8b 00                	mov    (%eax),%eax
c0103caa:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb5:	8b 00                	mov    (%eax),%eax
}
c0103cb7:	5d                   	pop    %ebp
c0103cb8:	c3                   	ret    

c0103cb9 <__intr_save>:
__intr_save(void) {
c0103cb9:	55                   	push   %ebp
c0103cba:	89 e5                	mov    %esp,%ebp
c0103cbc:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103cbf:	9c                   	pushf  
c0103cc0:	58                   	pop    %eax
c0103cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103cc7:	25 00 02 00 00       	and    $0x200,%eax
c0103ccc:	85 c0                	test   %eax,%eax
c0103cce:	74 0c                	je     c0103cdc <__intr_save+0x23>
        intr_disable();
c0103cd0:	e8 5f da ff ff       	call   c0101734 <intr_disable>
        return 1;
c0103cd5:	b8 01 00 00 00       	mov    $0x1,%eax
c0103cda:	eb 05                	jmp    c0103ce1 <__intr_save+0x28>
    return 0;
c0103cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103ce1:	89 ec                	mov    %ebp,%esp
c0103ce3:	5d                   	pop    %ebp
c0103ce4:	c3                   	ret    

c0103ce5 <__intr_restore>:
__intr_restore(bool flag) {
c0103ce5:	55                   	push   %ebp
c0103ce6:	89 e5                	mov    %esp,%ebp
c0103ce8:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103ceb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103cef:	74 05                	je     c0103cf6 <__intr_restore+0x11>
        intr_enable();
c0103cf1:	e8 36 da ff ff       	call   c010172c <intr_enable>
}
c0103cf6:	90                   	nop
c0103cf7:	89 ec                	mov    %ebp,%esp
c0103cf9:	5d                   	pop    %ebp
c0103cfa:	c3                   	ret    

c0103cfb <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103cfb:	55                   	push   %ebp
c0103cfc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d01:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103d04:	b8 23 00 00 00       	mov    $0x23,%eax
c0103d09:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103d0b:	b8 23 00 00 00       	mov    $0x23,%eax
c0103d10:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103d12:	b8 10 00 00 00       	mov    $0x10,%eax
c0103d17:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103d19:	b8 10 00 00 00       	mov    $0x10,%eax
c0103d1e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103d20:	b8 10 00 00 00       	mov    $0x10,%eax
c0103d25:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103d27:	ea 2e 3d 10 c0 08 00 	ljmp   $0x8,$0xc0103d2e
}
c0103d2e:	90                   	nop
c0103d2f:	5d                   	pop    %ebp
c0103d30:	c3                   	ret    

c0103d31 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103d31:	55                   	push   %ebp
c0103d32:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103d34:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d37:	a3 c4 be 11 c0       	mov    %eax,0xc011bec4
}
c0103d3c:	90                   	nop
c0103d3d:	5d                   	pop    %ebp
c0103d3e:	c3                   	ret    

c0103d3f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103d3f:	55                   	push   %ebp
c0103d40:	89 e5                	mov    %esp,%ebp
c0103d42:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103d45:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0103d4a:	89 04 24             	mov    %eax,(%esp)
c0103d4d:	e8 df ff ff ff       	call   c0103d31 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103d52:	66 c7 05 c8 be 11 c0 	movw   $0x10,0xc011bec8
c0103d59:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103d5b:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0103d62:	68 00 
c0103d64:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103d69:	0f b7 c0             	movzwl %ax,%eax
c0103d6c:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0103d72:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103d77:	c1 e8 10             	shr    $0x10,%eax
c0103d7a:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0103d7f:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103d86:	24 f0                	and    $0xf0,%al
c0103d88:	0c 09                	or     $0x9,%al
c0103d8a:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103d8f:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103d96:	24 ef                	and    $0xef,%al
c0103d98:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103d9d:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103da4:	24 9f                	and    $0x9f,%al
c0103da6:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103dab:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103db2:	0c 80                	or     $0x80,%al
c0103db4:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103db9:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103dc0:	24 f0                	and    $0xf0,%al
c0103dc2:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103dc7:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103dce:	24 ef                	and    $0xef,%al
c0103dd0:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103dd5:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103ddc:	24 df                	and    $0xdf,%al
c0103dde:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103de3:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103dea:	0c 40                	or     $0x40,%al
c0103dec:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103df1:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103df8:	24 7f                	and    $0x7f,%al
c0103dfa:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103dff:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103e04:	c1 e8 18             	shr    $0x18,%eax
c0103e07:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103e0c:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0103e13:	e8 e3 fe ff ff       	call   c0103cfb <lgdt>
c0103e18:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103e1e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103e22:	0f 00 d8             	ltr    %ax
}
c0103e25:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103e26:	90                   	nop
c0103e27:	89 ec                	mov    %ebp,%esp
c0103e29:	5d                   	pop    %ebp
c0103e2a:	c3                   	ret    

c0103e2b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103e2b:	55                   	push   %ebp
c0103e2c:	89 e5                	mov    %esp,%ebp
c0103e2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103e31:	c7 05 ac be 11 c0 98 	movl   $0xc0106998,0xc011beac
c0103e38:	69 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103e3b:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e40:	8b 00                	mov    (%eax),%eax
c0103e42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e46:	c7 04 24 34 6a 10 c0 	movl   $0xc0106a34,(%esp)
c0103e4d:	e8 04 c5 ff ff       	call   c0100356 <cprintf>
    pmm_manager->init();
c0103e52:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e57:	8b 40 04             	mov    0x4(%eax),%eax
c0103e5a:	ff d0                	call   *%eax
}
c0103e5c:	90                   	nop
c0103e5d:	89 ec                	mov    %ebp,%esp
c0103e5f:	5d                   	pop    %ebp
c0103e60:	c3                   	ret    

c0103e61 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103e61:	55                   	push   %ebp
c0103e62:	89 e5                	mov    %esp,%ebp
c0103e64:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103e67:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e6c:	8b 40 08             	mov    0x8(%eax),%eax
c0103e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e72:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e76:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e79:	89 14 24             	mov    %edx,(%esp)
c0103e7c:	ff d0                	call   *%eax
}
c0103e7e:	90                   	nop
c0103e7f:	89 ec                	mov    %ebp,%esp
c0103e81:	5d                   	pop    %ebp
c0103e82:	c3                   	ret    

c0103e83 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103e83:	55                   	push   %ebp
c0103e84:	89 e5                	mov    %esp,%ebp
c0103e86:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103e89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e90:	e8 24 fe ff ff       	call   c0103cb9 <__intr_save>
c0103e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103e98:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e9d:	8b 40 0c             	mov    0xc(%eax),%eax
c0103ea0:	8b 55 08             	mov    0x8(%ebp),%edx
c0103ea3:	89 14 24             	mov    %edx,(%esp)
c0103ea6:	ff d0                	call   *%eax
c0103ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103eae:	89 04 24             	mov    %eax,(%esp)
c0103eb1:	e8 2f fe ff ff       	call   c0103ce5 <__intr_restore>
    return page;
c0103eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103eb9:	89 ec                	mov    %ebp,%esp
c0103ebb:	5d                   	pop    %ebp
c0103ebc:	c3                   	ret    

c0103ebd <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103ebd:	55                   	push   %ebp
c0103ebe:	89 e5                	mov    %esp,%ebp
c0103ec0:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103ec3:	e8 f1 fd ff ff       	call   c0103cb9 <__intr_save>
c0103ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103ecb:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103ed0:	8b 40 10             	mov    0x10(%eax),%eax
c0103ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103ed6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103eda:	8b 55 08             	mov    0x8(%ebp),%edx
c0103edd:	89 14 24             	mov    %edx,(%esp)
c0103ee0:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ee5:	89 04 24             	mov    %eax,(%esp)
c0103ee8:	e8 f8 fd ff ff       	call   c0103ce5 <__intr_restore>
}
c0103eed:	90                   	nop
c0103eee:	89 ec                	mov    %ebp,%esp
c0103ef0:	5d                   	pop    %ebp
c0103ef1:	c3                   	ret    

c0103ef2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103ef2:	55                   	push   %ebp
c0103ef3:	89 e5                	mov    %esp,%ebp
c0103ef5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103ef8:	e8 bc fd ff ff       	call   c0103cb9 <__intr_save>
c0103efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103f00:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103f05:	8b 40 14             	mov    0x14(%eax),%eax
c0103f08:	ff d0                	call   *%eax
c0103f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f10:	89 04 24             	mov    %eax,(%esp)
c0103f13:	e8 cd fd ff ff       	call   c0103ce5 <__intr_restore>
    return ret;
c0103f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103f1b:	89 ec                	mov    %ebp,%esp
c0103f1d:	5d                   	pop    %ebp
c0103f1e:	c3                   	ret    

c0103f1f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103f1f:	55                   	push   %ebp
c0103f20:	89 e5                	mov    %esp,%ebp
c0103f22:	57                   	push   %edi
c0103f23:	56                   	push   %esi
c0103f24:	53                   	push   %ebx
c0103f25:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103f2b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103f32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103f39:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103f40:	c7 04 24 4b 6a 10 c0 	movl   $0xc0106a4b,(%esp)
c0103f47:	e8 0a c4 ff ff       	call   c0100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103f4c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103f53:	e9 0c 01 00 00       	jmp    c0104064 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103f58:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f5e:	89 d0                	mov    %edx,%eax
c0103f60:	c1 e0 02             	shl    $0x2,%eax
c0103f63:	01 d0                	add    %edx,%eax
c0103f65:	c1 e0 02             	shl    $0x2,%eax
c0103f68:	01 c8                	add    %ecx,%eax
c0103f6a:	8b 50 08             	mov    0x8(%eax),%edx
c0103f6d:	8b 40 04             	mov    0x4(%eax),%eax
c0103f70:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0103f73:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103f76:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f79:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f7c:	89 d0                	mov    %edx,%eax
c0103f7e:	c1 e0 02             	shl    $0x2,%eax
c0103f81:	01 d0                	add    %edx,%eax
c0103f83:	c1 e0 02             	shl    $0x2,%eax
c0103f86:	01 c8                	add    %ecx,%eax
c0103f88:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f8b:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f8e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103f91:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103f94:	01 c8                	add    %ecx,%eax
c0103f96:	11 da                	adc    %ebx,%edx
c0103f98:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103f9b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103f9e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fa1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fa4:	89 d0                	mov    %edx,%eax
c0103fa6:	c1 e0 02             	shl    $0x2,%eax
c0103fa9:	01 d0                	add    %edx,%eax
c0103fab:	c1 e0 02             	shl    $0x2,%eax
c0103fae:	01 c8                	add    %ecx,%eax
c0103fb0:	83 c0 14             	add    $0x14,%eax
c0103fb3:	8b 00                	mov    (%eax),%eax
c0103fb5:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103fbb:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103fbe:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103fc1:	83 c0 ff             	add    $0xffffffff,%eax
c0103fc4:	83 d2 ff             	adc    $0xffffffff,%edx
c0103fc7:	89 c6                	mov    %eax,%esi
c0103fc9:	89 d7                	mov    %edx,%edi
c0103fcb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fd1:	89 d0                	mov    %edx,%eax
c0103fd3:	c1 e0 02             	shl    $0x2,%eax
c0103fd6:	01 d0                	add    %edx,%eax
c0103fd8:	c1 e0 02             	shl    $0x2,%eax
c0103fdb:	01 c8                	add    %ecx,%eax
c0103fdd:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103fe0:	8b 58 10             	mov    0x10(%eax),%ebx
c0103fe3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103fe9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103fed:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103ff1:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103ff5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103ff8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103fff:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104003:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104007:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010400b:	c7 04 24 58 6a 10 c0 	movl   $0xc0106a58,(%esp)
c0104012:	e8 3f c3 ff ff       	call   c0100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104017:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010401a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010401d:	89 d0                	mov    %edx,%eax
c010401f:	c1 e0 02             	shl    $0x2,%eax
c0104022:	01 d0                	add    %edx,%eax
c0104024:	c1 e0 02             	shl    $0x2,%eax
c0104027:	01 c8                	add    %ecx,%eax
c0104029:	83 c0 14             	add    $0x14,%eax
c010402c:	8b 00                	mov    (%eax),%eax
c010402e:	83 f8 01             	cmp    $0x1,%eax
c0104031:	75 2e                	jne    c0104061 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104033:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104039:	3b 45 98             	cmp    -0x68(%ebp),%eax
c010403c:	89 d0                	mov    %edx,%eax
c010403e:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104041:	73 1e                	jae    c0104061 <page_init+0x142>
c0104043:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104048:	b8 00 00 00 00       	mov    $0x0,%eax
c010404d:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104050:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104053:	72 0c                	jb     c0104061 <page_init+0x142>
                maxpa = end;
c0104055:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104058:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010405b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010405e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104061:	ff 45 dc             	incl   -0x24(%ebp)
c0104064:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104067:	8b 00                	mov    (%eax),%eax
c0104069:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010406c:	0f 8c e6 fe ff ff    	jl     c0103f58 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104072:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104077:	b8 00 00 00 00       	mov    $0x0,%eax
c010407c:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c010407f:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104082:	73 0e                	jae    c0104092 <page_init+0x173>
        maxpa = KMEMSIZE;
c0104084:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010408b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104092:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104095:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104098:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010409c:	c1 ea 0c             	shr    $0xc,%edx
c010409f:	a3 a4 be 11 c0       	mov    %eax,0xc011bea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01040a4:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01040ab:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c01040b0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01040b3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01040b6:	01 d0                	add    %edx,%eax
c01040b8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01040bb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01040be:	ba 00 00 00 00       	mov    $0x0,%edx
c01040c3:	f7 75 c0             	divl   -0x40(%ebp)
c01040c6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01040c9:	29 d0                	sub    %edx,%eax
c01040cb:	a3 a0 be 11 c0       	mov    %eax,0xc011bea0

    for (i = 0; i < npage; i ++) {
c01040d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01040d7:	eb 2f                	jmp    c0104108 <page_init+0x1e9>
        SetPageReserved(pages + i);
c01040d9:	8b 0d a0 be 11 c0    	mov    0xc011bea0,%ecx
c01040df:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040e2:	89 d0                	mov    %edx,%eax
c01040e4:	c1 e0 02             	shl    $0x2,%eax
c01040e7:	01 d0                	add    %edx,%eax
c01040e9:	c1 e0 02             	shl    $0x2,%eax
c01040ec:	01 c8                	add    %ecx,%eax
c01040ee:	83 c0 04             	add    $0x4,%eax
c01040f1:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01040f8:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01040fb:	8b 45 90             	mov    -0x70(%ebp),%eax
c01040fe:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104101:	0f ab 10             	bts    %edx,(%eax)
}
c0104104:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0104105:	ff 45 dc             	incl   -0x24(%ebp)
c0104108:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010410b:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104110:	39 c2                	cmp    %eax,%edx
c0104112:	72 c5                	jb     c01040d9 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104114:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c010411a:	89 d0                	mov    %edx,%eax
c010411c:	c1 e0 02             	shl    $0x2,%eax
c010411f:	01 d0                	add    %edx,%eax
c0104121:	c1 e0 02             	shl    $0x2,%eax
c0104124:	89 c2                	mov    %eax,%edx
c0104126:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c010412b:	01 d0                	add    %edx,%eax
c010412d:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104130:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104137:	77 23                	ja     c010415c <page_init+0x23d>
c0104139:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010413c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104140:	c7 44 24 08 88 6a 10 	movl   $0xc0106a88,0x8(%esp)
c0104147:	c0 
c0104148:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010414f:	00 
c0104150:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104157:	e8 7f cb ff ff       	call   c0100cdb <__panic>
c010415c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010415f:	05 00 00 00 40       	add    $0x40000000,%eax
c0104164:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104167:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010416e:	e9 53 01 00 00       	jmp    c01042c6 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104173:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104176:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104179:	89 d0                	mov    %edx,%eax
c010417b:	c1 e0 02             	shl    $0x2,%eax
c010417e:	01 d0                	add    %edx,%eax
c0104180:	c1 e0 02             	shl    $0x2,%eax
c0104183:	01 c8                	add    %ecx,%eax
c0104185:	8b 50 08             	mov    0x8(%eax),%edx
c0104188:	8b 40 04             	mov    0x4(%eax),%eax
c010418b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010418e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104191:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104194:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104197:	89 d0                	mov    %edx,%eax
c0104199:	c1 e0 02             	shl    $0x2,%eax
c010419c:	01 d0                	add    %edx,%eax
c010419e:	c1 e0 02             	shl    $0x2,%eax
c01041a1:	01 c8                	add    %ecx,%eax
c01041a3:	8b 48 0c             	mov    0xc(%eax),%ecx
c01041a6:	8b 58 10             	mov    0x10(%eax),%ebx
c01041a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041af:	01 c8                	add    %ecx,%eax
c01041b1:	11 da                	adc    %ebx,%edx
c01041b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01041b6:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01041b9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01041bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041bf:	89 d0                	mov    %edx,%eax
c01041c1:	c1 e0 02             	shl    $0x2,%eax
c01041c4:	01 d0                	add    %edx,%eax
c01041c6:	c1 e0 02             	shl    $0x2,%eax
c01041c9:	01 c8                	add    %ecx,%eax
c01041cb:	83 c0 14             	add    $0x14,%eax
c01041ce:	8b 00                	mov    (%eax),%eax
c01041d0:	83 f8 01             	cmp    $0x1,%eax
c01041d3:	0f 85 ea 00 00 00    	jne    c01042c3 <page_init+0x3a4>
            if (begin < freemem) {
c01041d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041dc:	ba 00 00 00 00       	mov    $0x0,%edx
c01041e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01041e4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01041e7:	19 d1                	sbb    %edx,%ecx
c01041e9:	73 0d                	jae    c01041f8 <page_init+0x2d9>
                begin = freemem;
c01041eb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01041f1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01041f8:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01041fd:	b8 00 00 00 00       	mov    $0x0,%eax
c0104202:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104205:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104208:	73 0e                	jae    c0104218 <page_init+0x2f9>
                end = KMEMSIZE;
c010420a:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104211:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104218:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010421b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010421e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104221:	89 d0                	mov    %edx,%eax
c0104223:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104226:	0f 83 97 00 00 00    	jae    c01042c3 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c010422c:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104233:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104236:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104239:	01 d0                	add    %edx,%eax
c010423b:	48                   	dec    %eax
c010423c:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010423f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104242:	ba 00 00 00 00       	mov    $0x0,%edx
c0104247:	f7 75 b0             	divl   -0x50(%ebp)
c010424a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010424d:	29 d0                	sub    %edx,%eax
c010424f:	ba 00 00 00 00       	mov    $0x0,%edx
c0104254:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104257:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010425a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010425d:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104260:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104263:	ba 00 00 00 00       	mov    $0x0,%edx
c0104268:	89 c7                	mov    %eax,%edi
c010426a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104270:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104273:	89 d0                	mov    %edx,%eax
c0104275:	83 e0 00             	and    $0x0,%eax
c0104278:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010427b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010427e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104281:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104284:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104287:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010428a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010428d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104290:	89 d0                	mov    %edx,%eax
c0104292:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104295:	73 2c                	jae    c01042c3 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104297:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010429a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010429d:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01042a0:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01042a3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01042a7:	c1 ea 0c             	shr    $0xc,%edx
c01042aa:	89 c3                	mov    %eax,%ebx
c01042ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01042af:	89 04 24             	mov    %eax,(%esp)
c01042b2:	e8 c9 f8 ff ff       	call   c0103b80 <pa2page>
c01042b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01042bb:	89 04 24             	mov    %eax,(%esp)
c01042be:	e8 9e fb ff ff       	call   c0103e61 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01042c3:	ff 45 dc             	incl   -0x24(%ebp)
c01042c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01042c9:	8b 00                	mov    (%eax),%eax
c01042cb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01042ce:	0f 8c 9f fe ff ff    	jl     c0104173 <page_init+0x254>
                }
            }
        }
    }
}
c01042d4:	90                   	nop
c01042d5:	90                   	nop
c01042d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01042dc:	5b                   	pop    %ebx
c01042dd:	5e                   	pop    %esi
c01042de:	5f                   	pop    %edi
c01042df:	5d                   	pop    %ebp
c01042e0:	c3                   	ret    

c01042e1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01042e1:	55                   	push   %ebp
c01042e2:	89 e5                	mov    %esp,%ebp
c01042e4:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042ea:	33 45 14             	xor    0x14(%ebp),%eax
c01042ed:	25 ff 0f 00 00       	and    $0xfff,%eax
c01042f2:	85 c0                	test   %eax,%eax
c01042f4:	74 24                	je     c010431a <boot_map_segment+0x39>
c01042f6:	c7 44 24 0c ba 6a 10 	movl   $0xc0106aba,0xc(%esp)
c01042fd:	c0 
c01042fe:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104305:	c0 
c0104306:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010430d:	00 
c010430e:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104315:	e8 c1 c9 ff ff       	call   c0100cdb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010431a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104321:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104324:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104329:	89 c2                	mov    %eax,%edx
c010432b:	8b 45 10             	mov    0x10(%ebp),%eax
c010432e:	01 c2                	add    %eax,%edx
c0104330:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104333:	01 d0                	add    %edx,%eax
c0104335:	48                   	dec    %eax
c0104336:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104339:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010433c:	ba 00 00 00 00       	mov    $0x0,%edx
c0104341:	f7 75 f0             	divl   -0x10(%ebp)
c0104344:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104347:	29 d0                	sub    %edx,%eax
c0104349:	c1 e8 0c             	shr    $0xc,%eax
c010434c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010434f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104352:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104355:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104358:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010435d:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104360:	8b 45 14             	mov    0x14(%ebp),%eax
c0104363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104369:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010436e:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104371:	eb 68                	jmp    c01043db <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104373:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010437a:	00 
c010437b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010437e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104382:	8b 45 08             	mov    0x8(%ebp),%eax
c0104385:	89 04 24             	mov    %eax,(%esp)
c0104388:	e8 88 01 00 00       	call   c0104515 <get_pte>
c010438d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104390:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104394:	75 24                	jne    c01043ba <boot_map_segment+0xd9>
c0104396:	c7 44 24 0c e6 6a 10 	movl   $0xc0106ae6,0xc(%esp)
c010439d:	c0 
c010439e:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01043a5:	c0 
c01043a6:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01043ad:	00 
c01043ae:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01043b5:	e8 21 c9 ff ff       	call   c0100cdb <__panic>
        *ptep = pa | PTE_P | perm;
c01043ba:	8b 45 14             	mov    0x14(%ebp),%eax
c01043bd:	0b 45 18             	or     0x18(%ebp),%eax
c01043c0:	83 c8 01             	or     $0x1,%eax
c01043c3:	89 c2                	mov    %eax,%edx
c01043c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01043c8:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01043ca:	ff 4d f4             	decl   -0xc(%ebp)
c01043cd:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01043d4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01043db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01043df:	75 92                	jne    c0104373 <boot_map_segment+0x92>
    }
}
c01043e1:	90                   	nop
c01043e2:	90                   	nop
c01043e3:	89 ec                	mov    %ebp,%esp
c01043e5:	5d                   	pop    %ebp
c01043e6:	c3                   	ret    

c01043e7 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01043e7:	55                   	push   %ebp
c01043e8:	89 e5                	mov    %esp,%ebp
c01043ea:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01043ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043f4:	e8 8a fa ff ff       	call   c0103e83 <alloc_pages>
c01043f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01043fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104400:	75 1c                	jne    c010441e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104402:	c7 44 24 08 f3 6a 10 	movl   $0xc0106af3,0x8(%esp)
c0104409:	c0 
c010440a:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104411:	00 
c0104412:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104419:	e8 bd c8 ff ff       	call   c0100cdb <__panic>
    }
    return page2kva(p);
c010441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104421:	89 04 24             	mov    %eax,(%esp)
c0104424:	e8 a8 f7 ff ff       	call   c0103bd1 <page2kva>
}
c0104429:	89 ec                	mov    %ebp,%esp
c010442b:	5d                   	pop    %ebp
c010442c:	c3                   	ret    

c010442d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010442d:	55                   	push   %ebp
c010442e:	89 e5                	mov    %esp,%ebp
c0104430:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104433:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104438:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010443b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104442:	77 23                	ja     c0104467 <pmm_init+0x3a>
c0104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104447:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010444b:	c7 44 24 08 88 6a 10 	movl   $0xc0106a88,0x8(%esp)
c0104452:	c0 
c0104453:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010445a:	00 
c010445b:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104462:	e8 74 c8 ff ff       	call   c0100cdb <__panic>
c0104467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010446a:	05 00 00 00 40       	add    $0x40000000,%eax
c010446f:	a3 a8 be 11 c0       	mov    %eax,0xc011bea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104474:	e8 b2 f9 ff ff       	call   c0103e2b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104479:	e8 a1 fa ff ff       	call   c0103f1f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010447e:	e8 5a 02 00 00       	call   c01046dd <check_alloc_page>

    check_pgdir();
c0104483:	e8 76 02 00 00       	call   c01046fe <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104488:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010448d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104490:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104497:	77 23                	ja     c01044bc <pmm_init+0x8f>
c0104499:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010449c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044a0:	c7 44 24 08 88 6a 10 	movl   $0xc0106a88,0x8(%esp)
c01044a7:	c0 
c01044a8:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01044af:	00 
c01044b0:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01044b7:	e8 1f c8 ff ff       	call   c0100cdb <__panic>
c01044bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044bf:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01044c5:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01044ca:	05 ac 0f 00 00       	add    $0xfac,%eax
c01044cf:	83 ca 03             	or     $0x3,%edx
c01044d2:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01044d4:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01044d9:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01044e0:	00 
c01044e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01044e8:	00 
c01044e9:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01044f0:	38 
c01044f1:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01044f8:	c0 
c01044f9:	89 04 24             	mov    %eax,(%esp)
c01044fc:	e8 e0 fd ff ff       	call   c01042e1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104501:	e8 39 f8 ff ff       	call   c0103d3f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104506:	e8 91 08 00 00       	call   c0104d9c <check_boot_pgdir>

    print_pgdir();
c010450b:	e8 0e 0d 00 00       	call   c010521e <print_pgdir>

}
c0104510:	90                   	nop
c0104511:	89 ec                	mov    %ebp,%esp
c0104513:	5d                   	pop    %ebp
c0104514:	c3                   	ret    

c0104515 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104515:	55                   	push   %ebp
c0104516:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c0104518:	90                   	nop
c0104519:	5d                   	pop    %ebp
c010451a:	c3                   	ret    

c010451b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010451b:	55                   	push   %ebp
c010451c:	89 e5                	mov    %esp,%ebp
c010451e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104521:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104528:	00 
c0104529:	8b 45 0c             	mov    0xc(%ebp),%eax
c010452c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104530:	8b 45 08             	mov    0x8(%ebp),%eax
c0104533:	89 04 24             	mov    %eax,(%esp)
c0104536:	e8 da ff ff ff       	call   c0104515 <get_pte>
c010453b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010453e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104542:	74 08                	je     c010454c <get_page+0x31>
        *ptep_store = ptep;
c0104544:	8b 45 10             	mov    0x10(%ebp),%eax
c0104547:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010454a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010454c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104550:	74 1b                	je     c010456d <get_page+0x52>
c0104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104555:	8b 00                	mov    (%eax),%eax
c0104557:	83 e0 01             	and    $0x1,%eax
c010455a:	85 c0                	test   %eax,%eax
c010455c:	74 0f                	je     c010456d <get_page+0x52>
        return pte2page(*ptep);
c010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104561:	8b 00                	mov    (%eax),%eax
c0104563:	89 04 24             	mov    %eax,(%esp)
c0104566:	e8 bc f6 ff ff       	call   c0103c27 <pte2page>
c010456b:	eb 05                	jmp    c0104572 <get_page+0x57>
    }
    return NULL;
c010456d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104572:	89 ec                	mov    %ebp,%esp
c0104574:	5d                   	pop    %ebp
c0104575:	c3                   	ret    

c0104576 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104576:	55                   	push   %ebp
c0104577:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c0104579:	90                   	nop
c010457a:	5d                   	pop    %ebp
c010457b:	c3                   	ret    

c010457c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010457c:	55                   	push   %ebp
c010457d:	89 e5                	mov    %esp,%ebp
c010457f:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104582:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104589:	00 
c010458a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010458d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104591:	8b 45 08             	mov    0x8(%ebp),%eax
c0104594:	89 04 24             	mov    %eax,(%esp)
c0104597:	e8 79 ff ff ff       	call   c0104515 <get_pte>
c010459c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c010459f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01045a3:	74 19                	je     c01045be <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01045a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01045a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b6:	89 04 24             	mov    %eax,(%esp)
c01045b9:	e8 b8 ff ff ff       	call   c0104576 <page_remove_pte>
    }
}
c01045be:	90                   	nop
c01045bf:	89 ec                	mov    %ebp,%esp
c01045c1:	5d                   	pop    %ebp
c01045c2:	c3                   	ret    

c01045c3 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01045c3:	55                   	push   %ebp
c01045c4:	89 e5                	mov    %esp,%ebp
c01045c6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01045c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01045d0:	00 
c01045d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01045d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045db:	89 04 24             	mov    %eax,(%esp)
c01045de:	e8 32 ff ff ff       	call   c0104515 <get_pte>
c01045e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01045e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045ea:	75 0a                	jne    c01045f6 <page_insert+0x33>
        return -E_NO_MEM;
c01045ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01045f1:	e9 84 00 00 00       	jmp    c010467a <page_insert+0xb7>
    }
    page_ref_inc(page);
c01045f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045f9:	89 04 24             	mov    %eax,(%esp)
c01045fc:	e8 8a f6 ff ff       	call   c0103c8b <page_ref_inc>
    if (*ptep & PTE_P) {
c0104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104604:	8b 00                	mov    (%eax),%eax
c0104606:	83 e0 01             	and    $0x1,%eax
c0104609:	85 c0                	test   %eax,%eax
c010460b:	74 3e                	je     c010464b <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010460d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104610:	8b 00                	mov    (%eax),%eax
c0104612:	89 04 24             	mov    %eax,(%esp)
c0104615:	e8 0d f6 ff ff       	call   c0103c27 <pte2page>
c010461a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010461d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104620:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104623:	75 0d                	jne    c0104632 <page_insert+0x6f>
            page_ref_dec(page);
c0104625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104628:	89 04 24             	mov    %eax,(%esp)
c010462b:	e8 72 f6 ff ff       	call   c0103ca2 <page_ref_dec>
c0104630:	eb 19                	jmp    c010464b <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104635:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104639:	8b 45 10             	mov    0x10(%ebp),%eax
c010463c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104640:	8b 45 08             	mov    0x8(%ebp),%eax
c0104643:	89 04 24             	mov    %eax,(%esp)
c0104646:	e8 2b ff ff ff       	call   c0104576 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010464b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010464e:	89 04 24             	mov    %eax,(%esp)
c0104651:	e8 12 f5 ff ff       	call   c0103b68 <page2pa>
c0104656:	0b 45 14             	or     0x14(%ebp),%eax
c0104659:	83 c8 01             	or     $0x1,%eax
c010465c:	89 c2                	mov    %eax,%edx
c010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104661:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104663:	8b 45 10             	mov    0x10(%ebp),%eax
c0104666:	89 44 24 04          	mov    %eax,0x4(%esp)
c010466a:	8b 45 08             	mov    0x8(%ebp),%eax
c010466d:	89 04 24             	mov    %eax,(%esp)
c0104670:	e8 09 00 00 00       	call   c010467e <tlb_invalidate>
    return 0;
c0104675:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010467a:	89 ec                	mov    %ebp,%esp
c010467c:	5d                   	pop    %ebp
c010467d:	c3                   	ret    

c010467e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010467e:	55                   	push   %ebp
c010467f:	89 e5                	mov    %esp,%ebp
c0104681:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104684:	0f 20 d8             	mov    %cr3,%eax
c0104687:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010468a:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010468d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104690:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104693:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010469a:	77 23                	ja     c01046bf <tlb_invalidate+0x41>
c010469c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010469f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046a3:	c7 44 24 08 88 6a 10 	movl   $0xc0106a88,0x8(%esp)
c01046aa:	c0 
c01046ab:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c01046b2:	00 
c01046b3:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01046ba:	e8 1c c6 ff ff       	call   c0100cdb <__panic>
c01046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c2:	05 00 00 00 40       	add    $0x40000000,%eax
c01046c7:	39 d0                	cmp    %edx,%eax
c01046c9:	75 0d                	jne    c01046d8 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c01046cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01046d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046d4:	0f 01 38             	invlpg (%eax)
}
c01046d7:	90                   	nop
    }
}
c01046d8:	90                   	nop
c01046d9:	89 ec                	mov    %ebp,%esp
c01046db:	5d                   	pop    %ebp
c01046dc:	c3                   	ret    

c01046dd <check_alloc_page>:

static void
check_alloc_page(void) {
c01046dd:	55                   	push   %ebp
c01046de:	89 e5                	mov    %esp,%ebp
c01046e0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01046e3:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c01046e8:	8b 40 18             	mov    0x18(%eax),%eax
c01046eb:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01046ed:	c7 04 24 0c 6b 10 c0 	movl   $0xc0106b0c,(%esp)
c01046f4:	e8 5d bc ff ff       	call   c0100356 <cprintf>
}
c01046f9:	90                   	nop
c01046fa:	89 ec                	mov    %ebp,%esp
c01046fc:	5d                   	pop    %ebp
c01046fd:	c3                   	ret    

c01046fe <check_pgdir>:

static void
check_pgdir(void) {
c01046fe:	55                   	push   %ebp
c01046ff:	89 e5                	mov    %esp,%ebp
c0104701:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104704:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104709:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010470e:	76 24                	jbe    c0104734 <check_pgdir+0x36>
c0104710:	c7 44 24 0c 2b 6b 10 	movl   $0xc0106b2b,0xc(%esp)
c0104717:	c0 
c0104718:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c010471f:	c0 
c0104720:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0104727:	00 
c0104728:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c010472f:	e8 a7 c5 ff ff       	call   c0100cdb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104734:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104739:	85 c0                	test   %eax,%eax
c010473b:	74 0e                	je     c010474b <check_pgdir+0x4d>
c010473d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104742:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104747:	85 c0                	test   %eax,%eax
c0104749:	74 24                	je     c010476f <check_pgdir+0x71>
c010474b:	c7 44 24 0c 48 6b 10 	movl   $0xc0106b48,0xc(%esp)
c0104752:	c0 
c0104753:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c010475a:	c0 
c010475b:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0104762:	00 
c0104763:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c010476a:	e8 6c c5 ff ff       	call   c0100cdb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010476f:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104774:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010477b:	00 
c010477c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104783:	00 
c0104784:	89 04 24             	mov    %eax,(%esp)
c0104787:	e8 8f fd ff ff       	call   c010451b <get_page>
c010478c:	85 c0                	test   %eax,%eax
c010478e:	74 24                	je     c01047b4 <check_pgdir+0xb6>
c0104790:	c7 44 24 0c 80 6b 10 	movl   $0xc0106b80,0xc(%esp)
c0104797:	c0 
c0104798:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c010479f:	c0 
c01047a0:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c01047a7:	00 
c01047a8:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01047af:	e8 27 c5 ff ff       	call   c0100cdb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01047b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047bb:	e8 c3 f6 ff ff       	call   c0103e83 <alloc_pages>
c01047c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01047c3:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01047c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01047cf:	00 
c01047d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047d7:	00 
c01047d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047db:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047df:	89 04 24             	mov    %eax,(%esp)
c01047e2:	e8 dc fd ff ff       	call   c01045c3 <page_insert>
c01047e7:	85 c0                	test   %eax,%eax
c01047e9:	74 24                	je     c010480f <check_pgdir+0x111>
c01047eb:	c7 44 24 0c a8 6b 10 	movl   $0xc0106ba8,0xc(%esp)
c01047f2:	c0 
c01047f3:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01047fa:	c0 
c01047fb:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0104802:	00 
c0104803:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c010480a:	e8 cc c4 ff ff       	call   c0100cdb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010480f:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104814:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010481b:	00 
c010481c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104823:	00 
c0104824:	89 04 24             	mov    %eax,(%esp)
c0104827:	e8 e9 fc ff ff       	call   c0104515 <get_pte>
c010482c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010482f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104833:	75 24                	jne    c0104859 <check_pgdir+0x15b>
c0104835:	c7 44 24 0c d4 6b 10 	movl   $0xc0106bd4,0xc(%esp)
c010483c:	c0 
c010483d:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104844:	c0 
c0104845:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c010484c:	00 
c010484d:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104854:	e8 82 c4 ff ff       	call   c0100cdb <__panic>
    assert(pte2page(*ptep) == p1);
c0104859:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010485c:	8b 00                	mov    (%eax),%eax
c010485e:	89 04 24             	mov    %eax,(%esp)
c0104861:	e8 c1 f3 ff ff       	call   c0103c27 <pte2page>
c0104866:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104869:	74 24                	je     c010488f <check_pgdir+0x191>
c010486b:	c7 44 24 0c 01 6c 10 	movl   $0xc0106c01,0xc(%esp)
c0104872:	c0 
c0104873:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c010487a:	c0 
c010487b:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c0104882:	00 
c0104883:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c010488a:	e8 4c c4 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p1) == 1);
c010488f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104892:	89 04 24             	mov    %eax,(%esp)
c0104895:	e8 e7 f3 ff ff       	call   c0103c81 <page_ref>
c010489a:	83 f8 01             	cmp    $0x1,%eax
c010489d:	74 24                	je     c01048c3 <check_pgdir+0x1c5>
c010489f:	c7 44 24 0c 17 6c 10 	movl   $0xc0106c17,0xc(%esp)
c01048a6:	c0 
c01048a7:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01048ae:	c0 
c01048af:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c01048b6:	00 
c01048b7:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01048be:	e8 18 c4 ff ff       	call   c0100cdb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01048c3:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01048c8:	8b 00                	mov    (%eax),%eax
c01048ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01048cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01048d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048d5:	c1 e8 0c             	shr    $0xc,%eax
c01048d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01048db:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c01048e0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01048e3:	72 23                	jb     c0104908 <check_pgdir+0x20a>
c01048e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048ec:	c7 44 24 08 e4 69 10 	movl   $0xc01069e4,0x8(%esp)
c01048f3:	c0 
c01048f4:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c01048fb:	00 
c01048fc:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104903:	e8 d3 c3 ff ff       	call   c0100cdb <__panic>
c0104908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010490b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104910:	83 c0 04             	add    $0x4,%eax
c0104913:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104916:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010491b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104922:	00 
c0104923:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010492a:	00 
c010492b:	89 04 24             	mov    %eax,(%esp)
c010492e:	e8 e2 fb ff ff       	call   c0104515 <get_pte>
c0104933:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104936:	74 24                	je     c010495c <check_pgdir+0x25e>
c0104938:	c7 44 24 0c 2c 6c 10 	movl   $0xc0106c2c,0xc(%esp)
c010493f:	c0 
c0104940:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104947:	c0 
c0104948:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c010494f:	00 
c0104950:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104957:	e8 7f c3 ff ff       	call   c0100cdb <__panic>

    p2 = alloc_page();
c010495c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104963:	e8 1b f5 ff ff       	call   c0103e83 <alloc_pages>
c0104968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010496b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104970:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104977:	00 
c0104978:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010497f:	00 
c0104980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104983:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104987:	89 04 24             	mov    %eax,(%esp)
c010498a:	e8 34 fc ff ff       	call   c01045c3 <page_insert>
c010498f:	85 c0                	test   %eax,%eax
c0104991:	74 24                	je     c01049b7 <check_pgdir+0x2b9>
c0104993:	c7 44 24 0c 54 6c 10 	movl   $0xc0106c54,0xc(%esp)
c010499a:	c0 
c010499b:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01049a2:	c0 
c01049a3:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01049aa:	00 
c01049ab:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01049b2:	e8 24 c3 ff ff       	call   c0100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01049b7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01049bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049c3:	00 
c01049c4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01049cb:	00 
c01049cc:	89 04 24             	mov    %eax,(%esp)
c01049cf:	e8 41 fb ff ff       	call   c0104515 <get_pte>
c01049d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01049d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01049db:	75 24                	jne    c0104a01 <check_pgdir+0x303>
c01049dd:	c7 44 24 0c 8c 6c 10 	movl   $0xc0106c8c,0xc(%esp)
c01049e4:	c0 
c01049e5:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01049ec:	c0 
c01049ed:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c01049f4:	00 
c01049f5:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01049fc:	e8 da c2 ff ff       	call   c0100cdb <__panic>
    assert(*ptep & PTE_U);
c0104a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a04:	8b 00                	mov    (%eax),%eax
c0104a06:	83 e0 04             	and    $0x4,%eax
c0104a09:	85 c0                	test   %eax,%eax
c0104a0b:	75 24                	jne    c0104a31 <check_pgdir+0x333>
c0104a0d:	c7 44 24 0c bc 6c 10 	movl   $0xc0106cbc,0xc(%esp)
c0104a14:	c0 
c0104a15:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104a1c:	c0 
c0104a1d:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0104a24:	00 
c0104a25:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104a2c:	e8 aa c2 ff ff       	call   c0100cdb <__panic>
    assert(*ptep & PTE_W);
c0104a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a34:	8b 00                	mov    (%eax),%eax
c0104a36:	83 e0 02             	and    $0x2,%eax
c0104a39:	85 c0                	test   %eax,%eax
c0104a3b:	75 24                	jne    c0104a61 <check_pgdir+0x363>
c0104a3d:	c7 44 24 0c ca 6c 10 	movl   $0xc0106cca,0xc(%esp)
c0104a44:	c0 
c0104a45:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104a4c:	c0 
c0104a4d:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0104a54:	00 
c0104a55:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104a5c:	e8 7a c2 ff ff       	call   c0100cdb <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104a61:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104a66:	8b 00                	mov    (%eax),%eax
c0104a68:	83 e0 04             	and    $0x4,%eax
c0104a6b:	85 c0                	test   %eax,%eax
c0104a6d:	75 24                	jne    c0104a93 <check_pgdir+0x395>
c0104a6f:	c7 44 24 0c d8 6c 10 	movl   $0xc0106cd8,0xc(%esp)
c0104a76:	c0 
c0104a77:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104a7e:	c0 
c0104a7f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0104a86:	00 
c0104a87:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104a8e:	e8 48 c2 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 1);
c0104a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a96:	89 04 24             	mov    %eax,(%esp)
c0104a99:	e8 e3 f1 ff ff       	call   c0103c81 <page_ref>
c0104a9e:	83 f8 01             	cmp    $0x1,%eax
c0104aa1:	74 24                	je     c0104ac7 <check_pgdir+0x3c9>
c0104aa3:	c7 44 24 0c ee 6c 10 	movl   $0xc0106cee,0xc(%esp)
c0104aaa:	c0 
c0104aab:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104ab2:	c0 
c0104ab3:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0104aba:	00 
c0104abb:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104ac2:	e8 14 c2 ff ff       	call   c0100cdb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104ac7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104acc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104ad3:	00 
c0104ad4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104adb:	00 
c0104adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104adf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ae3:	89 04 24             	mov    %eax,(%esp)
c0104ae6:	e8 d8 fa ff ff       	call   c01045c3 <page_insert>
c0104aeb:	85 c0                	test   %eax,%eax
c0104aed:	74 24                	je     c0104b13 <check_pgdir+0x415>
c0104aef:	c7 44 24 0c 00 6d 10 	movl   $0xc0106d00,0xc(%esp)
c0104af6:	c0 
c0104af7:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104afe:	c0 
c0104aff:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0104b06:	00 
c0104b07:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104b0e:	e8 c8 c1 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p1) == 2);
c0104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b16:	89 04 24             	mov    %eax,(%esp)
c0104b19:	e8 63 f1 ff ff       	call   c0103c81 <page_ref>
c0104b1e:	83 f8 02             	cmp    $0x2,%eax
c0104b21:	74 24                	je     c0104b47 <check_pgdir+0x449>
c0104b23:	c7 44 24 0c 2c 6d 10 	movl   $0xc0106d2c,0xc(%esp)
c0104b2a:	c0 
c0104b2b:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104b32:	c0 
c0104b33:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0104b3a:	00 
c0104b3b:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104b42:	e8 94 c1 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b4a:	89 04 24             	mov    %eax,(%esp)
c0104b4d:	e8 2f f1 ff ff       	call   c0103c81 <page_ref>
c0104b52:	85 c0                	test   %eax,%eax
c0104b54:	74 24                	je     c0104b7a <check_pgdir+0x47c>
c0104b56:	c7 44 24 0c 3e 6d 10 	movl   $0xc0106d3e,0xc(%esp)
c0104b5d:	c0 
c0104b5e:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104b65:	c0 
c0104b66:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0104b6d:	00 
c0104b6e:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104b75:	e8 61 c1 ff ff       	call   c0100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104b7a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104b7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b86:	00 
c0104b87:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b8e:	00 
c0104b8f:	89 04 24             	mov    %eax,(%esp)
c0104b92:	e8 7e f9 ff ff       	call   c0104515 <get_pte>
c0104b97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b9e:	75 24                	jne    c0104bc4 <check_pgdir+0x4c6>
c0104ba0:	c7 44 24 0c 8c 6c 10 	movl   $0xc0106c8c,0xc(%esp)
c0104ba7:	c0 
c0104ba8:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104baf:	c0 
c0104bb0:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0104bb7:	00 
c0104bb8:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104bbf:	e8 17 c1 ff ff       	call   c0100cdb <__panic>
    assert(pte2page(*ptep) == p1);
c0104bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc7:	8b 00                	mov    (%eax),%eax
c0104bc9:	89 04 24             	mov    %eax,(%esp)
c0104bcc:	e8 56 f0 ff ff       	call   c0103c27 <pte2page>
c0104bd1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104bd4:	74 24                	je     c0104bfa <check_pgdir+0x4fc>
c0104bd6:	c7 44 24 0c 01 6c 10 	movl   $0xc0106c01,0xc(%esp)
c0104bdd:	c0 
c0104bde:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104be5:	c0 
c0104be6:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0104bed:	00 
c0104bee:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104bf5:	e8 e1 c0 ff ff       	call   c0100cdb <__panic>
    assert((*ptep & PTE_U) == 0);
c0104bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bfd:	8b 00                	mov    (%eax),%eax
c0104bff:	83 e0 04             	and    $0x4,%eax
c0104c02:	85 c0                	test   %eax,%eax
c0104c04:	74 24                	je     c0104c2a <check_pgdir+0x52c>
c0104c06:	c7 44 24 0c 50 6d 10 	movl   $0xc0106d50,0xc(%esp)
c0104c0d:	c0 
c0104c0e:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104c15:	c0 
c0104c16:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104c1d:	00 
c0104c1e:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104c25:	e8 b1 c0 ff ff       	call   c0100cdb <__panic>

    page_remove(boot_pgdir, 0x0);
c0104c2a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104c2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c36:	00 
c0104c37:	89 04 24             	mov    %eax,(%esp)
c0104c3a:	e8 3d f9 ff ff       	call   c010457c <page_remove>
    assert(page_ref(p1) == 1);
c0104c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c42:	89 04 24             	mov    %eax,(%esp)
c0104c45:	e8 37 f0 ff ff       	call   c0103c81 <page_ref>
c0104c4a:	83 f8 01             	cmp    $0x1,%eax
c0104c4d:	74 24                	je     c0104c73 <check_pgdir+0x575>
c0104c4f:	c7 44 24 0c 17 6c 10 	movl   $0xc0106c17,0xc(%esp)
c0104c56:	c0 
c0104c57:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104c5e:	c0 
c0104c5f:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104c66:	00 
c0104c67:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104c6e:	e8 68 c0 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c76:	89 04 24             	mov    %eax,(%esp)
c0104c79:	e8 03 f0 ff ff       	call   c0103c81 <page_ref>
c0104c7e:	85 c0                	test   %eax,%eax
c0104c80:	74 24                	je     c0104ca6 <check_pgdir+0x5a8>
c0104c82:	c7 44 24 0c 3e 6d 10 	movl   $0xc0106d3e,0xc(%esp)
c0104c89:	c0 
c0104c8a:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104c91:	c0 
c0104c92:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104c99:	00 
c0104c9a:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104ca1:	e8 35 c0 ff ff       	call   c0100cdb <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104ca6:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104cab:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104cb2:	00 
c0104cb3:	89 04 24             	mov    %eax,(%esp)
c0104cb6:	e8 c1 f8 ff ff       	call   c010457c <page_remove>
    assert(page_ref(p1) == 0);
c0104cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cbe:	89 04 24             	mov    %eax,(%esp)
c0104cc1:	e8 bb ef ff ff       	call   c0103c81 <page_ref>
c0104cc6:	85 c0                	test   %eax,%eax
c0104cc8:	74 24                	je     c0104cee <check_pgdir+0x5f0>
c0104cca:	c7 44 24 0c 65 6d 10 	movl   $0xc0106d65,0xc(%esp)
c0104cd1:	c0 
c0104cd2:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104cd9:	c0 
c0104cda:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104ce1:	00 
c0104ce2:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104ce9:	e8 ed bf ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cf1:	89 04 24             	mov    %eax,(%esp)
c0104cf4:	e8 88 ef ff ff       	call   c0103c81 <page_ref>
c0104cf9:	85 c0                	test   %eax,%eax
c0104cfb:	74 24                	je     c0104d21 <check_pgdir+0x623>
c0104cfd:	c7 44 24 0c 3e 6d 10 	movl   $0xc0106d3e,0xc(%esp)
c0104d04:	c0 
c0104d05:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104d0c:	c0 
c0104d0d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104d14:	00 
c0104d15:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104d1c:	e8 ba bf ff ff       	call   c0100cdb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104d21:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104d26:	8b 00                	mov    (%eax),%eax
c0104d28:	89 04 24             	mov    %eax,(%esp)
c0104d2b:	e8 37 ef ff ff       	call   c0103c67 <pde2page>
c0104d30:	89 04 24             	mov    %eax,(%esp)
c0104d33:	e8 49 ef ff ff       	call   c0103c81 <page_ref>
c0104d38:	83 f8 01             	cmp    $0x1,%eax
c0104d3b:	74 24                	je     c0104d61 <check_pgdir+0x663>
c0104d3d:	c7 44 24 0c 78 6d 10 	movl   $0xc0106d78,0xc(%esp)
c0104d44:	c0 
c0104d45:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104d4c:	c0 
c0104d4d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104d54:	00 
c0104d55:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104d5c:	e8 7a bf ff ff       	call   c0100cdb <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104d61:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104d66:	8b 00                	mov    (%eax),%eax
c0104d68:	89 04 24             	mov    %eax,(%esp)
c0104d6b:	e8 f7 ee ff ff       	call   c0103c67 <pde2page>
c0104d70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d77:	00 
c0104d78:	89 04 24             	mov    %eax,(%esp)
c0104d7b:	e8 3d f1 ff ff       	call   c0103ebd <free_pages>
    boot_pgdir[0] = 0;
c0104d80:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104d85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104d8b:	c7 04 24 9f 6d 10 c0 	movl   $0xc0106d9f,(%esp)
c0104d92:	e8 bf b5 ff ff       	call   c0100356 <cprintf>
}
c0104d97:	90                   	nop
c0104d98:	89 ec                	mov    %ebp,%esp
c0104d9a:	5d                   	pop    %ebp
c0104d9b:	c3                   	ret    

c0104d9c <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104d9c:	55                   	push   %ebp
c0104d9d:	89 e5                	mov    %esp,%ebp
c0104d9f:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104da2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104da9:	e9 ca 00 00 00       	jmp    c0104e78 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104db7:	c1 e8 0c             	shr    $0xc,%eax
c0104dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104dbd:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104dc2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104dc5:	72 23                	jb     c0104dea <check_boot_pgdir+0x4e>
c0104dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104dce:	c7 44 24 08 e4 69 10 	movl   $0xc01069e4,0x8(%esp)
c0104dd5:	c0 
c0104dd6:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104ddd:	00 
c0104dde:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104de5:	e8 f1 be ff ff       	call   c0100cdb <__panic>
c0104dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ded:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104df2:	89 c2                	mov    %eax,%edx
c0104df4:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104df9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e00:	00 
c0104e01:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e05:	89 04 24             	mov    %eax,(%esp)
c0104e08:	e8 08 f7 ff ff       	call   c0104515 <get_pte>
c0104e0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104e14:	75 24                	jne    c0104e3a <check_boot_pgdir+0x9e>
c0104e16:	c7 44 24 0c bc 6d 10 	movl   $0xc0106dbc,0xc(%esp)
c0104e1d:	c0 
c0104e1e:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104e25:	c0 
c0104e26:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104e2d:	00 
c0104e2e:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104e35:	e8 a1 be ff ff       	call   c0100cdb <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104e3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e3d:	8b 00                	mov    (%eax),%eax
c0104e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e44:	89 c2                	mov    %eax,%edx
c0104e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e49:	39 c2                	cmp    %eax,%edx
c0104e4b:	74 24                	je     c0104e71 <check_boot_pgdir+0xd5>
c0104e4d:	c7 44 24 0c f9 6d 10 	movl   $0xc0106df9,0xc(%esp)
c0104e54:	c0 
c0104e55:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104e5c:	c0 
c0104e5d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104e64:	00 
c0104e65:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104e6c:	e8 6a be ff ff       	call   c0100cdb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0104e71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e7b:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104e80:	39 c2                	cmp    %eax,%edx
c0104e82:	0f 82 26 ff ff ff    	jb     c0104dae <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104e88:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104e8d:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104e92:	8b 00                	mov    (%eax),%eax
c0104e94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e99:	89 c2                	mov    %eax,%edx
c0104e9b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ea3:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104eaa:	77 23                	ja     c0104ecf <check_boot_pgdir+0x133>
c0104eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104eb3:	c7 44 24 08 88 6a 10 	movl   $0xc0106a88,0x8(%esp)
c0104eba:	c0 
c0104ebb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104ec2:	00 
c0104ec3:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104eca:	e8 0c be ff ff       	call   c0100cdb <__panic>
c0104ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ed2:	05 00 00 00 40       	add    $0x40000000,%eax
c0104ed7:	39 d0                	cmp    %edx,%eax
c0104ed9:	74 24                	je     c0104eff <check_boot_pgdir+0x163>
c0104edb:	c7 44 24 0c 10 6e 10 	movl   $0xc0106e10,0xc(%esp)
c0104ee2:	c0 
c0104ee3:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104eea:	c0 
c0104eeb:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104ef2:	00 
c0104ef3:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104efa:	e8 dc bd ff ff       	call   c0100cdb <__panic>

    assert(boot_pgdir[0] == 0);
c0104eff:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104f04:	8b 00                	mov    (%eax),%eax
c0104f06:	85 c0                	test   %eax,%eax
c0104f08:	74 24                	je     c0104f2e <check_boot_pgdir+0x192>
c0104f0a:	c7 44 24 0c 44 6e 10 	movl   $0xc0106e44,0xc(%esp)
c0104f11:	c0 
c0104f12:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104f19:	c0 
c0104f1a:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104f21:	00 
c0104f22:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104f29:	e8 ad bd ff ff       	call   c0100cdb <__panic>

    struct Page *p;
    p = alloc_page();
c0104f2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f35:	e8 49 ef ff ff       	call   c0103e83 <alloc_pages>
c0104f3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104f3d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104f42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104f49:	00 
c0104f4a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104f51:	00 
c0104f52:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f55:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f59:	89 04 24             	mov    %eax,(%esp)
c0104f5c:	e8 62 f6 ff ff       	call   c01045c3 <page_insert>
c0104f61:	85 c0                	test   %eax,%eax
c0104f63:	74 24                	je     c0104f89 <check_boot_pgdir+0x1ed>
c0104f65:	c7 44 24 0c 58 6e 10 	movl   $0xc0106e58,0xc(%esp)
c0104f6c:	c0 
c0104f6d:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104f74:	c0 
c0104f75:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104f7c:	00 
c0104f7d:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104f84:	e8 52 bd ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p) == 1);
c0104f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f8c:	89 04 24             	mov    %eax,(%esp)
c0104f8f:	e8 ed ec ff ff       	call   c0103c81 <page_ref>
c0104f94:	83 f8 01             	cmp    $0x1,%eax
c0104f97:	74 24                	je     c0104fbd <check_boot_pgdir+0x221>
c0104f99:	c7 44 24 0c 86 6e 10 	movl   $0xc0106e86,0xc(%esp)
c0104fa0:	c0 
c0104fa1:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104fa8:	c0 
c0104fa9:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104fb0:	00 
c0104fb1:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0104fb8:	e8 1e bd ff ff       	call   c0100cdb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104fbd:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104fc2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104fc9:	00 
c0104fca:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104fd1:	00 
c0104fd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104fd5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fd9:	89 04 24             	mov    %eax,(%esp)
c0104fdc:	e8 e2 f5 ff ff       	call   c01045c3 <page_insert>
c0104fe1:	85 c0                	test   %eax,%eax
c0104fe3:	74 24                	je     c0105009 <check_boot_pgdir+0x26d>
c0104fe5:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c0104fec:	c0 
c0104fed:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0104ff4:	c0 
c0104ff5:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104ffc:	00 
c0104ffd:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0105004:	e8 d2 bc ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p) == 2);
c0105009:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010500c:	89 04 24             	mov    %eax,(%esp)
c010500f:	e8 6d ec ff ff       	call   c0103c81 <page_ref>
c0105014:	83 f8 02             	cmp    $0x2,%eax
c0105017:	74 24                	je     c010503d <check_boot_pgdir+0x2a1>
c0105019:	c7 44 24 0c cf 6e 10 	movl   $0xc0106ecf,0xc(%esp)
c0105020:	c0 
c0105021:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c0105028:	c0 
c0105029:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0105030:	00 
c0105031:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c0105038:	e8 9e bc ff ff       	call   c0100cdb <__panic>

    const char *str = "ucore: Hello world!!";
c010503d:	c7 45 e8 e0 6e 10 c0 	movl   $0xc0106ee0,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105044:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105047:	89 44 24 04          	mov    %eax,0x4(%esp)
c010504b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105052:	e8 fc 09 00 00       	call   c0105a53 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105057:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010505e:	00 
c010505f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105066:	e8 60 0a 00 00       	call   c0105acb <strcmp>
c010506b:	85 c0                	test   %eax,%eax
c010506d:	74 24                	je     c0105093 <check_boot_pgdir+0x2f7>
c010506f:	c7 44 24 0c f8 6e 10 	movl   $0xc0106ef8,0xc(%esp)
c0105076:	c0 
c0105077:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c010507e:	c0 
c010507f:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0105086:	00 
c0105087:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c010508e:	e8 48 bc ff ff       	call   c0100cdb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105093:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105096:	89 04 24             	mov    %eax,(%esp)
c0105099:	e8 33 eb ff ff       	call   c0103bd1 <page2kva>
c010509e:	05 00 01 00 00       	add    $0x100,%eax
c01050a3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01050a6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01050ad:	e8 47 09 00 00       	call   c01059f9 <strlen>
c01050b2:	85 c0                	test   %eax,%eax
c01050b4:	74 24                	je     c01050da <check_boot_pgdir+0x33e>
c01050b6:	c7 44 24 0c 30 6f 10 	movl   $0xc0106f30,0xc(%esp)
c01050bd:	c0 
c01050be:	c7 44 24 08 d1 6a 10 	movl   $0xc0106ad1,0x8(%esp)
c01050c5:	c0 
c01050c6:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c01050cd:	00 
c01050ce:	c7 04 24 ac 6a 10 c0 	movl   $0xc0106aac,(%esp)
c01050d5:	e8 01 bc ff ff       	call   c0100cdb <__panic>

    free_page(p);
c01050da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050e1:	00 
c01050e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050e5:	89 04 24             	mov    %eax,(%esp)
c01050e8:	e8 d0 ed ff ff       	call   c0103ebd <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01050ed:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01050f2:	8b 00                	mov    (%eax),%eax
c01050f4:	89 04 24             	mov    %eax,(%esp)
c01050f7:	e8 6b eb ff ff       	call   c0103c67 <pde2page>
c01050fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105103:	00 
c0105104:	89 04 24             	mov    %eax,(%esp)
c0105107:	e8 b1 ed ff ff       	call   c0103ebd <free_pages>
    boot_pgdir[0] = 0;
c010510c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0105111:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105117:	c7 04 24 54 6f 10 c0 	movl   $0xc0106f54,(%esp)
c010511e:	e8 33 b2 ff ff       	call   c0100356 <cprintf>
}
c0105123:	90                   	nop
c0105124:	89 ec                	mov    %ebp,%esp
c0105126:	5d                   	pop    %ebp
c0105127:	c3                   	ret    

c0105128 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105128:	55                   	push   %ebp
c0105129:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010512b:	8b 45 08             	mov    0x8(%ebp),%eax
c010512e:	83 e0 04             	and    $0x4,%eax
c0105131:	85 c0                	test   %eax,%eax
c0105133:	74 04                	je     c0105139 <perm2str+0x11>
c0105135:	b0 75                	mov    $0x75,%al
c0105137:	eb 02                	jmp    c010513b <perm2str+0x13>
c0105139:	b0 2d                	mov    $0x2d,%al
c010513b:	a2 28 bf 11 c0       	mov    %al,0xc011bf28
    str[1] = 'r';
c0105140:	c6 05 29 bf 11 c0 72 	movb   $0x72,0xc011bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105147:	8b 45 08             	mov    0x8(%ebp),%eax
c010514a:	83 e0 02             	and    $0x2,%eax
c010514d:	85 c0                	test   %eax,%eax
c010514f:	74 04                	je     c0105155 <perm2str+0x2d>
c0105151:	b0 77                	mov    $0x77,%al
c0105153:	eb 02                	jmp    c0105157 <perm2str+0x2f>
c0105155:	b0 2d                	mov    $0x2d,%al
c0105157:	a2 2a bf 11 c0       	mov    %al,0xc011bf2a
    str[3] = '\0';
c010515c:	c6 05 2b bf 11 c0 00 	movb   $0x0,0xc011bf2b
    return str;
c0105163:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
}
c0105168:	5d                   	pop    %ebp
c0105169:	c3                   	ret    

c010516a <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010516a:	55                   	push   %ebp
c010516b:	89 e5                	mov    %esp,%ebp
c010516d:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105170:	8b 45 10             	mov    0x10(%ebp),%eax
c0105173:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105176:	72 0d                	jb     c0105185 <get_pgtable_items+0x1b>
        return 0;
c0105178:	b8 00 00 00 00       	mov    $0x0,%eax
c010517d:	e9 98 00 00 00       	jmp    c010521a <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0105182:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0105185:	8b 45 10             	mov    0x10(%ebp),%eax
c0105188:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010518b:	73 18                	jae    c01051a5 <get_pgtable_items+0x3b>
c010518d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105190:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105197:	8b 45 14             	mov    0x14(%ebp),%eax
c010519a:	01 d0                	add    %edx,%eax
c010519c:	8b 00                	mov    (%eax),%eax
c010519e:	83 e0 01             	and    $0x1,%eax
c01051a1:	85 c0                	test   %eax,%eax
c01051a3:	74 dd                	je     c0105182 <get_pgtable_items+0x18>
    }
    if (start < right) {
c01051a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01051a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01051ab:	73 68                	jae    c0105215 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01051ad:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01051b1:	74 08                	je     c01051bb <get_pgtable_items+0x51>
            *left_store = start;
c01051b3:	8b 45 18             	mov    0x18(%ebp),%eax
c01051b6:	8b 55 10             	mov    0x10(%ebp),%edx
c01051b9:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01051bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01051be:	8d 50 01             	lea    0x1(%eax),%edx
c01051c1:	89 55 10             	mov    %edx,0x10(%ebp)
c01051c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051cb:	8b 45 14             	mov    0x14(%ebp),%eax
c01051ce:	01 d0                	add    %edx,%eax
c01051d0:	8b 00                	mov    (%eax),%eax
c01051d2:	83 e0 07             	and    $0x7,%eax
c01051d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051d8:	eb 03                	jmp    c01051dd <get_pgtable_items+0x73>
            start ++;
c01051da:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01051e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01051e3:	73 1d                	jae    c0105202 <get_pgtable_items+0x98>
c01051e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01051e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051ef:	8b 45 14             	mov    0x14(%ebp),%eax
c01051f2:	01 d0                	add    %edx,%eax
c01051f4:	8b 00                	mov    (%eax),%eax
c01051f6:	83 e0 07             	and    $0x7,%eax
c01051f9:	89 c2                	mov    %eax,%edx
c01051fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051fe:	39 c2                	cmp    %eax,%edx
c0105200:	74 d8                	je     c01051da <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0105202:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105206:	74 08                	je     c0105210 <get_pgtable_items+0xa6>
            *right_store = start;
c0105208:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010520b:	8b 55 10             	mov    0x10(%ebp),%edx
c010520e:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105210:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105213:	eb 05                	jmp    c010521a <get_pgtable_items+0xb0>
    }
    return 0;
c0105215:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010521a:	89 ec                	mov    %ebp,%esp
c010521c:	5d                   	pop    %ebp
c010521d:	c3                   	ret    

c010521e <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010521e:	55                   	push   %ebp
c010521f:	89 e5                	mov    %esp,%ebp
c0105221:	57                   	push   %edi
c0105222:	56                   	push   %esi
c0105223:	53                   	push   %ebx
c0105224:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105227:	c7 04 24 74 6f 10 c0 	movl   $0xc0106f74,(%esp)
c010522e:	e8 23 b1 ff ff       	call   c0100356 <cprintf>
    size_t left, right = 0, perm;
c0105233:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010523a:	e9 f2 00 00 00       	jmp    c0105331 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010523f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105242:	89 04 24             	mov    %eax,(%esp)
c0105245:	e8 de fe ff ff       	call   c0105128 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010524a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010524d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105250:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105252:	89 d6                	mov    %edx,%esi
c0105254:	c1 e6 16             	shl    $0x16,%esi
c0105257:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010525a:	89 d3                	mov    %edx,%ebx
c010525c:	c1 e3 16             	shl    $0x16,%ebx
c010525f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105262:	89 d1                	mov    %edx,%ecx
c0105264:	c1 e1 16             	shl    $0x16,%ecx
c0105267:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010526a:	8b 7d e0             	mov    -0x20(%ebp),%edi
c010526d:	29 fa                	sub    %edi,%edx
c010526f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105273:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105277:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010527b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010527f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105283:	c7 04 24 a5 6f 10 c0 	movl   $0xc0106fa5,(%esp)
c010528a:	e8 c7 b0 ff ff       	call   c0100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010528f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105292:	c1 e0 0a             	shl    $0xa,%eax
c0105295:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105298:	eb 50                	jmp    c01052ea <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010529a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010529d:	89 04 24             	mov    %eax,(%esp)
c01052a0:	e8 83 fe ff ff       	call   c0105128 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01052a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052a8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01052ab:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01052ad:	89 d6                	mov    %edx,%esi
c01052af:	c1 e6 0c             	shl    $0xc,%esi
c01052b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052b5:	89 d3                	mov    %edx,%ebx
c01052b7:	c1 e3 0c             	shl    $0xc,%ebx
c01052ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01052bd:	89 d1                	mov    %edx,%ecx
c01052bf:	c1 e1 0c             	shl    $0xc,%ecx
c01052c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052c5:	8b 7d d8             	mov    -0x28(%ebp),%edi
c01052c8:	29 fa                	sub    %edi,%edx
c01052ca:	89 44 24 14          	mov    %eax,0x14(%esp)
c01052ce:	89 74 24 10          	mov    %esi,0x10(%esp)
c01052d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01052d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01052da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052de:	c7 04 24 c4 6f 10 c0 	movl   $0xc0106fc4,(%esp)
c01052e5:	e8 6c b0 ff ff       	call   c0100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01052ea:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01052ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052f5:	89 d3                	mov    %edx,%ebx
c01052f7:	c1 e3 0a             	shl    $0xa,%ebx
c01052fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01052fd:	89 d1                	mov    %edx,%ecx
c01052ff:	c1 e1 0a             	shl    $0xa,%ecx
c0105302:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0105305:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105309:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010530c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105310:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105314:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105318:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010531c:	89 0c 24             	mov    %ecx,(%esp)
c010531f:	e8 46 fe ff ff       	call   c010516a <get_pgtable_items>
c0105324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010532b:	0f 85 69 ff ff ff    	jne    c010529a <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105331:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105336:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105339:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010533c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105340:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0105343:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105347:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010534b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010534f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105356:	00 
c0105357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010535e:	e8 07 fe ff ff       	call   c010516a <get_pgtable_items>
c0105363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105366:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010536a:	0f 85 cf fe ff ff    	jne    c010523f <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105370:	c7 04 24 e8 6f 10 c0 	movl   $0xc0106fe8,(%esp)
c0105377:	e8 da af ff ff       	call   c0100356 <cprintf>
}
c010537c:	90                   	nop
c010537d:	83 c4 4c             	add    $0x4c,%esp
c0105380:	5b                   	pop    %ebx
c0105381:	5e                   	pop    %esi
c0105382:	5f                   	pop    %edi
c0105383:	5d                   	pop    %ebp
c0105384:	c3                   	ret    

c0105385 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105385:	55                   	push   %ebp
c0105386:	89 e5                	mov    %esp,%ebp
c0105388:	83 ec 58             	sub    $0x58,%esp
c010538b:	8b 45 10             	mov    0x10(%ebp),%eax
c010538e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105391:	8b 45 14             	mov    0x14(%ebp),%eax
c0105394:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105397:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010539a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010539d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053a0:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01053a3:	8b 45 18             	mov    0x18(%ebp),%eax
c01053a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01053a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01053af:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053b2:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01053b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01053bf:	74 1c                	je     c01053dd <printnum+0x58>
c01053c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053c4:	ba 00 00 00 00       	mov    $0x0,%edx
c01053c9:	f7 75 e4             	divl   -0x1c(%ebp)
c01053cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01053cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d2:	ba 00 00 00 00       	mov    $0x0,%edx
c01053d7:	f7 75 e4             	divl   -0x1c(%ebp)
c01053da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053e3:	f7 75 e4             	divl   -0x1c(%ebp)
c01053e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01053ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01053f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053fb:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01053fe:	8b 45 18             	mov    0x18(%ebp),%eax
c0105401:	ba 00 00 00 00       	mov    $0x0,%edx
c0105406:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105409:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010540c:	19 d1                	sbb    %edx,%ecx
c010540e:	72 4c                	jb     c010545c <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105410:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105413:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105416:	8b 45 20             	mov    0x20(%ebp),%eax
c0105419:	89 44 24 18          	mov    %eax,0x18(%esp)
c010541d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105421:	8b 45 18             	mov    0x18(%ebp),%eax
c0105424:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105428:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010542b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010542e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105432:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105436:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105439:	89 44 24 04          	mov    %eax,0x4(%esp)
c010543d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105440:	89 04 24             	mov    %eax,(%esp)
c0105443:	e8 3d ff ff ff       	call   c0105385 <printnum>
c0105448:	eb 1b                	jmp    c0105465 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010544a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010544d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105451:	8b 45 20             	mov    0x20(%ebp),%eax
c0105454:	89 04 24             	mov    %eax,(%esp)
c0105457:	8b 45 08             	mov    0x8(%ebp),%eax
c010545a:	ff d0                	call   *%eax
        while (-- width > 0)
c010545c:	ff 4d 1c             	decl   0x1c(%ebp)
c010545f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105463:	7f e5                	jg     c010544a <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105465:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105468:	05 9c 70 10 c0       	add    $0xc010709c,%eax
c010546d:	0f b6 00             	movzbl (%eax),%eax
c0105470:	0f be c0             	movsbl %al,%eax
c0105473:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105476:	89 54 24 04          	mov    %edx,0x4(%esp)
c010547a:	89 04 24             	mov    %eax,(%esp)
c010547d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105480:	ff d0                	call   *%eax
}
c0105482:	90                   	nop
c0105483:	89 ec                	mov    %ebp,%esp
c0105485:	5d                   	pop    %ebp
c0105486:	c3                   	ret    

c0105487 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105487:	55                   	push   %ebp
c0105488:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010548a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010548e:	7e 14                	jle    c01054a4 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105490:	8b 45 08             	mov    0x8(%ebp),%eax
c0105493:	8b 00                	mov    (%eax),%eax
c0105495:	8d 48 08             	lea    0x8(%eax),%ecx
c0105498:	8b 55 08             	mov    0x8(%ebp),%edx
c010549b:	89 0a                	mov    %ecx,(%edx)
c010549d:	8b 50 04             	mov    0x4(%eax),%edx
c01054a0:	8b 00                	mov    (%eax),%eax
c01054a2:	eb 30                	jmp    c01054d4 <getuint+0x4d>
    }
    else if (lflag) {
c01054a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054a8:	74 16                	je     c01054c0 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01054aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ad:	8b 00                	mov    (%eax),%eax
c01054af:	8d 48 04             	lea    0x4(%eax),%ecx
c01054b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01054b5:	89 0a                	mov    %ecx,(%edx)
c01054b7:	8b 00                	mov    (%eax),%eax
c01054b9:	ba 00 00 00 00       	mov    $0x0,%edx
c01054be:	eb 14                	jmp    c01054d4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01054c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c3:	8b 00                	mov    (%eax),%eax
c01054c5:	8d 48 04             	lea    0x4(%eax),%ecx
c01054c8:	8b 55 08             	mov    0x8(%ebp),%edx
c01054cb:	89 0a                	mov    %ecx,(%edx)
c01054cd:	8b 00                	mov    (%eax),%eax
c01054cf:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01054d4:	5d                   	pop    %ebp
c01054d5:	c3                   	ret    

c01054d6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01054d6:	55                   	push   %ebp
c01054d7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01054d9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01054dd:	7e 14                	jle    c01054f3 <getint+0x1d>
        return va_arg(*ap, long long);
c01054df:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e2:	8b 00                	mov    (%eax),%eax
c01054e4:	8d 48 08             	lea    0x8(%eax),%ecx
c01054e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01054ea:	89 0a                	mov    %ecx,(%edx)
c01054ec:	8b 50 04             	mov    0x4(%eax),%edx
c01054ef:	8b 00                	mov    (%eax),%eax
c01054f1:	eb 28                	jmp    c010551b <getint+0x45>
    }
    else if (lflag) {
c01054f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054f7:	74 12                	je     c010550b <getint+0x35>
        return va_arg(*ap, long);
c01054f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01054fc:	8b 00                	mov    (%eax),%eax
c01054fe:	8d 48 04             	lea    0x4(%eax),%ecx
c0105501:	8b 55 08             	mov    0x8(%ebp),%edx
c0105504:	89 0a                	mov    %ecx,(%edx)
c0105506:	8b 00                	mov    (%eax),%eax
c0105508:	99                   	cltd   
c0105509:	eb 10                	jmp    c010551b <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010550b:	8b 45 08             	mov    0x8(%ebp),%eax
c010550e:	8b 00                	mov    (%eax),%eax
c0105510:	8d 48 04             	lea    0x4(%eax),%ecx
c0105513:	8b 55 08             	mov    0x8(%ebp),%edx
c0105516:	89 0a                	mov    %ecx,(%edx)
c0105518:	8b 00                	mov    (%eax),%eax
c010551a:	99                   	cltd   
    }
}
c010551b:	5d                   	pop    %ebp
c010551c:	c3                   	ret    

c010551d <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010551d:	55                   	push   %ebp
c010551e:	89 e5                	mov    %esp,%ebp
c0105520:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105523:	8d 45 14             	lea    0x14(%ebp),%eax
c0105526:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105529:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010552c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105530:	8b 45 10             	mov    0x10(%ebp),%eax
c0105533:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105537:	8b 45 0c             	mov    0xc(%ebp),%eax
c010553a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010553e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105541:	89 04 24             	mov    %eax,(%esp)
c0105544:	e8 05 00 00 00       	call   c010554e <vprintfmt>
    va_end(ap);
}
c0105549:	90                   	nop
c010554a:	89 ec                	mov    %ebp,%esp
c010554c:	5d                   	pop    %ebp
c010554d:	c3                   	ret    

c010554e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010554e:	55                   	push   %ebp
c010554f:	89 e5                	mov    %esp,%ebp
c0105551:	56                   	push   %esi
c0105552:	53                   	push   %ebx
c0105553:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105556:	eb 17                	jmp    c010556f <vprintfmt+0x21>
            if (ch == '\0') {
c0105558:	85 db                	test   %ebx,%ebx
c010555a:	0f 84 bf 03 00 00    	je     c010591f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105563:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105567:	89 1c 24             	mov    %ebx,(%esp)
c010556a:	8b 45 08             	mov    0x8(%ebp),%eax
c010556d:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010556f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105572:	8d 50 01             	lea    0x1(%eax),%edx
c0105575:	89 55 10             	mov    %edx,0x10(%ebp)
c0105578:	0f b6 00             	movzbl (%eax),%eax
c010557b:	0f b6 d8             	movzbl %al,%ebx
c010557e:	83 fb 25             	cmp    $0x25,%ebx
c0105581:	75 d5                	jne    c0105558 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105583:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105587:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010558e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105591:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105594:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010559b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010559e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01055a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01055a4:	8d 50 01             	lea    0x1(%eax),%edx
c01055a7:	89 55 10             	mov    %edx,0x10(%ebp)
c01055aa:	0f b6 00             	movzbl (%eax),%eax
c01055ad:	0f b6 d8             	movzbl %al,%ebx
c01055b0:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01055b3:	83 f8 55             	cmp    $0x55,%eax
c01055b6:	0f 87 37 03 00 00    	ja     c01058f3 <vprintfmt+0x3a5>
c01055bc:	8b 04 85 c0 70 10 c0 	mov    -0x3fef8f40(,%eax,4),%eax
c01055c3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01055c5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01055c9:	eb d6                	jmp    c01055a1 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01055cb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01055cf:	eb d0                	jmp    c01055a1 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01055d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01055db:	89 d0                	mov    %edx,%eax
c01055dd:	c1 e0 02             	shl    $0x2,%eax
c01055e0:	01 d0                	add    %edx,%eax
c01055e2:	01 c0                	add    %eax,%eax
c01055e4:	01 d8                	add    %ebx,%eax
c01055e6:	83 e8 30             	sub    $0x30,%eax
c01055e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01055ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01055ef:	0f b6 00             	movzbl (%eax),%eax
c01055f2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01055f5:	83 fb 2f             	cmp    $0x2f,%ebx
c01055f8:	7e 38                	jle    c0105632 <vprintfmt+0xe4>
c01055fa:	83 fb 39             	cmp    $0x39,%ebx
c01055fd:	7f 33                	jg     c0105632 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01055ff:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105602:	eb d4                	jmp    c01055d8 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105604:	8b 45 14             	mov    0x14(%ebp),%eax
c0105607:	8d 50 04             	lea    0x4(%eax),%edx
c010560a:	89 55 14             	mov    %edx,0x14(%ebp)
c010560d:	8b 00                	mov    (%eax),%eax
c010560f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105612:	eb 1f                	jmp    c0105633 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105614:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105618:	79 87                	jns    c01055a1 <vprintfmt+0x53>
                width = 0;
c010561a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105621:	e9 7b ff ff ff       	jmp    c01055a1 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105626:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010562d:	e9 6f ff ff ff       	jmp    c01055a1 <vprintfmt+0x53>
            goto process_precision;
c0105632:	90                   	nop

        process_precision:
            if (width < 0)
c0105633:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105637:	0f 89 64 ff ff ff    	jns    c01055a1 <vprintfmt+0x53>
                width = precision, precision = -1;
c010563d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105640:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105643:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010564a:	e9 52 ff ff ff       	jmp    c01055a1 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010564f:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105652:	e9 4a ff ff ff       	jmp    c01055a1 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105657:	8b 45 14             	mov    0x14(%ebp),%eax
c010565a:	8d 50 04             	lea    0x4(%eax),%edx
c010565d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105660:	8b 00                	mov    (%eax),%eax
c0105662:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105665:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105669:	89 04 24             	mov    %eax,(%esp)
c010566c:	8b 45 08             	mov    0x8(%ebp),%eax
c010566f:	ff d0                	call   *%eax
            break;
c0105671:	e9 a4 02 00 00       	jmp    c010591a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105676:	8b 45 14             	mov    0x14(%ebp),%eax
c0105679:	8d 50 04             	lea    0x4(%eax),%edx
c010567c:	89 55 14             	mov    %edx,0x14(%ebp)
c010567f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105681:	85 db                	test   %ebx,%ebx
c0105683:	79 02                	jns    c0105687 <vprintfmt+0x139>
                err = -err;
c0105685:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105687:	83 fb 06             	cmp    $0x6,%ebx
c010568a:	7f 0b                	jg     c0105697 <vprintfmt+0x149>
c010568c:	8b 34 9d 80 70 10 c0 	mov    -0x3fef8f80(,%ebx,4),%esi
c0105693:	85 f6                	test   %esi,%esi
c0105695:	75 23                	jne    c01056ba <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105697:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010569b:	c7 44 24 08 ad 70 10 	movl   $0xc01070ad,0x8(%esp)
c01056a2:	c0 
c01056a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01056ad:	89 04 24             	mov    %eax,(%esp)
c01056b0:	e8 68 fe ff ff       	call   c010551d <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01056b5:	e9 60 02 00 00       	jmp    c010591a <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01056ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01056be:	c7 44 24 08 b6 70 10 	movl   $0xc01070b6,0x8(%esp)
c01056c5:	c0 
c01056c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 45 fe ff ff       	call   c010551d <printfmt>
            break;
c01056d8:	e9 3d 02 00 00       	jmp    c010591a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01056dd:	8b 45 14             	mov    0x14(%ebp),%eax
c01056e0:	8d 50 04             	lea    0x4(%eax),%edx
c01056e3:	89 55 14             	mov    %edx,0x14(%ebp)
c01056e6:	8b 30                	mov    (%eax),%esi
c01056e8:	85 f6                	test   %esi,%esi
c01056ea:	75 05                	jne    c01056f1 <vprintfmt+0x1a3>
                p = "(null)";
c01056ec:	be b9 70 10 c0       	mov    $0xc01070b9,%esi
            }
            if (width > 0 && padc != '-') {
c01056f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f5:	7e 76                	jle    c010576d <vprintfmt+0x21f>
c01056f7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01056fb:	74 70                	je     c010576d <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01056fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105700:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105704:	89 34 24             	mov    %esi,(%esp)
c0105707:	e8 16 03 00 00       	call   c0105a22 <strnlen>
c010570c:	89 c2                	mov    %eax,%edx
c010570e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105711:	29 d0                	sub    %edx,%eax
c0105713:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105716:	eb 16                	jmp    c010572e <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105718:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010571c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010571f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105723:	89 04 24             	mov    %eax,(%esp)
c0105726:	8b 45 08             	mov    0x8(%ebp),%eax
c0105729:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010572b:	ff 4d e8             	decl   -0x18(%ebp)
c010572e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105732:	7f e4                	jg     c0105718 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105734:	eb 37                	jmp    c010576d <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105736:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010573a:	74 1f                	je     c010575b <vprintfmt+0x20d>
c010573c:	83 fb 1f             	cmp    $0x1f,%ebx
c010573f:	7e 05                	jle    c0105746 <vprintfmt+0x1f8>
c0105741:	83 fb 7e             	cmp    $0x7e,%ebx
c0105744:	7e 15                	jle    c010575b <vprintfmt+0x20d>
                    putch('?', putdat);
c0105746:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105749:	89 44 24 04          	mov    %eax,0x4(%esp)
c010574d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105754:	8b 45 08             	mov    0x8(%ebp),%eax
c0105757:	ff d0                	call   *%eax
c0105759:	eb 0f                	jmp    c010576a <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010575b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010575e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105762:	89 1c 24             	mov    %ebx,(%esp)
c0105765:	8b 45 08             	mov    0x8(%ebp),%eax
c0105768:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010576a:	ff 4d e8             	decl   -0x18(%ebp)
c010576d:	89 f0                	mov    %esi,%eax
c010576f:	8d 70 01             	lea    0x1(%eax),%esi
c0105772:	0f b6 00             	movzbl (%eax),%eax
c0105775:	0f be d8             	movsbl %al,%ebx
c0105778:	85 db                	test   %ebx,%ebx
c010577a:	74 27                	je     c01057a3 <vprintfmt+0x255>
c010577c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105780:	78 b4                	js     c0105736 <vprintfmt+0x1e8>
c0105782:	ff 4d e4             	decl   -0x1c(%ebp)
c0105785:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105789:	79 ab                	jns    c0105736 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010578b:	eb 16                	jmp    c01057a3 <vprintfmt+0x255>
                putch(' ', putdat);
c010578d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105790:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105794:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010579b:	8b 45 08             	mov    0x8(%ebp),%eax
c010579e:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c01057a0:	ff 4d e8             	decl   -0x18(%ebp)
c01057a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057a7:	7f e4                	jg     c010578d <vprintfmt+0x23f>
            }
            break;
c01057a9:	e9 6c 01 00 00       	jmp    c010591a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01057ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057b5:	8d 45 14             	lea    0x14(%ebp),%eax
c01057b8:	89 04 24             	mov    %eax,(%esp)
c01057bb:	e8 16 fd ff ff       	call   c01054d6 <getint>
c01057c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01057c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057cc:	85 d2                	test   %edx,%edx
c01057ce:	79 26                	jns    c01057f6 <vprintfmt+0x2a8>
                putch('-', putdat);
c01057d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01057de:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e1:	ff d0                	call   *%eax
                num = -(long long)num;
c01057e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057e9:	f7 d8                	neg    %eax
c01057eb:	83 d2 00             	adc    $0x0,%edx
c01057ee:	f7 da                	neg    %edx
c01057f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01057f6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01057fd:	e9 a8 00 00 00       	jmp    c01058aa <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105802:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105805:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105809:	8d 45 14             	lea    0x14(%ebp),%eax
c010580c:	89 04 24             	mov    %eax,(%esp)
c010580f:	e8 73 fc ff ff       	call   c0105487 <getuint>
c0105814:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105817:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010581a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105821:	e9 84 00 00 00       	jmp    c01058aa <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105826:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105829:	89 44 24 04          	mov    %eax,0x4(%esp)
c010582d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105830:	89 04 24             	mov    %eax,(%esp)
c0105833:	e8 4f fc ff ff       	call   c0105487 <getuint>
c0105838:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010583b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010583e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105845:	eb 63                	jmp    c01058aa <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105847:	8b 45 0c             	mov    0xc(%ebp),%eax
c010584a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010584e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105855:	8b 45 08             	mov    0x8(%ebp),%eax
c0105858:	ff d0                	call   *%eax
            putch('x', putdat);
c010585a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010585d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105861:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105868:	8b 45 08             	mov    0x8(%ebp),%eax
c010586b:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010586d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105870:	8d 50 04             	lea    0x4(%eax),%edx
c0105873:	89 55 14             	mov    %edx,0x14(%ebp)
c0105876:	8b 00                	mov    (%eax),%eax
c0105878:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010587b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105882:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105889:	eb 1f                	jmp    c01058aa <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010588b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010588e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105892:	8d 45 14             	lea    0x14(%ebp),%eax
c0105895:	89 04 24             	mov    %eax,(%esp)
c0105898:	e8 ea fb ff ff       	call   c0105487 <getuint>
c010589d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01058a3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01058aa:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01058ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058b1:	89 54 24 18          	mov    %edx,0x18(%esp)
c01058b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01058b8:	89 54 24 14          	mov    %edx,0x14(%esp)
c01058bc:	89 44 24 10          	mov    %eax,0x10(%esp)
c01058c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058d8:	89 04 24             	mov    %eax,(%esp)
c01058db:	e8 a5 fa ff ff       	call   c0105385 <printnum>
            break;
c01058e0:	eb 38                	jmp    c010591a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01058e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e9:	89 1c 24             	mov    %ebx,(%esp)
c01058ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ef:	ff d0                	call   *%eax
            break;
c01058f1:	eb 27                	jmp    c010591a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01058f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105901:	8b 45 08             	mov    0x8(%ebp),%eax
c0105904:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105906:	ff 4d 10             	decl   0x10(%ebp)
c0105909:	eb 03                	jmp    c010590e <vprintfmt+0x3c0>
c010590b:	ff 4d 10             	decl   0x10(%ebp)
c010590e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105911:	48                   	dec    %eax
c0105912:	0f b6 00             	movzbl (%eax),%eax
c0105915:	3c 25                	cmp    $0x25,%al
c0105917:	75 f2                	jne    c010590b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105919:	90                   	nop
    while (1) {
c010591a:	e9 37 fc ff ff       	jmp    c0105556 <vprintfmt+0x8>
                return;
c010591f:	90                   	nop
        }
    }
}
c0105920:	83 c4 40             	add    $0x40,%esp
c0105923:	5b                   	pop    %ebx
c0105924:	5e                   	pop    %esi
c0105925:	5d                   	pop    %ebp
c0105926:	c3                   	ret    

c0105927 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105927:	55                   	push   %ebp
c0105928:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010592a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592d:	8b 40 08             	mov    0x8(%eax),%eax
c0105930:	8d 50 01             	lea    0x1(%eax),%edx
c0105933:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105936:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010593c:	8b 10                	mov    (%eax),%edx
c010593e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105941:	8b 40 04             	mov    0x4(%eax),%eax
c0105944:	39 c2                	cmp    %eax,%edx
c0105946:	73 12                	jae    c010595a <sprintputch+0x33>
        *b->buf ++ = ch;
c0105948:	8b 45 0c             	mov    0xc(%ebp),%eax
c010594b:	8b 00                	mov    (%eax),%eax
c010594d:	8d 48 01             	lea    0x1(%eax),%ecx
c0105950:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105953:	89 0a                	mov    %ecx,(%edx)
c0105955:	8b 55 08             	mov    0x8(%ebp),%edx
c0105958:	88 10                	mov    %dl,(%eax)
    }
}
c010595a:	90                   	nop
c010595b:	5d                   	pop    %ebp
c010595c:	c3                   	ret    

c010595d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010595d:	55                   	push   %ebp
c010595e:	89 e5                	mov    %esp,%ebp
c0105960:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105963:	8d 45 14             	lea    0x14(%ebp),%eax
c0105966:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010596c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105970:	8b 45 10             	mov    0x10(%ebp),%eax
c0105973:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105977:	8b 45 0c             	mov    0xc(%ebp),%eax
c010597a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010597e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105981:	89 04 24             	mov    %eax,(%esp)
c0105984:	e8 0a 00 00 00       	call   c0105993 <vsnprintf>
c0105989:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010598f:	89 ec                	mov    %ebp,%esp
c0105991:	5d                   	pop    %ebp
c0105992:	c3                   	ret    

c0105993 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105993:	55                   	push   %ebp
c0105994:	89 e5                	mov    %esp,%ebp
c0105996:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105999:	8b 45 08             	mov    0x8(%ebp),%eax
c010599c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010599f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059a2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01059a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a8:	01 d0                	add    %edx,%eax
c01059aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01059b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01059b8:	74 0a                	je     c01059c4 <vsnprintf+0x31>
c01059ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059c0:	39 c2                	cmp    %eax,%edx
c01059c2:	76 07                	jbe    c01059cb <vsnprintf+0x38>
        return -E_INVAL;
c01059c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01059c9:	eb 2a                	jmp    c01059f5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01059cb:	8b 45 14             	mov    0x14(%ebp),%eax
c01059ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01059d5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01059dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059e0:	c7 04 24 27 59 10 c0 	movl   $0xc0105927,(%esp)
c01059e7:	e8 62 fb ff ff       	call   c010554e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01059ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059ef:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01059f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01059f5:	89 ec                	mov    %ebp,%esp
c01059f7:	5d                   	pop    %ebp
c01059f8:	c3                   	ret    

c01059f9 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01059f9:	55                   	push   %ebp
c01059fa:	89 e5                	mov    %esp,%ebp
c01059fc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01059ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105a06:	eb 03                	jmp    c0105a0b <strlen+0x12>
        cnt ++;
c0105a08:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a0e:	8d 50 01             	lea    0x1(%eax),%edx
c0105a11:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a14:	0f b6 00             	movzbl (%eax),%eax
c0105a17:	84 c0                	test   %al,%al
c0105a19:	75 ed                	jne    c0105a08 <strlen+0xf>
    }
    return cnt;
c0105a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a1e:	89 ec                	mov    %ebp,%esp
c0105a20:	5d                   	pop    %ebp
c0105a21:	c3                   	ret    

c0105a22 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105a22:	55                   	push   %ebp
c0105a23:	89 e5                	mov    %esp,%ebp
c0105a25:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105a28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105a2f:	eb 03                	jmp    c0105a34 <strnlen+0x12>
        cnt ++;
c0105a31:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a37:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105a3a:	73 10                	jae    c0105a4c <strnlen+0x2a>
c0105a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a3f:	8d 50 01             	lea    0x1(%eax),%edx
c0105a42:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a45:	0f b6 00             	movzbl (%eax),%eax
c0105a48:	84 c0                	test   %al,%al
c0105a4a:	75 e5                	jne    c0105a31 <strnlen+0xf>
    }
    return cnt;
c0105a4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a4f:	89 ec                	mov    %ebp,%esp
c0105a51:	5d                   	pop    %ebp
c0105a52:	c3                   	ret    

c0105a53 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105a53:	55                   	push   %ebp
c0105a54:	89 e5                	mov    %esp,%ebp
c0105a56:	57                   	push   %edi
c0105a57:	56                   	push   %esi
c0105a58:	83 ec 20             	sub    $0x20,%esp
c0105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105a67:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a6d:	89 d1                	mov    %edx,%ecx
c0105a6f:	89 c2                	mov    %eax,%edx
c0105a71:	89 ce                	mov    %ecx,%esi
c0105a73:	89 d7                	mov    %edx,%edi
c0105a75:	ac                   	lods   %ds:(%esi),%al
c0105a76:	aa                   	stos   %al,%es:(%edi)
c0105a77:	84 c0                	test   %al,%al
c0105a79:	75 fa                	jne    c0105a75 <strcpy+0x22>
c0105a7b:	89 fa                	mov    %edi,%edx
c0105a7d:	89 f1                	mov    %esi,%ecx
c0105a7f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105a82:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105a8b:	83 c4 20             	add    $0x20,%esp
c0105a8e:	5e                   	pop    %esi
c0105a8f:	5f                   	pop    %edi
c0105a90:	5d                   	pop    %ebp
c0105a91:	c3                   	ret    

c0105a92 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105a92:	55                   	push   %ebp
c0105a93:	89 e5                	mov    %esp,%ebp
c0105a95:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105a9e:	eb 1e                	jmp    c0105abe <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa3:	0f b6 10             	movzbl (%eax),%edx
c0105aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105aa9:	88 10                	mov    %dl,(%eax)
c0105aab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105aae:	0f b6 00             	movzbl (%eax),%eax
c0105ab1:	84 c0                	test   %al,%al
c0105ab3:	74 03                	je     c0105ab8 <strncpy+0x26>
            src ++;
c0105ab5:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105ab8:	ff 45 fc             	incl   -0x4(%ebp)
c0105abb:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0105abe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ac2:	75 dc                	jne    c0105aa0 <strncpy+0xe>
    }
    return dst;
c0105ac4:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ac7:	89 ec                	mov    %ebp,%esp
c0105ac9:	5d                   	pop    %ebp
c0105aca:	c3                   	ret    

c0105acb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105acb:	55                   	push   %ebp
c0105acc:	89 e5                	mov    %esp,%ebp
c0105ace:	57                   	push   %edi
c0105acf:	56                   	push   %esi
c0105ad0:	83 ec 20             	sub    $0x20,%esp
c0105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ae5:	89 d1                	mov    %edx,%ecx
c0105ae7:	89 c2                	mov    %eax,%edx
c0105ae9:	89 ce                	mov    %ecx,%esi
c0105aeb:	89 d7                	mov    %edx,%edi
c0105aed:	ac                   	lods   %ds:(%esi),%al
c0105aee:	ae                   	scas   %es:(%edi),%al
c0105aef:	75 08                	jne    c0105af9 <strcmp+0x2e>
c0105af1:	84 c0                	test   %al,%al
c0105af3:	75 f8                	jne    c0105aed <strcmp+0x22>
c0105af5:	31 c0                	xor    %eax,%eax
c0105af7:	eb 04                	jmp    c0105afd <strcmp+0x32>
c0105af9:	19 c0                	sbb    %eax,%eax
c0105afb:	0c 01                	or     $0x1,%al
c0105afd:	89 fa                	mov    %edi,%edx
c0105aff:	89 f1                	mov    %esi,%ecx
c0105b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b04:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105b07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105b0d:	83 c4 20             	add    $0x20,%esp
c0105b10:	5e                   	pop    %esi
c0105b11:	5f                   	pop    %edi
c0105b12:	5d                   	pop    %ebp
c0105b13:	c3                   	ret    

c0105b14 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105b14:	55                   	push   %ebp
c0105b15:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105b17:	eb 09                	jmp    c0105b22 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105b19:	ff 4d 10             	decl   0x10(%ebp)
c0105b1c:	ff 45 08             	incl   0x8(%ebp)
c0105b1f:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105b22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b26:	74 1a                	je     c0105b42 <strncmp+0x2e>
c0105b28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b2b:	0f b6 00             	movzbl (%eax),%eax
c0105b2e:	84 c0                	test   %al,%al
c0105b30:	74 10                	je     c0105b42 <strncmp+0x2e>
c0105b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b35:	0f b6 10             	movzbl (%eax),%edx
c0105b38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b3b:	0f b6 00             	movzbl (%eax),%eax
c0105b3e:	38 c2                	cmp    %al,%dl
c0105b40:	74 d7                	je     c0105b19 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105b42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b46:	74 18                	je     c0105b60 <strncmp+0x4c>
c0105b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4b:	0f b6 00             	movzbl (%eax),%eax
c0105b4e:	0f b6 d0             	movzbl %al,%edx
c0105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b54:	0f b6 00             	movzbl (%eax),%eax
c0105b57:	0f b6 c8             	movzbl %al,%ecx
c0105b5a:	89 d0                	mov    %edx,%eax
c0105b5c:	29 c8                	sub    %ecx,%eax
c0105b5e:	eb 05                	jmp    c0105b65 <strncmp+0x51>
c0105b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b65:	5d                   	pop    %ebp
c0105b66:	c3                   	ret    

c0105b67 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105b67:	55                   	push   %ebp
c0105b68:	89 e5                	mov    %esp,%ebp
c0105b6a:	83 ec 04             	sub    $0x4,%esp
c0105b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b70:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b73:	eb 13                	jmp    c0105b88 <strchr+0x21>
        if (*s == c) {
c0105b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b78:	0f b6 00             	movzbl (%eax),%eax
c0105b7b:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105b7e:	75 05                	jne    c0105b85 <strchr+0x1e>
            return (char *)s;
c0105b80:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b83:	eb 12                	jmp    c0105b97 <strchr+0x30>
        }
        s ++;
c0105b85:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105b88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8b:	0f b6 00             	movzbl (%eax),%eax
c0105b8e:	84 c0                	test   %al,%al
c0105b90:	75 e3                	jne    c0105b75 <strchr+0xe>
    }
    return NULL;
c0105b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b97:	89 ec                	mov    %ebp,%esp
c0105b99:	5d                   	pop    %ebp
c0105b9a:	c3                   	ret    

c0105b9b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105b9b:	55                   	push   %ebp
c0105b9c:	89 e5                	mov    %esp,%ebp
c0105b9e:	83 ec 04             	sub    $0x4,%esp
c0105ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ba4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ba7:	eb 0e                	jmp    c0105bb7 <strfind+0x1c>
        if (*s == c) {
c0105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bac:	0f b6 00             	movzbl (%eax),%eax
c0105baf:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105bb2:	74 0f                	je     c0105bc3 <strfind+0x28>
            break;
        }
        s ++;
c0105bb4:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105bb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bba:	0f b6 00             	movzbl (%eax),%eax
c0105bbd:	84 c0                	test   %al,%al
c0105bbf:	75 e8                	jne    c0105ba9 <strfind+0xe>
c0105bc1:	eb 01                	jmp    c0105bc4 <strfind+0x29>
            break;
c0105bc3:	90                   	nop
    }
    return (char *)s;
c0105bc4:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105bc7:	89 ec                	mov    %ebp,%esp
c0105bc9:	5d                   	pop    %ebp
c0105bca:	c3                   	ret    

c0105bcb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105bcb:	55                   	push   %ebp
c0105bcc:	89 e5                	mov    %esp,%ebp
c0105bce:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105bd8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105bdf:	eb 03                	jmp    c0105be4 <strtol+0x19>
        s ++;
c0105be1:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be7:	0f b6 00             	movzbl (%eax),%eax
c0105bea:	3c 20                	cmp    $0x20,%al
c0105bec:	74 f3                	je     c0105be1 <strtol+0x16>
c0105bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf1:	0f b6 00             	movzbl (%eax),%eax
c0105bf4:	3c 09                	cmp    $0x9,%al
c0105bf6:	74 e9                	je     c0105be1 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfb:	0f b6 00             	movzbl (%eax),%eax
c0105bfe:	3c 2b                	cmp    $0x2b,%al
c0105c00:	75 05                	jne    c0105c07 <strtol+0x3c>
        s ++;
c0105c02:	ff 45 08             	incl   0x8(%ebp)
c0105c05:	eb 14                	jmp    c0105c1b <strtol+0x50>
    }
    else if (*s == '-') {
c0105c07:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c0a:	0f b6 00             	movzbl (%eax),%eax
c0105c0d:	3c 2d                	cmp    $0x2d,%al
c0105c0f:	75 0a                	jne    c0105c1b <strtol+0x50>
        s ++, neg = 1;
c0105c11:	ff 45 08             	incl   0x8(%ebp)
c0105c14:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105c1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c1f:	74 06                	je     c0105c27 <strtol+0x5c>
c0105c21:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105c25:	75 22                	jne    c0105c49 <strtol+0x7e>
c0105c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2a:	0f b6 00             	movzbl (%eax),%eax
c0105c2d:	3c 30                	cmp    $0x30,%al
c0105c2f:	75 18                	jne    c0105c49 <strtol+0x7e>
c0105c31:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c34:	40                   	inc    %eax
c0105c35:	0f b6 00             	movzbl (%eax),%eax
c0105c38:	3c 78                	cmp    $0x78,%al
c0105c3a:	75 0d                	jne    c0105c49 <strtol+0x7e>
        s += 2, base = 16;
c0105c3c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105c40:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105c47:	eb 29                	jmp    c0105c72 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105c49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c4d:	75 16                	jne    c0105c65 <strtol+0x9a>
c0105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c52:	0f b6 00             	movzbl (%eax),%eax
c0105c55:	3c 30                	cmp    $0x30,%al
c0105c57:	75 0c                	jne    c0105c65 <strtol+0x9a>
        s ++, base = 8;
c0105c59:	ff 45 08             	incl   0x8(%ebp)
c0105c5c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105c63:	eb 0d                	jmp    c0105c72 <strtol+0xa7>
    }
    else if (base == 0) {
c0105c65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c69:	75 07                	jne    c0105c72 <strtol+0xa7>
        base = 10;
c0105c6b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c75:	0f b6 00             	movzbl (%eax),%eax
c0105c78:	3c 2f                	cmp    $0x2f,%al
c0105c7a:	7e 1b                	jle    c0105c97 <strtol+0xcc>
c0105c7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7f:	0f b6 00             	movzbl (%eax),%eax
c0105c82:	3c 39                	cmp    $0x39,%al
c0105c84:	7f 11                	jg     c0105c97 <strtol+0xcc>
            dig = *s - '0';
c0105c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c89:	0f b6 00             	movzbl (%eax),%eax
c0105c8c:	0f be c0             	movsbl %al,%eax
c0105c8f:	83 e8 30             	sub    $0x30,%eax
c0105c92:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c95:	eb 48                	jmp    c0105cdf <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9a:	0f b6 00             	movzbl (%eax),%eax
c0105c9d:	3c 60                	cmp    $0x60,%al
c0105c9f:	7e 1b                	jle    c0105cbc <strtol+0xf1>
c0105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca4:	0f b6 00             	movzbl (%eax),%eax
c0105ca7:	3c 7a                	cmp    $0x7a,%al
c0105ca9:	7f 11                	jg     c0105cbc <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105cab:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cae:	0f b6 00             	movzbl (%eax),%eax
c0105cb1:	0f be c0             	movsbl %al,%eax
c0105cb4:	83 e8 57             	sub    $0x57,%eax
c0105cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cba:	eb 23                	jmp    c0105cdf <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105cbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cbf:	0f b6 00             	movzbl (%eax),%eax
c0105cc2:	3c 40                	cmp    $0x40,%al
c0105cc4:	7e 3b                	jle    c0105d01 <strtol+0x136>
c0105cc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc9:	0f b6 00             	movzbl (%eax),%eax
c0105ccc:	3c 5a                	cmp    $0x5a,%al
c0105cce:	7f 31                	jg     c0105d01 <strtol+0x136>
            dig = *s - 'A' + 10;
c0105cd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd3:	0f b6 00             	movzbl (%eax),%eax
c0105cd6:	0f be c0             	movsbl %al,%eax
c0105cd9:	83 e8 37             	sub    $0x37,%eax
c0105cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce2:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105ce5:	7d 19                	jge    c0105d00 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0105ce7:	ff 45 08             	incl   0x8(%ebp)
c0105cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105ced:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105cf1:	89 c2                	mov    %eax,%edx
c0105cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cf6:	01 d0                	add    %edx,%eax
c0105cf8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0105cfb:	e9 72 ff ff ff       	jmp    c0105c72 <strtol+0xa7>
            break;
c0105d00:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105d01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d05:	74 08                	je     c0105d0f <strtol+0x144>
        *endptr = (char *) s;
c0105d07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d0a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d0d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105d0f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105d13:	74 07                	je     c0105d1c <strtol+0x151>
c0105d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105d18:	f7 d8                	neg    %eax
c0105d1a:	eb 03                	jmp    c0105d1f <strtol+0x154>
c0105d1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105d1f:	89 ec                	mov    %ebp,%esp
c0105d21:	5d                   	pop    %ebp
c0105d22:	c3                   	ret    

c0105d23 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105d23:	55                   	push   %ebp
c0105d24:	89 e5                	mov    %esp,%ebp
c0105d26:	83 ec 28             	sub    $0x28,%esp
c0105d29:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0105d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d2f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105d32:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0105d36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d39:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0105d3c:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0105d3f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105d45:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105d48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105d4c:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105d4f:	89 d7                	mov    %edx,%edi
c0105d51:	f3 aa                	rep stos %al,%es:(%edi)
c0105d53:	89 fa                	mov    %edi,%edx
c0105d55:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105d58:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105d5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105d5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0105d61:	89 ec                	mov    %ebp,%esp
c0105d63:	5d                   	pop    %ebp
c0105d64:	c3                   	ret    

c0105d65 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105d65:	55                   	push   %ebp
c0105d66:	89 e5                	mov    %esp,%ebp
c0105d68:	57                   	push   %edi
c0105d69:	56                   	push   %esi
c0105d6a:	53                   	push   %ebx
c0105d6b:	83 ec 30             	sub    $0x30,%esp
c0105d6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d71:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d77:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d7a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d7d:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105d86:	73 42                	jae    c0105dca <memmove+0x65>
c0105d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105d8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d97:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d9d:	c1 e8 02             	shr    $0x2,%eax
c0105da0:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105da2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105da8:	89 d7                	mov    %edx,%edi
c0105daa:	89 c6                	mov    %eax,%esi
c0105dac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105dae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105db1:	83 e1 03             	and    $0x3,%ecx
c0105db4:	74 02                	je     c0105db8 <memmove+0x53>
c0105db6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105db8:	89 f0                	mov    %esi,%eax
c0105dba:	89 fa                	mov    %edi,%edx
c0105dbc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105dbf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105dc2:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0105dc8:	eb 36                	jmp    c0105e00 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105dca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dcd:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105dd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105dd3:	01 c2                	add    %eax,%edx
c0105dd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dd8:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dde:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105de4:	89 c1                	mov    %eax,%ecx
c0105de6:	89 d8                	mov    %ebx,%eax
c0105de8:	89 d6                	mov    %edx,%esi
c0105dea:	89 c7                	mov    %eax,%edi
c0105dec:	fd                   	std    
c0105ded:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105def:	fc                   	cld    
c0105df0:	89 f8                	mov    %edi,%eax
c0105df2:	89 f2                	mov    %esi,%edx
c0105df4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105df7:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105dfa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105e00:	83 c4 30             	add    $0x30,%esp
c0105e03:	5b                   	pop    %ebx
c0105e04:	5e                   	pop    %esi
c0105e05:	5f                   	pop    %edi
c0105e06:	5d                   	pop    %ebp
c0105e07:	c3                   	ret    

c0105e08 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105e08:	55                   	push   %ebp
c0105e09:	89 e5                	mov    %esp,%ebp
c0105e0b:	57                   	push   %edi
c0105e0c:	56                   	push   %esi
c0105e0d:	83 ec 20             	sub    $0x20,%esp
c0105e10:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e19:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e1c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e25:	c1 e8 02             	shr    $0x2,%eax
c0105e28:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e30:	89 d7                	mov    %edx,%edi
c0105e32:	89 c6                	mov    %eax,%esi
c0105e34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e36:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105e39:	83 e1 03             	and    $0x3,%ecx
c0105e3c:	74 02                	je     c0105e40 <memcpy+0x38>
c0105e3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e40:	89 f0                	mov    %esi,%eax
c0105e42:	89 fa                	mov    %edi,%edx
c0105e44:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e47:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105e4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105e50:	83 c4 20             	add    $0x20,%esp
c0105e53:	5e                   	pop    %esi
c0105e54:	5f                   	pop    %edi
c0105e55:	5d                   	pop    %ebp
c0105e56:	c3                   	ret    

c0105e57 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105e57:	55                   	push   %ebp
c0105e58:	89 e5                	mov    %esp,%ebp
c0105e5a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105e5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e60:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105e63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e66:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105e69:	eb 2e                	jmp    c0105e99 <memcmp+0x42>
        if (*s1 != *s2) {
c0105e6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e6e:	0f b6 10             	movzbl (%eax),%edx
c0105e71:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e74:	0f b6 00             	movzbl (%eax),%eax
c0105e77:	38 c2                	cmp    %al,%dl
c0105e79:	74 18                	je     c0105e93 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e7e:	0f b6 00             	movzbl (%eax),%eax
c0105e81:	0f b6 d0             	movzbl %al,%edx
c0105e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e87:	0f b6 00             	movzbl (%eax),%eax
c0105e8a:	0f b6 c8             	movzbl %al,%ecx
c0105e8d:	89 d0                	mov    %edx,%eax
c0105e8f:	29 c8                	sub    %ecx,%eax
c0105e91:	eb 18                	jmp    c0105eab <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105e93:	ff 45 fc             	incl   -0x4(%ebp)
c0105e96:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105e99:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e9c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e9f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105ea2:	85 c0                	test   %eax,%eax
c0105ea4:	75 c5                	jne    c0105e6b <memcmp+0x14>
    }
    return 0;
c0105ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105eab:	89 ec                	mov    %ebp,%esp
c0105ead:	5d                   	pop    %ebp
c0105eae:	c3                   	ret    
