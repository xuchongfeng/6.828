
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800040:	68 40 0d 80 00       	push   $0x800d40
  800045:	e8 fa 00 00 00       	call   800144 <cprintf>
}
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800058:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005b:	e8 72 0a 00 00       	call   800ad2 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800068:	01 d0                	add    %edx,%eax
  80006a:	c1 e0 05             	shl    $0x5,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 db                	test   %ebx,%ebx
  800079:	7e 07                	jle    800082 <libmain+0x32>
		binaryname = argv[0];
  80007b:	8b 06                	mov    (%esi),%eax
  80007d:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 e8 09 00 00       	call   800a91 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 13                	mov    (%ebx),%edx
  8000bc:	8d 42 01             	lea    0x1(%edx),%eax
  8000bf:	89 03                	mov    %eax,(%ebx)
  8000c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cd:	74 08                	je     8000d7 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000cf:	ff 43 04             	incl   0x4(%ebx)
}
  8000d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 6c 09 00 00       	call   800a54 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
  8000f1:	eb dc                	jmp    8000cf <putch+0x1f>

008000f3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
	b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800110:	ff 75 0c             	pushl  0xc(%ebp)
  800113:	ff 75 08             	pushl  0x8(%ebp)
  800116:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011c:	50                   	push   %eax
  80011d:	68 b0 00 80 00       	push   $0x8000b0
  800122:	e8 17 01 00 00       	call   80023e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800127:	83 c4 08             	add    $0x8,%esp
  80012a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800130:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800136:	50                   	push   %eax
  800137:	e8 18 09 00 00       	call   800a54 <sys_cputs>

	return b.cnt;
}
  80013c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014d:	50                   	push   %eax
  80014e:	ff 75 08             	pushl  0x8(%ebp)
  800151:	e8 9d ff ff ff       	call   8000f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	83 ec 1c             	sub    $0x1c,%esp
  800161:	89 c7                	mov    %eax,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800171:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017f:	39 d3                	cmp    %edx,%ebx
  800181:	72 05                	jb     800188 <printnum+0x30>
  800183:	39 45 10             	cmp    %eax,0x10(%ebp)
  800186:	77 78                	ja     800200 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 18             	pushl  0x18(%ebp)
  80018e:	8b 45 14             	mov    0x14(%ebp),%eax
  800191:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800194:	53                   	push   %ebx
  800195:	ff 75 10             	pushl  0x10(%ebp)
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019e:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a7:	e8 90 09 00 00       	call   800b3c <__udivdi3>
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	52                   	push   %edx
  8001b0:	50                   	push   %eax
  8001b1:	89 f2                	mov    %esi,%edx
  8001b3:	89 f8                	mov    %edi,%eax
  8001b5:	e8 9e ff ff ff       	call   800158 <printnum>
  8001ba:	83 c4 20             	add    $0x20,%esp
  8001bd:	eb 11                	jmp    8001d0 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	56                   	push   %esi
  8001c3:	ff 75 18             	pushl  0x18(%ebp)
  8001c6:	ff d7                	call   *%edi
  8001c8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cb:	4b                   	dec    %ebx
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7f ef                	jg     8001bf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001da:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e3:	e8 54 0a 00 00       	call   800c3c <__umoddi3>
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	0f be 80 71 0d 80 00 	movsbl 0x800d71(%eax),%eax
  8001f2:	50                   	push   %eax
  8001f3:	ff d7                	call   *%edi
}
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5f                   	pop    %edi
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    
  800200:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800203:	eb c6                	jmp    8001cb <printnum+0x73>

