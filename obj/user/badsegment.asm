
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800048:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004b:	e8 ce 00 00 00       	call   80011e <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800058:	01 d0                	add    %edx,%eax
  80005a:	c1 e0 05             	shl    $0x5,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x32>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 44 00 00 00       	call   8000dd <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7f 08                	jg     800107 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 3a 0d 80 00       	push   $0x800d3a
  800112:	6a 23                	push   $0x23
  800114:	68 57 0d 80 00       	push   $0x800d57
  800119:	e8 22 00 00 00       	call   800140 <_panic>

0080011e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
  80013d:	00 00                	add    %al,(%eax)
	...

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80014e:	e8 cb ff ff ff       	call   80011e <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	56                   	push   %esi
  80015d:	50                   	push   %eax
  80015e:	68 68 0d 80 00       	push   $0x800d68
  800163:	e8 b4 00 00 00       	call   80021c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	53                   	push   %ebx
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 57 00 00 00       	call   8001cb <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 8c 0d 80 00 	movl   $0x800d8c,(%esp)
  80017b:	e8 9c 00 00 00       	call   80021c <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x43>
	...

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	53                   	push   %ebx
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800192:	8b 13                	mov    (%ebx),%edx
  800194:	8d 42 01             	lea    0x1(%edx),%eax
  800197:	89 03                	mov    %eax,(%ebx)
  800199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a5:	74 08                	je     8001af <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a7:	ff 43 04             	incl   0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	68 ff 00 00 00       	push   $0xff
  8001b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ba:	50                   	push   %eax
  8001bb:	e8 e0 fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	eb dc                	jmp    8001a7 <putch+0x1f>

