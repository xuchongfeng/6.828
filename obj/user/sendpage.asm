
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 6b 01 00 00       	call   80019c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 cd 0d 00 00       	call   800e0c <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 9c 00 00 00    	jne    8000e6 <umain+0xb2>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	83 ec 04             	sub    $0x4,%esp
  80004d:	6a 00                	push   $0x0
  80004f:	68 00 00 b0 00       	push   $0xb00000
  800054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800057:	50                   	push   %eax
  800058:	e8 df 0d 00 00       	call   800e3c <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005d:	83 c4 0c             	add    $0xc,%esp
  800060:	68 00 00 b0 00       	push   $0xb00000
  800065:	ff 75 f4             	pushl  -0xc(%ebp)
  800068:	68 00 11 80 00       	push   $0x801100
  80006d:	e8 1e 02 00 00       	call   800290 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800072:	83 c4 04             	add    $0x4,%esp
  800075:	ff 35 04 20 80 00    	pushl  0x802004
  80007b:	e8 e4 07 00 00       	call   800864 <strlen>
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	50                   	push   %eax
  800084:	ff 35 04 20 80 00    	pushl  0x802004
  80008a:	68 00 00 b0 00       	push   $0xb00000
  80008f:	e8 c1 08 00 00       	call   800955 <strncmp>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	74 39                	je     8000d4 <umain+0xa0>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	ff 35 00 20 80 00    	pushl  0x802000
  8000a4:	e8 bb 07 00 00       	call   800864 <strlen>
  8000a9:	83 c4 0c             	add    $0xc,%esp
  8000ac:	40                   	inc    %eax
  8000ad:	50                   	push   %eax
  8000ae:	ff 35 00 20 80 00    	pushl  0x802000
  8000b4:	68 00 00 b0 00       	push   $0xb00000
  8000b9:	e8 b2 09 00 00       	call   800a70 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000be:	6a 07                	push   $0x7
  8000c0:	68 00 00 b0 00       	push   $0xb00000
  8000c5:	6a 00                	push   $0x0
  8000c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8000ca:	e8 84 0d 00 00       	call   800e53 <ipc_send>
		return;
  8000cf:	83 c4 20             	add    $0x20,%esp
	ipc_recv(&who, TEMP_ADDR, 0);
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    
	if ((who = fork()) == 0) {
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
			cprintf("child received correct message\n");
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	68 14 11 80 00       	push   $0x801114
  8000dc:	e8 af 01 00 00       	call   800290 <cprintf>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	eb b5                	jmp    80009b <umain+0x67>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000eb:	8b 40 48             	mov    0x48(%eax),%eax
  8000ee:	83 ec 04             	sub    $0x4,%esp
  8000f1:	6a 07                	push   $0x7
  8000f3:	68 00 00 a0 00       	push   $0xa00000
  8000f8:	50                   	push   %eax
  8000f9:	e8 5e 0b 00 00       	call   800c5c <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000fe:	83 c4 04             	add    $0x4,%esp
  800101:	ff 35 04 20 80 00    	pushl  0x802004
  800107:	e8 58 07 00 00       	call   800864 <strlen>
  80010c:	83 c4 0c             	add    $0xc,%esp
  80010f:	40                   	inc    %eax
  800110:	50                   	push   %eax
  800111:	ff 35 04 20 80 00    	pushl  0x802004
  800117:	68 00 00 a0 00       	push   $0xa00000
  80011c:	e8 4f 09 00 00       	call   800a70 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800121:	6a 07                	push   $0x7
  800123:	68 00 00 a0 00       	push   $0xa00000
  800128:	6a 00                	push   $0x0
  80012a:	ff 75 f4             	pushl  -0xc(%ebp)
  80012d:	e8 21 0d 00 00       	call   800e53 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800132:	83 c4 1c             	add    $0x1c,%esp
  800135:	6a 00                	push   $0x0
  800137:	68 00 00 a0 00       	push   $0xa00000
  80013c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	e8 f7 0c 00 00       	call   800e3c <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800145:	83 c4 0c             	add    $0xc,%esp
  800148:	68 00 00 a0 00       	push   $0xa00000
  80014d:	ff 75 f4             	pushl  -0xc(%ebp)
  800150:	68 00 11 80 00       	push   $0x801100
  800155:	e8 36 01 00 00       	call   800290 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015a:	83 c4 04             	add    $0x4,%esp
  80015d:	ff 35 00 20 80 00    	pushl  0x802000
  800163:	e8 fc 06 00 00       	call   800864 <strlen>
  800168:	83 c4 0c             	add    $0xc,%esp
  80016b:	50                   	push   %eax
  80016c:	ff 35 00 20 80 00    	pushl  0x802000
  800172:	68 00 00 a0 00       	push   $0xa00000
  800177:	e8 d9 07 00 00       	call   800955 <strncmp>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	85 c0                	test   %eax,%eax
  800181:	0f 85 4b ff ff ff    	jne    8000d2 <umain+0x9e>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 11 80 00       	push   $0x801134
  80018f:	e8 fc 00 00 00       	call   800290 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
  800197:	e9 36 ff ff ff       	jmp    8000d2 <umain+0x9e>

0080019c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a7:	e8 72 0a 00 00       	call   800c1e <sys_getenvid>
  8001ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b1:	89 c2                	mov    %eax,%edx
  8001b3:	c1 e2 05             	shl    $0x5,%edx
  8001b6:	29 c2                	sub    %eax,%edx
  8001b8:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8001bf:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c4:	85 db                	test   %ebx,%ebx
  8001c6:	7e 07                	jle    8001cf <libmain+0x33>
		binaryname = argv[0];
  8001c8:	8b 06                	mov    (%esi),%eax
  8001ca:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	e8 5b fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001d9:	e8 0a 00 00 00       	call   8001e8 <exit>
}
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001ee:	6a 00                	push   $0x0
  8001f0:	e8 e8 09 00 00       	call   800bdd <sys_env_destroy>
}
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    
	...

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 13                	mov    (%ebx),%edx
  800208:	8d 42 01             	lea    0x1(%edx),%eax
  80020b:	89 03                	mov    %eax,(%ebx)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	74 08                	je     800223 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021b:	ff 43 04             	incl   0x4(%ebx)
}
  80021e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800221:	c9                   	leave  
  800222:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	68 ff 00 00 00       	push   $0xff
  80022b:	8d 43 08             	lea    0x8(%ebx),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 6c 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  800234:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	eb dc                	jmp    80021b <putch+0x1f>