00800205 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	3b 50 04             	cmp    0x4(%eax),%edx
  800213:	73 0a                	jae    80021f <sprintputch+0x1a>
		*b->buf++ = ch;
  800215:	8d 4a 01             	lea    0x1(%edx),%ecx
  800218:	89 08                	mov    %ecx,(%eax)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	88 02                	mov    %al,(%edx)
}
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 05 00 00 00       	call   80023e <vprintfmt>
	va_end(ap);
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
  800244:	83 ec 2c             	sub    $0x2c,%esp
  800247:	8b 75 08             	mov    0x8(%ebp),%esi
  80024a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800250:	e9 ac 03 00 00       	jmp    800601 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800255:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800259:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800260:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800267:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80026e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800273:	8d 47 01             	lea    0x1(%edi),%eax
  800276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800279:	8a 17                	mov    (%edi),%dl
  80027b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80027e:	3c 55                	cmp    $0x55,%al
  800280:	0f 87 fc 03 00 00    	ja     800682 <vprintfmt+0x444>
  800286:	0f b6 c0             	movzbl %al,%eax
  800289:	ff 24 85 00 0e 80 00 	jmp    *0x800e00(,%eax,4)
  800290:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800293:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800297:	eb da                	jmp    800273 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800299:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80029c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002a0:	eb d1                	jmp    800273 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a2:	0f b6 d2             	movzbl %dl,%edx
  8002a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002b3:	01 c0                	add    %eax,%eax
  8002b5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002b9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002bc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002bf:	83 f9 09             	cmp    $0x9,%ecx
  8002c2:	77 52                	ja     800316 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002c4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002c5:	eb e9                	jmp    8002b0 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ca:	8b 00                	mov    (%eax),%eax
  8002cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d2:	8d 40 04             	lea    0x4(%eax),%eax
  8002d5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002df:	79 92                	jns    800273 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	eb 83                	jmp    800273 <vprintfmt+0x35>
  8002f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f4:	78 08                	js     8002fe <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f9:	e9 75 ff ff ff       	jmp    800273 <vprintfmt+0x35>
  8002fe:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800305:	eb ef                	jmp    8002f6 <vprintfmt+0xb8>
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80030a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800311:	e9 5d ff ff ff       	jmp    800273 <vprintfmt+0x35>
  800316:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800319:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031c:	eb bd                	jmp    8002db <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80031e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800322:	e9 4c ff ff ff       	jmp    800273 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 78 04             	lea    0x4(%eax),%edi
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	53                   	push   %ebx
  800331:	ff 30                	pushl  (%eax)
  800333:	ff d6                	call   *%esi
			break;
  800335:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800338:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80033b:	e9 be 02 00 00       	jmp    8005fe <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800340:	8b 45 14             	mov    0x14(%ebp),%eax
  800343:	8d 78 04             	lea    0x4(%eax),%edi
  800346:	8b 00                	mov    (%eax),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	78 2a                	js     800376 <vprintfmt+0x138>
  80034c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80034e:	83 f8 06             	cmp    $0x6,%eax
  800351:	7f 27                	jg     80037a <vprintfmt+0x13c>
  800353:	8b 04 85 58 0f 80 00 	mov    0x800f58(,%eax,4),%eax
  80035a:	85 c0                	test   %eax,%eax
  80035c:	74 1c                	je     80037a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80035e:	50                   	push   %eax
  80035f:	68 92 0d 80 00       	push   $0x800d92
  800364:	53                   	push   %ebx
  800365:	56                   	push   %esi
  800366:	e8 b6 fe ff ff       	call   800221 <printfmt>
  80036b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80036e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800371:	e9 88 02 00 00       	jmp    8005fe <vprintfmt+0x3c0>
  800376:	f7 d8                	neg    %eax
  800378:	eb d2                	jmp    80034c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80037a:	52                   	push   %edx
  80037b:	68 89 0d 80 00       	push   $0x800d89
  800380:	53                   	push   %ebx
  800381:	56                   	push   %esi
  800382:	e8 9a fe ff ff       	call   800221 <printfmt>
  800387:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80038a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80038d:	e9 6c 02 00 00       	jmp    8005fe <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	83 c0 04             	add    $0x4,%eax
  800398:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8b 38                	mov    (%eax),%edi
  8003a0:	85 ff                	test   %edi,%edi
  8003a2:	74 18                	je     8003bc <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	0f 8e b7 00 00 00    	jle    800465 <vprintfmt+0x227>
  8003ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003b2:	75 0f                	jne    8003c3 <vprintfmt+0x185>
  8003b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003b7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8003ba:	eb 75                	jmp    800431 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8003bc:	bf 82 0d 80 00       	mov    $0x800d82,%edi
  8003c1:	eb e1                	jmp    8003a4 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8003c9:	57                   	push   %edi
  8003ca:	e8 5f 03 00 00       	call   80072e <strnlen>
  8003cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d2:	29 c1                	sub    %eax,%ecx
  8003d4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e6:	eb 0d                	jmp    8003f5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	53                   	push   %ebx
  8003ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f1:	4f                   	dec    %edi
  8003f2:	83 c4 10             	add    $0x10,%esp
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	7f ef                	jg     8003e8 <vprintfmt+0x1aa>
  8003f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8003fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003ff:	89 c8                	mov    %ecx,%eax
  800401:	85 c9                	test   %ecx,%ecx
  800403:	78 10                	js     800415 <vprintfmt+0x1d7>
  800405:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800408:	29 c1                	sub    %eax,%ecx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800410:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800413:	eb 1c                	jmp    800431 <vprintfmt+0x1f3>
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb e9                	jmp    800405 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80041c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800420:	75 29                	jne    80044b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	ff 75 0c             	pushl  0xc(%ebp)
  800428:	50                   	push   %eax
  800429:	ff d6                	call   *%esi
  80042b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042e:	ff 4d e0             	decl   -0x20(%ebp)
  800431:	47                   	inc    %edi
  800432:	8a 57 ff             	mov    -0x1(%edi),%dl
  800435:	0f be c2             	movsbl %dl,%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	74 4c                	je     800488 <vprintfmt+0x24a>
  80043c:	85 db                	test   %ebx,%ebx
  80043e:	78 dc                	js     80041c <vprintfmt+0x1de>
  800440:	4b                   	dec    %ebx
  800441:	79 d9                	jns    80041c <vprintfmt+0x1de>
  800443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800446:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800449:	eb 2e                	jmp    800479 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80044b:	0f be d2             	movsbl %dl,%edx
  80044e:	83 ea 20             	sub    $0x20,%edx
  800451:	83 fa 5e             	cmp    $0x5e,%edx
  800454:	76 cc                	jbe    800422 <vprintfmt+0x1e4>
					putch('?', putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	6a 3f                	push   $0x3f
  80045e:	ff d6                	call   *%esi
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	eb c9                	jmp    80042e <vprintfmt+0x1f0>
  800465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800468:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80046b:	eb c4                	jmp    800431 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	6a 20                	push   $0x20
  800473:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800475:	4f                   	dec    %edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f f0                	jg     80046d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800480:	89 45 14             	mov    %eax,0x14(%ebp)
  800483:	e9 76 01 00 00       	jmp    8005fe <vprintfmt+0x3c0>
  800488:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80048b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048e:	eb e9                	jmp    800479 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800490:	83 f9 01             	cmp    $0x1,%ecx
  800493:	7e 3f                	jle    8004d4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8b 50 04             	mov    0x4(%eax),%edx
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 40 08             	lea    0x8(%eax),%eax
  8004a9:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8004ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b0:	79 5c                	jns    80050e <vprintfmt+0x2d0>
				putch('-', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 2d                	push   $0x2d
  8004b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004c0:	f7 da                	neg    %edx
  8004c2:	83 d1 00             	adc    $0x0,%ecx
  8004c5:	f7 d9                	neg    %ecx
  8004c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004cf:	e9 10 01 00 00       	jmp    8005e4 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8004d4:	85 c9                	test   %ecx,%ecx
  8004d6:	75 1b                	jne    8004f3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e0:	89 c1                	mov    %eax,%ecx
  8004e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8004e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 40 04             	lea    0x4(%eax),%eax
  8004ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f1:	eb b9                	jmp    8004ac <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fb:	89 c1                	mov    %eax,%ecx
  8004fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800500:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 40 04             	lea    0x4(%eax),%eax
  800509:	89 45 14             	mov    %eax,0x14(%ebp)
  80050c:	eb 9e                	jmp    8004ac <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80050e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800511:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800514:	b8 0a 00 00 00       	mov    $0xa,%eax
  800519:	e9 c6 00 00 00       	jmp    8005e4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 f9 01             	cmp    $0x1,%ecx
  800521:	7e 18                	jle    80053b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 10                	mov    (%eax),%edx
  800528:	8b 48 04             	mov    0x4(%eax),%ecx
  80052b:	8d 40 08             	lea    0x8(%eax),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800531:	b8 0a 00 00 00       	mov    $0xa,%eax
  800536:	e9 a9 00 00 00       	jmp    8005e4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80053b:	85 c9                	test   %ecx,%ecx
  80053d:	75 1a                	jne    800559 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 10                	mov    (%eax),%edx
  800544:	b9 00 00 00 00       	mov    $0x0,%ecx
  800549:	8d 40 04             	lea    0x4(%eax),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800554:	e9 8b 00 00 00       	jmp    8005e4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 10                	mov    (%eax),%edx
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800563:	8d 40 04             	lea    0x4(%eax),%eax
  800566:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	eb 74                	jmp    8005e4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800570:	83 f9 01             	cmp    $0x1,%ecx
  800573:	7e 15                	jle    80058a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 10                	mov    (%eax),%edx
  80057a:	8b 48 04             	mov    0x4(%eax),%ecx
  80057d:	8d 40 08             	lea    0x8(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800583:	b8 08 00 00 00       	mov    $0x8,%eax
  800588:	eb 5a                	jmp    8005e4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058a:	85 c9                	test   %ecx,%ecx
  80058c:	75 17                	jne    8005a5 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 10                	mov    (%eax),%edx
  800593:	b9 00 00 00 00       	mov    $0x0,%ecx
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80059e:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a3:	eb 3f                	jmp    8005e4 <vprintfmt+0x3a6>
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

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ba:	eb 28                	jmp    8005e4 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	6a 30                	push   $0x30
  8005c2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c4:	83 c4 08             	add    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 78                	push   $0x78
  8005ca:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005df:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005eb:	57                   	push   %edi
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	50                   	push   %eax
  8005f0:	51                   	push   %ecx
  8005f1:	52                   	push   %edx
  8005f2:	89 da                	mov    %ebx,%edx
  8005f4:	89 f0                	mov    %esi,%eax
  8005f6:	e8 5d fb ff ff       	call   800158 <printnum>
			break;
  8005fb:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800601:	47                   	inc    %edi
  800602:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800606:	83 f8 25             	cmp    $0x25,%eax
  800609:	0f 84 46 fc ff ff    	je     800255 <vprintfmt+0x17>
			if (ch == '\0')
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 84 89 00 00 00    	je     8006a0 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	50                   	push   %eax
  80061c:	ff d6                	call   *%esi
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	eb de                	jmp    800601 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 15                	jle    80063d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800636:	b8 10 00 00 00       	mov    $0x10,%eax
  80063b:	eb a7                	jmp    8005e4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	75 17                	jne    800658 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800651:	b8 10 00 00 00       	mov    $0x10,%eax
  800656:	eb 8c                	jmp    8005e4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
  80066d:	e9 72 ff ff ff       	jmp    8005e4 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			break;
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	e9 7c ff ff ff       	jmp    8005fe <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 25                	push   $0x25
  800688:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	89 f8                	mov    %edi,%eax
  80068f:	eb 01                	jmp    800692 <vprintfmt+0x454>
  800691:	48                   	dec    %eax
  800692:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800696:	75 f9                	jne    800691 <vprintfmt+0x453>
  800698:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069b:	e9 5e ff ff ff       	jmp    8005fe <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a3:	5b                   	pop    %ebx
  8006a4:	5e                   	pop    %esi
  8006a5:	5f                   	pop    %edi
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    

008006a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 18             	sub    $0x18,%esp
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	74 26                	je     8006ef <vsnprintf+0x47>
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	7e 29                	jle    8006f6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cd:	ff 75 14             	pushl  0x14(%ebp)
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	68 05 02 80 00       	push   $0x800205
  8006dc:	e8 5d fb ff ff       	call   80023e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ea:	83 c4 10             	add    $0x10,%esp
}
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f4:	eb f7                	jmp    8006ed <vsnprintf+0x45>
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fb:	eb f0                	jmp    8006ed <vsnprintf+0x45>

008006fd <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	50                   	push   %eax
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	ff 75 08             	pushl  0x8(%ebp)
  800710:	e8 93 ff ff ff       	call   8006a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800715:	c9                   	leave  
  800716:	c3                   	ret    
	...

00800718 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	eb 01                	jmp    800726 <strlen+0xe>
		n++;
  800725:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072a:	75 f9                	jne    800725 <strlen+0xd>
		n++;
	return n;
}
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	eb 01                	jmp    80073f <strnlen+0x11>
		n++;
  80073e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	39 d0                	cmp    %edx,%eax
  800741:	74 06                	je     800749 <strnlen+0x1b>
  800743:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800747:	75 f5                	jne    80073e <strnlen+0x10>
		n++;
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800755:	89 c2                	mov    %eax,%edx
  800757:	41                   	inc    %ecx
  800758:	42                   	inc    %edx
  800759:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80075c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075f:	84 db                	test   %bl,%bl
  800761:	75 f4                	jne    800757 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800763:	5b                   	pop    %ebx
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076d:	53                   	push   %ebx
  80076e:	e8 a5 ff ff ff       	call   800718 <strlen>
  800773:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	01 d8                	add    %ebx,%eax
  80077b:	50                   	push   %eax
  80077c:	e8 ca ff ff ff       	call   80074b <strcpy>
	return dst;
}
  800781:	89 d8                	mov    %ebx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	89 f3                	mov    %esi,%ebx
  800795:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800798:	89 f2                	mov    %esi,%edx
  80079a:	39 da                	cmp    %ebx,%edx
  80079c:	74 0e                	je     8007ac <strncpy+0x24>
		*dst++ = *src;
  80079e:	42                   	inc    %edx
  80079f:	8a 01                	mov    (%ecx),%al
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007a4:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a7:	74 f1                	je     80079a <strncpy+0x12>
			src++;
  8007a9:	41                   	inc    %ecx
  8007aa:	eb ee                	jmp    80079a <strncpy+0x12>
	}
	return ret;
}
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	74 20                	je     8007e4 <strlcpy+0x32>
  8007c4:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8007c8:	89 f0                	mov    %esi,%eax
  8007ca:	eb 05                	jmp    8007d1 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007cc:	42                   	inc    %edx
  8007cd:	40                   	inc    %eax
  8007ce:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d1:	39 d8                	cmp    %ebx,%eax
  8007d3:	74 06                	je     8007db <strlcpy+0x29>
  8007d5:	8a 0a                	mov    (%edx),%cl
  8007d7:	84 c9                	test   %cl,%cl
  8007d9:	75 f1                	jne    8007cc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007de:	29 f0                	sub    %esi,%eax
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	eb f6                	jmp    8007de <strlcpy+0x2c>

