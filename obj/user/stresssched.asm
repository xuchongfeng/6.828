
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800039:	e8 74 0b 00 00       	call   800bb2 <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800045:	e8 56 0d 00 00       	call   800da0 <fork>
  80004a:	85 c0                	test   %eax,%eax
  80004c:	74 0d                	je     80005b <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004e:	43                   	inc    %ebx
  80004f:	83 fb 14             	cmp    $0x14,%ebx
  800052:	75 f1                	jne    800045 <umain+0x11>
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800054:	e8 78 0b 00 00       	call   800bd1 <sys_yield>
		return;
  800059:	eb 6e                	jmp    8000c9 <umain+0x95>

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
  80005b:	83 fb 14             	cmp    $0x14,%ebx
  80005e:	74 f4                	je     800054 <umain+0x20>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	89 c2                	mov    %eax,%edx
  800069:	c1 e2 05             	shl    $0x5,%edx
  80006c:	29 c2                	sub    %eax,%edx
  80006e:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800075:	eb 02                	jmp    800079 <umain+0x45>
		asm volatile("pause");
  800077:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 f7                	jne    800077 <umain+0x43>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 47 0b 00 00       	call   800bd1 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	40                   	inc    %eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009a:	4a                   	dec    %edx
  80009b:	75 f2                	jne    80008f <umain+0x5b>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  80009d:	4b                   	dec    %ebx
  80009e:	75 e5                	jne    800085 <umain+0x51>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9c>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 1b 10 80 00       	push   $0x80101b
  8000c1:	e8 5e 01 00 00       	call   800224 <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 e0 0f 80 00       	push   $0x800fe0
  8000db:	6a 21                	push   $0x21
  8000dd:	68 08 10 80 00       	push   $0x801008
  8000e2:	e8 61 00 00 00       	call   800148 <_panic>
	...

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f3:	e8 ba 0a 00 00       	call   800bb2 <sys_getenvid>
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	89 c2                	mov    %eax,%edx
  8000ff:	c1 e2 05             	shl    $0x5,%edx
  800102:	29 c2                	sub    %eax,%edx
  800104:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80010b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800110:	85 db                	test   %ebx,%ebx
  800112:	7e 07                	jle    80011b <libmain+0x33>
		binaryname = argv[0];
  800114:	8b 06                	mov    (%esi),%eax
  800116:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
  800120:	e8 0f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800125:	e8 0a 00 00 00       	call   800134 <exit>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013a:	6a 00                	push   $0x0
  80013c:	e8 30 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	c9                   	leave  
  800145:	c3                   	ret    
	...

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800156:	e8 57 0a 00 00       	call   800bb2 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 44 10 80 00       	push   $0x801044
  80016b:	e8 b4 00 00 00       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 57 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 37 10 80 00 	movl   $0x801037,(%esp)
  800183:	e8 9c 00 00 00       	call   800224 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>
	...

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 04             	sub    $0x4,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 13                	mov    (%ebx),%edx
  80019c:	8d 42 01             	lea    0x1(%edx),%eax
  80019f:	89 03                	mov    %eax,(%ebx)
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ad:	74 08                	je     8001b7 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001af:	ff 43 04             	incl   0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	68 ff 00 00 00       	push   $0xff
  8001bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 6c 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	eb dc                	jmp    8001af <putch+0x1f>

008001d3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	68 90 01 80 00       	push   $0x800190
  800202:	e8 17 01 00 00       	call   80031e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	83 c4 08             	add    $0x8,%esp
  80020a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	50                   	push   %eax
  800217:	e8 18 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80021c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022d:	50                   	push   %eax
  80022e:	ff 75 08             	pushl  0x8(%ebp)
  800231:	e8 9d ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 1c             	sub    $0x1c,%esp
  800241:	89 c7                	mov    %eax,%edi
  800243:	89 d6                	mov    %edx,%esi
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025f:	39 d3                	cmp    %edx,%ebx
  800261:	72 05                	jb     800268 <printnum+0x30>
  800263:	39 45 10             	cmp    %eax,0x10(%ebp)
  800266:	77 78                	ja     8002e0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	8b 45 14             	mov    0x14(%ebp),%eax
  800271:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800274:	53                   	push   %ebx
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	e8 44 0b 00 00       	call   800dd0 <__udivdi3>
  80028c:	83 c4 18             	add    $0x18,%esp
  80028f:	52                   	push   %edx
  800290:	50                   	push   %eax
  800291:	89 f2                	mov    %esi,%edx
  800293:	89 f8                	mov    %edi,%eax
  800295:	e8 9e ff ff ff       	call   800238 <printnum>
  80029a:	83 c4 20             	add    $0x20,%esp
  80029d:	eb 11                	jmp    8002b0 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	ff 75 18             	pushl  0x18(%ebp)
  8002a6:	ff d7                	call   *%edi
  8002a8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	4b                   	dec    %ebx
  8002ac:	85 db                	test   %ebx,%ebx
  8002ae:	7f ef                	jg     80029f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	56                   	push   %esi
  8002b4:	83 ec 04             	sub    $0x4,%esp
  8002b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c3:	e8 08 0c 00 00       	call   800ed0 <__umoddi3>
  8002c8:	83 c4 14             	add    $0x14,%esp
  8002cb:	0f be 80 68 10 80 00 	movsbl 0x801068(%eax),%eax
  8002d2:	50                   	push   %eax
  8002d3:	ff d7                	call   *%edi
}
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    
  8002e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e3:	eb c6                	jmp    8002ab <printnum+0x73>

