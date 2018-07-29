
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003a:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	50                   	push   %eax
  800052:	68 54 0d 80 00       	push   $0x800d54
  800057:	e8 fc 00 00 00       	call   800158 <cprintf>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    
  800061:	00 00                	add    %al,(%eax)
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006f:	e8 72 0a 00 00       	call   800ae6 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	8d 14 00             	lea    (%eax,%eax,1),%edx
  80007c:	01 d0                	add    %edx,%eax
  80007e:	c1 e0 05             	shl    $0x5,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 db                	test   %ebx,%ebx
  80008d:	7e 07                	jle    800096 <libmain+0x32>
		binaryname = argv[0];
  80008f:	8b 06                	mov    (%esi),%eax
  800091:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 e8 09 00 00       	call   800aa5 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    
	...

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 04             	sub    $0x4,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 13                	mov    (%ebx),%edx
  8000d0:	8d 42 01             	lea    0x1(%edx),%eax
  8000d3:	89 03                	mov    %eax,(%ebx)
  8000d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e1:	74 08                	je     8000eb <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e3:	ff 43 04             	incl   0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	68 ff 00 00 00       	push   $0xff
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	50                   	push   %eax
  8000f7:	e8 6c 09 00 00       	call   800a68 <sys_cputs>
		b->idx = 0;
  8000fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	eb dc                	jmp    8000e3 <putch+0x1f>

