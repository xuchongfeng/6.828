
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 0e 29 f0 00 	cmpl   $0x0,0xf0290e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 5b 0a 00 00       	call   f0100ab6 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
{
	va_list ap;

	if (panicstr)
		goto dead;
	panicstr = fmt;
f0100060:	89 35 80 0e 29 f0    	mov    %esi,0xf0290e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    

	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 68 58 00 00       	call   f01058d8 <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 00 5f 10 f0       	push   $0xf0105f00
f010007c:	e8 d0 3a 00 00       	call   f0103b51 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 a0 3a 00 00       	call   f0103b2b <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 27 72 10 f0 	movl   $0xf0107227,(%esp)
f0100092:	e8 ba 3a 00 00       	call   f0103b51 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 08 20 2d f0       	mov    $0xf02d2008,%eax
f01000a8:	2d 35 f3 28 f0       	sub    $0xf028f335,%eax
f01000ad:	50                   	push   %eax
f01000ae:	6a 00                	push   $0x0
f01000b0:	68 35 f3 28 f0       	push   $0xf028f335
f01000b5:	e8 0f 52 00 00       	call   f01052c9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000ba:	e8 a1 05 00 00       	call   f0100660 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bf:	83 c4 08             	add    $0x8,%esp
f01000c2:	68 ac 1a 00 00       	push   $0x1aac
f01000c7:	68 6c 5f 10 f0       	push   $0xf0105f6c
f01000cc:	e8 80 3a 00 00       	call   f0103b51 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000d1:	e8 f0 13 00 00       	call   f01014c6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d6:	e8 35 32 00 00       	call   f0103310 <env_init>
	trap_init();
f01000db:	e8 2c 3b 00 00       	call   f0103c0c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000e0:	e8 db 54 00 00       	call   f01055c0 <mp_init>
	lapic_init();
f01000e5:	e8 09 58 00 00       	call   f01058f3 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000ea:	e8 9e 39 00 00       	call   f0103a8d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ef:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000f6:	e8 54 5a 00 00       	call   f0105b4f <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000fb:	83 c4 10             	add    $0x10,%esp
f01000fe:	83 3d 88 0e 29 f0 07 	cmpl   $0x7,0xf0290e88
f0100105:	76 27                	jbe    f010012e <i386_init+0x92>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100107:	83 ec 04             	sub    $0x4,%esp
f010010a:	b8 26 55 10 f0       	mov    $0xf0105526,%eax
f010010f:	2d ac 54 10 f0       	sub    $0xf01054ac,%eax
f0100114:	50                   	push   %eax
f0100115:	68 ac 54 10 f0       	push   $0xf01054ac
f010011a:	68 00 70 00 f0       	push   $0xf0007000
f010011f:	e8 f2 51 00 00       	call   f0105316 <memmove>
f0100124:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100127:	bb 20 10 29 f0       	mov    $0xf0291020,%ebx
f010012c:	eb 19                	jmp    f0100147 <i386_init+0xab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010012e:	68 00 70 00 00       	push   $0x7000
f0100133:	68 24 5f 10 f0       	push   $0xf0105f24
f0100138:	6a 54                	push   $0x54
f010013a:	68 87 5f 10 f0       	push   $0xf0105f87
f010013f:	e8 fc fe ff ff       	call   f0100040 <_panic>
f0100144:	83 c3 74             	add    $0x74,%ebx
f0100147:	8b 15 c4 13 29 f0    	mov    0xf02913c4,%edx
f010014d:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100150:	01 d0                	add    %edx,%eax
f0100152:	01 c0                	add    %eax,%eax
f0100154:	01 d0                	add    %edx,%eax
f0100156:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100159:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
f0100160:	39 c3                	cmp    %eax,%ebx
f0100162:	73 6d                	jae    f01001d1 <i386_init+0x135>
		if (c == cpus + cpunum())  // We've started already.
f0100164:	e8 6f 57 00 00       	call   f01058d8 <cpunum>
f0100169:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010016c:	01 c2                	add    %eax,%edx
f010016e:	01 d2                	add    %edx,%edx
f0100170:	01 c2                	add    %eax,%edx
f0100172:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100175:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
f010017c:	39 c3                	cmp    %eax,%ebx
f010017e:	74 c4                	je     f0100144 <i386_init+0xa8>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100180:	89 d8                	mov    %ebx,%eax
f0100182:	2d 20 10 29 f0       	sub    $0xf0291020,%eax
f0100187:	c1 f8 02             	sar    $0x2,%eax
f010018a:	89 c2                	mov    %eax,%edx
f010018c:	c1 e0 07             	shl    $0x7,%eax
f010018f:	29 d0                	sub    %edx,%eax
f0100191:	8d 0c c2             	lea    (%edx,%eax,8),%ecx
f0100194:	89 c8                	mov    %ecx,%eax
f0100196:	c1 e0 0e             	shl    $0xe,%eax
f0100199:	29 c8                	sub    %ecx,%eax
f010019b:	c1 e0 04             	shl    $0x4,%eax
f010019e:	01 d0                	add    %edx,%eax
f01001a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01001a3:	c1 e0 0f             	shl    $0xf,%eax
f01001a6:	05 00 a0 29 f0       	add    $0xf029a000,%eax
f01001ab:	a3 84 0e 29 f0       	mov    %eax,0xf0290e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001b0:	83 ec 08             	sub    $0x8,%esp
f01001b3:	68 00 70 00 00       	push   $0x7000
f01001b8:	0f b6 03             	movzbl (%ebx),%eax
f01001bb:	50                   	push   %eax
f01001bc:	e8 8c 58 00 00       	call   f0105a4d <lapic_startap>
f01001c1:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001c4:	8b 43 04             	mov    0x4(%ebx),%eax
f01001c7:	83 f8 01             	cmp    $0x1,%eax
f01001ca:	75 f8                	jne    f01001c4 <i386_init+0x128>
f01001cc:	e9 73 ff ff ff       	jmp    f0100144 <i386_init+0xa8>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f01001d1:	83 ec 08             	sub    $0x8,%esp
f01001d4:	6a 00                	push   $0x0
f01001d6:	68 d6 35 28 f0       	push   $0xf02835d6
f01001db:	e8 41 33 00 00       	call   f0103521 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001e0:	e8 d5 43 00 00       	call   f01045ba <sched_yield>

f01001e5 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e5:	55                   	push   %ebp
f01001e6:	89 e5                	mov    %esp,%ebp
f01001e8:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001eb:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f5:	77 12                	ja     f0100209 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f7:	50                   	push   %eax
f01001f8:	68 48 5f 10 f0       	push   $0xf0105f48
f01001fd:	6a 6b                	push   $0x6b
f01001ff:	68 87 5f 10 f0       	push   $0xf0105f87
f0100204:	e8 37 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100209:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010020e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100211:	e8 c2 56 00 00       	call   f01058d8 <cpunum>
f0100216:	83 ec 08             	sub    $0x8,%esp
f0100219:	50                   	push   %eax
f010021a:	68 93 5f 10 f0       	push   $0xf0105f93
f010021f:	e8 2d 39 00 00       	call   f0103b51 <cprintf>

	lapic_init();
f0100224:	e8 ca 56 00 00       	call   f01058f3 <lapic_init>
	env_init_percpu();
f0100229:	e8 b2 30 00 00       	call   f01032e0 <env_init_percpu>
	trap_init_percpu();
f010022e:	e8 35 39 00 00       	call   f0103b68 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100233:	e8 a0 56 00 00       	call   f01058d8 <cpunum>
f0100238:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010023b:	01 c2                	add    %eax,%edx
f010023d:	01 d2                	add    %edx,%edx
f010023f:	01 c2                	add    %eax,%edx
f0100241:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100244:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010024b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100250:	f0 87 82 20 10 29 f0 	lock xchg %eax,-0xfd6efe0(%edx)
f0100257:	83 c4 10             	add    $0x10,%esp
f010025a:	eb fe                	jmp    f010025a <mp_main+0x75>

f010025c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010025c:	55                   	push   %ebp
f010025d:	89 e5                	mov    %esp,%ebp
f010025f:	53                   	push   %ebx
f0100260:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100263:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100266:	ff 75 0c             	pushl  0xc(%ebp)
f0100269:	ff 75 08             	pushl  0x8(%ebp)
f010026c:	68 a9 5f 10 f0       	push   $0xf0105fa9
f0100271:	e8 db 38 00 00       	call   f0103b51 <cprintf>
	vcprintf(fmt, ap);
f0100276:	83 c4 08             	add    $0x8,%esp
f0100279:	53                   	push   %ebx
f010027a:	ff 75 10             	pushl  0x10(%ebp)
f010027d:	e8 a9 38 00 00       	call   f0103b2b <vcprintf>
	cprintf("\n");
f0100282:	c7 04 24 27 72 10 f0 	movl   $0xf0107227,(%esp)
f0100289:	e8 c3 38 00 00       	call   f0103b51 <cprintf>
	va_end(ap);
}
f010028e:	83 c4 10             	add    $0x10,%esp
f0100291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100294:	c9                   	leave  
f0100295:	c3                   	ret    
	...

f0100298 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100298:	55                   	push   %ebp
f0100299:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010029b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a0:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a1:	a8 01                	test   $0x1,%al
f01002a3:	74 0b                	je     f01002b0 <serial_proc_data+0x18>
f01002a5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002aa:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002ab:	0f b6 c0             	movzbl %al,%eax
}
f01002ae:	5d                   	pop    %ebp
f01002af:	c3                   	ret    

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002b5:	eb f7                	jmp    f01002ae <serial_proc_data+0x16>

f01002b7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002b7:	55                   	push   %ebp
f01002b8:	89 e5                	mov    %esp,%ebp
f01002ba:	53                   	push   %ebx
f01002bb:	83 ec 04             	sub    $0x4,%esp
f01002be:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002c0:	ff d3                	call   *%ebx
f01002c2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c5:	74 2d                	je     f01002f4 <cons_intr+0x3d>
		if (c == 0)
f01002c7:	85 c0                	test   %eax,%eax
f01002c9:	74 f5                	je     f01002c0 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002cb:	8b 0d 24 02 29 f0    	mov    0xf0290224,%ecx
f01002d1:	8d 51 01             	lea    0x1(%ecx),%edx
f01002d4:	89 15 24 02 29 f0    	mov    %edx,0xf0290224
f01002da:	88 81 20 00 29 f0    	mov    %al,-0xfd6ffe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002e0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002e6:	75 d8                	jne    f01002c0 <cons_intr+0x9>
			cons.wpos = 0;
f01002e8:	c7 05 24 02 29 f0 00 	movl   $0x0,0xf0290224
f01002ef:	00 00 00 
f01002f2:	eb cc                	jmp    f01002c0 <cons_intr+0x9>
	}
}
f01002f4:	83 c4 04             	add    $0x4,%esp
f01002f7:	5b                   	pop    %ebx
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 04             	sub    $0x4,%esp
f0100301:	ba 64 00 00 00       	mov    $0x64,%edx
f0100306:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100307:	a8 01                	test   $0x1,%al
f0100309:	0f 84 f1 00 00 00    	je     f0100400 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010030f:	a8 20                	test   $0x20,%al
f0100311:	0f 85 f0 00 00 00    	jne    f0100407 <kbd_proc_data+0x10d>
f0100317:	ba 60 00 00 00       	mov    $0x60,%edx
f010031c:	ec                   	in     (%dx),%al
f010031d:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010031f:	3c e0                	cmp    $0xe0,%al
f0100321:	0f 84 8a 00 00 00    	je     f01003b1 <kbd_proc_data+0xb7>
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100327:	84 c0                	test   %al,%al
f0100329:	0f 88 95 00 00 00    	js     f01003c4 <kbd_proc_data+0xca>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f010032f:	8b 0d 00 00 29 f0    	mov    0xf0290000,%ecx
f0100335:	f6 c1 40             	test   $0x40,%cl
f0100338:	74 0e                	je     f0100348 <kbd_proc_data+0x4e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033a:	83 c8 80             	or     $0xffffff80,%eax
f010033d:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010033f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100342:	89 0d 00 00 29 f0    	mov    %ecx,0xf0290000
	}

	shift |= shiftcode[data];
f0100348:	0f b6 d2             	movzbl %dl,%edx
f010034b:	0f b6 82 20 61 10 f0 	movzbl -0xfef9ee0(%edx),%eax
f0100352:	0b 05 00 00 29 f0    	or     0xf0290000,%eax
	shift ^= togglecode[data];
f0100358:	0f b6 8a 20 60 10 f0 	movzbl -0xfef9fe0(%edx),%ecx
f010035f:	31 c8                	xor    %ecx,%eax
f0100361:	a3 00 00 29 f0       	mov    %eax,0xf0290000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100366:	89 c1                	mov    %eax,%ecx
f0100368:	83 e1 03             	and    $0x3,%ecx
f010036b:	8b 0c 8d 00 60 10 f0 	mov    -0xfefa000(,%ecx,4),%ecx
f0100372:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100375:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100378:	a8 08                	test   $0x8,%al
f010037a:	74 0d                	je     f0100389 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f010037c:	89 da                	mov    %ebx,%edx
f010037e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100381:	83 f9 19             	cmp    $0x19,%ecx
f0100384:	77 6d                	ja     f01003f3 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100386:	83 eb 20             	sub    $0x20,%ebx
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100389:	f7 d0                	not    %eax
f010038b:	a8 06                	test   $0x6,%al
f010038d:	75 2e                	jne    f01003bd <kbd_proc_data+0xc3>
f010038f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100395:	75 26                	jne    f01003bd <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100397:	83 ec 0c             	sub    $0xc,%esp
f010039a:	68 c3 5f 10 f0       	push   $0xf0105fc3
f010039f:	e8 ad 37 00 00       	call   f0103b51 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	b0 03                	mov    $0x3,%al
f01003a6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ab:	ee                   	out    %al,(%dx)
f01003ac:	83 c4 10             	add    $0x10,%esp
f01003af:	eb 0c                	jmp    f01003bd <kbd_proc_data+0xc3>

	data = inb(KBDATAP);

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
f01003b1:	83 0d 00 00 29 f0 40 	orl    $0x40,0xf0290000
		return 0;
f01003b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003bd:	89 d8                	mov    %ebx,%eax
f01003bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003c2:	c9                   	leave  
f01003c3:	c3                   	ret    
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c4:	8b 0d 00 00 29 f0    	mov    0xf0290000,%ecx
f01003ca:	f6 c1 40             	test   $0x40,%cl
f01003cd:	75 05                	jne    f01003d4 <kbd_proc_data+0xda>
f01003cf:	83 e0 7f             	and    $0x7f,%eax
f01003d2:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01003d4:	0f b6 d2             	movzbl %dl,%edx
f01003d7:	8a 82 20 61 10 f0    	mov    -0xfef9ee0(%edx),%al
f01003dd:	83 c8 40             	or     $0x40,%eax
f01003e0:	0f b6 c0             	movzbl %al,%eax
f01003e3:	f7 d0                	not    %eax
f01003e5:	21 c8                	and    %ecx,%eax
f01003e7:	a3 00 00 29 f0       	mov    %eax,0xf0290000
		return 0;
f01003ec:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f1:	eb ca                	jmp    f01003bd <kbd_proc_data+0xc3>

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
f01003f3:	83 ea 41             	sub    $0x41,%edx
f01003f6:	83 fa 19             	cmp    $0x19,%edx
f01003f9:	77 8e                	ja     f0100389 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01003fb:	83 c3 20             	add    $0x20,%ebx
f01003fe:	eb 89                	jmp    f0100389 <kbd_proc_data+0x8f>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100400:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100405:	eb b6                	jmp    f01003bd <kbd_proc_data+0xc3>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100407:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010040c:	eb af                	jmp    f01003bd <kbd_proc_data+0xc3>

f010040e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010040e:	55                   	push   %ebp
f010040f:	89 e5                	mov    %esp,%ebp
f0100411:	57                   	push   %edi
f0100412:	56                   	push   %esi
f0100413:	53                   	push   %ebx
f0100414:	83 ec 1c             	sub    $0x1c,%esp
f0100417:	89 c7                	mov    %eax,%edi
f0100419:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041e:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100423:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100428:	eb 06                	jmp    f0100430 <cons_putc+0x22>
f010042a:	89 ca                	mov    %ecx,%edx
f010042c:	ec                   	in     (%dx),%al
f010042d:	ec                   	in     (%dx),%al
f010042e:	ec                   	in     (%dx),%al
f010042f:	ec                   	in     (%dx),%al
f0100430:	89 f2                	mov    %esi,%edx
f0100432:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100433:	a8 20                	test   $0x20,%al
f0100435:	75 03                	jne    f010043a <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100437:	4b                   	dec    %ebx
f0100438:	75 f0                	jne    f010042a <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010043a:	89 f8                	mov    %edi,%eax
f010043c:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100444:	ee                   	out    %al,(%dx)
f0100445:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044a:	be 79 03 00 00       	mov    $0x379,%esi
f010044f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100454:	eb 06                	jmp    f010045c <cons_putc+0x4e>
f0100456:	89 ca                	mov    %ecx,%edx
f0100458:	ec                   	in     (%dx),%al
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	ec                   	in     (%dx),%al
f010045c:	89 f2                	mov    %esi,%edx
f010045e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010045f:	84 c0                	test   %al,%al
f0100461:	78 03                	js     f0100466 <cons_putc+0x58>
f0100463:	4b                   	dec    %ebx
f0100464:	75 f0                	jne    f0100456 <cons_putc+0x48>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100466:	ba 78 03 00 00       	mov    $0x378,%edx
f010046b:	8a 45 e7             	mov    -0x19(%ebp),%al
f010046e:	ee                   	out    %al,(%dx)
f010046f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100474:	b0 0d                	mov    $0xd,%al
f0100476:	ee                   	out    %al,(%dx)
f0100477:	b0 08                	mov    $0x8,%al
f0100479:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010047a:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100480:	75 06                	jne    f0100488 <cons_putc+0x7a>
		c |= 0x0700;
f0100482:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100488:	89 f8                	mov    %edi,%eax
f010048a:	0f b6 c0             	movzbl %al,%eax
f010048d:	83 f8 09             	cmp    $0x9,%eax
f0100490:	0f 84 b1 00 00 00    	je     f0100547 <cons_putc+0x139>
f0100496:	83 f8 09             	cmp    $0x9,%eax
f0100499:	7e 70                	jle    f010050b <cons_putc+0xfd>
f010049b:	83 f8 0a             	cmp    $0xa,%eax
f010049e:	0f 84 96 00 00 00    	je     f010053a <cons_putc+0x12c>
f01004a4:	83 f8 0d             	cmp    $0xd,%eax
f01004a7:	0f 85 d1 00 00 00    	jne    f010057e <cons_putc+0x170>
		break;
	case '\n':
		crt_pos += CRT_COLS;
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ad:	66 8b 0d 28 02 29 f0 	mov    0xf0290228,%cx
f01004b4:	bb 50 00 00 00       	mov    $0x50,%ebx
f01004b9:	89 c8                	mov    %ecx,%eax
f01004bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01004c0:	66 f7 f3             	div    %bx
f01004c3:	29 d1                	sub    %edx,%ecx
f01004c5:	66 89 0d 28 02 29 f0 	mov    %cx,0xf0290228
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004cc:	66 81 3d 28 02 29 f0 	cmpw   $0x7cf,0xf0290228
f01004d3:	cf 07 
f01004d5:	0f 87 c5 00 00 00    	ja     f01005a0 <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004db:	8b 0d 30 02 29 f0    	mov    0xf0290230,%ecx
f01004e1:	b0 0e                	mov    $0xe,%al
f01004e3:	89 ca                	mov    %ecx,%edx
f01004e5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e6:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004e9:	66 a1 28 02 29 f0    	mov    0xf0290228,%ax
f01004ef:	66 c1 e8 08          	shr    $0x8,%ax
f01004f3:	89 da                	mov    %ebx,%edx
f01004f5:	ee                   	out    %al,(%dx)
f01004f6:	b0 0f                	mov    $0xf,%al
f01004f8:	89 ca                	mov    %ecx,%edx
f01004fa:	ee                   	out    %al,(%dx)
f01004fb:	a0 28 02 29 f0       	mov    0xf0290228,%al
f0100500:	89 da                	mov    %ebx,%edx
f0100502:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100503:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100506:	5b                   	pop    %ebx
f0100507:	5e                   	pop    %esi
f0100508:	5f                   	pop    %edi
f0100509:	5d                   	pop    %ebp
f010050a:	c3                   	ret    
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;

	switch (c & 0xff) {
f010050b:	83 f8 08             	cmp    $0x8,%eax
f010050e:	75 6e                	jne    f010057e <cons_putc+0x170>
	case '\b':
		if (crt_pos > 0) {
f0100510:	66 a1 28 02 29 f0    	mov    0xf0290228,%ax
f0100516:	66 85 c0             	test   %ax,%ax
f0100519:	74 c0                	je     f01004db <cons_putc+0xcd>
			crt_pos--;
f010051b:	48                   	dec    %eax
f010051c:	66 a3 28 02 29 f0    	mov    %ax,0xf0290228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100522:	0f b7 c0             	movzwl %ax,%eax
f0100525:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f010052b:	83 cf 20             	or     $0x20,%edi
f010052e:	8b 15 2c 02 29 f0    	mov    0xf029022c,%edx
f0100534:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100538:	eb 92                	jmp    f01004cc <cons_putc+0xbe>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010053a:	66 83 05 28 02 29 f0 	addw   $0x50,0xf0290228
f0100541:	50 
f0100542:	e9 66 ff ff ff       	jmp    f01004ad <cons_putc+0x9f>
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
		break;
	case '\t':
		cons_putc(' ');
f0100547:	b8 20 00 00 00       	mov    $0x20,%eax
f010054c:	e8 bd fe ff ff       	call   f010040e <cons_putc>
		cons_putc(' ');
f0100551:	b8 20 00 00 00       	mov    $0x20,%eax
f0100556:	e8 b3 fe ff ff       	call   f010040e <cons_putc>
		cons_putc(' ');
f010055b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100560:	e8 a9 fe ff ff       	call   f010040e <cons_putc>
		cons_putc(' ');
f0100565:	b8 20 00 00 00       	mov    $0x20,%eax
f010056a:	e8 9f fe ff ff       	call   f010040e <cons_putc>
		cons_putc(' ');
f010056f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100574:	e8 95 fe ff ff       	call   f010040e <cons_putc>
f0100579:	e9 4e ff ff ff       	jmp    f01004cc <cons_putc+0xbe>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010057e:	66 a1 28 02 29 f0    	mov    0xf0290228,%ax
f0100584:	8d 50 01             	lea    0x1(%eax),%edx
f0100587:	66 89 15 28 02 29 f0 	mov    %dx,0xf0290228
f010058e:	0f b7 c0             	movzwl %ax,%eax
f0100591:	8b 15 2c 02 29 f0    	mov    0xf029022c,%edx
f0100597:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010059b:	e9 2c ff ff ff       	jmp    f01004cc <cons_putc+0xbe>

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005a0:	a1 2c 02 29 f0       	mov    0xf029022c,%eax
f01005a5:	83 ec 04             	sub    $0x4,%esp
f01005a8:	68 00 0f 00 00       	push   $0xf00
f01005ad:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b3:	52                   	push   %edx
f01005b4:	50                   	push   %eax
f01005b5:	e8 5c 4d 00 00       	call   f0105316 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005ba:	8b 15 2c 02 29 f0    	mov    0xf029022c,%edx
f01005c0:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005c6:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005cc:	83 c4 10             	add    $0x10,%esp
f01005cf:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005d4:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d7:	39 d0                	cmp    %edx,%eax
f01005d9:	75 f4                	jne    f01005cf <cons_putc+0x1c1>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005db:	66 83 2d 28 02 29 f0 	subw   $0x50,0xf0290228
f01005e2:	50 
f01005e3:	e9 f3 fe ff ff       	jmp    f01004db <cons_putc+0xcd>

f01005e8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005e8:	80 3d 34 02 29 f0 00 	cmpb   $0x0,0xf0290234
f01005ef:	75 01                	jne    f01005f2 <serial_intr+0xa>
f01005f1:	c3                   	ret    
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005f8:	b8 98 02 10 f0       	mov    $0xf0100298,%eax
f01005fd:	e8 b5 fc ff ff       	call   f01002b7 <cons_intr>
}
f0100602:	c9                   	leave  
f0100603:	c3                   	ret    

f0100604 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010060a:	b8 fa 02 10 f0       	mov    $0xf01002fa,%eax
f010060f:	e8 a3 fc ff ff       	call   f01002b7 <cons_intr>
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
f0100619:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061c:	e8 c7 ff ff ff       	call   f01005e8 <serial_intr>
	kbd_intr();
f0100621:	e8 de ff ff ff       	call   f0100604 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100626:	a1 20 02 29 f0       	mov    0xf0290220,%eax
f010062b:	3b 05 24 02 29 f0    	cmp    0xf0290224,%eax
f0100631:	74 26                	je     f0100659 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100633:	8d 50 01             	lea    0x1(%eax),%edx
f0100636:	89 15 20 02 29 f0    	mov    %edx,0xf0290220
f010063c:	0f b6 80 20 00 29 f0 	movzbl -0xfd6ffe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100643:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100649:	74 02                	je     f010064d <cons_getc+0x37>
			cons.rpos = 0;
		return c;
	}
	return 0;
}
f010064b:	c9                   	leave  
f010064c:	c3                   	ret    

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010064d:	c7 05 20 02 29 f0 00 	movl   $0x0,0xf0290220
f0100654:	00 00 00 
f0100657:	eb f2                	jmp    f010064b <cons_getc+0x35>
		return c;
	}
	return 0;
f0100659:	b8 00 00 00 00       	mov    $0x0,%eax
f010065e:	eb eb                	jmp    f010064b <cons_getc+0x35>

f0100660 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	57                   	push   %edi
f0100664:	56                   	push   %esi
f0100665:	53                   	push   %ebx
f0100666:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100669:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100670:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100677:	5a a5 
	if (*cp != 0xA55A) {
f0100679:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010067f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100683:	0f 84 be 00 00 00    	je     f0100747 <cons_init+0xe7>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100689:	c7 05 30 02 29 f0 b4 	movl   $0x3b4,0xf0290230
f0100690:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100693:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100698:	8b 3d 30 02 29 f0    	mov    0xf0290230,%edi
f010069e:	b0 0e                	mov    $0xe,%al
f01006a0:	89 fa                	mov    %edi,%edx
f01006a2:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a3:	8d 4f 01             	lea    0x1(%edi),%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a6:	89 ca                	mov    %ecx,%edx
f01006a8:	ec                   	in     (%dx),%al
f01006a9:	0f b6 c0             	movzbl %al,%eax
f01006ac:	c1 e0 08             	shl    $0x8,%eax
f01006af:	89 c3                	mov    %eax,%ebx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b1:	b0 0f                	mov    $0xf,%al
f01006b3:	89 fa                	mov    %edi,%edx
f01006b5:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b6:	89 ca                	mov    %ecx,%edx
f01006b8:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b9:	89 35 2c 02 29 f0    	mov    %esi,0xf029022c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006bf:	0f b6 c0             	movzbl %al,%eax
f01006c2:	09 d8                	or     %ebx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006c4:	66 a3 28 02 29 f0    	mov    %ax,0xf0290228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ca:	e8 35 ff ff ff       	call   f0100604 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006cf:	83 ec 0c             	sub    $0xc,%esp
f01006d2:	66 a1 a8 13 12 f0    	mov    0xf01213a8,%ax
f01006d8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006dd:	50                   	push   %eax
f01006de:	e8 29 33 00 00       	call   f0103a0c <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e3:	b1 00                	mov    $0x0,%cl
f01006e5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006ea:	88 c8                	mov    %cl,%al
f01006ec:	89 da                	mov    %ebx,%edx
f01006ee:	ee                   	out    %al,(%dx)
f01006ef:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006f4:	b0 80                	mov    $0x80,%al
f01006f6:	89 fa                	mov    %edi,%edx
f01006f8:	ee                   	out    %al,(%dx)
f01006f9:	b0 0c                	mov    $0xc,%al
f01006fb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100706:	88 c8                	mov    %cl,%al
f0100708:	89 f2                	mov    %esi,%edx
f010070a:	ee                   	out    %al,(%dx)
f010070b:	b0 03                	mov    $0x3,%al
f010070d:	89 fa                	mov    %edi,%edx
f010070f:	ee                   	out    %al,(%dx)
f0100710:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100715:	88 c8                	mov    %cl,%al
f0100717:	ee                   	out    %al,(%dx)
f0100718:	b0 01                	mov    $0x1,%al
f010071a:	89 f2                	mov    %esi,%edx
f010071c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100722:	ec                   	in     (%dx),%al
f0100723:	88 c1                	mov    %al,%cl
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100725:	83 c4 10             	add    $0x10,%esp
f0100728:	3c ff                	cmp    $0xff,%al
f010072a:	0f 95 05 34 02 29 f0 	setne  0xf0290234
f0100731:	89 da                	mov    %ebx,%edx
f0100733:	ec                   	in     (%dx),%al
f0100734:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100739:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010073a:	80 f9 ff             	cmp    $0xff,%cl
f010073d:	74 23                	je     f0100762 <cons_init+0x102>
		cprintf("Serial port does not exist!\n");
}
f010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100742:	5b                   	pop    %ebx
f0100743:	5e                   	pop    %esi
f0100744:	5f                   	pop    %edi
f0100745:	5d                   	pop    %ebp
f0100746:	c3                   	ret    
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100747:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010074e:	c7 05 30 02 29 f0 d4 	movl   $0x3d4,0xf0290230
f0100755:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100758:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010075d:	e9 36 ff ff ff       	jmp    f0100698 <cons_init+0x38>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	68 cf 5f 10 f0       	push   $0xf0105fcf
f010076a:	e8 e2 33 00 00       	call   f0103b51 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
}
f0100772:	eb cb                	jmp    f010073f <cons_init+0xdf>

f0100774 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010077a:	8b 45 08             	mov    0x8(%ebp),%eax
f010077d:	e8 8c fc ff ff       	call   f010040e <cons_putc>
}
f0100782:	c9                   	leave  
f0100783:	c3                   	ret    

f0100784 <getchar>:

int
getchar(void)
{
f0100784:	55                   	push   %ebp
f0100785:	89 e5                	mov    %esp,%ebp
f0100787:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010078a:	e8 87 fe ff ff       	call   f0100616 <cons_getc>
f010078f:	85 c0                	test   %eax,%eax
f0100791:	74 f7                	je     f010078a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100793:	c9                   	leave  
f0100794:	c3                   	ret    

f0100795 <iscons>:

int
iscons(int fdnum)
{
f0100795:	55                   	push   %ebp
f0100796:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100798:	b8 01 00 00 00       	mov    $0x1,%eax
f010079d:	5d                   	pop    %ebp
f010079e:	c3                   	ret    
	...

f01007a0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a6:	68 20 62 10 f0       	push   $0xf0106220
f01007ab:	68 3e 62 10 f0       	push   $0xf010623e
f01007b0:	68 43 62 10 f0       	push   $0xf0106243
f01007b5:	e8 97 33 00 00       	call   f0103b51 <cprintf>
f01007ba:	83 c4 0c             	add    $0xc,%esp
f01007bd:	68 14 63 10 f0       	push   $0xf0106314
f01007c2:	68 4c 62 10 f0       	push   $0xf010624c
f01007c7:	68 43 62 10 f0       	push   $0xf0106243
f01007cc:	e8 80 33 00 00       	call   f0103b51 <cprintf>
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 3c 63 10 f0       	push   $0xf010633c
f01007d9:	68 55 62 10 f0       	push   $0xf0106255
f01007de:	68 43 62 10 f0       	push   $0xf0106243
f01007e3:	e8 69 33 00 00       	call   f0103b51 <cprintf>
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	68 64 63 10 f0       	push   $0xf0106364
f01007f0:	68 5f 62 10 f0       	push   $0xf010625f
f01007f5:	68 43 62 10 f0       	push   $0xf0106243
f01007fa:	e8 52 33 00 00       	call   f0103b51 <cprintf>
	return 0;
}
f01007ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100804:	c9                   	leave  
f0100805:	c3                   	ret    

f0100806 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
f0100809:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080c:	68 6c 62 10 f0       	push   $0xf010626c
f0100811:	e8 3b 33 00 00       	call   f0103b51 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100816:	83 c4 08             	add    $0x8,%esp
f0100819:	68 0c 00 10 00       	push   $0x10000c
f010081e:	68 a4 63 10 f0       	push   $0xf01063a4
f0100823:	e8 29 33 00 00       	call   f0103b51 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100828:	83 c4 0c             	add    $0xc,%esp
f010082b:	68 0c 00 10 00       	push   $0x10000c
f0100830:	68 0c 00 10 f0       	push   $0xf010000c
f0100835:	68 cc 63 10 f0       	push   $0xf01063cc
f010083a:	e8 12 33 00 00       	call   f0103b51 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083f:	83 c4 0c             	add    $0xc,%esp
f0100842:	68 f4 5e 10 00       	push   $0x105ef4
f0100847:	68 f4 5e 10 f0       	push   $0xf0105ef4
f010084c:	68 f0 63 10 f0       	push   $0xf01063f0
f0100851:	e8 fb 32 00 00       	call   f0103b51 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100856:	83 c4 0c             	add    $0xc,%esp
f0100859:	68 35 f3 28 00       	push   $0x28f335
f010085e:	68 35 f3 28 f0       	push   $0xf028f335
f0100863:	68 14 64 10 f0       	push   $0xf0106414
f0100868:	e8 e4 32 00 00       	call   f0103b51 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086d:	83 c4 0c             	add    $0xc,%esp
f0100870:	68 08 20 2d 00       	push   $0x2d2008
f0100875:	68 08 20 2d f0       	push   $0xf02d2008
f010087a:	68 38 64 10 f0       	push   $0xf0106438
f010087f:	e8 cd 32 00 00       	call   f0103b51 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100884:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100887:	b8 07 24 2d f0       	mov    $0xf02d2407,%eax
f010088c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100891:	c1 f8 0a             	sar    $0xa,%eax
f0100894:	50                   	push   %eax
f0100895:	68 5c 64 10 f0       	push   $0xf010645c
f010089a:	e8 b2 32 00 00       	call   f0103b51 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010089f:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a4:	c9                   	leave  
f01008a5:	c3                   	ret    

f01008a6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a6:	55                   	push   %ebp
f01008a7:	89 e5                	mov    %esp,%ebp
f01008a9:	57                   	push   %edi
f01008aa:	56                   	push   %esi
f01008ab:	53                   	push   %ebx
f01008ac:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008af:	89 eb                	mov    %ebp,%ebx
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
f01008b1:	68 85 62 10 f0       	push   $0xf0106285
f01008b6:	e8 96 32 00 00       	call   f0103b51 <cprintf>
    while (ebp != 0) {
f01008bb:	83 c4 10             	add    $0x10,%esp
        ptr_ebp = (uint32_t*) ebp;
        cprintf("\tebp %x eip %x args %08x %08x %08x %08x %08x\n",
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008be:	8d 7d d0             	lea    -0x30(%ebp),%edi
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
    while (ebp != 0) {
f01008c1:	eb 02                	jmp    f01008c5 <mon_backtrace+0x1f>
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
			cprintf("\t\t %s:%d: %.*s+%d\n",
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ptr_ebp[1] - info.eip_fn_addr);
		}
		ebp = *ptr_ebp;
f01008c3:	8b 1e                	mov    (%esi),%ebx
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
    while (ebp != 0) {
f01008c5:	85 db                	test   %ebx,%ebx
f01008c7:	74 57                	je     f0100920 <mon_backtrace+0x7a>
        ptr_ebp = (uint32_t*) ebp;
f01008c9:	89 de                	mov    %ebx,%esi
        cprintf("\tebp %x eip %x args %08x %08x %08x %08x %08x\n",
f01008cb:	ff 73 18             	pushl  0x18(%ebx)
f01008ce:	ff 73 14             	pushl  0x14(%ebx)
f01008d1:	ff 73 10             	pushl  0x10(%ebx)
f01008d4:	ff 73 0c             	pushl  0xc(%ebx)
f01008d7:	ff 73 08             	pushl  0x8(%ebx)
f01008da:	ff 73 04             	pushl  0x4(%ebx)
f01008dd:	53                   	push   %ebx
f01008de:	68 88 64 10 f0       	push   $0xf0106488
f01008e3:	e8 69 32 00 00       	call   f0103b51 <cprintf>
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008e8:	83 c4 18             	add    $0x18,%esp
f01008eb:	57                   	push   %edi
f01008ec:	ff 73 04             	pushl  0x4(%ebx)
f01008ef:	e8 01 3f 00 00       	call   f01047f5 <debuginfo_eip>
f01008f4:	83 c4 10             	add    $0x10,%esp
f01008f7:	85 c0                	test   %eax,%eax
f01008f9:	75 c8                	jne    f01008c3 <mon_backtrace+0x1d>
			cprintf("\t\t %s:%d: %.*s+%d\n",
f01008fb:	83 ec 08             	sub    $0x8,%esp
f01008fe:	8b 43 04             	mov    0x4(%ebx),%eax
f0100901:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100904:	50                   	push   %eax
f0100905:	ff 75 d8             	pushl  -0x28(%ebp)
f0100908:	ff 75 dc             	pushl  -0x24(%ebp)
f010090b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100911:	68 97 62 10 f0       	push   $0xf0106297
f0100916:	e8 36 32 00 00       	call   f0103b51 <cprintf>
f010091b:	83 c4 20             	add    $0x20,%esp
f010091e:	eb a3                	jmp    f01008c3 <mon_backtrace+0x1d>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ptr_ebp[1] - info.eip_fn_addr);
		}
		ebp = *ptr_ebp;
    }
    return 0;
}
f0100920:	b8 00 00 00 00       	mov    $0x0,%eax
f0100925:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100928:	5b                   	pop    %ebx
f0100929:	5e                   	pop    %esi
f010092a:	5f                   	pop    %edi
f010092b:	5d                   	pop    %ebp
f010092c:	c3                   	ret    

f010092d <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010092d:	55                   	push   %ebp
f010092e:	89 e5                	mov    %esp,%ebp
f0100930:	57                   	push   %edi
f0100931:	56                   	push   %esi
f0100932:	53                   	push   %ebx
f0100933:	83 ec 1c             	sub    $0x1c,%esp
f0100936:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc != 3) {
f0100939:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010093d:	75 55                	jne    f0100994 <mon_showmappings+0x67>
		cprintf("Require 2 virtual address as arguments.\n");
		return -1;
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
f010093f:	83 ec 04             	sub    $0x4,%esp
f0100942:	6a 10                	push   $0x10
f0100944:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100947:	50                   	push   %eax
f0100948:	ff 76 04             	pushl  0x4(%esi)
f010094b:	e8 8d 4a 00 00       	call   f01053dd <strtol>
f0100950:	89 c3                	mov    %eax,%ebx
	if (*errChar) {
f0100952:	83 c4 10             	add    $0x10,%esp
f0100955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100958:	80 38 00             	cmpb   $0x0,(%eax)
f010095b:	75 51                	jne    f01009ae <mon_showmappings+0x81>
		cprintf("Invalid virtual address: %s.\n", argv[1]);
		return -1;
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
f010095d:	83 ec 04             	sub    $0x4,%esp
f0100960:	6a 10                	push   $0x10
f0100962:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100965:	50                   	push   %eax
f0100966:	ff 76 08             	pushl  0x8(%esi)
f0100969:	e8 6f 4a 00 00       	call   f01053dd <strtol>
	if (*errChar) {
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100974:	80 3a 00             	cmpb   $0x0,(%edx)
f0100977:	75 52                	jne    f01009cb <mon_showmappings+0x9e>
		cprintf("Invalid virtual address: %s.\n", argv[2]);
		return -1;
	}
	if (start_addr > end_addr) {
f0100979:	39 c3                	cmp    %eax,%ebx
f010097b:	77 6b                	ja     f01009e8 <mon_showmappings+0xbb>
		cprintf("Address 1 must be lower than address 2\n");
		return -1;
	}

	start_addr = ROUNDDOWN(start_addr, PGSIZE);
f010097d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end_addr = ROUNDUP(end_addr, PGSIZE);
f0100983:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100989:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f010098f:	e9 85 00 00 00       	jmp    f0100a19 <mon_showmappings+0xec>

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if (argc != 3) {
		cprintf("Require 2 virtual address as arguments.\n");
f0100994:	83 ec 0c             	sub    $0xc,%esp
f0100997:	68 b8 64 10 f0       	push   $0xf01064b8
f010099c:	e8 b0 31 00 00       	call   f0103b51 <cprintf>
		return -1;
f01009a1:	83 c4 10             	add    $0x10,%esp
f01009a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009a9:	e9 00 01 00 00       	jmp    f0100aae <mon_showmappings+0x181>
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[1]);
f01009ae:	83 ec 08             	sub    $0x8,%esp
f01009b1:	ff 76 04             	pushl  0x4(%esi)
f01009b4:	68 aa 62 10 f0       	push   $0xf01062aa
f01009b9:	e8 93 31 00 00       	call   f0103b51 <cprintf>
		return -1;
f01009be:	83 c4 10             	add    $0x10,%esp
f01009c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009c6:	e9 e3 00 00 00       	jmp    f0100aae <mon_showmappings+0x181>
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[2]);
f01009cb:	83 ec 08             	sub    $0x8,%esp
f01009ce:	ff 76 08             	pushl  0x8(%esi)
f01009d1:	68 aa 62 10 f0       	push   $0xf01062aa
f01009d6:	e8 76 31 00 00       	call   f0103b51 <cprintf>
		return -1;
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009e3:	e9 c6 00 00 00       	jmp    f0100aae <mon_showmappings+0x181>
	}
	if (start_addr > end_addr) {
		cprintf("Address 1 must be lower than address 2\n");
f01009e8:	83 ec 0c             	sub    $0xc,%esp
f01009eb:	68 e4 64 10 f0       	push   $0xf01064e4
f01009f0:	e8 5c 31 00 00       	call   f0103b51 <cprintf>
		return -1;
f01009f5:	83 c4 10             	add    $0x10,%esp
f01009f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009fd:	e9 ac 00 00 00       	jmp    f0100aae <mon_showmappings+0x181>
	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
		// if ( !cur_pte) {
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
f0100a02:	83 ec 08             	sub    $0x8,%esp
f0100a05:	53                   	push   %ebx
f0100a06:	68 0c 65 10 f0       	push   $0xf010650c
f0100a0b:	e8 41 31 00 00       	call   f0103b51 <cprintf>
f0100a10:	83 c4 10             	add    $0x10,%esp
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
			// 进入 else 分支说明 PTE_P 肯定为真了
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
		}
		cur_addr += PGSIZE;
f0100a13:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	start_addr = ROUNDDOWN(start_addr, PGSIZE);
	end_addr = ROUNDUP(end_addr, PGSIZE);

	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f0100a19:	39 fb                	cmp    %edi,%ebx
f0100a1b:	0f 87 88 00 00 00    	ja     f0100aa9 <mon_showmappings+0x17c>
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
f0100a21:	83 ec 04             	sub    $0x4,%esp
f0100a24:	6a 00                	push   $0x0
f0100a26:	53                   	push   %ebx
f0100a27:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0100a2d:	e8 9e 07 00 00       	call   f01011d0 <pgdir_walk>
f0100a32:	89 c6                	mov    %eax,%esi
		// if ( !cur_pte) {
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
f0100a34:	83 c4 10             	add    $0x10,%esp
f0100a37:	85 c0                	test   %eax,%eax
f0100a39:	74 c7                	je     f0100a02 <mon_showmappings+0xd5>
f0100a3b:	8b 00                	mov    (%eax),%eax
f0100a3d:	a8 01                	test   $0x1,%al
f0100a3f:	74 c1                	je     f0100a02 <mon_showmappings+0xd5>
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
		} else {
			cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
f0100a41:	83 ec 04             	sub    $0x4,%esp
f0100a44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a49:	50                   	push   %eax
f0100a4a:	53                   	push   %ebx
f0100a4b:	68 34 65 10 f0       	push   $0xf0106534
f0100a50:	e8 fc 30 00 00       	call   f0103b51 <cprintf>
			char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
f0100a55:	8b 06                	mov    (%esi),%eax
f0100a57:	83 c4 10             	add    $0x10,%esp
f0100a5a:	89 c2                	mov    %eax,%edx
f0100a5c:	81 e2 80 00 00 00    	and    $0x80,%edx
f0100a62:	83 fa 01             	cmp    $0x1,%edx
f0100a65:	19 d2                	sbb    %edx,%edx
f0100a67:	83 e2 da             	and    $0xffffffda,%edx
f0100a6a:	83 c2 53             	add    $0x53,%edx
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
f0100a6d:	89 c1                	mov    %eax,%ecx
f0100a6f:	83 e1 02             	and    $0x2,%ecx
f0100a72:	83 f9 01             	cmp    $0x1,%ecx
f0100a75:	19 c9                	sbb    %ecx,%ecx
f0100a77:	83 e1 d6             	and    $0xffffffd6,%ecx
f0100a7a:	83 c1 57             	add    $0x57,%ecx
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
f0100a7d:	83 e0 04             	and    $0x4,%eax
f0100a80:	83 f8 01             	cmp    $0x1,%eax
f0100a83:	19 c0                	sbb    %eax,%eax
f0100a85:	83 e0 d8             	and    $0xffffffd8,%eax
f0100a88:	83 c0 55             	add    $0x55,%eax
			// 进入 else 分支说明 PTE_P 肯定为真了
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
f0100a8b:	0f be c9             	movsbl %cl,%ecx
f0100a8e:	51                   	push   %ecx
f0100a8f:	0f be c0             	movsbl %al,%eax
f0100a92:	50                   	push   %eax
f0100a93:	0f be d2             	movsbl %dl,%edx
f0100a96:	52                   	push   %edx
f0100a97:	68 c8 62 10 f0       	push   $0xf01062c8
f0100a9c:	e8 b0 30 00 00       	call   f0103b51 <cprintf>
f0100aa1:	83 c4 10             	add    $0x10,%esp
f0100aa4:	e9 6a ff ff ff       	jmp    f0100a13 <mon_showmappings+0xe6>
		}
		cur_addr += PGSIZE;
	}
	return 0;
f0100aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab1:	5b                   	pop    %ebx
f0100ab2:	5e                   	pop    %esi
f0100ab3:	5f                   	pop    %edi
f0100ab4:	5d                   	pop    %ebp
f0100ab5:	c3                   	ret    

f0100ab6 <monitor>:



void
monitor(struct Trapframe *tf)
{
f0100ab6:	55                   	push   %ebp
f0100ab7:	89 e5                	mov    %esp,%ebp
f0100ab9:	57                   	push   %edi
f0100aba:	56                   	push   %esi
f0100abb:	53                   	push   %ebx
f0100abc:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100abf:	68 74 65 10 f0       	push   $0xf0106574
f0100ac4:	e8 88 30 00 00       	call   f0103b51 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ac9:	c7 04 24 98 65 10 f0 	movl   $0xf0106598,(%esp)
f0100ad0:	e8 7c 30 00 00       	call   f0103b51 <cprintf>

	if (tf != NULL)
f0100ad5:	83 c4 10             	add    $0x10,%esp
f0100ad8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100adc:	74 57                	je     f0100b35 <monitor+0x7f>
		print_trapframe(tf);
f0100ade:	83 ec 0c             	sub    $0xc,%esp
f0100ae1:	ff 75 08             	pushl  0x8(%ebp)
f0100ae4:	e8 ef 34 00 00       	call   f0103fd8 <print_trapframe>
f0100ae9:	83 c4 10             	add    $0x10,%esp
f0100aec:	eb 47                	jmp    f0100b35 <monitor+0x7f>
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100aee:	83 ec 08             	sub    $0x8,%esp
f0100af1:	0f be c0             	movsbl %al,%eax
f0100af4:	50                   	push   %eax
f0100af5:	68 da 62 10 f0       	push   $0xf01062da
f0100afa:	e8 95 47 00 00       	call   f0105294 <strchr>
f0100aff:	83 c4 10             	add    $0x10,%esp
f0100b02:	85 c0                	test   %eax,%eax
f0100b04:	74 0a                	je     f0100b10 <monitor+0x5a>
			*buf++ = 0;
f0100b06:	c6 03 00             	movb   $0x0,(%ebx)
f0100b09:	89 f7                	mov    %esi,%edi
f0100b0b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b0e:	eb 68                	jmp    f0100b78 <monitor+0xc2>
		if (*buf == 0)
f0100b10:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b13:	74 6f                	je     f0100b84 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b15:	83 fe 0f             	cmp    $0xf,%esi
f0100b18:	74 09                	je     f0100b23 <monitor+0x6d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f0100b1a:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b1d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b21:	eb 37                	jmp    f0100b5a <monitor+0xa4>
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b23:	83 ec 08             	sub    $0x8,%esp
f0100b26:	6a 10                	push   $0x10
f0100b28:	68 df 62 10 f0       	push   $0xf01062df
f0100b2d:	e8 1f 30 00 00       	call   f0103b51 <cprintf>
f0100b32:	83 c4 10             	add    $0x10,%esp

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
f0100b35:	83 ec 0c             	sub    $0xc,%esp
f0100b38:	68 d6 62 10 f0       	push   $0xf01062d6
f0100b3d:	e8 46 45 00 00       	call   f0105088 <readline>
f0100b42:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b44:	83 c4 10             	add    $0x10,%esp
f0100b47:	85 c0                	test   %eax,%eax
f0100b49:	74 ea                	je     f0100b35 <monitor+0x7f>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b4b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b52:	be 00 00 00 00       	mov    $0x0,%esi
f0100b57:	eb 21                	jmp    f0100b7a <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b59:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b5a:	8a 03                	mov    (%ebx),%al
f0100b5c:	84 c0                	test   %al,%al
f0100b5e:	74 18                	je     f0100b78 <monitor+0xc2>
f0100b60:	83 ec 08             	sub    $0x8,%esp
f0100b63:	0f be c0             	movsbl %al,%eax
f0100b66:	50                   	push   %eax
f0100b67:	68 da 62 10 f0       	push   $0xf01062da
f0100b6c:	e8 23 47 00 00       	call   f0105294 <strchr>
f0100b71:	83 c4 10             	add    $0x10,%esp
f0100b74:	85 c0                	test   %eax,%eax
f0100b76:	74 e1                	je     f0100b59 <monitor+0xa3>
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b78:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b7a:	8a 03                	mov    (%ebx),%al
f0100b7c:	84 c0                	test   %al,%al
f0100b7e:	0f 85 6a ff ff ff    	jne    f0100aee <monitor+0x38>
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f0100b84:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b8b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b8c:	85 f6                	test   %esi,%esi
f0100b8e:	74 a5                	je     f0100b35 <monitor+0x7f>
f0100b90:	bf c0 65 10 f0       	mov    $0xf01065c0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b95:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b9a:	83 ec 08             	sub    $0x8,%esp
f0100b9d:	ff 37                	pushl  (%edi)
f0100b9f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ba2:	e8 99 46 00 00       	call   f0105240 <strcmp>
f0100ba7:	83 c4 10             	add    $0x10,%esp
f0100baa:	85 c0                	test   %eax,%eax
f0100bac:	74 21                	je     f0100bcf <monitor+0x119>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100bae:	43                   	inc    %ebx
f0100baf:	83 c7 0c             	add    $0xc,%edi
f0100bb2:	83 fb 04             	cmp    $0x4,%ebx
f0100bb5:	75 e3                	jne    f0100b9a <monitor+0xe4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bb7:	83 ec 08             	sub    $0x8,%esp
f0100bba:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bbd:	68 fc 62 10 f0       	push   $0xf01062fc
f0100bc2:	e8 8a 2f 00 00       	call   f0103b51 <cprintf>
f0100bc7:	83 c4 10             	add    $0x10,%esp
f0100bca:	e9 66 ff ff ff       	jmp    f0100b35 <monitor+0x7f>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100bcf:	83 ec 04             	sub    $0x4,%esp
f0100bd2:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100bd5:	01 c3                	add    %eax,%ebx
f0100bd7:	ff 75 08             	pushl  0x8(%ebp)
f0100bda:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100bdd:	50                   	push   %eax
f0100bde:	56                   	push   %esi
f0100bdf:	ff 14 9d c8 65 10 f0 	call   *-0xfef9a38(,%ebx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100be6:	83 c4 10             	add    $0x10,%esp
f0100be9:	85 c0                	test   %eax,%eax
f0100beb:	0f 89 44 ff ff ff    	jns    f0100b35 <monitor+0x7f>
				break;
	}
}
f0100bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bf4:	5b                   	pop    %ebx
f0100bf5:	5e                   	pop    %esi
f0100bf6:	5f                   	pop    %edi
f0100bf7:	5d                   	pop    %ebp
f0100bf8:	c3                   	ret    
f0100bf9:	00 00                	add    %al,(%eax)
	...

f0100bfc <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bfc:	55                   	push   %ebp
f0100bfd:	89 e5                	mov    %esp,%ebp
f0100bff:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c01:	83 3d 38 02 29 f0 00 	cmpl   $0x0,0xf0290238
f0100c08:	74 1f                	je     f0100c29 <boot_alloc+0x2d>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    if (n == 0) {
f0100c0a:	85 d2                	test   %edx,%edx
f0100c0c:	74 2c                	je     f0100c3a <boot_alloc+0x3e>
		return nextfree;
	}
	result = nextfree;
f0100c0e:	a1 38 02 29 f0       	mov    0xf0290238,%eax
    nextfree += ROUNDUP(n, PGSIZE);
f0100c13:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100c19:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c1f:	01 c2                	add    %eax,%edx
f0100c21:	89 15 38 02 29 f0    	mov    %edx,0xf0290238

	return result;
}
f0100c27:	5d                   	pop    %ebp
f0100c28:	c3                   	ret    
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
		extern char end[]; // end point to the end of bss seg
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c29:	b8 07 30 2d f0       	mov    $0xf02d3007,%eax
f0100c2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c33:	a3 38 02 29 f0       	mov    %eax,0xf0290238
f0100c38:	eb d0                	jmp    f0100c0a <boot_alloc+0xe>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    if (n == 0) {
		return nextfree;
f0100c3a:	a1 38 02 29 f0       	mov    0xf0290238,%eax
f0100c3f:	eb e6                	jmp    f0100c27 <boot_alloc+0x2b>

f0100c41 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c41:	55                   	push   %ebp
f0100c42:	89 e5                	mov    %esp,%ebp
f0100c44:	56                   	push   %esi
f0100c45:	53                   	push   %ebx
f0100c46:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c48:	83 ec 0c             	sub    $0xc,%esp
f0100c4b:	50                   	push   %eax
f0100c4c:	e8 8b 2d 00 00       	call   f01039dc <mc146818_read>
f0100c51:	89 c3                	mov    %eax,%ebx
f0100c53:	46                   	inc    %esi
f0100c54:	89 34 24             	mov    %esi,(%esp)
f0100c57:	e8 80 2d 00 00       	call   f01039dc <mc146818_read>
f0100c5c:	c1 e0 08             	shl    $0x8,%eax
f0100c5f:	09 d8                	or     %ebx,%eax
}
f0100c61:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c64:	5b                   	pop    %ebx
f0100c65:	5e                   	pop    %esi
f0100c66:	5d                   	pop    %ebp
f0100c67:	c3                   	ret    

f0100c68 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c68:	89 d1                	mov    %edx,%ecx
f0100c6a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c6d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c70:	a8 01                	test   $0x1,%al
f0100c72:	74 47                	je     f0100cbb <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c79:	89 c1                	mov    %eax,%ecx
f0100c7b:	c1 e9 0c             	shr    $0xc,%ecx
f0100c7e:	3b 0d 88 0e 29 f0    	cmp    0xf0290e88,%ecx
f0100c84:	73 1a                	jae    f0100ca0 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100c86:	c1 ea 0c             	shr    $0xc,%edx
f0100c89:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c8f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c96:	a8 01                	test   $0x1,%al
f0100c98:	74 27                	je     f0100cc1 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c9f:	c3                   	ret    
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ca0:	55                   	push   %ebp
f0100ca1:	89 e5                	mov    %esp,%ebp
f0100ca3:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca6:	50                   	push   %eax
f0100ca7:	68 24 5f 10 f0       	push   $0xf0105f24
f0100cac:	68 a0 03 00 00       	push   $0x3a0
f0100cb1:	68 11 6f 10 f0       	push   $0xf0106f11
f0100cb6:	e8 85 f3 ff ff       	call   f0100040 <_panic>
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc0:	c3                   	ret    
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100cc6:	c3                   	ret    

f0100cc7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100cc7:	55                   	push   %ebp
f0100cc8:	89 e5                	mov    %esp,%ebp
f0100cca:	57                   	push   %edi
f0100ccb:	56                   	push   %esi
f0100ccc:	53                   	push   %ebx
f0100ccd:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cd0:	84 c0                	test   %al,%al
f0100cd2:	0f 85 80 02 00 00    	jne    f0100f58 <check_page_free_list+0x291>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cd8:	83 3d 40 02 29 f0 00 	cmpl   $0x0,0xf0290240
f0100cdf:	74 0a                	je     f0100ceb <check_page_free_list+0x24>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ce1:	be 00 04 00 00       	mov    $0x400,%esi
f0100ce6:	e9 c8 02 00 00       	jmp    f0100fb3 <check_page_free_list+0x2ec>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100ceb:	83 ec 04             	sub    $0x4,%esp
f0100cee:	68 f0 65 10 f0       	push   $0xf01065f0
f0100cf3:	68 d3 02 00 00       	push   $0x2d3
f0100cf8:	68 11 6f 10 f0       	push   $0xf0106f11
f0100cfd:	e8 3e f3 ff ff       	call   f0100040 <_panic>
f0100d02:	50                   	push   %eax
f0100d03:	68 24 5f 10 f0       	push   $0xf0105f24
f0100d08:	6a 58                	push   $0x58
f0100d0a:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0100d0f:	e8 2c f3 ff ff       	call   f0100040 <_panic>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d14:	8b 1b                	mov    (%ebx),%ebx
f0100d16:	85 db                	test   %ebx,%ebx
f0100d18:	74 41                	je     f0100d5b <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d1a:	89 d8                	mov    %ebx,%eax
f0100d1c:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0100d22:	c1 f8 03             	sar    $0x3,%eax
f0100d25:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d28:	89 c2                	mov    %eax,%edx
f0100d2a:	c1 ea 16             	shr    $0x16,%edx
f0100d2d:	39 f2                	cmp    %esi,%edx
f0100d2f:	73 e3                	jae    f0100d14 <check_page_free_list+0x4d>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d31:	89 c2                	mov    %eax,%edx
f0100d33:	c1 ea 0c             	shr    $0xc,%edx
f0100d36:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f0100d3c:	73 c4                	jae    f0100d02 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100d3e:	83 ec 04             	sub    $0x4,%esp
f0100d41:	68 80 00 00 00       	push   $0x80
f0100d46:	68 97 00 00 00       	push   $0x97
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100d4b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d50:	50                   	push   %eax
f0100d51:	e8 73 45 00 00       	call   f01052c9 <memset>
f0100d56:	83 c4 10             	add    $0x10,%esp
f0100d59:	eb b9                	jmp    f0100d14 <check_page_free_list+0x4d>

	first_free_page = (char *) boot_alloc(0);
f0100d5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d60:	e8 97 fe ff ff       	call   f0100bfc <boot_alloc>
f0100d65:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d68:	8b 15 40 02 29 f0    	mov    0xf0290240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d6e:	8b 0d 90 0e 29 f0    	mov    0xf0290e90,%ecx
		assert(pp < pages + npages);
f0100d74:	a1 88 0e 29 f0       	mov    0xf0290e88,%eax
f0100d79:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100d7c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d82:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d85:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d8a:	e9 00 01 00 00       	jmp    f0100e8f <check_page_free_list+0x1c8>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d8f:	68 2b 6f 10 f0       	push   $0xf0106f2b
f0100d94:	68 37 6f 10 f0       	push   $0xf0106f37
f0100d99:	68 ed 02 00 00       	push   $0x2ed
f0100d9e:	68 11 6f 10 f0       	push   $0xf0106f11
f0100da3:	e8 98 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100da8:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0100dad:	68 37 6f 10 f0       	push   $0xf0106f37
f0100db2:	68 ee 02 00 00       	push   $0x2ee
f0100db7:	68 11 6f 10 f0       	push   $0xf0106f11
f0100dbc:	e8 7f f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dc1:	68 14 66 10 f0       	push   $0xf0106614
f0100dc6:	68 37 6f 10 f0       	push   $0xf0106f37
f0100dcb:	68 ef 02 00 00       	push   $0x2ef
f0100dd0:	68 11 6f 10 f0       	push   $0xf0106f11
f0100dd5:	e8 66 f2 ff ff       	call   f0100040 <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100dda:	68 60 6f 10 f0       	push   $0xf0106f60
f0100ddf:	68 37 6f 10 f0       	push   $0xf0106f37
f0100de4:	68 f2 02 00 00       	push   $0x2f2
f0100de9:	68 11 6f 10 f0       	push   $0xf0106f11
f0100dee:	e8 4d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100df3:	68 71 6f 10 f0       	push   $0xf0106f71
f0100df8:	68 37 6f 10 f0       	push   $0xf0106f37
f0100dfd:	68 f3 02 00 00       	push   $0x2f3
f0100e02:	68 11 6f 10 f0       	push   $0xf0106f11
f0100e07:	e8 34 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e0c:	68 48 66 10 f0       	push   $0xf0106648
f0100e11:	68 37 6f 10 f0       	push   $0xf0106f37
f0100e16:	68 f4 02 00 00       	push   $0x2f4
f0100e1b:	68 11 6f 10 f0       	push   $0xf0106f11
f0100e20:	e8 1b f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e25:	68 8a 6f 10 f0       	push   $0xf0106f8a
f0100e2a:	68 37 6f 10 f0       	push   $0xf0106f37
f0100e2f:	68 f5 02 00 00       	push   $0x2f5
f0100e34:	68 11 6f 10 f0       	push   $0xf0106f11
f0100e39:	e8 02 f2 ff ff       	call   f0100040 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3e:	89 c7                	mov    %eax,%edi
f0100e40:	c1 ef 0c             	shr    $0xc,%edi
f0100e43:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100e46:	76 19                	jbe    f0100e61 <check_page_free_list+0x19a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100e48:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e4e:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100e51:	77 20                	ja     f0100e73 <check_page_free_list+0x1ac>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e53:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e58:	0f 84 92 00 00 00    	je     f0100ef0 <check_page_free_list+0x229>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
f0100e5e:	43                   	inc    %ebx
f0100e5f:	eb 2c                	jmp    f0100e8d <check_page_free_list+0x1c6>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e61:	50                   	push   %eax
f0100e62:	68 24 5f 10 f0       	push   $0xf0105f24
f0100e67:	6a 58                	push   $0x58
f0100e69:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0100e6e:	e8 cd f1 ff ff       	call   f0100040 <_panic>
		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e73:	68 6c 66 10 f0       	push   $0xf010666c
f0100e78:	68 37 6f 10 f0       	push   $0xf0106f37
f0100e7d:	68 f6 02 00 00       	push   $0x2f6
f0100e82:	68 11 6f 10 f0       	push   $0xf0106f11
f0100e87:	e8 b4 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e8c:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e8d:	8b 12                	mov    (%edx),%edx
f0100e8f:	85 d2                	test   %edx,%edx
f0100e91:	74 76                	je     f0100f09 <check_page_free_list+0x242>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100e93:	39 d1                	cmp    %edx,%ecx
f0100e95:	0f 87 f4 fe ff ff    	ja     f0100d8f <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100e9b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100e9e:	0f 86 04 ff ff ff    	jbe    f0100da8 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ea4:	89 d0                	mov    %edx,%eax
f0100ea6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ea9:	a8 07                	test   $0x7,%al
f0100eab:	0f 85 10 ff ff ff    	jne    f0100dc1 <check_page_free_list+0xfa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100eb1:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100eb4:	c1 e0 0c             	shl    $0xc,%eax
f0100eb7:	0f 84 1d ff ff ff    	je     f0100dda <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ebd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ec2:	0f 84 2b ff ff ff    	je     f0100df3 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ec8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ecd:	0f 84 39 ff ff ff    	je     f0100e0c <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ed3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ed8:	0f 84 47 ff ff ff    	je     f0100e25 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ede:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ee3:	0f 87 55 ff ff ff    	ja     f0100e3e <check_page_free_list+0x177>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ee9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eee:	75 9c                	jne    f0100e8c <check_page_free_list+0x1c5>
f0100ef0:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0100ef5:	68 37 6f 10 f0       	push   $0xf0106f37
f0100efa:	68 f8 02 00 00       	push   $0x2f8
f0100eff:	68 11 6f 10 f0       	push   $0xf0106f11
f0100f04:	e8 37 f1 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f09:	85 f6                	test   %esi,%esi
f0100f0b:	7e 19                	jle    f0100f26 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f0100f0d:	85 db                	test   %ebx,%ebx
f0100f0f:	7e 2e                	jle    f0100f3f <check_page_free_list+0x278>

	cprintf("check_page_free_list() succeeded!\n");
f0100f11:	83 ec 0c             	sub    $0xc,%esp
f0100f14:	68 b4 66 10 f0       	push   $0xf01066b4
f0100f19:	e8 33 2c 00 00       	call   f0103b51 <cprintf>
}
f0100f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f21:	5b                   	pop    %ebx
f0100f22:	5e                   	pop    %esi
f0100f23:	5f                   	pop    %edi
f0100f24:	5d                   	pop    %ebp
f0100f25:	c3                   	ret    
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f26:	68 c1 6f 10 f0       	push   $0xf0106fc1
f0100f2b:	68 37 6f 10 f0       	push   $0xf0106f37
f0100f30:	68 00 03 00 00       	push   $0x300
f0100f35:	68 11 6f 10 f0       	push   $0xf0106f11
f0100f3a:	e8 01 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f3f:	68 d3 6f 10 f0       	push   $0xf0106fd3
f0100f44:	68 37 6f 10 f0       	push   $0xf0106f37
f0100f49:	68 01 03 00 00       	push   $0x301
f0100f4e:	68 11 6f 10 f0       	push   $0xf0106f11
f0100f53:	e8 e8 f0 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f58:	a1 40 02 29 f0       	mov    0xf0290240,%eax
f0100f5d:	85 c0                	test   %eax,%eax
f0100f5f:	0f 84 86 fd ff ff    	je     f0100ceb <check_page_free_list+0x24>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f65:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f68:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f6b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100f71:	89 c2                	mov    %eax,%edx
f0100f73:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f79:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f7f:	0f 95 c2             	setne  %dl
f0100f82:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f85:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f89:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f8b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f8f:	8b 00                	mov    (%eax),%eax
f0100f91:	85 c0                	test   %eax,%eax
f0100f93:	75 dc                	jne    f0100f71 <check_page_free_list+0x2aa>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa4:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fa6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fa9:	a3 40 02 29 f0       	mov    %eax,0xf0290240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fae:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fb3:	8b 1d 40 02 29 f0    	mov    0xf0290240,%ebx
f0100fb9:	e9 58 fd ff ff       	jmp    f0100d16 <check_page_free_list+0x4f>

f0100fbe <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fbe:	55                   	push   %ebp
f0100fbf:	89 e5                	mov    %esp,%ebp
f0100fc1:	57                   	push   %edi
f0100fc2:	56                   	push   %esi
f0100fc3:	53                   	push   %ebx
f0100fc4:	83 ec 0c             	sub    $0xc,%esp
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
    pages[0].pp_ref = 1;
f0100fc7:	a1 90 0e 29 f0       	mov    0xf0290e90,%eax
f0100fcc:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	size_t mp_page = MPENTRY_PADDR/PGSIZE;
	for (size_t i = 1; i < npages_basemem; i++) {
f0100fd2:	8b 35 44 02 29 f0    	mov    0xf0290244,%esi
f0100fd8:	8b 1d 40 02 29 f0    	mov    0xf0290240,%ebx
f0100fde:	b2 00                	mov    $0x0,%dl
f0100fe0:	b8 01 00 00 00       	mov    $0x1,%eax
			pages[i].pp_ref = 1;
			continue;
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100fe5:	bf 01 00 00 00       	mov    $0x1,%edi
    pages[0].pp_ref = 1;

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	size_t mp_page = MPENTRY_PADDR/PGSIZE;
	for (size_t i = 1; i < npages_basemem; i++) {
f0100fea:	eb 0d                	jmp    f0100ff9 <page_init+0x3b>
		if (i == mp_page) {
			pages[i].pp_ref = 1;
f0100fec:	8b 0d 90 0e 29 f0    	mov    0xf0290e90,%ecx
f0100ff2:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
    pages[0].pp_ref = 1;

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	size_t mp_page = MPENTRY_PADDR/PGSIZE;
	for (size_t i = 1; i < npages_basemem; i++) {
f0100ff8:	40                   	inc    %eax
f0100ff9:	39 c6                	cmp    %eax,%esi
f0100ffb:	76 28                	jbe    f0101025 <page_init+0x67>
		if (i == mp_page) {
f0100ffd:	83 f8 07             	cmp    $0x7,%eax
f0101000:	74 ea                	je     f0100fec <page_init+0x2e>
			pages[i].pp_ref = 1;
			continue;
		}
		pages[i].pp_ref = 0;
f0101002:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101009:	89 d1                	mov    %edx,%ecx
f010100b:	03 0d 90 0e 29 f0    	add    0xf0290e90,%ecx
f0101011:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101017:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101019:	89 d3                	mov    %edx,%ebx
f010101b:	03 1d 90 0e 29 f0    	add    0xf0290e90,%ebx
f0101021:	89 fa                	mov    %edi,%edx
f0101023:	eb d3                	jmp    f0100ff8 <page_init+0x3a>
f0101025:	84 d2                	test   %dl,%dl
f0101027:	75 44                	jne    f010106d <page_init+0xaf>
	}

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	for (size_t i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0101029:	8b 15 90 0e 29 f0    	mov    0xf0290e90,%edx
f010102f:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0101035:	81 c2 04 08 00 00    	add    $0x804,%edx
f010103b:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0101040:	83 c0 08             	add    $0x8,%eax
		page_free_list = &pages[i];
	}

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	for (size_t i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0101043:	39 d0                	cmp    %edx,%eax
f0101045:	75 f4                	jne    f010103b <page_init+0x7d>
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
f0101047:	b8 00 00 00 00       	mov    $0x0,%eax
f010104c:	e8 ab fb ff ff       	call   f0100bfc <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101051:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101056:	76 1d                	jbe    f0101075 <page_init+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101058:	05 00 00 00 10       	add    $0x10000000,%eax
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f010105d:	c1 e8 0c             	shr    $0xc,%eax
		pages[i].pp_ref = 1;
f0101060:	8b 0d 90 0e 29 f0    	mov    0xf0290e90,%ecx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0101066:	ba 00 01 00 00       	mov    $0x100,%edx
f010106b:	eb 25                	jmp    f0101092 <page_init+0xd4>
f010106d:	89 1d 40 02 29 f0    	mov    %ebx,0xf0290240
f0101073:	eb b4                	jmp    f0101029 <page_init+0x6b>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101075:	50                   	push   %eax
f0101076:	68 48 5f 10 f0       	push   $0xf0105f48
f010107b:	68 4a 01 00 00       	push   $0x14a
f0101080:	68 11 6f 10 f0       	push   $0xf0106f11
f0101085:	e8 b6 ef ff ff       	call   f0100040 <_panic>
		pages[i].pp_ref = 1;
f010108a:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0101091:	42                   	inc    %edx
f0101092:	39 d0                	cmp    %edx,%eax
f0101094:	77 f4                	ja     f010108a <page_init+0xcc>
f0101096:	8b 1d 40 02 29 f0    	mov    0xf0290240,%ebx
f010109c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01010a3:	b1 00                	mov    $0x0,%cl
f01010a5:	be 01 00 00 00       	mov    $0x1,%esi
f01010aa:	eb 1e                	jmp    f01010ca <page_init+0x10c>
	// LAB 4:
	// Change your code to mark the physical page at MPENTRY_PADDR
	// as in use
	for (size_t i = first_free_address/PGSIZE; i < npages; i++) {

		pages[i].pp_ref = 0;
f01010ac:	89 d1                	mov    %edx,%ecx
f01010ae:	03 0d 90 0e 29 f0    	add    0xf0290e90,%ecx
f01010b4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010ba:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01010bc:	89 d3                	mov    %edx,%ebx
f01010be:	03 1d 90 0e 29 f0    	add    0xf0290e90,%ebx
	}

	// LAB 4:
	// Change your code to mark the physical page at MPENTRY_PADDR
	// as in use
	for (size_t i = first_free_address/PGSIZE; i < npages; i++) {
f01010c4:	40                   	inc    %eax
f01010c5:	83 c2 08             	add    $0x8,%edx
f01010c8:	89 f1                	mov    %esi,%ecx
f01010ca:	39 05 88 0e 29 f0    	cmp    %eax,0xf0290e88
f01010d0:	77 da                	ja     f01010ac <page_init+0xee>
f01010d2:	84 c9                	test   %cl,%cl
f01010d4:	75 08                	jne    f01010de <page_init+0x120>

		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01010d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010d9:	5b                   	pop    %ebx
f01010da:	5e                   	pop    %esi
f01010db:	5f                   	pop    %edi
f01010dc:	5d                   	pop    %ebp
f01010dd:	c3                   	ret    
f01010de:	89 1d 40 02 29 f0    	mov    %ebx,0xf0290240
f01010e4:	eb f0                	jmp    f01010d6 <page_init+0x118>

f01010e6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010e6:	55                   	push   %ebp
f01010e7:	89 e5                	mov    %esp,%ebp
f01010e9:	53                   	push   %ebx
f01010ea:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL) {
f01010ed:	8b 1d 40 02 29 f0    	mov    0xf0290240,%ebx
f01010f3:	85 db                	test   %ebx,%ebx
f01010f5:	74 13                	je     f010110a <page_alloc+0x24>
		return NULL;
	}
	// get the first node from page_free_list
	struct PageInfo* allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f01010f7:	8b 03                	mov    (%ebx),%eax
f01010f9:	a3 40 02 29 f0       	mov    %eax,0xf0290240
	allocated_page->pp_link = NULL;
f01010fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101104:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101108:	75 07                	jne    f0101111 <page_alloc+0x2b>
		memset(page2kva(allocated_page), '\0', PGSIZE);
	}
 	return allocated_page;
}
f010110a:	89 d8                	mov    %ebx,%eax
f010110c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010110f:	c9                   	leave  
f0101110:	c3                   	ret    
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101111:	89 d8                	mov    %ebx,%eax
f0101113:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0101119:	c1 f8 03             	sar    $0x3,%eax
f010111c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010111f:	89 c2                	mov    %eax,%edx
f0101121:	c1 ea 0c             	shr    $0xc,%edx
f0101124:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f010112a:	73 1a                	jae    f0101146 <page_alloc+0x60>
	// get the first node from page_free_list
	struct PageInfo* allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
	allocated_page->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) {
		memset(page2kva(allocated_page), '\0', PGSIZE);
f010112c:	83 ec 04             	sub    $0x4,%esp
f010112f:	68 00 10 00 00       	push   $0x1000
f0101134:	6a 00                	push   $0x0
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101136:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010113b:	50                   	push   %eax
f010113c:	e8 88 41 00 00       	call   f01052c9 <memset>
f0101141:	83 c4 10             	add    $0x10,%esp
f0101144:	eb c4                	jmp    f010110a <page_alloc+0x24>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101146:	50                   	push   %eax
f0101147:	68 24 5f 10 f0       	push   $0xf0105f24
f010114c:	6a 58                	push   $0x58
f010114e:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0101153:	e8 e8 ee ff ff       	call   f0100040 <_panic>

f0101158 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101158:	55                   	push   %ebp
f0101159:	89 e5                	mov    %esp,%ebp
f010115b:	83 ec 08             	sub    $0x8,%esp
f010115e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0101161:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101166:	75 14                	jne    f010117c <page_free+0x24>
		panic("pp_ref is nonzero");
        return;
	}

	if (pp->pp_link != NULL) {
f0101168:	83 38 00             	cmpl   $0x0,(%eax)
f010116b:	75 26                	jne    f0101193 <page_free+0x3b>
		panic("pp_link is nonNULL");
		return;
	}

	pp->pp_link = page_free_list;
f010116d:	8b 15 40 02 29 f0    	mov    0xf0290240,%edx
f0101173:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101175:	a3 40 02 29 f0       	mov    %eax,0xf0290240
}
f010117a:	c9                   	leave  
f010117b:	c3                   	ret    
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
		panic("pp_ref is nonzero");
f010117c:	83 ec 04             	sub    $0x4,%esp
f010117f:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0101184:	68 82 01 00 00       	push   $0x182
f0101189:	68 11 6f 10 f0       	push   $0xf0106f11
f010118e:	e8 ad ee ff ff       	call   f0100040 <_panic>
        return;
	}

	if (pp->pp_link != NULL) {
		panic("pp_link is nonNULL");
f0101193:	83 ec 04             	sub    $0x4,%esp
f0101196:	68 f6 6f 10 f0       	push   $0xf0106ff6
f010119b:	68 87 01 00 00       	push   $0x187
f01011a0:	68 11 6f 10 f0       	push   $0xf0106f11
f01011a5:	e8 96 ee ff ff       	call   f0100040 <_panic>

f01011aa <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01011aa:	55                   	push   %ebp
f01011ab:	89 e5                	mov    %esp,%ebp
f01011ad:	83 ec 08             	sub    $0x8,%esp
f01011b0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01011b3:	8b 42 04             	mov    0x4(%edx),%eax
f01011b6:	48                   	dec    %eax
f01011b7:	66 89 42 04          	mov    %ax,0x4(%edx)
f01011bb:	66 85 c0             	test   %ax,%ax
f01011be:	74 02                	je     f01011c2 <page_decref+0x18>
		page_free(pp);
}
f01011c0:	c9                   	leave  
f01011c1:	c3                   	ret    
//
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
f01011c2:	83 ec 0c             	sub    $0xc,%esp
f01011c5:	52                   	push   %edx
f01011c6:	e8 8d ff ff ff       	call   f0101158 <page_free>
f01011cb:	83 c4 10             	add    $0x10,%esp
}
f01011ce:	eb f0                	jmp    f01011c0 <page_decref+0x16>

f01011d0 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011d0:	55                   	push   %ebp
f01011d1:	89 e5                	mov    %esp,%ebp
f01011d3:	56                   	push   %esi
f01011d4:	53                   	push   %ebx
f01011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function in
	uint32_t page_dir_idx = PDX(va);
	uint32_t page_tab_idx = PTX(va);
f01011d8:	89 c6                	mov    %eax,%esi
f01011da:	c1 ee 0c             	shr    $0xc,%esi
f01011dd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	uint32_t page_dir_idx = PDX(va);
f01011e3:	c1 e8 16             	shr    $0x16,%eax
	uint32_t page_tab_idx = PTX(va);
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
f01011e6:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01011ed:	03 5d 08             	add    0x8(%ebp),%ebx
f01011f0:	8b 03                	mov    (%ebx),%eax
f01011f2:	a8 01                	test   $0x1,%al
f01011f4:	74 37                	je     f010122d <pgdir_walk+0x5d>
		pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
f01011f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011fb:	89 c2                	mov    %eax,%edx
f01011fd:	c1 ea 0c             	shr    $0xc,%edx
f0101200:	39 15 88 0e 29 f0    	cmp    %edx,0xf0290e88
f0101206:	76 10                	jbe    f0101218 <pgdir_walk+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101208:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
			}
		} else {
			return NULL;
		}
	}
	return &pgtab[page_tab_idx];
f010120e:	8d 04 b2             	lea    (%edx,%esi,4),%eax
}
f0101211:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101214:	5b                   	pop    %ebx
f0101215:	5e                   	pop    %esi
f0101216:	5d                   	pop    %ebp
f0101217:	c3                   	ret    

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101218:	50                   	push   %eax
f0101219:	68 24 5f 10 f0       	push   $0xf0105f24
f010121e:	68 b8 01 00 00       	push   $0x1b8
f0101223:	68 11 6f 10 f0       	push   $0xf0106f11
f0101228:	e8 13 ee ff ff       	call   f0100040 <_panic>
	uint32_t page_tab_idx = PTX(va);
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
		pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
	} else {
		if (create) {
f010122d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101231:	74 6c                	je     f010129f <pgdir_walk+0xcf>
            struct PageInfo *newPageInfo = page_alloc(ALLOC_ZERO);
f0101233:	83 ec 0c             	sub    $0xc,%esp
f0101236:	6a 01                	push   $0x1
f0101238:	e8 a9 fe ff ff       	call   f01010e6 <page_alloc>
			if (newPageInfo) {
f010123d:	83 c4 10             	add    $0x10,%esp
f0101240:	85 c0                	test   %eax,%eax
f0101242:	74 65                	je     f01012a9 <pgdir_walk+0xd9>
				newPageInfo->pp_ref += 1;
f0101244:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101248:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f010124e:	c1 f8 03             	sar    $0x3,%eax
f0101251:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101254:	89 c2                	mov    %eax,%edx
f0101256:	c1 ea 0c             	shr    $0xc,%edx
f0101259:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f010125f:	73 17                	jae    f0101278 <pgdir_walk+0xa8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101261:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0101267:	89 ca                	mov    %ecx,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101269:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010126f:	76 19                	jbe    f010128a <pgdir_walk+0xba>
				pgtab = (pte_t *) page2kva(newPageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f0101271:	83 c8 07             	or     $0x7,%eax
f0101274:	89 03                	mov    %eax,(%ebx)
f0101276:	eb 96                	jmp    f010120e <pgdir_walk+0x3e>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101278:	50                   	push   %eax
f0101279:	68 24 5f 10 f0       	push   $0xf0105f24
f010127e:	6a 58                	push   $0x58
f0101280:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0101285:	e8 b6 ed ff ff       	call   f0100040 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010128a:	51                   	push   %ecx
f010128b:	68 48 5f 10 f0       	push   $0xf0105f48
f0101290:	68 bf 01 00 00       	push   $0x1bf
f0101295:	68 11 6f 10 f0       	push   $0xf0106f11
f010129a:	e8 a1 ed ff ff       	call   f0100040 <_panic>
			} else {
				return NULL;
			}
		} else {
			return NULL;
f010129f:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a4:	e9 68 ff ff ff       	jmp    f0101211 <pgdir_walk+0x41>
			if (newPageInfo) {
				newPageInfo->pp_ref += 1;
				pgtab = (pte_t *) page2kva(newPageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
			} else {
				return NULL;
f01012a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ae:	e9 5e ff ff ff       	jmp    f0101211 <pgdir_walk+0x41>

f01012b3 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012b3:	55                   	push   %ebp
f01012b4:	89 e5                	mov    %esp,%ebp
f01012b6:	57                   	push   %edi
f01012b7:	56                   	push   %esi
f01012b8:	53                   	push   %ebx
f01012b9:	83 ec 1c             	sub    $0x1c,%esp
f01012bc:	89 c7                	mov    %eax,%edi
f01012be:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
f01012c1:	c1 e9 0c             	shr    $0xc,%ecx
f01012c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i=0; i<pg_num; i++) {
f01012c7:	89 c3                	mov    %eax,%ebx
f01012c9:	be 00 00 00 00       	mov    $0x0,%esi
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01012ce:	29 c2                	sub    %eax,%edx
f01012d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		if (!pgtab) {
			return;
		}
		*pgtab = pa | perm | PTE_P;
f01012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012d6:	83 c8 01             	or     $0x1,%eax
f01012d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
	for (size_t i=0; i<pg_num; i++) {
f01012dc:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01012df:	74 28                	je     f0101309 <boot_map_region+0x56>
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01012e1:	83 ec 04             	sub    $0x4,%esp
f01012e4:	6a 01                	push   $0x1
f01012e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012e9:	01 d8                	add    %ebx,%eax
f01012eb:	50                   	push   %eax
f01012ec:	57                   	push   %edi
f01012ed:	e8 de fe ff ff       	call   f01011d0 <pgdir_walk>
		if (!pgtab) {
f01012f2:	83 c4 10             	add    $0x10,%esp
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	74 10                	je     f0101309 <boot_map_region+0x56>
			return;
		}
		*pgtab = pa | perm | PTE_P;
f01012f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012fc:	09 da                	or     %ebx,%edx
f01012fe:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f0101300:	81 c3 00 10 00 00    	add    $0x1000,%ebx
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
	for (size_t i=0; i<pg_num; i++) {
f0101306:	46                   	inc    %esi
f0101307:	eb d3                	jmp    f01012dc <boot_map_region+0x29>
		}
		*pgtab = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f0101309:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010130c:	5b                   	pop    %ebx
f010130d:	5e                   	pop    %esi
f010130e:	5f                   	pop    %edi
f010130f:	5d                   	pop    %ebp
f0101310:	c3                   	ret    

f0101311 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101311:	55                   	push   %ebp
f0101312:	89 e5                	mov    %esp,%ebp
f0101314:	53                   	push   %ebx
f0101315:	83 ec 08             	sub    $0x8,%esp
f0101318:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
f010131b:	6a 00                	push   $0x0
f010131d:	ff 75 0c             	pushl  0xc(%ebp)
f0101320:	ff 75 08             	pushl  0x8(%ebp)
f0101323:	e8 a8 fe ff ff       	call   f01011d0 <pgdir_walk>
    if (!pgtab) {
f0101328:	83 c4 10             	add    $0x10,%esp
f010132b:	85 c0                	test   %eax,%eax
f010132d:	74 35                	je     f0101364 <page_lookup+0x53>
		return NULL;
	}
	if (pte_store != NULL) {
f010132f:	85 db                	test   %ebx,%ebx
f0101331:	74 02                	je     f0101335 <page_lookup+0x24>
		*pte_store = pgtab;
f0101333:	89 03                	mov    %eax,(%ebx)
f0101335:	8b 00                	mov    (%eax),%eax
f0101337:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010133a:	39 05 88 0e 29 f0    	cmp    %eax,0xf0290e88
f0101340:	76 0e                	jbe    f0101350 <page_lookup+0x3f>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101342:	8b 15 90 0e 29 f0    	mov    0xf0290e90,%edx
f0101348:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}

	return pa2page(PTE_ADDR(*pgtab));
}
f010134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010134e:	c9                   	leave  
f010134f:	c3                   	ret    

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f0101350:	83 ec 04             	sub    $0x4,%esp
f0101353:	68 d8 66 10 f0       	push   $0xf01066d8
f0101358:	6a 51                	push   $0x51
f010135a:	68 1d 6f 10 f0       	push   $0xf0106f1d
f010135f:	e8 dc ec ff ff       	call   f0100040 <_panic>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
    if (!pgtab) {
		return NULL;
f0101364:	b8 00 00 00 00       	mov    $0x0,%eax
f0101369:	eb e0                	jmp    f010134b <page_lookup+0x3a>

f010136b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010136b:	55                   	push   %ebp
f010136c:	89 e5                	mov    %esp,%ebp
f010136e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101371:	e8 62 45 00 00       	call   f01058d8 <cpunum>
f0101376:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0101379:	01 c2                	add    %eax,%edx
f010137b:	01 d2                	add    %edx,%edx
f010137d:	01 c2                	add    %eax,%edx
f010137f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101382:	83 3c 85 28 10 29 f0 	cmpl   $0x0,-0xfd6efd8(,%eax,4)
f0101389:	00 
f010138a:	74 20                	je     f01013ac <tlb_invalidate+0x41>
f010138c:	e8 47 45 00 00       	call   f01058d8 <cpunum>
f0101391:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0101394:	01 c2                	add    %eax,%edx
f0101396:	01 d2                	add    %edx,%edx
f0101398:	01 c2                	add    %eax,%edx
f010139a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010139d:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01013a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013a7:	39 48 60             	cmp    %ecx,0x60(%eax)
f01013aa:	75 06                	jne    f01013b2 <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01013ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013af:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01013b2:	c9                   	leave  
f01013b3:	c3                   	ret    

f01013b4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01013b4:	55                   	push   %ebp
f01013b5:	89 e5                	mov    %esp,%ebp
f01013b7:	56                   	push   %esi
f01013b8:	53                   	push   %ebx
f01013b9:	83 ec 14             	sub    $0x14,%esp
f01013bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pgtab;
	pte_t **pte_store = &pgtab;
    struct PageInfo* pageInfo = page_lookup(pgdir, va, pte_store);
f01013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013c5:	50                   	push   %eax
f01013c6:	56                   	push   %esi
f01013c7:	53                   	push   %ebx
f01013c8:	e8 44 ff ff ff       	call   f0101311 <page_lookup>
	if (pageInfo == NULL) {
f01013cd:	83 c4 10             	add    $0x10,%esp
f01013d0:	85 c0                	test   %eax,%eax
f01013d2:	75 07                	jne    f01013db <page_remove+0x27>
	}
	page_decref(pageInfo);
	*pgtab = 0;
	tlb_invalidate(pgdir, va);

}
f01013d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013d7:	5b                   	pop    %ebx
f01013d8:	5e                   	pop    %esi
f01013d9:	5d                   	pop    %ebp
f01013da:	c3                   	ret    
	pte_t **pte_store = &pgtab;
    struct PageInfo* pageInfo = page_lookup(pgdir, va, pte_store);
	if (pageInfo == NULL) {
		return;
	}
	page_decref(pageInfo);
f01013db:	83 ec 0c             	sub    $0xc,%esp
f01013de:	50                   	push   %eax
f01013df:	e8 c6 fd ff ff       	call   f01011aa <page_decref>
	*pgtab = 0;
f01013e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01013ed:	83 c4 08             	add    $0x8,%esp
f01013f0:	56                   	push   %esi
f01013f1:	53                   	push   %ebx
f01013f2:	e8 74 ff ff ff       	call   f010136b <tlb_invalidate>
f01013f7:	83 c4 10             	add    $0x10,%esp
f01013fa:	eb d8                	jmp    f01013d4 <page_remove+0x20>

f01013fc <page_insert>:
 * va    线性地址
 * perm  权限
 */
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01013fc:	55                   	push   %ebp
f01013fd:	89 e5                	mov    %esp,%ebp
f01013ff:	57                   	push   %edi
f0101400:	56                   	push   %esi
f0101401:	53                   	push   %ebx
f0101402:	83 ec 10             	sub    $0x10,%esp
f0101405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101408:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
f010140b:	6a 01                	push   $0x1
f010140d:	57                   	push   %edi
f010140e:	ff 75 08             	pushl  0x8(%ebp)
f0101411:	e8 ba fd ff ff       	call   f01011d0 <pgdir_walk>
	if (!pgtab) {
f0101416:	83 c4 10             	add    $0x10,%esp
f0101419:	85 c0                	test   %eax,%eax
f010141b:	74 3f                	je     f010145c <page_insert+0x60>
f010141d:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	}

	pp->pp_ref++;
f010141f:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pgtab & PTE_P) {
f0101423:	f6 00 01             	testb  $0x1,(%eax)
f0101426:	75 23                	jne    f010144b <page_insert+0x4f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101428:	2b 1d 90 0e 29 f0    	sub    0xf0290e90,%ebx
f010142e:	c1 fb 03             	sar    $0x3,%ebx
f0101431:	c1 e3 0c             	shl    $0xc,%ebx
		page_remove(pgdir, va);
	}

	*pgtab = page2pa(pp) | perm | PTE_P;
f0101434:	8b 45 14             	mov    0x14(%ebp),%eax
f0101437:	83 c8 01             	or     $0x1,%eax
f010143a:	09 c3                	or     %eax,%ebx
f010143c:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010143e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101443:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101446:	5b                   	pop    %ebx
f0101447:	5e                   	pop    %esi
f0101448:	5f                   	pop    %edi
f0101449:	5d                   	pop    %ebp
f010144a:	c3                   	ret    
		return -E_NO_MEM;
	}

	pp->pp_ref++;
	if (*pgtab & PTE_P) {
		page_remove(pgdir, va);
f010144b:	83 ec 08             	sub    $0x8,%esp
f010144e:	57                   	push   %edi
f010144f:	ff 75 08             	pushl  0x8(%ebp)
f0101452:	e8 5d ff ff ff       	call   f01013b4 <page_remove>
f0101457:	83 c4 10             	add    $0x10,%esp
f010145a:	eb cc                	jmp    f0101428 <page_insert+0x2c>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
	if (!pgtab) {
		return -E_NO_MEM;
f010145c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101461:	eb e0                	jmp    f0101443 <page_insert+0x47>

f0101463 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101463:	55                   	push   %ebp
f0101464:	89 e5                	mov    %esp,%ebp
f0101466:	53                   	push   %ebx
f0101467:	83 ec 04             	sub    $0x4,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size_t pgsize = ROUNDUP(size, PGSIZE);
f010146a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010146d:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101473:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + pgsize > MMIOLIM) panic("overflow MMIOLIM");
f0101479:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010147f:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101482:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101487:	77 26                	ja     f01014af <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, pgsize, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101489:	83 ec 08             	sub    $0x8,%esp
f010148c:	6a 1a                	push   $0x1a
f010148e:	ff 75 08             	pushl  0x8(%ebp)
f0101491:	89 d9                	mov    %ebx,%ecx
f0101493:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101498:	e8 16 fe ff ff       	call   f01012b3 <boot_map_region>

    uintptr_t result_base = base;
f010149d:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base += pgsize;
f01014a2:	01 c3                	add    %eax,%ebx
f01014a4:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300

	return (void *)result_base;
	// panic("mmio_map_region not implemented");
}
f01014aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014ad:	c9                   	leave  
f01014ae:	c3                   	ret    
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size_t pgsize = ROUNDUP(size, PGSIZE);
	if (base + pgsize > MMIOLIM) panic("overflow MMIOLIM");
f01014af:	83 ec 04             	sub    $0x4,%esp
f01014b2:	68 09 70 10 f0       	push   $0xf0107009
f01014b7:	68 7f 02 00 00       	push   $0x27f
f01014bc:	68 11 6f 10 f0       	push   $0xf0106f11
f01014c1:	e8 7a eb ff ff       	call   f0100040 <_panic>

f01014c6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01014c6:	55                   	push   %ebp
f01014c7:	89 e5                	mov    %esp,%ebp
f01014c9:	57                   	push   %edi
f01014ca:	56                   	push   %esi
f01014cb:	53                   	push   %ebx
f01014cc:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01014cf:	b8 15 00 00 00       	mov    $0x15,%eax
f01014d4:	e8 68 f7 ff ff       	call   f0100c41 <nvram_read>
f01014d9:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01014db:	b8 17 00 00 00       	mov    $0x17,%eax
f01014e0:	e8 5c f7 ff ff       	call   f0100c41 <nvram_read>
f01014e5:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014e7:	b8 34 00 00 00       	mov    $0x34,%eax
f01014ec:	e8 50 f7 ff ff       	call   f0100c41 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014f1:	c1 e0 06             	shl    $0x6,%eax
f01014f4:	75 10                	jne    f0101506 <mem_init+0x40>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
f01014f6:	85 db                	test   %ebx,%ebx
f01014f8:	0f 84 e6 00 00 00    	je     f01015e4 <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f01014fe:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f0101504:	eb 05                	jmp    f010150b <mem_init+0x45>
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f0101506:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010150b:	89 c2                	mov    %eax,%edx
f010150d:	c1 ea 02             	shr    $0x2,%edx
f0101510:	89 15 88 0e 29 f0    	mov    %edx,0xf0290e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101516:	89 f2                	mov    %esi,%edx
f0101518:	c1 ea 02             	shr    $0x2,%edx
f010151b:	89 15 44 02 29 f0    	mov    %edx,0xf0290244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101521:	89 c2                	mov    %eax,%edx
f0101523:	29 f2                	sub    %esi,%edx
f0101525:	52                   	push   %edx
f0101526:	56                   	push   %esi
f0101527:	50                   	push   %eax
f0101528:	68 f8 66 10 f0       	push   $0xf01066f8
f010152d:	e8 1f 26 00 00       	call   f0103b51 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101532:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101537:	e8 c0 f6 ff ff       	call   f0100bfc <boot_alloc>
f010153c:	a3 8c 0e 29 f0       	mov    %eax,0xf0290e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101541:	83 c4 0c             	add    $0xc,%esp
f0101544:	68 00 10 00 00       	push   $0x1000
f0101549:	6a 00                	push   $0x0
f010154b:	50                   	push   %eax
f010154c:	e8 78 3d 00 00       	call   f01052c9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101551:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101556:	83 c4 10             	add    $0x10,%esp
f0101559:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010155e:	0f 86 87 00 00 00    	jbe    f01015eb <mem_init+0x125>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101564:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010156a:	83 ca 05             	or     $0x5,%edx
f010156d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    pages = (struct PageInfo*)boot_alloc(npages * sizeof(struct PageInfo));
f0101573:	a1 88 0e 29 f0       	mov    0xf0290e88,%eax
f0101578:	c1 e0 03             	shl    $0x3,%eax
f010157b:	e8 7c f6 ff ff       	call   f0100bfc <boot_alloc>
f0101580:	a3 90 0e 29 f0       	mov    %eax,0xf0290e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101585:	83 ec 04             	sub    $0x4,%esp
f0101588:	8b 0d 88 0e 29 f0    	mov    0xf0290e88,%ecx
f010158e:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101595:	52                   	push   %edx
f0101596:	6a 00                	push   $0x0
f0101598:	50                   	push   %eax
f0101599:	e8 2b 3d 00 00       	call   f01052c9 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV * sizeof(struct Env));
f010159e:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01015a3:	e8 54 f6 ff ff       	call   f0100bfc <boot_alloc>
f01015a8:	a3 48 02 29 f0       	mov    %eax,0xf0290248
	memset(envs, 0, NENV * sizeof(struct Env));
f01015ad:	83 c4 0c             	add    $0xc,%esp
f01015b0:	68 00 f0 01 00       	push   $0x1f000
f01015b5:	6a 00                	push   $0x0
f01015b7:	50                   	push   %eax
f01015b8:	e8 0c 3d 00 00       	call   f01052c9 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015bd:	e8 fc f9 ff ff       	call   f0100fbe <page_init>
	check_page_free_list(1);
f01015c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01015c7:	e8 fb f6 ff ff       	call   f0100cc7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015cc:	83 c4 10             	add    $0x10,%esp
f01015cf:	83 3d 90 0e 29 f0 00 	cmpl   $0x0,0xf0290e90
f01015d6:	74 28                	je     f0101600 <mem_init+0x13a>
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015d8:	a1 40 02 29 f0       	mov    0xf0290240,%eax
f01015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015e2:	eb 36                	jmp    f010161a <mem_init+0x154>
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;
f01015e4:	89 f0                	mov    %esi,%eax
f01015e6:	e9 20 ff ff ff       	jmp    f010150b <mem_init+0x45>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015eb:	50                   	push   %eax
f01015ec:	68 48 5f 10 f0       	push   $0xf0105f48
f01015f1:	68 96 00 00 00       	push   $0x96
f01015f6:	68 11 6f 10 f0       	push   $0xf0106f11
f01015fb:	e8 40 ea ff ff       	call   f0100040 <_panic>
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
		panic("'pages' is a null pointer!");
f0101600:	83 ec 04             	sub    $0x4,%esp
f0101603:	68 1a 70 10 f0       	push   $0xf010701a
f0101608:	68 14 03 00 00       	push   $0x314
f010160d:	68 11 6f 10 f0       	push   $0xf0106f11
f0101612:	e8 29 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;
f0101617:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101618:	8b 00                	mov    (%eax),%eax
f010161a:	85 c0                	test   %eax,%eax
f010161c:	75 f9                	jne    f0101617 <mem_init+0x151>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010161e:	83 ec 0c             	sub    $0xc,%esp
f0101621:	6a 00                	push   $0x0
f0101623:	e8 be fa ff ff       	call   f01010e6 <page_alloc>
f0101628:	89 c7                	mov    %eax,%edi
f010162a:	83 c4 10             	add    $0x10,%esp
f010162d:	85 c0                	test   %eax,%eax
f010162f:	0f 84 10 02 00 00    	je     f0101845 <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f0101635:	83 ec 0c             	sub    $0xc,%esp
f0101638:	6a 00                	push   $0x0
f010163a:	e8 a7 fa ff ff       	call   f01010e6 <page_alloc>
f010163f:	89 c6                	mov    %eax,%esi
f0101641:	83 c4 10             	add    $0x10,%esp
f0101644:	85 c0                	test   %eax,%eax
f0101646:	0f 84 12 02 00 00    	je     f010185e <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f010164c:	83 ec 0c             	sub    $0xc,%esp
f010164f:	6a 00                	push   $0x0
f0101651:	e8 90 fa ff ff       	call   f01010e6 <page_alloc>
f0101656:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101659:	83 c4 10             	add    $0x10,%esp
f010165c:	85 c0                	test   %eax,%eax
f010165e:	0f 84 13 02 00 00    	je     f0101877 <mem_init+0x3b1>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101664:	39 f7                	cmp    %esi,%edi
f0101666:	0f 84 24 02 00 00    	je     f0101890 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166f:	39 c6                	cmp    %eax,%esi
f0101671:	0f 84 32 02 00 00    	je     f01018a9 <mem_init+0x3e3>
f0101677:	39 c7                	cmp    %eax,%edi
f0101679:	0f 84 2a 02 00 00    	je     f01018a9 <mem_init+0x3e3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010167f:	8b 0d 90 0e 29 f0    	mov    0xf0290e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101685:	8b 15 88 0e 29 f0    	mov    0xf0290e88,%edx
f010168b:	c1 e2 0c             	shl    $0xc,%edx
f010168e:	89 f8                	mov    %edi,%eax
f0101690:	29 c8                	sub    %ecx,%eax
f0101692:	c1 f8 03             	sar    $0x3,%eax
f0101695:	c1 e0 0c             	shl    $0xc,%eax
f0101698:	39 d0                	cmp    %edx,%eax
f010169a:	0f 83 22 02 00 00    	jae    f01018c2 <mem_init+0x3fc>
f01016a0:	89 f0                	mov    %esi,%eax
f01016a2:	29 c8                	sub    %ecx,%eax
f01016a4:	c1 f8 03             	sar    $0x3,%eax
f01016a7:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01016aa:	39 c2                	cmp    %eax,%edx
f01016ac:	0f 86 29 02 00 00    	jbe    f01018db <mem_init+0x415>
f01016b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016b5:	29 c8                	sub    %ecx,%eax
f01016b7:	c1 f8 03             	sar    $0x3,%eax
f01016ba:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01016bd:	39 c2                	cmp    %eax,%edx
f01016bf:	0f 86 2f 02 00 00    	jbe    f01018f4 <mem_init+0x42e>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016c5:	a1 40 02 29 f0       	mov    0xf0290240,%eax
f01016ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016cd:	c7 05 40 02 29 f0 00 	movl   $0x0,0xf0290240
f01016d4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016d7:	83 ec 0c             	sub    $0xc,%esp
f01016da:	6a 00                	push   $0x0
f01016dc:	e8 05 fa ff ff       	call   f01010e6 <page_alloc>
f01016e1:	83 c4 10             	add    $0x10,%esp
f01016e4:	85 c0                	test   %eax,%eax
f01016e6:	0f 85 21 02 00 00    	jne    f010190d <mem_init+0x447>

	// free and re-allocate?
	page_free(pp0);
f01016ec:	83 ec 0c             	sub    $0xc,%esp
f01016ef:	57                   	push   %edi
f01016f0:	e8 63 fa ff ff       	call   f0101158 <page_free>
	page_free(pp1);
f01016f5:	89 34 24             	mov    %esi,(%esp)
f01016f8:	e8 5b fa ff ff       	call   f0101158 <page_free>
	page_free(pp2);
f01016fd:	83 c4 04             	add    $0x4,%esp
f0101700:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101703:	e8 50 fa ff ff       	call   f0101158 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101708:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010170f:	e8 d2 f9 ff ff       	call   f01010e6 <page_alloc>
f0101714:	89 c6                	mov    %eax,%esi
f0101716:	83 c4 10             	add    $0x10,%esp
f0101719:	85 c0                	test   %eax,%eax
f010171b:	0f 84 05 02 00 00    	je     f0101926 <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101721:	83 ec 0c             	sub    $0xc,%esp
f0101724:	6a 00                	push   $0x0
f0101726:	e8 bb f9 ff ff       	call   f01010e6 <page_alloc>
f010172b:	89 c7                	mov    %eax,%edi
f010172d:	83 c4 10             	add    $0x10,%esp
f0101730:	85 c0                	test   %eax,%eax
f0101732:	0f 84 07 02 00 00    	je     f010193f <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101738:	83 ec 0c             	sub    $0xc,%esp
f010173b:	6a 00                	push   $0x0
f010173d:	e8 a4 f9 ff ff       	call   f01010e6 <page_alloc>
f0101742:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101745:	83 c4 10             	add    $0x10,%esp
f0101748:	85 c0                	test   %eax,%eax
f010174a:	0f 84 08 02 00 00    	je     f0101958 <mem_init+0x492>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101750:	39 fe                	cmp    %edi,%esi
f0101752:	0f 84 19 02 00 00    	je     f0101971 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101758:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010175b:	39 c7                	cmp    %eax,%edi
f010175d:	0f 84 27 02 00 00    	je     f010198a <mem_init+0x4c4>
f0101763:	39 c6                	cmp    %eax,%esi
f0101765:	0f 84 1f 02 00 00    	je     f010198a <mem_init+0x4c4>
	assert(!page_alloc(0));
f010176b:	83 ec 0c             	sub    $0xc,%esp
f010176e:	6a 00                	push   $0x0
f0101770:	e8 71 f9 ff ff       	call   f01010e6 <page_alloc>
f0101775:	83 c4 10             	add    $0x10,%esp
f0101778:	85 c0                	test   %eax,%eax
f010177a:	0f 85 23 02 00 00    	jne    f01019a3 <mem_init+0x4dd>
f0101780:	89 f0                	mov    %esi,%eax
f0101782:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0101788:	c1 f8 03             	sar    $0x3,%eax
f010178b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178e:	89 c2                	mov    %eax,%edx
f0101790:	c1 ea 0c             	shr    $0xc,%edx
f0101793:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f0101799:	0f 83 1d 02 00 00    	jae    f01019bc <mem_init+0x4f6>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010179f:	83 ec 04             	sub    $0x4,%esp
f01017a2:	68 00 10 00 00       	push   $0x1000
f01017a7:	6a 01                	push   $0x1
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01017a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017ae:	50                   	push   %eax
f01017af:	e8 15 3b 00 00       	call   f01052c9 <memset>
	page_free(pp0);
f01017b4:	89 34 24             	mov    %esi,(%esp)
f01017b7:	e8 9c f9 ff ff       	call   f0101158 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017c3:	e8 1e f9 ff ff       	call   f01010e6 <page_alloc>
f01017c8:	83 c4 10             	add    $0x10,%esp
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	0f 84 fb 01 00 00    	je     f01019ce <mem_init+0x508>
	assert(pp && pp0 == pp);
f01017d3:	39 c6                	cmp    %eax,%esi
f01017d5:	0f 85 0c 02 00 00    	jne    f01019e7 <mem_init+0x521>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017db:	89 f2                	mov    %esi,%edx
f01017dd:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f01017e3:	c1 fa 03             	sar    $0x3,%edx
f01017e6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017e9:	89 d0                	mov    %edx,%eax
f01017eb:	c1 e8 0c             	shr    $0xc,%eax
f01017ee:	3b 05 88 0e 29 f0    	cmp    0xf0290e88,%eax
f01017f4:	0f 83 06 02 00 00    	jae    f0101a00 <mem_init+0x53a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01017fa:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101800:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101806:	80 38 00             	cmpb   $0x0,(%eax)
f0101809:	0f 85 03 02 00 00    	jne    f0101a12 <mem_init+0x54c>
f010180f:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101810:	39 d0                	cmp    %edx,%eax
f0101812:	75 f2                	jne    f0101806 <mem_init+0x340>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101814:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101817:	a3 40 02 29 f0       	mov    %eax,0xf0290240

	// free the pages we took
	page_free(pp0);
f010181c:	83 ec 0c             	sub    $0xc,%esp
f010181f:	56                   	push   %esi
f0101820:	e8 33 f9 ff ff       	call   f0101158 <page_free>
	page_free(pp1);
f0101825:	89 3c 24             	mov    %edi,(%esp)
f0101828:	e8 2b f9 ff ff       	call   f0101158 <page_free>
	page_free(pp2);
f010182d:	83 c4 04             	add    $0x4,%esp
f0101830:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101833:	e8 20 f9 ff ff       	call   f0101158 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101838:	a1 40 02 29 f0       	mov    0xf0290240,%eax
f010183d:	83 c4 10             	add    $0x10,%esp
f0101840:	e9 e9 01 00 00       	jmp    f0101a2e <mem_init+0x568>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101845:	68 35 70 10 f0       	push   $0xf0107035
f010184a:	68 37 6f 10 f0       	push   $0xf0106f37
f010184f:	68 1c 03 00 00       	push   $0x31c
f0101854:	68 11 6f 10 f0       	push   $0xf0106f11
f0101859:	e8 e2 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010185e:	68 4b 70 10 f0       	push   $0xf010704b
f0101863:	68 37 6f 10 f0       	push   $0xf0106f37
f0101868:	68 1d 03 00 00       	push   $0x31d
f010186d:	68 11 6f 10 f0       	push   $0xf0106f11
f0101872:	e8 c9 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101877:	68 61 70 10 f0       	push   $0xf0107061
f010187c:	68 37 6f 10 f0       	push   $0xf0106f37
f0101881:	68 1e 03 00 00       	push   $0x31e
f0101886:	68 11 6f 10 f0       	push   $0xf0106f11
f010188b:	e8 b0 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101890:	68 77 70 10 f0       	push   $0xf0107077
f0101895:	68 37 6f 10 f0       	push   $0xf0106f37
f010189a:	68 21 03 00 00       	push   $0x321
f010189f:	68 11 6f 10 f0       	push   $0xf0106f11
f01018a4:	e8 97 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018a9:	68 34 67 10 f0       	push   $0xf0106734
f01018ae:	68 37 6f 10 f0       	push   $0xf0106f37
f01018b3:	68 22 03 00 00       	push   $0x322
f01018b8:	68 11 6f 10 f0       	push   $0xf0106f11
f01018bd:	e8 7e e7 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01018c2:	68 89 70 10 f0       	push   $0xf0107089
f01018c7:	68 37 6f 10 f0       	push   $0xf0106f37
f01018cc:	68 23 03 00 00       	push   $0x323
f01018d1:	68 11 6f 10 f0       	push   $0xf0106f11
f01018d6:	e8 65 e7 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01018db:	68 a6 70 10 f0       	push   $0xf01070a6
f01018e0:	68 37 6f 10 f0       	push   $0xf0106f37
f01018e5:	68 24 03 00 00       	push   $0x324
f01018ea:	68 11 6f 10 f0       	push   $0xf0106f11
f01018ef:	e8 4c e7 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01018f4:	68 c3 70 10 f0       	push   $0xf01070c3
f01018f9:	68 37 6f 10 f0       	push   $0xf0106f37
f01018fe:	68 25 03 00 00       	push   $0x325
f0101903:	68 11 6f 10 f0       	push   $0xf0106f11
f0101908:	e8 33 e7 ff ff       	call   f0100040 <_panic>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f010190d:	68 e0 70 10 f0       	push   $0xf01070e0
f0101912:	68 37 6f 10 f0       	push   $0xf0106f37
f0101917:	68 2c 03 00 00       	push   $0x32c
f010191c:	68 11 6f 10 f0       	push   $0xf0106f11
f0101921:	e8 1a e7 ff ff       	call   f0100040 <_panic>
	// free and re-allocate?
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101926:	68 35 70 10 f0       	push   $0xf0107035
f010192b:	68 37 6f 10 f0       	push   $0xf0106f37
f0101930:	68 33 03 00 00       	push   $0x333
f0101935:	68 11 6f 10 f0       	push   $0xf0106f11
f010193a:	e8 01 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010193f:	68 4b 70 10 f0       	push   $0xf010704b
f0101944:	68 37 6f 10 f0       	push   $0xf0106f37
f0101949:	68 34 03 00 00       	push   $0x334
f010194e:	68 11 6f 10 f0       	push   $0xf0106f11
f0101953:	e8 e8 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101958:	68 61 70 10 f0       	push   $0xf0107061
f010195d:	68 37 6f 10 f0       	push   $0xf0106f37
f0101962:	68 35 03 00 00       	push   $0x335
f0101967:	68 11 6f 10 f0       	push   $0xf0106f11
f010196c:	e8 cf e6 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101971:	68 77 70 10 f0       	push   $0xf0107077
f0101976:	68 37 6f 10 f0       	push   $0xf0106f37
f010197b:	68 37 03 00 00       	push   $0x337
f0101980:	68 11 6f 10 f0       	push   $0xf0106f11
f0101985:	e8 b6 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010198a:	68 34 67 10 f0       	push   $0xf0106734
f010198f:	68 37 6f 10 f0       	push   $0xf0106f37
f0101994:	68 38 03 00 00       	push   $0x338
f0101999:	68 11 6f 10 f0       	push   $0xf0106f11
f010199e:	e8 9d e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01019a3:	68 e0 70 10 f0       	push   $0xf01070e0
f01019a8:	68 37 6f 10 f0       	push   $0xf0106f37
f01019ad:	68 39 03 00 00       	push   $0x339
f01019b2:	68 11 6f 10 f0       	push   $0xf0106f11
f01019b7:	e8 84 e6 ff ff       	call   f0100040 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019bc:	50                   	push   %eax
f01019bd:	68 24 5f 10 f0       	push   $0xf0105f24
f01019c2:	6a 58                	push   $0x58
f01019c4:	68 1d 6f 10 f0       	push   $0xf0106f1d
f01019c9:	e8 72 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019ce:	68 ef 70 10 f0       	push   $0xf01070ef
f01019d3:	68 37 6f 10 f0       	push   $0xf0106f37
f01019d8:	68 3e 03 00 00       	push   $0x33e
f01019dd:	68 11 6f 10 f0       	push   $0xf0106f11
f01019e2:	e8 59 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019e7:	68 0d 71 10 f0       	push   $0xf010710d
f01019ec:	68 37 6f 10 f0       	push   $0xf0106f37
f01019f1:	68 3f 03 00 00       	push   $0x33f
f01019f6:	68 11 6f 10 f0       	push   $0xf0106f11
f01019fb:	e8 40 e6 ff ff       	call   f0100040 <_panic>
f0101a00:	52                   	push   %edx
f0101a01:	68 24 5f 10 f0       	push   $0xf0105f24
f0101a06:	6a 58                	push   $0x58
f0101a08:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0101a0d:	e8 2e e6 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a12:	68 1d 71 10 f0       	push   $0xf010711d
f0101a17:	68 37 6f 10 f0       	push   $0xf0106f37
f0101a1c:	68 42 03 00 00       	push   $0x342
f0101a21:	68 11 6f 10 f0       	push   $0xf0106f11
f0101a26:	e8 15 e6 ff ff       	call   f0100040 <_panic>
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
f0101a2b:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a2c:	8b 00                	mov    (%eax),%eax
f0101a2e:	85 c0                	test   %eax,%eax
f0101a30:	75 f9                	jne    f0101a2b <mem_init+0x565>
		--nfree;
	assert(nfree == 0);
f0101a32:	85 db                	test   %ebx,%ebx
f0101a34:	0f 85 65 09 00 00    	jne    f010239f <mem_init+0xed9>

	cprintf("check_page_alloc() succeeded!\n");
f0101a3a:	83 ec 0c             	sub    $0xc,%esp
f0101a3d:	68 54 67 10 f0       	push   $0xf0106754
f0101a42:	e8 0a 21 00 00       	call   f0103b51 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a4e:	e8 93 f6 ff ff       	call   f01010e6 <page_alloc>
f0101a53:	89 c7                	mov    %eax,%edi
f0101a55:	83 c4 10             	add    $0x10,%esp
f0101a58:	85 c0                	test   %eax,%eax
f0101a5a:	0f 84 58 09 00 00    	je     f01023b8 <mem_init+0xef2>
	assert((pp1 = page_alloc(0)));
f0101a60:	83 ec 0c             	sub    $0xc,%esp
f0101a63:	6a 00                	push   $0x0
f0101a65:	e8 7c f6 ff ff       	call   f01010e6 <page_alloc>
f0101a6a:	89 c3                	mov    %eax,%ebx
f0101a6c:	83 c4 10             	add    $0x10,%esp
f0101a6f:	85 c0                	test   %eax,%eax
f0101a71:	0f 84 5a 09 00 00    	je     f01023d1 <mem_init+0xf0b>
	assert((pp2 = page_alloc(0)));
f0101a77:	83 ec 0c             	sub    $0xc,%esp
f0101a7a:	6a 00                	push   $0x0
f0101a7c:	e8 65 f6 ff ff       	call   f01010e6 <page_alloc>
f0101a81:	89 c6                	mov    %eax,%esi
f0101a83:	83 c4 10             	add    $0x10,%esp
f0101a86:	85 c0                	test   %eax,%eax
f0101a88:	0f 84 5c 09 00 00    	je     f01023ea <mem_init+0xf24>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a8e:	39 df                	cmp    %ebx,%edi
f0101a90:	0f 84 6d 09 00 00    	je     f0102403 <mem_init+0xf3d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a96:	39 c3                	cmp    %eax,%ebx
f0101a98:	0f 84 7e 09 00 00    	je     f010241c <mem_init+0xf56>
f0101a9e:	39 c7                	cmp    %eax,%edi
f0101aa0:	0f 84 76 09 00 00    	je     f010241c <mem_init+0xf56>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa6:	a1 40 02 29 f0       	mov    0xf0290240,%eax
f0101aab:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101aae:	c7 05 40 02 29 f0 00 	movl   $0x0,0xf0290240
f0101ab5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab8:	83 ec 0c             	sub    $0xc,%esp
f0101abb:	6a 00                	push   $0x0
f0101abd:	e8 24 f6 ff ff       	call   f01010e6 <page_alloc>
f0101ac2:	83 c4 10             	add    $0x10,%esp
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	0f 85 68 09 00 00    	jne    f0102435 <mem_init+0xf6f>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101acd:	83 ec 04             	sub    $0x4,%esp
f0101ad0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ad3:	50                   	push   %eax
f0101ad4:	6a 00                	push   $0x0
f0101ad6:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101adc:	e8 30 f8 ff ff       	call   f0101311 <page_lookup>
f0101ae1:	83 c4 10             	add    $0x10,%esp
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	0f 85 62 09 00 00    	jne    f010244e <mem_init+0xf88>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aec:	6a 02                	push   $0x2
f0101aee:	6a 00                	push   $0x0
f0101af0:	53                   	push   %ebx
f0101af1:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101af7:	e8 00 f9 ff ff       	call   f01013fc <page_insert>
f0101afc:	83 c4 10             	add    $0x10,%esp
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	0f 89 60 09 00 00    	jns    f0102467 <mem_init+0xfa1>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b07:	83 ec 0c             	sub    $0xc,%esp
f0101b0a:	57                   	push   %edi
f0101b0b:	e8 48 f6 ff ff       	call   f0101158 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b10:	6a 02                	push   $0x2
f0101b12:	6a 00                	push   $0x0
f0101b14:	53                   	push   %ebx
f0101b15:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101b1b:	e8 dc f8 ff ff       	call   f01013fc <page_insert>
f0101b20:	83 c4 20             	add    $0x20,%esp
f0101b23:	85 c0                	test   %eax,%eax
f0101b25:	0f 85 55 09 00 00    	jne    f0102480 <mem_init+0xfba>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b2b:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101b30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b33:	8b 0d 90 0e 29 f0    	mov    0xf0290e90,%ecx
f0101b39:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101b3c:	8b 00                	mov    (%eax),%eax
f0101b3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b41:	89 c2                	mov    %eax,%edx
f0101b43:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b49:	89 f8                	mov    %edi,%eax
f0101b4b:	29 c8                	sub    %ecx,%eax
f0101b4d:	c1 f8 03             	sar    $0x3,%eax
f0101b50:	c1 e0 0c             	shl    $0xc,%eax
f0101b53:	39 c2                	cmp    %eax,%edx
f0101b55:	0f 85 3e 09 00 00    	jne    f0102499 <mem_init+0xfd3>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b63:	e8 00 f1 ff ff       	call   f0100c68 <check_va2pa>
f0101b68:	89 da                	mov    %ebx,%edx
f0101b6a:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101b6d:	c1 fa 03             	sar    $0x3,%edx
f0101b70:	c1 e2 0c             	shl    $0xc,%edx
f0101b73:	39 d0                	cmp    %edx,%eax
f0101b75:	0f 85 37 09 00 00    	jne    f01024b2 <mem_init+0xfec>
	assert(pp1->pp_ref == 1);
f0101b7b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b80:	0f 85 45 09 00 00    	jne    f01024cb <mem_init+0x1005>
	assert(pp0->pp_ref == 1);
f0101b86:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b8b:	0f 85 53 09 00 00    	jne    f01024e4 <mem_init+0x101e>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b91:	6a 02                	push   $0x2
f0101b93:	68 00 10 00 00       	push   $0x1000
f0101b98:	56                   	push   %esi
f0101b99:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b9c:	e8 5b f8 ff ff       	call   f01013fc <page_insert>
f0101ba1:	83 c4 10             	add    $0x10,%esp
f0101ba4:	85 c0                	test   %eax,%eax
f0101ba6:	0f 85 51 09 00 00    	jne    f01024fd <mem_init+0x1037>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bac:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bb1:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101bb6:	e8 ad f0 ff ff       	call   f0100c68 <check_va2pa>
f0101bbb:	89 f2                	mov    %esi,%edx
f0101bbd:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f0101bc3:	c1 fa 03             	sar    $0x3,%edx
f0101bc6:	c1 e2 0c             	shl    $0xc,%edx
f0101bc9:	39 d0                	cmp    %edx,%eax
f0101bcb:	0f 85 45 09 00 00    	jne    f0102516 <mem_init+0x1050>
	assert(pp2->pp_ref == 1);
f0101bd1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd6:	0f 85 53 09 00 00    	jne    f010252f <mem_init+0x1069>

	// should be no free memory
	assert(!page_alloc(0));
f0101bdc:	83 ec 0c             	sub    $0xc,%esp
f0101bdf:	6a 00                	push   $0x0
f0101be1:	e8 00 f5 ff ff       	call   f01010e6 <page_alloc>
f0101be6:	83 c4 10             	add    $0x10,%esp
f0101be9:	85 c0                	test   %eax,%eax
f0101beb:	0f 85 57 09 00 00    	jne    f0102548 <mem_init+0x1082>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bf1:	6a 02                	push   $0x2
f0101bf3:	68 00 10 00 00       	push   $0x1000
f0101bf8:	56                   	push   %esi
f0101bf9:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101bff:	e8 f8 f7 ff ff       	call   f01013fc <page_insert>
f0101c04:	83 c4 10             	add    $0x10,%esp
f0101c07:	85 c0                	test   %eax,%eax
f0101c09:	0f 85 52 09 00 00    	jne    f0102561 <mem_init+0x109b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c14:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101c19:	e8 4a f0 ff ff       	call   f0100c68 <check_va2pa>
f0101c1e:	89 f2                	mov    %esi,%edx
f0101c20:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f0101c26:	c1 fa 03             	sar    $0x3,%edx
f0101c29:	c1 e2 0c             	shl    $0xc,%edx
f0101c2c:	39 d0                	cmp    %edx,%eax
f0101c2e:	0f 85 46 09 00 00    	jne    f010257a <mem_init+0x10b4>
	assert(pp2->pp_ref == 1);
f0101c34:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c39:	0f 85 54 09 00 00    	jne    f0102593 <mem_init+0x10cd>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c3f:	83 ec 0c             	sub    $0xc,%esp
f0101c42:	6a 00                	push   $0x0
f0101c44:	e8 9d f4 ff ff       	call   f01010e6 <page_alloc>
f0101c49:	83 c4 10             	add    $0x10,%esp
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	0f 85 58 09 00 00    	jne    f01025ac <mem_init+0x10e6>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c54:	8b 15 8c 0e 29 f0    	mov    0xf0290e8c,%edx
f0101c5a:	8b 02                	mov    (%edx),%eax
f0101c5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c61:	89 c1                	mov    %eax,%ecx
f0101c63:	c1 e9 0c             	shr    $0xc,%ecx
f0101c66:	3b 0d 88 0e 29 f0    	cmp    0xf0290e88,%ecx
f0101c6c:	0f 83 53 09 00 00    	jae    f01025c5 <mem_init+0x10ff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101c72:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c7a:	83 ec 04             	sub    $0x4,%esp
f0101c7d:	6a 00                	push   $0x0
f0101c7f:	68 00 10 00 00       	push   $0x1000
f0101c84:	52                   	push   %edx
f0101c85:	e8 46 f5 ff ff       	call   f01011d0 <pgdir_walk>
f0101c8a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c8d:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c90:	83 c4 10             	add    $0x10,%esp
f0101c93:	39 d0                	cmp    %edx,%eax
f0101c95:	0f 85 3f 09 00 00    	jne    f01025da <mem_init+0x1114>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c9b:	6a 06                	push   $0x6
f0101c9d:	68 00 10 00 00       	push   $0x1000
f0101ca2:	56                   	push   %esi
f0101ca3:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101ca9:	e8 4e f7 ff ff       	call   f01013fc <page_insert>
f0101cae:	83 c4 10             	add    $0x10,%esp
f0101cb1:	85 c0                	test   %eax,%eax
f0101cb3:	0f 85 3a 09 00 00    	jne    f01025f3 <mem_init+0x112d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cb9:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101cbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cc1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc6:	e8 9d ef ff ff       	call   f0100c68 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ccb:	89 f2                	mov    %esi,%edx
f0101ccd:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f0101cd3:	c1 fa 03             	sar    $0x3,%edx
f0101cd6:	c1 e2 0c             	shl    $0xc,%edx
f0101cd9:	39 d0                	cmp    %edx,%eax
f0101cdb:	0f 85 2b 09 00 00    	jne    f010260c <mem_init+0x1146>
	assert(pp2->pp_ref == 1);
f0101ce1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ce6:	0f 85 39 09 00 00    	jne    f0102625 <mem_init+0x115f>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cec:	83 ec 04             	sub    $0x4,%esp
f0101cef:	6a 00                	push   $0x0
f0101cf1:	68 00 10 00 00       	push   $0x1000
f0101cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cf9:	e8 d2 f4 ff ff       	call   f01011d0 <pgdir_walk>
f0101cfe:	83 c4 10             	add    $0x10,%esp
f0101d01:	f6 00 04             	testb  $0x4,(%eax)
f0101d04:	0f 84 34 09 00 00    	je     f010263e <mem_init+0x1178>
	assert(kern_pgdir[0] & PTE_U);
f0101d0a:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101d0f:	f6 00 04             	testb  $0x4,(%eax)
f0101d12:	0f 84 3f 09 00 00    	je     f0102657 <mem_init+0x1191>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d18:	6a 02                	push   $0x2
f0101d1a:	68 00 10 00 00       	push   $0x1000
f0101d1f:	56                   	push   %esi
f0101d20:	50                   	push   %eax
f0101d21:	e8 d6 f6 ff ff       	call   f01013fc <page_insert>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	85 c0                	test   %eax,%eax
f0101d2b:	0f 85 3f 09 00 00    	jne    f0102670 <mem_init+0x11aa>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d31:	83 ec 04             	sub    $0x4,%esp
f0101d34:	6a 00                	push   $0x0
f0101d36:	68 00 10 00 00       	push   $0x1000
f0101d3b:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101d41:	e8 8a f4 ff ff       	call   f01011d0 <pgdir_walk>
f0101d46:	83 c4 10             	add    $0x10,%esp
f0101d49:	f6 00 02             	testb  $0x2,(%eax)
f0101d4c:	0f 84 37 09 00 00    	je     f0102689 <mem_init+0x11c3>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d52:	83 ec 04             	sub    $0x4,%esp
f0101d55:	6a 00                	push   $0x0
f0101d57:	68 00 10 00 00       	push   $0x1000
f0101d5c:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101d62:	e8 69 f4 ff ff       	call   f01011d0 <pgdir_walk>
f0101d67:	83 c4 10             	add    $0x10,%esp
f0101d6a:	f6 00 04             	testb  $0x4,(%eax)
f0101d6d:	0f 85 2f 09 00 00    	jne    f01026a2 <mem_init+0x11dc>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d73:	6a 02                	push   $0x2
f0101d75:	68 00 00 40 00       	push   $0x400000
f0101d7a:	57                   	push   %edi
f0101d7b:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101d81:	e8 76 f6 ff ff       	call   f01013fc <page_insert>
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	0f 89 2a 09 00 00    	jns    f01026bb <mem_init+0x11f5>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d91:	6a 02                	push   $0x2
f0101d93:	68 00 10 00 00       	push   $0x1000
f0101d98:	53                   	push   %ebx
f0101d99:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101d9f:	e8 58 f6 ff ff       	call   f01013fc <page_insert>
f0101da4:	83 c4 10             	add    $0x10,%esp
f0101da7:	85 c0                	test   %eax,%eax
f0101da9:	0f 85 25 09 00 00    	jne    f01026d4 <mem_init+0x120e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101daf:	83 ec 04             	sub    $0x4,%esp
f0101db2:	6a 00                	push   $0x0
f0101db4:	68 00 10 00 00       	push   $0x1000
f0101db9:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101dbf:	e8 0c f4 ff ff       	call   f01011d0 <pgdir_walk>
f0101dc4:	83 c4 10             	add    $0x10,%esp
f0101dc7:	f6 00 04             	testb  $0x4,(%eax)
f0101dca:	0f 85 1d 09 00 00    	jne    f01026ed <mem_init+0x1227>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101dd0:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101dd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ddd:	e8 86 ee ff ff       	call   f0100c68 <check_va2pa>
f0101de2:	89 c1                	mov    %eax,%ecx
f0101de4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101de7:	89 d8                	mov    %ebx,%eax
f0101de9:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0101def:	c1 f8 03             	sar    $0x3,%eax
f0101df2:	c1 e0 0c             	shl    $0xc,%eax
f0101df5:	39 c1                	cmp    %eax,%ecx
f0101df7:	0f 85 09 09 00 00    	jne    f0102706 <mem_init+0x1240>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dfd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e05:	e8 5e ee ff ff       	call   f0100c68 <check_va2pa>
f0101e0a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e0d:	0f 85 0c 09 00 00    	jne    f010271f <mem_init+0x1259>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e13:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e18:	0f 85 1a 09 00 00    	jne    f0102738 <mem_init+0x1272>
	assert(pp2->pp_ref == 0);
f0101e1e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e23:	0f 85 28 09 00 00    	jne    f0102751 <mem_init+0x128b>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e29:	83 ec 0c             	sub    $0xc,%esp
f0101e2c:	6a 00                	push   $0x0
f0101e2e:	e8 b3 f2 ff ff       	call   f01010e6 <page_alloc>
f0101e33:	83 c4 10             	add    $0x10,%esp
f0101e36:	85 c0                	test   %eax,%eax
f0101e38:	0f 84 2c 09 00 00    	je     f010276a <mem_init+0x12a4>
f0101e3e:	39 c6                	cmp    %eax,%esi
f0101e40:	0f 85 24 09 00 00    	jne    f010276a <mem_init+0x12a4>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e46:	83 ec 08             	sub    $0x8,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101e51:	e8 5e f5 ff ff       	call   f01013b4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e56:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101e5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e63:	e8 00 ee ff ff       	call   f0100c68 <check_va2pa>
f0101e68:	83 c4 10             	add    $0x10,%esp
f0101e6b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e6e:	0f 85 0f 09 00 00    	jne    f0102783 <mem_init+0x12bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e74:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e7c:	e8 e7 ed ff ff       	call   f0100c68 <check_va2pa>
f0101e81:	89 da                	mov    %ebx,%edx
f0101e83:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f0101e89:	c1 fa 03             	sar    $0x3,%edx
f0101e8c:	c1 e2 0c             	shl    $0xc,%edx
f0101e8f:	39 d0                	cmp    %edx,%eax
f0101e91:	0f 85 05 09 00 00    	jne    f010279c <mem_init+0x12d6>
	assert(pp1->pp_ref == 1);
f0101e97:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e9c:	0f 85 13 09 00 00    	jne    f01027b5 <mem_init+0x12ef>
	assert(pp2->pp_ref == 0);
f0101ea2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ea7:	0f 85 21 09 00 00    	jne    f01027ce <mem_init+0x1308>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ead:	6a 00                	push   $0x0
f0101eaf:	68 00 10 00 00       	push   $0x1000
f0101eb4:	53                   	push   %ebx
f0101eb5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101eb8:	e8 3f f5 ff ff       	call   f01013fc <page_insert>
f0101ebd:	83 c4 10             	add    $0x10,%esp
f0101ec0:	85 c0                	test   %eax,%eax
f0101ec2:	0f 85 1f 09 00 00    	jne    f01027e7 <mem_init+0x1321>
	assert(pp1->pp_ref);
f0101ec8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ecd:	0f 84 2d 09 00 00    	je     f0102800 <mem_init+0x133a>
	assert(pp1->pp_link == NULL);
f0101ed3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ed6:	0f 85 3d 09 00 00    	jne    f0102819 <mem_init+0x1353>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101edc:	83 ec 08             	sub    $0x8,%esp
f0101edf:	68 00 10 00 00       	push   $0x1000
f0101ee4:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101eea:	e8 c5 f4 ff ff       	call   f01013b4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eef:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101ef4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ef7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101efc:	e8 67 ed ff ff       	call   f0100c68 <check_va2pa>
f0101f01:	83 c4 10             	add    $0x10,%esp
f0101f04:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f07:	0f 85 25 09 00 00    	jne    f0102832 <mem_init+0x136c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f0d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f15:	e8 4e ed ff ff       	call   f0100c68 <check_va2pa>
f0101f1a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f1d:	0f 85 28 09 00 00    	jne    f010284b <mem_init+0x1385>
	assert(pp1->pp_ref == 0);
f0101f23:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f28:	0f 85 36 09 00 00    	jne    f0102864 <mem_init+0x139e>
	assert(pp2->pp_ref == 0);
f0101f2e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f33:	0f 85 44 09 00 00    	jne    f010287d <mem_init+0x13b7>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f39:	83 ec 0c             	sub    $0xc,%esp
f0101f3c:	6a 00                	push   $0x0
f0101f3e:	e8 a3 f1 ff ff       	call   f01010e6 <page_alloc>
f0101f43:	83 c4 10             	add    $0x10,%esp
f0101f46:	85 c0                	test   %eax,%eax
f0101f48:	0f 84 48 09 00 00    	je     f0102896 <mem_init+0x13d0>
f0101f4e:	39 c3                	cmp    %eax,%ebx
f0101f50:	0f 85 40 09 00 00    	jne    f0102896 <mem_init+0x13d0>

	// should be no free memory
	assert(!page_alloc(0));
f0101f56:	83 ec 0c             	sub    $0xc,%esp
f0101f59:	6a 00                	push   $0x0
f0101f5b:	e8 86 f1 ff ff       	call   f01010e6 <page_alloc>
f0101f60:	83 c4 10             	add    $0x10,%esp
f0101f63:	85 c0                	test   %eax,%eax
f0101f65:	0f 85 44 09 00 00    	jne    f01028af <mem_init+0x13e9>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f6b:	8b 0d 8c 0e 29 f0    	mov    0xf0290e8c,%ecx
f0101f71:	8b 11                	mov    (%ecx),%edx
f0101f73:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f79:	89 f8                	mov    %edi,%eax
f0101f7b:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0101f81:	c1 f8 03             	sar    $0x3,%eax
f0101f84:	c1 e0 0c             	shl    $0xc,%eax
f0101f87:	39 c2                	cmp    %eax,%edx
f0101f89:	0f 85 39 09 00 00    	jne    f01028c8 <mem_init+0x1402>
	kern_pgdir[0] = 0;
f0101f8f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f95:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f9a:	0f 85 41 09 00 00    	jne    f01028e1 <mem_init+0x141b>
	pp0->pp_ref = 0;
f0101fa0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fa6:	83 ec 0c             	sub    $0xc,%esp
f0101fa9:	57                   	push   %edi
f0101faa:	e8 a9 f1 ff ff       	call   f0101158 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101faf:	83 c4 0c             	add    $0xc,%esp
f0101fb2:	6a 01                	push   $0x1
f0101fb4:	68 00 10 40 00       	push   $0x401000
f0101fb9:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0101fbf:	e8 0c f2 ff ff       	call   f01011d0 <pgdir_walk>
f0101fc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101fca:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0101fcf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fd2:	8b 50 04             	mov    0x4(%eax),%edx
f0101fd5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fdb:	a1 88 0e 29 f0       	mov    0xf0290e88,%eax
f0101fe0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fe3:	89 d1                	mov    %edx,%ecx
f0101fe5:	c1 e9 0c             	shr    $0xc,%ecx
f0101fe8:	83 c4 10             	add    $0x10,%esp
f0101feb:	39 c1                	cmp    %eax,%ecx
f0101fed:	0f 83 07 09 00 00    	jae    f01028fa <mem_init+0x1434>
	assert(ptep == ptep1 + PTX(va));
f0101ff3:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101ff9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101ffc:	0f 85 0d 09 00 00    	jne    f010290f <mem_init+0x1449>
	kern_pgdir[PDX(va)] = 0;
f0102002:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102005:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010200c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102012:	89 f8                	mov    %edi,%eax
f0102014:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f010201a:	c1 f8 03             	sar    $0x3,%eax
f010201d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102020:	89 c2                	mov    %eax,%edx
f0102022:	c1 ea 0c             	shr    $0xc,%edx
f0102025:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102028:	0f 86 fa 08 00 00    	jbe    f0102928 <mem_init+0x1462>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010202e:	83 ec 04             	sub    $0x4,%esp
f0102031:	68 00 10 00 00       	push   $0x1000
f0102036:	68 ff 00 00 00       	push   $0xff
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f010203b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102040:	50                   	push   %eax
f0102041:	e8 83 32 00 00       	call   f01052c9 <memset>
	page_free(pp0);
f0102046:	89 3c 24             	mov    %edi,(%esp)
f0102049:	e8 0a f1 ff ff       	call   f0101158 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010204e:	83 c4 0c             	add    $0xc,%esp
f0102051:	6a 01                	push   $0x1
f0102053:	6a 00                	push   $0x0
f0102055:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f010205b:	e8 70 f1 ff ff       	call   f01011d0 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102060:	89 fa                	mov    %edi,%edx
f0102062:	2b 15 90 0e 29 f0    	sub    0xf0290e90,%edx
f0102068:	c1 fa 03             	sar    $0x3,%edx
f010206b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010206e:	89 d0                	mov    %edx,%eax
f0102070:	c1 e8 0c             	shr    $0xc,%eax
f0102073:	83 c4 10             	add    $0x10,%esp
f0102076:	3b 05 88 0e 29 f0    	cmp    0xf0290e88,%eax
f010207c:	0f 83 b8 08 00 00    	jae    f010293a <mem_init+0x1474>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0102082:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102088:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010208b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102091:	f6 00 01             	testb  $0x1,(%eax)
f0102094:	0f 85 b2 08 00 00    	jne    f010294c <mem_init+0x1486>
f010209a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010209d:	39 d0                	cmp    %edx,%eax
f010209f:	75 f0                	jne    f0102091 <mem_init+0xbcb>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01020a1:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f01020a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020ac:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01020b2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01020b5:	a3 40 02 29 f0       	mov    %eax,0xf0290240

	// free the pages we took
	page_free(pp0);
f01020ba:	83 ec 0c             	sub    $0xc,%esp
f01020bd:	57                   	push   %edi
f01020be:	e8 95 f0 ff ff       	call   f0101158 <page_free>
	page_free(pp1);
f01020c3:	89 1c 24             	mov    %ebx,(%esp)
f01020c6:	e8 8d f0 ff ff       	call   f0101158 <page_free>
	page_free(pp2);
f01020cb:	89 34 24             	mov    %esi,(%esp)
f01020ce:	e8 85 f0 ff ff       	call   f0101158 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01020d3:	83 c4 08             	add    $0x8,%esp
f01020d6:	68 01 10 00 00       	push   $0x1001
f01020db:	6a 00                	push   $0x0
f01020dd:	e8 81 f3 ff ff       	call   f0101463 <mmio_map_region>
f01020e2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01020e4:	83 c4 08             	add    $0x8,%esp
f01020e7:	68 00 10 00 00       	push   $0x1000
f01020ec:	6a 00                	push   $0x0
f01020ee:	e8 70 f3 ff ff       	call   f0101463 <mmio_map_region>
f01020f3:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01020f5:	83 c4 10             	add    $0x10,%esp
f01020f8:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01020fe:	0f 86 61 08 00 00    	jbe    f0102965 <mem_init+0x149f>
f0102104:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010210a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010210f:	0f 87 50 08 00 00    	ja     f0102965 <mem_init+0x149f>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102115:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010211b:	0f 86 5d 08 00 00    	jbe    f010297e <mem_init+0x14b8>
f0102121:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102127:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010212d:	0f 87 4b 08 00 00    	ja     f010297e <mem_init+0x14b8>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102133:	89 da                	mov    %ebx,%edx
f0102135:	09 f2                	or     %esi,%edx
f0102137:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010213d:	0f 85 54 08 00 00    	jne    f0102997 <mem_init+0x14d1>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102143:	39 c6                	cmp    %eax,%esi
f0102145:	0f 82 65 08 00 00    	jb     f01029b0 <mem_init+0x14ea>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010214b:	8b 3d 8c 0e 29 f0    	mov    0xf0290e8c,%edi
f0102151:	89 da                	mov    %ebx,%edx
f0102153:	89 f8                	mov    %edi,%eax
f0102155:	e8 0e eb ff ff       	call   f0100c68 <check_va2pa>
f010215a:	85 c0                	test   %eax,%eax
f010215c:	0f 85 67 08 00 00    	jne    f01029c9 <mem_init+0x1503>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102162:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102168:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010216b:	89 c2                	mov    %eax,%edx
f010216d:	89 f8                	mov    %edi,%eax
f010216f:	e8 f4 ea ff ff       	call   f0100c68 <check_va2pa>
f0102174:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102179:	0f 85 63 08 00 00    	jne    f01029e2 <mem_init+0x151c>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010217f:	89 f2                	mov    %esi,%edx
f0102181:	89 f8                	mov    %edi,%eax
f0102183:	e8 e0 ea ff ff       	call   f0100c68 <check_va2pa>
f0102188:	85 c0                	test   %eax,%eax
f010218a:	0f 85 6b 08 00 00    	jne    f01029fb <mem_init+0x1535>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102190:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102196:	89 f8                	mov    %edi,%eax
f0102198:	e8 cb ea ff ff       	call   f0100c68 <check_va2pa>
f010219d:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a0:	0f 85 6e 08 00 00    	jne    f0102a14 <mem_init+0x154e>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01021a6:	83 ec 04             	sub    $0x4,%esp
f01021a9:	6a 00                	push   $0x0
f01021ab:	53                   	push   %ebx
f01021ac:	57                   	push   %edi
f01021ad:	e8 1e f0 ff ff       	call   f01011d0 <pgdir_walk>
f01021b2:	83 c4 10             	add    $0x10,%esp
f01021b5:	f6 00 1a             	testb  $0x1a,(%eax)
f01021b8:	0f 84 6f 08 00 00    	je     f0102a2d <mem_init+0x1567>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01021be:	83 ec 04             	sub    $0x4,%esp
f01021c1:	6a 00                	push   $0x0
f01021c3:	53                   	push   %ebx
f01021c4:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f01021ca:	e8 01 f0 ff ff       	call   f01011d0 <pgdir_walk>
f01021cf:	83 c4 10             	add    $0x10,%esp
f01021d2:	f6 00 04             	testb  $0x4,(%eax)
f01021d5:	0f 85 6b 08 00 00    	jne    f0102a46 <mem_init+0x1580>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01021db:	83 ec 04             	sub    $0x4,%esp
f01021de:	6a 00                	push   $0x0
f01021e0:	53                   	push   %ebx
f01021e1:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f01021e7:	e8 e4 ef ff ff       	call   f01011d0 <pgdir_walk>
f01021ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01021f2:	83 c4 0c             	add    $0xc,%esp
f01021f5:	6a 00                	push   $0x0
f01021f7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021fa:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0102200:	e8 cb ef ff ff       	call   f01011d0 <pgdir_walk>
f0102205:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010220b:	83 c4 0c             	add    $0xc,%esp
f010220e:	6a 00                	push   $0x0
f0102210:	56                   	push   %esi
f0102211:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0102217:	e8 b4 ef ff ff       	call   f01011d0 <pgdir_walk>
f010221c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102222:	c7 04 24 10 72 10 f0 	movl   $0xf0107210,(%esp)
f0102229:	e8 23 19 00 00       	call   f0103b51 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f010222e:	a1 90 0e 29 f0       	mov    0xf0290e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102233:	83 c4 10             	add    $0x10,%esp
f0102236:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010223b:	0f 86 1e 08 00 00    	jbe    f0102a5f <mem_init+0x1599>
f0102241:	8b 0d 88 0e 29 f0    	mov    0xf0290e88,%ecx
f0102247:	c1 e1 03             	shl    $0x3,%ecx
f010224a:	83 ec 08             	sub    $0x8,%esp
f010224d:	6a 05                	push   $0x5
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010224f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102254:	50                   	push   %eax
f0102255:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010225a:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f010225f:	e8 4f f0 ff ff       	call   f01012b3 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir, (uintptr_t) UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U | PTE_P);
f0102264:	a1 48 02 29 f0       	mov    0xf0290248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102269:	83 c4 10             	add    $0x10,%esp
f010226c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102271:	0f 86 fd 07 00 00    	jbe    f0102a74 <mem_init+0x15ae>
f0102277:	83 ec 08             	sub    $0x8,%esp
f010227a:	6a 05                	push   $0x5
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010227c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102281:	50                   	push   %eax
f0102282:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102287:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010228c:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f0102291:	e8 1d f0 ff ff       	call   f01012b3 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102296:	83 c4 10             	add    $0x10,%esp
f0102299:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f010229e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022a3:	0f 86 e0 07 00 00    	jbe    f0102a89 <mem_init+0x15c3>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01022a9:	83 ec 08             	sub    $0x8,%esp
f01022ac:	6a 03                	push   $0x3
f01022ae:	68 00 70 11 00       	push   $0x117000
f01022b3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022b8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022bd:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f01022c2:	e8 ec ef ff ff       	call   f01012b3 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01022c7:	83 c4 08             	add    $0x8,%esp
f01022ca:	6a 03                	push   $0x3
f01022cc:	6a 00                	push   $0x0
f01022ce:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01022d3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01022d8:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f01022dd:	e8 d1 ef ff ff       	call   f01012b3 <boot_map_region>
f01022e2:	c7 45 c8 00 20 29 f0 	movl   $0xf0292000,-0x38(%ebp)
f01022e9:	83 c4 10             	add    $0x10,%esp
f01022ec:	bb 00 20 29 f0       	mov    $0xf0292000,%ebx
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	uintptr_t start_addr = KSTACKTOP - KSTKSIZE;
f01022f1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01022f6:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01022fc:	0f 86 9c 07 00 00    	jbe    f0102a9e <mem_init+0x15d8>
	for (size_t i=0; i<NCPU; i++) {
		boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102302:	83 ec 08             	sub    $0x8,%esp
f0102305:	6a 02                	push   $0x2
f0102307:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010230d:	50                   	push   %eax
f010230e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102313:	89 f2                	mov    %esi,%edx
f0102315:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
f010231a:	e8 94 ef ff ff       	call   f01012b3 <boot_map_region>
		start_addr -= KSTKSIZE + KSTKGAP;
f010231f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102325:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	uintptr_t start_addr = KSTACKTOP - KSTKSIZE;
	for (size_t i=0; i<NCPU; i++) {
f010232b:	83 c4 10             	add    $0x10,%esp
f010232e:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102334:	75 c0                	jne    f01022f6 <mem_init+0xe30>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102336:	8b 3d 8c 0e 29 f0    	mov    0xf0290e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010233c:	a1 88 0e 29 f0       	mov    0xf0290e88,%eax
f0102341:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102344:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010234b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102350:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102353:	a1 90 0e 29 f0       	mov    0xf0290e90,%eax
f0102358:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010235b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010235e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102364:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102369:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010236c:	0f 86 71 07 00 00    	jbe    f0102ae3 <mem_init+0x161d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102372:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102378:	89 f8                	mov    %edi,%eax
f010237a:	e8 e9 e8 ff ff       	call   f0100c68 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010237f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102386:	0f 86 27 07 00 00    	jbe    f0102ab3 <mem_init+0x15ed>
f010238c:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f010238f:	39 d0                	cmp    %edx,%eax
f0102391:	0f 85 33 07 00 00    	jne    f0102aca <mem_init+0x1604>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102397:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010239d:	eb ca                	jmp    f0102369 <mem_init+0xea3>
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
	assert(nfree == 0);
f010239f:	68 27 71 10 f0       	push   $0xf0107127
f01023a4:	68 37 6f 10 f0       	push   $0xf0106f37
f01023a9:	68 4f 03 00 00       	push   $0x34f
f01023ae:	68 11 6f 10 f0       	push   $0xf0106f11
f01023b3:	e8 88 dc ff ff       	call   f0100040 <_panic>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023b8:	68 35 70 10 f0       	push   $0xf0107035
f01023bd:	68 37 6f 10 f0       	push   $0xf0106f37
f01023c2:	68 b5 03 00 00       	push   $0x3b5
f01023c7:	68 11 6f 10 f0       	push   $0xf0106f11
f01023cc:	e8 6f dc ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01023d1:	68 4b 70 10 f0       	push   $0xf010704b
f01023d6:	68 37 6f 10 f0       	push   $0xf0106f37
f01023db:	68 b6 03 00 00       	push   $0x3b6
f01023e0:	68 11 6f 10 f0       	push   $0xf0106f11
f01023e5:	e8 56 dc ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01023ea:	68 61 70 10 f0       	push   $0xf0107061
f01023ef:	68 37 6f 10 f0       	push   $0xf0106f37
f01023f4:	68 b7 03 00 00       	push   $0x3b7
f01023f9:	68 11 6f 10 f0       	push   $0xf0106f11
f01023fe:	e8 3d dc ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102403:	68 77 70 10 f0       	push   $0xf0107077
f0102408:	68 37 6f 10 f0       	push   $0xf0106f37
f010240d:	68 ba 03 00 00       	push   $0x3ba
f0102412:	68 11 6f 10 f0       	push   $0xf0106f11
f0102417:	e8 24 dc ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010241c:	68 34 67 10 f0       	push   $0xf0106734
f0102421:	68 37 6f 10 f0       	push   $0xf0106f37
f0102426:	68 bb 03 00 00       	push   $0x3bb
f010242b:	68 11 6f 10 f0       	push   $0xf0106f11
f0102430:	e8 0b dc ff ff       	call   f0100040 <_panic>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f0102435:	68 e0 70 10 f0       	push   $0xf01070e0
f010243a:	68 37 6f 10 f0       	push   $0xf0106f37
f010243f:	68 c2 03 00 00       	push   $0x3c2
f0102444:	68 11 6f 10 f0       	push   $0xf0106f11
f0102449:	e8 f2 db ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010244e:	68 74 67 10 f0       	push   $0xf0106774
f0102453:	68 37 6f 10 f0       	push   $0xf0106f37
f0102458:	68 c5 03 00 00       	push   $0x3c5
f010245d:	68 11 6f 10 f0       	push   $0xf0106f11
f0102462:	e8 d9 db ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102467:	68 ac 67 10 f0       	push   $0xf01067ac
f010246c:	68 37 6f 10 f0       	push   $0xf0106f37
f0102471:	68 c8 03 00 00       	push   $0x3c8
f0102476:	68 11 6f 10 f0       	push   $0xf0106f11
f010247b:	e8 c0 db ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102480:	68 dc 67 10 f0       	push   $0xf01067dc
f0102485:	68 37 6f 10 f0       	push   $0xf0106f37
f010248a:	68 cc 03 00 00       	push   $0x3cc
f010248f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102494:	e8 a7 db ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102499:	68 0c 68 10 f0       	push   $0xf010680c
f010249e:	68 37 6f 10 f0       	push   $0xf0106f37
f01024a3:	68 cd 03 00 00       	push   $0x3cd
f01024a8:	68 11 6f 10 f0       	push   $0xf0106f11
f01024ad:	e8 8e db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01024b2:	68 34 68 10 f0       	push   $0xf0106834
f01024b7:	68 37 6f 10 f0       	push   $0xf0106f37
f01024bc:	68 ce 03 00 00       	push   $0x3ce
f01024c1:	68 11 6f 10 f0       	push   $0xf0106f11
f01024c6:	e8 75 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01024cb:	68 32 71 10 f0       	push   $0xf0107132
f01024d0:	68 37 6f 10 f0       	push   $0xf0106f37
f01024d5:	68 cf 03 00 00       	push   $0x3cf
f01024da:	68 11 6f 10 f0       	push   $0xf0106f11
f01024df:	e8 5c db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01024e4:	68 43 71 10 f0       	push   $0xf0107143
f01024e9:	68 37 6f 10 f0       	push   $0xf0106f37
f01024ee:	68 d0 03 00 00       	push   $0x3d0
f01024f3:	68 11 6f 10 f0       	push   $0xf0106f11
f01024f8:	e8 43 db ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024fd:	68 64 68 10 f0       	push   $0xf0106864
f0102502:	68 37 6f 10 f0       	push   $0xf0106f37
f0102507:	68 d3 03 00 00       	push   $0x3d3
f010250c:	68 11 6f 10 f0       	push   $0xf0106f11
f0102511:	e8 2a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102516:	68 a0 68 10 f0       	push   $0xf01068a0
f010251b:	68 37 6f 10 f0       	push   $0xf0106f37
f0102520:	68 d4 03 00 00       	push   $0x3d4
f0102525:	68 11 6f 10 f0       	push   $0xf0106f11
f010252a:	e8 11 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010252f:	68 54 71 10 f0       	push   $0xf0107154
f0102534:	68 37 6f 10 f0       	push   $0xf0106f37
f0102539:	68 d5 03 00 00       	push   $0x3d5
f010253e:	68 11 6f 10 f0       	push   $0xf0106f11
f0102543:	e8 f8 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102548:	68 e0 70 10 f0       	push   $0xf01070e0
f010254d:	68 37 6f 10 f0       	push   $0xf0106f37
f0102552:	68 d8 03 00 00       	push   $0x3d8
f0102557:	68 11 6f 10 f0       	push   $0xf0106f11
f010255c:	e8 df da ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102561:	68 64 68 10 f0       	push   $0xf0106864
f0102566:	68 37 6f 10 f0       	push   $0xf0106f37
f010256b:	68 db 03 00 00       	push   $0x3db
f0102570:	68 11 6f 10 f0       	push   $0xf0106f11
f0102575:	e8 c6 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010257a:	68 a0 68 10 f0       	push   $0xf01068a0
f010257f:	68 37 6f 10 f0       	push   $0xf0106f37
f0102584:	68 dc 03 00 00       	push   $0x3dc
f0102589:	68 11 6f 10 f0       	push   $0xf0106f11
f010258e:	e8 ad da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102593:	68 54 71 10 f0       	push   $0xf0107154
f0102598:	68 37 6f 10 f0       	push   $0xf0106f37
f010259d:	68 dd 03 00 00       	push   $0x3dd
f01025a2:	68 11 6f 10 f0       	push   $0xf0106f11
f01025a7:	e8 94 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01025ac:	68 e0 70 10 f0       	push   $0xf01070e0
f01025b1:	68 37 6f 10 f0       	push   $0xf0106f37
f01025b6:	68 e1 03 00 00       	push   $0x3e1
f01025bb:	68 11 6f 10 f0       	push   $0xf0106f11
f01025c0:	e8 7b da ff ff       	call   f0100040 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025c5:	50                   	push   %eax
f01025c6:	68 24 5f 10 f0       	push   $0xf0105f24
f01025cb:	68 e4 03 00 00       	push   $0x3e4
f01025d0:	68 11 6f 10 f0       	push   $0xf0106f11
f01025d5:	e8 66 da ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025da:	68 d0 68 10 f0       	push   $0xf01068d0
f01025df:	68 37 6f 10 f0       	push   $0xf0106f37
f01025e4:	68 e5 03 00 00       	push   $0x3e5
f01025e9:	68 11 6f 10 f0       	push   $0xf0106f11
f01025ee:	e8 4d da ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025f3:	68 10 69 10 f0       	push   $0xf0106910
f01025f8:	68 37 6f 10 f0       	push   $0xf0106f37
f01025fd:	68 e8 03 00 00       	push   $0x3e8
f0102602:	68 11 6f 10 f0       	push   $0xf0106f11
f0102607:	e8 34 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010260c:	68 a0 68 10 f0       	push   $0xf01068a0
f0102611:	68 37 6f 10 f0       	push   $0xf0106f37
f0102616:	68 e9 03 00 00       	push   $0x3e9
f010261b:	68 11 6f 10 f0       	push   $0xf0106f11
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102625:	68 54 71 10 f0       	push   $0xf0107154
f010262a:	68 37 6f 10 f0       	push   $0xf0106f37
f010262f:	68 ea 03 00 00       	push   $0x3ea
f0102634:	68 11 6f 10 f0       	push   $0xf0106f11
f0102639:	e8 02 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010263e:	68 50 69 10 f0       	push   $0xf0106950
f0102643:	68 37 6f 10 f0       	push   $0xf0106f37
f0102648:	68 eb 03 00 00       	push   $0x3eb
f010264d:	68 11 6f 10 f0       	push   $0xf0106f11
f0102652:	e8 e9 d9 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102657:	68 65 71 10 f0       	push   $0xf0107165
f010265c:	68 37 6f 10 f0       	push   $0xf0106f37
f0102661:	68 ec 03 00 00       	push   $0x3ec
f0102666:	68 11 6f 10 f0       	push   $0xf0106f11
f010266b:	e8 d0 d9 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102670:	68 64 68 10 f0       	push   $0xf0106864
f0102675:	68 37 6f 10 f0       	push   $0xf0106f37
f010267a:	68 ef 03 00 00       	push   $0x3ef
f010267f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102684:	e8 b7 d9 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102689:	68 84 69 10 f0       	push   $0xf0106984
f010268e:	68 37 6f 10 f0       	push   $0xf0106f37
f0102693:	68 f0 03 00 00       	push   $0x3f0
f0102698:	68 11 6f 10 f0       	push   $0xf0106f11
f010269d:	e8 9e d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026a2:	68 b8 69 10 f0       	push   $0xf01069b8
f01026a7:	68 37 6f 10 f0       	push   $0xf0106f37
f01026ac:	68 f1 03 00 00       	push   $0x3f1
f01026b1:	68 11 6f 10 f0       	push   $0xf0106f11
f01026b6:	e8 85 d9 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026bb:	68 f0 69 10 f0       	push   $0xf01069f0
f01026c0:	68 37 6f 10 f0       	push   $0xf0106f37
f01026c5:	68 f4 03 00 00       	push   $0x3f4
f01026ca:	68 11 6f 10 f0       	push   $0xf0106f11
f01026cf:	e8 6c d9 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026d4:	68 28 6a 10 f0       	push   $0xf0106a28
f01026d9:	68 37 6f 10 f0       	push   $0xf0106f37
f01026de:	68 f7 03 00 00       	push   $0x3f7
f01026e3:	68 11 6f 10 f0       	push   $0xf0106f11
f01026e8:	e8 53 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026ed:	68 b8 69 10 f0       	push   $0xf01069b8
f01026f2:	68 37 6f 10 f0       	push   $0xf0106f37
f01026f7:	68 f8 03 00 00       	push   $0x3f8
f01026fc:	68 11 6f 10 f0       	push   $0xf0106f11
f0102701:	e8 3a d9 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102706:	68 64 6a 10 f0       	push   $0xf0106a64
f010270b:	68 37 6f 10 f0       	push   $0xf0106f37
f0102710:	68 fb 03 00 00       	push   $0x3fb
f0102715:	68 11 6f 10 f0       	push   $0xf0106f11
f010271a:	e8 21 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010271f:	68 90 6a 10 f0       	push   $0xf0106a90
f0102724:	68 37 6f 10 f0       	push   $0xf0106f37
f0102729:	68 fc 03 00 00       	push   $0x3fc
f010272e:	68 11 6f 10 f0       	push   $0xf0106f11
f0102733:	e8 08 d9 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102738:	68 7b 71 10 f0       	push   $0xf010717b
f010273d:	68 37 6f 10 f0       	push   $0xf0106f37
f0102742:	68 fe 03 00 00       	push   $0x3fe
f0102747:	68 11 6f 10 f0       	push   $0xf0106f11
f010274c:	e8 ef d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102751:	68 8c 71 10 f0       	push   $0xf010718c
f0102756:	68 37 6f 10 f0       	push   $0xf0106f37
f010275b:	68 ff 03 00 00       	push   $0x3ff
f0102760:	68 11 6f 10 f0       	push   $0xf0106f11
f0102765:	e8 d6 d8 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010276a:	68 c0 6a 10 f0       	push   $0xf0106ac0
f010276f:	68 37 6f 10 f0       	push   $0xf0106f37
f0102774:	68 02 04 00 00       	push   $0x402
f0102779:	68 11 6f 10 f0       	push   $0xf0106f11
f010277e:	e8 bd d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102783:	68 e4 6a 10 f0       	push   $0xf0106ae4
f0102788:	68 37 6f 10 f0       	push   $0xf0106f37
f010278d:	68 06 04 00 00       	push   $0x406
f0102792:	68 11 6f 10 f0       	push   $0xf0106f11
f0102797:	e8 a4 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010279c:	68 90 6a 10 f0       	push   $0xf0106a90
f01027a1:	68 37 6f 10 f0       	push   $0xf0106f37
f01027a6:	68 07 04 00 00       	push   $0x407
f01027ab:	68 11 6f 10 f0       	push   $0xf0106f11
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01027b5:	68 32 71 10 f0       	push   $0xf0107132
f01027ba:	68 37 6f 10 f0       	push   $0xf0106f37
f01027bf:	68 08 04 00 00       	push   $0x408
f01027c4:	68 11 6f 10 f0       	push   $0xf0106f11
f01027c9:	e8 72 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027ce:	68 8c 71 10 f0       	push   $0xf010718c
f01027d3:	68 37 6f 10 f0       	push   $0xf0106f37
f01027d8:	68 09 04 00 00       	push   $0x409
f01027dd:	68 11 6f 10 f0       	push   $0xf0106f11
f01027e2:	e8 59 d8 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01027e7:	68 08 6b 10 f0       	push   $0xf0106b08
f01027ec:	68 37 6f 10 f0       	push   $0xf0106f37
f01027f1:	68 0c 04 00 00       	push   $0x40c
f01027f6:	68 11 6f 10 f0       	push   $0xf0106f11
f01027fb:	e8 40 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102800:	68 9d 71 10 f0       	push   $0xf010719d
f0102805:	68 37 6f 10 f0       	push   $0xf0106f37
f010280a:	68 0d 04 00 00       	push   $0x40d
f010280f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102814:	e8 27 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102819:	68 a9 71 10 f0       	push   $0xf01071a9
f010281e:	68 37 6f 10 f0       	push   $0xf0106f37
f0102823:	68 0e 04 00 00       	push   $0x40e
f0102828:	68 11 6f 10 f0       	push   $0xf0106f11
f010282d:	e8 0e d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102832:	68 e4 6a 10 f0       	push   $0xf0106ae4
f0102837:	68 37 6f 10 f0       	push   $0xf0106f37
f010283c:	68 12 04 00 00       	push   $0x412
f0102841:	68 11 6f 10 f0       	push   $0xf0106f11
f0102846:	e8 f5 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010284b:	68 40 6b 10 f0       	push   $0xf0106b40
f0102850:	68 37 6f 10 f0       	push   $0xf0106f37
f0102855:	68 13 04 00 00       	push   $0x413
f010285a:	68 11 6f 10 f0       	push   $0xf0106f11
f010285f:	e8 dc d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102864:	68 be 71 10 f0       	push   $0xf01071be
f0102869:	68 37 6f 10 f0       	push   $0xf0106f37
f010286e:	68 14 04 00 00       	push   $0x414
f0102873:	68 11 6f 10 f0       	push   $0xf0106f11
f0102878:	e8 c3 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010287d:	68 8c 71 10 f0       	push   $0xf010718c
f0102882:	68 37 6f 10 f0       	push   $0xf0106f37
f0102887:	68 15 04 00 00       	push   $0x415
f010288c:	68 11 6f 10 f0       	push   $0xf0106f11
f0102891:	e8 aa d7 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102896:	68 68 6b 10 f0       	push   $0xf0106b68
f010289b:	68 37 6f 10 f0       	push   $0xf0106f37
f01028a0:	68 18 04 00 00       	push   $0x418
f01028a5:	68 11 6f 10 f0       	push   $0xf0106f11
f01028aa:	e8 91 d7 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01028af:	68 e0 70 10 f0       	push   $0xf01070e0
f01028b4:	68 37 6f 10 f0       	push   $0xf0106f37
f01028b9:	68 1b 04 00 00       	push   $0x41b
f01028be:	68 11 6f 10 f0       	push   $0xf0106f11
f01028c3:	e8 78 d7 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028c8:	68 0c 68 10 f0       	push   $0xf010680c
f01028cd:	68 37 6f 10 f0       	push   $0xf0106f37
f01028d2:	68 1e 04 00 00       	push   $0x41e
f01028d7:	68 11 6f 10 f0       	push   $0xf0106f11
f01028dc:	e8 5f d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f01028e1:	68 43 71 10 f0       	push   $0xf0107143
f01028e6:	68 37 6f 10 f0       	push   $0xf0106f37
f01028eb:	68 20 04 00 00       	push   $0x420
f01028f0:	68 11 6f 10 f0       	push   $0xf0106f11
f01028f5:	e8 46 d7 ff ff       	call   f0100040 <_panic>
f01028fa:	52                   	push   %edx
f01028fb:	68 24 5f 10 f0       	push   $0xf0105f24
f0102900:	68 27 04 00 00       	push   $0x427
f0102905:	68 11 6f 10 f0       	push   $0xf0106f11
f010290a:	e8 31 d7 ff ff       	call   f0100040 <_panic>
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
f010290f:	68 cf 71 10 f0       	push   $0xf01071cf
f0102914:	68 37 6f 10 f0       	push   $0xf0106f37
f0102919:	68 28 04 00 00       	push   $0x428
f010291e:	68 11 6f 10 f0       	push   $0xf0106f11
f0102923:	e8 18 d7 ff ff       	call   f0100040 <_panic>
f0102928:	50                   	push   %eax
f0102929:	68 24 5f 10 f0       	push   $0xf0105f24
f010292e:	6a 58                	push   $0x58
f0102930:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0102935:	e8 06 d7 ff ff       	call   f0100040 <_panic>
f010293a:	52                   	push   %edx
f010293b:	68 24 5f 10 f0       	push   $0xf0105f24
f0102940:	6a 58                	push   $0x58
f0102942:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0102947:	e8 f4 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010294c:	68 e7 71 10 f0       	push   $0xf01071e7
f0102951:	68 37 6f 10 f0       	push   $0xf0106f37
f0102956:	68 32 04 00 00       	push   $0x432
f010295b:	68 11 6f 10 f0       	push   $0xf0106f11
f0102960:	e8 db d6 ff ff       	call   f0100040 <_panic>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102965:	68 8c 6b 10 f0       	push   $0xf0106b8c
f010296a:	68 37 6f 10 f0       	push   $0xf0106f37
f010296f:	68 42 04 00 00       	push   $0x442
f0102974:	68 11 6f 10 f0       	push   $0xf0106f11
f0102979:	e8 c2 d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010297e:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0102983:	68 37 6f 10 f0       	push   $0xf0106f37
f0102988:	68 43 04 00 00       	push   $0x443
f010298d:	68 11 6f 10 f0       	push   $0xf0106f11
f0102992:	e8 a9 d6 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102997:	68 dc 6b 10 f0       	push   $0xf0106bdc
f010299c:	68 37 6f 10 f0       	push   $0xf0106f37
f01029a1:	68 45 04 00 00       	push   $0x445
f01029a6:	68 11 6f 10 f0       	push   $0xf0106f11
f01029ab:	e8 90 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01029b0:	68 fe 71 10 f0       	push   $0xf01071fe
f01029b5:	68 37 6f 10 f0       	push   $0xf0106f37
f01029ba:	68 47 04 00 00       	push   $0x447
f01029bf:	68 11 6f 10 f0       	push   $0xf0106f11
f01029c4:	e8 77 d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029c9:	68 04 6c 10 f0       	push   $0xf0106c04
f01029ce:	68 37 6f 10 f0       	push   $0xf0106f37
f01029d3:	68 49 04 00 00       	push   $0x449
f01029d8:	68 11 6f 10 f0       	push   $0xf0106f11
f01029dd:	e8 5e d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029e2:	68 28 6c 10 f0       	push   $0xf0106c28
f01029e7:	68 37 6f 10 f0       	push   $0xf0106f37
f01029ec:	68 4a 04 00 00       	push   $0x44a
f01029f1:	68 11 6f 10 f0       	push   $0xf0106f11
f01029f6:	e8 45 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029fb:	68 58 6c 10 f0       	push   $0xf0106c58
f0102a00:	68 37 6f 10 f0       	push   $0xf0106f37
f0102a05:	68 4b 04 00 00       	push   $0x44b
f0102a0a:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a0f:	e8 2c d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a14:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0102a19:	68 37 6f 10 f0       	push   $0xf0106f37
f0102a1e:	68 4c 04 00 00       	push   $0x44c
f0102a23:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a28:	e8 13 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a2d:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102a32:	68 37 6f 10 f0       	push   $0xf0106f37
f0102a37:	68 4e 04 00 00       	push   $0x44e
f0102a3c:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a41:	e8 fa d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a46:	68 ec 6c 10 f0       	push   $0xf0106cec
f0102a4b:	68 37 6f 10 f0       	push   $0xf0106f37
f0102a50:	68 4f 04 00 00       	push   $0x44f
f0102a55:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a5a:	e8 e1 d5 ff ff       	call   f0100040 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a5f:	50                   	push   %eax
f0102a60:	68 48 5f 10 f0       	push   $0xf0105f48
f0102a65:	68 bd 00 00 00       	push   $0xbd
f0102a6a:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a6f:	e8 cc d5 ff ff       	call   f0100040 <_panic>
f0102a74:	50                   	push   %eax
f0102a75:	68 48 5f 10 f0       	push   $0xf0105f48
f0102a7a:	68 c6 00 00 00       	push   $0xc6
f0102a7f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a84:	e8 b7 d5 ff ff       	call   f0100040 <_panic>
f0102a89:	50                   	push   %eax
f0102a8a:	68 48 5f 10 f0       	push   $0xf0105f48
f0102a8f:	68 d3 00 00 00       	push   $0xd3
f0102a94:	68 11 6f 10 f0       	push   $0xf0106f11
f0102a99:	e8 a2 d5 ff ff       	call   f0100040 <_panic>
f0102a9e:	53                   	push   %ebx
f0102a9f:	68 48 5f 10 f0       	push   $0xf0105f48
f0102aa4:	68 14 01 00 00       	push   $0x114
f0102aa9:	68 11 6f 10 f0       	push   $0xf0106f11
f0102aae:	e8 8d d5 ff ff       	call   f0100040 <_panic>
f0102ab3:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102ab6:	68 48 5f 10 f0       	push   $0xf0105f48
f0102abb:	68 67 03 00 00       	push   $0x367
f0102ac0:	68 11 6f 10 f0       	push   $0xf0106f11
f0102ac5:	e8 76 d5 ff ff       	call   f0100040 <_panic>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102aca:	68 20 6d 10 f0       	push   $0xf0106d20
f0102acf:	68 37 6f 10 f0       	push   $0xf0106f37
f0102ad4:	68 67 03 00 00       	push   $0x367
f0102ad9:	68 11 6f 10 f0       	push   $0xf0106f11
f0102ade:	e8 5d d5 ff ff       	call   f0100040 <_panic>

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ae3:	a1 48 02 29 f0       	mov    0xf0290248,%eax
f0102ae8:	89 45 d0             	mov    %eax,-0x30(%ebp)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aeb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102aee:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102af3:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102af9:	89 da                	mov    %ebx,%edx
f0102afb:	89 f8                	mov    %edi,%eax
f0102afd:	e8 66 e1 ff ff       	call   f0100c68 <check_va2pa>
f0102b02:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102b09:	76 22                	jbe    f0102b2d <mem_init+0x1667>
f0102b0b:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102b0e:	39 d0                	cmp    %edx,%eax
f0102b10:	75 32                	jne    f0102b44 <mem_init+0x167e>
f0102b12:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b18:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102b1e:	75 d9                	jne    f0102af9 <mem_init+0x1633>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b20:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102b23:	c1 e6 0c             	shl    $0xc,%esi
f0102b26:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b2b:	eb 4b                	jmp    f0102b78 <mem_init+0x16b2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2d:	ff 75 d0             	pushl  -0x30(%ebp)
f0102b30:	68 48 5f 10 f0       	push   $0xf0105f48
f0102b35:	68 6c 03 00 00       	push   $0x36c
f0102b3a:	68 11 6f 10 f0       	push   $0xf0106f11
f0102b3f:	e8 fc d4 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b44:	68 54 6d 10 f0       	push   $0xf0106d54
f0102b49:	68 37 6f 10 f0       	push   $0xf0106f37
f0102b4e:	68 6c 03 00 00       	push   $0x36c
f0102b53:	68 11 6f 10 f0       	push   $0xf0106f11
f0102b58:	e8 e3 d4 ff ff       	call   f0100040 <_panic>

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b5d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102b63:	89 f8                	mov    %edi,%eax
f0102b65:	e8 fe e0 ff ff       	call   f0100c68 <check_va2pa>
f0102b6a:	39 c3                	cmp    %eax,%ebx
f0102b6c:	0f 85 f7 00 00 00    	jne    f0102c69 <mem_init+0x17a3>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b78:	39 f3                	cmp    %esi,%ebx
f0102b7a:	72 e1                	jb     f0102b5d <mem_init+0x1697>
f0102b7c:	c7 45 d4 00 20 29 f0 	movl   $0xf0292000,-0x2c(%ebp)
f0102b83:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b8d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102b90:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102b93:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102b99:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b9c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102b9f:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102ba5:	89 da                	mov    %ebx,%edx
f0102ba7:	89 f8                	mov    %edi,%eax
f0102ba9:	e8 ba e0 ff ff       	call   f0100c68 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bae:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102bb5:	0f 86 c7 00 00 00    	jbe    f0102c82 <mem_init+0x17bc>
f0102bbb:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102bbe:	39 d0                	cmp    %edx,%eax
f0102bc0:	0f 85 d3 00 00 00    	jne    f0102c99 <mem_init+0x17d3>
f0102bc6:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102bcc:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102bcf:	75 d4                	jne    f0102ba5 <mem_init+0x16df>
f0102bd1:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102bd4:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102bda:	89 da                	mov    %ebx,%edx
f0102bdc:	89 f8                	mov    %edi,%eax
f0102bde:	e8 85 e0 ff ff       	call   f0100c68 <check_va2pa>
f0102be3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102be6:	0f 85 c6 00 00 00    	jne    f0102cb2 <mem_init+0x17ec>
f0102bec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102bf2:	39 f3                	cmp    %esi,%ebx
f0102bf4:	75 e4                	jne    f0102bda <mem_init+0x1714>
f0102bf6:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102bfd:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102c04:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102c0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102c0e:	3d 00 20 2d f0       	cmp    $0xf02d2000,%eax
f0102c13:	0f 85 71 ff ff ff    	jne    f0102b8a <mem_init+0x16c4>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102c19:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102c1e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c23:	0f 87 a2 00 00 00    	ja     f0102ccb <mem_init+0x1805>
				assert(pgdir[i] & PTE_P);
				assert(pgdir[i] & PTE_W);
			} else
				assert(pgdir[i] == 0);
f0102c29:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102c2d:	0f 85 db 00 00 00    	jne    f0102d0e <mem_init+0x1848>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102c33:	40                   	inc    %eax
f0102c34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c39:	0f 87 e8 00 00 00    	ja     f0102d27 <mem_init+0x1861>
		switch (i) {
f0102c3f:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102c45:	83 fa 04             	cmp    $0x4,%edx
f0102c48:	77 d4                	ja     f0102c1e <mem_init+0x1758>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102c4a:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102c4e:	75 e3                	jne    f0102c33 <mem_init+0x176d>
f0102c50:	68 29 72 10 f0       	push   $0xf0107229
f0102c55:	68 37 6f 10 f0       	push   $0xf0106f37
f0102c5a:	68 85 03 00 00       	push   $0x385
f0102c5f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102c64:	e8 d7 d3 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c69:	68 88 6d 10 f0       	push   $0xf0106d88
f0102c6e:	68 37 6f 10 f0       	push   $0xf0106f37
f0102c73:	68 70 03 00 00       	push   $0x370
f0102c78:	68 11 6f 10 f0       	push   $0xf0106f11
f0102c7d:	e8 be d3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c82:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102c85:	68 48 5f 10 f0       	push   $0xf0105f48
f0102c8a:	68 78 03 00 00       	push   $0x378
f0102c8f:	68 11 6f 10 f0       	push   $0xf0106f11
f0102c94:	e8 a7 d3 ff ff       	call   f0100040 <_panic>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102c99:	68 b0 6d 10 f0       	push   $0xf0106db0
f0102c9e:	68 37 6f 10 f0       	push   $0xf0106f37
f0102ca3:	68 78 03 00 00       	push   $0x378
f0102ca8:	68 11 6f 10 f0       	push   $0xf0106f11
f0102cad:	e8 8e d3 ff ff       	call   f0100040 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102cb2:	68 f8 6d 10 f0       	push   $0xf0106df8
f0102cb7:	68 37 6f 10 f0       	push   $0xf0106f37
f0102cbc:	68 7a 03 00 00       	push   $0x37a
f0102cc1:	68 11 6f 10 f0       	push   $0xf0106f11
f0102cc6:	e8 75 d3 ff ff       	call   f0100040 <_panic>
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
f0102ccb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102cce:	f6 c2 01             	test   $0x1,%dl
f0102cd1:	74 22                	je     f0102cf5 <mem_init+0x182f>
				assert(pgdir[i] & PTE_W);
f0102cd3:	f6 c2 02             	test   $0x2,%dl
f0102cd6:	0f 85 57 ff ff ff    	jne    f0102c33 <mem_init+0x176d>
f0102cdc:	68 3a 72 10 f0       	push   $0xf010723a
f0102ce1:	68 37 6f 10 f0       	push   $0xf0106f37
f0102ce6:	68 8a 03 00 00       	push   $0x38a
f0102ceb:	68 11 6f 10 f0       	push   $0xf0106f11
f0102cf0:	e8 4b d3 ff ff       	call   f0100040 <_panic>
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
f0102cf5:	68 29 72 10 f0       	push   $0xf0107229
f0102cfa:	68 37 6f 10 f0       	push   $0xf0106f37
f0102cff:	68 89 03 00 00       	push   $0x389
f0102d04:	68 11 6f 10 f0       	push   $0xf0106f11
f0102d09:	e8 32 d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
			} else
				assert(pgdir[i] == 0);
f0102d0e:	68 4b 72 10 f0       	push   $0xf010724b
f0102d13:	68 37 6f 10 f0       	push   $0xf0106f37
f0102d18:	68 8c 03 00 00       	push   $0x38c
f0102d1d:	68 11 6f 10 f0       	push   $0xf0106f11
f0102d22:	e8 19 d3 ff ff       	call   f0100040 <_panic>
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d27:	83 ec 0c             	sub    $0xc,%esp
f0102d2a:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0102d2f:	e8 1d 0e 00 00       	call   f0103b51 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102d34:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d39:	83 c4 10             	add    $0x10,%esp
f0102d3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d41:	0f 86 fe 01 00 00    	jbe    f0102f45 <mem_init+0x1a7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102d47:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d4c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102d4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d54:	e8 6e df ff ff       	call   f0100cc7 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102d59:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102d5c:	83 e0 f3             	and    $0xfffffff3,%eax
f0102d5f:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102d64:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d67:	83 ec 0c             	sub    $0xc,%esp
f0102d6a:	6a 00                	push   $0x0
f0102d6c:	e8 75 e3 ff ff       	call   f01010e6 <page_alloc>
f0102d71:	89 c3                	mov    %eax,%ebx
f0102d73:	83 c4 10             	add    $0x10,%esp
f0102d76:	85 c0                	test   %eax,%eax
f0102d78:	0f 84 dc 01 00 00    	je     f0102f5a <mem_init+0x1a94>
	assert((pp1 = page_alloc(0)));
f0102d7e:	83 ec 0c             	sub    $0xc,%esp
f0102d81:	6a 00                	push   $0x0
f0102d83:	e8 5e e3 ff ff       	call   f01010e6 <page_alloc>
f0102d88:	89 c7                	mov    %eax,%edi
f0102d8a:	83 c4 10             	add    $0x10,%esp
f0102d8d:	85 c0                	test   %eax,%eax
f0102d8f:	0f 84 de 01 00 00    	je     f0102f73 <mem_init+0x1aad>
	assert((pp2 = page_alloc(0)));
f0102d95:	83 ec 0c             	sub    $0xc,%esp
f0102d98:	6a 00                	push   $0x0
f0102d9a:	e8 47 e3 ff ff       	call   f01010e6 <page_alloc>
f0102d9f:	89 c6                	mov    %eax,%esi
f0102da1:	83 c4 10             	add    $0x10,%esp
f0102da4:	85 c0                	test   %eax,%eax
f0102da6:	0f 84 e0 01 00 00    	je     f0102f8c <mem_init+0x1ac6>
	page_free(pp0);
f0102dac:	83 ec 0c             	sub    $0xc,%esp
f0102daf:	53                   	push   %ebx
f0102db0:	e8 a3 e3 ff ff       	call   f0101158 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102db5:	89 f8                	mov    %edi,%eax
f0102db7:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0102dbd:	c1 f8 03             	sar    $0x3,%eax
f0102dc0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dc3:	89 c2                	mov    %eax,%edx
f0102dc5:	c1 ea 0c             	shr    $0xc,%edx
f0102dc8:	83 c4 10             	add    $0x10,%esp
f0102dcb:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f0102dd1:	0f 83 ce 01 00 00    	jae    f0102fa5 <mem_init+0x1adf>
	memset(page2kva(pp1), 1, PGSIZE);
f0102dd7:	83 ec 04             	sub    $0x4,%esp
f0102dda:	68 00 10 00 00       	push   $0x1000
f0102ddf:	6a 01                	push   $0x1
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0102de1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102de6:	50                   	push   %eax
f0102de7:	e8 dd 24 00 00       	call   f01052c9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dec:	89 f0                	mov    %esi,%eax
f0102dee:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0102df4:	c1 f8 03             	sar    $0x3,%eax
f0102df7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dfa:	89 c2                	mov    %eax,%edx
f0102dfc:	c1 ea 0c             	shr    $0xc,%edx
f0102dff:	83 c4 10             	add    $0x10,%esp
f0102e02:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f0102e08:	0f 83 a9 01 00 00    	jae    f0102fb7 <mem_init+0x1af1>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e0e:	83 ec 04             	sub    $0x4,%esp
f0102e11:	68 00 10 00 00       	push   $0x1000
f0102e16:	6a 02                	push   $0x2
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0102e18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e1d:	50                   	push   %eax
f0102e1e:	e8 a6 24 00 00       	call   f01052c9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102e23:	6a 02                	push   $0x2
f0102e25:	68 00 10 00 00       	push   $0x1000
f0102e2a:	57                   	push   %edi
f0102e2b:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0102e31:	e8 c6 e5 ff ff       	call   f01013fc <page_insert>
	assert(pp1->pp_ref == 1);
f0102e36:	83 c4 20             	add    $0x20,%esp
f0102e39:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e3e:	0f 85 85 01 00 00    	jne    f0102fc9 <mem_init+0x1b03>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e44:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e4b:	01 01 01 
f0102e4e:	0f 85 8e 01 00 00    	jne    f0102fe2 <mem_init+0x1b1c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102e54:	6a 02                	push   $0x2
f0102e56:	68 00 10 00 00       	push   $0x1000
f0102e5b:	56                   	push   %esi
f0102e5c:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0102e62:	e8 95 e5 ff ff       	call   f01013fc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e67:	83 c4 10             	add    $0x10,%esp
f0102e6a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102e71:	02 02 02 
f0102e74:	0f 85 81 01 00 00    	jne    f0102ffb <mem_init+0x1b35>
	assert(pp2->pp_ref == 1);
f0102e7a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e7f:	0f 85 8f 01 00 00    	jne    f0103014 <mem_init+0x1b4e>
	assert(pp1->pp_ref == 0);
f0102e85:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e8a:	0f 85 9d 01 00 00    	jne    f010302d <mem_init+0x1b67>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e90:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e97:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e9a:	89 f0                	mov    %esi,%eax
f0102e9c:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0102ea2:	c1 f8 03             	sar    $0x3,%eax
f0102ea5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ea8:	89 c2                	mov    %eax,%edx
f0102eaa:	c1 ea 0c             	shr    $0xc,%edx
f0102ead:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f0102eb3:	0f 83 8d 01 00 00    	jae    f0103046 <mem_init+0x1b80>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102eb9:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102ec0:	03 03 03 
f0102ec3:	0f 85 8f 01 00 00    	jne    f0103058 <mem_init+0x1b92>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ec9:	83 ec 08             	sub    $0x8,%esp
f0102ecc:	68 00 10 00 00       	push   $0x1000
f0102ed1:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f0102ed7:	e8 d8 e4 ff ff       	call   f01013b4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102edc:	83 c4 10             	add    $0x10,%esp
f0102edf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ee4:	0f 85 87 01 00 00    	jne    f0103071 <mem_init+0x1bab>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eea:	8b 0d 8c 0e 29 f0    	mov    0xf0290e8c,%ecx
f0102ef0:	8b 11                	mov    (%ecx),%edx
f0102ef2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ef8:	89 d8                	mov    %ebx,%eax
f0102efa:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f0102f00:	c1 f8 03             	sar    $0x3,%eax
f0102f03:	c1 e0 0c             	shl    $0xc,%eax
f0102f06:	39 c2                	cmp    %eax,%edx
f0102f08:	0f 85 7c 01 00 00    	jne    f010308a <mem_init+0x1bc4>
	kern_pgdir[0] = 0;
f0102f0e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f14:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f19:	0f 85 84 01 00 00    	jne    f01030a3 <mem_init+0x1bdd>
	pp0->pp_ref = 0;
f0102f1f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f25:	83 ec 0c             	sub    $0xc,%esp
f0102f28:	53                   	push   %ebx
f0102f29:	e8 2a e2 ff ff       	call   f0101158 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f2e:	c7 04 24 b0 6e 10 f0 	movl   $0xf0106eb0,(%esp)
f0102f35:	e8 17 0c 00 00       	call   f0103b51 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f3a:	83 c4 10             	add    $0x10,%esp
f0102f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f40:	5b                   	pop    %ebx
f0102f41:	5e                   	pop    %esi
f0102f42:	5f                   	pop    %edi
f0102f43:	5d                   	pop    %ebp
f0102f44:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f45:	50                   	push   %eax
f0102f46:	68 48 5f 10 f0       	push   $0xf0105f48
f0102f4b:	68 ec 00 00 00       	push   $0xec
f0102f50:	68 11 6f 10 f0       	push   $0xf0106f11
f0102f55:	e8 e6 d0 ff ff       	call   f0100040 <_panic>
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f5a:	68 35 70 10 f0       	push   $0xf0107035
f0102f5f:	68 37 6f 10 f0       	push   $0xf0106f37
f0102f64:	68 64 04 00 00       	push   $0x464
f0102f69:	68 11 6f 10 f0       	push   $0xf0106f11
f0102f6e:	e8 cd d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f73:	68 4b 70 10 f0       	push   $0xf010704b
f0102f78:	68 37 6f 10 f0       	push   $0xf0106f37
f0102f7d:	68 65 04 00 00       	push   $0x465
f0102f82:	68 11 6f 10 f0       	push   $0xf0106f11
f0102f87:	e8 b4 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102f8c:	68 61 70 10 f0       	push   $0xf0107061
f0102f91:	68 37 6f 10 f0       	push   $0xf0106f37
f0102f96:	68 66 04 00 00       	push   $0x466
f0102f9b:	68 11 6f 10 f0       	push   $0xf0106f11
f0102fa0:	e8 9b d0 ff ff       	call   f0100040 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fa5:	50                   	push   %eax
f0102fa6:	68 24 5f 10 f0       	push   $0xf0105f24
f0102fab:	6a 58                	push   $0x58
f0102fad:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0102fb2:	e8 89 d0 ff ff       	call   f0100040 <_panic>
f0102fb7:	50                   	push   %eax
f0102fb8:	68 24 5f 10 f0       	push   $0xf0105f24
f0102fbd:	6a 58                	push   $0x58
f0102fbf:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0102fc4:	e8 77 d0 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
	assert(pp1->pp_ref == 1);
f0102fc9:	68 32 71 10 f0       	push   $0xf0107132
f0102fce:	68 37 6f 10 f0       	push   $0xf0106f37
f0102fd3:	68 6b 04 00 00       	push   $0x46b
f0102fd8:	68 11 6f 10 f0       	push   $0xf0106f11
f0102fdd:	e8 5e d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fe2:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0102fe7:	68 37 6f 10 f0       	push   $0xf0106f37
f0102fec:	68 6c 04 00 00       	push   $0x46c
f0102ff1:	68 11 6f 10 f0       	push   $0xf0106f11
f0102ff6:	e8 45 d0 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ffb:	68 60 6e 10 f0       	push   $0xf0106e60
f0103000:	68 37 6f 10 f0       	push   $0xf0106f37
f0103005:	68 6e 04 00 00       	push   $0x46e
f010300a:	68 11 6f 10 f0       	push   $0xf0106f11
f010300f:	e8 2c d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103014:	68 54 71 10 f0       	push   $0xf0107154
f0103019:	68 37 6f 10 f0       	push   $0xf0106f37
f010301e:	68 6f 04 00 00       	push   $0x46f
f0103023:	68 11 6f 10 f0       	push   $0xf0106f11
f0103028:	e8 13 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010302d:	68 be 71 10 f0       	push   $0xf01071be
f0103032:	68 37 6f 10 f0       	push   $0xf0106f37
f0103037:	68 70 04 00 00       	push   $0x470
f010303c:	68 11 6f 10 f0       	push   $0xf0106f11
f0103041:	e8 fa cf ff ff       	call   f0100040 <_panic>
f0103046:	50                   	push   %eax
f0103047:	68 24 5f 10 f0       	push   $0xf0105f24
f010304c:	6a 58                	push   $0x58
f010304e:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0103053:	e8 e8 cf ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103058:	68 84 6e 10 f0       	push   $0xf0106e84
f010305d:	68 37 6f 10 f0       	push   $0xf0106f37
f0103062:	68 72 04 00 00       	push   $0x472
f0103067:	68 11 6f 10 f0       	push   $0xf0106f11
f010306c:	e8 cf cf ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(pp2->pp_ref == 0);
f0103071:	68 8c 71 10 f0       	push   $0xf010718c
f0103076:	68 37 6f 10 f0       	push   $0xf0106f37
f010307b:	68 74 04 00 00       	push   $0x474
f0103080:	68 11 6f 10 f0       	push   $0xf0106f11
f0103085:	e8 b6 cf ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010308a:	68 0c 68 10 f0       	push   $0xf010680c
f010308f:	68 37 6f 10 f0       	push   $0xf0106f37
f0103094:	68 77 04 00 00       	push   $0x477
f0103099:	68 11 6f 10 f0       	push   $0xf0106f11
f010309e:	e8 9d cf ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f01030a3:	68 43 71 10 f0       	push   $0xf0107143
f01030a8:	68 37 6f 10 f0       	push   $0xf0106f37
f01030ad:	68 79 04 00 00       	push   $0x479
f01030b2:	68 11 6f 10 f0       	push   $0xf0106f11
f01030b7:	e8 84 cf ff ff       	call   f0100040 <_panic>

f01030bc <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01030bc:	55                   	push   %ebp
f01030bd:	89 e5                	mov    %esp,%ebp
f01030bf:	57                   	push   %edi
f01030c0:	56                   	push   %esi
f01030c1:	53                   	push   %ebx
f01030c2:	83 ec 1c             	sub    $0x1c,%esp
f01030c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
f01030c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01030d1:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
f01030d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01030d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030da:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f01030e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01030e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f01030e9:	8b 75 14             	mov    0x14(%ebp),%esi
f01030ec:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f01030ef:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01030f2:	73 54                	jae    f0103148 <user_mem_check+0x8c>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
f01030f4:	83 ec 04             	sub    $0x4,%esp
f01030f7:	6a 00                	push   $0x0
f01030f9:	53                   	push   %ebx
f01030fa:	ff 77 60             	pushl  0x60(%edi)
f01030fd:	e8 ce e0 ff ff       	call   f01011d0 <pgdir_walk>
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f0103102:	83 c4 10             	add    $0x10,%esp
f0103105:	85 c0                	test   %eax,%eax
f0103107:	74 18                	je     f0103121 <user_mem_check+0x65>
f0103109:	89 f2                	mov    %esi,%edx
f010310b:	23 10                	and    (%eax),%edx
f010310d:	39 d6                	cmp    %edx,%esi
f010310f:	75 10                	jne    f0103121 <user_mem_check+0x65>
f0103111:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103117:	77 08                	ja     f0103121 <user_mem_check+0x65>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f0103119:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010311f:	eb ce                	jmp    f01030ef <user_mem_check+0x33>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
f0103121:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0103124:	74 13                	je     f0103139 <user_mem_check+0x7d>
				user_mem_check_addr = (uintptr_t)va;
			} else {
				user_mem_check_addr = cur_va;
f0103126:	89 1d 3c 02 29 f0    	mov    %ebx,0xf029023c
			}
			return -E_FAULT;
f010312c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}
	return 0;
}
f0103131:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103134:	5b                   	pop    %ebx
f0103135:	5e                   	pop    %esi
f0103136:	5f                   	pop    %edi
f0103137:	5d                   	pop    %ebp
f0103138:	c3                   	ret    
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
				user_mem_check_addr = (uintptr_t)va;
f0103139:	8b 45 0c             	mov    0xc(%ebp),%eax
f010313c:	a3 3c 02 29 f0       	mov    %eax,0xf029023c
			} else {
				user_mem_check_addr = cur_va;
			}
			return -E_FAULT;
f0103141:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103146:	eb e9                	jmp    f0103131 <user_mem_check+0x75>
		}
	}
	return 0;
f0103148:	b8 00 00 00 00       	mov    $0x0,%eax
f010314d:	eb e2                	jmp    f0103131 <user_mem_check+0x75>

f010314f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010314f:	55                   	push   %ebp
f0103150:	89 e5                	mov    %esp,%ebp
f0103152:	53                   	push   %ebx
f0103153:	83 ec 04             	sub    $0x4,%esp
f0103156:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103159:	8b 45 14             	mov    0x14(%ebp),%eax
f010315c:	83 c8 04             	or     $0x4,%eax
f010315f:	50                   	push   %eax
f0103160:	ff 75 10             	pushl  0x10(%ebp)
f0103163:	ff 75 0c             	pushl  0xc(%ebp)
f0103166:	53                   	push   %ebx
f0103167:	e8 50 ff ff ff       	call   f01030bc <user_mem_check>
f010316c:	83 c4 10             	add    $0x10,%esp
f010316f:	85 c0                	test   %eax,%eax
f0103171:	78 05                	js     f0103178 <user_mem_assert+0x29>
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0103173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103176:	c9                   	leave  
f0103177:	c3                   	ret    
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f0103178:	83 ec 04             	sub    $0x4,%esp
f010317b:	ff 35 3c 02 29 f0    	pushl  0xf029023c
f0103181:	ff 73 48             	pushl  0x48(%ebx)
f0103184:	68 dc 6e 10 f0       	push   $0xf0106edc
f0103189:	e8 c3 09 00 00       	call   f0103b51 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010318e:	89 1c 24             	mov    %ebx,(%esp)
f0103191:	e8 e5 06 00 00       	call   f010387b <env_destroy>
f0103196:	83 c4 10             	add    $0x10,%esp
	}
}
f0103199:	eb d8                	jmp    f0103173 <user_mem_assert+0x24>
	...

f010319c <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010319c:	55                   	push   %ebp
f010319d:	89 e5                	mov    %esp,%ebp
f010319f:	57                   	push   %edi
f01031a0:	56                   	push   %esi
f01031a1:	53                   	push   %ebx
f01031a2:	83 ec 1c             	sub    $0x1c,%esp
f01031a5:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
f01031a7:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01031ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f01031b6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01031bc:	89 d3                	mov    %edx,%ebx
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f01031be:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01031c1:	73 4e                	jae    f0103211 <region_alloc+0x75>
		pginfo = page_alloc(0);
f01031c3:	83 ec 0c             	sub    $0xc,%esp
f01031c6:	6a 00                	push   $0x0
f01031c8:	e8 19 df ff ff       	call   f01010e6 <page_alloc>
f01031cd:	89 c6                	mov    %eax,%esi
		if (!pginfo) {
f01031cf:	83 c4 10             	add    $0x10,%esp
f01031d2:	85 c0                	test   %eax,%eax
f01031d4:	74 25                	je     f01031fb <region_alloc+0x5f>
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
		}
		cprintf("insert page at %08x\n",cur_va);
f01031d6:	83 ec 08             	sub    $0x8,%esp
f01031d9:	53                   	push   %ebx
f01031da:	68 75 72 10 f0       	push   $0xf0107275
f01031df:	e8 6d 09 00 00       	call   f0103b51 <cprintf>
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
f01031e4:	6a 07                	push   $0x7
f01031e6:	53                   	push   %ebx
f01031e7:	56                   	push   %esi
f01031e8:	ff 77 60             	pushl  0x60(%edi)
f01031eb:	e8 0c e2 ff ff       	call   f01013fc <page_insert>
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f01031f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031f6:	83 c4 20             	add    $0x20,%esp
f01031f9:	eb c3                	jmp    f01031be <region_alloc+0x22>
		pginfo = page_alloc(0);
		if (!pginfo) {
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
f01031fb:	6a fc                	push   $0xfffffffc
f01031fd:	68 59 72 10 f0       	push   $0xf0107259
f0103202:	68 2b 01 00 00       	push   $0x12b
f0103207:	68 6a 72 10 f0       	push   $0xf010726a
f010320c:	e8 2f ce ff ff       	call   f0100040 <_panic>
		}
		cprintf("insert page at %08x\n",cur_va);
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
	}
}
f0103211:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103214:	5b                   	pop    %ebx
f0103215:	5e                   	pop    %esi
f0103216:	5f                   	pop    %edi
f0103217:	5d                   	pop    %ebp
f0103218:	c3                   	ret    

f0103219 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103219:	55                   	push   %ebp
f010321a:	89 e5                	mov    %esp,%ebp
f010321c:	56                   	push   %esi
f010321d:	53                   	push   %ebx
f010321e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103221:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103224:	85 c0                	test   %eax,%eax
f0103226:	74 37                	je     f010325f <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103228:	89 c1                	mov    %eax,%ecx
f010322a:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103230:	89 ca                	mov    %ecx,%edx
f0103232:	c1 e2 05             	shl    $0x5,%edx
f0103235:	29 ca                	sub    %ecx,%edx
f0103237:	8b 0d 48 02 29 f0    	mov    0xf0290248,%ecx
f010323d:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103240:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103244:	74 3d                	je     f0103283 <envid2env+0x6a>
f0103246:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103249:	75 38                	jne    f0103283 <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010324b:	89 f0                	mov    %esi,%eax
f010324d:	84 c0                	test   %al,%al
f010324f:	75 42                	jne    f0103293 <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0103251:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103254:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103256:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010325b:	5b                   	pop    %ebx
f010325c:	5e                   	pop    %esi
f010325d:	5d                   	pop    %ebp
f010325e:	c3                   	ret    
{
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
		*env_store = curenv;
f010325f:	e8 74 26 00 00       	call   f01058d8 <cpunum>
f0103264:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103267:	01 c2                	add    %eax,%edx
f0103269:	01 d2                	add    %edx,%edx
f010326b:	01 c2                	add    %eax,%edx
f010326d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103270:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f0103277:	8b 75 0c             	mov    0xc(%ebp),%esi
f010327a:	89 06                	mov    %eax,(%esi)
		return 0;
f010327c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103281:	eb d8                	jmp    f010325b <envid2env+0x42>
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
	if (e->env_status == ENV_FREE || e->env_id != envid) {
		*env_store = 0;
f0103283:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103286:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010328c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103291:	eb c8                	jmp    f010325b <envid2env+0x42>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103293:	e8 40 26 00 00       	call   f01058d8 <cpunum>
f0103298:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010329b:	01 c2                	add    %eax,%edx
f010329d:	01 d2                	add    %edx,%edx
f010329f:	01 c2                	add    %eax,%edx
f01032a1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01032a4:	39 1c 85 28 10 29 f0 	cmp    %ebx,-0xfd6efd8(,%eax,4)
f01032ab:	74 a4                	je     f0103251 <envid2env+0x38>
f01032ad:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01032b0:	e8 23 26 00 00       	call   f01058d8 <cpunum>
f01032b5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01032b8:	01 c2                	add    %eax,%edx
f01032ba:	01 d2                	add    %edx,%edx
f01032bc:	01 c2                	add    %eax,%edx
f01032be:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01032c1:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01032c8:	3b 70 48             	cmp    0x48(%eax),%esi
f01032cb:	74 84                	je     f0103251 <envid2env+0x38>
		*env_store = 0;
f01032cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032d6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032db:	e9 7b ff ff ff       	jmp    f010325b <envid2env+0x42>

f01032e0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01032e0:	55                   	push   %ebp
f01032e1:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01032e3:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01032e8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01032eb:	b8 23 00 00 00       	mov    $0x23,%eax
f01032f0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01032f2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01032f4:	b8 10 00 00 00       	mov    $0x10,%eax
f01032f9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01032fb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01032fd:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01032ff:	ea 06 33 10 f0 08 00 	ljmp   $0x8,$0xf0103306
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103306:	b8 00 00 00 00       	mov    $0x0,%eax
f010330b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010330e:	5d                   	pop    %ebp
f010330f:	c3                   	ret    

f0103310 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103310:	55                   	push   %ebp
f0103311:	89 e5                	mov    %esp,%ebp
f0103313:	56                   	push   %esi
f0103314:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for (int index = NENV - 1; index >= 0; index--) {
		envs[index].env_link = env_free_list;
f0103315:	8b 35 48 02 29 f0    	mov    0xf0290248,%esi
f010331b:	8b 15 4c 02 29 f0    	mov    0xf029024c,%edx
f0103321:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103327:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010332a:	89 c1                	mov    %eax,%ecx
f010332c:	89 50 44             	mov    %edx,0x44(%eax)
		envs[index].env_runs = 0;
f010332f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
        envs[index].env_status = ENV_FREE;
f0103336:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[index].env_id = 0;
f010333d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f0103344:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[index];
f0103347:	89 ca                	mov    %ecx,%edx
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (int index = NENV - 1; index >= 0; index--) {
f0103349:	39 d8                	cmp    %ebx,%eax
f010334b:	75 dd                	jne    f010332a <env_init+0x1a>
f010334d:	89 35 4c 02 29 f0    	mov    %esi,0xf029024c
		envs[index].env_id = 0;
		env_free_list = &envs[index];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103353:	e8 88 ff ff ff       	call   f01032e0 <env_init_percpu>
}
f0103358:	5b                   	pop    %ebx
f0103359:	5e                   	pop    %esi
f010335a:	5d                   	pop    %ebp
f010335b:	c3                   	ret    

f010335c <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010335c:	55                   	push   %ebp
f010335d:	89 e5                	mov    %esp,%ebp
f010335f:	56                   	push   %esi
f0103360:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103361:	8b 1d 4c 02 29 f0    	mov    0xf029024c,%ebx
f0103367:	85 db                	test   %ebx,%ebx
f0103369:	0f 84 a4 01 00 00    	je     f0103513 <env_alloc+0x1b7>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010336f:	83 ec 0c             	sub    $0xc,%esp
f0103372:	6a 01                	push   $0x1
f0103374:	e8 6d dd ff ff       	call   f01010e6 <page_alloc>
f0103379:	89 c6                	mov    %eax,%esi
f010337b:	83 c4 10             	add    $0x10,%esp
f010337e:	85 c0                	test   %eax,%eax
f0103380:	0f 84 94 01 00 00    	je     f010351a <env_alloc+0x1be>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103386:	2b 05 90 0e 29 f0    	sub    0xf0290e90,%eax
f010338c:	c1 f8 03             	sar    $0x3,%eax
f010338f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103392:	89 c2                	mov    %eax,%edx
f0103394:	c1 ea 0c             	shr    $0xc,%edx
f0103397:	3b 15 88 0e 29 f0    	cmp    0xf0290e88,%edx
f010339d:	0f 83 38 01 00 00    	jae    f01034db <env_alloc+0x17f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01033a3:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    e->env_pgdir = page2kva(p);
f01033a8:	89 43 60             	mov    %eax,0x60(%ebx)
	memmove(e->env_pgdir, kern_pgdir, PGSIZE);
f01033ab:	83 ec 04             	sub    $0x4,%esp
f01033ae:	68 00 10 00 00       	push   $0x1000
f01033b3:	ff 35 8c 0e 29 f0    	pushl  0xf0290e8c
f01033b9:	50                   	push   %eax
f01033ba:	e8 57 1f 00 00       	call   f0105316 <memmove>
	p->pp_ref++;
f01033bf:	66 ff 46 04          	incw   0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01033c3:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033c6:	83 c4 10             	add    $0x10,%esp
f01033c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033ce:	0f 86 19 01 00 00    	jbe    f01034ed <env_alloc+0x191>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01033d4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01033da:	83 ca 05             	or     $0x5,%edx
f01033dd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01033e3:	8b 43 48             	mov    0x48(%ebx),%eax
f01033e6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01033eb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01033f0:	89 c2                	mov    %eax,%edx
f01033f2:	0f 8e 0a 01 00 00    	jle    f0103502 <env_alloc+0x1a6>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01033f8:	89 d8                	mov    %ebx,%eax
f01033fa:	2b 05 48 02 29 f0    	sub    0xf0290248,%eax
f0103400:	c1 f8 02             	sar    $0x2,%eax
f0103403:	89 c1                	mov    %eax,%ecx
f0103405:	c1 e0 05             	shl    $0x5,%eax
f0103408:	01 c8                	add    %ecx,%eax
f010340a:	c1 e0 05             	shl    $0x5,%eax
f010340d:	01 c8                	add    %ecx,%eax
f010340f:	89 c6                	mov    %eax,%esi
f0103411:	c1 e6 0f             	shl    $0xf,%esi
f0103414:	01 f0                	add    %esi,%eax
f0103416:	c1 e0 05             	shl    $0x5,%eax
f0103419:	01 c8                	add    %ecx,%eax
f010341b:	f7 d8                	neg    %eax
f010341d:	09 d0                	or     %edx,%eax
f010341f:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103422:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103425:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103428:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010342f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103436:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010343d:	83 ec 04             	sub    $0x4,%esp
f0103440:	6a 44                	push   $0x44
f0103442:	6a 00                	push   $0x0
f0103444:	53                   	push   %ebx
f0103445:	e8 7f 1e 00 00       	call   f01052c9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010344a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103450:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103456:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010345c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103463:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103469:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103470:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103474:	8b 43 44             	mov    0x44(%ebx),%eax
f0103477:	a3 4c 02 29 f0       	mov    %eax,0xf029024c
	*newenv_store = e;
f010347c:	8b 45 08             	mov    0x8(%ebp),%eax
f010347f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103481:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103484:	e8 4f 24 00 00       	call   f01058d8 <cpunum>
f0103489:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010348c:	01 c2                	add    %eax,%edx
f010348e:	01 d2                	add    %edx,%edx
f0103490:	01 c2                	add    %eax,%edx
f0103492:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103495:	83 c4 10             	add    $0x10,%esp
f0103498:	83 3c 85 28 10 29 f0 	cmpl   $0x0,-0xfd6efd8(,%eax,4)
f010349f:	00 
f01034a0:	74 6a                	je     f010350c <env_alloc+0x1b0>
f01034a2:	e8 31 24 00 00       	call   f01058d8 <cpunum>
f01034a7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01034aa:	01 c2                	add    %eax,%edx
f01034ac:	01 d2                	add    %edx,%edx
f01034ae:	01 c2                	add    %eax,%edx
f01034b0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034b3:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01034ba:	8b 40 48             	mov    0x48(%eax),%eax
f01034bd:	83 ec 04             	sub    $0x4,%esp
f01034c0:	53                   	push   %ebx
f01034c1:	50                   	push   %eax
f01034c2:	68 8a 72 10 f0       	push   $0xf010728a
f01034c7:	e8 85 06 00 00       	call   f0103b51 <cprintf>
	return 0;
f01034cc:	83 c4 10             	add    $0x10,%esp
f01034cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01034d7:	5b                   	pop    %ebx
f01034d8:	5e                   	pop    %esi
f01034d9:	5d                   	pop    %ebp
f01034da:	c3                   	ret    

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034db:	50                   	push   %eax
f01034dc:	68 24 5f 10 f0       	push   $0xf0105f24
f01034e1:	6a 58                	push   $0x58
f01034e3:	68 1d 6f 10 f0       	push   $0xf0106f1d
f01034e8:	e8 53 cb ff ff       	call   f0100040 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ed:	50                   	push   %eax
f01034ee:	68 48 5f 10 f0       	push   $0xf0105f48
f01034f3:	68 c6 00 00 00       	push   $0xc6
f01034f8:	68 6a 72 10 f0       	push   $0xf010726a
f01034fd:	e8 3e cb ff ff       	call   f0100040 <_panic>
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0103502:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103507:	e9 ec fe ff ff       	jmp    f01033f8 <env_alloc+0x9c>

	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010350c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103511:	eb aa                	jmp    f01034bd <env_alloc+0x161>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103513:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103518:	eb ba                	jmp    f01034d4 <env_alloc+0x178>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010351a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010351f:	eb b3                	jmp    f01034d4 <env_alloc+0x178>

f0103521 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103521:	55                   	push   %ebp
f0103522:	89 e5                	mov    %esp,%ebp
f0103524:	57                   	push   %edi
f0103525:	56                   	push   %esi
f0103526:	53                   	push   %ebx
f0103527:	83 ec 34             	sub    $0x34,%esp
f010352a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f010352d:	6a 00                	push   $0x0
f010352f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103532:	50                   	push   %eax
f0103533:	e8 24 fe ff ff       	call   f010335c <env_alloc>
	if (r < 0) {
f0103538:	83 c4 10             	add    $0x10,%esp
f010353b:	85 c0                	test   %eax,%eax
f010353d:	78 3b                	js     f010357a <env_create+0x59>
		panic("env_create: %e", r);
	}
	e->env_type = type;
f010353f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103542:	89 c1                	mov    %eax,%ecx
f0103544:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103547:	8b 45 0c             	mov    0xc(%ebp),%eax
f010354a:	89 41 50             	mov    %eax,0x50(%ecx)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
f010354d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103553:	75 3a                	jne    f010358f <env_create+0x6e>
		panic("load_icode: not an ELF file");
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
f0103555:	89 fb                	mov    %edi,%ebx
f0103557:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f010355a:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010355e:	c1 e6 05             	shl    $0x5,%esi
f0103561:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103563:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103566:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103569:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010356e:	76 36                	jbe    f01035a6 <env_create+0x85>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103570:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103575:	0f 22 d8             	mov    %eax,%cr3
f0103578:	eb 5b                	jmp    f01035d5 <env_create+0xb4>
{
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
	if (r < 0) {
		panic("env_create: %e", r);
f010357a:	50                   	push   %eax
f010357b:	68 9f 72 10 f0       	push   $0xf010729f
f0103580:	68 94 01 00 00       	push   $0x194
f0103585:	68 6a 72 10 f0       	push   $0xf010726a
f010358a:	e8 b1 ca ff ff       	call   f0100040 <_panic>

	// LAB 3: Your code here.
    struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
		panic("load_icode: not an ELF file");
f010358f:	83 ec 04             	sub    $0x4,%esp
f0103592:	68 ae 72 10 f0       	push   $0xf01072ae
f0103597:	68 6b 01 00 00       	push   $0x16b
f010359c:	68 6a 72 10 f0       	push   $0xf010726a
f01035a1:	e8 9a ca ff ff       	call   f0100040 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a6:	50                   	push   %eax
f01035a7:	68 48 5f 10 f0       	push   $0xf0105f48
f01035ac:	68 70 01 00 00       	push   $0x170
f01035b1:	68 6a 72 10 f0       	push   $0xf010726a
f01035b6:	e8 85 ca ff ff       	call   f0100040 <_panic>

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
			if (ph->p_filesz > ph->p_memsz) {
				panic("load_icode: file size is greater than memory size");
f01035bb:	83 ec 04             	sub    $0x4,%esp
f01035be:	68 ec 72 10 f0       	push   $0xf01072ec
f01035c3:	68 74 01 00 00       	push   $0x174
f01035c8:	68 6a 72 10 f0       	push   $0xf010726a
f01035cd:	e8 6e ca ff ff       	call   f0100040 <_panic>
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
f01035d2:	83 c3 20             	add    $0x20,%ebx
f01035d5:	39 de                	cmp    %ebx,%esi
f01035d7:	76 48                	jbe    f0103621 <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f01035d9:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035dc:	75 f4                	jne    f01035d2 <env_create+0xb1>
			if (ph->p_filesz > ph->p_memsz) {
f01035de:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01035e1:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01035e4:	77 d5                	ja     f01035bb <env_create+0x9a>
				panic("load_icode: file size is greater than memory size");
			}
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01035e6:	8b 53 08             	mov    0x8(%ebx),%edx
f01035e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035ec:	e8 ab fb ff ff       	call   f010319c <region_alloc>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01035f1:	83 ec 04             	sub    $0x4,%esp
f01035f4:	ff 73 10             	pushl  0x10(%ebx)
f01035f7:	89 f8                	mov    %edi,%eax
f01035f9:	03 43 04             	add    0x4(%ebx),%eax
f01035fc:	50                   	push   %eax
f01035fd:	ff 73 08             	pushl  0x8(%ebx)
f0103600:	e8 77 1d 00 00       	call   f010537c <memcpy>
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103605:	8b 43 10             	mov    0x10(%ebx),%eax
f0103608:	83 c4 0c             	add    $0xc,%esp
f010360b:	8b 53 14             	mov    0x14(%ebx),%edx
f010360e:	29 c2                	sub    %eax,%edx
f0103610:	52                   	push   %edx
f0103611:	6a 00                	push   $0x0
f0103613:	03 43 08             	add    0x8(%ebx),%eax
f0103616:	50                   	push   %eax
f0103617:	e8 ad 1c 00 00       	call   f01052c9 <memset>
f010361c:	83 c4 10             	add    $0x10,%esp
f010361f:	eb b1                	jmp    f01035d2 <env_create+0xb1>
		}
	}
	e->env_tf.tf_eip = elf->e_entry;
f0103621:	8b 47 18             	mov    0x18(%edi),%eax
f0103624:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103627:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	lcr3(PADDR(kern_pgdir));
f010362a:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010362f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103634:	76 22                	jbe    f0103658 <env_create+0x137>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103636:	05 00 00 00 10       	add    $0x10000000,%eax
f010363b:	0f 22 d8             	mov    %eax,%cr3

	region_alloc(e, (void *) USTACKTOP-PGSIZE, PGSIZE);
f010363e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103643:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010364b:	e8 4c fb ff ff       	call   f010319c <region_alloc>
	if (r < 0) {
		panic("env_create: %e", r);
	}
	e->env_type = type;
	load_icode(e, binary);
}
f0103650:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103653:	5b                   	pop    %ebx
f0103654:	5e                   	pop    %esi
f0103655:	5f                   	pop    %edi
f0103656:	5d                   	pop    %ebp
f0103657:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103658:	50                   	push   %eax
f0103659:	68 48 5f 10 f0       	push   $0xf0105f48
f010365e:	68 81 01 00 00       	push   $0x181
f0103663:	68 6a 72 10 f0       	push   $0xf010726a
f0103668:	e8 d3 c9 ff ff       	call   f0100040 <_panic>

f010366d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010366d:	55                   	push   %ebp
f010366e:	89 e5                	mov    %esp,%ebp
f0103670:	57                   	push   %edi
f0103671:	56                   	push   %esi
f0103672:	53                   	push   %ebx
f0103673:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103676:	e8 5d 22 00 00       	call   f01058d8 <cpunum>
f010367b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010367e:	01 c2                	add    %eax,%edx
f0103680:	01 d2                	add    %edx,%edx
f0103682:	01 c2                	add    %eax,%edx
f0103684:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103687:	8b 55 08             	mov    0x8(%ebp),%edx
f010368a:	39 14 85 28 10 29 f0 	cmp    %edx,-0xfd6efd8(,%eax,4)
f0103691:	75 14                	jne    f01036a7 <env_free+0x3a>
		lcr3(PADDR(kern_pgdir));
f0103693:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103698:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010369d:	76 65                	jbe    f0103704 <env_free+0x97>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010369f:	05 00 00 00 10       	add    $0x10000000,%eax
f01036a4:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036aa:	8b 58 48             	mov    0x48(%eax),%ebx
f01036ad:	e8 26 22 00 00       	call   f01058d8 <cpunum>
f01036b2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01036b5:	01 c2                	add    %eax,%edx
f01036b7:	01 d2                	add    %edx,%edx
f01036b9:	01 c2                	add    %eax,%edx
f01036bb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036be:	83 3c 85 28 10 29 f0 	cmpl   $0x0,-0xfd6efd8(,%eax,4)
f01036c5:	00 
f01036c6:	74 51                	je     f0103719 <env_free+0xac>
f01036c8:	e8 0b 22 00 00       	call   f01058d8 <cpunum>
f01036cd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01036d0:	01 c2                	add    %eax,%edx
f01036d2:	01 d2                	add    %edx,%edx
f01036d4:	01 c2                	add    %eax,%edx
f01036d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036d9:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01036e0:	8b 40 48             	mov    0x48(%eax),%eax
f01036e3:	83 ec 04             	sub    $0x4,%esp
f01036e6:	53                   	push   %ebx
f01036e7:	50                   	push   %eax
f01036e8:	68 ca 72 10 f0       	push   $0xf01072ca
f01036ed:	e8 5f 04 00 00       	call   f0103b51 <cprintf>
f01036f2:	83 c4 10             	add    $0x10,%esp
f01036f5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01036fc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036ff:	e9 96 00 00 00       	jmp    f010379a <env_free+0x12d>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103704:	50                   	push   %eax
f0103705:	68 48 5f 10 f0       	push   $0xf0105f48
f010370a:	68 a8 01 00 00       	push   $0x1a8
f010370f:	68 6a 72 10 f0       	push   $0xf010726a
f0103714:	e8 27 c9 ff ff       	call   f0100040 <_panic>
f0103719:	b8 00 00 00 00       	mov    $0x0,%eax
f010371e:	eb c3                	jmp    f01036e3 <env_free+0x76>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103720:	50                   	push   %eax
f0103721:	68 24 5f 10 f0       	push   $0xf0105f24
f0103726:	68 b7 01 00 00       	push   $0x1b7
f010372b:	68 6a 72 10 f0       	push   $0xf010726a
f0103730:	e8 0b c9 ff ff       	call   f0100040 <_panic>
f0103735:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103738:	39 f3                	cmp    %esi,%ebx
f010373a:	74 21                	je     f010375d <env_free+0xf0>
			if (pt[pteno] & PTE_P)
f010373c:	f6 03 01             	testb  $0x1,(%ebx)
f010373f:	74 f4                	je     f0103735 <env_free+0xc8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103741:	83 ec 08             	sub    $0x8,%esp
f0103744:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103747:	01 d8                	add    %ebx,%eax
f0103749:	c1 e0 0a             	shl    $0xa,%eax
f010374c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010374f:	50                   	push   %eax
f0103750:	ff 77 60             	pushl  0x60(%edi)
f0103753:	e8 5c dc ff ff       	call   f01013b4 <page_remove>
f0103758:	83 c4 10             	add    $0x10,%esp
f010375b:	eb d8                	jmp    f0103735 <env_free+0xc8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010375d:	8b 47 60             	mov    0x60(%edi),%eax
f0103760:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103763:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010376a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010376d:	3b 05 88 0e 29 f0    	cmp    0xf0290e88,%eax
f0103773:	73 6a                	jae    f01037df <env_free+0x172>
		page_decref(pa2page(pa));
f0103775:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0103778:	a1 90 0e 29 f0       	mov    0xf0290e90,%eax
f010377d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103780:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103783:	50                   	push   %eax
f0103784:	e8 21 da ff ff       	call   f01011aa <page_decref>
f0103789:	83 c4 10             	add    $0x10,%esp
f010378c:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103790:	8b 45 dc             	mov    -0x24(%ebp),%eax
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103793:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103798:	74 59                	je     f01037f3 <env_free+0x186>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010379a:	8b 47 60             	mov    0x60(%edi),%eax
f010379d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037a0:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01037a3:	a8 01                	test   $0x1,%al
f01037a5:	74 e5                	je     f010378c <env_free+0x11f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01037a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037ac:	89 c2                	mov    %eax,%edx
f01037ae:	c1 ea 0c             	shr    $0xc,%edx
f01037b1:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01037b4:	39 15 88 0e 29 f0    	cmp    %edx,0xf0290e88
f01037ba:	0f 86 60 ff ff ff    	jbe    f0103720 <env_free+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01037c0:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037c9:	c1 e2 14             	shl    $0x14,%edx
f01037cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01037cf:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f01037d5:	f7 d8                	neg    %eax
f01037d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01037da:	e9 5d ff ff ff       	jmp    f010373c <env_free+0xcf>

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f01037df:	83 ec 04             	sub    $0x4,%esp
f01037e2:	68 d8 66 10 f0       	push   $0xf01066d8
f01037e7:	6a 51                	push   $0x51
f01037e9:	68 1d 6f 10 f0       	push   $0xf0106f1d
f01037ee:	e8 4d c8 ff ff       	call   f0100040 <_panic>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01037f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f6:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037fe:	76 52                	jbe    f0103852 <env_free+0x1e5>
	e->env_pgdir = 0;
f0103800:	8b 55 08             	mov    0x8(%ebp),%edx
f0103803:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010380a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010380f:	c1 e8 0c             	shr    $0xc,%eax
f0103812:	3b 05 88 0e 29 f0    	cmp    0xf0290e88,%eax
f0103818:	73 4d                	jae    f0103867 <env_free+0x1fa>
	page_decref(pa2page(pa));
f010381a:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010381d:	8b 15 90 0e 29 f0    	mov    0xf0290e90,%edx
f0103823:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103826:	50                   	push   %eax
f0103827:	e8 7e d9 ff ff       	call   f01011aa <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010382c:	8b 45 08             	mov    0x8(%ebp),%eax
f010382f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103836:	a1 4c 02 29 f0       	mov    0xf029024c,%eax
f010383b:	8b 55 08             	mov    0x8(%ebp),%edx
f010383e:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103841:	89 15 4c 02 29 f0    	mov    %edx,0xf029024c
}
f0103847:	83 c4 10             	add    $0x10,%esp
f010384a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010384d:	5b                   	pop    %ebx
f010384e:	5e                   	pop    %esi
f010384f:	5f                   	pop    %edi
f0103850:	5d                   	pop    %ebp
f0103851:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103852:	50                   	push   %eax
f0103853:	68 48 5f 10 f0       	push   $0xf0105f48
f0103858:	68 c5 01 00 00       	push   $0x1c5
f010385d:	68 6a 72 10 f0       	push   $0xf010726a
f0103862:	e8 d9 c7 ff ff       	call   f0100040 <_panic>

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f0103867:	83 ec 04             	sub    $0x4,%esp
f010386a:	68 d8 66 10 f0       	push   $0xf01066d8
f010386f:	6a 51                	push   $0x51
f0103871:	68 1d 6f 10 f0       	push   $0xf0106f1d
f0103876:	e8 c5 c7 ff ff       	call   f0100040 <_panic>

f010387b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010387b:	55                   	push   %ebp
f010387c:	89 e5                	mov    %esp,%ebp
f010387e:	53                   	push   %ebx
f010387f:	83 ec 04             	sub    $0x4,%esp
f0103882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103885:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103889:	74 2b                	je     f01038b6 <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010388b:	83 ec 0c             	sub    $0xc,%esp
f010388e:	53                   	push   %ebx
f010388f:	e8 d9 fd ff ff       	call   f010366d <env_free>

	if (curenv == e) {
f0103894:	e8 3f 20 00 00       	call   f01058d8 <cpunum>
f0103899:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010389c:	01 c2                	add    %eax,%edx
f010389e:	01 d2                	add    %edx,%edx
f01038a0:	01 c2                	add    %eax,%edx
f01038a2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038a5:	83 c4 10             	add    $0x10,%esp
f01038a8:	39 1c 85 28 10 29 f0 	cmp    %ebx,-0xfd6efd8(,%eax,4)
f01038af:	74 28                	je     f01038d9 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f01038b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038b4:	c9                   	leave  
f01038b5:	c3                   	ret    
env_destroy(struct Env *e)
{
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01038b6:	e8 1d 20 00 00       	call   f01058d8 <cpunum>
f01038bb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01038be:	01 c2                	add    %eax,%edx
f01038c0:	01 d2                	add    %edx,%edx
f01038c2:	01 c2                	add    %eax,%edx
f01038c4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038c7:	39 1c 85 28 10 29 f0 	cmp    %ebx,-0xfd6efd8(,%eax,4)
f01038ce:	74 bb                	je     f010388b <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01038d0:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01038d7:	eb d8                	jmp    f01038b1 <env_destroy+0x36>
	}

	env_free(e);

	if (curenv == e) {
		curenv = NULL;
f01038d9:	e8 fa 1f 00 00       	call   f01058d8 <cpunum>
f01038de:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e1:	c7 80 28 10 29 f0 00 	movl   $0x0,-0xfd6efd8(%eax)
f01038e8:	00 00 00 
		sched_yield();
f01038eb:	e8 ca 0c 00 00       	call   f01045ba <sched_yield>

f01038f0 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038f0:	55                   	push   %ebp
f01038f1:	89 e5                	mov    %esp,%ebp
f01038f3:	53                   	push   %ebx
f01038f4:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01038f7:	e8 dc 1f 00 00       	call   f01058d8 <cpunum>
f01038fc:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01038ff:	01 c2                	add    %eax,%edx
f0103901:	01 d2                	add    %edx,%edx
f0103903:	01 c2                	add    %eax,%edx
f0103905:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103908:	8b 1c 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%ebx
f010390f:	e8 c4 1f 00 00       	call   f01058d8 <cpunum>
f0103914:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103917:	8b 65 08             	mov    0x8(%ebp),%esp
f010391a:	61                   	popa   
f010391b:	07                   	pop    %es
f010391c:	1f                   	pop    %ds
f010391d:	83 c4 08             	add    $0x8,%esp
f0103920:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103921:	83 ec 04             	sub    $0x4,%esp
f0103924:	68 e0 72 10 f0       	push   $0xf01072e0
f0103929:	68 fc 01 00 00       	push   $0x1fc
f010392e:	68 6a 72 10 f0       	push   $0xf010726a
f0103933:	e8 08 c7 ff ff       	call   f0100040 <_panic>

f0103938 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103938:	55                   	push   %ebp
f0103939:	89 e5                	mov    %esp,%ebp
f010393b:	53                   	push   %ebx
f010393c:	83 ec 04             	sub    $0x4,%esp
f010393f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103942:	e8 91 1f 00 00       	call   f01058d8 <cpunum>
f0103947:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010394a:	01 c2                	add    %eax,%edx
f010394c:	01 d2                	add    %edx,%edx
f010394e:	01 c2                	add    %eax,%edx
f0103950:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103953:	83 3c 85 28 10 29 f0 	cmpl   $0x0,-0xfd6efd8(,%eax,4)
f010395a:	00 
f010395b:	74 14                	je     f0103971 <env_run+0x39>
f010395d:	e8 76 1f 00 00       	call   f01058d8 <cpunum>
f0103962:	6b c0 74             	imul   $0x74,%eax,%eax
f0103965:	8b 80 28 10 29 f0    	mov    -0xfd6efd8(%eax),%eax
f010396b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010396f:	74 41                	je     f01039b2 <env_run+0x7a>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103971:	e8 62 1f 00 00       	call   f01058d8 <cpunum>
f0103976:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103979:	01 c2                	add    %eax,%edx
f010397b:	01 d2                	add    %edx,%edx
f010397d:	01 c2                	add    %eax,%edx
f010397f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103982:	89 1c 85 28 10 29 f0 	mov    %ebx,-0xfd6efd8(,%eax,4)
	e->env_status = ENV_RUNNING;
f0103989:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103990:	ff 43 58             	incl   0x58(%ebx)

	lcr3(PADDR(e->env_pgdir));
f0103993:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103996:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010399b:	77 2c                	ja     f01039c9 <env_run+0x91>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010399d:	50                   	push   %eax
f010399e:	68 48 5f 10 f0       	push   $0xf0105f48
f01039a3:	68 22 02 00 00       	push   $0x222
f01039a8:	68 6a 72 10 f0       	push   $0xf010726a
f01039ad:	e8 8e c6 ff ff       	call   f0100040 <_panic>
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
		curenv->env_status = ENV_RUNNABLE;
f01039b2:	e8 21 1f 00 00       	call   f01058d8 <cpunum>
f01039b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ba:	8b 80 28 10 29 f0    	mov    -0xfd6efd8(%eax),%eax
f01039c0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01039c7:	eb a8                	jmp    f0103971 <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f01039c9:	05 00 00 00 10       	add    $0x10000000,%eax
f01039ce:	0f 22 d8             	mov    %eax,%cr3
	e->env_status = ENV_RUNNING;
	e->env_runs++;

	lcr3(PADDR(e->env_pgdir));

	env_pop_tf(&e->env_tf);
f01039d1:	83 ec 0c             	sub    $0xc,%esp
f01039d4:	53                   	push   %ebx
f01039d5:	e8 16 ff ff ff       	call   f01038f0 <env_pop_tf>
	...

f01039dc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01039dc:	55                   	push   %ebp
f01039dd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039df:	8b 45 08             	mov    0x8(%ebp),%eax
f01039e2:	ba 70 00 00 00       	mov    $0x70,%edx
f01039e7:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039e8:	ba 71 00 00 00       	mov    $0x71,%edx
f01039ed:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039ee:	0f b6 c0             	movzbl %al,%eax
}
f01039f1:	5d                   	pop    %ebp
f01039f2:	c3                   	ret    

f01039f3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039f3:	55                   	push   %ebp
f01039f4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01039f9:	ba 70 00 00 00       	mov    $0x70,%edx
f01039fe:	ee                   	out    %al,(%dx)
f01039ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a02:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a07:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a08:	5d                   	pop    %ebp
f0103a09:	c3                   	ret    
	...

f0103a0c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103a0c:	55                   	push   %ebp
f0103a0d:	89 e5                	mov    %esp,%ebp
f0103a0f:	56                   	push   %esi
f0103a10:	53                   	push   %ebx
f0103a11:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103a14:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103a1a:	80 3d 50 02 29 f0 00 	cmpb   $0x0,0xf0290250
f0103a21:	75 07                	jne    f0103a2a <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103a23:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a26:	5b                   	pop    %ebx
f0103a27:	5e                   	pop    %esi
f0103a28:	5d                   	pop    %ebp
f0103a29:	c3                   	ret    
f0103a2a:	89 c6                	mov    %eax,%esi
f0103a2c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a31:	ee                   	out    %al,(%dx)
	int i;
	irq_mask_8259A = mask;
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103a32:	66 c1 e8 08          	shr    $0x8,%ax
f0103a36:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a3b:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103a3c:	83 ec 0c             	sub    $0xc,%esp
f0103a3f:	68 1e 73 10 f0       	push   $0xf010731e
f0103a44:	e8 08 01 00 00       	call   f0103b51 <cprintf>
f0103a49:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a4c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103a51:	0f b7 f6             	movzwl %si,%esi
f0103a54:	f7 d6                	not    %esi
f0103a56:	eb 06                	jmp    f0103a5e <irq_setmask_8259A+0x52>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103a58:	43                   	inc    %ebx
f0103a59:	83 fb 10             	cmp    $0x10,%ebx
f0103a5c:	74 1d                	je     f0103a7b <irq_setmask_8259A+0x6f>
		if (~mask & (1<<i))
f0103a5e:	89 f0                	mov    %esi,%eax
f0103a60:	88 d9                	mov    %bl,%cl
f0103a62:	d3 f8                	sar    %cl,%eax
f0103a64:	a8 01                	test   $0x1,%al
f0103a66:	74 f0                	je     f0103a58 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103a68:	83 ec 08             	sub    $0x8,%esp
f0103a6b:	53                   	push   %ebx
f0103a6c:	68 a5 77 10 f0       	push   $0xf01077a5
f0103a71:	e8 db 00 00 00       	call   f0103b51 <cprintf>
f0103a76:	83 c4 10             	add    $0x10,%esp
f0103a79:	eb dd                	jmp    f0103a58 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103a7b:	83 ec 0c             	sub    $0xc,%esp
f0103a7e:	68 27 72 10 f0       	push   $0xf0107227
f0103a83:	e8 c9 00 00 00       	call   f0103b51 <cprintf>
f0103a88:	83 c4 10             	add    $0x10,%esp
f0103a8b:	eb 96                	jmp    f0103a23 <irq_setmask_8259A+0x17>

f0103a8d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103a8d:	55                   	push   %ebp
f0103a8e:	89 e5                	mov    %esp,%ebp
f0103a90:	57                   	push   %edi
f0103a91:	56                   	push   %esi
f0103a92:	53                   	push   %ebx
f0103a93:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103a96:	c6 05 50 02 29 f0 01 	movb   $0x1,0xf0290250
f0103a9d:	b0 ff                	mov    $0xff,%al
f0103a9f:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103aa4:	89 da                	mov    %ebx,%edx
f0103aa6:	ee                   	out    %al,(%dx)
f0103aa7:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103aac:	89 ca                	mov    %ecx,%edx
f0103aae:	ee                   	out    %al,(%dx)
f0103aaf:	bf 11 00 00 00       	mov    $0x11,%edi
f0103ab4:	be 20 00 00 00       	mov    $0x20,%esi
f0103ab9:	89 f8                	mov    %edi,%eax
f0103abb:	89 f2                	mov    %esi,%edx
f0103abd:	ee                   	out    %al,(%dx)
f0103abe:	b0 20                	mov    $0x20,%al
f0103ac0:	89 da                	mov    %ebx,%edx
f0103ac2:	ee                   	out    %al,(%dx)
f0103ac3:	b0 04                	mov    $0x4,%al
f0103ac5:	ee                   	out    %al,(%dx)
f0103ac6:	b0 03                	mov    $0x3,%al
f0103ac8:	ee                   	out    %al,(%dx)
f0103ac9:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103ace:	89 f8                	mov    %edi,%eax
f0103ad0:	89 da                	mov    %ebx,%edx
f0103ad2:	ee                   	out    %al,(%dx)
f0103ad3:	b0 28                	mov    $0x28,%al
f0103ad5:	89 ca                	mov    %ecx,%edx
f0103ad7:	ee                   	out    %al,(%dx)
f0103ad8:	b0 02                	mov    $0x2,%al
f0103ada:	ee                   	out    %al,(%dx)
f0103adb:	b0 01                	mov    $0x1,%al
f0103add:	ee                   	out    %al,(%dx)
f0103ade:	bf 68 00 00 00       	mov    $0x68,%edi
f0103ae3:	89 f8                	mov    %edi,%eax
f0103ae5:	89 f2                	mov    %esi,%edx
f0103ae7:	ee                   	out    %al,(%dx)
f0103ae8:	b1 0a                	mov    $0xa,%cl
f0103aea:	88 c8                	mov    %cl,%al
f0103aec:	ee                   	out    %al,(%dx)
f0103aed:	89 f8                	mov    %edi,%eax
f0103aef:	89 da                	mov    %ebx,%edx
f0103af1:	ee                   	out    %al,(%dx)
f0103af2:	88 c8                	mov    %cl,%al
f0103af4:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103af5:	66 a1 a8 13 12 f0    	mov    0xf01213a8,%ax
f0103afb:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103aff:	74 0f                	je     f0103b10 <pic_init+0x83>
		irq_setmask_8259A(irq_mask_8259A);
f0103b01:	83 ec 0c             	sub    $0xc,%esp
f0103b04:	0f b7 c0             	movzwl %ax,%eax
f0103b07:	50                   	push   %eax
f0103b08:	e8 ff fe ff ff       	call   f0103a0c <irq_setmask_8259A>
f0103b0d:	83 c4 10             	add    $0x10,%esp
}
f0103b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b13:	5b                   	pop    %ebx
f0103b14:	5e                   	pop    %esi
f0103b15:	5f                   	pop    %edi
f0103b16:	5d                   	pop    %ebp
f0103b17:	c3                   	ret    

f0103b18 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103b18:	55                   	push   %ebp
f0103b19:	89 e5                	mov    %esp,%ebp
f0103b1b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103b1e:	ff 75 08             	pushl  0x8(%ebp)
f0103b21:	e8 4e cc ff ff       	call   f0100774 <cputchar>
	*cnt++;
}
f0103b26:	83 c4 10             	add    $0x10,%esp
f0103b29:	c9                   	leave  
f0103b2a:	c3                   	ret    

f0103b2b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b2b:	55                   	push   %ebp
f0103b2c:	89 e5                	mov    %esp,%ebp
f0103b2e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103b31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b38:	ff 75 0c             	pushl  0xc(%ebp)
f0103b3b:	ff 75 08             	pushl  0x8(%ebp)
f0103b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b41:	50                   	push   %eax
f0103b42:	68 18 3b 10 f0       	push   $0xf0103b18
f0103b47:	e8 62 10 00 00       	call   f0104bae <vprintfmt>
	return cnt;
}
f0103b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b4f:	c9                   	leave  
f0103b50:	c3                   	ret    

f0103b51 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b51:	55                   	push   %ebp
f0103b52:	89 e5                	mov    %esp,%ebp
f0103b54:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b57:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b5a:	50                   	push   %eax
f0103b5b:	ff 75 08             	pushl  0x8(%ebp)
f0103b5e:	e8 c8 ff ff ff       	call   f0103b2b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b63:	c9                   	leave  
f0103b64:	c3                   	ret    
f0103b65:	00 00                	add    %al,(%eax)
	...

f0103b68 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b68:	55                   	push   %ebp
f0103b69:	89 e5                	mov    %esp,%ebp
f0103b6b:	57                   	push   %edi
f0103b6c:	56                   	push   %esi
f0103b6d:	53                   	push   %ebx
f0103b6e:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	int cpu_id = cpunum();
f0103b71:	e8 62 1d 00 00       	call   f01058d8 <cpunum>
f0103b76:	89 c3                	mov    %eax,%ebx
	struct Taskstate* this_ts = &thiscpu->cpu_ts;
f0103b78:	e8 5b 1d 00 00       	call   f01058d8 <cpunum>

	this_ts->ts_esp0 = KSTACKTOP - cpu_id*(KSTKSIZE + KSTKGAP);
f0103b7d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103b80:	01 c2                	add    %eax,%edx
f0103b82:	01 d2                	add    %edx,%edx
f0103b84:	01 c2                	add    %eax,%edx
f0103b86:	c1 e2 02             	shl    $0x2,%edx
f0103b89:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
f0103b8c:	8d 34 8d 20 10 29 f0 	lea    -0xfd6efe0(,%ecx,4),%esi
f0103b93:	89 df                	mov    %ebx,%edi
f0103b95:	c1 e7 10             	shl    $0x10,%edi
f0103b98:	b9 00 00 00 f0       	mov    $0xf0000000,%ecx
f0103b9d:	29 f9                	sub    %edi,%ecx
f0103b9f:	89 4e 10             	mov    %ecx,0x10(%esi)
	this_ts->ts_ss0 = GD_KD;
f0103ba2:	66 c7 46 14 10 00    	movw   $0x10,0x14(%esi)
	this_ts->ts_iomb = sizeof(struct Taskstate);
f0103ba8:	01 d0                	add    %edx,%eax
f0103baa:	66 c7 04 85 92 10 29 	movw   $0x68,-0xfd6ef6e(,%eax,4)
f0103bb1:	f0 68 00 
	ts.ts_ss0 = GD_KD;
	ts.ts_iomb = sizeof(struct Taskstate);
	*/

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&this_ts),
f0103bb4:	8d 43 05             	lea    0x5(%ebx),%eax
f0103bb7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103bba:	66 c7 04 c5 40 13 12 	movw   $0x67,-0xfedecc0(,%eax,8)
f0103bc1:	f0 67 00 
f0103bc4:	66 89 14 c5 42 13 12 	mov    %dx,-0xfedecbe(,%eax,8)
f0103bcb:	f0 
f0103bcc:	89 d1                	mov    %edx,%ecx
f0103bce:	c1 e9 10             	shr    $0x10,%ecx
f0103bd1:	88 0c c5 44 13 12 f0 	mov    %cl,-0xfedecbc(,%eax,8)
f0103bd8:	c6 04 c5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%eax,8)
f0103bdf:	40 
f0103be0:	c1 ea 18             	shr    $0x18,%edx
f0103be3:	88 14 c5 47 13 12 f0 	mov    %dl,-0xfedecb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103bea:	c6 04 c5 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%eax,8)
f0103bf1:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpu_id << 3));
f0103bf2:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103bf9:	0f 00 db             	ltr    %bx
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103bfc:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103c01:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103c04:	83 c4 1c             	add    $0x1c,%esp
f0103c07:	5b                   	pop    %ebx
f0103c08:	5e                   	pop    %esi
f0103c09:	5f                   	pop    %edi
f0103c0a:	5d                   	pop    %ebp
f0103c0b:	c3                   	ret    

f0103c0c <trap_init>:
}


void
trap_init(void)
{
f0103c0c:	55                   	push   %ebp
f0103c0d:	89 e5                	mov    %esp,%ebp
f0103c0f:	83 ec 08             	sub    $0x8,%esp
	void handler17();
	void handler18();
	void handler19();
	void handler48();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, handler0, 0);
f0103c12:	b8 54 44 10 f0       	mov    $0xf0104454,%eax
f0103c17:	66 a3 60 02 29 f0    	mov    %ax,0xf0290260
f0103c1d:	66 c7 05 62 02 29 f0 	movw   $0x8,0xf0290262
f0103c24:	08 00 
f0103c26:	c6 05 64 02 29 f0 00 	movb   $0x0,0xf0290264
f0103c2d:	c6 05 65 02 29 f0 8f 	movb   $0x8f,0xf0290265
f0103c34:	c1 e8 10             	shr    $0x10,%eax
f0103c37:	66 a3 66 02 29 f0    	mov    %ax,0xf0290266
	SETGATE(idt[T_DEBUG], 1, GD_KT, handler1, 0);
f0103c3d:	b8 5a 44 10 f0       	mov    $0xf010445a,%eax
f0103c42:	66 a3 68 02 29 f0    	mov    %ax,0xf0290268
f0103c48:	66 c7 05 6a 02 29 f0 	movw   $0x8,0xf029026a
f0103c4f:	08 00 
f0103c51:	c6 05 6c 02 29 f0 00 	movb   $0x0,0xf029026c
f0103c58:	c6 05 6d 02 29 f0 8f 	movb   $0x8f,0xf029026d
f0103c5f:	c1 e8 10             	shr    $0x10,%eax
f0103c62:	66 a3 6e 02 29 f0    	mov    %ax,0xf029026e
	SETGATE(idt[T_NMI], 1, GD_KT, handler2, 0);
f0103c68:	b8 60 44 10 f0       	mov    $0xf0104460,%eax
f0103c6d:	66 a3 70 02 29 f0    	mov    %ax,0xf0290270
f0103c73:	66 c7 05 72 02 29 f0 	movw   $0x8,0xf0290272
f0103c7a:	08 00 
f0103c7c:	c6 05 74 02 29 f0 00 	movb   $0x0,0xf0290274
f0103c83:	c6 05 75 02 29 f0 8f 	movb   $0x8f,0xf0290275
f0103c8a:	c1 e8 10             	shr    $0x10,%eax
f0103c8d:	66 a3 76 02 29 f0    	mov    %ax,0xf0290276
	SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 3);
f0103c93:	b8 66 44 10 f0       	mov    $0xf0104466,%eax
f0103c98:	66 a3 78 02 29 f0    	mov    %ax,0xf0290278
f0103c9e:	66 c7 05 7a 02 29 f0 	movw   $0x8,0xf029027a
f0103ca5:	08 00 
f0103ca7:	c6 05 7c 02 29 f0 00 	movb   $0x0,0xf029027c
f0103cae:	c6 05 7d 02 29 f0 ef 	movb   $0xef,0xf029027d
f0103cb5:	c1 e8 10             	shr    $0x10,%eax
f0103cb8:	66 a3 7e 02 29 f0    	mov    %ax,0xf029027e
	SETGATE(idt[T_OFLOW], 1, GD_KT, handler4, 0);
f0103cbe:	b8 6c 44 10 f0       	mov    $0xf010446c,%eax
f0103cc3:	66 a3 80 02 29 f0    	mov    %ax,0xf0290280
f0103cc9:	66 c7 05 82 02 29 f0 	movw   $0x8,0xf0290282
f0103cd0:	08 00 
f0103cd2:	c6 05 84 02 29 f0 00 	movb   $0x0,0xf0290284
f0103cd9:	c6 05 85 02 29 f0 8f 	movb   $0x8f,0xf0290285
f0103ce0:	c1 e8 10             	shr    $0x10,%eax
f0103ce3:	66 a3 86 02 29 f0    	mov    %ax,0xf0290286
	SETGATE(idt[T_BOUND], 1, GD_KT, handler5, 0);
f0103ce9:	b8 72 44 10 f0       	mov    $0xf0104472,%eax
f0103cee:	66 a3 88 02 29 f0    	mov    %ax,0xf0290288
f0103cf4:	66 c7 05 8a 02 29 f0 	movw   $0x8,0xf029028a
f0103cfb:	08 00 
f0103cfd:	c6 05 8c 02 29 f0 00 	movb   $0x0,0xf029028c
f0103d04:	c6 05 8d 02 29 f0 8f 	movb   $0x8f,0xf029028d
f0103d0b:	c1 e8 10             	shr    $0x10,%eax
f0103d0e:	66 a3 8e 02 29 f0    	mov    %ax,0xf029028e
	SETGATE(idt[T_ILLOP], 1, GD_KT, handler6, 0);
f0103d14:	b8 78 44 10 f0       	mov    $0xf0104478,%eax
f0103d19:	66 a3 90 02 29 f0    	mov    %ax,0xf0290290
f0103d1f:	66 c7 05 92 02 29 f0 	movw   $0x8,0xf0290292
f0103d26:	08 00 
f0103d28:	c6 05 94 02 29 f0 00 	movb   $0x0,0xf0290294
f0103d2f:	c6 05 95 02 29 f0 8f 	movb   $0x8f,0xf0290295
f0103d36:	c1 e8 10             	shr    $0x10,%eax
f0103d39:	66 a3 96 02 29 f0    	mov    %ax,0xf0290296
	SETGATE(idt[T_DEVICE], 1, GD_KT, handler7, 0);
f0103d3f:	b8 7e 44 10 f0       	mov    $0xf010447e,%eax
f0103d44:	66 a3 98 02 29 f0    	mov    %ax,0xf0290298
f0103d4a:	66 c7 05 9a 02 29 f0 	movw   $0x8,0xf029029a
f0103d51:	08 00 
f0103d53:	c6 05 9c 02 29 f0 00 	movb   $0x0,0xf029029c
f0103d5a:	c6 05 9d 02 29 f0 8f 	movb   $0x8f,0xf029029d
f0103d61:	c1 e8 10             	shr    $0x10,%eax
f0103d64:	66 a3 9e 02 29 f0    	mov    %ax,0xf029029e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, handler8, 0);
f0103d6a:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103d6f:	66 a3 a0 02 29 f0    	mov    %ax,0xf02902a0
f0103d75:	66 c7 05 a2 02 29 f0 	movw   $0x8,0xf02902a2
f0103d7c:	08 00 
f0103d7e:	c6 05 a4 02 29 f0 00 	movb   $0x0,0xf02902a4
f0103d85:	c6 05 a5 02 29 f0 8f 	movb   $0x8f,0xf02902a5
f0103d8c:	c1 e8 10             	shr    $0x10,%eax
f0103d8f:	66 a3 a6 02 29 f0    	mov    %ax,0xf02902a6

	SETGATE(idt[T_TSS], 1, GD_KT, handler10, 0);
f0103d95:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103d9a:	66 a3 b0 02 29 f0    	mov    %ax,0xf02902b0
f0103da0:	66 c7 05 b2 02 29 f0 	movw   $0x8,0xf02902b2
f0103da7:	08 00 
f0103da9:	c6 05 b4 02 29 f0 00 	movb   $0x0,0xf02902b4
f0103db0:	c6 05 b5 02 29 f0 8f 	movb   $0x8f,0xf02902b5
f0103db7:	c1 e8 10             	shr    $0x10,%eax
f0103dba:	66 a3 b6 02 29 f0    	mov    %ax,0xf02902b6
	SETGATE(idt[T_SEGNP], 1, GD_KT, handler11, 0);
f0103dc0:	b8 8c 44 10 f0       	mov    $0xf010448c,%eax
f0103dc5:	66 a3 b8 02 29 f0    	mov    %ax,0xf02902b8
f0103dcb:	66 c7 05 ba 02 29 f0 	movw   $0x8,0xf02902ba
f0103dd2:	08 00 
f0103dd4:	c6 05 bc 02 29 f0 00 	movb   $0x0,0xf02902bc
f0103ddb:	c6 05 bd 02 29 f0 8f 	movb   $0x8f,0xf02902bd
f0103de2:	c1 e8 10             	shr    $0x10,%eax
f0103de5:	66 a3 be 02 29 f0    	mov    %ax,0xf02902be
	SETGATE(idt[T_STACK], 1, GD_KT, handler12, 0);
f0103deb:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103df0:	66 a3 c0 02 29 f0    	mov    %ax,0xf02902c0
f0103df6:	66 c7 05 c2 02 29 f0 	movw   $0x8,0xf02902c2
f0103dfd:	08 00 
f0103dff:	c6 05 c4 02 29 f0 00 	movb   $0x0,0xf02902c4
f0103e06:	c6 05 c5 02 29 f0 8f 	movb   $0x8f,0xf02902c5
f0103e0d:	c1 e8 10             	shr    $0x10,%eax
f0103e10:	66 a3 c6 02 29 f0    	mov    %ax,0xf02902c6
	SETGATE(idt[T_GPFLT], 1, GD_KT, handler13, 0);
f0103e16:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103e1b:	66 a3 c8 02 29 f0    	mov    %ax,0xf02902c8
f0103e21:	66 c7 05 ca 02 29 f0 	movw   $0x8,0xf02902ca
f0103e28:	08 00 
f0103e2a:	c6 05 cc 02 29 f0 00 	movb   $0x0,0xf02902cc
f0103e31:	c6 05 cd 02 29 f0 8f 	movb   $0x8f,0xf02902cd
f0103e38:	c1 e8 10             	shr    $0x10,%eax
f0103e3b:	66 a3 ce 02 29 f0    	mov    %ax,0xf02902ce
	SETGATE(idt[T_PGFLT], 1, GD_KT, handler14, 0);
f0103e41:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103e46:	66 a3 d0 02 29 f0    	mov    %ax,0xf02902d0
f0103e4c:	66 c7 05 d2 02 29 f0 	movw   $0x8,0xf02902d2
f0103e53:	08 00 
f0103e55:	c6 05 d4 02 29 f0 00 	movb   $0x0,0xf02902d4
f0103e5c:	c6 05 d5 02 29 f0 8f 	movb   $0x8f,0xf02902d5
f0103e63:	c1 e8 10             	shr    $0x10,%eax
f0103e66:	66 a3 d6 02 29 f0    	mov    %ax,0xf02902d6

	SETGATE(idt[T_FPERR], 1, GD_KT, handler16, 0);
f0103e6c:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103e71:	66 a3 e0 02 29 f0    	mov    %ax,0xf02902e0
f0103e77:	66 c7 05 e2 02 29 f0 	movw   $0x8,0xf02902e2
f0103e7e:	08 00 
f0103e80:	c6 05 e4 02 29 f0 00 	movb   $0x0,0xf02902e4
f0103e87:	c6 05 e5 02 29 f0 8f 	movb   $0x8f,0xf02902e5
f0103e8e:	c1 e8 10             	shr    $0x10,%eax
f0103e91:	66 a3 e6 02 29 f0    	mov    %ax,0xf02902e6
	SETGATE(idt[T_ALIGN], 1, GD_KT, handler17, 0);
f0103e97:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103e9c:	66 a3 e8 02 29 f0    	mov    %ax,0xf02902e8
f0103ea2:	66 c7 05 ea 02 29 f0 	movw   $0x8,0xf02902ea
f0103ea9:	08 00 
f0103eab:	c6 05 ec 02 29 f0 00 	movb   $0x0,0xf02902ec
f0103eb2:	c6 05 ed 02 29 f0 8f 	movb   $0x8f,0xf02902ed
f0103eb9:	c1 e8 10             	shr    $0x10,%eax
f0103ebc:	66 a3 ee 02 29 f0    	mov    %ax,0xf02902ee
	SETGATE(idt[T_MCHK], 1, GD_KT, handler18, 0);
f0103ec2:	b8 a6 44 10 f0       	mov    $0xf01044a6,%eax
f0103ec7:	66 a3 f0 02 29 f0    	mov    %ax,0xf02902f0
f0103ecd:	66 c7 05 f2 02 29 f0 	movw   $0x8,0xf02902f2
f0103ed4:	08 00 
f0103ed6:	c6 05 f4 02 29 f0 00 	movb   $0x0,0xf02902f4
f0103edd:	c6 05 f5 02 29 f0 8f 	movb   $0x8f,0xf02902f5
f0103ee4:	c1 e8 10             	shr    $0x10,%eax
f0103ee7:	66 a3 f6 02 29 f0    	mov    %ax,0xf02902f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, handler19, 0);
f0103eed:	b8 ac 44 10 f0       	mov    $0xf01044ac,%eax
f0103ef2:	66 a3 f8 02 29 f0    	mov    %ax,0xf02902f8
f0103ef8:	66 c7 05 fa 02 29 f0 	movw   $0x8,0xf02902fa
f0103eff:	08 00 
f0103f01:	c6 05 fc 02 29 f0 00 	movb   $0x0,0xf02902fc
f0103f08:	c6 05 fd 02 29 f0 8f 	movb   $0x8f,0xf02902fd
f0103f0f:	c1 e8 10             	shr    $0x10,%eax
f0103f12:	66 a3 fe 02 29 f0    	mov    %ax,0xf02902fe

	// interrupt
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f0103f18:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103f1d:	66 a3 e0 03 29 f0    	mov    %ax,0xf02903e0
f0103f23:	66 c7 05 e2 03 29 f0 	movw   $0x8,0xf02903e2
f0103f2a:	08 00 
f0103f2c:	c6 05 e4 03 29 f0 00 	movb   $0x0,0xf02903e4
f0103f33:	c6 05 e5 03 29 f0 ee 	movb   $0xee,0xf02903e5
f0103f3a:	c1 e8 10             	shr    $0x10,%eax
f0103f3d:	66 a3 e6 03 29 f0    	mov    %ax,0xf02903e6

	// Per-CPU setup
	trap_init_percpu();
f0103f43:	e8 20 fc ff ff       	call   f0103b68 <trap_init_percpu>
}
f0103f48:	c9                   	leave  
f0103f49:	c3                   	ret    

f0103f4a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f4a:	55                   	push   %ebp
f0103f4b:	89 e5                	mov    %esp,%ebp
f0103f4d:	53                   	push   %ebx
f0103f4e:	83 ec 0c             	sub    $0xc,%esp
f0103f51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f54:	ff 33                	pushl  (%ebx)
f0103f56:	68 32 73 10 f0       	push   $0xf0107332
f0103f5b:	e8 f1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f60:	83 c4 08             	add    $0x8,%esp
f0103f63:	ff 73 04             	pushl  0x4(%ebx)
f0103f66:	68 41 73 10 f0       	push   $0xf0107341
f0103f6b:	e8 e1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f70:	83 c4 08             	add    $0x8,%esp
f0103f73:	ff 73 08             	pushl  0x8(%ebx)
f0103f76:	68 50 73 10 f0       	push   $0xf0107350
f0103f7b:	e8 d1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f80:	83 c4 08             	add    $0x8,%esp
f0103f83:	ff 73 0c             	pushl  0xc(%ebx)
f0103f86:	68 5f 73 10 f0       	push   $0xf010735f
f0103f8b:	e8 c1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f90:	83 c4 08             	add    $0x8,%esp
f0103f93:	ff 73 10             	pushl  0x10(%ebx)
f0103f96:	68 6e 73 10 f0       	push   $0xf010736e
f0103f9b:	e8 b1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103fa0:	83 c4 08             	add    $0x8,%esp
f0103fa3:	ff 73 14             	pushl  0x14(%ebx)
f0103fa6:	68 7d 73 10 f0       	push   $0xf010737d
f0103fab:	e8 a1 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103fb0:	83 c4 08             	add    $0x8,%esp
f0103fb3:	ff 73 18             	pushl  0x18(%ebx)
f0103fb6:	68 8c 73 10 f0       	push   $0xf010738c
f0103fbb:	e8 91 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fc0:	83 c4 08             	add    $0x8,%esp
f0103fc3:	ff 73 1c             	pushl  0x1c(%ebx)
f0103fc6:	68 9b 73 10 f0       	push   $0xf010739b
f0103fcb:	e8 81 fb ff ff       	call   f0103b51 <cprintf>
}
f0103fd0:	83 c4 10             	add    $0x10,%esp
f0103fd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103fd6:	c9                   	leave  
f0103fd7:	c3                   	ret    

f0103fd8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103fd8:	55                   	push   %ebp
f0103fd9:	89 e5                	mov    %esp,%ebp
f0103fdb:	53                   	push   %ebx
f0103fdc:	83 ec 04             	sub    $0x4,%esp
f0103fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103fe2:	e8 f1 18 00 00       	call   f01058d8 <cpunum>
f0103fe7:	83 ec 04             	sub    $0x4,%esp
f0103fea:	50                   	push   %eax
f0103feb:	53                   	push   %ebx
f0103fec:	68 ff 73 10 f0       	push   $0xf01073ff
f0103ff1:	e8 5b fb ff ff       	call   f0103b51 <cprintf>
	print_regs(&tf->tf_regs);
f0103ff6:	89 1c 24             	mov    %ebx,(%esp)
f0103ff9:	e8 4c ff ff ff       	call   f0103f4a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ffe:	83 c4 08             	add    $0x8,%esp
f0104001:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104005:	50                   	push   %eax
f0104006:	68 1d 74 10 f0       	push   $0xf010741d
f010400b:	e8 41 fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104010:	83 c4 08             	add    $0x8,%esp
f0104013:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104017:	50                   	push   %eax
f0104018:	68 30 74 10 f0       	push   $0xf0107430
f010401d:	e8 2f fb ff ff       	call   f0103b51 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104022:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0104025:	83 c4 10             	add    $0x10,%esp
f0104028:	83 f8 13             	cmp    $0x13,%eax
f010402b:	76 1c                	jbe    f0104049 <print_trapframe+0x71>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f010402d:	83 f8 30             	cmp    $0x30,%eax
f0104030:	0f 84 cf 00 00 00    	je     f0104105 <print_trapframe+0x12d>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104036:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104039:	83 fa 0f             	cmp    $0xf,%edx
f010403c:	0f 86 cd 00 00 00    	jbe    f010410f <print_trapframe+0x137>
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104042:	ba c9 73 10 f0       	mov    $0xf01073c9,%edx
f0104047:	eb 07                	jmp    f0104050 <print_trapframe+0x78>
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
f0104049:	8b 14 85 c0 76 10 f0 	mov    -0xfef8940(,%eax,4),%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104050:	83 ec 04             	sub    $0x4,%esp
f0104053:	52                   	push   %edx
f0104054:	50                   	push   %eax
f0104055:	68 43 74 10 f0       	push   $0xf0107443
f010405a:	e8 f2 fa ff ff       	call   f0103b51 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010405f:	83 c4 10             	add    $0x10,%esp
f0104062:	39 1d 60 0a 29 f0    	cmp    %ebx,0xf0290a60
f0104068:	0f 84 ab 00 00 00    	je     f0104119 <print_trapframe+0x141>
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
f010406e:	83 ec 08             	sub    $0x8,%esp
f0104071:	ff 73 2c             	pushl  0x2c(%ebx)
f0104074:	68 64 74 10 f0       	push   $0xf0107464
f0104079:	e8 d3 fa ff ff       	call   f0103b51 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010407e:	83 c4 10             	add    $0x10,%esp
f0104081:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104085:	0f 85 cf 00 00 00    	jne    f010415a <print_trapframe+0x182>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010408b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010408e:	a8 01                	test   $0x1,%al
f0104090:	0f 85 a6 00 00 00    	jne    f010413c <print_trapframe+0x164>
f0104096:	b9 e3 73 10 f0       	mov    $0xf01073e3,%ecx
f010409b:	a8 02                	test   $0x2,%al
f010409d:	0f 85 a3 00 00 00    	jne    f0104146 <print_trapframe+0x16e>
f01040a3:	ba f5 73 10 f0       	mov    $0xf01073f5,%edx
f01040a8:	a8 04                	test   $0x4,%al
f01040aa:	0f 85 a0 00 00 00    	jne    f0104150 <print_trapframe+0x178>
f01040b0:	b8 49 75 10 f0       	mov    $0xf0107549,%eax
f01040b5:	51                   	push   %ecx
f01040b6:	52                   	push   %edx
f01040b7:	50                   	push   %eax
f01040b8:	68 72 74 10 f0       	push   $0xf0107472
f01040bd:	e8 8f fa ff ff       	call   f0103b51 <cprintf>
f01040c2:	83 c4 10             	add    $0x10,%esp
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040c5:	83 ec 08             	sub    $0x8,%esp
f01040c8:	ff 73 30             	pushl  0x30(%ebx)
f01040cb:	68 81 74 10 f0       	push   $0xf0107481
f01040d0:	e8 7c fa ff ff       	call   f0103b51 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040d5:	83 c4 08             	add    $0x8,%esp
f01040d8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01040dc:	50                   	push   %eax
f01040dd:	68 90 74 10 f0       	push   $0xf0107490
f01040e2:	e8 6a fa ff ff       	call   f0103b51 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040e7:	83 c4 08             	add    $0x8,%esp
f01040ea:	ff 73 38             	pushl  0x38(%ebx)
f01040ed:	68 a3 74 10 f0       	push   $0xf01074a3
f01040f2:	e8 5a fa ff ff       	call   f0103b51 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01040f7:	83 c4 10             	add    $0x10,%esp
f01040fa:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040fe:	75 6f                	jne    f010416f <print_trapframe+0x197>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}
f0104100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104103:	c9                   	leave  
f0104104:	c3                   	ret    
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104105:	ba aa 73 10 f0       	mov    $0xf01073aa,%edx
f010410a:	e9 41 ff ff ff       	jmp    f0104050 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
f010410f:	ba b6 73 10 f0       	mov    $0xf01073b6,%edx
f0104114:	e9 37 ff ff ff       	jmp    f0104050 <print_trapframe+0x78>
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104119:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010411d:	0f 85 4b ff ff ff    	jne    f010406e <print_trapframe+0x96>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104123:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104126:	83 ec 08             	sub    $0x8,%esp
f0104129:	50                   	push   %eax
f010412a:	68 55 74 10 f0       	push   $0xf0107455
f010412f:	e8 1d fa ff ff       	call   f0103b51 <cprintf>
f0104134:	83 c4 10             	add    $0x10,%esp
f0104137:	e9 32 ff ff ff       	jmp    f010406e <print_trapframe+0x96>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010413c:	b9 d8 73 10 f0       	mov    $0xf01073d8,%ecx
f0104141:	e9 55 ff ff ff       	jmp    f010409b <print_trapframe+0xc3>
f0104146:	ba ef 73 10 f0       	mov    $0xf01073ef,%edx
f010414b:	e9 58 ff ff ff       	jmp    f01040a8 <print_trapframe+0xd0>
f0104150:	b8 fa 73 10 f0       	mov    $0xf01073fa,%eax
f0104155:	e9 5b ff ff ff       	jmp    f01040b5 <print_trapframe+0xdd>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010415a:	83 ec 0c             	sub    $0xc,%esp
f010415d:	68 27 72 10 f0       	push   $0xf0107227
f0104162:	e8 ea f9 ff ff       	call   f0103b51 <cprintf>
f0104167:	83 c4 10             	add    $0x10,%esp
f010416a:	e9 56 ff ff ff       	jmp    f01040c5 <print_trapframe+0xed>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010416f:	83 ec 08             	sub    $0x8,%esp
f0104172:	ff 73 3c             	pushl  0x3c(%ebx)
f0104175:	68 b2 74 10 f0       	push   $0xf01074b2
f010417a:	e8 d2 f9 ff ff       	call   f0103b51 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010417f:	83 c4 08             	add    $0x8,%esp
f0104182:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104186:	50                   	push   %eax
f0104187:	68 c1 74 10 f0       	push   $0xf01074c1
f010418c:	e8 c0 f9 ff ff       	call   f0103b51 <cprintf>
f0104191:	83 c4 10             	add    $0x10,%esp
	}
}
f0104194:	e9 67 ff ff ff       	jmp    f0104100 <print_trapframe+0x128>

f0104199 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104199:	55                   	push   %ebp
f010419a:	89 e5                	mov    %esp,%ebp
f010419c:	57                   	push   %edi
f010419d:	56                   	push   %esi
f010419e:	53                   	push   %ebx
f010419f:	83 ec 18             	sub    $0x18,%esp
f01041a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01041a5:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f01041a8:	53                   	push   %ebx
f01041a9:	e8 2a fe ff ff       	call   f0103fd8 <print_trapframe>

	// LAB 3: Your code here.
	// tf_cs last 2 bits represents user-mode or kernel-mode, 0 means kern-mode, 3 mean user-mode
    if ((tf->tf_cs & 0x01) == 0) panic("page fault in kernel-mode");
f01041ae:	83 c4 10             	add    $0x10,%esp
f01041b1:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f01041b5:	74 5d                	je     f0104214 <page_fault_handler+0x7b>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041b7:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041ba:	e8 19 17 00 00       	call   f01058d8 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041bf:	57                   	push   %edi
f01041c0:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01041c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01041c4:	01 c2                	add    %eax,%edx
f01041c6:	01 d2                	add    %edx,%edx
f01041c8:	01 c2                	add    %eax,%edx
f01041ca:	8d 04 90             	lea    (%eax,%edx,4),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041cd:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01041d4:	ff 70 48             	pushl  0x48(%eax)
f01041d7:	68 94 76 10 f0       	push   $0xf0107694
f01041dc:	e8 70 f9 ff ff       	call   f0103b51 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041e1:	89 1c 24             	mov    %ebx,(%esp)
f01041e4:	e8 ef fd ff ff       	call   f0103fd8 <print_trapframe>
	env_destroy(curenv);
f01041e9:	e8 ea 16 00 00       	call   f01058d8 <cpunum>
f01041ee:	83 c4 04             	add    $0x4,%esp
f01041f1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01041f4:	01 c2                	add    %eax,%edx
f01041f6:	01 d2                	add    %edx,%edx
f01041f8:	01 c2                	add    %eax,%edx
f01041fa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041fd:	ff 34 85 28 10 29 f0 	pushl  -0xfd6efd8(,%eax,4)
f0104204:	e8 72 f6 ff ff       	call   f010387b <env_destroy>
}
f0104209:	83 c4 10             	add    $0x10,%esp
f010420c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010420f:	5b                   	pop    %ebx
f0104210:	5e                   	pop    %esi
f0104211:	5f                   	pop    %edi
f0104212:	5d                   	pop    %ebp
f0104213:	c3                   	ret    
	// Handle kernel-mode page faults.
	print_trapframe(tf);

	// LAB 3: Your code here.
	// tf_cs last 2 bits represents user-mode or kernel-mode, 0 means kern-mode, 3 mean user-mode
    if ((tf->tf_cs & 0x01) == 0) panic("page fault in kernel-mode");
f0104214:	83 ec 04             	sub    $0x4,%esp
f0104217:	68 d4 74 10 f0       	push   $0xf01074d4
f010421c:	68 5b 01 00 00       	push   $0x15b
f0104221:	68 ee 74 10 f0       	push   $0xf01074ee
f0104226:	e8 15 be ff ff       	call   f0100040 <_panic>

f010422b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010422b:	55                   	push   %ebp
f010422c:	89 e5                	mov    %esp,%ebp
f010422e:	57                   	push   %edi
f010422f:	56                   	push   %esi
f0104230:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104233:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104234:	83 3d 80 0e 29 f0 00 	cmpl   $0x0,0xf0290e80
f010423b:	74 01                	je     f010423e <trap+0x13>
		asm volatile("hlt");
f010423d:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010423e:	e8 95 16 00 00       	call   f01058d8 <cpunum>
f0104243:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104246:	01 c2                	add    %eax,%edx
f0104248:	01 d2                	add    %edx,%edx
f010424a:	01 c2                	add    %eax,%edx
f010424c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010424f:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104256:	b8 01 00 00 00       	mov    $0x1,%eax
f010425b:	f0 87 82 20 10 29 f0 	lock xchg %eax,-0xfd6efe0(%edx)
f0104262:	83 f8 02             	cmp    $0x2,%eax
f0104265:	74 7e                	je     f01042e5 <trap+0xba>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104267:	9c                   	pushf  
f0104268:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104269:	f6 c4 02             	test   $0x2,%ah
f010426c:	0f 85 88 00 00 00    	jne    f01042fa <trap+0xcf>

	if ((tf->tf_cs & 3) == 3) {
f0104272:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104276:	83 e0 03             	and    $0x3,%eax
f0104279:	66 83 f8 03          	cmp    $0x3,%ax
f010427d:	0f 84 90 00 00 00    	je     f0104313 <trap+0xe8>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104283:	89 35 60 0a 29 f0    	mov    %esi,0xf0290a60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104289:	8b 46 28             	mov    0x28(%esi),%eax
f010428c:	83 f8 27             	cmp    $0x27,%eax
f010428f:	0f 84 13 01 00 00    	je     f01043a8 <trap+0x17d>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

    switch (tf->tf_trapno) {
f0104295:	83 f8 0e             	cmp    $0xe,%eax
f0104298:	0f 84 24 01 00 00    	je     f01043c2 <trap+0x197>
f010429e:	83 f8 30             	cmp    $0x30,%eax
f01042a1:	0f 84 5f 01 00 00    	je     f0104406 <trap+0x1db>
f01042a7:	83 f8 03             	cmp    $0x3,%eax
f01042aa:	0f 84 48 01 00 00    	je     f01043f8 <trap+0x1cd>
										  tf->tf_regs.reg_edi,
										  tf->tf_regs.reg_esi);
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
f01042b0:	83 ec 0c             	sub    $0xc,%esp
f01042b3:	56                   	push   %esi
f01042b4:	e8 1f fd ff ff       	call   f0103fd8 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01042b9:	83 c4 10             	add    $0x10,%esp
f01042bc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042c1:	0f 84 60 01 00 00    	je     f0104427 <trap+0x1fc>
				panic("unhandled trap in kernel");
			else {
				env_destroy(curenv);
f01042c7:	e8 0c 16 00 00       	call   f01058d8 <cpunum>
f01042cc:	83 ec 0c             	sub    $0xc,%esp
f01042cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d2:	ff b0 28 10 29 f0    	pushl  -0xfd6efd8(%eax)
f01042d8:	e8 9e f5 ff ff       	call   f010387b <env_destroy>
f01042dd:	83 c4 10             	add    $0x10,%esp
f01042e0:	e9 e9 00 00 00       	jmp    f01043ce <trap+0x1a3>
f01042e5:	83 ec 0c             	sub    $0xc,%esp
f01042e8:	68 c0 13 12 f0       	push   $0xf01213c0
f01042ed:	e8 5d 18 00 00       	call   f0105b4f <spin_lock>
f01042f2:	83 c4 10             	add    $0x10,%esp
f01042f5:	e9 6d ff ff ff       	jmp    f0104267 <trap+0x3c>
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01042fa:	68 fa 74 10 f0       	push   $0xf01074fa
f01042ff:	68 37 6f 10 f0       	push   $0xf0106f37
f0104304:	68 25 01 00 00       	push   $0x125
f0104309:	68 ee 74 10 f0       	push   $0xf01074ee
f010430e:	e8 2d bd ff ff       	call   f0100040 <_panic>
	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104313:	e8 c0 15 00 00       	call   f01058d8 <cpunum>
f0104318:	6b c0 74             	imul   $0x74,%eax,%eax
f010431b:	83 b8 28 10 29 f0 00 	cmpl   $0x0,-0xfd6efd8(%eax)
f0104322:	74 3e                	je     f0104362 <trap+0x137>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104324:	e8 af 15 00 00       	call   f01058d8 <cpunum>
f0104329:	6b c0 74             	imul   $0x74,%eax,%eax
f010432c:	8b 80 28 10 29 f0    	mov    -0xfd6efd8(%eax),%eax
f0104332:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104336:	74 43                	je     f010437b <trap+0x150>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104338:	e8 9b 15 00 00       	call   f01058d8 <cpunum>
f010433d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104340:	8b 80 28 10 29 f0    	mov    -0xfd6efd8(%eax),%eax
f0104346:	b9 11 00 00 00       	mov    $0x11,%ecx
f010434b:	89 c7                	mov    %eax,%edi
f010434d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010434f:	e8 84 15 00 00       	call   f01058d8 <cpunum>
f0104354:	6b c0 74             	imul   $0x74,%eax,%eax
f0104357:	8b b0 28 10 29 f0    	mov    -0xfd6efd8(%eax),%esi
f010435d:	e9 21 ff ff ff       	jmp    f0104283 <trap+0x58>
	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104362:	68 13 75 10 f0       	push   $0xf0107513
f0104367:	68 37 6f 10 f0       	push   $0xf0106f37
f010436c:	68 2c 01 00 00       	push   $0x12c
f0104371:	68 ee 74 10 f0       	push   $0xf01074ee
f0104376:	e8 c5 bc ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
f010437b:	e8 58 15 00 00       	call   f01058d8 <cpunum>
f0104380:	83 ec 0c             	sub    $0xc,%esp
f0104383:	6b c0 74             	imul   $0x74,%eax,%eax
f0104386:	ff b0 28 10 29 f0    	pushl  -0xfd6efd8(%eax)
f010438c:	e8 dc f2 ff ff       	call   f010366d <env_free>
			curenv = NULL;
f0104391:	e8 42 15 00 00       	call   f01058d8 <cpunum>
f0104396:	6b c0 74             	imul   $0x74,%eax,%eax
f0104399:	c7 80 28 10 29 f0 00 	movl   $0x0,-0xfd6efd8(%eax)
f01043a0:	00 00 00 
			sched_yield();
f01043a3:	e8 12 02 00 00       	call   f01045ba <sched_yield>

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
f01043a8:	83 ec 0c             	sub    $0xc,%esp
f01043ab:	68 1a 75 10 f0       	push   $0xf010751a
f01043b0:	e8 9c f7 ff ff       	call   f0103b51 <cprintf>
		print_trapframe(tf);
f01043b5:	89 34 24             	mov    %esi,(%esp)
f01043b8:	e8 1b fc ff ff       	call   f0103fd8 <print_trapframe>
f01043bd:	83 c4 10             	add    $0x10,%esp
f01043c0:	eb 0c                	jmp    f01043ce <trap+0x1a3>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

    switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
f01043c2:	83 ec 0c             	sub    $0xc,%esp
f01043c5:	56                   	push   %esi
f01043c6:	e8 ce fd ff ff       	call   f0104199 <page_fault_handler>
f01043cb:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01043ce:	e8 05 15 00 00       	call   f01058d8 <cpunum>
f01043d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d6:	83 b8 28 10 29 f0 00 	cmpl   $0x0,-0xfd6efd8(%eax)
f01043dd:	74 14                	je     f01043f3 <trap+0x1c8>
f01043df:	e8 f4 14 00 00       	call   f01058d8 <cpunum>
f01043e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e7:	8b 80 28 10 29 f0    	mov    -0xfd6efd8(%eax),%eax
f01043ed:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01043f1:	74 4b                	je     f010443e <trap+0x213>
		env_run(curenv);
	else
		sched_yield();
f01043f3:	e8 c2 01 00 00       	call   f01045ba <sched_yield>
    switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
f01043f8:	83 ec 0c             	sub    $0xc,%esp
f01043fb:	56                   	push   %esi
f01043fc:	e8 b5 c6 ff ff       	call   f0100ab6 <monitor>
f0104401:	83 c4 10             	add    $0x10,%esp
f0104404:	eb c8                	jmp    f01043ce <trap+0x1a3>
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0104406:	83 ec 08             	sub    $0x8,%esp
f0104409:	ff 76 04             	pushl  0x4(%esi)
f010440c:	ff 36                	pushl  (%esi)
f010440e:	ff 76 10             	pushl  0x10(%esi)
f0104411:	ff 76 18             	pushl  0x18(%esi)
f0104414:	ff 76 14             	pushl  0x14(%esi)
f0104417:	ff 76 1c             	pushl  0x1c(%esi)
f010441a:	e8 a9 01 00 00       	call   f01045c8 <syscall>
f010441f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104422:	83 c4 20             	add    $0x20,%esp
f0104425:	eb a7                	jmp    f01043ce <trap+0x1a3>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
			if (tf->tf_cs == GD_KT)
				panic("unhandled trap in kernel");
f0104427:	83 ec 04             	sub    $0x4,%esp
f010442a:	68 37 75 10 f0       	push   $0xf0107537
f010442f:	68 0a 01 00 00       	push   $0x10a
f0104434:	68 ee 74 10 f0       	push   $0xf01074ee
f0104439:	e8 02 bc ff ff       	call   f0100040 <_panic>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
f010443e:	e8 95 14 00 00       	call   f01058d8 <cpunum>
f0104443:	83 ec 0c             	sub    $0xc,%esp
f0104446:	6b c0 74             	imul   $0x74,%eax,%eax
f0104449:	ff b0 28 10 29 f0    	pushl  -0xfd6efd8(%eax)
f010444f:	e8 e4 f4 ff ff       	call   f0103938 <env_run>

f0104454 <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

 TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104454:	6a 00                	push   $0x0
f0104456:	6a 00                	push   $0x0
f0104458:	eb 5e                	jmp    f01044b8 <_alltraps>

f010445a <handler1>:
 TRAPHANDLER_NOEC(handler1, T_DEBUG)
f010445a:	6a 00                	push   $0x0
f010445c:	6a 01                	push   $0x1
f010445e:	eb 58                	jmp    f01044b8 <_alltraps>

f0104460 <handler2>:
 TRAPHANDLER_NOEC(handler2, T_NMI)
f0104460:	6a 00                	push   $0x0
f0104462:	6a 02                	push   $0x2
f0104464:	eb 52                	jmp    f01044b8 <_alltraps>

f0104466 <handler3>:
 TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104466:	6a 00                	push   $0x0
f0104468:	6a 03                	push   $0x3
f010446a:	eb 4c                	jmp    f01044b8 <_alltraps>

f010446c <handler4>:
 TRAPHANDLER_NOEC(handler4, T_OFLOW)
f010446c:	6a 00                	push   $0x0
f010446e:	6a 04                	push   $0x4
f0104470:	eb 46                	jmp    f01044b8 <_alltraps>

f0104472 <handler5>:
 TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104472:	6a 00                	push   $0x0
f0104474:	6a 05                	push   $0x5
f0104476:	eb 40                	jmp    f01044b8 <_alltraps>

f0104478 <handler6>:
 TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104478:	6a 00                	push   $0x0
f010447a:	6a 06                	push   $0x6
f010447c:	eb 3a                	jmp    f01044b8 <_alltraps>

f010447e <handler7>:
 TRAPHANDLER_NOEC(handler7, T_DEVICE)
f010447e:	6a 00                	push   $0x0
f0104480:	6a 07                	push   $0x7
f0104482:	eb 34                	jmp    f01044b8 <_alltraps>

f0104484 <handler8>:
 TRAPHANDLER(handler8, T_DBLFLT)
f0104484:	6a 08                	push   $0x8
f0104486:	eb 30                	jmp    f01044b8 <_alltraps>

f0104488 <handler10>:

 // 9 deprecated since 386
 TRAPHANDLER(handler10, T_TSS)
f0104488:	6a 0a                	push   $0xa
f010448a:	eb 2c                	jmp    f01044b8 <_alltraps>

f010448c <handler11>:
 TRAPHANDLER(handler11, T_SEGNP)
f010448c:	6a 0b                	push   $0xb
f010448e:	eb 28                	jmp    f01044b8 <_alltraps>

f0104490 <handler12>:
 TRAPHANDLER(handler12, T_STACK)
f0104490:	6a 0c                	push   $0xc
f0104492:	eb 24                	jmp    f01044b8 <_alltraps>

f0104494 <handler13>:
 TRAPHANDLER(handler13, T_GPFLT)
f0104494:	6a 0d                	push   $0xd
f0104496:	eb 20                	jmp    f01044b8 <_alltraps>

f0104498 <handler14>:
 TRAPHANDLER(handler14, T_PGFLT)
f0104498:	6a 0e                	push   $0xe
f010449a:	eb 1c                	jmp    f01044b8 <_alltraps>

f010449c <handler16>:

 // 15 reserved by intel
 TRAPHANDLER_NOEC(handler16, T_FPERR)
f010449c:	6a 00                	push   $0x0
f010449e:	6a 10                	push   $0x10
f01044a0:	eb 16                	jmp    f01044b8 <_alltraps>

f01044a2 <handler17>:
 TRAPHANDLER(handler17, T_ALIGN)
f01044a2:	6a 11                	push   $0x11
f01044a4:	eb 12                	jmp    f01044b8 <_alltraps>

f01044a6 <handler18>:
 TRAPHANDLER_NOEC(handler18, T_MCHK)
f01044a6:	6a 00                	push   $0x0
f01044a8:	6a 12                	push   $0x12
f01044aa:	eb 0c                	jmp    f01044b8 <_alltraps>

f01044ac <handler19>:
 TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 13                	push   $0x13
f01044b0:	eb 06                	jmp    f01044b8 <_alltraps>

f01044b2 <handler48>:

 // system call (interrupt)
 TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f01044b2:	6a 00                	push   $0x0
f01044b4:	6a 30                	push   $0x30
f01044b6:	eb 00                	jmp    f01044b8 <_alltraps>

f01044b8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
    pushl %ds
f01044b8:	1e                   	push   %ds
    pushl %es
f01044b9:	06                   	push   %es
    pushal
f01044ba:	60                   	pusha  

    movw $GD_KD, %ax
f01044bb:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f01044bf:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f01044c1:	8e c0                	mov    %eax,%es
    pushl %esp
f01044c3:	54                   	push   %esp
    call trap
f01044c4:	e8 62 fd ff ff       	call   f010422b <trap>
f01044c9:	00 00                	add    %al,(%eax)
	...

f01044cc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044cc:	55                   	push   %ebp
f01044cd:	89 e5                	mov    %esp,%ebp
f01044cf:	83 ec 08             	sub    $0x8,%esp
f01044d2:	a1 48 02 29 f0       	mov    0xf0290248,%eax
f01044d7:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044da:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044df:	8b 10                	mov    (%eax),%edx
f01044e1:	4a                   	dec    %edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044e2:	83 fa 02             	cmp    $0x2,%edx
f01044e5:	76 2b                	jbe    f0104512 <sched_halt+0x46>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044e7:	41                   	inc    %ecx
f01044e8:	83 c0 7c             	add    $0x7c,%eax
f01044eb:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044f1:	75 ec                	jne    f01044df <sched_halt+0x13>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044f3:	83 ec 0c             	sub    $0xc,%esp
f01044f6:	68 10 77 10 f0       	push   $0xf0107710
f01044fb:	e8 51 f6 ff ff       	call   f0103b51 <cprintf>
f0104500:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104503:	83 ec 0c             	sub    $0xc,%esp
f0104506:	6a 00                	push   $0x0
f0104508:	e8 a9 c5 ff ff       	call   f0100ab6 <monitor>
f010450d:	83 c4 10             	add    $0x10,%esp
f0104510:	eb f1                	jmp    f0104503 <sched_halt+0x37>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104512:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104518:	74 d9                	je     f01044f3 <sched_halt+0x27>
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010451a:	e8 b9 13 00 00       	call   f01058d8 <cpunum>
f010451f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104522:	01 c2                	add    %eax,%edx
f0104524:	01 d2                	add    %edx,%edx
f0104526:	01 c2                	add    %eax,%edx
f0104528:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010452b:	c7 04 85 28 10 29 f0 	movl   $0x0,-0xfd6efd8(,%eax,4)
f0104532:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104536:	a1 8c 0e 29 f0       	mov    0xf0290e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010453b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104540:	76 66                	jbe    f01045a8 <sched_halt+0xdc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0104542:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104547:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010454a:	e8 89 13 00 00       	call   f01058d8 <cpunum>
f010454f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104552:	01 c2                	add    %eax,%edx
f0104554:	01 d2                	add    %edx,%edx
f0104556:	01 c2                	add    %eax,%edx
f0104558:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010455b:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104562:	b8 02 00 00 00       	mov    $0x2,%eax
f0104567:	f0 87 82 20 10 29 f0 	lock xchg %eax,-0xfd6efe0(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010456e:	83 ec 0c             	sub    $0xc,%esp
f0104571:	68 c0 13 12 f0       	push   $0xf01213c0
f0104576:	e8 81 16 00 00       	call   f0105bfc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010457b:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010457d:	e8 56 13 00 00       	call   f01058d8 <cpunum>
f0104582:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104585:	01 c2                	add    %eax,%edx
f0104587:	01 d2                	add    %edx,%edx
f0104589:	01 c2                	add    %eax,%edx
f010458b:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010458e:	8b 04 85 30 10 29 f0 	mov    -0xfd6efd0(,%eax,4),%eax
f0104595:	bd 00 00 00 00       	mov    $0x0,%ebp
f010459a:	89 c4                	mov    %eax,%esp
f010459c:	6a 00                	push   $0x0
f010459e:	6a 00                	push   $0x0
f01045a0:	f4                   	hlt    
f01045a1:	eb fd                	jmp    f01045a0 <sched_halt+0xd4>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01045a3:	83 c4 10             	add    $0x10,%esp
f01045a6:	c9                   	leave  
f01045a7:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045a8:	50                   	push   %eax
f01045a9:	68 48 5f 10 f0       	push   $0xf0105f48
f01045ae:	6a 3d                	push   $0x3d
f01045b0:	68 39 77 10 f0       	push   $0xf0107739
f01045b5:	e8 86 ba ff ff       	call   f0100040 <_panic>

f01045ba <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045ba:	55                   	push   %ebp
f01045bb:	89 e5                	mov    %esp,%ebp
f01045bd:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f01045c0:	e8 07 ff ff ff       	call   f01044cc <sched_halt>
}
f01045c5:	c9                   	leave  
f01045c6:	c3                   	ret    
	...

f01045c8 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045c8:	55                   	push   %ebp
f01045c9:	89 e5                	mov    %esp,%ebp
f01045cb:	53                   	push   %ebx
f01045cc:	83 ec 14             	sub    $0x14,%esp
f01045cf:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int32_t retVal = 0;
	switch (syscallno) {
f01045d2:	83 f8 01             	cmp    $0x1,%eax
f01045d5:	74 5f                	je     f0104636 <syscall+0x6e>
f01045d7:	83 f8 01             	cmp    $0x1,%eax
f01045da:	72 15                	jb     f01045f1 <syscall+0x29>
f01045dc:	83 f8 02             	cmp    $0x2,%eax
f01045df:	0f 84 01 01 00 00    	je     f01046e6 <syscall+0x11e>
f01045e5:	83 f8 03             	cmp    $0x3,%eax
f01045e8:	74 53                	je     f010463d <syscall+0x75>
			break;
		case SYS_getenvid:
			retVal = sys_getenvid();
			break;
	default:
		return -E_INVAL;
f01045ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01045ef:	eb 40                	jmp    f0104631 <syscall+0x69>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f01045f1:	e8 e2 12 00 00       	call   f01058d8 <cpunum>
f01045f6:	6a 04                	push   $0x4
f01045f8:	ff 75 10             	pushl  0x10(%ebp)
f01045fb:	ff 75 0c             	pushl  0xc(%ebp)
f01045fe:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104601:	01 c2                	add    %eax,%edx
f0104603:	01 d2                	add    %edx,%edx
f0104605:	01 c2                	add    %eax,%edx
f0104607:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010460a:	ff 34 85 28 10 29 f0 	pushl  -0xfd6efd8(,%eax,4)
f0104611:	e8 39 eb ff ff       	call   f010314f <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104616:	83 c4 0c             	add    $0xc,%esp
f0104619:	ff 75 0c             	pushl  0xc(%ebp)
f010461c:	ff 75 10             	pushl  0x10(%ebp)
f010461f:	68 46 77 10 f0       	push   $0xf0107746
f0104624:	e8 28 f5 ff ff       	call   f0103b51 <cprintf>
f0104629:	83 c4 10             	add    $0x10,%esp
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int32_t retVal = 0;
f010462c:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
		return -E_INVAL;
	}

	return retVal;
}
f0104631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104634:	c9                   	leave  
f0104635:	c3                   	ret    
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104636:	e8 db bf ff ff       	call   f0100616 <cons_getc>
		case SYS_cputs:
			sys_cputs((const char*)a1, a2);
			break;
		case SYS_cgetc:
			retVal = sys_cgetc();
			break;
f010463b:	eb f4                	jmp    f0104631 <syscall+0x69>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010463d:	83 ec 04             	sub    $0x4,%esp
f0104640:	6a 01                	push   $0x1
f0104642:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104645:	50                   	push   %eax
f0104646:	ff 75 0c             	pushl  0xc(%ebp)
f0104649:	e8 cb eb ff ff       	call   f0103219 <envid2env>
f010464e:	83 c4 10             	add    $0x10,%esp
f0104651:	85 c0                	test   %eax,%eax
f0104653:	78 dc                	js     f0104631 <syscall+0x69>
		return r;
	if (e == curenv)
f0104655:	e8 7e 12 00 00       	call   f01058d8 <cpunum>
f010465a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010465d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104660:	01 c2                	add    %eax,%edx
f0104662:	01 d2                	add    %edx,%edx
f0104664:	01 c2                	add    %eax,%edx
f0104666:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104669:	39 0c 85 28 10 29 f0 	cmp    %ecx,-0xfd6efd8(,%eax,4)
f0104670:	74 47                	je     f01046b9 <syscall+0xf1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104672:	8b 59 48             	mov    0x48(%ecx),%ebx
f0104675:	e8 5e 12 00 00       	call   f01058d8 <cpunum>
f010467a:	83 ec 04             	sub    $0x4,%esp
f010467d:	53                   	push   %ebx
f010467e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104681:	01 c2                	add    %eax,%edx
f0104683:	01 d2                	add    %edx,%edx
f0104685:	01 c2                	add    %eax,%edx
f0104687:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010468a:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f0104691:	ff 70 48             	pushl  0x48(%eax)
f0104694:	68 66 77 10 f0       	push   $0xf0107766
f0104699:	e8 b3 f4 ff ff       	call   f0103b51 <cprintf>
f010469e:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01046a1:	83 ec 0c             	sub    $0xc,%esp
f01046a4:	ff 75 f4             	pushl  -0xc(%ebp)
f01046a7:	e8 cf f1 ff ff       	call   f010387b <env_destroy>
f01046ac:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046af:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			retVal = sys_cgetc();
			break;
		case SYS_env_destroy:
			retVal = sys_env_destroy(a1);
			break;
f01046b4:	e9 78 ff ff ff       	jmp    f0104631 <syscall+0x69>
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01046b9:	e8 1a 12 00 00       	call   f01058d8 <cpunum>
f01046be:	83 ec 08             	sub    $0x8,%esp
f01046c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01046c4:	01 c2                	add    %eax,%edx
f01046c6:	01 d2                	add    %edx,%edx
f01046c8:	01 c2                	add    %eax,%edx
f01046ca:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01046cd:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01046d4:	ff 70 48             	pushl  0x48(%eax)
f01046d7:	68 4b 77 10 f0       	push   $0xf010774b
f01046dc:	e8 70 f4 ff ff       	call   f0103b51 <cprintf>
f01046e1:	83 c4 10             	add    $0x10,%esp
f01046e4:	eb bb                	jmp    f01046a1 <syscall+0xd9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046e6:	e8 ed 11 00 00       	call   f01058d8 <cpunum>
f01046eb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01046ee:	01 c2                	add    %eax,%edx
f01046f0:	01 d2                	add    %edx,%edx
f01046f2:	01 c2                	add    %eax,%edx
f01046f4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01046f7:	8b 04 85 28 10 29 f0 	mov    -0xfd6efd8(,%eax,4),%eax
f01046fe:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_env_destroy:
			retVal = sys_env_destroy(a1);
			break;
		case SYS_getenvid:
			retVal = sys_getenvid();
			break;
f0104701:	e9 2b ff ff ff       	jmp    f0104631 <syscall+0x69>
	...

f0104708 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104708:	55                   	push   %ebp
f0104709:	89 e5                	mov    %esp,%ebp
f010470b:	57                   	push   %edi
f010470c:	56                   	push   %esi
f010470d:	53                   	push   %ebx
f010470e:	83 ec 14             	sub    $0x14,%esp
f0104711:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104714:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104717:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010471a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010471d:	8b 32                	mov    (%edx),%esi
f010471f:	8b 01                	mov    (%ecx),%eax
f0104721:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104724:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010472b:	eb 2f                	jmp    f010475c <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010472d:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010472e:	39 c6                	cmp    %eax,%esi
f0104730:	7f 4d                	jg     f010477f <stab_binsearch+0x77>
f0104732:	0f b6 0a             	movzbl (%edx),%ecx
f0104735:	83 ea 0c             	sub    $0xc,%edx
f0104738:	39 f9                	cmp    %edi,%ecx
f010473a:	75 f1                	jne    f010472d <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010473c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010473f:	01 c2                	add    %eax,%edx
f0104741:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104744:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104748:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010474b:	73 37                	jae    f0104784 <stab_binsearch+0x7c>
			*region_left = m;
f010474d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104750:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104752:	8d 73 01             	lea    0x1(%ebx),%esi
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104755:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010475c:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010475f:	7f 4d                	jg     f01047ae <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0104761:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104764:	01 f0                	add    %esi,%eax
f0104766:	89 c3                	mov    %eax,%ebx
f0104768:	c1 eb 1f             	shr    $0x1f,%ebx
f010476b:	01 c3                	add    %eax,%ebx
f010476d:	d1 fb                	sar    %ebx
f010476f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104772:	01 d8                	add    %ebx,%eax
f0104774:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104777:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010477b:	89 d8                	mov    %ebx,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010477d:	eb af                	jmp    f010472e <stab_binsearch+0x26>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010477f:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104782:	eb d8                	jmp    f010475c <stab_binsearch+0x54>
		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104784:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104787:	76 12                	jbe    f010479b <stab_binsearch+0x93>
			*region_right = m - 1;
f0104789:	48                   	dec    %eax
f010478a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010478d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104790:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104792:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104799:	eb c1                	jmp    f010475c <stab_binsearch+0x54>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010479b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010479e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01047a0:	ff 45 0c             	incl   0xc(%ebp)
f01047a3:	89 c6                	mov    %eax,%esi
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01047a5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01047ac:	eb ae                	jmp    f010475c <stab_binsearch+0x54>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01047ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01047b2:	74 18                	je     f01047cc <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047b7:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01047b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01047bc:	8b 0e                	mov    (%esi),%ecx
f01047be:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01047c1:	01 c2                	add    %eax,%edx
f01047c3:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01047c6:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047ca:	eb 0e                	jmp    f01047da <stab_binsearch+0xd2>
			addr++;
		}
	}

	if (!any_matches)
		*region_right = *region_left - 1;
f01047cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047cf:	8b 00                	mov    (%eax),%eax
f01047d1:	48                   	dec    %eax
f01047d2:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01047d5:	89 07                	mov    %eax,(%edi)
f01047d7:	eb 14                	jmp    f01047ed <stab_binsearch+0xe5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01047d9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047da:	39 c1                	cmp    %eax,%ecx
f01047dc:	7d 0a                	jge    f01047e8 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01047de:	0f b6 1a             	movzbl (%edx),%ebx
f01047e1:	83 ea 0c             	sub    $0xc,%edx
f01047e4:	39 fb                	cmp    %edi,%ebx
f01047e6:	75 f1                	jne    f01047d9 <stab_binsearch+0xd1>
		     l--)
			/* do nothing */;
		*region_left = l;
f01047e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01047eb:	89 07                	mov    %eax,(%edi)
	}
}
f01047ed:	83 c4 14             	add    $0x14,%esp
f01047f0:	5b                   	pop    %ebx
f01047f1:	5e                   	pop    %esi
f01047f2:	5f                   	pop    %edi
f01047f3:	5d                   	pop    %ebp
f01047f4:	c3                   	ret    

f01047f5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01047f5:	55                   	push   %ebp
f01047f6:	89 e5                	mov    %esp,%ebp
f01047f8:	57                   	push   %edi
f01047f9:	56                   	push   %esi
f01047fa:	53                   	push   %ebx
f01047fb:	83 ec 2c             	sub    $0x2c,%esp
f01047fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104801:	c7 06 7e 77 10 f0    	movl   $0xf010777e,(%esi)
	info->eip_line = 0;
f0104807:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010480e:	c7 46 08 7e 77 10 f0 	movl   $0xf010777e,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104815:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010481c:	8b 45 08             	mov    0x8(%ebp),%eax
f010481f:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0104822:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104829:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010482e:	0f 86 02 01 00 00    	jbe    f0104936 <debuginfo_eip+0x141>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104834:	c7 45 d4 8d 63 11 f0 	movl   $0xf011638d,-0x2c(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010483b:	c7 45 cc 05 2c 11 f0 	movl   $0xf0112c05,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104842:	bb 04 2c 11 f0       	mov    $0xf0112c04,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104847:	c7 45 d0 54 7c 10 f0 	movl   $0xf0107c54,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010484e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104851:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104854:	0f 83 43 02 00 00    	jae    f0104a9d <debuginfo_eip+0x2a8>
f010485a:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010485e:	0f 85 40 02 00 00    	jne    f0104aa4 <debuginfo_eip+0x2af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104864:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010486b:	89 da                	mov    %ebx,%edx
f010486d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104870:	29 da                	sub    %ebx,%edx
f0104872:	c1 fa 02             	sar    $0x2,%edx
f0104875:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0104878:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010487b:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010487e:	89 c1                	mov    %eax,%ecx
f0104880:	c1 e1 08             	shl    $0x8,%ecx
f0104883:	01 c8                	add    %ecx,%eax
f0104885:	89 c1                	mov    %eax,%ecx
f0104887:	c1 e1 10             	shl    $0x10,%ecx
f010488a:	01 c8                	add    %ecx,%eax
f010488c:	01 c0                	add    %eax,%eax
f010488e:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0104892:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104895:	83 ec 08             	sub    $0x8,%esp
f0104898:	ff 75 08             	pushl  0x8(%ebp)
f010489b:	6a 64                	push   $0x64
f010489d:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01048a0:	89 d1                	mov    %edx,%ecx
f01048a2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01048a5:	89 df                	mov    %ebx,%edi
f01048a7:	89 d8                	mov    %ebx,%eax
f01048a9:	e8 5a fe ff ff       	call   f0104708 <stab_binsearch>
	if (lfile == 0)
f01048ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048b1:	83 c4 10             	add    $0x10,%esp
f01048b4:	85 c0                	test   %eax,%eax
f01048b6:	0f 84 ef 01 00 00    	je     f0104aab <debuginfo_eip+0x2b6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01048bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01048bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01048c5:	83 ec 08             	sub    $0x8,%esp
f01048c8:	ff 75 08             	pushl  0x8(%ebp)
f01048cb:	6a 24                	push   $0x24
f01048cd:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01048d0:	89 d1                	mov    %edx,%ecx
f01048d2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01048d5:	89 d8                	mov    %ebx,%eax
f01048d7:	e8 2c fe ff ff       	call   f0104708 <stab_binsearch>

	if (lfun <= rfun) {
f01048dc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01048df:	83 c4 10             	add    $0x10,%esp
f01048e2:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01048e5:	0f 8f 2c 01 00 00    	jg     f0104a17 <debuginfo_eip+0x222>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01048eb:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01048ee:	01 d8                	add    %ebx,%eax
f01048f0:	8d 14 87             	lea    (%edi,%eax,4),%edx
f01048f3:	8b 02                	mov    (%edx),%eax
f01048f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01048f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01048fb:	29 f9                	sub    %edi,%ecx
f01048fd:	39 c8                	cmp    %ecx,%eax
f01048ff:	73 05                	jae    f0104906 <debuginfo_eip+0x111>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104901:	01 f8                	add    %edi,%eax
f0104903:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104906:	8b 42 08             	mov    0x8(%edx),%eax
f0104909:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010490c:	83 ec 08             	sub    $0x8,%esp
f010490f:	6a 3a                	push   $0x3a
f0104911:	ff 76 08             	pushl  0x8(%esi)
f0104914:	e8 98 09 00 00       	call   f01052b1 <strfind>
f0104919:	2b 46 08             	sub    0x8(%esi),%eax
f010491c:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010491f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104922:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104925:	01 d8                	add    %ebx,%eax
f0104927:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010492a:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f010492e:	83 c4 10             	add    $0x10,%esp
f0104931:	e9 f3 00 00 00       	jmp    f0104a29 <debuginfo_eip+0x234>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0104936:	e8 9d 0f 00 00       	call   f01058d8 <cpunum>
f010493b:	6a 04                	push   $0x4
f010493d:	6a 10                	push   $0x10
f010493f:	68 00 00 20 00       	push   $0x200000
f0104944:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104947:	01 c2                	add    %eax,%edx
f0104949:	01 d2                	add    %edx,%edx
f010494b:	01 c2                	add    %eax,%edx
f010494d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104950:	ff 34 85 28 10 29 f0 	pushl  -0xfd6efd8(,%eax,4)
f0104957:	e8 60 e7 ff ff       	call   f01030bc <user_mem_check>
f010495c:	83 c4 10             	add    $0x10,%esp
f010495f:	85 c0                	test   %eax,%eax
f0104961:	0f 88 28 01 00 00    	js     f0104a8f <debuginfo_eip+0x29a>
			return -1;
		}

		stabs = usd->stabs;
f0104967:	a1 00 00 20 00       	mov    0x200000,%eax
f010496c:	89 c7                	mov    %eax,%edi
		stab_end = usd->stab_end;
f010496e:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0104974:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f010497a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010497d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104983:	89 55 d4             	mov    %edx,-0x2c(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
f0104986:	e8 4d 0f 00 00       	call   f01058d8 <cpunum>
f010498b:	6a 04                	push   $0x4
f010498d:	89 d9                	mov    %ebx,%ecx
f010498f:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0104992:	29 f9                	sub    %edi,%ecx
f0104994:	c1 f9 02             	sar    $0x2,%ecx
f0104997:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f010499a:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f010499d:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01049a0:	89 d7                	mov    %edx,%edi
f01049a2:	c1 e7 08             	shl    $0x8,%edi
f01049a5:	01 fa                	add    %edi,%edx
f01049a7:	89 d7                	mov    %edx,%edi
f01049a9:	c1 e7 10             	shl    $0x10,%edi
f01049ac:	01 fa                	add    %edi,%edx
f01049ae:	01 d2                	add    %edx,%edx
f01049b0:	01 d1                	add    %edx,%ecx
f01049b2:	51                   	push   %ecx
f01049b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01049b6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049b9:	01 c2                	add    %eax,%edx
f01049bb:	01 d2                	add    %edx,%edx
f01049bd:	01 c2                	add    %eax,%edx
f01049bf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049c2:	ff 34 85 28 10 29 f0 	pushl  -0xfd6efd8(,%eax,4)
f01049c9:	e8 ee e6 ff ff       	call   f01030bc <user_mem_check>
f01049ce:	83 c4 10             	add    $0x10,%esp
f01049d1:	85 c0                	test   %eax,%eax
f01049d3:	0f 88 bd 00 00 00    	js     f0104a96 <debuginfo_eip+0x2a1>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, stabstr_end-stabstr, PTE_U) < 0) {
f01049d9:	e8 fa 0e 00 00       	call   f01058d8 <cpunum>
f01049de:	6a 04                	push   $0x4
f01049e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01049e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01049e6:	29 ca                	sub    %ecx,%edx
f01049e8:	52                   	push   %edx
f01049e9:	51                   	push   %ecx
f01049ea:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049ed:	01 c2                	add    %eax,%edx
f01049ef:	01 d2                	add    %edx,%edx
f01049f1:	01 c2                	add    %eax,%edx
f01049f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049f6:	ff 34 85 28 10 29 f0 	pushl  -0xfd6efd8(,%eax,4)
f01049fd:	e8 ba e6 ff ff       	call   f01030bc <user_mem_check>
f0104a02:	83 c4 10             	add    $0x10,%esp
f0104a05:	85 c0                	test   %eax,%eax
f0104a07:	0f 89 41 fe ff ff    	jns    f010484e <debuginfo_eip+0x59>
			return -1;
f0104a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a12:	e9 a0 00 00 00       	jmp    f0104ab7 <debuginfo_eip+0x2c2>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a17:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a1a:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0104a1d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104a20:	e9 e7 fe ff ff       	jmp    f010490c <debuginfo_eip+0x117>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a25:	4b                   	dec    %ebx
f0104a26:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a29:	39 df                	cmp    %ebx,%edi
f0104a2b:	7f 2f                	jg     f0104a5c <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0104a2d:	8a 10                	mov    (%eax),%dl
f0104a2f:	80 fa 84             	cmp    $0x84,%dl
f0104a32:	74 0b                	je     f0104a3f <debuginfo_eip+0x24a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a34:	80 fa 64             	cmp    $0x64,%dl
f0104a37:	75 ec                	jne    f0104a25 <debuginfo_eip+0x230>
f0104a39:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104a3d:	74 e6                	je     f0104a25 <debuginfo_eip+0x230>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a3f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104a42:	01 c3                	add    %eax,%ebx
f0104a44:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a47:	8b 14 98             	mov    (%eax,%ebx,4),%edx
f0104a4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104a4d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104a50:	29 f8                	sub    %edi,%eax
f0104a52:	39 c2                	cmp    %eax,%edx
f0104a54:	73 06                	jae    f0104a5c <debuginfo_eip+0x267>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104a56:	89 f8                	mov    %edi,%eax
f0104a58:	01 d0                	add    %edx,%eax
f0104a5a:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a5f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a62:	39 c8                	cmp    %ecx,%eax
f0104a64:	7d 4c                	jge    f0104ab2 <debuginfo_eip+0x2bd>
		for (lline = lfun + 1;
f0104a66:	8d 50 01             	lea    0x1(%eax),%edx
f0104a69:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0104a6c:	01 d8                	add    %ebx,%eax
f0104a6e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104a71:	8d 44 87 10          	lea    0x10(%edi,%eax,4),%eax
f0104a75:	eb 04                	jmp    f0104a7b <debuginfo_eip+0x286>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104a77:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104a7a:	42                   	inc    %edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104a7b:	39 d1                	cmp    %edx,%ecx
f0104a7d:	74 40                	je     f0104abf <debuginfo_eip+0x2ca>
f0104a7f:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a82:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104a86:	74 ef                	je     f0104a77 <debuginfo_eip+0x282>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a88:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a8d:	eb 28                	jmp    f0104ab7 <debuginfo_eip+0x2c2>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0104a8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a94:	eb 21                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
			return -1;
f0104a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a9b:	eb 1a                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104aa2:	eb 13                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
f0104aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104aa9:	eb 0c                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104aab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ab0:	eb 05                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aba:	5b                   	pop    %ebx
f0104abb:	5e                   	pop    %esi
f0104abc:	5f                   	pop    %edi
f0104abd:	5d                   	pop    %ebp
f0104abe:	c3                   	ret    
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104abf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ac4:	eb f1                	jmp    f0104ab7 <debuginfo_eip+0x2c2>
	...

f0104ac8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104ac8:	55                   	push   %ebp
f0104ac9:	89 e5                	mov    %esp,%ebp
f0104acb:	57                   	push   %edi
f0104acc:	56                   	push   %esi
f0104acd:	53                   	push   %ebx
f0104ace:	83 ec 1c             	sub    $0x1c,%esp
f0104ad1:	89 c7                	mov    %eax,%edi
f0104ad3:	89 d6                	mov    %edx,%esi
f0104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104adb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ade:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ae4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ae9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104aec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104aef:	39 d3                	cmp    %edx,%ebx
f0104af1:	72 05                	jb     f0104af8 <printnum+0x30>
f0104af3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104af6:	77 78                	ja     f0104b70 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104af8:	83 ec 0c             	sub    $0xc,%esp
f0104afb:	ff 75 18             	pushl  0x18(%ebp)
f0104afe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b01:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104b04:	53                   	push   %ebx
f0104b05:	ff 75 10             	pushl  0x10(%ebp)
f0104b08:	83 ec 08             	sub    $0x8,%esp
f0104b0b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b0e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b11:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b14:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b17:	e8 d4 11 00 00       	call   f0105cf0 <__udivdi3>
f0104b1c:	83 c4 18             	add    $0x18,%esp
f0104b1f:	52                   	push   %edx
f0104b20:	50                   	push   %eax
f0104b21:	89 f2                	mov    %esi,%edx
f0104b23:	89 f8                	mov    %edi,%eax
f0104b25:	e8 9e ff ff ff       	call   f0104ac8 <printnum>
f0104b2a:	83 c4 20             	add    $0x20,%esp
f0104b2d:	eb 11                	jmp    f0104b40 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b2f:	83 ec 08             	sub    $0x8,%esp
f0104b32:	56                   	push   %esi
f0104b33:	ff 75 18             	pushl  0x18(%ebp)
f0104b36:	ff d7                	call   *%edi
f0104b38:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b3b:	4b                   	dec    %ebx
f0104b3c:	85 db                	test   %ebx,%ebx
f0104b3e:	7f ef                	jg     f0104b2f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b40:	83 ec 08             	sub    $0x8,%esp
f0104b43:	56                   	push   %esi
f0104b44:	83 ec 04             	sub    $0x4,%esp
f0104b47:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b4a:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b4d:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b50:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b53:	e8 98 12 00 00       	call   f0105df0 <__umoddi3>
f0104b58:	83 c4 14             	add    $0x14,%esp
f0104b5b:	0f be 80 88 77 10 f0 	movsbl -0xfef8878(%eax),%eax
f0104b62:	50                   	push   %eax
f0104b63:	ff d7                	call   *%edi
}
f0104b65:	83 c4 10             	add    $0x10,%esp
f0104b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b6b:	5b                   	pop    %ebx
f0104b6c:	5e                   	pop    %esi
f0104b6d:	5f                   	pop    %edi
f0104b6e:	5d                   	pop    %ebp
f0104b6f:	c3                   	ret    
f0104b70:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104b73:	eb c6                	jmp    f0104b3b <printnum+0x73>

f0104b75 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104b75:	55                   	push   %ebp
f0104b76:	89 e5                	mov    %esp,%ebp
f0104b78:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104b7b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104b7e:	8b 10                	mov    (%eax),%edx
f0104b80:	3b 50 04             	cmp    0x4(%eax),%edx
f0104b83:	73 0a                	jae    f0104b8f <sprintputch+0x1a>
		*b->buf++ = ch;
f0104b85:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104b88:	89 08                	mov    %ecx,(%eax)
f0104b8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b8d:	88 02                	mov    %al,(%edx)
}
f0104b8f:	5d                   	pop    %ebp
f0104b90:	c3                   	ret    

f0104b91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104b91:	55                   	push   %ebp
f0104b92:	89 e5                	mov    %esp,%ebp
f0104b94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104b97:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104b9a:	50                   	push   %eax
f0104b9b:	ff 75 10             	pushl  0x10(%ebp)
f0104b9e:	ff 75 0c             	pushl  0xc(%ebp)
f0104ba1:	ff 75 08             	pushl  0x8(%ebp)
f0104ba4:	e8 05 00 00 00       	call   f0104bae <vprintfmt>
	va_end(ap);
}
f0104ba9:	83 c4 10             	add    $0x10,%esp
f0104bac:	c9                   	leave  
f0104bad:	c3                   	ret    

f0104bae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104bae:	55                   	push   %ebp
f0104baf:	89 e5                	mov    %esp,%ebp
f0104bb1:	57                   	push   %edi
f0104bb2:	56                   	push   %esi
f0104bb3:	53                   	push   %ebx
f0104bb4:	83 ec 2c             	sub    $0x2c,%esp
f0104bb7:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bbd:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bc0:	e9 ac 03 00 00       	jmp    f0104f71 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0104bc5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
f0104bc9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
f0104bd0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
f0104bd7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
f0104bde:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104be3:	8d 47 01             	lea    0x1(%edi),%eax
f0104be6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104be9:	8a 17                	mov    (%edi),%dl
f0104beb:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104bee:	3c 55                	cmp    $0x55,%al
f0104bf0:	0f 87 fc 03 00 00    	ja     f0104ff2 <vprintfmt+0x444>
f0104bf6:	0f b6 c0             	movzbl %al,%eax
f0104bf9:	ff 24 85 40 78 10 f0 	jmp    *-0xfef87c0(,%eax,4)
f0104c00:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104c03:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104c07:	eb da                	jmp    f0104be3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104c0c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104c10:	eb d1                	jmp    f0104be3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c12:	0f b6 d2             	movzbl %dl,%edx
f0104c15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104c18:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c1d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104c20:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104c23:	01 c0                	add    %eax,%eax
f0104c25:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0104c29:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104c2c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104c2f:	83 f9 09             	cmp    $0x9,%ecx
f0104c32:	77 52                	ja     f0104c86 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104c34:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0104c35:	eb e9                	jmp    f0104c20 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c37:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c3a:	8b 00                	mov    (%eax),%eax
f0104c3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104c3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c42:	8d 40 04             	lea    0x4(%eax),%eax
f0104c45:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104c4b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104c4f:	79 92                	jns    f0104be3 <vprintfmt+0x35>
				width = precision, precision = -1;
f0104c51:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c54:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c57:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104c5e:	eb 83                	jmp    f0104be3 <vprintfmt+0x35>
f0104c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104c64:	78 08                	js     f0104c6e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c69:	e9 75 ff ff ff       	jmp    f0104be3 <vprintfmt+0x35>
f0104c6e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104c75:	eb ef                	jmp    f0104c66 <vprintfmt+0xb8>
f0104c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104c7a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104c81:	e9 5d ff ff ff       	jmp    f0104be3 <vprintfmt+0x35>
f0104c86:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104c89:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104c8c:	eb bd                	jmp    f0104c4b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104c8e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104c92:	e9 4c ff ff ff       	jmp    f0104be3 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104c97:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c9a:	8d 78 04             	lea    0x4(%eax),%edi
f0104c9d:	83 ec 08             	sub    $0x8,%esp
f0104ca0:	53                   	push   %ebx
f0104ca1:	ff 30                	pushl  (%eax)
f0104ca3:	ff d6                	call   *%esi
			break;
f0104ca5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104ca8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104cab:	e9 be 02 00 00       	jmp    f0104f6e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104cb0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cb3:	8d 78 04             	lea    0x4(%eax),%edi
f0104cb6:	8b 00                	mov    (%eax),%eax
f0104cb8:	85 c0                	test   %eax,%eax
f0104cba:	78 2a                	js     f0104ce6 <vprintfmt+0x138>
f0104cbc:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104cbe:	83 f8 08             	cmp    $0x8,%eax
f0104cc1:	7f 27                	jg     f0104cea <vprintfmt+0x13c>
f0104cc3:	8b 04 85 a0 79 10 f0 	mov    -0xfef8660(,%eax,4),%eax
f0104cca:	85 c0                	test   %eax,%eax
f0104ccc:	74 1c                	je     f0104cea <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104cce:	50                   	push   %eax
f0104ccf:	68 49 6f 10 f0       	push   $0xf0106f49
f0104cd4:	53                   	push   %ebx
f0104cd5:	56                   	push   %esi
f0104cd6:	e8 b6 fe ff ff       	call   f0104b91 <printfmt>
f0104cdb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104cde:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104ce1:	e9 88 02 00 00       	jmp    f0104f6e <vprintfmt+0x3c0>
f0104ce6:	f7 d8                	neg    %eax
f0104ce8:	eb d2                	jmp    f0104cbc <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104cea:	52                   	push   %edx
f0104ceb:	68 a0 77 10 f0       	push   $0xf01077a0
f0104cf0:	53                   	push   %ebx
f0104cf1:	56                   	push   %esi
f0104cf2:	e8 9a fe ff ff       	call   f0104b91 <printfmt>
f0104cf7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104cfa:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104cfd:	e9 6c 02 00 00       	jmp    f0104f6e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104d02:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d05:	83 c0 04             	add    $0x4,%eax
f0104d08:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104d0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d0e:	8b 38                	mov    (%eax),%edi
f0104d10:	85 ff                	test   %edi,%edi
f0104d12:	74 18                	je     f0104d2c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
f0104d14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d18:	0f 8e b7 00 00 00    	jle    f0104dd5 <vprintfmt+0x227>
f0104d1e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104d22:	75 0f                	jne    f0104d33 <vprintfmt+0x185>
f0104d24:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d27:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104d2a:	eb 75                	jmp    f0104da1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
f0104d2c:	bf 99 77 10 f0       	mov    $0xf0107799,%edi
f0104d31:	eb e1                	jmp    f0104d14 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d33:	83 ec 08             	sub    $0x8,%esp
f0104d36:	ff 75 d0             	pushl  -0x30(%ebp)
f0104d39:	57                   	push   %edi
f0104d3a:	e8 47 04 00 00       	call   f0105186 <strnlen>
f0104d3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d42:	29 c1                	sub    %eax,%ecx
f0104d44:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104d47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104d4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104d4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104d54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d56:	eb 0d                	jmp    f0104d65 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0104d58:	83 ec 08             	sub    $0x8,%esp
f0104d5b:	53                   	push   %ebx
f0104d5c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d61:	4f                   	dec    %edi
f0104d62:	83 c4 10             	add    $0x10,%esp
f0104d65:	85 ff                	test   %edi,%edi
f0104d67:	7f ef                	jg     f0104d58 <vprintfmt+0x1aa>
f0104d69:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d6c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104d6f:	89 c8                	mov    %ecx,%eax
f0104d71:	85 c9                	test   %ecx,%ecx
f0104d73:	78 10                	js     f0104d85 <vprintfmt+0x1d7>
f0104d75:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104d78:	29 c1                	sub    %eax,%ecx
f0104d7a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d7d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d80:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104d83:	eb 1c                	jmp    f0104da1 <vprintfmt+0x1f3>
f0104d85:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d8a:	eb e9                	jmp    f0104d75 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104d8c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104d90:	75 29                	jne    f0104dbb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104d92:	83 ec 08             	sub    $0x8,%esp
f0104d95:	ff 75 0c             	pushl  0xc(%ebp)
f0104d98:	50                   	push   %eax
f0104d99:	ff d6                	call   *%esi
f0104d9b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d9e:	ff 4d e0             	decl   -0x20(%ebp)
f0104da1:	47                   	inc    %edi
f0104da2:	8a 57 ff             	mov    -0x1(%edi),%dl
f0104da5:	0f be c2             	movsbl %dl,%eax
f0104da8:	85 c0                	test   %eax,%eax
f0104daa:	74 4c                	je     f0104df8 <vprintfmt+0x24a>
f0104dac:	85 db                	test   %ebx,%ebx
f0104dae:	78 dc                	js     f0104d8c <vprintfmt+0x1de>
f0104db0:	4b                   	dec    %ebx
f0104db1:	79 d9                	jns    f0104d8c <vprintfmt+0x1de>
f0104db3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104db6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104db9:	eb 2e                	jmp    f0104de9 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0104dbb:	0f be d2             	movsbl %dl,%edx
f0104dbe:	83 ea 20             	sub    $0x20,%edx
f0104dc1:	83 fa 5e             	cmp    $0x5e,%edx
f0104dc4:	76 cc                	jbe    f0104d92 <vprintfmt+0x1e4>
					putch('?', putdat);
f0104dc6:	83 ec 08             	sub    $0x8,%esp
f0104dc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104dcc:	6a 3f                	push   $0x3f
f0104dce:	ff d6                	call   *%esi
f0104dd0:	83 c4 10             	add    $0x10,%esp
f0104dd3:	eb c9                	jmp    f0104d9e <vprintfmt+0x1f0>
f0104dd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104dd8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104ddb:	eb c4                	jmp    f0104da1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104ddd:	83 ec 08             	sub    $0x8,%esp
f0104de0:	53                   	push   %ebx
f0104de1:	6a 20                	push   $0x20
f0104de3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104de5:	4f                   	dec    %edi
f0104de6:	83 c4 10             	add    $0x10,%esp
f0104de9:	85 ff                	test   %edi,%edi
f0104deb:	7f f0                	jg     f0104ddd <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104ded:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104df0:	89 45 14             	mov    %eax,0x14(%ebp)
f0104df3:	e9 76 01 00 00       	jmp    f0104f6e <vprintfmt+0x3c0>
f0104df8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dfe:	eb e9                	jmp    f0104de9 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104e00:	83 f9 01             	cmp    $0x1,%ecx
f0104e03:	7e 3f                	jle    f0104e44 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0104e05:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e08:	8b 50 04             	mov    0x4(%eax),%edx
f0104e0b:	8b 00                	mov    (%eax),%eax
f0104e0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e10:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104e13:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e16:	8d 40 08             	lea    0x8(%eax),%eax
f0104e19:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104e1c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104e20:	79 5c                	jns    f0104e7e <vprintfmt+0x2d0>
				putch('-', putdat);
f0104e22:	83 ec 08             	sub    $0x8,%esp
f0104e25:	53                   	push   %ebx
f0104e26:	6a 2d                	push   $0x2d
f0104e28:	ff d6                	call   *%esi
				num = -(long long) num;
f0104e2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e2d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104e30:	f7 da                	neg    %edx
f0104e32:	83 d1 00             	adc    $0x0,%ecx
f0104e35:	f7 d9                	neg    %ecx
f0104e37:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104e3a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104e3f:	e9 10 01 00 00       	jmp    f0104f54 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
f0104e44:	85 c9                	test   %ecx,%ecx
f0104e46:	75 1b                	jne    f0104e63 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f0104e48:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e4b:	8b 00                	mov    (%eax),%eax
f0104e4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e50:	89 c1                	mov    %eax,%ecx
f0104e52:	c1 f9 1f             	sar    $0x1f,%ecx
f0104e55:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104e58:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e5b:	8d 40 04             	lea    0x4(%eax),%eax
f0104e5e:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e61:	eb b9                	jmp    f0104e1c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
f0104e63:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e66:	8b 00                	mov    (%eax),%eax
f0104e68:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e6b:	89 c1                	mov    %eax,%ecx
f0104e6d:	c1 f9 1f             	sar    $0x1f,%ecx
f0104e70:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104e73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e76:	8d 40 04             	lea    0x4(%eax),%eax
f0104e79:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e7c:	eb 9e                	jmp    f0104e1c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104e7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e81:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104e84:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104e89:	e9 c6 00 00 00       	jmp    f0104f54 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104e8e:	83 f9 01             	cmp    $0x1,%ecx
f0104e91:	7e 18                	jle    f0104eab <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0104e93:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e96:	8b 10                	mov    (%eax),%edx
f0104e98:	8b 48 04             	mov    0x4(%eax),%ecx
f0104e9b:	8d 40 08             	lea    0x8(%eax),%eax
f0104e9e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104ea1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ea6:	e9 a9 00 00 00       	jmp    f0104f54 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104eab:	85 c9                	test   %ecx,%ecx
f0104ead:	75 1a                	jne    f0104ec9 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104eaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eb2:	8b 10                	mov    (%eax),%edx
f0104eb4:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104eb9:	8d 40 04             	lea    0x4(%eax),%eax
f0104ebc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104ebf:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ec4:	e9 8b 00 00 00       	jmp    f0104f54 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f0104ec9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ecc:	8b 10                	mov    (%eax),%edx
f0104ece:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ed3:	8d 40 04             	lea    0x4(%eax),%eax
f0104ed6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104ed9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ede:	eb 74                	jmp    f0104f54 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104ee0:	83 f9 01             	cmp    $0x1,%ecx
f0104ee3:	7e 15                	jle    f0104efa <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0104ee5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ee8:	8b 10                	mov    (%eax),%edx
f0104eea:	8b 48 04             	mov    0x4(%eax),%ecx
f0104eed:	8d 40 08             	lea    0x8(%eax),%eax
f0104ef0:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f0104ef3:	b8 08 00 00 00       	mov    $0x8,%eax
f0104ef8:	eb 5a                	jmp    f0104f54 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104efa:	85 c9                	test   %ecx,%ecx
f0104efc:	75 17                	jne    f0104f15 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104efe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f01:	8b 10                	mov    (%eax),%edx
f0104f03:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f08:	8d 40 04             	lea    0x4(%eax),%eax
f0104f0b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f0104f0e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104f13:	eb 3f                	jmp    f0104f54 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f0104f15:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f18:	8b 10                	mov    (%eax),%edx
f0104f1a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f1f:	8d 40 04             	lea    0x4(%eax),%eax
f0104f22:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f0104f25:	b8 08 00 00 00       	mov    $0x8,%eax
f0104f2a:	eb 28                	jmp    f0104f54 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0104f2c:	83 ec 08             	sub    $0x8,%esp
f0104f2f:	53                   	push   %ebx
f0104f30:	6a 30                	push   $0x30
f0104f32:	ff d6                	call   *%esi
			putch('x', putdat);
f0104f34:	83 c4 08             	add    $0x8,%esp
f0104f37:	53                   	push   %ebx
f0104f38:	6a 78                	push   $0x78
f0104f3a:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104f3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f3f:	8b 10                	mov    (%eax),%edx
f0104f41:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104f46:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104f49:	8d 40 04             	lea    0x4(%eax),%eax
f0104f4c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f4f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104f54:	83 ec 0c             	sub    $0xc,%esp
f0104f57:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104f5b:	57                   	push   %edi
f0104f5c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f5f:	50                   	push   %eax
f0104f60:	51                   	push   %ecx
f0104f61:	52                   	push   %edx
f0104f62:	89 da                	mov    %ebx,%edx
f0104f64:	89 f0                	mov    %esi,%eax
f0104f66:	e8 5d fb ff ff       	call   f0104ac8 <printnum>
			break;
f0104f6b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104f6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f71:	47                   	inc    %edi
f0104f72:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f76:	83 f8 25             	cmp    $0x25,%eax
f0104f79:	0f 84 46 fc ff ff    	je     f0104bc5 <vprintfmt+0x17>
			if (ch == '\0')
f0104f7f:	85 c0                	test   %eax,%eax
f0104f81:	0f 84 89 00 00 00    	je     f0105010 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
f0104f87:	83 ec 08             	sub    $0x8,%esp
f0104f8a:	53                   	push   %ebx
f0104f8b:	50                   	push   %eax
f0104f8c:	ff d6                	call   *%esi
f0104f8e:	83 c4 10             	add    $0x10,%esp
f0104f91:	eb de                	jmp    f0104f71 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104f93:	83 f9 01             	cmp    $0x1,%ecx
f0104f96:	7e 15                	jle    f0104fad <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0104f98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f9b:	8b 10                	mov    (%eax),%edx
f0104f9d:	8b 48 04             	mov    0x4(%eax),%ecx
f0104fa0:	8d 40 08             	lea    0x8(%eax),%eax
f0104fa3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104fa6:	b8 10 00 00 00       	mov    $0x10,%eax
f0104fab:	eb a7                	jmp    f0104f54 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104fad:	85 c9                	test   %ecx,%ecx
f0104faf:	75 17                	jne    f0104fc8 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104fb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb4:	8b 10                	mov    (%eax),%edx
f0104fb6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fbb:	8d 40 04             	lea    0x4(%eax),%eax
f0104fbe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104fc1:	b8 10 00 00 00       	mov    $0x10,%eax
f0104fc6:	eb 8c                	jmp    f0104f54 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f0104fc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fcb:	8b 10                	mov    (%eax),%edx
f0104fcd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fd2:	8d 40 04             	lea    0x4(%eax),%eax
f0104fd5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104fd8:	b8 10 00 00 00       	mov    $0x10,%eax
f0104fdd:	e9 72 ff ff ff       	jmp    f0104f54 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104fe2:	83 ec 08             	sub    $0x8,%esp
f0104fe5:	53                   	push   %ebx
f0104fe6:	6a 25                	push   $0x25
f0104fe8:	ff d6                	call   *%esi
			break;
f0104fea:	83 c4 10             	add    $0x10,%esp
f0104fed:	e9 7c ff ff ff       	jmp    f0104f6e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104ff2:	83 ec 08             	sub    $0x8,%esp
f0104ff5:	53                   	push   %ebx
f0104ff6:	6a 25                	push   $0x25
f0104ff8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ffa:	83 c4 10             	add    $0x10,%esp
f0104ffd:	89 f8                	mov    %edi,%eax
f0104fff:	eb 01                	jmp    f0105002 <vprintfmt+0x454>
f0105001:	48                   	dec    %eax
f0105002:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105006:	75 f9                	jne    f0105001 <vprintfmt+0x453>
f0105008:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010500b:	e9 5e ff ff ff       	jmp    f0104f6e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
f0105010:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105013:	5b                   	pop    %ebx
f0105014:	5e                   	pop    %esi
f0105015:	5f                   	pop    %edi
f0105016:	5d                   	pop    %ebp
f0105017:	c3                   	ret    

f0105018 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105018:	55                   	push   %ebp
f0105019:	89 e5                	mov    %esp,%ebp
f010501b:	83 ec 18             	sub    $0x18,%esp
f010501e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105021:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105024:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105027:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010502b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010502e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105035:	85 c0                	test   %eax,%eax
f0105037:	74 26                	je     f010505f <vsnprintf+0x47>
f0105039:	85 d2                	test   %edx,%edx
f010503b:	7e 29                	jle    f0105066 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010503d:	ff 75 14             	pushl  0x14(%ebp)
f0105040:	ff 75 10             	pushl  0x10(%ebp)
f0105043:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105046:	50                   	push   %eax
f0105047:	68 75 4b 10 f0       	push   $0xf0104b75
f010504c:	e8 5d fb ff ff       	call   f0104bae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105051:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105054:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105057:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010505a:	83 c4 10             	add    $0x10,%esp
}
f010505d:	c9                   	leave  
f010505e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010505f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105064:	eb f7                	jmp    f010505d <vsnprintf+0x45>
f0105066:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010506b:	eb f0                	jmp    f010505d <vsnprintf+0x45>

f010506d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010506d:	55                   	push   %ebp
f010506e:	89 e5                	mov    %esp,%ebp
f0105070:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105073:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105076:	50                   	push   %eax
f0105077:	ff 75 10             	pushl  0x10(%ebp)
f010507a:	ff 75 0c             	pushl  0xc(%ebp)
f010507d:	ff 75 08             	pushl  0x8(%ebp)
f0105080:	e8 93 ff ff ff       	call   f0105018 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105085:	c9                   	leave  
f0105086:	c3                   	ret    
	...

f0105088 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105088:	55                   	push   %ebp
f0105089:	89 e5                	mov    %esp,%ebp
f010508b:	57                   	push   %edi
f010508c:	56                   	push   %esi
f010508d:	53                   	push   %ebx
f010508e:	83 ec 0c             	sub    $0xc,%esp
f0105091:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105094:	85 c0                	test   %eax,%eax
f0105096:	74 11                	je     f01050a9 <readline+0x21>
		cprintf("%s", prompt);
f0105098:	83 ec 08             	sub    $0x8,%esp
f010509b:	50                   	push   %eax
f010509c:	68 49 6f 10 f0       	push   $0xf0106f49
f01050a1:	e8 ab ea ff ff       	call   f0103b51 <cprintf>
f01050a6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01050a9:	83 ec 0c             	sub    $0xc,%esp
f01050ac:	6a 00                	push   $0x0
f01050ae:	e8 e2 b6 ff ff       	call   f0100795 <iscons>
f01050b3:	89 c7                	mov    %eax,%edi
f01050b5:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01050b8:	be 00 00 00 00       	mov    $0x0,%esi
f01050bd:	eb 6f                	jmp    f010512e <readline+0xa6>
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01050bf:	83 ec 08             	sub    $0x8,%esp
f01050c2:	50                   	push   %eax
f01050c3:	68 c4 79 10 f0       	push   $0xf01079c4
f01050c8:	e8 84 ea ff ff       	call   f0103b51 <cprintf>
			return NULL;
f01050cd:	83 c4 10             	add    $0x10,%esp
f01050d0:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01050d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050d8:	5b                   	pop    %ebx
f01050d9:	5e                   	pop    %esi
f01050da:	5f                   	pop    %edi
f01050db:	5d                   	pop    %ebp
f01050dc:	c3                   	ret    
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f01050dd:	83 ec 0c             	sub    $0xc,%esp
f01050e0:	6a 08                	push   $0x8
f01050e2:	e8 8d b6 ff ff       	call   f0100774 <cputchar>
f01050e7:	83 c4 10             	add    $0x10,%esp
f01050ea:	eb 41                	jmp    f010512d <readline+0xa5>
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
f01050ec:	83 ec 0c             	sub    $0xc,%esp
f01050ef:	53                   	push   %ebx
f01050f0:	e8 7f b6 ff ff       	call   f0100774 <cputchar>
f01050f5:	83 c4 10             	add    $0x10,%esp
f01050f8:	eb 5a                	jmp    f0105154 <readline+0xcc>
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
f01050fa:	83 fb 0a             	cmp    $0xa,%ebx
f01050fd:	74 05                	je     f0105104 <readline+0x7c>
f01050ff:	83 fb 0d             	cmp    $0xd,%ebx
f0105102:	75 2a                	jne    f010512e <readline+0xa6>
			if (echoing)
f0105104:	85 ff                	test   %edi,%edi
f0105106:	75 0e                	jne    f0105116 <readline+0x8e>
				cputchar('\n');
			buf[i] = 0;
f0105108:	c6 86 80 0a 29 f0 00 	movb   $0x0,-0xfd6f580(%esi)
			return buf;
f010510f:	b8 80 0a 29 f0       	mov    $0xf0290a80,%eax
f0105114:	eb bf                	jmp    f01050d5 <readline+0x4d>
			if (echoing)
				cputchar(c);
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
			if (echoing)
				cputchar('\n');
f0105116:	83 ec 0c             	sub    $0xc,%esp
f0105119:	6a 0a                	push   $0xa
f010511b:	e8 54 b6 ff ff       	call   f0100774 <cputchar>
f0105120:	83 c4 10             	add    $0x10,%esp
f0105123:	eb e3                	jmp    f0105108 <readline+0x80>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105125:	85 f6                	test   %esi,%esi
f0105127:	7e 3c                	jle    f0105165 <readline+0xdd>
			if (echoing)
f0105129:	85 ff                	test   %edi,%edi
f010512b:	75 b0                	jne    f01050dd <readline+0x55>
				cputchar('\b');
			i--;
f010512d:	4e                   	dec    %esi
		cprintf("%s", prompt);

	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010512e:	e8 51 b6 ff ff       	call   f0100784 <getchar>
f0105133:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105135:	85 c0                	test   %eax,%eax
f0105137:	78 86                	js     f01050bf <readline+0x37>
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105139:	83 f8 08             	cmp    $0x8,%eax
f010513c:	74 21                	je     f010515f <readline+0xd7>
f010513e:	83 f8 7f             	cmp    $0x7f,%eax
f0105141:	74 e2                	je     f0105125 <readline+0x9d>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105143:	83 f8 1f             	cmp    $0x1f,%eax
f0105146:	7e b2                	jle    f01050fa <readline+0x72>
f0105148:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010514e:	7f aa                	jg     f01050fa <readline+0x72>
			if (echoing)
f0105150:	85 ff                	test   %edi,%edi
f0105152:	75 98                	jne    f01050ec <readline+0x64>
				cputchar(c);
			buf[i++] = c;
f0105154:	88 9e 80 0a 29 f0    	mov    %bl,-0xfd6f580(%esi)
f010515a:	8d 76 01             	lea    0x1(%esi),%esi
f010515d:	eb cf                	jmp    f010512e <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010515f:	85 f6                	test   %esi,%esi
f0105161:	7e cb                	jle    f010512e <readline+0xa6>
f0105163:	eb c4                	jmp    f0105129 <readline+0xa1>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105165:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010516b:	7e e3                	jle    f0105150 <readline+0xc8>
f010516d:	eb bf                	jmp    f010512e <readline+0xa6>
	...

f0105170 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105170:	55                   	push   %ebp
f0105171:	89 e5                	mov    %esp,%ebp
f0105173:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105176:	b8 00 00 00 00       	mov    $0x0,%eax
f010517b:	eb 01                	jmp    f010517e <strlen+0xe>
		n++;
f010517d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010517e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105182:	75 f9                	jne    f010517d <strlen+0xd>
		n++;
	return n;
}
f0105184:	5d                   	pop    %ebp
f0105185:	c3                   	ret    

f0105186 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105186:	55                   	push   %ebp
f0105187:	89 e5                	mov    %esp,%ebp
f0105189:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010518c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010518f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105194:	eb 01                	jmp    f0105197 <strnlen+0x11>
		n++;
f0105196:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105197:	39 d0                	cmp    %edx,%eax
f0105199:	74 06                	je     f01051a1 <strnlen+0x1b>
f010519b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010519f:	75 f5                	jne    f0105196 <strnlen+0x10>
		n++;
	return n;
}
f01051a1:	5d                   	pop    %ebp
f01051a2:	c3                   	ret    

f01051a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01051a3:	55                   	push   %ebp
f01051a4:	89 e5                	mov    %esp,%ebp
f01051a6:	53                   	push   %ebx
f01051a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01051aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051ad:	89 c2                	mov    %eax,%edx
f01051af:	41                   	inc    %ecx
f01051b0:	42                   	inc    %edx
f01051b1:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01051b4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01051b7:	84 db                	test   %bl,%bl
f01051b9:	75 f4                	jne    f01051af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01051bb:	5b                   	pop    %ebx
f01051bc:	5d                   	pop    %ebp
f01051bd:	c3                   	ret    

f01051be <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051be:	55                   	push   %ebp
f01051bf:	89 e5                	mov    %esp,%ebp
f01051c1:	53                   	push   %ebx
f01051c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01051c5:	53                   	push   %ebx
f01051c6:	e8 a5 ff ff ff       	call   f0105170 <strlen>
f01051cb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01051ce:	ff 75 0c             	pushl  0xc(%ebp)
f01051d1:	01 d8                	add    %ebx,%eax
f01051d3:	50                   	push   %eax
f01051d4:	e8 ca ff ff ff       	call   f01051a3 <strcpy>
	return dst;
}
f01051d9:	89 d8                	mov    %ebx,%eax
f01051db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01051de:	c9                   	leave  
f01051df:	c3                   	ret    

f01051e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01051e0:	55                   	push   %ebp
f01051e1:	89 e5                	mov    %esp,%ebp
f01051e3:	56                   	push   %esi
f01051e4:	53                   	push   %ebx
f01051e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01051e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051eb:	89 f3                	mov    %esi,%ebx
f01051ed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01051f0:	89 f2                	mov    %esi,%edx
f01051f2:	39 da                	cmp    %ebx,%edx
f01051f4:	74 0e                	je     f0105204 <strncpy+0x24>
		*dst++ = *src;
f01051f6:	42                   	inc    %edx
f01051f7:	8a 01                	mov    (%ecx),%al
f01051f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01051fc:	80 39 00             	cmpb   $0x0,(%ecx)
f01051ff:	74 f1                	je     f01051f2 <strncpy+0x12>
			src++;
f0105201:	41                   	inc    %ecx
f0105202:	eb ee                	jmp    f01051f2 <strncpy+0x12>
	}
	return ret;
}
f0105204:	89 f0                	mov    %esi,%eax
f0105206:	5b                   	pop    %ebx
f0105207:	5e                   	pop    %esi
f0105208:	5d                   	pop    %ebp
f0105209:	c3                   	ret    

f010520a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010520a:	55                   	push   %ebp
f010520b:	89 e5                	mov    %esp,%ebp
f010520d:	56                   	push   %esi
f010520e:	53                   	push   %ebx
f010520f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105212:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105215:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105218:	85 c0                	test   %eax,%eax
f010521a:	74 20                	je     f010523c <strlcpy+0x32>
f010521c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0105220:	89 f0                	mov    %esi,%eax
f0105222:	eb 05                	jmp    f0105229 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105224:	42                   	inc    %edx
f0105225:	40                   	inc    %eax
f0105226:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105229:	39 d8                	cmp    %ebx,%eax
f010522b:	74 06                	je     f0105233 <strlcpy+0x29>
f010522d:	8a 0a                	mov    (%edx),%cl
f010522f:	84 c9                	test   %cl,%cl
f0105231:	75 f1                	jne    f0105224 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
f0105233:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105236:	29 f0                	sub    %esi,%eax
}
f0105238:	5b                   	pop    %ebx
f0105239:	5e                   	pop    %esi
f010523a:	5d                   	pop    %ebp
f010523b:	c3                   	ret    
f010523c:	89 f0                	mov    %esi,%eax
f010523e:	eb f6                	jmp    f0105236 <strlcpy+0x2c>

f0105240 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105240:	55                   	push   %ebp
f0105241:	89 e5                	mov    %esp,%ebp
f0105243:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105246:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105249:	eb 02                	jmp    f010524d <strcmp+0xd>
		p++, q++;
f010524b:	41                   	inc    %ecx
f010524c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010524d:	8a 01                	mov    (%ecx),%al
f010524f:	84 c0                	test   %al,%al
f0105251:	74 04                	je     f0105257 <strcmp+0x17>
f0105253:	3a 02                	cmp    (%edx),%al
f0105255:	74 f4                	je     f010524b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105257:	0f b6 c0             	movzbl %al,%eax
f010525a:	0f b6 12             	movzbl (%edx),%edx
f010525d:	29 d0                	sub    %edx,%eax
}
f010525f:	5d                   	pop    %ebp
f0105260:	c3                   	ret    

f0105261 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105261:	55                   	push   %ebp
f0105262:	89 e5                	mov    %esp,%ebp
f0105264:	53                   	push   %ebx
f0105265:	8b 45 08             	mov    0x8(%ebp),%eax
f0105268:	8b 55 0c             	mov    0xc(%ebp),%edx
f010526b:	89 c3                	mov    %eax,%ebx
f010526d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105270:	eb 02                	jmp    f0105274 <strncmp+0x13>
		n--, p++, q++;
f0105272:	40                   	inc    %eax
f0105273:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105274:	39 d8                	cmp    %ebx,%eax
f0105276:	74 15                	je     f010528d <strncmp+0x2c>
f0105278:	8a 08                	mov    (%eax),%cl
f010527a:	84 c9                	test   %cl,%cl
f010527c:	74 04                	je     f0105282 <strncmp+0x21>
f010527e:	3a 0a                	cmp    (%edx),%cl
f0105280:	74 f0                	je     f0105272 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105282:	0f b6 00             	movzbl (%eax),%eax
f0105285:	0f b6 12             	movzbl (%edx),%edx
f0105288:	29 d0                	sub    %edx,%eax
}
f010528a:	5b                   	pop    %ebx
f010528b:	5d                   	pop    %ebp
f010528c:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010528d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105292:	eb f6                	jmp    f010528a <strncmp+0x29>

f0105294 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105294:	55                   	push   %ebp
f0105295:	89 e5                	mov    %esp,%ebp
f0105297:	8b 45 08             	mov    0x8(%ebp),%eax
f010529a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010529d:	8a 10                	mov    (%eax),%dl
f010529f:	84 d2                	test   %dl,%dl
f01052a1:	74 07                	je     f01052aa <strchr+0x16>
		if (*s == c)
f01052a3:	38 ca                	cmp    %cl,%dl
f01052a5:	74 08                	je     f01052af <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01052a7:	40                   	inc    %eax
f01052a8:	eb f3                	jmp    f010529d <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
f01052aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052af:	5d                   	pop    %ebp
f01052b0:	c3                   	ret    

f01052b1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01052b1:	55                   	push   %ebp
f01052b2:	89 e5                	mov    %esp,%ebp
f01052b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01052ba:	8a 10                	mov    (%eax),%dl
f01052bc:	84 d2                	test   %dl,%dl
f01052be:	74 07                	je     f01052c7 <strfind+0x16>
		if (*s == c)
f01052c0:	38 ca                	cmp    %cl,%dl
f01052c2:	74 03                	je     f01052c7 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01052c4:	40                   	inc    %eax
f01052c5:	eb f3                	jmp    f01052ba <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
f01052c7:	5d                   	pop    %ebp
f01052c8:	c3                   	ret    

f01052c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01052c9:	55                   	push   %ebp
f01052ca:	89 e5                	mov    %esp,%ebp
f01052cc:	57                   	push   %edi
f01052cd:	56                   	push   %esi
f01052ce:	53                   	push   %ebx
f01052cf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01052d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01052d5:	85 c9                	test   %ecx,%ecx
f01052d7:	74 13                	je     f01052ec <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01052d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01052df:	75 05                	jne    f01052e6 <memset+0x1d>
f01052e1:	f6 c1 03             	test   $0x3,%cl
f01052e4:	74 0d                	je     f01052f3 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01052e6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052e9:	fc                   	cld    
f01052ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01052ec:	89 f8                	mov    %edi,%eax
f01052ee:	5b                   	pop    %ebx
f01052ef:	5e                   	pop    %esi
f01052f0:	5f                   	pop    %edi
f01052f1:	5d                   	pop    %ebp
f01052f2:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
f01052f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01052f7:	89 d3                	mov    %edx,%ebx
f01052f9:	c1 e3 08             	shl    $0x8,%ebx
f01052fc:	89 d0                	mov    %edx,%eax
f01052fe:	c1 e0 18             	shl    $0x18,%eax
f0105301:	89 d6                	mov    %edx,%esi
f0105303:	c1 e6 10             	shl    $0x10,%esi
f0105306:	09 f0                	or     %esi,%eax
f0105308:	09 c2                	or     %eax,%edx
f010530a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010530c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010530f:	89 d0                	mov    %edx,%eax
f0105311:	fc                   	cld    
f0105312:	f3 ab                	rep stos %eax,%es:(%edi)
f0105314:	eb d6                	jmp    f01052ec <memset+0x23>

f0105316 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
f0105316:	55                   	push   %ebp
f0105317:	89 e5                	mov    %esp,%ebp
f0105319:	57                   	push   %edi
f010531a:	56                   	push   %esi
f010531b:	8b 45 08             	mov    0x8(%ebp),%eax
f010531e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105321:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105324:	39 c6                	cmp    %eax,%esi
f0105326:	73 33                	jae    f010535b <memmove+0x45>
f0105328:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010532b:	39 c2                	cmp    %eax,%edx
f010532d:	76 2c                	jbe    f010535b <memmove+0x45>
		s += n;
		d += n;
f010532f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105332:	89 d6                	mov    %edx,%esi
f0105334:	09 fe                	or     %edi,%esi
f0105336:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010533c:	74 0a                	je     f0105348 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010533e:	4f                   	dec    %edi
f010533f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105342:	fd                   	std    
f0105343:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105345:	fc                   	cld    
f0105346:	eb 21                	jmp    f0105369 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105348:	f6 c1 03             	test   $0x3,%cl
f010534b:	75 f1                	jne    f010533e <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010534d:	83 ef 04             	sub    $0x4,%edi
f0105350:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105353:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105356:	fd                   	std    
f0105357:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105359:	eb ea                	jmp    f0105345 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010535b:	89 f2                	mov    %esi,%edx
f010535d:	09 c2                	or     %eax,%edx
f010535f:	f6 c2 03             	test   $0x3,%dl
f0105362:	74 09                	je     f010536d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105364:	89 c7                	mov    %eax,%edi
f0105366:	fc                   	cld    
f0105367:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105369:	5e                   	pop    %esi
f010536a:	5f                   	pop    %edi
f010536b:	5d                   	pop    %ebp
f010536c:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010536d:	f6 c1 03             	test   $0x3,%cl
f0105370:	75 f2                	jne    f0105364 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105372:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105375:	89 c7                	mov    %eax,%edi
f0105377:	fc                   	cld    
f0105378:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010537a:	eb ed                	jmp    f0105369 <memmove+0x53>

f010537c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010537c:	55                   	push   %ebp
f010537d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010537f:	ff 75 10             	pushl  0x10(%ebp)
f0105382:	ff 75 0c             	pushl  0xc(%ebp)
f0105385:	ff 75 08             	pushl  0x8(%ebp)
f0105388:	e8 89 ff ff ff       	call   f0105316 <memmove>
}
f010538d:	c9                   	leave  
f010538e:	c3                   	ret    

f010538f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010538f:	55                   	push   %ebp
f0105390:	89 e5                	mov    %esp,%ebp
f0105392:	56                   	push   %esi
f0105393:	53                   	push   %ebx
f0105394:	8b 45 08             	mov    0x8(%ebp),%eax
f0105397:	8b 55 0c             	mov    0xc(%ebp),%edx
f010539a:	89 c6                	mov    %eax,%esi
f010539c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010539f:	39 f0                	cmp    %esi,%eax
f01053a1:	74 16                	je     f01053b9 <memcmp+0x2a>
		if (*s1 != *s2)
f01053a3:	8a 08                	mov    (%eax),%cl
f01053a5:	8a 1a                	mov    (%edx),%bl
f01053a7:	38 d9                	cmp    %bl,%cl
f01053a9:	75 04                	jne    f01053af <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01053ab:	40                   	inc    %eax
f01053ac:	42                   	inc    %edx
f01053ad:	eb f0                	jmp    f010539f <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
f01053af:	0f b6 c1             	movzbl %cl,%eax
f01053b2:	0f b6 db             	movzbl %bl,%ebx
f01053b5:	29 d8                	sub    %ebx,%eax
f01053b7:	eb 05                	jmp    f01053be <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
f01053b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01053be:	5b                   	pop    %ebx
f01053bf:	5e                   	pop    %esi
f01053c0:	5d                   	pop    %ebp
f01053c1:	c3                   	ret    

f01053c2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01053c2:	55                   	push   %ebp
f01053c3:	89 e5                	mov    %esp,%ebp
f01053c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01053c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01053cb:	89 c2                	mov    %eax,%edx
f01053cd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01053d0:	39 d0                	cmp    %edx,%eax
f01053d2:	73 07                	jae    f01053db <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01053d4:	38 08                	cmp    %cl,(%eax)
f01053d6:	74 03                	je     f01053db <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053d8:	40                   	inc    %eax
f01053d9:	eb f5                	jmp    f01053d0 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01053db:	5d                   	pop    %ebp
f01053dc:	c3                   	ret    

f01053dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01053dd:	55                   	push   %ebp
f01053de:	89 e5                	mov    %esp,%ebp
f01053e0:	57                   	push   %edi
f01053e1:	56                   	push   %esi
f01053e2:	53                   	push   %ebx
f01053e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053e6:	eb 01                	jmp    f01053e9 <strtol+0xc>
		s++;
f01053e8:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053e9:	8a 01                	mov    (%ecx),%al
f01053eb:	3c 20                	cmp    $0x20,%al
f01053ed:	74 f9                	je     f01053e8 <strtol+0xb>
f01053ef:	3c 09                	cmp    $0x9,%al
f01053f1:	74 f5                	je     f01053e8 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
f01053f3:	3c 2b                	cmp    $0x2b,%al
f01053f5:	74 2b                	je     f0105422 <strtol+0x45>
		s++;
	else if (*s == '-')
f01053f7:	3c 2d                	cmp    $0x2d,%al
f01053f9:	74 2f                	je     f010542a <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01053fb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105400:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105407:	75 12                	jne    f010541b <strtol+0x3e>
f0105409:	80 39 30             	cmpb   $0x30,(%ecx)
f010540c:	74 24                	je     f0105432 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010540e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105412:	75 07                	jne    f010541b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105414:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010541b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105420:	eb 4e                	jmp    f0105470 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
f0105422:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105423:	bf 00 00 00 00       	mov    $0x0,%edi
f0105428:	eb d6                	jmp    f0105400 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
f010542a:	41                   	inc    %ecx
f010542b:	bf 01 00 00 00       	mov    $0x1,%edi
f0105430:	eb ce                	jmp    f0105400 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105432:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105436:	74 10                	je     f0105448 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105438:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010543c:	75 dd                	jne    f010541b <strtol+0x3e>
		s++, base = 8;
f010543e:	41                   	inc    %ecx
f010543f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105446:	eb d3                	jmp    f010541b <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
f0105448:	83 c1 02             	add    $0x2,%ecx
f010544b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0105452:	eb c7                	jmp    f010541b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105454:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105457:	89 f3                	mov    %esi,%ebx
f0105459:	80 fb 19             	cmp    $0x19,%bl
f010545c:	77 24                	ja     f0105482 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010545e:	0f be d2             	movsbl %dl,%edx
f0105461:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105464:	39 55 10             	cmp    %edx,0x10(%ebp)
f0105467:	7e 2b                	jle    f0105494 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0105469:	41                   	inc    %ecx
f010546a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010546e:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105470:	8a 11                	mov    (%ecx),%dl
f0105472:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105475:	80 fb 09             	cmp    $0x9,%bl
f0105478:	77 da                	ja     f0105454 <strtol+0x77>
			dig = *s - '0';
f010547a:	0f be d2             	movsbl %dl,%edx
f010547d:	83 ea 30             	sub    $0x30,%edx
f0105480:	eb e2                	jmp    f0105464 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105482:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105485:	89 f3                	mov    %esi,%ebx
f0105487:	80 fb 19             	cmp    $0x19,%bl
f010548a:	77 08                	ja     f0105494 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010548c:	0f be d2             	movsbl %dl,%edx
f010548f:	83 ea 37             	sub    $0x37,%edx
f0105492:	eb d0                	jmp    f0105464 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105494:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105498:	74 05                	je     f010549f <strtol+0xc2>
		*endptr = (char *) s;
f010549a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010549d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010549f:	85 ff                	test   %edi,%edi
f01054a1:	74 02                	je     f01054a5 <strtol+0xc8>
f01054a3:	f7 d8                	neg    %eax
}
f01054a5:	5b                   	pop    %ebx
f01054a6:	5e                   	pop    %esi
f01054a7:	5f                   	pop    %edi
f01054a8:	5d                   	pop    %ebp
f01054a9:	c3                   	ret    
	...

f01054ac <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01054ac:	fa                   	cli    

	xorw    %ax, %ax
f01054ad:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01054af:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054b1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054b3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01054b5:	0f 01 16             	lgdtl  (%esi)
f01054b8:	74 70                	je     f010552a <mpsearch1+0x2>
	movl    %cr0, %eax
f01054ba:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01054bd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01054c1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01054c4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01054ca:	08 00                	or     %al,(%eax)

f01054cc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01054cc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01054d0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054d2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054d4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01054d6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01054da:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01054dc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01054de:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f01054e3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01054e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01054e9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01054ee:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01054f1:	8b 25 84 0e 29 f0    	mov    0xf0290e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01054f7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01054fc:	b8 e5 01 10 f0       	mov    $0xf01001e5,%eax
	call    *%eax
f0105501:	ff d0                	call   *%eax

f0105503 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105503:	eb fe                	jmp    f0105503 <spin>
f0105505:	8d 76 00             	lea    0x0(%esi),%esi

f0105508 <gdt>:
	...
f0105510:	ff                   	(bad)  
f0105511:	ff 00                	incl   (%eax)
f0105513:	00 00                	add    %al,(%eax)
f0105515:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010551c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105520 <gdtdesc>:
f0105520:	17                   	pop    %ss
f0105521:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105526 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105526:	90                   	nop
	...

f0105528 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105528:	55                   	push   %ebp
f0105529:	89 e5                	mov    %esp,%ebp
f010552b:	57                   	push   %edi
f010552c:	56                   	push   %esi
f010552d:	53                   	push   %ebx
f010552e:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105531:	8b 0d 88 0e 29 f0    	mov    0xf0290e88,%ecx
f0105537:	89 c3                	mov    %eax,%ebx
f0105539:	c1 eb 0c             	shr    $0xc,%ebx
f010553c:	39 cb                	cmp    %ecx,%ebx
f010553e:	73 1a                	jae    f010555a <mpsearch1+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0105540:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105546:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105549:	89 f0                	mov    %esi,%eax
f010554b:	c1 e8 0c             	shr    $0xc,%eax
f010554e:	39 c8                	cmp    %ecx,%eax
f0105550:	73 1a                	jae    f010556c <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0105552:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105558:	eb 27                	jmp    f0105581 <mpsearch1+0x59>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010555a:	50                   	push   %eax
f010555b:	68 24 5f 10 f0       	push   $0xf0105f24
f0105560:	6a 57                	push   $0x57
f0105562:	68 61 7b 10 f0       	push   $0xf0107b61
f0105567:	e8 d4 aa ff ff       	call   f0100040 <_panic>
f010556c:	56                   	push   %esi
f010556d:	68 24 5f 10 f0       	push   $0xf0105f24
f0105572:	6a 57                	push   $0x57
f0105574:	68 61 7b 10 f0       	push   $0xf0107b61
f0105579:	e8 c2 aa ff ff       	call   f0100040 <_panic>
f010557e:	83 c3 10             	add    $0x10,%ebx
f0105581:	39 f3                	cmp    %esi,%ebx
f0105583:	73 2c                	jae    f01055b1 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105585:	83 ec 04             	sub    $0x4,%esp
f0105588:	6a 04                	push   $0x4
f010558a:	68 71 7b 10 f0       	push   $0xf0107b71
f010558f:	53                   	push   %ebx
f0105590:	e8 fa fd ff ff       	call   f010538f <memcmp>
f0105595:	83 c4 10             	add    $0x10,%esp
f0105598:	85 c0                	test   %eax,%eax
f010559a:	75 e2                	jne    f010557e <mpsearch1+0x56>
f010559c:	89 da                	mov    %ebx,%edx
f010559e:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01055a1:	0f b6 0a             	movzbl (%edx),%ecx
f01055a4:	01 c8                	add    %ecx,%eax
f01055a6:	42                   	inc    %edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01055a7:	39 fa                	cmp    %edi,%edx
f01055a9:	75 f6                	jne    f01055a1 <mpsearch1+0x79>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01055ab:	84 c0                	test   %al,%al
f01055ad:	75 cf                	jne    f010557e <mpsearch1+0x56>
f01055af:	eb 05                	jmp    f01055b6 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01055b1:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01055b6:	89 d8                	mov    %ebx,%eax
f01055b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055bb:	5b                   	pop    %ebx
f01055bc:	5e                   	pop    %esi
f01055bd:	5f                   	pop    %edi
f01055be:	5d                   	pop    %ebp
f01055bf:	c3                   	ret    

f01055c0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01055c0:	55                   	push   %ebp
f01055c1:	89 e5                	mov    %esp,%ebp
f01055c3:	57                   	push   %edi
f01055c4:	56                   	push   %esi
f01055c5:	53                   	push   %ebx
f01055c6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01055c9:	c7 05 c0 13 29 f0 20 	movl   $0xf0291020,0xf02913c0
f01055d0:	10 29 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055d3:	83 3d 88 0e 29 f0 00 	cmpl   $0x0,0xf0290e88
f01055da:	0f 84 84 00 00 00    	je     f0105664 <mp_init+0xa4>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01055e0:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01055e7:	85 c0                	test   %eax,%eax
f01055e9:	0f 84 8b 00 00 00    	je     f010567a <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f01055ef:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01055f2:	ba 00 04 00 00       	mov    $0x400,%edx
f01055f7:	e8 2c ff ff ff       	call   f0105528 <mpsearch1>
f01055fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055ff:	85 c0                	test   %eax,%eax
f0105601:	0f 84 97 00 00 00    	je     f010569e <mp_init+0xde>
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105607:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010560a:	8b 70 04             	mov    0x4(%eax),%esi
f010560d:	85 f6                	test   %esi,%esi
f010560f:	0f 84 a8 00 00 00    	je     f01056bd <mp_init+0xfd>
f0105615:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105619:	0f 85 9e 00 00 00    	jne    f01056bd <mp_init+0xfd>
f010561f:	89 f0                	mov    %esi,%eax
f0105621:	c1 e8 0c             	shr    $0xc,%eax
f0105624:	3b 05 88 0e 29 f0    	cmp    0xf0290e88,%eax
f010562a:	0f 83 a2 00 00 00    	jae    f01056d2 <mp_init+0x112>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0105630:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0105636:	89 df                	mov    %ebx,%edi
		cprintf("SMP: Default configurations not implemented\n");
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105638:	83 ec 04             	sub    $0x4,%esp
f010563b:	6a 04                	push   $0x4
f010563d:	68 76 7b 10 f0       	push   $0xf0107b76
f0105642:	53                   	push   %ebx
f0105643:	e8 47 fd ff ff       	call   f010538f <memcmp>
f0105648:	83 c4 10             	add    $0x10,%esp
f010564b:	85 c0                	test   %eax,%eax
f010564d:	0f 85 94 00 00 00    	jne    f01056e7 <mp_init+0x127>
f0105653:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f0105657:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f010565a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010565d:	89 c2                	mov    %eax,%edx
f010565f:	e9 9e 00 00 00       	jmp    f0105702 <mp_init+0x142>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105664:	68 00 04 00 00       	push   $0x400
f0105669:	68 24 5f 10 f0       	push   $0xf0105f24
f010566e:	6a 6f                	push   $0x6f
f0105670:	68 61 7b 10 f0       	push   $0xf0107b61
f0105675:	e8 c6 a9 ff ff       	call   f0100040 <_panic>
		if ((mp = mpsearch1(p, 1024)))
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010567a:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105681:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105684:	2d 00 04 00 00       	sub    $0x400,%eax
f0105689:	ba 00 04 00 00       	mov    $0x400,%edx
f010568e:	e8 95 fe ff ff       	call   f0105528 <mpsearch1>
f0105693:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105696:	85 c0                	test   %eax,%eax
f0105698:	0f 85 69 ff ff ff    	jne    f0105607 <mp_init+0x47>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010569e:	ba 00 00 01 00       	mov    $0x10000,%edx
f01056a3:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01056a8:	e8 7b fe ff ff       	call   f0105528 <mpsearch1>
f01056ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01056b0:	85 c0                	test   %eax,%eax
f01056b2:	0f 85 4f ff ff ff    	jne    f0105607 <mp_init+0x47>
f01056b8:	e9 b3 01 00 00       	jmp    f0105870 <mp_init+0x2b0>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
		cprintf("SMP: Default configurations not implemented\n");
f01056bd:	83 ec 0c             	sub    $0xc,%esp
f01056c0:	68 d4 79 10 f0       	push   $0xf01079d4
f01056c5:	e8 87 e4 ff ff       	call   f0103b51 <cprintf>
f01056ca:	83 c4 10             	add    $0x10,%esp
f01056cd:	e9 9e 01 00 00       	jmp    f0105870 <mp_init+0x2b0>
f01056d2:	56                   	push   %esi
f01056d3:	68 24 5f 10 f0       	push   $0xf0105f24
f01056d8:	68 90 00 00 00       	push   $0x90
f01056dd:	68 61 7b 10 f0       	push   $0xf0107b61
f01056e2:	e8 59 a9 ff ff       	call   f0100040 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01056e7:	83 ec 0c             	sub    $0xc,%esp
f01056ea:	68 04 7a 10 f0       	push   $0xf0107a04
f01056ef:	e8 5d e4 ff ff       	call   f0103b51 <cprintf>
f01056f4:	83 c4 10             	add    $0x10,%esp
f01056f7:	e9 74 01 00 00       	jmp    f0105870 <mp_init+0x2b0>
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01056fc:	0f b6 0b             	movzbl (%ebx),%ecx
f01056ff:	01 ca                	add    %ecx,%edx
f0105701:	43                   	inc    %ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105702:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0105705:	75 f5                	jne    f01056fc <mp_init+0x13c>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105707:	84 d2                	test   %dl,%dl
f0105709:	75 15                	jne    f0105720 <mp_init+0x160>
		cprintf("SMP: Bad MP configuration checksum\n");
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010570b:	8a 57 06             	mov    0x6(%edi),%dl
f010570e:	80 fa 01             	cmp    $0x1,%dl
f0105711:	74 05                	je     f0105718 <mp_init+0x158>
f0105713:	80 fa 04             	cmp    $0x4,%dl
f0105716:	75 1d                	jne    f0105735 <mp_init+0x175>
f0105718:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f010571c:	01 d9                	add    %ebx,%ecx
f010571e:	eb 34                	jmp    f0105754 <mp_init+0x194>
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
		cprintf("SMP: Bad MP configuration checksum\n");
f0105720:	83 ec 0c             	sub    $0xc,%esp
f0105723:	68 38 7a 10 f0       	push   $0xf0107a38
f0105728:	e8 24 e4 ff ff       	call   f0103b51 <cprintf>
f010572d:	83 c4 10             	add    $0x10,%esp
f0105730:	e9 3b 01 00 00       	jmp    f0105870 <mp_init+0x2b0>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105735:	83 ec 08             	sub    $0x8,%esp
f0105738:	0f b6 d2             	movzbl %dl,%edx
f010573b:	52                   	push   %edx
f010573c:	68 5c 7a 10 f0       	push   $0xf0107a5c
f0105741:	e8 0b e4 ff ff       	call   f0103b51 <cprintf>
f0105746:	83 c4 10             	add    $0x10,%esp
f0105749:	e9 22 01 00 00       	jmp    f0105870 <mp_init+0x2b0>
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f010574e:	0f b6 13             	movzbl (%ebx),%edx
f0105751:	01 d0                	add    %edx,%eax
f0105753:	43                   	inc    %ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105754:	39 d9                	cmp    %ebx,%ecx
f0105756:	75 f6                	jne    f010574e <mp_init+0x18e>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105758:	02 47 2a             	add    0x2a(%edi),%al
f010575b:	75 28                	jne    f0105785 <mp_init+0x1c5>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010575d:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f0105763:	0f 84 07 01 00 00    	je     f0105870 <mp_init+0x2b0>
		return;
	ismp = 1;
f0105769:	c7 05 00 10 29 f0 01 	movl   $0x1,0xf0291000
f0105770:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105773:	8b 47 24             	mov    0x24(%edi),%eax
f0105776:	a3 00 20 2d f0       	mov    %eax,0xf02d2000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010577b:	8d 77 2c             	lea    0x2c(%edi),%esi
f010577e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105783:	eb 60                	jmp    f01057e5 <mp_init+0x225>
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105785:	83 ec 0c             	sub    $0xc,%esp
f0105788:	68 7c 7a 10 f0       	push   $0xf0107a7c
f010578d:	e8 bf e3 ff ff       	call   f0103b51 <cprintf>
f0105792:	83 c4 10             	add    $0x10,%esp
f0105795:	e9 d6 00 00 00       	jmp    f0105870 <mp_init+0x2b0>

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010579a:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f010579e:	74 1e                	je     f01057be <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f01057a0:	8b 15 c4 13 29 f0    	mov    0xf02913c4,%edx
f01057a6:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01057a9:	01 d0                	add    %edx,%eax
f01057ab:	01 c0                	add    %eax,%eax
f01057ad:	01 d0                	add    %edx,%eax
f01057af:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01057b2:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
f01057b9:	a3 c0 13 29 f0       	mov    %eax,0xf02913c0
			if (ncpu < NCPU) {
f01057be:	a1 c4 13 29 f0       	mov    0xf02913c4,%eax
f01057c3:	83 f8 07             	cmp    $0x7,%eax
f01057c6:	7f 34                	jg     f01057fc <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f01057c8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01057cb:	01 c2                	add    %eax,%edx
f01057cd:	01 d2                	add    %edx,%edx
f01057cf:	01 c2                	add    %eax,%edx
f01057d1:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01057d4:	88 04 95 20 10 29 f0 	mov    %al,-0xfd6efe0(,%edx,4)
				ncpu++;
f01057db:	40                   	inc    %eax
f01057dc:	a3 c4 13 29 f0       	mov    %eax,0xf02913c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01057e1:	83 c6 14             	add    $0x14,%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01057e4:	43                   	inc    %ebx
f01057e5:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f01057e9:	39 d8                	cmp    %ebx,%eax
f01057eb:	76 4a                	jbe    f0105837 <mp_init+0x277>
		switch (*p) {
f01057ed:	8a 06                	mov    (%esi),%al
f01057ef:	84 c0                	test   %al,%al
f01057f1:	74 a7                	je     f010579a <mp_init+0x1da>
f01057f3:	3c 04                	cmp    $0x4,%al
f01057f5:	77 1c                	ja     f0105813 <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01057f7:	83 c6 08             	add    $0x8,%esi
			continue;
f01057fa:	eb e8                	jmp    f01057e4 <mp_init+0x224>
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
				cpus[ncpu].cpu_id = ncpu;
				ncpu++;
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01057fc:	83 ec 08             	sub    $0x8,%esp
f01057ff:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105803:	50                   	push   %eax
f0105804:	68 ac 7a 10 f0       	push   $0xf0107aac
f0105809:	e8 43 e3 ff ff       	call   f0103b51 <cprintf>
f010580e:	83 c4 10             	add    $0x10,%esp
f0105811:	eb ce                	jmp    f01057e1 <mp_init+0x221>
		case MPIOINTR:
		case MPLINTR:
			p += 8;
			continue;
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105813:	83 ec 08             	sub    $0x8,%esp
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
		switch (*p) {
f0105816:	0f b6 c0             	movzbl %al,%eax
		case MPIOINTR:
		case MPLINTR:
			p += 8;
			continue;
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105819:	50                   	push   %eax
f010581a:	68 d4 7a 10 f0       	push   $0xf0107ad4
f010581f:	e8 2d e3 ff ff       	call   f0103b51 <cprintf>
			ismp = 0;
f0105824:	c7 05 00 10 29 f0 00 	movl   $0x0,0xf0291000
f010582b:	00 00 00 
			i = conf->entry;
f010582e:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105832:	83 c4 10             	add    $0x10,%esp
f0105835:	eb ad                	jmp    f01057e4 <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105837:	a1 c0 13 29 f0       	mov    0xf02913c0,%eax
f010583c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105843:	83 3d 00 10 29 f0 00 	cmpl   $0x0,0xf0291000
f010584a:	75 2c                	jne    f0105878 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010584c:	c7 05 c4 13 29 f0 01 	movl   $0x1,0xf02913c4
f0105853:	00 00 00 
		lapicaddr = 0;
f0105856:	c7 05 00 20 2d f0 00 	movl   $0x0,0xf02d2000
f010585d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105860:	83 ec 0c             	sub    $0xc,%esp
f0105863:	68 f4 7a 10 f0       	push   $0xf0107af4
f0105868:	e8 e4 e2 ff ff       	call   f0103b51 <cprintf>
		return;
f010586d:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105870:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105873:	5b                   	pop    %ebx
f0105874:	5e                   	pop    %esi
f0105875:	5f                   	pop    %edi
f0105876:	5d                   	pop    %ebp
f0105877:	c3                   	ret    
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105878:	83 ec 04             	sub    $0x4,%esp
f010587b:	ff 35 c4 13 29 f0    	pushl  0xf02913c4
f0105881:	0f b6 00             	movzbl (%eax),%eax
f0105884:	50                   	push   %eax
f0105885:	68 7b 7b 10 f0       	push   $0xf0107b7b
f010588a:	e8 c2 e2 ff ff       	call   f0103b51 <cprintf>

	if (mp->imcrp) {
f010588f:	83 c4 10             	add    $0x10,%esp
f0105892:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105895:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105899:	74 d5                	je     f0105870 <mp_init+0x2b0>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010589b:	83 ec 0c             	sub    $0xc,%esp
f010589e:	68 20 7b 10 f0       	push   $0xf0107b20
f01058a3:	e8 a9 e2 ff ff       	call   f0103b51 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01058a8:	b0 70                	mov    $0x70,%al
f01058aa:	ba 22 00 00 00       	mov    $0x22,%edx
f01058af:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01058b0:	ba 23 00 00 00       	mov    $0x23,%edx
f01058b5:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01058b6:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01058b9:	ee                   	out    %al,(%dx)
f01058ba:	83 c4 10             	add    $0x10,%esp
f01058bd:	eb b1                	jmp    f0105870 <mp_init+0x2b0>
	...

f01058c0 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01058c0:	55                   	push   %ebp
f01058c1:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01058c3:	8b 0d 04 20 2d f0    	mov    0xf02d2004,%ecx
f01058c9:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01058cc:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01058ce:	a1 04 20 2d f0       	mov    0xf02d2004,%eax
f01058d3:	8b 40 20             	mov    0x20(%eax),%eax
}
f01058d6:	5d                   	pop    %ebp
f01058d7:	c3                   	ret    

f01058d8 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01058d8:	55                   	push   %ebp
f01058d9:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01058db:	a1 04 20 2d f0       	mov    0xf02d2004,%eax
f01058e0:	85 c0                	test   %eax,%eax
f01058e2:	74 08                	je     f01058ec <cpunum+0x14>
		return lapic[ID] >> 24;
f01058e4:	8b 40 20             	mov    0x20(%eax),%eax
f01058e7:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01058ea:	5d                   	pop    %ebp
f01058eb:	c3                   	ret    
int
cpunum(void)
{
	if (lapic)
		return lapic[ID] >> 24;
	return 0;
f01058ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01058f1:	eb f7                	jmp    f01058ea <cpunum+0x12>

f01058f3 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01058f3:	a1 00 20 2d f0       	mov    0xf02d2000,%eax
f01058f8:	85 c0                	test   %eax,%eax
f01058fa:	75 01                	jne    f01058fd <lapic_init+0xa>
f01058fc:	c3                   	ret    
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01058fd:	55                   	push   %ebp
f01058fe:	89 e5                	mov    %esp,%ebp
f0105900:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105903:	68 00 10 00 00       	push   $0x1000
f0105908:	50                   	push   %eax
f0105909:	e8 55 bb ff ff       	call   f0101463 <mmio_map_region>
f010590e:	a3 04 20 2d f0       	mov    %eax,0xf02d2004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105913:	ba 27 01 00 00       	mov    $0x127,%edx
f0105918:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010591d:	e8 9e ff ff ff       	call   f01058c0 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105922:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105927:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010592c:	e8 8f ff ff ff       	call   f01058c0 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105931:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105936:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010593b:	e8 80 ff ff ff       	call   f01058c0 <lapicw>
	lapicw(TICR, 10000000); 
f0105940:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105945:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010594a:	e8 71 ff ff ff       	call   f01058c0 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010594f:	e8 84 ff ff ff       	call   f01058d8 <cpunum>
f0105954:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105957:	01 c2                	add    %eax,%edx
f0105959:	01 d2                	add    %edx,%edx
f010595b:	01 c2                	add    %eax,%edx
f010595d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105960:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
f0105967:	83 c4 10             	add    $0x10,%esp
f010596a:	39 05 c0 13 29 f0    	cmp    %eax,0xf02913c0
f0105970:	74 0f                	je     f0105981 <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f0105972:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105977:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010597c:	e8 3f ff ff ff       	call   f01058c0 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105981:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105986:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010598b:	e8 30 ff ff ff       	call   f01058c0 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105990:	a1 04 20 2d f0       	mov    0xf02d2004,%eax
f0105995:	8b 40 30             	mov    0x30(%eax),%eax
f0105998:	c1 e8 10             	shr    $0x10,%eax
f010599b:	3c 03                	cmp    $0x3,%al
f010599d:	77 7c                	ja     f0105a1b <lapic_init+0x128>
		lapicw(PCINT, MASKED);

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010599f:	ba 33 00 00 00       	mov    $0x33,%edx
f01059a4:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01059a9:	e8 12 ff ff ff       	call   f01058c0 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01059ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01059b3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059b8:	e8 03 ff ff ff       	call   f01058c0 <lapicw>
	lapicw(ESR, 0);
f01059bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01059c2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059c7:	e8 f4 fe ff ff       	call   f01058c0 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01059cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01059d1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01059d6:	e8 e5 fe ff ff       	call   f01058c0 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01059db:	ba 00 00 00 00       	mov    $0x0,%edx
f01059e0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059e5:	e8 d6 fe ff ff       	call   f01058c0 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01059ea:	ba 00 85 08 00       	mov    $0x88500,%edx
f01059ef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059f4:	e8 c7 fe ff ff       	call   f01058c0 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01059f9:	8b 15 04 20 2d f0    	mov    0xf02d2004,%edx
f01059ff:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105a05:	f6 c4 10             	test   $0x10,%ah
f0105a08:	75 f5                	jne    f01059ff <lapic_init+0x10c>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105a0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a0f:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a14:	e8 a7 fe ff ff       	call   f01058c0 <lapicw>
}
f0105a19:	c9                   	leave  
f0105a1a:	c3                   	ret    
	lapicw(LINT1, MASKED);

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
		lapicw(PCINT, MASKED);
f0105a1b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a20:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105a25:	e8 96 fe ff ff       	call   f01058c0 <lapicw>
f0105a2a:	e9 70 ff ff ff       	jmp    f010599f <lapic_init+0xac>

f0105a2f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105a2f:	83 3d 04 20 2d f0 00 	cmpl   $0x0,0xf02d2004
f0105a36:	74 14                	je     f0105a4c <lapic_eoi+0x1d>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105a38:	55                   	push   %ebp
f0105a39:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105a3b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a40:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a45:	e8 76 fe ff ff       	call   f01058c0 <lapicw>
}
f0105a4a:	5d                   	pop    %ebp
f0105a4b:	c3                   	ret    
f0105a4c:	c3                   	ret    

f0105a4d <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105a4d:	55                   	push   %ebp
f0105a4e:	89 e5                	mov    %esp,%ebp
f0105a50:	56                   	push   %esi
f0105a51:	53                   	push   %ebx
f0105a52:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a58:	b0 0f                	mov    $0xf,%al
f0105a5a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105a5f:	ee                   	out    %al,(%dx)
f0105a60:	b0 0a                	mov    $0xa,%al
f0105a62:	ba 71 00 00 00       	mov    $0x71,%edx
f0105a67:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a68:	83 3d 88 0e 29 f0 00 	cmpl   $0x0,0xf0290e88
f0105a6f:	74 7e                	je     f0105aef <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105a71:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105a78:	00 00 
	wrv[1] = addr >> 4;
f0105a7a:	89 d8                	mov    %ebx,%eax
f0105a7c:	c1 e8 04             	shr    $0x4,%eax
f0105a7f:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105a85:	c1 e6 18             	shl    $0x18,%esi
f0105a88:	89 f2                	mov    %esi,%edx
f0105a8a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a8f:	e8 2c fe ff ff       	call   f01058c0 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105a94:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105a99:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a9e:	e8 1d fe ff ff       	call   f01058c0 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105aa3:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105aa8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105aad:	e8 0e fe ff ff       	call   f01058c0 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ab2:	c1 eb 0c             	shr    $0xc,%ebx
f0105ab5:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ab8:	89 f2                	mov    %esi,%edx
f0105aba:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105abf:	e8 fc fd ff ff       	call   f01058c0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ac4:	89 da                	mov    %ebx,%edx
f0105ac6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105acb:	e8 f0 fd ff ff       	call   f01058c0 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ad0:	89 f2                	mov    %esi,%edx
f0105ad2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ad7:	e8 e4 fd ff ff       	call   f01058c0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105adc:	89 da                	mov    %ebx,%edx
f0105ade:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ae3:	e8 d8 fd ff ff       	call   f01058c0 <lapicw>
		microdelay(200);
	}
}
f0105ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105aeb:	5b                   	pop    %ebx
f0105aec:	5e                   	pop    %esi
f0105aed:	5d                   	pop    %ebp
f0105aee:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aef:	68 67 04 00 00       	push   $0x467
f0105af4:	68 24 5f 10 f0       	push   $0xf0105f24
f0105af9:	68 98 00 00 00       	push   $0x98
f0105afe:	68 98 7b 10 f0       	push   $0xf0107b98
f0105b03:	e8 38 a5 ff ff       	call   f0100040 <_panic>

f0105b08 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105b08:	55                   	push   %ebp
f0105b09:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105b0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b0e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105b14:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b19:	e8 a2 fd ff ff       	call   f01058c0 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105b1e:	8b 15 04 20 2d f0    	mov    0xf02d2004,%edx
f0105b24:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b2a:	f6 c4 10             	test   $0x10,%ah
f0105b2d:	75 f5                	jne    f0105b24 <lapic_ipi+0x1c>
		;
}
f0105b2f:	5d                   	pop    %ebp
f0105b30:	c3                   	ret    
f0105b31:	00 00                	add    %al,(%eax)
	...

f0105b34 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105b34:	55                   	push   %ebp
f0105b35:	89 e5                	mov    %esp,%ebp
f0105b37:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105b3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105b40:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b43:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105b46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105b4d:	5d                   	pop    %ebp
f0105b4e:	c3                   	ret    

f0105b4f <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105b4f:	55                   	push   %ebp
f0105b50:	89 e5                	mov    %esp,%ebp
f0105b52:	56                   	push   %esi
f0105b53:	53                   	push   %ebx
f0105b54:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105b57:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105b5a:	75 07                	jne    f0105b63 <spin_lock+0x14>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b5c:	ba 01 00 00 00       	mov    $0x1,%edx
f0105b61:	eb 3f                	jmp    f0105ba2 <spin_lock+0x53>
f0105b63:	8b 73 08             	mov    0x8(%ebx),%esi
f0105b66:	e8 6d fd ff ff       	call   f01058d8 <cpunum>
f0105b6b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105b6e:	01 c2                	add    %eax,%edx
f0105b70:	01 d2                	add    %edx,%edx
f0105b72:	01 c2                	add    %eax,%edx
f0105b74:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b77:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105b7e:	39 c6                	cmp    %eax,%esi
f0105b80:	75 da                	jne    f0105b5c <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105b82:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105b85:	e8 4e fd ff ff       	call   f01058d8 <cpunum>
f0105b8a:	83 ec 0c             	sub    $0xc,%esp
f0105b8d:	53                   	push   %ebx
f0105b8e:	50                   	push   %eax
f0105b8f:	68 a8 7b 10 f0       	push   $0xf0107ba8
f0105b94:	6a 41                	push   $0x41
f0105b96:	68 0c 7c 10 f0       	push   $0xf0107c0c
f0105b9b:	e8 a0 a4 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105ba0:	f3 90                	pause  
f0105ba2:	89 d0                	mov    %edx,%eax
f0105ba4:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ba7:	85 c0                	test   %eax,%eax
f0105ba9:	75 f5                	jne    f0105ba0 <spin_lock+0x51>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105bab:	e8 28 fd ff ff       	call   f01058d8 <cpunum>
f0105bb0:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105bb3:	01 c2                	add    %eax,%edx
f0105bb5:	01 d2                	add    %edx,%edx
f0105bb7:	01 c2                	add    %eax,%edx
f0105bb9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105bbc:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
f0105bc3:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105bc6:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105bc9:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105bcb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105bd0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105bd6:	76 1d                	jbe    f0105bf5 <spin_lock+0xa6>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105bd8:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105bdb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105bde:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105be0:	40                   	inc    %eax
f0105be1:	83 f8 0a             	cmp    $0xa,%eax
f0105be4:	75 ea                	jne    f0105bd0 <spin_lock+0x81>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105be6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105be9:	5b                   	pop    %ebx
f0105bea:	5e                   	pop    %esi
f0105beb:	5d                   	pop    %ebp
f0105bec:	c3                   	ret    
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105bed:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105bf4:	40                   	inc    %eax
f0105bf5:	83 f8 09             	cmp    $0x9,%eax
f0105bf8:	7e f3                	jle    f0105bed <spin_lock+0x9e>
f0105bfa:	eb ea                	jmp    f0105be6 <spin_lock+0x97>

f0105bfc <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105bfc:	55                   	push   %ebp
f0105bfd:	89 e5                	mov    %esp,%ebp
f0105bff:	57                   	push   %edi
f0105c00:	56                   	push   %esi
f0105c01:	53                   	push   %ebx
f0105c02:	83 ec 4c             	sub    $0x4c,%esp
f0105c05:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105c08:	83 3e 00             	cmpl   $0x0,(%esi)
f0105c0b:	75 35                	jne    f0105c42 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105c0d:	83 ec 04             	sub    $0x4,%esp
f0105c10:	6a 28                	push   $0x28
f0105c12:	8d 46 0c             	lea    0xc(%esi),%eax
f0105c15:	50                   	push   %eax
f0105c16:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105c19:	53                   	push   %ebx
f0105c1a:	e8 f7 f6 ff ff       	call   f0105316 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105c1f:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105c22:	0f b6 38             	movzbl (%eax),%edi
f0105c25:	8b 76 04             	mov    0x4(%esi),%esi
f0105c28:	e8 ab fc ff ff       	call   f01058d8 <cpunum>
f0105c2d:	57                   	push   %edi
f0105c2e:	56                   	push   %esi
f0105c2f:	50                   	push   %eax
f0105c30:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0105c35:	e8 17 df ff ff       	call   f0103b51 <cprintf>
f0105c3a:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105c3d:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105c40:	eb 6c                	jmp    f0105cae <spin_unlock+0xb2>

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105c42:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105c45:	e8 8e fc ff ff       	call   f01058d8 <cpunum>
f0105c4a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105c4d:	01 c2                	add    %eax,%edx
f0105c4f:	01 d2                	add    %edx,%edx
f0105c51:	01 c2                	add    %eax,%edx
f0105c53:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105c56:	8d 04 85 20 10 29 f0 	lea    -0xfd6efe0(,%eax,4),%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105c5d:	39 c3                	cmp    %eax,%ebx
f0105c5f:	75 ac                	jne    f0105c0d <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105c61:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105c68:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105c6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c74:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c7a:	5b                   	pop    %ebx
f0105c7b:	5e                   	pop    %esi
f0105c7c:	5f                   	pop    %edi
f0105c7d:	5d                   	pop    %ebp
f0105c7e:	c3                   	ret    
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105c7f:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105c81:	83 ec 04             	sub    $0x4,%esp
f0105c84:	89 c2                	mov    %eax,%edx
f0105c86:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105c89:	52                   	push   %edx
f0105c8a:	ff 75 b0             	pushl  -0x50(%ebp)
f0105c8d:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105c90:	ff 75 ac             	pushl  -0x54(%ebp)
f0105c93:	ff 75 a8             	pushl  -0x58(%ebp)
f0105c96:	50                   	push   %eax
f0105c97:	68 1c 7c 10 f0       	push   $0xf0107c1c
f0105c9c:	e8 b0 de ff ff       	call   f0103b51 <cprintf>
f0105ca1:	83 c4 20             	add    $0x20,%esp
f0105ca4:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105ca7:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105caa:	39 c3                	cmp    %eax,%ebx
f0105cac:	74 2d                	je     f0105cdb <spin_unlock+0xdf>
f0105cae:	89 de                	mov    %ebx,%esi
f0105cb0:	8b 03                	mov    (%ebx),%eax
f0105cb2:	85 c0                	test   %eax,%eax
f0105cb4:	74 25                	je     f0105cdb <spin_unlock+0xdf>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105cb6:	83 ec 08             	sub    $0x8,%esp
f0105cb9:	57                   	push   %edi
f0105cba:	50                   	push   %eax
f0105cbb:	e8 35 eb ff ff       	call   f01047f5 <debuginfo_eip>
f0105cc0:	83 c4 10             	add    $0x10,%esp
f0105cc3:	85 c0                	test   %eax,%eax
f0105cc5:	79 b8                	jns    f0105c7f <spin_unlock+0x83>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105cc7:	83 ec 08             	sub    $0x8,%esp
f0105cca:	ff 36                	pushl  (%esi)
f0105ccc:	68 33 7c 10 f0       	push   $0xf0107c33
f0105cd1:	e8 7b de ff ff       	call   f0103b51 <cprintf>
f0105cd6:	83 c4 10             	add    $0x10,%esp
f0105cd9:	eb c9                	jmp    f0105ca4 <spin_unlock+0xa8>
		}
		panic("spin_unlock");
f0105cdb:	83 ec 04             	sub    $0x4,%esp
f0105cde:	68 3b 7c 10 f0       	push   $0xf0107c3b
f0105ce3:	6a 67                	push   $0x67
f0105ce5:	68 0c 7c 10 f0       	push   $0xf0107c0c
f0105cea:	e8 51 a3 ff ff       	call   f0100040 <_panic>
	...

f0105cf0 <__udivdi3>:
f0105cf0:	55                   	push   %ebp
f0105cf1:	57                   	push   %edi
f0105cf2:	56                   	push   %esi
f0105cf3:	53                   	push   %ebx
f0105cf4:	83 ec 1c             	sub    $0x1c,%esp
f0105cf7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105cfb:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105cff:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105d03:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105d07:	85 d2                	test   %edx,%edx
f0105d09:	75 2d                	jne    f0105d38 <__udivdi3+0x48>
f0105d0b:	39 f7                	cmp    %esi,%edi
f0105d0d:	77 59                	ja     f0105d68 <__udivdi3+0x78>
f0105d0f:	89 f9                	mov    %edi,%ecx
f0105d11:	85 ff                	test   %edi,%edi
f0105d13:	75 0b                	jne    f0105d20 <__udivdi3+0x30>
f0105d15:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d1a:	31 d2                	xor    %edx,%edx
f0105d1c:	f7 f7                	div    %edi
f0105d1e:	89 c1                	mov    %eax,%ecx
f0105d20:	31 d2                	xor    %edx,%edx
f0105d22:	89 f0                	mov    %esi,%eax
f0105d24:	f7 f1                	div    %ecx
f0105d26:	89 c3                	mov    %eax,%ebx
f0105d28:	89 e8                	mov    %ebp,%eax
f0105d2a:	f7 f1                	div    %ecx
f0105d2c:	89 da                	mov    %ebx,%edx
f0105d2e:	83 c4 1c             	add    $0x1c,%esp
f0105d31:	5b                   	pop    %ebx
f0105d32:	5e                   	pop    %esi
f0105d33:	5f                   	pop    %edi
f0105d34:	5d                   	pop    %ebp
f0105d35:	c3                   	ret    
f0105d36:	66 90                	xchg   %ax,%ax
f0105d38:	39 f2                	cmp    %esi,%edx
f0105d3a:	77 1c                	ja     f0105d58 <__udivdi3+0x68>
f0105d3c:	0f bd da             	bsr    %edx,%ebx
f0105d3f:	83 f3 1f             	xor    $0x1f,%ebx
f0105d42:	75 38                	jne    f0105d7c <__udivdi3+0x8c>
f0105d44:	39 f2                	cmp    %esi,%edx
f0105d46:	72 08                	jb     f0105d50 <__udivdi3+0x60>
f0105d48:	39 ef                	cmp    %ebp,%edi
f0105d4a:	0f 87 98 00 00 00    	ja     f0105de8 <__udivdi3+0xf8>
f0105d50:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d55:	eb 05                	jmp    f0105d5c <__udivdi3+0x6c>
f0105d57:	90                   	nop
f0105d58:	31 db                	xor    %ebx,%ebx
f0105d5a:	31 c0                	xor    %eax,%eax
f0105d5c:	89 da                	mov    %ebx,%edx
f0105d5e:	83 c4 1c             	add    $0x1c,%esp
f0105d61:	5b                   	pop    %ebx
f0105d62:	5e                   	pop    %esi
f0105d63:	5f                   	pop    %edi
f0105d64:	5d                   	pop    %ebp
f0105d65:	c3                   	ret    
f0105d66:	66 90                	xchg   %ax,%ax
f0105d68:	89 e8                	mov    %ebp,%eax
f0105d6a:	89 f2                	mov    %esi,%edx
f0105d6c:	f7 f7                	div    %edi
f0105d6e:	31 db                	xor    %ebx,%ebx
f0105d70:	89 da                	mov    %ebx,%edx
f0105d72:	83 c4 1c             	add    $0x1c,%esp
f0105d75:	5b                   	pop    %ebx
f0105d76:	5e                   	pop    %esi
f0105d77:	5f                   	pop    %edi
f0105d78:	5d                   	pop    %ebp
f0105d79:	c3                   	ret    
f0105d7a:	66 90                	xchg   %ax,%ax
f0105d7c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d81:	29 d8                	sub    %ebx,%eax
f0105d83:	88 d9                	mov    %bl,%cl
f0105d85:	d3 e2                	shl    %cl,%edx
f0105d87:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105d8b:	89 fa                	mov    %edi,%edx
f0105d8d:	88 c1                	mov    %al,%cl
f0105d8f:	d3 ea                	shr    %cl,%edx
f0105d91:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105d95:	09 d1                	or     %edx,%ecx
f0105d97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d9b:	88 d9                	mov    %bl,%cl
f0105d9d:	d3 e7                	shl    %cl,%edi
f0105d9f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105da3:	89 f7                	mov    %esi,%edi
f0105da5:	88 c1                	mov    %al,%cl
f0105da7:	d3 ef                	shr    %cl,%edi
f0105da9:	88 d9                	mov    %bl,%cl
f0105dab:	d3 e6                	shl    %cl,%esi
f0105dad:	89 ea                	mov    %ebp,%edx
f0105daf:	88 c1                	mov    %al,%cl
f0105db1:	d3 ea                	shr    %cl,%edx
f0105db3:	09 d6                	or     %edx,%esi
f0105db5:	89 f0                	mov    %esi,%eax
f0105db7:	89 fa                	mov    %edi,%edx
f0105db9:	f7 74 24 08          	divl   0x8(%esp)
f0105dbd:	89 d7                	mov    %edx,%edi
f0105dbf:	89 c6                	mov    %eax,%esi
f0105dc1:	f7 64 24 0c          	mull   0xc(%esp)
f0105dc5:	39 d7                	cmp    %edx,%edi
f0105dc7:	72 13                	jb     f0105ddc <__udivdi3+0xec>
f0105dc9:	74 09                	je     f0105dd4 <__udivdi3+0xe4>
f0105dcb:	89 f0                	mov    %esi,%eax
f0105dcd:	31 db                	xor    %ebx,%ebx
f0105dcf:	eb 8b                	jmp    f0105d5c <__udivdi3+0x6c>
f0105dd1:	8d 76 00             	lea    0x0(%esi),%esi
f0105dd4:	88 d9                	mov    %bl,%cl
f0105dd6:	d3 e5                	shl    %cl,%ebp
f0105dd8:	39 c5                	cmp    %eax,%ebp
f0105dda:	73 ef                	jae    f0105dcb <__udivdi3+0xdb>
f0105ddc:	8d 46 ff             	lea    -0x1(%esi),%eax
f0105ddf:	31 db                	xor    %ebx,%ebx
f0105de1:	e9 76 ff ff ff       	jmp    f0105d5c <__udivdi3+0x6c>
f0105de6:	66 90                	xchg   %ax,%ax
f0105de8:	31 c0                	xor    %eax,%eax
f0105dea:	e9 6d ff ff ff       	jmp    f0105d5c <__udivdi3+0x6c>
	...

f0105df0 <__umoddi3>:
f0105df0:	55                   	push   %ebp
f0105df1:	57                   	push   %edi
f0105df2:	56                   	push   %esi
f0105df3:	53                   	push   %ebx
f0105df4:	83 ec 1c             	sub    $0x1c,%esp
f0105df7:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105dfb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105dff:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e03:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0105e07:	89 f0                	mov    %esi,%eax
f0105e09:	89 da                	mov    %ebx,%edx
f0105e0b:	85 ed                	test   %ebp,%ebp
f0105e0d:	75 15                	jne    f0105e24 <__umoddi3+0x34>
f0105e0f:	39 df                	cmp    %ebx,%edi
f0105e11:	76 39                	jbe    f0105e4c <__umoddi3+0x5c>
f0105e13:	f7 f7                	div    %edi
f0105e15:	89 d0                	mov    %edx,%eax
f0105e17:	31 d2                	xor    %edx,%edx
f0105e19:	83 c4 1c             	add    $0x1c,%esp
f0105e1c:	5b                   	pop    %ebx
f0105e1d:	5e                   	pop    %esi
f0105e1e:	5f                   	pop    %edi
f0105e1f:	5d                   	pop    %ebp
f0105e20:	c3                   	ret    
f0105e21:	8d 76 00             	lea    0x0(%esi),%esi
f0105e24:	39 dd                	cmp    %ebx,%ebp
f0105e26:	77 f1                	ja     f0105e19 <__umoddi3+0x29>
f0105e28:	0f bd cd             	bsr    %ebp,%ecx
f0105e2b:	83 f1 1f             	xor    $0x1f,%ecx
f0105e2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105e32:	75 38                	jne    f0105e6c <__umoddi3+0x7c>
f0105e34:	39 dd                	cmp    %ebx,%ebp
f0105e36:	72 04                	jb     f0105e3c <__umoddi3+0x4c>
f0105e38:	39 f7                	cmp    %esi,%edi
f0105e3a:	77 dd                	ja     f0105e19 <__umoddi3+0x29>
f0105e3c:	89 da                	mov    %ebx,%edx
f0105e3e:	89 f0                	mov    %esi,%eax
f0105e40:	29 f8                	sub    %edi,%eax
f0105e42:	19 ea                	sbb    %ebp,%edx
f0105e44:	83 c4 1c             	add    $0x1c,%esp
f0105e47:	5b                   	pop    %ebx
f0105e48:	5e                   	pop    %esi
f0105e49:	5f                   	pop    %edi
f0105e4a:	5d                   	pop    %ebp
f0105e4b:	c3                   	ret    
f0105e4c:	89 f9                	mov    %edi,%ecx
f0105e4e:	85 ff                	test   %edi,%edi
f0105e50:	75 0b                	jne    f0105e5d <__umoddi3+0x6d>
f0105e52:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e57:	31 d2                	xor    %edx,%edx
f0105e59:	f7 f7                	div    %edi
f0105e5b:	89 c1                	mov    %eax,%ecx
f0105e5d:	89 d8                	mov    %ebx,%eax
f0105e5f:	31 d2                	xor    %edx,%edx
f0105e61:	f7 f1                	div    %ecx
f0105e63:	89 f0                	mov    %esi,%eax
f0105e65:	f7 f1                	div    %ecx
f0105e67:	eb ac                	jmp    f0105e15 <__umoddi3+0x25>
f0105e69:	8d 76 00             	lea    0x0(%esi),%esi
f0105e6c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e71:	89 c2                	mov    %eax,%edx
f0105e73:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105e77:	29 c2                	sub    %eax,%edx
f0105e79:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105e7d:	88 c1                	mov    %al,%cl
f0105e7f:	d3 e5                	shl    %cl,%ebp
f0105e81:	89 f8                	mov    %edi,%eax
f0105e83:	88 d1                	mov    %dl,%cl
f0105e85:	d3 e8                	shr    %cl,%eax
f0105e87:	09 c5                	or     %eax,%ebp
f0105e89:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105e8d:	88 c1                	mov    %al,%cl
f0105e8f:	d3 e7                	shl    %cl,%edi
f0105e91:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105e95:	89 df                	mov    %ebx,%edi
f0105e97:	88 d1                	mov    %dl,%cl
f0105e99:	d3 ef                	shr    %cl,%edi
f0105e9b:	88 c1                	mov    %al,%cl
f0105e9d:	d3 e3                	shl    %cl,%ebx
f0105e9f:	89 f0                	mov    %esi,%eax
f0105ea1:	88 d1                	mov    %dl,%cl
f0105ea3:	d3 e8                	shr    %cl,%eax
f0105ea5:	09 d8                	or     %ebx,%eax
f0105ea7:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0105eab:	d3 e6                	shl    %cl,%esi
f0105ead:	89 fa                	mov    %edi,%edx
f0105eaf:	f7 f5                	div    %ebp
f0105eb1:	89 d1                	mov    %edx,%ecx
f0105eb3:	f7 64 24 08          	mull   0x8(%esp)
f0105eb7:	89 c3                	mov    %eax,%ebx
f0105eb9:	89 d7                	mov    %edx,%edi
f0105ebb:	39 d1                	cmp    %edx,%ecx
f0105ebd:	72 29                	jb     f0105ee8 <__umoddi3+0xf8>
f0105ebf:	74 23                	je     f0105ee4 <__umoddi3+0xf4>
f0105ec1:	89 ca                	mov    %ecx,%edx
f0105ec3:	29 de                	sub    %ebx,%esi
f0105ec5:	19 fa                	sbb    %edi,%edx
f0105ec7:	89 d0                	mov    %edx,%eax
f0105ec9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0105ecd:	d3 e0                	shl    %cl,%eax
f0105ecf:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0105ed3:	88 d9                	mov    %bl,%cl
f0105ed5:	d3 ee                	shr    %cl,%esi
f0105ed7:	09 f0                	or     %esi,%eax
f0105ed9:	d3 ea                	shr    %cl,%edx
f0105edb:	83 c4 1c             	add    $0x1c,%esp
f0105ede:	5b                   	pop    %ebx
f0105edf:	5e                   	pop    %esi
f0105ee0:	5f                   	pop    %edi
f0105ee1:	5d                   	pop    %ebp
f0105ee2:	c3                   	ret    
f0105ee3:	90                   	nop
f0105ee4:	39 c6                	cmp    %eax,%esi
f0105ee6:	73 d9                	jae    f0105ec1 <__umoddi3+0xd1>
f0105ee8:	2b 44 24 08          	sub    0x8(%esp),%eax
f0105eec:	19 ea                	sbb    %ebp,%edx
f0105eee:	89 d7                	mov    %edx,%edi
f0105ef0:	89 c3                	mov    %eax,%ebx
f0105ef2:	eb cd                	jmp    f0105ec1 <__umoddi3+0xd1>