0080023f <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800248:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024f:	00 00 00 
	b.cnt = 0;
  800252:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800259:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	68 fc 01 80 00       	push   $0x8001fc
  80026e:	e8 17 01 00 00       	call   80038a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 18 09 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 9d ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 1c             	sub    $0x1c,%esp
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cb:	39 d3                	cmp    %edx,%ebx
  8002cd:	72 05                	jb     8002d4 <printnum+0x30>
  8002cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d2:	77 78                	ja     80034c <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 fc 0b 00 00       	call   800ef4 <__udivdi3>
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	52                   	push   %edx
  8002fc:	50                   	push   %eax
  8002fd:	89 f2                	mov    %esi,%edx
  8002ff:	89 f8                	mov    %edi,%eax
  800301:	e8 9e ff ff ff       	call   8002a4 <printnum>
  800306:	83 c4 20             	add    $0x20,%esp
  800309:	eb 11                	jmp    80031c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	ff 75 18             	pushl  0x18(%ebp)
  800312:	ff d7                	call   *%edi
  800314:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800317:	4b                   	dec    %ebx
  800318:	85 db                	test   %ebx,%ebx
  80031a:	7f ef                	jg     80030b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	56                   	push   %esi
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	ff 75 e4             	pushl  -0x1c(%ebp)
  800326:	ff 75 e0             	pushl  -0x20(%ebp)
  800329:	ff 75 dc             	pushl  -0x24(%ebp)
  80032c:	ff 75 d8             	pushl  -0x28(%ebp)
  80032f:	e8 c0 0c 00 00       	call   800ff4 <__umoddi3>
  800334:	83 c4 14             	add    $0x14,%esp
  800337:	0f be 80 ac 11 80 00 	movsbl 0x8011ac(%eax),%eax
  80033e:	50                   	push   %eax
  80033f:	ff d7                	call   *%edi
}
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    
  80034c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034f:	eb c6                	jmp    800317 <printnum+0x73>

00800351 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800357:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	3b 50 04             	cmp    0x4(%eax),%edx
  80035f:	73 0a                	jae    80036b <sprintputch+0x1a>
		*b->buf++ = ch;
  800361:	8d 4a 01             	lea    0x1(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	88 02                	mov    %al,(%edx)
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800373:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800376:	50                   	push   %eax
  800377:	ff 75 10             	pushl  0x10(%ebp)
  80037a:	ff 75 0c             	pushl  0xc(%ebp)
  80037d:	ff 75 08             	pushl  0x8(%ebp)
  800380:	e8 05 00 00 00       	call   80038a <vprintfmt>
	va_end(ap);
}
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	c9                   	leave  
  800389:	c3                   	ret    

