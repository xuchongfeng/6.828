
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 53 00 00 00       	call   800084 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 42 04             	mov    0x4(%edx),%eax
  800040:	83 e0 07             	and    $0x7,%eax
  800043:	50                   	push   %eax
  800044:	ff 32                	pushl  (%edx)
  800046:	68 80 0f 80 00       	push   $0x800f80
  80004b:	e8 28 01 00 00       	call   800178 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 b1 0a 00 00       	call   800b06 <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 68 0a 00 00       	call   800ac5 <sys_env_destroy>
}
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <umain>:

void
umain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800068:	68 34 00 80 00       	push   $0x800034
  80006d:	e8 82 0c 00 00       	call   800cf4 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800072:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800079:	00 00 00 
}
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	c9                   	leave  
  800080:	c3                   	ret    
  800081:	00 00                	add    %al,(%eax)
	...

00800084 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008f:	e8 72 0a 00 00       	call   800b06 <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	89 c2                	mov    %eax,%edx
  80009b:	c1 e2 05             	shl    $0x5,%edx
  80009e:	29 c2                	sub    %eax,%edx
  8000a0:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000a7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 db                	test   %ebx,%ebx
  8000ae:	7e 07                	jle    8000b7 <libmain+0x33>
		binaryname = argv[0];
  8000b0:	8b 06                	mov    (%esi),%eax
  8000b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
  8000bc:	e8 a1 ff ff ff       	call   800062 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0a 00 00 00       	call   8000d0 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 e8 09 00 00       	call   800ac5 <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    
	...

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 04             	sub    $0x4,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 13                	mov    (%ebx),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 03                	mov    %eax,(%ebx)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	74 08                	je     80010b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800103:	ff 43 04             	incl   0x4(%ebx)
}
  800106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800109:	c9                   	leave  
  80010a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	68 ff 00 00 00       	push   $0xff
  800113:	8d 43 08             	lea    0x8(%ebx),%eax
  800116:	50                   	push   %eax
  800117:	e8 6c 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  80011c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb dc                	jmp    800103 <putch+0x1f>