008007e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f1:	eb 02                	jmp    8007f5 <strcmp+0xd>
		p++, q++;
  8007f3:	41                   	inc    %ecx
  8007f4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f5:	8a 01                	mov    (%ecx),%al
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x17>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 f4                	je     8007f3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 02                	jmp    80081c <strncmp+0x13>
		n--, p++, q++;
  80081a:	40                   	inc    %eax
  80081b:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	74 15                	je     800835 <strncmp+0x2c>
  800820:	8a 08                	mov    (%eax),%cl
  800822:	84 c9                	test   %cl,%cl
  800824:	74 04                	je     80082a <strncmp+0x21>
  800826:	3a 0a                	cmp    (%edx),%cl
  800828:	74 f0                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082a:	0f b6 00             	movzbl (%eax),%eax
  80082d:	0f b6 12             	movzbl (%edx),%edx
  800830:	29 d0                	sub    %edx,%eax
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	eb f6                	jmp    800832 <strncmp+0x29>

0080083c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800845:	8a 10                	mov    (%eax),%dl
  800847:	84 d2                	test   %dl,%dl
  800849:	74 07                	je     800852 <strchr+0x16>
		if (*s == c)
  80084b:	38 ca                	cmp    %cl,%dl
  80084d:	74 08                	je     800857 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084f:	40                   	inc    %eax
  800850:	eb f3                	jmp    800845 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800862:	8a 10                	mov    (%eax),%dl
  800864:	84 d2                	test   %dl,%dl
  800866:	74 07                	je     80086f <strfind+0x16>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 03                	je     80086f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	eb f3                	jmp    800862 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 13                	je     800894 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800881:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800887:	75 05                	jne    80088e <memset+0x1d>
  800889:	f6 c1 03             	test   $0x3,%cl
  80088c:	74 0d                	je     80089b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	fc                   	cld    
  800892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800894:	89 f8                	mov    %edi,%eax
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d0                	mov    %edx,%eax
  8008a6:	c1 e0 18             	shl    $0x18,%eax
  8008a9:	89 d6                	mov    %edx,%esi
  8008ab:	c1 e6 10             	shl    $0x10,%esi
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
  8008b2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b7:	89 d0                	mov    %edx,%eax
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb d6                	jmp    800894 <memset+0x23>

