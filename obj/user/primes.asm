
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	83 ec 04             	sub    $0x4,%esp
  800043:	6a 00                	push   $0x0
  800045:	6a 00                	push   $0x0
  800047:	56                   	push   %esi
  800048:	e8 93 0d 00 00       	call   800de0 <ipc_recv>
  80004d:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004f:	a1 04 20 80 00       	mov    0x802004,%eax
  800054:	8b 40 5c             	mov    0x5c(%eax),%eax
  800057:	83 c4 0c             	add    $0xc,%esp
  80005a:	53                   	push   %ebx
  80005b:	50                   	push   %eax
  80005c:	68 60 10 80 00       	push   $0x801060
  800061:	e8 ce 01 00 00       	call   800234 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800066:	e8 45 0d 00 00       	call   800db0 <fork>
  80006b:	89 c7                	mov    %eax,%edi
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	85 c0                	test   %eax,%eax
  800072:	78 30                	js     8000a4 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	74 c8                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800078:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007b:	83 ec 04             	sub    $0x4,%esp
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	56                   	push   %esi
  800083:	e8 58 0d 00 00       	call   800de0 <ipc_recv>
  800088:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80008a:	99                   	cltd   
  80008b:	f7 fb                	idiv   %ebx
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 d2                	test   %edx,%edx
  800092:	74 e7                	je     80007b <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800094:	6a 00                	push   $0x0
  800096:	6a 00                	push   $0x0
  800098:	51                   	push   %ecx
  800099:	57                   	push   %edi
  80009a:	e8 58 0d 00 00       	call   800df7 <ipc_send>
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb d7                	jmp    80007b <primeproc+0x47>
	p = ipc_recv(&envid, 0, 0);
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
		panic("fork: %e", id);
  8000a4:	50                   	push   %eax
  8000a5:	68 6c 10 80 00       	push   $0x80106c
  8000aa:	6a 1a                	push   $0x1a
  8000ac:	68 75 10 80 00       	push   $0x801075
  8000b1:	e8 a2 00 00 00       	call   800158 <_panic>

