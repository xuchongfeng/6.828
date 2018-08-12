
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 04             	sub    $0x4,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 23 0b 00 00       	call   800b66 <sys_getenvid>
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	53                   	push   %ebx
  800047:	50                   	push   %eax
  800048:	68 e0 0f 80 00       	push   $0x800fe0
  80004d:	e8 86 01 00 00       	call   8001d8 <cprintf>

	forkchild(cur, '0');
  800052:	83 c4 08             	add    $0x8,%esp
  800055:	6a 30                	push   $0x30
  800057:	53                   	push   %ebx
  800058:	e8 13 00 00 00       	call   800070 <forkchild>
	forkchild(cur, '1');
  80005d:	83 c4 08             	add    $0x8,%esp
  800060:	6a 31                	push   $0x31
  800062:	53                   	push   %ebx
  800063:	e8 08 00 00 00       	call   800070 <forkchild>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	83 ec 1c             	sub    $0x1c,%esp
  800078:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007b:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007e:	53                   	push   %ebx
  80007f:	e8 28 07 00 00       	call   8007ac <strlen>
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	83 f8 02             	cmp    $0x2,%eax
  80008a:	7e 07                	jle    800093 <forkchild+0x23>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
	if (fork() == 0) {
		forktree(nxt);
		exit();
	}
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	89 f0                	mov    %esi,%eax
  800098:	0f be f0             	movsbl %al,%esi
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	68 f1 0f 80 00       	push   $0x800ff1
  8000a2:	6a 04                	push   $0x4
  8000a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a7:	50                   	push   %eax
  8000a8:	e8 e4 06 00 00       	call   800791 <snprintf>
	if (fork() == 0) {
  8000ad:	83 c4 20             	add    $0x20,%esp
  8000b0:	e8 9f 0c 00 00       	call   800d54 <fork>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	75 d3                	jne    80008c <forkchild+0x1c>
		forktree(nxt);
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bf:	50                   	push   %eax
  8000c0:	e8 6f ff ff ff       	call   800034 <forktree>
		exit();
  8000c5:	e8 66 00 00 00       	call   800130 <exit>
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	eb bd                	jmp    80008c <forkchild+0x1c>

008000cf <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d5:	68 f0 0f 80 00       	push   $0x800ff0
  8000da:	e8 55 ff ff ff       	call   800034 <forktree>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ef:	e8 72 0a 00 00       	call   800b66 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	89 c2                	mov    %eax,%edx
  8000fb:	c1 e2 05             	shl    $0x5,%edx
  8000fe:	29 c2                	sub    %eax,%edx
  800100:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800107:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010c:	85 db                	test   %ebx,%ebx
  80010e:	7e 07                	jle    800117 <libmain+0x33>
		binaryname = argv[0];
  800110:	8b 06                	mov    (%esi),%eax
  800112:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	e8 ae ff ff ff       	call   8000cf <umain>

	// exit gracefully
	exit();
  800121:	e8 0a 00 00 00       	call   800130 <exit>
}
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800136:	6a 00                	push   $0x0
  800138:	e8 e8 09 00 00       	call   800b25 <sys_env_destroy>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	53                   	push   %ebx
  800148:	83 ec 04             	sub    $0x4,%esp
  80014b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014e:	8b 13                	mov    (%ebx),%edx
  800150:	8d 42 01             	lea    0x1(%edx),%eax
  800153:	89 03                	mov    %eax,(%ebx)
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800161:	74 08                	je     80016b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800163:	ff 43 04             	incl   0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	68 ff 00 00 00       	push   $0xff
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	50                   	push   %eax
  800177:	e8 6c 09 00 00       	call   800ae8 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	eb dc                	jmp    800163 <putch+0x1f>