008008be <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cc:	39 c6                	cmp    %eax,%esi
  8008ce:	73 33                	jae    800903 <memmove+0x45>
  8008d0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d3:	39 c2                	cmp    %eax,%edx
  8008d5:	76 2c                	jbe    800903 <memmove+0x45>
		s += n;
		d += n;
  8008d7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	09 fe                	or     %edi,%esi
  8008de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e4:	74 0a                	je     8008f0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e6:	4f                   	dec    %edi
  8008e7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ea:	fd                   	std    
  8008eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ed:	fc                   	cld    
  8008ee:	eb 21                	jmp    800911 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 f1                	jne    8008e6 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb ea                	jmp    8008ed <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800903:	89 f2                	mov    %esi,%edx
  800905:	09 c2                	or     %eax,%edx
  800907:	f6 c2 03             	test   $0x3,%dl
  80090a:	74 09                	je     800915 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 f2                	jne    80090c <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb ed                	jmp    800911 <memmove+0x53>

00800924 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 89 ff ff ff       	call   8008be <memmove>
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	89 c6                	mov    %eax,%esi
  800944:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 f0                	cmp    %esi,%eax
  800949:	74 16                	je     800961 <memcmp+0x2a>
		if (*s1 != *s2)
  80094b:	8a 08                	mov    (%eax),%cl
  80094d:	8a 1a                	mov    (%edx),%bl
  80094f:	38 d9                	cmp    %bl,%cl
  800951:	75 04                	jne    800957 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800953:	40                   	inc    %eax
  800954:	42                   	inc    %edx
  800955:	eb f0                	jmp    800947 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800957:	0f b6 c1             	movzbl %cl,%eax
  80095a:	0f b6 db             	movzbl %bl,%ebx
  80095d:	29 d8                	sub    %ebx,%eax
  80095f:	eb 05                	jmp    800966 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800973:	89 c2                	mov    %eax,%edx
  800975:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800978:	39 d0                	cmp    %edx,%eax
  80097a:	73 07                	jae    800983 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097c:	38 08                	cmp    %cl,(%eax)
  80097e:	74 03                	je     800983 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800980:	40                   	inc    %eax
  800981:	eb f5                	jmp    800978 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	eb 01                	jmp    800991 <strtol+0xc>
		s++;
  800990:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800991:	8a 01                	mov    (%ecx),%al
  800993:	3c 20                	cmp    $0x20,%al
  800995:	74 f9                	je     800990 <strtol+0xb>
  800997:	3c 09                	cmp    $0x9,%al
  800999:	74 f5                	je     800990 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099b:	3c 2b                	cmp    $0x2b,%al
  80099d:	74 2b                	je     8009ca <strtol+0x45>
		s++;
	else if (*s == '-')
  80099f:	3c 2d                	cmp    $0x2d,%al
  8009a1:	74 2f                	je     8009d2 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a8:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  8009af:	75 12                	jne    8009c3 <strtol+0x3e>
  8009b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b4:	74 24                	je     8009da <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ba:	75 07                	jne    8009c3 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	eb 4e                	jmp    800a18 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  8009ca:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d0:	eb d6                	jmp    8009a8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  8009d2:	41                   	inc    %ecx
  8009d3:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d8:	eb ce                	jmp    8009a8 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009de:	74 10                	je     8009f0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009e4:	75 dd                	jne    8009c3 <strtol+0x3e>
		s++, base = 8;
  8009e6:	41                   	inc    %ecx
  8009e7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8009ee:	eb d3                	jmp    8009c3 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8009fa:	eb c7                	jmp    8009c3 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009fc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 24                	ja     800a2a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a0c:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a0f:	7e 2b                	jle    800a3c <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a11:	41                   	inc    %ecx
  800a12:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a16:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	8a 11                	mov    (%ecx),%dl
  800a1a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 da                	ja     8009fc <strtol+0x77>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb e2                	jmp    800a0c <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a2a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 37             	sub    $0x37,%edx
  800a3a:	eb d0                	jmp    800a0c <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a40:	74 05                	je     800a47 <strtol+0xc2>
		*endptr = (char *) s;
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a47:	85 ff                	test   %edi,%edi
  800a49:	74 02                	je     800a4d <strtol+0xc8>
  800a4b:	f7 d8                	neg    %eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    
	...

