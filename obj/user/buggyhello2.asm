
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 10 80 00    	pushl  0x801000
  800045:	e8 66 00 00 00       	call   8000b0 <sys_cputs>
}
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800058:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005b:	e8 ce 00 00 00       	call   80012e <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 00             	lea    (%eax,%eax,1),%edx
  800068:	01 d0                	add    %edx,%eax
  80006a:	c1 e0 05             	shl    $0x5,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 db                	test   %ebx,%ebx
  800079:	7e 07                	jle    800082 <libmain+0x32>
		binaryname = argv[0];
  80007b:	8b 06                	mov    (%esi),%eax
  80007d:	a3 04 10 80 00       	mov    %eax,0x801004

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 44 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7f 08                	jg     800117 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	50                   	push   %eax
  80011b:	6a 03                	push   $0x3
  80011d:	68 58 0d 80 00       	push   $0x800d58
  800122:	6a 23                	push   $0x23
  800124:	68 75 0d 80 00       	push   $0x800d75
  800129:	e8 22 00 00 00       	call   800150 <_panic>

0080012e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 04 10 80 00    	mov    0x801004,%esi
  80015e:	e8 cb ff ff ff       	call   80012e <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 84 0d 80 00       	push   $0x800d84
  800173:	e8 b4 00 00 00       	call   80022c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 57 00 00 00       	call   8001db <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 4c 0d 80 00 	movl   $0x800d4c,(%esp)
  80018b:	e8 9c 00 00 00       	call   80022c <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>
	...

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 04             	sub    $0x4,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 13                	mov    (%ebx),%edx
  8001a4:	8d 42 01             	lea    0x1(%edx),%eax
  8001a7:	89 03                	mov    %eax,(%ebx)
  8001a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b5:	74 08                	je     8001bf <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	68 ff 00 00 00       	push   $0xff
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 e0 fe ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8001d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	eb dc                	jmp    8001b7 <putch+0x1f>

008001db <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001eb:	00 00 00 
	b.cnt = 0;
  8001ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f8:	ff 75 0c             	pushl  0xc(%ebp)
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	68 98 01 80 00       	push   $0x800198
  80020a:	e8 17 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020f:	83 c4 08             	add    $0x8,%esp
  800212:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800218:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021e:	50                   	push   %eax
  80021f:	e8 8c fe ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800224:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800232:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800235:	50                   	push   %eax
  800236:	ff 75 08             	pushl  0x8(%ebp)
  800239:	e8 9d ff ff ff       	call   8001db <vcprintf>
	va_end(ap);

	return cnt;
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 1c             	sub    $0x1c,%esp
  800249:	89 c7                	mov    %eax,%edi
  80024b:	89 d6                	mov    %edx,%esi
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	8b 55 0c             	mov    0xc(%ebp),%edx
  800253:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800256:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800259:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800261:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800264:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800267:	39 d3                	cmp    %edx,%ebx
  800269:	72 05                	jb     800270 <printnum+0x30>
  80026b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026e:	77 78                	ja     8002e8 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	ff 75 18             	pushl  0x18(%ebp)
  800276:	8b 45 14             	mov    0x14(%ebp),%eax
  800279:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80027c:	53                   	push   %ebx
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 a8 08 00 00       	call   800b3c <__udivdi3>
  800294:	83 c4 18             	add    $0x18,%esp
  800297:	52                   	push   %edx
  800298:	50                   	push   %eax
  800299:	89 f2                	mov    %esi,%edx
  80029b:	89 f8                	mov    %edi,%eax
  80029d:	e8 9e ff ff ff       	call   800240 <printnum>
  8002a2:	83 c4 20             	add    $0x20,%esp
  8002a5:	eb 11                	jmp    8002b8 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	ff 75 18             	pushl  0x18(%ebp)
  8002ae:	ff d7                	call   *%edi
  8002b0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b3:	4b                   	dec    %ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f ef                	jg     8002a7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cb:	e8 6c 09 00 00       	call   800c3c <__umoddi3>
  8002d0:	83 c4 14             	add    $0x14,%esp
  8002d3:	0f be 80 a8 0d 80 00 	movsbl 0x800da8(%eax),%eax
  8002da:	50                   	push   %eax
  8002db:	ff d7                	call   *%edi
}
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    
  8002e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002eb:	eb c6                	jmp    8002b3 <printnum+0x73>

