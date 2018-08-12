
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 e5 0a 00 00       	call   800b26 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 b5 0c 00 00       	call   800d14 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 e0 0f 80 00       	push   $0x800fe0
  80006b:	e8 28 01 00 00       	call   800198 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	50                   	push   %eax
  80007e:	53                   	push   %ebx
  80007f:	68 f1 0f 80 00       	push   $0x800ff1
  800084:	e8 0f 01 00 00       	call   800198 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800091:	6a 00                	push   $0x0
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	50                   	push   %eax
  800098:	e8 8e 0c 00 00       	call   800d2b <ipc_send>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	eb ea                	jmp    80008c <umain+0x58>
	...

008000a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000af:	e8 72 0a 00 00       	call   800b26 <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	89 c2                	mov    %eax,%edx
  8000bb:	c1 e2 05             	shl    $0x5,%edx
  8000be:	29 c2                	sub    %eax,%edx
  8000c0:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000c7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	85 db                	test   %ebx,%ebx
  8000ce:	7e 07                	jle    8000d7 <libmain+0x33>
		binaryname = argv[0];
  8000d0:	8b 06                	mov    (%esi),%eax
  8000d2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	e8 53 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e1:	e8 0a 00 00 00       	call   8000f0 <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f6:	6a 00                	push   $0x0
  8000f8:	e8 e8 09 00 00       	call   800ae5 <sys_env_destroy>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	c9                   	leave  
  800101:	c3                   	ret    
	...

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 13                	mov    (%ebx),%edx
  800110:	8d 42 01             	lea    0x1(%edx),%eax
  800113:	89 03                	mov    %eax,(%ebx)
  800115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800118:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	74 08                	je     80012b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800123:	ff 43 04             	incl   0x4(%ebx)
}
  800126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	68 ff 00 00 00       	push   $0xff
  800133:	8d 43 08             	lea    0x8(%ebx),%eax
  800136:	50                   	push   %eax
  800137:	e8 6c 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  80013c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	eb dc                	jmp    800123 <putch+0x1f>

