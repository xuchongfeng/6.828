
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 65 00 00 00       	call   8000a8 <sys_cputs>
}
  800043:	83 c4 10             	add    $0x10,%esp
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800050:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800053:	e8 ce 00 00 00       	call   800126 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800060:	01 d0                	add    %edx,%eax
  800062:	c1 e0 05             	shl    $0x5,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x32>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 44 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7f 08                	jg     80010f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	50                   	push   %eax
  800113:	6a 03                	push   $0x3
  800115:	68 42 0d 80 00       	push   $0x800d42
  80011a:	6a 23                	push   $0x23
  80011c:	68 5f 0d 80 00       	push   $0x800d5f
  800121:	e8 22 00 00 00       	call   800148 <_panic>

00800126 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	57                   	push   %edi
  80012a:	56                   	push   %esi
  80012b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	ba 00 00 00 00       	mov    $0x0,%edx
  800131:	b8 02 00 00 00       	mov    $0x2,%eax
  800136:	89 d1                	mov    %edx,%ecx
  800138:	89 d3                	mov    %edx,%ebx
  80013a:	89 d7                	mov    %edx,%edi
  80013c:	89 d6                	mov    %edx,%esi
  80013e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5f                   	pop    %edi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
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
  800150:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800156:	e8 cb ff ff ff       	call   800126 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 70 0d 80 00       	push   $0x800d70
  80016b:	e8 b4 00 00 00       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 57 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 94 0d 80 00 	movl   $0x800d94,(%esp)
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
  8001c3:	e8 e0 fe ff ff       	call   8000a8 <sys_cputs>
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
  800217:	e8 8c fe ff ff       	call   8000a8 <sys_cputs>

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
  800287:	e8 a8 08 00 00       	call   800b34 <__udivdi3>
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
  8002c3:	e8 6c 09 00 00       	call   800c34 <__umoddi3>
  8002c8:	83 c4 14             	add    $0x14,%esp
  8002cb:	0f be 80 96 0d 80 00 	movsbl 0x800d96(%eax),%eax
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
  800369:	ff 24 85 24 0e 80 00 	jmp    *0x800e24(,%eax,4)
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
  80042e:	83 f8 06             	cmp    $0x6,%eax
  800431:	7f 27                	jg     80045a <vprintfmt+0x13c>
  800433:	8b 04 85 7c 0f 80 00 	mov    0x800f7c(,%eax,4),%eax
  80043a:	85 c0                	test   %eax,%eax
  80043c:	74 1c                	je     80045a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	50                   	push   %eax
  80043f:	68 b7 0d 80 00       	push   $0x800db7
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
  80045b:	68 ae 0d 80 00       	push   $0x800dae
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
  80049c:	bf a7 0d 80 00       	mov    $0x800da7,%edi
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