008002ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fb:	73 0a                	jae    800307 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	88 02                	mov    %al,(%edx)
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800312:	50                   	push   %eax
  800313:	ff 75 10             	pushl  0x10(%ebp)
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 05 00 00 00       	call   800326 <vprintfmt>
	va_end(ap);
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 2c             	sub    $0x2c,%esp
  80032f:	8b 75 08             	mov    0x8(%ebp),%esi
  800332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800335:	8b 7d 10             	mov    0x10(%ebp),%edi
  800338:	e9 ac 03 00 00       	jmp    8006e9 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800356:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8d 47 01             	lea    0x1(%edi),%eax
  80035e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800361:	8a 17                	mov    (%edi),%dl
  800363:	8d 42 dd             	lea    -0x23(%edx),%eax
  800366:	3c 55                	cmp    $0x55,%al
  800368:	0f 87 fc 03 00 00    	ja     80076a <vprintfmt+0x444>
  80036e:	0f b6 c0             	movzbl %al,%eax
  800371:	ff 24 85 38 0e 80 00 	jmp    *0x800e38(,%eax,4)
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037f:	eb da                	jmp    80035b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800384:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800388:	eb d1                	jmp    80035b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	0f b6 d2             	movzbl %dl,%edx
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800390:	b8 00 00 00 00       	mov    $0x0,%eax
  800395:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800398:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039b:	01 c0                	add    %eax,%eax
  80039d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8003a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a7:	83 f9 09             	cmp    $0x9,%ecx
  8003aa:	77 52                	ja     8003fe <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003ad:	eb e9                	jmp    800398 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 40 04             	lea    0x4(%eax),%eax
  8003bd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c7:	79 92                	jns    80035b <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d6:	eb 83                	jmp    80035b <vprintfmt+0x35>
  8003d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003dc:	78 08                	js     8003e6 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e1:	e9 75 ff ff ff       	jmp    80035b <vprintfmt+0x35>
  8003e6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003ed:	eb ef                	jmp    8003de <vprintfmt+0xb8>
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f9:	e9 5d ff ff ff       	jmp    80035b <vprintfmt+0x35>
  8003fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800404:	eb bd                	jmp    8003c3 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800406:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040a:	e9 4c ff ff ff       	jmp    80035b <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 78 04             	lea    0x4(%eax),%edi
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 30                	pushl  (%eax)
  80041b:	ff d6                	call   *%esi
			break;
  80041d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800423:	e9 be 02 00 00       	jmp    8006e6 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	85 c0                	test   %eax,%eax
  800432:	78 2a                	js     80045e <vprintfmt+0x138>
  800434:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800436:	83 f8 06             	cmp    $0x6,%eax
  800439:	7f 27                	jg     800462 <vprintfmt+0x13c>
  80043b:	8b 04 85 90 0f 80 00 	mov    0x800f90(,%eax,4),%eax
  800442:	85 c0                	test   %eax,%eax
  800444:	74 1c                	je     800462 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800446:	50                   	push   %eax
  800447:	68 c9 0d 80 00       	push   $0x800dc9
  80044c:	53                   	push   %ebx
  80044d:	56                   	push   %esi
  80044e:	e8 b6 fe ff ff       	call   800309 <printfmt>
  800453:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	89 7d 14             	mov    %edi,0x14(%ebp)
  800459:	e9 88 02 00 00       	jmp    8006e6 <vprintfmt+0x3c0>
  80045e:	f7 d8                	neg    %eax
  800460:	eb d2                	jmp    800434 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800462:	52                   	push   %edx
  800463:	68 c0 0d 80 00       	push   $0x800dc0
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 9a fe ff ff       	call   800309 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800472:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800475:	e9 6c 02 00 00       	jmp    8006e6 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	83 c0 04             	add    $0x4,%eax
  800480:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8b 38                	mov    (%eax),%edi
  800488:	85 ff                	test   %edi,%edi
  80048a:	74 18                	je     8004a4 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	0f 8e b7 00 00 00    	jle    80054d <vprintfmt+0x227>
  800496:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049a:	75 0f                	jne    8004ab <vprintfmt+0x185>
  80049c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004a2:	eb 75                	jmp    800519 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  8004a4:	bf b9 0d 80 00       	mov    $0x800db9,%edi
  8004a9:	eb e1                	jmp    80048c <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b1:	57                   	push   %edi
  8004b2:	e8 5f 03 00 00       	call   800816 <strnlen>
  8004b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	eb 0d                	jmp    8004dd <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	4f                   	dec    %edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ef                	jg     8004d0 <vprintfmt+0x1aa>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e7:	89 c8                	mov    %ecx,%eax
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	78 10                	js     8004fd <vprintfmt+0x1d7>
  8004ed:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f0:	29 c1                	sub    %eax,%ecx
  8004f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004fb:	eb 1c                	jmp    800519 <vprintfmt+0x1f3>
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	eb e9                	jmp    8004ed <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800504:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800508:	75 29                	jne    800533 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	50                   	push   %eax
  800511:	ff d6                	call   *%esi
  800513:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800516:	ff 4d e0             	decl   -0x20(%ebp)
  800519:	47                   	inc    %edi
  80051a:	8a 57 ff             	mov    -0x1(%edi),%dl
  80051d:	0f be c2             	movsbl %dl,%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	74 4c                	je     800570 <vprintfmt+0x24a>
  800524:	85 db                	test   %ebx,%ebx
  800526:	78 dc                	js     800504 <vprintfmt+0x1de>
  800528:	4b                   	dec    %ebx
  800529:	79 d9                	jns    800504 <vprintfmt+0x1de>
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800531:	eb 2e                	jmp    800561 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800533:	0f be d2             	movsbl %dl,%edx
  800536:	83 ea 20             	sub    $0x20,%edx
  800539:	83 fa 5e             	cmp    $0x5e,%edx
  80053c:	76 cc                	jbe    80050a <vprintfmt+0x1e4>
					putch('?', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	6a 3f                	push   $0x3f
  800546:	ff d6                	call   *%esi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb c9                	jmp    800516 <vprintfmt+0x1f0>
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800553:	eb c4                	jmp    800519 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	6a 20                	push   $0x20
  80055b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055d:	4f                   	dec    %edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f f0                	jg     800555 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	e9 76 01 00 00       	jmp    8006e6 <vprintfmt+0x3c0>
  800570:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800576:	eb e9                	jmp    800561 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800578:	83 f9 01             	cmp    $0x1,%ecx
  80057b:	7e 3f                	jle    8005bc <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 50 04             	mov    0x4(%eax),%edx
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 40 08             	lea    0x8(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800594:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800598:	79 5c                	jns    8005f6 <vprintfmt+0x2d0>
				putch('-', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 2d                	push   $0x2d
  8005a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a8:	f7 da                	neg    %edx
  8005aa:	83 d1 00             	adc    $0x0,%ecx
  8005ad:	f7 d9                	neg    %ecx
  8005af:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 10 01 00 00       	jmp    8006cc <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	75 1b                	jne    8005db <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 c1                	mov    %eax,%ecx
  8005ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d9:	eb b9                	jmp    800594 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb 9e                	jmp    800594 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800601:	e9 c6 00 00 00       	jmp    8006cc <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800606:	83 f9 01             	cmp    $0x1,%ecx
  800609:	7e 18                	jle    800623 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8b 48 04             	mov    0x4(%eax),%ecx
  800613:	8d 40 08             	lea    0x8(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 a9 00 00 00       	jmp    8006cc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	75 1a                	jne    800641 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063c:	e9 8b 00 00 00       	jmp    8006cc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	eb 74                	jmp    8006cc <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800658:	83 f9 01             	cmp    $0x1,%ecx
  80065b:	7e 15                	jle    800672 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8b 48 04             	mov    0x4(%eax),%ecx
  800665:	8d 40 08             	lea    0x8(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80066b:	b8 08 00 00 00       	mov    $0x8,%eax
  800670:	eb 5a                	jmp    8006cc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800672:	85 c9                	test   %ecx,%ecx
  800674:	75 17                	jne    80068d <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
  80068b:	eb 3f                	jmp    8006cc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80069d:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a2:	eb 28                	jmp    8006cc <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 30                	push   $0x30
  8006aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 78                	push   $0x78
  8006b2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006be:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c1:	8d 40 04             	lea    0x4(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006d3:	57                   	push   %edi
  8006d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d7:	50                   	push   %eax
  8006d8:	51                   	push   %ecx
  8006d9:	52                   	push   %edx
  8006da:	89 da                	mov    %ebx,%edx
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	e8 5d fb ff ff       	call   800240 <printnum>
			break;
  8006e3:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e9:	47                   	inc    %edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	83 f8 25             	cmp    $0x25,%eax
  8006f1:	0f 84 46 fc ff ff    	je     80033d <vprintfmt+0x17>
			if (ch == '\0')
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	0f 84 89 00 00 00    	je     800788 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	50                   	push   %eax
  800704:	ff d6                	call   *%esi
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	eb de                	jmp    8006e9 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070b:	83 f9 01             	cmp    $0x1,%ecx
  80070e:	7e 15                	jle    800725 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	8b 48 04             	mov    0x4(%eax),%ecx
  800718:	8d 40 08             	lea    0x8(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071e:	b8 10 00 00 00       	mov    $0x10,%eax
  800723:	eb a7                	jmp    8006cc <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800725:	85 c9                	test   %ecx,%ecx
  800727:	75 17                	jne    800740 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800733:	8d 40 04             	lea    0x4(%eax),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800739:	b8 10 00 00 00       	mov    $0x10,%eax
  80073e:	eb 8c                	jmp    8006cc <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
  800745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800750:	b8 10 00 00 00       	mov    $0x10,%eax
  800755:	e9 72 ff ff ff       	jmp    8006cc <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 25                	push   $0x25
  800760:	ff d6                	call   *%esi
			break;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	e9 7c ff ff ff       	jmp    8006e6 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 25                	push   $0x25
  800770:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	89 f8                	mov    %edi,%eax
  800777:	eb 01                	jmp    80077a <vprintfmt+0x454>
  800779:	48                   	dec    %eax
  80077a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077e:	75 f9                	jne    800779 <vprintfmt+0x453>
  800780:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800783:	e9 5e ff ff ff       	jmp    8006e6 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5f                   	pop    %edi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 26                	je     8007d7 <vsnprintf+0x47>
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	7e 29                	jle    8007de <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b5:	ff 75 14             	pushl  0x14(%ebp)
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	68 ed 02 80 00       	push   $0x8002ed
  8007c4:	e8 5d fb ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d2:	83 c4 10             	add    $0x10,%esp
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007dc:	eb f7                	jmp    8007d5 <vsnprintf+0x45>
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e3:	eb f0                	jmp    8007d5 <vsnprintf+0x45>

008007e5 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 10             	pushl  0x10(%ebp)
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	ff 75 08             	pushl  0x8(%ebp)
  8007f8:	e8 93 ff ff ff       	call   800790 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    
	...

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 01                	jmp    80080e <strlen+0xe>
		n++;
  80080d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	75 f9                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 01                	jmp    800827 <strnlen+0x11>
		n++;
  800826:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 d0                	cmp    %edx,%eax
  800829:	74 06                	je     800831 <strnlen+0x1b>
  80082b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082f:	75 f5                	jne    800826 <strnlen+0x10>
		n++;
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083d:	89 c2                	mov    %eax,%edx
  80083f:	41                   	inc    %ecx
  800840:	42                   	inc    %edx
  800841:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800844:	88 5a ff             	mov    %bl,-0x1(%edx)
  800847:	84 db                	test   %bl,%bl
  800849:	75 f4                	jne    80083f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800855:	53                   	push   %ebx
  800856:	e8 a5 ff ff ff       	call   800800 <strlen>
  80085b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	01 d8                	add    %ebx,%eax
  800863:	50                   	push   %eax
  800864:	e8 ca ff ff ff       	call   800833 <strcpy>
	return dst;
}
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 75 08             	mov    0x8(%ebp),%esi
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	89 f2                	mov    %esi,%edx
  800882:	39 da                	cmp    %ebx,%edx
  800884:	74 0e                	je     800894 <strncpy+0x24>
		*dst++ = *src;
  800886:	42                   	inc    %edx
  800887:	8a 01                	mov    (%ecx),%al
  800889:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80088c:	80 39 00             	cmpb   $0x0,(%ecx)
  80088f:	74 f1                	je     800882 <strncpy+0x12>
			src++;
  800891:	41                   	inc    %ecx
  800892:	eb ee                	jmp    800882 <strncpy+0x12>
	}
	return ret;
}
  800894:	89 f0                	mov    %esi,%eax
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	74 20                	je     8008cc <strlcpy+0x32>
  8008ac:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	eb 05                	jmp    8008b9 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b4:	42                   	inc    %edx
  8008b5:	40                   	inc    %eax
  8008b6:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b9:	39 d8                	cmp    %ebx,%eax
  8008bb:	74 06                	je     8008c3 <strlcpy+0x29>
  8008bd:	8a 0a                	mov    (%edx),%cl
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	75 f1                	jne    8008b4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	eb f6                	jmp    8008c6 <strlcpy+0x2c>

008008d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d9:	eb 02                	jmp    8008dd <strcmp+0xd>
		p++, q++;
  8008db:	41                   	inc    %ecx
  8008dc:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008dd:	8a 01                	mov    (%ecx),%al
  8008df:	84 c0                	test   %al,%al
  8008e1:	74 04                	je     8008e7 <strcmp+0x17>
  8008e3:	3a 02                	cmp    (%edx),%al
  8008e5:	74 f4                	je     8008db <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 c0             	movzbl %al,%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	89 c3                	mov    %eax,%ebx
  8008fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800900:	eb 02                	jmp    800904 <strncmp+0x13>
		n--, p++, q++;
  800902:	40                   	inc    %eax
  800903:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800904:	39 d8                	cmp    %ebx,%eax
  800906:	74 15                	je     80091d <strncmp+0x2c>
  800908:	8a 08                	mov    (%eax),%cl
  80090a:	84 c9                	test   %cl,%cl
  80090c:	74 04                	je     800912 <strncmp+0x21>
  80090e:	3a 0a                	cmp    (%edx),%cl
  800910:	74 f0                	je     800902 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 00             	movzbl (%eax),%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb f6                	jmp    80091a <strncmp+0x29>

00800924 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092d:	8a 10                	mov    (%eax),%dl
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 07                	je     80093a <strchr+0x16>
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	74 08                	je     80093f <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800937:	40                   	inc    %eax
  800938:	eb f3                	jmp    80092d <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094a:	8a 10                	mov    (%eax),%dl
  80094c:	84 d2                	test   %dl,%dl
  80094e:	74 07                	je     800957 <strfind+0x16>
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 03                	je     800957 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800954:	40                   	inc    %eax
  800955:	eb f3                	jmp    80094a <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 13                	je     80097c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 05                	jne    800976 <memset+0x1d>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	74 0d                	je     800983 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800983:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800987:	89 d3                	mov    %edx,%ebx
  800989:	c1 e3 08             	shl    $0x8,%ebx
  80098c:	89 d0                	mov    %edx,%eax
  80098e:	c1 e0 18             	shl    $0x18,%eax
  800991:	89 d6                	mov    %edx,%esi
  800993:	c1 e6 10             	shl    $0x10,%esi
  800996:	09 f0                	or     %esi,%eax
  800998:	09 c2                	or     %eax,%edx
  80099a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	fc                   	cld    
  8009a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a4:	eb d6                	jmp    80097c <memset+0x23>

008009a6 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	73 33                	jae    8009eb <memmove+0x45>
  8009b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bb:	39 c2                	cmp    %eax,%edx
  8009bd:	76 2c                	jbe    8009eb <memmove+0x45>
		s += n;
		d += n;
  8009bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	09 fe                	or     %edi,%esi
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	74 0a                	je     8009d8 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ce:	4f                   	dec    %edi
  8009cf:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d5:	fc                   	cld    
  8009d6:	eb 21                	jmp    8009f9 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	f6 c1 03             	test   $0x3,%cl
  8009db:	75 f1                	jne    8009ce <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009dd:	83 ef 04             	sub    $0x4,%edi
  8009e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e6:	fd                   	std    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb ea                	jmp    8009d5 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	89 f2                	mov    %esi,%edx
  8009ed:	09 c2                	or     %eax,%edx
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	74 09                	je     8009fd <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f9:	5e                   	pop    %esi
  8009fa:	5f                   	pop    %edi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 f2                	jne    8009f4 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a02:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0a:	eb ed                	jmp    8009f9 <memmove+0x53>

00800a0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0f:	ff 75 10             	pushl  0x10(%ebp)
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	ff 75 08             	pushl  0x8(%ebp)
  800a18:	e8 89 ff ff ff       	call   8009a6 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	89 c6                	mov    %eax,%esi
  800a2c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	39 f0                	cmp    %esi,%eax
  800a31:	74 16                	je     800a49 <memcmp+0x2a>
		if (*s1 != *s2)
  800a33:	8a 08                	mov    (%eax),%cl
  800a35:	8a 1a                	mov    (%edx),%bl
  800a37:	38 d9                	cmp    %bl,%cl
  800a39:	75 04                	jne    800a3f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a3b:	40                   	inc    %eax
  800a3c:	42                   	inc    %edx
  800a3d:	eb f0                	jmp    800a2f <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a3f:	0f b6 c1             	movzbl %cl,%eax
  800a42:	0f b6 db             	movzbl %bl,%ebx
  800a45:	29 d8                	sub    %ebx,%eax
  800a47:	eb 05                	jmp    800a4e <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a60:	39 d0                	cmp    %edx,%eax
  800a62:	73 07                	jae    800a6b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a64:	38 08                	cmp    %cl,(%eax)
  800a66:	74 03                	je     800a6b <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a68:	40                   	inc    %eax
  800a69:	eb f5                	jmp    800a60 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a76:	eb 01                	jmp    800a79 <strtol+0xc>
		s++;
  800a78:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	8a 01                	mov    (%ecx),%al
  800a7b:	3c 20                	cmp    $0x20,%al
  800a7d:	74 f9                	je     800a78 <strtol+0xb>
  800a7f:	3c 09                	cmp    $0x9,%al
  800a81:	74 f5                	je     800a78 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a83:	3c 2b                	cmp    $0x2b,%al
  800a85:	74 2b                	je     800ab2 <strtol+0x45>
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	74 2f                	je     800aba <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a90:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a97:	75 12                	jne    800aab <strtol+0x3e>
  800a99:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9c:	74 24                	je     800ac2 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa2:	75 07                	jne    800aab <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab0:	eb 4e                	jmp    800b00 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800ab2:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	eb d6                	jmp    800a90 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800aba:	41                   	inc    %ecx
  800abb:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac0:	eb ce                	jmp    800a90 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	74 10                	je     800ad8 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800acc:	75 dd                	jne    800aab <strtol+0x3e>
		s++, base = 8;
  800ace:	41                   	inc    %ecx
  800acf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ad6:	eb d3                	jmp    800aab <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ad8:	83 c1 02             	add    $0x2,%ecx
  800adb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ae2:	eb c7                	jmp    800aab <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 24                	ja     800b12 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af4:	39 55 10             	cmp    %edx,0x10(%ebp)
  800af7:	7e 2b                	jle    800b24 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800af9:	41                   	inc    %ecx
  800afa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afe:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b00:	8a 11                	mov    (%ecx),%dl
  800b02:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b05:	80 fb 09             	cmp    $0x9,%bl
  800b08:	77 da                	ja     800ae4 <strtol+0x77>
			dig = *s - '0';
  800b0a:	0f be d2             	movsbl %dl,%edx
  800b0d:	83 ea 30             	sub    $0x30,%edx
  800b10:	eb e2                	jmp    800af4 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b12:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b15:	89 f3                	mov    %esi,%ebx
  800b17:	80 fb 19             	cmp    $0x19,%bl
  800b1a:	77 08                	ja     800b24 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b1c:	0f be d2             	movsbl %dl,%edx
  800b1f:	83 ea 37             	sub    $0x37,%edx
  800b22:	eb d0                	jmp    800af4 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b28:	74 05                	je     800b2f <strtol+0xc2>
		*endptr = (char *) s;
  800b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	74 02                	je     800b35 <strtol+0xc8>
  800b33:	f7 d8                	neg    %eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
	...

00800b3c <__udivdi3>:
  800b3c:	55                   	push   %ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 1c             	sub    $0x1c,%esp
  800b43:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b47:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b4f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b53:	85 d2                	test   %edx,%edx
  800b55:	75 2d                	jne    800b84 <__udivdi3+0x48>
  800b57:	39 f7                	cmp    %esi,%edi
  800b59:	77 59                	ja     800bb4 <__udivdi3+0x78>
  800b5b:	89 f9                	mov    %edi,%ecx
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	75 0b                	jne    800b6c <__udivdi3+0x30>
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	31 d2                	xor    %edx,%edx
  800b68:	f7 f7                	div    %edi
  800b6a:	89 c1                	mov    %eax,%ecx
  800b6c:	31 d2                	xor    %edx,%edx
  800b6e:	89 f0                	mov    %esi,%eax
  800b70:	f7 f1                	div    %ecx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 e8                	mov    %ebp,%eax
  800b76:	f7 f1                	div    %ecx
  800b78:	89 da                	mov    %ebx,%edx
  800b7a:	83 c4 1c             	add    $0x1c,%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    
  800b82:	66 90                	xchg   %ax,%ax
  800b84:	39 f2                	cmp    %esi,%edx
  800b86:	77 1c                	ja     800ba4 <__udivdi3+0x68>
  800b88:	0f bd da             	bsr    %edx,%ebx
  800b8b:	83 f3 1f             	xor    $0x1f,%ebx
  800b8e:	75 38                	jne    800bc8 <__udivdi3+0x8c>
  800b90:	39 f2                	cmp    %esi,%edx
  800b92:	72 08                	jb     800b9c <__udivdi3+0x60>
  800b94:	39 ef                	cmp    %ebp,%edi
  800b96:	0f 87 98 00 00 00    	ja     800c34 <__udivdi3+0xf8>
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	eb 05                	jmp    800ba8 <__udivdi3+0x6c>
  800ba3:	90                   	nop
  800ba4:	31 db                	xor    %ebx,%ebx
  800ba6:	31 c0                	xor    %eax,%eax
  800ba8:	89 da                	mov    %ebx,%edx
  800baa:	83 c4 1c             	add    $0x1c,%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
  800bb2:	66 90                	xchg   %ax,%ax
  800bb4:	89 e8                	mov    %ebp,%eax
  800bb6:	89 f2                	mov    %esi,%edx
  800bb8:	f7 f7                	div    %edi
  800bba:	31 db                	xor    %ebx,%ebx
  800bbc:	89 da                	mov    %ebx,%edx
  800bbe:	83 c4 1c             	add    $0x1c,%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    
  800bc6:	66 90                	xchg   %ax,%ax
  800bc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bcd:	29 d8                	sub    %ebx,%eax
  800bcf:	88 d9                	mov    %bl,%cl
  800bd1:	d3 e2                	shl    %cl,%edx
  800bd3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bd7:	89 fa                	mov    %edi,%edx
  800bd9:	88 c1                	mov    %al,%cl
  800bdb:	d3 ea                	shr    %cl,%edx
  800bdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800be1:	09 d1                	or     %edx,%ecx
  800be3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800be7:	88 d9                	mov    %bl,%cl
  800be9:	d3 e7                	shl    %cl,%edi
  800beb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	88 c1                	mov    %al,%cl
  800bf3:	d3 ef                	shr    %cl,%edi
  800bf5:	88 d9                	mov    %bl,%cl
  800bf7:	d3 e6                	shl    %cl,%esi
  800bf9:	89 ea                	mov    %ebp,%edx
  800bfb:	88 c1                	mov    %al,%cl
  800bfd:	d3 ea                	shr    %cl,%edx
  800bff:	09 d6                	or     %edx,%esi
  800c01:	89 f0                	mov    %esi,%eax
  800c03:	89 fa                	mov    %edi,%edx
  800c05:	f7 74 24 08          	divl   0x8(%esp)
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	f7 64 24 0c          	mull   0xc(%esp)
  800c11:	39 d7                	cmp    %edx,%edi
  800c13:	72 13                	jb     800c28 <__udivdi3+0xec>
  800c15:	74 09                	je     800c20 <__udivdi3+0xe4>
  800c17:	89 f0                	mov    %esi,%eax
  800c19:	31 db                	xor    %ebx,%ebx
  800c1b:	eb 8b                	jmp    800ba8 <__udivdi3+0x6c>
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	88 d9                	mov    %bl,%cl
  800c22:	d3 e5                	shl    %cl,%ebp
  800c24:	39 c5                	cmp    %eax,%ebp
  800c26:	73 ef                	jae    800c17 <__udivdi3+0xdb>
  800c28:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c2b:	31 db                	xor    %ebx,%ebx
  800c2d:	e9 76 ff ff ff       	jmp    800ba8 <__udivdi3+0x6c>
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	31 c0                	xor    %eax,%eax
  800c36:	e9 6d ff ff ff       	jmp    800ba8 <__udivdi3+0x6c>
	...

00800c3c <__umoddi3>:
  800c3c:	55                   	push   %ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 1c             	sub    $0x1c,%esp
  800c43:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c47:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c4f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	89 da                	mov    %ebx,%edx
  800c57:	85 ed                	test   %ebp,%ebp
  800c59:	75 15                	jne    800c70 <__umoddi3+0x34>
  800c5b:	39 df                	cmp    %ebx,%edi
  800c5d:	76 39                	jbe    800c98 <__umoddi3+0x5c>
  800c5f:	f7 f7                	div    %edi
  800c61:	89 d0                	mov    %edx,%eax
  800c63:	31 d2                	xor    %edx,%edx
  800c65:	83 c4 1c             	add    $0x1c,%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	39 dd                	cmp    %ebx,%ebp
  800c72:	77 f1                	ja     800c65 <__umoddi3+0x29>
  800c74:	0f bd cd             	bsr    %ebp,%ecx
  800c77:	83 f1 1f             	xor    $0x1f,%ecx
  800c7a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c7e:	75 38                	jne    800cb8 <__umoddi3+0x7c>
  800c80:	39 dd                	cmp    %ebx,%ebp
  800c82:	72 04                	jb     800c88 <__umoddi3+0x4c>
  800c84:	39 f7                	cmp    %esi,%edi
  800c86:	77 dd                	ja     800c65 <__umoddi3+0x29>
  800c88:	89 da                	mov    %ebx,%edx
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	29 f8                	sub    %edi,%eax
  800c8e:	19 ea                	sbb    %ebp,%edx
  800c90:	83 c4 1c             	add    $0x1c,%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
  800c98:	89 f9                	mov    %edi,%ecx
  800c9a:	85 ff                	test   %edi,%edi
  800c9c:	75 0b                	jne    800ca9 <__umoddi3+0x6d>
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f7                	div    %edi
  800ca7:	89 c1                	mov    %eax,%ecx
  800ca9:	89 d8                	mov    %ebx,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f1                	div    %ecx
  800caf:	89 f0                	mov    %esi,%eax
  800cb1:	f7 f1                	div    %ecx
  800cb3:	eb ac                	jmp    800c61 <__umoddi3+0x25>
  800cb5:	8d 76 00             	lea    0x0(%esi),%esi
  800cb8:	b8 20 00 00 00       	mov    $0x20,%eax
  800cbd:	89 c2                	mov    %eax,%edx
  800cbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cc3:	29 c2                	sub    %eax,%edx
  800cc5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc9:	88 c1                	mov    %al,%cl
  800ccb:	d3 e5                	shl    %cl,%ebp
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	88 d1                	mov    %dl,%cl
  800cd1:	d3 e8                	shr    %cl,%eax
  800cd3:	09 c5                	or     %eax,%ebp
  800cd5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cd9:	88 c1                	mov    %al,%cl
  800cdb:	d3 e7                	shl    %cl,%edi
  800cdd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	88 d1                	mov    %dl,%cl
  800ce5:	d3 ef                	shr    %cl,%edi
  800ce7:	88 c1                	mov    %al,%cl
  800ce9:	d3 e3                	shl    %cl,%ebx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	88 d1                	mov    %dl,%cl
  800cef:	d3 e8                	shr    %cl,%eax
  800cf1:	09 d8                	or     %ebx,%eax
  800cf3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cf7:	d3 e6                	shl    %cl,%esi
  800cf9:	89 fa                	mov    %edi,%edx
  800cfb:	f7 f5                	div    %ebp
  800cfd:	89 d1                	mov    %edx,%ecx
  800cff:	f7 64 24 08          	mull   0x8(%esp)
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	89 d7                	mov    %edx,%edi
  800d07:	39 d1                	cmp    %edx,%ecx
  800d09:	72 29                	jb     800d34 <__umoddi3+0xf8>
  800d0b:	74 23                	je     800d30 <__umoddi3+0xf4>
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	29 de                	sub    %ebx,%esi
  800d11:	19 fa                	sbb    %edi,%edx
  800d13:	89 d0                	mov    %edx,%eax
  800d15:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d19:	d3 e0                	shl    %cl,%eax
  800d1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d1f:	88 d9                	mov    %bl,%cl
  800d21:	d3 ee                	shr    %cl,%esi
  800d23:	09 f0                	or     %esi,%eax
  800d25:	d3 ea                	shr    %cl,%edx
  800d27:	83 c4 1c             	add    $0x1c,%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop
  800d30:	39 c6                	cmp    %eax,%esi
  800d32:	73 d9                	jae    800d0d <__umoddi3+0xd1>
  800d34:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d38:	19 ea                	sbb    %ebp,%edx
  800d3a:	89 d7                	mov    %edx,%edi
  800d3c:	89 c3                	mov    %eax,%ebx
  800d3e:	eb cd                	jmp    800d0d <__umoddi3+0xd1>
