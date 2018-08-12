
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 49 0d 00 00       	call   800d8b <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	75 72                	jne    8000bb <umain+0x87>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	6a 00                	push   $0x0
  800050:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800053:	50                   	push   %eax
  800054:	e8 4b 0d 00 00       	call   800da4 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800059:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005f:	8b 7b 48             	mov    0x48(%ebx),%edi
  800062:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800065:	a1 04 20 80 00       	mov    0x802004,%eax
  80006a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006d:	e8 14 0b 00 00       	call   800b86 <sys_getenvid>
  800072:	83 c4 08             	add    $0x8,%esp
  800075:	57                   	push   %edi
  800076:	53                   	push   %ebx
  800077:	56                   	push   %esi
  800078:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007b:	50                   	push   %eax
  80007c:	68 90 10 80 00       	push   $0x801090
  800081:	e8 72 01 00 00       	call   8001f8 <cprintf>
		if (val == 10)
  800086:	a1 04 20 80 00       	mov    0x802004,%eax
  80008b:	83 c4 20             	add    $0x20,%esp
  80008e:	83 f8 0a             	cmp    $0xa,%eax
  800091:	74 20                	je     8000b3 <umain+0x7f>
			return;
		++val;
  800093:	40                   	inc    %eax
  800094:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800099:	6a 00                	push   $0x0
  80009b:	6a 00                	push   $0x0
  80009d:	6a 00                	push   $0x0
  80009f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a2:	e8 14 0d 00 00       	call   800dbb <ipc_send>
		if (val == 10)
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b1:	75 96                	jne    800049 <umain+0x15>
			return;
	}

}
  8000b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bb:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c1:	e8 c0 0a 00 00       	call   800b86 <sys_getenvid>
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	53                   	push   %ebx
  8000ca:	50                   	push   %eax
  8000cb:	68 60 10 80 00       	push   $0x801060
  8000d0:	e8 23 01 00 00       	call   8001f8 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d8:	e8 a9 0a 00 00       	call   800b86 <sys_getenvid>
  8000dd:	83 c4 0c             	add    $0xc,%esp
  8000e0:	53                   	push   %ebx
  8000e1:	50                   	push   %eax
  8000e2:	68 7a 10 80 00       	push   $0x80107a
  8000e7:	e8 0c 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ec:	6a 00                	push   $0x0
  8000ee:	6a 00                	push   $0x0
  8000f0:	6a 00                	push   $0x0
  8000f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f5:	e8 c1 0c 00 00       	call   800dbb <ipc_send>
  8000fa:	83 c4 20             	add    $0x20,%esp
  8000fd:	e9 47 ff ff ff       	jmp    800049 <umain+0x15>
	...

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010f:	e8 72 0a 00 00       	call   800b86 <sys_getenvid>
  800114:	25 ff 03 00 00       	and    $0x3ff,%eax
  800119:	89 c2                	mov    %eax,%edx
  80011b:	c1 e2 05             	shl    $0x5,%edx
  80011e:	29 c2                	sub    %eax,%edx
  800120:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800127:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 db                	test   %ebx,%ebx
  80012e:	7e 07                	jle    800137 <libmain+0x33>
		binaryname = argv[0];
  800130:	8b 06                	mov    (%esi),%eax
  800132:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800137:	83 ec 08             	sub    $0x8,%esp
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
  80013c:	e8 f3 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800156:	6a 00                	push   $0x0
  800158:	e8 e8 09 00 00       	call   800b45 <sys_env_destroy>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	74 08                	je     80018b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800183:	ff 43 04             	incl   0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	68 ff 00 00 00       	push   $0xff
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	e8 6c 09 00 00       	call   800b08 <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb dc                	jmp    800183 <putch+0x1f>