008000b6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000bb:	e8 f0 0c 00 00       	call   800db0 <fork>
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	78 1a                	js     8000e0 <umain+0x2a>
		panic("fork: %e", id);
	if (id == 0)
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	74 28                	je     8000f2 <umain+0x3c>
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000ca:	bb 02 00 00 00       	mov    $0x2,%ebx
		ipc_send(id, i, 0, 0);
  8000cf:	6a 00                	push   $0x0
  8000d1:	6a 00                	push   $0x0
  8000d3:	53                   	push   %ebx
  8000d4:	56                   	push   %esi
  8000d5:	e8 1d 0d 00 00       	call   800df7 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000da:	43                   	inc    %ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb ef                	jmp    8000cf <umain+0x19>
{
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
		panic("fork: %e", id);
  8000e0:	50                   	push   %eax
  8000e1:	68 6c 10 80 00       	push   $0x80106c
  8000e6:	6a 2d                	push   $0x2d
  8000e8:	68 75 10 80 00       	push   $0x801075
  8000ed:	e8 66 00 00 00       	call   800158 <_panic>
	if (id == 0)
		primeproc();
  8000f2:	e8 3d ff ff ff       	call   800034 <primeproc>
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 ba 0a 00 00       	call   800bc2 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 05             	shl    $0x5,%edx
  800112:	29 c2                	sub    %eax,%edx
  800114:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80011b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x33>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 81 ff ff ff       	call   8000b6 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 30 0a 00 00       	call   800b81 <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    
	...

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800166:	e8 57 0a 00 00       	call   800bc2 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 90 10 80 00       	push   $0x801090
  80017b:	e8 b4 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 57 00 00 00       	call   8001e3 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 b4 10 80 00 	movl   $0x8010b4,(%esp)
  800193:	e8 9c 00 00 00       	call   800234 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 13                	mov    (%ebx),%edx
  8001ac:	8d 42 01             	lea    0x1(%edx),%eax
  8001af:	89 03                	mov    %eax,(%ebx)
  8001b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	74 08                	je     8001c7 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bf:	ff 43 04             	incl   0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	68 ff 00 00 00       	push   $0xff
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 6c 09 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	eb dc                	jmp    8001bf <putch+0x1f>

008001e3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 a0 01 80 00       	push   $0x8001a0
  800212:	e8 17 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 18 09 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023d:	50                   	push   %eax
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 9d ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 1c             	sub    $0x1c,%esp
  800251:	89 c7                	mov    %eax,%edi
  800253:	89 d6                	mov    %edx,%esi
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800261:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026f:	39 d3                	cmp    %edx,%ebx
  800271:	72 05                	jb     800278 <printnum+0x30>
  800273:	39 45 10             	cmp    %eax,0x10(%ebp)
  800276:	77 78                	ja     8002f0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	8b 45 14             	mov    0x14(%ebp),%eax
  800281:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800284:	53                   	push   %ebx
  800285:	ff 75 10             	pushl  0x10(%ebp)
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 b4 0b 00 00       	call   800e50 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 f2                	mov    %esi,%edx
  8002a3:	89 f8                	mov    %edi,%eax
  8002a5:	e8 9e ff ff ff       	call   800248 <printnum>
  8002aa:	83 c4 20             	add    $0x20,%esp
  8002ad:	eb 11                	jmp    8002c0 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	ff d7                	call   *%edi
  8002b8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bb:	4b                   	dec    %ebx
  8002bc:	85 db                	test   %ebx,%ebx
  8002be:	7f ef                	jg     8002af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	56                   	push   %esi
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d3:	e8 78 0c 00 00       	call   800f50 <__umoddi3>
  8002d8:	83 c4 14             	add    $0x14,%esp
  8002db:	0f be 80 b6 10 80 00 	movsbl 0x8010b6(%eax),%eax
  8002e2:	50                   	push   %eax
  8002e3:	ff d7                	call   *%edi
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    
  8002f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f3:	eb c6                	jmp    8002bb <printnum+0x73>

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1a>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	e9 ac 03 00 00       	jmp    8006f1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800345:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800349:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800350:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800357:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8d 47 01             	lea    0x1(%edi),%eax
  800366:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800369:	8a 17                	mov    (%edi),%dl
  80036b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036e:	3c 55                	cmp    $0x55,%al
  800370:	0f 87 fc 03 00 00    	ja     800772 <vprintfmt+0x444>
  800376:	0f b6 c0             	movzbl %al,%eax
  800379:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800387:	eb da                	jmp    800363 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800390:	eb d1                	jmp    800363 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 d2             	movzbl %dl,%edx
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	01 c0                	add    %eax,%eax
  8003a5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8003a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003af:	83 f9 09             	cmp    $0x9,%ecx
  8003b2:	77 52                	ja     800406 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 40 04             	lea    0x4(%eax),%eax
  8003c5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cf:	79 92                	jns    800363 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	eb 83                	jmp    800363 <vprintfmt+0x35>
  8003e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e4:	78 08                	js     8003ee <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e9:	e9 75 ff ff ff       	jmp    800363 <vprintfmt+0x35>
  8003ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f5:	eb ef                	jmp    8003e6 <vprintfmt+0xb8>
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800401:	e9 5d ff ff ff       	jmp    800363 <vprintfmt+0x35>
  800406:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800409:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80040c:	eb bd                	jmp    8003cb <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800412:	e9 4c ff ff ff       	jmp    800363 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 78 04             	lea    0x4(%eax),%edi
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	53                   	push   %ebx
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d6                	call   *%esi
			break;
  800425:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80042b:	e9 be 02 00 00       	jmp    8006ee <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 78 04             	lea    0x4(%eax),%edi
  800436:	8b 00                	mov    (%eax),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	78 2a                	js     800466 <vprintfmt+0x138>
  80043c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	83 f8 08             	cmp    $0x8,%eax
  800441:	7f 27                	jg     80046a <vprintfmt+0x13c>
  800443:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  80044a:	85 c0                	test   %eax,%eax
  80044c:	74 1c                	je     80046a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	50                   	push   %eax
  80044f:	68 d7 10 80 00       	push   $0x8010d7
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 b6 fe ff ff       	call   800311 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800461:	e9 88 02 00 00       	jmp    8006ee <vprintfmt+0x3c0>
  800466:	f7 d8                	neg    %eax
  800468:	eb d2                	jmp    80043c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046a:	52                   	push   %edx
  80046b:	68 ce 10 80 00       	push   $0x8010ce
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 9a fe ff ff       	call   800311 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 6c 02 00 00       	jmp    8006ee <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	83 c0 04             	add    $0x4,%eax
  800488:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8b 38                	mov    (%eax),%edi
  800490:	85 ff                	test   %edi,%edi
  800492:	74 18                	je     8004ac <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800494:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800498:	0f 8e b7 00 00 00    	jle    800555 <vprintfmt+0x227>
  80049e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a2:	75 0f                	jne    8004b3 <vprintfmt+0x185>
  8004a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004aa:	eb 75                	jmp    800521 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8004ac:	bf c7 10 80 00       	mov    $0x8010c7,%edi
  8004b1:	eb e1                	jmp    800494 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b9:	57                   	push   %edi
  8004ba:	e8 5f 03 00 00       	call   80081e <strnlen>
  8004bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	eb 0d                	jmp    8004e5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	4f                   	dec    %edi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	7f ef                	jg     8004d8 <vprintfmt+0x1aa>
  8004e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ef:	89 c8                	mov    %ecx,%eax
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	78 10                	js     800505 <vprintfmt+0x1d7>
  8004f5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f8:	29 c1                	sub    %eax,%ecx
  8004fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800503:	eb 1c                	jmp    800521 <vprintfmt+0x1f3>
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	eb e9                	jmp    8004f5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800510:	75 29                	jne    80053b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	50                   	push   %eax
  800519:	ff d6                	call   *%esi
  80051b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051e:	ff 4d e0             	decl   -0x20(%ebp)
  800521:	47                   	inc    %edi
  800522:	8a 57 ff             	mov    -0x1(%edi),%dl
  800525:	0f be c2             	movsbl %dl,%eax
  800528:	85 c0                	test   %eax,%eax
  80052a:	74 4c                	je     800578 <vprintfmt+0x24a>
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	78 dc                	js     80050c <vprintfmt+0x1de>
  800530:	4b                   	dec    %ebx
  800531:	79 d9                	jns    80050c <vprintfmt+0x1de>
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800539:	eb 2e                	jmp    800569 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80053b:	0f be d2             	movsbl %dl,%edx
  80053e:	83 ea 20             	sub    $0x20,%edx
  800541:	83 fa 5e             	cmp    $0x5e,%edx
  800544:	76 cc                	jbe    800512 <vprintfmt+0x1e4>
					putch('?', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff d6                	call   *%esi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb c9                	jmp    80051e <vprintfmt+0x1f0>
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80055b:	eb c4                	jmp    800521 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	6a 20                	push   $0x20
  800563:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800565:	4f                   	dec    %edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	85 ff                	test   %edi,%edi
  80056b:	7f f0                	jg     80055d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800570:	89 45 14             	mov    %eax,0x14(%ebp)
  800573:	e9 76 01 00 00       	jmp    8006ee <vprintfmt+0x3c0>
  800578:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	eb e9                	jmp    800569 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 3f                	jle    8005c4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 50 04             	mov    0x4(%eax),%edx
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	79 5c                	jns    8005fe <vprintfmt+0x2d0>
				putch('-', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	6a 2d                	push   $0x2d
  8005a8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b0:	f7 da                	neg    %edx
  8005b2:	83 d1 00             	adc    $0x0,%ecx
  8005b5:	f7 d9                	neg    %ecx
  8005b7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bf:	e9 10 01 00 00       	jmp    8006d4 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	75 1b                	jne    8005e3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 c1                	mov    %eax,%ecx
  8005d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e1:	eb b9                	jmp    80059c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fc:	eb 9e                	jmp    80059c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800601:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 c6 00 00 00       	jmp    8006d4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 18                	jle    80062b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 a9 00 00 00       	jmp    8006d4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	75 1a                	jne    800649 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 8b 00 00 00       	jmp    8006d4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	eb 74                	jmp    8006d4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800660:	83 f9 01             	cmp    $0x1,%ecx
  800663:	7e 15                	jle    80067a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8b 48 04             	mov    0x4(%eax),%ecx
  80066d:	8d 40 08             	lea    0x8(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
  800678:	eb 5a                	jmp    8006d4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	75 17                	jne    800695 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 3f                	jmp    8006d4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8006a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006aa:	eb 28                	jmp    8006d4 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 30                	push   $0x30
  8006b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 78                	push   $0x78
  8006ba:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d4:	83 ec 0c             	sub    $0xc,%esp
  8006d7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006db:	57                   	push   %edi
  8006dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006df:	50                   	push   %eax
  8006e0:	51                   	push   %ecx
  8006e1:	52                   	push   %edx
  8006e2:	89 da                	mov    %ebx,%edx
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	e8 5d fb ff ff       	call   800248 <printnum>
			break;
  8006eb:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f1:	47                   	inc    %edi
  8006f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f6:	83 f8 25             	cmp    $0x25,%eax
  8006f9:	0f 84 46 fc ff ff    	je     800345 <vprintfmt+0x17>
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 89 00 00 00    	je     800790 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	50                   	push   %eax
  80070c:	ff d6                	call   *%esi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb de                	jmp    8006f1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7e 15                	jle    80072d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	8b 48 04             	mov    0x4(%eax),%ecx
  800720:	8d 40 08             	lea    0x8(%eax),%eax
  800723:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800726:	b8 10 00 00 00       	mov    $0x10,%eax
  80072b:	eb a7                	jmp    8006d4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072d:	85 c9                	test   %ecx,%ecx
  80072f:	75 17                	jne    800748 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
  800746:	eb 8c                	jmp    8006d4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800758:	b8 10 00 00 00       	mov    $0x10,%eax
  80075d:	e9 72 ff ff ff       	jmp    8006d4 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 25                	push   $0x25
  800768:	ff d6                	call   *%esi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	e9 7c ff ff ff       	jmp    8006ee <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	89 f8                	mov    %edi,%eax
  80077f:	eb 01                	jmp    800782 <vprintfmt+0x454>
  800781:	48                   	dec    %eax
  800782:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800786:	75 f9                	jne    800781 <vprintfmt+0x453>
  800788:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078b:	e9 5e ff ff ff       	jmp    8006ee <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 18             	sub    $0x18,%esp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	74 26                	je     8007df <vsnprintf+0x47>
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	7e 29                	jle    8007e6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bd:	ff 75 14             	pushl  0x14(%ebp)
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c6:	50                   	push   %eax
  8007c7:	68 f5 02 80 00       	push   $0x8002f5
  8007cc:	e8 5d fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007da:	83 c4 10             	add    $0x10,%esp
}
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e4:	eb f7                	jmp    8007dd <vsnprintf+0x45>
  8007e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007eb:	eb f0                	jmp    8007dd <vsnprintf+0x45>

008007ed <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f6:	50                   	push   %eax
  8007f7:	ff 75 10             	pushl  0x10(%ebp)
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	ff 75 08             	pushl  0x8(%ebp)
  800800:	e8 93 ff ff ff       	call   800798 <vsnprintf>
	va_end(ap);

	return rc;
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    
	...

00800808 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 01                	jmp    800816 <strlen+0xe>
		n++;
  800815:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081a:	75 f9                	jne    800815 <strlen+0xd>
		n++;
	return n;
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 01                	jmp    80082f <strnlen+0x11>
		n++;
  80082e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082f:	39 d0                	cmp    %edx,%eax
  800831:	74 06                	je     800839 <strnlen+0x1b>
  800833:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800837:	75 f5                	jne    80082e <strnlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800845:	89 c2                	mov    %eax,%edx
  800847:	41                   	inc    %ecx
  800848:	42                   	inc    %edx
  800849:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 f4                	jne    800847 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 a5 ff ff ff       	call   800808 <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 ca ff ff ff       	call   80083b <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	39 da                	cmp    %ebx,%edx
  80088c:	74 0e                	je     80089c <strncpy+0x24>
		*dst++ = *src;
  80088e:	42                   	inc    %edx
  80088f:	8a 01                	mov    (%ecx),%al
  800891:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800894:	80 39 00             	cmpb   $0x0,(%ecx)
  800897:	74 f1                	je     80088a <strncpy+0x12>
			src++;
  800899:	41                   	inc    %ecx
  80089a:	eb ee                	jmp    80088a <strncpy+0x12>
	}
	return ret;
}
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	74 20                	je     8008d4 <strlcpy+0x32>
  8008b4:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	eb 05                	jmp    8008c1 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bc:	42                   	inc    %edx
  8008bd:	40                   	inc    %eax
  8008be:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c1:	39 d8                	cmp    %ebx,%eax
  8008c3:	74 06                	je     8008cb <strlcpy+0x29>
  8008c5:	8a 0a                	mov    (%edx),%cl
  8008c7:	84 c9                	test   %cl,%cl
  8008c9:	75 f1                	jne    8008bc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ce:	29 f0                	sub    %esi,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    
  8008d4:	89 f0                	mov    %esi,%eax
  8008d6:	eb f6                	jmp    8008ce <strlcpy+0x2c>

008008d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e1:	eb 02                	jmp    8008e5 <strcmp+0xd>
		p++, q++;
  8008e3:	41                   	inc    %ecx
  8008e4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e5:	8a 01                	mov    (%ecx),%al
  8008e7:	84 c0                	test   %al,%al
  8008e9:	74 04                	je     8008ef <strcmp+0x17>
  8008eb:	3a 02                	cmp    (%edx),%al
  8008ed:	74 f4                	je     8008e3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ef:	0f b6 c0             	movzbl %al,%eax
  8008f2:	0f b6 12             	movzbl (%edx),%edx
  8008f5:	29 d0                	sub    %edx,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
  800903:	89 c3                	mov    %eax,%ebx
  800905:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800908:	eb 02                	jmp    80090c <strncmp+0x13>
		n--, p++, q++;
  80090a:	40                   	inc    %eax
  80090b:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090c:	39 d8                	cmp    %ebx,%eax
  80090e:	74 15                	je     800925 <strncmp+0x2c>
  800910:	8a 08                	mov    (%eax),%cl
  800912:	84 c9                	test   %cl,%cl
  800914:	74 04                	je     80091a <strncmp+0x21>
  800916:	3a 0a                	cmp    (%edx),%cl
  800918:	74 f0                	je     80090a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091a:	0f b6 00             	movzbl (%eax),%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
}
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	eb f6                	jmp    800922 <strncmp+0x29>