00800127 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800130:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800137:	00 00 00 
	b.cnt = 0;
  80013a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800141:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800144:	ff 75 0c             	pushl  0xc(%ebp)
  800147:	ff 75 08             	pushl  0x8(%ebp)
  80014a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800150:	50                   	push   %eax
  800151:	68 e4 00 80 00       	push   $0x8000e4
  800156:	e8 17 01 00 00       	call   800272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	83 c4 08             	add    $0x8,%esp
  80015e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800164:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 18 09 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800181:	50                   	push   %eax
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	e8 9d ff ff ff       	call   800127 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 1c             	sub    $0x1c,%esp
  800195:	89 c7                	mov    %eax,%edi
  800197:	89 d6                	mov    %edx,%esi
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
  80019c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b3:	39 d3                	cmp    %edx,%ebx
  8001b5:	72 05                	jb     8001bc <printnum+0x30>
  8001b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ba:	77 78                	ja     800234 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 18             	pushl  0x18(%ebp)
  8001c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c8:	53                   	push   %ebx
  8001c9:	ff 75 10             	pushl  0x10(%ebp)
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001db:	e8 8c 0b 00 00       	call   800d6c <__udivdi3>
  8001e0:	83 c4 18             	add    $0x18,%esp
  8001e3:	52                   	push   %edx
  8001e4:	50                   	push   %eax
  8001e5:	89 f2                	mov    %esi,%edx
  8001e7:	89 f8                	mov    %edi,%eax
  8001e9:	e8 9e ff ff ff       	call   80018c <printnum>
  8001ee:	83 c4 20             	add    $0x20,%esp
  8001f1:	eb 11                	jmp    800204 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	ff 75 18             	pushl  0x18(%ebp)
  8001fa:	ff d7                	call   *%edi
  8001fc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	4b                   	dec    %ebx
  800200:	85 db                	test   %ebx,%ebx
  800202:	7f ef                	jg     8001f3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	56                   	push   %esi
  800208:	83 ec 04             	sub    $0x4,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 50 0c 00 00       	call   800e6c <__umoddi3>
  80021c:	83 c4 14             	add    $0x14,%esp
  80021f:	0f be 80 a6 0f 80 00 	movsbl 0x800fa6(%eax),%eax
  800226:	50                   	push   %eax
  800227:	ff d7                	call   *%edi
}
  800229:	83 c4 10             	add    $0x10,%esp
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    
  800234:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800237:	eb c6                	jmp    8001ff <printnum+0x73>

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1a>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 05 00 00 00       	call   800272 <vprintfmt>
	va_end(ap);
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	e9 ac 03 00 00       	jmp    800635 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800289:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80028d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800294:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80029b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	8a 17                	mov    (%edi),%dl
  8002af:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b2:	3c 55                	cmp    $0x55,%al
  8002b4:	0f 87 fc 03 00 00    	ja     8006b6 <vprintfmt+0x444>
  8002ba:	0f b6 c0             	movzbl %al,%eax
  8002bd:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002cb:	eb da                	jmp    8002a7 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002d0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d4:	eb d1                	jmp    8002a7 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	0f b6 d2             	movzbl %dl,%edx
  8002d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e7:	01 c0                	add    %eax,%eax
  8002e9:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002ed:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f3:	83 f9 09             	cmp    $0x9,%ecx
  8002f6:	77 52                	ja     80034a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002f8:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002f9:	eb e9                	jmp    8002e4 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8b 00                	mov    (%eax),%eax
  800300:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800303:	8b 45 14             	mov    0x14(%ebp),%eax
  800306:	8d 40 04             	lea    0x4(%eax),%eax
  800309:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80030f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800313:	79 92                	jns    8002a7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800315:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800318:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800322:	eb 83                	jmp    8002a7 <vprintfmt+0x35>
  800324:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800328:	78 08                	js     800332 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032d:	e9 75 ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  800332:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800339:	eb ef                	jmp    80032a <vprintfmt+0xb8>
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80033e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800345:	e9 5d ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  80034a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800350:	eb bd                	jmp    80030f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800352:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800356:	e9 4c ff ff ff       	jmp    8002a7 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 78 04             	lea    0x4(%eax),%edi
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	53                   	push   %ebx
  800365:	ff 30                	pushl  (%eax)
  800367:	ff d6                	call   *%esi
			break;
  800369:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036f:	e9 be 02 00 00       	jmp    800632 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 78 04             	lea    0x4(%eax),%edi
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	85 c0                	test   %eax,%eax
  80037e:	78 2a                	js     8003aa <vprintfmt+0x138>
  800380:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800382:	83 f8 08             	cmp    $0x8,%eax
  800385:	7f 27                	jg     8003ae <vprintfmt+0x13c>
  800387:	8b 04 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%eax
  80038e:	85 c0                	test   %eax,%eax
  800390:	74 1c                	je     8003ae <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800392:	50                   	push   %eax
  800393:	68 c7 0f 80 00       	push   $0x800fc7
  800398:	53                   	push   %ebx
  800399:	56                   	push   %esi
  80039a:	e8 b6 fe ff ff       	call   800255 <printfmt>
  80039f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a5:	e9 88 02 00 00       	jmp    800632 <vprintfmt+0x3c0>
  8003aa:	f7 d8                	neg    %eax
  8003ac:	eb d2                	jmp    800380 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ae:	52                   	push   %edx
  8003af:	68 be 0f 80 00       	push   $0x800fbe
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 9a fe ff ff       	call   800255 <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c1:	e9 6c 02 00 00       	jmp    800632 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	83 c0 04             	add    $0x4,%eax
  8003cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8b 38                	mov    (%eax),%edi
  8003d4:	85 ff                	test   %edi,%edi
  8003d6:	74 18                	je     8003f0 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003dc:	0f 8e b7 00 00 00    	jle    800499 <vprintfmt+0x227>
  8003e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003e6:	75 0f                	jne    8003f7 <vprintfmt+0x185>
  8003e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8003ee:	eb 75                	jmp    800465 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8003f0:	bf b7 0f 80 00       	mov    $0x800fb7,%edi
  8003f5:	eb e1                	jmp    8003d8 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fd:	57                   	push   %edi
  8003fe:	e8 5f 03 00 00       	call   800762 <strnlen>
  800403:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800406:	29 c1                	sub    %eax,%ecx
  800408:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80040b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800418:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	eb 0d                	jmp    800429 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 75 e0             	pushl  -0x20(%ebp)
  800423:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	4f                   	dec    %edi
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 ff                	test   %edi,%edi
  80042b:	7f ef                	jg     80041c <vprintfmt+0x1aa>
  80042d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800430:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800433:	89 c8                	mov    %ecx,%eax
  800435:	85 c9                	test   %ecx,%ecx
  800437:	78 10                	js     800449 <vprintfmt+0x1d7>
  800439:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80043c:	29 c1                	sub    %eax,%ecx
  80043e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800441:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800444:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800447:	eb 1c                	jmp    800465 <vprintfmt+0x1f3>
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	eb e9                	jmp    800439 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800450:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800454:	75 29                	jne    80047f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	50                   	push   %eax
  80045d:	ff d6                	call   *%esi
  80045f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800462:	ff 4d e0             	decl   -0x20(%ebp)
  800465:	47                   	inc    %edi
  800466:	8a 57 ff             	mov    -0x1(%edi),%dl
  800469:	0f be c2             	movsbl %dl,%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	74 4c                	je     8004bc <vprintfmt+0x24a>
  800470:	85 db                	test   %ebx,%ebx
  800472:	78 dc                	js     800450 <vprintfmt+0x1de>
  800474:	4b                   	dec    %ebx
  800475:	79 d9                	jns    800450 <vprintfmt+0x1de>
  800477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80047d:	eb 2e                	jmp    8004ad <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	0f be d2             	movsbl %dl,%edx
  800482:	83 ea 20             	sub    $0x20,%edx
  800485:	83 fa 5e             	cmp    $0x5e,%edx
  800488:	76 cc                	jbe    800456 <vprintfmt+0x1e4>
					putch('?', putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	6a 3f                	push   $0x3f
  800492:	ff d6                	call   *%esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	eb c9                	jmp    800462 <vprintfmt+0x1f0>
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80049f:	eb c4                	jmp    800465 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	6a 20                	push   $0x20
  8004a7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004a9:	4f                   	dec    %edi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	85 ff                	test   %edi,%edi
  8004af:	7f f0                	jg     8004a1 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b7:	e9 76 01 00 00       	jmp    800632 <vprintfmt+0x3c0>
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	eb e9                	jmp    8004ad <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004c4:	83 f9 01             	cmp    $0x1,%ecx
  8004c7:	7e 3f                	jle    800508 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 50 04             	mov    0x4(%eax),%edx
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 40 08             	lea    0x8(%eax),%eax
  8004dd:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8004e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e4:	79 5c                	jns    800542 <vprintfmt+0x2d0>
				putch('-', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	6a 2d                	push   $0x2d
  8004ec:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f4:	f7 da                	neg    %edx
  8004f6:	83 d1 00             	adc    $0x0,%ecx
  8004f9:	f7 d9                	neg    %ecx
  8004fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800503:	e9 10 01 00 00       	jmp    800618 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	75 1b                	jne    800527 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	89 c1                	mov    %eax,%ecx
  800516:	c1 f9 1f             	sar    $0x1f,%ecx
  800519:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 40 04             	lea    0x4(%eax),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	eb b9                	jmp    8004e0 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052f:	89 c1                	mov    %eax,%ecx
  800531:	c1 f9 1f             	sar    $0x1f,%ecx
  800534:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 40 04             	lea    0x4(%eax),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
  800540:	eb 9e                	jmp    8004e0 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054d:	e9 c6 00 00 00       	jmp    800618 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800552:	83 f9 01             	cmp    $0x1,%ecx
  800555:	7e 18                	jle    80056f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	8b 48 04             	mov    0x4(%eax),%ecx
  80055f:	8d 40 08             	lea    0x8(%eax),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800565:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056a:	e9 a9 00 00 00       	jmp    800618 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80056f:	85 c9                	test   %ecx,%ecx
  800571:	75 1a                	jne    80058d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 10                	mov    (%eax),%edx
  800578:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057d:	8d 40 04             	lea    0x4(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800583:	b8 0a 00 00 00       	mov    $0xa,%eax
  800588:	e9 8b 00 00 00       	jmp    800618 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a2:	eb 74                	jmp    800618 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a4:	83 f9 01             	cmp    $0x1,%ecx
  8005a7:	7e 15                	jle    8005be <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005bc:	eb 5a                	jmp    800618 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	75 17                	jne    8005d9 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d7:	eb 3f                	jmp    800618 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005e9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ee:	eb 28                	jmp    800618 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 30                	push   $0x30
  8005f6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 78                	push   $0x78
  8005fe:	ff d6                	call   *%esi
			num = (unsigned long long)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800613:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800618:	83 ec 0c             	sub    $0xc,%esp
  80061b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80061f:	57                   	push   %edi
  800620:	ff 75 e0             	pushl  -0x20(%ebp)
  800623:	50                   	push   %eax
  800624:	51                   	push   %ecx
  800625:	52                   	push   %edx
  800626:	89 da                	mov    %ebx,%edx
  800628:	89 f0                	mov    %esi,%eax
  80062a:	e8 5d fb ff ff       	call   80018c <printnum>
			break;
  80062f:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	47                   	inc    %edi
  800636:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063a:	83 f8 25             	cmp    $0x25,%eax
  80063d:	0f 84 46 fc ff ff    	je     800289 <vprintfmt+0x17>
			if (ch == '\0')
  800643:	85 c0                	test   %eax,%eax
  800645:	0f 84 89 00 00 00    	je     8006d4 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	50                   	push   %eax
  800650:	ff d6                	call   *%esi
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb de                	jmp    800635 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800657:	83 f9 01             	cmp    $0x1,%ecx
  80065a:	7e 15                	jle    800671 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	8b 48 04             	mov    0x4(%eax),%ecx
  800664:	8d 40 08             	lea    0x8(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80066a:	b8 10 00 00 00       	mov    $0x10,%eax
  80066f:	eb a7                	jmp    800618 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800671:	85 c9                	test   %ecx,%ecx
  800673:	75 17                	jne    80068c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
  80068a:	eb 8c                	jmp    800618 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a1:	e9 72 ff ff ff       	jmp    800618 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 25                	push   $0x25
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	e9 7c ff ff ff       	jmp    800632 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 25                	push   $0x25
  8006bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	89 f8                	mov    %edi,%eax
  8006c3:	eb 01                	jmp    8006c6 <vprintfmt+0x454>
  8006c5:	48                   	dec    %eax
  8006c6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ca:	75 f9                	jne    8006c5 <vprintfmt+0x453>
  8006cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cf:	e9 5e ff ff ff       	jmp    800632 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 26                	je     800723 <vsnprintf+0x47>
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	7e 29                	jle    80072a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800701:	ff 75 14             	pushl  0x14(%ebp)
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	68 39 02 80 00       	push   $0x800239
  800710:	e8 5d fb ff ff       	call   800272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800718:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	83 c4 10             	add    $0x10,%esp
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800728:	eb f7                	jmp    800721 <vsnprintf+0x45>
  80072a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072f:	eb f0                	jmp    800721 <vsnprintf+0x45>

00800731 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800737:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073a:	50                   	push   %eax
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	ff 75 08             	pushl  0x8(%ebp)
  800744:	e8 93 ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
	...

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 01                	jmp    80075a <strlen+0xe>
		n++;
  800759:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	75 f9                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	eb 01                	jmp    800773 <strnlen+0x11>
		n++;
  800772:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800773:	39 d0                	cmp    %edx,%eax
  800775:	74 06                	je     80077d <strnlen+0x1b>
  800777:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077b:	75 f5                	jne    800772 <strnlen+0x10>
		n++;
	return n;
}
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800789:	89 c2                	mov    %eax,%edx
  80078b:	41                   	inc    %ecx
  80078c:	42                   	inc    %edx
  80078d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800790:	88 5a ff             	mov    %bl,-0x1(%edx)
  800793:	84 db                	test   %bl,%bl
  800795:	75 f4                	jne    80078b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	53                   	push   %ebx
  8007a2:	e8 a5 ff ff ff       	call   80074c <strlen>
  8007a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	50                   	push   %eax
  8007b0:	e8 ca ff ff ff       	call   80077f <strcpy>
	return dst;
}
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	39 da                	cmp    %ebx,%edx
  8007d0:	74 0e                	je     8007e0 <strncpy+0x24>
		*dst++ = *src;
  8007d2:	42                   	inc    %edx
  8007d3:	8a 01                	mov    (%ecx),%al
  8007d5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007d8:	80 39 00             	cmpb   $0x0,(%ecx)
  8007db:	74 f1                	je     8007ce <strncpy+0x12>
			src++;
  8007dd:	41                   	inc    %ecx
  8007de:	eb ee                	jmp    8007ce <strncpy+0x12>
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 20                	je     800818 <strlcpy+0x32>
  8007f8:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	eb 05                	jmp    800805 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800800:	42                   	inc    %edx
  800801:	40                   	inc    %eax
  800802:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800805:	39 d8                	cmp    %ebx,%eax
  800807:	74 06                	je     80080f <strlcpy+0x29>
  800809:	8a 0a                	mov    (%edx),%cl
  80080b:	84 c9                	test   %cl,%cl
  80080d:	75 f1                	jne    800800 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80080f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800812:	29 f0                	sub    %esi,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    
  800818:	89 f0                	mov    %esi,%eax
  80081a:	eb f6                	jmp    800812 <strlcpy+0x2c>

0080081c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800825:	eb 02                	jmp    800829 <strcmp+0xd>
		p++, q++;
  800827:	41                   	inc    %ecx
  800828:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800829:	8a 01                	mov    (%ecx),%al
  80082b:	84 c0                	test   %al,%al
  80082d:	74 04                	je     800833 <strcmp+0x17>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	74 f4                	je     800827 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 c0             	movzbl %al,%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
  800847:	89 c3                	mov    %eax,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084c:	eb 02                	jmp    800850 <strncmp+0x13>
		n--, p++, q++;
  80084e:	40                   	inc    %eax
  80084f:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800850:	39 d8                	cmp    %ebx,%eax
  800852:	74 15                	je     800869 <strncmp+0x2c>
  800854:	8a 08                	mov    (%eax),%cl
  800856:	84 c9                	test   %cl,%cl
  800858:	74 04                	je     80085e <strncmp+0x21>
  80085a:	3a 0a                	cmp    (%edx),%cl
  80085c:	74 f0                	je     80084e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 00             	movzbl (%eax),%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
  80086e:	eb f6                	jmp    800866 <strncmp+0x29>

00800870 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800879:	8a 10                	mov    (%eax),%dl
  80087b:	84 d2                	test   %dl,%dl
  80087d:	74 07                	je     800886 <strchr+0x16>
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 08                	je     80088b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800883:	40                   	inc    %eax
  800884:	eb f3                	jmp    800879 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800896:	8a 10                	mov    (%eax),%dl
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 07                	je     8008a3 <strfind+0x16>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 03                	je     8008a3 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	40                   	inc    %eax
  8008a1:	eb f3                	jmp    800896 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 13                	je     8008c8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 05                	jne    8008c2 <memset+0x1d>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	74 0d                	je     8008cf <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	fc                   	cld    
  8008c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8008cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d3:	89 d3                	mov    %edx,%ebx
  8008d5:	c1 e3 08             	shl    $0x8,%ebx
  8008d8:	89 d0                	mov    %edx,%eax
  8008da:	c1 e0 18             	shl    $0x18,%eax
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	c1 e6 10             	shl    $0x10,%esi
  8008e2:	09 f0                	or     %esi,%eax
  8008e4:	09 c2                	or     %eax,%edx
  8008e6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb d6                	jmp    8008c8 <memset+0x23>

008008f2 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	57                   	push   %edi
  8008f6:	56                   	push   %esi
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800900:	39 c6                	cmp    %eax,%esi
  800902:	73 33                	jae    800937 <memmove+0x45>
  800904:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800907:	39 c2                	cmp    %eax,%edx
  800909:	76 2c                	jbe    800937 <memmove+0x45>
		s += n;
		d += n;
  80090b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090e:	89 d6                	mov    %edx,%esi
  800910:	09 fe                	or     %edi,%esi
  800912:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800918:	74 0a                	je     800924 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80091a:	4f                   	dec    %edi
  80091b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091e:	fd                   	std    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800921:	fc                   	cld    
  800922:	eb 21                	jmp    800945 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	f6 c1 03             	test   $0x3,%cl
  800927:	75 f1                	jne    80091a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800929:	83 ef 04             	sub    $0x4,%edi
  80092c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800932:	fd                   	std    
  800933:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800935:	eb ea                	jmp    800921 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	89 f2                	mov    %esi,%edx
  800939:	09 c2                	or     %eax,%edx
  80093b:	f6 c2 03             	test   $0x3,%dl
  80093e:	74 09                	je     800949 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800940:	89 c7                	mov    %eax,%edi
  800942:	fc                   	cld    
  800943:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 f2                	jne    800940 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb ed                	jmp    800945 <memmove+0x53>

00800958 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095b:	ff 75 10             	pushl  0x10(%ebp)
  80095e:	ff 75 0c             	pushl  0xc(%ebp)
  800961:	ff 75 08             	pushl  0x8(%ebp)
  800964:	e8 89 ff ff ff       	call   8008f2 <memmove>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 c6                	mov    %eax,%esi
  800978:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097b:	39 f0                	cmp    %esi,%eax
  80097d:	74 16                	je     800995 <memcmp+0x2a>
		if (*s1 != *s2)
  80097f:	8a 08                	mov    (%eax),%cl
  800981:	8a 1a                	mov    (%edx),%bl
  800983:	38 d9                	cmp    %bl,%cl
  800985:	75 04                	jne    80098b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800987:	40                   	inc    %eax
  800988:	42                   	inc    %edx
  800989:	eb f0                	jmp    80097b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  80098b:	0f b6 c1             	movzbl %cl,%eax
  80098e:	0f b6 db             	movzbl %bl,%ebx
  800991:	29 d8                	sub    %ebx,%eax
  800993:	eb 05                	jmp    80099a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ac:	39 d0                	cmp    %edx,%eax
  8009ae:	73 07                	jae    8009b7 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b0:	38 08                	cmp    %cl,(%eax)
  8009b2:	74 03                	je     8009b7 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b4:	40                   	inc    %eax
  8009b5:	eb f5                	jmp    8009ac <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c2:	eb 01                	jmp    8009c5 <strtol+0xc>
		s++;
  8009c4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	8a 01                	mov    (%ecx),%al
  8009c7:	3c 20                	cmp    $0x20,%al
  8009c9:	74 f9                	je     8009c4 <strtol+0xb>
  8009cb:	3c 09                	cmp    $0x9,%al
  8009cd:	74 f5                	je     8009c4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cf:	3c 2b                	cmp    $0x2b,%al
  8009d1:	74 2b                	je     8009fe <strtol+0x45>
		s++;
	else if (*s == '-')
  8009d3:	3c 2d                	cmp    $0x2d,%al
  8009d5:	74 2f                	je     800a06 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dc:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  8009e3:	75 12                	jne    8009f7 <strtol+0x3e>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	74 24                	je     800a0e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ee:	75 07                	jne    8009f7 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb 4e                	jmp    800a4c <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  8009fe:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb d6                	jmp    8009dc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a06:	41                   	inc    %ecx
  800a07:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0c:	eb ce                	jmp    8009dc <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a12:	74 10                	je     800a24 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a18:	75 dd                	jne    8009f7 <strtol+0x3e>
		s++, base = 8;
  800a1a:	41                   	inc    %ecx
  800a1b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a22:	eb d3                	jmp    8009f7 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a24:	83 c1 02             	add    $0x2,%ecx
  800a27:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a2e:	eb c7                	jmp    8009f7 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 24                	ja     800a5e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a3a:	0f be d2             	movsbl %dl,%edx
  800a3d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a40:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a43:	7e 2b                	jle    800a70 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a45:	41                   	inc    %ecx
  800a46:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4a:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4c:	8a 11                	mov    (%ecx),%dl
  800a4e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a51:	80 fb 09             	cmp    $0x9,%bl
  800a54:	77 da                	ja     800a30 <strtol+0x77>
			dig = *s - '0';
  800a56:	0f be d2             	movsbl %dl,%edx
  800a59:	83 ea 30             	sub    $0x30,%edx
  800a5c:	eb e2                	jmp    800a40 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a61:	89 f3                	mov    %esi,%ebx
  800a63:	80 fb 19             	cmp    $0x19,%bl
  800a66:	77 08                	ja     800a70 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a68:	0f be d2             	movsbl %dl,%edx
  800a6b:	83 ea 37             	sub    $0x37,%edx
  800a6e:	eb d0                	jmp    800a40 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a74:	74 05                	je     800a7b <strtol+0xc2>
		*endptr = (char *) s;
  800a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	74 02                	je     800a81 <strtol+0xc8>
  800a7f:	f7 d8                	neg    %eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	b8 03 00 00 00       	mov    $0x3,%eax
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7f 08                	jg     800aef <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	50                   	push   %eax
  800af3:	6a 03                	push   $0x3
  800af5:	68 e4 11 80 00       	push   $0x8011e4
  800afa:	6a 23                	push   $0x23
  800afc:	68 01 12 80 00       	push   $0x801201
  800b01:	e8 1e 02 00 00       	call   800d24 <_panic>

00800b06 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 02 00 00 00       	mov    $0x2,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_yield>:

void
sys_yield(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	be 00 00 00 00       	mov    $0x0,%esi
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b60:	89 f7                	mov    %esi,%edi
  800b62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b64:	85 c0                	test   %eax,%eax
  800b66:	7f 08                	jg     800b70 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 04                	push   $0x4
  800b76:	68 e4 11 80 00       	push   $0x8011e4
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 01 12 80 00       	push   $0x801201
  800b82:	e8 9d 01 00 00       	call   800d24 <_panic>

00800b87 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7f 08                	jg     800bb2 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	50                   	push   %eax
  800bb6:	6a 05                	push   $0x5
  800bb8:	68 e4 11 80 00       	push   $0x8011e4
  800bbd:	6a 23                	push   $0x23
  800bbf:	68 01 12 80 00       	push   $0x801201
  800bc4:	e8 5b 01 00 00       	call   800d24 <_panic>

00800bc9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	b8 06 00 00 00       	mov    $0x6,%eax
  800be2:	89 df                	mov    %ebx,%edi
  800be4:	89 de                	mov    %ebx,%esi
  800be6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7f 08                	jg     800bf4 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 06                	push   $0x6
  800bfa:	68 e4 11 80 00       	push   $0x8011e4
  800bff:	6a 23                	push   $0x23
  800c01:	68 01 12 80 00       	push   $0x801201
  800c06:	e8 19 01 00 00       	call   800d24 <_panic>

00800c0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7f 08                	jg     800c36 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 08                	push   $0x8
  800c3c:	68 e4 11 80 00       	push   $0x8011e4
  800c41:	6a 23                	push   $0x23
  800c43:	68 01 12 80 00       	push   $0x801201
  800c48:	e8 d7 00 00 00       	call   800d24 <_panic>

00800c4d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	b8 09 00 00 00       	mov    $0x9,%eax
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7f 08                	jg     800c78 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 09                	push   $0x9
  800c7e:	68 e4 11 80 00       	push   $0x8011e4
  800c83:	6a 23                	push   $0x23
  800c85:	68 01 12 80 00       	push   $0x801201
  800c8a:	e8 95 00 00 00       	call   800d24 <_panic>

00800c8f <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cab:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc8:	89 cb                	mov    %ecx,%ebx
  800cca:	89 cf                	mov    %ecx,%edi
  800ccc:	89 ce                	mov    %ecx,%esi
  800cce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7f 08                	jg     800cdc <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 0c                	push   $0xc
  800ce2:	68 e4 11 80 00       	push   $0x8011e4
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 01 12 80 00       	push   $0x801201
  800cee:	e8 31 00 00 00       	call   800d24 <_panic>
	...

00800cf4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cfa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d01:	74 0a                	je     800d0d <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	68 10 12 80 00       	push   $0x801210
  800d15:	6a 20                	push   $0x20
  800d17:	68 34 12 80 00       	push   $0x801234
  800d1c:	e8 03 00 00 00       	call   800d24 <_panic>
  800d21:	00 00                	add    %al,(%eax)
	...

00800d24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d32:	e8 cf fd ff ff       	call   800b06 <sys_getenvid>
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	ff 75 08             	pushl  0x8(%ebp)
  800d40:	56                   	push   %esi
  800d41:	50                   	push   %eax
  800d42:	68 44 12 80 00       	push   $0x801244
  800d47:	e8 2c f4 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d4c:	83 c4 18             	add    $0x18,%esp
  800d4f:	53                   	push   %ebx
  800d50:	ff 75 10             	pushl  0x10(%ebp)
  800d53:	e8 cf f3 ff ff       	call   800127 <vcprintf>
	cprintf("\n");
  800d58:	c7 04 24 9a 0f 80 00 	movl   $0x800f9a,(%esp)
  800d5f:	e8 14 f4 ff ff       	call   800178 <cprintf>
  800d64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d67:	cc                   	int3   
  800d68:	eb fd                	jmp    800d67 <_panic+0x43>
	...

00800d6c <__udivdi3>:
  800d6c:	55                   	push   %ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 1c             	sub    $0x1c,%esp
  800d73:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d77:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d7b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d7f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d83:	85 d2                	test   %edx,%edx
  800d85:	75 2d                	jne    800db4 <__udivdi3+0x48>
  800d87:	39 f7                	cmp    %esi,%edi
  800d89:	77 59                	ja     800de4 <__udivdi3+0x78>
  800d8b:	89 f9                	mov    %edi,%ecx
  800d8d:	85 ff                	test   %edi,%edi
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x30>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f7                	div    %edi
  800d9a:	89 c1                	mov    %eax,%ecx
  800d9c:	31 d2                	xor    %edx,%edx
  800d9e:	89 f0                	mov    %esi,%eax
  800da0:	f7 f1                	div    %ecx
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	89 e8                	mov    %ebp,%eax
  800da6:	f7 f1                	div    %ecx
  800da8:	89 da                	mov    %ebx,%edx
  800daa:	83 c4 1c             	add    $0x1c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
  800db2:	66 90                	xchg   %ax,%ax
  800db4:	39 f2                	cmp    %esi,%edx
  800db6:	77 1c                	ja     800dd4 <__udivdi3+0x68>
  800db8:	0f bd da             	bsr    %edx,%ebx
  800dbb:	83 f3 1f             	xor    $0x1f,%ebx
  800dbe:	75 38                	jne    800df8 <__udivdi3+0x8c>
  800dc0:	39 f2                	cmp    %esi,%edx
  800dc2:	72 08                	jb     800dcc <__udivdi3+0x60>
  800dc4:	39 ef                	cmp    %ebp,%edi
  800dc6:	0f 87 98 00 00 00    	ja     800e64 <__udivdi3+0xf8>
  800dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd1:	eb 05                	jmp    800dd8 <__udivdi3+0x6c>
  800dd3:	90                   	nop
  800dd4:	31 db                	xor    %ebx,%ebx
  800dd6:	31 c0                	xor    %eax,%eax
  800dd8:	89 da                	mov    %ebx,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	66 90                	xchg   %ax,%ax
  800de4:	89 e8                	mov    %ebp,%eax
  800de6:	89 f2                	mov    %esi,%edx
  800de8:	f7 f7                	div    %edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 da                	mov    %ebx,%edx
  800dee:	83 c4 1c             	add    $0x1c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	b8 20 00 00 00       	mov    $0x20,%eax
  800dfd:	29 d8                	sub    %ebx,%eax
  800dff:	88 d9                	mov    %bl,%cl
  800e01:	d3 e2                	shl    %cl,%edx
  800e03:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e07:	89 fa                	mov    %edi,%edx
  800e09:	88 c1                	mov    %al,%cl
  800e0b:	d3 ea                	shr    %cl,%edx
  800e0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e11:	09 d1                	or     %edx,%ecx
  800e13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e17:	88 d9                	mov    %bl,%cl
  800e19:	d3 e7                	shl    %cl,%edi
  800e1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e1f:	89 f7                	mov    %esi,%edi
  800e21:	88 c1                	mov    %al,%cl
  800e23:	d3 ef                	shr    %cl,%edi
  800e25:	88 d9                	mov    %bl,%cl
  800e27:	d3 e6                	shl    %cl,%esi
  800e29:	89 ea                	mov    %ebp,%edx
  800e2b:	88 c1                	mov    %al,%cl
  800e2d:	d3 ea                	shr    %cl,%edx
  800e2f:	09 d6                	or     %edx,%esi
  800e31:	89 f0                	mov    %esi,%eax
  800e33:	89 fa                	mov    %edi,%edx
  800e35:	f7 74 24 08          	divl   0x8(%esp)
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 c6                	mov    %eax,%esi
  800e3d:	f7 64 24 0c          	mull   0xc(%esp)
  800e41:	39 d7                	cmp    %edx,%edi
  800e43:	72 13                	jb     800e58 <__udivdi3+0xec>
  800e45:	74 09                	je     800e50 <__udivdi3+0xe4>
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	31 db                	xor    %ebx,%ebx
  800e4b:	eb 8b                	jmp    800dd8 <__udivdi3+0x6c>
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	88 d9                	mov    %bl,%cl
  800e52:	d3 e5                	shl    %cl,%ebp
  800e54:	39 c5                	cmp    %eax,%ebp
  800e56:	73 ef                	jae    800e47 <__udivdi3+0xdb>
  800e58:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e5b:	31 db                	xor    %ebx,%ebx
  800e5d:	e9 76 ff ff ff       	jmp    800dd8 <__udivdi3+0x6c>
  800e62:	66 90                	xchg   %ax,%ax
  800e64:	31 c0                	xor    %eax,%eax
  800e66:	e9 6d ff ff ff       	jmp    800dd8 <__udivdi3+0x6c>
	...

00800e6c <__umoddi3>:
  800e6c:	55                   	push   %ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 1c             	sub    $0x1c,%esp
  800e73:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e77:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e7b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e7f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	89 da                	mov    %ebx,%edx
  800e87:	85 ed                	test   %ebp,%ebp
  800e89:	75 15                	jne    800ea0 <__umoddi3+0x34>
  800e8b:	39 df                	cmp    %ebx,%edi
  800e8d:	76 39                	jbe    800ec8 <__umoddi3+0x5c>
  800e8f:	f7 f7                	div    %edi
  800e91:	89 d0                	mov    %edx,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	83 c4 1c             	add    $0x1c,%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	39 dd                	cmp    %ebx,%ebp
  800ea2:	77 f1                	ja     800e95 <__umoddi3+0x29>
  800ea4:	0f bd cd             	bsr    %ebp,%ecx
  800ea7:	83 f1 1f             	xor    $0x1f,%ecx
  800eaa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eae:	75 38                	jne    800ee8 <__umoddi3+0x7c>
  800eb0:	39 dd                	cmp    %ebx,%ebp
  800eb2:	72 04                	jb     800eb8 <__umoddi3+0x4c>
  800eb4:	39 f7                	cmp    %esi,%edi
  800eb6:	77 dd                	ja     800e95 <__umoddi3+0x29>
  800eb8:	89 da                	mov    %ebx,%edx
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	29 f8                	sub    %edi,%eax
  800ebe:	19 ea                	sbb    %ebp,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	89 f9                	mov    %edi,%ecx
  800eca:	85 ff                	test   %edi,%edi
  800ecc:	75 0b                	jne    800ed9 <__umoddi3+0x6d>
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f7                	div    %edi
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f1                	div    %ecx
  800edf:	89 f0                	mov    %esi,%eax
  800ee1:	f7 f1                	div    %ecx
  800ee3:	eb ac                	jmp    800e91 <__umoddi3+0x25>
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	b8 20 00 00 00       	mov    $0x20,%eax
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ef3:	29 c2                	sub    %eax,%edx
  800ef5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef9:	88 c1                	mov    %al,%cl
  800efb:	d3 e5                	shl    %cl,%ebp
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	88 d1                	mov    %dl,%cl
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	09 c5                	or     %eax,%ebp
  800f05:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f09:	88 c1                	mov    %al,%cl
  800f0b:	d3 e7                	shl    %cl,%edi
  800f0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f11:	89 df                	mov    %ebx,%edi
  800f13:	88 d1                	mov    %dl,%cl
  800f15:	d3 ef                	shr    %cl,%edi
  800f17:	88 c1                	mov    %al,%cl
  800f19:	d3 e3                	shl    %cl,%ebx
  800f1b:	89 f0                	mov    %esi,%eax
  800f1d:	88 d1                	mov    %dl,%cl
  800f1f:	d3 e8                	shr    %cl,%eax
  800f21:	09 d8                	or     %ebx,%eax
  800f23:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f27:	d3 e6                	shl    %cl,%esi
  800f29:	89 fa                	mov    %edi,%edx
  800f2b:	f7 f5                	div    %ebp
  800f2d:	89 d1                	mov    %edx,%ecx
  800f2f:	f7 64 24 08          	mull   0x8(%esp)
  800f33:	89 c3                	mov    %eax,%ebx
  800f35:	89 d7                	mov    %edx,%edi
  800f37:	39 d1                	cmp    %edx,%ecx
  800f39:	72 29                	jb     800f64 <__umoddi3+0xf8>
  800f3b:	74 23                	je     800f60 <__umoddi3+0xf4>
  800f3d:	89 ca                	mov    %ecx,%edx
  800f3f:	29 de                	sub    %ebx,%esi
  800f41:	19 fa                	sbb    %edi,%edx
  800f43:	89 d0                	mov    %edx,%eax
  800f45:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f49:	d3 e0                	shl    %cl,%eax
  800f4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f4f:	88 d9                	mov    %bl,%cl
  800f51:	d3 ee                	shr    %cl,%esi
  800f53:	09 f0                	or     %esi,%eax
  800f55:	d3 ea                	shr    %cl,%edx
  800f57:	83 c4 1c             	add    $0x1c,%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    
  800f5f:	90                   	nop
  800f60:	39 c6                	cmp    %eax,%esi
  800f62:	73 d9                	jae    800f3d <__umoddi3+0xd1>
  800f64:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f68:	19 ea                	sbb    %ebp,%edx
  800f6a:	89 d7                	mov    %edx,%edi
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	eb cd                	jmp    800f3d <__umoddi3+0xd1>
