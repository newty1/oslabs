
obj/bootblock.o：     文件格式 elf32-i386


Disassembly of section .startup:

00007c00 <start>:

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                     #屏蔽中断                        # Assemble for 16-bit mode
    cli                     #传输方向                       # Disable interrupts
    7c00:	fa                   	cli    
    cld                                             # String operations increment
    7c01:	fc                   	cld    

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
    movw %ax, %ds                                   # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
    movw %ax, %ss                                   # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c0a:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c0c:	a8 02                	test   $0x2,%al
    jnz seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c14:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c16:	a8 02                	test   $0x2,%al
    jnz seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
    7c1c:	e6 60                	out    %al,$0x60

00007c1e <probe_memory>:
    
#探测物理内存分布
probe_memory:
//对0x8000处的32位单元清零,即给位于0x8000处的
//struct e820map的成员变量nr_map清零
     movl $0, 0x8000
    7c1e:	66 c7 06 00 80       	movw   $0x8000,(%esi)
    7c23:	00 00                	add    %al,(%eax)
    7c25:	00 00                	add    %al,(%eax)
     xorl %ebx, %ebx
    7c27:	66 31 db             	xor    %bx,%bx
//表示设置调用INT 15h BIOS中断后，BIOS返回的映射地址描述符的起始地址
     movw $0x8004, %di
    7c2a:	bf                   	.byte 0xbf
    7c2b:	04 80                	add    $0x80,%al

00007c2d <start_probe>:
start_probe:
      movl $0xE820, %eax // INT 15的中断调用参数
    7c2d:	66 b8 20 e8          	mov    $0xe820,%ax
    7c31:	00 00                	add    %al,(%eax)
//设置地址范围描述符的大小为20字节，其大小等于struct e820map的成员变量map的大小
      movl $20, %ecx
    7c33:	66 b9 14 00          	mov    $0x14,%cx
    7c37:	00 00                	add    %al,(%eax)
//设置edx为534D4150h (即4个ASCII字符“SMAP”)，这是一个约定
      movl $SMAP, %edx
    7c39:	66 ba 50 41          	mov    $0x4150,%dx
    7c3d:	4d                   	dec    %ebp
    7c3e:	53                   	push   %ebx
//调用int 0x15中断，要求BIOS返回一个用地址范围描述符表示的内存段信息
      int $0x15
    7c3f:	cd 15                	int    $0x15
//如果eflags的CF位为0，则表示还有内存段需要探测
       jnc cont
    7c41:	73 08                	jae    7c4b <cont>
//探测有问题，结束探测
        movw $12345, 0x8000
    7c43:	c7 06 00 80 39 30    	movl   $0x30398000,(%esi)
        jmp finish_probe
    7c49:	eb 0e                	jmp    7c59 <finish_probe>

00007c4b <cont>:
cont:
//设置下一个BIOS返回的映射地址描述符的起始地址
        addw $20, %di
    7c4b:	83 c7 14             	add    $0x14,%edi
//递增struct e820map的成员变量nr_map
        incl 0x8000
    7c4e:	66 ff 06             	incw   (%esi)
    7c51:	00 80 66 83 fb 00    	add    %al,0xfb8366(%eax)
//如果INT0x15返回的ebx为零，表示探测结束，否则继续探测
        cmpl $0, %ebx
        jnz start_probe
    7c57:	75 d4                	jne    7c2d <start_probe>

00007c59 <finish_probe>:

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    lgdt gdtdesc  #boot/bootasm.S中的lgdt gdtdesc
    7c59:	0f 01 16             	lgdtl  (%esi)
    7c5c:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    7c5d:	7c 0f                	jl     7c6e <protcseg+0x1>
      #从代码中可以看到全局描述符表的大小为0x17 + 1 = 0x18，也就是24字节。
      #由于全局描述符表每项大小为8字节，因此一共有3项，而第一项是空白项，
      #所以全局描述符表中只有两个有效的段描述符，分别对应代码段和数据段。

      #将cr0寄存器的PE位（cr0寄存器的最低位）设置为1，便使能和进入保护模式了。代码如下所示：
     movl %cr0, %eax         #加载cro到eax
    7c5f:	20 c0                	and    %al,%al
     orl $CR0_PE_ON, %eax     #将eax的第0位置为1
    7c61:	66 83 c8 01          	or     $0x1,%ax
    movl %eax, %cr0          #将cr0的第0位置为1 开启保护模式
    7c65:	0f 22 c0             	mov    %eax,%cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg
    7c68:	ea                   	.byte 0xea
    7c69:	6d                   	insl   (%dx),%es:(%edi)
    7c6a:	7c 08                	jl     7c74 <protcseg+0x7>
	...