0080092c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800935:	8a 10                	mov    (%eax),%dl
  800937:	84 d2                	test   %dl,%dl
  800939:	74 07                	je     800942 <strchr+0x16>
		if (*s == c)
  80093b:	38 ca                	cmp    %cl,%dl
  80093d:	74 08                	je     800947 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093f:	40                   	inc    %eax
  800940:	eb f3                	jmp    800935 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800952:	8a 10                	mov    (%eax),%dl
  800954:	84 d2                	test   %dl,%dl
  800956:	74 07                	je     80095f <strfind+0x16>
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 03                	je     80095f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095c:	40                   	inc    %eax
  80095d:	eb f3                	jmp    800952 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096d:	85 c9                	test   %ecx,%ecx
  80096f:	74 13                	je     800984 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800971:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800977:	75 05                	jne    80097e <memset+0x1d>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	74 0d                	je     80098b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	fc                   	cld    
  800982:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800984:	89 f8                	mov    %edi,%eax
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80098b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098f:	89 d3                	mov    %edx,%ebx
  800991:	c1 e3 08             	shl    $0x8,%ebx
  800994:	89 d0                	mov    %edx,%eax
  800996:	c1 e0 18             	shl    $0x18,%eax
  800999:	89 d6                	mov    %edx,%esi
  80099b:	c1 e6 10             	shl    $0x10,%esi
  80099e:	09 f0                	or     %esi,%eax
  8009a0:	09 c2                	or     %eax,%edx
  8009a2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a7:	89 d0                	mov    %edx,%eax
  8009a9:	fc                   	cld    
  8009aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ac:	eb d6                	jmp    800984 <memset+0x23>

