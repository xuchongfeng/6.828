
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6b 00 00 00       	call   80009c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 60 0f 80 00       	push   $0x800f60
  800049:	e8 42 01 00 00       	call   800190 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800051:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800056:	e8 e2 0a 00 00       	call   800b3d <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005b:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	53                   	push   %ebx
  800067:	50                   	push   %eax
  800068:	68 80 0f 80 00       	push   $0x800f80
  80006d:	e8 1e 01 00 00       	call   800190 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800072:	43                   	inc    %ebx
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	83 fb 05             	cmp    $0x5,%ebx
  800079:	75 db                	jne    800056 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007b:	a1 04 20 80 00       	mov    0x802004,%eax
  800080:	8b 40 48             	mov    0x48(%eax),%eax
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	50                   	push   %eax
  800087:	68 ac 0f 80 00       	push   $0x800fac
  80008c:	e8 ff 00 00 00       	call   800190 <cprintf>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a7:	e8 72 0a 00 00       	call   800b1e <sys_getenvid>
  8000ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b1:	89 c2                	mov    %eax,%edx
  8000b3:	c1 e2 05             	shl    $0x5,%edx
  8000b6:	29 c2                	sub    %eax,%edx
  8000b8:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000bf:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c4:	85 db                	test   %ebx,%ebx
  8000c6:	7e 07                	jle    8000cf <libmain+0x33>
		binaryname = argv[0];
  8000c8:	8b 06                	mov    (%esi),%eax
  8000ca:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	e8 5b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 e8 09 00 00       	call   800add <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    
	...

008000fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800106:	8b 13                	mov    (%ebx),%edx
  800108:	8d 42 01             	lea    0x1(%edx),%eax
  80010b:	89 03                	mov    %eax,(%ebx)
  80010d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800110:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800114:	3d ff 00 00 00       	cmp    $0xff,%eax
  800119:	74 08                	je     800123 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011b:	ff 43 04             	incl   0x4(%ebx)
}
  80011e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800121:	c9                   	leave  
  800122:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800123:	83 ec 08             	sub    $0x8,%esp
  800126:	68 ff 00 00 00       	push   $0xff
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 6c 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	eb dc                	jmp    80011b <putch+0x1f>

0080013f <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014f:	00 00 00 
	b.cnt = 0;
  800152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	50                   	push   %eax
  800169:	68 fc 00 80 00       	push   $0x8000fc
  80016e:	e8 17 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 18 09 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 9d ff ff ff       	call   80013f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 1c             	sub    $0x1c,%esp
  8001ad:	89 c7                	mov    %eax,%edi
  8001af:	89 d6                	mov    %edx,%esi
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cb:	39 d3                	cmp    %edx,%ebx
  8001cd:	72 05                	jb     8001d4 <printnum+0x30>
  8001cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d2:	77 78                	ja     80024c <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	8b 45 14             	mov    0x14(%ebp),%eax
  8001dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e0:	53                   	push   %ebx
  8001e1:	ff 75 10             	pushl  0x10(%ebp)
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f3:	e8 5c 0b 00 00       	call   800d54 <__udivdi3>
  8001f8:	83 c4 18             	add    $0x18,%esp
  8001fb:	52                   	push   %edx
  8001fc:	50                   	push   %eax
  8001fd:	89 f2                	mov    %esi,%edx
  8001ff:	89 f8                	mov    %edi,%eax
  800201:	e8 9e ff ff ff       	call   8001a4 <printnum>
  800206:	83 c4 20             	add    $0x20,%esp
  800209:	eb 11                	jmp    80021c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	56                   	push   %esi
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	ff d7                	call   *%edi
  800214:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800217:	4b                   	dec    %ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f ef                	jg     80020b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 20 0c 00 00       	call   800e54 <__umoddi3>
  800234:	83 c4 14             	add    $0x14,%esp
  800237:	0f be 80 d5 0f 80 00 	movsbl 0x800fd5(%eax),%eax
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
  80024c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80024f:	eb c6                	jmp    800217 <printnum+0x73>