00800107 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	ff 75 0c             	pushl  0xc(%ebp)
  800127:	ff 75 08             	pushl  0x8(%ebp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	50                   	push   %eax
  800131:	68 c4 00 80 00       	push   $0x8000c4
  800136:	e8 17 01 00 00       	call   800252 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800144:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 18 09 00 00       	call   800a68 <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	50                   	push   %eax
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	e8 9d ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 1c             	sub    $0x1c,%esp
  800175:	89 c7                	mov    %eax,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800182:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800185:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800190:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800193:	39 d3                	cmp    %edx,%ebx
  800195:	72 05                	jb     80019c <printnum+0x30>
  800197:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019a:	77 78                	ja     800214 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 18             	pushl  0x18(%ebp)
  8001a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a8:	53                   	push   %ebx
  8001a9:	ff 75 10             	pushl  0x10(%ebp)
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bb:	e8 90 09 00 00       	call   800b50 <__udivdi3>
  8001c0:	83 c4 18             	add    $0x18,%esp
  8001c3:	52                   	push   %edx
  8001c4:	50                   	push   %eax
  8001c5:	89 f2                	mov    %esi,%edx
  8001c7:	89 f8                	mov    %edi,%eax
  8001c9:	e8 9e ff ff ff       	call   80016c <printnum>
  8001ce:	83 c4 20             	add    $0x20,%esp
  8001d1:	eb 11                	jmp    8001e4 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	56                   	push   %esi
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	ff d7                	call   *%edi
  8001dc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	4b                   	dec    %ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f ef                	jg     8001d3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 54 0a 00 00       	call   800c50 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 6c 0d 80 00 	movsbl 0x800d6c(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    
  800214:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800217:	eb c6                	jmp    8001df <printnum+0x73>

00800219 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800222:	8b 10                	mov    (%eax),%edx
  800224:	3b 50 04             	cmp    0x4(%eax),%edx
  800227:	73 0a                	jae    800233 <sprintputch+0x1a>
		*b->buf++ = ch;
  800229:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	88 02                	mov    %al,(%edx)
}
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    

00800235 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	e8 05 00 00 00       	call   800252 <vprintfmt>
	va_end(ap);
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 2c             	sub    $0x2c,%esp
  80025b:	8b 75 08             	mov    0x8(%ebp),%esi
  80025e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800261:	8b 7d 10             	mov    0x10(%ebp),%edi
  800264:	e9 ac 03 00 00       	jmp    800615 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800269:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80026d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800274:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80027b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800287:	8d 47 01             	lea    0x1(%edi),%eax
  80028a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028d:	8a 17                	mov    (%edi),%dl
  80028f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800292:	3c 55                	cmp    $0x55,%al
  800294:	0f 87 fc 03 00 00    	ja     800696 <vprintfmt+0x444>
  80029a:	0f b6 c0             	movzbl %al,%eax
  80029d:	ff 24 85 fc 0d 80 00 	jmp    *0x800dfc(,%eax,4)
  8002a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ab:	eb da                	jmp    800287 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b4:	eb d1                	jmp    800287 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b6:	0f b6 d2             	movzbl %dl,%edx
  8002b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c7:	01 c0                	add    %eax,%eax
  8002c9:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d3:	83 f9 09             	cmp    $0x9,%ecx
  8002d6:	77 52                	ja     80032a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d8:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002d9:	eb e9                	jmp    8002c4 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002db:	8b 45 14             	mov    0x14(%ebp),%eax
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8d 40 04             	lea    0x4(%eax),%eax
  8002e9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f3:	79 92                	jns    800287 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800302:	eb 83                	jmp    800287 <vprintfmt+0x35>
  800304:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800308:	78 08                	js     800312 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030d:	e9 75 ff ff ff       	jmp    800287 <vprintfmt+0x35>
  800312:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800319:	eb ef                	jmp    80030a <vprintfmt+0xb8>
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80031e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800325:	e9 5d ff ff ff       	jmp    800287 <vprintfmt+0x35>
  80032a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800330:	eb bd                	jmp    8002ef <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800332:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800336:	e9 4c ff ff ff       	jmp    800287 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 78 04             	lea    0x4(%eax),%edi
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	ff 30                	pushl  (%eax)
  800347:	ff d6                	call   *%esi
			break;
  800349:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80034c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80034f:	e9 be 02 00 00       	jmp    800612 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800354:	8b 45 14             	mov    0x14(%ebp),%eax
  800357:	8d 78 04             	lea    0x4(%eax),%edi
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	85 c0                	test   %eax,%eax
  80035e:	78 2a                	js     80038a <vprintfmt+0x138>
  800360:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800362:	83 f8 06             	cmp    $0x6,%eax
  800365:	7f 27                	jg     80038e <vprintfmt+0x13c>
  800367:	8b 04 85 54 0f 80 00 	mov    0x800f54(,%eax,4),%eax
  80036e:	85 c0                	test   %eax,%eax
  800370:	74 1c                	je     80038e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800372:	50                   	push   %eax
  800373:	68 8d 0d 80 00       	push   $0x800d8d
  800378:	53                   	push   %ebx
  800379:	56                   	push   %esi
  80037a:	e8 b6 fe ff ff       	call   800235 <printfmt>
  80037f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800382:	89 7d 14             	mov    %edi,0x14(%ebp)
  800385:	e9 88 02 00 00       	jmp    800612 <vprintfmt+0x3c0>
  80038a:	f7 d8                	neg    %eax
  80038c:	eb d2                	jmp    800360 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80038e:	52                   	push   %edx
  80038f:	68 84 0d 80 00       	push   $0x800d84
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 9a fe ff ff       	call   800235 <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a1:	e9 6c 02 00 00       	jmp    800612 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	83 c0 04             	add    $0x4,%eax
  8003ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8b 38                	mov    (%eax),%edi
  8003b4:	85 ff                	test   %edi,%edi
  8003b6:	74 18                	je     8003d0 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bc:	0f 8e b7 00 00 00    	jle    800479 <vprintfmt+0x227>
  8003c2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003c6:	75 0f                	jne    8003d7 <vprintfmt+0x185>
  8003c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8003ce:	eb 75                	jmp    800445 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8003d0:	bf 7d 0d 80 00       	mov    $0x800d7d,%edi
  8003d5:	eb e1                	jmp    8003b8 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	ff 75 d0             	pushl  -0x30(%ebp)
  8003dd:	57                   	push   %edi
  8003de:	e8 5f 03 00 00       	call   800742 <strnlen>
  8003e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003e6:	29 c1                	sub    %eax,%ecx
  8003e8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fa:	eb 0d                	jmp    800409 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8003fc:	83 ec 08             	sub    $0x8,%esp
  8003ff:	53                   	push   %ebx
  800400:	ff 75 e0             	pushl  -0x20(%ebp)
  800403:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800405:	4f                   	dec    %edi
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	85 ff                	test   %edi,%edi
  80040b:	7f ef                	jg     8003fc <vprintfmt+0x1aa>
  80040d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800410:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800413:	89 c8                	mov    %ecx,%eax
  800415:	85 c9                	test   %ecx,%ecx
  800417:	78 10                	js     800429 <vprintfmt+0x1d7>
  800419:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80041c:	29 c1                	sub    %eax,%ecx
  80041e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800421:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800424:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800427:	eb 1c                	jmp    800445 <vprintfmt+0x1f3>
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	eb e9                	jmp    800419 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800430:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800434:	75 29                	jne    80045f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	ff 75 0c             	pushl  0xc(%ebp)
  80043c:	50                   	push   %eax
  80043d:	ff d6                	call   *%esi
  80043f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800442:	ff 4d e0             	decl   -0x20(%ebp)
  800445:	47                   	inc    %edi
  800446:	8a 57 ff             	mov    -0x1(%edi),%dl
  800449:	0f be c2             	movsbl %dl,%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	74 4c                	je     80049c <vprintfmt+0x24a>
  800450:	85 db                	test   %ebx,%ebx
  800452:	78 dc                	js     800430 <vprintfmt+0x1de>
  800454:	4b                   	dec    %ebx
  800455:	79 d9                	jns    800430 <vprintfmt+0x1de>
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80045d:	eb 2e                	jmp    80048d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80045f:	0f be d2             	movsbl %dl,%edx
  800462:	83 ea 20             	sub    $0x20,%edx
  800465:	83 fa 5e             	cmp    $0x5e,%edx
  800468:	76 cc                	jbe    800436 <vprintfmt+0x1e4>
					putch('?', putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	6a 3f                	push   $0x3f
  800472:	ff d6                	call   *%esi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	eb c9                	jmp    800442 <vprintfmt+0x1f0>
  800479:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80047f:	eb c4                	jmp    800445 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	53                   	push   %ebx
  800485:	6a 20                	push   $0x20
  800487:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800489:	4f                   	dec    %edi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 ff                	test   %edi,%edi
  80048f:	7f f0                	jg     800481 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800494:	89 45 14             	mov    %eax,0x14(%ebp)
  800497:	e9 76 01 00 00       	jmp    800612 <vprintfmt+0x3c0>
  80049c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a2:	eb e9                	jmp    80048d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a4:	83 f9 01             	cmp    $0x1,%ecx
  8004a7:	7e 3f                	jle    8004e8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8b 50 04             	mov    0x4(%eax),%edx
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 40 08             	lea    0x8(%eax),%eax
  8004bd:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8004c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c4:	79 5c                	jns    800522 <vprintfmt+0x2d0>
				putch('-', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	6a 2d                	push   $0x2d
  8004cc:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d4:	f7 da                	neg    %edx
  8004d6:	83 d1 00             	adc    $0x0,%ecx
  8004d9:	f7 d9                	neg    %ecx
  8004db:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004e3:	e9 10 01 00 00       	jmp    8005f8 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8004e8:	85 c9                	test   %ecx,%ecx
  8004ea:	75 1b                	jne    800507 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	89 c1                	mov    %eax,%ecx
  8004f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 40 04             	lea    0x4(%eax),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	eb b9                	jmp    8004c0 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050f:	89 c1                	mov    %eax,%ecx
  800511:	c1 f9 1f             	sar    $0x1f,%ecx
  800514:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 40 04             	lea    0x4(%eax),%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
  800520:	eb 9e                	jmp    8004c0 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800528:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052d:	e9 c6 00 00 00       	jmp    8005f8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7e 18                	jle    80054f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	8b 48 04             	mov    0x4(%eax),%ecx
  80053f:	8d 40 08             	lea    0x8(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800545:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054a:	e9 a9 00 00 00       	jmp    8005f8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	75 1a                	jne    80056d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8b 10                	mov    (%eax),%edx
  800558:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055d:	8d 40 04             	lea    0x4(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800563:	b8 0a 00 00 00       	mov    $0xa,%eax
  800568:	e9 8b 00 00 00       	jmp    8005f8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 10                	mov    (%eax),%edx
  800572:	b9 00 00 00 00       	mov    $0x0,%ecx
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800582:	eb 74                	jmp    8005f8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7e 15                	jle    80059e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	8b 48 04             	mov    0x4(%eax),%ecx
  800591:	8d 40 08             	lea    0x8(%eax),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800597:	b8 08 00 00 00       	mov    $0x8,%eax
  80059c:	eb 5a                	jmp    8005f8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	75 17                	jne    8005b9 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b7:	eb 3f                	jmp    8005f8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ce:	eb 28                	jmp    8005f8 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 30                	push   $0x30
  8005d6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d8:	83 c4 08             	add    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 78                	push   $0x78
  8005de:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ea:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f3:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005ff:	57                   	push   %edi
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	50                   	push   %eax
  800604:	51                   	push   %ecx
  800605:	52                   	push   %edx
  800606:	89 da                	mov    %ebx,%edx
  800608:	89 f0                	mov    %esi,%eax
  80060a:	e8 5d fb ff ff       	call   80016c <printnum>
			break;
  80060f:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	47                   	inc    %edi
  800616:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061a:	83 f8 25             	cmp    $0x25,%eax
  80061d:	0f 84 46 fc ff ff    	je     800269 <vprintfmt+0x17>
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 89 00 00 00    	je     8006b4 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb de                	jmp    800615 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7e 15                	jle    800651 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	8b 48 04             	mov    0x4(%eax),%ecx
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
  80064f:	eb a7                	jmp    8005f8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800651:	85 c9                	test   %ecx,%ecx
  800653:	75 17                	jne    80066c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
  80066a:	eb 8c                	jmp    8005f8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
  800681:	e9 72 ff ff ff       	jmp    8005f8 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 25                	push   $0x25
  80068c:	ff d6                	call   *%esi
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	e9 7c ff ff ff       	jmp    800612 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 25                	push   $0x25
  80069c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	89 f8                	mov    %edi,%eax
  8006a3:	eb 01                	jmp    8006a6 <vprintfmt+0x454>
  8006a5:	48                   	dec    %eax
  8006a6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006aa:	75 f9                	jne    8006a5 <vprintfmt+0x453>
  8006ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006af:	e9 5e ff ff ff       	jmp    800612 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5e                   	pop    %esi
  8006b9:	5f                   	pop    %edi
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 26                	je     800703 <vsnprintf+0x47>
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	7e 29                	jle    80070a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e1:	ff 75 14             	pushl  0x14(%ebp)
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	68 19 02 80 00       	push   $0x800219
  8006f0:	e8 5d fb ff ff       	call   800252 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fe:	83 c4 10             	add    $0x10,%esp
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800708:	eb f7                	jmp    800701 <vsnprintf+0x45>
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb f0                	jmp    800701 <vsnprintf+0x45>

00800711 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071a:	50                   	push   %eax
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	ff 75 08             	pushl  0x8(%ebp)
  800724:	e8 93 ff ff ff       	call   8006bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    
	...

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	eb 01                	jmp    80073a <strlen+0xe>
		n++;
  800739:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073e:	75 f9                	jne    800739 <strlen+0xd>
		n++;
	return n;
}
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 01                	jmp    800753 <strnlen+0x11>
		n++;
  800752:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	39 d0                	cmp    %edx,%eax
  800755:	74 06                	je     80075d <strnlen+0x1b>
  800757:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075b:	75 f5                	jne    800752 <strnlen+0x10>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800769:	89 c2                	mov    %eax,%edx
  80076b:	41                   	inc    %ecx
  80076c:	42                   	inc    %edx
  80076d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800770:	88 5a ff             	mov    %bl,-0x1(%edx)
  800773:	84 db                	test   %bl,%bl
  800775:	75 f4                	jne    80076b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800781:	53                   	push   %ebx
  800782:	e8 a5 ff ff ff       	call   80072c <strlen>
  800787:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	01 d8                	add    %ebx,%eax
  80078f:	50                   	push   %eax
  800790:	e8 ca ff ff ff       	call   80075f <strcpy>
	return dst;
}
  800795:	89 d8                	mov    %ebx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	89 f3                	mov    %esi,%ebx
  8007a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	39 da                	cmp    %ebx,%edx
  8007b0:	74 0e                	je     8007c0 <strncpy+0x24>
		*dst++ = *src;
  8007b2:	42                   	inc    %edx
  8007b3:	8a 01                	mov    (%ecx),%al
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007b8:	80 39 00             	cmpb   $0x0,(%ecx)
  8007bb:	74 f1                	je     8007ae <strncpy+0x12>
			src++;
  8007bd:	41                   	inc    %ecx
  8007be:	eb ee                	jmp    8007ae <strncpy+0x12>
	}
	return ret;
}
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	74 20                	je     8007f8 <strlcpy+0x32>
  8007d8:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	eb 05                	jmp    8007e5 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e0:	42                   	inc    %edx
  8007e1:	40                   	inc    %eax
  8007e2:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e5:	39 d8                	cmp    %ebx,%eax
  8007e7:	74 06                	je     8007ef <strlcpy+0x29>
  8007e9:	8a 0a                	mov    (%edx),%cl
  8007eb:	84 c9                	test   %cl,%cl
  8007ed:	75 f1                	jne    8007e0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f2:	29 f0                	sub    %esi,%eax
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    
  8007f8:	89 f0                	mov    %esi,%eax
  8007fa:	eb f6                	jmp    8007f2 <strlcpy+0x2c>

008007fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800805:	eb 02                	jmp    800809 <strcmp+0xd>
		p++, q++;
  800807:	41                   	inc    %ecx
  800808:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800809:	8a 01                	mov    (%ecx),%al
  80080b:	84 c0                	test   %al,%al
  80080d:	74 04                	je     800813 <strcmp+0x17>
  80080f:	3a 02                	cmp    (%edx),%al
  800811:	74 f4                	je     800807 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 c0             	movzbl %al,%eax
  800816:	0f b6 12             	movzbl (%edx),%edx
  800819:	29 d0                	sub    %edx,%eax
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	89 c3                	mov    %eax,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082c:	eb 02                	jmp    800830 <strncmp+0x13>
		n--, p++, q++;
  80082e:	40                   	inc    %eax
  80082f:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800830:	39 d8                	cmp    %ebx,%eax
  800832:	74 15                	je     800849 <strncmp+0x2c>
  800834:	8a 08                	mov    (%eax),%cl
  800836:	84 c9                	test   %cl,%cl
  800838:	74 04                	je     80083e <strncmp+0x21>
  80083a:	3a 0a                	cmp    (%edx),%cl
  80083c:	74 f0                	je     80082e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083e:	0f b6 00             	movzbl (%eax),%eax
  800841:	0f b6 12             	movzbl (%edx),%edx
  800844:	29 d0                	sub    %edx,%eax
}
  800846:	5b                   	pop    %ebx
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
  80084e:	eb f6                	jmp    800846 <strncmp+0x29>

