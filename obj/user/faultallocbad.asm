
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
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
  800046:	e8 a9 01 00 00       	call   8001f4 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 61 0b 00 00       	call   800bc0 <sys_page_alloc>
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
  80006f:	e8 39 07 00 00       	call   8007ad <snprintf>
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
  800086:	6a 0f                	push   $0xf
  800088:	68 ca 0f 80 00       	push   $0x800fca
  80008d:	e8 86 00 00 00       	call   800118 <_panic>

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
  80009d:	e8 ce 0c 00 00       	call   800d70 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	6a 04                	push   $0x4
  8000a7:	68 ef be ad de       	push   $0xdeadbeef
  8000ac:	e8 53 0a 00 00       	call   800b04 <sys_cputs>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c3:	e8 ba 0a 00 00       	call   800b82 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	89 c2                	mov    %eax,%edx
  8000cf:	c1 e2 05             	shl    $0x5,%edx
  8000d2:	29 c2                	sub    %eax,%edx
  8000d4:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x33>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 9d ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 30 0a 00 00       	call   800b41 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    
	...

00800118 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800120:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800126:	e8 57 0a 00 00       	call   800b82 <sys_getenvid>
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	ff 75 0c             	pushl  0xc(%ebp)
  800131:	ff 75 08             	pushl  0x8(%ebp)
  800134:	56                   	push   %esi
  800135:	50                   	push   %eax
  800136:	68 38 10 80 00       	push   $0x801038
  80013b:	e8 b4 00 00 00       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800140:	83 c4 18             	add    $0x18,%esp
  800143:	53                   	push   %ebx
  800144:	ff 75 10             	pushl  0x10(%ebp)
  800147:	e8 57 00 00 00       	call   8001a3 <vcprintf>
	cprintf("\n");
  80014c:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  800153:	e8 9c 00 00 00       	call   8001f4 <cprintf>
  800158:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015b:	cc                   	int3   
  80015c:	eb fd                	jmp    80015b <_panic+0x43>
	...

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 04             	sub    $0x4,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 13                	mov    (%ebx),%edx
  80016c:	8d 42 01             	lea    0x1(%edx),%eax
  80016f:	89 03                	mov    %eax,(%ebx)
  800171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800174:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	74 08                	je     800187 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017f:	ff 43 04             	incl   0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 6c 09 00 00       	call   800b04 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb dc                	jmp    80017f <putch+0x1f>