00800187 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 44 01 80 00       	push   $0x800144
  8001b6:	e8 17 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 18 09 00 00       	call   800ae8 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800202:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800205:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800210:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800213:	39 d3                	cmp    %edx,%ebx
  800215:	72 05                	jb     80021c <printnum+0x30>
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 78                	ja     800294 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	8b 45 14             	mov    0x14(%ebp),%eax
  800225:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800228:	53                   	push   %ebx
  800229:	ff 75 10             	pushl  0x10(%ebp)
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 8c 0b 00 00       	call   800dcc <__udivdi3>
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	52                   	push   %edx
  800244:	50                   	push   %eax
  800245:	89 f2                	mov    %esi,%edx
  800247:	89 f8                	mov    %edi,%eax
  800249:	e8 9e ff ff ff       	call   8001ec <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 11                	jmp    800264 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f ef                	jg     800253 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	83 ec 04             	sub    $0x4,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 50 0c 00 00       	call   800ecc <__umoddi3>
  80027c:	83 c4 14             	add    $0x14,%esp
  80027f:	0f be 80 00 10 80 00 	movsbl 0x801000(%eax),%eax
  800286:	50                   	push   %eax
  800287:	ff d7                	call   *%edi
}
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    
  800294:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800297:	eb c6                	jmp    80025f <printnum+0x73>

