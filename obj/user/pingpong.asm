
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 ee 0c 00 00       	call   800d30 <fork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	75 4d                	jne    800096 <umain+0x62>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800049:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	56                   	push   %esi
  800054:	e8 07 0d 00 00       	call   800d60 <ipc_recv>
  800059:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005e:	e8 df 0a 00 00       	call   800b42 <sys_getenvid>
  800063:	57                   	push   %edi
  800064:	53                   	push   %ebx
  800065:	50                   	push   %eax
  800066:	68 36 10 80 00       	push   $0x801036
  80006b:	e8 44 01 00 00       	call   8001b4 <cprintf>
		if (i == 10)
  800070:	83 c4 20             	add    $0x20,%esp
  800073:	83 fb 0a             	cmp    $0xa,%ebx
  800076:	74 16                	je     80008e <umain+0x5a>
			return;
		i++;
  800078:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	53                   	push   %ebx
  80007e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800081:	e8 f1 0c 00 00       	call   800d77 <ipc_send>
		if (i == 10)
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 fb 0a             	cmp    $0xa,%ebx
  80008c:	75 be                	jne    80004c <umain+0x18>
			return;
	}

}
  80008e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5f                   	pop    %edi
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    
  800096:	89 c3                	mov    %eax,%ebx
{
	envid_t who;

	if ((who = fork()) != 0) {
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800098:	e8 a5 0a 00 00       	call   800b42 <sys_getenvid>
  80009d:	83 ec 04             	sub    $0x4,%esp
  8000a0:	53                   	push   %ebx
  8000a1:	50                   	push   %eax
  8000a2:	68 20 10 80 00       	push   $0x801020
  8000a7:	e8 08 01 00 00       	call   8001b4 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	6a 00                	push   $0x0
  8000b0:	6a 00                	push   $0x0
  8000b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b5:	e8 bd 0c 00 00       	call   800d77 <ipc_send>
  8000ba:	83 c4 20             	add    $0x20,%esp
  8000bd:	eb 8a                	jmp    800049 <umain+0x15>
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cb:	e8 72 0a 00 00       	call   800b42 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	89 c2                	mov    %eax,%edx
  8000d7:	c1 e2 05             	shl    $0x5,%edx
  8000da:	29 c2                	sub    %eax,%edx
  8000dc:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000e3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e8:	85 db                	test   %ebx,%ebx
  8000ea:	7e 07                	jle    8000f3 <libmain+0x33>
		binaryname = argv[0];
  8000ec:	8b 06                	mov    (%esi),%eax
  8000ee:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f3:	83 ec 08             	sub    $0x8,%esp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	e8 37 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000fd:	e8 0a 00 00 00       	call   80010c <exit>
}
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800112:	6a 00                	push   $0x0
  800114:	e8 e8 09 00 00       	call   800b01 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	74 08                	je     800147 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013f:	ff 43 04             	incl   0x4(%ebx)
}
  800142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800145:	c9                   	leave  
  800146:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	68 ff 00 00 00       	push   $0xff
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	50                   	push   %eax
  800153:	e8 6c 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	eb dc                	jmp    80013f <putch+0x1f>

00800163 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 20 01 80 00       	push   $0x800120
  800192:	e8 17 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 18 09 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 78                	ja     800270 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 fc 0b 00 00       	call   800e18 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 11                	jmp    800240 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	4b                   	dec    %ebx
  80023c:	85 db                	test   %ebx,%ebx
  80023e:	7f ef                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	56                   	push   %esi
  800244:	83 ec 04             	sub    $0x4,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 c0 0c 00 00       	call   800f18 <__umoddi3>
  800258:	83 c4 14             	add    $0x14,%esp
  80025b:	0f be 80 53 10 80 00 	movsbl 0x801053(%eax),%eax
  800262:	50                   	push   %eax
  800263:	ff d7                	call   *%edi
}
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    
  800270:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800273:	eb c6                	jmp    80023b <printnum+0x73>

