
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 a7 00 00 00       	call   8000d8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	68 a0 0f 80 00       	push   $0x800fa0
  80003f:	e8 d0 01 00 00       	call   800214 <cprintf>
  800044:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800047:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004c:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800053:	00 
  800054:	75 5d                	jne    8000b3 <umain+0x7f>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800056:	40                   	inc    %eax
  800057:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005c:	75 ee                	jne    80004c <umain+0x18>
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005e:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800063:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006a:	40                   	inc    %eax
  80006b:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800070:	75 f1                	jne    800063 <umain+0x2f>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  800072:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800077:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80007e:	75 45                	jne    8000c5 <umain+0x91>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  800080:	40                   	inc    %eax
  800081:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800086:	75 ef                	jne    800077 <umain+0x43>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 e8 0f 80 00       	push   $0x800fe8
  800090:	e8 7f 01 00 00       	call   800214 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800095:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80009c:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80009f:	83 c4 0c             	add    $0xc,%esp
  8000a2:	68 47 10 80 00       	push   $0x801047
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 38 10 80 00       	push   $0x801038
  8000ae:	e8 85 00 00 00       	call   800138 <_panic>
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b3:	50                   	push   %eax
  8000b4:	68 1b 10 80 00       	push   $0x80101b
  8000b9:	6a 11                	push   $0x11
  8000bb:	68 38 10 80 00       	push   $0x801038
  8000c0:	e8 73 00 00 00       	call   800138 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c5:	50                   	push   %eax
  8000c6:	68 c0 0f 80 00       	push   $0x800fc0
  8000cb:	6a 16                	push   $0x16
  8000cd:	68 38 10 80 00       	push   $0x801038
  8000d2:	e8 61 00 00 00       	call   800138 <_panic>
	...

008000d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e3:	e8 ba 0a 00 00       	call   800ba2 <sys_getenvid>
  8000e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ed:	89 c2                	mov    %eax,%edx
  8000ef:	c1 e2 05             	shl    $0x5,%edx
  8000f2:	29 c2                	sub    %eax,%edx
  8000f4:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8000fb:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x33>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012a:	6a 00                	push   $0x0
  80012c:	e8 30 0a 00 00       	call   800b61 <sys_env_destroy>
}
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	c9                   	leave  
  800135:	c3                   	ret    
	...

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800140:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800146:	e8 57 0a 00 00       	call   800ba2 <sys_getenvid>
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 75 0c             	pushl  0xc(%ebp)
  800151:	ff 75 08             	pushl  0x8(%ebp)
  800154:	56                   	push   %esi
  800155:	50                   	push   %eax
  800156:	68 68 10 80 00       	push   $0x801068
  80015b:	e8 b4 00 00 00       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 57 00 00 00       	call   8001c3 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 36 10 80 00 	movl   $0x801036,(%esp)
  800173:	e8 9c 00 00 00       	call   800214 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x43>
	...

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	74 08                	je     8001a7 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019f:	ff 43 04             	incl   0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	68 ff 00 00 00       	push   $0xff
  8001af:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 6c 09 00 00       	call   800b24 <sys_cputs>
		b->idx = 0;
  8001b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	eb dc                	jmp    80019f <putch+0x1f>

008001c3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 80 01 80 00       	push   $0x800180
  8001f2:	e8 17 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 18 09 00 00       	call   800b24 <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800241:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024f:	39 d3                	cmp    %edx,%ebx
  800251:	72 05                	jb     800258 <printnum+0x30>
  800253:	39 45 10             	cmp    %eax,0x10(%ebp)
  800256:	77 78                	ja     8002d0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	8b 45 14             	mov    0x14(%ebp),%eax
  800261:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800264:	53                   	push   %ebx
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 14 0b 00 00       	call   800d90 <__udivdi3>
  80027c:	83 c4 18             	add    $0x18,%esp
  80027f:	52                   	push   %edx
  800280:	50                   	push   %eax
  800281:	89 f2                	mov    %esi,%edx
  800283:	89 f8                	mov    %edi,%eax
  800285:	e8 9e ff ff ff       	call   800228 <printnum>
  80028a:	83 c4 20             	add    $0x20,%esp
  80028d:	eb 11                	jmp    8002a0 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	ff 75 18             	pushl  0x18(%ebp)
  800296:	ff d7                	call   *%edi
  800298:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f ef                	jg     80028f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b3:	e8 d8 0b 00 00       	call   800e90 <__umoddi3>
  8002b8:	83 c4 14             	add    $0x14,%esp
  8002bb:	0f be 80 8c 10 80 00 	movsbl 0x80108c(%eax),%eax
  8002c2:	50                   	push   %eax
  8002c3:	ff d7                	call   *%edi
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
  8002d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d3:	eb c6                	jmp    80029b <printnum+0x73>