00800251 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800257:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1a>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	e9 ac 03 00 00       	jmp    80064d <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8002a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8002a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8002ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8002b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8002ba:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002bf:	8d 47 01             	lea    0x1(%edi),%eax
  8002c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c5:	8a 17                	mov    (%edi),%dl
  8002c7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ca:	3c 55                	cmp    $0x55,%al
  8002cc:	0f 87 fc 03 00 00    	ja     8006ce <vprintfmt+0x444>
  8002d2:	0f b6 c0             	movzbl %al,%eax
  8002d5:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002e3:	eb da                	jmp    8002bf <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ec:	eb d1                	jmp    8002bf <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	0f b6 d2             	movzbl %dl,%edx
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ff:	01 c0                	add    %eax,%eax
  800301:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 52                	ja     800362 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800311:	eb e9                	jmp    8002fc <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800313:	8b 45 14             	mov    0x14(%ebp),%eax
  800316:	8b 00                	mov    (%eax),%eax
  800318:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031b:	8b 45 14             	mov    0x14(%ebp),%eax
  80031e:	8d 40 04             	lea    0x4(%eax),%eax
  800321:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800327:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032b:	79 92                	jns    8002bf <vprintfmt+0x35>
				width = precision, precision = -1;
  80032d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033a:	eb 83                	jmp    8002bf <vprintfmt+0x35>
  80033c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800340:	78 08                	js     80034a <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	e9 75 ff ff ff       	jmp    8002bf <vprintfmt+0x35>
  80034a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800351:	eb ef                	jmp    800342 <vprintfmt+0xb8>
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800356:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035d:	e9 5d ff ff ff       	jmp    8002bf <vprintfmt+0x35>
  800362:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800365:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800368:	eb bd                	jmp    800327 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036a:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80036e:	e9 4c ff ff ff       	jmp    8002bf <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 78 04             	lea    0x4(%eax),%edi
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	ff 30                	pushl  (%eax)
  80037f:	ff d6                	call   *%esi
			break;
  800381:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800384:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800387:	e9 be 02 00 00       	jmp    80064a <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 78 04             	lea    0x4(%eax),%edi
  800392:	8b 00                	mov    (%eax),%eax
  800394:	85 c0                	test   %eax,%eax
  800396:	78 2a                	js     8003c2 <vprintfmt+0x138>
  800398:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039a:	83 f8 08             	cmp    $0x8,%eax
  80039d:	7f 27                	jg     8003c6 <vprintfmt+0x13c>
  80039f:	8b 04 85 00 12 80 00 	mov    0x801200(,%eax,4),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	74 1c                	je     8003c6 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003aa:	50                   	push   %eax
  8003ab:	68 f6 0f 80 00       	push   $0x800ff6
  8003b0:	53                   	push   %ebx
  8003b1:	56                   	push   %esi
  8003b2:	e8 b6 fe ff ff       	call   80026d <printfmt>
  8003b7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003bd:	e9 88 02 00 00       	jmp    80064a <vprintfmt+0x3c0>
  8003c2:	f7 d8                	neg    %eax
  8003c4:	eb d2                	jmp    800398 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c6:	52                   	push   %edx
  8003c7:	68 ed 0f 80 00       	push   $0x800fed
  8003cc:	53                   	push   %ebx
  8003cd:	56                   	push   %esi
  8003ce:	e8 9a fe ff ff       	call   80026d <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d9:	e9 6c 02 00 00       	jmp    80064a <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	83 c0 04             	add    $0x4,%eax
  8003e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8b 38                	mov    (%eax),%edi
  8003ec:	85 ff                	test   %edi,%edi
  8003ee:	74 18                	je     800408 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f4:	0f 8e b7 00 00 00    	jle    8004b1 <vprintfmt+0x227>
  8003fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003fe:	75 0f                	jne    80040f <vprintfmt+0x185>
  800400:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800403:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800406:	eb 75                	jmp    80047d <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800408:	bf e6 0f 80 00       	mov    $0x800fe6,%edi
  80040d:	eb e1                	jmp    8003f0 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	ff 75 d0             	pushl  -0x30(%ebp)
  800415:	57                   	push   %edi
  800416:	e8 5f 03 00 00       	call   80077a <strnlen>
  80041b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041e:	29 c1                	sub    %eax,%ecx
  800420:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800423:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800426:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800430:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	eb 0d                	jmp    800441 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	4f                   	dec    %edi
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	85 ff                	test   %edi,%edi
  800443:	7f ef                	jg     800434 <vprintfmt+0x1aa>
  800445:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800448:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80044b:	89 c8                	mov    %ecx,%eax
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	78 10                	js     800461 <vprintfmt+0x1d7>
  800451:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800459:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80045c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80045f:	eb 1c                	jmp    80047d <vprintfmt+0x1f3>
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb e9                	jmp    800451 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800468:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046c:	75 29                	jne    800497 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	ff 75 0c             	pushl  0xc(%ebp)
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047a:	ff 4d e0             	decl   -0x20(%ebp)
  80047d:	47                   	inc    %edi
  80047e:	8a 57 ff             	mov    -0x1(%edi),%dl
  800481:	0f be c2             	movsbl %dl,%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	74 4c                	je     8004d4 <vprintfmt+0x24a>
  800488:	85 db                	test   %ebx,%ebx
  80048a:	78 dc                	js     800468 <vprintfmt+0x1de>
  80048c:	4b                   	dec    %ebx
  80048d:	79 d9                	jns    800468 <vprintfmt+0x1de>
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800492:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800495:	eb 2e                	jmp    8004c5 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800497:	0f be d2             	movsbl %dl,%edx
  80049a:	83 ea 20             	sub    $0x20,%edx
  80049d:	83 fa 5e             	cmp    $0x5e,%edx
  8004a0:	76 cc                	jbe    80046e <vprintfmt+0x1e4>
					putch('?', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	6a 3f                	push   $0x3f
  8004aa:	ff d6                	call   *%esi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	eb c9                	jmp    80047a <vprintfmt+0x1f0>
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004b7:	eb c4                	jmp    80047d <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	6a 20                	push   $0x20
  8004bf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c1:	4f                   	dec    %edi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	7f f0                	jg     8004b9 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cf:	e9 76 01 00 00       	jmp    80064a <vprintfmt+0x3c0>
  8004d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	eb e9                	jmp    8004c5 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004dc:	83 f9 01             	cmp    $0x1,%ecx
  8004df:	7e 3f                	jle    800520 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8b 50 04             	mov    0x4(%eax),%edx
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 40 08             	lea    0x8(%eax),%eax
  8004f5:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8004f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fc:	79 5c                	jns    80055a <vprintfmt+0x2d0>
				putch('-', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	6a 2d                	push   $0x2d
  800504:	ff d6                	call   *%esi
				num = -(long long) num;
  800506:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800509:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050c:	f7 da                	neg    %edx
  80050e:	83 d1 00             	adc    $0x0,%ecx
  800511:	f7 d9                	neg    %ecx
  800513:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800516:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051b:	e9 10 01 00 00       	jmp    800630 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800520:	85 c9                	test   %ecx,%ecx
  800522:	75 1b                	jne    80053f <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052c:	89 c1                	mov    %eax,%ecx
  80052e:	c1 f9 1f             	sar    $0x1f,%ecx
  800531:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 40 04             	lea    0x4(%eax),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	eb b9                	jmp    8004f8 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800547:	89 c1                	mov    %eax,%ecx
  800549:	c1 f9 1f             	sar    $0x1f,%ecx
  80054c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 04             	lea    0x4(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
  800558:	eb 9e                	jmp    8004f8 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800560:	b8 0a 00 00 00       	mov    $0xa,%eax
  800565:	e9 c6 00 00 00       	jmp    800630 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056a:	83 f9 01             	cmp    $0x1,%ecx
  80056d:	7e 18                	jle    800587 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 10                	mov    (%eax),%edx
  800574:	8b 48 04             	mov    0x4(%eax),%ecx
  800577:	8d 40 08             	lea    0x8(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800582:	e9 a9 00 00 00       	jmp    800630 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800587:	85 c9                	test   %ecx,%ecx
  800589:	75 1a                	jne    8005a5 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	b9 00 00 00 00       	mov    $0x0,%ecx
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 8b 00 00 00       	jmp    800630 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ba:	eb 74                	jmp    800630 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bc:	83 f9 01             	cmp    $0x1,%ecx
  8005bf:	7e 15                	jle    8005d6 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c9:	8d 40 08             	lea    0x8(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d4:	eb 5a                	jmp    800630 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d6:	85 c9                	test   %ecx,%ecx
  8005d8:	75 17                	jne    8005f1 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ef:	eb 3f                	jmp    800630 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
  800606:	eb 28                	jmp    800630 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 30                	push   $0x30
  80060e:	ff d6                	call   *%esi
			putch('x', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 78                	push   $0x78
  800616:	ff d6                	call   *%esi
			num = (unsigned long long)
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800622:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800630:	83 ec 0c             	sub    $0xc,%esp
  800633:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800637:	57                   	push   %edi
  800638:	ff 75 e0             	pushl  -0x20(%ebp)
  80063b:	50                   	push   %eax
  80063c:	51                   	push   %ecx
  80063d:	52                   	push   %edx
  80063e:	89 da                	mov    %ebx,%edx
  800640:	89 f0                	mov    %esi,%eax
  800642:	e8 5d fb ff ff       	call   8001a4 <printnum>
			break;
  800647:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064d:	47                   	inc    %edi
  80064e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800652:	83 f8 25             	cmp    $0x25,%eax
  800655:	0f 84 46 fc ff ff    	je     8002a1 <vprintfmt+0x17>
			if (ch == '\0')
  80065b:	85 c0                	test   %eax,%eax
  80065d:	0f 84 89 00 00 00    	je     8006ec <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	50                   	push   %eax
  800668:	ff d6                	call   *%esi
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb de                	jmp    80064d <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 f9 01             	cmp    $0x1,%ecx
  800672:	7e 15                	jle    800689 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	8b 48 04             	mov    0x4(%eax),%ecx
  80067c:	8d 40 08             	lea    0x8(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
  800687:	eb a7                	jmp    800630 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800689:	85 c9                	test   %ecx,%ecx
  80068b:	75 17                	jne    8006a4 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069d:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a2:	eb 8c                	jmp    800630 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b9:	e9 72 ff ff ff       	jmp    800630 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 25                	push   $0x25
  8006c4:	ff d6                	call   *%esi
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	e9 7c ff ff ff       	jmp    80064a <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 25                	push   $0x25
  8006d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	89 f8                	mov    %edi,%eax
  8006db:	eb 01                	jmp    8006de <vprintfmt+0x454>
  8006dd:	48                   	dec    %eax
  8006de:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e2:	75 f9                	jne    8006dd <vprintfmt+0x453>
  8006e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e7:	e9 5e ff ff ff       	jmp    80064a <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 18             	sub    $0x18,%esp
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800700:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800703:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800707:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800711:	85 c0                	test   %eax,%eax
  800713:	74 26                	je     80073b <vsnprintf+0x47>
  800715:	85 d2                	test   %edx,%edx
  800717:	7e 29                	jle    800742 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800719:	ff 75 14             	pushl  0x14(%ebp)
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	68 51 02 80 00       	push   $0x800251
  800728:	e8 5d fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800730:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800736:	83 c4 10             	add    $0x10,%esp
}
  800739:	c9                   	leave  
  80073a:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800740:	eb f7                	jmp    800739 <vsnprintf+0x45>
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb f0                	jmp    800739 <vsnprintf+0x45>

00800749 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	50                   	push   %eax
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	ff 75 08             	pushl  0x8(%ebp)
  80075c:	e8 93 ff ff ff       	call   8006f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    
	...

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 01                	jmp    800772 <strlen+0xe>
		n++;
  800771:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800776:	75 f9                	jne    800771 <strlen+0xd>
		n++;
	return n;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 01                	jmp    80078b <strnlen+0x11>
		n++;
  80078a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1b>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	75 f5                	jne    80078a <strnlen+0x10>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	41                   	inc    %ecx
  8007a4:	42                   	inc    %edx
  8007a5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 f4                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007af:	5b                   	pop    %ebx
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b9:	53                   	push   %ebx
  8007ba:	e8 a5 ff ff ff       	call   800764 <strlen>
  8007bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	01 d8                	add    %ebx,%eax
  8007c7:	50                   	push   %eax
  8007c8:	e8 ca ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	89 f3                	mov    %esi,%ebx
  8007e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	39 da                	cmp    %ebx,%edx
  8007e8:	74 0e                	je     8007f8 <strncpy+0x24>
		*dst++ = *src;
  8007ea:	42                   	inc    %edx
  8007eb:	8a 01                	mov    (%ecx),%al
  8007ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007f0:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f3:	74 f1                	je     8007e6 <strncpy+0x12>
			src++;
  8007f5:	41                   	inc    %ecx
  8007f6:	eb ee                	jmp    8007e6 <strncpy+0x12>
	}
	return ret;
}
  8007f8:	89 f0                	mov    %esi,%eax
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 20                	je     800830 <strlcpy+0x32>
  800810:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800814:	89 f0                	mov    %esi,%eax
  800816:	eb 05                	jmp    80081d <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800818:	42                   	inc    %edx
  800819:	40                   	inc    %eax
  80081a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 06                	je     800827 <strlcpy+0x29>
  800821:	8a 0a                	mov    (%edx),%cl
  800823:	84 c9                	test   %cl,%cl
  800825:	75 f1                	jne    800818 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800827:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082a:	29 f0                	sub    %esi,%eax
}
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    
  800830:	89 f0                	mov    %esi,%eax
  800832:	eb f6                	jmp    80082a <strlcpy+0x2c>

00800834 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083d:	eb 02                	jmp    800841 <strcmp+0xd>
		p++, q++;
  80083f:	41                   	inc    %ecx
  800840:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800841:	8a 01                	mov    (%ecx),%al
  800843:	84 c0                	test   %al,%al
  800845:	74 04                	je     80084b <strcmp+0x17>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	74 f4                	je     80083f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 02                	jmp    800868 <strncmp+0x13>
		n--, p++, q++;
  800866:	40                   	inc    %eax
  800867:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800868:	39 d8                	cmp    %ebx,%eax
  80086a:	74 15                	je     800881 <strncmp+0x2c>
  80086c:	8a 08                	mov    (%eax),%cl
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x21>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 f0                	je     800866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb f6                	jmp    80087e <strncmp+0x29>

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800891:	8a 10                	mov    (%eax),%dl
  800893:	84 d2                	test   %dl,%dl
  800895:	74 07                	je     80089e <strchr+0x16>
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 08                	je     8008a3 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089b:	40                   	inc    %eax
  80089c:	eb f3                	jmp    800891 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ae:	8a 10                	mov    (%eax),%dl
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 07                	je     8008bb <strfind+0x16>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 03                	je     8008bb <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b8:	40                   	inc    %eax
  8008b9:	eb f3                	jmp    8008ae <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 13                	je     8008e0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 05                	jne    8008da <memset+0x1d>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	74 0d                	je     8008e7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	fc                   	cld    
  8008de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8008e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008eb:	89 d3                	mov    %edx,%ebx
  8008ed:	c1 e3 08             	shl    $0x8,%ebx
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 18             	shl    $0x18,%eax
  8008f5:	89 d6                	mov    %edx,%esi
  8008f7:	c1 e6 10             	shl    $0x10,%esi
  8008fa:	09 f0                	or     %esi,%eax
  8008fc:	09 c2                	or     %eax,%edx
  8008fe:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800900:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800903:	89 d0                	mov    %edx,%eax
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb d6                	jmp    8008e0 <memset+0x23>

0080090a <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 75 0c             	mov    0xc(%ebp),%esi
  800915:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800918:	39 c6                	cmp    %eax,%esi
  80091a:	73 33                	jae    80094f <memmove+0x45>
  80091c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091f:	39 c2                	cmp    %eax,%edx
  800921:	76 2c                	jbe    80094f <memmove+0x45>
		s += n;
		d += n;
  800923:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800926:	89 d6                	mov    %edx,%esi
  800928:	09 fe                	or     %edi,%esi
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	74 0a                	je     80093c <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800932:	4f                   	dec    %edi
  800933:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800936:	fd                   	std    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800939:	fc                   	cld    
  80093a:	eb 21                	jmp    80095d <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 f1                	jne    800932 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb ea                	jmp    800939 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 f2                	mov    %esi,%edx
  800951:	09 c2                	or     %eax,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	74 09                	je     800961 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 f2                	jne    800958 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800966:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800969:	89 c7                	mov    %eax,%edi
  80096b:	fc                   	cld    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb ed                	jmp    80095d <memmove+0x53>

00800970 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 89 ff ff ff       	call   80090a <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 f0                	cmp    %esi,%eax
  800995:	74 16                	je     8009ad <memcmp+0x2a>
		if (*s1 != *s2)
  800997:	8a 08                	mov    (%eax),%cl
  800999:	8a 1a                	mov    (%edx),%bl
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	75 04                	jne    8009a3 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099f:	40                   	inc    %eax
  8009a0:	42                   	inc    %edx
  8009a1:	eb f0                	jmp    800993 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  8009a3:	0f b6 c1             	movzbl %cl,%eax
  8009a6:	0f b6 db             	movzbl %bl,%ebx
  8009a9:	29 d8                	sub    %ebx,%eax
  8009ab:	eb 05                	jmp    8009b2 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 07                	jae    8009cf <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	38 08                	cmp    %cl,(%eax)
  8009ca:	74 03                	je     8009cf <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	40                   	inc    %eax
  8009cd:	eb f5                	jmp    8009c4 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009da:	eb 01                	jmp    8009dd <strtol+0xc>
		s++;
  8009dc:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	8a 01                	mov    (%ecx),%al
  8009df:	3c 20                	cmp    $0x20,%al
  8009e1:	74 f9                	je     8009dc <strtol+0xb>
  8009e3:	3c 09                	cmp    $0x9,%al
  8009e5:	74 f5                	je     8009dc <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e7:	3c 2b                	cmp    $0x2b,%al
  8009e9:	74 2b                	je     800a16 <strtol+0x45>
		s++;
	else if (*s == '-')
  8009eb:	3c 2d                	cmp    $0x2d,%al
  8009ed:	74 2f                	je     800a1e <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  8009fb:	75 12                	jne    800a0f <strtol+0x3e>
  8009fd:	80 39 30             	cmpb   $0x30,(%ecx)
  800a00:	74 24                	je     800a26 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a06:	75 07                	jne    800a0f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a08:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	eb 4e                	jmp    800a64 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a16:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1c:	eb d6                	jmp    8009f4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a1e:	41                   	inc    %ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a24:	eb ce                	jmp    8009f4 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2a:	74 10                	je     800a3c <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a30:	75 dd                	jne    800a0f <strtol+0x3e>
		s++, base = 8;
  800a32:	41                   	inc    %ecx
  800a33:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a3a:	eb d3                	jmp    800a0f <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a46:	eb c7                	jmp    800a0f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4b:	89 f3                	mov    %esi,%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 24                	ja     800a76 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a52:	0f be d2             	movsbl %dl,%edx
  800a55:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a58:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a5b:	7e 2b                	jle    800a88 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a5d:	41                   	inc    %ecx
  800a5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a62:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	8a 11                	mov    (%ecx),%dl
  800a66:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a69:	80 fb 09             	cmp    $0x9,%bl
  800a6c:	77 da                	ja     800a48 <strtol+0x77>
			dig = *s - '0';
  800a6e:	0f be d2             	movsbl %dl,%edx
  800a71:	83 ea 30             	sub    $0x30,%edx
  800a74:	eb e2                	jmp    800a58 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 19             	cmp    $0x19,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 37             	sub    $0x37,%edx
  800a86:	eb d0                	jmp    800a58 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8c:	74 05                	je     800a93 <strtol+0xc2>
		*endptr = (char *) s;
  800a8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a91:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a93:	85 ff                	test   %edi,%edi
  800a95:	74 02                	je     800a99 <strtol+0xc8>
  800a97:	f7 d8                	neg    %eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    
	...

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 55 08             	mov    0x8(%ebp),%edx
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	b8 03 00 00 00       	mov    $0x3,%eax
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7f 08                	jg     800b07 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 03                	push   $0x3
  800b0d:	68 24 12 80 00       	push   $0x801224
  800b12:	6a 23                	push   $0x23
  800b14:	68 41 12 80 00       	push   $0x801241
  800b19:	e8 ee 01 00 00       	call   800d0c <_panic>

00800b1e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	b8 04 00 00 00       	mov    $0x4,%eax
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7f 08                	jg     800b88 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 04                	push   $0x4
  800b8e:	68 24 12 80 00       	push   $0x801224
  800b93:	6a 23                	push   $0x23
  800b95:	68 41 12 80 00       	push   $0x801241
  800b9a:	e8 6d 01 00 00       	call   800d0c <_panic>

00800b9f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7f 08                	jg     800bca <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 05                	push   $0x5
  800bd0:	68 24 12 80 00       	push   $0x801224
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 41 12 80 00       	push   $0x801241
  800bdc:	e8 2b 01 00 00       	call   800d0c <_panic>

00800be1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7f 08                	jg     800c0c <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 06                	push   $0x6
  800c12:	68 24 12 80 00       	push   $0x801224
  800c17:	6a 23                	push   $0x23
  800c19:	68 41 12 80 00       	push   $0x801241
  800c1e:	e8 e9 00 00 00       	call   800d0c <_panic>

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7f 08                	jg     800c4e <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 08                	push   $0x8
  800c54:	68 24 12 80 00       	push   $0x801224
  800c59:	6a 23                	push   $0x23
  800c5b:	68 41 12 80 00       	push   $0x801241
  800c60:	e8 a7 00 00 00       	call   800d0c <_panic>

00800c65 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7f 08                	jg     800c90 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 09                	push   $0x9
  800c96:	68 24 12 80 00       	push   $0x801224
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 41 12 80 00       	push   $0x801241
  800ca2:	e8 65 00 00 00       	call   800d0c <_panic>

00800ca7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb8:	be 00 00 00 00       	mov    $0x0,%esi
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce0:	89 cb                	mov    %ecx,%ebx
  800ce2:	89 cf                	mov    %ecx,%edi
  800ce4:	89 ce                	mov    %ecx,%esi
  800ce6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7f 08                	jg     800cf4 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800cf8:	6a 0c                	push   $0xc
  800cfa:	68 24 12 80 00       	push   $0x801224
  800cff:	6a 23                	push   $0x23
  800d01:	68 41 12 80 00       	push   $0x801241
  800d06:	e8 01 00 00 00       	call   800d0c <_panic>
	...

00800d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d14:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d1a:	e8 ff fd ff ff       	call   800b1e <sys_getenvid>
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	ff 75 08             	pushl  0x8(%ebp)
  800d28:	56                   	push   %esi
  800d29:	50                   	push   %eax
  800d2a:	68 50 12 80 00       	push   $0x801250
  800d2f:	e8 5c f4 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d34:	83 c4 18             	add    $0x18,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 75 10             	pushl  0x10(%ebp)
  800d3b:	e8 ff f3 ff ff       	call   80013f <vcprintf>
	cprintf("\n");
  800d40:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d47:	e8 44 f4 ff ff       	call   800190 <cprintf>
  800d4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d4f:	cc                   	int3   
  800d50:	eb fd                	jmp    800d4f <_panic+0x43>
	...

00800d54 <__udivdi3>:
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
  800d5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d6b:	85 d2                	test   %edx,%edx
  800d6d:	75 2d                	jne    800d9c <__udivdi3+0x48>
  800d6f:	39 f7                	cmp    %esi,%edi
  800d71:	77 59                	ja     800dcc <__udivdi3+0x78>
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	85 ff                	test   %edi,%edi
  800d77:	75 0b                	jne    800d84 <__udivdi3+0x30>
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f7                	div    %edi
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	31 d2                	xor    %edx,%edx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 e8                	mov    %ebp,%eax
  800d8e:	f7 f1                	div    %ecx
  800d90:	89 da                	mov    %ebx,%edx
  800d92:	83 c4 1c             	add    $0x1c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	39 f2                	cmp    %esi,%edx
  800d9e:	77 1c                	ja     800dbc <__udivdi3+0x68>
  800da0:	0f bd da             	bsr    %edx,%ebx
  800da3:	83 f3 1f             	xor    $0x1f,%ebx
  800da6:	75 38                	jne    800de0 <__udivdi3+0x8c>
  800da8:	39 f2                	cmp    %esi,%edx
  800daa:	72 08                	jb     800db4 <__udivdi3+0x60>
  800dac:	39 ef                	cmp    %ebp,%edi
  800dae:	0f 87 98 00 00 00    	ja     800e4c <__udivdi3+0xf8>
  800db4:	b8 01 00 00 00       	mov    $0x1,%eax
  800db9:	eb 05                	jmp    800dc0 <__udivdi3+0x6c>
  800dbb:	90                   	nop
  800dbc:	31 db                	xor    %ebx,%ebx
  800dbe:	31 c0                	xor    %eax,%eax
  800dc0:	89 da                	mov    %ebx,%edx
  800dc2:	83 c4 1c             	add    $0x1c,%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	89 e8                	mov    %ebp,%eax
  800dce:	89 f2                	mov    %esi,%edx
  800dd0:	f7 f7                	div    %edi
  800dd2:	31 db                	xor    %ebx,%ebx
  800dd4:	89 da                	mov    %ebx,%edx
  800dd6:	83 c4 1c             	add    $0x1c,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax
  800de0:	b8 20 00 00 00       	mov    $0x20,%eax
  800de5:	29 d8                	sub    %ebx,%eax
  800de7:	88 d9                	mov    %bl,%cl
  800de9:	d3 e2                	shl    %cl,%edx
  800deb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800def:	89 fa                	mov    %edi,%edx
  800df1:	88 c1                	mov    %al,%cl
  800df3:	d3 ea                	shr    %cl,%edx
  800df5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800df9:	09 d1                	or     %edx,%ecx
  800dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dff:	88 d9                	mov    %bl,%cl
  800e01:	d3 e7                	shl    %cl,%edi
  800e03:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e07:	89 f7                	mov    %esi,%edi
  800e09:	88 c1                	mov    %al,%cl
  800e0b:	d3 ef                	shr    %cl,%edi
  800e0d:	88 d9                	mov    %bl,%cl
  800e0f:	d3 e6                	shl    %cl,%esi
  800e11:	89 ea                	mov    %ebp,%edx
  800e13:	88 c1                	mov    %al,%cl
  800e15:	d3 ea                	shr    %cl,%edx
  800e17:	09 d6                	or     %edx,%esi
  800e19:	89 f0                	mov    %esi,%eax
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	f7 74 24 08          	divl   0x8(%esp)
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 c6                	mov    %eax,%esi
  800e25:	f7 64 24 0c          	mull   0xc(%esp)
  800e29:	39 d7                	cmp    %edx,%edi
  800e2b:	72 13                	jb     800e40 <__udivdi3+0xec>
  800e2d:	74 09                	je     800e38 <__udivdi3+0xe4>
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	31 db                	xor    %ebx,%ebx
  800e33:	eb 8b                	jmp    800dc0 <__udivdi3+0x6c>
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	88 d9                	mov    %bl,%cl
  800e3a:	d3 e5                	shl    %cl,%ebp
  800e3c:	39 c5                	cmp    %eax,%ebp
  800e3e:	73 ef                	jae    800e2f <__udivdi3+0xdb>
  800e40:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e43:	31 db                	xor    %ebx,%ebx
  800e45:	e9 76 ff ff ff       	jmp    800dc0 <__udivdi3+0x6c>
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	e9 6d ff ff ff       	jmp    800dc0 <__udivdi3+0x6c>
	...

00800e54 <__umoddi3>:
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 1c             	sub    $0x1c,%esp
  800e5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	89 da                	mov    %ebx,%edx
  800e6f:	85 ed                	test   %ebp,%ebp
  800e71:	75 15                	jne    800e88 <__umoddi3+0x34>
  800e73:	39 df                	cmp    %ebx,%edi
  800e75:	76 39                	jbe    800eb0 <__umoddi3+0x5c>
  800e77:	f7 f7                	div    %edi
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 dd                	cmp    %ebx,%ebp
  800e8a:	77 f1                	ja     800e7d <__umoddi3+0x29>
  800e8c:	0f bd cd             	bsr    %ebp,%ecx
  800e8f:	83 f1 1f             	xor    $0x1f,%ecx
  800e92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e96:	75 38                	jne    800ed0 <__umoddi3+0x7c>
  800e98:	39 dd                	cmp    %ebx,%ebp
  800e9a:	72 04                	jb     800ea0 <__umoddi3+0x4c>
  800e9c:	39 f7                	cmp    %esi,%edi
  800e9e:	77 dd                	ja     800e7d <__umoddi3+0x29>
  800ea0:	89 da                	mov    %ebx,%edx
  800ea2:	89 f0                	mov    %esi,%eax
  800ea4:	29 f8                	sub    %edi,%eax
  800ea6:	19 ea                	sbb    %ebp,%edx
  800ea8:	83 c4 1c             	add    $0x1c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	85 ff                	test   %edi,%edi
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x6d>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 f0                	mov    %esi,%eax
  800ec9:	f7 f1                	div    %ecx
  800ecb:	eb ac                	jmp    800e79 <__umoddi3+0x25>
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edb:	29 c2                	sub    %eax,%edx
  800edd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee1:	88 c1                	mov    %al,%cl
  800ee3:	d3 e5                	shl    %cl,%ebp
  800ee5:	89 f8                	mov    %edi,%eax
  800ee7:	88 d1                	mov    %dl,%cl
  800ee9:	d3 e8                	shr    %cl,%eax
  800eeb:	09 c5                	or     %eax,%ebp
  800eed:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ef1:	88 c1                	mov    %al,%cl
  800ef3:	d3 e7                	shl    %cl,%edi
  800ef5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	88 d1                	mov    %dl,%cl
  800efd:	d3 ef                	shr    %cl,%edi
  800eff:	88 c1                	mov    %al,%cl
  800f01:	d3 e3                	shl    %cl,%ebx
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	88 d1                	mov    %dl,%cl
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	09 d8                	or     %ebx,%eax
  800f0b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f0f:	d3 e6                	shl    %cl,%esi
  800f11:	89 fa                	mov    %edi,%edx
  800f13:	f7 f5                	div    %ebp
  800f15:	89 d1                	mov    %edx,%ecx
  800f17:	f7 64 24 08          	mull   0x8(%esp)
  800f1b:	89 c3                	mov    %eax,%ebx
  800f1d:	89 d7                	mov    %edx,%edi
  800f1f:	39 d1                	cmp    %edx,%ecx
  800f21:	72 29                	jb     800f4c <__umoddi3+0xf8>
  800f23:	74 23                	je     800f48 <__umoddi3+0xf4>
  800f25:	89 ca                	mov    %ecx,%edx
  800f27:	29 de                	sub    %ebx,%esi
  800f29:	19 fa                	sbb    %edi,%edx
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f37:	88 d9                	mov    %bl,%cl
  800f39:	d3 ee                	shr    %cl,%esi
  800f3b:	09 f0                	or     %esi,%eax
  800f3d:	d3 ea                	shr    %cl,%edx
  800f3f:	83 c4 1c             	add    $0x1c,%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    
  800f47:	90                   	nop
  800f48:	39 c6                	cmp    %eax,%esi
  800f4a:	73 d9                	jae    800f25 <__umoddi3+0xd1>
  800f4c:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f50:	19 ea                	sbb    %ebp,%edx
  800f52:	89 d7                	mov    %edx,%edi
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	eb cd                	jmp    800f25 <__umoddi3+0xd1>