008002e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002eb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f3:	73 0a                	jae    8002ff <sprintputch+0x1a>
		*b->buf++ = ch;
  8002f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	88 02                	mov    %al,(%edx)
}
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800307:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030a:	50                   	push   %eax
  80030b:	ff 75 10             	pushl  0x10(%ebp)
  80030e:	ff 75 0c             	pushl  0xc(%ebp)
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 05 00 00 00       	call   80031e <vprintfmt>
	va_end(ap);
}
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 2c             	sub    $0x2c,%esp
  800327:	8b 75 08             	mov    0x8(%ebp),%esi
  80032a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800330:	e9 ac 03 00 00       	jmp    8006e1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8d 47 01             	lea    0x1(%edi),%eax
  800356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800359:	8a 17                	mov    (%edi),%dl
  80035b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035e:	3c 55                	cmp    $0x55,%al
  800360:	0f 87 fc 03 00 00    	ja     800762 <vprintfmt+0x444>
  800366:	0f b6 c0             	movzbl %al,%eax
  800369:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800373:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800377:	eb da                	jmp    800353 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800380:	eb d1                	jmp    800353 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	0f b6 d2             	movzbl %dl,%edx
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	b8 00 00 00 00       	mov    $0x0,%eax
  80038d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800390:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800393:	01 c0                	add    %eax,%eax
  800395:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800399:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039f:	83 f9 09             	cmp    $0x9,%ecx
  8003a2:	77 52                	ja     8003f6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003a5:	eb e9                	jmp    800390 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 40 04             	lea    0x4(%eax),%eax
  8003b5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bf:	79 92                	jns    800353 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ce:	eb 83                	jmp    800353 <vprintfmt+0x35>
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	78 08                	js     8003de <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	e9 75 ff ff ff       	jmp    800353 <vprintfmt+0x35>
  8003de:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e5:	eb ef                	jmp    8003d6 <vprintfmt+0xb8>
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f1:	e9 5d ff ff ff       	jmp    800353 <vprintfmt+0x35>
  8003f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003fc:	eb bd                	jmp    8003bb <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800402:	e9 4c ff ff ff       	jmp    800353 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 78 04             	lea    0x4(%eax),%edi
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	53                   	push   %ebx
  800411:	ff 30                	pushl  (%eax)
  800413:	ff d6                	call   *%esi
			break;
  800415:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041b:	e9 be 02 00 00       	jmp    8006de <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 78 04             	lea    0x4(%eax),%edi
  800426:	8b 00                	mov    (%eax),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	78 2a                	js     800456 <vprintfmt+0x138>
  80042c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042e:	83 f8 08             	cmp    $0x8,%eax
  800431:	7f 27                	jg     80045a <vprintfmt+0x13c>
  800433:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  80043a:	85 c0                	test   %eax,%eax
  80043c:	74 1c                	je     80045a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	50                   	push   %eax
  80043f:	68 89 10 80 00       	push   $0x801089
  800444:	53                   	push   %ebx
  800445:	56                   	push   %esi
  800446:	e8 b6 fe ff ff       	call   800301 <printfmt>
  80044b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800451:	e9 88 02 00 00       	jmp    8006de <vprintfmt+0x3c0>
  800456:	f7 d8                	neg    %eax
  800458:	eb d2                	jmp    80042c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045a:	52                   	push   %edx
  80045b:	68 80 10 80 00       	push   $0x801080
  800460:	53                   	push   %ebx
  800461:	56                   	push   %esi
  800462:	e8 9a fe ff ff       	call   800301 <printfmt>
  800467:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046d:	e9 6c 02 00 00       	jmp    8006de <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	83 c0 04             	add    $0x4,%eax
  800478:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8b 38                	mov    (%eax),%edi
  800480:	85 ff                	test   %edi,%edi
  800482:	74 18                	je     80049c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	0f 8e b7 00 00 00    	jle    800545 <vprintfmt+0x227>
  80048e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800492:	75 0f                	jne    8004a3 <vprintfmt+0x185>
  800494:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800497:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80049a:	eb 75                	jmp    800511 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80049c:	bf 79 10 80 00       	mov    $0x801079,%edi
  8004a1:	eb e1                	jmp    800484 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a9:	57                   	push   %edi
  8004aa:	e8 5f 03 00 00       	call   80080e <strnlen>
  8004af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b2:	29 c1                	sub    %eax,%ecx
  8004b4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ba:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	eb 0d                	jmp    8004d5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	53                   	push   %ebx
  8004cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	4f                   	dec    %edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ef                	jg     8004c8 <vprintfmt+0x1aa>
  8004d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004df:	89 c8                	mov    %ecx,%eax
  8004e1:	85 c9                	test   %ecx,%ecx
  8004e3:	78 10                	js     8004f5 <vprintfmt+0x1d7>
  8004e5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e8:	29 c1                	sub    %eax,%ecx
  8004ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f3:	eb 1c                	jmp    800511 <vprintfmt+0x1f3>
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	eb e9                	jmp    8004e5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800500:	75 29                	jne    80052b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	ff 4d e0             	decl   -0x20(%ebp)
  800511:	47                   	inc    %edi
  800512:	8a 57 ff             	mov    -0x1(%edi),%dl
  800515:	0f be c2             	movsbl %dl,%eax
  800518:	85 c0                	test   %eax,%eax
  80051a:	74 4c                	je     800568 <vprintfmt+0x24a>
  80051c:	85 db                	test   %ebx,%ebx
  80051e:	78 dc                	js     8004fc <vprintfmt+0x1de>
  800520:	4b                   	dec    %ebx
  800521:	79 d9                	jns    8004fc <vprintfmt+0x1de>
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800526:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800529:	eb 2e                	jmp    800559 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80052b:	0f be d2             	movsbl %dl,%edx
  80052e:	83 ea 20             	sub    $0x20,%edx
  800531:	83 fa 5e             	cmp    $0x5e,%edx
  800534:	76 cc                	jbe    800502 <vprintfmt+0x1e4>
					putch('?', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	6a 3f                	push   $0x3f
  80053e:	ff d6                	call   *%esi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb c9                	jmp    80050e <vprintfmt+0x1f0>
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80054b:	eb c4                	jmp    800511 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	6a 20                	push   $0x20
  800553:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800555:	4f                   	dec    %edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 ff                	test   %edi,%edi
  80055b:	7f f0                	jg     80054d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
  800563:	e9 76 01 00 00       	jmp    8006de <vprintfmt+0x3c0>
  800568:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80056b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056e:	eb e9                	jmp    800559 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800570:	83 f9 01             	cmp    $0x1,%ecx
  800573:	7e 3f                	jle    8005b4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 50 04             	mov    0x4(%eax),%edx
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 08             	lea    0x8(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800590:	79 5c                	jns    8005ee <vprintfmt+0x2d0>
				putch('-', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 2d                	push   $0x2d
  800598:	ff d6                	call   *%esi
				num = -(long long) num;
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 d1 00             	adc    $0x0,%ecx
  8005a5:	f7 d9                	neg    %ecx
  8005a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 10 01 00 00       	jmp    8006c4 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	75 1b                	jne    8005d3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb b9                	jmp    80058c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ec:	eb 9e                	jmp    80058c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f9:	e9 c6 00 00 00       	jmp    8006c4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fe:	83 f9 01             	cmp    $0x1,%ecx
  800601:	7e 18                	jle    80061b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	8b 48 04             	mov    0x4(%eax),%ecx
  80060b:	8d 40 08             	lea    0x8(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	e9 a9 00 00 00       	jmp    8006c4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	75 1a                	jne    800639 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 10                	mov    (%eax),%edx
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 8b 00 00 00       	jmp    8006c4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	eb 74                	jmp    8006c4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7e 15                	jle    80066a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8b 48 04             	mov    0x4(%eax),%ecx
  80065d:	8d 40 08             	lea    0x8(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800663:	b8 08 00 00 00       	mov    $0x8,%eax
  800668:	eb 5a                	jmp    8006c4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066a:	85 c9                	test   %ecx,%ecx
  80066c:	75 17                	jne    800685 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80067e:	b8 08 00 00 00       	mov    $0x8,%eax
  800683:	eb 3f                	jmp    8006c4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	eb 28                	jmp    8006c4 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 30                	push   $0x30
  8006a2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 78                	push   $0x78
  8006aa:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	83 ec 0c             	sub    $0xc,%esp
  8006c7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cb:	57                   	push   %edi
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	50                   	push   %eax
  8006d0:	51                   	push   %ecx
  8006d1:	52                   	push   %edx
  8006d2:	89 da                	mov    %ebx,%edx
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	e8 5d fb ff ff       	call   800238 <printnum>
			break;
  8006db:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e1:	47                   	inc    %edi
  8006e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e6:	83 f8 25             	cmp    $0x25,%eax
  8006e9:	0f 84 46 fc ff ff    	je     800335 <vprintfmt+0x17>
			if (ch == '\0')
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	0f 84 89 00 00 00    	je     800780 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	50                   	push   %eax
  8006fc:	ff d6                	call   *%esi
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb de                	jmp    8006e1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800703:	83 f9 01             	cmp    $0x1,%ecx
  800706:	7e 15                	jle    80071d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	8d 40 08             	lea    0x8(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	eb a7                	jmp    8006c4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	75 17                	jne    800738 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
  800736:	eb 8c                	jmp    8006c4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800748:	b8 10 00 00 00       	mov    $0x10,%eax
  80074d:	e9 72 ff ff ff       	jmp    8006c4 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 25                	push   $0x25
  800758:	ff d6                	call   *%esi
			break;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	e9 7c ff ff ff       	jmp    8006de <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 25                	push   $0x25
  800768:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	89 f8                	mov    %edi,%eax
  80076f:	eb 01                	jmp    800772 <vprintfmt+0x454>
  800771:	48                   	dec    %eax
  800772:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800776:	75 f9                	jne    800771 <vprintfmt+0x453>
  800778:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80077b:	e9 5e ff ff ff       	jmp    8006de <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800797:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	74 26                	je     8007cf <vsnprintf+0x47>
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	7e 29                	jle    8007d6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ad:	ff 75 14             	pushl  0x14(%ebp)
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b6:	50                   	push   %eax
  8007b7:	68 e5 02 80 00       	push   $0x8002e5
  8007bc:	e8 5d fb ff ff       	call   80031e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ca:	83 c4 10             	add    $0x10,%esp
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d4:	eb f7                	jmp    8007cd <vsnprintf+0x45>
  8007d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007db:	eb f0                	jmp    8007cd <vsnprintf+0x45>

008007dd <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e6:	50                   	push   %eax
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	ff 75 08             	pushl  0x8(%ebp)
  8007f0:	e8 93 ff ff ff       	call   800788 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    
	...

008007f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	eb 01                	jmp    800806 <strlen+0xe>
		n++;
  800805:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	75 f9                	jne    800805 <strlen+0xd>
		n++;
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	eb 01                	jmp    80081f <strnlen+0x11>
		n++;
  80081e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	39 d0                	cmp    %edx,%eax
  800821:	74 06                	je     800829 <strnlen+0x1b>
  800823:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800827:	75 f5                	jne    80081e <strnlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	89 c2                	mov    %eax,%edx
  800837:	41                   	inc    %ecx
  800838:	42                   	inc    %edx
  800839:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083f:	84 db                	test   %bl,%bl
  800841:	75 f4                	jne    800837 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084d:	53                   	push   %ebx
  80084e:	e8 a5 ff ff ff       	call   8007f8 <strlen>
  800853:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	01 d8                	add    %ebx,%eax
  80085b:	50                   	push   %eax
  80085c:	e8 ca ff ff ff       	call   80082b <strcpy>
	return dst;
}
  800861:	89 d8                	mov    %ebx,%eax
  800863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	89 f3                	mov    %esi,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800878:	89 f2                	mov    %esi,%edx
  80087a:	39 da                	cmp    %ebx,%edx
  80087c:	74 0e                	je     80088c <strncpy+0x24>
		*dst++ = *src;
  80087e:	42                   	inc    %edx
  80087f:	8a 01                	mov    (%ecx),%al
  800881:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800884:	80 39 00             	cmpb   $0x0,(%ecx)
  800887:	74 f1                	je     80087a <strncpy+0x12>
			src++;
  800889:	41                   	inc    %ecx
  80088a:	eb ee                	jmp    80087a <strncpy+0x12>
	}
	return ret;
}
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 75 08             	mov    0x8(%ebp),%esi
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	74 20                	je     8008c4 <strlcpy+0x32>
  8008a4:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	eb 05                	jmp    8008b1 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ac:	42                   	inc    %edx
  8008ad:	40                   	inc    %eax
  8008ae:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b1:	39 d8                	cmp    %ebx,%eax
  8008b3:	74 06                	je     8008bb <strlcpy+0x29>
  8008b5:	8a 0a                	mov    (%edx),%cl
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	75 f1                	jne    8008ac <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008be:	29 f0                	sub    %esi,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    
  8008c4:	89 f0                	mov    %esi,%eax
  8008c6:	eb f6                	jmp    8008be <strlcpy+0x2c>

008008c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d1:	eb 02                	jmp    8008d5 <strcmp+0xd>
		p++, q++;
  8008d3:	41                   	inc    %ecx
  8008d4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d5:	8a 01                	mov    (%ecx),%al
  8008d7:	84 c0                	test   %al,%al
  8008d9:	74 04                	je     8008df <strcmp+0x17>
  8008db:	3a 02                	cmp    (%edx),%al
  8008dd:	74 f4                	je     8008d3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 c0             	movzbl %al,%eax
  8008e2:	0f b6 12             	movzbl (%edx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	89 c3                	mov    %eax,%ebx
  8008f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f8:	eb 02                	jmp    8008fc <strncmp+0x13>
		n--, p++, q++;
  8008fa:	40                   	inc    %eax
  8008fb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fc:	39 d8                	cmp    %ebx,%eax
  8008fe:	74 15                	je     800915 <strncmp+0x2c>
  800900:	8a 08                	mov    (%eax),%cl
  800902:	84 c9                	test   %cl,%cl
  800904:	74 04                	je     80090a <strncmp+0x21>
  800906:	3a 0a                	cmp    (%edx),%cl
  800908:	74 f0                	je     8008fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 00             	movzbl (%eax),%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb f6                	jmp    800912 <strncmp+0x29>

0080091c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	74 07                	je     800932 <strchr+0x16>
		if (*s == c)
  80092b:	38 ca                	cmp    %cl,%dl
  80092d:	74 08                	je     800937 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092f:	40                   	inc    %eax
  800930:	eb f3                	jmp    800925 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	74 07                	je     80094f <strfind+0x16>
		if (*s == c)
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	74 03                	je     80094f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094c:	40                   	inc    %eax
  80094d:	eb f3                	jmp    800942 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 13                	je     800974 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800961:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800967:	75 05                	jne    80096e <memset+0x1d>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	74 0d                	je     80097b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80097b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 18             	shl    $0x18,%eax
  800989:	89 d6                	mov    %edx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 c2                	or     %eax,%edx
  800992:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800997:	89 d0                	mov    %edx,%eax
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb d6                	jmp    800974 <memset+0x23>

0080099e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ac:	39 c6                	cmp    %eax,%esi
  8009ae:	73 33                	jae    8009e3 <memmove+0x45>
  8009b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b3:	39 c2                	cmp    %eax,%edx
  8009b5:	76 2c                	jbe    8009e3 <memmove+0x45>
		s += n;
		d += n;
  8009b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	09 fe                	or     %edi,%esi
  8009be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c4:	74 0a                	je     8009d0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c6:	4f                   	dec    %edi
  8009c7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cd:	fc                   	cld    
  8009ce:	eb 21                	jmp    8009f1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 f1                	jne    8009c6 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d5:	83 ef 04             	sub    $0x4,%edi
  8009d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009db:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009de:	fd                   	std    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb ea                	jmp    8009cd <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	09 c2                	or     %eax,%edx
  8009e7:	f6 c2 03             	test   $0x3,%dl
  8009ea:	74 09                	je     8009f5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 f2                	jne    8009ec <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb ed                	jmp    8009f1 <memmove+0x53>

00800a04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a07:	ff 75 10             	pushl  0x10(%ebp)
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	ff 75 08             	pushl  0x8(%ebp)
  800a10:	e8 89 ff ff ff       	call   80099e <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 16                	je     800a41 <memcmp+0x2a>
		if (*s1 != *s2)
  800a2b:	8a 08                	mov    (%eax),%cl
  800a2d:	8a 1a                	mov    (%edx),%bl
  800a2f:	38 d9                	cmp    %bl,%cl
  800a31:	75 04                	jne    800a37 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a33:	40                   	inc    %eax
  800a34:	42                   	inc    %edx
  800a35:	eb f0                	jmp    800a27 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a37:	0f b6 c1             	movzbl %cl,%eax
  800a3a:	0f b6 db             	movzbl %bl,%ebx
  800a3d:	29 d8                	sub    %ebx,%eax
  800a3f:	eb 05                	jmp    800a46 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a53:	89 c2                	mov    %eax,%edx
  800a55:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a58:	39 d0                	cmp    %edx,%eax
  800a5a:	73 07                	jae    800a63 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5c:	38 08                	cmp    %cl,(%eax)
  800a5e:	74 03                	je     800a63 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a60:	40                   	inc    %eax
  800a61:	eb f5                	jmp    800a58 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 01                	jmp    800a71 <strtol+0xc>
		s++;
  800a70:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	8a 01                	mov    (%ecx),%al
  800a73:	3c 20                	cmp    $0x20,%al
  800a75:	74 f9                	je     800a70 <strtol+0xb>
  800a77:	3c 09                	cmp    $0x9,%al
  800a79:	74 f5                	je     800a70 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7b:	3c 2b                	cmp    $0x2b,%al
  800a7d:	74 2b                	je     800aaa <strtol+0x45>
		s++;
	else if (*s == '-')
  800a7f:	3c 2d                	cmp    $0x2d,%al
  800a81:	74 2f                	je     800ab2 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a8f:	75 12                	jne    800aa3 <strtol+0x3e>
  800a91:	80 39 30             	cmpb   $0x30,(%ecx)
  800a94:	74 24                	je     800aba <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9a:	75 07                	jne    800aa3 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	eb 4e                	jmp    800af8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800aaa:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aab:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab0:	eb d6                	jmp    800a88 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800ab2:	41                   	inc    %ecx
  800ab3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab8:	eb ce                	jmp    800a88 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abe:	74 10                	je     800ad0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac4:	75 dd                	jne    800aa3 <strtol+0x3e>
		s++, base = 8;
  800ac6:	41                   	inc    %ecx
  800ac7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ace:	eb d3                	jmp    800aa3 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ad0:	83 c1 02             	add    $0x2,%ecx
  800ad3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ada:	eb c7                	jmp    800aa3 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800adc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 24                	ja     800b0a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aec:	39 55 10             	cmp    %edx,0x10(%ebp)
  800aef:	7e 2b                	jle    800b1c <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800af1:	41                   	inc    %ecx
  800af2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af8:	8a 11                	mov    (%ecx),%dl
  800afa:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	77 da                	ja     800adc <strtol+0x77>
			dig = *s - '0';
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 30             	sub    $0x30,%edx
  800b08:	eb e2                	jmp    800aec <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b14:	0f be d2             	movsbl %dl,%edx
  800b17:	83 ea 37             	sub    $0x37,%edx
  800b1a:	eb d0                	jmp    800aec <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b20:	74 05                	je     800b27 <strtol+0xc2>
		*endptr = (char *) s;
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b27:	85 ff                	test   %edi,%edi
  800b29:	74 02                	je     800b2d <strtol+0xc8>
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 a4 12 80 00       	push   $0x8012a4
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 c1 12 80 00       	push   $0x8012c1
  800bad:	e8 96 f5 ff ff       	call   800148 <_panic>

00800bb2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 a4 12 80 00       	push   $0x8012a4
  800c27:	6a 23                	push   $0x23
  800c29:	68 c1 12 80 00       	push   $0x8012c1
  800c2e:	e8 15 f5 ff ff       	call   800148 <_panic>

00800c33 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 05                	push   $0x5
  800c64:	68 a4 12 80 00       	push   $0x8012a4
  800c69:	6a 23                	push   $0x23
  800c6b:	68 c1 12 80 00       	push   $0x8012c1
  800c70:	e8 d3 f4 ff ff       	call   800148 <_panic>

00800c75 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 a4 12 80 00       	push   $0x8012a4
  800cab:	6a 23                	push   $0x23
  800cad:	68 c1 12 80 00       	push   $0x8012c1
  800cb2:	e8 91 f4 ff ff       	call   800148 <_panic>

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 a4 12 80 00       	push   $0x8012a4
  800ced:	6a 23                	push   $0x23
  800cef:	68 c1 12 80 00       	push   $0x8012c1
  800cf4:	e8 4f f4 ff ff       	call   800148 <_panic>

00800cf9 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 a4 12 80 00       	push   $0x8012a4
  800d2f:	6a 23                	push   $0x23
  800d31:	68 c1 12 80 00       	push   $0x8012c1
  800d36:	e8 0d f4 ff ff       	call   800148 <_panic>

00800d3b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0c                	push   $0xc
  800d8e:	68 a4 12 80 00       	push   $0x8012a4
  800d93:	6a 23                	push   $0x23
  800d95:	68 c1 12 80 00       	push   $0x8012c1
  800d9a:	e8 a9 f3 ff ff       	call   800148 <_panic>
	...

00800da0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800da6:	68 db 12 80 00       	push   $0x8012db
  800dab:	6a 51                	push   $0x51
  800dad:	68 cf 12 80 00       	push   $0x8012cf
  800db2:	e8 91 f3 ff ff       	call   800148 <_panic>

00800db7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dbd:	68 da 12 80 00       	push   $0x8012da
  800dc2:	6a 58                	push   $0x58
  800dc4:	68 cf 12 80 00       	push   $0x8012cf
  800dc9:	e8 7a f3 ff ff       	call   800148 <_panic>
	...

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ddb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ddf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800de7:	85 d2                	test   %edx,%edx
  800de9:	75 2d                	jne    800e18 <__udivdi3+0x48>
  800deb:	39 f7                	cmp    %esi,%edi
  800ded:	77 59                	ja     800e48 <__udivdi3+0x78>
  800def:	89 f9                	mov    %edi,%ecx
  800df1:	85 ff                	test   %edi,%edi
  800df3:	75 0b                	jne    800e00 <__udivdi3+0x30>
  800df5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfa:	31 d2                	xor    %edx,%edx
  800dfc:	f7 f7                	div    %edi
  800dfe:	89 c1                	mov    %eax,%ecx
  800e00:	31 d2                	xor    %edx,%edx
  800e02:	89 f0                	mov    %esi,%eax
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 e8                	mov    %ebp,%eax
  800e0a:	f7 f1                	div    %ecx
  800e0c:	89 da                	mov    %ebx,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	39 f2                	cmp    %esi,%edx
  800e1a:	77 1c                	ja     800e38 <__udivdi3+0x68>
  800e1c:	0f bd da             	bsr    %edx,%ebx
  800e1f:	83 f3 1f             	xor    $0x1f,%ebx
  800e22:	75 38                	jne    800e5c <__udivdi3+0x8c>
  800e24:	39 f2                	cmp    %esi,%edx
  800e26:	72 08                	jb     800e30 <__udivdi3+0x60>
  800e28:	39 ef                	cmp    %ebp,%edi
  800e2a:	0f 87 98 00 00 00    	ja     800ec8 <__udivdi3+0xf8>
  800e30:	b8 01 00 00 00       	mov    $0x1,%eax
  800e35:	eb 05                	jmp    800e3c <__udivdi3+0x6c>
  800e37:	90                   	nop
  800e38:	31 db                	xor    %ebx,%ebx
  800e3a:	31 c0                	xor    %eax,%eax
  800e3c:	89 da                	mov    %ebx,%edx
  800e3e:	83 c4 1c             	add    $0x1c,%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	89 e8                	mov    %ebp,%eax
  800e4a:	89 f2                	mov    %esi,%edx
  800e4c:	f7 f7                	div    %edi
  800e4e:	31 db                	xor    %ebx,%ebx
  800e50:	89 da                	mov    %ebx,%edx
  800e52:	83 c4 1c             	add    $0x1c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e61:	29 d8                	sub    %ebx,%eax
  800e63:	88 d9                	mov    %bl,%cl
  800e65:	d3 e2                	shl    %cl,%edx
  800e67:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6b:	89 fa                	mov    %edi,%edx
  800e6d:	88 c1                	mov    %al,%cl
  800e6f:	d3 ea                	shr    %cl,%edx
  800e71:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e75:	09 d1                	or     %edx,%ecx
  800e77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e7b:	88 d9                	mov    %bl,%cl
  800e7d:	d3 e7                	shl    %cl,%edi
  800e7f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e83:	89 f7                	mov    %esi,%edi
  800e85:	88 c1                	mov    %al,%cl
  800e87:	d3 ef                	shr    %cl,%edi
  800e89:	88 d9                	mov    %bl,%cl
  800e8b:	d3 e6                	shl    %cl,%esi
  800e8d:	89 ea                	mov    %ebp,%edx
  800e8f:	88 c1                	mov    %al,%cl
  800e91:	d3 ea                	shr    %cl,%edx
  800e93:	09 d6                	or     %edx,%esi
  800e95:	89 f0                	mov    %esi,%eax
  800e97:	89 fa                	mov    %edi,%edx
  800e99:	f7 74 24 08          	divl   0x8(%esp)
  800e9d:	89 d7                	mov    %edx,%edi
  800e9f:	89 c6                	mov    %eax,%esi
  800ea1:	f7 64 24 0c          	mull   0xc(%esp)
  800ea5:	39 d7                	cmp    %edx,%edi
  800ea7:	72 13                	jb     800ebc <__udivdi3+0xec>
  800ea9:	74 09                	je     800eb4 <__udivdi3+0xe4>
  800eab:	89 f0                	mov    %esi,%eax
  800ead:	31 db                	xor    %ebx,%ebx
  800eaf:	eb 8b                	jmp    800e3c <__udivdi3+0x6c>
  800eb1:	8d 76 00             	lea    0x0(%esi),%esi
  800eb4:	88 d9                	mov    %bl,%cl
  800eb6:	d3 e5                	shl    %cl,%ebp
  800eb8:	39 c5                	cmp    %eax,%ebp
  800eba:	73 ef                	jae    800eab <__udivdi3+0xdb>
  800ebc:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ebf:	31 db                	xor    %ebx,%ebx
  800ec1:	e9 76 ff ff ff       	jmp    800e3c <__udivdi3+0x6c>
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	31 c0                	xor    %eax,%eax
  800eca:	e9 6d ff ff ff       	jmp    800e3c <__udivdi3+0x6c>
	...

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800edb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800edf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ee7:	89 f0                	mov    %esi,%eax
  800ee9:	89 da                	mov    %ebx,%edx
  800eeb:	85 ed                	test   %ebp,%ebp
  800eed:	75 15                	jne    800f04 <__umoddi3+0x34>
  800eef:	39 df                	cmp    %ebx,%edi
  800ef1:	76 39                	jbe    800f2c <__umoddi3+0x5c>
  800ef3:	f7 f7                	div    %edi
  800ef5:	89 d0                	mov    %edx,%eax
  800ef7:	31 d2                	xor    %edx,%edx
  800ef9:	83 c4 1c             	add    $0x1c,%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    
  800f01:	8d 76 00             	lea    0x0(%esi),%esi
  800f04:	39 dd                	cmp    %ebx,%ebp
  800f06:	77 f1                	ja     800ef9 <__umoddi3+0x29>
  800f08:	0f bd cd             	bsr    %ebp,%ecx
  800f0b:	83 f1 1f             	xor    $0x1f,%ecx
  800f0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f12:	75 38                	jne    800f4c <__umoddi3+0x7c>
  800f14:	39 dd                	cmp    %ebx,%ebp
  800f16:	72 04                	jb     800f1c <__umoddi3+0x4c>
  800f18:	39 f7                	cmp    %esi,%edi
  800f1a:	77 dd                	ja     800ef9 <__umoddi3+0x29>
  800f1c:	89 da                	mov    %ebx,%edx
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	29 f8                	sub    %edi,%eax
  800f22:	19 ea                	sbb    %ebp,%edx
  800f24:	83 c4 1c             	add    $0x1c,%esp
  800f27:	5b                   	pop    %ebx
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    
  800f2c:	89 f9                	mov    %edi,%ecx
  800f2e:	85 ff                	test   %edi,%edi
  800f30:	75 0b                	jne    800f3d <__umoddi3+0x6d>
  800f32:	b8 01 00 00 00       	mov    $0x1,%eax
  800f37:	31 d2                	xor    %edx,%edx
  800f39:	f7 f7                	div    %edi
  800f3b:	89 c1                	mov    %eax,%ecx
  800f3d:	89 d8                	mov    %ebx,%eax
  800f3f:	31 d2                	xor    %edx,%edx
  800f41:	f7 f1                	div    %ecx
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	f7 f1                	div    %ecx
  800f47:	eb ac                	jmp    800ef5 <__umoddi3+0x25>
  800f49:	8d 76 00             	lea    0x0(%esi),%esi
  800f4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f57:	29 c2                	sub    %eax,%edx
  800f59:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5d:	88 c1                	mov    %al,%cl
  800f5f:	d3 e5                	shl    %cl,%ebp
  800f61:	89 f8                	mov    %edi,%eax
  800f63:	88 d1                	mov    %dl,%cl
  800f65:	d3 e8                	shr    %cl,%eax
  800f67:	09 c5                	or     %eax,%ebp
  800f69:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f6d:	88 c1                	mov    %al,%cl
  800f6f:	d3 e7                	shl    %cl,%edi
  800f71:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f75:	89 df                	mov    %ebx,%edi
  800f77:	88 d1                	mov    %dl,%cl
  800f79:	d3 ef                	shr    %cl,%edi
  800f7b:	88 c1                	mov    %al,%cl
  800f7d:	d3 e3                	shl    %cl,%ebx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	88 d1                	mov    %dl,%cl
  800f83:	d3 e8                	shr    %cl,%eax
  800f85:	09 d8                	or     %ebx,%eax
  800f87:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f8b:	d3 e6                	shl    %cl,%esi
  800f8d:	89 fa                	mov    %edi,%edx
  800f8f:	f7 f5                	div    %ebp
  800f91:	89 d1                	mov    %edx,%ecx
  800f93:	f7 64 24 08          	mull   0x8(%esp)
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	89 d7                	mov    %edx,%edi
  800f9b:	39 d1                	cmp    %edx,%ecx
  800f9d:	72 29                	jb     800fc8 <__umoddi3+0xf8>
  800f9f:	74 23                	je     800fc4 <__umoddi3+0xf4>
  800fa1:	89 ca                	mov    %ecx,%edx
  800fa3:	29 de                	sub    %ebx,%esi
  800fa5:	19 fa                	sbb    %edi,%edx
  800fa7:	89 d0                	mov    %edx,%eax
  800fa9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800fad:	d3 e0                	shl    %cl,%eax
  800faf:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fb3:	88 d9                	mov    %bl,%cl
  800fb5:	d3 ee                	shr    %cl,%esi
  800fb7:	09 f0                	or     %esi,%eax
  800fb9:	d3 ea                	shr    %cl,%edx
  800fbb:	83 c4 1c             	add    $0x1c,%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    
  800fc3:	90                   	nop
  800fc4:	39 c6                	cmp    %eax,%esi
  800fc6:	73 d9                	jae    800fa1 <__umoddi3+0xd1>
  800fc8:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fcc:	19 ea                	sbb    %ebp,%edx
  800fce:	89 d7                	mov    %edx,%edi
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	eb cd                	jmp    800fa1 <__umoddi3+0xd1>