008009ae <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bc:	39 c6                	cmp    %eax,%esi
  8009be:	73 33                	jae    8009f3 <memmove+0x45>
  8009c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c3:	39 c2                	cmp    %eax,%edx
  8009c5:	76 2c                	jbe    8009f3 <memmove+0x45>
		s += n;
		d += n;
  8009c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 d6                	mov    %edx,%esi
  8009cc:	09 fe                	or     %edi,%esi
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	74 0a                	je     8009e0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d6:	4f                   	dec    %edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 21                	jmp    800a01 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	f6 c1 03             	test   $0x3,%cl
  8009e3:	75 f1                	jne    8009d6 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e5:	83 ef 04             	sub    $0x4,%edi
  8009e8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ee:	fd                   	std    
  8009ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f1:	eb ea                	jmp    8009dd <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	89 f2                	mov    %esi,%edx
  8009f5:	09 c2                	or     %eax,%edx
  8009f7:	f6 c2 03             	test   $0x3,%dl
  8009fa:	74 09                	je     800a05 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 f2                	jne    8009fc <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0d:	89 c7                	mov    %eax,%edi
  800a0f:	fc                   	cld    
  800a10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a12:	eb ed                	jmp    800a01 <memmove+0x53>

00800a14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a17:	ff 75 10             	pushl  0x10(%ebp)
  800a1a:	ff 75 0c             	pushl  0xc(%ebp)
  800a1d:	ff 75 08             	pushl  0x8(%ebp)
  800a20:	e8 89 ff ff ff       	call   8009ae <memmove>
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	39 f0                	cmp    %esi,%eax
  800a39:	74 16                	je     800a51 <memcmp+0x2a>
		if (*s1 != *s2)
  800a3b:	8a 08                	mov    (%eax),%cl
  800a3d:	8a 1a                	mov    (%edx),%bl
  800a3f:	38 d9                	cmp    %bl,%cl
  800a41:	75 04                	jne    800a47 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a43:	40                   	inc    %eax
  800a44:	42                   	inc    %edx
  800a45:	eb f0                	jmp    800a37 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a47:	0f b6 c1             	movzbl %cl,%eax
  800a4a:	0f b6 db             	movzbl %bl,%ebx
  800a4d:	29 d8                	sub    %ebx,%eax
  800a4f:	eb 05                	jmp    800a56 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a63:	89 c2                	mov    %eax,%edx
  800a65:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	73 07                	jae    800a73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6c:	38 08                	cmp    %cl,(%eax)
  800a6e:	74 03                	je     800a73 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	40                   	inc    %eax
  800a71:	eb f5                	jmp    800a68 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	eb 01                	jmp    800a81 <strtol+0xc>
		s++;
  800a80:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	8a 01                	mov    (%ecx),%al
  800a83:	3c 20                	cmp    $0x20,%al
  800a85:	74 f9                	je     800a80 <strtol+0xb>
  800a87:	3c 09                	cmp    $0x9,%al
  800a89:	74 f5                	je     800a80 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8b:	3c 2b                	cmp    $0x2b,%al
  800a8d:	74 2b                	je     800aba <strtol+0x45>
		s++;
	else if (*s == '-')
  800a8f:	3c 2d                	cmp    $0x2d,%al
  800a91:	74 2f                	je     800ac2 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a98:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a9f:	75 12                	jne    800ab3 <strtol+0x3e>
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	74 24                	je     800aca <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aaa:	75 07                	jne    800ab3 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aac:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	eb 4e                	jmp    800b08 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800aba:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac0:	eb d6                	jmp    800a98 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800ac2:	41                   	inc    %ecx
  800ac3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac8:	eb ce                	jmp    800a98 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ace:	74 10                	je     800ae0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad4:	75 dd                	jne    800ab3 <strtol+0x3e>
		s++, base = 8;
  800ad6:	41                   	inc    %ecx
  800ad7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ade:	eb d3                	jmp    800ab3 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ae0:	83 c1 02             	add    $0x2,%ecx
  800ae3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aea:	eb c7                	jmp    800ab3 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aef:	89 f3                	mov    %esi,%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 24                	ja     800b1a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800af6:	0f be d2             	movsbl %dl,%edx
  800af9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afc:	39 55 10             	cmp    %edx,0x10(%ebp)
  800aff:	7e 2b                	jle    800b2c <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800b01:	41                   	inc    %ecx
  800b02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b06:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b08:	8a 11                	mov    (%ecx),%dl
  800b0a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b0d:	80 fb 09             	cmp    $0x9,%bl
  800b10:	77 da                	ja     800aec <strtol+0x77>
			dig = *s - '0';
  800b12:	0f be d2             	movsbl %dl,%edx
  800b15:	83 ea 30             	sub    $0x30,%edx
  800b18:	eb e2                	jmp    800afc <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1d:	89 f3                	mov    %esi,%ebx
  800b1f:	80 fb 19             	cmp    $0x19,%bl
  800b22:	77 08                	ja     800b2c <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b24:	0f be d2             	movsbl %dl,%edx
  800b27:	83 ea 37             	sub    $0x37,%edx
  800b2a:	eb d0                	jmp    800afc <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b30:	74 05                	je     800b37 <strtol+0xc2>
		*endptr = (char *) s;
  800b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b35:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b37:	85 ff                	test   %edi,%edi
  800b39:	74 02                	je     800b3d <strtol+0xc8>
  800b3b:	f7 d8                	neg    %eax
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    
	...

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	b8 03 00 00 00       	mov    $0x3,%eax
  800b97:	89 cb                	mov    %ecx,%ebx
  800b99:	89 cf                	mov    %ecx,%edi
  800b9b:	89 ce                	mov    %ecx,%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7f 08                	jg     800bab <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	50                   	push   %eax
  800baf:	6a 03                	push   $0x3
  800bb1:	68 04 13 80 00       	push   $0x801304
  800bb6:	6a 23                	push   $0x23
  800bb8:	68 21 13 80 00       	push   $0x801321
  800bbd:	e8 96 f5 ff ff       	call   800158 <_panic>