0080038a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	57                   	push   %edi
  80038e:	56                   	push   %esi
  80038f:	53                   	push   %ebx
  800390:	83 ec 2c             	sub    $0x2c,%esp
  800393:	8b 75 08             	mov    0x8(%ebp),%esi
  800396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800399:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039c:	e9 ac 03 00 00       	jmp    80074d <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8003a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8003ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8003b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8d 47 01             	lea    0x1(%edi),%eax
  8003c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c5:	8a 17                	mov    (%edi),%dl
  8003c7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ca:	3c 55                	cmp    $0x55,%al
  8003cc:	0f 87 fc 03 00 00    	ja     8007ce <vprintfmt+0x444>
  8003d2:	0f b6 c0             	movzbl %al,%eax
  8003d5:	ff 24 85 80 12 80 00 	jmp    *0x801280(,%eax,4)
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003e3:	eb da                	jmp    8003bf <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ec:	eb d1                	jmp    8003bf <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	0f b6 d2             	movzbl %dl,%edx
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ff:	01 c0                	add    %eax,%eax
  800401:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800405:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800408:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040b:	83 f9 09             	cmp    $0x9,%ecx
  80040e:	77 52                	ja     800462 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800410:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800411:	eb e9                	jmp    8003fc <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 40 04             	lea    0x4(%eax),%eax
  800421:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	79 92                	jns    8003bf <vprintfmt+0x35>
				width = precision, precision = -1;
  80042d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043a:	eb 83                	jmp    8003bf <vprintfmt+0x35>
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	78 08                	js     80044a <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800445:	e9 75 ff ff ff       	jmp    8003bf <vprintfmt+0x35>
  80044a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800451:	eb ef                	jmp    800442 <vprintfmt+0xb8>
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800456:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045d:	e9 5d ff ff ff       	jmp    8003bf <vprintfmt+0x35>
  800462:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800465:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800468:	eb bd                	jmp    800427 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046e:	e9 4c ff ff ff       	jmp    8003bf <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 78 04             	lea    0x4(%eax),%edi
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	ff 30                	pushl  (%eax)
  80047f:	ff d6                	call   *%esi
			break;
  800481:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800484:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800487:	e9 be 02 00 00       	jmp    80074a <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 78 04             	lea    0x4(%eax),%edi
  800492:	8b 00                	mov    (%eax),%eax
  800494:	85 c0                	test   %eax,%eax
  800496:	78 2a                	js     8004c2 <vprintfmt+0x138>
  800498:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 08             	cmp    $0x8,%eax
  80049d:	7f 27                	jg     8004c6 <vprintfmt+0x13c>
  80049f:	8b 04 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	74 1c                	je     8004c6 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004aa:	50                   	push   %eax
  8004ab:	68 cd 11 80 00       	push   $0x8011cd
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 b6 fe ff ff       	call   80036d <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004bd:	e9 88 02 00 00       	jmp    80074a <vprintfmt+0x3c0>
  8004c2:	f7 d8                	neg    %eax
  8004c4:	eb d2                	jmp    800498 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c6:	52                   	push   %edx
  8004c7:	68 c4 11 80 00       	push   $0x8011c4
  8004cc:	53                   	push   %ebx
  8004cd:	56                   	push   %esi
  8004ce:	e8 9a fe ff ff       	call   80036d <printfmt>
  8004d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d9:	e9 6c 02 00 00       	jmp    80074a <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	83 c0 04             	add    $0x4,%eax
  8004e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8b 38                	mov    (%eax),%edi
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	74 18                	je     800508 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  8004f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f4:	0f 8e b7 00 00 00    	jle    8005b1 <vprintfmt+0x227>
  8004fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fe:	75 0f                	jne    80050f <vprintfmt+0x185>
  800500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800503:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800506:	eb 75                	jmp    80057d <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800508:	bf bd 11 80 00       	mov    $0x8011bd,%edi
  80050d:	eb e1                	jmp    8004f0 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 d0             	pushl  -0x30(%ebp)
  800515:	57                   	push   %edi
  800516:	e8 5f 03 00 00       	call   80087a <strnlen>
  80051b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051e:	29 c1                	sub    %eax,%ecx
  800520:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800526:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800530:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800532:	eb 0d                	jmp    800541 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	ff 75 e0             	pushl  -0x20(%ebp)
  80053b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	4f                   	dec    %edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ef                	jg     800534 <vprintfmt+0x1aa>
  800545:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800548:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80054b:	89 c8                	mov    %ecx,%eax
  80054d:	85 c9                	test   %ecx,%ecx
  80054f:	78 10                	js     800561 <vprintfmt+0x1d7>
  800551:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800554:	29 c1                	sub    %eax,%ecx
  800556:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800559:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80055f:	eb 1c                	jmp    80057d <vprintfmt+0x1f3>
  800561:	b8 00 00 00 00       	mov    $0x0,%eax
  800566:	eb e9                	jmp    800551 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800568:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056c:	75 29                	jne    800597 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	50                   	push   %eax
  800575:	ff d6                	call   *%esi
  800577:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	ff 4d e0             	decl   -0x20(%ebp)
  80057d:	47                   	inc    %edi
  80057e:	8a 57 ff             	mov    -0x1(%edi),%dl
  800581:	0f be c2             	movsbl %dl,%eax
  800584:	85 c0                	test   %eax,%eax
  800586:	74 4c                	je     8005d4 <vprintfmt+0x24a>
  800588:	85 db                	test   %ebx,%ebx
  80058a:	78 dc                	js     800568 <vprintfmt+0x1de>
  80058c:	4b                   	dec    %ebx
  80058d:	79 d9                	jns    800568 <vprintfmt+0x1de>
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800595:	eb 2e                	jmp    8005c5 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800597:	0f be d2             	movsbl %dl,%edx
  80059a:	83 ea 20             	sub    $0x20,%edx
  80059d:	83 fa 5e             	cmp    $0x5e,%edx
  8005a0:	76 cc                	jbe    80056e <vprintfmt+0x1e4>
					putch('?', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	6a 3f                	push   $0x3f
  8005aa:	ff d6                	call   *%esi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	eb c9                	jmp    80057a <vprintfmt+0x1f0>
  8005b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b7:	eb c4                	jmp    80057d <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 20                	push   $0x20
  8005bf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c1:	4f                   	dec    %edi
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	7f f0                	jg     8005b9 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cf:	e9 76 01 00 00       	jmp    80074a <vprintfmt+0x3c0>
  8005d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005da:	eb e9                	jmp    8005c5 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dc:	83 f9 01             	cmp    $0x1,%ecx
  8005df:	7e 3f                	jle    800620 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 50 04             	mov    0x4(%eax),%edx
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 08             	lea    0x8(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fc:	79 5c                	jns    80065a <vprintfmt+0x2d0>
				putch('-', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 2d                	push   $0x2d
  800604:	ff d6                	call   *%esi
				num = -(long long) num;
  800606:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060c:	f7 da                	neg    %edx
  80060e:	83 d1 00             	adc    $0x0,%ecx
  800611:	f7 d9                	neg    %ecx
  800613:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	e9 10 01 00 00       	jmp    800730 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800620:	85 c9                	test   %ecx,%ecx
  800622:	75 1b                	jne    80063f <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 00                	mov    (%eax),%eax
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	89 c1                	mov    %eax,%ecx
  80062e:	c1 f9 1f             	sar    $0x1f,%ecx
  800631:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	eb b9                	jmp    8005f8 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 c1                	mov    %eax,%ecx
  800649:	c1 f9 1f             	sar    $0x1f,%ecx
  80064c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
  800658:	eb 9e                	jmp    8005f8 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	e9 c6 00 00 00       	jmp    800730 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 18                	jle    800687 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	e9 a9 00 00 00       	jmp    800730 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800687:	85 c9                	test   %ecx,%ecx
  800689:	75 1a                	jne    8006a5 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a0:	e9 8b 00 00 00       	jmp    800730 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ba:	eb 74                	jmp    800730 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7e 15                	jle    8006d6 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c9:	8d 40 08             	lea    0x8(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8006cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d4:	eb 5a                	jmp    800730 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006d6:	85 c9                	test   %ecx,%ecx
  8006d8:	75 17                	jne    8006f1 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  8006ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ef:	eb 3f                	jmp    800730 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800701:	b8 08 00 00 00       	mov    $0x8,%eax
  800706:	eb 28                	jmp    800730 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 30                	push   $0x30
  80070e:	ff d6                	call   *%esi
			putch('x', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 78                	push   $0x78
  800716:	ff d6                	call   *%esi
			num = (unsigned long long)
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800722:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800725:	8d 40 04             	lea    0x4(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072b:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800737:	57                   	push   %edi
  800738:	ff 75 e0             	pushl  -0x20(%ebp)
  80073b:	50                   	push   %eax
  80073c:	51                   	push   %ecx
  80073d:	52                   	push   %edx
  80073e:	89 da                	mov    %ebx,%edx
  800740:	89 f0                	mov    %esi,%eax
  800742:	e8 5d fb ff ff       	call   8002a4 <printnum>
			break;
  800747:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074d:	47                   	inc    %edi
  80074e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800752:	83 f8 25             	cmp    $0x25,%eax
  800755:	0f 84 46 fc ff ff    	je     8003a1 <vprintfmt+0x17>
			if (ch == '\0')
  80075b:	85 c0                	test   %eax,%eax
  80075d:	0f 84 89 00 00 00    	je     8007ec <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	50                   	push   %eax
  800768:	ff d6                	call   *%esi
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb de                	jmp    80074d <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7e 15                	jle    800789 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
  800787:	eb a7                	jmp    800730 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 17                	jne    8007a4 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80079d:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a2:	eb 8c                	jmp    800730 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b9:	e9 72 ff ff ff       	jmp    800730 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	6a 25                	push   $0x25
  8007c4:	ff d6                	call   *%esi
			break;
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	e9 7c ff ff ff       	jmp    80074a <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	6a 25                	push   $0x25
  8007d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	89 f8                	mov    %edi,%eax
  8007db:	eb 01                	jmp    8007de <vprintfmt+0x454>
  8007dd:	48                   	dec    %eax
  8007de:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e2:	75 f9                	jne    8007dd <vprintfmt+0x453>
  8007e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e7:	e9 5e ff ff ff       	jmp    80074a <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  8007ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5f                   	pop    %edi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	83 ec 18             	sub    $0x18,%esp
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800800:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800803:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800807:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800811:	85 c0                	test   %eax,%eax
  800813:	74 26                	je     80083b <vsnprintf+0x47>
  800815:	85 d2                	test   %edx,%edx
  800817:	7e 29                	jle    800842 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800819:	ff 75 14             	pushl  0x14(%ebp)
  80081c:	ff 75 10             	pushl  0x10(%ebp)
  80081f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800822:	50                   	push   %eax
  800823:	68 51 03 80 00       	push   $0x800351
  800828:	e8 5d fb ff ff       	call   80038a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800830:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800836:	83 c4 10             	add    $0x10,%esp
}
  800839:	c9                   	leave  
  80083a:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800840:	eb f7                	jmp    800839 <vsnprintf+0x45>
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800847:	eb f0                	jmp    800839 <vsnprintf+0x45>

00800849 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	50                   	push   %eax
  800853:	ff 75 10             	pushl  0x10(%ebp)
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 93 ff ff ff       	call   8007f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    
	...

00800864 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	eb 01                	jmp    800872 <strlen+0xe>
		n++;
  800871:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800876:	75 f9                	jne    800871 <strlen+0xd>
		n++;
	return n;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	eb 01                	jmp    80088b <strnlen+0x11>
		n++;
  80088a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1b>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f5                	jne    80088a <strnlen+0x10>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	41                   	inc    %ecx
  8008a4:	42                   	inc    %edx
  8008a5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 f4                	jne    8008a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b9:	53                   	push   %ebx
  8008ba:	e8 a5 ff ff ff       	call   800864 <strlen>
  8008bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c2:	ff 75 0c             	pushl  0xc(%ebp)
  8008c5:	01 d8                	add    %ebx,%eax
  8008c7:	50                   	push   %eax
  8008c8:	e8 ca ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008cd:	89 d8                	mov    %ebx,%eax
  8008cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008df:	89 f3                	mov    %esi,%ebx
  8008e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e4:	89 f2                	mov    %esi,%edx
  8008e6:	39 da                	cmp    %ebx,%edx
  8008e8:	74 0e                	je     8008f8 <strncpy+0x24>
		*dst++ = *src;
  8008ea:	42                   	inc    %edx
  8008eb:	8a 01                	mov    (%ecx),%al
  8008ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008f0:	80 39 00             	cmpb   $0x0,(%ecx)
  8008f3:	74 f1                	je     8008e6 <strncpy+0x12>
			src++;
  8008f5:	41                   	inc    %ecx
  8008f6:	eb ee                	jmp    8008e6 <strncpy+0x12>
	}
	return ret;
}
  8008f8:	89 f0                	mov    %esi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 75 08             	mov    0x8(%ebp),%esi
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090c:	85 c0                	test   %eax,%eax
  80090e:	74 20                	je     800930 <strlcpy+0x32>
  800910:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800914:	89 f0                	mov    %esi,%eax
  800916:	eb 05                	jmp    80091d <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800918:	42                   	inc    %edx
  800919:	40                   	inc    %eax
  80091a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 06                	je     800927 <strlcpy+0x29>
  800921:	8a 0a                	mov    (%edx),%cl
  800923:	84 c9                	test   %cl,%cl
  800925:	75 f1                	jne    800918 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800927:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092a:	29 f0                	sub    %esi,%eax
}
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    
  800930:	89 f0                	mov    %esi,%eax
  800932:	eb f6                	jmp    80092a <strlcpy+0x2c>

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 02                	jmp    800941 <strcmp+0xd>
		p++, q++;
  80093f:	41                   	inc    %ecx
  800940:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800941:	8a 01                	mov    (%ecx),%al
  800943:	84 c0                	test   %al,%al
  800945:	74 04                	je     80094b <strcmp+0x17>
  800947:	3a 02                	cmp    (%edx),%al
  800949:	74 f4                	je     80093f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 c0             	movzbl %al,%eax
  80094e:	0f b6 12             	movzbl (%edx),%edx
  800951:	29 d0                	sub    %edx,%eax
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	53                   	push   %ebx
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 c3                	mov    %eax,%ebx
  800961:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800964:	eb 02                	jmp    800968 <strncmp+0x13>
		n--, p++, q++;
  800966:	40                   	inc    %eax
  800967:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800968:	39 d8                	cmp    %ebx,%eax
  80096a:	74 15                	je     800981 <strncmp+0x2c>
  80096c:	8a 08                	mov    (%eax),%cl
  80096e:	84 c9                	test   %cl,%cl
  800970:	74 04                	je     800976 <strncmp+0x21>
  800972:	3a 0a                	cmp    (%edx),%cl
  800974:	74 f0                	je     800966 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 00             	movzbl (%eax),%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb f6                	jmp    80097e <strncmp+0x29>

00800988 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800991:	8a 10                	mov    (%eax),%dl
  800993:	84 d2                	test   %dl,%dl
  800995:	74 07                	je     80099e <strchr+0x16>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 08                	je     8009a3 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099b:	40                   	inc    %eax
  80099c:	eb f3                	jmp    800991 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ae:	8a 10                	mov    (%eax),%dl
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	74 07                	je     8009bb <strfind+0x16>
		if (*s == c)
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 03                	je     8009bb <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b8:	40                   	inc    %eax
  8009b9:	eb f3                	jmp    8009ae <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c9:	85 c9                	test   %ecx,%ecx
  8009cb:	74 13                	je     8009e0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d3:	75 05                	jne    8009da <memset+0x1d>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	74 0d                	je     8009e7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	fc                   	cld    
  8009de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e0:	89 f8                	mov    %edi,%eax
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  8009e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009eb:	89 d3                	mov    %edx,%ebx
  8009ed:	c1 e3 08             	shl    $0x8,%ebx
  8009f0:	89 d0                	mov    %edx,%eax
  8009f2:	c1 e0 18             	shl    $0x18,%eax
  8009f5:	89 d6                	mov    %edx,%esi
  8009f7:	c1 e6 10             	shl    $0x10,%esi
  8009fa:	09 f0                	or     %esi,%eax
  8009fc:	09 c2                	or     %eax,%edx
  8009fe:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a00:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	fc                   	cld    
  800a06:	f3 ab                	rep stos %eax,%es:(%edi)
  800a08:	eb d6                	jmp    8009e0 <memset+0x23>

00800a0a <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 33                	jae    800a4f <memmove+0x45>
  800a1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1f:	39 c2                	cmp    %eax,%edx
  800a21:	76 2c                	jbe    800a4f <memmove+0x45>
		s += n;
		d += n;
  800a23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	09 fe                	or     %edi,%esi
  800a2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a30:	74 0a                	je     800a3c <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a32:	4f                   	dec    %edi
  800a33:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a36:	fd                   	std    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a39:	fc                   	cld    
  800a3a:	eb 21                	jmp    800a5d <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 f1                	jne    800a32 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb ea                	jmp    800a39 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	74 09                	je     800a61 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	f6 c1 03             	test   $0x3,%cl
  800a64:	75 f2                	jne    800a58 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a66:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb ed                	jmp    800a5d <memmove+0x53>

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 89 ff ff ff       	call   800a0a <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	74 16                	je     800aad <memcmp+0x2a>
		if (*s1 != *s2)
  800a97:	8a 08                	mov    (%eax),%cl
  800a99:	8a 1a                	mov    (%edx),%bl
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	75 04                	jne    800aa3 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a9f:	40                   	inc    %eax
  800aa0:	42                   	inc    %edx
  800aa1:	eb f0                	jmp    800a93 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800aa3:	0f b6 c1             	movzbl %cl,%eax
  800aa6:	0f b6 db             	movzbl %bl,%ebx
  800aa9:	29 d8                	sub    %ebx,%eax
  800aab:	eb 05                	jmp    800ab2 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac4:	39 d0                	cmp    %edx,%eax
  800ac6:	73 07                	jae    800acf <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	38 08                	cmp    %cl,(%eax)
  800aca:	74 03                	je     800acf <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	40                   	inc    %eax
  800acd:	eb f5                	jmp    800ac4 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ada:	eb 01                	jmp    800add <strtol+0xc>
		s++;
  800adc:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800add:	8a 01                	mov    (%ecx),%al
  800adf:	3c 20                	cmp    $0x20,%al
  800ae1:	74 f9                	je     800adc <strtol+0xb>
  800ae3:	3c 09                	cmp    $0x9,%al
  800ae5:	74 f5                	je     800adc <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae7:	3c 2b                	cmp    $0x2b,%al
  800ae9:	74 2b                	je     800b16 <strtol+0x45>
		s++;
	else if (*s == '-')
  800aeb:	3c 2d                	cmp    $0x2d,%al
  800aed:	74 2f                	je     800b1e <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af4:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800afb:	75 12                	jne    800b0f <strtol+0x3e>
  800afd:	80 39 30             	cmpb   $0x30,(%ecx)
  800b00:	74 24                	je     800b26 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b06:	75 07                	jne    800b0f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 4e                	jmp    800b64 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800b16:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b17:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1c:	eb d6                	jmp    800af4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800b1e:	41                   	inc    %ecx
  800b1f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b24:	eb ce                	jmp    800af4 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2a:	74 10                	je     800b3c <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b30:	75 dd                	jne    800b0f <strtol+0x3e>
		s++, base = 8;
  800b32:	41                   	inc    %ecx
  800b33:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b3a:	eb d3                	jmp    800b0f <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800b3c:	83 c1 02             	add    $0x2,%ecx
  800b3f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b46:	eb c7                	jmp    800b0f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4b:	89 f3                	mov    %esi,%ebx
  800b4d:	80 fb 19             	cmp    $0x19,%bl
  800b50:	77 24                	ja     800b76 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b58:	39 55 10             	cmp    %edx,0x10(%ebp)
  800b5b:	7e 2b                	jle    800b88 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800b5d:	41                   	inc    %ecx
  800b5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b62:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b64:	8a 11                	mov    (%ecx),%dl
  800b66:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b69:	80 fb 09             	cmp    $0x9,%bl
  800b6c:	77 da                	ja     800b48 <strtol+0x77>
			dig = *s - '0';
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 30             	sub    $0x30,%edx
  800b74:	eb e2                	jmp    800b58 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 37             	sub    $0x37,%edx
  800b86:	eb d0                	jmp    800b58 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8c:	74 05                	je     800b93 <strtol+0xc2>
		*endptr = (char *) s;
  800b8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b91:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b93:	85 ff                	test   %edi,%edi
  800b95:	74 02                	je     800b99 <strtol+0xc8>
  800b97:	f7 d8                	neg    %eax
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    
	...

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7f 08                	jg     800c07 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 03                	push   $0x3
  800c0d:	68 04 14 80 00       	push   $0x801404
  800c12:	6a 23                	push   $0x23
  800c14:	68 21 14 80 00       	push   $0x801421
  800c19:	e8 8e 02 00 00       	call   800eac <_panic>

00800c1e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2e:	89 d1                	mov    %edx,%ecx
  800c30:	89 d3                	mov    %edx,%ebx
  800c32:	89 d7                	mov    %edx,%edi
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_yield>:

void
sys_yield(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	be 00 00 00 00       	mov    $0x0,%esi
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 04 00 00 00       	mov    $0x4,%eax
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	89 f7                	mov    %esi,%edi
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7f 08                	jg     800c88 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 04                	push   $0x4
  800c8e:	68 04 14 80 00       	push   $0x801404
  800c93:	6a 23                	push   $0x23
  800c95:	68 21 14 80 00       	push   $0x801421
  800c9a:	e8 0d 02 00 00       	call   800eac <_panic>

00800c9f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7f 08                	jg     800cca <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 05                	push   $0x5
  800cd0:	68 04 14 80 00       	push   $0x801404
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 21 14 80 00       	push   $0x801421
  800cdc:	e8 cb 01 00 00       	call   800eac <_panic>

00800ce1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfa:	89 df                	mov    %ebx,%edi
  800cfc:	89 de                	mov    %ebx,%esi
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7f 08                	jg     800d0c <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 06                	push   $0x6
  800d12:	68 04 14 80 00       	push   $0x801404
  800d17:	6a 23                	push   $0x23
  800d19:	68 21 14 80 00       	push   $0x801421
  800d1e:	e8 89 01 00 00       	call   800eac <_panic>

00800d23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3c:	89 df                	mov    %ebx,%edi
  800d3e:	89 de                	mov    %ebx,%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7f 08                	jg     800d4e <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 08                	push   $0x8
  800d54:	68 04 14 80 00       	push   $0x801404
  800d59:	6a 23                	push   $0x23
  800d5b:	68 21 14 80 00       	push   $0x801421
  800d60:	e8 47 01 00 00       	call   800eac <_panic>

00800d65 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7f 08                	jg     800d90 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 09                	push   $0x9
  800d96:	68 04 14 80 00       	push   $0x801404
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 21 14 80 00       	push   $0x801421
  800da2:	e8 05 01 00 00       	call   800eac <_panic>

00800da7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db8:	be 00 00 00 00       	mov    $0x0,%esi
  800dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de0:	89 cb                	mov    %ecx,%ebx
  800de2:	89 cf                	mov    %ecx,%edi
  800de4:	89 ce                	mov    %ecx,%esi
  800de6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de8:	85 c0                	test   %eax,%eax
  800dea:	7f 08                	jg     800df4 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	6a 0c                	push   $0xc
  800dfa:	68 04 14 80 00       	push   $0x801404
  800dff:	6a 23                	push   $0x23
  800e01:	68 21 14 80 00       	push   $0x801421
  800e06:	e8 a1 00 00 00       	call   800eac <_panic>
	...

00800e0c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e12:	68 3b 14 80 00       	push   $0x80143b
  800e17:	6a 51                	push   $0x51
  800e19:	68 2f 14 80 00       	push   $0x80142f
  800e1e:	e8 89 00 00 00       	call   800eac <_panic>

00800e23 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e29:	68 3a 14 80 00       	push   $0x80143a
  800e2e:	6a 58                	push   $0x58
  800e30:	68 2f 14 80 00       	push   $0x80142f
  800e35:	e8 72 00 00 00       	call   800eac <_panic>
	...

00800e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e42:	68 50 14 80 00       	push   $0x801450
  800e47:	6a 1a                	push   $0x1a
  800e49:	68 69 14 80 00       	push   $0x801469
  800e4e:	e8 59 00 00 00       	call   800eac <_panic>

00800e53 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e59:	68 73 14 80 00       	push   $0x801473
  800e5e:	6a 2a                	push   $0x2a
  800e60:	68 69 14 80 00       	push   $0x801469
  800e65:	e8 42 00 00 00       	call   800eac <_panic>

00800e6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	c1 e2 05             	shl    $0x5,%edx
  800e7a:	29 c2                	sub    %eax,%edx
  800e7c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800e83:	8b 52 50             	mov    0x50(%edx),%edx
  800e86:	39 ca                	cmp    %ecx,%edx
  800e88:	74 0f                	je     800e99 <ipc_find_env+0x2f>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e8a:	40                   	inc    %eax
  800e8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e90:	75 e3                	jne    800e75 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 11                	jmp    800eaa <ipc_find_env+0x40>
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 e2 05             	shl    $0x5,%edx
  800e9e:	29 c2                	sub    %eax,%edx
  800ea0:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800ea7:	8b 40 48             	mov    0x48(%eax),%eax
	return 0;
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800eb1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eb4:	8b 35 08 20 80 00    	mov    0x802008,%esi
  800eba:	e8 5f fd ff ff       	call   800c1e <sys_getenvid>
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	ff 75 0c             	pushl  0xc(%ebp)
  800ec5:	ff 75 08             	pushl  0x8(%ebp)
  800ec8:	56                   	push   %esi
  800ec9:	50                   	push   %eax
  800eca:	68 8c 14 80 00       	push   $0x80148c
  800ecf:	e8 bc f3 ff ff       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ed4:	83 c4 18             	add    $0x18,%esp
  800ed7:	53                   	push   %ebx
  800ed8:	ff 75 10             	pushl  0x10(%ebp)
  800edb:	e8 5f f3 ff ff       	call   80023f <vcprintf>
	cprintf("\n");
  800ee0:	c7 04 24 12 11 80 00 	movl   $0x801112,(%esp)
  800ee7:	e8 a4 f3 ff ff       	call   800290 <cprintf>
  800eec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eef:	cc                   	int3   
  800ef0:	eb fd                	jmp    800eef <_panic+0x43>
	...

00800ef4 <__udivdi3>:
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 1c             	sub    $0x1c,%esp
  800efb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	85 d2                	test   %edx,%edx
  800f0d:	75 2d                	jne    800f3c <__udivdi3+0x48>
  800f0f:	39 f7                	cmp    %esi,%edi
  800f11:	77 59                	ja     800f6c <__udivdi3+0x78>
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	85 ff                	test   %edi,%edi
  800f17:	75 0b                	jne    800f24 <__udivdi3+0x30>
  800f19:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1e:	31 d2                	xor    %edx,%edx
  800f20:	f7 f7                	div    %edi
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	31 d2                	xor    %edx,%edx
  800f26:	89 f0                	mov    %esi,%eax
  800f28:	f7 f1                	div    %ecx
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 e8                	mov    %ebp,%eax
  800f2e:	f7 f1                	div    %ecx
  800f30:	89 da                	mov    %ebx,%edx
  800f32:	83 c4 1c             	add    $0x1c,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	39 f2                	cmp    %esi,%edx
  800f3e:	77 1c                	ja     800f5c <__udivdi3+0x68>
  800f40:	0f bd da             	bsr    %edx,%ebx
  800f43:	83 f3 1f             	xor    $0x1f,%ebx
  800f46:	75 38                	jne    800f80 <__udivdi3+0x8c>
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	72 08                	jb     800f54 <__udivdi3+0x60>
  800f4c:	39 ef                	cmp    %ebp,%edi
  800f4e:	0f 87 98 00 00 00    	ja     800fec <__udivdi3+0xf8>
  800f54:	b8 01 00 00 00       	mov    $0x1,%eax
  800f59:	eb 05                	jmp    800f60 <__udivdi3+0x6c>
  800f5b:	90                   	nop
  800f5c:	31 db                	xor    %ebx,%ebx
  800f5e:	31 c0                	xor    %eax,%eax
  800f60:	89 da                	mov    %ebx,%edx
  800f62:	83 c4 1c             	add    $0x1c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	89 e8                	mov    %ebp,%eax
  800f6e:	89 f2                	mov    %esi,%edx
  800f70:	f7 f7                	div    %edi
  800f72:	31 db                	xor    %ebx,%ebx
  800f74:	89 da                	mov    %ebx,%edx
  800f76:	83 c4 1c             	add    $0x1c,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	b8 20 00 00 00       	mov    $0x20,%eax
  800f85:	29 d8                	sub    %ebx,%eax
  800f87:	88 d9                	mov    %bl,%cl
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	88 c1                	mov    %al,%cl
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f99:	09 d1                	or     %edx,%ecx
  800f9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9f:	88 d9                	mov    %bl,%cl
  800fa1:	d3 e7                	shl    %cl,%edi
  800fa3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fa7:	89 f7                	mov    %esi,%edi
  800fa9:	88 c1                	mov    %al,%cl
  800fab:	d3 ef                	shr    %cl,%edi
  800fad:	88 d9                	mov    %bl,%cl
  800faf:	d3 e6                	shl    %cl,%esi
  800fb1:	89 ea                	mov    %ebp,%edx
  800fb3:	88 c1                	mov    %al,%cl
  800fb5:	d3 ea                	shr    %cl,%edx
  800fb7:	09 d6                	or     %edx,%esi
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	89 fa                	mov    %edi,%edx
  800fbd:	f7 74 24 08          	divl   0x8(%esp)
  800fc1:	89 d7                	mov    %edx,%edi
  800fc3:	89 c6                	mov    %eax,%esi
  800fc5:	f7 64 24 0c          	mull   0xc(%esp)
  800fc9:	39 d7                	cmp    %edx,%edi
  800fcb:	72 13                	jb     800fe0 <__udivdi3+0xec>
  800fcd:	74 09                	je     800fd8 <__udivdi3+0xe4>
  800fcf:	89 f0                	mov    %esi,%eax
  800fd1:	31 db                	xor    %ebx,%ebx
  800fd3:	eb 8b                	jmp    800f60 <__udivdi3+0x6c>
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	88 d9                	mov    %bl,%cl
  800fda:	d3 e5                	shl    %cl,%ebp
  800fdc:	39 c5                	cmp    %eax,%ebp
  800fde:	73 ef                	jae    800fcf <__udivdi3+0xdb>
  800fe0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fe3:	31 db                	xor    %ebx,%ebx
  800fe5:	e9 76 ff ff ff       	jmp    800f60 <__udivdi3+0x6c>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	31 c0                	xor    %eax,%eax
  800fee:	e9 6d ff ff ff       	jmp    800f60 <__udivdi3+0x6c>
	...

00800ff4 <__umoddi3>:
  800ff4:	55                   	push   %ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 1c             	sub    $0x1c,%esp
  800ffb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801007:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	89 da                	mov    %ebx,%edx
  80100f:	85 ed                	test   %ebp,%ebp
  801011:	75 15                	jne    801028 <__umoddi3+0x34>
  801013:	39 df                	cmp    %ebx,%edi
  801015:	76 39                	jbe    801050 <__umoddi3+0x5c>
  801017:	f7 f7                	div    %edi
  801019:	89 d0                	mov    %edx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 1c             	add    $0x1c,%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	39 dd                	cmp    %ebx,%ebp
  80102a:	77 f1                	ja     80101d <__umoddi3+0x29>
  80102c:	0f bd cd             	bsr    %ebp,%ecx
  80102f:	83 f1 1f             	xor    $0x1f,%ecx
  801032:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801036:	75 38                	jne    801070 <__umoddi3+0x7c>
  801038:	39 dd                	cmp    %ebx,%ebp
  80103a:	72 04                	jb     801040 <__umoddi3+0x4c>
  80103c:	39 f7                	cmp    %esi,%edi
  80103e:	77 dd                	ja     80101d <__umoddi3+0x29>
  801040:	89 da                	mov    %ebx,%edx
  801042:	89 f0                	mov    %esi,%eax
  801044:	29 f8                	sub    %edi,%eax
  801046:	19 ea                	sbb    %ebp,%edx
  801048:	83 c4 1c             	add    $0x1c,%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    
  801050:	89 f9                	mov    %edi,%ecx
  801052:	85 ff                	test   %edi,%edi
  801054:	75 0b                	jne    801061 <__umoddi3+0x6d>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f7                	div    %edi
  80105f:	89 c1                	mov    %eax,%ecx
  801061:	89 d8                	mov    %ebx,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f1                	div    %ecx
  801067:	89 f0                	mov    %esi,%eax
  801069:	f7 f1                	div    %ecx
  80106b:	eb ac                	jmp    801019 <__umoddi3+0x25>
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	b8 20 00 00 00       	mov    $0x20,%eax
  801075:	89 c2                	mov    %eax,%edx
  801077:	8b 44 24 04          	mov    0x4(%esp),%eax
  80107b:	29 c2                	sub    %eax,%edx
  80107d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801081:	88 c1                	mov    %al,%cl
  801083:	d3 e5                	shl    %cl,%ebp
  801085:	89 f8                	mov    %edi,%eax
  801087:	88 d1                	mov    %dl,%cl
  801089:	d3 e8                	shr    %cl,%eax
  80108b:	09 c5                	or     %eax,%ebp
  80108d:	8b 44 24 04          	mov    0x4(%esp),%eax
  801091:	88 c1                	mov    %al,%cl
  801093:	d3 e7                	shl    %cl,%edi
  801095:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801099:	89 df                	mov    %ebx,%edi
  80109b:	88 d1                	mov    %dl,%cl
  80109d:	d3 ef                	shr    %cl,%edi
  80109f:	88 c1                	mov    %al,%cl
  8010a1:	d3 e3                	shl    %cl,%ebx
  8010a3:	89 f0                	mov    %esi,%eax
  8010a5:	88 d1                	mov    %dl,%cl
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	09 d8                	or     %ebx,%eax
  8010ab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010af:	d3 e6                	shl    %cl,%esi
  8010b1:	89 fa                	mov    %edi,%edx
  8010b3:	f7 f5                	div    %ebp
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	f7 64 24 08          	mull   0x8(%esp)
  8010bb:	89 c3                	mov    %eax,%ebx
  8010bd:	89 d7                	mov    %edx,%edi
  8010bf:	39 d1                	cmp    %edx,%ecx
  8010c1:	72 29                	jb     8010ec <__umoddi3+0xf8>
  8010c3:	74 23                	je     8010e8 <__umoddi3+0xf4>
  8010c5:	89 ca                	mov    %ecx,%edx
  8010c7:	29 de                	sub    %ebx,%esi
  8010c9:	19 fa                	sbb    %edi,%edx
  8010cb:	89 d0                	mov    %edx,%eax
  8010cd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8010d1:	d3 e0                	shl    %cl,%eax
  8010d3:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8010d7:	88 d9                	mov    %bl,%cl
  8010d9:	d3 ee                	shr    %cl,%esi
  8010db:	09 f0                	or     %esi,%eax
  8010dd:	d3 ea                	shr    %cl,%edx
  8010df:	83 c4 1c             	add    $0x1c,%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5f                   	pop    %edi
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    
  8010e7:	90                   	nop
  8010e8:	39 c6                	cmp    %eax,%esi
  8010ea:	73 d9                	jae    8010c5 <__umoddi3+0xd1>
  8010ec:	2b 44 24 08          	sub    0x8(%esp),%eax
  8010f0:	19 ea                	sbb    %ebp,%edx
  8010f2:	89 d7                	mov    %edx,%edi
  8010f4:	89 c3                	mov    %eax,%ebx
  8010f6:	eb cd                	jmp    8010c5 <__umoddi3+0xd1>
