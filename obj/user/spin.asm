
obj/user/spin:     file format elf32-i386


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

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 c0 0f 80 00       	push   $0x800fc0
  800040:	e8 67 01 00 00       	call   8001ac <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 de 0c 00 00       	call   800d28 <fork>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	75 12                	jne    800063 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	68 38 10 80 00       	push   $0x801038
  800059:	e8 4e 01 00 00       	call   8001ac <cprintf>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	eb fe                	jmp    800061 <umain+0x2d>
  800063:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 e8 0f 80 00       	push   $0x800fe8
  80006d:	e8 3a 01 00 00       	call   8001ac <cprintf>
	sys_yield();
  800072:	e8 e2 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800077:	e8 dd 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80007c:	e8 d8 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800081:	e8 d3 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800086:	e8 ce 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008b:	e8 c9 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800090:	e8 c4 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800095:	e8 bf 0a 00 00       	call   800b59 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 10 10 80 00 	movl   $0x801010,(%esp)
  8000a1:	e8 06 01 00 00       	call   8001ac <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 4b 0a 00 00       	call   800af9 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c3:	e8 72 0a 00 00       	call   800b3a <sys_getenvid>
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
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

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
  80010c:	e8 e8 09 00 00       	call   800af9 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    
	...

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 13                	mov    (%ebx),%edx
  800124:	8d 42 01             	lea    0x1(%edx),%eax
  800127:	89 03                	mov    %eax,(%ebx)
  800129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	74 08                	je     80013f <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800137:	ff 43 04             	incl   0x4(%ebx)
}
  80013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	68 ff 00 00 00       	push   $0xff
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 6c 09 00 00       	call   800abc <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb dc                	jmp    800137 <putch+0x1f>

0080015b <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800164:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016b:	00 00 00 
	b.cnt = 0;
  80016e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800175:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	68 18 01 80 00       	push   $0x800118
  80018a:	e8 17 01 00 00       	call   8002a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 18 09 00 00       	call   800abc <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	e8 9d ff ff ff       	call   80015b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 1c             	sub    $0x1c,%esp
  8001c9:	89 c7                	mov    %eax,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e7:	39 d3                	cmp    %edx,%ebx
  8001e9:	72 05                	jb     8001f0 <printnum+0x30>
  8001eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ee:	77 78                	ja     800268 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fc:	53                   	push   %ebx
  8001fd:	ff 75 10             	pushl  0x10(%ebp)
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 e4             	pushl  -0x1c(%ebp)
  800206:	ff 75 e0             	pushl  -0x20(%ebp)
  800209:	ff 75 dc             	pushl  -0x24(%ebp)
  80020c:	ff 75 d8             	pushl  -0x28(%ebp)
  80020f:	e8 8c 0b 00 00       	call   800da0 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 f2                	mov    %esi,%edx
  80021b:	89 f8                	mov    %edi,%eax
  80021d:	e8 9e ff ff ff       	call   8001c0 <printnum>
  800222:	83 c4 20             	add    $0x20,%esp
  800225:	eb 11                	jmp    800238 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	ff 75 18             	pushl  0x18(%ebp)
  80022e:	ff d7                	call   *%edi
  800230:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800233:	4b                   	dec    %ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f ef                	jg     800227 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	83 ec 04             	sub    $0x4,%esp
  80023f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800242:	ff 75 e0             	pushl  -0x20(%ebp)
  800245:	ff 75 dc             	pushl  -0x24(%ebp)
  800248:	ff 75 d8             	pushl  -0x28(%ebp)
  80024b:	e8 50 0c 00 00       	call   800ea0 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 80 60 10 80 00 	movsbl 0x801060(%eax),%eax
  80025a:	50                   	push   %eax
  80025b:	ff d7                	call   *%edi
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    
  800268:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026b:	eb c6                	jmp    800233 <printnum+0x73>