00800b34 <__udivdi3>:
  800b34:	55                   	push   %ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	83 ec 1c             	sub    $0x1c,%esp
  800b3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b4b:	85 d2                	test   %edx,%edx
  800b4d:	75 2d                	jne    800b7c <__udivdi3+0x48>
  800b4f:	39 f7                	cmp    %esi,%edi
  800b51:	77 59                	ja     800bac <__udivdi3+0x78>
  800b53:	89 f9                	mov    %edi,%ecx
  800b55:	85 ff                	test   %edi,%edi
  800b57:	75 0b                	jne    800b64 <__udivdi3+0x30>
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	31 d2                	xor    %edx,%edx
  800b60:	f7 f7                	div    %edi
  800b62:	89 c1                	mov    %eax,%ecx
  800b64:	31 d2                	xor    %edx,%edx
  800b66:	89 f0                	mov    %esi,%eax
  800b68:	f7 f1                	div    %ecx
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 e8                	mov    %ebp,%eax
  800b6e:	f7 f1                	div    %ecx
  800b70:	89 da                	mov    %ebx,%edx
  800b72:	83 c4 1c             	add    $0x1c,%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    
  800b7a:	66 90                	xchg   %ax,%ax
  800b7c:	39 f2                	cmp    %esi,%edx
  800b7e:	77 1c                	ja     800b9c <__udivdi3+0x68>
  800b80:	0f bd da             	bsr    %edx,%ebx
  800b83:	83 f3 1f             	xor    $0x1f,%ebx
  800b86:	75 38                	jne    800bc0 <__udivdi3+0x8c>
  800b88:	39 f2                	cmp    %esi,%edx
  800b8a:	72 08                	jb     800b94 <__udivdi3+0x60>
  800b8c:	39 ef                	cmp    %ebp,%edi
  800b8e:	0f 87 98 00 00 00    	ja     800c2c <__udivdi3+0xf8>
  800b94:	b8 01 00 00 00       	mov    $0x1,%eax
  800b99:	eb 05                	jmp    800ba0 <__udivdi3+0x6c>
  800b9b:	90                   	nop
  800b9c:	31 db                	xor    %ebx,%ebx
  800b9e:	31 c0                	xor    %eax,%eax
  800ba0:	89 da                	mov    %ebx,%edx
  800ba2:	83 c4 1c             	add    $0x1c,%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    
  800baa:	66 90                	xchg   %ax,%ax
  800bac:	89 e8                	mov    %ebp,%eax
  800bae:	89 f2                	mov    %esi,%edx
  800bb0:	f7 f7                	div    %edi
  800bb2:	31 db                	xor    %ebx,%ebx
  800bb4:	89 da                	mov    %ebx,%edx
  800bb6:	83 c4 1c             	add    $0x1c,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	b8 20 00 00 00       	mov    $0x20,%eax
  800bc5:	29 d8                	sub    %ebx,%eax
  800bc7:	88 d9                	mov    %bl,%cl
  800bc9:	d3 e2                	shl    %cl,%edx
  800bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bcf:	89 fa                	mov    %edi,%edx
  800bd1:	88 c1                	mov    %al,%cl
  800bd3:	d3 ea                	shr    %cl,%edx
  800bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bd9:	09 d1                	or     %edx,%ecx
  800bdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bdf:	88 d9                	mov    %bl,%cl
  800be1:	d3 e7                	shl    %cl,%edi
  800be3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800be7:	89 f7                	mov    %esi,%edi
  800be9:	88 c1                	mov    %al,%cl
  800beb:	d3 ef                	shr    %cl,%edi
  800bed:	88 d9                	mov    %bl,%cl
  800bef:	d3 e6                	shl    %cl,%esi
  800bf1:	89 ea                	mov    %ebp,%edx
  800bf3:	88 c1                	mov    %al,%cl
  800bf5:	d3 ea                	shr    %cl,%edx
  800bf7:	09 d6                	or     %edx,%esi
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	89 fa                	mov    %edi,%edx
  800bfd:	f7 74 24 08          	divl   0x8(%esp)
  800c01:	89 d7                	mov    %edx,%edi
  800c03:	89 c6                	mov    %eax,%esi
  800c05:	f7 64 24 0c          	mull   0xc(%esp)
  800c09:	39 d7                	cmp    %edx,%edi
  800c0b:	72 13                	jb     800c20 <__udivdi3+0xec>
  800c0d:	74 09                	je     800c18 <__udivdi3+0xe4>
  800c0f:	89 f0                	mov    %esi,%eax
  800c11:	31 db                	xor    %ebx,%ebx
  800c13:	eb 8b                	jmp    800ba0 <__udivdi3+0x6c>
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	88 d9                	mov    %bl,%cl
  800c1a:	d3 e5                	shl    %cl,%ebp
  800c1c:	39 c5                	cmp    %eax,%ebp
  800c1e:	73 ef                	jae    800c0f <__udivdi3+0xdb>
  800c20:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c23:	31 db                	xor    %ebx,%ebx
  800c25:	e9 76 ff ff ff       	jmp    800ba0 <__udivdi3+0x6c>
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	31 c0                	xor    %eax,%eax
  800c2e:	e9 6d ff ff ff       	jmp    800ba0 <__udivdi3+0x6c>
	...