00800299 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a7:	73 0a                	jae    8002b3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	88 02                	mov    %al,(%edx)
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002be:	50                   	push   %eax
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	e8 05 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
  8002db:	8b 75 08             	mov    0x8(%ebp),%esi
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e4:	e9 ac 03 00 00       	jmp    800695 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8002e9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8002ed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  8002f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  8002fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	8a 17                	mov    (%edi),%dl
  80030f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 fc 03 00 00    	ja     800716 <vprintfmt+0x444>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800327:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032b:	eb da                	jmp    800307 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800330:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800334:	eb d1                	jmp    800307 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	0f b6 d2             	movzbl %dl,%edx
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033c:	b8 00 00 00 00       	mov    $0x0,%eax
  800341:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800344:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800347:	01 c0                	add    %eax,%eax
  800349:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80034d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800350:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800353:	83 f9 09             	cmp    $0x9,%ecx
  800356:	77 52                	ja     8003aa <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800358:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800359:	eb e9                	jmp    800344 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	8d 40 04             	lea    0x4(%eax),%eax
  800369:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	79 92                	jns    800307 <vprintfmt+0x35>
				width = precision, precision = -1;
  800375:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800382:	eb 83                	jmp    800307 <vprintfmt+0x35>
  800384:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800388:	78 08                	js     800392 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038d:	e9 75 ff ff ff       	jmp    800307 <vprintfmt+0x35>
  800392:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800399:	eb ef                	jmp    80038a <vprintfmt+0xb8>
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a5:	e9 5d ff ff ff       	jmp    800307 <vprintfmt+0x35>
  8003aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b0:	eb bd                	jmp    80036f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b6:	e9 4c ff ff ff       	jmp    800307 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 78 04             	lea    0x4(%eax),%edi
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	53                   	push   %ebx
  8003c5:	ff 30                	pushl  (%eax)
  8003c7:	ff d6                	call   *%esi
			break;
  8003c9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cf:	e9 be 02 00 00       	jmp    800692 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 78 04             	lea    0x4(%eax),%edi
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	78 2a                	js     80040a <vprintfmt+0x138>
  8003e0:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e2:	83 f8 08             	cmp    $0x8,%eax
  8003e5:	7f 27                	jg     80040e <vprintfmt+0x13c>
  8003e7:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	74 1c                	je     80040e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003f2:	50                   	push   %eax
  8003f3:	68 21 10 80 00       	push   $0x801021
  8003f8:	53                   	push   %ebx
  8003f9:	56                   	push   %esi
  8003fa:	e8 b6 fe ff ff       	call   8002b5 <printfmt>
  8003ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800402:	89 7d 14             	mov    %edi,0x14(%ebp)
  800405:	e9 88 02 00 00       	jmp    800692 <vprintfmt+0x3c0>
  80040a:	f7 d8                	neg    %eax
  80040c:	eb d2                	jmp    8003e0 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040e:	52                   	push   %edx
  80040f:	68 18 10 80 00       	push   $0x801018
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 9a fe ff ff       	call   8002b5 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800421:	e9 6c 02 00 00       	jmp    800692 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	83 c0 04             	add    $0x4,%eax
  80042c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8b 38                	mov    (%eax),%edi
  800434:	85 ff                	test   %edi,%edi
  800436:	74 18                	je     800450 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e b7 00 00 00    	jle    8004f9 <vprintfmt+0x227>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	75 0f                	jne    800457 <vprintfmt+0x185>
  800448:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80044e:	eb 75                	jmp    8004c5 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800450:	bf 11 10 80 00       	mov    $0x801011,%edi
  800455:	eb e1                	jmp    800438 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d0             	pushl  -0x30(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 5f 03 00 00       	call   8007c2 <strnlen>
  800463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 0d                	jmp    800489 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	4f                   	dec    %edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ef                	jg     80047c <vprintfmt+0x1aa>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800493:	89 c8                	mov    %ecx,%eax
  800495:	85 c9                	test   %ecx,%ecx
  800497:	78 10                	js     8004a9 <vprintfmt+0x1d7>
  800499:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049c:	29 c1                	sub    %eax,%ecx
  80049e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004a7:	eb 1c                	jmp    8004c5 <vprintfmt+0x1f3>
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	eb e9                	jmp    800499 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b4:	75 29                	jne    8004df <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 0c             	pushl  0xc(%ebp)
  8004bc:	50                   	push   %eax
  8004bd:	ff d6                	call   *%esi
  8004bf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	ff 4d e0             	decl   -0x20(%ebp)
  8004c5:	47                   	inc    %edi
  8004c6:	8a 57 ff             	mov    -0x1(%edi),%dl
  8004c9:	0f be c2             	movsbl %dl,%eax
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	74 4c                	je     80051c <vprintfmt+0x24a>
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	78 dc                	js     8004b0 <vprintfmt+0x1de>
  8004d4:	4b                   	dec    %ebx
  8004d5:	79 d9                	jns    8004b0 <vprintfmt+0x1de>
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004dd:	eb 2e                	jmp    80050d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8004df:	0f be d2             	movsbl %dl,%edx
  8004e2:	83 ea 20             	sub    $0x20,%edx
  8004e5:	83 fa 5e             	cmp    $0x5e,%edx
  8004e8:	76 cc                	jbe    8004b6 <vprintfmt+0x1e4>
					putch('?', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff d6                	call   *%esi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	eb c9                	jmp    8004c2 <vprintfmt+0x1f0>
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ff:	eb c4                	jmp    8004c5 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	6a 20                	push   $0x20
  800507:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800509:	4f                   	dec    %edi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	85 ff                	test   %edi,%edi
  80050f:	7f f0                	jg     800501 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800511:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800514:	89 45 14             	mov    %eax,0x14(%ebp)
  800517:	e9 76 01 00 00       	jmp    800692 <vprintfmt+0x3c0>
  80051c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb e9                	jmp    80050d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800524:	83 f9 01             	cmp    $0x1,%ecx
  800527:	7e 3f                	jle    800568 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 50 04             	mov    0x4(%eax),%edx
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800534:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 40 08             	lea    0x8(%eax),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800540:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800544:	79 5c                	jns    8005a2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	53                   	push   %ebx
  80054a:	6a 2d                	push   $0x2d
  80054c:	ff d6                	call   *%esi
				num = -(long long) num;
  80054e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800554:	f7 da                	neg    %edx
  800556:	83 d1 00             	adc    $0x0,%ecx
  800559:	f7 d9                	neg    %ecx
  80055b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 10 01 00 00       	jmp    800678 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	75 1b                	jne    800587 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
  800585:	eb b9                	jmp    800540 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 c1                	mov    %eax,%ecx
  800591:	c1 f9 1f             	sar    $0x1f,%ecx
  800594:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb 9e                	jmp    800540 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ad:	e9 c6 00 00 00       	jmp    800678 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b2:	83 f9 01             	cmp    $0x1,%ecx
  8005b5:	7e 18                	jle    8005cf <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bf:	8d 40 08             	lea    0x8(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	e9 a9 00 00 00       	jmp    800678 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	75 1a                	jne    8005ed <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e8:	e9 8b 00 00 00       	jmp    800678 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800602:	eb 74                	jmp    800678 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7e 15                	jle    80061e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	8b 48 04             	mov    0x4(%eax),%ecx
  800611:	8d 40 08             	lea    0x8(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
  80061c:	eb 5a                	jmp    800678 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	75 17                	jne    800639 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
  800637:	eb 3f                	jmp    800678 <vprintfmt+0x3a6>
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

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800649:	b8 08 00 00 00       	mov    $0x8,%eax
  80064e:	eb 28                	jmp    800678 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 30                	push   $0x30
  800656:	ff d6                	call   *%esi
			putch('x', putdat);
  800658:	83 c4 08             	add    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 78                	push   $0x78
  80065e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800673:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800678:	83 ec 0c             	sub    $0xc,%esp
  80067b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067f:	57                   	push   %edi
  800680:	ff 75 e0             	pushl  -0x20(%ebp)
  800683:	50                   	push   %eax
  800684:	51                   	push   %ecx
  800685:	52                   	push   %edx
  800686:	89 da                	mov    %ebx,%edx
  800688:	89 f0                	mov    %esi,%eax
  80068a:	e8 5d fb ff ff       	call   8001ec <printnum>
			break;
  80068f:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800695:	47                   	inc    %edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	83 f8 25             	cmp    $0x25,%eax
  80069d:	0f 84 46 fc ff ff    	je     8002e9 <vprintfmt+0x17>
			if (ch == '\0')
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	0f 84 89 00 00 00    	je     800734 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	50                   	push   %eax
  8006b0:	ff d6                	call   *%esi
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb de                	jmp    800695 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b7:	83 f9 01             	cmp    $0x1,%ecx
  8006ba:	7e 15                	jle    8006d1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c4:	8d 40 08             	lea    0x8(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cf:	eb a7                	jmp    800678 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006d1:	85 c9                	test   %ecx,%ecx
  8006d3:	75 17                	jne    8006ec <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ea:	eb 8c                	jmp    800678 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8b 10                	mov    (%eax),%edx
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	8d 40 04             	lea    0x4(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
  800701:	e9 72 ff ff ff       	jmp    800678 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	6a 25                	push   $0x25
  80070c:	ff d6                	call   *%esi
			break;
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	e9 7c ff ff ff       	jmp    800692 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 25                	push   $0x25
  80071c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	89 f8                	mov    %edi,%eax
  800723:	eb 01                	jmp    800726 <vprintfmt+0x454>
  800725:	48                   	dec    %eax
  800726:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072a:	75 f9                	jne    800725 <vprintfmt+0x453>
  80072c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072f:	e9 5e ff ff ff       	jmp    800692 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 18             	sub    $0x18,%esp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800752:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 26                	je     800783 <vsnprintf+0x47>
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e 29                	jle    80078a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800761:	ff 75 14             	pushl  0x14(%ebp)
  800764:	ff 75 10             	pushl  0x10(%ebp)
  800767:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	68 99 02 80 00       	push   $0x800299
  800770:	e8 5d fb ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	83 c4 10             	add    $0x10,%esp
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb f7                	jmp    800781 <vsnprintf+0x45>
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078f:	eb f0                	jmp    800781 <vsnprintf+0x45>

00800791 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	50                   	push   %eax
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	ff 75 08             	pushl  0x8(%ebp)
  8007a4:	e8 93 ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    
	...

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	eb 01                	jmp    8007ba <strlen+0xe>
		n++;
  8007b9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007be:	75 f9                	jne    8007b9 <strlen+0xd>
		n++;
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	eb 01                	jmp    8007d3 <strnlen+0x11>
		n++;
  8007d2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	39 d0                	cmp    %edx,%eax
  8007d5:	74 06                	je     8007dd <strnlen+0x1b>
  8007d7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007db:	75 f5                	jne    8007d2 <strnlen+0x10>
		n++;
	return n;
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e9:	89 c2                	mov    %eax,%edx
  8007eb:	41                   	inc    %ecx
  8007ec:	42                   	inc    %edx
  8007ed:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	75 f4                	jne    8007eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800801:	53                   	push   %ebx
  800802:	e8 a5 ff ff ff       	call   8007ac <strlen>
  800807:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	01 d8                	add    %ebx,%eax
  80080f:	50                   	push   %eax
  800810:	e8 ca ff ff ff       	call   8007df <strcpy>
	return dst;
}
  800815:	89 d8                	mov    %ebx,%eax
  800817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	89 f3                	mov    %esi,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	89 f2                	mov    %esi,%edx
  80082e:	39 da                	cmp    %ebx,%edx
  800830:	74 0e                	je     800840 <strncpy+0x24>
		*dst++ = *src;
  800832:	42                   	inc    %edx
  800833:	8a 01                	mov    (%ecx),%al
  800835:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800838:	80 39 00             	cmpb   $0x0,(%ecx)
  80083b:	74 f1                	je     80082e <strncpy+0x12>
			src++;
  80083d:	41                   	inc    %ecx
  80083e:	eb ee                	jmp    80082e <strncpy+0x12>
	}
	return ret;
}
  800840:	89 f0                	mov    %esi,%eax
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800854:	85 c0                	test   %eax,%eax
  800856:	74 20                	je     800878 <strlcpy+0x32>
  800858:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	eb 05                	jmp    800865 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800860:	42                   	inc    %edx
  800861:	40                   	inc    %eax
  800862:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800865:	39 d8                	cmp    %ebx,%eax
  800867:	74 06                	je     80086f <strlcpy+0x29>
  800869:	8a 0a                	mov    (%edx),%cl
  80086b:	84 c9                	test   %cl,%cl
  80086d:	75 f1                	jne    800860 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80086f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800872:	29 f0                	sub    %esi,%eax
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    
  800878:	89 f0                	mov    %esi,%eax
  80087a:	eb f6                	jmp    800872 <strlcpy+0x2c>

0080087c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800885:	eb 02                	jmp    800889 <strcmp+0xd>
		p++, q++;
  800887:	41                   	inc    %ecx
  800888:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800889:	8a 01                	mov    (%ecx),%al
  80088b:	84 c0                	test   %al,%al
  80088d:	74 04                	je     800893 <strcmp+0x17>
  80088f:	3a 02                	cmp    (%edx),%al
  800891:	74 f4                	je     800887 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 c0             	movzbl %al,%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	53                   	push   %ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 c3                	mov    %eax,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ac:	eb 02                	jmp    8008b0 <strncmp+0x13>
		n--, p++, q++;
  8008ae:	40                   	inc    %eax
  8008af:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b0:	39 d8                	cmp    %ebx,%eax
  8008b2:	74 15                	je     8008c9 <strncmp+0x2c>
  8008b4:	8a 08                	mov    (%eax),%cl
  8008b6:	84 c9                	test   %cl,%cl
  8008b8:	74 04                	je     8008be <strncmp+0x21>
  8008ba:	3a 0a                	cmp    (%edx),%cl
  8008bc:	74 f0                	je     8008ae <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 00             	movzbl (%eax),%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	eb f6                	jmp    8008c6 <strncmp+0x29>

008008d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d9:	8a 10                	mov    (%eax),%dl
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	74 07                	je     8008e6 <strchr+0x16>
		if (*s == c)
  8008df:	38 ca                	cmp    %cl,%dl
  8008e1:	74 08                	je     8008eb <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e3:	40                   	inc    %eax
  8008e4:	eb f3                	jmp    8008d9 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f6:	8a 10                	mov    (%eax),%dl
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	74 07                	je     800903 <strfind+0x16>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 03                	je     800903 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800900:	40                   	inc    %eax
  800901:	eb f3                	jmp    8008f6 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 13                	je     800928 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 05                	jne    800922 <memset+0x1d>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	74 0d                	je     80092f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	fc                   	cld    
  800926:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800928:	89 f8                	mov    %edi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80092f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800933:	89 d3                	mov    %edx,%ebx
  800935:	c1 e3 08             	shl    $0x8,%ebx
  800938:	89 d0                	mov    %edx,%eax
  80093a:	c1 e0 18             	shl    $0x18,%eax
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 10             	shl    $0x10,%esi
  800942:	09 f0                	or     %esi,%eax
  800944:	09 c2                	or     %eax,%edx
  800946:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800948:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	fc                   	cld    
  80094e:	f3 ab                	rep stos %eax,%es:(%edi)
  800950:	eb d6                	jmp    800928 <memset+0x23>

00800952 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 33                	jae    800997 <memmove+0x45>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 c2                	cmp    %eax,%edx
  800969:	76 2c                	jbe    800997 <memmove+0x45>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 d6                	mov    %edx,%esi
  800970:	09 fe                	or     %edi,%esi
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	74 0a                	je     800984 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097a:	4f                   	dec    %edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 21                	jmp    8009a5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 f1                	jne    80097a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800989:	83 ef 04             	sub    $0x4,%edi
  80098c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800992:	fd                   	std    
  800993:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800995:	eb ea                	jmp    800981 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 f2                	mov    %esi,%edx
  800999:	09 c2                	or     %eax,%edx
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	74 09                	je     8009a9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 f2                	jne    8009a0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb ed                	jmp    8009a5 <memmove+0x53>

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bb:	ff 75 10             	pushl  0x10(%ebp)
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 89 ff ff ff       	call   800952 <memmove>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 f0                	cmp    %esi,%eax
  8009dd:	74 16                	je     8009f5 <memcmp+0x2a>
		if (*s1 != *s2)
  8009df:	8a 08                	mov    (%eax),%cl
  8009e1:	8a 1a                	mov    (%edx),%bl
  8009e3:	38 d9                	cmp    %bl,%cl
  8009e5:	75 04                	jne    8009eb <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e7:	40                   	inc    %eax
  8009e8:	42                   	inc    %edx
  8009e9:	eb f0                	jmp    8009db <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  8009eb:	0f b6 c1             	movzbl %cl,%eax
  8009ee:	0f b6 db             	movzbl %bl,%ebx
  8009f1:	29 d8                	sub    %ebx,%eax
  8009f3:	eb 05                	jmp    8009fa <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0c:	39 d0                	cmp    %edx,%eax
  800a0e:	73 07                	jae    800a17 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	38 08                	cmp    %cl,(%eax)
  800a12:	74 03                	je     800a17 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	40                   	inc    %eax
  800a15:	eb f5                	jmp    800a0c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a22:	eb 01                	jmp    800a25 <strtol+0xc>
		s++;
  800a24:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	8a 01                	mov    (%ecx),%al
  800a27:	3c 20                	cmp    $0x20,%al
  800a29:	74 f9                	je     800a24 <strtol+0xb>
  800a2b:	3c 09                	cmp    $0x9,%al
  800a2d:	74 f5                	je     800a24 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2f:	3c 2b                	cmp    $0x2b,%al
  800a31:	74 2b                	je     800a5e <strtol+0x45>
		s++;
	else if (*s == '-')
  800a33:	3c 2d                	cmp    $0x2d,%al
  800a35:	74 2f                	je     800a66 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a43:	75 12                	jne    800a57 <strtol+0x3e>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 24                	je     800a6e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4e:	75 07                	jne    800a57 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a50:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	eb 4e                	jmp    800aac <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a5e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb d6                	jmp    800a3c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800a66:	41                   	inc    %ecx
  800a67:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6c:	eb ce                	jmp    800a3c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	74 10                	je     800a84 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a78:	75 dd                	jne    800a57 <strtol+0x3e>
		s++, base = 8;
  800a7a:	41                   	inc    %ecx
  800a7b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a82:	eb d3                	jmp    800a57 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800a84:	83 c1 02             	add    $0x2,%ecx
  800a87:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a8e:	eb c7                	jmp    800a57 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 24                	ja     800abe <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a9a:	0f be d2             	movsbl %dl,%edx
  800a9d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800aa3:	7e 2b                	jle    800ad0 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800aa5:	41                   	inc    %ecx
  800aa6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaa:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aac:	8a 11                	mov    (%ecx),%dl
  800aae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	77 da                	ja     800a90 <strtol+0x77>
			dig = *s - '0';
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 30             	sub    $0x30,%edx
  800abc:	eb e2                	jmp    800aa0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 37             	sub    $0x37,%edx
  800ace:	eb d0                	jmp    800aa0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad4:	74 05                	je     800adb <strtol+0xc2>
		*endptr = (char *) s;
  800ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800adb:	85 ff                	test   %edi,%edi
  800add:	74 02                	je     800ae1 <strtol+0xc8>
  800adf:	f7 d8                	neg    %eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    
	...

00800ae8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	89 c6                	mov    %eax,%esi
  800aff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3b:	89 cb                	mov    %ecx,%ebx
  800b3d:	89 cf                	mov    %ecx,%edi
  800b3f:	89 ce                	mov    %ecx,%esi
  800b41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7f 08                	jg     800b4f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 03                	push   $0x3
  800b55:	68 44 12 80 00       	push   $0x801244
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 61 12 80 00       	push   $0x801261
  800b61:	e8 1e 02 00 00       	call   800d84 <_panic>

00800b66 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 02 00 00 00       	mov    $0x2,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_yield>:

void
sys_yield(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	be 00 00 00 00       	mov    $0x0,%esi
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	89 f7                	mov    %esi,%edi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7f 08                	jg     800bd0 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 04                	push   $0x4
  800bd6:	68 44 12 80 00       	push   $0x801244
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 61 12 80 00       	push   $0x801261
  800be2:	e8 9d 01 00 00       	call   800d84 <_panic>

00800be7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 75 18             	mov    0x18(%ebp),%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7f 08                	jg     800c12 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 05                	push   $0x5
  800c18:	68 44 12 80 00       	push   $0x801244
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 61 12 80 00       	push   $0x801261
  800c24:	e8 5b 01 00 00       	call   800d84 <_panic>

00800c29 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7f 08                	jg     800c54 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 06                	push   $0x6
  800c5a:	68 44 12 80 00       	push   $0x801244
  800c5f:	6a 23                	push   $0x23
  800c61:	68 61 12 80 00       	push   $0x801261
  800c66:	e8 19 01 00 00       	call   800d84 <_panic>

00800c6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7f 08                	jg     800c96 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 08                	push   $0x8
  800c9c:	68 44 12 80 00       	push   $0x801244
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 61 12 80 00       	push   $0x801261
  800ca8:	e8 d7 00 00 00       	call   800d84 <_panic>

00800cad <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7f 08                	jg     800cd8 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 09                	push   $0x9
  800cde:	68 44 12 80 00       	push   $0x801244
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 61 12 80 00       	push   $0x801261
  800cea:	e8 95 00 00 00       	call   800d84 <_panic>

00800cef <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d00:	be 00 00 00 00       	mov    $0x0,%esi
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	89 cb                	mov    %ecx,%ebx
  800d2a:	89 cf                	mov    %ecx,%edi
  800d2c:	89 ce                	mov    %ecx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 0c                	push   $0xc
  800d42:	68 44 12 80 00       	push   $0x801244
  800d47:	6a 23                	push   $0x23
  800d49:	68 61 12 80 00       	push   $0x801261
  800d4e:	e8 31 00 00 00       	call   800d84 <_panic>
	...

00800d54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d5a:	68 7b 12 80 00       	push   $0x80127b
  800d5f:	6a 51                	push   $0x51
  800d61:	68 6f 12 80 00       	push   $0x80126f
  800d66:	e8 19 00 00 00       	call   800d84 <_panic>

00800d6b <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d71:	68 7a 12 80 00       	push   $0x80127a
  800d76:	6a 58                	push   $0x58
  800d78:	68 6f 12 80 00       	push   $0x80126f
  800d7d:	e8 02 00 00 00       	call   800d84 <_panic>
	...

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
  800d92:	e8 cf fd ff ff       	call   800b66 <sys_getenvid>
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	ff 75 0c             	pushl  0xc(%ebp)
  800d9d:	ff 75 08             	pushl  0x8(%ebp)
  800da0:	56                   	push   %esi
  800da1:	50                   	push   %eax
  800da2:	68 90 12 80 00       	push   $0x801290
  800da7:	e8 2c f4 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dac:	83 c4 18             	add    $0x18,%esp
  800daf:	53                   	push   %ebx
  800db0:	ff 75 10             	pushl  0x10(%ebp)
  800db3:	e8 cf f3 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  800db8:	c7 04 24 ef 0f 80 00 	movl   $0x800fef,(%esp)
  800dbf:	e8 14 f4 ff ff       	call   8001d8 <cprintf>
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