00007c6d <protcseg>:

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    7c6d:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds                                   # -> DS: Data Segment
    7c71:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> ES: Extra Segment
    7c73:	8e c0                	mov    %eax,%es
    movw %ax, %fs                                   # -> FS
    7c75:	8e e0                	mov    %eax,%fs
    movw %ax, %gs                                   # -> GS
    7c77:	8e e8                	mov    %eax,%gs
    movw %ax, %ss                                   # -> SS: Stack Segment
    7c79:	8e d0                	mov    %eax,%ss

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    7c7b:	bd 00 00 00 00       	mov    $0x0,%ebp
    movl $start, %esp
    7c80:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    call bootmain
    7c85:	e8 bf 00 00 00       	call   7d49 <bootmain>

00007c8a <spin>:

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin
    7c8a:	eb fe                	jmp    7c8a <spin>

00007c8c <gdt>:
	...
    7c94:	ff                   	(bad)  
    7c95:	ff 00                	incl   (%eax)
    7c97:	00 00                	add    %al,(%eax)
    7c99:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7ca0:	00                   	.byte 0x0
    7ca1:	92                   	xchg   %eax,%edx
    7ca2:	cf                   	iret   
	...

00007ca4 <gdtdesc>:
    7ca4:	17                   	pop    %ss
    7ca5:	00                   	.byte 0x0
    7ca6:	8c 7c 00 00          	mov    %?,0x0(%eax,%eax,1)

Disassembly of section .text:

00007caa <readseg>:
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * readseg简单包装了readsect，可以从设备读取任意长度的内容。
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7caa:	55                   	push   %ebp
    7cab:	89 e5                	mov    %esp,%ebp
    7cad:	57                   	push   %edi
    uintptr_t end_va = va + count;
    7cae:	8d 3c 10             	lea    (%eax,%edx,1),%edi

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7cb1:	89 ca                	mov    %ecx,%edx
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7cb3:	56                   	push   %esi
    va -= offset % SECTSIZE;
    7cb4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;
    7cba:	c1 e9 09             	shr    $0x9,%ecx
    va -= offset % SECTSIZE;
    7cbd:	29 d0                	sub    %edx,%eax
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7cbf:	53                   	push   %ebx
    va -= offset % SECTSIZE;
    7cc0:	89 c6                	mov    %eax,%esi
    uint32_t secno = (offset / SECTSIZE) + 1;
    7cc2:	8d 41 01             	lea    0x1(%ecx),%eax
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7cc5:	83 ec 08             	sub    $0x8,%esp
    uintptr_t end_va = va + count;
    7cc8:	89 7d ec             	mov    %edi,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7ccb:	bb f7 01 00 00       	mov    $0x1f7,%ebx
    uint32_t secno = (offset / SECTSIZE) + 1;
    7cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // 加1因为0扇区被引导占用
        // ELF文件从1扇区开始
    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7cd3:	3b 75 ec             	cmp    -0x14(%ebp),%esi
    7cd6:	73 6a                	jae    7d42 <readseg+0x98>
    7cd8:	89 da                	mov    %ebx,%edx
    7cda:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)//与状态位有关
    7cdb:	24 c0                	and    $0xc0,%al
    7cdd:	3c 40                	cmp    $0x40,%al
    7cdf:	75 f7                	jne    7cd8 <readseg+0x2e>
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
    7ce1:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7ce6:	b0 01                	mov    $0x1,%al
    7ce8:	ee                   	out    %al,(%dx)
    7ce9:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7cee:	8a 45 f0             	mov    -0x10(%ebp),%al
    7cf1:	ee                   	out    %al,(%dx)
    outb(0x1F4, (secno >> 8) & 0xFF);// 4是lba参数的8-15位
    7cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7cf5:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cfa:	c1 e8 08             	shr    $0x8,%eax
    7cfd:	ee                   	out    %al,(%dx)
    outb(0x1F5, (secno >> 16) & 0xFF);//16-23位
    7cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7d01:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7d06:	c1 e8 10             	shr    $0x10,%eax
    7d09:	ee                   	out    %al,(%dx)
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    7d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7d0d:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7d12:	c1 e8 18             	shr    $0x18,%eax
    7d15:	24 0f                	and    $0xf,%al
    7d17:	0c e0                	or     $0xe0,%al
    7d19:	ee                   	out    %al,(%dx)
    7d1a:	b0 20                	mov    $0x20,%al
    7d1c:	89 da                	mov    %ebx,%edx
    7d1e:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7d1f:	89 da                	mov    %ebx,%edx
    7d21:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)//与状态位有关
    7d22:	24 c0                	and    $0xc0,%al
    7d24:	3c 40                	cmp    $0x40,%al
    7d26:	75 f7                	jne    7d1f <readseg+0x75>
    asm volatile (
    7d28:	89 f7                	mov    %esi,%edi
    7d2a:	b9 80 00 00 00       	mov    $0x80,%ecx
    7d2f:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d34:	fc                   	cld    
    7d35:	f2 6d                	repnz insl (%dx),%es:(%edi)
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7d37:	ff 45 f0             	incl   -0x10(%ebp)
    7d3a:	81 c6 00 02 00 00    	add    $0x200,%esi
    7d40:	eb 91                	jmp    7cd3 <readseg+0x29>
        readsect((void *)va, secno);
    }
}
    7d42:	58                   	pop    %eax
    7d43:	5a                   	pop    %edx
    7d44:	5b                   	pop    %ebx
    7d45:	5e                   	pop    %esi
    7d46:	5f                   	pop    %edi
    7d47:	5d                   	pop    %ebp
    7d48:	c3                   	ret    

