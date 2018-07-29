
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800044:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800047:	e8 ce 00 00 00       	call   80011a <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800054:	01 d0                	add    %edx,%eax
  800056:	c1 e0 05             	shl    $0x5,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x32>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bc ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800078:	e8 0b 00 00 00       	call   800088 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 44 00 00 00       	call   8000d9 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7f 08                	jg     800103 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	6a 03                	push   $0x3
  800109:	68 36 0d 80 00       	push   $0x800d36
  80010e:	6a 23                	push   $0x23
  800110:	68 53 0d 80 00       	push   $0x800d53
  800115:	e8 22 00 00 00       	call   80013c <_panic>

0080011a <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 02 00 00 00       	mov    $0x2,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    
  800139:	00 00                	add    %al,(%eax)
	...

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80014a:	e8 cb ff ff ff       	call   80011a <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 64 0d 80 00       	push   $0x800d64
  80015f:	e8 b4 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 57 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 88 0d 80 00 	movl   $0x800d88,(%esp)
  800177:	e8 9c 00 00 00       	call   800218 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>
	...

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 13                	mov    (%ebx),%edx
  800190:	8d 42 01             	lea    0x1(%edx),%eax
  800193:	89 03                	mov    %eax,(%ebx)
  800195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a1:	74 08                	je     8001ab <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a3:	ff 43 04             	incl   0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 e0 fe ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	eb dc                	jmp    8001a3 <putch+0x1f>

008001c7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 84 01 80 00       	push   $0x800184
  8001f6:	e8 17 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 8c fe ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 1c             	sub    $0x1c,%esp
  800235:	89 c7                	mov    %eax,%edi
  800237:	89 d6                	mov    %edx,%esi
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800242:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800245:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800250:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800253:	39 d3                	cmp    %edx,%ebx
  800255:	72 05                	jb     80025c <printnum+0x30>
  800257:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025a:	77 78                	ja     8002d4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	8b 45 14             	mov    0x14(%ebp),%eax
  800265:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800268:	53                   	push   %ebx
  800269:	ff 75 10             	pushl  0x10(%ebp)
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 a8 08 00 00       	call   800b28 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 9e ff ff ff       	call   80022c <printnum>
  80028e:	83 c4 20             	add    $0x20,%esp
  800291:	eb 11                	jmp    8002a4 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	ff 75 18             	pushl  0x18(%ebp)
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	4b                   	dec    %ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ef                	jg     800293 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	83 ec 04             	sub    $0x4,%esp
  8002ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b7:	e8 6c 09 00 00       	call   800c28 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 8a 0d 80 00 	movsbl 0x800d8a(%eax),%eax
  8002c6:	50                   	push   %eax
  8002c7:	ff d7                	call   *%edi
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    
  8002d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d7:	eb c6                	jmp    80029f <printnum+0x73>

