
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 50 0d 80 00       	push   $0x800d50
  80003f:	e8 10 01 00 00       	call   800154 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 10 80 00       	mov    0x801004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 5e 0d 80 00       	push   $0x800d5e
  800055:	e8 fa 00 00 00       	call   800154 <cprintf>
}
  80005a:	83 c4 10             	add    $0x10,%esp
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    
	...

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 72 0a 00 00       	call   800ae2 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800078:	01 d0                	add    %edx,%eax
  80007a:	c1 e0 05             	shl    $0x5,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x32>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 e8 09 00 00       	call   800aa1 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    
	...

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	74 08                	je     8000e7 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000df:	ff 43 04             	incl   0x4(%ebx)
}
  8000e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	68 ff 00 00 00       	push   $0xff
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 6c 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	eb dc                	jmp    8000df <putch+0x1f>

00800103 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	ff 75 0c             	pushl  0xc(%ebp)
  800123:	ff 75 08             	pushl  0x8(%ebp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	50                   	push   %eax
  80012d:	68 c0 00 80 00       	push   $0x8000c0
  800132:	e8 17 01 00 00       	call   80024e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 18 09 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	50                   	push   %eax
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	e8 9d ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 1c             	sub    $0x1c,%esp
  800171:	89 c7                	mov    %eax,%edi
  800173:	89 d6                	mov    %edx,%esi
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800181:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800184:	bb 00 00 00 00       	mov    $0x0,%ebx
  800189:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018f:	39 d3                	cmp    %edx,%ebx
  800191:	72 05                	jb     800198 <printnum+0x30>
  800193:	39 45 10             	cmp    %eax,0x10(%ebp)
  800196:	77 78                	ja     800210 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	ff 75 18             	pushl  0x18(%ebp)
  80019e:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a4:	53                   	push   %ebx
  8001a5:	ff 75 10             	pushl  0x10(%ebp)
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b7:	e8 90 09 00 00       	call   800b4c <__udivdi3>
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	52                   	push   %edx
  8001c0:	50                   	push   %eax
  8001c1:	89 f2                	mov    %esi,%edx
  8001c3:	89 f8                	mov    %edi,%eax
  8001c5:	e8 9e ff ff ff       	call   800168 <printnum>
  8001ca:	83 c4 20             	add    $0x20,%esp
  8001cd:	eb 11                	jmp    8001e0 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	ff d7                	call   *%edi
  8001d8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001db:	4b                   	dec    %ebx
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7f ef                	jg     8001cf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	56                   	push   %esi
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f3:	e8 54 0a 00 00       	call   800c4c <__umoddi3>
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	0f be 80 7f 0d 80 00 	movsbl 0x800d7f(%eax),%eax
  800202:	50                   	push   %eax
  800203:	ff d7                	call   *%edi
}
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    
  800210:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800213:	eb c6                	jmp    8001db <printnum+0x73>