00007d49 <bootmain>:

/* bootmain - the entry of bootloader */
void
bootmain(void) {
    7d49:	55                   	push   %ebp
    // read the 1st page off disk 读取ELF头部
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d4a:	31 c9                	xor    %ecx,%ecx
bootmain(void) {
    7d4c:	89 e5                	mov    %esp,%ebp
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d4e:	ba 00 10 00 00       	mov    $0x1000,%edx
bootmain(void) {
    7d53:	56                   	push   %esi
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d54:	b8 00 00 01 00       	mov    $0x10000,%eax
bootmain(void) {
    7d59:	53                   	push   %ebx
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d5a:	e8 4b ff ff ff       	call   7caa <readseg>

    // is this a valid ELF? 
    if (ELFHDR->e_magic != ELF_MAGIC) {
    7d5f:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d66:	45 4c 46 
    7d69:	75 3f                	jne    7daa <bootmain+0x61>

    struct proghdr *ph, *eph;
    // ELF头部有描述ELF文件应加载到内存什么位置的描述表，
    // 先将描述表的头地址存在ph ph是数据表的起始位置，eph是数据表的结束位置，循环把数据装入内存
    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7d6b:	a1 1c 00 01 00       	mov    0x1001c,%eax
    eph = ph + ELFHDR->e_phnum;
    7d70:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7d77:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    eph = ph + ELFHDR->e_phnum;
    7d7d:	c1 e6 05             	shl    $0x5,%esi
    7d80:	01 de                	add    %ebx,%esi
    for (; ph < eph; ph ++) {
    7d82:	39 f3                	cmp    %esi,%ebx
    7d84:	73 18                	jae    7d9e <bootmain+0x55>
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d86:	8b 43 08             	mov    0x8(%ebx),%eax
    for (; ph < eph; ph ++) {
    7d89:	83 c3 20             	add    $0x20,%ebx
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d8c:	8b 4b e4             	mov    -0x1c(%ebx),%ecx
    7d8f:	8b 53 f4             	mov    -0xc(%ebx),%edx
    7d92:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d97:	e8 0e ff ff ff       	call   7caa <readseg>
    7d9c:	eb e4                	jmp    7d82 <bootmain+0x39>
    // ELF文件0x1000位置后面的0xd1ec比特被载入内存0x00100000
    // ELF文件0xf000位置后面的0x1d20比特被载入内存0x0010e000
    // 根据ELF头部储存的入口信息，找到内核的入口
    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();//function pointer
    7d9e:	a1 18 00 01 00       	mov    0x10018,%eax
    7da3:	25 ff ff ff 00       	and    $0xffffff,%eax
    7da8:	ff d0                	call   *%eax
}

static inline void
outw(uint16_t port, uint16_t data) {
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
    7daa:	ba 00 8a ff ff       	mov    $0xffff8a00,%edx
    7daf:	89 d0                	mov    %edx,%eax
    7db1:	66 ef                	out    %ax,(%dx)
    7db3:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7db8:	66 ef                	out    %ax,(%dx)
    7dba:	eb fe                	jmp    7dba <bootmain+0x71>