008002d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002df:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e7:	73 0a                	jae    8002f3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002e9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	88 02                	mov    %al,(%edx)
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fe:	50                   	push   %eax
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	e8 05 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 2c             	sub    $0x2c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	e9 ac 03 00 00       	jmp    8006d5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800329:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80032d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800334:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80033b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800342:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	8a 17                	mov    (%edi),%dl
  80034f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800352:	3c 55                	cmp    $0x55,%al
  800354:	0f 87 fc 03 00 00    	ja     800756 <vprintfmt+0x444>
  80035a:	0f b6 c0             	movzbl %al,%eax
  80035d:	ff 24 85 18 0e 80 00 	jmp    *0x800e18(,%eax,4)
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036b:	eb da                	jmp    800347 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800370:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800374:	eb d1                	jmp    800347 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	0f b6 d2             	movzbl %dl,%edx
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	b8 00 00 00 00       	mov    $0x0,%eax
  800381:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800384:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800387:	01 c0                	add    %eax,%eax
  800389:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80038d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800390:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800393:	83 f9 09             	cmp    $0x9,%ecx
  800396:	77 52                	ja     8003ea <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800398:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800399:	eb e9                	jmp    800384 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 40 04             	lea    0x4(%eax),%eax
  8003a9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b3:	79 92                	jns    800347 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c2:	eb 83                	jmp    800347 <vprintfmt+0x35>
  8003c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c8:	78 08                	js     8003d2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cd:	e9 75 ff ff ff       	jmp    800347 <vprintfmt+0x35>
  8003d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d9:	eb ef                	jmp    8003ca <vprintfmt+0xb8>
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e5:	e9 5d ff ff ff       	jmp    800347 <vprintfmt+0x35>
  8003ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f0:	eb bd                	jmp    8003af <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f6:	e9 4c ff ff ff       	jmp    800347 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 78 04             	lea    0x4(%eax),%edi
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	53                   	push   %ebx
  800405:	ff 30                	pushl  (%eax)
  800407:	ff d6                	call   *%esi
			break;
  800409:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040f:	e9 be 02 00 00       	jmp    8006d2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 78 04             	lea    0x4(%eax),%edi
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	85 c0                	test   %eax,%eax
  80041e:	78 2a                	js     80044a <vprintfmt+0x138>
  800420:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 06             	cmp    $0x6,%eax
  800425:	7f 27                	jg     80044e <vprintfmt+0x13c>
  800427:	8b 04 85 70 0f 80 00 	mov    0x800f70(,%eax,4),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	74 1c                	je     80044e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800432:	50                   	push   %eax
  800433:	68 ab 0d 80 00       	push   $0x800dab
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 b6 fe ff ff       	call   8002f5 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	89 7d 14             	mov    %edi,0x14(%ebp)
  800445:	e9 88 02 00 00       	jmp    8006d2 <vprintfmt+0x3c0>
  80044a:	f7 d8                	neg    %eax
  80044c:	eb d2                	jmp    800420 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044e:	52                   	push   %edx
  80044f:	68 a2 0d 80 00       	push   $0x800da2
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 9a fe ff ff       	call   8002f5 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800461:	e9 6c 02 00 00       	jmp    8006d2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 38                	mov    (%eax),%edi
  800474:	85 ff                	test   %edi,%edi
  800476:	74 18                	je     800490 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800478:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047c:	0f 8e b7 00 00 00    	jle    800539 <vprintfmt+0x227>
  800482:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800486:	75 0f                	jne    800497 <vprintfmt+0x185>
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80048e:	eb 75                	jmp    800505 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800490:	bf 9b 0d 80 00       	mov    $0x800d9b,%edi
  800495:	eb e1                	jmp    800478 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 d0             	pushl  -0x30(%ebp)
  80049d:	57                   	push   %edi
  80049e:	e8 5f 03 00 00       	call   800802 <strnlen>
  8004a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	eb 0d                	jmp    8004c9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	4f                   	dec    %edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ef                	jg     8004bc <vprintfmt+0x1aa>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	89 c8                	mov    %ecx,%eax
  8004d5:	85 c9                	test   %ecx,%ecx
  8004d7:	78 10                	js     8004e9 <vprintfmt+0x1d7>
  8004d9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004dc:	29 c1                	sub    %eax,%ecx
  8004de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004e7:	eb 1c                	jmp    800505 <vprintfmt+0x1f3>
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	eb e9                	jmp    8004d9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f4:	75 29                	jne    80051f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 0c             	pushl  0xc(%ebp)
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	ff 4d e0             	decl   -0x20(%ebp)
  800505:	47                   	inc    %edi
  800506:	8a 57 ff             	mov    -0x1(%edi),%dl
  800509:	0f be c2             	movsbl %dl,%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	74 4c                	je     80055c <vprintfmt+0x24a>
  800510:	85 db                	test   %ebx,%ebx
  800512:	78 dc                	js     8004f0 <vprintfmt+0x1de>
  800514:	4b                   	dec    %ebx
  800515:	79 d9                	jns    8004f0 <vprintfmt+0x1de>
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80051d:	eb 2e                	jmp    80054d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80051f:	0f be d2             	movsbl %dl,%edx
  800522:	83 ea 20             	sub    $0x20,%edx
  800525:	83 fa 5e             	cmp    $0x5e,%edx
  800528:	76 cc                	jbe    8004f6 <vprintfmt+0x1e4>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff d6                	call   *%esi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	eb c9                	jmp    800502 <vprintfmt+0x1f0>
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053f:	eb c4                	jmp    800505 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	6a 20                	push   $0x20
  800547:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800549:	4f                   	dec    %edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 ff                	test   %edi,%edi
  80054f:	7f f0                	jg     800541 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800551:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	e9 76 01 00 00       	jmp    8006d2 <vprintfmt+0x3c0>
  80055c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	eb e9                	jmp    80054d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800564:	83 f9 01             	cmp    $0x1,%ecx
  800567:	7e 3f                	jle    8005a8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 50 04             	mov    0x4(%eax),%edx
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 08             	lea    0x8(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800580:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800584:	79 5c                	jns    8005e2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	6a 2d                	push   $0x2d
  80058c:	ff d6                	call   *%esi
				num = -(long long) num;
  80058e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800591:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800594:	f7 da                	neg    %edx
  800596:	83 d1 00             	adc    $0x0,%ecx
  800599:	f7 d9                	neg    %ecx
  80059b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 10 01 00 00       	jmp    8006b8 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005a8:	85 c9                	test   %ecx,%ecx
  8005aa:	75 1b                	jne    8005c7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c5:	eb b9                	jmp    800580 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 c1                	mov    %eax,%ecx
  8005d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb 9e                	jmp    800580 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	e9 c6 00 00 00       	jmp    8006b8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f2:	83 f9 01             	cmp    $0x1,%ecx
  8005f5:	7e 18                	jle    80060f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	8d 40 08             	lea    0x8(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060a:	e9 a9 00 00 00       	jmp    8006b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80060f:	85 c9                	test   %ecx,%ecx
  800611:	75 1a                	jne    80062d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800623:	b8 0a 00 00 00       	mov    $0xa,%eax
  800628:	e9 8b 00 00 00       	jmp    8006b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 10                	mov    (%eax),%edx
  800632:	b9 00 00 00 00       	mov    $0x0,%ecx
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800642:	eb 74                	jmp    8006b8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 15                	jle    80065e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8b 48 04             	mov    0x4(%eax),%ecx
  800651:	8d 40 08             	lea    0x8(%eax),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800657:	b8 08 00 00 00       	mov    $0x8,%eax
  80065c:	eb 5a                	jmp    8006b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80065e:	85 c9                	test   %ecx,%ecx
  800660:	75 17                	jne    800679 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800672:	b8 08 00 00 00       	mov    $0x8,%eax
  800677:	eb 3f                	jmp    8006b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
  80068e:	eb 28                	jmp    8006b8 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 30                	push   $0x30
  800696:	ff d6                	call   *%esi
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 78                	push   $0x78
  80069e:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bf:	57                   	push   %edi
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	50                   	push   %eax
  8006c4:	51                   	push   %ecx
  8006c5:	52                   	push   %edx
  8006c6:	89 da                	mov    %ebx,%edx
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	e8 5d fb ff ff       	call   80022c <printnum>
			break;
  8006cf:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d5:	47                   	inc    %edi
  8006d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006da:	83 f8 25             	cmp    $0x25,%eax
  8006dd:	0f 84 46 fc ff ff    	je     800329 <vprintfmt+0x17>
			if (ch == '\0')
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	0f 84 89 00 00 00    	je     800774 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	50                   	push   %eax
  8006f0:	ff d6                	call   *%esi
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb de                	jmp    8006d5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f7:	83 f9 01             	cmp    $0x1,%ecx
  8006fa:	7e 15                	jle    800711 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8b 48 04             	mov    0x4(%eax),%ecx
  800704:	8d 40 08             	lea    0x8(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
  80070f:	eb a7                	jmp    8006b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800711:	85 c9                	test   %ecx,%ecx
  800713:	75 17                	jne    80072c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071f:	8d 40 04             	lea    0x4(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800725:	b8 10 00 00 00       	mov    $0x10,%eax
  80072a:	eb 8c                	jmp    8006b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80073c:	b8 10 00 00 00       	mov    $0x10,%eax
  800741:	e9 72 ff ff ff       	jmp    8006b8 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	6a 25                	push   $0x25
  80074c:	ff d6                	call   *%esi
			break;
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	e9 7c ff ff ff       	jmp    8006d2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 25                	push   $0x25
  80075c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	89 f8                	mov    %edi,%eax
  800763:	eb 01                	jmp    800766 <vprintfmt+0x454>
  800765:	48                   	dec    %eax
  800766:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076a:	75 f9                	jne    800765 <vprintfmt+0x453>
  80076c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076f:	e9 5e ff ff ff       	jmp    8006d2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5f                   	pop    %edi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 18             	sub    $0x18,%esp
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800788:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800792:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 26                	je     8007c3 <vsnprintf+0x47>
  80079d:	85 d2                	test   %edx,%edx
  80079f:	7e 29                	jle    8007ca <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a1:	ff 75 14             	pushl  0x14(%ebp)
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007aa:	50                   	push   %eax
  8007ab:	68 d9 02 80 00       	push   $0x8002d9
  8007b0:	e8 5d fb ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007be:	83 c4 10             	add    $0x10,%esp
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c8:	eb f7                	jmp    8007c1 <vsnprintf+0x45>
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cf:	eb f0                	jmp    8007c1 <vsnprintf+0x45>

008007d1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007da:	50                   	push   %eax
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	ff 75 0c             	pushl  0xc(%ebp)
  8007e1:	ff 75 08             	pushl  0x8(%ebp)
  8007e4:	e8 93 ff ff ff       	call   80077c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    
	...

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 01                	jmp    8007fa <strlen+0xe>
		n++;
  8007f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fe:	75 f9                	jne    8007f9 <strlen+0xd>
		n++;
	return n;
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 01                	jmp    800813 <strnlen+0x11>
		n++;
  800812:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	39 d0                	cmp    %edx,%eax
  800815:	74 06                	je     80081d <strnlen+0x1b>
  800817:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081b:	75 f5                	jne    800812 <strnlen+0x10>
		n++;
	return n;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800829:	89 c2                	mov    %eax,%edx
  80082b:	41                   	inc    %ecx
  80082c:	42                   	inc    %edx
  80082d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800830:	88 5a ff             	mov    %bl,-0x1(%edx)
  800833:	84 db                	test   %bl,%bl
  800835:	75 f4                	jne    80082b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	53                   	push   %ebx
  800842:	e8 a5 ff ff ff       	call   8007ec <strlen>
  800847:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	50                   	push   %eax
  800850:	e8 ca ff ff ff       	call   80081f <strcpy>
	return dst;
}
  800855:	89 d8                	mov    %ebx,%eax
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	89 f3                	mov    %esi,%ebx
  800869:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	89 f2                	mov    %esi,%edx
  80086e:	39 da                	cmp    %ebx,%edx
  800870:	74 0e                	je     800880 <strncpy+0x24>
		*dst++ = *src;
  800872:	42                   	inc    %edx
  800873:	8a 01                	mov    (%ecx),%al
  800875:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800878:	80 39 00             	cmpb   $0x0,(%ecx)
  80087b:	74 f1                	je     80086e <strncpy+0x12>
			src++;
  80087d:	41                   	inc    %ecx
  80087e:	eb ee                	jmp    80086e <strncpy+0x12>
	}
	return ret;
}
  800880:	89 f0                	mov    %esi,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	85 c0                	test   %eax,%eax
  800896:	74 20                	je     8008b8 <strlcpy+0x32>
  800898:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	eb 05                	jmp    8008a5 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a0:	42                   	inc    %edx
  8008a1:	40                   	inc    %eax
  8008a2:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 d8                	cmp    %ebx,%eax
  8008a7:	74 06                	je     8008af <strlcpy+0x29>
  8008a9:	8a 0a                	mov    (%edx),%cl
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	75 f1                	jne    8008a0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b2:	29 f0                	sub    %esi,%eax
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	eb f6                	jmp    8008b2 <strlcpy+0x2c>

008008bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c5:	eb 02                	jmp    8008c9 <strcmp+0xd>
		p++, q++;
  8008c7:	41                   	inc    %ecx
  8008c8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c9:	8a 01                	mov    (%ecx),%al
  8008cb:	84 c0                	test   %al,%al
  8008cd:	74 04                	je     8008d3 <strcmp+0x17>
  8008cf:	3a 02                	cmp    (%edx),%al
  8008d1:	74 f4                	je     8008c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 c0             	movzbl %al,%eax
  8008d6:	0f b6 12             	movzbl (%edx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e7:	89 c3                	mov    %eax,%ebx
  8008e9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ec:	eb 02                	jmp    8008f0 <strncmp+0x13>
		n--, p++, q++;
  8008ee:	40                   	inc    %eax
  8008ef:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f0:	39 d8                	cmp    %ebx,%eax
  8008f2:	74 15                	je     800909 <strncmp+0x2c>
  8008f4:	8a 08                	mov    (%eax),%cl
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 04                	je     8008fe <strncmp+0x21>
  8008fa:	3a 0a                	cmp    (%edx),%cl
  8008fc:	74 f0                	je     8008ee <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
  80090e:	eb f6                	jmp    800906 <strncmp+0x29>

00800910 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	74 07                	je     800926 <strchr+0x16>
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	74 08                	je     80092b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800923:	40                   	inc    %eax
  800924:	eb f3                	jmp    800919 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	74 07                	je     800943 <strfind+0x16>
		if (*s == c)
  80093c:	38 ca                	cmp    %cl,%dl
  80093e:	74 03                	je     800943 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800940:	40                   	inc    %eax
  800941:	eb f3                	jmp    800936 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 13                	je     800968 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 05                	jne    800962 <memset+0x1d>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	74 0d                	je     80096f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80096f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800973:	89 d3                	mov    %edx,%ebx
  800975:	c1 e3 08             	shl    $0x8,%ebx
  800978:	89 d0                	mov    %edx,%eax
  80097a:	c1 e0 18             	shl    $0x18,%eax
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 10             	shl    $0x10,%esi
  800982:	09 f0                	or     %esi,%eax
  800984:	09 c2                	or     %eax,%edx
  800986:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800988:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	fc                   	cld    
  80098e:	f3 ab                	rep stos %eax,%es:(%edi)
  800990:	eb d6                	jmp    800968 <memset+0x23>

00800992 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a0:	39 c6                	cmp    %eax,%esi
  8009a2:	73 33                	jae    8009d7 <memmove+0x45>
  8009a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	76 2c                	jbe    8009d7 <memmove+0x45>
		s += n;
		d += n;
  8009ab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	09 fe                	or     %edi,%esi
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	74 0a                	je     8009c4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ba:	4f                   	dec    %edi
  8009bb:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009be:	fd                   	std    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c1:	fc                   	cld    
  8009c2:	eb 21                	jmp    8009e5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 f1                	jne    8009ba <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c9:	83 ef 04             	sub    $0x4,%edi
  8009cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d5:	eb ea                	jmp    8009c1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d7:	89 f2                	mov    %esi,%edx
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	f6 c2 03             	test   $0x3,%dl
  8009de:	74 09                	je     8009e9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 f2                	jne    8009e0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb ed                	jmp    8009e5 <memmove+0x53>

008009f8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fb:	ff 75 10             	pushl  0x10(%ebp)
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	ff 75 08             	pushl  0x8(%ebp)
  800a04:	e8 89 ff ff ff       	call   800992 <memmove>
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a16:	89 c6                	mov    %eax,%esi
  800a18:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	39 f0                	cmp    %esi,%eax
  800a1d:	74 16                	je     800a35 <memcmp+0x2a>
		if (*s1 != *s2)
  800a1f:	8a 08                	mov    (%eax),%cl
  800a21:	8a 1a                	mov    (%edx),%bl
  800a23:	38 d9                	cmp    %bl,%cl
  800a25:	75 04                	jne    800a2b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a27:	40                   	inc    %eax
  800a28:	42                   	inc    %edx
  800a29:	eb f0                	jmp    800a1b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a2b:	0f b6 c1             	movzbl %cl,%eax
  800a2e:	0f b6 db             	movzbl %bl,%ebx
  800a31:	29 d8                	sub    %ebx,%eax
  800a33:	eb 05                	jmp    800a3a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4c:	39 d0                	cmp    %edx,%eax
  800a4e:	73 07                	jae    800a57 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a50:	38 08                	cmp    %cl,(%eax)
  800a52:	74 03                	je     800a57 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	40                   	inc    %eax
  800a55:	eb f5                	jmp    800a4c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 01                	jmp    800a65 <strtol+0xc>
		s++;
  800a64:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a65:	8a 01                	mov    (%ecx),%al
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f9                	je     800a64 <strtol+0xb>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f5                	je     800a64 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	74 2b                	je     800a9e <strtol+0x45>
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	74 2f                	je     800aa6 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a83:	75 12                	jne    800a97 <strtol+0x3e>
  800a85:	80 39 30             	cmpb   $0x30,(%ecx)
  800a88:	74 24                	je     800aae <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a8e:	75 07                	jne    800a97 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a90:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	eb 4e                	jmp    800aec <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800a9e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa4:	eb d6                	jmp    800a7c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800aa6:	41                   	inc    %ecx
  800aa7:	bf 01 00 00 00       	mov    $0x1,%edi
  800aac:	eb ce                	jmp    800a7c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab2:	74 10                	je     800ac4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab8:	75 dd                	jne    800a97 <strtol+0x3e>
		s++, base = 8;
  800aba:	41                   	inc    %ecx
  800abb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ac2:	eb d3                	jmp    800a97 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ac4:	83 c1 02             	add    $0x2,%ecx
  800ac7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ace:	eb c7                	jmp    800a97 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 24                	ja     800afe <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800ae3:	7e 2b                	jle    800b10 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ae5:	41                   	inc    %ecx
  800ae6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aea:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aec:	8a 11                	mov    (%ecx),%dl
  800aee:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800af1:	80 fb 09             	cmp    $0x9,%bl
  800af4:	77 da                	ja     800ad0 <strtol+0x77>
			dig = *s - '0';
  800af6:	0f be d2             	movsbl %dl,%edx
  800af9:	83 ea 30             	sub    $0x30,%edx
  800afc:	eb e2                	jmp    800ae0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b01:	89 f3                	mov    %esi,%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 08                	ja     800b10 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 37             	sub    $0x37,%edx
  800b0e:	eb d0                	jmp    800ae0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b14:	74 05                	je     800b1b <strtol+0xc2>
		*endptr = (char *) s;
  800b16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b19:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1b:	85 ff                	test   %edi,%edi
  800b1d:	74 02                	je     800b21 <strtol+0xc8>
  800b1f:	f7 d8                	neg    %eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
	...

00800b28 <__udivdi3>:
  800b28:	55                   	push   %ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 1c             	sub    $0x1c,%esp
  800b2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b3b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b3f:	85 d2                	test   %edx,%edx
  800b41:	75 2d                	jne    800b70 <__udivdi3+0x48>
  800b43:	39 f7                	cmp    %esi,%edi
  800b45:	77 59                	ja     800ba0 <__udivdi3+0x78>
  800b47:	89 f9                	mov    %edi,%ecx
  800b49:	85 ff                	test   %edi,%edi
  800b4b:	75 0b                	jne    800b58 <__udivdi3+0x30>
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	31 d2                	xor    %edx,%edx
  800b54:	f7 f7                	div    %edi
  800b56:	89 c1                	mov    %eax,%ecx
  800b58:	31 d2                	xor    %edx,%edx
  800b5a:	89 f0                	mov    %esi,%eax
  800b5c:	f7 f1                	div    %ecx
  800b5e:	89 c3                	mov    %eax,%ebx
  800b60:	89 e8                	mov    %ebp,%eax
  800b62:	f7 f1                	div    %ecx
  800b64:	89 da                	mov    %ebx,%edx
  800b66:	83 c4 1c             	add    $0x1c,%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	39 f2                	cmp    %esi,%edx
  800b72:	77 1c                	ja     800b90 <__udivdi3+0x68>
  800b74:	0f bd da             	bsr    %edx,%ebx
  800b77:	83 f3 1f             	xor    $0x1f,%ebx
  800b7a:	75 38                	jne    800bb4 <__udivdi3+0x8c>
  800b7c:	39 f2                	cmp    %esi,%edx
  800b7e:	72 08                	jb     800b88 <__udivdi3+0x60>
  800b80:	39 ef                	cmp    %ebp,%edi
  800b82:	0f 87 98 00 00 00    	ja     800c20 <__udivdi3+0xf8>
  800b88:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8d:	eb 05                	jmp    800b94 <__udivdi3+0x6c>
  800b8f:	90                   	nop
  800b90:	31 db                	xor    %ebx,%ebx
  800b92:	31 c0                	xor    %eax,%eax
  800b94:	89 da                	mov    %ebx,%edx
  800b96:	83 c4 1c             	add    $0x1c,%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    
  800b9e:	66 90                	xchg   %ax,%ax
  800ba0:	89 e8                	mov    %ebp,%eax
  800ba2:	89 f2                	mov    %esi,%edx
  800ba4:	f7 f7                	div    %edi
  800ba6:	31 db                	xor    %ebx,%ebx
  800ba8:	89 da                	mov    %ebx,%edx
  800baa:	83 c4 1c             	add    $0x1c,%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
  800bb2:	66 90                	xchg   %ax,%ax
  800bb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bb9:	29 d8                	sub    %ebx,%eax
  800bbb:	88 d9                	mov    %bl,%cl
  800bbd:	d3 e2                	shl    %cl,%edx
  800bbf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bc3:	89 fa                	mov    %edi,%edx
  800bc5:	88 c1                	mov    %al,%cl
  800bc7:	d3 ea                	shr    %cl,%edx
  800bc9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bcd:	09 d1                	or     %edx,%ecx
  800bcf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bd3:	88 d9                	mov    %bl,%cl
  800bd5:	d3 e7                	shl    %cl,%edi
  800bd7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bdb:	89 f7                	mov    %esi,%edi
  800bdd:	88 c1                	mov    %al,%cl
  800bdf:	d3 ef                	shr    %cl,%edi
  800be1:	88 d9                	mov    %bl,%cl
  800be3:	d3 e6                	shl    %cl,%esi
  800be5:	89 ea                	mov    %ebp,%edx
  800be7:	88 c1                	mov    %al,%cl
  800be9:	d3 ea                	shr    %cl,%edx
  800beb:	09 d6                	or     %edx,%esi
  800bed:	89 f0                	mov    %esi,%eax
  800bef:	89 fa                	mov    %edi,%edx
  800bf1:	f7 74 24 08          	divl   0x8(%esp)
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 c6                	mov    %eax,%esi
  800bf9:	f7 64 24 0c          	mull   0xc(%esp)
  800bfd:	39 d7                	cmp    %edx,%edi
  800bff:	72 13                	jb     800c14 <__udivdi3+0xec>
  800c01:	74 09                	je     800c0c <__udivdi3+0xe4>
  800c03:	89 f0                	mov    %esi,%eax
  800c05:	31 db                	xor    %ebx,%ebx
  800c07:	eb 8b                	jmp    800b94 <__udivdi3+0x6c>
  800c09:	8d 76 00             	lea    0x0(%esi),%esi
  800c0c:	88 d9                	mov    %bl,%cl
  800c0e:	d3 e5                	shl    %cl,%ebp
  800c10:	39 c5                	cmp    %eax,%ebp
  800c12:	73 ef                	jae    800c03 <__udivdi3+0xdb>
  800c14:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c17:	31 db                	xor    %ebx,%ebx
  800c19:	e9 76 ff ff ff       	jmp    800b94 <__udivdi3+0x6c>
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	31 c0                	xor    %eax,%eax
  800c22:	e9 6d ff ff ff       	jmp    800b94 <__udivdi3+0x6c>
	...

00800c28 <__umoddi3>:
  800c28:	55                   	push   %ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 1c             	sub    $0x1c,%esp
  800c2f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c3b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	89 da                	mov    %ebx,%edx
  800c43:	85 ed                	test   %ebp,%ebp
  800c45:	75 15                	jne    800c5c <__umoddi3+0x34>
  800c47:	39 df                	cmp    %ebx,%edi
  800c49:	76 39                	jbe    800c84 <__umoddi3+0x5c>
  800c4b:	f7 f7                	div    %edi
  800c4d:	89 d0                	mov    %edx,%eax
  800c4f:	31 d2                	xor    %edx,%edx
  800c51:	83 c4 1c             	add    $0x1c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    
  800c59:	8d 76 00             	lea    0x0(%esi),%esi
  800c5c:	39 dd                	cmp    %ebx,%ebp
  800c5e:	77 f1                	ja     800c51 <__umoddi3+0x29>
  800c60:	0f bd cd             	bsr    %ebp,%ecx
  800c63:	83 f1 1f             	xor    $0x1f,%ecx
  800c66:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c6a:	75 38                	jne    800ca4 <__umoddi3+0x7c>
  800c6c:	39 dd                	cmp    %ebx,%ebp
  800c6e:	72 04                	jb     800c74 <__umoddi3+0x4c>
  800c70:	39 f7                	cmp    %esi,%edi
  800c72:	77 dd                	ja     800c51 <__umoddi3+0x29>
  800c74:	89 da                	mov    %ebx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	29 f8                	sub    %edi,%eax
  800c7a:	19 ea                	sbb    %ebp,%edx
  800c7c:	83 c4 1c             	add    $0x1c,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    
  800c84:	89 f9                	mov    %edi,%ecx
  800c86:	85 ff                	test   %edi,%edi
  800c88:	75 0b                	jne    800c95 <__umoddi3+0x6d>
  800c8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8f:	31 d2                	xor    %edx,%edx
  800c91:	f7 f7                	div    %edi
  800c93:	89 c1                	mov    %eax,%ecx
  800c95:	89 d8                	mov    %ebx,%eax
  800c97:	31 d2                	xor    %edx,%edx
  800c99:	f7 f1                	div    %ecx
  800c9b:	89 f0                	mov    %esi,%eax
  800c9d:	f7 f1                	div    %ecx
  800c9f:	eb ac                	jmp    800c4d <__umoddi3+0x25>
  800ca1:	8d 76 00             	lea    0x0(%esi),%esi
  800ca4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	8b 44 24 04          	mov    0x4(%esp),%eax
  800caf:	29 c2                	sub    %eax,%edx
  800cb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cb5:	88 c1                	mov    %al,%cl
  800cb7:	d3 e5                	shl    %cl,%ebp
  800cb9:	89 f8                	mov    %edi,%eax
  800cbb:	88 d1                	mov    %dl,%cl
  800cbd:	d3 e8                	shr    %cl,%eax
  800cbf:	09 c5                	or     %eax,%ebp
  800cc1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cc5:	88 c1                	mov    %al,%cl
  800cc7:	d3 e7                	shl    %cl,%edi
  800cc9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	88 d1                	mov    %dl,%cl
  800cd1:	d3 ef                	shr    %cl,%edi
  800cd3:	88 c1                	mov    %al,%cl
  800cd5:	d3 e3                	shl    %cl,%ebx
  800cd7:	89 f0                	mov    %esi,%eax
  800cd9:	88 d1                	mov    %dl,%cl
  800cdb:	d3 e8                	shr    %cl,%eax
  800cdd:	09 d8                	or     %ebx,%eax
  800cdf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ce3:	d3 e6                	shl    %cl,%esi
  800ce5:	89 fa                	mov    %edi,%edx
  800ce7:	f7 f5                	div    %ebp
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	f7 64 24 08          	mull   0x8(%esp)
  800cef:	89 c3                	mov    %eax,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	39 d1                	cmp    %edx,%ecx
  800cf5:	72 29                	jb     800d20 <__umoddi3+0xf8>
  800cf7:	74 23                	je     800d1c <__umoddi3+0xf4>
  800cf9:	89 ca                	mov    %ecx,%edx
  800cfb:	29 de                	sub    %ebx,%esi
  800cfd:	19 fa                	sbb    %edi,%edx
  800cff:	89 d0                	mov    %edx,%eax
  800d01:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d05:	d3 e0                	shl    %cl,%eax
  800d07:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d0b:	88 d9                	mov    %bl,%cl
  800d0d:	d3 ee                	shr    %cl,%esi
  800d0f:	09 f0                	or     %esi,%eax
  800d11:	d3 ea                	shr    %cl,%edx
  800d13:	83 c4 1c             	add    $0x1c,%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
  800d1b:	90                   	nop
  800d1c:	39 c6                	cmp    %eax,%esi
  800d1e:	73 d9                	jae    800cf9 <__umoddi3+0xd1>
  800d20:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d24:	19 ea                	sbb    %ebp,%edx
  800d26:	89 d7                	mov    %edx,%edi
  800d28:	89 c3                	mov    %eax,%ebx
  800d2a:	eb cd                	jmp    800cf9 <__umoddi3+0xd1>