008002d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002db:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e3:	73 0a                	jae    8002ef <sprintputch+0x1a>
		*b->buf++ = ch;
  8002e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	88 02                	mov    %al,(%edx)
}
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 10             	pushl  0x10(%ebp)
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	ff 75 08             	pushl  0x8(%ebp)
  800304:	e8 05 00 00 00       	call   80030e <vprintfmt>
	va_end(ap);
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 2c             	sub    $0x2c,%esp
  800317:	8b 75 08             	mov    0x8(%ebp),%esi
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800320:	e9 ac 03 00 00       	jmp    8006d1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800325:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800329:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800330:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800337:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8d 47 01             	lea    0x1(%edi),%eax
  800346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800349:	8a 17                	mov    (%edi),%dl
  80034b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034e:	3c 55                	cmp    $0x55,%al
  800350:	0f 87 fc 03 00 00    	ja     800752 <vprintfmt+0x444>
  800356:	0f b6 c0             	movzbl %al,%eax
  800359:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800363:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800367:	eb da                	jmp    800343 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800370:	eb d1                	jmp    800343 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	0f b6 d2             	movzbl %dl,%edx
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800380:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800383:	01 c0                	add    %eax,%eax
  800385:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800389:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038f:	83 f9 09             	cmp    $0x9,%ecx
  800392:	77 52                	ja     8003e6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800394:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800395:	eb e9                	jmp    800380 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 40 04             	lea    0x4(%eax),%eax
  8003a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003af:	79 92                	jns    800343 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003be:	eb 83                	jmp    800343 <vprintfmt+0x35>
  8003c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c4:	78 08                	js     8003ce <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c9:	e9 75 ff ff ff       	jmp    800343 <vprintfmt+0x35>
  8003ce:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d5:	eb ef                	jmp    8003c6 <vprintfmt+0xb8>
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e1:	e9 5d ff ff ff       	jmp    800343 <vprintfmt+0x35>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ec:	eb bd                	jmp    8003ab <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ee:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	e9 4c ff ff ff       	jmp    800343 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040b:	e9 be 02 00 00       	jmp    8006ce <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 78 04             	lea    0x4(%eax),%edi
  800416:	8b 00                	mov    (%eax),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	78 2a                	js     800446 <vprintfmt+0x138>
  80041c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041e:	83 f8 08             	cmp    $0x8,%eax
  800421:	7f 27                	jg     80044a <vprintfmt+0x13c>
  800423:	8b 04 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%eax
  80042a:	85 c0                	test   %eax,%eax
  80042c:	74 1c                	je     80044a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80042e:	50                   	push   %eax
  80042f:	68 ad 10 80 00       	push   $0x8010ad
  800434:	53                   	push   %ebx
  800435:	56                   	push   %esi
  800436:	e8 b6 fe ff ff       	call   8002f1 <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800441:	e9 88 02 00 00       	jmp    8006ce <vprintfmt+0x3c0>
  800446:	f7 d8                	neg    %eax
  800448:	eb d2                	jmp    80041c <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044a:	52                   	push   %edx
  80044b:	68 a4 10 80 00       	push   $0x8010a4
  800450:	53                   	push   %ebx
  800451:	56                   	push   %esi
  800452:	e8 9a fe ff ff       	call   8002f1 <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045d:	e9 6c 02 00 00       	jmp    8006ce <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	83 c0 04             	add    $0x4,%eax
  800468:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8b 38                	mov    (%eax),%edi
  800470:	85 ff                	test   %edi,%edi
  800472:	74 18                	je     80048c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800474:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800478:	0f 8e b7 00 00 00    	jle    800535 <vprintfmt+0x227>
  80047e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800482:	75 0f                	jne    800493 <vprintfmt+0x185>
  800484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800487:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80048a:	eb 75                	jmp    800501 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80048c:	bf 9d 10 80 00       	mov    $0x80109d,%edi
  800491:	eb e1                	jmp    800474 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 d0             	pushl  -0x30(%ebp)
  800499:	57                   	push   %edi
  80049a:	e8 5f 03 00 00       	call   8007fe <strnlen>
  80049f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a2:	29 c1                	sub    %eax,%ecx
  8004a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	eb 0d                	jmp    8004c5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	53                   	push   %ebx
  8004bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	4f                   	dec    %edi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	7f ef                	jg     8004b8 <vprintfmt+0x1aa>
  8004c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004cf:	89 c8                	mov    %ecx,%eax
  8004d1:	85 c9                	test   %ecx,%ecx
  8004d3:	78 10                	js     8004e5 <vprintfmt+0x1d7>
  8004d5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004e3:	eb 1c                	jmp    800501 <vprintfmt+0x1f3>
  8004e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ea:	eb e9                	jmp    8004d5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	75 29                	jne    80051b <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	50                   	push   %eax
  8004f9:	ff d6                	call   *%esi
  8004fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	ff 4d e0             	decl   -0x20(%ebp)
  800501:	47                   	inc    %edi
  800502:	8a 57 ff             	mov    -0x1(%edi),%dl
  800505:	0f be c2             	movsbl %dl,%eax
  800508:	85 c0                	test   %eax,%eax
  80050a:	74 4c                	je     800558 <vprintfmt+0x24a>
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	78 dc                	js     8004ec <vprintfmt+0x1de>
  800510:	4b                   	dec    %ebx
  800511:	79 d9                	jns    8004ec <vprintfmt+0x1de>
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800516:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800519:	eb 2e                	jmp    800549 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80051b:	0f be d2             	movsbl %dl,%edx
  80051e:	83 ea 20             	sub    $0x20,%edx
  800521:	83 fa 5e             	cmp    $0x5e,%edx
  800524:	76 cc                	jbe    8004f2 <vprintfmt+0x1e4>
					putch('?', putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	6a 3f                	push   $0x3f
  80052e:	ff d6                	call   *%esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb c9                	jmp    8004fe <vprintfmt+0x1f0>
  800535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800538:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053b:	eb c4                	jmp    800501 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	4f                   	dec    %edi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 ff                	test   %edi,%edi
  80054b:	7f f0                	jg     80053d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	e9 76 01 00 00       	jmp    8006ce <vprintfmt+0x3c0>
  800558:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80055b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055e:	eb e9                	jmp    800549 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800560:	83 f9 01             	cmp    $0x1,%ecx
  800563:	7e 3f                	jle    8005a4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 50 04             	mov    0x4(%eax),%edx
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 08             	lea    0x8(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80057c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800580:	79 5c                	jns    8005de <vprintfmt+0x2d0>
				putch('-', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	6a 2d                	push   $0x2d
  800588:	ff d6                	call   *%esi
				num = -(long long) num;
  80058a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800590:	f7 da                	neg    %edx
  800592:	83 d1 00             	adc    $0x0,%ecx
  800595:	f7 d9                	neg    %ecx
  800597:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	e9 10 01 00 00       	jmp    8006b4 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005a4:	85 c9                	test   %ecx,%ecx
  8005a6:	75 1b                	jne    8005c3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 c1                	mov    %eax,%ecx
  8005b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	eb b9                	jmp    80057c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 c1                	mov    %eax,%ecx
  8005cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb 9e                	jmp    80057c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 c6 00 00 00       	jmp    8006b4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7e 18                	jle    80060b <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
  800606:	e9 a9 00 00 00       	jmp    8006b4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80060b:	85 c9                	test   %ecx,%ecx
  80060d:	75 1a                	jne    800629 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	e9 8b 00 00 00       	jmp    8006b4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800633:	8d 40 04             	lea    0x4(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063e:	eb 74                	jmp    8006b4 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800640:	83 f9 01             	cmp    $0x1,%ecx
  800643:	7e 15                	jle    80065a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8b 48 04             	mov    0x4(%eax),%ecx
  80064d:	8d 40 08             	lea    0x8(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800653:	b8 08 00 00 00       	mov    $0x8,%eax
  800658:	eb 5a                	jmp    8006b4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80065a:	85 c9                	test   %ecx,%ecx
  80065c:	75 17                	jne    800675 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80066e:	b8 08 00 00 00       	mov    $0x8,%eax
  800673:	eb 3f                	jmp    8006b4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800685:	b8 08 00 00 00       	mov    $0x8,%eax
  80068a:	eb 28                	jmp    8006b4 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 30                	push   $0x30
  800692:	ff d6                	call   *%esi
			putch('x', putdat);
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 78                	push   $0x78
  80069a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	50                   	push   %eax
  8006c0:	51                   	push   %ecx
  8006c1:	52                   	push   %edx
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 5d fb ff ff       	call   800228 <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	47                   	inc    %edi
  8006d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d6:	83 f8 25             	cmp    $0x25,%eax
  8006d9:	0f 84 46 fc ff ff    	je     800325 <vprintfmt+0x17>
			if (ch == '\0')
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	0f 84 89 00 00 00    	je     800770 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	50                   	push   %eax
  8006ec:	ff d6                	call   *%esi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	eb de                	jmp    8006d1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7e 15                	jle    80070d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	8d 40 08             	lea    0x8(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
  80070b:	eb a7                	jmp    8006b4 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	75 17                	jne    800728 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
  800726:	eb 8c                	jmp    8006b4 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
  80073d:	e9 72 ff ff ff       	jmp    8006b4 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	6a 25                	push   $0x25
  800748:	ff d6                	call   *%esi
			break;
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	e9 7c ff ff ff       	jmp    8006ce <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 25                	push   $0x25
  800758:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	89 f8                	mov    %edi,%eax
  80075f:	eb 01                	jmp    800762 <vprintfmt+0x454>
  800761:	48                   	dec    %eax
  800762:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800766:	75 f9                	jne    800761 <vprintfmt+0x453>
  800768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076b:	e9 5e ff ff ff       	jmp    8006ce <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x47>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 29                	jle    8007c6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 d5 02 80 00       	push   $0x8002d5
  8007ac:	e8 5d fb ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb f7                	jmp    8007bd <vsnprintf+0x45>
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cb:	eb f0                	jmp    8007bd <vsnprintf+0x45>

008007cd <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d6:	50                   	push   %eax
  8007d7:	ff 75 10             	pushl  0x10(%ebp)
  8007da:	ff 75 0c             	pushl  0xc(%ebp)
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 93 ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	41                   	inc    %ecx
  800828:	42                   	inc    %edx
  800829:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80082c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082f:	84 db                	test   %bl,%bl
  800831:	75 f4                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083d:	53                   	push   %ebx
  80083e:	e8 a5 ff ff ff       	call   8007e8 <strlen>
  800843:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800846:	ff 75 0c             	pushl  0xc(%ebp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	50                   	push   %eax
  80084c:	e8 ca ff ff ff       	call   80081b <strcpy>
	return dst;
}
  800851:	89 d8                	mov    %ebx,%eax
  800853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	89 f3                	mov    %esi,%ebx
  800865:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	89 f2                	mov    %esi,%edx
  80086a:	39 da                	cmp    %ebx,%edx
  80086c:	74 0e                	je     80087c <strncpy+0x24>
		*dst++ = *src;
  80086e:	42                   	inc    %edx
  80086f:	8a 01                	mov    (%ecx),%al
  800871:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800874:	80 39 00             	cmpb   $0x0,(%ecx)
  800877:	74 f1                	je     80086a <strncpy+0x12>
			src++;
  800879:	41                   	inc    %ecx
  80087a:	eb ee                	jmp    80086a <strncpy+0x12>
	}
	return ret;
}
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 c0                	test   %eax,%eax
  800892:	74 20                	je     8008b4 <strlcpy+0x32>
  800894:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800898:	89 f0                	mov    %esi,%eax
  80089a:	eb 05                	jmp    8008a1 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	42                   	inc    %edx
  80089d:	40                   	inc    %eax
  80089e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 06                	je     8008ab <strlcpy+0x29>
  8008a5:	8a 0a                	mov    (%edx),%cl
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	75 f1                	jne    80089c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f0                	sub    %esi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    
  8008b4:	89 f0                	mov    %esi,%eax
  8008b6:	eb f6                	jmp    8008ae <strlcpy+0x2c>

008008b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c1:	eb 02                	jmp    8008c5 <strcmp+0xd>
		p++, q++;
  8008c3:	41                   	inc    %ecx
  8008c4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c5:	8a 01                	mov    (%ecx),%al
  8008c7:	84 c0                	test   %al,%al
  8008c9:	74 04                	je     8008cf <strcmp+0x17>
  8008cb:	3a 02                	cmp    (%edx),%al
  8008cd:	74 f4                	je     8008c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 c0             	movzbl %al,%eax
  8008d2:	0f b6 12             	movzbl (%edx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e3:	89 c3                	mov    %eax,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 02                	jmp    8008ec <strncmp+0x13>
		n--, p++, q++;
  8008ea:	40                   	inc    %eax
  8008eb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ec:	39 d8                	cmp    %ebx,%eax
  8008ee:	74 15                	je     800905 <strncmp+0x2c>
  8008f0:	8a 08                	mov    (%eax),%cl
  8008f2:	84 c9                	test   %cl,%cl
  8008f4:	74 04                	je     8008fa <strncmp+0x21>
  8008f6:	3a 0a                	cmp    (%edx),%cl
  8008f8:	74 f0                	je     8008ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fa:	0f b6 00             	movzbl (%eax),%eax
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	29 d0                	sub    %edx,%eax
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	eb f6                	jmp    800902 <strncmp+0x29>

0080090c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800915:	8a 10                	mov    (%eax),%dl
  800917:	84 d2                	test   %dl,%dl
  800919:	74 07                	je     800922 <strchr+0x16>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 08                	je     800927 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	40                   	inc    %eax
  800920:	eb f3                	jmp    800915 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800932:	8a 10                	mov    (%eax),%dl
  800934:	84 d2                	test   %dl,%dl
  800936:	74 07                	je     80093f <strfind+0x16>
		if (*s == c)
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 03                	je     80093f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093c:	40                   	inc    %eax
  80093d:	eb f3                	jmp    800932 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 13                	je     800964 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 05                	jne    80095e <memset+0x1d>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	74 0d                	je     80096b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	fc                   	cld    
  800962:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800964:	89 f8                	mov    %edi,%eax
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80096b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096f:	89 d3                	mov    %edx,%ebx
  800971:	c1 e3 08             	shl    $0x8,%ebx
  800974:	89 d0                	mov    %edx,%eax
  800976:	c1 e0 18             	shl    $0x18,%eax
  800979:	89 d6                	mov    %edx,%esi
  80097b:	c1 e6 10             	shl    $0x10,%esi
  80097e:	09 f0                	or     %esi,%eax
  800980:	09 c2                	or     %eax,%edx
  800982:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800984:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800987:	89 d0                	mov    %edx,%eax
  800989:	fc                   	cld    
  80098a:	f3 ab                	rep stos %eax,%es:(%edi)
  80098c:	eb d6                	jmp    800964 <memset+0x23>

0080098e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 33                	jae    8009d3 <memmove+0x45>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	76 2c                	jbe    8009d3 <memmove+0x45>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	74 0a                	je     8009c0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b6:	4f                   	dec    %edi
  8009b7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bd:	fc                   	cld    
  8009be:	eb 21                	jmp    8009e1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	f6 c1 03             	test   $0x3,%cl
  8009c3:	75 f1                	jne    8009b6 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c5:	83 ef 04             	sub    $0x4,%edi
  8009c8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ce:	fd                   	std    
  8009cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d1:	eb ea                	jmp    8009bd <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	09 c2                	or     %eax,%edx
  8009d7:	f6 c2 03             	test   $0x3,%dl
  8009da:	74 09                	je     8009e5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 f2                	jne    8009dc <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ea:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f2:	eb ed                	jmp    8009e1 <memmove+0x53>

008009f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	ff 75 08             	pushl  0x8(%ebp)
  800a00:	e8 89 ff ff ff       	call   80098e <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a12:	89 c6                	mov    %eax,%esi
  800a14:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	39 f0                	cmp    %esi,%eax
  800a19:	74 16                	je     800a31 <memcmp+0x2a>
		if (*s1 != *s2)
  800a1b:	8a 08                	mov    (%eax),%cl
  800a1d:	8a 1a                	mov    (%edx),%bl
  800a1f:	38 d9                	cmp    %bl,%cl
  800a21:	75 04                	jne    800a27 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a23:	40                   	inc    %eax
  800a24:	42                   	inc    %edx
  800a25:	eb f0                	jmp    800a17 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a27:	0f b6 c1             	movzbl %cl,%eax
  800a2a:	0f b6 db             	movzbl %bl,%ebx
  800a2d:	29 d8                	sub    %ebx,%eax
  800a2f:	eb 05                	jmp    800a36 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	73 07                	jae    800a53 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	38 08                	cmp    %cl,(%eax)
  800a4e:	74 03                	je     800a53 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	40                   	inc    %eax
  800a51:	eb f5                	jmp    800a48 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	eb 01                	jmp    800a61 <strtol+0xc>
		s++;
  800a60:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	8a 01                	mov    (%ecx),%al
  800a63:	3c 20                	cmp    $0x20,%al
  800a65:	74 f9                	je     800a60 <strtol+0xb>
  800a67:	3c 09                	cmp    $0x9,%al
  800a69:	74 f5                	je     800a60 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6b:	3c 2b                	cmp    $0x2b,%al
  800a6d:	74 2b                	je     800a9a <strtol+0x45>
		s++;
	else if (*s == '-')
  800a6f:	3c 2d                	cmp    $0x2d,%al
  800a71:	74 2f                	je     800aa2 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a7f:	75 12                	jne    800a93 <strtol+0x3e>
  800a81:	80 39 30             	cmpb   $0x30,(%ecx)
  800a84:	74 24                	je     800aaa <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a8a:	75 07                	jne    800a93 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
  800a98:	eb 4e                	jmp    800ae8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a9a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa0:	eb d6                	jmp    800a78 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800aa2:	41                   	inc    %ecx
  800aa3:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa8:	eb ce                	jmp    800a78 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aaa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aae:	74 10                	je     800ac0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab4:	75 dd                	jne    800a93 <strtol+0x3e>
		s++, base = 8;
  800ab6:	41                   	inc    %ecx
  800ab7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800abe:	eb d3                	jmp    800a93 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ac0:	83 c1 02             	add    $0x2,%ecx
  800ac3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aca:	eb c7                	jmp    800a93 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800acc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 24                	ja     800afa <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800adc:	39 55 10             	cmp    %edx,0x10(%ebp)
  800adf:	7e 2b                	jle    800b0c <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ae1:	41                   	inc    %ecx
  800ae2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae8:	8a 11                	mov    (%ecx),%dl
  800aea:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	77 da                	ja     800acc <strtol+0x77>
			dig = *s - '0';
  800af2:	0f be d2             	movsbl %dl,%edx
  800af5:	83 ea 30             	sub    $0x30,%edx
  800af8:	eb e2                	jmp    800adc <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afd:	89 f3                	mov    %esi,%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 08                	ja     800b0c <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b04:	0f be d2             	movsbl %dl,%edx
  800b07:	83 ea 37             	sub    $0x37,%edx
  800b0a:	eb d0                	jmp    800adc <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b10:	74 05                	je     800b17 <strtol+0xc2>
		*endptr = (char *) s;
  800b12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b15:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b17:	85 ff                	test   %edi,%edi
  800b19:	74 02                	je     800b1d <strtol+0xc8>
  800b1b:	f7 d8                	neg    %eax
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    
	...

00800b24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	b8 03 00 00 00       	mov    $0x3,%eax
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7f 08                	jg     800b8b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 03                	push   $0x3
  800b91:	68 e4 12 80 00       	push   $0x8012e4
  800b96:	6a 23                	push   $0x23
  800b98:	68 01 13 80 00       	push   $0x801301
  800b9d:	e8 96 f5 ff ff       	call   800138 <_panic>

00800ba2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_yield>:

void
sys_yield(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	be 00 00 00 00       	mov    $0x0,%esi
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	89 f7                	mov    %esi,%edi
  800bfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7f 08                	jg     800c0c <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 04                	push   $0x4
  800c12:	68 e4 12 80 00       	push   $0x8012e4
  800c17:	6a 23                	push   $0x23
  800c19:	68 01 13 80 00       	push   $0x801301
  800c1e:	e8 15 f5 ff ff       	call   800138 <_panic>

00800c23 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	b8 05 00 00 00       	mov    $0x5,%eax
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7f 08                	jg     800c4e <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 05                	push   $0x5
  800c54:	68 e4 12 80 00       	push   $0x8012e4
  800c59:	6a 23                	push   $0x23
  800c5b:	68 01 13 80 00       	push   $0x801301
  800c60:	e8 d3 f4 ff ff       	call   800138 <_panic>

00800c65 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7f 08                	jg     800c90 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 06                	push   $0x6
  800c96:	68 e4 12 80 00       	push   $0x8012e4
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 01 13 80 00       	push   $0x801301
  800ca2:	e8 91 f4 ff ff       	call   800138 <_panic>

00800ca7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7f 08                	jg     800cd2 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 08                	push   $0x8
  800cd8:	68 e4 12 80 00       	push   $0x8012e4
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 01 13 80 00       	push   $0x801301
  800ce4:	e8 4f f4 ff ff       	call   800138 <_panic>

00800ce9 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 09 00 00 00       	mov    $0x9,%eax
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7f 08                	jg     800d14 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 09                	push   $0x9
  800d1a:	68 e4 12 80 00       	push   $0x8012e4
  800d1f:	6a 23                	push   $0x23
  800d21:	68 01 13 80 00       	push   $0x801301
  800d26:	e8 0d f4 ff ff       	call   800138 <_panic>

00800d2b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3c:	be 00 00 00 00       	mov    $0x0,%esi
  800d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7f 08                	jg     800d78 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0c                	push   $0xc
  800d7e:	68 e4 12 80 00       	push   $0x8012e4
  800d83:	6a 23                	push   $0x23
  800d85:	68 01 13 80 00       	push   $0x801301
  800d8a:	e8 a9 f3 ff ff       	call   800138 <_panic>
	...

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d9b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d9f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800da7:	85 d2                	test   %edx,%edx
  800da9:	75 2d                	jne    800dd8 <__udivdi3+0x48>
  800dab:	39 f7                	cmp    %esi,%edi
  800dad:	77 59                	ja     800e08 <__udivdi3+0x78>
  800daf:	89 f9                	mov    %edi,%ecx
  800db1:	85 ff                	test   %edi,%edi
  800db3:	75 0b                	jne    800dc0 <__udivdi3+0x30>
  800db5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dba:	31 d2                	xor    %edx,%edx
  800dbc:	f7 f7                	div    %edi
  800dbe:	89 c1                	mov    %eax,%ecx
  800dc0:	31 d2                	xor    %edx,%edx
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	f7 f1                	div    %ecx
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	89 e8                	mov    %ebp,%eax
  800dca:	f7 f1                	div    %ecx
  800dcc:	89 da                	mov    %ebx,%edx
  800dce:	83 c4 1c             	add    $0x1c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	39 f2                	cmp    %esi,%edx
  800dda:	77 1c                	ja     800df8 <__udivdi3+0x68>
  800ddc:	0f bd da             	bsr    %edx,%ebx
  800ddf:	83 f3 1f             	xor    $0x1f,%ebx
  800de2:	75 38                	jne    800e1c <__udivdi3+0x8c>
  800de4:	39 f2                	cmp    %esi,%edx
  800de6:	72 08                	jb     800df0 <__udivdi3+0x60>
  800de8:	39 ef                	cmp    %ebp,%edi
  800dea:	0f 87 98 00 00 00    	ja     800e88 <__udivdi3+0xf8>
  800df0:	b8 01 00 00 00       	mov    $0x1,%eax
  800df5:	eb 05                	jmp    800dfc <__udivdi3+0x6c>
  800df7:	90                   	nop
  800df8:	31 db                	xor    %ebx,%ebx
  800dfa:	31 c0                	xor    %eax,%eax
  800dfc:	89 da                	mov    %ebx,%edx
  800dfe:	83 c4 1c             	add    $0x1c,%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	89 e8                	mov    %ebp,%eax
  800e0a:	89 f2                	mov    %esi,%edx
  800e0c:	f7 f7                	div    %edi
  800e0e:	31 db                	xor    %ebx,%ebx
  800e10:	89 da                	mov    %ebx,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e21:	29 d8                	sub    %ebx,%eax
  800e23:	88 d9                	mov    %bl,%cl
  800e25:	d3 e2                	shl    %cl,%edx
  800e27:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e35:	09 d1                	or     %edx,%ecx
  800e37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e3b:	88 d9                	mov    %bl,%cl
  800e3d:	d3 e7                	shl    %cl,%edi
  800e3f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e43:	89 f7                	mov    %esi,%edi
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ef                	shr    %cl,%edi
  800e49:	88 d9                	mov    %bl,%cl
  800e4b:	d3 e6                	shl    %cl,%esi
  800e4d:	89 ea                	mov    %ebp,%edx
  800e4f:	88 c1                	mov    %al,%cl
  800e51:	d3 ea                	shr    %cl,%edx
  800e53:	09 d6                	or     %edx,%esi
  800e55:	89 f0                	mov    %esi,%eax
  800e57:	89 fa                	mov    %edi,%edx
  800e59:	f7 74 24 08          	divl   0x8(%esp)
  800e5d:	89 d7                	mov    %edx,%edi
  800e5f:	89 c6                	mov    %eax,%esi
  800e61:	f7 64 24 0c          	mull   0xc(%esp)
  800e65:	39 d7                	cmp    %edx,%edi
  800e67:	72 13                	jb     800e7c <__udivdi3+0xec>
  800e69:	74 09                	je     800e74 <__udivdi3+0xe4>
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	31 db                	xor    %ebx,%ebx
  800e6f:	eb 8b                	jmp    800dfc <__udivdi3+0x6c>
  800e71:	8d 76 00             	lea    0x0(%esi),%esi
  800e74:	88 d9                	mov    %bl,%cl
  800e76:	d3 e5                	shl    %cl,%ebp
  800e78:	39 c5                	cmp    %eax,%ebp
  800e7a:	73 ef                	jae    800e6b <__udivdi3+0xdb>
  800e7c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e7f:	31 db                	xor    %ebx,%ebx
  800e81:	e9 76 ff ff ff       	jmp    800dfc <__udivdi3+0x6c>
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	31 c0                	xor    %eax,%eax
  800e8a:	e9 6d ff ff ff       	jmp    800dfc <__udivdi3+0x6c>
	...

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e9b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e9f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	89 da                	mov    %ebx,%edx
  800eab:	85 ed                	test   %ebp,%ebp
  800ead:	75 15                	jne    800ec4 <__umoddi3+0x34>
  800eaf:	39 df                	cmp    %ebx,%edi
  800eb1:	76 39                	jbe    800eec <__umoddi3+0x5c>
  800eb3:	f7 f7                	div    %edi
  800eb5:	89 d0                	mov    %edx,%eax
  800eb7:	31 d2                	xor    %edx,%edx
  800eb9:	83 c4 1c             	add    $0x1c,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
  800ec1:	8d 76 00             	lea    0x0(%esi),%esi
  800ec4:	39 dd                	cmp    %ebx,%ebp
  800ec6:	77 f1                	ja     800eb9 <__umoddi3+0x29>
  800ec8:	0f bd cd             	bsr    %ebp,%ecx
  800ecb:	83 f1 1f             	xor    $0x1f,%ecx
  800ece:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ed2:	75 38                	jne    800f0c <__umoddi3+0x7c>
  800ed4:	39 dd                	cmp    %ebx,%ebp
  800ed6:	72 04                	jb     800edc <__umoddi3+0x4c>
  800ed8:	39 f7                	cmp    %esi,%edi
  800eda:	77 dd                	ja     800eb9 <__umoddi3+0x29>
  800edc:	89 da                	mov    %ebx,%edx
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	29 f8                	sub    %edi,%eax
  800ee2:	19 ea                	sbb    %ebp,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	89 f9                	mov    %edi,%ecx
  800eee:	85 ff                	test   %edi,%edi
  800ef0:	75 0b                	jne    800efd <__umoddi3+0x6d>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	31 d2                	xor    %edx,%edx
  800ef9:	f7 f7                	div    %edi
  800efb:	89 c1                	mov    %eax,%ecx
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	31 d2                	xor    %edx,%edx
  800f01:	f7 f1                	div    %ecx
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	f7 f1                	div    %ecx
  800f07:	eb ac                	jmp    800eb5 <__umoddi3+0x25>
  800f09:	8d 76 00             	lea    0x0(%esi),%esi
  800f0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f17:	29 c2                	sub    %eax,%edx
  800f19:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f1d:	88 c1                	mov    %al,%cl
  800f1f:	d3 e5                	shl    %cl,%ebp
  800f21:	89 f8                	mov    %edi,%eax
  800f23:	88 d1                	mov    %dl,%cl
  800f25:	d3 e8                	shr    %cl,%eax
  800f27:	09 c5                	or     %eax,%ebp
  800f29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f2d:	88 c1                	mov    %al,%cl
  800f2f:	d3 e7                	shl    %cl,%edi
  800f31:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f35:	89 df                	mov    %ebx,%edi
  800f37:	88 d1                	mov    %dl,%cl
  800f39:	d3 ef                	shr    %cl,%edi
  800f3b:	88 c1                	mov    %al,%cl
  800f3d:	d3 e3                	shl    %cl,%ebx
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	88 d1                	mov    %dl,%cl
  800f43:	d3 e8                	shr    %cl,%eax
  800f45:	09 d8                	or     %ebx,%eax
  800f47:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f4b:	d3 e6                	shl    %cl,%esi
  800f4d:	89 fa                	mov    %edi,%edx
  800f4f:	f7 f5                	div    %ebp
  800f51:	89 d1                	mov    %edx,%ecx
  800f53:	f7 64 24 08          	mull   0x8(%esp)
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	39 d1                	cmp    %edx,%ecx
  800f5d:	72 29                	jb     800f88 <__umoddi3+0xf8>
  800f5f:	74 23                	je     800f84 <__umoddi3+0xf4>
  800f61:	89 ca                	mov    %ecx,%edx
  800f63:	29 de                	sub    %ebx,%esi
  800f65:	19 fa                	sbb    %edi,%edx
  800f67:	89 d0                	mov    %edx,%eax
  800f69:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f6d:	d3 e0                	shl    %cl,%eax
  800f6f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f73:	88 d9                	mov    %bl,%cl
  800f75:	d3 ee                	shr    %cl,%esi
  800f77:	09 f0                	or     %esi,%eax
  800f79:	d3 ea                	shr    %cl,%edx
  800f7b:	83 c4 1c             	add    $0x1c,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	39 c6                	cmp    %eax,%esi
  800f86:	73 d9                	jae    800f61 <__umoddi3+0xd1>
  800f88:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f8c:	19 ea                	sbb    %ebp,%edx
  800f8e:	89 d7                	mov    %edx,%edi
  800f90:	89 c3                	mov    %eax,%ebx
  800f92:	eb cd                	jmp    800f61 <__umoddi3+0xd1>