008001cb <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001db:	00 00 00 
	b.cnt = 0;
  8001de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e8:	ff 75 0c             	pushl  0xc(%ebp)
  8001eb:	ff 75 08             	pushl  0x8(%ebp)
  8001ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f4:	50                   	push   %eax
  8001f5:	68 88 01 80 00       	push   $0x800188
  8001fa:	e8 17 01 00 00       	call   800316 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ff:	83 c4 08             	add    $0x8,%esp
  800202:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800208:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 8c fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800214:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800222:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800225:	50                   	push   %eax
  800226:	ff 75 08             	pushl  0x8(%ebp)
  800229:	e8 9d ff ff ff       	call   8001cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 1c             	sub    $0x1c,%esp
  800239:	89 c7                	mov    %eax,%edi
  80023b:	89 d6                	mov    %edx,%esi
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	8b 55 0c             	mov    0xc(%ebp),%edx
  800243:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800246:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800249:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800251:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800254:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800257:	39 d3                	cmp    %edx,%ebx
  800259:	72 05                	jb     800260 <printnum+0x30>
  80025b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025e:	77 78                	ja     8002d8 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800260:	83 ec 0c             	sub    $0xc,%esp
  800263:	ff 75 18             	pushl  0x18(%ebp)
  800266:	8b 45 14             	mov    0x14(%ebp),%eax
  800269:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026c:	53                   	push   %ebx
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	ff 75 dc             	pushl  -0x24(%ebp)
  80027c:	ff 75 d8             	pushl  -0x28(%ebp)
  80027f:	e8 a8 08 00 00       	call   800b2c <__udivdi3>
  800284:	83 c4 18             	add    $0x18,%esp
  800287:	52                   	push   %edx
  800288:	50                   	push   %eax
  800289:	89 f2                	mov    %esi,%edx
  80028b:	89 f8                	mov    %edi,%eax
  80028d:	e8 9e ff ff ff       	call   800230 <printnum>
  800292:	83 c4 20             	add    $0x20,%esp
  800295:	eb 11                	jmp    8002a8 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	56                   	push   %esi
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	ff d7                	call   *%edi
  8002a0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f ef                	jg     800297 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 6c 09 00 00       	call   800c2c <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 8e 0d 80 00 	movsbl 0x800d8e(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    
  8002d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002db:	eb c6                	jmp    8002a3 <printnum+0x73>

008002dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002eb:	73 0a                	jae    8002f7 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	88 02                	mov    %al,(%edx)
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	ff 75 08             	pushl  0x8(%ebp)
  80030c:	e8 05 00 00 00       	call   800316 <vprintfmt>
	va_end(ap);
}
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 2c             	sub    $0x2c,%esp
  80031f:	8b 75 08             	mov    0x8(%ebp),%esi
  800322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800325:	8b 7d 10             	mov    0x10(%ebp),%edi
  800328:	e9 ac 03 00 00       	jmp    8006d9 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80032d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800331:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800338:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80033f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 47 01             	lea    0x1(%edi),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	8a 17                	mov    (%edi),%dl
  800353:	8d 42 dd             	lea    -0x23(%edx),%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 fc 03 00 00    	ja     80075a <vprintfmt+0x444>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 1c 0e 80 00 	jmp    *0x800e1c(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036f:	eb da                	jmp    80034b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800374:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800378:	eb d1                	jmp    80034b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 d2             	movzbl %dl,%edx
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
  800385:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800388:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038b:	01 c0                	add    %eax,%eax
  80038d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800391:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800394:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800397:	83 f9 09             	cmp    $0x9,%ecx
  80039a:	77 52                	ja     8003ee <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80039d:	eb e9                	jmp    800388 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8b 00                	mov    (%eax),%eax
  8003a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 40 04             	lea    0x4(%eax),%eax
  8003ad:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b7:	79 92                	jns    80034b <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c6:	eb 83                	jmp    80034b <vprintfmt+0x35>
  8003c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cc:	78 08                	js     8003d6 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	e9 75 ff ff ff       	jmp    80034b <vprintfmt+0x35>
  8003d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003dd:	eb ef                	jmp    8003ce <vprintfmt+0xb8>
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e9:	e9 5d ff ff ff       	jmp    80034b <vprintfmt+0x35>
  8003ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f4:	eb bd                	jmp    8003b3 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fa:	e9 4c ff ff ff       	jmp    80034b <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 78 04             	lea    0x4(%eax),%edi
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	53                   	push   %ebx
  800409:	ff 30                	pushl  (%eax)
  80040b:	ff d6                	call   *%esi
			break;
  80040d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800410:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800413:	e9 be 02 00 00       	jmp    8006d6 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 78 04             	lea    0x4(%eax),%edi
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	85 c0                	test   %eax,%eax
  800422:	78 2a                	js     80044e <vprintfmt+0x138>
  800424:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 06             	cmp    $0x6,%eax
  800429:	7f 27                	jg     800452 <vprintfmt+0x13c>
  80042b:	8b 04 85 74 0f 80 00 	mov    0x800f74(,%eax,4),%eax
  800432:	85 c0                	test   %eax,%eax
  800434:	74 1c                	je     800452 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800436:	50                   	push   %eax
  800437:	68 af 0d 80 00       	push   $0x800daf
  80043c:	53                   	push   %ebx
  80043d:	56                   	push   %esi
  80043e:	e8 b6 fe ff ff       	call   8002f9 <printfmt>
  800443:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
  800449:	e9 88 02 00 00       	jmp    8006d6 <vprintfmt+0x3c0>
  80044e:	f7 d8                	neg    %eax
  800450:	eb d2                	jmp    800424 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800452:	52                   	push   %edx
  800453:	68 a6 0d 80 00       	push   $0x800da6
  800458:	53                   	push   %ebx
  800459:	56                   	push   %esi
  80045a:	e8 9a fe ff ff       	call   8002f9 <printfmt>
  80045f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800462:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800465:	e9 6c 02 00 00       	jmp    8006d6 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	83 c0 04             	add    $0x4,%eax
  800470:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8b 38                	mov    (%eax),%edi
  800478:	85 ff                	test   %edi,%edi
  80047a:	74 18                	je     800494 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  80047c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800480:	0f 8e b7 00 00 00    	jle    80053d <vprintfmt+0x227>
  800486:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048a:	75 0f                	jne    80049b <vprintfmt+0x185>
  80048c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800492:	eb 75                	jmp    800509 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800494:	bf 9f 0d 80 00       	mov    $0x800d9f,%edi
  800499:	eb e1                	jmp    80047c <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a1:	57                   	push   %edi
  8004a2:	e8 5f 03 00 00       	call   800806 <strnlen>
  8004a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004aa:	29 c1                	sub    %eax,%ecx
  8004ac:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004af:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004bc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	eb 0d                	jmp    8004cd <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	4f                   	dec    %edi
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f ef                	jg     8004c0 <vprintfmt+0x1aa>
  8004d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d7:	89 c8                	mov    %ecx,%eax
  8004d9:	85 c9                	test   %ecx,%ecx
  8004db:	78 10                	js     8004ed <vprintfmt+0x1d7>
  8004dd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e0:	29 c1                	sub    %eax,%ecx
  8004e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004eb:	eb 1c                	jmp    800509 <vprintfmt+0x1f3>
  8004ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f2:	eb e9                	jmp    8004dd <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f8:	75 29                	jne    800523 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	50                   	push   %eax
  800501:	ff d6                	call   *%esi
  800503:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800506:	ff 4d e0             	decl   -0x20(%ebp)
  800509:	47                   	inc    %edi
  80050a:	8a 57 ff             	mov    -0x1(%edi),%dl
  80050d:	0f be c2             	movsbl %dl,%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	74 4c                	je     800560 <vprintfmt+0x24a>
  800514:	85 db                	test   %ebx,%ebx
  800516:	78 dc                	js     8004f4 <vprintfmt+0x1de>
  800518:	4b                   	dec    %ebx
  800519:	79 d9                	jns    8004f4 <vprintfmt+0x1de>
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800521:	eb 2e                	jmp    800551 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	0f be d2             	movsbl %dl,%edx
  800526:	83 ea 20             	sub    $0x20,%edx
  800529:	83 fa 5e             	cmp    $0x5e,%edx
  80052c:	76 cc                	jbe    8004fa <vprintfmt+0x1e4>
					putch('?', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	6a 3f                	push   $0x3f
  800536:	ff d6                	call   *%esi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb c9                	jmp    800506 <vprintfmt+0x1f0>
  80053d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800540:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800543:	eb c4                	jmp    800509 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	6a 20                	push   $0x20
  80054b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054d:	4f                   	dec    %edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 ff                	test   %edi,%edi
  800553:	7f f0                	jg     800545 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	e9 76 01 00 00       	jmp    8006d6 <vprintfmt+0x3c0>
  800560:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800566:	eb e9                	jmp    800551 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800568:	83 f9 01             	cmp    $0x1,%ecx
  80056b:	7e 3f                	jle    8005ac <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 50 04             	mov    0x4(%eax),%edx
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 08             	lea    0x8(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800584:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800588:	79 5c                	jns    8005e6 <vprintfmt+0x2d0>
				putch('-', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	53                   	push   %ebx
  80058e:	6a 2d                	push   $0x2d
  800590:	ff d6                	call   *%esi
				num = -(long long) num;
  800592:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800595:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800598:	f7 da                	neg    %edx
  80059a:	83 d1 00             	adc    $0x0,%ecx
  80059d:	f7 d9                	neg    %ecx
  80059f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 10 01 00 00       	jmp    8006bc <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005ac:	85 c9                	test   %ecx,%ecx
  8005ae:	75 1b                	jne    8005cb <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	89 c1                	mov    %eax,%ecx
  8005ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c9:	eb b9                	jmp    800584 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 c1                	mov    %eax,%ecx
  8005d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 40 04             	lea    0x4(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e4:	eb 9e                	jmp    800584 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f1:	e9 c6 00 00 00       	jmp    8006bc <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f6:	83 f9 01             	cmp    $0x1,%ecx
  8005f9:	7e 18                	jle    800613 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8b 48 04             	mov    0x4(%eax),%ecx
  800603:	8d 40 08             	lea    0x8(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	e9 a9 00 00 00       	jmp    8006bc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	75 1a                	jne    800631 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	e9 8b 00 00 00       	jmp    8006bc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800641:	b8 0a 00 00 00       	mov    $0xa,%eax
  800646:	eb 74                	jmp    8006bc <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800648:	83 f9 01             	cmp    $0x1,%ecx
  80064b:	7e 15                	jle    800662 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	8b 48 04             	mov    0x4(%eax),%ecx
  800655:	8d 40 08             	lea    0x8(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80065b:	b8 08 00 00 00       	mov    $0x8,%eax
  800660:	eb 5a                	jmp    8006bc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	75 17                	jne    80067d <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800676:	b8 08 00 00 00       	mov    $0x8,%eax
  80067b:	eb 3f                	jmp    8006bc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80068d:	b8 08 00 00 00       	mov    $0x8,%eax
  800692:	eb 28                	jmp    8006bc <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 30                	push   $0x30
  80069a:	ff d6                	call   *%esi
			putch('x', putdat);
  80069c:	83 c4 08             	add    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 78                	push   $0x78
  8006a2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c3:	57                   	push   %edi
  8006c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c7:	50                   	push   %eax
  8006c8:	51                   	push   %ecx
  8006c9:	52                   	push   %edx
  8006ca:	89 da                	mov    %ebx,%edx
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	e8 5d fb ff ff       	call   800230 <printnum>
			break;
  8006d3:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d9:	47                   	inc    %edi
  8006da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006de:	83 f8 25             	cmp    $0x25,%eax
  8006e1:	0f 84 46 fc ff ff    	je     80032d <vprintfmt+0x17>
			if (ch == '\0')
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	0f 84 89 00 00 00    	je     800778 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	50                   	push   %eax
  8006f4:	ff d6                	call   *%esi
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb de                	jmp    8006d9 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7e 15                	jle    800715 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8b 10                	mov    (%eax),%edx
  800705:	8b 48 04             	mov    0x4(%eax),%ecx
  800708:	8d 40 08             	lea    0x8(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
  800713:	eb a7                	jmp    8006bc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800715:	85 c9                	test   %ecx,%ecx
  800717:	75 17                	jne    800730 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800729:	b8 10 00 00 00       	mov    $0x10,%eax
  80072e:	eb 8c                	jmp    8006bc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800740:	b8 10 00 00 00       	mov    $0x10,%eax
  800745:	e9 72 ff ff ff       	jmp    8006bc <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 25                	push   $0x25
  800750:	ff d6                	call   *%esi
			break;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	e9 7c ff ff ff       	jmp    8006d6 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 25                	push   $0x25
  800760:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	89 f8                	mov    %edi,%eax
  800767:	eb 01                	jmp    80076a <vprintfmt+0x454>
  800769:	48                   	dec    %eax
  80076a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076e:	75 f9                	jne    800769 <vprintfmt+0x453>
  800770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800773:	e9 5e ff ff ff       	jmp    8006d6 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800778:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 18             	sub    $0x18,%esp
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800793:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 26                	je     8007c7 <vsnprintf+0x47>
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	7e 29                	jle    8007ce <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a5:	ff 75 14             	pushl  0x14(%ebp)
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	68 dd 02 80 00       	push   $0x8002dd
  8007b4:	e8 5d fb ff ff       	call   800316 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c2:	83 c4 10             	add    $0x10,%esp
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cc:	eb f7                	jmp    8007c5 <vsnprintf+0x45>
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d3:	eb f0                	jmp    8007c5 <vsnprintf+0x45>

008007d5 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007de:	50                   	push   %eax
  8007df:	ff 75 10             	pushl  0x10(%ebp)
  8007e2:	ff 75 0c             	pushl  0xc(%ebp)
  8007e5:	ff 75 08             	pushl  0x8(%ebp)
  8007e8:	e8 93 ff ff ff       	call   800780 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 01                	jmp    8007fe <strlen+0xe>
		n++;
  8007fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800802:	75 f9                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 01                	jmp    800817 <strnlen+0x11>
		n++;
  800816:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	39 d0                	cmp    %edx,%eax
  800819:	74 06                	je     800821 <strnlen+0x1b>
  80081b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081f:	75 f5                	jne    800816 <strnlen+0x10>
		n++;
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	89 c2                	mov    %eax,%edx
  80082f:	41                   	inc    %ecx
  800830:	42                   	inc    %edx
  800831:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800834:	88 5a ff             	mov    %bl,-0x1(%edx)
  800837:	84 db                	test   %bl,%bl
  800839:	75 f4                	jne    80082f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800845:	53                   	push   %ebx
  800846:	e8 a5 ff ff ff       	call   8007f0 <strlen>
  80084b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	50                   	push   %eax
  800854:	e8 ca ff ff ff       	call   800823 <strcpy>
	return dst;
}
  800859:	89 d8                	mov    %ebx,%eax
  80085b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	89 f3                	mov    %esi,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	89 f2                	mov    %esi,%edx
  800872:	39 da                	cmp    %ebx,%edx
  800874:	74 0e                	je     800884 <strncpy+0x24>
		*dst++ = *src;
  800876:	42                   	inc    %edx
  800877:	8a 01                	mov    (%ecx),%al
  800879:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80087c:	80 39 00             	cmpb   $0x0,(%ecx)
  80087f:	74 f1                	je     800872 <strncpy+0x12>
			src++;
  800881:	41                   	inc    %ecx
  800882:	eb ee                	jmp    800872 <strncpy+0x12>
	}
	return ret;
}
  800884:	89 f0                	mov    %esi,%eax
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 75 08             	mov    0x8(%ebp),%esi
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	85 c0                	test   %eax,%eax
  80089a:	74 20                	je     8008bc <strlcpy+0x32>
  80089c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	eb 05                	jmp    8008a9 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a4:	42                   	inc    %edx
  8008a5:	40                   	inc    %eax
  8008a6:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 06                	je     8008b3 <strlcpy+0x29>
  8008ad:	8a 0a                	mov    (%edx),%cl
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	75 f1                	jne    8008a4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b6:	29 f0                	sub    %esi,%eax
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	eb f6                	jmp    8008b6 <strlcpy+0x2c>

008008c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c9:	eb 02                	jmp    8008cd <strcmp+0xd>
		p++, q++;
  8008cb:	41                   	inc    %ecx
  8008cc:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cd:	8a 01                	mov    (%ecx),%al
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x17>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 f4                	je     8008cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 02                	jmp    8008f4 <strncmp+0x13>
		n--, p++, q++;
  8008f2:	40                   	inc    %eax
  8008f3:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f4:	39 d8                	cmp    %ebx,%eax
  8008f6:	74 15                	je     80090d <strncmp+0x2c>
  8008f8:	8a 08                	mov    (%eax),%cl
  8008fa:	84 c9                	test   %cl,%cl
  8008fc:	74 04                	je     800902 <strncmp+0x21>
  8008fe:	3a 0a                	cmp    (%edx),%cl
  800900:	74 f0                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800902:	0f b6 00             	movzbl (%eax),%eax
  800905:	0f b6 12             	movzbl (%edx),%edx
  800908:	29 d0                	sub    %edx,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb f6                	jmp    80090a <strncmp+0x29>

00800914 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	74 07                	je     80092a <strchr+0x16>
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 08                	je     80092f <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800927:	40                   	inc    %eax
  800928:	eb f3                	jmp    80091d <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	74 07                	je     800947 <strfind+0x16>
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 03                	je     800947 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800944:	40                   	inc    %eax
  800945:	eb f3                	jmp    80093a <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 13                	je     80096c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 05                	jne    800966 <memset+0x1d>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	74 0d                	je     800973 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d0                	mov    %edx,%eax
  80097e:	c1 e0 18             	shl    $0x18,%eax
  800981:	89 d6                	mov    %edx,%esi
  800983:	c1 e6 10             	shl    $0x10,%esi
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
  80098a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098f:	89 d0                	mov    %edx,%eax
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb d6                	jmp    80096c <memset+0x23>

00800996 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a4:	39 c6                	cmp    %eax,%esi
  8009a6:	73 33                	jae    8009db <memmove+0x45>
  8009a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ab:	39 c2                	cmp    %eax,%edx
  8009ad:	76 2c                	jbe    8009db <memmove+0x45>
		s += n;
		d += n;
  8009af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	09 fe                	or     %edi,%esi
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	74 0a                	je     8009c8 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009be:	4f                   	dec    %edi
  8009bf:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c5:	fc                   	cld    
  8009c6:	eb 21                	jmp    8009e9 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	f6 c1 03             	test   $0x3,%cl
  8009cb:	75 f1                	jne    8009be <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cd:	83 ef 04             	sub    $0x4,%edi
  8009d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d6:	fd                   	std    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb ea                	jmp    8009c5 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	f6 c2 03             	test   $0x3,%dl
  8009e2:	74 09                	je     8009ed <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 f2                	jne    8009e4 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb ed                	jmp    8009e9 <memmove+0x53>

008009fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ff:	ff 75 10             	pushl  0x10(%ebp)
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	ff 75 08             	pushl  0x8(%ebp)
  800a08:	e8 89 ff ff ff       	call   800996 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c6                	mov    %eax,%esi
  800a1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 f0                	cmp    %esi,%eax
  800a21:	74 16                	je     800a39 <memcmp+0x2a>
		if (*s1 != *s2)
  800a23:	8a 08                	mov    (%eax),%cl
  800a25:	8a 1a                	mov    (%edx),%bl
  800a27:	38 d9                	cmp    %bl,%cl
  800a29:	75 04                	jne    800a2f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2b:	40                   	inc    %eax
  800a2c:	42                   	inc    %edx
  800a2d:	eb f0                	jmp    800a1f <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a2f:	0f b6 c1             	movzbl %cl,%eax
  800a32:	0f b6 db             	movzbl %bl,%ebx
  800a35:	29 d8                	sub    %ebx,%eax
  800a37:	eb 05                	jmp    800a3e <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	73 07                	jae    800a5b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a54:	38 08                	cmp    %cl,(%eax)
  800a56:	74 03                	je     800a5b <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a58:	40                   	inc    %eax
  800a59:	eb f5                	jmp    800a50 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	eb 01                	jmp    800a69 <strtol+0xc>
		s++;
  800a68:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	8a 01                	mov    (%ecx),%al
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f9                	je     800a68 <strtol+0xb>
  800a6f:	3c 09                	cmp    $0x9,%al
  800a71:	74 f5                	je     800a68 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	74 2b                	je     800aa2 <strtol+0x45>
		s++;
	else if (*s == '-')
  800a77:	3c 2d                	cmp    $0x2d,%al
  800a79:	74 2f                	je     800aaa <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a87:	75 12                	jne    800a9b <strtol+0x3e>
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	74 24                	je     800ab2 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a92:	75 07                	jne    800a9b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a94:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	eb 4e                	jmp    800af0 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800aa2:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa8:	eb d6                	jmp    800a80 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800aaa:	41                   	inc    %ecx
  800aab:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab0:	eb ce                	jmp    800a80 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab6:	74 10                	je     800ac8 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800abc:	75 dd                	jne    800a9b <strtol+0x3e>
		s++, base = 8;
  800abe:	41                   	inc    %ecx
  800abf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ac6:	eb d3                	jmp    800a9b <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ad2:	eb c7                	jmp    800a9b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 24                	ja     800b02 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	39 55 10             	cmp    %edx,0x10(%ebp)
  800ae7:	7e 2b                	jle    800b14 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800ae9:	41                   	inc    %ecx
  800aea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aee:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	8a 11                	mov    (%ecx),%dl
  800af2:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800af5:	80 fb 09             	cmp    $0x9,%bl
  800af8:	77 da                	ja     800ad4 <strtol+0x77>
			dig = *s - '0';
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 30             	sub    $0x30,%edx
  800b00:	eb e2                	jmp    800ae4 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 37             	sub    $0x37,%edx
  800b12:	eb d0                	jmp    800ae4 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b18:	74 05                	je     800b1f <strtol+0xc2>
		*endptr = (char *) s;
  800b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1f:	85 ff                	test   %edi,%edi
  800b21:	74 02                	je     800b25 <strtol+0xc8>
  800b23:	f7 d8                	neg    %eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    
	...

00800b2c <__udivdi3>:
  800b2c:	55                   	push   %ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 1c             	sub    $0x1c,%esp
  800b33:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b37:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b3b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b3f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b43:	85 d2                	test   %edx,%edx
  800b45:	75 2d                	jne    800b74 <__udivdi3+0x48>
  800b47:	39 f7                	cmp    %esi,%edi
  800b49:	77 59                	ja     800ba4 <__udivdi3+0x78>
  800b4b:	89 f9                	mov    %edi,%ecx
  800b4d:	85 ff                	test   %edi,%edi
  800b4f:	75 0b                	jne    800b5c <__udivdi3+0x30>
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	31 d2                	xor    %edx,%edx
  800b58:	f7 f7                	div    %edi
  800b5a:	89 c1                	mov    %eax,%ecx
  800b5c:	31 d2                	xor    %edx,%edx
  800b5e:	89 f0                	mov    %esi,%eax
  800b60:	f7 f1                	div    %ecx
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	89 e8                	mov    %ebp,%eax
  800b66:	f7 f1                	div    %ecx
  800b68:	89 da                	mov    %ebx,%edx
  800b6a:	83 c4 1c             	add    $0x1c,%esp
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    
  800b72:	66 90                	xchg   %ax,%ax
  800b74:	39 f2                	cmp    %esi,%edx
  800b76:	77 1c                	ja     800b94 <__udivdi3+0x68>
  800b78:	0f bd da             	bsr    %edx,%ebx
  800b7b:	83 f3 1f             	xor    $0x1f,%ebx
  800b7e:	75 38                	jne    800bb8 <__udivdi3+0x8c>
  800b80:	39 f2                	cmp    %esi,%edx
  800b82:	72 08                	jb     800b8c <__udivdi3+0x60>
  800b84:	39 ef                	cmp    %ebp,%edi
  800b86:	0f 87 98 00 00 00    	ja     800c24 <__udivdi3+0xf8>
  800b8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b91:	eb 05                	jmp    800b98 <__udivdi3+0x6c>
  800b93:	90                   	nop
  800b94:	31 db                	xor    %ebx,%ebx
  800b96:	31 c0                	xor    %eax,%eax
  800b98:	89 da                	mov    %ebx,%edx
  800b9a:	83 c4 1c             	add    $0x1c,%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    
  800ba2:	66 90                	xchg   %ax,%ax
  800ba4:	89 e8                	mov    %ebp,%eax
  800ba6:	89 f2                	mov    %esi,%edx
  800ba8:	f7 f7                	div    %edi
  800baa:	31 db                	xor    %ebx,%ebx
  800bac:	89 da                	mov    %ebx,%edx
  800bae:	83 c4 1c             	add    $0x1c,%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
  800bb6:	66 90                	xchg   %ax,%ax
  800bb8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bbd:	29 d8                	sub    %ebx,%eax
  800bbf:	88 d9                	mov    %bl,%cl
  800bc1:	d3 e2                	shl    %cl,%edx
  800bc3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bc7:	89 fa                	mov    %edi,%edx
  800bc9:	88 c1                	mov    %al,%cl
  800bcb:	d3 ea                	shr    %cl,%edx
  800bcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bd1:	09 d1                	or     %edx,%ecx
  800bd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bd7:	88 d9                	mov    %bl,%cl
  800bd9:	d3 e7                	shl    %cl,%edi
  800bdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	88 c1                	mov    %al,%cl
  800be3:	d3 ef                	shr    %cl,%edi
  800be5:	88 d9                	mov    %bl,%cl
  800be7:	d3 e6                	shl    %cl,%esi
  800be9:	89 ea                	mov    %ebp,%edx
  800beb:	88 c1                	mov    %al,%cl
  800bed:	d3 ea                	shr    %cl,%edx
  800bef:	09 d6                	or     %edx,%esi
  800bf1:	89 f0                	mov    %esi,%eax
  800bf3:	89 fa                	mov    %edi,%edx
  800bf5:	f7 74 24 08          	divl   0x8(%esp)
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	f7 64 24 0c          	mull   0xc(%esp)
  800c01:	39 d7                	cmp    %edx,%edi
  800c03:	72 13                	jb     800c18 <__udivdi3+0xec>
  800c05:	74 09                	je     800c10 <__udivdi3+0xe4>
  800c07:	89 f0                	mov    %esi,%eax
  800c09:	31 db                	xor    %ebx,%ebx
  800c0b:	eb 8b                	jmp    800b98 <__udivdi3+0x6c>
  800c0d:	8d 76 00             	lea    0x0(%esi),%esi
  800c10:	88 d9                	mov    %bl,%cl
  800c12:	d3 e5                	shl    %cl,%ebp
  800c14:	39 c5                	cmp    %eax,%ebp
  800c16:	73 ef                	jae    800c07 <__udivdi3+0xdb>
  800c18:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c1b:	31 db                	xor    %ebx,%ebx
  800c1d:	e9 76 ff ff ff       	jmp    800b98 <__udivdi3+0x6c>
  800c22:	66 90                	xchg   %ax,%ax
  800c24:	31 c0                	xor    %eax,%eax
  800c26:	e9 6d ff ff ff       	jmp    800b98 <__udivdi3+0x6c>
	...

00800c2c <__umoddi3>:
  800c2c:	55                   	push   %ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 1c             	sub    $0x1c,%esp
  800c33:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c37:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c3b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c3f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	89 da                	mov    %ebx,%edx
  800c47:	85 ed                	test   %ebp,%ebp
  800c49:	75 15                	jne    800c60 <__umoddi3+0x34>
  800c4b:	39 df                	cmp    %ebx,%edi
  800c4d:	76 39                	jbe    800c88 <__umoddi3+0x5c>
  800c4f:	f7 f7                	div    %edi
  800c51:	89 d0                	mov    %edx,%eax
  800c53:	31 d2                	xor    %edx,%edx
  800c55:	83 c4 1c             	add    $0x1c,%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
  800c5d:	8d 76 00             	lea    0x0(%esi),%esi
  800c60:	39 dd                	cmp    %ebx,%ebp
  800c62:	77 f1                	ja     800c55 <__umoddi3+0x29>
  800c64:	0f bd cd             	bsr    %ebp,%ecx
  800c67:	83 f1 1f             	xor    $0x1f,%ecx
  800c6a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c6e:	75 38                	jne    800ca8 <__umoddi3+0x7c>
  800c70:	39 dd                	cmp    %ebx,%ebp
  800c72:	72 04                	jb     800c78 <__umoddi3+0x4c>
  800c74:	39 f7                	cmp    %esi,%edi
  800c76:	77 dd                	ja     800c55 <__umoddi3+0x29>
  800c78:	89 da                	mov    %ebx,%edx
  800c7a:	89 f0                	mov    %esi,%eax
  800c7c:	29 f8                	sub    %edi,%eax
  800c7e:	19 ea                	sbb    %ebp,%edx
  800c80:	83 c4 1c             	add    $0x1c,%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    
  800c88:	89 f9                	mov    %edi,%ecx
  800c8a:	85 ff                	test   %edi,%edi
  800c8c:	75 0b                	jne    800c99 <__umoddi3+0x6d>
  800c8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c93:	31 d2                	xor    %edx,%edx
  800c95:	f7 f7                	div    %edi
  800c97:	89 c1                	mov    %eax,%ecx
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	f7 f1                	div    %ecx
  800c9f:	89 f0                	mov    %esi,%eax
  800ca1:	f7 f1                	div    %ecx
  800ca3:	eb ac                	jmp    800c51 <__umoddi3+0x25>
  800ca5:	8d 76 00             	lea    0x0(%esi),%esi
  800ca8:	b8 20 00 00 00       	mov    $0x20,%eax
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cb3:	29 c2                	sub    %eax,%edx
  800cb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cb9:	88 c1                	mov    %al,%cl
  800cbb:	d3 e5                	shl    %cl,%ebp
  800cbd:	89 f8                	mov    %edi,%eax
  800cbf:	88 d1                	mov    %dl,%cl
  800cc1:	d3 e8                	shr    %cl,%eax
  800cc3:	09 c5                	or     %eax,%ebp
  800cc5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cc9:	88 c1                	mov    %al,%cl
  800ccb:	d3 e7                	shl    %cl,%edi
  800ccd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	88 d1                	mov    %dl,%cl
  800cd5:	d3 ef                	shr    %cl,%edi
  800cd7:	88 c1                	mov    %al,%cl
  800cd9:	d3 e3                	shl    %cl,%ebx
  800cdb:	89 f0                	mov    %esi,%eax
  800cdd:	88 d1                	mov    %dl,%cl
  800cdf:	d3 e8                	shr    %cl,%eax
  800ce1:	09 d8                	or     %ebx,%eax
  800ce3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ce7:	d3 e6                	shl    %cl,%esi
  800ce9:	89 fa                	mov    %edi,%edx
  800ceb:	f7 f5                	div    %ebp
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	f7 64 24 08          	mull   0x8(%esp)
  800cf3:	89 c3                	mov    %eax,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	39 d1                	cmp    %edx,%ecx
  800cf9:	72 29                	jb     800d24 <__umoddi3+0xf8>
  800cfb:	74 23                	je     800d20 <__umoddi3+0xf4>
  800cfd:	89 ca                	mov    %ecx,%edx
  800cff:	29 de                	sub    %ebx,%esi
  800d01:	19 fa                	sbb    %edi,%edx
  800d03:	89 d0                	mov    %edx,%eax
  800d05:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d09:	d3 e0                	shl    %cl,%eax
  800d0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d0f:	88 d9                	mov    %bl,%cl
  800d11:	d3 ee                	shr    %cl,%esi
  800d13:	09 f0                	or     %esi,%eax
  800d15:	d3 ea                	shr    %cl,%edx
  800d17:	83 c4 1c             	add    $0x1c,%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    
  800d1f:	90                   	nop
  800d20:	39 c6                	cmp    %eax,%esi
  800d22:	73 d9                	jae    800cfd <__umoddi3+0xd1>
  800d24:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d28:	19 ea                	sbb    %ebp,%edx
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	eb cd                	jmp    800cfd <__umoddi3+0xd1>