00800850 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800859:	8a 10                	mov    (%eax),%dl
  80085b:	84 d2                	test   %dl,%dl
  80085d:	74 07                	je     800866 <strchr+0x16>
		if (*s == c)
  80085f:	38 ca                	cmp    %cl,%dl
  800861:	74 08                	je     80086b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800863:	40                   	inc    %eax
  800864:	eb f3                	jmp    800859 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800876:	8a 10                	mov    (%eax),%dl
  800878:	84 d2                	test   %dl,%dl
  80087a:	74 07                	je     800883 <strfind+0x16>
		if (*s == c)
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	74 03                	je     800883 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800880:	40                   	inc    %eax
  800881:	eb f3                	jmp    800876 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	57                   	push   %edi
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	74 13                	je     8008a8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800895:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089b:	75 05                	jne    8008a2 <memset+0x1d>
  80089d:	f6 c1 03             	test   $0x3,%cl
  8008a0:	74 0d                	je     8008af <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a5:	fc                   	cld    
  8008a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a8:	89 f8                	mov    %edi,%eax
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8008af:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b3:	89 d3                	mov    %edx,%ebx
  8008b5:	c1 e3 08             	shl    $0x8,%ebx
  8008b8:	89 d0                	mov    %edx,%eax
  8008ba:	c1 e0 18             	shl    $0x18,%eax
  8008bd:	89 d6                	mov    %edx,%esi
  8008bf:	c1 e6 10             	shl    $0x10,%esi
  8008c2:	09 f0                	or     %esi,%eax
  8008c4:	09 c2                	or     %eax,%edx
  8008c6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cb:	89 d0                	mov    %edx,%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb d6                	jmp    8008a8 <memset+0x23>