00800c34 <__umoddi3>:
  800c34:	55                   	push   %ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 1c             	sub    $0x1c,%esp
  800c3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c4b:	89 f0                	mov    %esi,%eax
  800c4d:	89 da                	mov    %ebx,%edx
  800c4f:	85 ed                	test   %ebp,%ebp
  800c51:	75 15                	jne    800c68 <__umoddi3+0x34>
  800c53:	39 df                	cmp    %ebx,%edi
  800c55:	76 39                	jbe    800c90 <__umoddi3+0x5c>
  800c57:	f7 f7                	div    %edi
  800c59:	89 d0                	mov    %edx,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	83 c4 1c             	add    $0x1c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
  800c65:	8d 76 00             	lea    0x0(%esi),%esi
  800c68:	39 dd                	cmp    %ebx,%ebp
  800c6a:	77 f1                	ja     800c5d <__umoddi3+0x29>
  800c6c:	0f bd cd             	bsr    %ebp,%ecx
  800c6f:	83 f1 1f             	xor    $0x1f,%ecx
  800c72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c76:	75 38                	jne    800cb0 <__umoddi3+0x7c>
  800c78:	39 dd                	cmp    %ebx,%ebp
  800c7a:	72 04                	jb     800c80 <__umoddi3+0x4c>
  800c7c:	39 f7                	cmp    %esi,%edi
  800c7e:	77 dd                	ja     800c5d <__umoddi3+0x29>
  800c80:	89 da                	mov    %ebx,%edx
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	29 f8                	sub    %edi,%eax
  800c86:	19 ea                	sbb    %ebp,%edx
  800c88:	83 c4 1c             	add    $0x1c,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	85 ff                	test   %edi,%edi
  800c94:	75 0b                	jne    800ca1 <__umoddi3+0x6d>
  800c96:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	f7 f7                	div    %edi
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 d8                	mov    %ebx,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f1                	div    %ecx
  800ca7:	89 f0                	mov    %esi,%eax
  800ca9:	f7 f1                	div    %ecx
  800cab:	eb ac                	jmp    800c59 <__umoddi3+0x25>
  800cad:	8d 76 00             	lea    0x0(%esi),%esi
  800cb0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cb5:	89 c2                	mov    %eax,%edx
  800cb7:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cbb:	29 c2                	sub    %eax,%edx
  800cbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc1:	88 c1                	mov    %al,%cl
  800cc3:	d3 e5                	shl    %cl,%ebp
  800cc5:	89 f8                	mov    %edi,%eax
  800cc7:	88 d1                	mov    %dl,%cl
  800cc9:	d3 e8                	shr    %cl,%eax
  800ccb:	09 c5                	or     %eax,%ebp
  800ccd:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd1:	88 c1                	mov    %al,%cl
  800cd3:	d3 e7                	shl    %cl,%edi
  800cd5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	88 d1                	mov    %dl,%cl
  800cdd:	d3 ef                	shr    %cl,%edi
  800cdf:	88 c1                	mov    %al,%cl
  800ce1:	d3 e3                	shl    %cl,%ebx
  800ce3:	89 f0                	mov    %esi,%eax
  800ce5:	88 d1                	mov    %dl,%cl
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	09 d8                	or     %ebx,%eax
  800ceb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cef:	d3 e6                	shl    %cl,%esi
  800cf1:	89 fa                	mov    %edi,%edx
  800cf3:	f7 f5                	div    %ebp
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	f7 64 24 08          	mull   0x8(%esp)
  800cfb:	89 c3                	mov    %eax,%ebx
  800cfd:	89 d7                	mov    %edx,%edi
  800cff:	39 d1                	cmp    %edx,%ecx
  800d01:	72 29                	jb     800d2c <__umoddi3+0xf8>
  800d03:	74 23                	je     800d28 <__umoddi3+0xf4>
  800d05:	89 ca                	mov    %ecx,%edx
  800d07:	29 de                	sub    %ebx,%esi
  800d09:	19 fa                	sbb    %edi,%edx
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d11:	d3 e0                	shl    %cl,%eax
  800d13:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d17:	88 d9                	mov    %bl,%cl
  800d19:	d3 ee                	shr    %cl,%esi
  800d1b:	09 f0                	or     %esi,%eax
  800d1d:	d3 ea                	shr    %cl,%edx
  800d1f:	83 c4 1c             	add    $0x1c,%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    
  800d27:	90                   	nop
  800d28:	39 c6                	cmp    %eax,%esi
  800d2a:	73 d9                	jae    800d05 <__umoddi3+0xd1>
  800d2c:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d30:	19 ea                	sbb    %ebp,%edx
  800d32:	89 d7                	mov    %edx,%edi
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	eb cd                	jmp    800d05 <__umoddi3+0xd1>