00800215 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	3b 50 04             	cmp    0x4(%eax),%edx
  800223:	73 0a                	jae    80022f <sprintputch+0x1a>
		*b->buf++ = ch;
  800225:	8d 4a 01             	lea    0x1(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	88 02                	mov    %al,(%edx)
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 10             	pushl  0x10(%ebp)
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 05 00 00 00       	call   80024e <vprintfmt>
	va_end(ap);
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 2c             	sub    $0x2c,%esp
  800257:	8b 75 08             	mov    0x8(%ebp),%esi
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800260:	e9 ac 03 00 00       	jmp    800611 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800265:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800269:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800270:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800277:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80027e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800283:	8d 47 01             	lea    0x1(%edi),%eax
  800286:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800289:	8a 17                	mov    (%edi),%dl
  80028b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80028e:	3c 55                	cmp    $0x55,%al
  800290:	0f 87 fc 03 00 00    	ja     800692 <vprintfmt+0x444>
  800296:	0f b6 c0             	movzbl %al,%eax
  800299:	ff 24 85 0c 0e 80 00 	jmp    *0x800e0c(,%eax,4)
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002a7:	eb da                	jmp    800283 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b0:	eb d1                	jmp    800283 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b2:	0f b6 d2             	movzbl %dl,%edx
  8002b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c3:	01 c0                	add    %eax,%eax
  8002c5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002c9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002cc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002cf:	83 f9 09             	cmp    $0x9,%ecx
  8002d2:	77 52                	ja     800326 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002d5:	eb e9                	jmp    8002c0 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002da:	8b 00                	mov    (%eax),%eax
  8002dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002df:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e2:	8d 40 04             	lea    0x4(%eax),%eax
  8002e5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002ef:	79 92                	jns    800283 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002fe:	eb 83                	jmp    800283 <vprintfmt+0x35>
  800300:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800304:	78 08                	js     80030e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800309:	e9 75 ff ff ff       	jmp    800283 <vprintfmt+0x35>
  80030e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800315:	eb ef                	jmp    800306 <vprintfmt+0xb8>
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80031a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800321:	e9 5d ff ff ff       	jmp    800283 <vprintfmt+0x35>
  800326:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800329:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80032c:	eb bd                	jmp    8002eb <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80032e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800332:	e9 4c ff ff ff       	jmp    800283 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 78 04             	lea    0x4(%eax),%edi
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	53                   	push   %ebx
  800341:	ff 30                	pushl  (%eax)
  800343:	ff d6                	call   *%esi
			break;
  800345:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800348:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80034b:	e9 be 02 00 00       	jmp    80060e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 78 04             	lea    0x4(%eax),%edi
  800356:	8b 00                	mov    (%eax),%eax
  800358:	85 c0                	test   %eax,%eax
  80035a:	78 2a                	js     800386 <vprintfmt+0x138>
  80035c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80035e:	83 f8 06             	cmp    $0x6,%eax
  800361:	7f 27                	jg     80038a <vprintfmt+0x13c>
  800363:	8b 04 85 64 0f 80 00 	mov    0x800f64(,%eax,4),%eax
  80036a:	85 c0                	test   %eax,%eax
  80036c:	74 1c                	je     80038a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80036e:	50                   	push   %eax
  80036f:	68 a0 0d 80 00       	push   $0x800da0
  800374:	53                   	push   %ebx
  800375:	56                   	push   %esi
  800376:	e8 b6 fe ff ff       	call   800231 <printfmt>
  80037b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80037e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800381:	e9 88 02 00 00       	jmp    80060e <vprintfmt+0x3c0>
  800386:	f7 d8                	neg    %eax
  800388:	eb d2                	jmp    80035c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80038a:	52                   	push   %edx
  80038b:	68 97 0d 80 00       	push   $0x800d97
  800390:	53                   	push   %ebx
  800391:	56                   	push   %esi
  800392:	e8 9a fe ff ff       	call   800231 <printfmt>
  800397:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80039d:	e9 6c 02 00 00       	jmp    80060e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	83 c0 04             	add    $0x4,%eax
  8003a8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8b 38                	mov    (%eax),%edi
  8003b0:	85 ff                	test   %edi,%edi
  8003b2:	74 18                	je     8003cc <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	0f 8e b7 00 00 00    	jle    800475 <vprintfmt+0x227>
  8003be:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003c2:	75 0f                	jne    8003d3 <vprintfmt+0x185>
  8003c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003c7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8003ca:	eb 75                	jmp    800441 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8003cc:	bf 90 0d 80 00       	mov    $0x800d90,%edi
  8003d1:	eb e1                	jmp    8003b4 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	ff 75 d0             	pushl  -0x30(%ebp)
  8003d9:	57                   	push   %edi
  8003da:	e8 5f 03 00 00       	call   80073e <strnlen>
  8003df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003e2:	29 c1                	sub    %eax,%ecx
  8003e4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003ea:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003f4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f6:	eb 0d                	jmp    800405 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	53                   	push   %ebx
  8003fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800401:	4f                   	dec    %edi
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	85 ff                	test   %edi,%edi
  800407:	7f ef                	jg     8003f8 <vprintfmt+0x1aa>
  800409:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80040c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80040f:	89 c8                	mov    %ecx,%eax
  800411:	85 c9                	test   %ecx,%ecx
  800413:	78 10                	js     800425 <vprintfmt+0x1d7>
  800415:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800418:	29 c1                	sub    %eax,%ecx
  80041a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800420:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800423:	eb 1c                	jmp    800441 <vprintfmt+0x1f3>
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	eb e9                	jmp    800415 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80042c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800430:	75 29                	jne    80045b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 0c             	pushl  0xc(%ebp)
  800438:	50                   	push   %eax
  800439:	ff d6                	call   *%esi
  80043b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043e:	ff 4d e0             	decl   -0x20(%ebp)
  800441:	47                   	inc    %edi
  800442:	8a 57 ff             	mov    -0x1(%edi),%dl
  800445:	0f be c2             	movsbl %dl,%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	74 4c                	je     800498 <vprintfmt+0x24a>
  80044c:	85 db                	test   %ebx,%ebx
  80044e:	78 dc                	js     80042c <vprintfmt+0x1de>
  800450:	4b                   	dec    %ebx
  800451:	79 d9                	jns    80042c <vprintfmt+0x1de>
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800459:	eb 2e                	jmp    800489 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80045b:	0f be d2             	movsbl %dl,%edx
  80045e:	83 ea 20             	sub    $0x20,%edx
  800461:	83 fa 5e             	cmp    $0x5e,%edx
  800464:	76 cc                	jbe    800432 <vprintfmt+0x1e4>
					putch('?', putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 0c             	pushl  0xc(%ebp)
  80046c:	6a 3f                	push   $0x3f
  80046e:	ff d6                	call   *%esi
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	eb c9                	jmp    80043e <vprintfmt+0x1f0>
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80047b:	eb c4                	jmp    800441 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	6a 20                	push   $0x20
  800483:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800485:	4f                   	dec    %edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f f0                	jg     80047d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800490:	89 45 14             	mov    %eax,0x14(%ebp)
  800493:	e9 76 01 00 00       	jmp    80060e <vprintfmt+0x3c0>
  800498:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049e:	eb e9                	jmp    800489 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a0:	83 f9 01             	cmp    $0x1,%ecx
  8004a3:	7e 3f                	jle    8004e4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8b 50 04             	mov    0x4(%eax),%edx
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 40 08             	lea    0x8(%eax),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8004bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c0:	79 5c                	jns    80051e <vprintfmt+0x2d0>
				putch('-', putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	6a 2d                	push   $0x2d
  8004c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d0:	f7 da                	neg    %edx
  8004d2:	83 d1 00             	adc    $0x0,%ecx
  8004d5:	f7 d9                	neg    %ecx
  8004d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004df:	e9 10 01 00 00       	jmp    8005f4 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	75 1b                	jne    800503 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f0:	89 c1                	mov    %eax,%ecx
  8004f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 40 04             	lea    0x4(%eax),%eax
  8004fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800501:	eb b9                	jmp    8004bc <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	89 c1                	mov    %eax,%ecx
  80050d:	c1 f9 1f             	sar    $0x1f,%ecx
  800510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 04             	lea    0x4(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	eb 9e                	jmp    8004bc <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80051e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800521:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800524:	b8 0a 00 00 00       	mov    $0xa,%eax
  800529:	e9 c6 00 00 00       	jmp    8005f4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 f9 01             	cmp    $0x1,%ecx
  800531:	7e 18                	jle    80054b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 10                	mov    (%eax),%edx
  800538:	8b 48 04             	mov    0x4(%eax),%ecx
  80053b:	8d 40 08             	lea    0x8(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800541:	b8 0a 00 00 00       	mov    $0xa,%eax
  800546:	e9 a9 00 00 00       	jmp    8005f4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	75 1a                	jne    800569 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 10                	mov    (%eax),%edx
  800554:	b9 00 00 00 00       	mov    $0x0,%ecx
  800559:	8d 40 04             	lea    0x4(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80055f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800564:	e9 8b 00 00 00       	jmp    8005f4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 74                	jmp    8005f4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 15                	jle    80059a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8b 48 04             	mov    0x4(%eax),%ecx
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800593:	b8 08 00 00 00       	mov    $0x8,%eax
  800598:	eb 5a                	jmp    8005f4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	75 17                	jne    8005b5 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a8:	8d 40 04             	lea    0x4(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b3:	eb 3f                	jmp    8005f4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ca:	eb 28                	jmp    8005f4 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 30                	push   $0x30
  8005d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d4:	83 c4 08             	add    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 78                	push   $0x78
  8005da:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005fb:	57                   	push   %edi
  8005fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ff:	50                   	push   %eax
  800600:	51                   	push   %ecx
  800601:	52                   	push   %edx
  800602:	89 da                	mov    %ebx,%edx
  800604:	89 f0                	mov    %esi,%eax
  800606:	e8 5d fb ff ff       	call   800168 <printnum>
			break;
  80060b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800611:	47                   	inc    %edi
  800612:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800616:	83 f8 25             	cmp    $0x25,%eax
  800619:	0f 84 46 fc ff ff    	je     800265 <vprintfmt+0x17>
			if (ch == '\0')
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 84 89 00 00 00    	je     8006b0 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	50                   	push   %eax
  80062c:	ff d6                	call   *%esi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb de                	jmp    800611 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800633:	83 f9 01             	cmp    $0x1,%ecx
  800636:	7e 15                	jle    80064d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	8d 40 08             	lea    0x8(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800646:	b8 10 00 00 00       	mov    $0x10,%eax
  80064b:	eb a7                	jmp    8005f4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	75 17                	jne    800668 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800661:	b8 10 00 00 00       	mov    $0x10,%eax
  800666:	eb 8c                	jmp    8005f4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
  80067d:	e9 72 ff ff ff       	jmp    8005f4 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 25                	push   $0x25
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	e9 7c ff ff ff       	jmp    80060e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 25                	push   $0x25
  800698:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	89 f8                	mov    %edi,%eax
  80069f:	eb 01                	jmp    8006a2 <vprintfmt+0x454>
  8006a1:	48                   	dec    %eax
  8006a2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a6:	75 f9                	jne    8006a1 <vprintfmt+0x453>
  8006a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ab:	e9 5e ff ff ff       	jmp    80060e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 26                	je     8006ff <vsnprintf+0x47>
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	7e 29                	jle    800706 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dd:	ff 75 14             	pushl  0x14(%ebp)
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	68 15 02 80 00       	push   $0x800215
  8006ec:	e8 5d fb ff ff       	call   80024e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	83 c4 10             	add    $0x10,%esp
}
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb f7                	jmp    8006fd <vsnprintf+0x45>
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070b:	eb f0                	jmp    8006fd <vsnprintf+0x45>

0080070d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	50                   	push   %eax
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	ff 75 0c             	pushl  0xc(%ebp)
  80071d:	ff 75 08             	pushl  0x8(%ebp)
  800720:	e8 93 ff ff ff       	call   8006b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    
	...

00800728 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	eb 01                	jmp    800736 <strlen+0xe>
		n++;
  800735:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f9                	jne    800735 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 01                	jmp    80074f <strnlen+0x11>
		n++;
  80074e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 d0                	cmp    %edx,%eax
  800751:	74 06                	je     800759 <strnlen+0x1b>
  800753:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800757:	75 f5                	jne    80074e <strnlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	89 c2                	mov    %eax,%edx
  800767:	41                   	inc    %ecx
  800768:	42                   	inc    %edx
  800769:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80076c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076f:	84 db                	test   %bl,%bl
  800771:	75 f4                	jne    800767 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800773:	5b                   	pop    %ebx
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077d:	53                   	push   %ebx
  80077e:	e8 a5 ff ff ff       	call   800728 <strlen>
  800783:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800786:	ff 75 0c             	pushl  0xc(%ebp)
  800789:	01 d8                	add    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	e8 ca ff ff ff       	call   80075b <strcpy>
	return dst;
}
  800791:	89 d8                	mov    %ebx,%eax
  800793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a3:	89 f3                	mov    %esi,%ebx
  8007a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	89 f2                	mov    %esi,%edx
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	74 0e                	je     8007bc <strncpy+0x24>
		*dst++ = *src;
  8007ae:	42                   	inc    %edx
  8007af:	8a 01                	mov    (%ecx),%al
  8007b1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007b4:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b7:	74 f1                	je     8007aa <strncpy+0x12>
			src++;
  8007b9:	41                   	inc    %ecx
  8007ba:	eb ee                	jmp    8007aa <strncpy+0x12>
	}
	return ret;
}
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 20                	je     8007f4 <strlcpy+0x32>
  8007d4:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	eb 05                	jmp    8007e1 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007dc:	42                   	inc    %edx
  8007dd:	40                   	inc    %eax
  8007de:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e1:	39 d8                	cmp    %ebx,%eax
  8007e3:	74 06                	je     8007eb <strlcpy+0x29>
  8007e5:	8a 0a                	mov    (%edx),%cl
  8007e7:	84 c9                	test   %cl,%cl
  8007e9:	75 f1                	jne    8007dc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007eb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ee:	29 f0                	sub    %esi,%eax
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	eb f6                	jmp    8007ee <strlcpy+0x2c>

008007f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800801:	eb 02                	jmp    800805 <strcmp+0xd>
		p++, q++;
  800803:	41                   	inc    %ecx
  800804:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800805:	8a 01                	mov    (%ecx),%al
  800807:	84 c0                	test   %al,%al
  800809:	74 04                	je     80080f <strcmp+0x17>
  80080b:	3a 02                	cmp    (%edx),%al
  80080d:	74 f4                	je     800803 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 c0             	movzbl %al,%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
  800823:	89 c3                	mov    %eax,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800828:	eb 02                	jmp    80082c <strncmp+0x13>
		n--, p++, q++;
  80082a:	40                   	inc    %eax
  80082b:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x2c>
  800830:	8a 08                	mov    (%eax),%cl
  800832:	84 c9                	test   %cl,%cl
  800834:	74 04                	je     80083a <strncmp+0x21>
  800836:	3a 0a                	cmp    (%edx),%cl
  800838:	74 f0                	je     80082a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 00             	movzbl (%eax),%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	eb f6                	jmp    800842 <strncmp+0x29>

0080084c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800855:	8a 10                	mov    (%eax),%dl
  800857:	84 d2                	test   %dl,%dl
  800859:	74 07                	je     800862 <strchr+0x16>
		if (*s == c)
  80085b:	38 ca                	cmp    %cl,%dl
  80085d:	74 08                	je     800867 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085f:	40                   	inc    %eax
  800860:	eb f3                	jmp    800855 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800872:	8a 10                	mov    (%eax),%dl
  800874:	84 d2                	test   %dl,%dl
  800876:	74 07                	je     80087f <strfind+0x16>
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 03                	je     80087f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80087c:	40                   	inc    %eax
  80087d:	eb f3                	jmp    800872 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	74 13                	je     8008a4 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 05                	jne    80089e <memset+0x1d>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	74 0d                	je     8008ab <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8008ab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008af:	89 d3                	mov    %edx,%ebx
  8008b1:	c1 e3 08             	shl    $0x8,%ebx
  8008b4:	89 d0                	mov    %edx,%eax
  8008b6:	c1 e0 18             	shl    $0x18,%eax
  8008b9:	89 d6                	mov    %edx,%esi
  8008bb:	c1 e6 10             	shl    $0x10,%esi
  8008be:	09 f0                	or     %esi,%eax
  8008c0:	09 c2                	or     %eax,%edx
  8008c2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	fc                   	cld    
  8008ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8008cc:	eb d6                	jmp    8008a4 <memset+0x23>

008008ce <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dc:	39 c6                	cmp    %eax,%esi
  8008de:	73 33                	jae    800913 <memmove+0x45>
  8008e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e3:	39 c2                	cmp    %eax,%edx
  8008e5:	76 2c                	jbe    800913 <memmove+0x45>
		s += n;
		d += n;
  8008e7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	09 fe                	or     %edi,%esi
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	74 0a                	je     800900 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f6:	4f                   	dec    %edi
  8008f7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	fd                   	std    
  8008fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fd:	fc                   	cld    
  8008fe:	eb 21                	jmp    800921 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 f1                	jne    8008f6 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800905:	83 ef 04             	sub    $0x4,%edi
  800908:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090e:	fd                   	std    
  80090f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800911:	eb ea                	jmp    8008fd <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800913:	89 f2                	mov    %esi,%edx
  800915:	09 c2                	or     %eax,%edx
  800917:	f6 c2 03             	test   $0x3,%dl
  80091a:	74 09                	je     800925 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	fc                   	cld    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 f2                	jne    80091c <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb ed                	jmp    800921 <memmove+0x53>

00800934 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800937:	ff 75 10             	pushl  0x10(%ebp)
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	ff 75 08             	pushl  0x8(%ebp)
  800940:	e8 89 ff ff ff       	call   8008ce <memmove>
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800952:	89 c6                	mov    %eax,%esi
  800954:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800957:	39 f0                	cmp    %esi,%eax
  800959:	74 16                	je     800971 <memcmp+0x2a>
		if (*s1 != *s2)
  80095b:	8a 08                	mov    (%eax),%cl
  80095d:	8a 1a                	mov    (%edx),%bl
  80095f:	38 d9                	cmp    %bl,%cl
  800961:	75 04                	jne    800967 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800963:	40                   	inc    %eax
  800964:	42                   	inc    %edx
  800965:	eb f0                	jmp    800957 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800967:	0f b6 c1             	movzbl %cl,%eax
  80096a:	0f b6 db             	movzbl %bl,%ebx
  80096d:	29 d8                	sub    %ebx,%eax
  80096f:	eb 05                	jmp    800976 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800983:	89 c2                	mov    %eax,%edx
  800985:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	73 07                	jae    800993 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098c:	38 08                	cmp    %cl,(%eax)
  80098e:	74 03                	je     800993 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800990:	40                   	inc    %eax
  800991:	eb f5                	jmp    800988 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099e:	eb 01                	jmp    8009a1 <strtol+0xc>
		s++;
  8009a0:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	8a 01                	mov    (%ecx),%al
  8009a3:	3c 20                	cmp    $0x20,%al
  8009a5:	74 f9                	je     8009a0 <strtol+0xb>
  8009a7:	3c 09                	cmp    $0x9,%al
  8009a9:	74 f5                	je     8009a0 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ab:	3c 2b                	cmp    $0x2b,%al
  8009ad:	74 2b                	je     8009da <strtol+0x45>
		s++;
	else if (*s == '-')
  8009af:	3c 2d                	cmp    $0x2d,%al
  8009b1:	74 2f                	je     8009e2 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b8:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  8009bf:	75 12                	jne    8009d3 <strtol+0x3e>
  8009c1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c4:	74 24                	je     8009ea <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ca:	75 07                	jne    8009d3 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	eb 4e                	jmp    800a28 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  8009da:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009db:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e0:	eb d6                	jmp    8009b8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  8009e2:	41                   	inc    %ecx
  8009e3:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e8:	eb ce                	jmp    8009b8 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	74 10                	je     800a00 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f4:	75 dd                	jne    8009d3 <strtol+0x3e>
		s++, base = 8;
  8009f6:	41                   	inc    %ecx
  8009f7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8009fe:	eb d3                	jmp    8009d3 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a00:	83 c1 02             	add    $0x2,%ecx
  800a03:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a0a:	eb c7                	jmp    8009d3 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0f:	89 f3                	mov    %esi,%ebx
  800a11:	80 fb 19             	cmp    $0x19,%bl
  800a14:	77 24                	ja     800a3a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a16:	0f be d2             	movsbl %dl,%edx
  800a19:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a1c:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a1f:	7e 2b                	jle    800a4c <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a21:	41                   	inc    %ecx
  800a22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a26:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a28:	8a 11                	mov    (%ecx),%dl
  800a2a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a2d:	80 fb 09             	cmp    $0x9,%bl
  800a30:	77 da                	ja     800a0c <strtol+0x77>
			dig = *s - '0';
  800a32:	0f be d2             	movsbl %dl,%edx
  800a35:	83 ea 30             	sub    $0x30,%edx
  800a38:	eb e2                	jmp    800a1c <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3d:	89 f3                	mov    %esi,%ebx
  800a3f:	80 fb 19             	cmp    $0x19,%bl
  800a42:	77 08                	ja     800a4c <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a44:	0f be d2             	movsbl %dl,%edx
  800a47:	83 ea 37             	sub    $0x37,%edx
  800a4a:	eb d0                	jmp    800a1c <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a50:	74 05                	je     800a57 <strtol+0xc2>
		*endptr = (char *) s;
  800a52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a55:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a57:	85 ff                	test   %edi,%edi
  800a59:	74 02                	je     800a5d <strtol+0xc8>
  800a5b:	f7 d8                	neg    %eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
	...

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7f 08                	jg     800acb <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	50                   	push   %eax
  800acf:	6a 03                	push   $0x3
  800ad1:	68 80 0f 80 00       	push   $0x800f80
  800ad6:	6a 23                	push   $0x23
  800ad8:	68 9d 0f 80 00       	push   $0x800f9d
  800add:	e8 22 00 00 00       	call   800b04 <_panic>

00800ae2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 02 00 00 00       	mov    $0x2,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    
  800b01:	00 00                	add    %al,(%eax)
	...

00800b04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b09:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b0c:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800b12:	e8 cb ff ff ff       	call   800ae2 <sys_getenvid>
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	ff 75 08             	pushl  0x8(%ebp)
  800b20:	56                   	push   %esi
  800b21:	50                   	push   %eax
  800b22:	68 ac 0f 80 00       	push   $0x800fac
  800b27:	e8 28 f6 ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b2c:	83 c4 18             	add    $0x18,%esp
  800b2f:	53                   	push   %ebx
  800b30:	ff 75 10             	pushl  0x10(%ebp)
  800b33:	e8 cb f5 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800b38:	c7 04 24 5c 0d 80 00 	movl   $0x800d5c,(%esp)
  800b3f:	e8 10 f6 ff ff       	call   800154 <cprintf>
  800b44:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b47:	cc                   	int3   
  800b48:	eb fd                	jmp    800b47 <_panic+0x43>
	...

00800b4c <__udivdi3>:
  800b4c:	55                   	push   %ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 1c             	sub    $0x1c,%esp
  800b53:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b57:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b5b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b5f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b63:	85 d2                	test   %edx,%edx
  800b65:	75 2d                	jne    800b94 <__udivdi3+0x48>
  800b67:	39 f7                	cmp    %esi,%edi
  800b69:	77 59                	ja     800bc4 <__udivdi3+0x78>
  800b6b:	89 f9                	mov    %edi,%ecx
  800b6d:	85 ff                	test   %edi,%edi
  800b6f:	75 0b                	jne    800b7c <__udivdi3+0x30>
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	31 d2                	xor    %edx,%edx
  800b78:	f7 f7                	div    %edi
  800b7a:	89 c1                	mov    %eax,%ecx
  800b7c:	31 d2                	xor    %edx,%edx
  800b7e:	89 f0                	mov    %esi,%eax
  800b80:	f7 f1                	div    %ecx
  800b82:	89 c3                	mov    %eax,%ebx
  800b84:	89 e8                	mov    %ebp,%eax
  800b86:	f7 f1                	div    %ecx
  800b88:	89 da                	mov    %ebx,%edx
  800b8a:	83 c4 1c             	add    $0x1c,%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    
  800b92:	66 90                	xchg   %ax,%ax
  800b94:	39 f2                	cmp    %esi,%edx
  800b96:	77 1c                	ja     800bb4 <__udivdi3+0x68>
  800b98:	0f bd da             	bsr    %edx,%ebx
  800b9b:	83 f3 1f             	xor    $0x1f,%ebx
  800b9e:	75 38                	jne    800bd8 <__udivdi3+0x8c>
  800ba0:	39 f2                	cmp    %esi,%edx
  800ba2:	72 08                	jb     800bac <__udivdi3+0x60>
  800ba4:	39 ef                	cmp    %ebp,%edi
  800ba6:	0f 87 98 00 00 00    	ja     800c44 <__udivdi3+0xf8>
  800bac:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb1:	eb 05                	jmp    800bb8 <__udivdi3+0x6c>
  800bb3:	90                   	nop
  800bb4:	31 db                	xor    %ebx,%ebx
  800bb6:	31 c0                	xor    %eax,%eax
  800bb8:	89 da                	mov    %ebx,%edx
  800bba:	83 c4 1c             	add    $0x1c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    
  800bc2:	66 90                	xchg   %ax,%ax
  800bc4:	89 e8                	mov    %ebp,%eax
  800bc6:	89 f2                	mov    %esi,%edx
  800bc8:	f7 f7                	div    %edi
  800bca:	31 db                	xor    %ebx,%ebx
  800bcc:	89 da                	mov    %ebx,%edx
  800bce:	83 c4 1c             	add    $0x1c,%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    
  800bd6:	66 90                	xchg   %ax,%ax
  800bd8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bdd:	29 d8                	sub    %ebx,%eax
  800bdf:	88 d9                	mov    %bl,%cl
  800be1:	d3 e2                	shl    %cl,%edx
  800be3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800be7:	89 fa                	mov    %edi,%edx
  800be9:	88 c1                	mov    %al,%cl
  800beb:	d3 ea                	shr    %cl,%edx
  800bed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bf1:	09 d1                	or     %edx,%ecx
  800bf3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bf7:	88 d9                	mov    %bl,%cl
  800bf9:	d3 e7                	shl    %cl,%edi
  800bfb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bff:	89 f7                	mov    %esi,%edi
  800c01:	88 c1                	mov    %al,%cl
  800c03:	d3 ef                	shr    %cl,%edi
  800c05:	88 d9                	mov    %bl,%cl
  800c07:	d3 e6                	shl    %cl,%esi
  800c09:	89 ea                	mov    %ebp,%edx
  800c0b:	88 c1                	mov    %al,%cl
  800c0d:	d3 ea                	shr    %cl,%edx
  800c0f:	09 d6                	or     %edx,%esi
  800c11:	89 f0                	mov    %esi,%eax
  800c13:	89 fa                	mov    %edi,%edx
  800c15:	f7 74 24 08          	divl   0x8(%esp)
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 c6                	mov    %eax,%esi
  800c1d:	f7 64 24 0c          	mull   0xc(%esp)
  800c21:	39 d7                	cmp    %edx,%edi
  800c23:	72 13                	jb     800c38 <__udivdi3+0xec>
  800c25:	74 09                	je     800c30 <__udivdi3+0xe4>
  800c27:	89 f0                	mov    %esi,%eax
  800c29:	31 db                	xor    %ebx,%ebx
  800c2b:	eb 8b                	jmp    800bb8 <__udivdi3+0x6c>
  800c2d:	8d 76 00             	lea    0x0(%esi),%esi
  800c30:	88 d9                	mov    %bl,%cl
  800c32:	d3 e5                	shl    %cl,%ebp
  800c34:	39 c5                	cmp    %eax,%ebp
  800c36:	73 ef                	jae    800c27 <__udivdi3+0xdb>
  800c38:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c3b:	31 db                	xor    %ebx,%ebx
  800c3d:	e9 76 ff ff ff       	jmp    800bb8 <__udivdi3+0x6c>
  800c42:	66 90                	xchg   %ax,%ax
  800c44:	31 c0                	xor    %eax,%eax
  800c46:	e9 6d ff ff ff       	jmp    800bb8 <__udivdi3+0x6c>
	...

00800c4c <__umoddi3>:
  800c4c:	55                   	push   %ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 1c             	sub    $0x1c,%esp
  800c53:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c57:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c5b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c5f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	89 da                	mov    %ebx,%edx
  800c67:	85 ed                	test   %ebp,%ebp
  800c69:	75 15                	jne    800c80 <__umoddi3+0x34>
  800c6b:	39 df                	cmp    %ebx,%edi
  800c6d:	76 39                	jbe    800ca8 <__umoddi3+0x5c>
  800c6f:	f7 f7                	div    %edi
  800c71:	89 d0                	mov    %edx,%eax
  800c73:	31 d2                	xor    %edx,%edx
  800c75:	83 c4 1c             	add    $0x1c,%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
  800c7d:	8d 76 00             	lea    0x0(%esi),%esi
  800c80:	39 dd                	cmp    %ebx,%ebp
  800c82:	77 f1                	ja     800c75 <__umoddi3+0x29>
  800c84:	0f bd cd             	bsr    %ebp,%ecx
  800c87:	83 f1 1f             	xor    $0x1f,%ecx
  800c8a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c8e:	75 38                	jne    800cc8 <__umoddi3+0x7c>
  800c90:	39 dd                	cmp    %ebx,%ebp
  800c92:	72 04                	jb     800c98 <__umoddi3+0x4c>
  800c94:	39 f7                	cmp    %esi,%edi
  800c96:	77 dd                	ja     800c75 <__umoddi3+0x29>
  800c98:	89 da                	mov    %ebx,%edx
  800c9a:	89 f0                	mov    %esi,%eax
  800c9c:	29 f8                	sub    %edi,%eax
  800c9e:	19 ea                	sbb    %ebp,%edx
  800ca0:	83 c4 1c             	add    $0x1c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    
  800ca8:	89 f9                	mov    %edi,%ecx
  800caa:	85 ff                	test   %edi,%edi
  800cac:	75 0b                	jne    800cb9 <__umoddi3+0x6d>
  800cae:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb3:	31 d2                	xor    %edx,%edx
  800cb5:	f7 f7                	div    %edi
  800cb7:	89 c1                	mov    %eax,%ecx
  800cb9:	89 d8                	mov    %ebx,%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	f7 f1                	div    %ecx
  800cbf:	89 f0                	mov    %esi,%eax
  800cc1:	f7 f1                	div    %ecx
  800cc3:	eb ac                	jmp    800c71 <__umoddi3+0x25>
  800cc5:	8d 76 00             	lea    0x0(%esi),%esi
  800cc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd3:	29 c2                	sub    %eax,%edx
  800cd5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cd9:	88 c1                	mov    %al,%cl
  800cdb:	d3 e5                	shl    %cl,%ebp
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	88 d1                	mov    %dl,%cl
  800ce1:	d3 e8                	shr    %cl,%eax
  800ce3:	09 c5                	or     %eax,%ebp
  800ce5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ce9:	88 c1                	mov    %al,%cl
  800ceb:	d3 e7                	shl    %cl,%edi
  800ced:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	88 d1                	mov    %dl,%cl
  800cf5:	d3 ef                	shr    %cl,%edi
  800cf7:	88 c1                	mov    %al,%cl
  800cf9:	d3 e3                	shl    %cl,%ebx
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	88 d1                	mov    %dl,%cl
  800cff:	d3 e8                	shr    %cl,%eax
  800d01:	09 d8                	or     %ebx,%eax
  800d03:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d07:	d3 e6                	shl    %cl,%esi
  800d09:	89 fa                	mov    %edi,%edx
  800d0b:	f7 f5                	div    %ebp
  800d0d:	89 d1                	mov    %edx,%ecx
  800d0f:	f7 64 24 08          	mull   0x8(%esp)
  800d13:	89 c3                	mov    %eax,%ebx
  800d15:	89 d7                	mov    %edx,%edi
  800d17:	39 d1                	cmp    %edx,%ecx
  800d19:	72 29                	jb     800d44 <__umoddi3+0xf8>
  800d1b:	74 23                	je     800d40 <__umoddi3+0xf4>
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	29 de                	sub    %ebx,%esi
  800d21:	19 fa                	sbb    %edi,%edx
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d29:	d3 e0                	shl    %cl,%eax
  800d2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d2f:	88 d9                	mov    %bl,%cl
  800d31:	d3 ee                	shr    %cl,%esi
  800d33:	09 f0                	or     %esi,%eax
  800d35:	d3 ea                	shr    %cl,%edx
  800d37:	83 c4 1c             	add    $0x1c,%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
  800d3f:	90                   	nop
  800d40:	39 c6                	cmp    %eax,%esi
  800d42:	73 d9                	jae    800d1d <__umoddi3+0xd1>
  800d44:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d48:	19 ea                	sbb    %ebp,%edx
  800d4a:	89 d7                	mov    %edx,%edi
  800d4c:	89 c3                	mov    %eax,%ebx
  800d4e:	eb cd                	jmp    800d1d <__umoddi3+0xd1>
