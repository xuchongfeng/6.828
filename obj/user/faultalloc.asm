
obj/user/faultalloc:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 9b 00 00 00       	call   8000cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	53                   	push   %ebx
  800041:	68 c0 0f 80 00       	push   $0x800fc0
  800046:	e8 bd 01 00 00       	call   800208 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 75 0b 00 00       	call   800bd4 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	78 16                	js     80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800066:	53                   	push   %ebx
  800067:	68 0c 10 80 00       	push   $0x80100c
  80006c:	6a 64                	push   $0x64
  80006e:	53                   	push   %ebx
  80006f:	e8 4d 07 00 00       	call   8007c1 <snprintf>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007a:	c9                   	leave  
  80007b:	c3                   	ret    
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007c:	83 ec 0c             	sub    $0xc,%esp
  80007f:	50                   	push   %eax
  800080:	53                   	push   %ebx
  800081:	68 e0 0f 80 00       	push   $0x800fe0
  800086:	6a 0e                	push   $0xe
  800088:	68 ca 0f 80 00       	push   $0x800fca
  80008d:	e8 9a 00 00 00       	call   80012c <_panic>

00800092 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800098:	68 34 00 80 00       	push   $0x800034
  80009d:	e8 e2 0c 00 00       	call   800d84 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 ef be ad de       	push   $0xdeadbeef
  8000aa:	68 dc 0f 80 00       	push   $0x800fdc
  8000af:	e8 54 01 00 00       	call   800208 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	68 fe bf fe ca       	push   $0xcafebffe
  8000bc:	68 dc 0f 80 00       	push   $0x800fdc
  8000c1:	e8 42 01 00 00       	call   800208 <cprintf>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    
	...

008000cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d7:	e8 ba 0a 00 00       	call   800b96 <sys_getenvid>
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	89 c2                	mov    %eax,%edx
  8000e3:	c1 e2 05             	shl    $0x5,%edx
  8000e6:	29 c2                	sub    %eax,%edx
  8000e8:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000ef:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f4:	85 db                	test   %ebx,%ebx
  8000f6:	7e 07                	jle    8000ff <libmain+0x33>
		binaryname = argv[0];
  8000f8:	8b 06                	mov    (%esi),%eax
  8000fa:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	e8 89 ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011e:	6a 00                	push   $0x0
  800120:	e8 30 0a 00 00       	call   800b55 <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    
	...

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013a:	e8 57 0a 00 00       	call   800b96 <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	56                   	push   %esi
  800149:	50                   	push   %eax
  80014a:	68 38 10 80 00       	push   $0x801038
  80014f:	e8 b4 00 00 00       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	53                   	push   %ebx
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 57 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 de 0f 80 00 	movl   $0x800fde,(%esp)
  800167:	e8 9c 00 00 00       	call   800208 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>
	...

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 13                	mov    (%ebx),%edx
  800180:	8d 42 01             	lea    0x1(%edx),%eax
  800183:	89 03                	mov    %eax,(%ebx)
  800185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800188:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800191:	74 08                	je     80019b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800193:	ff 43 04             	incl   0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 6c 09 00 00       	call   800b18 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	eb dc                	jmp    800193 <putch+0x1f>