00800a54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a82:	89 d1                	mov    %edx,%ecx
  800a84:	89 d3                	mov    %edx,%ebx
  800a86:	89 d7                	mov    %edx,%edi
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	89 cb                	mov    %ecx,%ebx
  800aa9:	89 cf                	mov    %ecx,%edi
  800aab:	89 ce                	mov    %ecx,%esi
  800aad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	7f 08                	jg     800abb <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	50                   	push   %eax
  800abf:	6a 03                	push   $0x3
  800ac1:	68 74 0f 80 00       	push   $0x800f74
  800ac6:	6a 23                	push   $0x23
  800ac8:	68 91 0f 80 00       	push   $0x800f91
  800acd:	e8 22 00 00 00       	call   800af4 <_panic>

00800ad2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  800add:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae2:	89 d1                	mov    %edx,%ecx
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	89 d7                	mov    %edx,%edi
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    
  800af1:	00 00                	add    %al,(%eax)
	...

00800af4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800af9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800afc:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800b02:	e8 cb ff ff ff       	call   800ad2 <sys_getenvid>
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	ff 75 0c             	pushl  0xc(%ebp)
  800b0d:	ff 75 08             	pushl  0x8(%ebp)
  800b10:	56                   	push   %esi
  800b11:	50                   	push   %eax
  800b12:	68 a0 0f 80 00       	push   $0x800fa0
  800b17:	e8 28 f6 ff ff       	call   800144 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b1c:	83 c4 18             	add    $0x18,%esp
  800b1f:	53                   	push   %ebx
  800b20:	ff 75 10             	pushl  0x10(%ebp)
  800b23:	e8 cb f5 ff ff       	call   8000f3 <vcprintf>
	cprintf("\n");
  800b28:	c7 04 24 c4 0f 80 00 	movl   $0x800fc4,(%esp)
  800b2f:	e8 10 f6 ff ff       	call   800144 <cprintf>
  800b34:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b37:	cc                   	int3   
  800b38:	eb fd                	jmp    800b37 <_panic+0x43>
	...

