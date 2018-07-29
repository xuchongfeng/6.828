
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
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 f0 c9 19 f0       	mov    $0xf019c9f0,%eax
f010004b:	2d c9 ba 19 f0       	sub    $0xf019bac9,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 c9 ba 19 f0       	push   $0xf019bac9
f0100058:	e8 2c 47 00 00       	call   f0104789 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9a 04 00 00       	call   f01004fc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 4b 10 f0       	push   $0xf0104b80
f010006f:	e8 c1 32 00 00       	call   f0103335 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 d3 11 00 00       	call   f010124c <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 b2 2c 00 00       	call   f0102d30 <env_init>
	trap_init();
f010007e:	e8 2f 33 00 00       	call   f01033b2 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 51 96 13 f0       	push   $0xf0139651
f010008d:	e8 6f 2e 00 00       	call   f0102f01 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 2c bd 19 f0    	pushl  0xf019bd2c
f010009b:	e8 c9 31 00 00       	call   f0103269 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d e0 c9 19 f0 00 	cmpl   $0x0,0xf019c9e0
f01000af:	74 0f                	je     f01000c0 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b1:	83 ec 0c             	sub    $0xc,%esp
f01000b4:	6a 00                	push   $0x0
f01000b6:	e8 7b 08 00 00       	call   f0100936 <monitor>
f01000bb:	83 c4 10             	add    $0x10,%esp
f01000be:	eb f1                	jmp    f01000b1 <_panic+0x11>
{
	va_list ap;

	if (panicstr)
		goto dead;
	panicstr = fmt;
f01000c0:	89 35 e0 c9 19 f0    	mov    %esi,0xf019c9e0

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000c6:	fa                   	cli    
f01000c7:	fc                   	cld    

	va_start(ap, fmt);
f01000c8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000cb:	83 ec 04             	sub    $0x4,%esp
f01000ce:	ff 75 0c             	pushl  0xc(%ebp)
f01000d1:	ff 75 08             	pushl  0x8(%ebp)
f01000d4:	68 9b 4b 10 f0       	push   $0xf0104b9b
f01000d9:	e8 57 32 00 00       	call   f0103335 <cprintf>
	vcprintf(fmt, ap);
f01000de:	83 c4 08             	add    $0x8,%esp
f01000e1:	53                   	push   %ebx
f01000e2:	56                   	push   %esi
f01000e3:	e8 27 32 00 00       	call   f010330f <vcprintf>
	cprintf("\n");
f01000e8:	c7 04 24 a7 5c 10 f0 	movl   $0xf0105ca7,(%esp)
f01000ef:	e8 41 32 00 00       	call   f0103335 <cprintf>
f01000f4:	83 c4 10             	add    $0x10,%esp
f01000f7:	eb b8                	jmp    f01000b1 <_panic+0x11>

f01000f9 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f9:	55                   	push   %ebp
f01000fa:	89 e5                	mov    %esp,%ebp
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100100:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100103:	ff 75 0c             	pushl  0xc(%ebp)
f0100106:	ff 75 08             	pushl  0x8(%ebp)
f0100109:	68 b3 4b 10 f0       	push   $0xf0104bb3
f010010e:	e8 22 32 00 00       	call   f0103335 <cprintf>
	vcprintf(fmt, ap);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	53                   	push   %ebx
f0100117:	ff 75 10             	pushl  0x10(%ebp)
f010011a:	e8 f0 31 00 00       	call   f010330f <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 a7 5c 10 f0 	movl   $0xf0105ca7,(%esp)
f0100126:	e8 0a 32 00 00       	call   f0103335 <cprintf>
	va_end(ap);
}
f010012b:	83 c4 10             	add    $0x10,%esp
f010012e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100131:	c9                   	leave  
f0100132:	c3                   	ret    
	...

f0100134 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100134:	55                   	push   %ebp
f0100135:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100137:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010013c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013d:	a8 01                	test   $0x1,%al
f010013f:	74 0b                	je     f010014c <serial_proc_data+0x18>
f0100141:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100146:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100147:	0f b6 c0             	movzbl %al,%eax
}
f010014a:	5d                   	pop    %ebp
f010014b:	c3                   	ret    

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010014c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100151:	eb f7                	jmp    f010014a <serial_proc_data+0x16>

f0100153 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100153:	55                   	push   %ebp
f0100154:	89 e5                	mov    %esp,%ebp
f0100156:	53                   	push   %ebx
f0100157:	83 ec 04             	sub    $0x4,%esp
f010015a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010015c:	ff d3                	call   *%ebx
f010015e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100161:	74 2d                	je     f0100190 <cons_intr+0x3d>
		if (c == 0)
f0100163:	85 c0                	test   %eax,%eax
f0100165:	74 f5                	je     f010015c <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100167:	8b 0d 04 bd 19 f0    	mov    0xf019bd04,%ecx
f010016d:	8d 51 01             	lea    0x1(%ecx),%edx
f0100170:	89 15 04 bd 19 f0    	mov    %edx,0xf019bd04
f0100176:	88 81 00 bb 19 f0    	mov    %al,-0xfe64500(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010017c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100182:	75 d8                	jne    f010015c <cons_intr+0x9>
			cons.wpos = 0;
f0100184:	c7 05 04 bd 19 f0 00 	movl   $0x0,0xf019bd04
f010018b:	00 00 00 
f010018e:	eb cc                	jmp    f010015c <cons_intr+0x9>
	}
}
f0100190:	83 c4 04             	add    $0x4,%esp
f0100193:	5b                   	pop    %ebx
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	ba 64 00 00 00       	mov    $0x64,%edx
f01001a2:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001a3:	a8 01                	test   $0x1,%al
f01001a5:	0f 84 f1 00 00 00    	je     f010029c <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001ab:	a8 20                	test   $0x20,%al
f01001ad:	0f 85 f0 00 00 00    	jne    f01002a3 <kbd_proc_data+0x10d>
f01001b3:	ba 60 00 00 00       	mov    $0x60,%edx
f01001b8:	ec                   	in     (%dx),%al
f01001b9:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001bb:	3c e0                	cmp    $0xe0,%al
f01001bd:	0f 84 8a 00 00 00    	je     f010024d <kbd_proc_data+0xb7>
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c3:	84 c0                	test   %al,%al
f01001c5:	0f 88 95 00 00 00    	js     f0100260 <kbd_proc_data+0xca>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f01001cb:	8b 0d e0 ba 19 f0    	mov    0xf019bae0,%ecx
f01001d1:	f6 c1 40             	test   $0x40,%cl
f01001d4:	74 0e                	je     f01001e4 <kbd_proc_data+0x4e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001d6:	83 c8 80             	or     $0xffffff80,%eax
f01001d9:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01001db:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001de:	89 0d e0 ba 19 f0    	mov    %ecx,0xf019bae0
	}

	shift |= shiftcode[data];
f01001e4:	0f b6 d2             	movzbl %dl,%edx
f01001e7:	0f b6 82 20 4d 10 f0 	movzbl -0xfefb2e0(%edx),%eax
f01001ee:	0b 05 e0 ba 19 f0    	or     0xf019bae0,%eax
	shift ^= togglecode[data];
f01001f4:	0f b6 8a 20 4c 10 f0 	movzbl -0xfefb3e0(%edx),%ecx
f01001fb:	31 c8                	xor    %ecx,%eax
f01001fd:	a3 e0 ba 19 f0       	mov    %eax,0xf019bae0

	c = charcode[shift & (CTL | SHIFT)][data];
f0100202:	89 c1                	mov    %eax,%ecx
f0100204:	83 e1 03             	and    $0x3,%ecx
f0100207:	8b 0c 8d 00 4c 10 f0 	mov    -0xfefb400(,%ecx,4),%ecx
f010020e:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100211:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100214:	a8 08                	test   $0x8,%al
f0100216:	74 0d                	je     f0100225 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f0100218:	89 da                	mov    %ebx,%edx
f010021a:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010021d:	83 f9 19             	cmp    $0x19,%ecx
f0100220:	77 6d                	ja     f010028f <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100222:	83 eb 20             	sub    $0x20,%ebx
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100225:	f7 d0                	not    %eax
f0100227:	a8 06                	test   $0x6,%al
f0100229:	75 2e                	jne    f0100259 <kbd_proc_data+0xc3>
f010022b:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100231:	75 26                	jne    f0100259 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100233:	83 ec 0c             	sub    $0xc,%esp
f0100236:	68 cd 4b 10 f0       	push   $0xf0104bcd
f010023b:	e8 f5 30 00 00       	call   f0103335 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100240:	b0 03                	mov    $0x3,%al
f0100242:	ba 92 00 00 00       	mov    $0x92,%edx
f0100247:	ee                   	out    %al,(%dx)
f0100248:	83 c4 10             	add    $0x10,%esp
f010024b:	eb 0c                	jmp    f0100259 <kbd_proc_data+0xc3>

	data = inb(KBDATAP);

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
f010024d:	83 0d e0 ba 19 f0 40 	orl    $0x40,0xf019bae0
		return 0;
f0100254:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100259:	89 d8                	mov    %ebx,%eax
f010025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025e:	c9                   	leave  
f010025f:	c3                   	ret    
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100260:	8b 0d e0 ba 19 f0    	mov    0xf019bae0,%ecx
f0100266:	f6 c1 40             	test   $0x40,%cl
f0100269:	75 05                	jne    f0100270 <kbd_proc_data+0xda>
f010026b:	83 e0 7f             	and    $0x7f,%eax
f010026e:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100270:	0f b6 d2             	movzbl %dl,%edx
f0100273:	8a 82 20 4d 10 f0    	mov    -0xfefb2e0(%edx),%al
f0100279:	83 c8 40             	or     $0x40,%eax
f010027c:	0f b6 c0             	movzbl %al,%eax
f010027f:	f7 d0                	not    %eax
f0100281:	21 c8                	and    %ecx,%eax
f0100283:	a3 e0 ba 19 f0       	mov    %eax,0xf019bae0
		return 0;
f0100288:	bb 00 00 00 00       	mov    $0x0,%ebx
f010028d:	eb ca                	jmp    f0100259 <kbd_proc_data+0xc3>

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
f010028f:	83 ea 41             	sub    $0x41,%edx
f0100292:	83 fa 19             	cmp    $0x19,%edx
f0100295:	77 8e                	ja     f0100225 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f0100297:	83 c3 20             	add    $0x20,%ebx
f010029a:	eb 89                	jmp    f0100225 <kbd_proc_data+0x8f>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f010029c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002a1:	eb b6                	jmp    f0100259 <kbd_proc_data+0xc3>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002a3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002a8:	eb af                	jmp    f0100259 <kbd_proc_data+0xc3>

f01002aa <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002aa:	55                   	push   %ebp
f01002ab:	89 e5                	mov    %esp,%ebp
f01002ad:	57                   	push   %edi
f01002ae:	56                   	push   %esi
f01002af:	53                   	push   %ebx
f01002b0:	83 ec 1c             	sub    $0x1c,%esp
f01002b3:	89 c7                	mov    %eax,%edi
f01002b5:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ba:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002bf:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c4:	eb 06                	jmp    f01002cc <cons_putc+0x22>
f01002c6:	89 ca                	mov    %ecx,%edx
f01002c8:	ec                   	in     (%dx),%al
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	89 f2                	mov    %esi,%edx
f01002ce:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002cf:	a8 20                	test   $0x20,%al
f01002d1:	75 03                	jne    f01002d6 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d3:	4b                   	dec    %ebx
f01002d4:	75 f0                	jne    f01002c6 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002d6:	89 f8                	mov    %edi,%eax
f01002d8:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002db:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e0:	ee                   	out    %al,(%dx)
f01002e1:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e6:	be 79 03 00 00       	mov    $0x379,%esi
f01002eb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002f0:	eb 06                	jmp    f01002f8 <cons_putc+0x4e>
f01002f2:	89 ca                	mov    %ecx,%edx
f01002f4:	ec                   	in     (%dx),%al
f01002f5:	ec                   	in     (%dx),%al
f01002f6:	ec                   	in     (%dx),%al
f01002f7:	ec                   	in     (%dx),%al
f01002f8:	89 f2                	mov    %esi,%edx
f01002fa:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002fb:	84 c0                	test   %al,%al
f01002fd:	78 03                	js     f0100302 <cons_putc+0x58>
f01002ff:	4b                   	dec    %ebx
f0100300:	75 f0                	jne    f01002f2 <cons_putc+0x48>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100302:	ba 78 03 00 00       	mov    $0x378,%edx
f0100307:	8a 45 e7             	mov    -0x19(%ebp),%al
f010030a:	ee                   	out    %al,(%dx)
f010030b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100310:	b0 0d                	mov    $0xd,%al
f0100312:	ee                   	out    %al,(%dx)
f0100313:	b0 08                	mov    $0x8,%al
f0100315:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100316:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010031c:	75 06                	jne    f0100324 <cons_putc+0x7a>
		c |= 0x0700;
f010031e:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100324:	89 f8                	mov    %edi,%eax
f0100326:	0f b6 c0             	movzbl %al,%eax
f0100329:	83 f8 09             	cmp    $0x9,%eax
f010032c:	0f 84 b1 00 00 00    	je     f01003e3 <cons_putc+0x139>
f0100332:	83 f8 09             	cmp    $0x9,%eax
f0100335:	7e 70                	jle    f01003a7 <cons_putc+0xfd>
f0100337:	83 f8 0a             	cmp    $0xa,%eax
f010033a:	0f 84 96 00 00 00    	je     f01003d6 <cons_putc+0x12c>
f0100340:	83 f8 0d             	cmp    $0xd,%eax
f0100343:	0f 85 d1 00 00 00    	jne    f010041a <cons_putc+0x170>
		break;
	case '\n':
		crt_pos += CRT_COLS;
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100349:	66 8b 0d 08 bd 19 f0 	mov    0xf019bd08,%cx
f0100350:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100355:	89 c8                	mov    %ecx,%eax
f0100357:	ba 00 00 00 00       	mov    $0x0,%edx
f010035c:	66 f7 f3             	div    %bx
f010035f:	29 d1                	sub    %edx,%ecx
f0100361:	66 89 0d 08 bd 19 f0 	mov    %cx,0xf019bd08
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100368:	66 81 3d 08 bd 19 f0 	cmpw   $0x7cf,0xf019bd08
f010036f:	cf 07 
f0100371:	0f 87 c5 00 00 00    	ja     f010043c <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100377:	8b 0d 10 bd 19 f0    	mov    0xf019bd10,%ecx
f010037d:	b0 0e                	mov    $0xe,%al
f010037f:	89 ca                	mov    %ecx,%edx
f0100381:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100382:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100385:	66 a1 08 bd 19 f0    	mov    0xf019bd08,%ax
f010038b:	66 c1 e8 08          	shr    $0x8,%ax
f010038f:	89 da                	mov    %ebx,%edx
f0100391:	ee                   	out    %al,(%dx)
f0100392:	b0 0f                	mov    $0xf,%al
f0100394:	89 ca                	mov    %ecx,%edx
f0100396:	ee                   	out    %al,(%dx)
f0100397:	a0 08 bd 19 f0       	mov    0xf019bd08,%al
f010039c:	89 da                	mov    %ebx,%edx
f010039e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010039f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003a2:	5b                   	pop    %ebx
f01003a3:	5e                   	pop    %esi
f01003a4:	5f                   	pop    %edi
f01003a5:	5d                   	pop    %ebp
f01003a6:	c3                   	ret    
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;

	switch (c & 0xff) {
f01003a7:	83 f8 08             	cmp    $0x8,%eax
f01003aa:	75 6e                	jne    f010041a <cons_putc+0x170>
	case '\b':
		if (crt_pos > 0) {
f01003ac:	66 a1 08 bd 19 f0    	mov    0xf019bd08,%ax
f01003b2:	66 85 c0             	test   %ax,%ax
f01003b5:	74 c0                	je     f0100377 <cons_putc+0xcd>
			crt_pos--;
f01003b7:	48                   	dec    %eax
f01003b8:	66 a3 08 bd 19 f0    	mov    %ax,0xf019bd08
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003be:	0f b7 c0             	movzwl %ax,%eax
f01003c1:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01003c7:	83 cf 20             	or     $0x20,%edi
f01003ca:	8b 15 0c bd 19 f0    	mov    0xf019bd0c,%edx
f01003d0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003d4:	eb 92                	jmp    f0100368 <cons_putc+0xbe>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003d6:	66 83 05 08 bd 19 f0 	addw   $0x50,0xf019bd08
f01003dd:	50 
f01003de:	e9 66 ff ff ff       	jmp    f0100349 <cons_putc+0x9f>
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
		break;
	case '\t':
		cons_putc(' ');
f01003e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e8:	e8 bd fe ff ff       	call   f01002aa <cons_putc>
		cons_putc(' ');
f01003ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f2:	e8 b3 fe ff ff       	call   f01002aa <cons_putc>
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 a9 fe ff ff       	call   f01002aa <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 9f fe ff ff       	call   f01002aa <cons_putc>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 95 fe ff ff       	call   f01002aa <cons_putc>
f0100415:	e9 4e ff ff ff       	jmp    f0100368 <cons_putc+0xbe>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010041a:	66 a1 08 bd 19 f0    	mov    0xf019bd08,%ax
f0100420:	8d 50 01             	lea    0x1(%eax),%edx
f0100423:	66 89 15 08 bd 19 f0 	mov    %dx,0xf019bd08
f010042a:	0f b7 c0             	movzwl %ax,%eax
f010042d:	8b 15 0c bd 19 f0    	mov    0xf019bd0c,%edx
f0100433:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100437:	e9 2c ff ff ff       	jmp    f0100368 <cons_putc+0xbe>

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010043c:	a1 0c bd 19 f0       	mov    0xf019bd0c,%eax
f0100441:	83 ec 04             	sub    $0x4,%esp
f0100444:	68 00 0f 00 00       	push   $0xf00
f0100449:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010044f:	52                   	push   %edx
f0100450:	50                   	push   %eax
f0100451:	e8 80 43 00 00       	call   f01047d6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100456:	8b 15 0c bd 19 f0    	mov    0xf019bd0c,%edx
f010045c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100462:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100468:	83 c4 10             	add    $0x10,%esp
f010046b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100470:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100473:	39 d0                	cmp    %edx,%eax
f0100475:	75 f4                	jne    f010046b <cons_putc+0x1c1>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100477:	66 83 2d 08 bd 19 f0 	subw   $0x50,0xf019bd08
f010047e:	50 
f010047f:	e9 f3 fe ff ff       	jmp    f0100377 <cons_putc+0xcd>

f0100484 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100484:	80 3d 14 bd 19 f0 00 	cmpb   $0x0,0xf019bd14
f010048b:	75 01                	jne    f010048e <serial_intr+0xa>
f010048d:	c3                   	ret    
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010048e:	55                   	push   %ebp
f010048f:	89 e5                	mov    %esp,%ebp
f0100491:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100494:	b8 34 01 10 f0       	mov    $0xf0100134,%eax
f0100499:	e8 b5 fc ff ff       	call   f0100153 <cons_intr>
}
f010049e:	c9                   	leave  
f010049f:	c3                   	ret    

f01004a0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a6:	b8 96 01 10 f0       	mov    $0xf0100196,%eax
f01004ab:	e8 a3 fc ff ff       	call   f0100153 <cons_intr>
}
f01004b0:	c9                   	leave  
f01004b1:	c3                   	ret    

f01004b2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b2:	55                   	push   %ebp
f01004b3:	89 e5                	mov    %esp,%ebp
f01004b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b8:	e8 c7 ff ff ff       	call   f0100484 <serial_intr>
	kbd_intr();
f01004bd:	e8 de ff ff ff       	call   f01004a0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c2:	a1 00 bd 19 f0       	mov    0xf019bd00,%eax
f01004c7:	3b 05 04 bd 19 f0    	cmp    0xf019bd04,%eax
f01004cd:	74 26                	je     f01004f5 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cf:	8d 50 01             	lea    0x1(%eax),%edx
f01004d2:	89 15 00 bd 19 f0    	mov    %edx,0xf019bd00
f01004d8:	0f b6 80 00 bb 19 f0 	movzbl -0xfe64500(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01004df:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e5:	74 02                	je     f01004e9 <cons_getc+0x37>
			cons.rpos = 0;
		return c;
	}
	return 0;
}
f01004e7:	c9                   	leave  
f01004e8:	c3                   	ret    

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004e9:	c7 05 00 bd 19 f0 00 	movl   $0x0,0xf019bd00
f01004f0:	00 00 00 
f01004f3:	eb f2                	jmp    f01004e7 <cons_getc+0x35>
		return c;
	}
	return 0;
f01004f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004fa:	eb eb                	jmp    f01004e7 <cons_getc+0x35>

f01004fc <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004fc:	55                   	push   %ebp
f01004fd:	89 e5                	mov    %esp,%ebp
f01004ff:	57                   	push   %edi
f0100500:	56                   	push   %esi
f0100501:	53                   	push   %ebx
f0100502:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100505:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010050c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100513:	5a a5 
	if (*cp != 0xA55A) {
f0100515:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010051b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051f:	0f 84 a2 00 00 00    	je     f01005c7 <cons_init+0xcb>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 10 bd 19 f0 b4 	movl   $0x3b4,0xf019bd10
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100534:	8b 3d 10 bd 19 f0    	mov    0xf019bd10,%edi
f010053a:	b0 0e                	mov    $0xe,%al
f010053c:	89 fa                	mov    %edi,%edx
f010053e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010053f:	8d 4f 01             	lea    0x1(%edi),%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100542:	89 ca                	mov    %ecx,%edx
f0100544:	ec                   	in     (%dx),%al
f0100545:	0f b6 c0             	movzbl %al,%eax
f0100548:	c1 e0 08             	shl    $0x8,%eax
f010054b:	89 c3                	mov    %eax,%ebx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010054d:	b0 0f                	mov    $0xf,%al
f010054f:	89 fa                	mov    %edi,%edx
f0100551:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100552:	89 ca                	mov    %ecx,%edx
f0100554:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100555:	89 35 0c bd 19 f0    	mov    %esi,0xf019bd0c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010055b:	0f b6 c0             	movzbl %al,%eax
f010055e:	09 d8                	or     %ebx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100560:	66 a3 08 bd 19 f0    	mov    %ax,0xf019bd08
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b1 00                	mov    $0x0,%cl
f0100568:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010056d:	88 c8                	mov    %cl,%al
f010056f:	89 da                	mov    %ebx,%edx
f0100571:	ee                   	out    %al,(%dx)
f0100572:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100577:	b0 80                	mov    $0x80,%al
f0100579:	89 fa                	mov    %edi,%edx
f010057b:	ee                   	out    %al,(%dx)
f010057c:	b0 0c                	mov    $0xc,%al
f010057e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100583:	ee                   	out    %al,(%dx)
f0100584:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100589:	88 c8                	mov    %cl,%al
f010058b:	89 f2                	mov    %esi,%edx
f010058d:	ee                   	out    %al,(%dx)
f010058e:	b0 03                	mov    $0x3,%al
f0100590:	89 fa                	mov    %edi,%edx
f0100592:	ee                   	out    %al,(%dx)
f0100593:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100598:	88 c8                	mov    %cl,%al
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b0 01                	mov    $0x1,%al
f010059d:	89 f2                	mov    %esi,%edx
f010059f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005a5:	ec                   	in     (%dx),%al
f01005a6:	88 c1                	mov    %al,%cl
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005a8:	3c ff                	cmp    $0xff,%al
f01005aa:	0f 95 05 14 bd 19 f0 	setne  0xf019bd14
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005b9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ba:	80 f9 ff             	cmp    $0xff,%cl
f01005bd:	74 23                	je     f01005e2 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005c7:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005ce:	c7 05 10 bd 19 f0 d4 	movl   $0x3d4,0xf019bd10
f01005d5:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005d8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01005dd:	e9 52 ff ff ff       	jmp    f0100534 <cons_init+0x38>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f01005e2:	83 ec 0c             	sub    $0xc,%esp
f01005e5:	68 d9 4b 10 f0       	push   $0xf0104bd9
f01005ea:	e8 46 2d 00 00       	call   f0103335 <cprintf>
f01005ef:	83 c4 10             	add    $0x10,%esp
}
f01005f2:	eb cb                	jmp    f01005bf <cons_init+0xc3>

f01005f4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f4:	55                   	push   %ebp
f01005f5:	89 e5                	mov    %esp,%ebp
f01005f7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fd:	e8 a8 fc ff ff       	call   f01002aa <cons_putc>
}
f0100602:	c9                   	leave  
f0100603:	c3                   	ret    

f0100604 <getchar>:

int
getchar(void)
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010060a:	e8 a3 fe ff ff       	call   f01004b2 <cons_getc>
f010060f:	85 c0                	test   %eax,%eax
f0100611:	74 f7                	je     f010060a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100613:	c9                   	leave  
f0100614:	c3                   	ret    

f0100615 <iscons>:

int
iscons(int fdnum)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100618:	b8 01 00 00 00       	mov    $0x1,%eax
f010061d:	5d                   	pop    %ebp
f010061e:	c3                   	ret    
	...

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	68 20 4e 10 f0       	push   $0xf0104e20
f010062b:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0100630:	68 43 4e 10 f0       	push   $0xf0104e43
f0100635:	e8 fb 2c 00 00       	call   f0103335 <cprintf>
f010063a:	83 c4 0c             	add    $0xc,%esp
f010063d:	68 14 4f 10 f0       	push   $0xf0104f14
f0100642:	68 4c 4e 10 f0       	push   $0xf0104e4c
f0100647:	68 43 4e 10 f0       	push   $0xf0104e43
f010064c:	e8 e4 2c 00 00       	call   f0103335 <cprintf>
f0100651:	83 c4 0c             	add    $0xc,%esp
f0100654:	68 3c 4f 10 f0       	push   $0xf0104f3c
f0100659:	68 55 4e 10 f0       	push   $0xf0104e55
f010065e:	68 43 4e 10 f0       	push   $0xf0104e43
f0100663:	e8 cd 2c 00 00       	call   f0103335 <cprintf>
f0100668:	83 c4 0c             	add    $0xc,%esp
f010066b:	68 64 4f 10 f0       	push   $0xf0104f64
f0100670:	68 5f 4e 10 f0       	push   $0xf0104e5f
f0100675:	68 43 4e 10 f0       	push   $0xf0104e43
f010067a:	e8 b6 2c 00 00       	call   f0103335 <cprintf>
	return 0;
}
f010067f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100684:	c9                   	leave  
f0100685:	c3                   	ret    

f0100686 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068c:	68 6c 4e 10 f0       	push   $0xf0104e6c
f0100691:	e8 9f 2c 00 00       	call   f0103335 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100696:	83 c4 08             	add    $0x8,%esp
f0100699:	68 0c 00 10 00       	push   $0x10000c
f010069e:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01006a3:	e8 8d 2c 00 00       	call   f0103335 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a8:	83 c4 0c             	add    $0xc,%esp
f01006ab:	68 0c 00 10 00       	push   $0x10000c
f01006b0:	68 0c 00 10 f0       	push   $0xf010000c
f01006b5:	68 cc 4f 10 f0       	push   $0xf0104fcc
f01006ba:	e8 76 2c 00 00       	call   f0103335 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006bf:	83 c4 0c             	add    $0xc,%esp
f01006c2:	68 70 4b 10 00       	push   $0x104b70
f01006c7:	68 70 4b 10 f0       	push   $0xf0104b70
f01006cc:	68 f0 4f 10 f0       	push   $0xf0104ff0
f01006d1:	e8 5f 2c 00 00       	call   f0103335 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d6:	83 c4 0c             	add    $0xc,%esp
f01006d9:	68 c9 ba 19 00       	push   $0x19bac9
f01006de:	68 c9 ba 19 f0       	push   $0xf019bac9
f01006e3:	68 14 50 10 f0       	push   $0xf0105014
f01006e8:	e8 48 2c 00 00       	call   f0103335 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ed:	83 c4 0c             	add    $0xc,%esp
f01006f0:	68 f0 c9 19 00       	push   $0x19c9f0
f01006f5:	68 f0 c9 19 f0       	push   $0xf019c9f0
f01006fa:	68 38 50 10 f0       	push   $0xf0105038
f01006ff:	e8 31 2c 00 00       	call   f0103335 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100704:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100707:	b8 ef cd 19 f0       	mov    $0xf019cdef,%eax
f010070c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100711:	c1 f8 0a             	sar    $0xa,%eax
f0100714:	50                   	push   %eax
f0100715:	68 5c 50 10 f0       	push   $0xf010505c
f010071a:	e8 16 2c 00 00       	call   f0103335 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010071f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100724:	c9                   	leave  
f0100725:	c3                   	ret    

f0100726 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100726:	55                   	push   %ebp
f0100727:	89 e5                	mov    %esp,%ebp
f0100729:	57                   	push   %edi
f010072a:	56                   	push   %esi
f010072b:	53                   	push   %ebx
f010072c:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010072f:	89 eb                	mov    %ebp,%ebx
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
f0100731:	68 85 4e 10 f0       	push   $0xf0104e85
f0100736:	e8 fa 2b 00 00       	call   f0103335 <cprintf>
    while (ebp != 0) {
f010073b:	83 c4 10             	add    $0x10,%esp
        ptr_ebp = (uint32_t*) ebp;
        cprintf("\tebp %x eip %x args %08x %08x %08x %08x %08x\n",
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f010073e:	8d 7d d0             	lea    -0x30(%ebp),%edi
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
    while (ebp != 0) {
f0100741:	eb 02                	jmp    f0100745 <mon_backtrace+0x1f>
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
			cprintf("\t\t %s:%d: %.*s+%d\n",
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ptr_ebp[1] - info.eip_fn_addr);
		}
		ebp = *ptr_ebp;
f0100743:	8b 1e                	mov    (%esi),%ebx
	// Your code here.
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
	ebp = read_ebp();
    cprintf("Stack backtrace:\n");
    while (ebp != 0) {
f0100745:	85 db                	test   %ebx,%ebx
f0100747:	74 57                	je     f01007a0 <mon_backtrace+0x7a>
        ptr_ebp = (uint32_t*) ebp;
f0100749:	89 de                	mov    %ebx,%esi
        cprintf("\tebp %x eip %x args %08x %08x %08x %08x %08x\n",
f010074b:	ff 73 18             	pushl  0x18(%ebx)
f010074e:	ff 73 14             	pushl  0x14(%ebx)
f0100751:	ff 73 10             	pushl  0x10(%ebx)
f0100754:	ff 73 0c             	pushl  0xc(%ebx)
f0100757:	ff 73 08             	pushl  0x8(%ebx)
f010075a:	ff 73 04             	pushl  0x4(%ebx)
f010075d:	53                   	push   %ebx
f010075e:	68 88 50 10 f0       	push   $0xf0105088
f0100763:	e8 cd 2b 00 00       	call   f0103335 <cprintf>
			ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100768:	83 c4 18             	add    $0x18,%esp
f010076b:	57                   	push   %edi
f010076c:	ff 73 04             	pushl  0x4(%ebx)
f010076f:	e8 7d 35 00 00       	call   f0103cf1 <debuginfo_eip>
f0100774:	83 c4 10             	add    $0x10,%esp
f0100777:	85 c0                	test   %eax,%eax
f0100779:	75 c8                	jne    f0100743 <mon_backtrace+0x1d>
			cprintf("\t\t %s:%d: %.*s+%d\n",
f010077b:	83 ec 08             	sub    $0x8,%esp
f010077e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100781:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100784:	50                   	push   %eax
f0100785:	ff 75 d8             	pushl  -0x28(%ebp)
f0100788:	ff 75 dc             	pushl  -0x24(%ebp)
f010078b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010078e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100791:	68 97 4e 10 f0       	push   $0xf0104e97
f0100796:	e8 9a 2b 00 00       	call   f0103335 <cprintf>
f010079b:	83 c4 20             	add    $0x20,%esp
f010079e:	eb a3                	jmp    f0100743 <mon_backtrace+0x1d>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ptr_ebp[1] - info.eip_fn_addr);
		}
		ebp = *ptr_ebp;
    }
    return 0;
}
f01007a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a8:	5b                   	pop    %ebx
f01007a9:	5e                   	pop    %esi
f01007aa:	5f                   	pop    %edi
f01007ab:	5d                   	pop    %ebp
f01007ac:	c3                   	ret    

f01007ad <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	57                   	push   %edi
f01007b1:	56                   	push   %esi
f01007b2:	53                   	push   %ebx
f01007b3:	83 ec 1c             	sub    $0x1c,%esp
f01007b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc != 3) {
f01007b9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01007bd:	75 55                	jne    f0100814 <mon_showmappings+0x67>
		cprintf("Require 2 virtual address as arguments.\n");
		return -1;
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
f01007bf:	83 ec 04             	sub    $0x4,%esp
f01007c2:	6a 10                	push   $0x10
f01007c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01007c7:	50                   	push   %eax
f01007c8:	ff 76 04             	pushl  0x4(%esi)
f01007cb:	e8 cd 40 00 00       	call   f010489d <strtol>
f01007d0:	89 c3                	mov    %eax,%ebx
	if (*errChar) {
f01007d2:	83 c4 10             	add    $0x10,%esp
f01007d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007d8:	80 38 00             	cmpb   $0x0,(%eax)
f01007db:	75 51                	jne    f010082e <mon_showmappings+0x81>
		cprintf("Invalid virtual address: %s.\n", argv[1]);
		return -1;
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
f01007dd:	83 ec 04             	sub    $0x4,%esp
f01007e0:	6a 10                	push   $0x10
f01007e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01007e5:	50                   	push   %eax
f01007e6:	ff 76 08             	pushl  0x8(%esi)
f01007e9:	e8 af 40 00 00       	call   f010489d <strtol>
	if (*errChar) {
f01007ee:	83 c4 10             	add    $0x10,%esp
f01007f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01007f4:	80 3a 00             	cmpb   $0x0,(%edx)
f01007f7:	75 52                	jne    f010084b <mon_showmappings+0x9e>
		cprintf("Invalid virtual address: %s.\n", argv[2]);
		return -1;
	}
	if (start_addr > end_addr) {
f01007f9:	39 c3                	cmp    %eax,%ebx
f01007fb:	77 6b                	ja     f0100868 <mon_showmappings+0xbb>
		cprintf("Address 1 must be lower than address 2\n");
		return -1;
	}

	start_addr = ROUNDDOWN(start_addr, PGSIZE);
f01007fd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end_addr = ROUNDUP(end_addr, PGSIZE);
f0100803:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100809:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f010080f:	e9 85 00 00 00       	jmp    f0100899 <mon_showmappings+0xec>

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if (argc != 3) {
		cprintf("Require 2 virtual address as arguments.\n");
f0100814:	83 ec 0c             	sub    $0xc,%esp
f0100817:	68 b8 50 10 f0       	push   $0xf01050b8
f010081c:	e8 14 2b 00 00       	call   f0103335 <cprintf>
		return -1;
f0100821:	83 c4 10             	add    $0x10,%esp
f0100824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100829:	e9 00 01 00 00       	jmp    f010092e <mon_showmappings+0x181>
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[1]);
f010082e:	83 ec 08             	sub    $0x8,%esp
f0100831:	ff 76 04             	pushl  0x4(%esi)
f0100834:	68 aa 4e 10 f0       	push   $0xf0104eaa
f0100839:	e8 f7 2a 00 00       	call   f0103335 <cprintf>
		return -1;
f010083e:	83 c4 10             	add    $0x10,%esp
f0100841:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100846:	e9 e3 00 00 00       	jmp    f010092e <mon_showmappings+0x181>
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[2]);
f010084b:	83 ec 08             	sub    $0x8,%esp
f010084e:	ff 76 08             	pushl  0x8(%esi)
f0100851:	68 aa 4e 10 f0       	push   $0xf0104eaa
f0100856:	e8 da 2a 00 00       	call   f0103335 <cprintf>
		return -1;
f010085b:	83 c4 10             	add    $0x10,%esp
f010085e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100863:	e9 c6 00 00 00       	jmp    f010092e <mon_showmappings+0x181>
	}
	if (start_addr > end_addr) {
		cprintf("Address 1 must be lower than address 2\n");
f0100868:	83 ec 0c             	sub    $0xc,%esp
f010086b:	68 e4 50 10 f0       	push   $0xf01050e4
f0100870:	e8 c0 2a 00 00       	call   f0103335 <cprintf>
		return -1;
f0100875:	83 c4 10             	add    $0x10,%esp
f0100878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010087d:	e9 ac 00 00 00       	jmp    f010092e <mon_showmappings+0x181>
	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
		// if ( !cur_pte) {
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
f0100882:	83 ec 08             	sub    $0x8,%esp
f0100885:	53                   	push   %ebx
f0100886:	68 0c 51 10 f0       	push   $0xf010510c
f010088b:	e8 a5 2a 00 00       	call   f0103335 <cprintf>
f0100890:	83 c4 10             	add    $0x10,%esp
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
			// 进入 else 分支说明 PTE_P 肯定为真了
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
		}
		cur_addr += PGSIZE;
f0100893:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	start_addr = ROUNDDOWN(start_addr, PGSIZE);
	end_addr = ROUNDUP(end_addr, PGSIZE);

	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f0100899:	39 fb                	cmp    %edi,%ebx
f010089b:	0f 87 88 00 00 00    	ja     f0100929 <mon_showmappings+0x17c>
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
f01008a1:	83 ec 04             	sub    $0x4,%esp
f01008a4:	6a 00                	push   $0x0
f01008a6:	53                   	push   %ebx
f01008a7:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f01008ad:	e8 5b 07 00 00       	call   f010100d <pgdir_walk>
f01008b2:	89 c6                	mov    %eax,%esi
		// if ( !cur_pte) {
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
f01008b4:	83 c4 10             	add    $0x10,%esp
f01008b7:	85 c0                	test   %eax,%eax
f01008b9:	74 c7                	je     f0100882 <mon_showmappings+0xd5>
f01008bb:	8b 00                	mov    (%eax),%eax
f01008bd:	a8 01                	test   $0x1,%al
f01008bf:	74 c1                	je     f0100882 <mon_showmappings+0xd5>
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
		} else {
			cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
f01008c1:	83 ec 04             	sub    $0x4,%esp
f01008c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008c9:	50                   	push   %eax
f01008ca:	53                   	push   %ebx
f01008cb:	68 34 51 10 f0       	push   $0xf0105134
f01008d0:	e8 60 2a 00 00       	call   f0103335 <cprintf>
			char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
f01008d5:	8b 06                	mov    (%esi),%eax
f01008d7:	83 c4 10             	add    $0x10,%esp
f01008da:	89 c2                	mov    %eax,%edx
f01008dc:	81 e2 80 00 00 00    	and    $0x80,%edx
f01008e2:	83 fa 01             	cmp    $0x1,%edx
f01008e5:	19 d2                	sbb    %edx,%edx
f01008e7:	83 e2 da             	and    $0xffffffda,%edx
f01008ea:	83 c2 53             	add    $0x53,%edx
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
f01008ed:	89 c1                	mov    %eax,%ecx
f01008ef:	83 e1 02             	and    $0x2,%ecx
f01008f2:	83 f9 01             	cmp    $0x1,%ecx
f01008f5:	19 c9                	sbb    %ecx,%ecx
f01008f7:	83 e1 d6             	and    $0xffffffd6,%ecx
f01008fa:	83 c1 57             	add    $0x57,%ecx
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
f01008fd:	83 e0 04             	and    $0x4,%eax
f0100900:	83 f8 01             	cmp    $0x1,%eax
f0100903:	19 c0                	sbb    %eax,%eax
f0100905:	83 e0 d8             	and    $0xffffffd8,%eax
f0100908:	83 c0 55             	add    $0x55,%eax
			// 进入 else 分支说明 PTE_P 肯定为真了
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
f010090b:	0f be c9             	movsbl %cl,%ecx
f010090e:	51                   	push   %ecx
f010090f:	0f be c0             	movsbl %al,%eax
f0100912:	50                   	push   %eax
f0100913:	0f be d2             	movsbl %dl,%edx
f0100916:	52                   	push   %edx
f0100917:	68 c8 4e 10 f0       	push   $0xf0104ec8
f010091c:	e8 14 2a 00 00       	call   f0103335 <cprintf>
f0100921:	83 c4 10             	add    $0x10,%esp
f0100924:	e9 6a ff ff ff       	jmp    f0100893 <mon_showmappings+0xe6>
		}
		cur_addr += PGSIZE;
	}
	return 0;
f0100929:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010092e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100931:	5b                   	pop    %ebx
f0100932:	5e                   	pop    %esi
f0100933:	5f                   	pop    %edi
f0100934:	5d                   	pop    %ebp
f0100935:	c3                   	ret    

f0100936 <monitor>:



void
monitor(struct Trapframe *tf)
{
f0100936:	55                   	push   %ebp
f0100937:	89 e5                	mov    %esp,%ebp
f0100939:	57                   	push   %edi
f010093a:	56                   	push   %esi
f010093b:	53                   	push   %ebx
f010093c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093f:	68 74 51 10 f0       	push   $0xf0105174
f0100944:	e8 ec 29 00 00       	call   f0103335 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100949:	c7 04 24 98 51 10 f0 	movl   $0xf0105198,(%esp)
f0100950:	e8 e0 29 00 00       	call   f0103335 <cprintf>

	if (tf != NULL)
f0100955:	83 c4 10             	add    $0x10,%esp
f0100958:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010095c:	74 57                	je     f01009b5 <monitor+0x7f>
		print_trapframe(tf);
f010095e:	83 ec 0c             	sub    $0xc,%esp
f0100961:	ff 75 08             	pushl  0x8(%ebp)
f0100964:	e8 12 2e 00 00       	call   f010377b <print_trapframe>
f0100969:	83 c4 10             	add    $0x10,%esp
f010096c:	eb 47                	jmp    f01009b5 <monitor+0x7f>
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010096e:	83 ec 08             	sub    $0x8,%esp
f0100971:	0f be c0             	movsbl %al,%eax
f0100974:	50                   	push   %eax
f0100975:	68 da 4e 10 f0       	push   $0xf0104eda
f010097a:	e8 d5 3d 00 00       	call   f0104754 <strchr>
f010097f:	83 c4 10             	add    $0x10,%esp
f0100982:	85 c0                	test   %eax,%eax
f0100984:	74 0a                	je     f0100990 <monitor+0x5a>
			*buf++ = 0;
f0100986:	c6 03 00             	movb   $0x0,(%ebx)
f0100989:	89 f7                	mov    %esi,%edi
f010098b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010098e:	eb 68                	jmp    f01009f8 <monitor+0xc2>
		if (*buf == 0)
f0100990:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100993:	74 6f                	je     f0100a04 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100995:	83 fe 0f             	cmp    $0xf,%esi
f0100998:	74 09                	je     f01009a3 <monitor+0x6d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f010099a:	8d 7e 01             	lea    0x1(%esi),%edi
f010099d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009a1:	eb 37                	jmp    f01009da <monitor+0xa4>
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009a3:	83 ec 08             	sub    $0x8,%esp
f01009a6:	6a 10                	push   $0x10
f01009a8:	68 df 4e 10 f0       	push   $0xf0104edf
f01009ad:	e8 83 29 00 00       	call   f0103335 <cprintf>
f01009b2:	83 c4 10             	add    $0x10,%esp

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
f01009b5:	83 ec 0c             	sub    $0xc,%esp
f01009b8:	68 d6 4e 10 f0       	push   $0xf0104ed6
f01009bd:	e8 86 3b 00 00       	call   f0104548 <readline>
f01009c2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009c4:	83 c4 10             	add    $0x10,%esp
f01009c7:	85 c0                	test   %eax,%eax
f01009c9:	74 ea                	je     f01009b5 <monitor+0x7f>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009cb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009d2:	be 00 00 00 00       	mov    $0x0,%esi
f01009d7:	eb 21                	jmp    f01009fa <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009d9:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009da:	8a 03                	mov    (%ebx),%al
f01009dc:	84 c0                	test   %al,%al
f01009de:	74 18                	je     f01009f8 <monitor+0xc2>
f01009e0:	83 ec 08             	sub    $0x8,%esp
f01009e3:	0f be c0             	movsbl %al,%eax
f01009e6:	50                   	push   %eax
f01009e7:	68 da 4e 10 f0       	push   $0xf0104eda
f01009ec:	e8 63 3d 00 00       	call   f0104754 <strchr>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	85 c0                	test   %eax,%eax
f01009f6:	74 e1                	je     f01009d9 <monitor+0xa3>
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009f8:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009fa:	8a 03                	mov    (%ebx),%al
f01009fc:	84 c0                	test   %al,%al
f01009fe:	0f 85 6a ff ff ff    	jne    f010096e <monitor+0x38>
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f0100a04:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a0b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a0c:	85 f6                	test   %esi,%esi
f0100a0e:	74 a5                	je     f01009b5 <monitor+0x7f>
f0100a10:	bf c0 51 10 f0       	mov    $0xf01051c0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a15:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a1a:	83 ec 08             	sub    $0x8,%esp
f0100a1d:	ff 37                	pushl  (%edi)
f0100a1f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a22:	e8 d9 3c 00 00       	call   f0104700 <strcmp>
f0100a27:	83 c4 10             	add    $0x10,%esp
f0100a2a:	85 c0                	test   %eax,%eax
f0100a2c:	74 21                	je     f0100a4f <monitor+0x119>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a2e:	43                   	inc    %ebx
f0100a2f:	83 c7 0c             	add    $0xc,%edi
f0100a32:	83 fb 04             	cmp    $0x4,%ebx
f0100a35:	75 e3                	jne    f0100a1a <monitor+0xe4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a37:	83 ec 08             	sub    $0x8,%esp
f0100a3a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a3d:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100a42:	e8 ee 28 00 00       	call   f0103335 <cprintf>
f0100a47:	83 c4 10             	add    $0x10,%esp
f0100a4a:	e9 66 ff ff ff       	jmp    f01009b5 <monitor+0x7f>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100a4f:	83 ec 04             	sub    $0x4,%esp
f0100a52:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100a55:	01 c3                	add    %eax,%ebx
f0100a57:	ff 75 08             	pushl  0x8(%ebp)
f0100a5a:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a5d:	50                   	push   %eax
f0100a5e:	56                   	push   %esi
f0100a5f:	ff 14 9d c8 51 10 f0 	call   *-0xfefae38(,%ebx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a66:	83 c4 10             	add    $0x10,%esp
f0100a69:	85 c0                	test   %eax,%eax
f0100a6b:	0f 89 44 ff ff ff    	jns    f01009b5 <monitor+0x7f>
				break;
	}
}
f0100a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a74:	5b                   	pop    %ebx
f0100a75:	5e                   	pop    %esi
f0100a76:	5f                   	pop    %edi
f0100a77:	5d                   	pop    %ebp
f0100a78:	c3                   	ret    
f0100a79:	00 00                	add    %al,(%eax)
	...

f0100a7c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a7c:	55                   	push   %ebp
f0100a7d:	89 e5                	mov    %esp,%ebp
f0100a7f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a81:	83 3d 18 bd 19 f0 00 	cmpl   $0x0,0xf019bd18
f0100a88:	74 1f                	je     f0100aa9 <boot_alloc+0x2d>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    if (n == 0) {
f0100a8a:	85 d2                	test   %edx,%edx
f0100a8c:	74 2c                	je     f0100aba <boot_alloc+0x3e>
		return nextfree;
	}
	result = nextfree;
f0100a8e:	a1 18 bd 19 f0       	mov    0xf019bd18,%eax
    nextfree += ROUNDUP(n, PGSIZE);
f0100a93:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a99:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a9f:	01 c2                	add    %eax,%edx
f0100aa1:	89 15 18 bd 19 f0    	mov    %edx,0xf019bd18

	return result;
}
f0100aa7:	5d                   	pop    %ebp
f0100aa8:	c3                   	ret    
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
		extern char end[]; // end point to the end of bss seg
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa9:	b8 ef d9 19 f0       	mov    $0xf019d9ef,%eax
f0100aae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab3:	a3 18 bd 19 f0       	mov    %eax,0xf019bd18
f0100ab8:	eb d0                	jmp    f0100a8a <boot_alloc+0xe>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    if (n == 0) {
		return nextfree;
f0100aba:	a1 18 bd 19 f0       	mov    0xf019bd18,%eax
f0100abf:	eb e6                	jmp    f0100aa7 <boot_alloc+0x2b>

f0100ac1 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ac1:	55                   	push   %ebp
f0100ac2:	89 e5                	mov    %esp,%ebp
f0100ac4:	56                   	push   %esi
f0100ac5:	53                   	push   %ebx
f0100ac6:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac8:	83 ec 0c             	sub    $0xc,%esp
f0100acb:	50                   	push   %eax
f0100acc:	e8 fb 27 00 00       	call   f01032cc <mc146818_read>
f0100ad1:	89 c3                	mov    %eax,%ebx
f0100ad3:	46                   	inc    %esi
f0100ad4:	89 34 24             	mov    %esi,(%esp)
f0100ad7:	e8 f0 27 00 00       	call   f01032cc <mc146818_read>
f0100adc:	c1 e0 08             	shl    $0x8,%eax
f0100adf:	09 d8                	or     %ebx,%eax
}
f0100ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae4:	5b                   	pop    %ebx
f0100ae5:	5e                   	pop    %esi
f0100ae6:	5d                   	pop    %ebp
f0100ae7:	c3                   	ret    

f0100ae8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ae8:	89 d1                	mov    %edx,%ecx
f0100aea:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100aed:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af0:	a8 01                	test   $0x1,%al
f0100af2:	74 47                	je     f0100b3b <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100af4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af9:	89 c1                	mov    %eax,%ecx
f0100afb:	c1 e9 0c             	shr    $0xc,%ecx
f0100afe:	3b 0d e4 c9 19 f0    	cmp    0xf019c9e4,%ecx
f0100b04:	73 1a                	jae    f0100b20 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100b06:	c1 ea 0c             	shr    $0xc,%edx
f0100b09:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b0f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b16:	a8 01                	test   $0x1,%al
f0100b18:	74 27                	je     f0100b41 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b1f:	c3                   	ret    
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
f0100b23:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b26:	50                   	push   %eax
f0100b27:	68 f0 51 10 f0       	push   $0xf01051f0
f0100b2c:	68 40 03 00 00       	push   $0x340
f0100b31:	68 d1 59 10 f0       	push   $0xf01059d1
f0100b36:	e8 65 f5 ff ff       	call   f01000a0 <_panic>
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b40:	c3                   	ret    
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100b41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b46:	c3                   	ret    

f0100b47 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b47:	55                   	push   %ebp
f0100b48:	89 e5                	mov    %esp,%ebp
f0100b4a:	57                   	push   %edi
f0100b4b:	56                   	push   %esi
f0100b4c:	53                   	push   %ebx
f0100b4d:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b50:	84 c0                	test   %al,%al
f0100b52:	0f 85 50 02 00 00    	jne    f0100da8 <check_page_free_list+0x261>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b58:	83 3d 20 bd 19 f0 00 	cmpl   $0x0,0xf019bd20
f0100b5f:	74 0a                	je     f0100b6b <check_page_free_list+0x24>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b61:	be 00 04 00 00       	mov    $0x400,%esi
f0100b66:	e9 98 02 00 00       	jmp    f0100e03 <check_page_free_list+0x2bc>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b6b:	83 ec 04             	sub    $0x4,%esp
f0100b6e:	68 14 52 10 f0       	push   $0xf0105214
f0100b73:	68 7c 02 00 00       	push   $0x27c
f0100b78:	68 d1 59 10 f0       	push   $0xf01059d1
f0100b7d:	e8 1e f5 ff ff       	call   f01000a0 <_panic>
f0100b82:	50                   	push   %eax
f0100b83:	68 f0 51 10 f0       	push   $0xf01051f0
f0100b88:	6a 56                	push   $0x56
f0100b8a:	68 dd 59 10 f0       	push   $0xf01059dd
f0100b8f:	e8 0c f5 ff ff       	call   f01000a0 <_panic>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b94:	8b 1b                	mov    (%ebx),%ebx
f0100b96:	85 db                	test   %ebx,%ebx
f0100b98:	74 41                	je     f0100bdb <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b9a:	89 d8                	mov    %ebx,%eax
f0100b9c:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0100ba2:	c1 f8 03             	sar    $0x3,%eax
f0100ba5:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ba8:	89 c2                	mov    %eax,%edx
f0100baa:	c1 ea 16             	shr    $0x16,%edx
f0100bad:	39 f2                	cmp    %esi,%edx
f0100baf:	73 e3                	jae    f0100b94 <check_page_free_list+0x4d>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb1:	89 c2                	mov    %eax,%edx
f0100bb3:	c1 ea 0c             	shr    $0xc,%edx
f0100bb6:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f0100bbc:	73 c4                	jae    f0100b82 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bbe:	83 ec 04             	sub    $0x4,%esp
f0100bc1:	68 80 00 00 00       	push   $0x80
f0100bc6:	68 97 00 00 00       	push   $0x97
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100bcb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd0:	50                   	push   %eax
f0100bd1:	e8 b3 3b 00 00       	call   f0104789 <memset>
f0100bd6:	83 c4 10             	add    $0x10,%esp
f0100bd9:	eb b9                	jmp    f0100b94 <check_page_free_list+0x4d>

	first_free_page = (char *) boot_alloc(0);
f0100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be0:	e8 97 fe ff ff       	call   f0100a7c <boot_alloc>
f0100be5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be8:	8b 15 20 bd 19 f0    	mov    0xf019bd20,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bee:	8b 0d ec c9 19 f0    	mov    0xf019c9ec,%ecx
		assert(pp < pages + npages);
f0100bf4:	a1 e4 c9 19 f0       	mov    0xf019c9e4,%eax
f0100bf9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100bfc:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c02:	be 00 00 00 00       	mov    $0x0,%esi
f0100c07:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0a:	e9 c8 00 00 00       	jmp    f0100cd7 <check_page_free_list+0x190>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c0f:	68 eb 59 10 f0       	push   $0xf01059eb
f0100c14:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c19:	68 96 02 00 00       	push   $0x296
f0100c1e:	68 d1 59 10 f0       	push   $0xf01059d1
f0100c23:	e8 78 f4 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100c28:	68 0c 5a 10 f0       	push   $0xf0105a0c
f0100c2d:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c32:	68 97 02 00 00       	push   $0x297
f0100c37:	68 d1 59 10 f0       	push   $0xf01059d1
f0100c3c:	e8 5f f4 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c41:	68 38 52 10 f0       	push   $0xf0105238
f0100c46:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c4b:	68 98 02 00 00       	push   $0x298
f0100c50:	68 d1 59 10 f0       	push   $0xf01059d1
f0100c55:	e8 46 f4 ff ff       	call   f01000a0 <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c5a:	68 20 5a 10 f0       	push   $0xf0105a20
f0100c5f:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c64:	68 9b 02 00 00       	push   $0x29b
f0100c69:	68 d1 59 10 f0       	push   $0xf01059d1
f0100c6e:	e8 2d f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c73:	68 31 5a 10 f0       	push   $0xf0105a31
f0100c78:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c7d:	68 9c 02 00 00       	push   $0x29c
f0100c82:	68 d1 59 10 f0       	push   $0xf01059d1
f0100c87:	e8 14 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c8c:	68 6c 52 10 f0       	push   $0xf010526c
f0100c91:	68 f7 59 10 f0       	push   $0xf01059f7
f0100c96:	68 9d 02 00 00       	push   $0x29d
f0100c9b:	68 d1 59 10 f0       	push   $0xf01059d1
f0100ca0:	e8 fb f3 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ca5:	68 4a 5a 10 f0       	push   $0xf0105a4a
f0100caa:	68 f7 59 10 f0       	push   $0xf01059f7
f0100caf:	68 9e 02 00 00       	push   $0x29e
f0100cb4:	68 d1 59 10 f0       	push   $0xf01059d1
f0100cb9:	e8 e2 f3 ff ff       	call   f01000a0 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cbe:	89 c3                	mov    %eax,%ebx
f0100cc0:	c1 eb 0c             	shr    $0xc,%ebx
f0100cc3:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100cc6:	76 63                	jbe    f0100d2b <check_page_free_list+0x1e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100cc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ccd:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100cd0:	77 6b                	ja     f0100d3d <check_page_free_list+0x1f6>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
f0100cd2:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cd5:	8b 12                	mov    (%edx),%edx
f0100cd7:	85 d2                	test   %edx,%edx
f0100cd9:	74 7b                	je     f0100d56 <check_page_free_list+0x20f>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cdb:	39 d1                	cmp    %edx,%ecx
f0100cdd:	0f 87 2c ff ff ff    	ja     f0100c0f <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100ce3:	39 d7                	cmp    %edx,%edi
f0100ce5:	0f 86 3d ff ff ff    	jbe    f0100c28 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ceb:	89 d0                	mov    %edx,%eax
f0100ced:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100cf0:	a8 07                	test   $0x7,%al
f0100cf2:	0f 85 49 ff ff ff    	jne    f0100c41 <check_page_free_list+0xfa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cf8:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cfb:	c1 e0 0c             	shl    $0xc,%eax
f0100cfe:	0f 84 56 ff ff ff    	je     f0100c5a <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d04:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d09:	0f 84 64 ff ff ff    	je     f0100c73 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d0f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d14:	0f 84 72 ff ff ff    	je     f0100c8c <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d1a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d1f:	74 84                	je     f0100ca5 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d21:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d26:	77 96                	ja     f0100cbe <check_page_free_list+0x177>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d28:	46                   	inc    %esi
f0100d29:	eb aa                	jmp    f0100cd5 <check_page_free_list+0x18e>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d2b:	50                   	push   %eax
f0100d2c:	68 f0 51 10 f0       	push   $0xf01051f0
f0100d31:	6a 56                	push   $0x56
f0100d33:	68 dd 59 10 f0       	push   $0xf01059dd
f0100d38:	e8 63 f3 ff ff       	call   f01000a0 <_panic>
		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3d:	68 90 52 10 f0       	push   $0xf0105290
f0100d42:	68 f7 59 10 f0       	push   $0xf01059f7
f0100d47:	68 9f 02 00 00       	push   $0x29f
f0100d4c:	68 d1 59 10 f0       	push   $0xf01059d1
f0100d51:	e8 4a f3 ff ff       	call   f01000a0 <_panic>
f0100d56:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d59:	85 f6                	test   %esi,%esi
f0100d5b:	7e 19                	jle    f0100d76 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f0100d5d:	85 db                	test   %ebx,%ebx
f0100d5f:	7e 2e                	jle    f0100d8f <check_page_free_list+0x248>

	cprintf("check_page_free_list() succeeded!\n");
f0100d61:	83 ec 0c             	sub    $0xc,%esp
f0100d64:	68 d8 52 10 f0       	push   $0xf01052d8
f0100d69:	e8 c7 25 00 00       	call   f0103335 <cprintf>
}
f0100d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d71:	5b                   	pop    %ebx
f0100d72:	5e                   	pop    %esi
f0100d73:	5f                   	pop    %edi
f0100d74:	5d                   	pop    %ebp
f0100d75:	c3                   	ret    
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d76:	68 64 5a 10 f0       	push   $0xf0105a64
f0100d7b:	68 f7 59 10 f0       	push   $0xf01059f7
f0100d80:	68 a7 02 00 00       	push   $0x2a7
f0100d85:	68 d1 59 10 f0       	push   $0xf01059d1
f0100d8a:	e8 11 f3 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100d8f:	68 76 5a 10 f0       	push   $0xf0105a76
f0100d94:	68 f7 59 10 f0       	push   $0xf01059f7
f0100d99:	68 a8 02 00 00       	push   $0x2a8
f0100d9e:	68 d1 59 10 f0       	push   $0xf01059d1
f0100da3:	e8 f8 f2 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100da8:	a1 20 bd 19 f0       	mov    0xf019bd20,%eax
f0100dad:	85 c0                	test   %eax,%eax
f0100daf:	0f 84 b6 fd ff ff    	je     f0100b6b <check_page_free_list+0x24>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100db5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100db8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dbb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dbe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc1:	89 c2                	mov    %eax,%edx
f0100dc3:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dc9:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100dcf:	0f 95 c2             	setne  %dl
f0100dd2:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100dd5:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dd9:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ddb:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ddf:	8b 00                	mov    (%eax),%eax
f0100de1:	85 c0                	test   %eax,%eax
f0100de3:	75 dc                	jne    f0100dc1 <check_page_free_list+0x27a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100de8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dee:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df4:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100df6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100df9:	a3 20 bd 19 f0       	mov    %eax,0xf019bd20
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dfe:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e03:	8b 1d 20 bd 19 f0    	mov    0xf019bd20,%ebx
f0100e09:	e9 88 fd ff ff       	jmp    f0100b96 <check_page_free_list+0x4f>

f0100e0e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e0e:	55                   	push   %ebp
f0100e0f:	89 e5                	mov    %esp,%ebp
f0100e11:	57                   	push   %edi
f0100e12:	56                   	push   %esi
f0100e13:	53                   	push   %ebx
f0100e14:	83 ec 0c             	sub    $0xc,%esp
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
    pages[0].pp_ref = 1;
f0100e17:	a1 ec c9 19 f0       	mov    0xf019c9ec,%eax
f0100e1c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (size_t i = 1; i < npages_basemem; i++) {
f0100e22:	8b 35 24 bd 19 f0    	mov    0xf019bd24,%esi
f0100e28:	8b 1d 20 bd 19 f0    	mov    0xf019bd20,%ebx
f0100e2e:	b2 00                	mov    $0x0,%dl
f0100e30:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e35:	bf 01 00 00 00       	mov    $0x1,%edi
f0100e3a:	eb 22                	jmp    f0100e5e <page_init+0x50>
		pages[i].pp_ref = 0;
f0100e3c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100e43:	89 d1                	mov    %edx,%ecx
f0100e45:	03 0d ec c9 19 f0    	add    0xf019c9ec,%ecx
f0100e4b:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e51:	89 19                	mov    %ebx,(%ecx)
	//     in case we ever need them.  (Currently we don't, but...)
    pages[0].pp_ref = 1;

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (size_t i = 1; i < npages_basemem; i++) {
f0100e53:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100e54:	89 d3                	mov    %edx,%ebx
f0100e56:	03 1d ec c9 19 f0    	add    0xf019c9ec,%ebx
f0100e5c:	89 fa                	mov    %edi,%edx
	//     in case we ever need them.  (Currently we don't, but...)
    pages[0].pp_ref = 1;

	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (size_t i = 1; i < npages_basemem; i++) {
f0100e5e:	39 c6                	cmp    %eax,%esi
f0100e60:	77 da                	ja     f0100e3c <page_init+0x2e>
f0100e62:	84 d2                	test   %dl,%dl
f0100e64:	75 44                	jne    f0100eaa <page_init+0x9c>
	}

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	for (size_t i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100e66:	8b 15 ec c9 19 f0    	mov    0xf019c9ec,%edx
f0100e6c:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100e72:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100e78:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100e7d:	83 c0 08             	add    $0x8,%eax
		page_free_list = &pages[i];
	}

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	for (size_t i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100e80:	39 d0                	cmp    %edx,%eax
f0100e82:	75 f4                	jne    f0100e78 <page_init+0x6a>
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
f0100e84:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e89:	e8 ee fb ff ff       	call   f0100a7c <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e8e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e93:	76 1d                	jbe    f0100eb2 <page_init+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100e95:	05 00 00 00 10       	add    $0x10000000,%eax
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100e9a:	c1 e8 0c             	shr    $0xc,%eax
		pages[i].pp_ref = 1;
f0100e9d:	8b 0d ec c9 19 f0    	mov    0xf019c9ec,%ecx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100ea3:	ba 00 01 00 00       	mov    $0x100,%edx
f0100ea8:	eb 25                	jmp    f0100ecf <page_init+0xc1>
f0100eaa:	89 1d 20 bd 19 f0    	mov    %ebx,0xf019bd20
f0100eb0:	eb b4                	jmp    f0100e66 <page_init+0x58>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eb2:	50                   	push   %eax
f0100eb3:	68 fc 52 10 f0       	push   $0xf01052fc
f0100eb8:	68 22 01 00 00       	push   $0x122
f0100ebd:	68 d1 59 10 f0       	push   $0xf01059d1
f0100ec2:	e8 d9 f1 ff ff       	call   f01000a0 <_panic>
		pages[i].pp_ref = 1;
f0100ec7:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t first_free_address = PADDR(boot_alloc(0));
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100ece:	42                   	inc    %edx
f0100ecf:	39 d0                	cmp    %edx,%eax
f0100ed1:	77 f4                	ja     f0100ec7 <page_init+0xb9>
f0100ed3:	8b 1d 20 bd 19 f0    	mov    0xf019bd20,%ebx
f0100ed9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ee0:	b1 00                	mov    $0x0,%cl
f0100ee2:	be 01 00 00 00       	mov    $0x1,%esi
f0100ee7:	eb 1e                	jmp    f0100f07 <page_init+0xf9>
		pages[i].pp_ref = 1;
	}

	for (size_t i = first_free_address/PGSIZE; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100ee9:	89 d1                	mov    %edx,%ecx
f0100eeb:	03 0d ec c9 19 f0    	add    0xf019c9ec,%ecx
f0100ef1:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ef7:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100ef9:	89 d3                	mov    %edx,%ebx
f0100efb:	03 1d ec c9 19 f0    	add    0xf019c9ec,%ebx
	size_t first_free_address = PADDR(boot_alloc(0));
	for (size_t i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
		pages[i].pp_ref = 1;
	}

	for (size_t i = first_free_address/PGSIZE; i < npages; i++) {
f0100f01:	40                   	inc    %eax
f0100f02:	83 c2 08             	add    $0x8,%edx
f0100f05:	89 f1                	mov    %esi,%ecx
f0100f07:	39 05 e4 c9 19 f0    	cmp    %eax,0xf019c9e4
f0100f0d:	77 da                	ja     f0100ee9 <page_init+0xdb>
f0100f0f:	84 c9                	test   %cl,%cl
f0100f11:	75 08                	jne    f0100f1b <page_init+0x10d>
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f16:	5b                   	pop    %ebx
f0100f17:	5e                   	pop    %esi
f0100f18:	5f                   	pop    %edi
f0100f19:	5d                   	pop    %ebp
f0100f1a:	c3                   	ret    
f0100f1b:	89 1d 20 bd 19 f0    	mov    %ebx,0xf019bd20
f0100f21:	eb f0                	jmp    f0100f13 <page_init+0x105>

f0100f23 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f23:	55                   	push   %ebp
f0100f24:	89 e5                	mov    %esp,%ebp
f0100f26:	53                   	push   %ebx
f0100f27:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL) {
f0100f2a:	8b 1d 20 bd 19 f0    	mov    0xf019bd20,%ebx
f0100f30:	85 db                	test   %ebx,%ebx
f0100f32:	74 13                	je     f0100f47 <page_alloc+0x24>
		return NULL;
	}
	// get the first node from page_free_list
	struct PageInfo* allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100f34:	8b 03                	mov    (%ebx),%eax
f0100f36:	a3 20 bd 19 f0       	mov    %eax,0xf019bd20
	allocated_page->pp_link = NULL;
f0100f3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100f41:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f45:	75 07                	jne    f0100f4e <page_alloc+0x2b>
		memset(page2kva(allocated_page), '\0', PGSIZE);
	}
 	return allocated_page;
}
f0100f47:	89 d8                	mov    %ebx,%eax
f0100f49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f4c:	c9                   	leave  
f0100f4d:	c3                   	ret    
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f4e:	89 d8                	mov    %ebx,%eax
f0100f50:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0100f56:	c1 f8 03             	sar    $0x3,%eax
f0100f59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5c:	89 c2                	mov    %eax,%edx
f0100f5e:	c1 ea 0c             	shr    $0xc,%edx
f0100f61:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f0100f67:	73 1a                	jae    f0100f83 <page_alloc+0x60>
	// get the first node from page_free_list
	struct PageInfo* allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
	allocated_page->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) {
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0100f69:	83 ec 04             	sub    $0x4,%esp
f0100f6c:	68 00 10 00 00       	push   $0x1000
f0100f71:	6a 00                	push   $0x0
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100f73:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f78:	50                   	push   %eax
f0100f79:	e8 0b 38 00 00       	call   f0104789 <memset>
f0100f7e:	83 c4 10             	add    $0x10,%esp
f0100f81:	eb c4                	jmp    f0100f47 <page_alloc+0x24>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f83:	50                   	push   %eax
f0100f84:	68 f0 51 10 f0       	push   $0xf01051f0
f0100f89:	6a 56                	push   $0x56
f0100f8b:	68 dd 59 10 f0       	push   $0xf01059dd
f0100f90:	e8 0b f1 ff ff       	call   f01000a0 <_panic>

f0100f95 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f95:	55                   	push   %ebp
f0100f96:	89 e5                	mov    %esp,%ebp
f0100f98:	83 ec 08             	sub    $0x8,%esp
f0100f9b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0100f9e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fa3:	75 14                	jne    f0100fb9 <page_free+0x24>
		panic("pp_ref is nonzero");
        return;
	}

	if (pp->pp_link != NULL) {
f0100fa5:	83 38 00             	cmpl   $0x0,(%eax)
f0100fa8:	75 26                	jne    f0100fd0 <page_free+0x3b>
		panic("pp_link is nonNULL");
		return;
	}

	pp->pp_link = page_free_list;
f0100faa:	8b 15 20 bd 19 f0    	mov    0xf019bd20,%edx
f0100fb0:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fb2:	a3 20 bd 19 f0       	mov    %eax,0xf019bd20
}
f0100fb7:	c9                   	leave  
f0100fb8:	c3                   	ret    
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
		panic("pp_ref is nonzero");
f0100fb9:	83 ec 04             	sub    $0x4,%esp
f0100fbc:	68 87 5a 10 f0       	push   $0xf0105a87
f0100fc1:	68 57 01 00 00       	push   $0x157
f0100fc6:	68 d1 59 10 f0       	push   $0xf01059d1
f0100fcb:	e8 d0 f0 ff ff       	call   f01000a0 <_panic>
        return;
	}

	if (pp->pp_link != NULL) {
		panic("pp_link is nonNULL");
f0100fd0:	83 ec 04             	sub    $0x4,%esp
f0100fd3:	68 99 5a 10 f0       	push   $0xf0105a99
f0100fd8:	68 5c 01 00 00       	push   $0x15c
f0100fdd:	68 d1 59 10 f0       	push   $0xf01059d1
f0100fe2:	e8 b9 f0 ff ff       	call   f01000a0 <_panic>

f0100fe7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
f0100fea:	83 ec 08             	sub    $0x8,%esp
f0100fed:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ff0:	8b 42 04             	mov    0x4(%edx),%eax
f0100ff3:	48                   	dec    %eax
f0100ff4:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ff8:	66 85 c0             	test   %ax,%ax
f0100ffb:	74 02                	je     f0100fff <page_decref+0x18>
		page_free(pp);
}
f0100ffd:	c9                   	leave  
f0100ffe:	c3                   	ret    
//
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
f0100fff:	83 ec 0c             	sub    $0xc,%esp
f0101002:	52                   	push   %edx
f0101003:	e8 8d ff ff ff       	call   f0100f95 <page_free>
f0101008:	83 c4 10             	add    $0x10,%esp
}
f010100b:	eb f0                	jmp    f0100ffd <page_decref+0x16>

f010100d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
f0101010:	56                   	push   %esi
f0101011:	53                   	push   %ebx
f0101012:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function in
	uint32_t page_dir_idx = PDX(va);
	uint32_t page_tab_idx = PTX(va);
f0101015:	89 c6                	mov    %eax,%esi
f0101017:	c1 ee 0c             	shr    $0xc,%esi
f010101a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	uint32_t page_dir_idx = PDX(va);
f0101020:	c1 e8 16             	shr    $0x16,%eax
	uint32_t page_tab_idx = PTX(va);
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
f0101023:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f010102a:	03 5d 08             	add    0x8(%ebp),%ebx
f010102d:	8b 03                	mov    (%ebx),%eax
f010102f:	a8 01                	test   $0x1,%al
f0101031:	74 37                	je     f010106a <pgdir_walk+0x5d>
		pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
f0101033:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 ea 0c             	shr    $0xc,%edx
f010103d:	39 15 e4 c9 19 f0    	cmp    %edx,0xf019c9e4
f0101043:	76 10                	jbe    f0101055 <pgdir_walk+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101045:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
			}
		} else {
			return NULL;
		}
	}
	return &pgtab[page_tab_idx];
f010104b:	8d 04 b2             	lea    (%edx,%esi,4),%eax
}
f010104e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101051:	5b                   	pop    %ebx
f0101052:	5e                   	pop    %esi
f0101053:	5d                   	pop    %ebp
f0101054:	c3                   	ret    

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101055:	50                   	push   %eax
f0101056:	68 f0 51 10 f0       	push   $0xf01051f0
f010105b:	68 8d 01 00 00       	push   $0x18d
f0101060:	68 d1 59 10 f0       	push   $0xf01059d1
f0101065:	e8 36 f0 ff ff       	call   f01000a0 <_panic>
	uint32_t page_tab_idx = PTX(va);
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
		pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
	} else {
		if (create) {
f010106a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010106e:	74 6c                	je     f01010dc <pgdir_walk+0xcf>
            struct PageInfo *newPageInfo = page_alloc(ALLOC_ZERO);
f0101070:	83 ec 0c             	sub    $0xc,%esp
f0101073:	6a 01                	push   $0x1
f0101075:	e8 a9 fe ff ff       	call   f0100f23 <page_alloc>
			if (newPageInfo) {
f010107a:	83 c4 10             	add    $0x10,%esp
f010107d:	85 c0                	test   %eax,%eax
f010107f:	74 65                	je     f01010e6 <pgdir_walk+0xd9>
				newPageInfo->pp_ref += 1;
f0101081:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101085:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f010108b:	c1 f8 03             	sar    $0x3,%eax
f010108e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101091:	89 c2                	mov    %eax,%edx
f0101093:	c1 ea 0c             	shr    $0xc,%edx
f0101096:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f010109c:	73 17                	jae    f01010b5 <pgdir_walk+0xa8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f010109e:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f01010a4:	89 ca                	mov    %ecx,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010a6:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01010ac:	76 19                	jbe    f01010c7 <pgdir_walk+0xba>
				pgtab = (pte_t *) page2kva(newPageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f01010ae:	83 c8 07             	or     $0x7,%eax
f01010b1:	89 03                	mov    %eax,(%ebx)
f01010b3:	eb 96                	jmp    f010104b <pgdir_walk+0x3e>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b5:	50                   	push   %eax
f01010b6:	68 f0 51 10 f0       	push   $0xf01051f0
f01010bb:	6a 56                	push   $0x56
f01010bd:	68 dd 59 10 f0       	push   $0xf01059dd
f01010c2:	e8 d9 ef ff ff       	call   f01000a0 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010c7:	51                   	push   %ecx
f01010c8:	68 fc 52 10 f0       	push   $0xf01052fc
f01010cd:	68 94 01 00 00       	push   $0x194
f01010d2:	68 d1 59 10 f0       	push   $0xf01059d1
f01010d7:	e8 c4 ef ff ff       	call   f01000a0 <_panic>
			} else {
				return NULL;
			}
		} else {
			return NULL;
f01010dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e1:	e9 68 ff ff ff       	jmp    f010104e <pgdir_walk+0x41>
			if (newPageInfo) {
				newPageInfo->pp_ref += 1;
				pgtab = (pte_t *) page2kva(newPageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
			} else {
				return NULL;
f01010e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010eb:	e9 5e ff ff ff       	jmp    f010104e <pgdir_walk+0x41>

f01010f0 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010f0:	55                   	push   %ebp
f01010f1:	89 e5                	mov    %esp,%ebp
f01010f3:	57                   	push   %edi
f01010f4:	56                   	push   %esi
f01010f5:	53                   	push   %ebx
f01010f6:	83 ec 1c             	sub    $0x1c,%esp
f01010f9:	89 c7                	mov    %eax,%edi
f01010fb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
f01010fe:	c1 e9 0c             	shr    $0xc,%ecx
f0101101:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i=0; i<pg_num; i++) {
f0101104:	89 c3                	mov    %eax,%ebx
f0101106:	be 00 00 00 00       	mov    $0x0,%esi
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f010110b:	29 c2                	sub    %eax,%edx
f010110d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		if (!pgtab) {
			return;
		}
		*pgtab = pa | perm | PTE_P;
f0101110:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101113:	83 c8 01             	or     $0x1,%eax
f0101116:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
	for (size_t i=0; i<pg_num; i++) {
f0101119:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010111c:	74 28                	je     f0101146 <boot_map_region+0x56>
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f010111e:	83 ec 04             	sub    $0x4,%esp
f0101121:	6a 01                	push   $0x1
f0101123:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101126:	01 d8                	add    %ebx,%eax
f0101128:	50                   	push   %eax
f0101129:	57                   	push   %edi
f010112a:	e8 de fe ff ff       	call   f010100d <pgdir_walk>
		if (!pgtab) {
f010112f:	83 c4 10             	add    $0x10,%esp
f0101132:	85 c0                	test   %eax,%eax
f0101134:	74 10                	je     f0101146 <boot_map_region+0x56>
			return;
		}
		*pgtab = pa | perm | PTE_P;
f0101136:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101139:	09 da                	or     %ebx,%edx
f010113b:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f010113d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = PGNUM(size);
	for (size_t i=0; i<pg_num; i++) {
f0101143:	46                   	inc    %esi
f0101144:	eb d3                	jmp    f0101119 <boot_map_region+0x29>
		}
		*pgtab = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f0101146:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101149:	5b                   	pop    %ebx
f010114a:	5e                   	pop    %esi
f010114b:	5f                   	pop    %edi
f010114c:	5d                   	pop    %ebp
f010114d:	c3                   	ret    

f010114e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010114e:	55                   	push   %ebp
f010114f:	89 e5                	mov    %esp,%ebp
f0101151:	53                   	push   %ebx
f0101152:	83 ec 08             	sub    $0x8,%esp
f0101155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
f0101158:	6a 00                	push   $0x0
f010115a:	ff 75 0c             	pushl  0xc(%ebp)
f010115d:	ff 75 08             	pushl  0x8(%ebp)
f0101160:	e8 a8 fe ff ff       	call   f010100d <pgdir_walk>
    if (!pgtab) {
f0101165:	83 c4 10             	add    $0x10,%esp
f0101168:	85 c0                	test   %eax,%eax
f010116a:	74 35                	je     f01011a1 <page_lookup+0x53>
		return NULL;
	}
	if (pte_store != NULL) {
f010116c:	85 db                	test   %ebx,%ebx
f010116e:	74 02                	je     f0101172 <page_lookup+0x24>
		*pte_store = pgtab;
f0101170:	89 03                	mov    %eax,(%ebx)
f0101172:	8b 00                	mov    (%eax),%eax
f0101174:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101177:	39 05 e4 c9 19 f0    	cmp    %eax,0xf019c9e4
f010117d:	76 0e                	jbe    f010118d <page_lookup+0x3f>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010117f:	8b 15 ec c9 19 f0    	mov    0xf019c9ec,%edx
f0101185:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}

	return pa2page(PTE_ADDR(*pgtab));
}
f0101188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010118b:	c9                   	leave  
f010118c:	c3                   	ret    

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f010118d:	83 ec 04             	sub    $0x4,%esp
f0101190:	68 20 53 10 f0       	push   $0xf0105320
f0101195:	6a 4f                	push   $0x4f
f0101197:	68 dd 59 10 f0       	push   $0xf01059dd
f010119c:	e8 ff ee ff ff       	call   f01000a0 <_panic>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
    if (!pgtab) {
		return NULL;
f01011a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a6:	eb e0                	jmp    f0101188 <page_lookup+0x3a>

f01011a8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011a8:	55                   	push   %ebp
f01011a9:	89 e5                	mov    %esp,%ebp
f01011ab:	53                   	push   %ebx
f01011ac:	83 ec 18             	sub    $0x18,%esp
f01011af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pgtab;
	pte_t **pte_store = &pgtab;
    struct PageInfo* pageInfo = page_lookup(pgdir, va, pte_store);
f01011b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011b5:	50                   	push   %eax
f01011b6:	53                   	push   %ebx
f01011b7:	ff 75 08             	pushl  0x8(%ebp)
f01011ba:	e8 8f ff ff ff       	call   f010114e <page_lookup>
	if (pageInfo == NULL) {
f01011bf:	83 c4 10             	add    $0x10,%esp
f01011c2:	85 c0                	test   %eax,%eax
f01011c4:	75 05                	jne    f01011cb <page_remove+0x23>
	}
	page_decref(pageInfo);
	*pgtab = 0;
	tlb_invalidate(pgdir, va);

}
f01011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011c9:	c9                   	leave  
f01011ca:	c3                   	ret    
	pte_t **pte_store = &pgtab;
    struct PageInfo* pageInfo = page_lookup(pgdir, va, pte_store);
	if (pageInfo == NULL) {
		return;
	}
	page_decref(pageInfo);
f01011cb:	83 ec 0c             	sub    $0xc,%esp
f01011ce:	50                   	push   %eax
f01011cf:	e8 13 fe ff ff       	call   f0100fe7 <page_decref>
	*pgtab = 0;
f01011d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011dd:	0f 01 3b             	invlpg (%ebx)
f01011e0:	83 c4 10             	add    $0x10,%esp
f01011e3:	eb e1                	jmp    f01011c6 <page_remove+0x1e>

f01011e5 <page_insert>:
 * va    线性地址
 * perm  权限
 */
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011e5:	55                   	push   %ebp
f01011e6:	89 e5                	mov    %esp,%ebp
f01011e8:	57                   	push   %edi
f01011e9:	56                   	push   %esi
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 10             	sub    $0x10,%esp
f01011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011f1:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
f01011f4:	6a 01                	push   $0x1
f01011f6:	57                   	push   %edi
f01011f7:	ff 75 08             	pushl  0x8(%ebp)
f01011fa:	e8 0e fe ff ff       	call   f010100d <pgdir_walk>
	if (!pgtab) {
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	85 c0                	test   %eax,%eax
f0101204:	74 3f                	je     f0101245 <page_insert+0x60>
f0101206:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	}

	pp->pp_ref++;
f0101208:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pgtab & PTE_P) {
f010120c:	f6 00 01             	testb  $0x1,(%eax)
f010120f:	75 23                	jne    f0101234 <page_insert+0x4f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101211:	2b 1d ec c9 19 f0    	sub    0xf019c9ec,%ebx
f0101217:	c1 fb 03             	sar    $0x3,%ebx
f010121a:	c1 e3 0c             	shl    $0xc,%ebx
		page_remove(pgdir, va);
	}

	*pgtab = page2pa(pp) | perm | PTE_P;
f010121d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101220:	83 c8 01             	or     $0x1,%eax
f0101223:	09 c3                	or     %eax,%ebx
f0101225:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101227:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122f:	5b                   	pop    %ebx
f0101230:	5e                   	pop    %esi
f0101231:	5f                   	pop    %edi
f0101232:	5d                   	pop    %ebp
f0101233:	c3                   	ret    
		return -E_NO_MEM;
	}

	pp->pp_ref++;
	if (*pgtab & PTE_P) {
		page_remove(pgdir, va);
f0101234:	83 ec 08             	sub    $0x8,%esp
f0101237:	57                   	push   %edi
f0101238:	ff 75 08             	pushl  0x8(%ebp)
f010123b:	e8 68 ff ff ff       	call   f01011a8 <page_remove>
f0101240:	83 c4 10             	add    $0x10,%esp
f0101243:	eb cc                	jmp    f0101211 <page_insert+0x2c>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
	if (!pgtab) {
		return -E_NO_MEM;
f0101245:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010124a:	eb e0                	jmp    f010122c <page_insert+0x47>

f010124c <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010124c:	55                   	push   %ebp
f010124d:	89 e5                	mov    %esp,%ebp
f010124f:	57                   	push   %edi
f0101250:	56                   	push   %esi
f0101251:	53                   	push   %ebx
f0101252:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101255:	b8 15 00 00 00       	mov    $0x15,%eax
f010125a:	e8 62 f8 ff ff       	call   f0100ac1 <nvram_read>
f010125f:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101261:	b8 17 00 00 00       	mov    $0x17,%eax
f0101266:	e8 56 f8 ff ff       	call   f0100ac1 <nvram_read>
f010126b:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010126d:	b8 34 00 00 00       	mov    $0x34,%eax
f0101272:	e8 4a f8 ff ff       	call   f0100ac1 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101277:	c1 e0 06             	shl    $0x6,%eax
f010127a:	75 10                	jne    f010128c <mem_init+0x40>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
f010127c:	85 db                	test   %ebx,%ebx
f010127e:	0f 84 e6 00 00 00    	je     f010136a <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101284:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010128a:	eb 05                	jmp    f0101291 <mem_init+0x45>
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f010128c:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101291:	89 c2                	mov    %eax,%edx
f0101293:	c1 ea 02             	shr    $0x2,%edx
f0101296:	89 15 e4 c9 19 f0    	mov    %edx,0xf019c9e4
	npages_basemem = basemem / (PGSIZE / 1024);
f010129c:	89 f2                	mov    %esi,%edx
f010129e:	c1 ea 02             	shr    $0x2,%edx
f01012a1:	89 15 24 bd 19 f0    	mov    %edx,0xf019bd24

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012a7:	89 c2                	mov    %eax,%edx
f01012a9:	29 f2                	sub    %esi,%edx
f01012ab:	52                   	push   %edx
f01012ac:	56                   	push   %esi
f01012ad:	50                   	push   %eax
f01012ae:	68 40 53 10 f0       	push   $0xf0105340
f01012b3:	e8 7d 20 00 00       	call   f0103335 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012b8:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012bd:	e8 ba f7 ff ff       	call   f0100a7c <boot_alloc>
f01012c2:	a3 e8 c9 19 f0       	mov    %eax,0xf019c9e8
	memset(kern_pgdir, 0, PGSIZE);
f01012c7:	83 c4 0c             	add    $0xc,%esp
f01012ca:	68 00 10 00 00       	push   $0x1000
f01012cf:	6a 00                	push   $0x0
f01012d1:	50                   	push   %eax
f01012d2:	e8 b2 34 00 00       	call   f0104789 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012d7:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012dc:	83 c4 10             	add    $0x10,%esp
f01012df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012e4:	0f 86 87 00 00 00    	jbe    f0101371 <mem_init+0x125>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01012ea:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012f0:	83 ca 05             	or     $0x5,%edx
f01012f3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    pages = (struct PageInfo*)boot_alloc(npages * sizeof(struct PageInfo));
f01012f9:	a1 e4 c9 19 f0       	mov    0xf019c9e4,%eax
f01012fe:	c1 e0 03             	shl    $0x3,%eax
f0101301:	e8 76 f7 ff ff       	call   f0100a7c <boot_alloc>
f0101306:	a3 ec c9 19 f0       	mov    %eax,0xf019c9ec
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010130b:	83 ec 04             	sub    $0x4,%esp
f010130e:	8b 3d e4 c9 19 f0    	mov    0xf019c9e4,%edi
f0101314:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010131b:	52                   	push   %edx
f010131c:	6a 00                	push   $0x0
f010131e:	50                   	push   %eax
f010131f:	e8 65 34 00 00       	call   f0104789 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV * sizeof(struct Env));
f0101324:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101329:	e8 4e f7 ff ff       	call   f0100a7c <boot_alloc>
f010132e:	a3 2c bd 19 f0       	mov    %eax,0xf019bd2c
	memset(envs, 0, NENV * sizeof(struct Env));
f0101333:	83 c4 0c             	add    $0xc,%esp
f0101336:	68 00 80 01 00       	push   $0x18000
f010133b:	6a 00                	push   $0x0
f010133d:	50                   	push   %eax
f010133e:	e8 46 34 00 00       	call   f0104789 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101343:	e8 c6 fa ff ff       	call   f0100e0e <page_init>
	check_page_free_list(1);
f0101348:	b8 01 00 00 00       	mov    $0x1,%eax
f010134d:	e8 f5 f7 ff ff       	call   f0100b47 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101352:	83 c4 10             	add    $0x10,%esp
f0101355:	83 3d ec c9 19 f0 00 	cmpl   $0x0,0xf019c9ec
f010135c:	74 28                	je     f0101386 <mem_init+0x13a>
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010135e:	a1 20 bd 19 f0       	mov    0xf019bd20,%eax
f0101363:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101368:	eb 36                	jmp    f01013a0 <mem_init+0x154>
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;
f010136a:	89 f0                	mov    %esi,%eax
f010136c:	e9 20 ff ff ff       	jmp    f0101291 <mem_init+0x45>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101371:	50                   	push   %eax
f0101372:	68 fc 52 10 f0       	push   $0xf01052fc
f0101377:	68 94 00 00 00       	push   $0x94
f010137c:	68 d1 59 10 f0       	push   $0xf01059d1
f0101381:	e8 1a ed ff ff       	call   f01000a0 <_panic>
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
		panic("'pages' is a null pointer!");
f0101386:	83 ec 04             	sub    $0x4,%esp
f0101389:	68 ac 5a 10 f0       	push   $0xf0105aac
f010138e:	68 bb 02 00 00       	push   $0x2bb
f0101393:	68 d1 59 10 f0       	push   $0xf01059d1
f0101398:	e8 03 ed ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;
f010139d:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010139e:	8b 00                	mov    (%eax),%eax
f01013a0:	85 c0                	test   %eax,%eax
f01013a2:	75 f9                	jne    f010139d <mem_init+0x151>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013a4:	83 ec 0c             	sub    $0xc,%esp
f01013a7:	6a 00                	push   $0x0
f01013a9:	e8 75 fb ff ff       	call   f0100f23 <page_alloc>
f01013ae:	89 c7                	mov    %eax,%edi
f01013b0:	83 c4 10             	add    $0x10,%esp
f01013b3:	85 c0                	test   %eax,%eax
f01013b5:	0f 84 10 02 00 00    	je     f01015cb <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f01013bb:	83 ec 0c             	sub    $0xc,%esp
f01013be:	6a 00                	push   $0x0
f01013c0:	e8 5e fb ff ff       	call   f0100f23 <page_alloc>
f01013c5:	89 c6                	mov    %eax,%esi
f01013c7:	83 c4 10             	add    $0x10,%esp
f01013ca:	85 c0                	test   %eax,%eax
f01013cc:	0f 84 12 02 00 00    	je     f01015e4 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01013d2:	83 ec 0c             	sub    $0xc,%esp
f01013d5:	6a 00                	push   $0x0
f01013d7:	e8 47 fb ff ff       	call   f0100f23 <page_alloc>
f01013dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013df:	83 c4 10             	add    $0x10,%esp
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	0f 84 13 02 00 00    	je     f01015fd <mem_init+0x3b1>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013ea:	39 f7                	cmp    %esi,%edi
f01013ec:	0f 84 24 02 00 00    	je     f0101616 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013f5:	39 c6                	cmp    %eax,%esi
f01013f7:	0f 84 32 02 00 00    	je     f010162f <mem_init+0x3e3>
f01013fd:	39 c7                	cmp    %eax,%edi
f01013ff:	0f 84 2a 02 00 00    	je     f010162f <mem_init+0x3e3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101405:	8b 0d ec c9 19 f0    	mov    0xf019c9ec,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010140b:	8b 15 e4 c9 19 f0    	mov    0xf019c9e4,%edx
f0101411:	c1 e2 0c             	shl    $0xc,%edx
f0101414:	89 f8                	mov    %edi,%eax
f0101416:	29 c8                	sub    %ecx,%eax
f0101418:	c1 f8 03             	sar    $0x3,%eax
f010141b:	c1 e0 0c             	shl    $0xc,%eax
f010141e:	39 d0                	cmp    %edx,%eax
f0101420:	0f 83 22 02 00 00    	jae    f0101648 <mem_init+0x3fc>
f0101426:	89 f0                	mov    %esi,%eax
f0101428:	29 c8                	sub    %ecx,%eax
f010142a:	c1 f8 03             	sar    $0x3,%eax
f010142d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101430:	39 c2                	cmp    %eax,%edx
f0101432:	0f 86 29 02 00 00    	jbe    f0101661 <mem_init+0x415>
f0101438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010143b:	29 c8                	sub    %ecx,%eax
f010143d:	c1 f8 03             	sar    $0x3,%eax
f0101440:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101443:	39 c2                	cmp    %eax,%edx
f0101445:	0f 86 2f 02 00 00    	jbe    f010167a <mem_init+0x42e>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010144b:	a1 20 bd 19 f0       	mov    0xf019bd20,%eax
f0101450:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101453:	c7 05 20 bd 19 f0 00 	movl   $0x0,0xf019bd20
f010145a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010145d:	83 ec 0c             	sub    $0xc,%esp
f0101460:	6a 00                	push   $0x0
f0101462:	e8 bc fa ff ff       	call   f0100f23 <page_alloc>
f0101467:	83 c4 10             	add    $0x10,%esp
f010146a:	85 c0                	test   %eax,%eax
f010146c:	0f 85 21 02 00 00    	jne    f0101693 <mem_init+0x447>

	// free and re-allocate?
	page_free(pp0);
f0101472:	83 ec 0c             	sub    $0xc,%esp
f0101475:	57                   	push   %edi
f0101476:	e8 1a fb ff ff       	call   f0100f95 <page_free>
	page_free(pp1);
f010147b:	89 34 24             	mov    %esi,(%esp)
f010147e:	e8 12 fb ff ff       	call   f0100f95 <page_free>
	page_free(pp2);
f0101483:	83 c4 04             	add    $0x4,%esp
f0101486:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101489:	e8 07 fb ff ff       	call   f0100f95 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010148e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101495:	e8 89 fa ff ff       	call   f0100f23 <page_alloc>
f010149a:	89 c6                	mov    %eax,%esi
f010149c:	83 c4 10             	add    $0x10,%esp
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	0f 84 05 02 00 00    	je     f01016ac <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f01014a7:	83 ec 0c             	sub    $0xc,%esp
f01014aa:	6a 00                	push   $0x0
f01014ac:	e8 72 fa ff ff       	call   f0100f23 <page_alloc>
f01014b1:	89 c7                	mov    %eax,%edi
f01014b3:	83 c4 10             	add    $0x10,%esp
f01014b6:	85 c0                	test   %eax,%eax
f01014b8:	0f 84 07 02 00 00    	je     f01016c5 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f01014be:	83 ec 0c             	sub    $0xc,%esp
f01014c1:	6a 00                	push   $0x0
f01014c3:	e8 5b fa ff ff       	call   f0100f23 <page_alloc>
f01014c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014cb:	83 c4 10             	add    $0x10,%esp
f01014ce:	85 c0                	test   %eax,%eax
f01014d0:	0f 84 08 02 00 00    	je     f01016de <mem_init+0x492>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014d6:	39 fe                	cmp    %edi,%esi
f01014d8:	0f 84 19 02 00 00    	je     f01016f7 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e1:	39 c7                	cmp    %eax,%edi
f01014e3:	0f 84 27 02 00 00    	je     f0101710 <mem_init+0x4c4>
f01014e9:	39 c6                	cmp    %eax,%esi
f01014eb:	0f 84 1f 02 00 00    	je     f0101710 <mem_init+0x4c4>
	assert(!page_alloc(0));
f01014f1:	83 ec 0c             	sub    $0xc,%esp
f01014f4:	6a 00                	push   $0x0
f01014f6:	e8 28 fa ff ff       	call   f0100f23 <page_alloc>
f01014fb:	83 c4 10             	add    $0x10,%esp
f01014fe:	85 c0                	test   %eax,%eax
f0101500:	0f 85 23 02 00 00    	jne    f0101729 <mem_init+0x4dd>
f0101506:	89 f0                	mov    %esi,%eax
f0101508:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f010150e:	c1 f8 03             	sar    $0x3,%eax
f0101511:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101514:	89 c2                	mov    %eax,%edx
f0101516:	c1 ea 0c             	shr    $0xc,%edx
f0101519:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f010151f:	0f 83 1d 02 00 00    	jae    f0101742 <mem_init+0x4f6>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101525:	83 ec 04             	sub    $0x4,%esp
f0101528:	68 00 10 00 00       	push   $0x1000
f010152d:	6a 01                	push   $0x1
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f010152f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101534:	50                   	push   %eax
f0101535:	e8 4f 32 00 00       	call   f0104789 <memset>
	page_free(pp0);
f010153a:	89 34 24             	mov    %esi,(%esp)
f010153d:	e8 53 fa ff ff       	call   f0100f95 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101542:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101549:	e8 d5 f9 ff ff       	call   f0100f23 <page_alloc>
f010154e:	83 c4 10             	add    $0x10,%esp
f0101551:	85 c0                	test   %eax,%eax
f0101553:	0f 84 fb 01 00 00    	je     f0101754 <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101559:	39 c6                	cmp    %eax,%esi
f010155b:	0f 85 0c 02 00 00    	jne    f010176d <mem_init+0x521>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101561:	89 f2                	mov    %esi,%edx
f0101563:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f0101569:	c1 fa 03             	sar    $0x3,%edx
f010156c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010156f:	89 d0                	mov    %edx,%eax
f0101571:	c1 e8 0c             	shr    $0xc,%eax
f0101574:	3b 05 e4 c9 19 f0    	cmp    0xf019c9e4,%eax
f010157a:	0f 83 06 02 00 00    	jae    f0101786 <mem_init+0x53a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101580:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101586:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010158c:	80 38 00             	cmpb   $0x0,(%eax)
f010158f:	0f 85 03 02 00 00    	jne    f0101798 <mem_init+0x54c>
f0101595:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101596:	39 d0                	cmp    %edx,%eax
f0101598:	75 f2                	jne    f010158c <mem_init+0x340>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010159a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010159d:	a3 20 bd 19 f0       	mov    %eax,0xf019bd20

	// free the pages we took
	page_free(pp0);
f01015a2:	83 ec 0c             	sub    $0xc,%esp
f01015a5:	56                   	push   %esi
f01015a6:	e8 ea f9 ff ff       	call   f0100f95 <page_free>
	page_free(pp1);
f01015ab:	89 3c 24             	mov    %edi,(%esp)
f01015ae:	e8 e2 f9 ff ff       	call   f0100f95 <page_free>
	page_free(pp2);
f01015b3:	83 c4 04             	add    $0x4,%esp
f01015b6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015b9:	e8 d7 f9 ff ff       	call   f0100f95 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015be:	a1 20 bd 19 f0       	mov    0xf019bd20,%eax
f01015c3:	83 c4 10             	add    $0x10,%esp
f01015c6:	e9 e9 01 00 00       	jmp    f01017b4 <mem_init+0x568>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015cb:	68 c7 5a 10 f0       	push   $0xf0105ac7
f01015d0:	68 f7 59 10 f0       	push   $0xf01059f7
f01015d5:	68 c3 02 00 00       	push   $0x2c3
f01015da:	68 d1 59 10 f0       	push   $0xf01059d1
f01015df:	e8 bc ea ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01015e4:	68 dd 5a 10 f0       	push   $0xf0105add
f01015e9:	68 f7 59 10 f0       	push   $0xf01059f7
f01015ee:	68 c4 02 00 00       	push   $0x2c4
f01015f3:	68 d1 59 10 f0       	push   $0xf01059d1
f01015f8:	e8 a3 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01015fd:	68 f3 5a 10 f0       	push   $0xf0105af3
f0101602:	68 f7 59 10 f0       	push   $0xf01059f7
f0101607:	68 c5 02 00 00       	push   $0x2c5
f010160c:	68 d1 59 10 f0       	push   $0xf01059d1
f0101611:	e8 8a ea ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101616:	68 09 5b 10 f0       	push   $0xf0105b09
f010161b:	68 f7 59 10 f0       	push   $0xf01059f7
f0101620:	68 c8 02 00 00       	push   $0x2c8
f0101625:	68 d1 59 10 f0       	push   $0xf01059d1
f010162a:	e8 71 ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010162f:	68 7c 53 10 f0       	push   $0xf010537c
f0101634:	68 f7 59 10 f0       	push   $0xf01059f7
f0101639:	68 c9 02 00 00       	push   $0x2c9
f010163e:	68 d1 59 10 f0       	push   $0xf01059d1
f0101643:	e8 58 ea ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101648:	68 1b 5b 10 f0       	push   $0xf0105b1b
f010164d:	68 f7 59 10 f0       	push   $0xf01059f7
f0101652:	68 ca 02 00 00       	push   $0x2ca
f0101657:	68 d1 59 10 f0       	push   $0xf01059d1
f010165c:	e8 3f ea ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101661:	68 38 5b 10 f0       	push   $0xf0105b38
f0101666:	68 f7 59 10 f0       	push   $0xf01059f7
f010166b:	68 cb 02 00 00       	push   $0x2cb
f0101670:	68 d1 59 10 f0       	push   $0xf01059d1
f0101675:	e8 26 ea ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010167a:	68 55 5b 10 f0       	push   $0xf0105b55
f010167f:	68 f7 59 10 f0       	push   $0xf01059f7
f0101684:	68 cc 02 00 00       	push   $0x2cc
f0101689:	68 d1 59 10 f0       	push   $0xf01059d1
f010168e:	e8 0d ea ff ff       	call   f01000a0 <_panic>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f0101693:	68 72 5b 10 f0       	push   $0xf0105b72
f0101698:	68 f7 59 10 f0       	push   $0xf01059f7
f010169d:	68 d3 02 00 00       	push   $0x2d3
f01016a2:	68 d1 59 10 f0       	push   $0xf01059d1
f01016a7:	e8 f4 e9 ff ff       	call   f01000a0 <_panic>
	// free and re-allocate?
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016ac:	68 c7 5a 10 f0       	push   $0xf0105ac7
f01016b1:	68 f7 59 10 f0       	push   $0xf01059f7
f01016b6:	68 da 02 00 00       	push   $0x2da
f01016bb:	68 d1 59 10 f0       	push   $0xf01059d1
f01016c0:	e8 db e9 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01016c5:	68 dd 5a 10 f0       	push   $0xf0105add
f01016ca:	68 f7 59 10 f0       	push   $0xf01059f7
f01016cf:	68 db 02 00 00       	push   $0x2db
f01016d4:	68 d1 59 10 f0       	push   $0xf01059d1
f01016d9:	e8 c2 e9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01016de:	68 f3 5a 10 f0       	push   $0xf0105af3
f01016e3:	68 f7 59 10 f0       	push   $0xf01059f7
f01016e8:	68 dc 02 00 00       	push   $0x2dc
f01016ed:	68 d1 59 10 f0       	push   $0xf01059d1
f01016f2:	e8 a9 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016f7:	68 09 5b 10 f0       	push   $0xf0105b09
f01016fc:	68 f7 59 10 f0       	push   $0xf01059f7
f0101701:	68 de 02 00 00       	push   $0x2de
f0101706:	68 d1 59 10 f0       	push   $0xf01059d1
f010170b:	e8 90 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101710:	68 7c 53 10 f0       	push   $0xf010537c
f0101715:	68 f7 59 10 f0       	push   $0xf01059f7
f010171a:	68 df 02 00 00       	push   $0x2df
f010171f:	68 d1 59 10 f0       	push   $0xf01059d1
f0101724:	e8 77 e9 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101729:	68 72 5b 10 f0       	push   $0xf0105b72
f010172e:	68 f7 59 10 f0       	push   $0xf01059f7
f0101733:	68 e0 02 00 00       	push   $0x2e0
f0101738:	68 d1 59 10 f0       	push   $0xf01059d1
f010173d:	e8 5e e9 ff ff       	call   f01000a0 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101742:	50                   	push   %eax
f0101743:	68 f0 51 10 f0       	push   $0xf01051f0
f0101748:	6a 56                	push   $0x56
f010174a:	68 dd 59 10 f0       	push   $0xf01059dd
f010174f:	e8 4c e9 ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101754:	68 81 5b 10 f0       	push   $0xf0105b81
f0101759:	68 f7 59 10 f0       	push   $0xf01059f7
f010175e:	68 e5 02 00 00       	push   $0x2e5
f0101763:	68 d1 59 10 f0       	push   $0xf01059d1
f0101768:	e8 33 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f010176d:	68 9f 5b 10 f0       	push   $0xf0105b9f
f0101772:	68 f7 59 10 f0       	push   $0xf01059f7
f0101777:	68 e6 02 00 00       	push   $0x2e6
f010177c:	68 d1 59 10 f0       	push   $0xf01059d1
f0101781:	e8 1a e9 ff ff       	call   f01000a0 <_panic>
f0101786:	52                   	push   %edx
f0101787:	68 f0 51 10 f0       	push   $0xf01051f0
f010178c:	6a 56                	push   $0x56
f010178e:	68 dd 59 10 f0       	push   $0xf01059dd
f0101793:	e8 08 e9 ff ff       	call   f01000a0 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101798:	68 af 5b 10 f0       	push   $0xf0105baf
f010179d:	68 f7 59 10 f0       	push   $0xf01059f7
f01017a2:	68 e9 02 00 00       	push   $0x2e9
f01017a7:	68 d1 59 10 f0       	push   $0xf01059d1
f01017ac:	e8 ef e8 ff ff       	call   f01000a0 <_panic>
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
f01017b1:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017b2:	8b 00                	mov    (%eax),%eax
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	75 f9                	jne    f01017b1 <mem_init+0x565>
		--nfree;
	assert(nfree == 0);
f01017b8:	85 db                	test   %ebx,%ebx
f01017ba:	0f 85 98 07 00 00    	jne    f0101f58 <mem_init+0xd0c>

	cprintf("check_page_alloc() succeeded!\n");
f01017c0:	83 ec 0c             	sub    $0xc,%esp
f01017c3:	68 9c 53 10 f0       	push   $0xf010539c
f01017c8:	e8 68 1b 00 00       	call   f0103335 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017d4:	e8 4a f7 ff ff       	call   f0100f23 <page_alloc>
f01017d9:	89 c7                	mov    %eax,%edi
f01017db:	83 c4 10             	add    $0x10,%esp
f01017de:	85 c0                	test   %eax,%eax
f01017e0:	0f 84 8b 07 00 00    	je     f0101f71 <mem_init+0xd25>
	assert((pp1 = page_alloc(0)));
f01017e6:	83 ec 0c             	sub    $0xc,%esp
f01017e9:	6a 00                	push   $0x0
f01017eb:	e8 33 f7 ff ff       	call   f0100f23 <page_alloc>
f01017f0:	89 c3                	mov    %eax,%ebx
f01017f2:	83 c4 10             	add    $0x10,%esp
f01017f5:	85 c0                	test   %eax,%eax
f01017f7:	0f 84 8d 07 00 00    	je     f0101f8a <mem_init+0xd3e>
	assert((pp2 = page_alloc(0)));
f01017fd:	83 ec 0c             	sub    $0xc,%esp
f0101800:	6a 00                	push   $0x0
f0101802:	e8 1c f7 ff ff       	call   f0100f23 <page_alloc>
f0101807:	89 c6                	mov    %eax,%esi
f0101809:	83 c4 10             	add    $0x10,%esp
f010180c:	85 c0                	test   %eax,%eax
f010180e:	0f 84 8f 07 00 00    	je     f0101fa3 <mem_init+0xd57>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101814:	39 df                	cmp    %ebx,%edi
f0101816:	0f 84 a0 07 00 00    	je     f0101fbc <mem_init+0xd70>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010181c:	39 c3                	cmp    %eax,%ebx
f010181e:	0f 84 b1 07 00 00    	je     f0101fd5 <mem_init+0xd89>
f0101824:	39 c7                	cmp    %eax,%edi
f0101826:	0f 84 a9 07 00 00    	je     f0101fd5 <mem_init+0xd89>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010182c:	a1 20 bd 19 f0       	mov    0xf019bd20,%eax
f0101831:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101834:	c7 05 20 bd 19 f0 00 	movl   $0x0,0xf019bd20
f010183b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010183e:	83 ec 0c             	sub    $0xc,%esp
f0101841:	6a 00                	push   $0x0
f0101843:	e8 db f6 ff ff       	call   f0100f23 <page_alloc>
f0101848:	83 c4 10             	add    $0x10,%esp
f010184b:	85 c0                	test   %eax,%eax
f010184d:	0f 85 9b 07 00 00    	jne    f0101fee <mem_init+0xda2>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101853:	83 ec 04             	sub    $0x4,%esp
f0101856:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101859:	50                   	push   %eax
f010185a:	6a 00                	push   $0x0
f010185c:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101862:	e8 e7 f8 ff ff       	call   f010114e <page_lookup>
f0101867:	83 c4 10             	add    $0x10,%esp
f010186a:	85 c0                	test   %eax,%eax
f010186c:	0f 85 95 07 00 00    	jne    f0102007 <mem_init+0xdbb>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101872:	6a 02                	push   $0x2
f0101874:	6a 00                	push   $0x0
f0101876:	53                   	push   %ebx
f0101877:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f010187d:	e8 63 f9 ff ff       	call   f01011e5 <page_insert>
f0101882:	83 c4 10             	add    $0x10,%esp
f0101885:	85 c0                	test   %eax,%eax
f0101887:	0f 89 93 07 00 00    	jns    f0102020 <mem_init+0xdd4>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010188d:	83 ec 0c             	sub    $0xc,%esp
f0101890:	57                   	push   %edi
f0101891:	e8 ff f6 ff ff       	call   f0100f95 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101896:	6a 02                	push   $0x2
f0101898:	6a 00                	push   $0x0
f010189a:	53                   	push   %ebx
f010189b:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f01018a1:	e8 3f f9 ff ff       	call   f01011e5 <page_insert>
f01018a6:	83 c4 20             	add    $0x20,%esp
f01018a9:	85 c0                	test   %eax,%eax
f01018ab:	0f 85 88 07 00 00    	jne    f0102039 <mem_init+0xded>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018b1:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f01018b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b9:	8b 0d ec c9 19 f0    	mov    0xf019c9ec,%ecx
f01018bf:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01018c2:	8b 00                	mov    (%eax),%eax
f01018c4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018c7:	89 c2                	mov    %eax,%edx
f01018c9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018cf:	89 f8                	mov    %edi,%eax
f01018d1:	29 c8                	sub    %ecx,%eax
f01018d3:	c1 f8 03             	sar    $0x3,%eax
f01018d6:	c1 e0 0c             	shl    $0xc,%eax
f01018d9:	39 c2                	cmp    %eax,%edx
f01018db:	0f 85 71 07 00 00    	jne    f0102052 <mem_init+0xe06>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01018e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018e9:	e8 fa f1 ff ff       	call   f0100ae8 <check_va2pa>
f01018ee:	89 da                	mov    %ebx,%edx
f01018f0:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01018f3:	c1 fa 03             	sar    $0x3,%edx
f01018f6:	c1 e2 0c             	shl    $0xc,%edx
f01018f9:	39 d0                	cmp    %edx,%eax
f01018fb:	0f 85 6a 07 00 00    	jne    f010206b <mem_init+0xe1f>
	assert(pp1->pp_ref == 1);
f0101901:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101906:	0f 85 78 07 00 00    	jne    f0102084 <mem_init+0xe38>
	assert(pp0->pp_ref == 1);
f010190c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101911:	0f 85 86 07 00 00    	jne    f010209d <mem_init+0xe51>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101917:	6a 02                	push   $0x2
f0101919:	68 00 10 00 00       	push   $0x1000
f010191e:	56                   	push   %esi
f010191f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101922:	e8 be f8 ff ff       	call   f01011e5 <page_insert>
f0101927:	83 c4 10             	add    $0x10,%esp
f010192a:	85 c0                	test   %eax,%eax
f010192c:	0f 85 84 07 00 00    	jne    f01020b6 <mem_init+0xe6a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101932:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101937:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f010193c:	e8 a7 f1 ff ff       	call   f0100ae8 <check_va2pa>
f0101941:	89 f2                	mov    %esi,%edx
f0101943:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f0101949:	c1 fa 03             	sar    $0x3,%edx
f010194c:	c1 e2 0c             	shl    $0xc,%edx
f010194f:	39 d0                	cmp    %edx,%eax
f0101951:	0f 85 78 07 00 00    	jne    f01020cf <mem_init+0xe83>
	assert(pp2->pp_ref == 1);
f0101957:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010195c:	0f 85 86 07 00 00    	jne    f01020e8 <mem_init+0xe9c>

	// should be no free memory
	assert(!page_alloc(0));
f0101962:	83 ec 0c             	sub    $0xc,%esp
f0101965:	6a 00                	push   $0x0
f0101967:	e8 b7 f5 ff ff       	call   f0100f23 <page_alloc>
f010196c:	83 c4 10             	add    $0x10,%esp
f010196f:	85 c0                	test   %eax,%eax
f0101971:	0f 85 8a 07 00 00    	jne    f0102101 <mem_init+0xeb5>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101977:	6a 02                	push   $0x2
f0101979:	68 00 10 00 00       	push   $0x1000
f010197e:	56                   	push   %esi
f010197f:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101985:	e8 5b f8 ff ff       	call   f01011e5 <page_insert>
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	85 c0                	test   %eax,%eax
f010198f:	0f 85 85 07 00 00    	jne    f010211a <mem_init+0xece>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101995:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199a:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f010199f:	e8 44 f1 ff ff       	call   f0100ae8 <check_va2pa>
f01019a4:	89 f2                	mov    %esi,%edx
f01019a6:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f01019ac:	c1 fa 03             	sar    $0x3,%edx
f01019af:	c1 e2 0c             	shl    $0xc,%edx
f01019b2:	39 d0                	cmp    %edx,%eax
f01019b4:	0f 85 79 07 00 00    	jne    f0102133 <mem_init+0xee7>
	assert(pp2->pp_ref == 1);
f01019ba:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019bf:	0f 85 87 07 00 00    	jne    f010214c <mem_init+0xf00>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019c5:	83 ec 0c             	sub    $0xc,%esp
f01019c8:	6a 00                	push   $0x0
f01019ca:	e8 54 f5 ff ff       	call   f0100f23 <page_alloc>
f01019cf:	83 c4 10             	add    $0x10,%esp
f01019d2:	85 c0                	test   %eax,%eax
f01019d4:	0f 85 8b 07 00 00    	jne    f0102165 <mem_init+0xf19>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019da:	8b 15 e8 c9 19 f0    	mov    0xf019c9e8,%edx
f01019e0:	8b 02                	mov    (%edx),%eax
f01019e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019e7:	89 c1                	mov    %eax,%ecx
f01019e9:	c1 e9 0c             	shr    $0xc,%ecx
f01019ec:	3b 0d e4 c9 19 f0    	cmp    0xf019c9e4,%ecx
f01019f2:	0f 83 86 07 00 00    	jae    f010217e <mem_init+0xf32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01019f8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a00:	83 ec 04             	sub    $0x4,%esp
f0101a03:	6a 00                	push   $0x0
f0101a05:	68 00 10 00 00       	push   $0x1000
f0101a0a:	52                   	push   %edx
f0101a0b:	e8 fd f5 ff ff       	call   f010100d <pgdir_walk>
f0101a10:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a13:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a16:	83 c4 10             	add    $0x10,%esp
f0101a19:	39 d0                	cmp    %edx,%eax
f0101a1b:	0f 85 72 07 00 00    	jne    f0102193 <mem_init+0xf47>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a21:	6a 06                	push   $0x6
f0101a23:	68 00 10 00 00       	push   $0x1000
f0101a28:	56                   	push   %esi
f0101a29:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101a2f:	e8 b1 f7 ff ff       	call   f01011e5 <page_insert>
f0101a34:	83 c4 10             	add    $0x10,%esp
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	0f 85 6d 07 00 00    	jne    f01021ac <mem_init+0xf60>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3f:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101a44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a47:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a4c:	e8 97 f0 ff ff       	call   f0100ae8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a51:	89 f2                	mov    %esi,%edx
f0101a53:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f0101a59:	c1 fa 03             	sar    $0x3,%edx
f0101a5c:	c1 e2 0c             	shl    $0xc,%edx
f0101a5f:	39 d0                	cmp    %edx,%eax
f0101a61:	0f 85 5e 07 00 00    	jne    f01021c5 <mem_init+0xf79>
	assert(pp2->pp_ref == 1);
f0101a67:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a6c:	0f 85 6c 07 00 00    	jne    f01021de <mem_init+0xf92>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a72:	83 ec 04             	sub    $0x4,%esp
f0101a75:	6a 00                	push   $0x0
f0101a77:	68 00 10 00 00       	push   $0x1000
f0101a7c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a7f:	e8 89 f5 ff ff       	call   f010100d <pgdir_walk>
f0101a84:	83 c4 10             	add    $0x10,%esp
f0101a87:	f6 00 04             	testb  $0x4,(%eax)
f0101a8a:	0f 84 67 07 00 00    	je     f01021f7 <mem_init+0xfab>
	assert(kern_pgdir[0] & PTE_U);
f0101a90:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101a95:	f6 00 04             	testb  $0x4,(%eax)
f0101a98:	0f 84 72 07 00 00    	je     f0102210 <mem_init+0xfc4>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a9e:	6a 02                	push   $0x2
f0101aa0:	68 00 10 00 00       	push   $0x1000
f0101aa5:	56                   	push   %esi
f0101aa6:	50                   	push   %eax
f0101aa7:	e8 39 f7 ff ff       	call   f01011e5 <page_insert>
f0101aac:	83 c4 10             	add    $0x10,%esp
f0101aaf:	85 c0                	test   %eax,%eax
f0101ab1:	0f 85 72 07 00 00    	jne    f0102229 <mem_init+0xfdd>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ab7:	83 ec 04             	sub    $0x4,%esp
f0101aba:	6a 00                	push   $0x0
f0101abc:	68 00 10 00 00       	push   $0x1000
f0101ac1:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101ac7:	e8 41 f5 ff ff       	call   f010100d <pgdir_walk>
f0101acc:	83 c4 10             	add    $0x10,%esp
f0101acf:	f6 00 02             	testb  $0x2,(%eax)
f0101ad2:	0f 84 6a 07 00 00    	je     f0102242 <mem_init+0xff6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ad8:	83 ec 04             	sub    $0x4,%esp
f0101adb:	6a 00                	push   $0x0
f0101add:	68 00 10 00 00       	push   $0x1000
f0101ae2:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101ae8:	e8 20 f5 ff ff       	call   f010100d <pgdir_walk>
f0101aed:	83 c4 10             	add    $0x10,%esp
f0101af0:	f6 00 04             	testb  $0x4,(%eax)
f0101af3:	0f 85 62 07 00 00    	jne    f010225b <mem_init+0x100f>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101af9:	6a 02                	push   $0x2
f0101afb:	68 00 00 40 00       	push   $0x400000
f0101b00:	57                   	push   %edi
f0101b01:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101b07:	e8 d9 f6 ff ff       	call   f01011e5 <page_insert>
f0101b0c:	83 c4 10             	add    $0x10,%esp
f0101b0f:	85 c0                	test   %eax,%eax
f0101b11:	0f 89 5d 07 00 00    	jns    f0102274 <mem_init+0x1028>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	68 00 10 00 00       	push   $0x1000
f0101b1e:	53                   	push   %ebx
f0101b1f:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101b25:	e8 bb f6 ff ff       	call   f01011e5 <page_insert>
f0101b2a:	83 c4 10             	add    $0x10,%esp
f0101b2d:	85 c0                	test   %eax,%eax
f0101b2f:	0f 85 58 07 00 00    	jne    f010228d <mem_init+0x1041>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b35:	83 ec 04             	sub    $0x4,%esp
f0101b38:	6a 00                	push   $0x0
f0101b3a:	68 00 10 00 00       	push   $0x1000
f0101b3f:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101b45:	e8 c3 f4 ff ff       	call   f010100d <pgdir_walk>
f0101b4a:	83 c4 10             	add    $0x10,%esp
f0101b4d:	f6 00 04             	testb  $0x4,(%eax)
f0101b50:	0f 85 50 07 00 00    	jne    f01022a6 <mem_init+0x105a>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b56:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101b5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b63:	e8 80 ef ff ff       	call   f0100ae8 <check_va2pa>
f0101b68:	89 c1                	mov    %eax,%ecx
f0101b6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b6d:	89 d8                	mov    %ebx,%eax
f0101b6f:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0101b75:	c1 f8 03             	sar    $0x3,%eax
f0101b78:	c1 e0 0c             	shl    $0xc,%eax
f0101b7b:	39 c1                	cmp    %eax,%ecx
f0101b7d:	0f 85 3c 07 00 00    	jne    f01022bf <mem_init+0x1073>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b83:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b8b:	e8 58 ef ff ff       	call   f0100ae8 <check_va2pa>
f0101b90:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101b93:	0f 85 3f 07 00 00    	jne    f01022d8 <mem_init+0x108c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101b99:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101b9e:	0f 85 4d 07 00 00    	jne    f01022f1 <mem_init+0x10a5>
	assert(pp2->pp_ref == 0);
f0101ba4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ba9:	0f 85 5b 07 00 00    	jne    f010230a <mem_init+0x10be>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101baf:	83 ec 0c             	sub    $0xc,%esp
f0101bb2:	6a 00                	push   $0x0
f0101bb4:	e8 6a f3 ff ff       	call   f0100f23 <page_alloc>
f0101bb9:	83 c4 10             	add    $0x10,%esp
f0101bbc:	85 c0                	test   %eax,%eax
f0101bbe:	0f 84 5f 07 00 00    	je     f0102323 <mem_init+0x10d7>
f0101bc4:	39 c6                	cmp    %eax,%esi
f0101bc6:	0f 85 57 07 00 00    	jne    f0102323 <mem_init+0x10d7>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101bcc:	83 ec 08             	sub    $0x8,%esp
f0101bcf:	6a 00                	push   $0x0
f0101bd1:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101bd7:	e8 cc f5 ff ff       	call   f01011a8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101bdc:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101be1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101be4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be9:	e8 fa ee ff ff       	call   f0100ae8 <check_va2pa>
f0101bee:	83 c4 10             	add    $0x10,%esp
f0101bf1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101bf4:	0f 85 42 07 00 00    	jne    f010233c <mem_init+0x10f0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bfa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c02:	e8 e1 ee ff ff       	call   f0100ae8 <check_va2pa>
f0101c07:	89 da                	mov    %ebx,%edx
f0101c09:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f0101c0f:	c1 fa 03             	sar    $0x3,%edx
f0101c12:	c1 e2 0c             	shl    $0xc,%edx
f0101c15:	39 d0                	cmp    %edx,%eax
f0101c17:	0f 85 38 07 00 00    	jne    f0102355 <mem_init+0x1109>
	assert(pp1->pp_ref == 1);
f0101c1d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c22:	0f 85 46 07 00 00    	jne    f010236e <mem_init+0x1122>
	assert(pp2->pp_ref == 0);
f0101c28:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c2d:	0f 85 54 07 00 00    	jne    f0102387 <mem_init+0x113b>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101c33:	6a 00                	push   $0x0
f0101c35:	68 00 10 00 00       	push   $0x1000
f0101c3a:	53                   	push   %ebx
f0101c3b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c3e:	e8 a2 f5 ff ff       	call   f01011e5 <page_insert>
f0101c43:	83 c4 10             	add    $0x10,%esp
f0101c46:	85 c0                	test   %eax,%eax
f0101c48:	0f 85 52 07 00 00    	jne    f01023a0 <mem_init+0x1154>
	assert(pp1->pp_ref);
f0101c4e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c53:	0f 84 60 07 00 00    	je     f01023b9 <mem_init+0x116d>
	assert(pp1->pp_link == NULL);
f0101c59:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101c5c:	0f 85 70 07 00 00    	jne    f01023d2 <mem_init+0x1186>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101c62:	83 ec 08             	sub    $0x8,%esp
f0101c65:	68 00 10 00 00       	push   $0x1000
f0101c6a:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101c70:	e8 33 f5 ff ff       	call   f01011a8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c75:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101c7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c82:	e8 61 ee ff ff       	call   f0100ae8 <check_va2pa>
f0101c87:	83 c4 10             	add    $0x10,%esp
f0101c8a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c8d:	0f 85 58 07 00 00    	jne    f01023eb <mem_init+0x119f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101c93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c9b:	e8 48 ee ff ff       	call   f0100ae8 <check_va2pa>
f0101ca0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ca3:	0f 85 5b 07 00 00    	jne    f0102404 <mem_init+0x11b8>
	assert(pp1->pp_ref == 0);
f0101ca9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cae:	0f 85 69 07 00 00    	jne    f010241d <mem_init+0x11d1>
	assert(pp2->pp_ref == 0);
f0101cb4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cb9:	0f 85 77 07 00 00    	jne    f0102436 <mem_init+0x11ea>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101cbf:	83 ec 0c             	sub    $0xc,%esp
f0101cc2:	6a 00                	push   $0x0
f0101cc4:	e8 5a f2 ff ff       	call   f0100f23 <page_alloc>
f0101cc9:	83 c4 10             	add    $0x10,%esp
f0101ccc:	85 c0                	test   %eax,%eax
f0101cce:	0f 84 7b 07 00 00    	je     f010244f <mem_init+0x1203>
f0101cd4:	39 c3                	cmp    %eax,%ebx
f0101cd6:	0f 85 73 07 00 00    	jne    f010244f <mem_init+0x1203>

	// should be no free memory
	assert(!page_alloc(0));
f0101cdc:	83 ec 0c             	sub    $0xc,%esp
f0101cdf:	6a 00                	push   $0x0
f0101ce1:	e8 3d f2 ff ff       	call   f0100f23 <page_alloc>
f0101ce6:	83 c4 10             	add    $0x10,%esp
f0101ce9:	85 c0                	test   %eax,%eax
f0101ceb:	0f 85 77 07 00 00    	jne    f0102468 <mem_init+0x121c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cf1:	8b 0d e8 c9 19 f0    	mov    0xf019c9e8,%ecx
f0101cf7:	8b 11                	mov    (%ecx),%edx
f0101cf9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cff:	89 f8                	mov    %edi,%eax
f0101d01:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0101d07:	c1 f8 03             	sar    $0x3,%eax
f0101d0a:	c1 e0 0c             	shl    $0xc,%eax
f0101d0d:	39 c2                	cmp    %eax,%edx
f0101d0f:	0f 85 6c 07 00 00    	jne    f0102481 <mem_init+0x1235>
	kern_pgdir[0] = 0;
f0101d15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d1b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d20:	0f 85 74 07 00 00    	jne    f010249a <mem_init+0x124e>
	pp0->pp_ref = 0;
f0101d26:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101d2c:	83 ec 0c             	sub    $0xc,%esp
f0101d2f:	57                   	push   %edi
f0101d30:	e8 60 f2 ff ff       	call   f0100f95 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101d35:	83 c4 0c             	add    $0xc,%esp
f0101d38:	6a 01                	push   $0x1
f0101d3a:	68 00 10 40 00       	push   $0x401000
f0101d3f:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101d45:	e8 c3 f2 ff ff       	call   f010100d <pgdir_walk>
f0101d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101d50:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101d55:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d58:	8b 50 04             	mov    0x4(%eax),%edx
f0101d5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d61:	a1 e4 c9 19 f0       	mov    0xf019c9e4,%eax
f0101d66:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d69:	89 d1                	mov    %edx,%ecx
f0101d6b:	c1 e9 0c             	shr    $0xc,%ecx
f0101d6e:	83 c4 10             	add    $0x10,%esp
f0101d71:	39 c1                	cmp    %eax,%ecx
f0101d73:	0f 83 3a 07 00 00    	jae    f01024b3 <mem_init+0x1267>
	assert(ptep == ptep1 + PTX(va));
f0101d79:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101d7f:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101d82:	0f 85 40 07 00 00    	jne    f01024c8 <mem_init+0x127c>
	kern_pgdir[PDX(va)] = 0;
f0101d88:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d8b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101d92:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d98:	89 f8                	mov    %edi,%eax
f0101d9a:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0101da0:	c1 f8 03             	sar    $0x3,%eax
f0101da3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101da6:	89 c2                	mov    %eax,%edx
f0101da8:	c1 ea 0c             	shr    $0xc,%edx
f0101dab:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101dae:	0f 86 2d 07 00 00    	jbe    f01024e1 <mem_init+0x1295>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101db4:	83 ec 04             	sub    $0x4,%esp
f0101db7:	68 00 10 00 00       	push   $0x1000
f0101dbc:	68 ff 00 00 00       	push   $0xff
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101dc1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dc6:	50                   	push   %eax
f0101dc7:	e8 bd 29 00 00       	call   f0104789 <memset>
	page_free(pp0);
f0101dcc:	89 3c 24             	mov    %edi,(%esp)
f0101dcf:	e8 c1 f1 ff ff       	call   f0100f95 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101dd4:	83 c4 0c             	add    $0xc,%esp
f0101dd7:	6a 01                	push   $0x1
f0101dd9:	6a 00                	push   $0x0
f0101ddb:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0101de1:	e8 27 f2 ff ff       	call   f010100d <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101de6:	89 fa                	mov    %edi,%edx
f0101de8:	2b 15 ec c9 19 f0    	sub    0xf019c9ec,%edx
f0101dee:	c1 fa 03             	sar    $0x3,%edx
f0101df1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101df4:	89 d0                	mov    %edx,%eax
f0101df6:	c1 e8 0c             	shr    $0xc,%eax
f0101df9:	83 c4 10             	add    $0x10,%esp
f0101dfc:	3b 05 e4 c9 19 f0    	cmp    0xf019c9e4,%eax
f0101e02:	0f 83 eb 06 00 00    	jae    f01024f3 <mem_init+0x12a7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0101e08:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e11:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e17:	f6 00 01             	testb  $0x1,(%eax)
f0101e1a:	0f 85 e5 06 00 00    	jne    f0102505 <mem_init+0x12b9>
f0101e20:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101e23:	39 d0                	cmp    %edx,%eax
f0101e25:	75 f0                	jne    f0101e17 <mem_init+0xbcb>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101e27:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101e2c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101e32:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0101e38:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101e3b:	a3 20 bd 19 f0       	mov    %eax,0xf019bd20

	// free the pages we took
	page_free(pp0);
f0101e40:	83 ec 0c             	sub    $0xc,%esp
f0101e43:	57                   	push   %edi
f0101e44:	e8 4c f1 ff ff       	call   f0100f95 <page_free>
	page_free(pp1);
f0101e49:	89 1c 24             	mov    %ebx,(%esp)
f0101e4c:	e8 44 f1 ff ff       	call   f0100f95 <page_free>
	page_free(pp2);
f0101e51:	89 34 24             	mov    %esi,(%esp)
f0101e54:	e8 3c f1 ff ff       	call   f0100f95 <page_free>

	cprintf("check_page() succeeded!\n");
f0101e59:	c7 04 24 90 5c 10 f0 	movl   $0xf0105c90,(%esp)
f0101e60:	e8 d0 14 00 00       	call   f0103335 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0101e65:	a1 ec c9 19 f0       	mov    0xf019c9ec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101e6a:	83 c4 10             	add    $0x10,%esp
f0101e6d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e72:	0f 86 a6 06 00 00    	jbe    f010251e <mem_init+0x12d2>
f0101e78:	8b 3d e4 c9 19 f0    	mov    0xf019c9e4,%edi
f0101e7e:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0101e85:	83 ec 08             	sub    $0x8,%esp
f0101e88:	6a 05                	push   $0x5
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101e8a:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e8f:	50                   	push   %eax
f0101e90:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101e95:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101e9a:	e8 51 f2 ff ff       	call   f01010f0 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir, (uintptr_t) UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U | PTE_P);
f0101e9f:	a1 2c bd 19 f0       	mov    0xf019bd2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101ea4:	83 c4 10             	add    $0x10,%esp
f0101ea7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101eac:	0f 86 81 06 00 00    	jbe    f0102533 <mem_init+0x12e7>
f0101eb2:	83 ec 08             	sub    $0x8,%esp
f0101eb5:	6a 05                	push   $0x5
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101eb7:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ebc:	50                   	push   %eax
f0101ebd:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0101ec2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101ec7:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101ecc:	e8 1f f2 ff ff       	call   f01010f0 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101ed1:	83 c4 10             	add    $0x10,%esp
f0101ed4:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f0101ed9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101ede:	0f 86 64 06 00 00    	jbe    f0102548 <mem_init+0x12fc>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0101ee4:	83 ec 08             	sub    $0x8,%esp
f0101ee7:	6a 03                	push   $0x3
f0101ee9:	68 00 20 11 00       	push   $0x112000
f0101eee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101ef3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101ef8:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101efd:	e8 ee f1 ff ff       	call   f01010f0 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0101f02:	83 c4 08             	add    $0x8,%esp
f0101f05:	6a 03                	push   $0x3
f0101f07:	6a 00                	push   $0x0
f0101f09:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101f0e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101f13:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
f0101f18:	e8 d3 f1 ff ff       	call   f01010f0 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0101f1d:	8b 1d e8 c9 19 f0    	mov    0xf019c9e8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101f23:	a1 e4 c9 19 f0       	mov    0xf019c9e4,%eax
f0101f28:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f2b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101f37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101f3a:	a1 ec c9 19 f0       	mov    0xf019c9ec,%eax
f0101f3f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101f42:	89 45 d0             	mov    %eax,-0x30(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101f45:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101f4b:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101f4e:	be 00 00 00 00       	mov    $0x0,%esi
f0101f53:	e9 22 06 00 00       	jmp    f010257a <mem_init+0x132e>
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
	assert(nfree == 0);
f0101f58:	68 b9 5b 10 f0       	push   $0xf0105bb9
f0101f5d:	68 f7 59 10 f0       	push   $0xf01059f7
f0101f62:	68 f6 02 00 00       	push   $0x2f6
f0101f67:	68 d1 59 10 f0       	push   $0xf01059d1
f0101f6c:	e8 2f e1 ff ff       	call   f01000a0 <_panic>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f71:	68 c7 5a 10 f0       	push   $0xf0105ac7
f0101f76:	68 f7 59 10 f0       	push   $0xf01059f7
f0101f7b:	68 54 03 00 00       	push   $0x354
f0101f80:	68 d1 59 10 f0       	push   $0xf01059d1
f0101f85:	e8 16 e1 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f8a:	68 dd 5a 10 f0       	push   $0xf0105add
f0101f8f:	68 f7 59 10 f0       	push   $0xf01059f7
f0101f94:	68 55 03 00 00       	push   $0x355
f0101f99:	68 d1 59 10 f0       	push   $0xf01059d1
f0101f9e:	e8 fd e0 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fa3:	68 f3 5a 10 f0       	push   $0xf0105af3
f0101fa8:	68 f7 59 10 f0       	push   $0xf01059f7
f0101fad:	68 56 03 00 00       	push   $0x356
f0101fb2:	68 d1 59 10 f0       	push   $0xf01059d1
f0101fb7:	e8 e4 e0 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101fbc:	68 09 5b 10 f0       	push   $0xf0105b09
f0101fc1:	68 f7 59 10 f0       	push   $0xf01059f7
f0101fc6:	68 59 03 00 00       	push   $0x359
f0101fcb:	68 d1 59 10 f0       	push   $0xf01059d1
f0101fd0:	e8 cb e0 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fd5:	68 7c 53 10 f0       	push   $0xf010537c
f0101fda:	68 f7 59 10 f0       	push   $0xf01059f7
f0101fdf:	68 5a 03 00 00       	push   $0x35a
f0101fe4:	68 d1 59 10 f0       	push   $0xf01059d1
f0101fe9:	e8 b2 e0 ff ff       	call   f01000a0 <_panic>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f0101fee:	68 72 5b 10 f0       	push   $0xf0105b72
f0101ff3:	68 f7 59 10 f0       	push   $0xf01059f7
f0101ff8:	68 61 03 00 00       	push   $0x361
f0101ffd:	68 d1 59 10 f0       	push   $0xf01059d1
f0102002:	e8 99 e0 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102007:	68 bc 53 10 f0       	push   $0xf01053bc
f010200c:	68 f7 59 10 f0       	push   $0xf01059f7
f0102011:	68 64 03 00 00       	push   $0x364
f0102016:	68 d1 59 10 f0       	push   $0xf01059d1
f010201b:	e8 80 e0 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102020:	68 f4 53 10 f0       	push   $0xf01053f4
f0102025:	68 f7 59 10 f0       	push   $0xf01059f7
f010202a:	68 67 03 00 00       	push   $0x367
f010202f:	68 d1 59 10 f0       	push   $0xf01059d1
f0102034:	e8 67 e0 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102039:	68 24 54 10 f0       	push   $0xf0105424
f010203e:	68 f7 59 10 f0       	push   $0xf01059f7
f0102043:	68 6b 03 00 00       	push   $0x36b
f0102048:	68 d1 59 10 f0       	push   $0xf01059d1
f010204d:	e8 4e e0 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102052:	68 54 54 10 f0       	push   $0xf0105454
f0102057:	68 f7 59 10 f0       	push   $0xf01059f7
f010205c:	68 6c 03 00 00       	push   $0x36c
f0102061:	68 d1 59 10 f0       	push   $0xf01059d1
f0102066:	e8 35 e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010206b:	68 7c 54 10 f0       	push   $0xf010547c
f0102070:	68 f7 59 10 f0       	push   $0xf01059f7
f0102075:	68 6d 03 00 00       	push   $0x36d
f010207a:	68 d1 59 10 f0       	push   $0xf01059d1
f010207f:	e8 1c e0 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0102084:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0102089:	68 f7 59 10 f0       	push   $0xf01059f7
f010208e:	68 6e 03 00 00       	push   $0x36e
f0102093:	68 d1 59 10 f0       	push   $0xf01059d1
f0102098:	e8 03 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f010209d:	68 d5 5b 10 f0       	push   $0xf0105bd5
f01020a2:	68 f7 59 10 f0       	push   $0xf01059f7
f01020a7:	68 6f 03 00 00       	push   $0x36f
f01020ac:	68 d1 59 10 f0       	push   $0xf01059d1
f01020b1:	e8 ea df ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020b6:	68 ac 54 10 f0       	push   $0xf01054ac
f01020bb:	68 f7 59 10 f0       	push   $0xf01059f7
f01020c0:	68 72 03 00 00       	push   $0x372
f01020c5:	68 d1 59 10 f0       	push   $0xf01059d1
f01020ca:	e8 d1 df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020cf:	68 e8 54 10 f0       	push   $0xf01054e8
f01020d4:	68 f7 59 10 f0       	push   $0xf01059f7
f01020d9:	68 73 03 00 00       	push   $0x373
f01020de:	68 d1 59 10 f0       	push   $0xf01059d1
f01020e3:	e8 b8 df ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01020e8:	68 e6 5b 10 f0       	push   $0xf0105be6
f01020ed:	68 f7 59 10 f0       	push   $0xf01059f7
f01020f2:	68 74 03 00 00       	push   $0x374
f01020f7:	68 d1 59 10 f0       	push   $0xf01059d1
f01020fc:	e8 9f df ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102101:	68 72 5b 10 f0       	push   $0xf0105b72
f0102106:	68 f7 59 10 f0       	push   $0xf01059f7
f010210b:	68 77 03 00 00       	push   $0x377
f0102110:	68 d1 59 10 f0       	push   $0xf01059d1
f0102115:	e8 86 df ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010211a:	68 ac 54 10 f0       	push   $0xf01054ac
f010211f:	68 f7 59 10 f0       	push   $0xf01059f7
f0102124:	68 7a 03 00 00       	push   $0x37a
f0102129:	68 d1 59 10 f0       	push   $0xf01059d1
f010212e:	e8 6d df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102133:	68 e8 54 10 f0       	push   $0xf01054e8
f0102138:	68 f7 59 10 f0       	push   $0xf01059f7
f010213d:	68 7b 03 00 00       	push   $0x37b
f0102142:	68 d1 59 10 f0       	push   $0xf01059d1
f0102147:	e8 54 df ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010214c:	68 e6 5b 10 f0       	push   $0xf0105be6
f0102151:	68 f7 59 10 f0       	push   $0xf01059f7
f0102156:	68 7c 03 00 00       	push   $0x37c
f010215b:	68 d1 59 10 f0       	push   $0xf01059d1
f0102160:	e8 3b df ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102165:	68 72 5b 10 f0       	push   $0xf0105b72
f010216a:	68 f7 59 10 f0       	push   $0xf01059f7
f010216f:	68 80 03 00 00       	push   $0x380
f0102174:	68 d1 59 10 f0       	push   $0xf01059d1
f0102179:	e8 22 df ff ff       	call   f01000a0 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010217e:	50                   	push   %eax
f010217f:	68 f0 51 10 f0       	push   $0xf01051f0
f0102184:	68 83 03 00 00       	push   $0x383
f0102189:	68 d1 59 10 f0       	push   $0xf01059d1
f010218e:	e8 0d df ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102193:	68 18 55 10 f0       	push   $0xf0105518
f0102198:	68 f7 59 10 f0       	push   $0xf01059f7
f010219d:	68 84 03 00 00       	push   $0x384
f01021a2:	68 d1 59 10 f0       	push   $0xf01059d1
f01021a7:	e8 f4 de ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01021ac:	68 58 55 10 f0       	push   $0xf0105558
f01021b1:	68 f7 59 10 f0       	push   $0xf01059f7
f01021b6:	68 87 03 00 00       	push   $0x387
f01021bb:	68 d1 59 10 f0       	push   $0xf01059d1
f01021c0:	e8 db de ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021c5:	68 e8 54 10 f0       	push   $0xf01054e8
f01021ca:	68 f7 59 10 f0       	push   $0xf01059f7
f01021cf:	68 88 03 00 00       	push   $0x388
f01021d4:	68 d1 59 10 f0       	push   $0xf01059d1
f01021d9:	e8 c2 de ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01021de:	68 e6 5b 10 f0       	push   $0xf0105be6
f01021e3:	68 f7 59 10 f0       	push   $0xf01059f7
f01021e8:	68 89 03 00 00       	push   $0x389
f01021ed:	68 d1 59 10 f0       	push   $0xf01059d1
f01021f2:	e8 a9 de ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01021f7:	68 98 55 10 f0       	push   $0xf0105598
f01021fc:	68 f7 59 10 f0       	push   $0xf01059f7
f0102201:	68 8a 03 00 00       	push   $0x38a
f0102206:	68 d1 59 10 f0       	push   $0xf01059d1
f010220b:	e8 90 de ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102210:	68 f7 5b 10 f0       	push   $0xf0105bf7
f0102215:	68 f7 59 10 f0       	push   $0xf01059f7
f010221a:	68 8b 03 00 00       	push   $0x38b
f010221f:	68 d1 59 10 f0       	push   $0xf01059d1
f0102224:	e8 77 de ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102229:	68 ac 54 10 f0       	push   $0xf01054ac
f010222e:	68 f7 59 10 f0       	push   $0xf01059f7
f0102233:	68 8e 03 00 00       	push   $0x38e
f0102238:	68 d1 59 10 f0       	push   $0xf01059d1
f010223d:	e8 5e de ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102242:	68 cc 55 10 f0       	push   $0xf01055cc
f0102247:	68 f7 59 10 f0       	push   $0xf01059f7
f010224c:	68 8f 03 00 00       	push   $0x38f
f0102251:	68 d1 59 10 f0       	push   $0xf01059d1
f0102256:	e8 45 de ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010225b:	68 00 56 10 f0       	push   $0xf0105600
f0102260:	68 f7 59 10 f0       	push   $0xf01059f7
f0102265:	68 90 03 00 00       	push   $0x390
f010226a:	68 d1 59 10 f0       	push   $0xf01059d1
f010226f:	e8 2c de ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102274:	68 38 56 10 f0       	push   $0xf0105638
f0102279:	68 f7 59 10 f0       	push   $0xf01059f7
f010227e:	68 93 03 00 00       	push   $0x393
f0102283:	68 d1 59 10 f0       	push   $0xf01059d1
f0102288:	e8 13 de ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010228d:	68 70 56 10 f0       	push   $0xf0105670
f0102292:	68 f7 59 10 f0       	push   $0xf01059f7
f0102297:	68 96 03 00 00       	push   $0x396
f010229c:	68 d1 59 10 f0       	push   $0xf01059d1
f01022a1:	e8 fa dd ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022a6:	68 00 56 10 f0       	push   $0xf0105600
f01022ab:	68 f7 59 10 f0       	push   $0xf01059f7
f01022b0:	68 97 03 00 00       	push   $0x397
f01022b5:	68 d1 59 10 f0       	push   $0xf01059d1
f01022ba:	e8 e1 dd ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022bf:	68 ac 56 10 f0       	push   $0xf01056ac
f01022c4:	68 f7 59 10 f0       	push   $0xf01059f7
f01022c9:	68 9a 03 00 00       	push   $0x39a
f01022ce:	68 d1 59 10 f0       	push   $0xf01059d1
f01022d3:	e8 c8 dd ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022d8:	68 d8 56 10 f0       	push   $0xf01056d8
f01022dd:	68 f7 59 10 f0       	push   $0xf01059f7
f01022e2:	68 9b 03 00 00       	push   $0x39b
f01022e7:	68 d1 59 10 f0       	push   $0xf01059d1
f01022ec:	e8 af dd ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022f1:	68 0d 5c 10 f0       	push   $0xf0105c0d
f01022f6:	68 f7 59 10 f0       	push   $0xf01059f7
f01022fb:	68 9d 03 00 00       	push   $0x39d
f0102300:	68 d1 59 10 f0       	push   $0xf01059d1
f0102305:	e8 96 dd ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f010230a:	68 1e 5c 10 f0       	push   $0xf0105c1e
f010230f:	68 f7 59 10 f0       	push   $0xf01059f7
f0102314:	68 9e 03 00 00       	push   $0x39e
f0102319:	68 d1 59 10 f0       	push   $0xf01059d1
f010231e:	e8 7d dd ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102323:	68 08 57 10 f0       	push   $0xf0105708
f0102328:	68 f7 59 10 f0       	push   $0xf01059f7
f010232d:	68 a1 03 00 00       	push   $0x3a1
f0102332:	68 d1 59 10 f0       	push   $0xf01059d1
f0102337:	e8 64 dd ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010233c:	68 2c 57 10 f0       	push   $0xf010572c
f0102341:	68 f7 59 10 f0       	push   $0xf01059f7
f0102346:	68 a5 03 00 00       	push   $0x3a5
f010234b:	68 d1 59 10 f0       	push   $0xf01059d1
f0102350:	e8 4b dd ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102355:	68 d8 56 10 f0       	push   $0xf01056d8
f010235a:	68 f7 59 10 f0       	push   $0xf01059f7
f010235f:	68 a6 03 00 00       	push   $0x3a6
f0102364:	68 d1 59 10 f0       	push   $0xf01059d1
f0102369:	e8 32 dd ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010236e:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0102373:	68 f7 59 10 f0       	push   $0xf01059f7
f0102378:	68 a7 03 00 00       	push   $0x3a7
f010237d:	68 d1 59 10 f0       	push   $0xf01059d1
f0102382:	e8 19 dd ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0102387:	68 1e 5c 10 f0       	push   $0xf0105c1e
f010238c:	68 f7 59 10 f0       	push   $0xf01059f7
f0102391:	68 a8 03 00 00       	push   $0x3a8
f0102396:	68 d1 59 10 f0       	push   $0xf01059d1
f010239b:	e8 00 dd ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01023a0:	68 50 57 10 f0       	push   $0xf0105750
f01023a5:	68 f7 59 10 f0       	push   $0xf01059f7
f01023aa:	68 ab 03 00 00       	push   $0x3ab
f01023af:	68 d1 59 10 f0       	push   $0xf01059d1
f01023b4:	e8 e7 dc ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f01023b9:	68 2f 5c 10 f0       	push   $0xf0105c2f
f01023be:	68 f7 59 10 f0       	push   $0xf01059f7
f01023c3:	68 ac 03 00 00       	push   $0x3ac
f01023c8:	68 d1 59 10 f0       	push   $0xf01059d1
f01023cd:	e8 ce dc ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f01023d2:	68 3b 5c 10 f0       	push   $0xf0105c3b
f01023d7:	68 f7 59 10 f0       	push   $0xf01059f7
f01023dc:	68 ad 03 00 00       	push   $0x3ad
f01023e1:	68 d1 59 10 f0       	push   $0xf01059d1
f01023e6:	e8 b5 dc ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023eb:	68 2c 57 10 f0       	push   $0xf010572c
f01023f0:	68 f7 59 10 f0       	push   $0xf01059f7
f01023f5:	68 b1 03 00 00       	push   $0x3b1
f01023fa:	68 d1 59 10 f0       	push   $0xf01059d1
f01023ff:	e8 9c dc ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102404:	68 88 57 10 f0       	push   $0xf0105788
f0102409:	68 f7 59 10 f0       	push   $0xf01059f7
f010240e:	68 b2 03 00 00       	push   $0x3b2
f0102413:	68 d1 59 10 f0       	push   $0xf01059d1
f0102418:	e8 83 dc ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f010241d:	68 50 5c 10 f0       	push   $0xf0105c50
f0102422:	68 f7 59 10 f0       	push   $0xf01059f7
f0102427:	68 b3 03 00 00       	push   $0x3b3
f010242c:	68 d1 59 10 f0       	push   $0xf01059d1
f0102431:	e8 6a dc ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0102436:	68 1e 5c 10 f0       	push   $0xf0105c1e
f010243b:	68 f7 59 10 f0       	push   $0xf01059f7
f0102440:	68 b4 03 00 00       	push   $0x3b4
f0102445:	68 d1 59 10 f0       	push   $0xf01059d1
f010244a:	e8 51 dc ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010244f:	68 b0 57 10 f0       	push   $0xf01057b0
f0102454:	68 f7 59 10 f0       	push   $0xf01059f7
f0102459:	68 b7 03 00 00       	push   $0x3b7
f010245e:	68 d1 59 10 f0       	push   $0xf01059d1
f0102463:	e8 38 dc ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102468:	68 72 5b 10 f0       	push   $0xf0105b72
f010246d:	68 f7 59 10 f0       	push   $0xf01059f7
f0102472:	68 ba 03 00 00       	push   $0x3ba
f0102477:	68 d1 59 10 f0       	push   $0xf01059d1
f010247c:	e8 1f dc ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102481:	68 54 54 10 f0       	push   $0xf0105454
f0102486:	68 f7 59 10 f0       	push   $0xf01059f7
f010248b:	68 bd 03 00 00       	push   $0x3bd
f0102490:	68 d1 59 10 f0       	push   $0xf01059d1
f0102495:	e8 06 dc ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f010249a:	68 d5 5b 10 f0       	push   $0xf0105bd5
f010249f:	68 f7 59 10 f0       	push   $0xf01059f7
f01024a4:	68 bf 03 00 00       	push   $0x3bf
f01024a9:	68 d1 59 10 f0       	push   $0xf01059d1
f01024ae:	e8 ed db ff ff       	call   f01000a0 <_panic>
f01024b3:	52                   	push   %edx
f01024b4:	68 f0 51 10 f0       	push   $0xf01051f0
f01024b9:	68 c6 03 00 00       	push   $0x3c6
f01024be:	68 d1 59 10 f0       	push   $0xf01059d1
f01024c3:	e8 d8 db ff ff       	call   f01000a0 <_panic>
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
f01024c8:	68 61 5c 10 f0       	push   $0xf0105c61
f01024cd:	68 f7 59 10 f0       	push   $0xf01059f7
f01024d2:	68 c7 03 00 00       	push   $0x3c7
f01024d7:	68 d1 59 10 f0       	push   $0xf01059d1
f01024dc:	e8 bf db ff ff       	call   f01000a0 <_panic>
f01024e1:	50                   	push   %eax
f01024e2:	68 f0 51 10 f0       	push   $0xf01051f0
f01024e7:	6a 56                	push   $0x56
f01024e9:	68 dd 59 10 f0       	push   $0xf01059dd
f01024ee:	e8 ad db ff ff       	call   f01000a0 <_panic>
f01024f3:	52                   	push   %edx
f01024f4:	68 f0 51 10 f0       	push   $0xf01051f0
f01024f9:	6a 56                	push   $0x56
f01024fb:	68 dd 59 10 f0       	push   $0xf01059dd
f0102500:	e8 9b db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102505:	68 79 5c 10 f0       	push   $0xf0105c79
f010250a:	68 f7 59 10 f0       	push   $0xf01059f7
f010250f:	68 d1 03 00 00       	push   $0x3d1
f0102514:	68 d1 59 10 f0       	push   $0xf01059d1
f0102519:	e8 82 db ff ff       	call   f01000a0 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010251e:	50                   	push   %eax
f010251f:	68 fc 52 10 f0       	push   $0xf01052fc
f0102524:	68 bb 00 00 00       	push   $0xbb
f0102529:	68 d1 59 10 f0       	push   $0xf01059d1
f010252e:	e8 6d db ff ff       	call   f01000a0 <_panic>
f0102533:	50                   	push   %eax
f0102534:	68 fc 52 10 f0       	push   $0xf01052fc
f0102539:	68 c4 00 00 00       	push   $0xc4
f010253e:	68 d1 59 10 f0       	push   $0xf01059d1
f0102543:	e8 58 db ff ff       	call   f01000a0 <_panic>
f0102548:	50                   	push   %eax
f0102549:	68 fc 52 10 f0       	push   $0xf01052fc
f010254e:	68 d1 00 00 00       	push   $0xd1
f0102553:	68 d1 59 10 f0       	push   $0xf01059d1
f0102558:	e8 43 db ff ff       	call   f01000a0 <_panic>
f010255d:	ff 75 c8             	pushl  -0x38(%ebp)
f0102560:	68 fc 52 10 f0       	push   $0xf01052fc
f0102565:	68 0e 03 00 00       	push   $0x30e
f010256a:	68 d1 59 10 f0       	push   $0xf01059d1
f010256f:	e8 2c db ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102574:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010257a:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010257d:	76 36                	jbe    f01025b5 <mem_init+0x1369>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010257f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102585:	89 d8                	mov    %ebx,%eax
f0102587:	e8 5c e5 ff ff       	call   f0100ae8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010258c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102593:	76 c8                	jbe    f010255d <mem_init+0x1311>
f0102595:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0102598:	39 c2                	cmp    %eax,%edx
f010259a:	74 d8                	je     f0102574 <mem_init+0x1328>
f010259c:	68 d4 57 10 f0       	push   $0xf01057d4
f01025a1:	68 f7 59 10 f0       	push   $0xf01059f7
f01025a6:	68 0e 03 00 00       	push   $0x30e
f01025ab:	68 d1 59 10 f0       	push   $0xf01059d1
f01025b0:	e8 eb da ff ff       	call   f01000a0 <_panic>

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01025b5:	a1 2c bd 19 f0       	mov    0xf019bd2c,%eax
f01025ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01025bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025c0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01025c5:	8d b8 00 00 40 21    	lea    0x21400000(%eax),%edi
f01025cb:	89 f2                	mov    %esi,%edx
f01025cd:	89 d8                	mov    %ebx,%eax
f01025cf:	e8 14 e5 ff ff       	call   f0100ae8 <check_va2pa>
f01025d4:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01025db:	76 3d                	jbe    f010261a <mem_init+0x13ce>
f01025dd:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01025e0:	39 c2                	cmp    %eax,%edx
f01025e2:	75 4d                	jne    f0102631 <mem_init+0x13e5>
f01025e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025ea:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01025f0:	75 d9                	jne    f01025cb <mem_init+0x137f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01025f2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01025f5:	c1 e7 0c             	shl    $0xc,%edi
f01025f8:	be 00 00 00 00       	mov    $0x0,%esi
f01025fd:	39 fe                	cmp    %edi,%esi
f01025ff:	73 62                	jae    f0102663 <mem_init+0x1417>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102601:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102607:	89 d8                	mov    %ebx,%eax
f0102609:	e8 da e4 ff ff       	call   f0100ae8 <check_va2pa>
f010260e:	39 c6                	cmp    %eax,%esi
f0102610:	75 38                	jne    f010264a <mem_init+0x13fe>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102612:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102618:	eb e3                	jmp    f01025fd <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010261a:	ff 75 d0             	pushl  -0x30(%ebp)
f010261d:	68 fc 52 10 f0       	push   $0xf01052fc
f0102622:	68 13 03 00 00       	push   $0x313
f0102627:	68 d1 59 10 f0       	push   $0xf01059d1
f010262c:	e8 6f da ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102631:	68 08 58 10 f0       	push   $0xf0105808
f0102636:	68 f7 59 10 f0       	push   $0xf01059f7
f010263b:	68 13 03 00 00       	push   $0x313
f0102640:	68 d1 59 10 f0       	push   $0xf01059d1
f0102645:	e8 56 da ff ff       	call   f01000a0 <_panic>

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010264a:	68 3c 58 10 f0       	push   $0xf010583c
f010264f:	68 f7 59 10 f0       	push   $0xf01059f7
f0102654:	68 17 03 00 00       	push   $0x317
f0102659:	68 d1 59 10 f0       	push   $0xf01059d1
f010265e:	e8 3d da ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102663:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102668:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f010266d:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f0102673:	89 f2                	mov    %esi,%edx
f0102675:	89 d8                	mov    %ebx,%eax
f0102677:	e8 6c e4 ff ff       	call   f0100ae8 <check_va2pa>
f010267c:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010267f:	39 d0                	cmp    %edx,%eax
f0102681:	75 26                	jne    f01026a9 <mem_init+0x145d>
f0102683:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102689:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010268f:	75 e2                	jne    f0102673 <mem_init+0x1427>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102691:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102696:	89 d8                	mov    %ebx,%eax
f0102698:	e8 4b e4 ff ff       	call   f0100ae8 <check_va2pa>
f010269d:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026a0:	75 20                	jne    f01026c2 <mem_init+0x1476>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01026a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01026a7:	eb 59                	jmp    f0102702 <mem_init+0x14b6>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026a9:	68 64 58 10 f0       	push   $0xf0105864
f01026ae:	68 f7 59 10 f0       	push   $0xf01059f7
f01026b3:	68 1b 03 00 00       	push   $0x31b
f01026b8:	68 d1 59 10 f0       	push   $0xf01059d1
f01026bd:	e8 de d9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01026c2:	68 ac 58 10 f0       	push   $0xf01058ac
f01026c7:	68 f7 59 10 f0       	push   $0xf01059f7
f01026cc:	68 1c 03 00 00       	push   $0x31c
f01026d1:	68 d1 59 10 f0       	push   $0xf01059d1
f01026d6:	e8 c5 d9 ff ff       	call   f01000a0 <_panic>
		switch (i) {
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01026db:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01026df:	74 47                	je     f0102728 <mem_init+0x14dc>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01026e1:	40                   	inc    %eax
f01026e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01026e7:	0f 87 93 00 00 00    	ja     f0102780 <mem_init+0x1534>
		switch (i) {
f01026ed:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01026f2:	72 0e                	jb     f0102702 <mem_init+0x14b6>
f01026f4:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01026f9:	76 e0                	jbe    f01026db <mem_init+0x148f>
f01026fb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102700:	74 d9                	je     f01026db <mem_init+0x148f>
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102702:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102707:	77 38                	ja     f0102741 <mem_init+0x14f5>
				assert(pgdir[i] & PTE_P);
				assert(pgdir[i] & PTE_W);
			} else
				assert(pgdir[i] == 0);
f0102709:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010270d:	74 d2                	je     f01026e1 <mem_init+0x1495>
f010270f:	68 cb 5c 10 f0       	push   $0xf0105ccb
f0102714:	68 f7 59 10 f0       	push   $0xf01059f7
f0102719:	68 2c 03 00 00       	push   $0x32c
f010271e:	68 d1 59 10 f0       	push   $0xf01059d1
f0102723:	e8 78 d9 ff ff       	call   f01000a0 <_panic>
		switch (i) {
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102728:	68 a9 5c 10 f0       	push   $0xf0105ca9
f010272d:	68 f7 59 10 f0       	push   $0xf01059f7
f0102732:	68 25 03 00 00       	push   $0x325
f0102737:	68 d1 59 10 f0       	push   $0xf01059d1
f010273c:	e8 5f d9 ff ff       	call   f01000a0 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
f0102741:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102744:	f6 c2 01             	test   $0x1,%dl
f0102747:	74 1e                	je     f0102767 <mem_init+0x151b>
				assert(pgdir[i] & PTE_W);
f0102749:	f6 c2 02             	test   $0x2,%dl
f010274c:	75 93                	jne    f01026e1 <mem_init+0x1495>
f010274e:	68 ba 5c 10 f0       	push   $0xf0105cba
f0102753:	68 f7 59 10 f0       	push   $0xf01059f7
f0102758:	68 2a 03 00 00       	push   $0x32a
f010275d:	68 d1 59 10 f0       	push   $0xf01059d1
f0102762:	e8 39 d9 ff ff       	call   f01000a0 <_panic>
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
f0102767:	68 a9 5c 10 f0       	push   $0xf0105ca9
f010276c:	68 f7 59 10 f0       	push   $0xf01059f7
f0102771:	68 29 03 00 00       	push   $0x329
f0102776:	68 d1 59 10 f0       	push   $0xf01059d1
f010277b:	e8 20 d9 ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102780:	83 ec 0c             	sub    $0xc,%esp
f0102783:	68 dc 58 10 f0       	push   $0xf01058dc
f0102788:	e8 a8 0b 00 00       	call   f0103335 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010278d:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102792:	83 c4 10             	add    $0x10,%esp
f0102795:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010279a:	0f 86 fe 01 00 00    	jbe    f010299e <mem_init+0x1752>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01027a0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01027a5:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01027a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01027ad:	e8 95 e3 ff ff       	call   f0100b47 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01027b2:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01027b5:	83 e0 f3             	and    $0xfffffff3,%eax
f01027b8:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01027bd:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01027c0:	83 ec 0c             	sub    $0xc,%esp
f01027c3:	6a 00                	push   $0x0
f01027c5:	e8 59 e7 ff ff       	call   f0100f23 <page_alloc>
f01027ca:	89 c3                	mov    %eax,%ebx
f01027cc:	83 c4 10             	add    $0x10,%esp
f01027cf:	85 c0                	test   %eax,%eax
f01027d1:	0f 84 dc 01 00 00    	je     f01029b3 <mem_init+0x1767>
	assert((pp1 = page_alloc(0)));
f01027d7:	83 ec 0c             	sub    $0xc,%esp
f01027da:	6a 00                	push   $0x0
f01027dc:	e8 42 e7 ff ff       	call   f0100f23 <page_alloc>
f01027e1:	89 c7                	mov    %eax,%edi
f01027e3:	83 c4 10             	add    $0x10,%esp
f01027e6:	85 c0                	test   %eax,%eax
f01027e8:	0f 84 de 01 00 00    	je     f01029cc <mem_init+0x1780>
	assert((pp2 = page_alloc(0)));
f01027ee:	83 ec 0c             	sub    $0xc,%esp
f01027f1:	6a 00                	push   $0x0
f01027f3:	e8 2b e7 ff ff       	call   f0100f23 <page_alloc>
f01027f8:	89 c6                	mov    %eax,%esi
f01027fa:	83 c4 10             	add    $0x10,%esp
f01027fd:	85 c0                	test   %eax,%eax
f01027ff:	0f 84 e0 01 00 00    	je     f01029e5 <mem_init+0x1799>
	page_free(pp0);
f0102805:	83 ec 0c             	sub    $0xc,%esp
f0102808:	53                   	push   %ebx
f0102809:	e8 87 e7 ff ff       	call   f0100f95 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010280e:	89 f8                	mov    %edi,%eax
f0102810:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0102816:	c1 f8 03             	sar    $0x3,%eax
f0102819:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010281c:	89 c2                	mov    %eax,%edx
f010281e:	c1 ea 0c             	shr    $0xc,%edx
f0102821:	83 c4 10             	add    $0x10,%esp
f0102824:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f010282a:	0f 83 ce 01 00 00    	jae    f01029fe <mem_init+0x17b2>
	memset(page2kva(pp1), 1, PGSIZE);
f0102830:	83 ec 04             	sub    $0x4,%esp
f0102833:	68 00 10 00 00       	push   $0x1000
f0102838:	6a 01                	push   $0x1
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f010283a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010283f:	50                   	push   %eax
f0102840:	e8 44 1f 00 00       	call   f0104789 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102845:	89 f0                	mov    %esi,%eax
f0102847:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f010284d:	c1 f8 03             	sar    $0x3,%eax
f0102850:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102853:	89 c2                	mov    %eax,%edx
f0102855:	c1 ea 0c             	shr    $0xc,%edx
f0102858:	83 c4 10             	add    $0x10,%esp
f010285b:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f0102861:	0f 83 a9 01 00 00    	jae    f0102a10 <mem_init+0x17c4>
	memset(page2kva(pp2), 2, PGSIZE);
f0102867:	83 ec 04             	sub    $0x4,%esp
f010286a:	68 00 10 00 00       	push   $0x1000
f010286f:	6a 02                	push   $0x2
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0102871:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102876:	50                   	push   %eax
f0102877:	e8 0d 1f 00 00       	call   f0104789 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010287c:	6a 02                	push   $0x2
f010287e:	68 00 10 00 00       	push   $0x1000
f0102883:	57                   	push   %edi
f0102884:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f010288a:	e8 56 e9 ff ff       	call   f01011e5 <page_insert>
	assert(pp1->pp_ref == 1);
f010288f:	83 c4 20             	add    $0x20,%esp
f0102892:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102897:	0f 85 85 01 00 00    	jne    f0102a22 <mem_init+0x17d6>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010289d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01028a4:	01 01 01 
f01028a7:	0f 85 8e 01 00 00    	jne    f0102a3b <mem_init+0x17ef>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01028ad:	6a 02                	push   $0x2
f01028af:	68 00 10 00 00       	push   $0x1000
f01028b4:	56                   	push   %esi
f01028b5:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f01028bb:	e8 25 e9 ff ff       	call   f01011e5 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01028c0:	83 c4 10             	add    $0x10,%esp
f01028c3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01028ca:	02 02 02 
f01028cd:	0f 85 81 01 00 00    	jne    f0102a54 <mem_init+0x1808>
	assert(pp2->pp_ref == 1);
f01028d3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01028d8:	0f 85 8f 01 00 00    	jne    f0102a6d <mem_init+0x1821>
	assert(pp1->pp_ref == 0);
f01028de:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01028e3:	0f 85 9d 01 00 00    	jne    f0102a86 <mem_init+0x183a>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01028e9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01028f0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028f3:	89 f0                	mov    %esi,%eax
f01028f5:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f01028fb:	c1 f8 03             	sar    $0x3,%eax
f01028fe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102901:	89 c2                	mov    %eax,%edx
f0102903:	c1 ea 0c             	shr    $0xc,%edx
f0102906:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f010290c:	0f 83 8d 01 00 00    	jae    f0102a9f <mem_init+0x1853>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102912:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102919:	03 03 03 
f010291c:	0f 85 8f 01 00 00    	jne    f0102ab1 <mem_init+0x1865>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102922:	83 ec 08             	sub    $0x8,%esp
f0102925:	68 00 10 00 00       	push   $0x1000
f010292a:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0102930:	e8 73 e8 ff ff       	call   f01011a8 <page_remove>
	assert(pp2->pp_ref == 0);
f0102935:	83 c4 10             	add    $0x10,%esp
f0102938:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010293d:	0f 85 87 01 00 00    	jne    f0102aca <mem_init+0x187e>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102943:	8b 0d e8 c9 19 f0    	mov    0xf019c9e8,%ecx
f0102949:	8b 11                	mov    (%ecx),%edx
f010294b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102951:	89 d8                	mov    %ebx,%eax
f0102953:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0102959:	c1 f8 03             	sar    $0x3,%eax
f010295c:	c1 e0 0c             	shl    $0xc,%eax
f010295f:	39 c2                	cmp    %eax,%edx
f0102961:	0f 85 7c 01 00 00    	jne    f0102ae3 <mem_init+0x1897>
	kern_pgdir[0] = 0;
f0102967:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010296d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102972:	0f 85 84 01 00 00    	jne    f0102afc <mem_init+0x18b0>
	pp0->pp_ref = 0;
f0102978:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010297e:	83 ec 0c             	sub    $0xc,%esp
f0102981:	53                   	push   %ebx
f0102982:	e8 0e e6 ff ff       	call   f0100f95 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102987:	c7 04 24 70 59 10 f0 	movl   $0xf0105970,(%esp)
f010298e:	e8 a2 09 00 00       	call   f0103335 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102993:	83 c4 10             	add    $0x10,%esp
f0102996:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102999:	5b                   	pop    %ebx
f010299a:	5e                   	pop    %esi
f010299b:	5f                   	pop    %edi
f010299c:	5d                   	pop    %ebp
f010299d:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010299e:	50                   	push   %eax
f010299f:	68 fc 52 10 f0       	push   $0xf01052fc
f01029a4:	68 e7 00 00 00       	push   $0xe7
f01029a9:	68 d1 59 10 f0       	push   $0xf01059d1
f01029ae:	e8 ed d6 ff ff       	call   f01000a0 <_panic>
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029b3:	68 c7 5a 10 f0       	push   $0xf0105ac7
f01029b8:	68 f7 59 10 f0       	push   $0xf01059f7
f01029bd:	68 ec 03 00 00       	push   $0x3ec
f01029c2:	68 d1 59 10 f0       	push   $0xf01059d1
f01029c7:	e8 d4 d6 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01029cc:	68 dd 5a 10 f0       	push   $0xf0105add
f01029d1:	68 f7 59 10 f0       	push   $0xf01059f7
f01029d6:	68 ed 03 00 00       	push   $0x3ed
f01029db:	68 d1 59 10 f0       	push   $0xf01059d1
f01029e0:	e8 bb d6 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01029e5:	68 f3 5a 10 f0       	push   $0xf0105af3
f01029ea:	68 f7 59 10 f0       	push   $0xf01059f7
f01029ef:	68 ee 03 00 00       	push   $0x3ee
f01029f4:	68 d1 59 10 f0       	push   $0xf01059d1
f01029f9:	e8 a2 d6 ff ff       	call   f01000a0 <_panic>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029fe:	50                   	push   %eax
f01029ff:	68 f0 51 10 f0       	push   $0xf01051f0
f0102a04:	6a 56                	push   $0x56
f0102a06:	68 dd 59 10 f0       	push   $0xf01059dd
f0102a0b:	e8 90 d6 ff ff       	call   f01000a0 <_panic>
f0102a10:	50                   	push   %eax
f0102a11:	68 f0 51 10 f0       	push   $0xf01051f0
f0102a16:	6a 56                	push   $0x56
f0102a18:	68 dd 59 10 f0       	push   $0xf01059dd
f0102a1d:	e8 7e d6 ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
	assert(pp1->pp_ref == 1);
f0102a22:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0102a27:	68 f7 59 10 f0       	push   $0xf01059f7
f0102a2c:	68 f3 03 00 00       	push   $0x3f3
f0102a31:	68 d1 59 10 f0       	push   $0xf01059d1
f0102a36:	e8 65 d6 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a3b:	68 fc 58 10 f0       	push   $0xf01058fc
f0102a40:	68 f7 59 10 f0       	push   $0xf01059f7
f0102a45:	68 f4 03 00 00       	push   $0x3f4
f0102a4a:	68 d1 59 10 f0       	push   $0xf01059d1
f0102a4f:	e8 4c d6 ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a54:	68 20 59 10 f0       	push   $0xf0105920
f0102a59:	68 f7 59 10 f0       	push   $0xf01059f7
f0102a5e:	68 f6 03 00 00       	push   $0x3f6
f0102a63:	68 d1 59 10 f0       	push   $0xf01059d1
f0102a68:	e8 33 d6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102a6d:	68 e6 5b 10 f0       	push   $0xf0105be6
f0102a72:	68 f7 59 10 f0       	push   $0xf01059f7
f0102a77:	68 f7 03 00 00       	push   $0x3f7
f0102a7c:	68 d1 59 10 f0       	push   $0xf01059d1
f0102a81:	e8 1a d6 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0102a86:	68 50 5c 10 f0       	push   $0xf0105c50
f0102a8b:	68 f7 59 10 f0       	push   $0xf01059f7
f0102a90:	68 f8 03 00 00       	push   $0x3f8
f0102a95:	68 d1 59 10 f0       	push   $0xf01059d1
f0102a9a:	e8 01 d6 ff ff       	call   f01000a0 <_panic>
f0102a9f:	50                   	push   %eax
f0102aa0:	68 f0 51 10 f0       	push   $0xf01051f0
f0102aa5:	6a 56                	push   $0x56
f0102aa7:	68 dd 59 10 f0       	push   $0xf01059dd
f0102aac:	e8 ef d5 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ab1:	68 44 59 10 f0       	push   $0xf0105944
f0102ab6:	68 f7 59 10 f0       	push   $0xf01059f7
f0102abb:	68 fa 03 00 00       	push   $0x3fa
f0102ac0:	68 d1 59 10 f0       	push   $0xf01059d1
f0102ac5:	e8 d6 d5 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(pp2->pp_ref == 0);
f0102aca:	68 1e 5c 10 f0       	push   $0xf0105c1e
f0102acf:	68 f7 59 10 f0       	push   $0xf01059f7
f0102ad4:	68 fc 03 00 00       	push   $0x3fc
f0102ad9:	68 d1 59 10 f0       	push   $0xf01059d1
f0102ade:	e8 bd d5 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ae3:	68 54 54 10 f0       	push   $0xf0105454
f0102ae8:	68 f7 59 10 f0       	push   $0xf01059f7
f0102aed:	68 ff 03 00 00       	push   $0x3ff
f0102af2:	68 d1 59 10 f0       	push   $0xf01059d1
f0102af7:	e8 a4 d5 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f0102afc:	68 d5 5b 10 f0       	push   $0xf0105bd5
f0102b01:	68 f7 59 10 f0       	push   $0xf01059f7
f0102b06:	68 01 04 00 00       	push   $0x401
f0102b0b:	68 d1 59 10 f0       	push   $0xf01059d1
f0102b10:	e8 8b d5 ff ff       	call   f01000a0 <_panic>

f0102b15 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102b15:	55                   	push   %ebp
f0102b16:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102b18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b1b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102b1e:	5d                   	pop    %ebp
f0102b1f:	c3                   	ret    

f0102b20 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102b20:	55                   	push   %ebp
f0102b21:	89 e5                	mov    %esp,%ebp
f0102b23:	57                   	push   %edi
f0102b24:	56                   	push   %esi
f0102b25:	53                   	push   %ebx
f0102b26:	83 ec 1c             	sub    $0x1c,%esp
f0102b29:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0102b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b2f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102b35:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102b38:	8b 45 10             	mov    0x10(%ebp),%eax
f0102b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102b3e:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0102b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f0102b4d:	8b 75 14             	mov    0x14(%ebp),%esi
f0102b50:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f0102b53:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102b56:	73 54                	jae    f0102bac <user_mem_check+0x8c>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
f0102b58:	83 ec 04             	sub    $0x4,%esp
f0102b5b:	6a 00                	push   $0x0
f0102b5d:	53                   	push   %ebx
f0102b5e:	ff 77 5c             	pushl  0x5c(%edi)
f0102b61:	e8 a7 e4 ff ff       	call   f010100d <pgdir_walk>
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f0102b66:	83 c4 10             	add    $0x10,%esp
f0102b69:	85 c0                	test   %eax,%eax
f0102b6b:	74 18                	je     f0102b85 <user_mem_check+0x65>
f0102b6d:	89 f2                	mov    %esi,%edx
f0102b6f:	23 10                	and    (%eax),%edx
f0102b71:	39 d6                	cmp    %edx,%esi
f0102b73:	75 10                	jne    f0102b85 <user_mem_check+0x65>
f0102b75:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102b7b:	77 08                	ja     f0102b85 <user_mem_check+0x65>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f0102b7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b83:	eb ce                	jmp    f0102b53 <user_mem_check+0x33>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
f0102b85:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102b88:	74 13                	je     f0102b9d <user_mem_check+0x7d>
				user_mem_check_addr = (uintptr_t)va;
			} else {
				user_mem_check_addr = cur_va;
f0102b8a:	89 1d 1c bd 19 f0    	mov    %ebx,0xf019bd1c
			}
			return -E_FAULT;
f0102b90:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}
	return 0;
}
f0102b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b98:	5b                   	pop    %ebx
f0102b99:	5e                   	pop    %esi
f0102b9a:	5f                   	pop    %edi
f0102b9b:	5d                   	pop    %ebp
f0102b9c:	c3                   	ret    
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
				user_mem_check_addr = (uintptr_t)va;
f0102b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ba0:	a3 1c bd 19 f0       	mov    %eax,0xf019bd1c
			} else {
				user_mem_check_addr = cur_va;
			}
			return -E_FAULT;
f0102ba5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102baa:	eb e9                	jmp    f0102b95 <user_mem_check+0x75>
		}
	}
	return 0;
f0102bac:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb1:	eb e2                	jmp    f0102b95 <user_mem_check+0x75>

f0102bb3 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102bb3:	55                   	push   %ebp
f0102bb4:	89 e5                	mov    %esp,%ebp
f0102bb6:	53                   	push   %ebx
f0102bb7:	83 ec 04             	sub    $0x4,%esp
f0102bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102bbd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bc0:	83 c8 04             	or     $0x4,%eax
f0102bc3:	50                   	push   %eax
f0102bc4:	ff 75 10             	pushl  0x10(%ebp)
f0102bc7:	ff 75 0c             	pushl  0xc(%ebp)
f0102bca:	53                   	push   %ebx
f0102bcb:	e8 50 ff ff ff       	call   f0102b20 <user_mem_check>
f0102bd0:	83 c4 10             	add    $0x10,%esp
f0102bd3:	85 c0                	test   %eax,%eax
f0102bd5:	78 05                	js     f0102bdc <user_mem_assert+0x29>
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0102bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102bda:	c9                   	leave  
f0102bdb:	c3                   	ret    
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f0102bdc:	83 ec 04             	sub    $0x4,%esp
f0102bdf:	ff 35 1c bd 19 f0    	pushl  0xf019bd1c
f0102be5:	ff 73 48             	pushl  0x48(%ebx)
f0102be8:	68 9c 59 10 f0       	push   $0xf010599c
f0102bed:	e8 43 07 00 00       	call   f0103335 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102bf2:	89 1c 24             	mov    %ebx,(%esp)
f0102bf5:	e8 1f 06 00 00       	call   f0103219 <env_destroy>
f0102bfa:	83 c4 10             	add    $0x10,%esp
	}
}
f0102bfd:	eb d8                	jmp    f0102bd7 <user_mem_assert+0x24>
	...

f0102c00 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102c00:	55                   	push   %ebp
f0102c01:	89 e5                	mov    %esp,%ebp
f0102c03:	57                   	push   %edi
f0102c04:	56                   	push   %esi
f0102c05:	53                   	push   %ebx
f0102c06:	83 ec 1c             	sub    $0x1c,%esp
f0102c09:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102c0b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102c12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0102c1a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c20:	89 d3                	mov    %edx,%ebx
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f0102c22:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102c25:	73 4e                	jae    f0102c75 <region_alloc+0x75>
		pginfo = page_alloc(0);
f0102c27:	83 ec 0c             	sub    $0xc,%esp
f0102c2a:	6a 00                	push   $0x0
f0102c2c:	e8 f2 e2 ff ff       	call   f0100f23 <page_alloc>
f0102c31:	89 c6                	mov    %eax,%esi
		if (!pginfo) {
f0102c33:	83 c4 10             	add    $0x10,%esp
f0102c36:	85 c0                	test   %eax,%eax
f0102c38:	74 25                	je     f0102c5f <region_alloc+0x5f>
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
		}
		cprintf("insert page at %08x\n",cur_va);
f0102c3a:	83 ec 08             	sub    $0x8,%esp
f0102c3d:	53                   	push   %ebx
f0102c3e:	68 f5 5c 10 f0       	push   $0xf0105cf5
f0102c43:	e8 ed 06 00 00       	call   f0103335 <cprintf>
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
f0102c48:	6a 07                	push   $0x7
f0102c4a:	53                   	push   %ebx
f0102c4b:	56                   	push   %esi
f0102c4c:	ff 77 5c             	pushl  0x5c(%edi)
f0102c4f:	e8 91 e5 ff ff       	call   f01011e5 <page_insert>
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f0102c54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c5a:	83 c4 20             	add    $0x20,%esp
f0102c5d:	eb c3                	jmp    f0102c22 <region_alloc+0x22>
		pginfo = page_alloc(0);
		if (!pginfo) {
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
f0102c5f:	6a fc                	push   $0xfffffffc
f0102c61:	68 d9 5c 10 f0       	push   $0xf0105cd9
f0102c66:	68 1d 01 00 00       	push   $0x11d
f0102c6b:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102c70:	e8 2b d4 ff ff       	call   f01000a0 <_panic>
		}
		cprintf("insert page at %08x\n",cur_va);
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
	}
}
f0102c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c78:	5b                   	pop    %ebx
f0102c79:	5e                   	pop    %esi
f0102c7a:	5f                   	pop    %edi
f0102c7b:	5d                   	pop    %ebp
f0102c7c:	c3                   	ret    

f0102c7d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102c7d:	55                   	push   %ebp
f0102c7e:	89 e5                	mov    %esp,%ebp
f0102c80:	53                   	push   %ebx
f0102c81:	8b 55 08             	mov    0x8(%ebp),%edx
f0102c84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102c87:	85 d2                	test   %edx,%edx
f0102c89:	74 44                	je     f0102ccf <envid2env+0x52>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102c8b:	89 d3                	mov    %edx,%ebx
f0102c8d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102c93:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102c96:	01 d8                	add    %ebx,%eax
f0102c98:	c1 e0 05             	shl    $0x5,%eax
f0102c9b:	03 05 2c bd 19 f0    	add    0xf019bd2c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ca1:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102ca5:	74 39                	je     f0102ce0 <envid2env+0x63>
f0102ca7:	39 50 48             	cmp    %edx,0x48(%eax)
f0102caa:	75 34                	jne    f0102ce0 <envid2env+0x63>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102cac:	84 c9                	test   %cl,%cl
f0102cae:	74 12                	je     f0102cc2 <envid2env+0x45>
f0102cb0:	8b 15 28 bd 19 f0    	mov    0xf019bd28,%edx
f0102cb6:	39 c2                	cmp    %eax,%edx
f0102cb8:	74 08                	je     f0102cc2 <envid2env+0x45>
f0102cba:	8b 5a 48             	mov    0x48(%edx),%ebx
f0102cbd:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0102cc0:	75 2e                	jne    f0102cf0 <envid2env+0x73>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0102cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102cc5:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ccc:	5b                   	pop    %ebx
f0102ccd:	5d                   	pop    %ebp
f0102cce:	c3                   	ret    
{
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
		*env_store = curenv;
f0102ccf:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0102cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102cd7:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102cd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cde:	eb ec                	jmp    f0102ccc <envid2env+0x4f>
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
	if (e->env_status == ENV_FREE || e->env_id != envid) {
		*env_store = 0;
f0102ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ce3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ce9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102cee:	eb dc                	jmp    f0102ccc <envid2env+0x4f>
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
		*env_store = 0;
f0102cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cf3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102cf9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102cfe:	eb cc                	jmp    f0102ccc <envid2env+0x4f>

f0102d00 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102d00:	55                   	push   %ebp
f0102d01:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102d03:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f0102d08:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102d0b:	b8 23 00 00 00       	mov    $0x23,%eax
f0102d10:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102d12:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102d14:	b8 10 00 00 00       	mov    $0x10,%eax
f0102d19:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102d1b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102d1d:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102d1f:	ea 26 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102d26
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102d26:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d2b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102d2e:	5d                   	pop    %ebp
f0102d2f:	c3                   	ret    

f0102d30 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102d30:	55                   	push   %ebp
f0102d31:	89 e5                	mov    %esp,%ebp
f0102d33:	56                   	push   %esi
f0102d34:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for (int index = NENV - 1; index >= 0; index--) {
		envs[index].env_link = env_free_list;
f0102d35:	8b 35 2c bd 19 f0    	mov    0xf019bd2c,%esi
f0102d3b:	8b 15 30 bd 19 f0    	mov    0xf019bd30,%edx
f0102d41:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102d47:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102d4a:	89 c1                	mov    %eax,%ecx
f0102d4c:	89 50 44             	mov    %edx,0x44(%eax)
		envs[index].env_runs = 0;
f0102d4f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
f0102d56:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[index];
f0102d59:	89 ca                	mov    %ecx,%edx
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (int index = NENV - 1; index >= 0; index--) {
f0102d5b:	39 d8                	cmp    %ebx,%eax
f0102d5d:	75 eb                	jne    f0102d4a <env_init+0x1a>
f0102d5f:	89 35 30 bd 19 f0    	mov    %esi,0xf019bd30
		envs[index].env_runs = 0;
		env_free_list = &envs[index];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102d65:	e8 96 ff ff ff       	call   f0102d00 <env_init_percpu>
}
f0102d6a:	5b                   	pop    %ebx
f0102d6b:	5e                   	pop    %esi
f0102d6c:	5d                   	pop    %ebp
f0102d6d:	c3                   	ret    

f0102d6e <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102d6e:	55                   	push   %ebp
f0102d6f:	89 e5                	mov    %esp,%ebp
f0102d71:	56                   	push   %esi
f0102d72:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102d73:	8b 1d 30 bd 19 f0    	mov    0xf019bd30,%ebx
f0102d79:	85 db                	test   %ebx,%ebx
f0102d7b:	0f 84 72 01 00 00    	je     f0102ef3 <env_alloc+0x185>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102d81:	83 ec 0c             	sub    $0xc,%esp
f0102d84:	6a 01                	push   $0x1
f0102d86:	e8 98 e1 ff ff       	call   f0100f23 <page_alloc>
f0102d8b:	89 c6                	mov    %eax,%esi
f0102d8d:	83 c4 10             	add    $0x10,%esp
f0102d90:	85 c0                	test   %eax,%eax
f0102d92:	0f 84 62 01 00 00    	je     f0102efa <env_alloc+0x18c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d98:	2b 05 ec c9 19 f0    	sub    0xf019c9ec,%eax
f0102d9e:	c1 f8 03             	sar    $0x3,%eax
f0102da1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102da4:	89 c2                	mov    %eax,%edx
f0102da6:	c1 ea 0c             	shr    $0xc,%edx
f0102da9:	3b 15 e4 c9 19 f0    	cmp    0xf019c9e4,%edx
f0102daf:	0f 83 06 01 00 00    	jae    f0102ebb <env_alloc+0x14d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0102db5:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    e->env_pgdir = page2kva(p);
f0102dba:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102dbd:	83 ec 04             	sub    $0x4,%esp
f0102dc0:	68 00 10 00 00       	push   $0x1000
f0102dc5:	ff 35 e8 c9 19 f0    	pushl  0xf019c9e8
f0102dcb:	50                   	push   %eax
f0102dcc:	e8 6b 1a 00 00       	call   f010483c <memcpy>
	p->pp_ref++;
f0102dd1:	66 ff 46 04          	incw   0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102dd5:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd8:	83 c4 10             	add    $0x10,%esp
f0102ddb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102de0:	0f 86 e7 00 00 00    	jbe    f0102ecd <env_alloc+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102de6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102dec:	83 ca 05             	or     $0x5,%edx
f0102def:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102df5:	8b 43 48             	mov    0x48(%ebx),%eax
f0102df8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102dfd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102e02:	89 c2                	mov    %eax,%edx
f0102e04:	0f 8e d8 00 00 00    	jle    f0102ee2 <env_alloc+0x174>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0102e0a:	89 d8                	mov    %ebx,%eax
f0102e0c:	2b 05 2c bd 19 f0    	sub    0xf019bd2c,%eax
f0102e12:	c1 f8 05             	sar    $0x5,%eax
f0102e15:	89 c1                	mov    %eax,%ecx
f0102e17:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102e1a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102e1d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102e20:	89 c6                	mov    %eax,%esi
f0102e22:	c1 e6 08             	shl    $0x8,%esi
f0102e25:	01 f0                	add    %esi,%eax
f0102e27:	89 c6                	mov    %eax,%esi
f0102e29:	c1 e6 10             	shl    $0x10,%esi
f0102e2c:	01 f0                	add    %esi,%eax
f0102e2e:	01 c0                	add    %eax,%eax
f0102e30:	01 c8                	add    %ecx,%eax
f0102e32:	09 d0                	or     %edx,%eax
f0102e34:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102e37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e3a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102e3d:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102e44:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102e4b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102e52:	83 ec 04             	sub    $0x4,%esp
f0102e55:	6a 44                	push   $0x44
f0102e57:	6a 00                	push   $0x0
f0102e59:	53                   	push   %ebx
f0102e5a:	e8 2a 19 00 00       	call   f0104789 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102e5f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102e65:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102e6b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102e71:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102e78:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102e7e:	8b 43 44             	mov    0x44(%ebx),%eax
f0102e81:	a3 30 bd 19 f0       	mov    %eax,0xf019bd30
	*newenv_store = e;
f0102e86:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e89:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e8b:	8b 53 48             	mov    0x48(%ebx),%edx
f0102e8e:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0102e93:	83 c4 10             	add    $0x10,%esp
f0102e96:	85 c0                	test   %eax,%eax
f0102e98:	74 52                	je     f0102eec <env_alloc+0x17e>
f0102e9a:	8b 40 48             	mov    0x48(%eax),%eax
f0102e9d:	83 ec 04             	sub    $0x4,%esp
f0102ea0:	52                   	push   %edx
f0102ea1:	50                   	push   %eax
f0102ea2:	68 0a 5d 10 f0       	push   $0xf0105d0a
f0102ea7:	e8 89 04 00 00       	call   f0103335 <cprintf>
	return 0;
f0102eac:	83 c4 10             	add    $0x10,%esp
f0102eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102eb7:	5b                   	pop    %ebx
f0102eb8:	5e                   	pop    %esi
f0102eb9:	5d                   	pop    %ebp
f0102eba:	c3                   	ret    

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ebb:	50                   	push   %eax
f0102ebc:	68 f0 51 10 f0       	push   $0xf01051f0
f0102ec1:	6a 56                	push   $0x56
f0102ec3:	68 dd 59 10 f0       	push   $0xf01059dd
f0102ec8:	e8 d3 d1 ff ff       	call   f01000a0 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ecd:	50                   	push   %eax
f0102ece:	68 fc 52 10 f0       	push   $0xf01052fc
f0102ed3:	68 c1 00 00 00       	push   $0xc1
f0102ed8:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102edd:	e8 be d1 ff ff       	call   f01000a0 <_panic>
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0102ee2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ee7:	e9 1e ff ff ff       	jmp    f0102e0a <env_alloc+0x9c>

	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102eec:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ef1:	eb aa                	jmp    f0102e9d <env_alloc+0x12f>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102ef3:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102ef8:	eb ba                	jmp    f0102eb4 <env_alloc+0x146>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102efa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102eff:	eb b3                	jmp    f0102eb4 <env_alloc+0x146>

f0102f01 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102f01:	55                   	push   %ebp
f0102f02:	89 e5                	mov    %esp,%ebp
f0102f04:	57                   	push   %edi
f0102f05:	56                   	push   %esi
f0102f06:	53                   	push   %ebx
f0102f07:	83 ec 34             	sub    $0x34,%esp
f0102f0a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f0102f0d:	6a 00                	push   $0x0
f0102f0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102f12:	50                   	push   %eax
f0102f13:	e8 56 fe ff ff       	call   f0102d6e <env_alloc>
	if (r < 0) {
f0102f18:	83 c4 10             	add    $0x10,%esp
f0102f1b:	85 c0                	test   %eax,%eax
f0102f1d:	78 3b                	js     f0102f5a <env_create+0x59>
		panic("env_create: %e", r);
	}
	e->env_type = type;
f0102f1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f22:	89 c1                	mov    %eax,%ecx
f0102f24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102f27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2a:	89 41 50             	mov    %eax,0x50(%ecx)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
f0102f2d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102f33:	75 3a                	jne    f0102f6f <env_create+0x6e>
		panic("load_icode: not an ELF file");
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
f0102f35:	89 fb                	mov    %edi,%ebx
f0102f37:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0102f3a:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102f3e:	c1 e6 05             	shl    $0x5,%esi
f0102f41:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0102f43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f46:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f49:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f4e:	76 36                	jbe    f0102f86 <env_create+0x85>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102f50:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f55:	0f 22 d8             	mov    %eax,%cr3
f0102f58:	eb 5b                	jmp    f0102fb5 <env_create+0xb4>
{
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
	if (r < 0) {
		panic("env_create: %e", r);
f0102f5a:	50                   	push   %eax
f0102f5b:	68 1f 5d 10 f0       	push   $0xf0105d1f
f0102f60:	68 85 01 00 00       	push   $0x185
f0102f65:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102f6a:	e8 31 d1 ff ff       	call   f01000a0 <_panic>

	// LAB 3: Your code here.
    struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
		panic("load_icode: not an ELF file");
f0102f6f:	83 ec 04             	sub    $0x4,%esp
f0102f72:	68 2e 5d 10 f0       	push   $0xf0105d2e
f0102f77:	68 5d 01 00 00       	push   $0x15d
f0102f7c:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102f81:	e8 1a d1 ff ff       	call   f01000a0 <_panic>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f86:	50                   	push   %eax
f0102f87:	68 fc 52 10 f0       	push   $0xf01052fc
f0102f8c:	68 62 01 00 00       	push   $0x162
f0102f91:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102f96:	e8 05 d1 ff ff       	call   f01000a0 <_panic>

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
			if (ph->p_filesz > ph->p_memsz) {
				panic("load_icode: file size is greater than memory size");
f0102f9b:	83 ec 04             	sub    $0x4,%esp
f0102f9e:	68 6c 5d 10 f0       	push   $0xf0105d6c
f0102fa3:	68 66 01 00 00       	push   $0x166
f0102fa8:	68 ea 5c 10 f0       	push   $0xf0105cea
f0102fad:	e8 ee d0 ff ff       	call   f01000a0 <_panic>
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
f0102fb2:	83 c3 20             	add    $0x20,%ebx
f0102fb5:	39 de                	cmp    %ebx,%esi
f0102fb7:	76 48                	jbe    f0103001 <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f0102fb9:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102fbc:	75 f4                	jne    f0102fb2 <env_create+0xb1>
			if (ph->p_filesz > ph->p_memsz) {
f0102fbe:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102fc1:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102fc4:	77 d5                	ja     f0102f9b <env_create+0x9a>
				panic("load_icode: file size is greater than memory size");
			}
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102fc6:	8b 53 08             	mov    0x8(%ebx),%edx
f0102fc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fcc:	e8 2f fc ff ff       	call   f0102c00 <region_alloc>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102fd1:	83 ec 04             	sub    $0x4,%esp
f0102fd4:	ff 73 10             	pushl  0x10(%ebx)
f0102fd7:	89 f8                	mov    %edi,%eax
f0102fd9:	03 43 04             	add    0x4(%ebx),%eax
f0102fdc:	50                   	push   %eax
f0102fdd:	ff 73 08             	pushl  0x8(%ebx)
f0102fe0:	e8 57 18 00 00       	call   f010483c <memcpy>
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0102fe5:	8b 43 10             	mov    0x10(%ebx),%eax
f0102fe8:	83 c4 0c             	add    $0xc,%esp
f0102feb:	8b 53 14             	mov    0x14(%ebx),%edx
f0102fee:	29 c2                	sub    %eax,%edx
f0102ff0:	52                   	push   %edx
f0102ff1:	6a 00                	push   $0x0
f0102ff3:	03 43 08             	add    0x8(%ebx),%eax
f0102ff6:	50                   	push   %eax
f0102ff7:	e8 8d 17 00 00       	call   f0104789 <memset>
f0102ffc:	83 c4 10             	add    $0x10,%esp
f0102fff:	eb b1                	jmp    f0102fb2 <env_create+0xb1>
		}
	}
	e->env_tf.tf_eip = elf->e_entry;
f0103001:	8b 47 18             	mov    0x18(%edi),%eax
f0103004:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103007:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) USTACKTOP-PGSIZE, PGSIZE);
f010300a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010300f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103014:	89 f8                	mov    %edi,%eax
f0103016:	e8 e5 fb ff ff       	call   f0102c00 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f010301b:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103020:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103025:	76 10                	jbe    f0103037 <env_create+0x136>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103027:	05 00 00 00 10       	add    $0x10000000,%eax
f010302c:	0f 22 d8             	mov    %eax,%cr3
	if (r < 0) {
		panic("env_create: %e", r);
	}
	e->env_type = type;
	load_icode(e, binary);
}
f010302f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103032:	5b                   	pop    %ebx
f0103033:	5e                   	pop    %esi
f0103034:	5f                   	pop    %edi
f0103035:	5d                   	pop    %ebp
f0103036:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103037:	50                   	push   %eax
f0103038:	68 fc 52 10 f0       	push   $0xf01052fc
f010303d:	68 74 01 00 00       	push   $0x174
f0103042:	68 ea 5c 10 f0       	push   $0xf0105cea
f0103047:	e8 54 d0 ff ff       	call   f01000a0 <_panic>

f010304c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010304c:	55                   	push   %ebp
f010304d:	89 e5                	mov    %esp,%ebp
f010304f:	57                   	push   %edi
f0103050:	56                   	push   %esi
f0103051:	53                   	push   %ebx
f0103052:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103055:	8b 15 28 bd 19 f0    	mov    0xf019bd28,%edx
f010305b:	3b 55 08             	cmp    0x8(%ebp),%edx
f010305e:	75 14                	jne    f0103074 <env_free+0x28>
		lcr3(PADDR(kern_pgdir));
f0103060:	a1 e8 c9 19 f0       	mov    0xf019c9e8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103065:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010306a:	76 36                	jbe    f01030a2 <env_free+0x56>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010306c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103071:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103074:	8b 45 08             	mov    0x8(%ebp),%eax
f0103077:	8b 48 48             	mov    0x48(%eax),%ecx
f010307a:	85 d2                	test   %edx,%edx
f010307c:	74 39                	je     f01030b7 <env_free+0x6b>
f010307e:	8b 42 48             	mov    0x48(%edx),%eax
f0103081:	83 ec 04             	sub    $0x4,%esp
f0103084:	51                   	push   %ecx
f0103085:	50                   	push   %eax
f0103086:	68 4a 5d 10 f0       	push   $0xf0105d4a
f010308b:	e8 a5 02 00 00       	call   f0103335 <cprintf>
f0103090:	83 c4 10             	add    $0x10,%esp
f0103093:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010309a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010309d:	e9 96 00 00 00       	jmp    f0103138 <env_free+0xec>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a2:	50                   	push   %eax
f01030a3:	68 fc 52 10 f0       	push   $0xf01052fc
f01030a8:	68 99 01 00 00       	push   $0x199
f01030ad:	68 ea 5c 10 f0       	push   $0xf0105cea
f01030b2:	e8 e9 cf ff ff       	call   f01000a0 <_panic>
f01030b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01030bc:	eb c3                	jmp    f0103081 <env_free+0x35>

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030be:	50                   	push   %eax
f01030bf:	68 f0 51 10 f0       	push   $0xf01051f0
f01030c4:	68 a8 01 00 00       	push   $0x1a8
f01030c9:	68 ea 5c 10 f0       	push   $0xf0105cea
f01030ce:	e8 cd cf ff ff       	call   f01000a0 <_panic>
f01030d3:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030d6:	39 f3                	cmp    %esi,%ebx
f01030d8:	74 21                	je     f01030fb <env_free+0xaf>
			if (pt[pteno] & PTE_P)
f01030da:	f6 03 01             	testb  $0x1,(%ebx)
f01030dd:	74 f4                	je     f01030d3 <env_free+0x87>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030df:	83 ec 08             	sub    $0x8,%esp
f01030e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030e5:	01 d8                	add    %ebx,%eax
f01030e7:	c1 e0 0a             	shl    $0xa,%eax
f01030ea:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01030ed:	50                   	push   %eax
f01030ee:	ff 77 5c             	pushl  0x5c(%edi)
f01030f1:	e8 b2 e0 ff ff       	call   f01011a8 <page_remove>
f01030f6:	83 c4 10             	add    $0x10,%esp
f01030f9:	eb d8                	jmp    f01030d3 <env_free+0x87>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01030fb:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103101:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103108:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010310b:	3b 05 e4 c9 19 f0    	cmp    0xf019c9e4,%eax
f0103111:	73 6a                	jae    f010317d <env_free+0x131>
		page_decref(pa2page(pa));
f0103113:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0103116:	a1 ec c9 19 f0       	mov    0xf019c9ec,%eax
f010311b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010311e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103121:	50                   	push   %eax
f0103122:	e8 c0 de ff ff       	call   f0100fe7 <page_decref>
f0103127:	83 c4 10             	add    $0x10,%esp
f010312a:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010312e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103131:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103136:	74 59                	je     f0103191 <env_free+0x145>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103138:	8b 47 5c             	mov    0x5c(%edi),%eax
f010313b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010313e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103141:	a8 01                	test   $0x1,%al
f0103143:	74 e5                	je     f010312a <env_free+0xde>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010314a:	89 c2                	mov    %eax,%edx
f010314c:	c1 ea 0c             	shr    $0xc,%edx
f010314f:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103152:	39 15 e4 c9 19 f0    	cmp    %edx,0xf019c9e4
f0103158:	0f 86 60 ff ff ff    	jbe    f01030be <env_free+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f010315e:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103164:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103167:	c1 e2 14             	shl    $0x14,%edx
f010316a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010316d:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103173:	f7 d8                	neg    %eax
f0103175:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103178:	e9 5d ff ff ff       	jmp    f01030da <env_free+0x8e>

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f010317d:	83 ec 04             	sub    $0x4,%esp
f0103180:	68 20 53 10 f0       	push   $0xf0105320
f0103185:	6a 4f                	push   $0x4f
f0103187:	68 dd 59 10 f0       	push   $0xf01059dd
f010318c:	e8 0f cf ff ff       	call   f01000a0 <_panic>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103191:	8b 45 08             	mov    0x8(%ebp),%eax
f0103194:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103197:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010319c:	76 52                	jbe    f01031f0 <env_free+0x1a4>
	e->env_pgdir = 0;
f010319e:	8b 55 08             	mov    0x8(%ebp),%edx
f01031a1:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01031a8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031ad:	c1 e8 0c             	shr    $0xc,%eax
f01031b0:	3b 05 e4 c9 19 f0    	cmp    0xf019c9e4,%eax
f01031b6:	73 4d                	jae    f0103205 <env_free+0x1b9>
	page_decref(pa2page(pa));
f01031b8:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01031bb:	8b 15 ec c9 19 f0    	mov    0xf019c9ec,%edx
f01031c1:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01031c4:	50                   	push   %eax
f01031c5:	e8 1d de ff ff       	call   f0100fe7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01031ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01031cd:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01031d4:	a1 30 bd 19 f0       	mov    0xf019bd30,%eax
f01031d9:	8b 55 08             	mov    0x8(%ebp),%edx
f01031dc:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f01031df:	89 15 30 bd 19 f0    	mov    %edx,0xf019bd30
}
f01031e5:	83 c4 10             	add    $0x10,%esp
f01031e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031eb:	5b                   	pop    %ebx
f01031ec:	5e                   	pop    %esi
f01031ed:	5f                   	pop    %edi
f01031ee:	5d                   	pop    %ebp
f01031ef:	c3                   	ret    

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f0:	50                   	push   %eax
f01031f1:	68 fc 52 10 f0       	push   $0xf01052fc
f01031f6:	68 b6 01 00 00       	push   $0x1b6
f01031fb:	68 ea 5c 10 f0       	push   $0xf0105cea
f0103200:	e8 9b ce ff ff       	call   f01000a0 <_panic>

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f0103205:	83 ec 04             	sub    $0x4,%esp
f0103208:	68 20 53 10 f0       	push   $0xf0105320
f010320d:	6a 4f                	push   $0x4f
f010320f:	68 dd 59 10 f0       	push   $0xf01059dd
f0103214:	e8 87 ce ff ff       	call   f01000a0 <_panic>

f0103219 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103219:	55                   	push   %ebp
f010321a:	89 e5                	mov    %esp,%ebp
f010321c:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f010321f:	ff 75 08             	pushl  0x8(%ebp)
f0103222:	e8 25 fe ff ff       	call   f010304c <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103227:	c7 04 24 a0 5d 10 f0 	movl   $0xf0105da0,(%esp)
f010322e:	e8 02 01 00 00       	call   f0103335 <cprintf>
f0103233:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103236:	83 ec 0c             	sub    $0xc,%esp
f0103239:	6a 00                	push   $0x0
f010323b:	e8 f6 d6 ff ff       	call   f0100936 <monitor>
f0103240:	83 c4 10             	add    $0x10,%esp
f0103243:	eb f1                	jmp    f0103236 <env_destroy+0x1d>

f0103245 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103245:	55                   	push   %ebp
f0103246:	89 e5                	mov    %esp,%ebp
f0103248:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f010324b:	8b 65 08             	mov    0x8(%ebp),%esp
f010324e:	61                   	popa   
f010324f:	07                   	pop    %es
f0103250:	1f                   	pop    %ds
f0103251:	83 c4 08             	add    $0x8,%esp
f0103254:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103255:	68 60 5d 10 f0       	push   $0xf0105d60
f010325a:	68 df 01 00 00       	push   $0x1df
f010325f:	68 ea 5c 10 f0       	push   $0xf0105cea
f0103264:	e8 37 ce ff ff       	call   f01000a0 <_panic>

f0103269 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103269:	55                   	push   %ebp
f010326a:	89 e5                	mov    %esp,%ebp
f010326c:	83 ec 08             	sub    $0x8,%esp
f010326f:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103272:	8b 15 28 bd 19 f0    	mov    0xf019bd28,%edx
f0103278:	85 d2                	test   %edx,%edx
f010327a:	74 06                	je     f0103282 <env_run+0x19>
f010327c:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103280:	74 2f                	je     f01032b1 <env_run+0x48>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103282:	a3 28 bd 19 f0       	mov    %eax,0xf019bd28
	e->env_status = ENV_RUNNING;
f0103287:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f010328e:	ff 40 58             	incl   0x58(%eax)

	lcr3(PADDR(e->env_pgdir));
f0103291:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103294:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010329a:	77 1e                	ja     f01032ba <env_run+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010329c:	52                   	push   %edx
f010329d:	68 fc 52 10 f0       	push   $0xf01052fc
f01032a2:	68 05 02 00 00       	push   $0x205
f01032a7:	68 ea 5c 10 f0       	push   $0xf0105cea
f01032ac:	e8 ef cd ff ff       	call   f01000a0 <_panic>
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
		curenv->env_status = ENV_RUNNABLE;
f01032b1:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f01032b8:	eb c8                	jmp    f0103282 <env_run+0x19>
	return (physaddr_t)kva - KERNBASE;
f01032ba:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01032c0:	0f 22 da             	mov    %edx,%cr3
	e->env_status = ENV_RUNNING;
	e->env_runs++;

	lcr3(PADDR(e->env_pgdir));

	env_pop_tf(&e->env_tf);
f01032c3:	83 ec 0c             	sub    $0xc,%esp
f01032c6:	50                   	push   %eax
f01032c7:	e8 79 ff ff ff       	call   f0103245 <env_pop_tf>

f01032cc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01032cc:	55                   	push   %ebp
f01032cd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d2:	ba 70 00 00 00       	mov    $0x70,%edx
f01032d7:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01032d8:	ba 71 00 00 00       	mov    $0x71,%edx
f01032dd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01032de:	0f b6 c0             	movzbl %al,%eax
}
f01032e1:	5d                   	pop    %ebp
f01032e2:	c3                   	ret    

f01032e3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01032e3:	55                   	push   %ebp
f01032e4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e9:	ba 70 00 00 00       	mov    $0x70,%edx
f01032ee:	ee                   	out    %al,(%dx)
f01032ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032f2:	ba 71 00 00 00       	mov    $0x71,%edx
f01032f7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01032f8:	5d                   	pop    %ebp
f01032f9:	c3                   	ret    
	...

f01032fc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01032fc:	55                   	push   %ebp
f01032fd:	89 e5                	mov    %esp,%ebp
f01032ff:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103302:	ff 75 08             	pushl  0x8(%ebp)
f0103305:	e8 ea d2 ff ff       	call   f01005f4 <cputchar>
	*cnt++;
}
f010330a:	83 c4 10             	add    $0x10,%esp
f010330d:	c9                   	leave  
f010330e:	c3                   	ret    

f010330f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010330f:	55                   	push   %ebp
f0103310:	89 e5                	mov    %esp,%ebp
f0103312:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010331c:	ff 75 0c             	pushl  0xc(%ebp)
f010331f:	ff 75 08             	pushl  0x8(%ebp)
f0103322:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103325:	50                   	push   %eax
f0103326:	68 fc 32 10 f0       	push   $0xf01032fc
f010332b:	e8 3e 0d 00 00       	call   f010406e <vprintfmt>
	return cnt;
}
f0103330:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103333:	c9                   	leave  
f0103334:	c3                   	ret    

f0103335 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103335:	55                   	push   %ebp
f0103336:	89 e5                	mov    %esp,%ebp
f0103338:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010333b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010333e:	50                   	push   %eax
f010333f:	ff 75 08             	pushl  0x8(%ebp)
f0103342:	e8 c8 ff ff ff       	call   f010330f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103347:	c9                   	leave  
f0103348:	c3                   	ret    
f0103349:	00 00                	add    %al,(%eax)
	...

f010334c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010334c:	55                   	push   %ebp
f010334d:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010334f:	b8 60 c5 19 f0       	mov    $0xf019c560,%eax
f0103354:	c7 05 64 c5 19 f0 00 	movl   $0xf0000000,0xf019c564
f010335b:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010335e:	66 c7 05 68 c5 19 f0 	movw   $0x10,0xf019c568
f0103365:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103367:	66 c7 05 c6 c5 19 f0 	movw   $0x68,0xf019c5c6
f010336e:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103370:	66 c7 05 48 c3 11 f0 	movw   $0x67,0xf011c348
f0103377:	67 00 
f0103379:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f010337f:	89 c2                	mov    %eax,%edx
f0103381:	c1 ea 10             	shr    $0x10,%edx
f0103384:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f010338a:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f0103391:	c1 e8 18             	shr    $0x18,%eax
f0103394:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103399:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f01033a0:	b8 28 00 00 00       	mov    $0x28,%eax
f01033a5:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f01033a8:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f01033ad:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01033b0:	5d                   	pop    %ebp
f01033b1:	c3                   	ret    

f01033b2 <trap_init>:
}


void
trap_init(void)
{
f01033b2:	55                   	push   %ebp
f01033b3:	89 e5                	mov    %esp,%ebp
	void handler17();
	void handler18();
	void handler19();
	void handler48();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, handler0, 0);
f01033b5:	b8 bc 3a 10 f0       	mov    $0xf0103abc,%eax
f01033ba:	66 a3 40 bd 19 f0    	mov    %ax,0xf019bd40
f01033c0:	66 c7 05 42 bd 19 f0 	movw   $0x8,0xf019bd42
f01033c7:	08 00 
f01033c9:	c6 05 44 bd 19 f0 00 	movb   $0x0,0xf019bd44
f01033d0:	c6 05 45 bd 19 f0 8f 	movb   $0x8f,0xf019bd45
f01033d7:	c1 e8 10             	shr    $0x10,%eax
f01033da:	66 a3 46 bd 19 f0    	mov    %ax,0xf019bd46
	SETGATE(idt[T_DEBUG], 1, GD_KT, handler1, 0);
f01033e0:	b8 c2 3a 10 f0       	mov    $0xf0103ac2,%eax
f01033e5:	66 a3 48 bd 19 f0    	mov    %ax,0xf019bd48
f01033eb:	66 c7 05 4a bd 19 f0 	movw   $0x8,0xf019bd4a
f01033f2:	08 00 
f01033f4:	c6 05 4c bd 19 f0 00 	movb   $0x0,0xf019bd4c
f01033fb:	c6 05 4d bd 19 f0 8f 	movb   $0x8f,0xf019bd4d
f0103402:	c1 e8 10             	shr    $0x10,%eax
f0103405:	66 a3 4e bd 19 f0    	mov    %ax,0xf019bd4e
	SETGATE(idt[T_NMI], 1, GD_KT, handler2, 0);
f010340b:	b8 c8 3a 10 f0       	mov    $0xf0103ac8,%eax
f0103410:	66 a3 50 bd 19 f0    	mov    %ax,0xf019bd50
f0103416:	66 c7 05 52 bd 19 f0 	movw   $0x8,0xf019bd52
f010341d:	08 00 
f010341f:	c6 05 54 bd 19 f0 00 	movb   $0x0,0xf019bd54
f0103426:	c6 05 55 bd 19 f0 8f 	movb   $0x8f,0xf019bd55
f010342d:	c1 e8 10             	shr    $0x10,%eax
f0103430:	66 a3 56 bd 19 f0    	mov    %ax,0xf019bd56
	SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 3);
f0103436:	b8 ce 3a 10 f0       	mov    $0xf0103ace,%eax
f010343b:	66 a3 58 bd 19 f0    	mov    %ax,0xf019bd58
f0103441:	66 c7 05 5a bd 19 f0 	movw   $0x8,0xf019bd5a
f0103448:	08 00 
f010344a:	c6 05 5c bd 19 f0 00 	movb   $0x0,0xf019bd5c
f0103451:	c6 05 5d bd 19 f0 ef 	movb   $0xef,0xf019bd5d
f0103458:	c1 e8 10             	shr    $0x10,%eax
f010345b:	66 a3 5e bd 19 f0    	mov    %ax,0xf019bd5e
	SETGATE(idt[T_OFLOW], 1, GD_KT, handler4, 0);
f0103461:	b8 d4 3a 10 f0       	mov    $0xf0103ad4,%eax
f0103466:	66 a3 60 bd 19 f0    	mov    %ax,0xf019bd60
f010346c:	66 c7 05 62 bd 19 f0 	movw   $0x8,0xf019bd62
f0103473:	08 00 
f0103475:	c6 05 64 bd 19 f0 00 	movb   $0x0,0xf019bd64
f010347c:	c6 05 65 bd 19 f0 8f 	movb   $0x8f,0xf019bd65
f0103483:	c1 e8 10             	shr    $0x10,%eax
f0103486:	66 a3 66 bd 19 f0    	mov    %ax,0xf019bd66
	SETGATE(idt[T_BOUND], 1, GD_KT, handler5, 0);
f010348c:	b8 da 3a 10 f0       	mov    $0xf0103ada,%eax
f0103491:	66 a3 68 bd 19 f0    	mov    %ax,0xf019bd68
f0103497:	66 c7 05 6a bd 19 f0 	movw   $0x8,0xf019bd6a
f010349e:	08 00 
f01034a0:	c6 05 6c bd 19 f0 00 	movb   $0x0,0xf019bd6c
f01034a7:	c6 05 6d bd 19 f0 8f 	movb   $0x8f,0xf019bd6d
f01034ae:	c1 e8 10             	shr    $0x10,%eax
f01034b1:	66 a3 6e bd 19 f0    	mov    %ax,0xf019bd6e
	SETGATE(idt[T_ILLOP], 1, GD_KT, handler6, 0);
f01034b7:	b8 e0 3a 10 f0       	mov    $0xf0103ae0,%eax
f01034bc:	66 a3 70 bd 19 f0    	mov    %ax,0xf019bd70
f01034c2:	66 c7 05 72 bd 19 f0 	movw   $0x8,0xf019bd72
f01034c9:	08 00 
f01034cb:	c6 05 74 bd 19 f0 00 	movb   $0x0,0xf019bd74
f01034d2:	c6 05 75 bd 19 f0 8f 	movb   $0x8f,0xf019bd75
f01034d9:	c1 e8 10             	shr    $0x10,%eax
f01034dc:	66 a3 76 bd 19 f0    	mov    %ax,0xf019bd76
	SETGATE(idt[T_DEVICE], 1, GD_KT, handler7, 0);
f01034e2:	b8 e6 3a 10 f0       	mov    $0xf0103ae6,%eax
f01034e7:	66 a3 78 bd 19 f0    	mov    %ax,0xf019bd78
f01034ed:	66 c7 05 7a bd 19 f0 	movw   $0x8,0xf019bd7a
f01034f4:	08 00 
f01034f6:	c6 05 7c bd 19 f0 00 	movb   $0x0,0xf019bd7c
f01034fd:	c6 05 7d bd 19 f0 8f 	movb   $0x8f,0xf019bd7d
f0103504:	c1 e8 10             	shr    $0x10,%eax
f0103507:	66 a3 7e bd 19 f0    	mov    %ax,0xf019bd7e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, handler8, 0);
f010350d:	b8 ec 3a 10 f0       	mov    $0xf0103aec,%eax
f0103512:	66 a3 80 bd 19 f0    	mov    %ax,0xf019bd80
f0103518:	66 c7 05 82 bd 19 f0 	movw   $0x8,0xf019bd82
f010351f:	08 00 
f0103521:	c6 05 84 bd 19 f0 00 	movb   $0x0,0xf019bd84
f0103528:	c6 05 85 bd 19 f0 8f 	movb   $0x8f,0xf019bd85
f010352f:	c1 e8 10             	shr    $0x10,%eax
f0103532:	66 a3 86 bd 19 f0    	mov    %ax,0xf019bd86

	SETGATE(idt[T_TSS], 1, GD_KT, handler10, 0);
f0103538:	b8 f0 3a 10 f0       	mov    $0xf0103af0,%eax
f010353d:	66 a3 90 bd 19 f0    	mov    %ax,0xf019bd90
f0103543:	66 c7 05 92 bd 19 f0 	movw   $0x8,0xf019bd92
f010354a:	08 00 
f010354c:	c6 05 94 bd 19 f0 00 	movb   $0x0,0xf019bd94
f0103553:	c6 05 95 bd 19 f0 8f 	movb   $0x8f,0xf019bd95
f010355a:	c1 e8 10             	shr    $0x10,%eax
f010355d:	66 a3 96 bd 19 f0    	mov    %ax,0xf019bd96
	SETGATE(idt[T_SEGNP], 1, GD_KT, handler11, 0);
f0103563:	b8 f4 3a 10 f0       	mov    $0xf0103af4,%eax
f0103568:	66 a3 98 bd 19 f0    	mov    %ax,0xf019bd98
f010356e:	66 c7 05 9a bd 19 f0 	movw   $0x8,0xf019bd9a
f0103575:	08 00 
f0103577:	c6 05 9c bd 19 f0 00 	movb   $0x0,0xf019bd9c
f010357e:	c6 05 9d bd 19 f0 8f 	movb   $0x8f,0xf019bd9d
f0103585:	c1 e8 10             	shr    $0x10,%eax
f0103588:	66 a3 9e bd 19 f0    	mov    %ax,0xf019bd9e
	SETGATE(idt[T_STACK], 1, GD_KT, handler12, 0);
f010358e:	b8 f8 3a 10 f0       	mov    $0xf0103af8,%eax
f0103593:	66 a3 a0 bd 19 f0    	mov    %ax,0xf019bda0
f0103599:	66 c7 05 a2 bd 19 f0 	movw   $0x8,0xf019bda2
f01035a0:	08 00 
f01035a2:	c6 05 a4 bd 19 f0 00 	movb   $0x0,0xf019bda4
f01035a9:	c6 05 a5 bd 19 f0 8f 	movb   $0x8f,0xf019bda5
f01035b0:	c1 e8 10             	shr    $0x10,%eax
f01035b3:	66 a3 a6 bd 19 f0    	mov    %ax,0xf019bda6
	SETGATE(idt[T_GPFLT], 1, GD_KT, handler13, 0);
f01035b9:	b8 fc 3a 10 f0       	mov    $0xf0103afc,%eax
f01035be:	66 a3 a8 bd 19 f0    	mov    %ax,0xf019bda8
f01035c4:	66 c7 05 aa bd 19 f0 	movw   $0x8,0xf019bdaa
f01035cb:	08 00 
f01035cd:	c6 05 ac bd 19 f0 00 	movb   $0x0,0xf019bdac
f01035d4:	c6 05 ad bd 19 f0 8f 	movb   $0x8f,0xf019bdad
f01035db:	c1 e8 10             	shr    $0x10,%eax
f01035de:	66 a3 ae bd 19 f0    	mov    %ax,0xf019bdae
	SETGATE(idt[T_PGFLT], 1, GD_KT, handler14, 0);
f01035e4:	b8 00 3b 10 f0       	mov    $0xf0103b00,%eax
f01035e9:	66 a3 b0 bd 19 f0    	mov    %ax,0xf019bdb0
f01035ef:	66 c7 05 b2 bd 19 f0 	movw   $0x8,0xf019bdb2
f01035f6:	08 00 
f01035f8:	c6 05 b4 bd 19 f0 00 	movb   $0x0,0xf019bdb4
f01035ff:	c6 05 b5 bd 19 f0 8f 	movb   $0x8f,0xf019bdb5
f0103606:	c1 e8 10             	shr    $0x10,%eax
f0103609:	66 a3 b6 bd 19 f0    	mov    %ax,0xf019bdb6

	SETGATE(idt[T_FPERR], 1, GD_KT, handler16, 0);
f010360f:	b8 04 3b 10 f0       	mov    $0xf0103b04,%eax
f0103614:	66 a3 c0 bd 19 f0    	mov    %ax,0xf019bdc0
f010361a:	66 c7 05 c2 bd 19 f0 	movw   $0x8,0xf019bdc2
f0103621:	08 00 
f0103623:	c6 05 c4 bd 19 f0 00 	movb   $0x0,0xf019bdc4
f010362a:	c6 05 c5 bd 19 f0 8f 	movb   $0x8f,0xf019bdc5
f0103631:	c1 e8 10             	shr    $0x10,%eax
f0103634:	66 a3 c6 bd 19 f0    	mov    %ax,0xf019bdc6
	SETGATE(idt[T_ALIGN], 1, GD_KT, handler17, 0);
f010363a:	b8 0a 3b 10 f0       	mov    $0xf0103b0a,%eax
f010363f:	66 a3 c8 bd 19 f0    	mov    %ax,0xf019bdc8
f0103645:	66 c7 05 ca bd 19 f0 	movw   $0x8,0xf019bdca
f010364c:	08 00 
f010364e:	c6 05 cc bd 19 f0 00 	movb   $0x0,0xf019bdcc
f0103655:	c6 05 cd bd 19 f0 8f 	movb   $0x8f,0xf019bdcd
f010365c:	c1 e8 10             	shr    $0x10,%eax
f010365f:	66 a3 ce bd 19 f0    	mov    %ax,0xf019bdce
	SETGATE(idt[T_MCHK], 1, GD_KT, handler18, 0);
f0103665:	b8 0e 3b 10 f0       	mov    $0xf0103b0e,%eax
f010366a:	66 a3 d0 bd 19 f0    	mov    %ax,0xf019bdd0
f0103670:	66 c7 05 d2 bd 19 f0 	movw   $0x8,0xf019bdd2
f0103677:	08 00 
f0103679:	c6 05 d4 bd 19 f0 00 	movb   $0x0,0xf019bdd4
f0103680:	c6 05 d5 bd 19 f0 8f 	movb   $0x8f,0xf019bdd5
f0103687:	c1 e8 10             	shr    $0x10,%eax
f010368a:	66 a3 d6 bd 19 f0    	mov    %ax,0xf019bdd6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, handler19, 0);
f0103690:	b8 14 3b 10 f0       	mov    $0xf0103b14,%eax
f0103695:	66 a3 d8 bd 19 f0    	mov    %ax,0xf019bdd8
f010369b:	66 c7 05 da bd 19 f0 	movw   $0x8,0xf019bdda
f01036a2:	08 00 
f01036a4:	c6 05 dc bd 19 f0 00 	movb   $0x0,0xf019bddc
f01036ab:	c6 05 dd bd 19 f0 8f 	movb   $0x8f,0xf019bddd
f01036b2:	c1 e8 10             	shr    $0x10,%eax
f01036b5:	66 a3 de bd 19 f0    	mov    %ax,0xf019bdde

	// interrupt
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f01036bb:	b8 1a 3b 10 f0       	mov    $0xf0103b1a,%eax
f01036c0:	66 a3 c0 be 19 f0    	mov    %ax,0xf019bec0
f01036c6:	66 c7 05 c2 be 19 f0 	movw   $0x8,0xf019bec2
f01036cd:	08 00 
f01036cf:	c6 05 c4 be 19 f0 00 	movb   $0x0,0xf019bec4
f01036d6:	c6 05 c5 be 19 f0 ee 	movb   $0xee,0xf019bec5
f01036dd:	c1 e8 10             	shr    $0x10,%eax
f01036e0:	66 a3 c6 be 19 f0    	mov    %ax,0xf019bec6

	// Per-CPU setup
	trap_init_percpu();
f01036e6:	e8 61 fc ff ff       	call   f010334c <trap_init_percpu>
}
f01036eb:	5d                   	pop    %ebp
f01036ec:	c3                   	ret    

f01036ed <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01036ed:	55                   	push   %ebp
f01036ee:	89 e5                	mov    %esp,%ebp
f01036f0:	53                   	push   %ebx
f01036f1:	83 ec 0c             	sub    $0xc,%esp
f01036f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01036f7:	ff 33                	pushl  (%ebx)
f01036f9:	68 d6 5d 10 f0       	push   $0xf0105dd6
f01036fe:	e8 32 fc ff ff       	call   f0103335 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103703:	83 c4 08             	add    $0x8,%esp
f0103706:	ff 73 04             	pushl  0x4(%ebx)
f0103709:	68 e5 5d 10 f0       	push   $0xf0105de5
f010370e:	e8 22 fc ff ff       	call   f0103335 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103713:	83 c4 08             	add    $0x8,%esp
f0103716:	ff 73 08             	pushl  0x8(%ebx)
f0103719:	68 f4 5d 10 f0       	push   $0xf0105df4
f010371e:	e8 12 fc ff ff       	call   f0103335 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103723:	83 c4 08             	add    $0x8,%esp
f0103726:	ff 73 0c             	pushl  0xc(%ebx)
f0103729:	68 03 5e 10 f0       	push   $0xf0105e03
f010372e:	e8 02 fc ff ff       	call   f0103335 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103733:	83 c4 08             	add    $0x8,%esp
f0103736:	ff 73 10             	pushl  0x10(%ebx)
f0103739:	68 12 5e 10 f0       	push   $0xf0105e12
f010373e:	e8 f2 fb ff ff       	call   f0103335 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103743:	83 c4 08             	add    $0x8,%esp
f0103746:	ff 73 14             	pushl  0x14(%ebx)
f0103749:	68 21 5e 10 f0       	push   $0xf0105e21
f010374e:	e8 e2 fb ff ff       	call   f0103335 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103753:	83 c4 08             	add    $0x8,%esp
f0103756:	ff 73 18             	pushl  0x18(%ebx)
f0103759:	68 30 5e 10 f0       	push   $0xf0105e30
f010375e:	e8 d2 fb ff ff       	call   f0103335 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103763:	83 c4 08             	add    $0x8,%esp
f0103766:	ff 73 1c             	pushl  0x1c(%ebx)
f0103769:	68 3f 5e 10 f0       	push   $0xf0105e3f
f010376e:	e8 c2 fb ff ff       	call   f0103335 <cprintf>
}
f0103773:	83 c4 10             	add    $0x10,%esp
f0103776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103779:	c9                   	leave  
f010377a:	c3                   	ret    

f010377b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010377b:	55                   	push   %ebp
f010377c:	89 e5                	mov    %esp,%ebp
f010377e:	53                   	push   %ebx
f010377f:	83 ec 0c             	sub    $0xc,%esp
f0103782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103785:	53                   	push   %ebx
f0103786:	68 8f 5f 10 f0       	push   $0xf0105f8f
f010378b:	e8 a5 fb ff ff       	call   f0103335 <cprintf>
	print_regs(&tf->tf_regs);
f0103790:	89 1c 24             	mov    %ebx,(%esp)
f0103793:	e8 55 ff ff ff       	call   f01036ed <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103798:	83 c4 08             	add    $0x8,%esp
f010379b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010379f:	50                   	push   %eax
f01037a0:	68 90 5e 10 f0       	push   $0xf0105e90
f01037a5:	e8 8b fb ff ff       	call   f0103335 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01037aa:	83 c4 08             	add    $0x8,%esp
f01037ad:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01037b1:	50                   	push   %eax
f01037b2:	68 a3 5e 10 f0       	push   $0xf0105ea3
f01037b7:	e8 79 fb ff ff       	call   f0103335 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037bc:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01037bf:	83 c4 10             	add    $0x10,%esp
f01037c2:	83 f8 13             	cmp    $0x13,%eax
f01037c5:	76 10                	jbe    f01037d7 <print_trapframe+0x5c>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f01037c7:	83 f8 30             	cmp    $0x30,%eax
f01037ca:	0f 84 c3 00 00 00    	je     f0103893 <print_trapframe+0x118>
		return "System call";
	return "(unknown trap)";
f01037d0:	ba 5a 5e 10 f0       	mov    $0xf0105e5a,%edx
f01037d5:	eb 07                	jmp    f01037de <print_trapframe+0x63>
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
f01037d7:	8b 14 85 60 61 10 f0 	mov    -0xfef9ea0(,%eax,4),%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037de:	83 ec 04             	sub    $0x4,%esp
f01037e1:	52                   	push   %edx
f01037e2:	50                   	push   %eax
f01037e3:	68 b6 5e 10 f0       	push   $0xf0105eb6
f01037e8:	e8 48 fb ff ff       	call   f0103335 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01037ed:	83 c4 10             	add    $0x10,%esp
f01037f0:	39 1d 40 c5 19 f0    	cmp    %ebx,0xf019c540
f01037f6:	0f 84 a1 00 00 00    	je     f010389d <print_trapframe+0x122>
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
f01037fc:	83 ec 08             	sub    $0x8,%esp
f01037ff:	ff 73 2c             	pushl  0x2c(%ebx)
f0103802:	68 d7 5e 10 f0       	push   $0xf0105ed7
f0103807:	e8 29 fb ff ff       	call   f0103335 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010380c:	83 c4 10             	add    $0x10,%esp
f010380f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103813:	0f 85 c5 00 00 00    	jne    f01038de <print_trapframe+0x163>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103819:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010381c:	a8 01                	test   $0x1,%al
f010381e:	0f 85 9c 00 00 00    	jne    f01038c0 <print_trapframe+0x145>
f0103824:	b9 74 5e 10 f0       	mov    $0xf0105e74,%ecx
f0103829:	a8 02                	test   $0x2,%al
f010382b:	0f 85 99 00 00 00    	jne    f01038ca <print_trapframe+0x14f>
f0103831:	ba 86 5e 10 f0       	mov    $0xf0105e86,%edx
f0103836:	a8 04                	test   $0x4,%al
f0103838:	0f 85 96 00 00 00    	jne    f01038d4 <print_trapframe+0x159>
f010383e:	b8 ba 5f 10 f0       	mov    $0xf0105fba,%eax
f0103843:	51                   	push   %ecx
f0103844:	52                   	push   %edx
f0103845:	50                   	push   %eax
f0103846:	68 e5 5e 10 f0       	push   $0xf0105ee5
f010384b:	e8 e5 fa ff ff       	call   f0103335 <cprintf>
f0103850:	83 c4 10             	add    $0x10,%esp
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103853:	83 ec 08             	sub    $0x8,%esp
f0103856:	ff 73 30             	pushl  0x30(%ebx)
f0103859:	68 f4 5e 10 f0       	push   $0xf0105ef4
f010385e:	e8 d2 fa ff ff       	call   f0103335 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103863:	83 c4 08             	add    $0x8,%esp
f0103866:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010386a:	50                   	push   %eax
f010386b:	68 03 5f 10 f0       	push   $0xf0105f03
f0103870:	e8 c0 fa ff ff       	call   f0103335 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103875:	83 c4 08             	add    $0x8,%esp
f0103878:	ff 73 38             	pushl  0x38(%ebx)
f010387b:	68 16 5f 10 f0       	push   $0xf0105f16
f0103880:	e8 b0 fa ff ff       	call   f0103335 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103885:	83 c4 10             	add    $0x10,%esp
f0103888:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010388c:	75 65                	jne    f01038f3 <print_trapframe+0x178>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}
f010388e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103891:	c9                   	leave  
f0103892:	c3                   	ret    
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103893:	ba 4e 5e 10 f0       	mov    $0xf0105e4e,%edx
f0103898:	e9 41 ff ff ff       	jmp    f01037de <print_trapframe+0x63>
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010389d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01038a1:	0f 85 55 ff ff ff    	jne    f01037fc <print_trapframe+0x81>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01038a7:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01038aa:	83 ec 08             	sub    $0x8,%esp
f01038ad:	50                   	push   %eax
f01038ae:	68 c8 5e 10 f0       	push   $0xf0105ec8
f01038b3:	e8 7d fa ff ff       	call   f0103335 <cprintf>
f01038b8:	83 c4 10             	add    $0x10,%esp
f01038bb:	e9 3c ff ff ff       	jmp    f01037fc <print_trapframe+0x81>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01038c0:	b9 69 5e 10 f0       	mov    $0xf0105e69,%ecx
f01038c5:	e9 5f ff ff ff       	jmp    f0103829 <print_trapframe+0xae>
f01038ca:	ba 80 5e 10 f0       	mov    $0xf0105e80,%edx
f01038cf:	e9 62 ff ff ff       	jmp    f0103836 <print_trapframe+0xbb>
f01038d4:	b8 8b 5e 10 f0       	mov    $0xf0105e8b,%eax
f01038d9:	e9 65 ff ff ff       	jmp    f0103843 <print_trapframe+0xc8>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01038de:	83 ec 0c             	sub    $0xc,%esp
f01038e1:	68 a7 5c 10 f0       	push   $0xf0105ca7
f01038e6:	e8 4a fa ff ff       	call   f0103335 <cprintf>
f01038eb:	83 c4 10             	add    $0x10,%esp
f01038ee:	e9 60 ff ff ff       	jmp    f0103853 <print_trapframe+0xd8>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01038f3:	83 ec 08             	sub    $0x8,%esp
f01038f6:	ff 73 3c             	pushl  0x3c(%ebx)
f01038f9:	68 25 5f 10 f0       	push   $0xf0105f25
f01038fe:	e8 32 fa ff ff       	call   f0103335 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103903:	83 c4 08             	add    $0x8,%esp
f0103906:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010390a:	50                   	push   %eax
f010390b:	68 34 5f 10 f0       	push   $0xf0105f34
f0103910:	e8 20 fa ff ff       	call   f0103335 <cprintf>
f0103915:	83 c4 10             	add    $0x10,%esp
	}
}
f0103918:	e9 71 ff ff ff       	jmp    f010388e <print_trapframe+0x113>

f010391d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010391d:	55                   	push   %ebp
f010391e:	89 e5                	mov    %esp,%ebp
f0103920:	53                   	push   %ebx
f0103921:	83 ec 04             	sub    $0x4,%esp
f0103924:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103927:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs & 3) == 0) panic("page fault in kernel-mode");
f010392a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010392e:	74 34                	je     f0103964 <page_fault_handler+0x47>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103930:	ff 73 30             	pushl  0x30(%ebx)
f0103933:	50                   	push   %eax
f0103934:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0103939:	ff 70 48             	pushl  0x48(%eax)
f010393c:	68 04 61 10 f0       	push   $0xf0106104
f0103941:	e8 ef f9 ff ff       	call   f0103335 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103946:	89 1c 24             	mov    %ebx,(%esp)
f0103949:	e8 2d fe ff ff       	call   f010377b <print_trapframe>
	env_destroy(curenv);
f010394e:	83 c4 04             	add    $0x4,%esp
f0103951:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103957:	e8 bd f8 ff ff       	call   f0103219 <env_destroy>
}
f010395c:	83 c4 10             	add    $0x10,%esp
f010395f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103962:	c9                   	leave  
f0103963:	c3                   	ret    
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs & 3) == 0) panic("page fault in kernel-mode");
f0103964:	83 ec 04             	sub    $0x4,%esp
f0103967:	68 47 5f 10 f0       	push   $0xf0105f47
f010396c:	68 0d 01 00 00       	push   $0x10d
f0103971:	68 61 5f 10 f0       	push   $0xf0105f61
f0103976:	e8 25 c7 ff ff       	call   f01000a0 <_panic>

f010397b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010397b:	55                   	push   %ebp
f010397c:	89 e5                	mov    %esp,%ebp
f010397e:	57                   	push   %edi
f010397f:	56                   	push   %esi
f0103980:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103983:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103984:	9c                   	pushf  
f0103985:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103986:	f6 c4 02             	test   $0x2,%ah
f0103989:	74 19                	je     f01039a4 <trap+0x29>
f010398b:	68 6d 5f 10 f0       	push   $0xf0105f6d
f0103990:	68 f7 59 10 f0       	push   $0xf01059f7
f0103995:	68 e5 00 00 00       	push   $0xe5
f010399a:	68 61 5f 10 f0       	push   $0xf0105f61
f010399f:	e8 fc c6 ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01039a4:	83 ec 08             	sub    $0x8,%esp
f01039a7:	56                   	push   %esi
f01039a8:	68 86 5f 10 f0       	push   $0xf0105f86
f01039ad:	e8 83 f9 ff ff       	call   f0103335 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01039b2:	66 8b 46 34          	mov    0x34(%esi),%ax
f01039b6:	83 e0 03             	and    $0x3,%eax
f01039b9:	83 c4 10             	add    $0x10,%esp
f01039bc:	66 83 f8 03          	cmp    $0x3,%ax
f01039c0:	75 18                	jne    f01039da <trap+0x5f>
		// Trapped from user mode.
		assert(curenv);
f01039c2:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f01039c7:	85 c0                	test   %eax,%eax
f01039c9:	74 55                	je     f0103a20 <trap+0xa5>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01039cb:	b9 11 00 00 00       	mov    $0x11,%ecx
f01039d0:	89 c7                	mov    %eax,%edi
f01039d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01039d4:	8b 35 28 bd 19 f0    	mov    0xf019bd28,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01039da:	89 35 40 c5 19 f0    	mov    %esi,0xf019c540
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    switch (tf->tf_trapno) {
f01039e0:	8b 46 28             	mov    0x28(%esi),%eax
f01039e3:	83 f8 0e             	cmp    $0xe,%eax
f01039e6:	74 51                	je     f0103a39 <trap+0xbe>
f01039e8:	83 f8 30             	cmp    $0x30,%eax
f01039eb:	0f 84 8a 00 00 00    	je     f0103a7b <trap+0x100>
f01039f1:	83 f8 03             	cmp    $0x3,%eax
f01039f4:	74 77                	je     f0103a6d <trap+0xf2>
										  tf->tf_regs.reg_edi,
										  tf->tf_regs.reg_esi);
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
f01039f6:	83 ec 0c             	sub    $0xc,%esp
f01039f9:	56                   	push   %esi
f01039fa:	e8 7c fd ff ff       	call   f010377b <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01039ff:	83 c4 10             	add    $0x10,%esp
f0103a02:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a07:	0f 84 8f 00 00 00    	je     f0103a9c <trap+0x121>
				panic("unhandled trap in kernel");
			else {
				env_destroy(curenv);
f0103a0d:	83 ec 0c             	sub    $0xc,%esp
f0103a10:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103a16:	e8 fe f7 ff ff       	call   f0103219 <env_destroy>
f0103a1b:	83 c4 10             	add    $0x10,%esp
f0103a1e:	eb 25                	jmp    f0103a45 <trap+0xca>

	cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		assert(curenv);
f0103a20:	68 a1 5f 10 f0       	push   $0xf0105fa1
f0103a25:	68 f7 59 10 f0       	push   $0xf01059f7
f0103a2a:	68 eb 00 00 00       	push   $0xeb
f0103a2f:	68 61 5f 10 f0       	push   $0xf0105f61
f0103a34:	e8 67 c6 ff ff       	call   f01000a0 <_panic>
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
f0103a39:	83 ec 0c             	sub    $0xc,%esp
f0103a3c:	56                   	push   %esi
f0103a3d:	e8 db fe ff ff       	call   f010391d <page_fault_handler>
f0103a42:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a45:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0103a4a:	85 c0                	test   %eax,%eax
f0103a4c:	74 06                	je     f0103a54 <trap+0xd9>
f0103a4e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a52:	74 5f                	je     f0103ab3 <trap+0x138>
f0103a54:	68 28 61 10 f0       	push   $0xf0106128
f0103a59:	68 f7 59 10 f0       	push   $0xf01059f7
f0103a5e:	68 fd 00 00 00       	push   $0xfd
f0103a63:	68 61 5f 10 f0       	push   $0xf0105f61
f0103a68:	e8 33 c6 ff ff       	call   f01000a0 <_panic>
    switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
f0103a6d:	83 ec 0c             	sub    $0xc,%esp
f0103a70:	56                   	push   %esi
f0103a71:	e8 c0 ce ff ff       	call   f0100936 <monitor>
f0103a76:	83 c4 10             	add    $0x10,%esp
f0103a79:	eb ca                	jmp    f0103a45 <trap+0xca>
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0103a7b:	83 ec 08             	sub    $0x8,%esp
f0103a7e:	ff 76 04             	pushl  0x4(%esi)
f0103a81:	ff 36                	pushl  (%esi)
f0103a83:	ff 76 10             	pushl  0x10(%esi)
f0103a86:	ff 76 18             	pushl  0x18(%esi)
f0103a89:	ff 76 14             	pushl  0x14(%esi)
f0103a8c:	ff 76 1c             	pushl  0x1c(%esi)
f0103a8f:	e8 a0 00 00 00       	call   f0103b34 <syscall>
f0103a94:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103a97:	83 c4 20             	add    $0x20,%esp
f0103a9a:	eb a9                	jmp    f0103a45 <trap+0xca>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
			if (tf->tf_cs == GD_KT)
				panic("unhandled trap in kernel");
f0103a9c:	83 ec 04             	sub    $0x4,%esp
f0103a9f:	68 a8 5f 10 f0       	push   $0xf0105fa8
f0103aa4:	68 d3 00 00 00       	push   $0xd3
f0103aa9:	68 61 5f 10 f0       	push   $0xf0105f61
f0103aae:	e8 ed c5 ff ff       	call   f01000a0 <_panic>
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
	env_run(curenv);
f0103ab3:	83 ec 0c             	sub    $0xc,%esp
f0103ab6:	50                   	push   %eax
f0103ab7:	e8 ad f7 ff ff       	call   f0103269 <env_run>

f0103abc <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

 TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0103abc:	6a 00                	push   $0x0
f0103abe:	6a 00                	push   $0x0
f0103ac0:	eb 5e                	jmp    f0103b20 <_alltraps>

f0103ac2 <handler1>:
 TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0103ac2:	6a 00                	push   $0x0
f0103ac4:	6a 01                	push   $0x1
f0103ac6:	eb 58                	jmp    f0103b20 <_alltraps>

f0103ac8 <handler2>:
 TRAPHANDLER_NOEC(handler2, T_NMI)
f0103ac8:	6a 00                	push   $0x0
f0103aca:	6a 02                	push   $0x2
f0103acc:	eb 52                	jmp    f0103b20 <_alltraps>

f0103ace <handler3>:
 TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0103ace:	6a 00                	push   $0x0
f0103ad0:	6a 03                	push   $0x3
f0103ad2:	eb 4c                	jmp    f0103b20 <_alltraps>

f0103ad4 <handler4>:
 TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0103ad4:	6a 00                	push   $0x0
f0103ad6:	6a 04                	push   $0x4
f0103ad8:	eb 46                	jmp    f0103b20 <_alltraps>

f0103ada <handler5>:
 TRAPHANDLER_NOEC(handler5, T_BOUND)
f0103ada:	6a 00                	push   $0x0
f0103adc:	6a 05                	push   $0x5
f0103ade:	eb 40                	jmp    f0103b20 <_alltraps>

f0103ae0 <handler6>:
 TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0103ae0:	6a 00                	push   $0x0
f0103ae2:	6a 06                	push   $0x6
f0103ae4:	eb 3a                	jmp    f0103b20 <_alltraps>

f0103ae6 <handler7>:
 TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0103ae6:	6a 00                	push   $0x0
f0103ae8:	6a 07                	push   $0x7
f0103aea:	eb 34                	jmp    f0103b20 <_alltraps>

f0103aec <handler8>:
 TRAPHANDLER(handler8, T_DBLFLT)
f0103aec:	6a 08                	push   $0x8
f0103aee:	eb 30                	jmp    f0103b20 <_alltraps>

f0103af0 <handler10>:

 // 9 deprecated since 386
 TRAPHANDLER(handler10, T_TSS)
f0103af0:	6a 0a                	push   $0xa
f0103af2:	eb 2c                	jmp    f0103b20 <_alltraps>

f0103af4 <handler11>:
 TRAPHANDLER(handler11, T_SEGNP)
f0103af4:	6a 0b                	push   $0xb
f0103af6:	eb 28                	jmp    f0103b20 <_alltraps>

f0103af8 <handler12>:
 TRAPHANDLER(handler12, T_STACK)
f0103af8:	6a 0c                	push   $0xc
f0103afa:	eb 24                	jmp    f0103b20 <_alltraps>

f0103afc <handler13>:
 TRAPHANDLER(handler13, T_GPFLT)
f0103afc:	6a 0d                	push   $0xd
f0103afe:	eb 20                	jmp    f0103b20 <_alltraps>

f0103b00 <handler14>:
 TRAPHANDLER(handler14, T_PGFLT)
f0103b00:	6a 0e                	push   $0xe
f0103b02:	eb 1c                	jmp    f0103b20 <_alltraps>

f0103b04 <handler16>:

 // 15 reserved by intel
 TRAPHANDLER_NOEC(handler16, T_FPERR)
f0103b04:	6a 00                	push   $0x0
f0103b06:	6a 10                	push   $0x10
f0103b08:	eb 16                	jmp    f0103b20 <_alltraps>

f0103b0a <handler17>:
 TRAPHANDLER(handler17, T_ALIGN)
f0103b0a:	6a 11                	push   $0x11
f0103b0c:	eb 12                	jmp    f0103b20 <_alltraps>

f0103b0e <handler18>:
 TRAPHANDLER_NOEC(handler18, T_MCHK)
f0103b0e:	6a 00                	push   $0x0
f0103b10:	6a 12                	push   $0x12
f0103b12:	eb 0c                	jmp    f0103b20 <_alltraps>

f0103b14 <handler19>:
 TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0103b14:	6a 00                	push   $0x0
f0103b16:	6a 13                	push   $0x13
f0103b18:	eb 06                	jmp    f0103b20 <_alltraps>

f0103b1a <handler48>:

 // system call (interrupt)
 TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f0103b1a:	6a 00                	push   $0x0
f0103b1c:	6a 30                	push   $0x30
f0103b1e:	eb 00                	jmp    f0103b20 <_alltraps>

f0103b20 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
    pushl %ds
f0103b20:	1e                   	push   %ds
    pushl %es
f0103b21:	06                   	push   %es
    pushal
f0103b22:	60                   	pusha  

    movw $GD_KD, %ax
f0103b23:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f0103b27:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0103b29:	8e c0                	mov    %eax,%es
    pushl %esp
f0103b2b:	54                   	push   %esp
    call trap
f0103b2c:	e8 4a fe ff ff       	call   f010397b <trap>
f0103b31:	00 00                	add    %al,(%eax)
	...

f0103b34 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103b34:	55                   	push   %ebp
f0103b35:	89 e5                	mov    %esp,%ebp
f0103b37:	83 ec 18             	sub    $0x18,%esp
f0103b3a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int32_t retVal = 0;
	switch (syscallno) {
f0103b3d:	83 f8 01             	cmp    $0x1,%eax
f0103b40:	74 4a                	je     f0103b8c <syscall+0x58>
f0103b42:	83 f8 01             	cmp    $0x1,%eax
f0103b45:	72 15                	jb     f0103b5c <syscall+0x28>
f0103b47:	83 f8 02             	cmp    $0x2,%eax
f0103b4a:	0f 84 a7 00 00 00    	je     f0103bf7 <syscall+0xc3>
f0103b50:	83 f8 03             	cmp    $0x3,%eax
f0103b53:	74 3e                	je     f0103b93 <syscall+0x5f>
			break;
		case SYS_getenvid:
			retVal = sys_getenvid();
			break;
	default:
		return -E_INVAL;
f0103b55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103b5a:	eb 2e                	jmp    f0103b8a <syscall+0x56>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0103b5c:	6a 04                	push   $0x4
f0103b5e:	ff 75 10             	pushl  0x10(%ebp)
f0103b61:	ff 75 0c             	pushl  0xc(%ebp)
f0103b64:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103b6a:	e8 44 f0 ff ff       	call   f0102bb3 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b6f:	83 c4 0c             	add    $0xc,%esp
f0103b72:	ff 75 0c             	pushl  0xc(%ebp)
f0103b75:	ff 75 10             	pushl  0x10(%ebp)
f0103b78:	68 b0 61 10 f0       	push   $0xf01061b0
f0103b7d:	e8 b3 f7 ff ff       	call   f0103335 <cprintf>
f0103b82:	83 c4 10             	add    $0x10,%esp
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int32_t retVal = 0;
f0103b85:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
		return -E_INVAL;
	}

	return retVal;
}
f0103b8a:	c9                   	leave  
f0103b8b:	c3                   	ret    
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103b8c:	e8 21 c9 ff ff       	call   f01004b2 <cons_getc>
		case SYS_cputs:
			sys_cputs((const char*)a1, a2);
			break;
		case SYS_cgetc:
			retVal = sys_cgetc();
			break;
f0103b91:	eb f7                	jmp    f0103b8a <syscall+0x56>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103b93:	83 ec 04             	sub    $0x4,%esp
f0103b96:	6a 01                	push   $0x1
f0103b98:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b9b:	50                   	push   %eax
f0103b9c:	ff 75 0c             	pushl  0xc(%ebp)
f0103b9f:	e8 d9 f0 ff ff       	call   f0102c7d <envid2env>
f0103ba4:	83 c4 10             	add    $0x10,%esp
f0103ba7:	85 c0                	test   %eax,%eax
f0103ba9:	78 df                	js     f0103b8a <syscall+0x56>
		return r;
	if (e == curenv)
f0103bab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103bae:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0103bb3:	39 c2                	cmp    %eax,%edx
f0103bb5:	74 2b                	je     f0103be2 <syscall+0xae>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103bb7:	83 ec 04             	sub    $0x4,%esp
f0103bba:	ff 72 48             	pushl  0x48(%edx)
f0103bbd:	ff 70 48             	pushl  0x48(%eax)
f0103bc0:	68 d0 61 10 f0       	push   $0xf01061d0
f0103bc5:	e8 6b f7 ff ff       	call   f0103335 <cprintf>
f0103bca:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103bcd:	83 ec 0c             	sub    $0xc,%esp
f0103bd0:	ff 75 f4             	pushl  -0xc(%ebp)
f0103bd3:	e8 41 f6 ff ff       	call   f0103219 <env_destroy>
f0103bd8:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103bdb:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			retVal = sys_cgetc();
			break;
		case SYS_env_destroy:
			retVal = sys_env_destroy(a1);
			break;
f0103be0:	eb a8                	jmp    f0103b8a <syscall+0x56>
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103be2:	83 ec 08             	sub    $0x8,%esp
f0103be5:	ff 70 48             	pushl  0x48(%eax)
f0103be8:	68 b5 61 10 f0       	push   $0xf01061b5
f0103bed:	e8 43 f7 ff ff       	call   f0103335 <cprintf>
f0103bf2:	83 c4 10             	add    $0x10,%esp
f0103bf5:	eb d6                	jmp    f0103bcd <syscall+0x99>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103bf7:	a1 28 bd 19 f0       	mov    0xf019bd28,%eax
f0103bfc:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_env_destroy:
			retVal = sys_env_destroy(a1);
			break;
		case SYS_getenvid:
			retVal = sys_getenvid();
			break;
f0103bff:	eb 89                	jmp    f0103b8a <syscall+0x56>
f0103c01:	00 00                	add    %al,(%eax)
	...

f0103c04 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103c04:	55                   	push   %ebp
f0103c05:	89 e5                	mov    %esp,%ebp
f0103c07:	57                   	push   %edi
f0103c08:	56                   	push   %esi
f0103c09:	53                   	push   %ebx
f0103c0a:	83 ec 14             	sub    $0x14,%esp
f0103c0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c10:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103c13:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103c16:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103c19:	8b 32                	mov    (%edx),%esi
f0103c1b:	8b 01                	mov    (%ecx),%eax
f0103c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c20:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103c27:	eb 2f                	jmp    f0103c58 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103c29:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c2a:	39 c6                	cmp    %eax,%esi
f0103c2c:	7f 4d                	jg     f0103c7b <stab_binsearch+0x77>
f0103c2e:	0f b6 0a             	movzbl (%edx),%ecx
f0103c31:	83 ea 0c             	sub    $0xc,%edx
f0103c34:	39 f9                	cmp    %edi,%ecx
f0103c36:	75 f1                	jne    f0103c29 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103c38:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c3b:	01 c2                	add    %eax,%edx
f0103c3d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103c40:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103c44:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c47:	73 37                	jae    f0103c80 <stab_binsearch+0x7c>
			*region_left = m;
f0103c49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c4c:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103c4e:	8d 73 01             	lea    0x1(%ebx),%esi
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c51:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103c58:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0103c5b:	7f 4d                	jg     f0103caa <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0103c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c60:	01 f0                	add    %esi,%eax
f0103c62:	89 c3                	mov    %eax,%ebx
f0103c64:	c1 eb 1f             	shr    $0x1f,%ebx
f0103c67:	01 c3                	add    %eax,%ebx
f0103c69:	d1 fb                	sar    %ebx
f0103c6b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103c6e:	01 d8                	add    %ebx,%eax
f0103c70:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103c73:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103c77:	89 d8                	mov    %ebx,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c79:	eb af                	jmp    f0103c2a <stab_binsearch+0x26>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103c7b:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0103c7e:	eb d8                	jmp    f0103c58 <stab_binsearch+0x54>
		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103c80:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c83:	76 12                	jbe    f0103c97 <stab_binsearch+0x93>
			*region_right = m - 1;
f0103c85:	48                   	dec    %eax
f0103c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c89:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103c8c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c8e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103c95:	eb c1                	jmp    f0103c58 <stab_binsearch+0x54>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c97:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c9a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103c9c:	ff 45 0c             	incl   0xc(%ebp)
f0103c9f:	89 c6                	mov    %eax,%esi
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103ca1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103ca8:	eb ae                	jmp    f0103c58 <stab_binsearch+0x54>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103caa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103cae:	74 18                	je     f0103cc8 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103cb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103cb3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103cb5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103cb8:	8b 0e                	mov    (%esi),%ecx
f0103cba:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cbd:	01 c2                	add    %eax,%edx
f0103cbf:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103cc2:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103cc6:	eb 0e                	jmp    f0103cd6 <stab_binsearch+0xd2>
			addr++;
		}
	}

	if (!any_matches)
		*region_right = *region_left - 1;
f0103cc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ccb:	8b 00                	mov    (%eax),%eax
f0103ccd:	48                   	dec    %eax
f0103cce:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103cd1:	89 07                	mov    %eax,(%edi)
f0103cd3:	eb 14                	jmp    f0103ce9 <stab_binsearch+0xe5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103cd5:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103cd6:	39 c1                	cmp    %eax,%ecx
f0103cd8:	7d 0a                	jge    f0103ce4 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0103cda:	0f b6 1a             	movzbl (%edx),%ebx
f0103cdd:	83 ea 0c             	sub    $0xc,%edx
f0103ce0:	39 fb                	cmp    %edi,%ebx
f0103ce2:	75 f1                	jne    f0103cd5 <stab_binsearch+0xd1>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103ce4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ce7:	89 07                	mov    %eax,(%edi)
	}
}
f0103ce9:	83 c4 14             	add    $0x14,%esp
f0103cec:	5b                   	pop    %ebx
f0103ced:	5e                   	pop    %esi
f0103cee:	5f                   	pop    %edi
f0103cef:	5d                   	pop    %ebp
f0103cf0:	c3                   	ret    

f0103cf1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103cf1:	55                   	push   %ebp
f0103cf2:	89 e5                	mov    %esp,%ebp
f0103cf4:	57                   	push   %edi
f0103cf5:	56                   	push   %esi
f0103cf6:	53                   	push   %ebx
f0103cf7:	83 ec 2c             	sub    $0x2c,%esp
f0103cfa:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103d00:	c7 06 e8 61 10 f0    	movl   $0xf01061e8,(%esi)
	info->eip_line = 0;
f0103d06:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103d0d:	c7 46 08 e8 61 10 f0 	movl   $0xf01061e8,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103d14:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103d1b:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103d1e:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103d25:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103d2b:	0f 86 01 01 00 00    	jbe    f0103e32 <debuginfo_eip+0x141>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103d31:	c7 45 d0 7b 1c 11 f0 	movl   $0xf0111c7b,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103d38:	c7 45 cc e9 f0 10 f0 	movl   $0xf010f0e9,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103d3f:	bb e8 f0 10 f0       	mov    $0xf010f0e8,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103d44:	c7 45 d4 00 64 10 f0 	movl   $0xf0106400,-0x2c(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103d4b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103d4e:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0103d51:	0f 83 07 02 00 00    	jae    f0103f5e <debuginfo_eip+0x26d>
f0103d57:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103d5b:	0f 85 04 02 00 00    	jne    f0103f65 <debuginfo_eip+0x274>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103d61:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103d68:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0103d6b:	c1 fb 02             	sar    $0x2,%ebx
f0103d6e:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f0103d71:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0103d74:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0103d77:	89 c2                	mov    %eax,%edx
f0103d79:	c1 e2 08             	shl    $0x8,%edx
f0103d7c:	01 d0                	add    %edx,%eax
f0103d7e:	89 c2                	mov    %eax,%edx
f0103d80:	c1 e2 10             	shl    $0x10,%edx
f0103d83:	01 d0                	add    %edx,%eax
f0103d85:	01 c0                	add    %eax,%eax
f0103d87:	8d 44 03 ff          	lea    -0x1(%ebx,%eax,1),%eax
f0103d8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103d8e:	83 ec 08             	sub    $0x8,%esp
f0103d91:	57                   	push   %edi
f0103d92:	6a 64                	push   $0x64
f0103d94:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103d97:	89 d1                	mov    %edx,%ecx
f0103d99:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103d9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103d9f:	89 d8                	mov    %ebx,%eax
f0103da1:	e8 5e fe ff ff       	call   f0103c04 <stab_binsearch>
	if (lfile == 0)
f0103da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103da9:	83 c4 10             	add    $0x10,%esp
f0103dac:	85 c0                	test   %eax,%eax
f0103dae:	0f 84 b8 01 00 00    	je     f0103f6c <debuginfo_eip+0x27b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103db4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103db7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103dba:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103dbd:	83 ec 08             	sub    $0x8,%esp
f0103dc0:	57                   	push   %edi
f0103dc1:	6a 24                	push   $0x24
f0103dc3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103dc6:	89 d1                	mov    %edx,%ecx
f0103dc8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103dcb:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0103dce:	89 d8                	mov    %ebx,%eax
f0103dd0:	e8 2f fe ff ff       	call   f0103c04 <stab_binsearch>

	if (lfun <= rfun) {
f0103dd5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103dd8:	83 c4 10             	add    $0x10,%esp
f0103ddb:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0103dde:	0f 8f f7 00 00 00    	jg     f0103edb <debuginfo_eip+0x1ea>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103de4:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103de7:	01 d8                	add    %ebx,%eax
f0103de9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103dec:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0103def:	8b 02                	mov    (%edx),%eax
f0103df1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103df4:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103df7:	29 f9                	sub    %edi,%ecx
f0103df9:	39 c8                	cmp    %ecx,%eax
f0103dfb:	73 05                	jae    f0103e02 <debuginfo_eip+0x111>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103dfd:	01 f8                	add    %edi,%eax
f0103dff:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e02:	8b 42 08             	mov    0x8(%edx),%eax
f0103e05:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103e08:	83 ec 08             	sub    $0x8,%esp
f0103e0b:	6a 3a                	push   $0x3a
f0103e0d:	ff 76 08             	pushl  0x8(%esi)
f0103e10:	e8 5c 09 00 00       	call   f0104771 <strfind>
f0103e15:	2b 46 08             	sub    0x8(%esi),%eax
f0103e18:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103e1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e1e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103e21:	01 d8                	add    %ebx,%eax
f0103e23:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103e26:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f0103e2a:	83 c4 10             	add    $0x10,%esp
f0103e2d:	e9 b8 00 00 00       	jmp    f0103eea <debuginfo_eip+0x1f9>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0103e32:	6a 04                	push   $0x4
f0103e34:	6a 10                	push   $0x10
f0103e36:	68 00 00 20 00       	push   $0x200000
f0103e3b:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103e41:	e8 da ec ff ff       	call   f0102b20 <user_mem_check>
f0103e46:	83 c4 10             	add    $0x10,%esp
f0103e49:	85 c0                	test   %eax,%eax
f0103e4b:	0f 88 ff 00 00 00    	js     f0103f50 <debuginfo_eip+0x25f>
			return -1;
		}

		stabs = usd->stabs;
f0103e51:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0103e56:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0103e5c:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0103e62:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0103e65:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103e6b:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
f0103e6e:	6a 04                	push   $0x4
f0103e70:	89 da                	mov    %ebx,%edx
f0103e72:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103e75:	29 c2                	sub    %eax,%edx
f0103e77:	c1 fa 02             	sar    $0x2,%edx
f0103e7a:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103e7d:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103e80:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103e83:	89 c1                	mov    %eax,%ecx
f0103e85:	c1 e1 08             	shl    $0x8,%ecx
f0103e88:	01 c8                	add    %ecx,%eax
f0103e8a:	89 c1                	mov    %eax,%ecx
f0103e8c:	c1 e1 10             	shl    $0x10,%ecx
f0103e8f:	01 c8                	add    %ecx,%eax
f0103e91:	01 c0                	add    %eax,%eax
f0103e93:	01 c2                	add    %eax,%edx
f0103e95:	52                   	push   %edx
f0103e96:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103e99:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103e9f:	e8 7c ec ff ff       	call   f0102b20 <user_mem_check>
f0103ea4:	83 c4 10             	add    $0x10,%esp
f0103ea7:	85 c0                	test   %eax,%eax
f0103ea9:	0f 88 a8 00 00 00    	js     f0103f57 <debuginfo_eip+0x266>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, stabstr_end-stabstr, PTE_U) < 0) {
f0103eaf:	6a 04                	push   $0x4
f0103eb1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103eb4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103eb7:	29 c8                	sub    %ecx,%eax
f0103eb9:	50                   	push   %eax
f0103eba:	51                   	push   %ecx
f0103ebb:	ff 35 28 bd 19 f0    	pushl  0xf019bd28
f0103ec1:	e8 5a ec ff ff       	call   f0102b20 <user_mem_check>
f0103ec6:	83 c4 10             	add    $0x10,%esp
f0103ec9:	85 c0                	test   %eax,%eax
f0103ecb:	0f 89 7a fe ff ff    	jns    f0103d4b <debuginfo_eip+0x5a>
			return -1;
f0103ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ed6:	e9 9d 00 00 00       	jmp    f0103f78 <debuginfo_eip+0x287>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103edb:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103ede:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103ee1:	e9 22 ff ff ff       	jmp    f0103e08 <debuginfo_eip+0x117>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ee6:	4b                   	dec    %ebx
f0103ee7:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103eea:	39 df                	cmp    %ebx,%edi
f0103eec:	7f 2f                	jg     f0103f1d <debuginfo_eip+0x22c>
	       && stabs[lline].n_type != N_SOL
f0103eee:	8a 10                	mov    (%eax),%dl
f0103ef0:	80 fa 84             	cmp    $0x84,%dl
f0103ef3:	74 0b                	je     f0103f00 <debuginfo_eip+0x20f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103ef5:	80 fa 64             	cmp    $0x64,%dl
f0103ef8:	75 ec                	jne    f0103ee6 <debuginfo_eip+0x1f5>
f0103efa:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103efe:	74 e6                	je     f0103ee6 <debuginfo_eip+0x1f5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f00:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103f03:	01 c3                	add    %eax,%ebx
f0103f05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103f08:	8b 14 98             	mov    (%eax,%ebx,4),%edx
f0103f0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103f0e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103f11:	29 f8                	sub    %edi,%eax
f0103f13:	39 c2                	cmp    %eax,%edx
f0103f15:	73 06                	jae    f0103f1d <debuginfo_eip+0x22c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f17:	89 f8                	mov    %edi,%eax
f0103f19:	01 d0                	add    %edx,%eax
f0103f1b:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f20:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103f23:	39 c8                	cmp    %ecx,%eax
f0103f25:	7d 4c                	jge    f0103f73 <debuginfo_eip+0x282>
		for (lline = lfun + 1;
f0103f27:	8d 50 01             	lea    0x1(%eax),%edx
f0103f2a:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103f2d:	01 d8                	add    %ebx,%eax
f0103f2f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103f32:	8d 44 87 10          	lea    0x10(%edi,%eax,4),%eax
f0103f36:	eb 04                	jmp    f0103f3c <debuginfo_eip+0x24b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f38:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103f3b:	42                   	inc    %edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f3c:	39 d1                	cmp    %edx,%ecx
f0103f3e:	74 40                	je     f0103f80 <debuginfo_eip+0x28f>
f0103f40:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f43:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0103f47:	74 ef                	je     f0103f38 <debuginfo_eip+0x247>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f49:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f4e:	eb 28                	jmp    f0103f78 <debuginfo_eip+0x287>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0103f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f55:	eb 21                	jmp    f0103f78 <debuginfo_eip+0x287>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
			return -1;
f0103f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f5c:	eb 1a                	jmp    f0103f78 <debuginfo_eip+0x287>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f63:	eb 13                	jmp    f0103f78 <debuginfo_eip+0x287>
f0103f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f6a:	eb 0c                	jmp    f0103f78 <debuginfo_eip+0x287>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f71:	eb 05                	jmp    f0103f78 <debuginfo_eip+0x287>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f7b:	5b                   	pop    %ebx
f0103f7c:	5e                   	pop    %esi
f0103f7d:	5f                   	pop    %edi
f0103f7e:	5d                   	pop    %ebp
f0103f7f:	c3                   	ret    
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f80:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f85:	eb f1                	jmp    f0103f78 <debuginfo_eip+0x287>
	...

f0103f88 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103f88:	55                   	push   %ebp
f0103f89:	89 e5                	mov    %esp,%ebp
f0103f8b:	57                   	push   %edi
f0103f8c:	56                   	push   %esi
f0103f8d:	53                   	push   %ebx
f0103f8e:	83 ec 1c             	sub    $0x1c,%esp
f0103f91:	89 c7                	mov    %eax,%edi
f0103f93:	89 d6                	mov    %edx,%esi
f0103f95:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f98:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103f9b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f9e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103fa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103fa9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103fac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103faf:	39 d3                	cmp    %edx,%ebx
f0103fb1:	72 05                	jb     f0103fb8 <printnum+0x30>
f0103fb3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103fb6:	77 78                	ja     f0104030 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103fb8:	83 ec 0c             	sub    $0xc,%esp
f0103fbb:	ff 75 18             	pushl  0x18(%ebp)
f0103fbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fc1:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103fc4:	53                   	push   %ebx
f0103fc5:	ff 75 10             	pushl  0x10(%ebp)
f0103fc8:	83 ec 08             	sub    $0x8,%esp
f0103fcb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103fce:	ff 75 e0             	pushl  -0x20(%ebp)
f0103fd1:	ff 75 dc             	pushl  -0x24(%ebp)
f0103fd4:	ff 75 d8             	pushl  -0x28(%ebp)
f0103fd7:	e8 90 09 00 00       	call   f010496c <__udivdi3>
f0103fdc:	83 c4 18             	add    $0x18,%esp
f0103fdf:	52                   	push   %edx
f0103fe0:	50                   	push   %eax
f0103fe1:	89 f2                	mov    %esi,%edx
f0103fe3:	89 f8                	mov    %edi,%eax
f0103fe5:	e8 9e ff ff ff       	call   f0103f88 <printnum>
f0103fea:	83 c4 20             	add    $0x20,%esp
f0103fed:	eb 11                	jmp    f0104000 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103fef:	83 ec 08             	sub    $0x8,%esp
f0103ff2:	56                   	push   %esi
f0103ff3:	ff 75 18             	pushl  0x18(%ebp)
f0103ff6:	ff d7                	call   *%edi
f0103ff8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103ffb:	4b                   	dec    %ebx
f0103ffc:	85 db                	test   %ebx,%ebx
f0103ffe:	7f ef                	jg     f0103fef <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104000:	83 ec 08             	sub    $0x8,%esp
f0104003:	56                   	push   %esi
f0104004:	83 ec 04             	sub    $0x4,%esp
f0104007:	ff 75 e4             	pushl  -0x1c(%ebp)
f010400a:	ff 75 e0             	pushl  -0x20(%ebp)
f010400d:	ff 75 dc             	pushl  -0x24(%ebp)
f0104010:	ff 75 d8             	pushl  -0x28(%ebp)
f0104013:	e8 54 0a 00 00       	call   f0104a6c <__umoddi3>
f0104018:	83 c4 14             	add    $0x14,%esp
f010401b:	0f be 80 f2 61 10 f0 	movsbl -0xfef9e0e(%eax),%eax
f0104022:	50                   	push   %eax
f0104023:	ff d7                	call   *%edi
}
f0104025:	83 c4 10             	add    $0x10,%esp
f0104028:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010402b:	5b                   	pop    %ebx
f010402c:	5e                   	pop    %esi
f010402d:	5f                   	pop    %edi
f010402e:	5d                   	pop    %ebp
f010402f:	c3                   	ret    
f0104030:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104033:	eb c6                	jmp    f0103ffb <printnum+0x73>

f0104035 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104035:	55                   	push   %ebp
f0104036:	89 e5                	mov    %esp,%ebp
f0104038:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010403b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010403e:	8b 10                	mov    (%eax),%edx
f0104040:	3b 50 04             	cmp    0x4(%eax),%edx
f0104043:	73 0a                	jae    f010404f <sprintputch+0x1a>
		*b->buf++ = ch;
f0104045:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104048:	89 08                	mov    %ecx,(%eax)
f010404a:	8b 45 08             	mov    0x8(%ebp),%eax
f010404d:	88 02                	mov    %al,(%edx)
}
f010404f:	5d                   	pop    %ebp
f0104050:	c3                   	ret    

f0104051 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104051:	55                   	push   %ebp
f0104052:	89 e5                	mov    %esp,%ebp
f0104054:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104057:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010405a:	50                   	push   %eax
f010405b:	ff 75 10             	pushl  0x10(%ebp)
f010405e:	ff 75 0c             	pushl  0xc(%ebp)
f0104061:	ff 75 08             	pushl  0x8(%ebp)
f0104064:	e8 05 00 00 00       	call   f010406e <vprintfmt>
	va_end(ap);
}
f0104069:	83 c4 10             	add    $0x10,%esp
f010406c:	c9                   	leave  
f010406d:	c3                   	ret    

f010406e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010406e:	55                   	push   %ebp
f010406f:	89 e5                	mov    %esp,%ebp
f0104071:	57                   	push   %edi
f0104072:	56                   	push   %esi
f0104073:	53                   	push   %ebx
f0104074:	83 ec 2c             	sub    $0x2c,%esp
f0104077:	8b 75 08             	mov    0x8(%ebp),%esi
f010407a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010407d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104080:	e9 ac 03 00 00       	jmp    f0104431 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0104085:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
f0104089:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
f0104090:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
f0104097:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
f010409e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040a3:	8d 47 01             	lea    0x1(%edi),%eax
f01040a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01040a9:	8a 17                	mov    (%edi),%dl
f01040ab:	8d 42 dd             	lea    -0x23(%edx),%eax
f01040ae:	3c 55                	cmp    $0x55,%al
f01040b0:	0f 87 fc 03 00 00    	ja     f01044b2 <vprintfmt+0x444>
f01040b6:	0f b6 c0             	movzbl %al,%eax
f01040b9:	ff 24 85 7c 62 10 f0 	jmp    *-0xfef9d84(,%eax,4)
f01040c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01040c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01040c7:	eb da                	jmp    f01040a3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01040cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01040d0:	eb d1                	jmp    f01040a3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040d2:	0f b6 d2             	movzbl %dl,%edx
f01040d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01040d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01040dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01040e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01040e3:	01 c0                	add    %eax,%eax
f01040e5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f01040e9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01040ec:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01040ef:	83 f9 09             	cmp    $0x9,%ecx
f01040f2:	77 52                	ja     f0104146 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01040f4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f01040f5:	eb e9                	jmp    f01040e0 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01040f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01040fa:	8b 00                	mov    (%eax),%eax
f01040fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01040ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104102:	8d 40 04             	lea    0x4(%eax),%eax
f0104105:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104108:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010410b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010410f:	79 92                	jns    f01040a3 <vprintfmt+0x35>
				width = precision, precision = -1;
f0104111:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104114:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104117:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010411e:	eb 83                	jmp    f01040a3 <vprintfmt+0x35>
f0104120:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104124:	78 08                	js     f010412e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104126:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104129:	e9 75 ff ff ff       	jmp    f01040a3 <vprintfmt+0x35>
f010412e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104135:	eb ef                	jmp    f0104126 <vprintfmt+0xb8>
f0104137:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010413a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104141:	e9 5d ff ff ff       	jmp    f01040a3 <vprintfmt+0x35>
f0104146:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104149:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010414c:	eb bd                	jmp    f010410b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010414e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010414f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104152:	e9 4c ff ff ff       	jmp    f01040a3 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104157:	8b 45 14             	mov    0x14(%ebp),%eax
f010415a:	8d 78 04             	lea    0x4(%eax),%edi
f010415d:	83 ec 08             	sub    $0x8,%esp
f0104160:	53                   	push   %ebx
f0104161:	ff 30                	pushl  (%eax)
f0104163:	ff d6                	call   *%esi
			break;
f0104165:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104168:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f010416b:	e9 be 02 00 00       	jmp    f010442e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104170:	8b 45 14             	mov    0x14(%ebp),%eax
f0104173:	8d 78 04             	lea    0x4(%eax),%edi
f0104176:	8b 00                	mov    (%eax),%eax
f0104178:	85 c0                	test   %eax,%eax
f010417a:	78 2a                	js     f01041a6 <vprintfmt+0x138>
f010417c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010417e:	83 f8 06             	cmp    $0x6,%eax
f0104181:	7f 27                	jg     f01041aa <vprintfmt+0x13c>
f0104183:	8b 04 85 d4 63 10 f0 	mov    -0xfef9c2c(,%eax,4),%eax
f010418a:	85 c0                	test   %eax,%eax
f010418c:	74 1c                	je     f01041aa <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f010418e:	50                   	push   %eax
f010418f:	68 09 5a 10 f0       	push   $0xf0105a09
f0104194:	53                   	push   %ebx
f0104195:	56                   	push   %esi
f0104196:	e8 b6 fe ff ff       	call   f0104051 <printfmt>
f010419b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010419e:	89 7d 14             	mov    %edi,0x14(%ebp)
f01041a1:	e9 88 02 00 00       	jmp    f010442e <vprintfmt+0x3c0>
f01041a6:	f7 d8                	neg    %eax
f01041a8:	eb d2                	jmp    f010417c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01041aa:	52                   	push   %edx
f01041ab:	68 0a 62 10 f0       	push   $0xf010620a
f01041b0:	53                   	push   %ebx
f01041b1:	56                   	push   %esi
f01041b2:	e8 9a fe ff ff       	call   f0104051 <printfmt>
f01041b7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01041ba:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01041bd:	e9 6c 02 00 00       	jmp    f010442e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01041c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01041c5:	83 c0 04             	add    $0x4,%eax
f01041c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01041cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01041ce:	8b 38                	mov    (%eax),%edi
f01041d0:	85 ff                	test   %edi,%edi
f01041d2:	74 18                	je     f01041ec <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
f01041d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01041d8:	0f 8e b7 00 00 00    	jle    f0104295 <vprintfmt+0x227>
f01041de:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01041e2:	75 0f                	jne    f01041f3 <vprintfmt+0x185>
f01041e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01041e7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01041ea:	eb 75                	jmp    f0104261 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
f01041ec:	bf 03 62 10 f0       	mov    $0xf0106203,%edi
f01041f1:	eb e1                	jmp    f01041d4 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01041f3:	83 ec 08             	sub    $0x8,%esp
f01041f6:	ff 75 d0             	pushl  -0x30(%ebp)
f01041f9:	57                   	push   %edi
f01041fa:	e8 47 04 00 00       	call   f0104646 <strnlen>
f01041ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104202:	29 c1                	sub    %eax,%ecx
f0104204:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104207:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010420a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010420e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104211:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104214:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104216:	eb 0d                	jmp    f0104225 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0104218:	83 ec 08             	sub    $0x8,%esp
f010421b:	53                   	push   %ebx
f010421c:	ff 75 e0             	pushl  -0x20(%ebp)
f010421f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104221:	4f                   	dec    %edi
f0104222:	83 c4 10             	add    $0x10,%esp
f0104225:	85 ff                	test   %edi,%edi
f0104227:	7f ef                	jg     f0104218 <vprintfmt+0x1aa>
f0104229:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010422c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010422f:	89 c8                	mov    %ecx,%eax
f0104231:	85 c9                	test   %ecx,%ecx
f0104233:	78 10                	js     f0104245 <vprintfmt+0x1d7>
f0104235:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104238:	29 c1                	sub    %eax,%ecx
f010423a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010423d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104240:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104243:	eb 1c                	jmp    f0104261 <vprintfmt+0x1f3>
f0104245:	b8 00 00 00 00       	mov    $0x0,%eax
f010424a:	eb e9                	jmp    f0104235 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010424c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104250:	75 29                	jne    f010427b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104252:	83 ec 08             	sub    $0x8,%esp
f0104255:	ff 75 0c             	pushl  0xc(%ebp)
f0104258:	50                   	push   %eax
f0104259:	ff d6                	call   *%esi
f010425b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010425e:	ff 4d e0             	decl   -0x20(%ebp)
f0104261:	47                   	inc    %edi
f0104262:	8a 57 ff             	mov    -0x1(%edi),%dl
f0104265:	0f be c2             	movsbl %dl,%eax
f0104268:	85 c0                	test   %eax,%eax
f010426a:	74 4c                	je     f01042b8 <vprintfmt+0x24a>
f010426c:	85 db                	test   %ebx,%ebx
f010426e:	78 dc                	js     f010424c <vprintfmt+0x1de>
f0104270:	4b                   	dec    %ebx
f0104271:	79 d9                	jns    f010424c <vprintfmt+0x1de>
f0104273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104276:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104279:	eb 2e                	jmp    f01042a9 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f010427b:	0f be d2             	movsbl %dl,%edx
f010427e:	83 ea 20             	sub    $0x20,%edx
f0104281:	83 fa 5e             	cmp    $0x5e,%edx
f0104284:	76 cc                	jbe    f0104252 <vprintfmt+0x1e4>
					putch('?', putdat);
f0104286:	83 ec 08             	sub    $0x8,%esp
f0104289:	ff 75 0c             	pushl  0xc(%ebp)
f010428c:	6a 3f                	push   $0x3f
f010428e:	ff d6                	call   *%esi
f0104290:	83 c4 10             	add    $0x10,%esp
f0104293:	eb c9                	jmp    f010425e <vprintfmt+0x1f0>
f0104295:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104298:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010429b:	eb c4                	jmp    f0104261 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010429d:	83 ec 08             	sub    $0x8,%esp
f01042a0:	53                   	push   %ebx
f01042a1:	6a 20                	push   $0x20
f01042a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01042a5:	4f                   	dec    %edi
f01042a6:	83 c4 10             	add    $0x10,%esp
f01042a9:	85 ff                	test   %edi,%edi
f01042ab:	7f f0                	jg     f010429d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01042ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01042b0:	89 45 14             	mov    %eax,0x14(%ebp)
f01042b3:	e9 76 01 00 00       	jmp    f010442e <vprintfmt+0x3c0>
f01042b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01042bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01042be:	eb e9                	jmp    f01042a9 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01042c0:	83 f9 01             	cmp    $0x1,%ecx
f01042c3:	7e 3f                	jle    f0104304 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f01042c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01042c8:	8b 50 04             	mov    0x4(%eax),%edx
f01042cb:	8b 00                	mov    (%eax),%eax
f01042cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01042d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d6:	8d 40 08             	lea    0x8(%eax),%eax
f01042d9:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01042dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01042e0:	79 5c                	jns    f010433e <vprintfmt+0x2d0>
				putch('-', putdat);
f01042e2:	83 ec 08             	sub    $0x8,%esp
f01042e5:	53                   	push   %ebx
f01042e6:	6a 2d                	push   $0x2d
f01042e8:	ff d6                	call   *%esi
				num = -(long long) num;
f01042ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01042f0:	f7 da                	neg    %edx
f01042f2:	83 d1 00             	adc    $0x0,%ecx
f01042f5:	f7 d9                	neg    %ecx
f01042f7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01042fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042ff:	e9 10 01 00 00       	jmp    f0104414 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
f0104304:	85 c9                	test   %ecx,%ecx
f0104306:	75 1b                	jne    f0104323 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f0104308:	8b 45 14             	mov    0x14(%ebp),%eax
f010430b:	8b 00                	mov    (%eax),%eax
f010430d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104310:	89 c1                	mov    %eax,%ecx
f0104312:	c1 f9 1f             	sar    $0x1f,%ecx
f0104315:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104318:	8b 45 14             	mov    0x14(%ebp),%eax
f010431b:	8d 40 04             	lea    0x4(%eax),%eax
f010431e:	89 45 14             	mov    %eax,0x14(%ebp)
f0104321:	eb b9                	jmp    f01042dc <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
f0104323:	8b 45 14             	mov    0x14(%ebp),%eax
f0104326:	8b 00                	mov    (%eax),%eax
f0104328:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010432b:	89 c1                	mov    %eax,%ecx
f010432d:	c1 f9 1f             	sar    $0x1f,%ecx
f0104330:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104333:	8b 45 14             	mov    0x14(%ebp),%eax
f0104336:	8d 40 04             	lea    0x4(%eax),%eax
f0104339:	89 45 14             	mov    %eax,0x14(%ebp)
f010433c:	eb 9e                	jmp    f01042dc <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010433e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104341:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104344:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104349:	e9 c6 00 00 00       	jmp    f0104414 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010434e:	83 f9 01             	cmp    $0x1,%ecx
f0104351:	7e 18                	jle    f010436b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0104353:	8b 45 14             	mov    0x14(%ebp),%eax
f0104356:	8b 10                	mov    (%eax),%edx
f0104358:	8b 48 04             	mov    0x4(%eax),%ecx
f010435b:	8d 40 08             	lea    0x8(%eax),%eax
f010435e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104361:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104366:	e9 a9 00 00 00       	jmp    f0104414 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010436b:	85 c9                	test   %ecx,%ecx
f010436d:	75 1a                	jne    f0104389 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010436f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104372:	8b 10                	mov    (%eax),%edx
f0104374:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104379:	8d 40 04             	lea    0x4(%eax),%eax
f010437c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010437f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104384:	e9 8b 00 00 00       	jmp    f0104414 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f0104389:	8b 45 14             	mov    0x14(%ebp),%eax
f010438c:	8b 10                	mov    (%eax),%edx
f010438e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104393:	8d 40 04             	lea    0x4(%eax),%eax
f0104396:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104399:	b8 0a 00 00 00       	mov    $0xa,%eax
f010439e:	eb 74                	jmp    f0104414 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01043a0:	83 f9 01             	cmp    $0x1,%ecx
f01043a3:	7e 15                	jle    f01043ba <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f01043a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01043a8:	8b 10                	mov    (%eax),%edx
f01043aa:	8b 48 04             	mov    0x4(%eax),%ecx
f01043ad:	8d 40 08             	lea    0x8(%eax),%eax
f01043b0:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f01043b3:	b8 08 00 00 00       	mov    $0x8,%eax
f01043b8:	eb 5a                	jmp    f0104414 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01043ba:	85 c9                	test   %ecx,%ecx
f01043bc:	75 17                	jne    f01043d5 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01043be:	8b 45 14             	mov    0x14(%ebp),%eax
f01043c1:	8b 10                	mov    (%eax),%edx
f01043c3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043c8:	8d 40 04             	lea    0x4(%eax),%eax
f01043cb:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f01043ce:	b8 08 00 00 00       	mov    $0x8,%eax
f01043d3:	eb 3f                	jmp    f0104414 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f01043d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01043d8:	8b 10                	mov    (%eax),%edx
f01043da:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043df:	8d 40 04             	lea    0x4(%eax),%eax
f01043e2:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
f01043e5:	b8 08 00 00 00       	mov    $0x8,%eax
f01043ea:	eb 28                	jmp    f0104414 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f01043ec:	83 ec 08             	sub    $0x8,%esp
f01043ef:	53                   	push   %ebx
f01043f0:	6a 30                	push   $0x30
f01043f2:	ff d6                	call   *%esi
			putch('x', putdat);
f01043f4:	83 c4 08             	add    $0x8,%esp
f01043f7:	53                   	push   %ebx
f01043f8:	6a 78                	push   $0x78
f01043fa:	ff d6                	call   *%esi
			num = (unsigned long long)
f01043fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01043ff:	8b 10                	mov    (%eax),%edx
f0104401:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104406:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104409:	8d 40 04             	lea    0x4(%eax),%eax
f010440c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010440f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104414:	83 ec 0c             	sub    $0xc,%esp
f0104417:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010441b:	57                   	push   %edi
f010441c:	ff 75 e0             	pushl  -0x20(%ebp)
f010441f:	50                   	push   %eax
f0104420:	51                   	push   %ecx
f0104421:	52                   	push   %edx
f0104422:	89 da                	mov    %ebx,%edx
f0104424:	89 f0                	mov    %esi,%eax
f0104426:	e8 5d fb ff ff       	call   f0103f88 <printnum>
			break;
f010442b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010442e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104431:	47                   	inc    %edi
f0104432:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104436:	83 f8 25             	cmp    $0x25,%eax
f0104439:	0f 84 46 fc ff ff    	je     f0104085 <vprintfmt+0x17>
			if (ch == '\0')
f010443f:	85 c0                	test   %eax,%eax
f0104441:	0f 84 89 00 00 00    	je     f01044d0 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
f0104447:	83 ec 08             	sub    $0x8,%esp
f010444a:	53                   	push   %ebx
f010444b:	50                   	push   %eax
f010444c:	ff d6                	call   *%esi
f010444e:	83 c4 10             	add    $0x10,%esp
f0104451:	eb de                	jmp    f0104431 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104453:	83 f9 01             	cmp    $0x1,%ecx
f0104456:	7e 15                	jle    f010446d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0104458:	8b 45 14             	mov    0x14(%ebp),%eax
f010445b:	8b 10                	mov    (%eax),%edx
f010445d:	8b 48 04             	mov    0x4(%eax),%ecx
f0104460:	8d 40 08             	lea    0x8(%eax),%eax
f0104463:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104466:	b8 10 00 00 00       	mov    $0x10,%eax
f010446b:	eb a7                	jmp    f0104414 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010446d:	85 c9                	test   %ecx,%ecx
f010446f:	75 17                	jne    f0104488 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104471:	8b 45 14             	mov    0x14(%ebp),%eax
f0104474:	8b 10                	mov    (%eax),%edx
f0104476:	b9 00 00 00 00       	mov    $0x0,%ecx
f010447b:	8d 40 04             	lea    0x4(%eax),%eax
f010447e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104481:	b8 10 00 00 00       	mov    $0x10,%eax
f0104486:	eb 8c                	jmp    f0104414 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
f0104488:	8b 45 14             	mov    0x14(%ebp),%eax
f010448b:	8b 10                	mov    (%eax),%edx
f010448d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104492:	8d 40 04             	lea    0x4(%eax),%eax
f0104495:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104498:	b8 10 00 00 00       	mov    $0x10,%eax
f010449d:	e9 72 ff ff ff       	jmp    f0104414 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01044a2:	83 ec 08             	sub    $0x8,%esp
f01044a5:	53                   	push   %ebx
f01044a6:	6a 25                	push   $0x25
f01044a8:	ff d6                	call   *%esi
			break;
f01044aa:	83 c4 10             	add    $0x10,%esp
f01044ad:	e9 7c ff ff ff       	jmp    f010442e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01044b2:	83 ec 08             	sub    $0x8,%esp
f01044b5:	53                   	push   %ebx
f01044b6:	6a 25                	push   $0x25
f01044b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01044ba:	83 c4 10             	add    $0x10,%esp
f01044bd:	89 f8                	mov    %edi,%eax
f01044bf:	eb 01                	jmp    f01044c2 <vprintfmt+0x454>
f01044c1:	48                   	dec    %eax
f01044c2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01044c6:	75 f9                	jne    f01044c1 <vprintfmt+0x453>
f01044c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01044cb:	e9 5e ff ff ff       	jmp    f010442e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
f01044d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044d3:	5b                   	pop    %ebx
f01044d4:	5e                   	pop    %esi
f01044d5:	5f                   	pop    %edi
f01044d6:	5d                   	pop    %ebp
f01044d7:	c3                   	ret    

f01044d8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01044d8:	55                   	push   %ebp
f01044d9:	89 e5                	mov    %esp,%ebp
f01044db:	83 ec 18             	sub    $0x18,%esp
f01044de:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01044e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01044eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01044ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01044f5:	85 c0                	test   %eax,%eax
f01044f7:	74 26                	je     f010451f <vsnprintf+0x47>
f01044f9:	85 d2                	test   %edx,%edx
f01044fb:	7e 29                	jle    f0104526 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01044fd:	ff 75 14             	pushl  0x14(%ebp)
f0104500:	ff 75 10             	pushl  0x10(%ebp)
f0104503:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104506:	50                   	push   %eax
f0104507:	68 35 40 10 f0       	push   $0xf0104035
f010450c:	e8 5d fb ff ff       	call   f010406e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104511:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104514:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010451a:	83 c4 10             	add    $0x10,%esp
}
f010451d:	c9                   	leave  
f010451e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010451f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104524:	eb f7                	jmp    f010451d <vsnprintf+0x45>
f0104526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010452b:	eb f0                	jmp    f010451d <vsnprintf+0x45>

f010452d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010452d:	55                   	push   %ebp
f010452e:	89 e5                	mov    %esp,%ebp
f0104530:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104533:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104536:	50                   	push   %eax
f0104537:	ff 75 10             	pushl  0x10(%ebp)
f010453a:	ff 75 0c             	pushl  0xc(%ebp)
f010453d:	ff 75 08             	pushl  0x8(%ebp)
f0104540:	e8 93 ff ff ff       	call   f01044d8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104545:	c9                   	leave  
f0104546:	c3                   	ret    
	...

f0104548 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104548:	55                   	push   %ebp
f0104549:	89 e5                	mov    %esp,%ebp
f010454b:	57                   	push   %edi
f010454c:	56                   	push   %esi
f010454d:	53                   	push   %ebx
f010454e:	83 ec 0c             	sub    $0xc,%esp
f0104551:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104554:	85 c0                	test   %eax,%eax
f0104556:	74 11                	je     f0104569 <readline+0x21>
		cprintf("%s", prompt);
f0104558:	83 ec 08             	sub    $0x8,%esp
f010455b:	50                   	push   %eax
f010455c:	68 09 5a 10 f0       	push   $0xf0105a09
f0104561:	e8 cf ed ff ff       	call   f0103335 <cprintf>
f0104566:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104569:	83 ec 0c             	sub    $0xc,%esp
f010456c:	6a 00                	push   $0x0
f010456e:	e8 a2 c0 ff ff       	call   f0100615 <iscons>
f0104573:	89 c7                	mov    %eax,%edi
f0104575:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104578:	be 00 00 00 00       	mov    $0x0,%esi
f010457d:	eb 6f                	jmp    f01045ee <readline+0xa6>
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010457f:	83 ec 08             	sub    $0x8,%esp
f0104582:	50                   	push   %eax
f0104583:	68 f0 63 10 f0       	push   $0xf01063f0
f0104588:	e8 a8 ed ff ff       	call   f0103335 <cprintf>
			return NULL;
f010458d:	83 c4 10             	add    $0x10,%esp
f0104590:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104595:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104598:	5b                   	pop    %ebx
f0104599:	5e                   	pop    %esi
f010459a:	5f                   	pop    %edi
f010459b:	5d                   	pop    %ebp
f010459c:	c3                   	ret    
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f010459d:	83 ec 0c             	sub    $0xc,%esp
f01045a0:	6a 08                	push   $0x8
f01045a2:	e8 4d c0 ff ff       	call   f01005f4 <cputchar>
f01045a7:	83 c4 10             	add    $0x10,%esp
f01045aa:	eb 41                	jmp    f01045ed <readline+0xa5>
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
f01045ac:	83 ec 0c             	sub    $0xc,%esp
f01045af:	53                   	push   %ebx
f01045b0:	e8 3f c0 ff ff       	call   f01005f4 <cputchar>
f01045b5:	83 c4 10             	add    $0x10,%esp
f01045b8:	eb 5a                	jmp    f0104614 <readline+0xcc>
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
f01045ba:	83 fb 0a             	cmp    $0xa,%ebx
f01045bd:	74 05                	je     f01045c4 <readline+0x7c>
f01045bf:	83 fb 0d             	cmp    $0xd,%ebx
f01045c2:	75 2a                	jne    f01045ee <readline+0xa6>
			if (echoing)
f01045c4:	85 ff                	test   %edi,%edi
f01045c6:	75 0e                	jne    f01045d6 <readline+0x8e>
				cputchar('\n');
			buf[i] = 0;
f01045c8:	c6 86 e0 c5 19 f0 00 	movb   $0x0,-0xfe63a20(%esi)
			return buf;
f01045cf:	b8 e0 c5 19 f0       	mov    $0xf019c5e0,%eax
f01045d4:	eb bf                	jmp    f0104595 <readline+0x4d>
			if (echoing)
				cputchar(c);
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
			if (echoing)
				cputchar('\n');
f01045d6:	83 ec 0c             	sub    $0xc,%esp
f01045d9:	6a 0a                	push   $0xa
f01045db:	e8 14 c0 ff ff       	call   f01005f4 <cputchar>
f01045e0:	83 c4 10             	add    $0x10,%esp
f01045e3:	eb e3                	jmp    f01045c8 <readline+0x80>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01045e5:	85 f6                	test   %esi,%esi
f01045e7:	7e 3c                	jle    f0104625 <readline+0xdd>
			if (echoing)
f01045e9:	85 ff                	test   %edi,%edi
f01045eb:	75 b0                	jne    f010459d <readline+0x55>
				cputchar('\b');
			i--;
f01045ed:	4e                   	dec    %esi
		cprintf("%s", prompt);

	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01045ee:	e8 11 c0 ff ff       	call   f0100604 <getchar>
f01045f3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01045f5:	85 c0                	test   %eax,%eax
f01045f7:	78 86                	js     f010457f <readline+0x37>
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01045f9:	83 f8 08             	cmp    $0x8,%eax
f01045fc:	74 21                	je     f010461f <readline+0xd7>
f01045fe:	83 f8 7f             	cmp    $0x7f,%eax
f0104601:	74 e2                	je     f01045e5 <readline+0x9d>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104603:	83 f8 1f             	cmp    $0x1f,%eax
f0104606:	7e b2                	jle    f01045ba <readline+0x72>
f0104608:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010460e:	7f aa                	jg     f01045ba <readline+0x72>
			if (echoing)
f0104610:	85 ff                	test   %edi,%edi
f0104612:	75 98                	jne    f01045ac <readline+0x64>
				cputchar(c);
			buf[i++] = c;
f0104614:	88 9e e0 c5 19 f0    	mov    %bl,-0xfe63a20(%esi)
f010461a:	8d 76 01             	lea    0x1(%esi),%esi
f010461d:	eb cf                	jmp    f01045ee <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010461f:	85 f6                	test   %esi,%esi
f0104621:	7e cb                	jle    f01045ee <readline+0xa6>
f0104623:	eb c4                	jmp    f01045e9 <readline+0xa1>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104625:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010462b:	7e e3                	jle    f0104610 <readline+0xc8>
f010462d:	eb bf                	jmp    f01045ee <readline+0xa6>
	...

f0104630 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104630:	55                   	push   %ebp
f0104631:	89 e5                	mov    %esp,%ebp
f0104633:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104636:	b8 00 00 00 00       	mov    $0x0,%eax
f010463b:	eb 01                	jmp    f010463e <strlen+0xe>
		n++;
f010463d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010463e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104642:	75 f9                	jne    f010463d <strlen+0xd>
		n++;
	return n;
}
f0104644:	5d                   	pop    %ebp
f0104645:	c3                   	ret    

f0104646 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104646:	55                   	push   %ebp
f0104647:	89 e5                	mov    %esp,%ebp
f0104649:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010464c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010464f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104654:	eb 01                	jmp    f0104657 <strnlen+0x11>
		n++;
f0104656:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104657:	39 d0                	cmp    %edx,%eax
f0104659:	74 06                	je     f0104661 <strnlen+0x1b>
f010465b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010465f:	75 f5                	jne    f0104656 <strnlen+0x10>
		n++;
	return n;
}
f0104661:	5d                   	pop    %ebp
f0104662:	c3                   	ret    

f0104663 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104663:	55                   	push   %ebp
f0104664:	89 e5                	mov    %esp,%ebp
f0104666:	53                   	push   %ebx
f0104667:	8b 45 08             	mov    0x8(%ebp),%eax
f010466a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010466d:	89 c2                	mov    %eax,%edx
f010466f:	41                   	inc    %ecx
f0104670:	42                   	inc    %edx
f0104671:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0104674:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104677:	84 db                	test   %bl,%bl
f0104679:	75 f4                	jne    f010466f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010467b:	5b                   	pop    %ebx
f010467c:	5d                   	pop    %ebp
f010467d:	c3                   	ret    

f010467e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010467e:	55                   	push   %ebp
f010467f:	89 e5                	mov    %esp,%ebp
f0104681:	53                   	push   %ebx
f0104682:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104685:	53                   	push   %ebx
f0104686:	e8 a5 ff ff ff       	call   f0104630 <strlen>
f010468b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010468e:	ff 75 0c             	pushl  0xc(%ebp)
f0104691:	01 d8                	add    %ebx,%eax
f0104693:	50                   	push   %eax
f0104694:	e8 ca ff ff ff       	call   f0104663 <strcpy>
	return dst;
}
f0104699:	89 d8                	mov    %ebx,%eax
f010469b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010469e:	c9                   	leave  
f010469f:	c3                   	ret    

f01046a0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01046a0:	55                   	push   %ebp
f01046a1:	89 e5                	mov    %esp,%ebp
f01046a3:	56                   	push   %esi
f01046a4:	53                   	push   %ebx
f01046a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01046a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01046ab:	89 f3                	mov    %esi,%ebx
f01046ad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01046b0:	89 f2                	mov    %esi,%edx
f01046b2:	39 da                	cmp    %ebx,%edx
f01046b4:	74 0e                	je     f01046c4 <strncpy+0x24>
		*dst++ = *src;
f01046b6:	42                   	inc    %edx
f01046b7:	8a 01                	mov    (%ecx),%al
f01046b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01046bc:	80 39 00             	cmpb   $0x0,(%ecx)
f01046bf:	74 f1                	je     f01046b2 <strncpy+0x12>
			src++;
f01046c1:	41                   	inc    %ecx
f01046c2:	eb ee                	jmp    f01046b2 <strncpy+0x12>
	}
	return ret;
}
f01046c4:	89 f0                	mov    %esi,%eax
f01046c6:	5b                   	pop    %ebx
f01046c7:	5e                   	pop    %esi
f01046c8:	5d                   	pop    %ebp
f01046c9:	c3                   	ret    

f01046ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01046ca:	55                   	push   %ebp
f01046cb:	89 e5                	mov    %esp,%ebp
f01046cd:	56                   	push   %esi
f01046ce:	53                   	push   %ebx
f01046cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01046d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046d5:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046d8:	85 c0                	test   %eax,%eax
f01046da:	74 20                	je     f01046fc <strlcpy+0x32>
f01046dc:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f01046e0:	89 f0                	mov    %esi,%eax
f01046e2:	eb 05                	jmp    f01046e9 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01046e4:	42                   	inc    %edx
f01046e5:	40                   	inc    %eax
f01046e6:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01046e9:	39 d8                	cmp    %ebx,%eax
f01046eb:	74 06                	je     f01046f3 <strlcpy+0x29>
f01046ed:	8a 0a                	mov    (%edx),%cl
f01046ef:	84 c9                	test   %cl,%cl
f01046f1:	75 f1                	jne    f01046e4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
f01046f3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01046f6:	29 f0                	sub    %esi,%eax
}
f01046f8:	5b                   	pop    %ebx
f01046f9:	5e                   	pop    %esi
f01046fa:	5d                   	pop    %ebp
f01046fb:	c3                   	ret    
f01046fc:	89 f0                	mov    %esi,%eax
f01046fe:	eb f6                	jmp    f01046f6 <strlcpy+0x2c>

f0104700 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104700:	55                   	push   %ebp
f0104701:	89 e5                	mov    %esp,%ebp
f0104703:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104706:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104709:	eb 02                	jmp    f010470d <strcmp+0xd>
		p++, q++;
f010470b:	41                   	inc    %ecx
f010470c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010470d:	8a 01                	mov    (%ecx),%al
f010470f:	84 c0                	test   %al,%al
f0104711:	74 04                	je     f0104717 <strcmp+0x17>
f0104713:	3a 02                	cmp    (%edx),%al
f0104715:	74 f4                	je     f010470b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104717:	0f b6 c0             	movzbl %al,%eax
f010471a:	0f b6 12             	movzbl (%edx),%edx
f010471d:	29 d0                	sub    %edx,%eax
}
f010471f:	5d                   	pop    %ebp
f0104720:	c3                   	ret    

f0104721 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104721:	55                   	push   %ebp
f0104722:	89 e5                	mov    %esp,%ebp
f0104724:	53                   	push   %ebx
f0104725:	8b 45 08             	mov    0x8(%ebp),%eax
f0104728:	8b 55 0c             	mov    0xc(%ebp),%edx
f010472b:	89 c3                	mov    %eax,%ebx
f010472d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104730:	eb 02                	jmp    f0104734 <strncmp+0x13>
		n--, p++, q++;
f0104732:	40                   	inc    %eax
f0104733:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104734:	39 d8                	cmp    %ebx,%eax
f0104736:	74 15                	je     f010474d <strncmp+0x2c>
f0104738:	8a 08                	mov    (%eax),%cl
f010473a:	84 c9                	test   %cl,%cl
f010473c:	74 04                	je     f0104742 <strncmp+0x21>
f010473e:	3a 0a                	cmp    (%edx),%cl
f0104740:	74 f0                	je     f0104732 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104742:	0f b6 00             	movzbl (%eax),%eax
f0104745:	0f b6 12             	movzbl (%edx),%edx
f0104748:	29 d0                	sub    %edx,%eax
}
f010474a:	5b                   	pop    %ebx
f010474b:	5d                   	pop    %ebp
f010474c:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010474d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104752:	eb f6                	jmp    f010474a <strncmp+0x29>

f0104754 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104754:	55                   	push   %ebp
f0104755:	89 e5                	mov    %esp,%ebp
f0104757:	8b 45 08             	mov    0x8(%ebp),%eax
f010475a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010475d:	8a 10                	mov    (%eax),%dl
f010475f:	84 d2                	test   %dl,%dl
f0104761:	74 07                	je     f010476a <strchr+0x16>
		if (*s == c)
f0104763:	38 ca                	cmp    %cl,%dl
f0104765:	74 08                	je     f010476f <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104767:	40                   	inc    %eax
f0104768:	eb f3                	jmp    f010475d <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
f010476a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010476f:	5d                   	pop    %ebp
f0104770:	c3                   	ret    

f0104771 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104771:	55                   	push   %ebp
f0104772:	89 e5                	mov    %esp,%ebp
f0104774:	8b 45 08             	mov    0x8(%ebp),%eax
f0104777:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010477a:	8a 10                	mov    (%eax),%dl
f010477c:	84 d2                	test   %dl,%dl
f010477e:	74 07                	je     f0104787 <strfind+0x16>
		if (*s == c)
f0104780:	38 ca                	cmp    %cl,%dl
f0104782:	74 03                	je     f0104787 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104784:	40                   	inc    %eax
f0104785:	eb f3                	jmp    f010477a <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
f0104787:	5d                   	pop    %ebp
f0104788:	c3                   	ret    

f0104789 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104789:	55                   	push   %ebp
f010478a:	89 e5                	mov    %esp,%ebp
f010478c:	57                   	push   %edi
f010478d:	56                   	push   %esi
f010478e:	53                   	push   %ebx
f010478f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104792:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104795:	85 c9                	test   %ecx,%ecx
f0104797:	74 13                	je     f01047ac <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104799:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010479f:	75 05                	jne    f01047a6 <memset+0x1d>
f01047a1:	f6 c1 03             	test   $0x3,%cl
f01047a4:	74 0d                	je     f01047b3 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01047a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047a9:	fc                   	cld    
f01047aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01047ac:	89 f8                	mov    %edi,%eax
f01047ae:	5b                   	pop    %ebx
f01047af:	5e                   	pop    %esi
f01047b0:	5f                   	pop    %edi
f01047b1:	5d                   	pop    %ebp
f01047b2:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
f01047b3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01047b7:	89 d3                	mov    %edx,%ebx
f01047b9:	c1 e3 08             	shl    $0x8,%ebx
f01047bc:	89 d0                	mov    %edx,%eax
f01047be:	c1 e0 18             	shl    $0x18,%eax
f01047c1:	89 d6                	mov    %edx,%esi
f01047c3:	c1 e6 10             	shl    $0x10,%esi
f01047c6:	09 f0                	or     %esi,%eax
f01047c8:	09 c2                	or     %eax,%edx
f01047ca:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01047cc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01047cf:	89 d0                	mov    %edx,%eax
f01047d1:	fc                   	cld    
f01047d2:	f3 ab                	rep stos %eax,%es:(%edi)
f01047d4:	eb d6                	jmp    f01047ac <memset+0x23>

f01047d6 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
f01047d6:	55                   	push   %ebp
f01047d7:	89 e5                	mov    %esp,%ebp
f01047d9:	57                   	push   %edi
f01047da:	56                   	push   %esi
f01047db:	8b 45 08             	mov    0x8(%ebp),%eax
f01047de:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047e4:	39 c6                	cmp    %eax,%esi
f01047e6:	73 33                	jae    f010481b <memmove+0x45>
f01047e8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01047eb:	39 c2                	cmp    %eax,%edx
f01047ed:	76 2c                	jbe    f010481b <memmove+0x45>
		s += n;
		d += n;
f01047ef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047f2:	89 d6                	mov    %edx,%esi
f01047f4:	09 fe                	or     %edi,%esi
f01047f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01047fc:	74 0a                	je     f0104808 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047fe:	4f                   	dec    %edi
f01047ff:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104802:	fd                   	std    
f0104803:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104805:	fc                   	cld    
f0104806:	eb 21                	jmp    f0104829 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104808:	f6 c1 03             	test   $0x3,%cl
f010480b:	75 f1                	jne    f01047fe <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010480d:	83 ef 04             	sub    $0x4,%edi
f0104810:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104813:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104816:	fd                   	std    
f0104817:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104819:	eb ea                	jmp    f0104805 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010481b:	89 f2                	mov    %esi,%edx
f010481d:	09 c2                	or     %eax,%edx
f010481f:	f6 c2 03             	test   $0x3,%dl
f0104822:	74 09                	je     f010482d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104824:	89 c7                	mov    %eax,%edi
f0104826:	fc                   	cld    
f0104827:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104829:	5e                   	pop    %esi
f010482a:	5f                   	pop    %edi
f010482b:	5d                   	pop    %ebp
f010482c:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010482d:	f6 c1 03             	test   $0x3,%cl
f0104830:	75 f2                	jne    f0104824 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104832:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104835:	89 c7                	mov    %eax,%edi
f0104837:	fc                   	cld    
f0104838:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010483a:	eb ed                	jmp    f0104829 <memmove+0x53>

f010483c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010483c:	55                   	push   %ebp
f010483d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010483f:	ff 75 10             	pushl  0x10(%ebp)
f0104842:	ff 75 0c             	pushl  0xc(%ebp)
f0104845:	ff 75 08             	pushl  0x8(%ebp)
f0104848:	e8 89 ff ff ff       	call   f01047d6 <memmove>
}
f010484d:	c9                   	leave  
f010484e:	c3                   	ret    

f010484f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010484f:	55                   	push   %ebp
f0104850:	89 e5                	mov    %esp,%ebp
f0104852:	56                   	push   %esi
f0104853:	53                   	push   %ebx
f0104854:	8b 45 08             	mov    0x8(%ebp),%eax
f0104857:	8b 55 0c             	mov    0xc(%ebp),%edx
f010485a:	89 c6                	mov    %eax,%esi
f010485c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010485f:	39 f0                	cmp    %esi,%eax
f0104861:	74 16                	je     f0104879 <memcmp+0x2a>
		if (*s1 != *s2)
f0104863:	8a 08                	mov    (%eax),%cl
f0104865:	8a 1a                	mov    (%edx),%bl
f0104867:	38 d9                	cmp    %bl,%cl
f0104869:	75 04                	jne    f010486f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010486b:	40                   	inc    %eax
f010486c:	42                   	inc    %edx
f010486d:	eb f0                	jmp    f010485f <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
f010486f:	0f b6 c1             	movzbl %cl,%eax
f0104872:	0f b6 db             	movzbl %bl,%ebx
f0104875:	29 d8                	sub    %ebx,%eax
f0104877:	eb 05                	jmp    f010487e <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
f0104879:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010487e:	5b                   	pop    %ebx
f010487f:	5e                   	pop    %esi
f0104880:	5d                   	pop    %ebp
f0104881:	c3                   	ret    

f0104882 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104882:	55                   	push   %ebp
f0104883:	89 e5                	mov    %esp,%ebp
f0104885:	8b 45 08             	mov    0x8(%ebp),%eax
f0104888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010488b:	89 c2                	mov    %eax,%edx
f010488d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104890:	39 d0                	cmp    %edx,%eax
f0104892:	73 07                	jae    f010489b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104894:	38 08                	cmp    %cl,(%eax)
f0104896:	74 03                	je     f010489b <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104898:	40                   	inc    %eax
f0104899:	eb f5                	jmp    f0104890 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010489b:	5d                   	pop    %ebp
f010489c:	c3                   	ret    

f010489d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010489d:	55                   	push   %ebp
f010489e:	89 e5                	mov    %esp,%ebp
f01048a0:	57                   	push   %edi
f01048a1:	56                   	push   %esi
f01048a2:	53                   	push   %ebx
f01048a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048a6:	eb 01                	jmp    f01048a9 <strtol+0xc>
		s++;
f01048a8:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048a9:	8a 01                	mov    (%ecx),%al
f01048ab:	3c 20                	cmp    $0x20,%al
f01048ad:	74 f9                	je     f01048a8 <strtol+0xb>
f01048af:	3c 09                	cmp    $0x9,%al
f01048b1:	74 f5                	je     f01048a8 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
f01048b3:	3c 2b                	cmp    $0x2b,%al
f01048b5:	74 2b                	je     f01048e2 <strtol+0x45>
		s++;
	else if (*s == '-')
f01048b7:	3c 2d                	cmp    $0x2d,%al
f01048b9:	74 2f                	je     f01048ea <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048c0:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01048c7:	75 12                	jne    f01048db <strtol+0x3e>
f01048c9:	80 39 30             	cmpb   $0x30,(%ecx)
f01048cc:	74 24                	je     f01048f2 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01048ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01048d2:	75 07                	jne    f01048db <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01048d4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01048db:	b8 00 00 00 00       	mov    $0x0,%eax
f01048e0:	eb 4e                	jmp    f0104930 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
f01048e2:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048e3:	bf 00 00 00 00       	mov    $0x0,%edi
f01048e8:	eb d6                	jmp    f01048c0 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
f01048ea:	41                   	inc    %ecx
f01048eb:	bf 01 00 00 00       	mov    $0x1,%edi
f01048f0:	eb ce                	jmp    f01048c0 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048f2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01048f6:	74 10                	je     f0104908 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01048f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01048fc:	75 dd                	jne    f01048db <strtol+0x3e>
		s++, base = 8;
f01048fe:	41                   	inc    %ecx
f01048ff:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104906:	eb d3                	jmp    f01048db <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
f0104908:	83 c1 02             	add    $0x2,%ecx
f010490b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0104912:	eb c7                	jmp    f01048db <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104914:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104917:	89 f3                	mov    %esi,%ebx
f0104919:	80 fb 19             	cmp    $0x19,%bl
f010491c:	77 24                	ja     f0104942 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010491e:	0f be d2             	movsbl %dl,%edx
f0104921:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104924:	39 55 10             	cmp    %edx,0x10(%ebp)
f0104927:	7e 2b                	jle    f0104954 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0104929:	41                   	inc    %ecx
f010492a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010492e:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104930:	8a 11                	mov    (%ecx),%dl
f0104932:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104935:	80 fb 09             	cmp    $0x9,%bl
f0104938:	77 da                	ja     f0104914 <strtol+0x77>
			dig = *s - '0';
f010493a:	0f be d2             	movsbl %dl,%edx
f010493d:	83 ea 30             	sub    $0x30,%edx
f0104940:	eb e2                	jmp    f0104924 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104942:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104945:	89 f3                	mov    %esi,%ebx
f0104947:	80 fb 19             	cmp    $0x19,%bl
f010494a:	77 08                	ja     f0104954 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010494c:	0f be d2             	movsbl %dl,%edx
f010494f:	83 ea 37             	sub    $0x37,%edx
f0104952:	eb d0                	jmp    f0104924 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104954:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104958:	74 05                	je     f010495f <strtol+0xc2>
		*endptr = (char *) s;
f010495a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010495d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010495f:	85 ff                	test   %edi,%edi
f0104961:	74 02                	je     f0104965 <strtol+0xc8>
f0104963:	f7 d8                	neg    %eax
}
f0104965:	5b                   	pop    %ebx
f0104966:	5e                   	pop    %esi
f0104967:	5f                   	pop    %edi
f0104968:	5d                   	pop    %ebp
f0104969:	c3                   	ret    
	...

f010496c <__udivdi3>:
f010496c:	55                   	push   %ebp
f010496d:	57                   	push   %edi
f010496e:	56                   	push   %esi
f010496f:	53                   	push   %ebx
f0104970:	83 ec 1c             	sub    $0x1c,%esp
f0104973:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104977:	8b 74 24 34          	mov    0x34(%esp),%esi
f010497b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010497f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104983:	85 d2                	test   %edx,%edx
f0104985:	75 2d                	jne    f01049b4 <__udivdi3+0x48>
f0104987:	39 f7                	cmp    %esi,%edi
f0104989:	77 59                	ja     f01049e4 <__udivdi3+0x78>
f010498b:	89 f9                	mov    %edi,%ecx
f010498d:	85 ff                	test   %edi,%edi
f010498f:	75 0b                	jne    f010499c <__udivdi3+0x30>
f0104991:	b8 01 00 00 00       	mov    $0x1,%eax
f0104996:	31 d2                	xor    %edx,%edx
f0104998:	f7 f7                	div    %edi
f010499a:	89 c1                	mov    %eax,%ecx
f010499c:	31 d2                	xor    %edx,%edx
f010499e:	89 f0                	mov    %esi,%eax
f01049a0:	f7 f1                	div    %ecx
f01049a2:	89 c3                	mov    %eax,%ebx
f01049a4:	89 e8                	mov    %ebp,%eax
f01049a6:	f7 f1                	div    %ecx
f01049a8:	89 da                	mov    %ebx,%edx
f01049aa:	83 c4 1c             	add    $0x1c,%esp
f01049ad:	5b                   	pop    %ebx
f01049ae:	5e                   	pop    %esi
f01049af:	5f                   	pop    %edi
f01049b0:	5d                   	pop    %ebp
f01049b1:	c3                   	ret    
f01049b2:	66 90                	xchg   %ax,%ax
f01049b4:	39 f2                	cmp    %esi,%edx
f01049b6:	77 1c                	ja     f01049d4 <__udivdi3+0x68>
f01049b8:	0f bd da             	bsr    %edx,%ebx
f01049bb:	83 f3 1f             	xor    $0x1f,%ebx
f01049be:	75 38                	jne    f01049f8 <__udivdi3+0x8c>
f01049c0:	39 f2                	cmp    %esi,%edx
f01049c2:	72 08                	jb     f01049cc <__udivdi3+0x60>
f01049c4:	39 ef                	cmp    %ebp,%edi
f01049c6:	0f 87 98 00 00 00    	ja     f0104a64 <__udivdi3+0xf8>
f01049cc:	b8 01 00 00 00       	mov    $0x1,%eax
f01049d1:	eb 05                	jmp    f01049d8 <__udivdi3+0x6c>
f01049d3:	90                   	nop
f01049d4:	31 db                	xor    %ebx,%ebx
f01049d6:	31 c0                	xor    %eax,%eax
f01049d8:	89 da                	mov    %ebx,%edx
f01049da:	83 c4 1c             	add    $0x1c,%esp
f01049dd:	5b                   	pop    %ebx
f01049de:	5e                   	pop    %esi
f01049df:	5f                   	pop    %edi
f01049e0:	5d                   	pop    %ebp
f01049e1:	c3                   	ret    
f01049e2:	66 90                	xchg   %ax,%ax
f01049e4:	89 e8                	mov    %ebp,%eax
f01049e6:	89 f2                	mov    %esi,%edx
f01049e8:	f7 f7                	div    %edi
f01049ea:	31 db                	xor    %ebx,%ebx
f01049ec:	89 da                	mov    %ebx,%edx
f01049ee:	83 c4 1c             	add    $0x1c,%esp
f01049f1:	5b                   	pop    %ebx
f01049f2:	5e                   	pop    %esi
f01049f3:	5f                   	pop    %edi
f01049f4:	5d                   	pop    %ebp
f01049f5:	c3                   	ret    
f01049f6:	66 90                	xchg   %ax,%ax
f01049f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01049fd:	29 d8                	sub    %ebx,%eax
f01049ff:	88 d9                	mov    %bl,%cl
f0104a01:	d3 e2                	shl    %cl,%edx
f0104a03:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104a07:	89 fa                	mov    %edi,%edx
f0104a09:	88 c1                	mov    %al,%cl
f0104a0b:	d3 ea                	shr    %cl,%edx
f0104a0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104a11:	09 d1                	or     %edx,%ecx
f0104a13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104a17:	88 d9                	mov    %bl,%cl
f0104a19:	d3 e7                	shl    %cl,%edi
f0104a1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104a1f:	89 f7                	mov    %esi,%edi
f0104a21:	88 c1                	mov    %al,%cl
f0104a23:	d3 ef                	shr    %cl,%edi
f0104a25:	88 d9                	mov    %bl,%cl
f0104a27:	d3 e6                	shl    %cl,%esi
f0104a29:	89 ea                	mov    %ebp,%edx
f0104a2b:	88 c1                	mov    %al,%cl
f0104a2d:	d3 ea                	shr    %cl,%edx
f0104a2f:	09 d6                	or     %edx,%esi
f0104a31:	89 f0                	mov    %esi,%eax
f0104a33:	89 fa                	mov    %edi,%edx
f0104a35:	f7 74 24 08          	divl   0x8(%esp)
f0104a39:	89 d7                	mov    %edx,%edi
f0104a3b:	89 c6                	mov    %eax,%esi
f0104a3d:	f7 64 24 0c          	mull   0xc(%esp)
f0104a41:	39 d7                	cmp    %edx,%edi
f0104a43:	72 13                	jb     f0104a58 <__udivdi3+0xec>
f0104a45:	74 09                	je     f0104a50 <__udivdi3+0xe4>
f0104a47:	89 f0                	mov    %esi,%eax
f0104a49:	31 db                	xor    %ebx,%ebx
f0104a4b:	eb 8b                	jmp    f01049d8 <__udivdi3+0x6c>
f0104a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0104a50:	88 d9                	mov    %bl,%cl
f0104a52:	d3 e5                	shl    %cl,%ebp
f0104a54:	39 c5                	cmp    %eax,%ebp
f0104a56:	73 ef                	jae    f0104a47 <__udivdi3+0xdb>
f0104a58:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104a5b:	31 db                	xor    %ebx,%ebx
f0104a5d:	e9 76 ff ff ff       	jmp    f01049d8 <__udivdi3+0x6c>
f0104a62:	66 90                	xchg   %ax,%ax
f0104a64:	31 c0                	xor    %eax,%eax
f0104a66:	e9 6d ff ff ff       	jmp    f01049d8 <__udivdi3+0x6c>
	...

f0104a6c <__umoddi3>:
f0104a6c:	55                   	push   %ebp
f0104a6d:	57                   	push   %edi
f0104a6e:	56                   	push   %esi
f0104a6f:	53                   	push   %ebx
f0104a70:	83 ec 1c             	sub    $0x1c,%esp
f0104a73:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104a77:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104a7b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104a7f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104a83:	89 f0                	mov    %esi,%eax
f0104a85:	89 da                	mov    %ebx,%edx
f0104a87:	85 ed                	test   %ebp,%ebp
f0104a89:	75 15                	jne    f0104aa0 <__umoddi3+0x34>
f0104a8b:	39 df                	cmp    %ebx,%edi
f0104a8d:	76 39                	jbe    f0104ac8 <__umoddi3+0x5c>
f0104a8f:	f7 f7                	div    %edi
f0104a91:	89 d0                	mov    %edx,%eax
f0104a93:	31 d2                	xor    %edx,%edx
f0104a95:	83 c4 1c             	add    $0x1c,%esp
f0104a98:	5b                   	pop    %ebx
f0104a99:	5e                   	pop    %esi
f0104a9a:	5f                   	pop    %edi
f0104a9b:	5d                   	pop    %ebp
f0104a9c:	c3                   	ret    
f0104a9d:	8d 76 00             	lea    0x0(%esi),%esi
f0104aa0:	39 dd                	cmp    %ebx,%ebp
f0104aa2:	77 f1                	ja     f0104a95 <__umoddi3+0x29>
f0104aa4:	0f bd cd             	bsr    %ebp,%ecx
f0104aa7:	83 f1 1f             	xor    $0x1f,%ecx
f0104aaa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104aae:	75 38                	jne    f0104ae8 <__umoddi3+0x7c>
f0104ab0:	39 dd                	cmp    %ebx,%ebp
f0104ab2:	72 04                	jb     f0104ab8 <__umoddi3+0x4c>
f0104ab4:	39 f7                	cmp    %esi,%edi
f0104ab6:	77 dd                	ja     f0104a95 <__umoddi3+0x29>
f0104ab8:	89 da                	mov    %ebx,%edx
f0104aba:	89 f0                	mov    %esi,%eax
f0104abc:	29 f8                	sub    %edi,%eax
f0104abe:	19 ea                	sbb    %ebp,%edx
f0104ac0:	83 c4 1c             	add    $0x1c,%esp
f0104ac3:	5b                   	pop    %ebx
f0104ac4:	5e                   	pop    %esi
f0104ac5:	5f                   	pop    %edi
f0104ac6:	5d                   	pop    %ebp
f0104ac7:	c3                   	ret    
f0104ac8:	89 f9                	mov    %edi,%ecx
f0104aca:	85 ff                	test   %edi,%edi
f0104acc:	75 0b                	jne    f0104ad9 <__umoddi3+0x6d>
f0104ace:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ad3:	31 d2                	xor    %edx,%edx
f0104ad5:	f7 f7                	div    %edi
f0104ad7:	89 c1                	mov    %eax,%ecx
f0104ad9:	89 d8                	mov    %ebx,%eax
f0104adb:	31 d2                	xor    %edx,%edx
f0104add:	f7 f1                	div    %ecx
f0104adf:	89 f0                	mov    %esi,%eax
f0104ae1:	f7 f1                	div    %ecx
f0104ae3:	eb ac                	jmp    f0104a91 <__umoddi3+0x25>
f0104ae5:	8d 76 00             	lea    0x0(%esi),%esi
f0104ae8:	b8 20 00 00 00       	mov    $0x20,%eax
f0104aed:	89 c2                	mov    %eax,%edx
f0104aef:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104af3:	29 c2                	sub    %eax,%edx
f0104af5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104af9:	88 c1                	mov    %al,%cl
f0104afb:	d3 e5                	shl    %cl,%ebp
f0104afd:	89 f8                	mov    %edi,%eax
f0104aff:	88 d1                	mov    %dl,%cl
f0104b01:	d3 e8                	shr    %cl,%eax
f0104b03:	09 c5                	or     %eax,%ebp
f0104b05:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104b09:	88 c1                	mov    %al,%cl
f0104b0b:	d3 e7                	shl    %cl,%edi
f0104b0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104b11:	89 df                	mov    %ebx,%edi
f0104b13:	88 d1                	mov    %dl,%cl
f0104b15:	d3 ef                	shr    %cl,%edi
f0104b17:	88 c1                	mov    %al,%cl
f0104b19:	d3 e3                	shl    %cl,%ebx
f0104b1b:	89 f0                	mov    %esi,%eax
f0104b1d:	88 d1                	mov    %dl,%cl
f0104b1f:	d3 e8                	shr    %cl,%eax
f0104b21:	09 d8                	or     %ebx,%eax
f0104b23:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0104b27:	d3 e6                	shl    %cl,%esi
f0104b29:	89 fa                	mov    %edi,%edx
f0104b2b:	f7 f5                	div    %ebp
f0104b2d:	89 d1                	mov    %edx,%ecx
f0104b2f:	f7 64 24 08          	mull   0x8(%esp)
f0104b33:	89 c3                	mov    %eax,%ebx
f0104b35:	89 d7                	mov    %edx,%edi
f0104b37:	39 d1                	cmp    %edx,%ecx
f0104b39:	72 29                	jb     f0104b64 <__umoddi3+0xf8>
f0104b3b:	74 23                	je     f0104b60 <__umoddi3+0xf4>
f0104b3d:	89 ca                	mov    %ecx,%edx
f0104b3f:	29 de                	sub    %ebx,%esi
f0104b41:	19 fa                	sbb    %edi,%edx
f0104b43:	89 d0                	mov    %edx,%eax
f0104b45:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0104b49:	d3 e0                	shl    %cl,%eax
f0104b4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0104b4f:	88 d9                	mov    %bl,%cl
f0104b51:	d3 ee                	shr    %cl,%esi
f0104b53:	09 f0                	or     %esi,%eax
f0104b55:	d3 ea                	shr    %cl,%edx
f0104b57:	83 c4 1c             	add    $0x1c,%esp
f0104b5a:	5b                   	pop    %ebx
f0104b5b:	5e                   	pop    %esi
f0104b5c:	5f                   	pop    %edi
f0104b5d:	5d                   	pop    %ebp
f0104b5e:	c3                   	ret    
f0104b5f:	90                   	nop
f0104b60:	39 c6                	cmp    %eax,%esi
f0104b62:	73 d9                	jae    f0104b3d <__umoddi3+0xd1>
f0104b64:	2b 44 24 08          	sub    0x8(%esp),%eax
f0104b68:	19 ea                	sbb    %ebp,%edx
f0104b6a:	89 d7                	mov    %edx,%edi
f0104b6c:	89 c3                	mov    %eax,%ebx
f0104b6e:	eb cd                	jmp    f0104b3d <__umoddi3+0xd1>
