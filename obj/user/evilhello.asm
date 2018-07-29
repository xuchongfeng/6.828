
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 66 00 00 00       	call   8000ac <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800054:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800057:	e8 ce 00 00 00       	call   80012a <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800064:	01 d0                	add    %edx,%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x32>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 44 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 46 0d 80 00       	push   $0x800d46
  80011e:	6a 23                	push   $0x23
  800120:	68 63 0d 80 00       	push   $0x800d63
  800125:	e8 22 00 00 00       	call   80014c <_panic>

0080012a <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80015a:	e8 cb ff ff ff       	call   80012a <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 74 0d 80 00       	push   $0x800d74
  80016f:	e8 b4 00 00 00       	call   800228 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	pushl  0x10(%ebp)
  80017b:	e8 57 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 98 0d 80 00 	movl   $0x800d98,(%esp)
  800187:	e8 9c 00 00 00       	call   800228 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>
	...

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 04             	sub    $0x4,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 13                	mov    (%ebx),%edx
  8001a0:	8d 42 01             	lea    0x1(%edx),%eax
  8001a3:	89 03                	mov    %eax,(%ebx)
  8001a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b1:	74 08                	je     8001bb <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b3:	ff 43 04             	incl   0x4(%ebx)
}
  8001b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	68 ff 00 00 00       	push   $0xff
  8001c3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 e0 fe ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8001cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	eb dc                	jmp    8001b3 <putch+0x1f>