00800147 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800150:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800157:	00 00 00 
	b.cnt = 0;
  80015a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800161:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800170:	50                   	push   %eax
  800171:	68 04 01 80 00       	push   $0x800104
  800176:	e8 17 01 00 00       	call   800292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800184:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 18 09 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	e8 9d ff ff ff       	call   800147 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 1c             	sub    $0x1c,%esp
  8001b5:	89 c7                	mov    %eax,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d3:	39 d3                	cmp    %edx,%ebx
  8001d5:	72 05                	jb     8001dc <printnum+0x30>
  8001d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001da:	77 78                	ja     800254 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e8:	53                   	push   %ebx
  8001e9:	ff 75 10             	pushl  0x10(%ebp)
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fb:	e8 cc 0b 00 00       	call   800dcc <__udivdi3>
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	52                   	push   %edx
  800204:	50                   	push   %eax
  800205:	89 f2                	mov    %esi,%edx
  800207:	89 f8                	mov    %edi,%eax
  800209:	e8 9e ff ff ff       	call   8001ac <printnum>
  80020e:	83 c4 20             	add    $0x20,%esp
  800211:	eb 11                	jmp    800224 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	56                   	push   %esi
  800217:	ff 75 18             	pushl  0x18(%ebp)
  80021a:	ff d7                	call   *%edi
  80021c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021f:	4b                   	dec    %ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ef                	jg     800213 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 90 0c 00 00       	call   800ecc <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 12 10 80 00 	movsbl 0x801012(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800257:	eb c6                	jmp    80021f <printnum+0x73>

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800262:	8b 10                	mov    (%eax),%edx
  800264:	3b 50 04             	cmp    0x4(%eax),%edx
  800267:	73 0a                	jae    800273 <sprintputch+0x1a>
		*b->buf++ = ch;
  800269:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	88 02                	mov    %al,(%edx)
}
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 10             	pushl  0x10(%ebp)
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	ff 75 08             	pushl  0x8(%ebp)
  800288:	e8 05 00 00 00       	call   800292 <vprintfmt>
	va_end(ap);
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 2c             	sub    $0x2c,%esp
  80029b:	8b 75 08             	mov    0x8(%ebp),%esi
  80029e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a4:	e9 ac 03 00 00       	jmp    800655 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8002a9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8002ad:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8002b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8002bb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8002c2:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c7:	8d 47 01             	lea    0x1(%edi),%eax
  8002ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cd:	8a 17                	mov    (%edi),%dl
  8002cf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d2:	3c 55                	cmp    $0x55,%al
  8002d4:	0f 87 fc 03 00 00    	ja     8006d6 <vprintfmt+0x444>
  8002da:	0f b6 c0             	movzbl %al,%eax
  8002dd:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8002e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002eb:	eb da                	jmp    8002c7 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f4:	eb d1                	jmp    8002c7 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	0f b6 d2             	movzbl %dl,%edx
  8002f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800304:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800307:	01 c0                	add    %eax,%eax
  800309:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80030d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800310:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800313:	83 f9 09             	cmp    $0x9,%ecx
  800316:	77 52                	ja     80036a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800319:	eb e9                	jmp    800304 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031b:	8b 45 14             	mov    0x14(%ebp),%eax
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800323:	8b 45 14             	mov    0x14(%ebp),%eax
  800326:	8d 40 04             	lea    0x4(%eax),%eax
  800329:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80032f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800333:	79 92                	jns    8002c7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800335:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800338:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800342:	eb 83                	jmp    8002c7 <vprintfmt+0x35>
  800344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800348:	78 08                	js     800352 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	e9 75 ff ff ff       	jmp    8002c7 <vprintfmt+0x35>
  800352:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800359:	eb ef                	jmp    80034a <vprintfmt+0xb8>
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800365:	e9 5d ff ff ff       	jmp    8002c7 <vprintfmt+0x35>
  80036a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800370:	eb bd                	jmp    80032f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800372:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800376:	e9 4c ff ff ff       	jmp    8002c7 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8d 78 04             	lea    0x4(%eax),%edi
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	ff 30                	pushl  (%eax)
  800387:	ff d6                	call   *%esi
			break;
  800389:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038f:	e9 be 02 00 00       	jmp    800652 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	85 c0                	test   %eax,%eax
  80039e:	78 2a                	js     8003ca <vprintfmt+0x138>
  8003a0:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a2:	83 f8 08             	cmp    $0x8,%eax
  8003a5:	7f 27                	jg     8003ce <vprintfmt+0x13c>
  8003a7:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	74 1c                	je     8003ce <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003b2:	50                   	push   %eax
  8003b3:	68 33 10 80 00       	push   $0x801033
  8003b8:	53                   	push   %ebx
  8003b9:	56                   	push   %esi
  8003ba:	e8 b6 fe ff ff       	call   800275 <printfmt>
  8003bf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c5:	e9 88 02 00 00       	jmp    800652 <vprintfmt+0x3c0>
  8003ca:	f7 d8                	neg    %eax
  8003cc:	eb d2                	jmp    8003a0 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ce:	52                   	push   %edx
  8003cf:	68 2a 10 80 00       	push   $0x80102a
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 9a fe ff ff       	call   800275 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e1:	e9 6c 02 00 00       	jmp    800652 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	83 c0 04             	add    $0x4,%eax
  8003ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8b 38                	mov    (%eax),%edi
  8003f4:	85 ff                	test   %edi,%edi
  8003f6:	74 18                	je     800410 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8003f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fc:	0f 8e b7 00 00 00    	jle    8004b9 <vprintfmt+0x227>
  800402:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800406:	75 0f                	jne    800417 <vprintfmt+0x185>
  800408:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80040b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80040e:	eb 75                	jmp    800485 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800410:	bf 23 10 80 00       	mov    $0x801023,%edi
  800415:	eb e1                	jmp    8003f8 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 5f 03 00 00       	call   800782 <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0d                	jmp    800449 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	4f                   	dec    %edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 ff                	test   %edi,%edi
  80044b:	7f ef                	jg     80043c <vprintfmt+0x1aa>
  80044d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800450:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800453:	89 c8                	mov    %ecx,%eax
  800455:	85 c9                	test   %ecx,%ecx
  800457:	78 10                	js     800469 <vprintfmt+0x1d7>
  800459:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045c:	29 c1                	sub    %eax,%ecx
  80045e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800461:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800464:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800467:	eb 1c                	jmp    800485 <vprintfmt+0x1f3>
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	eb e9                	jmp    800459 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800470:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800474:	75 29                	jne    80049f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 0c             	pushl  0xc(%ebp)
  80047c:	50                   	push   %eax
  80047d:	ff d6                	call   *%esi
  80047f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800482:	ff 4d e0             	decl   -0x20(%ebp)
  800485:	47                   	inc    %edi
  800486:	8a 57 ff             	mov    -0x1(%edi),%dl
  800489:	0f be c2             	movsbl %dl,%eax
  80048c:	85 c0                	test   %eax,%eax
  80048e:	74 4c                	je     8004dc <vprintfmt+0x24a>
  800490:	85 db                	test   %ebx,%ebx
  800492:	78 dc                	js     800470 <vprintfmt+0x1de>
  800494:	4b                   	dec    %ebx
  800495:	79 d9                	jns    800470 <vprintfmt+0x1de>
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049d:	eb 2e                	jmp    8004cd <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80049f:	0f be d2             	movsbl %dl,%edx
  8004a2:	83 ea 20             	sub    $0x20,%edx
  8004a5:	83 fa 5e             	cmp    $0x5e,%edx
  8004a8:	76 cc                	jbe    800476 <vprintfmt+0x1e4>
					putch('?', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	6a 3f                	push   $0x3f
  8004b2:	ff d6                	call   *%esi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	eb c9                	jmp    800482 <vprintfmt+0x1f0>
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004bf:	eb c4                	jmp    800485 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	6a 20                	push   $0x20
  8004c7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c9:	4f                   	dec    %edi
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f f0                	jg     8004c1 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d7:	e9 76 01 00 00       	jmp    800652 <vprintfmt+0x3c0>
  8004dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	eb e9                	jmp    8004cd <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7e 3f                	jle    800528 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 50 04             	mov    0x4(%eax),%edx
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 08             	lea    0x8(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800500:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800504:	79 5c                	jns    800562 <vprintfmt+0x2d0>
				putch('-', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	53                   	push   %ebx
  80050a:	6a 2d                	push   $0x2d
  80050c:	ff d6                	call   *%esi
				num = -(long long) num;
  80050e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800511:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800514:	f7 da                	neg    %edx
  800516:	83 d1 00             	adc    $0x0,%ecx
  800519:	f7 d9                	neg    %ecx
  80051b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80051e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800523:	e9 10 01 00 00       	jmp    800638 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800528:	85 c9                	test   %ecx,%ecx
  80052a:	75 1b                	jne    800547 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800534:	89 c1                	mov    %eax,%ecx
  800536:	c1 f9 1f             	sar    $0x1f,%ecx
  800539:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 04             	lea    0x4(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	eb b9                	jmp    800500 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054f:	89 c1                	mov    %eax,%ecx
  800551:	c1 f9 1f             	sar    $0x1f,%ecx
  800554:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 04             	lea    0x4(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 9e                	jmp    800500 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800562:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800565:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800568:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056d:	e9 c6 00 00 00       	jmp    800638 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800572:	83 f9 01             	cmp    $0x1,%ecx
  800575:	7e 18                	jle    80058f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	8b 48 04             	mov    0x4(%eax),%ecx
  80057f:	8d 40 08             	lea    0x8(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058a:	e9 a9 00 00 00       	jmp    800638 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058f:	85 c9                	test   %ecx,%ecx
  800591:	75 1a                	jne    8005ad <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 10                	mov    (%eax),%edx
  800598:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 8b 00 00 00       	jmp    800638 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c2:	eb 74                	jmp    800638 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c4:	83 f9 01             	cmp    $0x1,%ecx
  8005c7:	7e 15                	jle    8005de <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d1:	8d 40 08             	lea    0x8(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005dc:	eb 5a                	jmp    800638 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	75 17                	jne    8005f9 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f7:	eb 3f                	jmp    800638 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800603:	8d 40 04             	lea    0x4(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800609:	b8 08 00 00 00       	mov    $0x8,%eax
  80060e:	eb 28                	jmp    800638 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 30                	push   $0x30
  800616:	ff d6                	call   *%esi
			putch('x', putdat);
  800618:	83 c4 08             	add    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 78                	push   $0x78
  80061e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800633:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	50                   	push   %eax
  800644:	51                   	push   %ecx
  800645:	52                   	push   %edx
  800646:	89 da                	mov    %ebx,%edx
  800648:	89 f0                	mov    %esi,%eax
  80064a:	e8 5d fb ff ff       	call   8001ac <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800655:	47                   	inc    %edi
  800656:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065a:	83 f8 25             	cmp    $0x25,%eax
  80065d:	0f 84 46 fc ff ff    	je     8002a9 <vprintfmt+0x17>
			if (ch == '\0')
  800663:	85 c0                	test   %eax,%eax
  800665:	0f 84 89 00 00 00    	je     8006f4 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	50                   	push   %eax
  800670:	ff d6                	call   *%esi
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	eb de                	jmp    800655 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
  80068f:	eb a7                	jmp    800638 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	75 17                	jne    8006ac <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006aa:	eb 8c                	jmp    800638 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c1:	e9 72 ff ff ff       	jmp    800638 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 25                	push   $0x25
  8006cc:	ff d6                	call   *%esi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	e9 7c ff ff ff       	jmp    800652 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	89 f8                	mov    %edi,%eax
  8006e3:	eb 01                	jmp    8006e6 <vprintfmt+0x454>
  8006e5:	48                   	dec    %eax
  8006e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ea:	75 f9                	jne    8006e5 <vprintfmt+0x453>
  8006ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ef:	e9 5e ff ff ff       	jmp    800652 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 18             	sub    $0x18,%esp
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800708:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 26                	je     800743 <vsnprintf+0x47>
  80071d:	85 d2                	test   %edx,%edx
  80071f:	7e 29                	jle    80074a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800721:	ff 75 14             	pushl  0x14(%ebp)
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	68 59 02 80 00       	push   $0x800259
  800730:	e8 5d fb ff ff       	call   800292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800735:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800738:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073e:	83 c4 10             	add    $0x10,%esp
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb f7                	jmp    800741 <vsnprintf+0x45>
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb f0                	jmp    800741 <vsnprintf+0x45>

00800751 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	50                   	push   %eax
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	ff 75 08             	pushl  0x8(%ebp)
  800764:	e8 93 ff ff ff       	call   8006fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 01                	jmp    80077a <strlen+0xe>
		n++;
  800779:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	75 f9                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 01                	jmp    800793 <strnlen+0x11>
		n++;
  800792:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 06                	je     80079d <strnlen+0x1b>
  800797:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079b:	75 f5                	jne    800792 <strnlen+0x10>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a9:	89 c2                	mov    %eax,%edx
  8007ab:	41                   	inc    %ecx
  8007ac:	42                   	inc    %edx
  8007ad:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 f4                	jne    8007ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 a5 ff ff ff       	call   80076c <strlen>
  8007c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 ca ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f2                	mov    %esi,%edx
  8007ee:	39 da                	cmp    %ebx,%edx
  8007f0:	74 0e                	je     800800 <strncpy+0x24>
		*dst++ = *src;
  8007f2:	42                   	inc    %edx
  8007f3:	8a 01                	mov    (%ecx),%al
  8007f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007f8:	80 39 00             	cmpb   $0x0,(%ecx)
  8007fb:	74 f1                	je     8007ee <strncpy+0x12>
			src++;
  8007fd:	41                   	inc    %ecx
  8007fe:	eb ee                	jmp    8007ee <strncpy+0x12>
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800814:	85 c0                	test   %eax,%eax
  800816:	74 20                	je     800838 <strlcpy+0x32>
  800818:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80081c:	89 f0                	mov    %esi,%eax
  80081e:	eb 05                	jmp    800825 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800820:	42                   	inc    %edx
  800821:	40                   	inc    %eax
  800822:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 d8                	cmp    %ebx,%eax
  800827:	74 06                	je     80082f <strlcpy+0x29>
  800829:	8a 0a                	mov    (%edx),%cl
  80082b:	84 c9                	test   %cl,%cl
  80082d:	75 f1                	jne    800820 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80082f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800832:	29 f0                	sub    %esi,%eax
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    
  800838:	89 f0                	mov    %esi,%eax
  80083a:	eb f6                	jmp    800832 <strlcpy+0x2c>

0080083c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800845:	eb 02                	jmp    800849 <strcmp+0xd>
		p++, q++;
  800847:	41                   	inc    %ecx
  800848:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800849:	8a 01                	mov    (%ecx),%al
  80084b:	84 c0                	test   %al,%al
  80084d:	74 04                	je     800853 <strcmp+0x17>
  80084f:	3a 02                	cmp    (%edx),%al
  800851:	74 f4                	je     800847 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
  800867:	89 c3                	mov    %eax,%ebx
  800869:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086c:	eb 02                	jmp    800870 <strncmp+0x13>
		n--, p++, q++;
  80086e:	40                   	inc    %eax
  80086f:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800870:	39 d8                	cmp    %ebx,%eax
  800872:	74 15                	je     800889 <strncmp+0x2c>
  800874:	8a 08                	mov    (%eax),%cl
  800876:	84 c9                	test   %cl,%cl
  800878:	74 04                	je     80087e <strncmp+0x21>
  80087a:	3a 0a                	cmp    (%edx),%cl
  80087c:	74 f0                	je     80086e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 00             	movzbl (%eax),%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
  80088e:	eb f6                	jmp    800886 <strncmp+0x29>

00800890 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800899:	8a 10                	mov    (%eax),%dl
  80089b:	84 d2                	test   %dl,%dl
  80089d:	74 07                	je     8008a6 <strchr+0x16>
		if (*s == c)
  80089f:	38 ca                	cmp    %cl,%dl
  8008a1:	74 08                	je     8008ab <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a3:	40                   	inc    %eax
  8008a4:	eb f3                	jmp    800899 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	8a 10                	mov    (%eax),%dl
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 07                	je     8008c3 <strfind+0x16>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 03                	je     8008c3 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	40                   	inc    %eax
  8008c1:	eb f3                	jmp    8008b6 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 13                	je     8008e8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 05                	jne    8008e2 <memset+0x1d>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	74 0d                	je     8008ef <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8008ef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f3:	89 d3                	mov    %edx,%ebx
  8008f5:	c1 e3 08             	shl    $0x8,%ebx
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	c1 e0 18             	shl    $0x18,%eax
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 10             	shl    $0x10,%esi
  800902:	09 f0                	or     %esi,%eax
  800904:	09 c2                	or     %eax,%edx
  800906:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800908:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	fc                   	cld    
  80090e:	f3 ab                	rep stos %eax,%es:(%edi)
  800910:	eb d6                	jmp    8008e8 <memset+0x23>

00800912 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 33                	jae    800957 <memmove+0x45>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 c2                	cmp    %eax,%edx
  800929:	76 2c                	jbe    800957 <memmove+0x45>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	74 0a                	je     800944 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093a:	4f                   	dec    %edi
  80093b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093e:	fd                   	std    
  80093f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800941:	fc                   	cld    
  800942:	eb 21                	jmp    800965 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 f1                	jne    80093a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800949:	83 ef 04             	sub    $0x4,%edi
  80094c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800952:	fd                   	std    
  800953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800955:	eb ea                	jmp    800941 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	89 f2                	mov    %esi,%edx
  800959:	09 c2                	or     %eax,%edx
  80095b:	f6 c2 03             	test   $0x3,%dl
  80095e:	74 09                	je     800969 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 f2                	jne    800960 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb ed                	jmp    800965 <memmove+0x53>

00800978 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097b:	ff 75 10             	pushl  0x10(%ebp)
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 89 ff ff ff       	call   800912 <memmove>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	89 c6                	mov    %eax,%esi
  800998:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	39 f0                	cmp    %esi,%eax
  80099d:	74 16                	je     8009b5 <memcmp+0x2a>
		if (*s1 != *s2)
  80099f:	8a 08                	mov    (%eax),%cl
  8009a1:	8a 1a                	mov    (%edx),%bl
  8009a3:	38 d9                	cmp    %bl,%cl
  8009a5:	75 04                	jne    8009ab <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009a7:	40                   	inc    %eax
  8009a8:	42                   	inc    %edx
  8009a9:	eb f0                	jmp    80099b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  8009ab:	0f b6 c1             	movzbl %cl,%eax
  8009ae:	0f b6 db             	movzbl %bl,%ebx
  8009b1:	29 d8                	sub    %ebx,%eax
  8009b3:	eb 05                	jmp    8009ba <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cc:	39 d0                	cmp    %edx,%eax
  8009ce:	73 07                	jae    8009d7 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d0:	38 08                	cmp    %cl,(%eax)
  8009d2:	74 03                	je     8009d7 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d4:	40                   	inc    %eax
  8009d5:	eb f5                	jmp    8009cc <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	eb 01                	jmp    8009e5 <strtol+0xc>
		s++;
  8009e4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e5:	8a 01                	mov    (%ecx),%al
  8009e7:	3c 20                	cmp    $0x20,%al
  8009e9:	74 f9                	je     8009e4 <strtol+0xb>
  8009eb:	3c 09                	cmp    $0x9,%al
  8009ed:	74 f5                	je     8009e4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ef:	3c 2b                	cmp    $0x2b,%al
  8009f1:	74 2b                	je     800a1e <strtol+0x45>
		s++;
	else if (*s == '-')
  8009f3:	3c 2d                	cmp    $0x2d,%al
  8009f5:	74 2f                	je     800a26 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a03:	75 12                	jne    800a17 <strtol+0x3e>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	74 24                	je     800a2e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a0e:	75 07                	jne    800a17 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a10:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	eb 4e                	jmp    800a6c <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a1e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a24:	eb d6                	jmp    8009fc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a26:	41                   	inc    %ecx
  800a27:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2c:	eb ce                	jmp    8009fc <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	74 10                	je     800a44 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a38:	75 dd                	jne    800a17 <strtol+0x3e>
		s++, base = 8;
  800a3a:	41                   	inc    %ecx
  800a3b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a42:	eb d3                	jmp    800a17 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a44:	83 c1 02             	add    $0x2,%ecx
  800a47:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a4e:	eb c7                	jmp    800a17 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a50:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 24                	ja     800a7e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a60:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a63:	7e 2b                	jle    800a90 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a65:	41                   	inc    %ecx
  800a66:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6a:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6c:	8a 11                	mov    (%ecx),%dl
  800a6e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a71:	80 fb 09             	cmp    $0x9,%bl
  800a74:	77 da                	ja     800a50 <strtol+0x77>
			dig = *s - '0';
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 30             	sub    $0x30,%edx
  800a7c:	eb e2                	jmp    800a60 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 08                	ja     800a90 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 37             	sub    $0x37,%edx
  800a8e:	eb d0                	jmp    800a60 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a94:	74 05                	je     800a9b <strtol+0xc2>
		*endptr = (char *) s;
  800a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a99:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a9b:	85 ff                	test   %edi,%edi
  800a9d:	74 02                	je     800aa1 <strtol+0xc8>
  800a9f:	f7 d8                	neg    %eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    
	...

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	b8 03 00 00 00       	mov    $0x3,%eax
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7f 08                	jg     800b0f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	50                   	push   %eax
  800b13:	6a 03                	push   $0x3
  800b15:	68 64 12 80 00       	push   $0x801264
  800b1a:	6a 23                	push   $0x23
  800b1c:	68 81 12 80 00       	push   $0x801281
  800b21:	e8 5e 02 00 00       	call   800d84 <_panic>

00800b26 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 02 00 00 00       	mov    $0x2,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_yield>:

void
sys_yield(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	be 00 00 00 00       	mov    $0x0,%esi
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	89 f7                	mov    %esi,%edi
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7f 08                	jg     800b90 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 04                	push   $0x4
  800b96:	68 64 12 80 00       	push   $0x801264
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 81 12 80 00       	push   $0x801281
  800ba2:	e8 dd 01 00 00       	call   800d84 <_panic>

00800ba7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7f 08                	jg     800bd2 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 05                	push   $0x5
  800bd8:	68 64 12 80 00       	push   $0x801264
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 81 12 80 00       	push   $0x801281
  800be4:	e8 9b 01 00 00       	call   800d84 <_panic>

00800be9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	b8 06 00 00 00       	mov    $0x6,%eax
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	89 de                	mov    %ebx,%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 06                	push   $0x6
  800c1a:	68 64 12 80 00       	push   $0x801264
  800c1f:	6a 23                	push   $0x23
  800c21:	68 81 12 80 00       	push   $0x801281
  800c26:	e8 59 01 00 00       	call   800d84 <_panic>

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 08                	push   $0x8
  800c5c:	68 64 12 80 00       	push   $0x801264
  800c61:	6a 23                	push   $0x23
  800c63:	68 81 12 80 00       	push   $0x801281
  800c68:	e8 17 01 00 00       	call   800d84 <_panic>

00800c6d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 09 00 00 00       	mov    $0x9,%eax
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 09                	push   $0x9
  800c9e:	68 64 12 80 00       	push   $0x801264
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 81 12 80 00       	push   $0x801281
  800caa:	e8 d5 00 00 00       	call   800d84 <_panic>

00800caf <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc0:	be 00 00 00 00       	mov    $0x0,%esi
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce8:	89 cb                	mov    %ecx,%ebx
  800cea:	89 cf                	mov    %ecx,%edi
  800cec:	89 ce                	mov    %ecx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7f 08                	jg     800cfc <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 0c                	push   $0xc
  800d02:	68 64 12 80 00       	push   $0x801264
  800d07:	6a 23                	push   $0x23
  800d09:	68 81 12 80 00       	push   $0x801281
  800d0e:	e8 71 00 00 00       	call   800d84 <_panic>
	...

00800d14 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d1a:	68 8f 12 80 00       	push   $0x80128f
  800d1f:	6a 1a                	push   $0x1a
  800d21:	68 a8 12 80 00       	push   $0x8012a8
  800d26:	e8 59 00 00 00       	call   800d84 <_panic>

00800d2b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d31:	68 b2 12 80 00       	push   $0x8012b2
  800d36:	6a 2a                	push   $0x2a
  800d38:	68 a8 12 80 00       	push   $0x8012a8
  800d3d:	e8 42 00 00 00       	call   800d84 <_panic>

00800d42 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d48:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	c1 e2 05             	shl    $0x5,%edx
  800d52:	29 c2                	sub    %eax,%edx
  800d54:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800d5b:	8b 52 50             	mov    0x50(%edx),%edx
  800d5e:	39 ca                	cmp    %ecx,%edx
  800d60:	74 0f                	je     800d71 <ipc_find_env+0x2f>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d62:	40                   	inc    %eax
  800d63:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d68:	75 e3                	jne    800d4d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	eb 11                	jmp    800d82 <ipc_find_env+0x40>
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	c1 e2 05             	shl    $0x5,%edx
  800d76:	29 c2                	sub    %eax,%edx
  800d78:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800d7f:	8b 40 48             	mov    0x48(%eax),%eax
	return 0;
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d89:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d8c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d92:	e8 8f fd ff ff       	call   800b26 <sys_getenvid>
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	ff 75 0c             	pushl  0xc(%ebp)
  800d9d:	ff 75 08             	pushl  0x8(%ebp)
  800da0:	56                   	push   %esi
  800da1:	50                   	push   %eax
  800da2:	68 cc 12 80 00       	push   $0x8012cc
  800da7:	e8 ec f3 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dac:	83 c4 18             	add    $0x18,%esp
  800daf:	53                   	push   %ebx
  800db0:	ff 75 10             	pushl  0x10(%ebp)
  800db3:	e8 8f f3 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  800db8:	c7 04 24 ef 0f 80 00 	movl   $0x800fef,(%esp)
  800dbf:	e8 d4 f3 ff ff       	call   800198 <cprintf>
  800dc4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc7:	cc                   	int3   
  800dc8:	eb fd                	jmp    800dc7 <_panic+0x43>
	...

00800dcc <__udivdi3>:
  800dcc:	55                   	push   %ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 1c             	sub    $0x1c,%esp
  800dd3:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dd7:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ddb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ddf:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800de3:	85 d2                	test   %edx,%edx
  800de5:	75 2d                	jne    800e14 <__udivdi3+0x48>
  800de7:	39 f7                	cmp    %esi,%edi
  800de9:	77 59                	ja     800e44 <__udivdi3+0x78>
  800deb:	89 f9                	mov    %edi,%ecx
  800ded:	85 ff                	test   %edi,%edi
  800def:	75 0b                	jne    800dfc <__udivdi3+0x30>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c1                	mov    %eax,%ecx
  800dfc:	31 d2                	xor    %edx,%edx
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	f7 f1                	div    %ecx
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	89 e8                	mov    %ebp,%eax
  800e06:	f7 f1                	div    %ecx
  800e08:	89 da                	mov    %ebx,%edx
  800e0a:	83 c4 1c             	add    $0x1c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	39 f2                	cmp    %esi,%edx
  800e16:	77 1c                	ja     800e34 <__udivdi3+0x68>
  800e18:	0f bd da             	bsr    %edx,%ebx
  800e1b:	83 f3 1f             	xor    $0x1f,%ebx
  800e1e:	75 38                	jne    800e58 <__udivdi3+0x8c>
  800e20:	39 f2                	cmp    %esi,%edx
  800e22:	72 08                	jb     800e2c <__udivdi3+0x60>
  800e24:	39 ef                	cmp    %ebp,%edi
  800e26:	0f 87 98 00 00 00    	ja     800ec4 <__udivdi3+0xf8>
  800e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e31:	eb 05                	jmp    800e38 <__udivdi3+0x6c>
  800e33:	90                   	nop
  800e34:	31 db                	xor    %ebx,%ebx
  800e36:	31 c0                	xor    %eax,%eax
  800e38:	89 da                	mov    %ebx,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	89 e8                	mov    %ebp,%eax
  800e46:	89 f2                	mov    %esi,%edx
  800e48:	f7 f7                	div    %edi
  800e4a:	31 db                	xor    %ebx,%ebx
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	83 c4 1c             	add    $0x1c,%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	b8 20 00 00 00       	mov    $0x20,%eax
  800e5d:	29 d8                	sub    %ebx,%eax
  800e5f:	88 d9                	mov    %bl,%cl
  800e61:	d3 e2                	shl    %cl,%edx
  800e63:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e67:	89 fa                	mov    %edi,%edx
  800e69:	88 c1                	mov    %al,%cl
  800e6b:	d3 ea                	shr    %cl,%edx
  800e6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e71:	09 d1                	or     %edx,%ecx
  800e73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e77:	88 d9                	mov    %bl,%cl
  800e79:	d3 e7                	shl    %cl,%edi
  800e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e7f:	89 f7                	mov    %esi,%edi
  800e81:	88 c1                	mov    %al,%cl
  800e83:	d3 ef                	shr    %cl,%edi
  800e85:	88 d9                	mov    %bl,%cl
  800e87:	d3 e6                	shl    %cl,%esi
  800e89:	89 ea                	mov    %ebp,%edx
  800e8b:	88 c1                	mov    %al,%cl
  800e8d:	d3 ea                	shr    %cl,%edx
  800e8f:	09 d6                	or     %edx,%esi
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	89 fa                	mov    %edi,%edx
  800e95:	f7 74 24 08          	divl   0x8(%esp)
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 c6                	mov    %eax,%esi
  800e9d:	f7 64 24 0c          	mull   0xc(%esp)
  800ea1:	39 d7                	cmp    %edx,%edi
  800ea3:	72 13                	jb     800eb8 <__udivdi3+0xec>
  800ea5:	74 09                	je     800eb0 <__udivdi3+0xe4>
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	31 db                	xor    %ebx,%ebx
  800eab:	eb 8b                	jmp    800e38 <__udivdi3+0x6c>
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
  800eb0:	88 d9                	mov    %bl,%cl
  800eb2:	d3 e5                	shl    %cl,%ebp
  800eb4:	39 c5                	cmp    %eax,%ebp
  800eb6:	73 ef                	jae    800ea7 <__udivdi3+0xdb>
  800eb8:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ebb:	31 db                	xor    %ebx,%ebx
  800ebd:	e9 76 ff ff ff       	jmp    800e38 <__udivdi3+0x6c>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	31 c0                	xor    %eax,%eax
  800ec6:	e9 6d ff ff ff       	jmp    800e38 <__udivdi3+0x6c>
	...

00800ecc <__umoddi3>:
  800ecc:	55                   	push   %ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 1c             	sub    $0x1c,%esp
  800ed3:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ed7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800edb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800edf:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	89 da                	mov    %ebx,%edx
  800ee7:	85 ed                	test   %ebp,%ebp
  800ee9:	75 15                	jne    800f00 <__umoddi3+0x34>
  800eeb:	39 df                	cmp    %ebx,%edi
  800eed:	76 39                	jbe    800f28 <__umoddi3+0x5c>
  800eef:	f7 f7                	div    %edi
  800ef1:	89 d0                	mov    %edx,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	83 c4 1c             	add    $0x1c,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	39 dd                	cmp    %ebx,%ebp
  800f02:	77 f1                	ja     800ef5 <__umoddi3+0x29>
  800f04:	0f bd cd             	bsr    %ebp,%ecx
  800f07:	83 f1 1f             	xor    $0x1f,%ecx
  800f0a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f0e:	75 38                	jne    800f48 <__umoddi3+0x7c>
  800f10:	39 dd                	cmp    %ebx,%ebp
  800f12:	72 04                	jb     800f18 <__umoddi3+0x4c>
  800f14:	39 f7                	cmp    %esi,%edi
  800f16:	77 dd                	ja     800ef5 <__umoddi3+0x29>
  800f18:	89 da                	mov    %ebx,%edx
  800f1a:	89 f0                	mov    %esi,%eax
  800f1c:	29 f8                	sub    %edi,%eax
  800f1e:	19 ea                	sbb    %ebp,%edx
  800f20:	83 c4 1c             	add    $0x1c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
  800f28:	89 f9                	mov    %edi,%ecx
  800f2a:	85 ff                	test   %edi,%edi
  800f2c:	75 0b                	jne    800f39 <__umoddi3+0x6d>
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f7                	div    %edi
  800f37:	89 c1                	mov    %eax,%ecx
  800f39:	89 d8                	mov    %ebx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f1                	div    %ecx
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	f7 f1                	div    %ecx
  800f43:	eb ac                	jmp    800ef1 <__umoddi3+0x25>
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	b8 20 00 00 00       	mov    $0x20,%eax
  800f4d:	89 c2                	mov    %eax,%edx
  800f4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f53:	29 c2                	sub    %eax,%edx
  800f55:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f59:	88 c1                	mov    %al,%cl
  800f5b:	d3 e5                	shl    %cl,%ebp
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	88 d1                	mov    %dl,%cl
  800f61:	d3 e8                	shr    %cl,%eax
  800f63:	09 c5                	or     %eax,%ebp
  800f65:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f69:	88 c1                	mov    %al,%cl
  800f6b:	d3 e7                	shl    %cl,%edi
  800f6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f71:	89 df                	mov    %ebx,%edi
  800f73:	88 d1                	mov    %dl,%cl
  800f75:	d3 ef                	shr    %cl,%edi
  800f77:	88 c1                	mov    %al,%cl
  800f79:	d3 e3                	shl    %cl,%ebx
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	88 d1                	mov    %dl,%cl
  800f7f:	d3 e8                	shr    %cl,%eax
  800f81:	09 d8                	or     %ebx,%eax
  800f83:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f87:	d3 e6                	shl    %cl,%esi
  800f89:	89 fa                	mov    %edi,%edx
  800f8b:	f7 f5                	div    %ebp
  800f8d:	89 d1                	mov    %edx,%ecx
  800f8f:	f7 64 24 08          	mull   0x8(%esp)
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	89 d7                	mov    %edx,%edi
  800f97:	39 d1                	cmp    %edx,%ecx
  800f99:	72 29                	jb     800fc4 <__umoddi3+0xf8>
  800f9b:	74 23                	je     800fc0 <__umoddi3+0xf4>
  800f9d:	89 ca                	mov    %ecx,%edx
  800f9f:	29 de                	sub    %ebx,%esi
  800fa1:	19 fa                	sbb    %edi,%edx
  800fa3:	89 d0                	mov    %edx,%eax
  800fa5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800fa9:	d3 e0                	shl    %cl,%eax
  800fab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800faf:	88 d9                	mov    %bl,%cl
  800fb1:	d3 ee                	shr    %cl,%esi
  800fb3:	09 f0                	or     %esi,%eax
  800fb5:	d3 ea                	shr    %cl,%edx
  800fb7:	83 c4 1c             	add    $0x1c,%esp
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    
  800fbf:	90                   	nop
  800fc0:	39 c6                	cmp    %eax,%esi
  800fc2:	73 d9                	jae    800f9d <__umoddi3+0xd1>
  800fc4:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fc8:	19 ea                	sbb    %ebp,%edx
  800fca:	89 d7                	mov    %edx,%edi
  800fcc:	89 c3                	mov    %eax,%ebx
  800fce:	eb cd                	jmp    800f9d <__umoddi3+0xd1>