00800b3c <__udivdi3>:
  800b3c:	55                   	push   %ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 1c             	sub    $0x1c,%esp
  800b43:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b47:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b4f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b53:	85 d2                	test   %edx,%edx
  800b55:	75 2d                	jne    800b84 <__udivdi3+0x48>
  800b57:	39 f7                	cmp    %esi,%edi
  800b59:	77 59                	ja     800bb4 <__udivdi3+0x78>
  800b5b:	89 f9                	mov    %edi,%ecx
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	75 0b                	jne    800b6c <__udivdi3+0x30>
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	31 d2                	xor    %edx,%edx
  800b68:	f7 f7                	div    %edi
  800b6a:	89 c1                	mov    %eax,%ecx
  800b6c:	31 d2                	xor    %edx,%edx
  800b6e:	89 f0                	mov    %esi,%eax
  800b70:	f7 f1                	div    %ecx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 e8                	mov    %ebp,%eax
  800b76:	f7 f1                	div    %ecx
  800b78:	89 da                	mov    %ebx,%edx
  800b7a:	83 c4 1c             	add    $0x1c,%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    
  800b82:	66 90                	xchg   %ax,%ax
  800b84:	39 f2                	cmp    %esi,%edx
  800b86:	77 1c                	ja     800ba4 <__udivdi3+0x68>
  800b88:	0f bd da             	bsr    %edx,%ebx
  800b8b:	83 f3 1f             	xor    $0x1f,%ebx
  800b8e:	75 38                	jne    800bc8 <__udivdi3+0x8c>
  800b90:	39 f2                	cmp    %esi,%edx
  800b92:	72 08                	jb     800b9c <__udivdi3+0x60>
  800b94:	39 ef                	cmp    %ebp,%edi
  800b96:	0f 87 98 00 00 00    	ja     800c34 <__udivdi3+0xf8>
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	eb 05                	jmp    800ba8 <__udivdi3+0x6c>
  800ba3:	90                   	nop
  800ba4:	31 db                	xor    %ebx,%ebx
  800ba6:	31 c0                	xor    %eax,%eax
  800ba8:	89 da                	mov    %ebx,%edx
  800baa:	83 c4 1c             	add    $0x1c,%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
  800bb2:	66 90                	xchg   %ax,%ax
  800bb4:	89 e8                	mov    %ebp,%eax
  800bb6:	89 f2                	mov    %esi,%edx
  800bb8:	f7 f7                	div    %edi
  800bba:	31 db                	xor    %ebx,%ebx
  800bbc:	89 da                	mov    %ebx,%edx
  800bbe:	83 c4 1c             	add    $0x1c,%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    
  800bc6:	66 90                	xchg   %ax,%ax
  800bc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bcd:	29 d8                	sub    %ebx,%eax
  800bcf:	88 d9                	mov    %bl,%cl
  800bd1:	d3 e2                	shl    %cl,%edx
  800bd3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bd7:	89 fa                	mov    %edi,%edx
  800bd9:	88 c1                	mov    %al,%cl
  800bdb:	d3 ea                	shr    %cl,%edx
  800bdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800be1:	09 d1                	or     %edx,%ecx
  800be3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800be7:	88 d9                	mov    %bl,%cl
  800be9:	d3 e7                	shl    %cl,%edi
  800beb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	88 c1                	mov    %al,%cl
  800bf3:	d3 ef                	shr    %cl,%edi
  800bf5:	88 d9                	mov    %bl,%cl
  800bf7:	d3 e6                	shl    %cl,%esi
  800bf9:	89 ea                	mov    %ebp,%edx
  800bfb:	88 c1                	mov    %al,%cl
  800bfd:	d3 ea                	shr    %cl,%edx
  800bff:	09 d6                	or     %edx,%esi
  800c01:	89 f0                	mov    %esi,%eax
  800c03:	89 fa                	mov    %edi,%edx
  800c05:	f7 74 24 08          	divl   0x8(%esp)
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	f7 64 24 0c          	mull   0xc(%esp)
  800c11:	39 d7                	cmp    %edx,%edi
  800c13:	72 13                	jb     800c28 <__udivdi3+0xec>
  800c15:	74 09                	je     800c20 <__udivdi3+0xe4>
  800c17:	89 f0                	mov    %esi,%eax
  800c19:	31 db                	xor    %ebx,%ebx
  800c1b:	eb 8b                	jmp    800ba8 <__udivdi3+0x6c>
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	88 d9                	mov    %bl,%cl
  800c22:	d3 e5                	shl    %cl,%ebp
  800c24:	39 c5                	cmp    %eax,%ebp
  800c26:	73 ef                	jae    800c17 <__udivdi3+0xdb>
  800c28:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c2b:	31 db                	xor    %ebx,%ebx
  800c2d:	e9 76 ff ff ff       	jmp    800ba8 <__udivdi3+0x6c>
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	31 c0                	xor    %eax,%eax
  800c36:	e9 6d ff ff ff       	jmp    800ba8 <__udivdi3+0x6c>
	...