008001a7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 64 01 80 00       	push   $0x800164
  8001d6:	e8 17 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 18 09 00 00       	call   800b08 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 78                	ja     8002b4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 fc 0b 00 00       	call   800e5c <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 11                	jmp    800284 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027f:	4b                   	dec    %ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ef                	jg     800273 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 c0 0c 00 00       	call   800f5c <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 c0 10 80 00 	movsbl 0x8010c0(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    
  8002b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b7:	eb c6                	jmp    80027f <printnum+0x73>

008002b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bf:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c7:	73 0a                	jae    8002d3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	88 02                	mov    %al,(%edx)
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	e8 05 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 2c             	sub    $0x2c,%esp
  8002fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 7d 10             	mov    0x10(%ebp),%edi
  800304:	e9 ac 03 00 00       	jmp    8006b5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800309:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80030d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80031b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8d 47 01             	lea    0x1(%edi),%eax
  80032a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032d:	8a 17                	mov    (%edi),%dl
  80032f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800332:	3c 55                	cmp    $0x55,%al
  800334:	0f 87 fc 03 00 00    	ja     800736 <vprintfmt+0x444>
  80033a:	0f b6 c0             	movzbl %al,%eax
  80033d:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80034b:	eb da                	jmp    800327 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800354:	eb d1                	jmp    800327 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	0f b6 d2             	movzbl %dl,%edx
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800364:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800367:	01 c0                	add    %eax,%eax
  800369:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80036d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800370:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800373:	83 f9 09             	cmp    $0x9,%ecx
  800376:	77 52                	ja     8003ca <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800378:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800379:	eb e9                	jmp    800364 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 40 04             	lea    0x4(%eax),%eax
  800389:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800393:	79 92                	jns    800327 <vprintfmt+0x35>
				width = precision, precision = -1;
  800395:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a2:	eb 83                	jmp    800327 <vprintfmt+0x35>
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	78 08                	js     8003b2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ad:	e9 75 ff ff ff       	jmp    800327 <vprintfmt+0x35>
  8003b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b9:	eb ef                	jmp    8003aa <vprintfmt+0xb8>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	e9 5d ff ff ff       	jmp    800327 <vprintfmt+0x35>
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	eb bd                	jmp    80038f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d6:	e9 4c ff ff ff       	jmp    800327 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 78 04             	lea    0x4(%eax),%edi
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	53                   	push   %ebx
  8003e5:	ff 30                	pushl  (%eax)
  8003e7:	ff d6                	call   *%esi
			break;
  8003e9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ec:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ef:	e9 be 02 00 00       	jmp    8006b2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 78 04             	lea    0x4(%eax),%edi
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	78 2a                	js     80042a <vprintfmt+0x138>
  800400:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800402:	83 f8 08             	cmp    $0x8,%eax
  800405:	7f 27                	jg     80042e <vprintfmt+0x13c>
  800407:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  80040e:	85 c0                	test   %eax,%eax
  800410:	74 1c                	je     80042e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800412:	50                   	push   %eax
  800413:	68 e1 10 80 00       	push   $0x8010e1
  800418:	53                   	push   %ebx
  800419:	56                   	push   %esi
  80041a:	e8 b6 fe ff ff       	call   8002d5 <printfmt>
  80041f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	89 7d 14             	mov    %edi,0x14(%ebp)
  800425:	e9 88 02 00 00       	jmp    8006b2 <vprintfmt+0x3c0>
  80042a:	f7 d8                	neg    %eax
  80042c:	eb d2                	jmp    800400 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042e:	52                   	push   %edx
  80042f:	68 d8 10 80 00       	push   $0x8010d8
  800434:	53                   	push   %ebx
  800435:	56                   	push   %esi
  800436:	e8 9a fe ff ff       	call   8002d5 <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800441:	e9 6c 02 00 00       	jmp    8006b2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	83 c0 04             	add    $0x4,%eax
  80044c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8b 38                	mov    (%eax),%edi
  800454:	85 ff                	test   %edi,%edi
  800456:	74 18                	je     800470 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800458:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045c:	0f 8e b7 00 00 00    	jle    800519 <vprintfmt+0x227>
  800462:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800466:	75 0f                	jne    800477 <vprintfmt+0x185>
  800468:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80046e:	eb 75                	jmp    8004e5 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800470:	bf d1 10 80 00       	mov    $0x8010d1,%edi
  800475:	eb e1                	jmp    800458 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 d0             	pushl  -0x30(%ebp)
  80047d:	57                   	push   %edi
  80047e:	e8 5f 03 00 00       	call   8007e2 <strnlen>
  800483:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800486:	29 c1                	sub    %eax,%ecx
  800488:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800492:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800495:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800498:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049a:	eb 0d                	jmp    8004a9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	4f                   	dec    %edi
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	7f ef                	jg     80049c <vprintfmt+0x1aa>
  8004ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b3:	89 c8                	mov    %ecx,%eax
  8004b5:	85 c9                	test   %ecx,%ecx
  8004b7:	78 10                	js     8004c9 <vprintfmt+0x1d7>
  8004b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bc:	29 c1                	sub    %eax,%ecx
  8004be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004c7:	eb 1c                	jmp    8004e5 <vprintfmt+0x1f3>
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ce:	eb e9                	jmp    8004b9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d4:	75 29                	jne    8004ff <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	50                   	push   %eax
  8004dd:	ff d6                	call   *%esi
  8004df:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e0             	decl   -0x20(%ebp)
  8004e5:	47                   	inc    %edi
  8004e6:	8a 57 ff             	mov    -0x1(%edi),%dl
  8004e9:	0f be c2             	movsbl %dl,%eax
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 4c                	je     80053c <vprintfmt+0x24a>
  8004f0:	85 db                	test   %ebx,%ebx
  8004f2:	78 dc                	js     8004d0 <vprintfmt+0x1de>
  8004f4:	4b                   	dec    %ebx
  8004f5:	79 d9                	jns    8004d0 <vprintfmt+0x1de>
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004fd:	eb 2e                	jmp    80052d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	0f be d2             	movsbl %dl,%edx
  800502:	83 ea 20             	sub    $0x20,%edx
  800505:	83 fa 5e             	cmp    $0x5e,%edx
  800508:	76 cc                	jbe    8004d6 <vprintfmt+0x1e4>
					putch('?', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	6a 3f                	push   $0x3f
  800512:	ff d6                	call   *%esi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb c9                	jmp    8004e2 <vprintfmt+0x1f0>
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80051f:	eb c4                	jmp    8004e5 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	53                   	push   %ebx
  800525:	6a 20                	push   $0x20
  800527:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800529:	4f                   	dec    %edi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 ff                	test   %edi,%edi
  80052f:	7f f0                	jg     800521 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800531:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
  800537:	e9 76 01 00 00       	jmp    8006b2 <vprintfmt+0x3c0>
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800542:	eb e9                	jmp    80052d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 3f                	jle    800588 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800560:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800564:	79 5c                	jns    8005c2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	6a 2d                	push   $0x2d
  80056c:	ff d6                	call   *%esi
				num = -(long long) num;
  80056e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800571:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800574:	f7 da                	neg    %edx
  800576:	83 d1 00             	adc    $0x0,%ecx
  800579:	f7 d9                	neg    %ecx
  80057b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 10 01 00 00       	jmp    800698 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	75 1b                	jne    8005a7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a5:	eb b9                	jmp    800560 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005af:	89 c1                	mov    %eax,%ecx
  8005b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 40 04             	lea    0x4(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c0:	eb 9e                	jmp    800560 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cd:	e9 c6 00 00 00       	jmp    800698 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d2:	83 f9 01             	cmp    $0x1,%ecx
  8005d5:	7e 18                	jle    8005ef <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005df:	8d 40 08             	lea    0x8(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 a9 00 00 00       	jmp    800698 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	75 1a                	jne    80060d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
  800608:	e9 8b 00 00 00       	jmp    800698 <vprintfmt+0x3a6>
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
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	eb 74                	jmp    800698 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800624:	83 f9 01             	cmp    $0x1,%ecx
  800627:	7e 15                	jle    80063e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	8b 48 04             	mov    0x4(%eax),%ecx
  800631:	8d 40 08             	lea    0x8(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800637:	b8 08 00 00 00       	mov    $0x8,%eax
  80063c:	eb 5a                	jmp    800698 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	75 17                	jne    800659 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800652:	b8 08 00 00 00       	mov    $0x8,%eax
  800657:	eb 3f                	jmp    800698 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800669:	b8 08 00 00 00       	mov    $0x8,%eax
  80066e:	eb 28                	jmp    800698 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 30                	push   $0x30
  800676:	ff d6                	call   *%esi
			putch('x', putdat);
  800678:	83 c4 08             	add    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 78                	push   $0x78
  80067e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 10                	mov    (%eax),%edx
  800685:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069f:	57                   	push   %edi
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	50                   	push   %eax
  8006a4:	51                   	push   %ecx
  8006a5:	52                   	push   %edx
  8006a6:	89 da                	mov    %ebx,%edx
  8006a8:	89 f0                	mov    %esi,%eax
  8006aa:	e8 5d fb ff ff       	call   80020c <printnum>
			break;
  8006af:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b5:	47                   	inc    %edi
  8006b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ba:	83 f8 25             	cmp    $0x25,%eax
  8006bd:	0f 84 46 fc ff ff    	je     800309 <vprintfmt+0x17>
			if (ch == '\0')
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	0f 84 89 00 00 00    	je     800754 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	50                   	push   %eax
  8006d0:	ff d6                	call   *%esi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb de                	jmp    8006b5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7e 15                	jle    8006f1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e4:	8d 40 08             	lea    0x8(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ef:	eb a7                	jmp    800698 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	75 17                	jne    80070c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
  80070a:	eb 8c                	jmp    800698 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071c:	b8 10 00 00 00       	mov    $0x10,%eax
  800721:	e9 72 ff ff ff       	jmp    800698 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			break;
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	e9 7c ff ff ff       	jmp    8006b2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 25                	push   $0x25
  80073c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	89 f8                	mov    %edi,%eax
  800743:	eb 01                	jmp    800746 <vprintfmt+0x454>
  800745:	48                   	dec    %eax
  800746:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074a:	75 f9                	jne    800745 <vprintfmt+0x453>
  80074c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074f:	e9 5e ff ff ff       	jmp    8006b2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 18             	sub    $0x18,%esp
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800779:	85 c0                	test   %eax,%eax
  80077b:	74 26                	je     8007a3 <vsnprintf+0x47>
  80077d:	85 d2                	test   %edx,%edx
  80077f:	7e 29                	jle    8007aa <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800781:	ff 75 14             	pushl  0x14(%ebp)
  800784:	ff 75 10             	pushl  0x10(%ebp)
  800787:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	68 b9 02 80 00       	push   $0x8002b9
  800790:	e8 5d fb ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800795:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800798:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079e:	83 c4 10             	add    $0x10,%esp
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb f7                	jmp    8007a1 <vsnprintf+0x45>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007af:	eb f0                	jmp    8007a1 <vsnprintf+0x45>

008007b1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	50                   	push   %eax
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	ff 75 08             	pushl  0x8(%ebp)
  8007c4:	e8 93 ff ff ff       	call   80075c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    
	...

008007cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	eb 01                	jmp    8007da <strlen+0xe>
		n++;
  8007d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007de:	75 f9                	jne    8007d9 <strlen+0xd>
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	eb 01                	jmp    8007f3 <strnlen+0x11>
		n++;
  8007f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	39 d0                	cmp    %edx,%eax
  8007f5:	74 06                	je     8007fd <strnlen+0x1b>
  8007f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fb:	75 f5                	jne    8007f2 <strnlen+0x10>
		n++;
	return n;
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800809:	89 c2                	mov    %eax,%edx
  80080b:	41                   	inc    %ecx
  80080c:	42                   	inc    %edx
  80080d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800810:	88 5a ff             	mov    %bl,-0x1(%edx)
  800813:	84 db                	test   %bl,%bl
  800815:	75 f4                	jne    80080b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800821:	53                   	push   %ebx
  800822:	e8 a5 ff ff ff       	call   8007cc <strlen>
  800827:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082a:	ff 75 0c             	pushl  0xc(%ebp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	50                   	push   %eax
  800830:	e8 ca ff ff ff       	call   8007ff <strcpy>
	return dst;
}
  800835:	89 d8                	mov    %ebx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	89 f3                	mov    %esi,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	39 da                	cmp    %ebx,%edx
  800850:	74 0e                	je     800860 <strncpy+0x24>
		*dst++ = *src;
  800852:	42                   	inc    %edx
  800853:	8a 01                	mov    (%ecx),%al
  800855:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800858:	80 39 00             	cmpb   $0x0,(%ecx)
  80085b:	74 f1                	je     80084e <strncpy+0x12>
			src++;
  80085d:	41                   	inc    %ecx
  80085e:	eb ee                	jmp    80084e <strncpy+0x12>
	}
	return ret;
}
  800860:	89 f0                	mov    %esi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	85 c0                	test   %eax,%eax
  800876:	74 20                	je     800898 <strlcpy+0x32>
  800878:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	eb 05                	jmp    800885 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	42                   	inc    %edx
  800881:	40                   	inc    %eax
  800882:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	39 d8                	cmp    %ebx,%eax
  800887:	74 06                	je     80088f <strlcpy+0x29>
  800889:	8a 0a                	mov    (%edx),%cl
  80088b:	84 c9                	test   %cl,%cl
  80088d:	75 f1                	jne    800880 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80088f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800892:	29 f0                	sub    %esi,%eax
}
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
  800898:	89 f0                	mov    %esi,%eax
  80089a:	eb f6                	jmp    800892 <strlcpy+0x2c>

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 02                	jmp    8008a9 <strcmp+0xd>
		p++, q++;
  8008a7:	41                   	inc    %ecx
  8008a8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a9:	8a 01                	mov    (%ecx),%al
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 04                	je     8008b3 <strcmp+0x17>
  8008af:	3a 02                	cmp    (%edx),%al
  8008b1:	74 f4                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 c0             	movzbl %al,%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 c3                	mov    %eax,%ebx
  8008c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 02                	jmp    8008d0 <strncmp+0x13>
		n--, p++, q++;
  8008ce:	40                   	inc    %eax
  8008cf:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d0:	39 d8                	cmp    %ebx,%eax
  8008d2:	74 15                	je     8008e9 <strncmp+0x2c>
  8008d4:	8a 08                	mov    (%eax),%cl
  8008d6:	84 c9                	test   %cl,%cl
  8008d8:	74 04                	je     8008de <strncmp+0x21>
  8008da:	3a 0a                	cmp    (%edx),%cl
  8008dc:	74 f0                	je     8008ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 00             	movzbl (%eax),%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	eb f6                	jmp    8008e6 <strncmp+0x29>

008008f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	74 07                	je     800906 <strchr+0x16>
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	74 08                	je     80090b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800903:	40                   	inc    %eax
  800904:	eb f3                	jmp    8008f9 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	74 07                	je     800923 <strfind+0x16>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 03                	je     800923 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	eb f3                	jmp    800916 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 13                	je     800948 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 05                	jne    800942 <memset+0x1d>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	74 0d                	je     80094f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	fc                   	cld    
  800946:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800948:	89 f8                	mov    %edi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80094f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800953:	89 d3                	mov    %edx,%ebx
  800955:	c1 e3 08             	shl    $0x8,%ebx
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 18             	shl    $0x18,%eax
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 10             	shl    $0x10,%esi
  800962:	09 f0                	or     %esi,%eax
  800964:	09 c2                	or     %eax,%edx
  800966:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800968:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb d6                	jmp    800948 <memset+0x23>

00800972 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800980:	39 c6                	cmp    %eax,%esi
  800982:	73 33                	jae    8009b7 <memmove+0x45>
  800984:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800987:	39 c2                	cmp    %eax,%edx
  800989:	76 2c                	jbe    8009b7 <memmove+0x45>
		s += n;
		d += n;
  80098b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 d6                	mov    %edx,%esi
  800990:	09 fe                	or     %edi,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	74 0a                	je     8009a4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099a:	4f                   	dec    %edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 21                	jmp    8009c5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 f1                	jne    80099a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb ea                	jmp    8009a1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b7:	89 f2                	mov    %esi,%edx
  8009b9:	09 c2                	or     %eax,%edx
  8009bb:	f6 c2 03             	test   $0x3,%dl
  8009be:	74 09                	je     8009c9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 f2                	jne    8009c0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb ed                	jmp    8009c5 <memmove+0x53>

008009d8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009db:	ff 75 10             	pushl  0x10(%ebp)
  8009de:	ff 75 0c             	pushl  0xc(%ebp)
  8009e1:	ff 75 08             	pushl  0x8(%ebp)
  8009e4:	e8 89 ff ff ff       	call   800972 <memmove>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f6:	89 c6                	mov    %eax,%esi
  8009f8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	39 f0                	cmp    %esi,%eax
  8009fd:	74 16                	je     800a15 <memcmp+0x2a>
		if (*s1 != *s2)
  8009ff:	8a 08                	mov    (%eax),%cl
  800a01:	8a 1a                	mov    (%edx),%bl
  800a03:	38 d9                	cmp    %bl,%cl
  800a05:	75 04                	jne    800a0b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a07:	40                   	inc    %eax
  800a08:	42                   	inc    %edx
  800a09:	eb f0                	jmp    8009fb <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2c:	39 d0                	cmp    %edx,%eax
  800a2e:	73 07                	jae    800a37 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	38 08                	cmp    %cl,(%eax)
  800a32:	74 03                	je     800a37 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a34:	40                   	inc    %eax
  800a35:	eb f5                	jmp    800a2c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	eb 01                	jmp    800a45 <strtol+0xc>
		s++;
  800a44:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	8a 01                	mov    (%ecx),%al
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f9                	je     800a44 <strtol+0xb>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f5                	je     800a44 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	74 2b                	je     800a7e <strtol+0x45>
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	74 2f                	je     800a86 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a63:	75 12                	jne    800a77 <strtol+0x3e>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	74 24                	je     800a8e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a6e:	75 07                	jne    800a77 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	eb 4e                	jmp    800acc <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a7e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a84:	eb d6                	jmp    800a5c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a86:	41                   	inc    %ecx
  800a87:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8c:	eb ce                	jmp    800a5c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a92:	74 10                	je     800aa4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a98:	75 dd                	jne    800a77 <strtol+0x3e>
		s++, base = 8;
  800a9a:	41                   	inc    %ecx
  800a9b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800aa2:	eb d3                	jmp    800a77 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800aa4:	83 c1 02             	add    $0x2,%ecx
  800aa7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aae:	eb c7                	jmp    800a77 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab3:	89 f3                	mov    %esi,%ebx
  800ab5:	80 fb 19             	cmp    $0x19,%bl
  800ab8:	77 24                	ja     800ade <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aba:	0f be d2             	movsbl %dl,%edx
  800abd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800ac3:	7e 2b                	jle    800af0 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ac5:	41                   	inc    %ecx
  800ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aca:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acc:	8a 11                	mov    (%ecx),%dl
  800ace:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 da                	ja     800ab0 <strtol+0x77>
			dig = *s - '0';
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 30             	sub    $0x30,%edx
  800adc:	eb e2                	jmp    800ac0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
  800aee:	eb d0                	jmp    800ac0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af4:	74 05                	je     800afb <strtol+0xc2>
		*endptr = (char *) s;
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800afb:	85 ff                	test   %edi,%edi
  800afd:	74 02                	je     800b01 <strtol+0xc8>
  800aff:	f7 d8                	neg    %eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
	...

00800b08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	89 c6                	mov    %eax,%esi
  800b1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5b:	89 cb                	mov    %ecx,%ebx
  800b5d:	89 cf                	mov    %ecx,%edi
  800b5f:	89 ce                	mov    %ecx,%esi
  800b61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7f 08                	jg     800b6f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	50                   	push   %eax
  800b73:	6a 03                	push   $0x3
  800b75:	68 04 13 80 00       	push   $0x801304
  800b7a:	6a 23                	push   $0x23
  800b7c:	68 21 13 80 00       	push   $0x801321
  800b81:	e8 8e 02 00 00       	call   800e14 <_panic>

00800b86 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 02 00 00 00       	mov    $0x2,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_yield>:

void
sys_yield(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	be 00 00 00 00       	mov    $0x0,%esi
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	89 f7                	mov    %esi,%edi
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7f 08                	jg     800bf0 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 04                	push   $0x4
  800bf6:	68 04 13 80 00       	push   $0x801304
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 21 13 80 00       	push   $0x801321
  800c02:	e8 0d 02 00 00       	call   800e14 <_panic>

00800c07 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 75 18             	mov    0x18(%ebp),%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7f 08                	jg     800c32 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 05                	push   $0x5
  800c38:	68 04 13 80 00       	push   $0x801304
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 21 13 80 00       	push   $0x801321
  800c44:	e8 cb 01 00 00       	call   800e14 <_panic>

00800c49 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7f 08                	jg     800c74 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 06                	push   $0x6
  800c7a:	68 04 13 80 00       	push   $0x801304
  800c7f:	6a 23                	push   $0x23
  800c81:	68 21 13 80 00       	push   $0x801321
  800c86:	e8 89 01 00 00       	call   800e14 <_panic>

00800c8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7f 08                	jg     800cb6 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 08                	push   $0x8
  800cbc:	68 04 13 80 00       	push   $0x801304
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 21 13 80 00       	push   $0x801321
  800cc8:	e8 47 01 00 00       	call   800e14 <_panic>

00800ccd <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7f 08                	jg     800cf8 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 09                	push   $0x9
  800cfe:	68 04 13 80 00       	push   $0x801304
  800d03:	6a 23                	push   $0x23
  800d05:	68 21 13 80 00       	push   $0x801321
  800d0a:	e8 05 01 00 00       	call   800e14 <_panic>

00800d0f <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d20:	be 00 00 00 00       	mov    $0x0,%esi
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d48:	89 cb                	mov    %ecx,%ebx
  800d4a:	89 cf                	mov    %ecx,%edi
  800d4c:	89 ce                	mov    %ecx,%esi
  800d4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 0c                	push   $0xc
  800d62:	68 04 13 80 00       	push   $0x801304
  800d67:	6a 23                	push   $0x23
  800d69:	68 21 13 80 00       	push   $0x801321
  800d6e:	e8 a1 00 00 00       	call   800e14 <_panic>
	...

00800d74 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d7a:	68 3b 13 80 00       	push   $0x80133b
  800d7f:	6a 51                	push   $0x51
  800d81:	68 2f 13 80 00       	push   $0x80132f
  800d86:	e8 89 00 00 00       	call   800e14 <_panic>

00800d8b <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d91:	68 3a 13 80 00       	push   $0x80133a
  800d96:	6a 58                	push   $0x58
  800d98:	68 2f 13 80 00       	push   $0x80132f
  800d9d:	e8 72 00 00 00       	call   800e14 <_panic>
	...

00800da4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800daa:	68 50 13 80 00       	push   $0x801350
  800daf:	6a 1a                	push   $0x1a
  800db1:	68 69 13 80 00       	push   $0x801369
  800db6:	e8 59 00 00 00       	call   800e14 <_panic>

00800dbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800dc1:	68 73 13 80 00       	push   $0x801373
  800dc6:	6a 2a                	push   $0x2a
  800dc8:	68 69 13 80 00       	push   $0x801369
  800dcd:	e8 42 00 00 00       	call   800e14 <_panic>

00800dd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	c1 e2 05             	shl    $0x5,%edx
  800de2:	29 c2                	sub    %eax,%edx
  800de4:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800deb:	8b 52 50             	mov    0x50(%edx),%edx
  800dee:	39 ca                	cmp    %ecx,%edx
  800df0:	74 0f                	je     800e01 <ipc_find_env+0x2f>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800df2:	40                   	inc    %eax
  800df3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df8:	75 e3                	jne    800ddd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	eb 11                	jmp    800e12 <ipc_find_env+0x40>
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	c1 e2 05             	shl    $0x5,%edx
  800e06:	29 c2                	sub    %eax,%edx
  800e08:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800e0f:	8b 40 48             	mov    0x48(%eax),%eax
	return 0;
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e19:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e1c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e22:	e8 5f fd ff ff       	call   800b86 <sys_getenvid>
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	ff 75 0c             	pushl  0xc(%ebp)
  800e2d:	ff 75 08             	pushl  0x8(%ebp)
  800e30:	56                   	push   %esi
  800e31:	50                   	push   %eax
  800e32:	68 8c 13 80 00       	push   $0x80138c
  800e37:	e8 bc f3 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e3c:	83 c4 18             	add    $0x18,%esp
  800e3f:	53                   	push   %ebx
  800e40:	ff 75 10             	pushl  0x10(%ebp)
  800e43:	e8 5f f3 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  800e48:	c7 04 24 78 10 80 00 	movl   $0x801078,(%esp)
  800e4f:	e8 a4 f3 ff ff       	call   8001f8 <cprintf>
  800e54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e57:	cc                   	int3   
  800e58:	eb fd                	jmp    800e57 <_panic+0x43>
	...

00800e5c <__udivdi3>:
  800e5c:	55                   	push   %ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 1c             	sub    $0x1c,%esp
  800e63:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e67:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e6b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e6f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e73:	85 d2                	test   %edx,%edx
  800e75:	75 2d                	jne    800ea4 <__udivdi3+0x48>
  800e77:	39 f7                	cmp    %esi,%edi
  800e79:	77 59                	ja     800ed4 <__udivdi3+0x78>
  800e7b:	89 f9                	mov    %edi,%ecx
  800e7d:	85 ff                	test   %edi,%edi
  800e7f:	75 0b                	jne    800e8c <__udivdi3+0x30>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  800e86:	31 d2                	xor    %edx,%edx
  800e88:	f7 f7                	div    %edi
  800e8a:	89 c1                	mov    %eax,%ecx
  800e8c:	31 d2                	xor    %edx,%edx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	f7 f1                	div    %ecx
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	89 e8                	mov    %ebp,%eax
  800e96:	f7 f1                	div    %ecx
  800e98:	89 da                	mov    %ebx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	66 90                	xchg   %ax,%ax
  800ea4:	39 f2                	cmp    %esi,%edx
  800ea6:	77 1c                	ja     800ec4 <__udivdi3+0x68>
  800ea8:	0f bd da             	bsr    %edx,%ebx
  800eab:	83 f3 1f             	xor    $0x1f,%ebx
  800eae:	75 38                	jne    800ee8 <__udivdi3+0x8c>
  800eb0:	39 f2                	cmp    %esi,%edx
  800eb2:	72 08                	jb     800ebc <__udivdi3+0x60>
  800eb4:	39 ef                	cmp    %ebp,%edi
  800eb6:	0f 87 98 00 00 00    	ja     800f54 <__udivdi3+0xf8>
  800ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec1:	eb 05                	jmp    800ec8 <__udivdi3+0x6c>
  800ec3:	90                   	nop
  800ec4:	31 db                	xor    %ebx,%ebx
  800ec6:	31 c0                	xor    %eax,%eax
  800ec8:	89 da                	mov    %ebx,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	66 90                	xchg   %ax,%ax
  800ed4:	89 e8                	mov    %ebp,%eax
  800ed6:	89 f2                	mov    %esi,%edx
  800ed8:	f7 f7                	div    %edi
  800eda:	31 db                	xor    %ebx,%ebx
  800edc:	89 da                	mov    %ebx,%edx
  800ede:	83 c4 1c             	add    $0x1c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	b8 20 00 00 00       	mov    $0x20,%eax
  800eed:	29 d8                	sub    %ebx,%eax
  800eef:	88 d9                	mov    %bl,%cl
  800ef1:	d3 e2                	shl    %cl,%edx
  800ef3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ef7:	89 fa                	mov    %edi,%edx
  800ef9:	88 c1                	mov    %al,%cl
  800efb:	d3 ea                	shr    %cl,%edx
  800efd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f01:	09 d1                	or     %edx,%ecx
  800f03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f07:	88 d9                	mov    %bl,%cl
  800f09:	d3 e7                	shl    %cl,%edi
  800f0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f0f:	89 f7                	mov    %esi,%edi
  800f11:	88 c1                	mov    %al,%cl
  800f13:	d3 ef                	shr    %cl,%edi
  800f15:	88 d9                	mov    %bl,%cl
  800f17:	d3 e6                	shl    %cl,%esi
  800f19:	89 ea                	mov    %ebp,%edx
  800f1b:	88 c1                	mov    %al,%cl
  800f1d:	d3 ea                	shr    %cl,%edx
  800f1f:	09 d6                	or     %edx,%esi
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	89 fa                	mov    %edi,%edx
  800f25:	f7 74 24 08          	divl   0x8(%esp)
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 c6                	mov    %eax,%esi
  800f2d:	f7 64 24 0c          	mull   0xc(%esp)
  800f31:	39 d7                	cmp    %edx,%edi
  800f33:	72 13                	jb     800f48 <__udivdi3+0xec>
  800f35:	74 09                	je     800f40 <__udivdi3+0xe4>
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	31 db                	xor    %ebx,%ebx
  800f3b:	eb 8b                	jmp    800ec8 <__udivdi3+0x6c>
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	88 d9                	mov    %bl,%cl
  800f42:	d3 e5                	shl    %cl,%ebp
  800f44:	39 c5                	cmp    %eax,%ebp
  800f46:	73 ef                	jae    800f37 <__udivdi3+0xdb>
  800f48:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f4b:	31 db                	xor    %ebx,%ebx
  800f4d:	e9 76 ff ff ff       	jmp    800ec8 <__udivdi3+0x6c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	31 c0                	xor    %eax,%eax
  800f56:	e9 6d ff ff ff       	jmp    800ec8 <__udivdi3+0x6c>
	...

00800f5c <__umoddi3>:
  800f5c:	55                   	push   %ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 1c             	sub    $0x1c,%esp
  800f63:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f67:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f6b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f6f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f73:	89 f0                	mov    %esi,%eax
  800f75:	89 da                	mov    %ebx,%edx
  800f77:	85 ed                	test   %ebp,%ebp
  800f79:	75 15                	jne    800f90 <__umoddi3+0x34>
  800f7b:	39 df                	cmp    %ebx,%edi
  800f7d:	76 39                	jbe    800fb8 <__umoddi3+0x5c>
  800f7f:	f7 f7                	div    %edi
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	39 dd                	cmp    %ebx,%ebp
  800f92:	77 f1                	ja     800f85 <__umoddi3+0x29>
  800f94:	0f bd cd             	bsr    %ebp,%ecx
  800f97:	83 f1 1f             	xor    $0x1f,%ecx
  800f9a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f9e:	75 38                	jne    800fd8 <__umoddi3+0x7c>
  800fa0:	39 dd                	cmp    %ebx,%ebp
  800fa2:	72 04                	jb     800fa8 <__umoddi3+0x4c>
  800fa4:	39 f7                	cmp    %esi,%edi
  800fa6:	77 dd                	ja     800f85 <__umoddi3+0x29>
  800fa8:	89 da                	mov    %ebx,%edx
  800faa:	89 f0                	mov    %esi,%eax
  800fac:	29 f8                	sub    %edi,%eax
  800fae:	19 ea                	sbb    %ebp,%edx
  800fb0:	83 c4 1c             	add    $0x1c,%esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5e                   	pop    %esi
  800fb5:	5f                   	pop    %edi
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    
  800fb8:	89 f9                	mov    %edi,%ecx
  800fba:	85 ff                	test   %edi,%edi
  800fbc:	75 0b                	jne    800fc9 <__umoddi3+0x6d>
  800fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	f7 f7                	div    %edi
  800fc7:	89 c1                	mov    %eax,%ecx
  800fc9:	89 d8                	mov    %ebx,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f1                	div    %ecx
  800fcf:	89 f0                	mov    %esi,%eax
  800fd1:	f7 f1                	div    %ecx
  800fd3:	eb ac                	jmp    800f81 <__umoddi3+0x25>
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fe3:	29 c2                	sub    %eax,%edx
  800fe5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe9:	88 c1                	mov    %al,%cl
  800feb:	d3 e5                	shl    %cl,%ebp
  800fed:	89 f8                	mov    %edi,%eax
  800fef:	88 d1                	mov    %dl,%cl
  800ff1:	d3 e8                	shr    %cl,%eax
  800ff3:	09 c5                	or     %eax,%ebp
  800ff5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ff9:	88 c1                	mov    %al,%cl
  800ffb:	d3 e7                	shl    %cl,%edi
  800ffd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801001:	89 df                	mov    %ebx,%edi
  801003:	88 d1                	mov    %dl,%cl
  801005:	d3 ef                	shr    %cl,%edi
  801007:	88 c1                	mov    %al,%cl
  801009:	d3 e3                	shl    %cl,%ebx
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	88 d1                	mov    %dl,%cl
  80100f:	d3 e8                	shr    %cl,%eax
  801011:	09 d8                	or     %ebx,%eax
  801013:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801017:	d3 e6                	shl    %cl,%esi
  801019:	89 fa                	mov    %edi,%edx
  80101b:	f7 f5                	div    %ebp
  80101d:	89 d1                	mov    %edx,%ecx
  80101f:	f7 64 24 08          	mull   0x8(%esp)
  801023:	89 c3                	mov    %eax,%ebx
  801025:	89 d7                	mov    %edx,%edi
  801027:	39 d1                	cmp    %edx,%ecx
  801029:	72 29                	jb     801054 <__umoddi3+0xf8>
  80102b:	74 23                	je     801050 <__umoddi3+0xf4>
  80102d:	89 ca                	mov    %ecx,%edx
  80102f:	29 de                	sub    %ebx,%esi
  801031:	19 fa                	sbb    %edi,%edx
  801033:	89 d0                	mov    %edx,%eax
  801035:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801039:	d3 e0                	shl    %cl,%eax
  80103b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80103f:	88 d9                	mov    %bl,%cl
  801041:	d3 ee                	shr    %cl,%esi
  801043:	09 f0                	or     %esi,%eax
  801045:	d3 ea                	shr    %cl,%edx
  801047:	83 c4 1c             	add    $0x1c,%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    
  80104f:	90                   	nop
  801050:	39 c6                	cmp    %eax,%esi
  801052:	73 d9                	jae    80102d <__umoddi3+0xd1>
  801054:	2b 44 24 08          	sub    0x8(%esp),%eax
  801058:	19 ea                	sbb    %ebp,%edx
  80105a:	89 d7                	mov    %edx,%edi
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	eb cd                	jmp    80102d <__umoddi3+0xd1>