008008d2 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e0:	39 c6                	cmp    %eax,%esi
  8008e2:	73 33                	jae    800917 <memmove+0x45>
  8008e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	76 2c                	jbe    800917 <memmove+0x45>
		s += n;
		d += n;
  8008eb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	09 fe                	or     %edi,%esi
  8008f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f8:	74 0a                	je     800904 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fa:	4f                   	dec    %edi
  8008fb:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fe:	fd                   	std    
  8008ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800901:	fc                   	cld    
  800902:	eb 21                	jmp    800925 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 f1                	jne    8008fa <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800909:	83 ef 04             	sub    $0x4,%edi
  80090c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800912:	fd                   	std    
  800913:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800915:	eb ea                	jmp    800901 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800917:	89 f2                	mov    %esi,%edx
  800919:	09 c2                	or     %eax,%edx
  80091b:	f6 c2 03             	test   $0x3,%dl
  80091e:	74 09                	je     800929 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 f2                	jne    800920 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800931:	89 c7                	mov    %eax,%edi
  800933:	fc                   	cld    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb ed                	jmp    800925 <memmove+0x53>

00800938 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093b:	ff 75 10             	pushl  0x10(%ebp)
  80093e:	ff 75 0c             	pushl  0xc(%ebp)
  800941:	ff 75 08             	pushl  0x8(%ebp)
  800944:	e8 89 ff ff ff       	call   8008d2 <memmove>
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	89 c6                	mov    %eax,%esi
  800958:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	39 f0                	cmp    %esi,%eax
  80095d:	74 16                	je     800975 <memcmp+0x2a>
		if (*s1 != *s2)
  80095f:	8a 08                	mov    (%eax),%cl
  800961:	8a 1a                	mov    (%edx),%bl
  800963:	38 d9                	cmp    %bl,%cl
  800965:	75 04                	jne    80096b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800967:	40                   	inc    %eax
  800968:	42                   	inc    %edx
  800969:	eb f0                	jmp    80095b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  80096b:	0f b6 c1             	movzbl %cl,%eax
  80096e:	0f b6 db             	movzbl %bl,%ebx
  800971:	29 d8                	sub    %ebx,%eax
  800973:	eb 05                	jmp    80097a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800987:	89 c2                	mov    %eax,%edx
  800989:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	73 07                	jae    800997 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800990:	38 08                	cmp    %cl,(%eax)
  800992:	74 03                	je     800997 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800994:	40                   	inc    %eax
  800995:	eb f5                	jmp    80098c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 01                	jmp    8009a5 <strtol+0xc>
		s++;
  8009a4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a5:	8a 01                	mov    (%ecx),%al
  8009a7:	3c 20                	cmp    $0x20,%al
  8009a9:	74 f9                	je     8009a4 <strtol+0xb>
  8009ab:	3c 09                	cmp    $0x9,%al
  8009ad:	74 f5                	je     8009a4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009af:	3c 2b                	cmp    $0x2b,%al
  8009b1:	74 2b                	je     8009de <strtol+0x45>
		s++;
	else if (*s == '-')
  8009b3:	3c 2d                	cmp    $0x2d,%al
  8009b5:	74 2f                	je     8009e6 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bc:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  8009c3:	75 12                	jne    8009d7 <strtol+0x3e>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	74 24                	je     8009ee <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ce:	75 07                	jne    8009d7 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb 4e                	jmp    800a2c <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  8009de:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009df:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e4:	eb d6                	jmp    8009bc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  8009e6:	41                   	inc    %ecx
  8009e7:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ec:	eb ce                	jmp    8009bc <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f2:	74 10                	je     800a04 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f8:	75 dd                	jne    8009d7 <strtol+0x3e>
		s++, base = 8;
  8009fa:	41                   	inc    %ecx
  8009fb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a02:	eb d3                	jmp    8009d7 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a04:	83 c1 02             	add    $0x2,%ecx
  800a07:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a0e:	eb c7                	jmp    8009d7 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 24                	ja     800a3e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a20:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a23:	7e 2b                	jle    800a50 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a25:	41                   	inc    %ecx
  800a26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2a:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	8a 11                	mov    (%ecx),%dl
  800a2e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a31:	80 fb 09             	cmp    $0x9,%bl
  800a34:	77 da                	ja     800a10 <strtol+0x77>
			dig = *s - '0';
  800a36:	0f be d2             	movsbl %dl,%edx
  800a39:	83 ea 30             	sub    $0x30,%edx
  800a3c:	eb e2                	jmp    800a20 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a41:	89 f3                	mov    %esi,%ebx
  800a43:	80 fb 19             	cmp    $0x19,%bl
  800a46:	77 08                	ja     800a50 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a48:	0f be d2             	movsbl %dl,%edx
  800a4b:	83 ea 37             	sub    $0x37,%edx
  800a4e:	eb d0                	jmp    800a20 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a54:	74 05                	je     800a5b <strtol+0xc2>
		*endptr = (char *) s;
  800a56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a5b:	85 ff                	test   %edi,%edi
  800a5d:	74 02                	je     800a61 <strtol+0xc8>
  800a5f:	f7 d8                	neg    %eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	...