008001d7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	ff 75 08             	pushl  0x8(%ebp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	68 94 01 80 00       	push   $0x800194
  800206:	e8 17 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020b:	83 c4 08             	add    $0x8,%esp
  80020e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800214:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021a:	50                   	push   %eax
  80021b:	e8 8c fe ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800220:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800231:	50                   	push   %eax
  800232:	ff 75 08             	pushl  0x8(%ebp)
  800235:	e8 9d ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 1c             	sub    $0x1c,%esp
  800245:	89 c7                	mov    %eax,%edi
  800247:	89 d6                	mov    %edx,%esi
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800252:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800260:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800263:	39 d3                	cmp    %edx,%ebx
  800265:	72 05                	jb     80026c <printnum+0x30>
  800267:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026a:	77 78                	ja     8002e4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	8b 45 14             	mov    0x14(%ebp),%eax
  800275:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800278:	53                   	push   %ebx
  800279:	ff 75 10             	pushl  0x10(%ebp)
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800282:	ff 75 e0             	pushl  -0x20(%ebp)
  800285:	ff 75 dc             	pushl  -0x24(%ebp)
  800288:	ff 75 d8             	pushl  -0x28(%ebp)
  80028b:	e8 a8 08 00 00       	call   800b38 <__udivdi3>
  800290:	83 c4 18             	add    $0x18,%esp
  800293:	52                   	push   %edx
  800294:	50                   	push   %eax
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 9e ff ff ff       	call   80023c <printnum>
  80029e:	83 c4 20             	add    $0x20,%esp
  8002a1:	eb 11                	jmp    8002b4 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	ff d7                	call   *%edi
  8002ac:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	4b                   	dec    %ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ef                	jg     8002a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002be:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c7:	e8 6c 09 00 00       	call   800c38 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 9a 0d 80 00 	movsbl 0x800d9a(%eax),%eax
  8002d6:	50                   	push   %eax
  8002d7:	ff d7                	call   *%edi
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    
  8002e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e7:	eb c6                	jmp    8002af <printnum+0x73>

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f7:	73 0a                	jae    800303 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	88 02                	mov    %al,(%edx)
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	e8 05 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 2c             	sub    $0x2c,%esp
  80032b:	8b 75 08             	mov    0x8(%ebp),%esi
  80032e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800331:	8b 7d 10             	mov    0x10(%ebp),%edi
  800334:	e9 ac 03 00 00       	jmp    8006e5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800339:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80033d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800344:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80034b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8d 47 01             	lea    0x1(%edi),%eax
  80035a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035d:	8a 17                	mov    (%edi),%dl
  80035f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800362:	3c 55                	cmp    $0x55,%al
  800364:	0f 87 fc 03 00 00    	ja     800766 <vprintfmt+0x444>
  80036a:	0f b6 c0             	movzbl %al,%eax
  80036d:	ff 24 85 28 0e 80 00 	jmp    *0x800e28(,%eax,4)
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800377:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037b:	eb da                	jmp    800357 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800380:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800384:	eb d1                	jmp    800357 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	0f b6 d2             	movzbl %dl,%edx
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	01 c0                	add    %eax,%eax
  800399:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80039d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a3:	83 f9 09             	cmp    $0x9,%ecx
  8003a6:	77 52                	ja     8003fa <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a8:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 40 04             	lea    0x4(%eax),%eax
  8003b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	79 92                	jns    800357 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d2:	eb 83                	jmp    800357 <vprintfmt+0x35>
  8003d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d8:	78 08                	js     8003e2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dd:	e9 75 ff ff ff       	jmp    800357 <vprintfmt+0x35>
  8003e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e9:	eb ef                	jmp    8003da <vprintfmt+0xb8>
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f5:	e9 5d ff ff ff       	jmp    800357 <vprintfmt+0x35>
  8003fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	eb bd                	jmp    8003bf <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800402:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800406:	e9 4c ff ff ff       	jmp    800357 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 78 04             	lea    0x4(%eax),%edi
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 30                	pushl  (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041f:	e9 be 02 00 00       	jmp    8006e2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	85 c0                	test   %eax,%eax
  80042e:	78 2a                	js     80045a <vprintfmt+0x138>
  800430:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 06             	cmp    $0x6,%eax
  800435:	7f 27                	jg     80045e <vprintfmt+0x13c>
  800437:	8b 04 85 80 0f 80 00 	mov    0x800f80(,%eax,4),%eax
  80043e:	85 c0                	test   %eax,%eax
  800440:	74 1c                	je     80045e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800442:	50                   	push   %eax
  800443:	68 bb 0d 80 00       	push   $0x800dbb
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 b6 fe ff ff       	call   800305 <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800452:	89 7d 14             	mov    %edi,0x14(%ebp)
  800455:	e9 88 02 00 00       	jmp    8006e2 <vprintfmt+0x3c0>
  80045a:	f7 d8                	neg    %eax
  80045c:	eb d2                	jmp    800430 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045e:	52                   	push   %edx
  80045f:	68 b2 0d 80 00       	push   $0x800db2
  800464:	53                   	push   %ebx
  800465:	56                   	push   %esi
  800466:	e8 9a fe ff ff       	call   800305 <printfmt>
  80046b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800471:	e9 6c 02 00 00       	jmp    8006e2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	83 c0 04             	add    $0x4,%eax
  80047c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8b 38                	mov    (%eax),%edi
  800484:	85 ff                	test   %edi,%edi
  800486:	74 18                	je     8004a0 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800488:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048c:	0f 8e b7 00 00 00    	jle    800549 <vprintfmt+0x227>
  800492:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800496:	75 0f                	jne    8004a7 <vprintfmt+0x185>
  800498:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80049e:	eb 75                	jmp    800515 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8004a0:	bf ab 0d 80 00       	mov    $0x800dab,%edi
  8004a5:	eb e1                	jmp    800488 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 5f 03 00 00       	call   800812 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0d                	jmp    8004d9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	4f                   	dec    %edi
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	7f ef                	jg     8004cc <vprintfmt+0x1aa>
  8004dd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e3:	89 c8                	mov    %ecx,%eax
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	78 10                	js     8004f9 <vprintfmt+0x1d7>
  8004e9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ec:	29 c1                	sub    %eax,%ecx
  8004ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f7:	eb 1c                	jmp    800515 <vprintfmt+0x1f3>
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	eb e9                	jmp    8004e9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	75 29                	jne    80052f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	50                   	push   %eax
  80050d:	ff d6                	call   *%esi
  80050f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	ff 4d e0             	decl   -0x20(%ebp)
  800515:	47                   	inc    %edi
  800516:	8a 57 ff             	mov    -0x1(%edi),%dl
  800519:	0f be c2             	movsbl %dl,%eax
  80051c:	85 c0                	test   %eax,%eax
  80051e:	74 4c                	je     80056c <vprintfmt+0x24a>
  800520:	85 db                	test   %ebx,%ebx
  800522:	78 dc                	js     800500 <vprintfmt+0x1de>
  800524:	4b                   	dec    %ebx
  800525:	79 d9                	jns    800500 <vprintfmt+0x1de>
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052d:	eb 2e                	jmp    80055d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	0f be d2             	movsbl %dl,%edx
  800532:	83 ea 20             	sub    $0x20,%edx
  800535:	83 fa 5e             	cmp    $0x5e,%edx
  800538:	76 cc                	jbe    800506 <vprintfmt+0x1e4>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff d6                	call   *%esi
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	eb c9                	jmp    800512 <vprintfmt+0x1f0>
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80054f:	eb c4                	jmp    800515 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	6a 20                	push   $0x20
  800557:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800559:	4f                   	dec    %edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 ff                	test   %edi,%edi
  80055f:	7f f0                	jg     800551 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800561:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	e9 76 01 00 00       	jmp    8006e2 <vprintfmt+0x3c0>
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	eb e9                	jmp    80055d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800574:	83 f9 01             	cmp    $0x1,%ecx
  800577:	7e 3f                	jle    8005b8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 50 04             	mov    0x4(%eax),%edx
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 40 08             	lea    0x8(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800590:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800594:	79 5c                	jns    8005f2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 2d                	push   $0x2d
  80059c:	ff d6                	call   *%esi
				num = -(long long) num;
  80059e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a4:	f7 da                	neg    %edx
  8005a6:	83 d1 00             	adc    $0x0,%ecx
  8005a9:	f7 d9                	neg    %ecx
  8005ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 10 01 00 00       	jmp    8006c8 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005b8:	85 c9                	test   %ecx,%ecx
  8005ba:	75 1b                	jne    8005d7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	89 c1                	mov    %eax,%ecx
  8005c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb b9                	jmp    800590 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 c1                	mov    %eax,%ecx
  8005e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f0:	eb 9e                	jmp    800590 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 c6 00 00 00       	jmp    8006c8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800602:	83 f9 01             	cmp    $0x1,%ecx
  800605:	7e 18                	jle    80061f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	8b 48 04             	mov    0x4(%eax),%ecx
  80060f:	8d 40 08             	lea    0x8(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	e9 a9 00 00 00       	jmp    8006c8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	75 1a                	jne    80063d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	e9 8b 00 00 00       	jmp    8006c8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800652:	eb 74                	jmp    8006c8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800654:	83 f9 01             	cmp    $0x1,%ecx
  800657:	7e 15                	jle    80066e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8b 48 04             	mov    0x4(%eax),%ecx
  800661:	8d 40 08             	lea    0x8(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800667:	b8 08 00 00 00       	mov    $0x8,%eax
  80066c:	eb 5a                	jmp    8006c8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	75 17                	jne    800689 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800682:	b8 08 00 00 00       	mov    $0x8,%eax
  800687:	eb 3f                	jmp    8006c8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 10                	mov    (%eax),%edx
  80068e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800699:	b8 08 00 00 00       	mov    $0x8,%eax
  80069e:	eb 28                	jmp    8006c8 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 30                	push   $0x30
  8006a6:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a8:	83 c4 08             	add    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 78                	push   $0x78
  8006ae:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ba:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cf:	57                   	push   %edi
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 5d fb ff ff       	call   80023c <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e5:	47                   	inc    %edi
  8006e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ea:	83 f8 25             	cmp    $0x25,%eax
  8006ed:	0f 84 46 fc ff ff    	je     800339 <vprintfmt+0x17>
			if (ch == '\0')
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	0f 84 89 00 00 00    	je     800784 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	50                   	push   %eax
  800700:	ff d6                	call   *%esi
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb de                	jmp    8006e5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800707:	83 f9 01             	cmp    $0x1,%ecx
  80070a:	7e 15                	jle    800721 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	8b 48 04             	mov    0x4(%eax),%ecx
  800714:	8d 40 08             	lea    0x8(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
  80071f:	eb a7                	jmp    8006c8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800721:	85 c9                	test   %ecx,%ecx
  800723:	75 17                	jne    80073c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800735:	b8 10 00 00 00       	mov    $0x10,%eax
  80073a:	eb 8c                	jmp    8006c8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80074c:	b8 10 00 00 00       	mov    $0x10,%eax
  800751:	e9 72 ff ff ff       	jmp    8006c8 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 25                	push   $0x25
  80075c:	ff d6                	call   *%esi
			break;
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	e9 7c ff ff ff       	jmp    8006e2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 25                	push   $0x25
  80076c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	89 f8                	mov    %edi,%eax
  800773:	eb 01                	jmp    800776 <vprintfmt+0x454>
  800775:	48                   	dec    %eax
  800776:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077a:	75 f9                	jne    800775 <vprintfmt+0x453>
  80077c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80077f:	e9 5e ff ff ff       	jmp    8006e2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800784:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5f                   	pop    %edi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	83 ec 18             	sub    $0x18,%esp
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800798:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	74 26                	je     8007d3 <vsnprintf+0x47>
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	7e 29                	jle    8007da <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b1:	ff 75 14             	pushl  0x14(%ebp)
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ba:	50                   	push   %eax
  8007bb:	68 e9 02 80 00       	push   $0x8002e9
  8007c0:	e8 5d fb ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ce:	83 c4 10             	add    $0x10,%esp
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d8:	eb f7                	jmp    8007d1 <vsnprintf+0x45>
  8007da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007df:	eb f0                	jmp    8007d1 <vsnprintf+0x45>

008007e1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 10             	pushl  0x10(%ebp)
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 93 ff ff ff       	call   80078c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
	...

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 01                	jmp    80080a <strlen+0xe>
		n++;
  800809:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080e:	75 f9                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 01                	jmp    800823 <strnlen+0x11>
		n++;
  800822:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	39 d0                	cmp    %edx,%eax
  800825:	74 06                	je     80082d <strnlen+0x1b>
  800827:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082b:	75 f5                	jne    800822 <strnlen+0x10>
		n++;
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	89 c2                	mov    %eax,%edx
  80083b:	41                   	inc    %ecx
  80083c:	42                   	inc    %edx
  80083d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800840:	88 5a ff             	mov    %bl,-0x1(%edx)
  800843:	84 db                	test   %bl,%bl
  800845:	75 f4                	jne    80083b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	53                   	push   %ebx
  800852:	e8 a5 ff ff ff       	call   8007fc <strlen>
  800857:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	50                   	push   %eax
  800860:	e8 ca ff ff ff       	call   80082f <strcpy>
	return dst;
}
  800865:	89 d8                	mov    %ebx,%eax
  800867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	89 f3                	mov    %esi,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	39 da                	cmp    %ebx,%edx
  800880:	74 0e                	je     800890 <strncpy+0x24>
		*dst++ = *src;
  800882:	42                   	inc    %edx
  800883:	8a 01                	mov    (%ecx),%al
  800885:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800888:	80 39 00             	cmpb   $0x0,(%ecx)
  80088b:	74 f1                	je     80087e <strncpy+0x12>
			src++;
  80088d:	41                   	inc    %ecx
  80088e:	eb ee                	jmp    80087e <strncpy+0x12>
	}
	return ret;
}
  800890:	89 f0                	mov    %esi,%eax
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 20                	je     8008c8 <strlcpy+0x32>
  8008a8:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	eb 05                	jmp    8008b5 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b0:	42                   	inc    %edx
  8008b1:	40                   	inc    %eax
  8008b2:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b5:	39 d8                	cmp    %ebx,%eax
  8008b7:	74 06                	je     8008bf <strlcpy+0x29>
  8008b9:	8a 0a                	mov    (%edx),%cl
  8008bb:	84 c9                	test   %cl,%cl
  8008bd:	75 f1                	jne    8008b0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008bf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c2:	29 f0                	sub    %esi,%eax
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    
  8008c8:	89 f0                	mov    %esi,%eax
  8008ca:	eb f6                	jmp    8008c2 <strlcpy+0x2c>

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	eb 02                	jmp    8008d9 <strcmp+0xd>
		p++, q++;
  8008d7:	41                   	inc    %ecx
  8008d8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d9:	8a 01                	mov    (%ecx),%al
  8008db:	84 c0                	test   %al,%al
  8008dd:	74 04                	je     8008e3 <strcmp+0x17>
  8008df:	3a 02                	cmp    (%edx),%al
  8008e1:	74 f4                	je     8008d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 c0             	movzbl %al,%eax
  8008e6:	0f b6 12             	movzbl (%edx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fc:	eb 02                	jmp    800900 <strncmp+0x13>
		n--, p++, q++;
  8008fe:	40                   	inc    %eax
  8008ff:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800900:	39 d8                	cmp    %ebx,%eax
  800902:	74 15                	je     800919 <strncmp+0x2c>
  800904:	8a 08                	mov    (%eax),%cl
  800906:	84 c9                	test   %cl,%cl
  800908:	74 04                	je     80090e <strncmp+0x21>
  80090a:	3a 0a                	cmp    (%edx),%cl
  80090c:	74 f0                	je     8008fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	0f b6 00             	movzbl (%eax),%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb f6                	jmp    800916 <strncmp+0x29>

00800920 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800929:	8a 10                	mov    (%eax),%dl
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 07                	je     800936 <strchr+0x16>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 08                	je     80093b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800933:	40                   	inc    %eax
  800934:	eb f3                	jmp    800929 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800946:	8a 10                	mov    (%eax),%dl
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 07                	je     800953 <strfind+0x16>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 03                	je     800953 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800950:	40                   	inc    %eax
  800951:	eb f3                	jmp    800946 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800961:	85 c9                	test   %ecx,%ecx
  800963:	74 13                	je     800978 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096b:	75 05                	jne    800972 <memset+0x1d>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	74 0d                	je     80097f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  80097f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800983:	89 d3                	mov    %edx,%ebx
  800985:	c1 e3 08             	shl    $0x8,%ebx
  800988:	89 d0                	mov    %edx,%eax
  80098a:	c1 e0 18             	shl    $0x18,%eax
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 10             	shl    $0x10,%esi
  800992:	09 f0                	or     %esi,%eax
  800994:	09 c2                	or     %eax,%edx
  800996:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800998:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	fc                   	cld    
  80099e:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a0:	eb d6                	jmp    800978 <memset+0x23>

008009a2 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b0:	39 c6                	cmp    %eax,%esi
  8009b2:	73 33                	jae    8009e7 <memmove+0x45>
  8009b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b7:	39 c2                	cmp    %eax,%edx
  8009b9:	76 2c                	jbe    8009e7 <memmove+0x45>
		s += n;
		d += n;
  8009bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	09 fe                	or     %edi,%esi
  8009c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c8:	74 0a                	je     8009d4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ca:	4f                   	dec    %edi
  8009cb:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ce:	fd                   	std    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d1:	fc                   	cld    
  8009d2:	eb 21                	jmp    8009f5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 f1                	jne    8009ca <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d9:	83 ef 04             	sub    $0x4,%edi
  8009dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009df:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e2:	fd                   	std    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb ea                	jmp    8009d1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	89 f2                	mov    %esi,%edx
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	f6 c2 03             	test   $0x3,%dl
  8009ee:	74 09                	je     8009f9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	f6 c1 03             	test   $0x3,%cl
  8009fc:	75 f2                	jne    8009f0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb ed                	jmp    8009f5 <memmove+0x53>

00800a08 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0b:	ff 75 10             	pushl  0x10(%ebp)
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	ff 75 08             	pushl  0x8(%ebp)
  800a14:	e8 89 ff ff ff       	call   8009a2 <memmove>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a26:	89 c6                	mov    %eax,%esi
  800a28:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	74 16                	je     800a45 <memcmp+0x2a>
		if (*s1 != *s2)
  800a2f:	8a 08                	mov    (%eax),%cl
  800a31:	8a 1a                	mov    (%edx),%bl
  800a33:	38 d9                	cmp    %bl,%cl
  800a35:	75 04                	jne    800a3b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a37:	40                   	inc    %eax
  800a38:	42                   	inc    %edx
  800a39:	eb f0                	jmp    800a2b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a3b:	0f b6 c1             	movzbl %cl,%eax
  800a3e:	0f b6 db             	movzbl %bl,%ebx
  800a41:	29 d8                	sub    %ebx,%eax
  800a43:	eb 05                	jmp    800a4a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	73 07                	jae    800a67 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a60:	38 08                	cmp    %cl,(%eax)
  800a62:	74 03                	je     800a67 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a64:	40                   	inc    %eax
  800a65:	eb f5                	jmp    800a5c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 01                	jmp    800a75 <strtol+0xc>
		s++;
  800a74:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	8a 01                	mov    (%ecx),%al
  800a77:	3c 20                	cmp    $0x20,%al
  800a79:	74 f9                	je     800a74 <strtol+0xb>
  800a7b:	3c 09                	cmp    $0x9,%al
  800a7d:	74 f5                	je     800a74 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7f:	3c 2b                	cmp    $0x2b,%al
  800a81:	74 2b                	je     800aae <strtol+0x45>
		s++;
	else if (*s == '-')
  800a83:	3c 2d                	cmp    $0x2d,%al
  800a85:	74 2f                	je     800ab6 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a93:	75 12                	jne    800aa7 <strtol+0x3e>
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	74 24                	je     800abe <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9e:	75 07                	jne    800aa7 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	eb 4e                	jmp    800afc <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800aae:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab4:	eb d6                	jmp    800a8c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800ab6:	41                   	inc    %ecx
  800ab7:	bf 01 00 00 00       	mov    $0x1,%edi
  800abc:	eb ce                	jmp    800a8c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac2:	74 10                	je     800ad4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac8:	75 dd                	jne    800aa7 <strtol+0x3e>
		s++, base = 8;
  800aca:	41                   	inc    %ecx
  800acb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ad2:	eb d3                	jmp    800aa7 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ad4:	83 c1 02             	add    $0x2,%ecx
  800ad7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ade:	eb c7                	jmp    800aa7 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 24                	ja     800b0e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aea:	0f be d2             	movsbl %dl,%edx
  800aed:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800af3:	7e 2b                	jle    800b20 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800af5:	41                   	inc    %ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afc:	8a 11                	mov    (%ecx),%dl
  800afe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b01:	80 fb 09             	cmp    $0x9,%bl
  800b04:	77 da                	ja     800ae0 <strtol+0x77>
			dig = *s - '0';
  800b06:	0f be d2             	movsbl %dl,%edx
  800b09:	83 ea 30             	sub    $0x30,%edx
  800b0c:	eb e2                	jmp    800af0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 08                	ja     800b20 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b18:	0f be d2             	movsbl %dl,%edx
  800b1b:	83 ea 37             	sub    $0x37,%edx
  800b1e:	eb d0                	jmp    800af0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 05                	je     800b2b <strtol+0xc2>
		*endptr = (char *) s;
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	74 02                	je     800b31 <strtol+0xc8>
  800b2f:	f7 d8                	neg    %eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
	...

00800b38 <__udivdi3>:
  800b38:	55                   	push   %ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	83 ec 1c             	sub    $0x1c,%esp
  800b3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b4f:	85 d2                	test   %edx,%edx
  800b51:	75 2d                	jne    800b80 <__udivdi3+0x48>
  800b53:	39 f7                	cmp    %esi,%edi
  800b55:	77 59                	ja     800bb0 <__udivdi3+0x78>
  800b57:	89 f9                	mov    %edi,%ecx
  800b59:	85 ff                	test   %edi,%edi
  800b5b:	75 0b                	jne    800b68 <__udivdi3+0x30>
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	31 d2                	xor    %edx,%edx
  800b64:	f7 f7                	div    %edi
  800b66:	89 c1                	mov    %eax,%ecx
  800b68:	31 d2                	xor    %edx,%edx
  800b6a:	89 f0                	mov    %esi,%eax
  800b6c:	f7 f1                	div    %ecx
  800b6e:	89 c3                	mov    %eax,%ebx
  800b70:	89 e8                	mov    %ebp,%eax
  800b72:	f7 f1                	div    %ecx
  800b74:	89 da                	mov    %ebx,%edx
  800b76:	83 c4 1c             	add    $0x1c,%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    
  800b7e:	66 90                	xchg   %ax,%ax
  800b80:	39 f2                	cmp    %esi,%edx
  800b82:	77 1c                	ja     800ba0 <__udivdi3+0x68>
  800b84:	0f bd da             	bsr    %edx,%ebx
  800b87:	83 f3 1f             	xor    $0x1f,%ebx
  800b8a:	75 38                	jne    800bc4 <__udivdi3+0x8c>
  800b8c:	39 f2                	cmp    %esi,%edx
  800b8e:	72 08                	jb     800b98 <__udivdi3+0x60>
  800b90:	39 ef                	cmp    %ebp,%edi
  800b92:	0f 87 98 00 00 00    	ja     800c30 <__udivdi3+0xf8>
  800b98:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9d:	eb 05                	jmp    800ba4 <__udivdi3+0x6c>
  800b9f:	90                   	nop
  800ba0:	31 db                	xor    %ebx,%ebx
  800ba2:	31 c0                	xor    %eax,%eax
  800ba4:	89 da                	mov    %ebx,%edx
  800ba6:	83 c4 1c             	add    $0x1c,%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    
  800bae:	66 90                	xchg   %ax,%ax
  800bb0:	89 e8                	mov    %ebp,%eax
  800bb2:	89 f2                	mov    %esi,%edx
  800bb4:	f7 f7                	div    %edi
  800bb6:	31 db                	xor    %ebx,%ebx
  800bb8:	89 da                	mov    %ebx,%edx
  800bba:	83 c4 1c             	add    $0x1c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    
  800bc2:	66 90                	xchg   %ax,%ax
  800bc4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bc9:	29 d8                	sub    %ebx,%eax
  800bcb:	88 d9                	mov    %bl,%cl
  800bcd:	d3 e2                	shl    %cl,%edx
  800bcf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bd3:	89 fa                	mov    %edi,%edx
  800bd5:	88 c1                	mov    %al,%cl
  800bd7:	d3 ea                	shr    %cl,%edx
  800bd9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bdd:	09 d1                	or     %edx,%ecx
  800bdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800be3:	88 d9                	mov    %bl,%cl
  800be5:	d3 e7                	shl    %cl,%edi
  800be7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800beb:	89 f7                	mov    %esi,%edi
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ef                	shr    %cl,%edi
  800bf1:	88 d9                	mov    %bl,%cl
  800bf3:	d3 e6                	shl    %cl,%esi
  800bf5:	89 ea                	mov    %ebp,%edx
  800bf7:	88 c1                	mov    %al,%cl
  800bf9:	d3 ea                	shr    %cl,%edx
  800bfb:	09 d6                	or     %edx,%esi
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	89 fa                	mov    %edi,%edx
  800c01:	f7 74 24 08          	divl   0x8(%esp)
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	f7 64 24 0c          	mull   0xc(%esp)
  800c0d:	39 d7                	cmp    %edx,%edi
  800c0f:	72 13                	jb     800c24 <__udivdi3+0xec>
  800c11:	74 09                	je     800c1c <__udivdi3+0xe4>
  800c13:	89 f0                	mov    %esi,%eax
  800c15:	31 db                	xor    %ebx,%ebx
  800c17:	eb 8b                	jmp    800ba4 <__udivdi3+0x6c>
  800c19:	8d 76 00             	lea    0x0(%esi),%esi
  800c1c:	88 d9                	mov    %bl,%cl
  800c1e:	d3 e5                	shl    %cl,%ebp
  800c20:	39 c5                	cmp    %eax,%ebp
  800c22:	73 ef                	jae    800c13 <__udivdi3+0xdb>
  800c24:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c27:	31 db                	xor    %ebx,%ebx
  800c29:	e9 76 ff ff ff       	jmp    800ba4 <__udivdi3+0x6c>
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	31 c0                	xor    %eax,%eax
  800c32:	e9 6d ff ff ff       	jmp    800ba4 <__udivdi3+0x6c>
	...

00800c38 <__umoddi3>:
  800c38:	55                   	push   %ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 1c             	sub    $0x1c,%esp
  800c3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c4b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	89 da                	mov    %ebx,%edx
  800c53:	85 ed                	test   %ebp,%ebp
  800c55:	75 15                	jne    800c6c <__umoddi3+0x34>
  800c57:	39 df                	cmp    %ebx,%edi
  800c59:	76 39                	jbe    800c94 <__umoddi3+0x5c>
  800c5b:	f7 f7                	div    %edi
  800c5d:	89 d0                	mov    %edx,%eax
  800c5f:	31 d2                	xor    %edx,%edx
  800c61:	83 c4 1c             	add    $0x1c,%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    
  800c69:	8d 76 00             	lea    0x0(%esi),%esi
  800c6c:	39 dd                	cmp    %ebx,%ebp
  800c6e:	77 f1                	ja     800c61 <__umoddi3+0x29>
  800c70:	0f bd cd             	bsr    %ebp,%ecx
  800c73:	83 f1 1f             	xor    $0x1f,%ecx
  800c76:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c7a:	75 38                	jne    800cb4 <__umoddi3+0x7c>
  800c7c:	39 dd                	cmp    %ebx,%ebp
  800c7e:	72 04                	jb     800c84 <__umoddi3+0x4c>
  800c80:	39 f7                	cmp    %esi,%edi
  800c82:	77 dd                	ja     800c61 <__umoddi3+0x29>
  800c84:	89 da                	mov    %ebx,%edx
  800c86:	89 f0                	mov    %esi,%eax
  800c88:	29 f8                	sub    %edi,%eax
  800c8a:	19 ea                	sbb    %ebp,%edx
  800c8c:	83 c4 1c             	add    $0x1c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
  800c94:	89 f9                	mov    %edi,%ecx
  800c96:	85 ff                	test   %edi,%edi
  800c98:	75 0b                	jne    800ca5 <__umoddi3+0x6d>
  800c9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9f:	31 d2                	xor    %edx,%edx
  800ca1:	f7 f7                	div    %edi
  800ca3:	89 c1                	mov    %eax,%ecx
  800ca5:	89 d8                	mov    %ebx,%eax
  800ca7:	31 d2                	xor    %edx,%edx
  800ca9:	f7 f1                	div    %ecx
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	f7 f1                	div    %ecx
  800caf:	eb ac                	jmp    800c5d <__umoddi3+0x25>
  800cb1:	8d 76 00             	lea    0x0(%esi),%esi
  800cb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800cb9:	89 c2                	mov    %eax,%edx
  800cbb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cbf:	29 c2                	sub    %eax,%edx
  800cc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc5:	88 c1                	mov    %al,%cl
  800cc7:	d3 e5                	shl    %cl,%ebp
  800cc9:	89 f8                	mov    %edi,%eax
  800ccb:	88 d1                	mov    %dl,%cl
  800ccd:	d3 e8                	shr    %cl,%eax
  800ccf:	09 c5                	or     %eax,%ebp
  800cd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd5:	88 c1                	mov    %al,%cl
  800cd7:	d3 e7                	shl    %cl,%edi
  800cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	88 d1                	mov    %dl,%cl
  800ce1:	d3 ef                	shr    %cl,%edi
  800ce3:	88 c1                	mov    %al,%cl
  800ce5:	d3 e3                	shl    %cl,%ebx
  800ce7:	89 f0                	mov    %esi,%eax
  800ce9:	88 d1                	mov    %dl,%cl
  800ceb:	d3 e8                	shr    %cl,%eax
  800ced:	09 d8                	or     %ebx,%eax
  800cef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cf3:	d3 e6                	shl    %cl,%esi
  800cf5:	89 fa                	mov    %edi,%edx
  800cf7:	f7 f5                	div    %ebp
  800cf9:	89 d1                	mov    %edx,%ecx
  800cfb:	f7 64 24 08          	mull   0x8(%esp)
  800cff:	89 c3                	mov    %eax,%ebx
  800d01:	89 d7                	mov    %edx,%edi
  800d03:	39 d1                	cmp    %edx,%ecx
  800d05:	72 29                	jb     800d30 <__umoddi3+0xf8>
  800d07:	74 23                	je     800d2c <__umoddi3+0xf4>
  800d09:	89 ca                	mov    %ecx,%edx
  800d0b:	29 de                	sub    %ebx,%esi
  800d0d:	19 fa                	sbb    %edi,%edx
  800d0f:	89 d0                	mov    %edx,%eax
  800d11:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d15:	d3 e0                	shl    %cl,%eax
  800d17:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d1b:	88 d9                	mov    %bl,%cl
  800d1d:	d3 ee                	shr    %cl,%esi
  800d1f:	09 f0                	or     %esi,%eax
  800d21:	d3 ea                	shr    %cl,%edx
  800d23:	83 c4 1c             	add    $0x1c,%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    
  800d2b:	90                   	nop
  800d2c:	39 c6                	cmp    %eax,%esi
  800d2e:	73 d9                	jae    800d09 <__umoddi3+0xd1>
  800d30:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d34:	19 ea                	sbb    %ebp,%edx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 c3                	mov    %eax,%ebx
  800d3a:	eb cd                	jmp    800d09 <__umoddi3+0xd1>