00800275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1a>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	e9 ac 03 00 00       	jmp    800671 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8002c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8002c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8002d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8002d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8002de:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	8a 17                	mov    (%edi),%dl
  8002eb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ee:	3c 55                	cmp    $0x55,%al
  8002f0:	0f 87 fc 03 00 00    	ja     8006f2 <vprintfmt+0x444>
  8002f6:	0f b6 c0             	movzbl %al,%eax
  8002f9:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800307:	eb da                	jmp    8002e3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800310:	eb d1                	jmp    8002e3 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	0f b6 d2             	movzbl %dl,%edx
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	b8 00 00 00 00       	mov    $0x0,%eax
  80031d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800323:	01 c0                	add    %eax,%eax
  800325:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800329:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032f:	83 f9 09             	cmp    $0x9,%ecx
  800332:	77 52                	ja     800386 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800334:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800335:	eb e9                	jmp    800320 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8d 40 04             	lea    0x4(%eax),%eax
  800345:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80034b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034f:	79 92                	jns    8002e3 <vprintfmt+0x35>
				width = precision, precision = -1;
  800351:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800354:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800357:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035e:	eb 83                	jmp    8002e3 <vprintfmt+0x35>
  800360:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800364:	78 08                	js     80036e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	e9 75 ff ff ff       	jmp    8002e3 <vprintfmt+0x35>
  80036e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800375:	eb ef                	jmp    800366 <vprintfmt+0xb8>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	e9 5d ff ff ff       	jmp    8002e3 <vprintfmt+0x35>
  800386:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800389:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80038c:	eb bd                	jmp    80034b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800392:	e9 4c ff ff ff       	jmp    8002e3 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 78 04             	lea    0x4(%eax),%edi
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	53                   	push   %ebx
  8003a1:	ff 30                	pushl  (%eax)
  8003a3:	ff d6                	call   *%esi
			break;
  8003a5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ab:	e9 be 02 00 00       	jmp    80066e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	78 2a                	js     8003e6 <vprintfmt+0x138>
  8003bc:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003be:	83 f8 08             	cmp    $0x8,%eax
  8003c1:	7f 27                	jg     8003ea <vprintfmt+0x13c>
  8003c3:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	74 1c                	je     8003ea <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003ce:	50                   	push   %eax
  8003cf:	68 74 10 80 00       	push   $0x801074
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 b6 fe ff ff       	call   800291 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e1:	e9 88 02 00 00       	jmp    80066e <vprintfmt+0x3c0>
  8003e6:	f7 d8                	neg    %eax
  8003e8:	eb d2                	jmp    8003bc <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ea:	52                   	push   %edx
  8003eb:	68 6b 10 80 00       	push   $0x80106b
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 9a fe ff ff       	call   800291 <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003fd:	e9 6c 02 00 00       	jmp    80066e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	83 c0 04             	add    $0x4,%eax
  800408:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8b 38                	mov    (%eax),%edi
  800410:	85 ff                	test   %edi,%edi
  800412:	74 18                	je     80042c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 8e b7 00 00 00    	jle    8004d5 <vprintfmt+0x227>
  80041e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800422:	75 0f                	jne    800433 <vprintfmt+0x185>
  800424:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800427:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80042a:	eb 75                	jmp    8004a1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80042c:	bf 64 10 80 00       	mov    $0x801064,%edi
  800431:	eb e1                	jmp    800414 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	ff 75 d0             	pushl  -0x30(%ebp)
  800439:	57                   	push   %edi
  80043a:	e8 5f 03 00 00       	call   80079e <strnlen>
  80043f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800442:	29 c1                	sub    %eax,%ecx
  800444:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800447:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800454:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	eb 0d                	jmp    800465 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	ff 75 e0             	pushl  -0x20(%ebp)
  80045f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	4f                   	dec    %edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 ff                	test   %edi,%edi
  800467:	7f ef                	jg     800458 <vprintfmt+0x1aa>
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046f:	89 c8                	mov    %ecx,%eax
  800471:	85 c9                	test   %ecx,%ecx
  800473:	78 10                	js     800485 <vprintfmt+0x1d7>
  800475:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800480:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800483:	eb 1c                	jmp    8004a1 <vprintfmt+0x1f3>
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	eb e9                	jmp    800475 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800490:	75 29                	jne    8004bb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 0c             	pushl  0xc(%ebp)
  800498:	50                   	push   %eax
  800499:	ff d6                	call   *%esi
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	ff 4d e0             	decl   -0x20(%ebp)
  8004a1:	47                   	inc    %edi
  8004a2:	8a 57 ff             	mov    -0x1(%edi),%dl
  8004a5:	0f be c2             	movsbl %dl,%eax
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	74 4c                	je     8004f8 <vprintfmt+0x24a>
  8004ac:	85 db                	test   %ebx,%ebx
  8004ae:	78 dc                	js     80048c <vprintfmt+0x1de>
  8004b0:	4b                   	dec    %ebx
  8004b1:	79 d9                	jns    80048c <vprintfmt+0x1de>
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004b9:	eb 2e                	jmp    8004e9 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8004bb:	0f be d2             	movsbl %dl,%edx
  8004be:	83 ea 20             	sub    $0x20,%edx
  8004c1:	83 fa 5e             	cmp    $0x5e,%edx
  8004c4:	76 cc                	jbe    800492 <vprintfmt+0x1e4>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff d6                	call   *%esi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb c9                	jmp    80049e <vprintfmt+0x1f0>
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004db:	eb c4                	jmp    8004a1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 20                	push   $0x20
  8004e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e5:	4f                   	dec    %edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f f0                	jg     8004dd <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f3:	e9 76 01 00 00       	jmp    80066e <vprintfmt+0x3c0>
  8004f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fe:	eb e9                	jmp    8004e9 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800500:	83 f9 01             	cmp    $0x1,%ecx
  800503:	7e 3f                	jle    800544 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 50 04             	mov    0x4(%eax),%edx
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 08             	lea    0x8(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80051c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800520:	79 5c                	jns    80057e <vprintfmt+0x2d0>
				putch('-', putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	6a 2d                	push   $0x2d
  800528:	ff d6                	call   *%esi
				num = -(long long) num;
  80052a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800530:	f7 da                	neg    %edx
  800532:	83 d1 00             	adc    $0x0,%ecx
  800535:	f7 d9                	neg    %ecx
  800537:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80053a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053f:	e9 10 01 00 00       	jmp    800654 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800544:	85 c9                	test   %ecx,%ecx
  800546:	75 1b                	jne    800563 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 40 04             	lea    0x4(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
  800561:	eb b9                	jmp    80051c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	eb 9e                	jmp    80051c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800581:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
  800589:	e9 c6 00 00 00       	jmp    800654 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058e:	83 f9 01             	cmp    $0x1,%ecx
  800591:	7e 18                	jle    8005ab <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 10                	mov    (%eax),%edx
  800598:	8b 48 04             	mov    0x4(%eax),%ecx
  80059b:	8d 40 08             	lea    0x8(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a6:	e9 a9 00 00 00       	jmp    800654 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ab:	85 c9                	test   %ecx,%ecx
  8005ad:	75 1a                	jne    8005c9 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c4:	e9 8b 00 00 00       	jmp    800654 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	eb 74                	jmp    800654 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7e 15                	jle    8005fa <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ed:	8d 40 08             	lea    0x8(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8005f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f8:	eb 5a                	jmp    800654 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005fa:	85 c9                	test   %ecx,%ecx
  8005fc:	75 17                	jne    800615 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	b9 00 00 00 00       	mov    $0x0,%ecx
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80060e:	b8 08 00 00 00       	mov    $0x8,%eax
  800613:	eb 3f                	jmp    800654 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800625:	b8 08 00 00 00       	mov    $0x8,%eax
  80062a:	eb 28                	jmp    800654 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065b:	57                   	push   %edi
  80065c:	ff 75 e0             	pushl  -0x20(%ebp)
  80065f:	50                   	push   %eax
  800660:	51                   	push   %ecx
  800661:	52                   	push   %edx
  800662:	89 da                	mov    %ebx,%edx
  800664:	89 f0                	mov    %esi,%eax
  800666:	e8 5d fb ff ff       	call   8001c8 <printnum>
			break;
  80066b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800671:	47                   	inc    %edi
  800672:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800676:	83 f8 25             	cmp    $0x25,%eax
  800679:	0f 84 46 fc ff ff    	je     8002c5 <vprintfmt+0x17>
			if (ch == '\0')
  80067f:	85 c0                	test   %eax,%eax
  800681:	0f 84 89 00 00 00    	je     800710 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	50                   	push   %eax
  80068c:	ff d6                	call   *%esi
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb de                	jmp    800671 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800693:	83 f9 01             	cmp    $0x1,%ecx
  800696:	7e 15                	jle    8006ad <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	8d 40 08             	lea    0x8(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ab:	eb a7                	jmp    800654 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	75 17                	jne    8006c8 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c6:	eb 8c                	jmp    800654 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006dd:	e9 72 ff ff ff       	jmp    800654 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	e9 7c ff ff ff       	jmp    80066e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	89 f8                	mov    %edi,%eax
  8006ff:	eb 01                	jmp    800702 <vprintfmt+0x454>
  800701:	48                   	dec    %eax
  800702:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800706:	75 f9                	jne    800701 <vprintfmt+0x453>
  800708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070b:	e9 5e ff ff ff       	jmp    80066e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 29                	jle    800766 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 75 02 80 00       	push   $0x800275
  80074c:	e8 5d fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb f7                	jmp    80075d <vsnprintf+0x45>
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb f0                	jmp    80075d <vsnprintf+0x45>

0080076d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 93 ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    
	...

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 01                	jmp    800796 <strlen+0xe>
		n++;
  800795:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	75 f9                	jne    800795 <strlen+0xd>
		n++;
	return n;
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	eb 01                	jmp    8007af <strnlen+0x11>
		n++;
  8007ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	39 d0                	cmp    %edx,%eax
  8007b1:	74 06                	je     8007b9 <strnlen+0x1b>
  8007b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b7:	75 f5                	jne    8007ae <strnlen+0x10>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	41                   	inc    %ecx
  8007c8:	42                   	inc    %edx
  8007c9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 f4                	jne    8007c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 a5 ff ff ff       	call   800788 <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 ca ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	39 da                	cmp    %ebx,%edx
  80080c:	74 0e                	je     80081c <strncpy+0x24>
		*dst++ = *src;
  80080e:	42                   	inc    %edx
  80080f:	8a 01                	mov    (%ecx),%al
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800814:	80 39 00             	cmpb   $0x0,(%ecx)
  800817:	74 f1                	je     80080a <strncpy+0x12>
			src++;
  800819:	41                   	inc    %ecx
  80081a:	eb ee                	jmp    80080a <strncpy+0x12>
	}
	return ret;
}
  80081c:	89 f0                	mov    %esi,%eax
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 75 08             	mov    0x8(%ebp),%esi
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800830:	85 c0                	test   %eax,%eax
  800832:	74 20                	je     800854 <strlcpy+0x32>
  800834:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800838:	89 f0                	mov    %esi,%eax
  80083a:	eb 05                	jmp    800841 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083c:	42                   	inc    %edx
  80083d:	40                   	inc    %eax
  80083e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	74 06                	je     80084b <strlcpy+0x29>
  800845:	8a 0a                	mov    (%edx),%cl
  800847:	84 c9                	test   %cl,%cl
  800849:	75 f1                	jne    80083c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80084b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084e:	29 f0                	sub    %esi,%eax
}
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    
  800854:	89 f0                	mov    %esi,%eax
  800856:	eb f6                	jmp    80084e <strlcpy+0x2c>

00800858 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800861:	eb 02                	jmp    800865 <strcmp+0xd>
		p++, q++;
  800863:	41                   	inc    %ecx
  800864:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800865:	8a 01                	mov    (%ecx),%al
  800867:	84 c0                	test   %al,%al
  800869:	74 04                	je     80086f <strcmp+0x17>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	74 f4                	je     800863 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 c3                	mov    %eax,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800888:	eb 02                	jmp    80088c <strncmp+0x13>
		n--, p++, q++;
  80088a:	40                   	inc    %eax
  80088b:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088c:	39 d8                	cmp    %ebx,%eax
  80088e:	74 15                	je     8008a5 <strncmp+0x2c>
  800890:	8a 08                	mov    (%eax),%cl
  800892:	84 c9                	test   %cl,%cl
  800894:	74 04                	je     80089a <strncmp+0x21>
  800896:	3a 0a                	cmp    (%edx),%cl
  800898:	74 f0                	je     80088a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 00             	movzbl (%eax),%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	eb f6                	jmp    8008a2 <strncmp+0x29>

008008ac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b5:	8a 10                	mov    (%eax),%dl
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	74 07                	je     8008c2 <strchr+0x16>
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 08                	je     8008c7 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bf:	40                   	inc    %eax
  8008c0:	eb f3                	jmp    8008b5 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d2:	8a 10                	mov    (%eax),%dl
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	74 07                	je     8008df <strfind+0x16>
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 03                	je     8008df <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008dc:	40                   	inc    %eax
  8008dd:	eb f3                	jmp    8008d2 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	57                   	push   %edi
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 13                	je     800904 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 05                	jne    8008fe <memset+0x1d>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	74 0d                	je     80090b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80090b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090f:	89 d3                	mov    %edx,%ebx
  800911:	c1 e3 08             	shl    $0x8,%ebx
  800914:	89 d0                	mov    %edx,%eax
  800916:	c1 e0 18             	shl    $0x18,%eax
  800919:	89 d6                	mov    %edx,%esi
  80091b:	c1 e6 10             	shl    $0x10,%esi
  80091e:	09 f0                	or     %esi,%eax
  800920:	09 c2                	or     %eax,%edx
  800922:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800924:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800927:	89 d0                	mov    %edx,%eax
  800929:	fc                   	cld    
  80092a:	f3 ab                	rep stos %eax,%es:(%edi)
  80092c:	eb d6                	jmp    800904 <memset+0x23>

0080092e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 75 0c             	mov    0xc(%ebp),%esi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093c:	39 c6                	cmp    %eax,%esi
  80093e:	73 33                	jae    800973 <memmove+0x45>
  800940:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800943:	39 c2                	cmp    %eax,%edx
  800945:	76 2c                	jbe    800973 <memmove+0x45>
		s += n;
		d += n;
  800947:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	09 fe                	or     %edi,%esi
  80094e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800954:	74 0a                	je     800960 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800956:	4f                   	dec    %edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 21                	jmp    800981 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 f1                	jne    800956 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800965:	83 ef 04             	sub    $0x4,%edi
  800968:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096e:	fd                   	std    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb ea                	jmp    80095d <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 f2                	mov    %esi,%edx
  800975:	09 c2                	or     %eax,%edx
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	74 09                	je     800985 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 f2                	jne    80097c <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb ed                	jmp    800981 <memmove+0x53>

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 89 ff ff ff       	call   80092e <memmove>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	39 f0                	cmp    %esi,%eax
  8009b9:	74 16                	je     8009d1 <memcmp+0x2a>
		if (*s1 != *s2)
  8009bb:	8a 08                	mov    (%eax),%cl
  8009bd:	8a 1a                	mov    (%edx),%bl
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	75 04                	jne    8009c7 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c3:	40                   	inc    %eax
  8009c4:	42                   	inc    %edx
  8009c5:	eb f0                	jmp    8009b7 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  8009c7:	0f b6 c1             	movzbl %cl,%eax
  8009ca:	0f b6 db             	movzbl %bl,%ebx
  8009cd:	29 d8                	sub    %ebx,%eax
  8009cf:	eb 05                	jmp    8009d6 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e3:	89 c2                	mov    %eax,%edx
  8009e5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e8:	39 d0                	cmp    %edx,%eax
  8009ea:	73 07                	jae    8009f3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	38 08                	cmp    %cl,(%eax)
  8009ee:	74 03                	je     8009f3 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	40                   	inc    %eax
  8009f1:	eb f5                	jmp    8009e8 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fe:	eb 01                	jmp    800a01 <strtol+0xc>
		s++;
  800a00:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a01:	8a 01                	mov    (%ecx),%al
  800a03:	3c 20                	cmp    $0x20,%al
  800a05:	74 f9                	je     800a00 <strtol+0xb>
  800a07:	3c 09                	cmp    $0x9,%al
  800a09:	74 f5                	je     800a00 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0b:	3c 2b                	cmp    $0x2b,%al
  800a0d:	74 2b                	je     800a3a <strtol+0x45>
		s++;
	else if (*s == '-')
  800a0f:	3c 2d                	cmp    $0x2d,%al
  800a11:	74 2f                	je     800a42 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a18:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a1f:	75 12                	jne    800a33 <strtol+0x3e>
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	74 24                	je     800a4a <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2a:	75 07                	jne    800a33 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	eb 4e                	jmp    800a88 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a3a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a40:	eb d6                	jmp    800a18 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a42:	41                   	inc    %ecx
  800a43:	bf 01 00 00 00       	mov    $0x1,%edi
  800a48:	eb ce                	jmp    800a18 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4e:	74 10                	je     800a60 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a54:	75 dd                	jne    800a33 <strtol+0x3e>
		s++, base = 8;
  800a56:	41                   	inc    %ecx
  800a57:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a5e:	eb d3                	jmp    800a33 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a60:	83 c1 02             	add    $0x2,%ecx
  800a63:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a6a:	eb c7                	jmp    800a33 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a6c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 24                	ja     800a9a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7c:	39 55 10             	cmp    %edx,0x10(%ebp)
  800a7f:	7e 2b                	jle    800aac <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800a81:	41                   	inc    %ecx
  800a82:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a86:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a88:	8a 11                	mov    (%ecx),%dl
  800a8a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a8d:	80 fb 09             	cmp    $0x9,%bl
  800a90:	77 da                	ja     800a6c <strtol+0x77>
			dig = *s - '0';
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 30             	sub    $0x30,%edx
  800a98:	eb e2                	jmp    800a7c <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0xb7>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
  800aaa:	eb d0                	jmp    800a7c <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab0:	74 05                	je     800ab7 <strtol+0xc2>
		*endptr = (char *) s;
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	74 02                	je     800abd <strtol+0xc8>
  800abb:	f7 d8                	neg    %eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
	...

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
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
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7f 08                	jg     800b2b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 03                	push   $0x3
  800b31:	68 a4 12 80 00       	push   $0x8012a4
  800b36:	6a 23                	push   $0x23
  800b38:	68 c1 12 80 00       	push   $0x8012c1
  800b3d:	e8 8e 02 00 00       	call   800dd0 <_panic>

00800b42 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	b8 04 00 00 00       	mov    $0x4,%eax
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7f 08                	jg     800bac <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 04                	push   $0x4
  800bb2:	68 a4 12 80 00       	push   $0x8012a4
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 c1 12 80 00       	push   $0x8012c1
  800bbe:	e8 0d 02 00 00       	call   800dd0 <_panic>

00800bc3 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 05                	push   $0x5
  800bf4:	68 a4 12 80 00       	push   $0x8012a4
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 c1 12 80 00       	push   $0x8012c1
  800c00:	e8 cb 01 00 00       	call   800dd0 <_panic>

00800c05 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7f 08                	jg     800c30 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 06                	push   $0x6
  800c36:	68 a4 12 80 00       	push   $0x8012a4
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 c1 12 80 00       	push   $0x8012c1
  800c42:	e8 89 01 00 00       	call   800dd0 <_panic>

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 08                	push   $0x8
  800c78:	68 a4 12 80 00       	push   $0x8012a4
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 c1 12 80 00       	push   $0x8012c1
  800c84:	e8 47 01 00 00       	call   800dd0 <_panic>

00800c89 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 09                	push   $0x9
  800cba:	68 a4 12 80 00       	push   $0x8012a4
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 c1 12 80 00       	push   $0x8012c1
  800cc6:	e8 05 01 00 00       	call   800dd0 <_panic>

00800ccb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdc:	be 00 00 00 00       	mov    $0x0,%esi
  800ce1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	89 cb                	mov    %ecx,%ebx
  800d06:	89 cf                	mov    %ecx,%edi
  800d08:	89 ce                	mov    %ecx,%esi
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7f 08                	jg     800d18 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 0c                	push   $0xc
  800d1e:	68 a4 12 80 00       	push   $0x8012a4
  800d23:	6a 23                	push   $0x23
  800d25:	68 c1 12 80 00       	push   $0x8012c1
  800d2a:	e8 a1 00 00 00       	call   800dd0 <_panic>
	...

00800d30 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d36:	68 db 12 80 00       	push   $0x8012db
  800d3b:	6a 51                	push   $0x51
  800d3d:	68 cf 12 80 00       	push   $0x8012cf
  800d42:	e8 89 00 00 00       	call   800dd0 <_panic>

00800d47 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d4d:	68 da 12 80 00       	push   $0x8012da
  800d52:	6a 58                	push   $0x58
  800d54:	68 cf 12 80 00       	push   $0x8012cf
  800d59:	e8 72 00 00 00       	call   800dd0 <_panic>
	...

00800d60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d66:	68 f0 12 80 00       	push   $0x8012f0
  800d6b:	6a 1a                	push   $0x1a
  800d6d:	68 09 13 80 00       	push   $0x801309
  800d72:	e8 59 00 00 00       	call   800dd0 <_panic>

00800d77 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d7d:	68 13 13 80 00       	push   $0x801313
  800d82:	6a 2a                	push   $0x2a
  800d84:	68 09 13 80 00       	push   $0x801309
  800d89:	e8 42 00 00 00       	call   800dd0 <_panic>

00800d8e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	c1 e2 05             	shl    $0x5,%edx
  800d9e:	29 c2                	sub    %eax,%edx
  800da0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800da7:	8b 52 50             	mov    0x50(%edx),%edx
  800daa:	39 ca                	cmp    %ecx,%edx
  800dac:	74 0f                	je     800dbd <ipc_find_env+0x2f>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dae:	40                   	inc    %eax
  800daf:	3d 00 04 00 00       	cmp    $0x400,%eax
  800db4:	75 e3                	jne    800d99 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800db6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbb:	eb 11                	jmp    800dce <ipc_find_env+0x40>
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 e2 05             	shl    $0x5,%edx
  800dc2:	29 c2                	sub    %eax,%edx
  800dc4:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800dcb:	8b 40 48             	mov    0x48(%eax),%eax
	return 0;
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dd8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dde:	e8 5f fd ff ff       	call   800b42 <sys_getenvid>
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	ff 75 08             	pushl  0x8(%ebp)
  800dec:	56                   	push   %esi
  800ded:	50                   	push   %eax
  800dee:	68 2c 13 80 00       	push   $0x80132c
  800df3:	e8 bc f3 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df8:	83 c4 18             	add    $0x18,%esp
  800dfb:	53                   	push   %ebx
  800dfc:	ff 75 10             	pushl  0x10(%ebp)
  800dff:	e8 5f f3 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  800e04:	c7 04 24 47 10 80 00 	movl   $0x801047,(%esp)
  800e0b:	e8 a4 f3 ff ff       	call   8001b4 <cprintf>
  800e10:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e13:	cc                   	int3   
  800e14:	eb fd                	jmp    800e13 <_panic+0x43>
	...

00800e18 <__udivdi3>:
  800e18:	55                   	push   %ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 1c             	sub    $0x1c,%esp
  800e1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2f:	85 d2                	test   %edx,%edx
  800e31:	75 2d                	jne    800e60 <__udivdi3+0x48>
  800e33:	39 f7                	cmp    %esi,%edi
  800e35:	77 59                	ja     800e90 <__udivdi3+0x78>
  800e37:	89 f9                	mov    %edi,%ecx
  800e39:	85 ff                	test   %edi,%edi
  800e3b:	75 0b                	jne    800e48 <__udivdi3+0x30>
  800e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e42:	31 d2                	xor    %edx,%edx
  800e44:	f7 f7                	div    %edi
  800e46:	89 c1                	mov    %eax,%ecx
  800e48:	31 d2                	xor    %edx,%edx
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	f7 f1                	div    %ecx
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	89 e8                	mov    %ebp,%eax
  800e52:	f7 f1                	div    %ecx
  800e54:	89 da                	mov    %ebx,%edx
  800e56:	83 c4 1c             	add    $0x1c,%esp
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    
  800e5e:	66 90                	xchg   %ax,%ax
  800e60:	39 f2                	cmp    %esi,%edx
  800e62:	77 1c                	ja     800e80 <__udivdi3+0x68>
  800e64:	0f bd da             	bsr    %edx,%ebx
  800e67:	83 f3 1f             	xor    $0x1f,%ebx
  800e6a:	75 38                	jne    800ea4 <__udivdi3+0x8c>
  800e6c:	39 f2                	cmp    %esi,%edx
  800e6e:	72 08                	jb     800e78 <__udivdi3+0x60>
  800e70:	39 ef                	cmp    %ebp,%edi
  800e72:	0f 87 98 00 00 00    	ja     800f10 <__udivdi3+0xf8>
  800e78:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7d:	eb 05                	jmp    800e84 <__udivdi3+0x6c>
  800e7f:	90                   	nop
  800e80:	31 db                	xor    %ebx,%ebx
  800e82:	31 c0                	xor    %eax,%eax
  800e84:	89 da                	mov    %ebx,%edx
  800e86:	83 c4 1c             	add    $0x1c,%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	89 e8                	mov    %ebp,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	f7 f7                	div    %edi
  800e96:	31 db                	xor    %ebx,%ebx
  800e98:	89 da                	mov    %ebx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	66 90                	xchg   %ax,%ax
  800ea4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea9:	29 d8                	sub    %ebx,%eax
  800eab:	88 d9                	mov    %bl,%cl
  800ead:	d3 e2                	shl    %cl,%edx
  800eaf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eb3:	89 fa                	mov    %edi,%edx
  800eb5:	88 c1                	mov    %al,%cl
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ebd:	09 d1                	or     %edx,%ecx
  800ebf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec3:	88 d9                	mov    %bl,%cl
  800ec5:	d3 e7                	shl    %cl,%edi
  800ec7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ecb:	89 f7                	mov    %esi,%edi
  800ecd:	88 c1                	mov    %al,%cl
  800ecf:	d3 ef                	shr    %cl,%edi
  800ed1:	88 d9                	mov    %bl,%cl
  800ed3:	d3 e6                	shl    %cl,%esi
  800ed5:	89 ea                	mov    %ebp,%edx
  800ed7:	88 c1                	mov    %al,%cl
  800ed9:	d3 ea                	shr    %cl,%edx
  800edb:	09 d6                	or     %edx,%esi
  800edd:	89 f0                	mov    %esi,%eax
  800edf:	89 fa                	mov    %edi,%edx
  800ee1:	f7 74 24 08          	divl   0x8(%esp)
  800ee5:	89 d7                	mov    %edx,%edi
  800ee7:	89 c6                	mov    %eax,%esi
  800ee9:	f7 64 24 0c          	mull   0xc(%esp)
  800eed:	39 d7                	cmp    %edx,%edi
  800eef:	72 13                	jb     800f04 <__udivdi3+0xec>
  800ef1:	74 09                	je     800efc <__udivdi3+0xe4>
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	31 db                	xor    %ebx,%ebx
  800ef7:	eb 8b                	jmp    800e84 <__udivdi3+0x6c>
  800ef9:	8d 76 00             	lea    0x0(%esi),%esi
  800efc:	88 d9                	mov    %bl,%cl
  800efe:	d3 e5                	shl    %cl,%ebp
  800f00:	39 c5                	cmp    %eax,%ebp
  800f02:	73 ef                	jae    800ef3 <__udivdi3+0xdb>
  800f04:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f07:	31 db                	xor    %ebx,%ebx
  800f09:	e9 76 ff ff ff       	jmp    800e84 <__udivdi3+0x6c>
  800f0e:	66 90                	xchg   %ax,%ax
  800f10:	31 c0                	xor    %eax,%eax
  800f12:	e9 6d ff ff ff       	jmp    800e84 <__udivdi3+0x6c>
	...

00800f18 <__umoddi3>:
  800f18:	55                   	push   %ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 1c             	sub    $0x1c,%esp
  800f1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f2b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f2f:	89 f0                	mov    %esi,%eax
  800f31:	89 da                	mov    %ebx,%edx
  800f33:	85 ed                	test   %ebp,%ebp
  800f35:	75 15                	jne    800f4c <__umoddi3+0x34>
  800f37:	39 df                	cmp    %ebx,%edi
  800f39:	76 39                	jbe    800f74 <__umoddi3+0x5c>
  800f3b:	f7 f7                	div    %edi
  800f3d:	89 d0                	mov    %edx,%eax
  800f3f:	31 d2                	xor    %edx,%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d 76 00             	lea    0x0(%esi),%esi
  800f4c:	39 dd                	cmp    %ebx,%ebp
  800f4e:	77 f1                	ja     800f41 <__umoddi3+0x29>
  800f50:	0f bd cd             	bsr    %ebp,%ecx
  800f53:	83 f1 1f             	xor    $0x1f,%ecx
  800f56:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f5a:	75 38                	jne    800f94 <__umoddi3+0x7c>
  800f5c:	39 dd                	cmp    %ebx,%ebp
  800f5e:	72 04                	jb     800f64 <__umoddi3+0x4c>
  800f60:	39 f7                	cmp    %esi,%edi
  800f62:	77 dd                	ja     800f41 <__umoddi3+0x29>
  800f64:	89 da                	mov    %ebx,%edx
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	29 f8                	sub    %edi,%eax
  800f6a:	19 ea                	sbb    %ebp,%edx
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	89 f9                	mov    %edi,%ecx
  800f76:	85 ff                	test   %edi,%edi
  800f78:	75 0b                	jne    800f85 <__umoddi3+0x6d>
  800f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7f:	31 d2                	xor    %edx,%edx
  800f81:	f7 f7                	div    %edi
  800f83:	89 c1                	mov    %eax,%ecx
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	31 d2                	xor    %edx,%edx
  800f89:	f7 f1                	div    %ecx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	f7 f1                	div    %ecx
  800f8f:	eb ac                	jmp    800f3d <__umoddi3+0x25>
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
  800f94:	b8 20 00 00 00       	mov    $0x20,%eax
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9f:	29 c2                	sub    %eax,%edx
  800fa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa5:	88 c1                	mov    %al,%cl
  800fa7:	d3 e5                	shl    %cl,%ebp
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	88 d1                	mov    %dl,%cl
  800fad:	d3 e8                	shr    %cl,%eax
  800faf:	09 c5                	or     %eax,%ebp
  800fb1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fb5:	88 c1                	mov    %al,%cl
  800fb7:	d3 e7                	shl    %cl,%edi
  800fb9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fbd:	89 df                	mov    %ebx,%edi
  800fbf:	88 d1                	mov    %dl,%cl
  800fc1:	d3 ef                	shr    %cl,%edi
  800fc3:	88 c1                	mov    %al,%cl
  800fc5:	d3 e3                	shl    %cl,%ebx
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	88 d1                	mov    %dl,%cl
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	09 d8                	or     %ebx,%eax
  800fcf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fd3:	d3 e6                	shl    %cl,%esi
  800fd5:	89 fa                	mov    %edi,%edx
  800fd7:	f7 f5                	div    %ebp
  800fd9:	89 d1                	mov    %edx,%ecx
  800fdb:	f7 64 24 08          	mull   0x8(%esp)
  800fdf:	89 c3                	mov    %eax,%ebx
  800fe1:	89 d7                	mov    %edx,%edi
  800fe3:	39 d1                	cmp    %edx,%ecx
  800fe5:	72 29                	jb     801010 <__umoddi3+0xf8>
  800fe7:	74 23                	je     80100c <__umoddi3+0xf4>
  800fe9:	89 ca                	mov    %ecx,%edx
  800feb:	29 de                	sub    %ebx,%esi
  800fed:	19 fa                	sbb    %edi,%edx
  800fef:	89 d0                	mov    %edx,%eax
  800ff1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ff5:	d3 e0                	shl    %cl,%eax
  800ff7:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800ffb:	88 d9                	mov    %bl,%cl
  800ffd:	d3 ee                	shr    %cl,%esi
  800fff:	09 f0                	or     %esi,%eax
  801001:	d3 ea                	shr    %cl,%edx
  801003:	83 c4 1c             	add    $0x1c,%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
  80100b:	90                   	nop
  80100c:	39 c6                	cmp    %eax,%esi
  80100e:	73 d9                	jae    800fe9 <__umoddi3+0xd1>
  801010:	2b 44 24 08          	sub    0x8(%esp),%eax
  801014:	19 ea                	sbb    %ebp,%edx
  801016:	89 d7                	mov    %edx,%edi
  801018:	89 c3                	mov    %eax,%ebx
  80101a:	eb cd                	jmp    800fe9 <__umoddi3+0xd1>