008001b7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 74 01 80 00       	push   $0x800174
  8001e6:	e8 17 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 18 09 00 00       	call   800b18 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800240:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800243:	39 d3                	cmp    %edx,%ebx
  800245:	72 05                	jb     80024c <printnum+0x30>
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 78                	ja     8002c4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	8b 45 14             	mov    0x14(%ebp),%eax
  800255:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800262:	ff 75 e0             	pushl  -0x20(%ebp)
  800265:	ff 75 dc             	pushl  -0x24(%ebp)
  800268:	ff 75 d8             	pushl  -0x28(%ebp)
  80026b:	e8 44 0b 00 00       	call   800db4 <__udivdi3>
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	52                   	push   %edx
  800274:	50                   	push   %eax
  800275:	89 f2                	mov    %esi,%edx
  800277:	89 f8                	mov    %edi,%eax
  800279:	e8 9e ff ff ff       	call   80021c <printnum>
  80027e:	83 c4 20             	add    $0x20,%esp
  800281:	eb 11                	jmp    800294 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	ff d7                	call   *%edi
  80028c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	4b                   	dec    %ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f ef                	jg     800283 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029e:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a7:	e8 08 0c 00 00       	call   800eb4 <__umoddi3>
  8002ac:	83 c4 14             	add    $0x14,%esp
  8002af:	0f be 80 5b 10 80 00 	movsbl 0x80105b(%eax),%eax
  8002b6:	50                   	push   %eax
  8002b7:	ff d7                	call   *%edi
}
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    
  8002c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c7:	eb c6                	jmp    80028f <printnum+0x73>

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d7:	73 0a                	jae    8002e3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	88 02                	mov    %al,(%edx)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ee:	50                   	push   %eax
  8002ef:	ff 75 10             	pushl  0x10(%ebp)
  8002f2:	ff 75 0c             	pushl  0xc(%ebp)
  8002f5:	ff 75 08             	pushl  0x8(%ebp)
  8002f8:	e8 05 00 00 00       	call   800302 <vprintfmt>
	va_end(ap);
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	e9 ac 03 00 00       	jmp    8006c5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800319:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80031d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800324:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80032b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8d 47 01             	lea    0x1(%edi),%eax
  80033a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033d:	8a 17                	mov    (%edi),%dl
  80033f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800342:	3c 55                	cmp    $0x55,%al
  800344:	0f 87 fc 03 00 00    	ja     800746 <vprintfmt+0x444>
  80034a:	0f b6 c0             	movzbl %al,%eax
  80034d:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800357:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035b:	eb da                	jmp    800337 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d1                	jmp    800337 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	0f b6 d2             	movzbl %dl,%edx
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036c:	b8 00 00 00 00       	mov    $0x0,%eax
  800371:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800374:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800377:	01 c0                	add    %eax,%eax
  800379:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80037d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800380:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800383:	83 f9 09             	cmp    $0x9,%ecx
  800386:	77 52                	ja     8003da <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800389:	eb e9                	jmp    800374 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 40 04             	lea    0x4(%eax),%eax
  800399:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80039f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a3:	79 92                	jns    800337 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b2:	eb 83                	jmp    800337 <vprintfmt+0x35>
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	78 08                	js     8003c2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	e9 75 ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c9:	eb ef                	jmp    8003ba <vprintfmt+0xb8>
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d5:	e9 5d ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e0:	eb bd                	jmp    80039f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e6:	e9 4c ff ff ff       	jmp    800337 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 78 04             	lea    0x4(%eax),%edi
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	pushl  (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ff:	e9 be 02 00 00       	jmp    8006c2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 78 04             	lea    0x4(%eax),%edi
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	78 2a                	js     80043a <vprintfmt+0x138>
  800410:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 08             	cmp    $0x8,%eax
  800415:	7f 27                	jg     80043e <vprintfmt+0x13c>
  800417:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  80041e:	85 c0                	test   %eax,%eax
  800420:	74 1c                	je     80043e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800422:	50                   	push   %eax
  800423:	68 7c 10 80 00       	push   $0x80107c
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 b6 fe ff ff       	call   8002e5 <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800432:	89 7d 14             	mov    %edi,0x14(%ebp)
  800435:	e9 88 02 00 00       	jmp    8006c2 <vprintfmt+0x3c0>
  80043a:	f7 d8                	neg    %eax
  80043c:	eb d2                	jmp    800410 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043e:	52                   	push   %edx
  80043f:	68 73 10 80 00       	push   $0x801073
  800444:	53                   	push   %ebx
  800445:	56                   	push   %esi
  800446:	e8 9a fe ff ff       	call   8002e5 <printfmt>
  80044b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800451:	e9 6c 02 00 00       	jmp    8006c2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	83 c0 04             	add    $0x4,%eax
  80045c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8b 38                	mov    (%eax),%edi
  800464:	85 ff                	test   %edi,%edi
  800466:	74 18                	je     800480 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800468:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046c:	0f 8e b7 00 00 00    	jle    800529 <vprintfmt+0x227>
  800472:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800476:	75 0f                	jne    800487 <vprintfmt+0x185>
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80047e:	eb 75                	jmp    8004f5 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800480:	bf 6c 10 80 00       	mov    $0x80106c,%edi
  800485:	eb e1                	jmp    800468 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 d0             	pushl  -0x30(%ebp)
  80048d:	57                   	push   %edi
  80048e:	e8 5f 03 00 00       	call   8007f2 <strnlen>
  800493:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800496:	29 c1                	sub    %eax,%ecx
  800498:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	eb 0d                	jmp    8004b9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	53                   	push   %ebx
  8004b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	4f                   	dec    %edi
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	7f ef                	jg     8004ac <vprintfmt+0x1aa>
  8004bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004c3:	89 c8                	mov    %ecx,%eax
  8004c5:	85 c9                	test   %ecx,%ecx
  8004c7:	78 10                	js     8004d9 <vprintfmt+0x1d7>
  8004c9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004cc:	29 c1                	sub    %eax,%ecx
  8004ce:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004d7:	eb 1c                	jmp    8004f5 <vprintfmt+0x1f3>
  8004d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004de:	eb e9                	jmp    8004c9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e4:	75 29                	jne    80050f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ec:	50                   	push   %eax
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f2:	ff 4d e0             	decl   -0x20(%ebp)
  8004f5:	47                   	inc    %edi
  8004f6:	8a 57 ff             	mov    -0x1(%edi),%dl
  8004f9:	0f be c2             	movsbl %dl,%eax
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	74 4c                	je     80054c <vprintfmt+0x24a>
  800500:	85 db                	test   %ebx,%ebx
  800502:	78 dc                	js     8004e0 <vprintfmt+0x1de>
  800504:	4b                   	dec    %ebx
  800505:	79 d9                	jns    8004e0 <vprintfmt+0x1de>
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80050d:	eb 2e                	jmp    80053d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80050f:	0f be d2             	movsbl %dl,%edx
  800512:	83 ea 20             	sub    $0x20,%edx
  800515:	83 fa 5e             	cmp    $0x5e,%edx
  800518:	76 cc                	jbe    8004e6 <vprintfmt+0x1e4>
					putch('?', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	6a 3f                	push   $0x3f
  800522:	ff d6                	call   *%esi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb c9                	jmp    8004f2 <vprintfmt+0x1f0>
  800529:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80052f:	eb c4                	jmp    8004f5 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 20                	push   $0x20
  800537:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800539:	4f                   	dec    %edi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f f0                	jg     800531 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800541:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
  800547:	e9 76 01 00 00       	jmp    8006c2 <vprintfmt+0x3c0>
  80054c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80054f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800552:	eb e9                	jmp    80053d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7e 3f                	jle    800598 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 50 04             	mov    0x4(%eax),%edx
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 08             	lea    0x8(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	79 5c                	jns    8005d2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800581:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800584:	f7 da                	neg    %edx
  800586:	83 d1 00             	adc    $0x0,%ecx
  800589:	f7 d9                	neg    %ecx
  80058b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 10 01 00 00       	jmp    8006a8 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	75 1b                	jne    8005b7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 c1                	mov    %eax,%ecx
  8005a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b5:	eb b9                	jmp    800570 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d0:	eb 9e                	jmp    800570 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	e9 c6 00 00 00       	jmp    8006a8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7e 18                	jle    8005ff <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 a9 00 00 00       	jmp    8006a8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	75 1a                	jne    80061d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 8b 00 00 00       	jmp    8006a8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	eb 74                	jmp    8006a8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7e 15                	jle    80064e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
  80064c:	eb 5a                	jmp    8006a8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	75 17                	jne    800669 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800662:	b8 08 00 00 00       	mov    $0x8,%eax
  800667:	eb 3f                	jmp    8006a8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800679:	b8 08 00 00 00       	mov    $0x8,%eax
  80067e:	eb 28                	jmp    8006a8 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d6                	call   *%esi
			putch('x', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 78                	push   $0x78
  80068e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006af:	57                   	push   %edi
  8006b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b3:	50                   	push   %eax
  8006b4:	51                   	push   %ecx
  8006b5:	52                   	push   %edx
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	e8 5d fb ff ff       	call   80021c <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c5:	47                   	inc    %edi
  8006c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ca:	83 f8 25             	cmp    $0x25,%eax
  8006cd:	0f 84 46 fc ff ff    	je     800319 <vprintfmt+0x17>
			if (ch == '\0')
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	0f 84 89 00 00 00    	je     800764 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	50                   	push   %eax
  8006e0:	ff d6                	call   *%esi
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb de                	jmp    8006c5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e7:	83 f9 01             	cmp    $0x1,%ecx
  8006ea:	7e 15                	jle    800701 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8b 10                	mov    (%eax),%edx
  8006f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f4:	8d 40 08             	lea    0x8(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ff:	eb a7                	jmp    8006a8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800701:	85 c9                	test   %ecx,%ecx
  800703:	75 17                	jne    80071c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
  80071a:	eb 8c                	jmp    8006a8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
  800731:	e9 72 ff ff ff       	jmp    8006a8 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 25                	push   $0x25
  80073c:	ff d6                	call   *%esi
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	e9 7c ff ff ff       	jmp    8006c2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	6a 25                	push   $0x25
  80074c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	89 f8                	mov    %edi,%eax
  800753:	eb 01                	jmp    800756 <vprintfmt+0x454>
  800755:	48                   	dec    %eax
  800756:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075a:	75 f9                	jne    800755 <vprintfmt+0x453>
  80075c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075f:	e9 5e ff ff ff       	jmp    8006c2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	83 ec 18             	sub    $0x18,%esp
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800778:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800782:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800789:	85 c0                	test   %eax,%eax
  80078b:	74 26                	je     8007b3 <vsnprintf+0x47>
  80078d:	85 d2                	test   %edx,%edx
  80078f:	7e 29                	jle    8007ba <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800791:	ff 75 14             	pushl  0x14(%ebp)
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	68 c9 02 80 00       	push   $0x8002c9
  8007a0:	e8 5d fb ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ae:	83 c4 10             	add    $0x10,%esp
}
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b8:	eb f7                	jmp    8007b1 <vsnprintf+0x45>
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bf:	eb f0                	jmp    8007b1 <vsnprintf+0x45>

008007c1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ca:	50                   	push   %eax
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 93 ff ff ff       	call   80076c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	41                   	inc    %ecx
  80081c:	42                   	inc    %edx
  80081d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800820:	88 5a ff             	mov    %bl,-0x1(%edx)
  800823:	84 db                	test   %bl,%bl
  800825:	75 f4                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800831:	53                   	push   %ebx
  800832:	e8 a5 ff ff ff       	call   8007dc <strlen>
  800837:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	01 d8                	add    %ebx,%eax
  80083f:	50                   	push   %eax
  800840:	e8 ca ff ff ff       	call   80080f <strcpy>
	return dst;
}
  800845:	89 d8                	mov    %ebx,%eax
  800847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	89 f3                	mov    %esi,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085c:	89 f2                	mov    %esi,%edx
  80085e:	39 da                	cmp    %ebx,%edx
  800860:	74 0e                	je     800870 <strncpy+0x24>
		*dst++ = *src;
  800862:	42                   	inc    %edx
  800863:	8a 01                	mov    (%ecx),%al
  800865:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800868:	80 39 00             	cmpb   $0x0,(%ecx)
  80086b:	74 f1                	je     80085e <strncpy+0x12>
			src++;
  80086d:	41                   	inc    %ecx
  80086e:	eb ee                	jmp    80085e <strncpy+0x12>
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 c0                	test   %eax,%eax
  800886:	74 20                	je     8008a8 <strlcpy+0x32>
  800888:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	eb 05                	jmp    800895 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	42                   	inc    %edx
  800891:	40                   	inc    %eax
  800892:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800895:	39 d8                	cmp    %ebx,%eax
  800897:	74 06                	je     80089f <strlcpy+0x29>
  800899:	8a 0a                	mov    (%edx),%cl
  80089b:	84 c9                	test   %cl,%cl
  80089d:	75 f1                	jne    800890 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80089f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a2:	29 f0                	sub    %esi,%eax
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	eb f6                	jmp    8008a2 <strlcpy+0x2c>

008008ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b5:	eb 02                	jmp    8008b9 <strcmp+0xd>
		p++, q++;
  8008b7:	41                   	inc    %ecx
  8008b8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b9:	8a 01                	mov    (%ecx),%al
  8008bb:	84 c0                	test   %al,%al
  8008bd:	74 04                	je     8008c3 <strcmp+0x17>
  8008bf:	3a 02                	cmp    (%edx),%al
  8008c1:	74 f4                	je     8008b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 c0             	movzbl %al,%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008dc:	eb 02                	jmp    8008e0 <strncmp+0x13>
		n--, p++, q++;
  8008de:	40                   	inc    %eax
  8008df:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e0:	39 d8                	cmp    %ebx,%eax
  8008e2:	74 15                	je     8008f9 <strncmp+0x2c>
  8008e4:	8a 08                	mov    (%eax),%cl
  8008e6:	84 c9                	test   %cl,%cl
  8008e8:	74 04                	je     8008ee <strncmp+0x21>
  8008ea:	3a 0a                	cmp    (%edx),%cl
  8008ec:	74 f0                	je     8008de <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 00             	movzbl (%eax),%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb f6                	jmp    8008f6 <strncmp+0x29>

00800900 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800909:	8a 10                	mov    (%eax),%dl
  80090b:	84 d2                	test   %dl,%dl
  80090d:	74 07                	je     800916 <strchr+0x16>
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 08                	je     80091b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800913:	40                   	inc    %eax
  800914:	eb f3                	jmp    800909 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800926:	8a 10                	mov    (%eax),%dl
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 07                	je     800933 <strfind+0x16>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 03                	je     800933 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800930:	40                   	inc    %eax
  800931:	eb f3                	jmp    800926 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 13                	je     800958 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 05                	jne    800952 <memset+0x1d>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	74 0d                	je     80095f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	fc                   	cld    
  800956:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800958:	89 f8                	mov    %edi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80095f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800963:	89 d3                	mov    %edx,%ebx
  800965:	c1 e3 08             	shl    $0x8,%ebx
  800968:	89 d0                	mov    %edx,%eax
  80096a:	c1 e0 18             	shl    $0x18,%eax
  80096d:	89 d6                	mov    %edx,%esi
  80096f:	c1 e6 10             	shl    $0x10,%esi
  800972:	09 f0                	or     %esi,%eax
  800974:	09 c2                	or     %eax,%edx
  800976:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800978:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb d6                	jmp    800958 <memset+0x23>

00800982 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800990:	39 c6                	cmp    %eax,%esi
  800992:	73 33                	jae    8009c7 <memmove+0x45>
  800994:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800997:	39 c2                	cmp    %eax,%edx
  800999:	76 2c                	jbe    8009c7 <memmove+0x45>
		s += n;
		d += n;
  80099b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	09 fe                	or     %edi,%esi
  8009a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a8:	74 0a                	je     8009b4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009aa:	4f                   	dec    %edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 21                	jmp    8009d5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 f1                	jne    8009aa <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb ea                	jmp    8009b1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	09 c2                	or     %eax,%edx
  8009cb:	f6 c2 03             	test   $0x3,%dl
  8009ce:	74 09                	je     8009d9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 f2                	jne    8009d0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009de:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb ed                	jmp    8009d5 <memmove+0x53>

008009e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009eb:	ff 75 10             	pushl  0x10(%ebp)
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	e8 89 ff ff ff       	call   800982 <memmove>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a06:	89 c6                	mov    %eax,%esi
  800a08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	39 f0                	cmp    %esi,%eax
  800a0d:	74 16                	je     800a25 <memcmp+0x2a>
		if (*s1 != *s2)
  800a0f:	8a 08                	mov    (%eax),%cl
  800a11:	8a 1a                	mov    (%edx),%bl
  800a13:	38 d9                	cmp    %bl,%cl
  800a15:	75 04                	jne    800a1b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a17:	40                   	inc    %eax
  800a18:	42                   	inc    %edx
  800a19:	eb f0                	jmp    800a0b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 05                	jmp    800a2a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a37:	89 c2                	mov    %eax,%edx
  800a39:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3c:	39 d0                	cmp    %edx,%eax
  800a3e:	73 07                	jae    800a47 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a40:	38 08                	cmp    %cl,(%eax)
  800a42:	74 03                	je     800a47 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a44:	40                   	inc    %eax
  800a45:	eb f5                	jmp    800a3c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 01                	jmp    800a55 <strtol+0xc>
		s++;
  800a54:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	8a 01                	mov    (%ecx),%al
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f9                	je     800a54 <strtol+0xb>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f5                	je     800a54 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	74 2b                	je     800a8e <strtol+0x45>
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	74 2f                	je     800a96 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a73:	75 12                	jne    800a87 <strtol+0x3e>
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	74 24                	je     800a9e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7e:	75 07                	jne    800a87 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a80:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	eb 4e                	jmp    800adc <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a8e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a94:	eb d6                	jmp    800a6c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a96:	41                   	inc    %ecx
  800a97:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9c:	eb ce                	jmp    800a6c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa2:	74 10                	je     800ab4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa8:	75 dd                	jne    800a87 <strtol+0x3e>
		s++, base = 8;
  800aaa:	41                   	inc    %ecx
  800aab:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ab2:	eb d3                	jmp    800a87 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ab4:	83 c1 02             	add    $0x2,%ecx
  800ab7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800abe:	eb c7                	jmp    800a87 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ac0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 24                	ja     800aee <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800ad3:	7e 2b                	jle    800b00 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ad5:	41                   	inc    %ecx
  800ad6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ada:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	8a 11                	mov    (%ecx),%dl
  800ade:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 da                	ja     800ac0 <strtol+0x77>
			dig = *s - '0';
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 30             	sub    $0x30,%edx
  800aec:	eb e2                	jmp    800ad0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 37             	sub    $0x37,%edx
  800afe:	eb d0                	jmp    800ad0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b04:	74 05                	je     800b0b <strtol+0xc2>
		*endptr = (char *) s;
  800b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	74 02                	je     800b11 <strtol+0xc8>
  800b0f:	f7 d8                	neg    %eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
	...

00800b18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	89 c6                	mov    %eax,%esi
  800b2f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6b:	89 cb                	mov    %ecx,%ebx
  800b6d:	89 cf                	mov    %ecx,%edi
  800b6f:	89 ce                	mov    %ecx,%esi
  800b71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7f 08                	jg     800b7f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 03                	push   $0x3
  800b85:	68 a4 12 80 00       	push   $0x8012a4
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 c1 12 80 00       	push   $0x8012c1
  800b91:	e8 96 f5 ff ff       	call   80012c <_panic>

00800b96 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba6:	89 d1                	mov    %edx,%ecx
  800ba8:	89 d3                	mov    %edx,%ebx
  800baa:	89 d7                	mov    %edx,%edi
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_yield>:

void
sys_yield(void)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc5:	89 d1                	mov    %edx,%ecx
  800bc7:	89 d3                	mov    %edx,%ebx
  800bc9:	89 d7                	mov    %edx,%edi
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	be 00 00 00 00       	mov    $0x0,%esi
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf0:	89 f7                	mov    %esi,%edi
  800bf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7f 08                	jg     800c00 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 04                	push   $0x4
  800c06:	68 a4 12 80 00       	push   $0x8012a4
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 c1 12 80 00       	push   $0x8012c1
  800c12:	e8 15 f5 ff ff       	call   80012c <_panic>

00800c17 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c31:	8b 75 18             	mov    0x18(%ebp),%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7f 08                	jg     800c42 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 05                	push   $0x5
  800c48:	68 a4 12 80 00       	push   $0x8012a4
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 c1 12 80 00       	push   $0x8012c1
  800c54:	e8 d3 f4 ff ff       	call   80012c <_panic>

00800c59 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c72:	89 df                	mov    %ebx,%edi
  800c74:	89 de                	mov    %ebx,%esi
  800c76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7f 08                	jg     800c84 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 06                	push   $0x6
  800c8a:	68 a4 12 80 00       	push   $0x8012a4
  800c8f:	6a 23                	push   $0x23
  800c91:	68 c1 12 80 00       	push   $0x8012c1
  800c96:	e8 91 f4 ff ff       	call   80012c <_panic>

00800c9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7f 08                	jg     800cc6 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 08                	push   $0x8
  800ccc:	68 a4 12 80 00       	push   $0x8012a4
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 c1 12 80 00       	push   $0x8012c1
  800cd8:	e8 4f f4 ff ff       	call   80012c <_panic>

00800cdd <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7f 08                	jg     800d08 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 09                	push   $0x9
  800d0e:	68 a4 12 80 00       	push   $0x8012a4
  800d13:	6a 23                	push   $0x23
  800d15:	68 c1 12 80 00       	push   $0x8012c1
  800d1a:	e8 0d f4 ff ff       	call   80012c <_panic>

00800d1f <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	89 cb                	mov    %ecx,%ebx
  800d5a:	89 cf                	mov    %ecx,%edi
  800d5c:	89 ce                	mov    %ecx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7f 08                	jg     800d6c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	6a 0c                	push   $0xc
  800d72:	68 a4 12 80 00       	push   $0x8012a4
  800d77:	6a 23                	push   $0x23
  800d79:	68 c1 12 80 00       	push   $0x8012c1
  800d7e:	e8 a9 f3 ff ff       	call   80012c <_panic>
	...

00800d84 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d8a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d91:	74 0a                	je     800d9d <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	68 d0 12 80 00       	push   $0x8012d0
  800da5:	6a 20                	push   $0x20
  800da7:	68 f4 12 80 00       	push   $0x8012f4
  800dac:	e8 7b f3 ff ff       	call   80012c <_panic>
  800db1:	00 00                	add    %al,(%eax)
	...

00800db4 <__udivdi3>:
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 1c             	sub    $0x1c,%esp
  800dbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dcb:	85 d2                	test   %edx,%edx
  800dcd:	75 2d                	jne    800dfc <__udivdi3+0x48>
  800dcf:	39 f7                	cmp    %esi,%edi
  800dd1:	77 59                	ja     800e2c <__udivdi3+0x78>
  800dd3:	89 f9                	mov    %edi,%ecx
  800dd5:	85 ff                	test   %edi,%edi
  800dd7:	75 0b                	jne    800de4 <__udivdi3+0x30>
  800dd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f7                	div    %edi
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	31 d2                	xor    %edx,%edx
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	f7 f1                	div    %ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 e8                	mov    %ebp,%eax
  800dee:	f7 f1                	div    %ecx
  800df0:	89 da                	mov    %ebx,%edx
  800df2:	83 c4 1c             	add    $0x1c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	39 f2                	cmp    %esi,%edx
  800dfe:	77 1c                	ja     800e1c <__udivdi3+0x68>
  800e00:	0f bd da             	bsr    %edx,%ebx
  800e03:	83 f3 1f             	xor    $0x1f,%ebx
  800e06:	75 38                	jne    800e40 <__udivdi3+0x8c>
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	72 08                	jb     800e14 <__udivdi3+0x60>
  800e0c:	39 ef                	cmp    %ebp,%edi
  800e0e:	0f 87 98 00 00 00    	ja     800eac <__udivdi3+0xf8>
  800e14:	b8 01 00 00 00       	mov    $0x1,%eax
  800e19:	eb 05                	jmp    800e20 <__udivdi3+0x6c>
  800e1b:	90                   	nop
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	31 c0                	xor    %eax,%eax
  800e20:	89 da                	mov    %ebx,%edx
  800e22:	83 c4 1c             	add    $0x1c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	89 e8                	mov    %ebp,%eax
  800e2e:	89 f2                	mov    %esi,%edx
  800e30:	f7 f7                	div    %edi
  800e32:	31 db                	xor    %ebx,%ebx
  800e34:	89 da                	mov    %ebx,%edx
  800e36:	83 c4 1c             	add    $0x1c,%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
  800e3e:	66 90                	xchg   %ax,%ax
  800e40:	b8 20 00 00 00       	mov    $0x20,%eax
  800e45:	29 d8                	sub    %ebx,%eax
  800e47:	88 d9                	mov    %bl,%cl
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 fa                	mov    %edi,%edx
  800e51:	88 c1                	mov    %al,%cl
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e5f:	88 d9                	mov    %bl,%cl
  800e61:	d3 e7                	shl    %cl,%edi
  800e63:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e67:	89 f7                	mov    %esi,%edi
  800e69:	88 c1                	mov    %al,%cl
  800e6b:	d3 ef                	shr    %cl,%edi
  800e6d:	88 d9                	mov    %bl,%cl
  800e6f:	d3 e6                	shl    %cl,%esi
  800e71:	89 ea                	mov    %ebp,%edx
  800e73:	88 c1                	mov    %al,%cl
  800e75:	d3 ea                	shr    %cl,%edx
  800e77:	09 d6                	or     %edx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	89 fa                	mov    %edi,%edx
  800e7d:	f7 74 24 08          	divl   0x8(%esp)
  800e81:	89 d7                	mov    %edx,%edi
  800e83:	89 c6                	mov    %eax,%esi
  800e85:	f7 64 24 0c          	mull   0xc(%esp)
  800e89:	39 d7                	cmp    %edx,%edi
  800e8b:	72 13                	jb     800ea0 <__udivdi3+0xec>
  800e8d:	74 09                	je     800e98 <__udivdi3+0xe4>
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	31 db                	xor    %ebx,%ebx
  800e93:	eb 8b                	jmp    800e20 <__udivdi3+0x6c>
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	88 d9                	mov    %bl,%cl
  800e9a:	d3 e5                	shl    %cl,%ebp
  800e9c:	39 c5                	cmp    %eax,%ebp
  800e9e:	73 ef                	jae    800e8f <__udivdi3+0xdb>
  800ea0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ea3:	31 db                	xor    %ebx,%ebx
  800ea5:	e9 76 ff ff ff       	jmp    800e20 <__udivdi3+0x6c>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	31 c0                	xor    %eax,%eax
  800eae:	e9 6d ff ff ff       	jmp    800e20 <__udivdi3+0x6c>
	...

00800eb4 <__umoddi3>:
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ebf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ec7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	89 da                	mov    %ebx,%edx
  800ecf:	85 ed                	test   %ebp,%ebp
  800ed1:	75 15                	jne    800ee8 <__umoddi3+0x34>
  800ed3:	39 df                	cmp    %ebx,%edi
  800ed5:	76 39                	jbe    800f10 <__umoddi3+0x5c>
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	39 dd                	cmp    %ebx,%ebp
  800eea:	77 f1                	ja     800edd <__umoddi3+0x29>
  800eec:	0f bd cd             	bsr    %ebp,%ecx
  800eef:	83 f1 1f             	xor    $0x1f,%ecx
  800ef2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ef6:	75 38                	jne    800f30 <__umoddi3+0x7c>
  800ef8:	39 dd                	cmp    %ebx,%ebp
  800efa:	72 04                	jb     800f00 <__umoddi3+0x4c>
  800efc:	39 f7                	cmp    %esi,%edi
  800efe:	77 dd                	ja     800edd <__umoddi3+0x29>
  800f00:	89 da                	mov    %ebx,%edx
  800f02:	89 f0                	mov    %esi,%eax
  800f04:	29 f8                	sub    %edi,%eax
  800f06:	19 ea                	sbb    %ebp,%edx
  800f08:	83 c4 1c             	add    $0x1c,%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    
  800f10:	89 f9                	mov    %edi,%ecx
  800f12:	85 ff                	test   %edi,%edi
  800f14:	75 0b                	jne    800f21 <__umoddi3+0x6d>
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f7                	div    %edi
  800f1f:	89 c1                	mov    %eax,%ecx
  800f21:	89 d8                	mov    %ebx,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f1                	div    %ecx
  800f27:	89 f0                	mov    %esi,%eax
  800f29:	f7 f1                	div    %ecx
  800f2b:	eb ac                	jmp    800ed9 <__umoddi3+0x25>
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	b8 20 00 00 00       	mov    $0x20,%eax
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f3b:	29 c2                	sub    %eax,%edx
  800f3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f41:	88 c1                	mov    %al,%cl
  800f43:	d3 e5                	shl    %cl,%ebp
  800f45:	89 f8                	mov    %edi,%eax
  800f47:	88 d1                	mov    %dl,%cl
  800f49:	d3 e8                	shr    %cl,%eax
  800f4b:	09 c5                	or     %eax,%ebp
  800f4d:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f51:	88 c1                	mov    %al,%cl
  800f53:	d3 e7                	shl    %cl,%edi
  800f55:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	88 d1                	mov    %dl,%cl
  800f5d:	d3 ef                	shr    %cl,%edi
  800f5f:	88 c1                	mov    %al,%cl
  800f61:	d3 e3                	shl    %cl,%ebx
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	88 d1                	mov    %dl,%cl
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	09 d8                	or     %ebx,%eax
  800f6b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f6f:	d3 e6                	shl    %cl,%esi
  800f71:	89 fa                	mov    %edi,%edx
  800f73:	f7 f5                	div    %ebp
  800f75:	89 d1                	mov    %edx,%ecx
  800f77:	f7 64 24 08          	mull   0x8(%esp)
  800f7b:	89 c3                	mov    %eax,%ebx
  800f7d:	89 d7                	mov    %edx,%edi
  800f7f:	39 d1                	cmp    %edx,%ecx
  800f81:	72 29                	jb     800fac <__umoddi3+0xf8>
  800f83:	74 23                	je     800fa8 <__umoddi3+0xf4>
  800f85:	89 ca                	mov    %ecx,%edx
  800f87:	29 de                	sub    %ebx,%esi
  800f89:	19 fa                	sbb    %edi,%edx
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f97:	88 d9                	mov    %bl,%cl
  800f99:	d3 ee                	shr    %cl,%esi
  800f9b:	09 f0                	or     %esi,%eax
  800f9d:	d3 ea                	shr    %cl,%edx
  800f9f:	83 c4 1c             	add    $0x1c,%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
  800fa8:	39 c6                	cmp    %eax,%esi
  800faa:	73 d9                	jae    800f85 <__umoddi3+0xd1>
  800fac:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fb0:	19 ea                	sbb    %ebp,%edx
  800fb2:	89 d7                	mov    %edx,%edi
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	eb cd                	jmp    800f85 <__umoddi3+0xd1>