008001a3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 60 01 80 00       	push   $0x800160
  8001d2:	e8 17 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 18 09 00 00       	call   800b04 <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	50                   	push   %eax
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 9d ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 1c             	sub    $0x1c,%esp
  800211:	89 c7                	mov    %eax,%edi
  800213:	89 d6                	mov    %edx,%esi
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800221:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022f:	39 d3                	cmp    %edx,%ebx
  800231:	72 05                	jb     800238 <printnum+0x30>
  800233:	39 45 10             	cmp    %eax,0x10(%ebp)
  800236:	77 78                	ja     8002b0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	8b 45 14             	mov    0x14(%ebp),%eax
  800241:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800244:	53                   	push   %ebx
  800245:	ff 75 10             	pushl  0x10(%ebp)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 44 0b 00 00       	call   800da0 <__udivdi3>
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	52                   	push   %edx
  800260:	50                   	push   %eax
  800261:	89 f2                	mov    %esi,%edx
  800263:	89 f8                	mov    %edi,%eax
  800265:	e8 9e ff ff ff       	call   800208 <printnum>
  80026a:	83 c4 20             	add    $0x20,%esp
  80026d:	eb 11                	jmp    800280 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	56                   	push   %esi
  800273:	ff 75 18             	pushl  0x18(%ebp)
  800276:	ff d7                	call   *%edi
  800278:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027b:	4b                   	dec    %ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f ef                	jg     80026f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 08 0c 00 00       	call   800ea0 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 5b 10 80 00 	movsbl 0x80105b(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b3:	eb c6                	jmp    80027b <printnum+0x73>

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	e9 ac 03 00 00       	jmp    8006b1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800305:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800309:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800317:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80031e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8d 47 01             	lea    0x1(%edi),%eax
  800326:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800329:	8a 17                	mov    (%edi),%dl
  80032b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 fc 03 00 00    	ja     800732 <vprintfmt+0x444>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800347:	eb da                	jmp    800323 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800350:	eb d1                	jmp    800323 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800358:	b8 00 00 00 00       	mov    $0x0,%eax
  80035d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800360:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800363:	01 c0                	add    %eax,%eax
  800365:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800369:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036f:	83 f9 09             	cmp    $0x9,%ecx
  800372:	77 52                	ja     8003c6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800374:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800375:	eb e9                	jmp    800360 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 40 04             	lea    0x4(%eax),%eax
  800385:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	79 92                	jns    800323 <vprintfmt+0x35>
				width = precision, precision = -1;
  800391:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800394:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039e:	eb 83                	jmp    800323 <vprintfmt+0x35>
  8003a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a4:	78 08                	js     8003ae <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	e9 75 ff ff ff       	jmp    800323 <vprintfmt+0x35>
  8003ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b5:	eb ef                	jmp    8003a6 <vprintfmt+0xb8>
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c1:	e9 5d ff ff ff       	jmp    800323 <vprintfmt+0x35>
  8003c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003cc:	eb bd                	jmp    80038b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ce:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d2:	e9 4c ff ff ff       	jmp    800323 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 78 04             	lea    0x4(%eax),%edi
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff d6                	call   *%esi
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003eb:	e9 be 02 00 00       	jmp    8006ae <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 78 04             	lea    0x4(%eax),%edi
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	78 2a                	js     800426 <vprintfmt+0x138>
  8003fc:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fe:	83 f8 08             	cmp    $0x8,%eax
  800401:	7f 27                	jg     80042a <vprintfmt+0x13c>
  800403:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  80040a:	85 c0                	test   %eax,%eax
  80040c:	74 1c                	je     80042a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	50                   	push   %eax
  80040f:	68 7c 10 80 00       	push   $0x80107c
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 b6 fe ff ff       	call   8002d1 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800421:	e9 88 02 00 00       	jmp    8006ae <vprintfmt+0x3c0>
  800426:	f7 d8                	neg    %eax
  800428:	eb d2                	jmp    8003fc <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042a:	52                   	push   %edx
  80042b:	68 73 10 80 00       	push   $0x801073
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 9a fe ff ff       	call   8002d1 <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 6c 02 00 00       	jmp    8006ae <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	83 c0 04             	add    $0x4,%eax
  800448:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8b 38                	mov    (%eax),%edi
  800450:	85 ff                	test   %edi,%edi
  800452:	74 18                	je     80046c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	0f 8e b7 00 00 00    	jle    800515 <vprintfmt+0x227>
  80045e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800462:	75 0f                	jne    800473 <vprintfmt+0x185>
  800464:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800467:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80046a:	eb 75                	jmp    8004e1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80046c:	bf 6c 10 80 00       	mov    $0x80106c,%edi
  800471:	eb e1                	jmp    800454 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 d0             	pushl  -0x30(%ebp)
  800479:	57                   	push   %edi
  80047a:	e8 5f 03 00 00       	call   8007de <strnlen>
  80047f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800482:	29 c1                	sub    %eax,%ecx
  800484:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800487:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800494:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	eb 0d                	jmp    8004a5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	53                   	push   %ebx
  80049c:	ff 75 e0             	pushl  -0x20(%ebp)
  80049f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	4f                   	dec    %edi
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	7f ef                	jg     800498 <vprintfmt+0x1aa>
  8004a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004af:	89 c8                	mov    %ecx,%eax
  8004b1:	85 c9                	test   %ecx,%ecx
  8004b3:	78 10                	js     8004c5 <vprintfmt+0x1d7>
  8004b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004c3:	eb 1c                	jmp    8004e1 <vprintfmt+0x1f3>
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	eb e9                	jmp    8004b5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d0:	75 29                	jne    8004fb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 0c             	pushl  0xc(%ebp)
  8004d8:	50                   	push   %eax
  8004d9:	ff d6                	call   *%esi
  8004db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	ff 4d e0             	decl   -0x20(%ebp)
  8004e1:	47                   	inc    %edi
  8004e2:	8a 57 ff             	mov    -0x1(%edi),%dl
  8004e5:	0f be c2             	movsbl %dl,%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	74 4c                	je     800538 <vprintfmt+0x24a>
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	78 dc                	js     8004cc <vprintfmt+0x1de>
  8004f0:	4b                   	dec    %ebx
  8004f1:	79 d9                	jns    8004cc <vprintfmt+0x1de>
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f9:	eb 2e                	jmp    800529 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fb:	0f be d2             	movsbl %dl,%edx
  8004fe:	83 ea 20             	sub    $0x20,%edx
  800501:	83 fa 5e             	cmp    $0x5e,%edx
  800504:	76 cc                	jbe    8004d2 <vprintfmt+0x1e4>
					putch('?', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb c9                	jmp    8004de <vprintfmt+0x1f0>
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80051b:	eb c4                	jmp    8004e1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 20                	push   $0x20
  800523:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	4f                   	dec    %edi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f f0                	jg     80051d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
  800533:	e9 76 01 00 00       	jmp    8006ae <vprintfmt+0x3c0>
  800538:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	eb e9                	jmp    800529 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800540:	83 f9 01             	cmp    $0x1,%ecx
  800543:	7e 3f                	jle    800584 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 50 04             	mov    0x4(%eax),%edx
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 08             	lea    0x8(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800560:	79 5c                	jns    8005be <vprintfmt+0x2d0>
				putch('-', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	6a 2d                	push   $0x2d
  800568:	ff d6                	call   *%esi
				num = -(long long) num;
  80056a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800570:	f7 da                	neg    %edx
  800572:	83 d1 00             	adc    $0x0,%ecx
  800575:	f7 d9                	neg    %ecx
  800577:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 10 01 00 00       	jmp    800694 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	75 1b                	jne    8005a3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a1:	eb b9                	jmp    80055c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 9e                	jmp    80055c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 c6 00 00 00       	jmp    800694 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ce:	83 f9 01             	cmp    $0x1,%ecx
  8005d1:	7e 18                	jle    8005eb <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005db:	8d 40 08             	lea    0x8(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 a9 00 00 00       	jmp    800694 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005eb:	85 c9                	test   %ecx,%ecx
  8005ed:	75 1a                	jne    800609 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 8b 00 00 00       	jmp    800694 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 74                	jmp    800694 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 15                	jle    80063a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8b 48 04             	mov    0x4(%eax),%ecx
  80062d:	8d 40 08             	lea    0x8(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800633:	b8 08 00 00 00       	mov    $0x8,%eax
  800638:	eb 5a                	jmp    800694 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063a:	85 c9                	test   %ecx,%ecx
  80063c:	75 17                	jne    800655 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80064e:	b8 08 00 00 00       	mov    $0x8,%eax
  800653:	eb 3f                	jmp    800694 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800665:	b8 08 00 00 00       	mov    $0x8,%eax
  80066a:	eb 28                	jmp    800694 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 30                	push   $0x30
  800672:	ff d6                	call   *%esi
			putch('x', putdat);
  800674:	83 c4 08             	add    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 78                	push   $0x78
  80067a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	83 ec 0c             	sub    $0xc,%esp
  800697:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069b:	57                   	push   %edi
  80069c:	ff 75 e0             	pushl  -0x20(%ebp)
  80069f:	50                   	push   %eax
  8006a0:	51                   	push   %ecx
  8006a1:	52                   	push   %edx
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	89 f0                	mov    %esi,%eax
  8006a6:	e8 5d fb ff ff       	call   800208 <printnum>
			break;
  8006ab:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b1:	47                   	inc    %edi
  8006b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b6:	83 f8 25             	cmp    $0x25,%eax
  8006b9:	0f 84 46 fc ff ff    	je     800305 <vprintfmt+0x17>
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 89 00 00 00    	je     800750 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	50                   	push   %eax
  8006cc:	ff d6                	call   *%esi
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb de                	jmp    8006b1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d3:	83 f9 01             	cmp    $0x1,%ecx
  8006d6:	7e 15                	jle    8006ed <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e0:	8d 40 08             	lea    0x8(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006eb:	eb a7                	jmp    800694 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	75 17                	jne    800708 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800701:	b8 10 00 00 00       	mov    $0x10,%eax
  800706:	eb 8c                	jmp    800694 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800718:	b8 10 00 00 00       	mov    $0x10,%eax
  80071d:	e9 72 ff ff ff       	jmp    800694 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 25                	push   $0x25
  800728:	ff d6                	call   *%esi
			break;
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	e9 7c ff ff ff       	jmp    8006ae <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 25                	push   $0x25
  800738:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	89 f8                	mov    %edi,%eax
  80073f:	eb 01                	jmp    800742 <vprintfmt+0x454>
  800741:	48                   	dec    %eax
  800742:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800746:	75 f9                	jne    800741 <vprintfmt+0x453>
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	e9 5e ff ff ff       	jmp    8006ae <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800767:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800775:	85 c0                	test   %eax,%eax
  800777:	74 26                	je     80079f <vsnprintf+0x47>
  800779:	85 d2                	test   %edx,%edx
  80077b:	7e 29                	jle    8007a6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	ff 75 14             	pushl  0x14(%ebp)
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	68 b5 02 80 00       	push   $0x8002b5
  80078c:	e8 5d fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	83 c4 10             	add    $0x10,%esp
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb f7                	jmp    80079d <vsnprintf+0x45>
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb f0                	jmp    80079d <vsnprintf+0x45>

008007ad <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	50                   	push   %eax
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	ff 75 08             	pushl  0x8(%ebp)
  8007c0:	e8 93 ff ff ff       	call   800758 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	41                   	inc    %ecx
  800808:	42                   	inc    %edx
  800809:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80080c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080f:	84 db                	test   %bl,%bl
  800811:	75 f4                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800813:	5b                   	pop    %ebx
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081d:	53                   	push   %ebx
  80081e:	e8 a5 ff ff ff       	call   8007c8 <strlen>
  800823:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	01 d8                	add    %ebx,%eax
  80082b:	50                   	push   %eax
  80082c:	e8 ca ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  800831:	89 d8                	mov    %ebx,%eax
  800833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	89 f3                	mov    %esi,%ebx
  800845:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800848:	89 f2                	mov    %esi,%edx
  80084a:	39 da                	cmp    %ebx,%edx
  80084c:	74 0e                	je     80085c <strncpy+0x24>
		*dst++ = *src;
  80084e:	42                   	inc    %edx
  80084f:	8a 01                	mov    (%ecx),%al
  800851:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800854:	80 39 00             	cmpb   $0x0,(%ecx)
  800857:	74 f1                	je     80084a <strncpy+0x12>
			src++;
  800859:	41                   	inc    %ecx
  80085a:	eb ee                	jmp    80084a <strncpy+0x12>
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 c0                	test   %eax,%eax
  800872:	74 20                	je     800894 <strlcpy+0x32>
  800874:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800878:	89 f0                	mov    %esi,%eax
  80087a:	eb 05                	jmp    800881 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087c:	42                   	inc    %edx
  80087d:	40                   	inc    %eax
  80087e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 06                	je     80088b <strlcpy+0x29>
  800885:	8a 0a                	mov    (%edx),%cl
  800887:	84 c9                	test   %cl,%cl
  800889:	75 f1                	jne    80087c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80088b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088e:	29 f0                	sub    %esi,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    
  800894:	89 f0                	mov    %esi,%eax
  800896:	eb f6                	jmp    80088e <strlcpy+0x2c>

00800898 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a1:	eb 02                	jmp    8008a5 <strcmp+0xd>
		p++, q++;
  8008a3:	41                   	inc    %ecx
  8008a4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a5:	8a 01                	mov    (%ecx),%al
  8008a7:	84 c0                	test   %al,%al
  8008a9:	74 04                	je     8008af <strcmp+0x17>
  8008ab:	3a 02                	cmp    (%edx),%al
  8008ad:	74 f4                	je     8008a3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 c0             	movzbl %al,%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 02                	jmp    8008cc <strncmp+0x13>
		n--, p++, q++;
  8008ca:	40                   	inc    %eax
  8008cb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	39 d8                	cmp    %ebx,%eax
  8008ce:	74 15                	je     8008e5 <strncmp+0x2c>
  8008d0:	8a 08                	mov    (%eax),%cl
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	74 04                	je     8008da <strncmp+0x21>
  8008d6:	3a 0a                	cmp    (%edx),%cl
  8008d8:	74 f0                	je     8008ca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 00             	movzbl (%eax),%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb f6                	jmp    8008e2 <strncmp+0x29>

008008ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f5:	8a 10                	mov    (%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 07                	je     800902 <strchr+0x16>
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 08                	je     800907 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ff:	40                   	inc    %eax
  800900:	eb f3                	jmp    8008f5 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	8a 10                	mov    (%eax),%dl
  800914:	84 d2                	test   %dl,%dl
  800916:	74 07                	je     80091f <strfind+0x16>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 03                	je     80091f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	eb f3                	jmp    800912 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 13                	je     800944 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 05                	jne    80093e <memset+0x1d>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	74 0d                	je     80094b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80094b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d0                	mov    %edx,%eax
  800956:	c1 e0 18             	shl    $0x18,%eax
  800959:	89 d6                	mov    %edx,%esi
  80095b:	c1 e6 10             	shl    $0x10,%esi
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 c2                	or     %eax,%edx
  800962:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800964:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800967:	89 d0                	mov    %edx,%eax
  800969:	fc                   	cld    
  80096a:	f3 ab                	rep stos %eax,%es:(%edi)
  80096c:	eb d6                	jmp    800944 <memset+0x23>

0080096e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	57                   	push   %edi
  800972:	56                   	push   %esi
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 75 0c             	mov    0xc(%ebp),%esi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097c:	39 c6                	cmp    %eax,%esi
  80097e:	73 33                	jae    8009b3 <memmove+0x45>
  800980:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800983:	39 c2                	cmp    %eax,%edx
  800985:	76 2c                	jbe    8009b3 <memmove+0x45>
		s += n;
		d += n;
  800987:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	09 fe                	or     %edi,%esi
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	74 0a                	je     8009a0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800996:	4f                   	dec    %edi
  800997:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099a:	fd                   	std    
  80099b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099d:	fc                   	cld    
  80099e:	eb 21                	jmp    8009c1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 f1                	jne    800996 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a5:	83 ef 04             	sub    $0x4,%edi
  8009a8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ae:	fd                   	std    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb ea                	jmp    80099d <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	09 c2                	or     %eax,%edx
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	74 09                	je     8009c5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 f2                	jne    8009bc <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb ed                	jmp    8009c1 <memmove+0x53>

008009d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d7:	ff 75 10             	pushl  0x10(%ebp)
  8009da:	ff 75 0c             	pushl  0xc(%ebp)
  8009dd:	ff 75 08             	pushl  0x8(%ebp)
  8009e0:	e8 89 ff ff ff       	call   80096e <memmove>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f2:	89 c6                	mov    %eax,%esi
  8009f4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	74 16                	je     800a11 <memcmp+0x2a>
		if (*s1 != *s2)
  8009fb:	8a 08                	mov    (%eax),%cl
  8009fd:	8a 1a                	mov    (%edx),%bl
  8009ff:	38 d9                	cmp    %bl,%cl
  800a01:	75 04                	jne    800a07 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a03:	40                   	inc    %eax
  800a04:	42                   	inc    %edx
  800a05:	eb f0                	jmp    8009f7 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a07:	0f b6 c1             	movzbl %cl,%eax
  800a0a:	0f b6 db             	movzbl %bl,%ebx
  800a0d:	29 d8                	sub    %ebx,%eax
  800a0f:	eb 05                	jmp    800a16 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a23:	89 c2                	mov    %eax,%edx
  800a25:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a28:	39 d0                	cmp    %edx,%eax
  800a2a:	73 07                	jae    800a33 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2c:	38 08                	cmp    %cl,(%eax)
  800a2e:	74 03                	je     800a33 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a30:	40                   	inc    %eax
  800a31:	eb f5                	jmp    800a28 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	eb 01                	jmp    800a41 <strtol+0xc>
		s++;
  800a40:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a41:	8a 01                	mov    (%ecx),%al
  800a43:	3c 20                	cmp    $0x20,%al
  800a45:	74 f9                	je     800a40 <strtol+0xb>
  800a47:	3c 09                	cmp    $0x9,%al
  800a49:	74 f5                	je     800a40 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4b:	3c 2b                	cmp    $0x2b,%al
  800a4d:	74 2b                	je     800a7a <strtol+0x45>
		s++;
	else if (*s == '-')
  800a4f:	3c 2d                	cmp    $0x2d,%al
  800a51:	74 2f                	je     800a82 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a58:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a5f:	75 12                	jne    800a73 <strtol+0x3e>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	74 24                	je     800a8a <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a6a:	75 07                	jne    800a73 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	eb 4e                	jmp    800ac8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a7a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb d6                	jmp    800a58 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a82:	41                   	inc    %ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi
  800a88:	eb ce                	jmp    800a58 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8e:	74 10                	je     800aa0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a94:	75 dd                	jne    800a73 <strtol+0x3e>
		s++, base = 8;
  800a96:	41                   	inc    %ecx
  800a97:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a9e:	eb d3                	jmp    800a73 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800aa0:	83 c1 02             	add    $0x2,%ecx
  800aa3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aaa:	eb c7                	jmp    800a73 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 24                	ja     800ada <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abc:	39 55 10             	cmp    %edx,0x10(%ebp)
  800abf:	7e 2b                	jle    800aec <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ac1:	41                   	inc    %ecx
  800ac2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac8:	8a 11                	mov    (%ecx),%dl
  800aca:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800acd:	80 fb 09             	cmp    $0x9,%bl
  800ad0:	77 da                	ja     800aac <strtol+0x77>
			dig = *s - '0';
  800ad2:	0f be d2             	movsbl %dl,%edx
  800ad5:	83 ea 30             	sub    $0x30,%edx
  800ad8:	eb e2                	jmp    800abc <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 72 bf             	lea    -0x41(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 19             	cmp    $0x19,%bl
  800ae2:	77 08                	ja     800aec <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ae4:	0f be d2             	movsbl %dl,%edx
  800ae7:	83 ea 37             	sub    $0x37,%edx
  800aea:	eb d0                	jmp    800abc <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af0:	74 05                	je     800af7 <strtol+0xc2>
		*endptr = (char *) s;
  800af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af7:	85 ff                	test   %edi,%edi
  800af9:	74 02                	je     800afd <strtol+0xc8>
  800afb:	f7 d8                	neg    %eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    
	...

00800b04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	89 c7                	mov    %eax,%edi
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	b8 03 00 00 00       	mov    $0x3,%eax
  800b57:	89 cb                	mov    %ecx,%ebx
  800b59:	89 cf                	mov    %ecx,%edi
  800b5b:	89 ce                	mov    %ecx,%esi
  800b5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7f 08                	jg     800b6b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	50                   	push   %eax
  800b6f:	6a 03                	push   $0x3
  800b71:	68 a4 12 80 00       	push   $0x8012a4
  800b76:	6a 23                	push   $0x23
  800b78:	68 c1 12 80 00       	push   $0x8012c1
  800b7d:	e8 96 f5 ff ff       	call   800118 <_panic>

00800b82 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_yield>:

void
sys_yield(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	be 00 00 00 00       	mov    $0x0,%esi
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	89 f7                	mov    %esi,%edi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7f 08                	jg     800bec <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 04                	push   $0x4
  800bf2:	68 a4 12 80 00       	push   $0x8012a4
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 c1 12 80 00       	push   $0x8012c1
  800bfe:	e8 15 f5 ff ff       	call   800118 <_panic>

00800c03 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	b8 05 00 00 00       	mov    $0x5,%eax
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7f 08                	jg     800c2e <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 05                	push   $0x5
  800c34:	68 a4 12 80 00       	push   $0x8012a4
  800c39:	6a 23                	push   $0x23
  800c3b:	68 c1 12 80 00       	push   $0x8012c1
  800c40:	e8 d3 f4 ff ff       	call   800118 <_panic>

00800c45 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7f 08                	jg     800c70 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 06                	push   $0x6
  800c76:	68 a4 12 80 00       	push   $0x8012a4
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 c1 12 80 00       	push   $0x8012c1
  800c82:	e8 91 f4 ff ff       	call   800118 <_panic>

00800c87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7f 08                	jg     800cb2 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 08                	push   $0x8
  800cb8:	68 a4 12 80 00       	push   $0x8012a4
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 c1 12 80 00       	push   $0x8012c1
  800cc4:	e8 4f f4 ff ff       	call   800118 <_panic>

00800cc9 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7f 08                	jg     800cf4 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 09                	push   $0x9
  800cfa:	68 a4 12 80 00       	push   $0x8012a4
  800cff:	6a 23                	push   $0x23
  800d01:	68 c1 12 80 00       	push   $0x8012c1
  800d06:	e8 0d f4 ff ff       	call   800118 <_panic>

00800d0b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1c:	be 00 00 00 00       	mov    $0x0,%esi
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d44:	89 cb                	mov    %ecx,%ebx
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	89 ce                	mov    %ecx,%esi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7f 08                	jg     800d58 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 0c                	push   $0xc
  800d5e:	68 a4 12 80 00       	push   $0x8012a4
  800d63:	6a 23                	push   $0x23
  800d65:	68 c1 12 80 00       	push   $0x8012c1
  800d6a:	e8 a9 f3 ff ff       	call   800118 <_panic>
	...

00800d70 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d76:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d7d:	74 0a                	je     800d89 <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	68 d0 12 80 00       	push   $0x8012d0
  800d91:	6a 20                	push   $0x20
  800d93:	68 f4 12 80 00       	push   $0x8012f4
  800d98:	e8 7b f3 ff ff       	call   800118 <_panic>
  800d9d:	00 00                	add    %al,(%eax)
	...

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dab:	8b 74 24 34          	mov    0x34(%esp),%esi
  800daf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800db7:	85 d2                	test   %edx,%edx
  800db9:	75 2d                	jne    800de8 <__udivdi3+0x48>
  800dbb:	39 f7                	cmp    %esi,%edi
  800dbd:	77 59                	ja     800e18 <__udivdi3+0x78>
  800dbf:	89 f9                	mov    %edi,%ecx
  800dc1:	85 ff                	test   %edi,%edi
  800dc3:	75 0b                	jne    800dd0 <__udivdi3+0x30>
  800dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dca:	31 d2                	xor    %edx,%edx
  800dcc:	f7 f7                	div    %edi
  800dce:	89 c1                	mov    %eax,%ecx
  800dd0:	31 d2                	xor    %edx,%edx
  800dd2:	89 f0                	mov    %esi,%eax
  800dd4:	f7 f1                	div    %ecx
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	89 e8                	mov    %ebp,%eax
  800dda:	f7 f1                	div    %ecx
  800ddc:	89 da                	mov    %ebx,%edx
  800dde:	83 c4 1c             	add    $0x1c,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	39 f2                	cmp    %esi,%edx
  800dea:	77 1c                	ja     800e08 <__udivdi3+0x68>
  800dec:	0f bd da             	bsr    %edx,%ebx
  800def:	83 f3 1f             	xor    $0x1f,%ebx
  800df2:	75 38                	jne    800e2c <__udivdi3+0x8c>
  800df4:	39 f2                	cmp    %esi,%edx
  800df6:	72 08                	jb     800e00 <__udivdi3+0x60>
  800df8:	39 ef                	cmp    %ebp,%edi
  800dfa:	0f 87 98 00 00 00    	ja     800e98 <__udivdi3+0xf8>
  800e00:	b8 01 00 00 00       	mov    $0x1,%eax
  800e05:	eb 05                	jmp    800e0c <__udivdi3+0x6c>
  800e07:	90                   	nop
  800e08:	31 db                	xor    %ebx,%ebx
  800e0a:	31 c0                	xor    %eax,%eax
  800e0c:	89 da                	mov    %ebx,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	89 e8                	mov    %ebp,%eax
  800e1a:	89 f2                	mov    %esi,%edx
  800e1c:	f7 f7                	div    %edi
  800e1e:	31 db                	xor    %ebx,%ebx
  800e20:	89 da                	mov    %ebx,%edx
  800e22:	83 c4 1c             	add    $0x1c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	29 d8                	sub    %ebx,%eax
  800e33:	88 d9                	mov    %bl,%cl
  800e35:	d3 e2                	shl    %cl,%edx
  800e37:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e3b:	89 fa                	mov    %edi,%edx
  800e3d:	88 c1                	mov    %al,%cl
  800e3f:	d3 ea                	shr    %cl,%edx
  800e41:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e45:	09 d1                	or     %edx,%ecx
  800e47:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e4b:	88 d9                	mov    %bl,%cl
  800e4d:	d3 e7                	shl    %cl,%edi
  800e4f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e53:	89 f7                	mov    %esi,%edi
  800e55:	88 c1                	mov    %al,%cl
  800e57:	d3 ef                	shr    %cl,%edi
  800e59:	88 d9                	mov    %bl,%cl
  800e5b:	d3 e6                	shl    %cl,%esi
  800e5d:	89 ea                	mov    %ebp,%edx
  800e5f:	88 c1                	mov    %al,%cl
  800e61:	d3 ea                	shr    %cl,%edx
  800e63:	09 d6                	or     %edx,%esi
  800e65:	89 f0                	mov    %esi,%eax
  800e67:	89 fa                	mov    %edi,%edx
  800e69:	f7 74 24 08          	divl   0x8(%esp)
  800e6d:	89 d7                	mov    %edx,%edi
  800e6f:	89 c6                	mov    %eax,%esi
  800e71:	f7 64 24 0c          	mull   0xc(%esp)
  800e75:	39 d7                	cmp    %edx,%edi
  800e77:	72 13                	jb     800e8c <__udivdi3+0xec>
  800e79:	74 09                	je     800e84 <__udivdi3+0xe4>
  800e7b:	89 f0                	mov    %esi,%eax
  800e7d:	31 db                	xor    %ebx,%ebx
  800e7f:	eb 8b                	jmp    800e0c <__udivdi3+0x6c>
  800e81:	8d 76 00             	lea    0x0(%esi),%esi
  800e84:	88 d9                	mov    %bl,%cl
  800e86:	d3 e5                	shl    %cl,%ebp
  800e88:	39 c5                	cmp    %eax,%ebp
  800e8a:	73 ef                	jae    800e7b <__udivdi3+0xdb>
  800e8c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e8f:	31 db                	xor    %ebx,%ebx
  800e91:	e9 76 ff ff ff       	jmp    800e0c <__udivdi3+0x6c>
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	31 c0                	xor    %eax,%eax
  800e9a:	e9 6d ff ff ff       	jmp    800e0c <__udivdi3+0x6c>
	...

00800ea0 <__umoddi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800eab:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800eaf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eb3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	89 da                	mov    %ebx,%edx
  800ebb:	85 ed                	test   %ebp,%ebp
  800ebd:	75 15                	jne    800ed4 <__umoddi3+0x34>
  800ebf:	39 df                	cmp    %ebx,%edi
  800ec1:	76 39                	jbe    800efc <__umoddi3+0x5c>
  800ec3:	f7 f7                	div    %edi
  800ec5:	89 d0                	mov    %edx,%eax
  800ec7:	31 d2                	xor    %edx,%edx
  800ec9:	83 c4 1c             	add    $0x1c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
  800ed1:	8d 76 00             	lea    0x0(%esi),%esi
  800ed4:	39 dd                	cmp    %ebx,%ebp
  800ed6:	77 f1                	ja     800ec9 <__umoddi3+0x29>
  800ed8:	0f bd cd             	bsr    %ebp,%ecx
  800edb:	83 f1 1f             	xor    $0x1f,%ecx
  800ede:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ee2:	75 38                	jne    800f1c <__umoddi3+0x7c>
  800ee4:	39 dd                	cmp    %ebx,%ebp
  800ee6:	72 04                	jb     800eec <__umoddi3+0x4c>
  800ee8:	39 f7                	cmp    %esi,%edi
  800eea:	77 dd                	ja     800ec9 <__umoddi3+0x29>
  800eec:	89 da                	mov    %ebx,%edx
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	29 f8                	sub    %edi,%eax
  800ef2:	19 ea                	sbb    %ebp,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	89 f9                	mov    %edi,%ecx
  800efe:	85 ff                	test   %edi,%edi
  800f00:	75 0b                	jne    800f0d <__umoddi3+0x6d>
  800f02:	b8 01 00 00 00       	mov    $0x1,%eax
  800f07:	31 d2                	xor    %edx,%edx
  800f09:	f7 f7                	div    %edi
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	89 d8                	mov    %ebx,%eax
  800f0f:	31 d2                	xor    %edx,%edx
  800f11:	f7 f1                	div    %ecx
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	eb ac                	jmp    800ec5 <__umoddi3+0x25>
  800f19:	8d 76 00             	lea    0x0(%esi),%esi
  800f1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f21:	89 c2                	mov    %eax,%edx
  800f23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f27:	29 c2                	sub    %eax,%edx
  800f29:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f2d:	88 c1                	mov    %al,%cl
  800f2f:	d3 e5                	shl    %cl,%ebp
  800f31:	89 f8                	mov    %edi,%eax
  800f33:	88 d1                	mov    %dl,%cl
  800f35:	d3 e8                	shr    %cl,%eax
  800f37:	09 c5                	or     %eax,%ebp
  800f39:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f3d:	88 c1                	mov    %al,%cl
  800f3f:	d3 e7                	shl    %cl,%edi
  800f41:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f45:	89 df                	mov    %ebx,%edi
  800f47:	88 d1                	mov    %dl,%cl
  800f49:	d3 ef                	shr    %cl,%edi
  800f4b:	88 c1                	mov    %al,%cl
  800f4d:	d3 e3                	shl    %cl,%ebx
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	88 d1                	mov    %dl,%cl
  800f53:	d3 e8                	shr    %cl,%eax
  800f55:	09 d8                	or     %ebx,%eax
  800f57:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f5b:	d3 e6                	shl    %cl,%esi
  800f5d:	89 fa                	mov    %edi,%edx
  800f5f:	f7 f5                	div    %ebp
  800f61:	89 d1                	mov    %edx,%ecx
  800f63:	f7 64 24 08          	mull   0x8(%esp)
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	89 d7                	mov    %edx,%edi
  800f6b:	39 d1                	cmp    %edx,%ecx
  800f6d:	72 29                	jb     800f98 <__umoddi3+0xf8>
  800f6f:	74 23                	je     800f94 <__umoddi3+0xf4>
  800f71:	89 ca                	mov    %ecx,%edx
  800f73:	29 de                	sub    %ebx,%esi
  800f75:	19 fa                	sbb    %edi,%edx
  800f77:	89 d0                	mov    %edx,%eax
  800f79:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f7d:	d3 e0                	shl    %cl,%eax
  800f7f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f83:	88 d9                	mov    %bl,%cl
  800f85:	d3 ee                	shr    %cl,%esi
  800f87:	09 f0                	or     %esi,%eax
  800f89:	d3 ea                	shr    %cl,%edx
  800f8b:	83 c4 1c             	add    $0x1c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
  800f93:	90                   	nop
  800f94:	39 c6                	cmp    %eax,%esi
  800f96:	73 d9                	jae    800f71 <__umoddi3+0xd1>
  800f98:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f9c:	19 ea                	sbb    %ebp,%edx
  800f9e:	89 d7                	mov    %edx,%edi
  800fa0:	89 c3                	mov    %eax,%ebx
  800fa2:	eb cd                	jmp    800f71 <__umoddi3+0xd1>