00800bc2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_yield>:

void
sys_yield(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	be 00 00 00 00       	mov    $0x0,%esi
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	b8 04 00 00 00       	mov    $0x4,%eax
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	89 f7                	mov    %esi,%edi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 04                	push   $0x4
  800c32:	68 04 13 80 00       	push   $0x801304
  800c37:	6a 23                	push   $0x23
  800c39:	68 21 13 80 00       	push   $0x801321
  800c3e:	e8 15 f5 ff ff       	call   800158 <_panic>

00800c43 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 05                	push   $0x5
  800c74:	68 04 13 80 00       	push   $0x801304
  800c79:	6a 23                	push   $0x23
  800c7b:	68 21 13 80 00       	push   $0x801321
  800c80:	e8 d3 f4 ff ff       	call   800158 <_panic>

00800c85 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 06                	push   $0x6
  800cb6:	68 04 13 80 00       	push   $0x801304
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 21 13 80 00       	push   $0x801321
  800cc2:	e8 91 f4 ff ff       	call   800158 <_panic>

00800cc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 08                	push   $0x8
  800cf8:	68 04 13 80 00       	push   $0x801304
  800cfd:	6a 23                	push   $0x23
  800cff:	68 21 13 80 00       	push   $0x801321
  800d04:	e8 4f f4 ff ff       	call   800158 <_panic>

00800d09 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7f 08                	jg     800d34 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 09                	push   $0x9
  800d3a:	68 04 13 80 00       	push   $0x801304
  800d3f:	6a 23                	push   $0x23
  800d41:	68 21 13 80 00       	push   $0x801321
  800d46:	e8 0d f4 ff ff       	call   800158 <_panic>

00800d4b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7f 08                	jg     800d98 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	50                   	push   %eax
  800d9c:	6a 0c                	push   $0xc
  800d9e:	68 04 13 80 00       	push   $0x801304
  800da3:	6a 23                	push   $0x23
  800da5:	68 21 13 80 00       	push   $0x801321
  800daa:	e8 a9 f3 ff ff       	call   800158 <_panic>
	...

00800db0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800db6:	68 3b 13 80 00       	push   $0x80133b
  800dbb:	6a 51                	push   $0x51
  800dbd:	68 2f 13 80 00       	push   $0x80132f
  800dc2:	e8 91 f3 ff ff       	call   800158 <_panic>

00800dc7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dcd:	68 3a 13 80 00       	push   $0x80133a
  800dd2:	6a 58                	push   $0x58
  800dd4:	68 2f 13 80 00       	push   $0x80132f
  800dd9:	e8 7a f3 ff ff       	call   800158 <_panic>
	...

00800de0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800de6:	68 50 13 80 00       	push   $0x801350
  800deb:	6a 1a                	push   $0x1a
  800ded:	68 69 13 80 00       	push   $0x801369
  800df2:	e8 61 f3 ff ff       	call   800158 <_panic>

00800df7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800dfd:	68 73 13 80 00       	push   $0x801373
  800e02:	6a 2a                	push   $0x2a
  800e04:	68 69 13 80 00       	push   $0x801369
  800e09:	e8 4a f3 ff ff       	call   800158 <_panic>

00800e0e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 e2 05             	shl    $0x5,%edx
  800e1e:	29 c2                	sub    %eax,%edx
  800e20:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800e27:	8b 52 50             	mov    0x50(%edx),%edx
  800e2a:	39 ca                	cmp    %ecx,%edx
  800e2c:	74 0f                	je     800e3d <ipc_find_env+0x2f>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e2e:	40                   	inc    %eax
  800e2f:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e34:	75 e3                	jne    800e19 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	eb 11                	jmp    800e4e <ipc_find_env+0x40>
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 e2 05             	shl    $0x5,%edx
  800e42:	29 c2                	sub    %eax,%edx
  800e44:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800e4b:	8b 40 48             	mov    0x48(%eax),%eax
	return 0;
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e5b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e63:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e67:	85 d2                	test   %edx,%edx
  800e69:	75 2d                	jne    800e98 <__udivdi3+0x48>
  800e6b:	39 f7                	cmp    %esi,%edi
  800e6d:	77 59                	ja     800ec8 <__udivdi3+0x78>
  800e6f:	89 f9                	mov    %edi,%ecx
  800e71:	85 ff                	test   %edi,%edi
  800e73:	75 0b                	jne    800e80 <__udivdi3+0x30>
  800e75:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7a:	31 d2                	xor    %edx,%edx
  800e7c:	f7 f7                	div    %edi
  800e7e:	89 c1                	mov    %eax,%ecx
  800e80:	31 d2                	xor    %edx,%edx
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	f7 f1                	div    %ecx
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	89 e8                	mov    %ebp,%eax
  800e8a:	f7 f1                	div    %ecx
  800e8c:	89 da                	mov    %ebx,%edx
  800e8e:	83 c4 1c             	add    $0x1c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	77 1c                	ja     800eb8 <__udivdi3+0x68>
  800e9c:	0f bd da             	bsr    %edx,%ebx
  800e9f:	83 f3 1f             	xor    $0x1f,%ebx
  800ea2:	75 38                	jne    800edc <__udivdi3+0x8c>
  800ea4:	39 f2                	cmp    %esi,%edx
  800ea6:	72 08                	jb     800eb0 <__udivdi3+0x60>
  800ea8:	39 ef                	cmp    %ebp,%edi
  800eaa:	0f 87 98 00 00 00    	ja     800f48 <__udivdi3+0xf8>
  800eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb5:	eb 05                	jmp    800ebc <__udivdi3+0x6c>
  800eb7:	90                   	nop
  800eb8:	31 db                	xor    %ebx,%ebx
  800eba:	31 c0                	xor    %eax,%eax
  800ebc:	89 da                	mov    %ebx,%edx
  800ebe:	83 c4 1c             	add    $0x1c,%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	89 e8                	mov    %ebp,%eax
  800eca:	89 f2                	mov    %esi,%edx
  800ecc:	f7 f7                	div    %edi
  800ece:	31 db                	xor    %ebx,%ebx
  800ed0:	89 da                	mov    %ebx,%edx
  800ed2:	83 c4 1c             	add    $0x1c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	29 d8                	sub    %ebx,%eax
  800ee3:	88 d9                	mov    %bl,%cl
  800ee5:	d3 e2                	shl    %cl,%edx
  800ee7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eeb:	89 fa                	mov    %edi,%edx
  800eed:	88 c1                	mov    %al,%cl
  800eef:	d3 ea                	shr    %cl,%edx
  800ef1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ef5:	09 d1                	or     %edx,%ecx
  800ef7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800efb:	88 d9                	mov    %bl,%cl
  800efd:	d3 e7                	shl    %cl,%edi
  800eff:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f03:	89 f7                	mov    %esi,%edi
  800f05:	88 c1                	mov    %al,%cl
  800f07:	d3 ef                	shr    %cl,%edi
  800f09:	88 d9                	mov    %bl,%cl
  800f0b:	d3 e6                	shl    %cl,%esi
  800f0d:	89 ea                	mov    %ebp,%edx
  800f0f:	88 c1                	mov    %al,%cl
  800f11:	d3 ea                	shr    %cl,%edx
  800f13:	09 d6                	or     %edx,%esi
  800f15:	89 f0                	mov    %esi,%eax
  800f17:	89 fa                	mov    %edi,%edx
  800f19:	f7 74 24 08          	divl   0x8(%esp)
  800f1d:	89 d7                	mov    %edx,%edi
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	f7 64 24 0c          	mull   0xc(%esp)
  800f25:	39 d7                	cmp    %edx,%edi
  800f27:	72 13                	jb     800f3c <__udivdi3+0xec>
  800f29:	74 09                	je     800f34 <__udivdi3+0xe4>
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	31 db                	xor    %ebx,%ebx
  800f2f:	eb 8b                	jmp    800ebc <__udivdi3+0x6c>
  800f31:	8d 76 00             	lea    0x0(%esi),%esi
  800f34:	88 d9                	mov    %bl,%cl
  800f36:	d3 e5                	shl    %cl,%ebp
  800f38:	39 c5                	cmp    %eax,%ebp
  800f3a:	73 ef                	jae    800f2b <__udivdi3+0xdb>
  800f3c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f3f:	31 db                	xor    %ebx,%ebx
  800f41:	e9 76 ff ff ff       	jmp    800ebc <__udivdi3+0x6c>
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	31 c0                	xor    %eax,%eax
  800f4a:	e9 6d ff ff ff       	jmp    800ebc <__udivdi3+0x6c>
	...

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
  800f57:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f5b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f63:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	89 da                	mov    %ebx,%edx
  800f6b:	85 ed                	test   %ebp,%ebp
  800f6d:	75 15                	jne    800f84 <__umoddi3+0x34>
  800f6f:	39 df                	cmp    %ebx,%edi
  800f71:	76 39                	jbe    800fac <__umoddi3+0x5c>
  800f73:	f7 f7                	div    %edi
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	31 d2                	xor    %edx,%edx
  800f79:	83 c4 1c             	add    $0x1c,%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    
  800f81:	8d 76 00             	lea    0x0(%esi),%esi
  800f84:	39 dd                	cmp    %ebx,%ebp
  800f86:	77 f1                	ja     800f79 <__umoddi3+0x29>
  800f88:	0f bd cd             	bsr    %ebp,%ecx
  800f8b:	83 f1 1f             	xor    $0x1f,%ecx
  800f8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f92:	75 38                	jne    800fcc <__umoddi3+0x7c>
  800f94:	39 dd                	cmp    %ebx,%ebp
  800f96:	72 04                	jb     800f9c <__umoddi3+0x4c>
  800f98:	39 f7                	cmp    %esi,%edi
  800f9a:	77 dd                	ja     800f79 <__umoddi3+0x29>
  800f9c:	89 da                	mov    %ebx,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	29 f8                	sub    %edi,%eax
  800fa2:	19 ea                	sbb    %ebp,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	89 f9                	mov    %edi,%ecx
  800fae:	85 ff                	test   %edi,%edi
  800fb0:	75 0b                	jne    800fbd <__umoddi3+0x6d>
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	31 d2                	xor    %edx,%edx
  800fb9:	f7 f7                	div    %edi
  800fbb:	89 c1                	mov    %eax,%ecx
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	31 d2                	xor    %edx,%edx
  800fc1:	f7 f1                	div    %ecx
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	f7 f1                	div    %ecx
  800fc7:	eb ac                	jmp    800f75 <__umoddi3+0x25>
  800fc9:	8d 76 00             	lea    0x0(%esi),%esi
  800fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fd7:	29 c2                	sub    %eax,%edx
  800fd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdd:	88 c1                	mov    %al,%cl
  800fdf:	d3 e5                	shl    %cl,%ebp
  800fe1:	89 f8                	mov    %edi,%eax
  800fe3:	88 d1                	mov    %dl,%cl
  800fe5:	d3 e8                	shr    %cl,%eax
  800fe7:	09 c5                	or     %eax,%ebp
  800fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fed:	88 c1                	mov    %al,%cl
  800fef:	d3 e7                	shl    %cl,%edi
  800ff1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff5:	89 df                	mov    %ebx,%edi
  800ff7:	88 d1                	mov    %dl,%cl
  800ff9:	d3 ef                	shr    %cl,%edi
  800ffb:	88 c1                	mov    %al,%cl
  800ffd:	d3 e3                	shl    %cl,%ebx
  800fff:	89 f0                	mov    %esi,%eax
  801001:	88 d1                	mov    %dl,%cl
  801003:	d3 e8                	shr    %cl,%eax
  801005:	09 d8                	or     %ebx,%eax
  801007:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80100b:	d3 e6                	shl    %cl,%esi
  80100d:	89 fa                	mov    %edi,%edx
  80100f:	f7 f5                	div    %ebp
  801011:	89 d1                	mov    %edx,%ecx
  801013:	f7 64 24 08          	mull   0x8(%esp)
  801017:	89 c3                	mov    %eax,%ebx
  801019:	89 d7                	mov    %edx,%edi
  80101b:	39 d1                	cmp    %edx,%ecx
  80101d:	72 29                	jb     801048 <__umoddi3+0xf8>
  80101f:	74 23                	je     801044 <__umoddi3+0xf4>
  801021:	89 ca                	mov    %ecx,%edx
  801023:	29 de                	sub    %ebx,%esi
  801025:	19 fa                	sbb    %edi,%edx
  801027:	89 d0                	mov    %edx,%eax
  801029:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80102d:	d3 e0                	shl    %cl,%eax
  80102f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801033:	88 d9                	mov    %bl,%cl
  801035:	d3 ee                	shr    %cl,%esi
  801037:	09 f0                	or     %esi,%eax
  801039:	d3 ea                	shr    %cl,%edx
  80103b:	83 c4 1c             	add    $0x1c,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	39 c6                	cmp    %eax,%esi
  801046:	73 d9                	jae    801021 <__umoddi3+0xd1>
  801048:	2b 44 24 08          	sub    0x8(%esp),%eax
  80104c:	19 ea                	sbb    %ebp,%edx
  80104e:	89 d7                	mov    %edx,%edi
  801050:	89 c3                	mov    %eax,%ebx
  801052:	eb cd                	jmp    801021 <__umoddi3+0xd1>