00800a68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	89 d1                	mov    %edx,%ecx
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	89 d7                	mov    %edx,%edi
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	b8 03 00 00 00       	mov    $0x3,%eax
  800abb:	89 cb                	mov    %ecx,%ebx
  800abd:	89 cf                	mov    %ecx,%edi
  800abf:	89 ce                	mov    %ecx,%esi
  800ac1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7f 08                	jg     800acf <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	50                   	push   %eax
  800ad3:	6a 03                	push   $0x3
  800ad5:	68 70 0f 80 00       	push   $0x800f70
  800ada:	6a 23                	push   $0x23
  800adc:	68 8d 0f 80 00       	push   $0x800f8d
  800ae1:	e8 22 00 00 00       	call   800b08 <_panic>

00800ae6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 02 00 00 00       	mov    $0x2,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    
  800b05:	00 00                	add    %al,(%eax)
	...

00800b08 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b0d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b10:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800b16:	e8 cb ff ff ff       	call   800ae6 <sys_getenvid>
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	ff 75 0c             	pushl  0xc(%ebp)
  800b21:	ff 75 08             	pushl  0x8(%ebp)
  800b24:	56                   	push   %esi
  800b25:	50                   	push   %eax
  800b26:	68 9c 0f 80 00       	push   $0x800f9c
  800b2b:	e8 28 f6 ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b30:	83 c4 18             	add    $0x18,%esp
  800b33:	53                   	push   %ebx
  800b34:	ff 75 10             	pushl  0x10(%ebp)
  800b37:	e8 cb f5 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800b3c:	c7 04 24 60 0d 80 00 	movl   $0x800d60,(%esp)
  800b43:	e8 10 f6 ff ff       	call   800158 <cprintf>
  800b48:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b4b:	cc                   	int3   
  800b4c:	eb fd                	jmp    800b4b <_panic+0x43>
	...