00800c3c <__umoddi3>:
  800c3c:	55                   	push   %ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 1c             	sub    $0x1c,%esp
  800c43:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c47:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c4f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	89 da                	mov    %ebx,%edx
  800c57:	85 ed                	test   %ebp,%ebp
  800c59:	75 15                	jne    800c70 <__umoddi3+0x34>
  800c5b:	39 df                	cmp    %ebx,%edi
  800c5d:	76 39                	jbe    800c98 <__umoddi3+0x5c>
  800c5f:	f7 f7                	div    %edi
  800c61:	89 d0                	mov    %edx,%eax
  800c63:	31 d2                	xor    %edx,%edx
  800c65:	83 c4 1c             	add    $0x1c,%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	39 dd                	cmp    %ebx,%ebp
  800c72:	77 f1                	ja     800c65 <__umoddi3+0x29>
  800c74:	0f bd cd             	bsr    %ebp,%ecx
  800c77:	83 f1 1f             	xor    $0x1f,%ecx
  800c7a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c7e:	75 38                	jne    800cb8 <__umoddi3+0x7c>
  800c80:	39 dd                	cmp    %ebx,%ebp
  800c82:	72 04                	jb     800c88 <__umoddi3+0x4c>
  800c84:	39 f7                	cmp    %esi,%edi
  800c86:	77 dd                	ja     800c65 <__umoddi3+0x29>
  800c88:	89 da                	mov    %ebx,%edx
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	29 f8                	sub    %edi,%eax
  800c8e:	19 ea                	sbb    %ebp,%edx
  800c90:	83 c4 1c             	add    $0x1c,%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
  800c98:	89 f9                	mov    %edi,%ecx
  800c9a:	85 ff                	test   %edi,%edi
  800c9c:	75 0b                	jne    800ca9 <__umoddi3+0x6d>
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f7                	div    %edi
  800ca7:	89 c1                	mov    %eax,%ecx
  800ca9:	89 d8                	mov    %ebx,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f1                	div    %ecx
  800caf:	89 f0                	mov    %esi,%eax
  800cb1:	f7 f1                	div    %ecx
  800cb3:	eb ac                	jmp    800c61 <__umoddi3+0x25>
  800cb5:	8d 76 00             	lea    0x0(%esi),%esi
  800cb8:	b8 20 00 00 00       	mov    $0x20,%eax
  800cbd:	89 c2                	mov    %eax,%edx
  800cbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cc3:	29 c2                	sub    %eax,%edx
  800cc5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc9:	88 c1                	mov    %al,%cl
  800ccb:	d3 e5                	shl    %cl,%ebp
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	88 d1                	mov    %dl,%cl
  800cd1:	d3 e8                	shr    %cl,%eax
  800cd3:	09 c5                	or     %eax,%ebp
  800cd5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd9:	88 c1                	mov    %al,%cl
  800cdb:	d3 e7                	shl    %cl,%edi
  800cdd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	88 d1                	mov    %dl,%cl
  800ce5:	d3 ef                	shr    %cl,%edi
  800ce7:	88 c1                	mov    %al,%cl
  800ce9:	d3 e3                	shl    %cl,%ebx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	88 d1                	mov    %dl,%cl
  800cef:	d3 e8                	shr    %cl,%eax
  800cf1:	09 d8                	or     %ebx,%eax
  800cf3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cf7:	d3 e6                	shl    %cl,%esi
  800cf9:	89 fa                	mov    %edi,%edx
  800cfb:	f7 f5                	div    %ebp
  800cfd:	89 d1                	mov    %edx,%ecx
  800cff:	f7 64 24 08          	mull   0x8(%esp)
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	89 d7                	mov    %edx,%edi
  800d07:	39 d1                	cmp    %edx,%ecx
  800d09:	72 29                	jb     800d34 <__umoddi3+0xf8>
  800d0b:	74 23                	je     800d30 <__umoddi3+0xf4>
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	29 de                	sub    %ebx,%esi
  800d11:	19 fa                	sbb    %edi,%edx
  800d13:	89 d0                	mov    %edx,%eax
  800d15:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d19:	d3 e0                	shl    %cl,%eax
  800d1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d1f:	88 d9                	mov    %bl,%cl
  800d21:	d3 ee                	shr    %cl,%esi
  800d23:	09 f0                	or     %esi,%eax
  800d25:	d3 ea                	shr    %cl,%edx
  800d27:	83 c4 1c             	add    $0x1c,%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop
  800d30:	39 c6                	cmp    %eax,%esi
  800d32:	73 d9                	jae    800d0d <__umoddi3+0xd1>
  800d34:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d38:	19 ea                	sbb    %ebp,%edx
  800d3a:	89 d7                	mov    %edx,%edi
  800d3c:	89 c3                	mov    %eax,%ebx
  800d3e:	eb cd                	jmp    800d0d <__umoddi3+0xd1>