0080026d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800273:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800276:	8b 10                	mov    (%eax),%edx
  800278:	3b 50 04             	cmp    0x4(%eax),%edx
  80027b:	73 0a                	jae    800287 <sprintputch+0x1a>
		*b->buf++ = ch;
  80027d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	88 02                	mov    %al,(%edx)
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800292:	50                   	push   %eax
  800293:	ff 75 10             	pushl  0x10(%ebp)
  800296:	ff 75 0c             	pushl  0xc(%ebp)
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	e8 05 00 00 00       	call   8002a6 <vprintfmt>
	va_end(ap);
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 2c             	sub    $0x2c,%esp
  8002af:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b8:	e9 ac 03 00 00       	jmp    800669 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8002bd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8002c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8002c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8002cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8d 47 01             	lea    0x1(%edi),%eax
  8002de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e1:	8a 17                	mov    (%edi),%dl
  8002e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e6:	3c 55                	cmp    $0x55,%al
  8002e8:	0f 87 fc 03 00 00    	ja     8006ea <vprintfmt+0x444>
  8002ee:	0f b6 c0             	movzbl %al,%eax
  8002f1:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ff:	eb da                	jmp    8002db <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800304:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800308:	eb d1                	jmp    8002db <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	0f b6 d2             	movzbl %dl,%edx
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	01 c0                	add    %eax,%eax
  80031d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800321:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800324:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800327:	83 f9 09             	cmp    $0x9,%ecx
  80032a:	77 52                	ja     80037e <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800343:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800347:	79 92                	jns    8002db <vprintfmt+0x35>
				width = precision, precision = -1;
  800349:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800356:	eb 83                	jmp    8002db <vprintfmt+0x35>
  800358:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035c:	78 08                	js     800366 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800361:	e9 75 ff ff ff       	jmp    8002db <vprintfmt+0x35>
  800366:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80036d:	eb ef                	jmp    80035e <vprintfmt+0xb8>
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800372:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800379:	e9 5d ff ff ff       	jmp    8002db <vprintfmt+0x35>
  80037e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800381:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800384:	eb bd                	jmp    800343 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800386:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038a:	e9 4c ff ff ff       	jmp    8002db <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038f:	8b 45 14             	mov    0x14(%ebp),%eax
  800392:	8d 78 04             	lea    0x4(%eax),%edi
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	53                   	push   %ebx
  800399:	ff 30                	pushl  (%eax)
  80039b:	ff d6                	call   *%esi
			break;
  80039d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a3:	e9 be 02 00 00       	jmp    800666 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 78 04             	lea    0x4(%eax),%edi
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	78 2a                	js     8003de <vprintfmt+0x138>
  8003b4:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b6:	83 f8 08             	cmp    $0x8,%eax
  8003b9:	7f 27                	jg     8003e2 <vprintfmt+0x13c>
  8003bb:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	74 1c                	je     8003e2 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003c6:	50                   	push   %eax
  8003c7:	68 81 10 80 00       	push   $0x801081
  8003cc:	53                   	push   %ebx
  8003cd:	56                   	push   %esi
  8003ce:	e8 b6 fe ff ff       	call   800289 <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d9:	e9 88 02 00 00       	jmp    800666 <vprintfmt+0x3c0>
  8003de:	f7 d8                	neg    %eax
  8003e0:	eb d2                	jmp    8003b4 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e2:	52                   	push   %edx
  8003e3:	68 78 10 80 00       	push   $0x801078
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 9a fe ff ff       	call   800289 <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 6c 02 00 00       	jmp    800666 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 38                	mov    (%eax),%edi
  800408:	85 ff                	test   %edi,%edi
  80040a:	74 18                	je     800424 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  80040c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800410:	0f 8e b7 00 00 00    	jle    8004cd <vprintfmt+0x227>
  800416:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041a:	75 0f                	jne    80042b <vprintfmt+0x185>
  80041c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80041f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800422:	eb 75                	jmp    800499 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800424:	bf 71 10 80 00       	mov    $0x801071,%edi
  800429:	eb e1                	jmp    80040c <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 d0             	pushl  -0x30(%ebp)
  800431:	57                   	push   %edi
  800432:	e8 5f 03 00 00       	call   800796 <strnlen>
  800437:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043a:	29 c1                	sub    %eax,%ecx
  80043c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80043f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800442:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800449:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	eb 0d                	jmp    80045d <vprintfmt+0x1b7>
					putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	53                   	push   %ebx
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800459:	4f                   	dec    %edi
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 ff                	test   %edi,%edi
  80045f:	7f ef                	jg     800450 <vprintfmt+0x1aa>
  800461:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800464:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800467:	89 c8                	mov    %ecx,%eax
  800469:	85 c9                	test   %ecx,%ecx
  80046b:	78 10                	js     80047d <vprintfmt+0x1d7>
  80046d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80047b:	eb 1c                	jmp    800499 <vprintfmt+0x1f3>
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	eb e9                	jmp    80046d <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800488:	75 29                	jne    8004b3 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	50                   	push   %eax
  800491:	ff d6                	call   *%esi
  800493:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800496:	ff 4d e0             	decl   -0x20(%ebp)
  800499:	47                   	inc    %edi
  80049a:	8a 57 ff             	mov    -0x1(%edi),%dl
  80049d:	0f be c2             	movsbl %dl,%eax
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	74 4c                	je     8004f0 <vprintfmt+0x24a>
  8004a4:	85 db                	test   %ebx,%ebx
  8004a6:	78 dc                	js     800484 <vprintfmt+0x1de>
  8004a8:	4b                   	dec    %ebx
  8004a9:	79 d9                	jns    800484 <vprintfmt+0x1de>
  8004ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ae:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004b1:	eb 2e                	jmp    8004e1 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b3:	0f be d2             	movsbl %dl,%edx
  8004b6:	83 ea 20             	sub    $0x20,%edx
  8004b9:	83 fa 5e             	cmp    $0x5e,%edx
  8004bc:	76 cc                	jbe    80048a <vprintfmt+0x1e4>
					putch('?', putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 0c             	pushl  0xc(%ebp)
  8004c4:	6a 3f                	push   $0x3f
  8004c6:	ff d6                	call   *%esi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb c9                	jmp    800496 <vprintfmt+0x1f0>
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004d3:	eb c4                	jmp    800499 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	6a 20                	push   $0x20
  8004db:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004dd:	4f                   	dec    %edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f f0                	jg     8004d5 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	e9 76 01 00 00       	jmp    800666 <vprintfmt+0x3c0>
  8004f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	eb e9                	jmp    8004e1 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f8:	83 f9 01             	cmp    $0x1,%ecx
  8004fb:	7e 3f                	jle    80053c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8b 50 04             	mov    0x4(%eax),%edx
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 40 08             	lea    0x8(%eax),%eax
  800511:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800514:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800518:	79 5c                	jns    800576 <vprintfmt+0x2d0>
				putch('-', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 2d                	push   $0x2d
  800520:	ff d6                	call   *%esi
				num = -(long long) num;
  800522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800528:	f7 da                	neg    %edx
  80052a:	83 d1 00             	adc    $0x0,%ecx
  80052d:	f7 d9                	neg    %ecx
  80052f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800532:	b8 0a 00 00 00       	mov    $0xa,%eax
  800537:	e9 10 01 00 00       	jmp    80064c <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	75 1b                	jne    80055b <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800548:	89 c1                	mov    %eax,%ecx
  80054a:	c1 f9 1f             	sar    $0x1f,%ecx
  80054d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 40 04             	lea    0x4(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
  800559:	eb b9                	jmp    800514 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	89 c1                	mov    %eax,%ecx
  800565:	c1 f9 1f             	sar    $0x1f,%ecx
  800568:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 40 04             	lea    0x4(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	eb 9e                	jmp    800514 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800581:	e9 c6 00 00 00       	jmp    80064c <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800586:	83 f9 01             	cmp    $0x1,%ecx
  800589:	7e 18                	jle    8005a3 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	8b 48 04             	mov    0x4(%eax),%ecx
  800593:	8d 40 08             	lea    0x8(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059e:	e9 a9 00 00 00       	jmp    80064c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005a3:	85 c9                	test   %ecx,%ecx
  8005a5:	75 1a                	jne    8005c1 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 8b 00 00 00       	jmp    80064c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d6:	eb 74                	jmp    80064c <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d8:	83 f9 01             	cmp    $0x1,%ecx
  8005db:	7e 15                	jle    8005f2 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e5:	8d 40 08             	lea    0x8(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f0:	eb 5a                	jmp    80064c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005f2:	85 c9                	test   %ecx,%ecx
  8005f4:	75 17                	jne    80060d <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800606:	b8 08 00 00 00       	mov    $0x8,%eax
  80060b:	eb 3f                	jmp    80064c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80061d:	b8 08 00 00 00       	mov    $0x8,%eax
  800622:	eb 28                	jmp    80064c <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800653:	57                   	push   %edi
  800654:	ff 75 e0             	pushl  -0x20(%ebp)
  800657:	50                   	push   %eax
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	e8 5d fb ff ff       	call   8001c0 <printnum>
			break;
  800663:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800669:	47                   	inc    %edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	83 f8 25             	cmp    $0x25,%eax
  800671:	0f 84 46 fc ff ff    	je     8002bd <vprintfmt+0x17>
			if (ch == '\0')
  800677:	85 c0                	test   %eax,%eax
  800679:	0f 84 89 00 00 00    	je     800708 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	50                   	push   %eax
  800684:	ff d6                	call   *%esi
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	eb de                	jmp    800669 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068b:	83 f9 01             	cmp    $0x1,%ecx
  80068e:	7e 15                	jle    8006a5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	8b 48 04             	mov    0x4(%eax),%ecx
  800698:	8d 40 08             	lea    0x8(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069e:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a3:	eb a7                	jmp    80064c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006a5:	85 c9                	test   %ecx,%ecx
  8006a7:	75 17                	jne    8006c0 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006be:	eb 8c                	jmp    80064c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8b 10                	mov    (%eax),%edx
  8006c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ca:	8d 40 04             	lea    0x4(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d5:	e9 72 ff ff ff       	jmp    80064c <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 25                	push   $0x25
  8006e0:	ff d6                	call   *%esi
			break;
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	e9 7c ff ff ff       	jmp    800666 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 25                	push   $0x25
  8006f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	89 f8                	mov    %edi,%eax
  8006f7:	eb 01                	jmp    8006fa <vprintfmt+0x454>
  8006f9:	48                   	dec    %eax
  8006fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fe:	75 f9                	jne    8006f9 <vprintfmt+0x453>
  800700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800703:	e9 5e ff ff ff       	jmp    800666 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 18             	sub    $0x18,%esp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 26                	je     800757 <vsnprintf+0x47>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 29                	jle    80075e <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	ff 75 14             	pushl  0x14(%ebp)
  800738:	ff 75 10             	pushl  0x10(%ebp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	68 6d 02 80 00       	push   $0x80026d
  800744:	e8 5d fb ff ff       	call   8002a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	83 c4 10             	add    $0x10,%esp
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075c:	eb f7                	jmp    800755 <vsnprintf+0x45>
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800763:	eb f0                	jmp    800755 <vsnprintf+0x45>

00800765 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 93 ff ff ff       	call   800710 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 01                	jmp    80078e <strlen+0xe>
		n++;
  80078d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f9                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 01                	jmp    8007a7 <strnlen+0x11>
		n++;
  8007a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 06                	je     8007b1 <strnlen+0x1b>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	75 f5                	jne    8007a6 <strnlen+0x10>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	89 c2                	mov    %eax,%edx
  8007bf:	41                   	inc    %ecx
  8007c0:	42                   	inc    %edx
  8007c1:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 f4                	jne    8007bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d5:	53                   	push   %ebx
  8007d6:	e8 a5 ff ff ff       	call   800780 <strlen>
  8007db:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007de:	ff 75 0c             	pushl  0xc(%ebp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	50                   	push   %eax
  8007e4:	e8 ca ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007e9:	89 d8                	mov    %ebx,%eax
  8007eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	89 f3                	mov    %esi,%ebx
  8007fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	89 f2                	mov    %esi,%edx
  800802:	39 da                	cmp    %ebx,%edx
  800804:	74 0e                	je     800814 <strncpy+0x24>
		*dst++ = *src;
  800806:	42                   	inc    %edx
  800807:	8a 01                	mov    (%ecx),%al
  800809:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80080c:	80 39 00             	cmpb   $0x0,(%ecx)
  80080f:	74 f1                	je     800802 <strncpy+0x12>
			src++;
  800811:	41                   	inc    %ecx
  800812:	eb ee                	jmp    800802 <strncpy+0x12>
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 20                	je     80084c <strlcpy+0x32>
  80082c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800830:	89 f0                	mov    %esi,%eax
  800832:	eb 05                	jmp    800839 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800834:	42                   	inc    %edx
  800835:	40                   	inc    %eax
  800836:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800839:	39 d8                	cmp    %ebx,%eax
  80083b:	74 06                	je     800843 <strlcpy+0x29>
  80083d:	8a 0a                	mov    (%edx),%cl
  80083f:	84 c9                	test   %cl,%cl
  800841:	75 f1                	jne    800834 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800843:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	eb f6                	jmp    800846 <strlcpy+0x2c>

00800850 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800859:	eb 02                	jmp    80085d <strcmp+0xd>
		p++, q++;
  80085b:	41                   	inc    %ecx
  80085c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085d:	8a 01                	mov    (%ecx),%al
  80085f:	84 c0                	test   %al,%al
  800861:	74 04                	je     800867 <strcmp+0x17>
  800863:	3a 02                	cmp    (%edx),%al
  800865:	74 f4                	je     80085b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 c0             	movzbl %al,%eax
  80086a:	0f b6 12             	movzbl (%edx),%edx
  80086d:	29 d0                	sub    %edx,%eax
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087b:	89 c3                	mov    %eax,%ebx
  80087d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800880:	eb 02                	jmp    800884 <strncmp+0x13>
		n--, p++, q++;
  800882:	40                   	inc    %eax
  800883:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 15                	je     80089d <strncmp+0x2c>
  800888:	8a 08                	mov    (%eax),%cl
  80088a:	84 c9                	test   %cl,%cl
  80088c:	74 04                	je     800892 <strncmp+0x21>
  80088e:	3a 0a                	cmp    (%edx),%cl
  800890:	74 f0                	je     800882 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 00             	movzbl (%eax),%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb f6                	jmp    80089a <strncmp+0x29>

008008a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ad:	8a 10                	mov    (%eax),%dl
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	74 07                	je     8008ba <strchr+0x16>
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	74 08                	je     8008bf <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b7:	40                   	inc    %eax
  8008b8:	eb f3                	jmp    8008ad <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ca:	8a 10                	mov    (%eax),%dl
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 07                	je     8008d7 <strfind+0x16>
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 03                	je     8008d7 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d4:	40                   	inc    %eax
  8008d5:	eb f3                	jmp    8008ca <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 13                	je     8008fc <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 05                	jne    8008f6 <memset+0x1d>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	74 0d                	je     800903 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	fc                   	cld    
  8008fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fc:	89 f8                	mov    %edi,%eax
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5f                   	pop    %edi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800903:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800907:	89 d3                	mov    %edx,%ebx
  800909:	c1 e3 08             	shl    $0x8,%ebx
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	c1 e0 18             	shl    $0x18,%eax
  800911:	89 d6                	mov    %edx,%esi
  800913:	c1 e6 10             	shl    $0x10,%esi
  800916:	09 f0                	or     %esi,%eax
  800918:	09 c2                	or     %eax,%edx
  80091a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091f:	89 d0                	mov    %edx,%eax
  800921:	fc                   	cld    
  800922:	f3 ab                	rep stos %eax,%es:(%edi)
  800924:	eb d6                	jmp    8008fc <memset+0x23>

00800926 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 33                	jae    80096b <memmove+0x45>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 c2                	cmp    %eax,%edx
  80093d:	76 2c                	jbe    80096b <memmove+0x45>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	74 0a                	je     800958 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094e:	4f                   	dec    %edi
  80094f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800952:	fd                   	std    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800955:	fc                   	cld    
  800956:	eb 21                	jmp    800979 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 f1                	jne    80094e <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095d:	83 ef 04             	sub    $0x4,%edi
  800960:	8d 72 fc             	lea    -0x4(%edx),%esi
  800963:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800966:	fd                   	std    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb ea                	jmp    800955 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	09 c2                	or     %eax,%edx
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	74 09                	je     80097d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 f2                	jne    800974 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800982:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098a:	eb ed                	jmp    800979 <memmove+0x53>

0080098c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098f:	ff 75 10             	pushl  0x10(%ebp)
  800992:	ff 75 0c             	pushl  0xc(%ebp)
  800995:	ff 75 08             	pushl  0x8(%ebp)
  800998:	e8 89 ff ff ff       	call   800926 <memmove>
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	89 c6                	mov    %eax,%esi
  8009ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f0                	cmp    %esi,%eax
  8009b1:	74 16                	je     8009c9 <memcmp+0x2a>
		if (*s1 != *s2)
  8009b3:	8a 08                	mov    (%eax),%cl
  8009b5:	8a 1a                	mov    (%edx),%bl
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	75 04                	jne    8009bf <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bb:	40                   	inc    %eax
  8009bc:	42                   	inc    %edx
  8009bd:	eb f0                	jmp    8009af <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c1             	movzbl %cl,%eax
  8009c2:	0f b6 db             	movzbl %bl,%ebx
  8009c5:	29 d8                	sub    %ebx,%eax
  8009c7:	eb 05                	jmp    8009ce <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	73 07                	jae    8009eb <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e4:	38 08                	cmp    %cl,(%eax)
  8009e6:	74 03                	je     8009eb <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e8:	40                   	inc    %eax
  8009e9:	eb f5                	jmp    8009e0 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	eb 01                	jmp    8009f9 <strtol+0xc>
		s++;
  8009f8:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f9:	8a 01                	mov    (%ecx),%al
  8009fb:	3c 20                	cmp    $0x20,%al
  8009fd:	74 f9                	je     8009f8 <strtol+0xb>
  8009ff:	3c 09                	cmp    $0x9,%al
  800a01:	74 f5                	je     8009f8 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a03:	3c 2b                	cmp    $0x2b,%al
  800a05:	74 2b                	je     800a32 <strtol+0x45>
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	74 2f                	je     800a3a <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a17:	75 12                	jne    800a2b <strtol+0x3e>
  800a19:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1c:	74 24                	je     800a42 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a22:	75 07                	jne    800a2b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a24:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	eb 4e                	jmp    800a80 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a32:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb d6                	jmp    800a10 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a3a:	41                   	inc    %ecx
  800a3b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a40:	eb ce                	jmp    800a10 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a46:	74 10                	je     800a58 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4c:	75 dd                	jne    800a2b <strtol+0x3e>
		s++, base = 8;
  800a4e:	41                   	inc    %ecx
  800a4f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a56:	eb d3                	jmp    800a2b <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a58:	83 c1 02             	add    $0x2,%ecx
  800a5b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a62:	eb c7                	jmp    800a2b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a67:	89 f3                	mov    %esi,%ebx
  800a69:	80 fb 19             	cmp    $0x19,%bl
  800a6c:	77 24                	ja     800a92 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a6e:	0f be d2             	movsbl %dl,%edx
  800a71:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a77:	7e 2b                	jle    800aa4 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a79:	41                   	inc    %ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a80:	8a 11                	mov    (%ecx),%dl
  800a82:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a85:	80 fb 09             	cmp    $0x9,%bl
  800a88:	77 da                	ja     800a64 <strtol+0x77>
			dig = *s - '0';
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 30             	sub    $0x30,%edx
  800a90:	eb e2                	jmp    800a74 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 08                	ja     800aa4 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 37             	sub    $0x37,%edx
  800aa2:	eb d0                	jmp    800a74 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa8:	74 05                	je     800aaf <strtol+0xc2>
		*endptr = (char *) s;
  800aaa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aad:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aaf:	85 ff                	test   %edi,%edi
  800ab1:	74 02                	je     800ab5 <strtol+0xc8>
  800ab3:	f7 d8                	neg    %eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    
	...

00800abc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cgetc>:

int
sys_cgetc(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0f:	89 cb                	mov    %ecx,%ebx
  800b11:	89 cf                	mov    %ecx,%edi
  800b13:	89 ce                	mov    %ecx,%esi
  800b15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7f 08                	jg     800b23 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 a4 12 80 00       	push   $0x8012a4
  800b2e:	6a 23                	push   $0x23
  800b30:	68 c1 12 80 00       	push   $0x8012c1
  800b35:	e8 1e 02 00 00       	call   800d58 <_panic>

00800b3a <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_yield>:

void
sys_yield(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	be 00 00 00 00       	mov    $0x0,%esi
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	89 f7                	mov    %esi,%edi
  800b96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7f 08                	jg     800ba4 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 a4 12 80 00       	push   $0x8012a4
  800baf:	6a 23                	push   $0x23
  800bb1:	68 c1 12 80 00       	push   $0x8012c1
  800bb6:	e8 9d 01 00 00       	call   800d58 <_panic>

00800bbb <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 a4 12 80 00       	push   $0x8012a4
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 c1 12 80 00       	push   $0x8012c1
  800bf8:	e8 5b 01 00 00       	call   800d58 <_panic>

00800bfd <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	89 de                	mov    %ebx,%esi
  800c1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7f 08                	jg     800c28 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 a4 12 80 00       	push   $0x8012a4
  800c33:	6a 23                	push   $0x23
  800c35:	68 c1 12 80 00       	push   $0x8012c1
  800c3a:	e8 19 01 00 00       	call   800d58 <_panic>

00800c3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 a4 12 80 00       	push   $0x8012a4
  800c75:	6a 23                	push   $0x23
  800c77:	68 c1 12 80 00       	push   $0x8012c1
  800c7c:	e8 d7 00 00 00       	call   800d58 <_panic>

00800c81 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 a4 12 80 00       	push   $0x8012a4
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 c1 12 80 00       	push   $0x8012c1
  800cbe:	e8 95 00 00 00       	call   800d58 <_panic>

00800cc3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	89 cb                	mov    %ecx,%ebx
  800cfe:	89 cf                	mov    %ecx,%edi
  800d00:	89 ce                	mov    %ecx,%esi
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 0c                	push   $0xc
  800d16:	68 a4 12 80 00       	push   $0x8012a4
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 c1 12 80 00       	push   $0x8012c1
  800d22:	e8 31 00 00 00       	call   800d58 <_panic>
	...

00800d28 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d2e:	68 db 12 80 00       	push   $0x8012db
  800d33:	6a 51                	push   $0x51
  800d35:	68 cf 12 80 00       	push   $0x8012cf
  800d3a:	e8 19 00 00 00       	call   800d58 <_panic>

00800d3f <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d45:	68 da 12 80 00       	push   $0x8012da
  800d4a:	6a 58                	push   $0x58
  800d4c:	68 cf 12 80 00       	push   $0x8012cf
  800d51:	e8 02 00 00 00       	call   800d58 <_panic>
	...

00800d58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d5d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d60:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d66:	e8 cf fd ff ff       	call   800b3a <sys_getenvid>
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	ff 75 08             	pushl  0x8(%ebp)
  800d74:	56                   	push   %esi
  800d75:	50                   	push   %eax
  800d76:	68 f0 12 80 00       	push   $0x8012f0
  800d7b:	e8 2c f4 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d80:	83 c4 18             	add    $0x18,%esp
  800d83:	53                   	push   %ebx
  800d84:	ff 75 10             	pushl  0x10(%ebp)
  800d87:	e8 cf f3 ff ff       	call   80015b <vcprintf>
	cprintf("\n");
  800d8c:	c7 04 24 54 10 80 00 	movl   $0x801054,(%esp)
  800d93:	e8 14 f4 ff ff       	call   8001ac <cprintf>
  800d98:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d9b:	cc                   	int3   
  800d9c:	eb fd                	jmp    800d9b <_panic+0x43>
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