00800b50 <__udivdi3>:
  800b50:	55                   	push   %ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 1c             	sub    $0x1c,%esp
  800b57:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b5b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b63:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b67:	85 d2                	test   %edx,%edx
  800b69:	75 2d                	jne    800b98 <__udivdi3+0x48>
  800b6b:	39 f7                	cmp    %esi,%edi
  800b6d:	77 59                	ja     800bc8 <__udivdi3+0x78>
  800b6f:	89 f9                	mov    %edi,%ecx
  800b71:	85 ff                	test   %edi,%edi
  800b73:	75 0b                	jne    800b80 <__udivdi3+0x30>
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	31 d2                	xor    %edx,%edx
  800b7c:	f7 f7                	div    %edi
  800b7e:	89 c1                	mov    %eax,%ecx
  800b80:	31 d2                	xor    %edx,%edx
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	f7 f1                	div    %ecx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 e8                	mov    %ebp,%eax
  800b8a:	f7 f1                	div    %ecx
  800b8c:	89 da                	mov    %ebx,%edx
  800b8e:	83 c4 1c             	add    $0x1c,%esp
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    
  800b96:	66 90                	xchg   %ax,%ax
  800b98:	39 f2                	cmp    %esi,%edx
  800b9a:	77 1c                	ja     800bb8 <__udivdi3+0x68>
  800b9c:	0f bd da             	bsr    %edx,%ebx
  800b9f:	83 f3 1f             	xor    $0x1f,%ebx
  800ba2:	75 38                	jne    800bdc <__udivdi3+0x8c>
  800ba4:	39 f2                	cmp    %esi,%edx
  800ba6:	72 08                	jb     800bb0 <__udivdi3+0x60>
  800ba8:	39 ef                	cmp    %ebp,%edi
  800baa:	0f 87 98 00 00 00    	ja     800c48 <__udivdi3+0xf8>
  800bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb5:	eb 05                	jmp    800bbc <__udivdi3+0x6c>
  800bb7:	90                   	nop
  800bb8:	31 db                	xor    %ebx,%ebx
  800bba:	31 c0                	xor    %eax,%eax
  800bbc:	89 da                	mov    %ebx,%edx
  800bbe:	83 c4 1c             	add    $0x1c,%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    
  800bc6:	66 90                	xchg   %ax,%ax
  800bc8:	89 e8                	mov    %ebp,%eax
  800bca:	89 f2                	mov    %esi,%edx
  800bcc:	f7 f7                	div    %edi
  800bce:	31 db                	xor    %ebx,%ebx
  800bd0:	89 da                	mov    %ebx,%edx
  800bd2:	83 c4 1c             	add    $0x1c,%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
  800bda:	66 90                	xchg   %ax,%ax
  800bdc:	b8 20 00 00 00       	mov    $0x20,%eax
  800be1:	29 d8                	sub    %ebx,%eax
  800be3:	88 d9                	mov    %bl,%cl
  800be5:	d3 e2                	shl    %cl,%edx
  800be7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800beb:	89 fa                	mov    %edi,%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bf5:	09 d1                	or     %edx,%ecx
  800bf7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bfb:	88 d9                	mov    %bl,%cl
  800bfd:	d3 e7                	shl    %cl,%edi
  800bff:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c03:	89 f7                	mov    %esi,%edi
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ef                	shr    %cl,%edi
  800c09:	88 d9                	mov    %bl,%cl
  800c0b:	d3 e6                	shl    %cl,%esi
  800c0d:	89 ea                	mov    %ebp,%edx
  800c0f:	88 c1                	mov    %al,%cl
  800c11:	d3 ea                	shr    %cl,%edx
  800c13:	09 d6                	or     %edx,%esi
  800c15:	89 f0                	mov    %esi,%eax
  800c17:	89 fa                	mov    %edi,%edx
  800c19:	f7 74 24 08          	divl   0x8(%esp)
  800c1d:	89 d7                	mov    %edx,%edi
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	f7 64 24 0c          	mull   0xc(%esp)
  800c25:	39 d7                	cmp    %edx,%edi
  800c27:	72 13                	jb     800c3c <__udivdi3+0xec>
  800c29:	74 09                	je     800c34 <__udivdi3+0xe4>
  800c2b:	89 f0                	mov    %esi,%eax
  800c2d:	31 db                	xor    %ebx,%ebx
  800c2f:	eb 8b                	jmp    800bbc <__udivdi3+0x6c>
  800c31:	8d 76 00             	lea    0x0(%esi),%esi
  800c34:	88 d9                	mov    %bl,%cl
  800c36:	d3 e5                	shl    %cl,%ebp
  800c38:	39 c5                	cmp    %eax,%ebp
  800c3a:	73 ef                	jae    800c2b <__udivdi3+0xdb>
  800c3c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c3f:	31 db                	xor    %ebx,%ebx
  800c41:	e9 76 ff ff ff       	jmp    800bbc <__udivdi3+0x6c>
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	31 c0                	xor    %eax,%eax
  800c4a:	e9 6d ff ff ff       	jmp    800bbc <__udivdi3+0x6c>
	...

00800c50 <__umoddi3>:
  800c50:	55                   	push   %ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 1c             	sub    $0x1c,%esp
  800c57:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c5b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c63:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c67:	89 f0                	mov    %esi,%eax
  800c69:	89 da                	mov    %ebx,%edx
  800c6b:	85 ed                	test   %ebp,%ebp
  800c6d:	75 15                	jne    800c84 <__umoddi3+0x34>
  800c6f:	39 df                	cmp    %ebx,%edi
  800c71:	76 39                	jbe    800cac <__umoddi3+0x5c>
  800c73:	f7 f7                	div    %edi
  800c75:	89 d0                	mov    %edx,%eax
  800c77:	31 d2                	xor    %edx,%edx
  800c79:	83 c4 1c             	add    $0x1c,%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
  800c81:	8d 76 00             	lea    0x0(%esi),%esi
  800c84:	39 dd                	cmp    %ebx,%ebp
  800c86:	77 f1                	ja     800c79 <__umoddi3+0x29>
  800c88:	0f bd cd             	bsr    %ebp,%ecx
  800c8b:	83 f1 1f             	xor    $0x1f,%ecx
  800c8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c92:	75 38                	jne    800ccc <__umoddi3+0x7c>
  800c94:	39 dd                	cmp    %ebx,%ebp
  800c96:	72 04                	jb     800c9c <__umoddi3+0x4c>
  800c98:	39 f7                	cmp    %esi,%edi
  800c9a:	77 dd                	ja     800c79 <__umoddi3+0x29>
  800c9c:	89 da                	mov    %ebx,%edx
  800c9e:	89 f0                	mov    %esi,%eax
  800ca0:	29 f8                	sub    %edi,%eax
  800ca2:	19 ea                	sbb    %ebp,%edx
  800ca4:	83 c4 1c             	add    $0x1c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
  800cac:	89 f9                	mov    %edi,%ecx
  800cae:	85 ff                	test   %edi,%edi
  800cb0:	75 0b                	jne    800cbd <__umoddi3+0x6d>
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	31 d2                	xor    %edx,%edx
  800cb9:	f7 f7                	div    %edi
  800cbb:	89 c1                	mov    %eax,%ecx
  800cbd:	89 d8                	mov    %ebx,%eax
  800cbf:	31 d2                	xor    %edx,%edx
  800cc1:	f7 f1                	div    %ecx
  800cc3:	89 f0                	mov    %esi,%eax
  800cc5:	f7 f1                	div    %ecx
  800cc7:	eb ac                	jmp    800c75 <__umoddi3+0x25>
  800cc9:	8d 76 00             	lea    0x0(%esi),%esi
  800ccc:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd7:	29 c2                	sub    %eax,%edx
  800cd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cdd:	88 c1                	mov    %al,%cl
  800cdf:	d3 e5                	shl    %cl,%ebp
  800ce1:	89 f8                	mov    %edi,%eax
  800ce3:	88 d1                	mov    %dl,%cl
  800ce5:	d3 e8                	shr    %cl,%eax
  800ce7:	09 c5                	or     %eax,%ebp
  800ce9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ced:	88 c1                	mov    %al,%cl
  800cef:	d3 e7                	shl    %cl,%edi
  800cf1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	88 d1                	mov    %dl,%cl
  800cf9:	d3 ef                	shr    %cl,%edi
  800cfb:	88 c1                	mov    %al,%cl
  800cfd:	d3 e3                	shl    %cl,%ebx
  800cff:	89 f0                	mov    %esi,%eax
  800d01:	88 d1                	mov    %dl,%cl
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	09 d8                	or     %ebx,%eax
  800d07:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d0b:	d3 e6                	shl    %cl,%esi
  800d0d:	89 fa                	mov    %edi,%edx
  800d0f:	f7 f5                	div    %ebp
  800d11:	89 d1                	mov    %edx,%ecx
  800d13:	f7 64 24 08          	mull   0x8(%esp)
  800d17:	89 c3                	mov    %eax,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	39 d1                	cmp    %edx,%ecx
  800d1d:	72 29                	jb     800d48 <__umoddi3+0xf8>
  800d1f:	74 23                	je     800d44 <__umoddi3+0xf4>
  800d21:	89 ca                	mov    %ecx,%edx
  800d23:	29 de                	sub    %ebx,%esi
  800d25:	19 fa                	sbb    %edi,%edx
  800d27:	89 d0                	mov    %edx,%eax
  800d29:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d2d:	d3 e0                	shl    %cl,%eax
  800d2f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d33:	88 d9                	mov    %bl,%cl
  800d35:	d3 ee                	shr    %cl,%esi
  800d37:	09 f0                	or     %esi,%eax
  800d39:	d3 ea                	shr    %cl,%edx
  800d3b:	83 c4 1c             	add    $0x1c,%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
  800d43:	90                   	nop
  800d44:	39 c6                	cmp    %eax,%esi
  800d46:	73 d9                	jae    800d21 <__umoddi3+0xd1>
  800d48:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d4c:	19 ea                	sbb    %ebp,%edx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	eb cd                	jmp    800d21 <__umoddi3+0xd1>
